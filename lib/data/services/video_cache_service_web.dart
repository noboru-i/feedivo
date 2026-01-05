import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:web/web.dart' as web;

/// Web版動画キャッシュサービス
/// IndexedDBを使用して動画ファイルをローカルにキャッシュ
class VideoCacheServiceWeb {
  VideoCacheServiceWeb() {
    _idbFactory = getIdbFactory()!;
  }

  late final IdbFactory _idbFactory;
  Database? _db;

  static const String _dbName = 'feedivo_video_cache';
  static const String _storeName = 'videos';
  static const int _dbVersion = 1;

  // キャッシュ容量上限: 1GB
  static const int _maxCacheSizeBytes = 1024 * 1024 * 1024;

  // 古いキャッシュの削除期間: 30日
  static const int _cacheExpirationDays = 30;

  /// IndexedDBを初期化
  Future<void> init() async {
    try {
      debugPrint('[VideoCacheServiceWeb] IndexedDB初期化開始');

      _db = await _idbFactory.open(
        _dbName,
        version: _dbVersion,
        onUpgradeNeeded: (VersionChangeEvent event) {
          final db = event.database;
          debugPrint('[VideoCacheServiceWeb] オブジェクトストア作成');

          // オブジェクトストア作成
          if (!db.objectStoreNames.contains(_storeName)) {
            db.createObjectStore(_storeName);
          }
        },
      );

      debugPrint('[VideoCacheServiceWeb] IndexedDB初期化完了');

      // 起動時に古いキャッシュを削除
      await clearOldCache();
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheServiceWeb] IndexedDB初期化失敗: $e');
      debugPrint('[VideoCacheServiceWeb] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// キャッシュが存在するかチェック
  Future<bool> isCached(String videoFileId) async {
    try {
      if (_db == null) {
        await init();
      }

      final txn = _db!.transaction(_storeName, idbModeReadOnly);
      final store = txn.objectStore(_storeName);
      final result = await store.getObject(videoFileId);

      return result != null;
    } on Exception catch (e) {
      debugPrint('[VideoCacheServiceWeb] キャッシュ確認失敗: $e');
      return false;
    }
  }

  /// キャッシュから動画のBlob URLを取得
  /// キャッシュがない場合はnullを返す
  Future<String?> getCachedVideoUrl(String videoFileId) async {
    try {
      debugPrint('[VideoCacheServiceWeb] キャッシュから動画取得: $videoFileId');

      if (_db == null) {
        await init();
      }

      final txn = _db!.transaction(_storeName, idbModeReadWrite);
      final store = txn.objectStore(_storeName);
      final result = await store.getObject(videoFileId);

      if (result == null) {
        debugPrint('[VideoCacheServiceWeb] キャッシュなし: $videoFileId');
        return null;
      }

      final cachedData = result as Map<String, dynamic>;
      final data = cachedData['data'] as Uint8List;

      // lastAccessedAtを更新（LRU用）
      cachedData['lastAccessedAt'] = DateTime.now().millisecondsSinceEpoch;
      await store.put(cachedData, videoFileId);
      await txn.completed;

      // Blob URLを生成
      final blobUrl = _createBlobUrl(data);

      debugPrint(
        '[VideoCacheServiceWeb] キャッシュから動画取得成功: $videoFileId, Blob URL: ${blobUrl.substring(0, 50)}...',
      );

      return blobUrl;
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheServiceWeb] キャッシュから動画取得失敗: $e');
      debugPrint('[VideoCacheServiceWeb] スタックトレース: $stackTrace');
      return null;
    }
  }

  /// 動画をキャッシュに保存
  Future<void> cacheVideo(String videoFileId, Uint8List data) async {
    try {
      debugPrint(
        '[VideoCacheServiceWeb] 動画をキャッシュに保存: $videoFileId, サイズ: ${data.length} bytes',
      );

      if (_db == null) {
        await init();
      }

      // 容量チェック：キャッシュサイズが上限を超える場合は古いキャッシュを削除
      await _ensureCacheSize(data.length);

      final txn = _db!.transaction(_storeName, idbModeReadWrite);
      final store = txn.objectStore(_storeName);

      final cachedData = {
        'videoFileId': videoFileId,
        'data': data,
        'size': data.length,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'lastAccessedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await store.put(cachedData, videoFileId);
      await txn.completed;

      debugPrint('[VideoCacheServiceWeb] 動画をキャッシュに保存成功: $videoFileId');
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheServiceWeb] 動画のキャッシュ保存失敗: $e');
      debugPrint('[VideoCacheServiceWeb] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// 古いキャッシュをクリア（30日以上アクセスがないもの）
  Future<void> clearOldCache() async {
    try {
      debugPrint('[VideoCacheServiceWeb] 古いキャッシュのクリア開始');

      if (_db == null) {
        await init();
      }

      final expirationTimestamp = DateTime.now()
          .subtract(const Duration(days: _cacheExpirationDays))
          .millisecondsSinceEpoch;

      final txn = _db!.transaction(_storeName, idbModeReadWrite);
      final store = txn.objectStore(_storeName);

      // すべてのキャッシュエントリを取得
      final cursor = store.openCursor(autoAdvance: true);
      var deletedCount = 0;

      await cursor.listen((cursorWithValue) async {
        final data = cursorWithValue.value as Map<String, dynamic>;
        final lastAccessedAt = data['lastAccessedAt'] as int;

        // 期限切れの場合は削除
        if (lastAccessedAt < expirationTimestamp) {
          await cursorWithValue.delete();
          deletedCount++;
        }
      }).asFuture<void>();

      await txn.completed;

      debugPrint('[VideoCacheServiceWeb] 古いキャッシュのクリア完了: $deletedCount件削除');
    } on Exception catch (e) {
      debugPrint('[VideoCacheServiceWeb] 古いキャッシュのクリア失敗: $e');
      // エラーは無視（クリア失敗してもアプリは続行）
    }
  }

  /// すべてのキャッシュをクリア
  Future<void> clearAllCache() async {
    try {
      debugPrint('[VideoCacheServiceWeb] すべてのキャッシュをクリア');

      if (_db == null) {
        await init();
      }

      final txn = _db!.transaction(_storeName, idbModeReadWrite);
      final store = txn.objectStore(_storeName);
      await store.clear();
      await txn.completed;

      debugPrint('[VideoCacheServiceWeb] すべてのキャッシュをクリア完了');
    } on Exception catch (e, stackTrace) {
      debugPrint('[VideoCacheServiceWeb] すべてのキャッシュのクリア失敗: $e');
      debugPrint('[VideoCacheServiceWeb] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// キャッシュサイズを確保（LRU削除）
  Future<void> _ensureCacheSize(int newDataSize) async {
    try {
      final currentSize = await _getTotalCacheSize();

      debugPrint(
        '[VideoCacheServiceWeb] 現在のキャッシュサイズ: $currentSize bytes, 新規データ: $newDataSize bytes',
      );

      // 容量が上限を超える場合は、古いキャッシュを削除
      if (currentSize + newDataSize > _maxCacheSizeBytes) {
        debugPrint('[VideoCacheServiceWeb] キャッシュ容量超過、LRU削除を実行');
        await _deleteLRUCache(currentSize + newDataSize - _maxCacheSizeBytes);
      }
    } on Exception catch (e) {
      debugPrint('[VideoCacheServiceWeb] キャッシュサイズ確保失敗: $e');
      // エラーは無視（削除失敗しても保存は試みる）
    }
  }

  /// 現在のキャッシュサイズを取得
  Future<int> _getTotalCacheSize() async {
    final txn = _db!.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final cursor = store.openCursor(autoAdvance: true);

    var totalSize = 0;

    await cursor.listen((cursorWithValue) {
      final data = cursorWithValue.value as Map<String, dynamic>;
      totalSize += data['size'] as int;
    }).asFuture<void>();

    return totalSize;
  }

  /// LRU（Least Recently Used）削除
  /// 指定されたサイズ分のキャッシュを削除
  Future<void> _deleteLRUCache(int sizeToDelete) async {
    final txn = _db!.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    final cursor = store.openCursor(autoAdvance: true);

    // すべてのエントリをlastAccessedAtでソート
    final entries = <Map<String, dynamic>>[];

    await cursor.listen((cursorWithValue) {
      final data = cursorWithValue.value as Map<String, dynamic>;
      entries.add(data);
    }).asFuture<void>();

    // lastAccessedAtの昇順でソート（古いものが先）
    entries.sort((a, b) {
      final aTime = a['lastAccessedAt'] as int;
      final bTime = b['lastAccessedAt'] as int;
      return aTime.compareTo(bTime);
    });

    // 古いものから削除
    var deletedSize = 0;
    var deletedCount = 0;

    for (final entry in entries) {
      if (deletedSize >= sizeToDelete) {
        break;
      }

      final videoFileId = entry['videoFileId'] as String;
      final size = entry['size'] as int;

      await store.delete(videoFileId);
      deletedSize += size;
      deletedCount++;

      debugPrint(
        '[VideoCacheServiceWeb] LRU削除: $videoFileId, サイズ: $size bytes',
      );
    }

    await txn.completed;

    debugPrint(
      '[VideoCacheServiceWeb] LRU削除完了: $deletedCount件削除, $deletedSize bytes解放',
    );
  }

  /// Blob URLを生成
  String _createBlobUrl(Uint8List data) {
    // Web APIを使用してBlobを作成
    final blob = web.Blob(
      [data.toJS].toJS,
      web.BlobPropertyBag(type: 'video/mp4'),
    );
    final url = web.URL.createObjectURL(blob);
    return url;
  }

  /// リソースの破棄
  Future<void> dispose() async {
    _db?.close();
    _db = null;
  }
}
