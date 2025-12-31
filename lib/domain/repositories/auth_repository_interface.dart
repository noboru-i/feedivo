import '../entities/user.dart';

/// 認証リポジトリのインターフェース
/// Domain層ではインターフェースのみを定義し、実装はData層に委ねる
abstract class IAuthRepository {
  /// 現在のユーザーを取得
  Future<User?> getCurrentUser();

  /// Googleアカウントでサインイン
  Future<User?> signInWithGoogle();

  /// サインアウト
  Future<void> signOut();

  /// 認証状態の変更を監視
  Stream<User?> authStateChanges();
}
