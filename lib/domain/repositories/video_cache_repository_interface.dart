import '../entities/video.dart';

/// 動画キャッシュリポジトリインターフェース
/// SQLiteを使用したローカルキャッシュを管理
abstract class IVideoCacheRepository {
  /// 動画一覧をキャッシュから取得
  Future<List<Video>> getVideos(String channelId);

  /// 動画をキャッシュに保存
  Future<void> saveVideo(Video video);

  /// 複数の動画をキャッシュに保存
  Future<void> saveVideos(List<Video> videos);

  /// 動画をキャッシュから削除
  Future<void> deleteVideo(String videoId);

  /// チャンネルの全動画をキャッシュから削除
  Future<void> deleteVideosByChannel(String channelId);
}
