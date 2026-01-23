import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/constants.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// 認証リポジトリの実装
/// Firebase AuthenticationとGoogle Sign-Inを使用
class AuthRepository {
  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  // Web版で取得したアクセストークンを保存
  String? _webAccessToken;

  // Web版アクセストークンの有効期限（50分後に設定）
  DateTime? _webAccessTokenExpiresAt;

  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final userModel = UserModel.fromFirebaseUser(firebaseUser);
    return userModel.toEntity();
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web版: renderButton()を使用してサインイン
        // authenticationEventsをリッスンする必要がある
        // この処理はAuthProviderで行う
        throw UnimplementedError(
          'Web版ではrenderButton()とauthenticationEventsを使用してください',
        );
      }

      // モバイル版: Google Sign-in フロー (v7.x)
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: AppConstants.googleScopes,
      );

      // scopeの認可を取得してaccessTokenを取得
      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizationForScopes(
        AppConstants.googleScopes,
      );

      // Google認証情報を取得 (v7.xでは同期的)
      final googleAuth = googleUser.authentication;

      // Firebase認証クレデンシャルを作成
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseにサインイン
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return null;
      }

      // UserModelに変換
      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      // Firestoreにユーザー情報を保存（初回のみ）
      await _saveUserToFirestore(userModel);

      return userModel.toEntity();
    } on Exception catch (e) {
      // エラーハンドリング
      print('Google Sign-in error: $e');
      rethrow;
    }
  }

  /// Web版: authenticationEventsからユーザーを処理
  Future<User?> handleWebAuthentication(
    firebase_auth.UserCredential userCredential,
  ) async {
    try {
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return null;
      }

      // OAuthCredentialからアクセストークンを取得（Web版のみ）
      if (kIsWeb &&
          userCredential.credential is firebase_auth.OAuthCredential) {
        final oauthCredential =
            userCredential.credential! as firebase_auth.OAuthCredential;
        _webAccessToken = oauthCredential.accessToken;
        // トークン有効期限を50分後に設定（Google OAuthトークンは約1時間有効）
        _webAccessTokenExpiresAt = DateTime.now().add(const Duration(minutes: 50));
        print('[AuthRepository] Web版アクセストークン保存: ${_webAccessToken != null}');
        print('[AuthRepository] トークン有効期限: $_webAccessTokenExpiresAt');
      }

      // UserModelに変換
      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      // Firestoreにユーザー情報を保存（初回のみ）
      await _saveUserToFirestore(userModel);

      return userModel.toEntity();
    } on Exception catch (e) {
      print('Web authentication handling error: $e');
      rethrow;
    }
  }

  /// Web版: 保存されたアクセストークンを取得
  String? getWebAccessToken() {
    if (!kIsWeb) {
      return null;
    }
    return _webAccessToken;
  }

  /// Web版: アクセストークンが期限切れかどうかをチェック
  bool isWebAccessTokenExpired() {
    if (!kIsWeb) {
      return false;
    }
    if (_webAccessToken == null || _webAccessTokenExpiresAt == null) {
      return true;
    }
    return DateTime.now().isAfter(_webAccessTokenExpiresAt!);
  }

  /// Web版: アクセストークンをクリア（期限切れ時にUIから呼び出される）
  void clearWebAccessToken() {
    _webAccessToken = null;
    _webAccessTokenExpiresAt = null;
    print('[AuthRepository] Web版アクセストークンをクリア');
  }

  /// Web版: アクセストークンをリフレッシュ（再認証が必要）
  /// ユーザーインタラクション（ポップアップ）が必要なため、UIから呼び出す
  Future<void> refreshWebAccessToken() async {
    if (!kIsWeb) {
      return;
    }

    try {
      print('[AuthRepository] Web版アクセストークンリフレッシュ開始');

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      // 再認証用のプロバイダーを作成
      final provider = firebase_auth.GoogleAuthProvider()
        ..addScope('https://www.googleapis.com/auth/drive.readonly');

      // reauthenticateWithPopupで再認証
      final userCredential = await currentUser.reauthenticateWithPopup(provider);

      // 新しいトークンを保存
      if (userCredential.credential is firebase_auth.OAuthCredential) {
        final oauthCredential =
            userCredential.credential! as firebase_auth.OAuthCredential;
        _webAccessToken = oauthCredential.accessToken;
        _webAccessTokenExpiresAt = DateTime.now().add(const Duration(minutes: 50));
        print('[AuthRepository] Web版アクセストークンリフレッシュ成功');
        print('[AuthRepository] 新しい有効期限: $_webAccessTokenExpiresAt');
      }
    } on Exception catch (e) {
      print('[AuthRepository] Web版アクセストークンリフレッシュ失敗: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Web版: トークンをクリア
      _webAccessToken = null;
      _webAccessTokenExpiresAt = null;

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Sign-out error: $e');
      rethrow;
    }
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      return userModel.toEntity();
    });
  }

  /// Firestoreにユーザー情報を保存
  Future<void> _saveUserToFirestore(UserModel userModel) async {
    try {
      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userModel.uid);

      // ドキュメントが存在するか確認
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // 新規ユーザーの場合のみ保存
        await userDoc.set({
          ...userModel.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 既存ユーザーの場合は更新
        await userDoc.update({
          'displayName': userModel.displayName,
          'photoUrl': userModel.photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on Exception catch (e) {
      print('Error saving user to Firestore: $e');
      // Firestoreへの保存エラーは致命的ではないので、続行
    }
  }
}
