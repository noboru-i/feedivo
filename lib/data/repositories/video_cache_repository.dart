import 'package:flutter/foundation.dart';

import '../services/google_drive_service.dart';
import '../services/video_cache_service.dart';

/// 動画キャッシュリポジトリ
/// プラットフォーム分岐（Web/モバイル）とキャッシュ戦略を管理
class VideoCacheRepository {
  VideoCacheRepository({
    required GoogleDriveService googleDriveService,
    VideoCacheServiceWeb? videoCacheServiceWeb,
  }) : _googleDriveService = googleDriveService,
       _videoCacheServiceWeb = videoCacheServiceWeb;

  final GoogleDriveService _googleDriveService;
  final VideoCacheServiceWeb? _videoCacheServiceWeb;

  /// 動画URLを取得
  /// Web版: IndexedDBからBlob URLを取得、なければダウンロードしてキャッシュ
  /// モバイル版: nullを返す（ストリーミング再生を使用）
  Future<String?> getOrCacheVideoUrl(String videoFileId) async {
    // モバイル版ではnullを返す（ストリーミング再生を使用）
    if (!kIsWeb) {
      debugPrint(
        '[VideoCacheRepository] モバイル版: ストリーミング再生を使用',
      );
      return null;
    }

    // Web版: IndexedDBキャッシュを使用
    try {
      debugPrint(
        '[VideoCacheRepository] Web版: 動画URL取得開始: $videoFileId',
      );

      // VideoCacheServiceWebが初期化されていない場合は初期化
      if (_videoCacheServiceWeb == null) {
        debugPrint('[VideoCacheRepository] エラー: VideoCacheServiceWebがnull');
        throw Exception('VideoCacheServiceWebが初期化されていません');
      }

      // キャッシュから取得を試みる
      final cachedUrl = await _videoCacheServiceWeb.getCachedVideoUrl(
        videoFileId,
      );

      if (cachedUrl != null) {
        debugPrint(
          '[VideoCacheRepository] キャッシュヒット: $videoFileId',
        );
        return cachedUrl;
      }

      // キャッシュにない場合はダウンロード
      debugPrint(
        '[VideoCacheRepository] キャッシュミス: ダウンロード開始: $videoFileId',
      );

      final data = await _downloadVideo(videoFileId);

      // キャッシュに保存
      await _videoCacheServiceWeb.cacheVideo(videoFileId, data);

      // Blob URLを生成して返す
      final blobUrl = await _videoCacheServiceWeb.getCachedVideoUrl(
        videoFileId,
      );

      debugPrint(
        '[VideoCacheRepository] ダウンロード完了、キャッシュに保存: $videoFileId',
      );

      return blobUrl;
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheRepository] 動画URL取得失敗: $e');
      debugPrint('[VideoCacheRepository] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// Google Driveから動画をダウンロード
  Future<Uint8List> _downloadVideo(String videoFileId) async {
    try {
      debugPrint(
        '[VideoCacheRepository] Google Driveから動画ダウンロード: $videoFileId',
      );

      final bytes = await _googleDriveService.downloadFileAsBytes(videoFileId);

      debugPrint(
        '[VideoCacheRepository] Google Driveから動画ダウンロード完了: $videoFileId, サイズ: ${bytes.length} bytes',
      );

      return Uint8List.fromList(bytes);
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheRepository] Google Driveダウンロード失敗: $e');
      debugPrint('[VideoCacheRepository] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// キャッシュが存在するかチェック
  Future<bool> isCached(String videoFileId) async {
    if (!kIsWeb || _videoCacheServiceWeb == null) {
      return false;
    }

    return _videoCacheServiceWeb.isCached(videoFileId);
  }

  /// すべてのキャッシュをクリア
  Future<void> clearCache() async {
    if (!kIsWeb || _videoCacheServiceWeb == null) {
      debugPrint('[VideoCacheRepository] モバイル版: キャッシュクリアなし');
      return;
    }

    try {
      debugPrint('[VideoCacheRepository] キャッシュクリア開始');
      await _videoCacheServiceWeb.clearAllCache();
      debugPrint('[VideoCacheRepository] キャッシュクリア完了');
    } on Exception catch (e) {
      debugPrint('[VideoCacheRepository] キャッシュクリア失敗: $e');
      rethrow;
    }
  }

  /// リソースの破棄
  Future<void> dispose() async {
    if (kIsWeb && _videoCacheServiceWeb != null) {
      await _videoCacheServiceWeb.dispose();
    }
  }
}
