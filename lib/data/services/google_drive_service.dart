import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/exceptions.dart';

/// Google Drive API低レベル操作サービス
/// API呼び出しとエラーハンドリングを担当
class GoogleDriveService {
  GoogleDriveService({
    required GoogleSignIn googleSignIn,
    http.Client? httpClient,
    String? Function()? webAccessTokenProvider,
  }) : _googleSignIn = googleSignIn,
       _httpClient = httpClient ?? http.Client(),
       _webAccessTokenProvider = webAccessTokenProvider;

  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;
  final String? Function()? _webAccessTokenProvider;

  static const String _baseUrl = 'https://www.googleapis.com/drive/v3';

  /// Google Drive APIのアクセストークンを取得
  /// トークンが期限切れの場合は自動更新を試みる
  /// スコープが不足している場合は再認証をリクエスト
  Future<String> getAccessToken() async {
    try {
      debugPrint('[GoogleDriveService] アクセストークン取得開始');
      debugPrint('[GoogleDriveService] プラットフォーム: ${kIsWeb ? "Web" : "Mobile"}');

      // Web版の場合は、AuthRepositoryから提供されたアクセストークンを使用
      if (kIsWeb) {
        debugPrint('[GoogleDriveService] Web版: AuthRepositoryからアクセストークンを取得');

        if (_webAccessTokenProvider == null) {
          debugPrint('[GoogleDriveService] エラー: webAccessTokenProviderがnull');
          throw UnauthorizedException(
            'Web版のアクセストークンプロバイダーが設定されていません。\n'
            'アプリの設定エラーです。',
          );
        }

        final accessToken = _webAccessTokenProvider();
        debugPrint('[GoogleDriveService] Web版アクセストークン: ${accessToken != null ? "存在する" : "null"}');

        if (accessToken == null || accessToken.isEmpty) {
          debugPrint('[GoogleDriveService] エラー: Web版アクセストークンがnullまたは空');
          throw UnauthorizedException(
            'Google Driveへのアクセス権限が不足しています。\n'
            'アプリからログアウトして、再度ログインしてください。',
          );
        }

        debugPrint('[GoogleDriveService] Web版: アクセストークン取得成功 (長さ: ${accessToken.length})');
        return accessToken;
      }

      // モバイル版の場合は、authorizationClientを使用
      debugPrint('[GoogleDriveService] モバイル版: authorizationClientを使用');

      // google_sign_in 7.x: authorizationClientを使用してaccessTokenを取得
      final authClient = _googleSignIn.authorizationClient;
      debugPrint('[GoogleDriveService] authClient取得: 成功');

      // Google Driveのscopesに対する認可を取得
      // authorizationForScopes()は不足しているスコープがあれば自動的に追加認証をトリガー
      debugPrint('[GoogleDriveService] authorizationForScopes呼び出し開始');
      final authorization = await authClient.authorizationForScopes([
        'https://www.googleapis.com/auth/drive.readonly',
      ]);

      debugPrint('[GoogleDriveService] authorization取得: ${authorization != null}');
      debugPrint('[GoogleDriveService] accessToken: ${authorization?.accessToken != null ? "存在する" : "null"}');

      final accessToken = authorization?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        // アクセストークンが取得できない場合、ユーザーに再ログインを促す
        debugPrint('[GoogleDriveService] エラー: アクセストークンがnullまたは空');
        throw UnauthorizedException(
          'Google Driveへのアクセス権限が不足しています。\n'
          'アプリからログアウトして、再度ログインしてください。',
        );
      }

      debugPrint('[GoogleDriveService] モバイル版: アクセストークン取得成功 (長さ: ${accessToken.length})');
      return accessToken;
    } on UnauthorizedException catch (e) {
      // UnauthorizedExceptionはそのまま再スロー
      debugPrint('[GoogleDriveService] UnauthorizedException: ${e.message}');
      rethrow;
    } on Exception catch (e, stackTrace) {
      // その他のエラーは権限不足として扱う
      debugPrint('[GoogleDriveService] エラー: $e');
      debugPrint('[GoogleDriveService] スタックトレース: $stackTrace');
      throw UnauthorizedException(
        'Google Driveへのアクセス権限の取得に失敗しました。\n'
        'アプリからログアウトして、再度ログインしてください。\n'
        'エラー: $e',
      );
    }
  }

  /// ファイルを文字列としてダウンロード（設定ファイル用）
  Future<String> downloadFileAsString(String fileId) async {
    try {
      debugPrint('[GoogleDriveService] ファイルダウンロード開始 (String): $fileId');
      final bytes = await downloadFileAsBytes(fileId);
      final content = utf8.decode(bytes);
      debugPrint('[GoogleDriveService] ファイルダウンロード成功 (String): $fileId');
      return content;
    } on Exception catch (e, stackTrace) {
      debugPrint('[GoogleDriveService] ファイルダウンロード失敗 (String): $fileId');
      debugPrint('[GoogleDriveService] エラー: $e');
      debugPrint('[GoogleDriveService] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// ファイルをバイト配列としてダウンロード（画像・動画用）
  Future<List<int>> downloadFileAsBytes(String fileId) async {
    try {
      debugPrint('[GoogleDriveService] ファイルダウンロード開始 (Bytes): $fileId');
      final token = await getAccessToken();
      final url = Uri.parse('$_baseUrl/files/$fileId?alt=media');

      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, fileId);

      debugPrint('[GoogleDriveService] ファイルダウンロード成功 (Bytes): $fileId, サイズ: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
    } on Exception catch (e, stackTrace) {
      debugPrint('[GoogleDriveService] ファイルダウンロード失敗 (Bytes): $fileId');
      debugPrint('[GoogleDriveService] エラー: $e');
      debugPrint('[GoogleDriveService] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// ファイルメタデータを取得
  Future<Map<String, dynamic>> getFileMetadata(String fileId) async {
    try {
      debugPrint('[GoogleDriveService] メタデータ取得開始: $fileId');
      final token = await getAccessToken();
      final url = Uri.parse(
        '$_baseUrl/files/$fileId?fields=id,name,mimeType,size,modifiedTime,createdTime,parents',
      );

      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, fileId);

      final metadata = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('[GoogleDriveService] メタデータ取得成功: $fileId, name: ${metadata['name']}');
      return metadata;
    } on Exception catch (e, stackTrace) {
      debugPrint('[GoogleDriveService] メタデータ取得失敗: $fileId');
      debugPrint('[GoogleDriveService] エラー: $e');
      debugPrint('[GoogleDriveService] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// フォルダ内のファイル一覧を取得
  /// [folderId] 親フォルダのID
  /// [mimeTypeFilter] MIMEタイプでフィルタ（例: 'video/mp4'）
  Future<List<Map<String, dynamic>>> listFilesInFolder(
    String folderId, {
    String? mimeTypeFilter,
  }) async {
    try {
      debugPrint('[GoogleDriveService] フォルダ内ファイル一覧取得開始: $folderId');
      final token = await getAccessToken();

      // クエリの構築
      var query = "'$folderId' in parents";
      if (mimeTypeFilter != null) {
        query += " and mimeType='$mimeTypeFilter'";
      }
      // トラッシュを除外
      query += ' and trashed=false';

      debugPrint('[GoogleDriveService] クエリ: $query');

      final url = Uri.parse(
        '$_baseUrl/files?q=${Uri.encodeComponent(query)}&fields=files(id,name,mimeType,createdTime,modifiedTime)&pageSize=100',
      );

      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[GoogleDriveService] フォルダ内ファイル一覧取得失敗: ${response.statusCode}');
        throw DriveApiException(
          'フォルダ内のファイル一覧取得に失敗しました: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final files = data['files'] as List<dynamic>?;

      if (files == null) {
        debugPrint('[GoogleDriveService] フォルダ内ファイル一覧: 0件');
        return [];
      }

      debugPrint('[GoogleDriveService] フォルダ内ファイル一覧取得成功: ${files.length}件');
      return files.cast<Map<String, dynamic>>();
    } on Exception catch (e, stackTrace) {
      debugPrint('[GoogleDriveService] フォルダ内ファイル一覧取得失敗: $folderId');
      debugPrint('[GoogleDriveService] エラー: $e');
      debugPrint('[GoogleDriveService] スタックトレース: $stackTrace');
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
