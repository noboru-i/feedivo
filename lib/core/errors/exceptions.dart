/// カスタム例外の定義
/// アプリケーション全体で使用するエラー型
library;

/// ネットワーク接続エラー
class NetworkException implements Exception {
  NetworkException([this.message = 'ネットワークに接続できません']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// 認証エラー
class UnauthorizedException implements Exception {
  UnauthorizedException([this.message = '認証が必要です']);
  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// アクセストークン期限切れエラー
class TokenExpiredException implements Exception {
  TokenExpiredException([this.message = 'アクセストークンの有効期限が切れました']);
  final String message;

  @override
  String toString() => 'TokenExpiredException: $message';
}

/// Google Drive APIエラー
class DriveApiException implements Exception {
  DriveApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode != null) {
      return 'DriveApiException ($statusCode): $message';
    }
    return 'DriveApiException: $message';
  }
}

/// 設定ファイルフォーマット不正エラー
class InvalidConfigException implements Exception {
  InvalidConfigException(this.message);
  final String message;

  @override
  String toString() => 'InvalidConfigException: $message';
}

/// Firestoreエラー
class FirestoreException implements Exception {
  FirestoreException(this.message);
  final String message;

  @override
  String toString() => 'FirestoreException: $message';
}

/// ファイルが見つからないエラー
class FileNotFoundException implements Exception {
  FileNotFoundException(this.fileId);
  final String fileId;

  @override
  String toString() => 'FileNotFoundException: ファイルが見つかりません (File ID: $fileId)';
}

/// アクセス権限不足エラー
class PermissionDeniedException implements Exception {
  PermissionDeniedException(this.fileId);
  final String fileId;

  @override
  String toString() =>
      'PermissionDeniedException: ファイルへのアクセス権限がありません (File ID: $fileId)';
}
