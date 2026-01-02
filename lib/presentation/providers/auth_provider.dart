import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

/// 認証状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository) {
    _initialize();
  }
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// 初期化：現在のユーザーを取得し、認証状態の変更を監視
  Future<void> _initialize() async {
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();

    // 認証状態の変更を監視
    _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });

    // Web版: Google Sign-in authenticationEventsを監視
    if (kIsWeb) {
      print('[AuthProvider] Web版: authenticationEventsのリスニング開始');
      GoogleSignIn.instance.authenticationEvents.listen((event) async {
        print('[AuthProvider] authenticationEventを受信: $event');

        try {
          final googleUser = switch (event) {
            GoogleSignInAuthenticationEventSignIn() => event.user,
            _ => null,
          };

          if (googleUser != null) {
            print('[AuthProvider] Googleユーザー: ${googleUser.displayName}');

            // Google認証情報を取得 (v7.xでは同期的)
            final googleAuth = googleUser.authentication;
            print('[AuthProvider] idToken取得: ${googleAuth.idToken != null}');

            // Firebase認証クレデンシャルを作成
            final credential = firebase_auth.GoogleAuthProvider.credential(
              idToken: googleAuth.idToken,
            );

            print('[AuthProvider] Firebaseサインイン開始');
            // Firebaseにサインイン
            final userCredential = await firebase_auth.FirebaseAuth.instance
                .signInWithCredential(credential);

            print('[AuthProvider] Firebaseサインイン成功');
            // ユーザー情報を処理
            final user = await _authRepository.handleWebAuthentication(
              userCredential,
            );

            _currentUser = user;
            print('[AuthProvider] currentUserを更新: ${user?.displayName}');
            notifyListeners();
          }
        } on Exception catch (e) {
          print('[AuthProvider] Web認証エラー: $e');
          _errorMessage = 'Web認証に失敗しました: $e';
          notifyListeners();
        }
      });
    }
  }

  /// Googleアカウントでサインイン
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'サインインに失敗しました: $e';
      notifyListeners();
      return false;
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'サインアウトに失敗しました: $e';
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Web版: signInWithPopupの結果を処理
  Future<void> handleWebSignInResult(
    firebase_auth.UserCredential userCredential,
  ) async {
    try {
      debugPrint('[AuthProvider] Web版サインイン結果を処理中');

      // ユーザー情報を処理
      final user = await _authRepository.handleWebAuthentication(userCredential);
      _currentUser = user;
      _errorMessage = null;

      debugPrint('[AuthProvider] Web版サインイン成功: ${user?.displayName}');
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('[AuthProvider] Web版サインイン処理エラー: $e');
      _errorMessage = 'ログイン処理に失敗しました: $e';
      notifyListeners();
    }
  }
}
