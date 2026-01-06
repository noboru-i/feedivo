// 動画キャッシュサービス
// プラットフォームに応じて適切な実装を提供
//
// Web: IndexedDBを使用したキャッシュ実装
// その他: スタブ実装（何もしない）
export 'video_cache_service_stub.dart'
    if (dart.library.js_interop) 'video_cache_service_web.dart';
