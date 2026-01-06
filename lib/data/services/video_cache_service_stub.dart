import 'package:flutter/foundation.dart';

/// 動画キャッシュサービスのスタブ実装
/// サポートされていないプラットフォーム用
class VideoCacheServiceWeb {
  Future<void> init() {
    throw UnsupportedError(
      'Video cache service is not supported on this platform',
    );
  }

  Future<bool> isCached(String videoFileId) {
    return Future.value(false);
  }

  Future<String?> getCachedVideoUrl(String videoFileId) {
    return Future.value();
  }

  Future<void> cacheVideo(String videoFileId, Uint8List data) {
    throw UnsupportedError(
      'Video cache service is not supported on this platform',
    );
  }

  Future<void> clearOldCache() {
    return Future.value();
  }

  Future<void> clearAllCache() {
    return Future.value();
  }

  Future<void> dispose() {
    return Future.value();
  }
}
