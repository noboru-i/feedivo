import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository_interface.dart';

/// 認証状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository) {
    _initialize();
  }
  final IAuthRepository _authRepository;

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
}
