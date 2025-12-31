import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

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
      // Google Sign-in フロー (v7.x)
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

  Future<void> signOut() async {
    try {
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
