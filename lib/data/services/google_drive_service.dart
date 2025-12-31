import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/exceptions.dart';

/// Google Drive API低レベル操作サービス
/// API呼び出しとエラーハンドリングを担当
class GoogleDriveService {
  GoogleDriveService({
    required GoogleSignIn googleSignIn,
    http.Client? httpClient,
  }) : _googleSignIn = googleSignIn,
       _httpClient = httpClient ?? http.Client();
  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;

  static const String _baseUrl = 'https://www.googleapis.com/drive/v3';

  /// Google Drive APIのアクセストークンを取得
  /// トークンが期限切れの場合は自動更新を試みる
  Future<String> getAccessToken() async {
    try {
      // google_sign_in 7.x: authorizationClientを使用してaccessTokenを取得
      final authClient = _googleSignIn.authorizationClient;

      // Google Driveのscopesに対する認可を取得
      final authorization = await authClient.authorizationForScopes([
        'https://www.googleapis.com/auth/drive.file',
      ]);

      final accessToken = authorization?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw UnauthorizedException('ログインしていないか、権限が不足しています');
      }

      return accessToken;
    } on Exception {
      rethrow;
    }
  }

  /// ファイルを文字列としてダウンロード（設定ファイル用）
  Future<String> downloadFileAsString(String fileId) async {
    try {
      final bytes = await downloadFileAsBytes(fileId);
      return utf8.decode(bytes);
    } on Exception {
      rethrow;
    }
  }

  /// ファイルをバイト配列としてダウンロード（画像・動画用）
  Future<List<int>> downloadFileAsBytes(String fileId) async {
    try {
      final token = await getAccessToken();
      final url = Uri.parse('$_baseUrl/files/$fileId?alt=media');

      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, fileId);

      return response.bodyBytes;
    } on Exception {
      rethrow;
    }
  }

  /// ファイルメタデータを取得
  Future<Map<String, dynamic>> getFileMetadata(String fileId) async {
    try {
      final token = await getAccessToken();
      final url = Uri.parse(
        '$_baseUrl/files/$fileId?fields=id,name,mimeType,size,modifiedTime,createdTime',
      );

      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, fileId);

      return json.decode(response.body) as Map<String, dynamic>;
    } on Exception {
      rethrow;
    }
  }

  /// URLまたはFile IDからFile IDを抽出
  /// 共有URL例: https://drive.google.com/file/d/FILE_ID/view
  String extractFileId(String input) {
    // すでにFile IDの形式の場合はそのまま返す
    final fileIdPattern = RegExp(r'^[a-zA-Z0-9_-]{20,}$');
    if (fileIdPattern.hasMatch(input)) {
      return input;
    }

    // URLからFile IDを抽出
    final urlPattern = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = urlPattern.firstMatch(input);
    if (match != null) {
      return match.group(1)!;
    }

    // マッチしない場合はそのまま返す（エラーは呼び出し側で処理）
    return input;
  }

  /// HTTPレスポンスのエラーハンドリング
  void _handleHttpError(http.Response response, String fileId) {
    if (response.statusCode == 200) {
      return;
    }

    switch (response.statusCode) {
      case 401:
        throw TokenExpiredException('アクセストークンが無効です');
      case 403:
        throw PermissionDeniedException(fileId);
      case 404:
        throw FileNotFoundException(fileId);
      case 429:
        throw DriveApiException(
          'APIリクエスト制限に達しました。しばらく待ってから再試行してください。',
          statusCode: 429,
        );
      default:
        throw DriveApiException(
          'ファイルの取得に失敗しました: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  /// リソースの破棄
  void dispose() {
    _httpClient.close();
  }
}
