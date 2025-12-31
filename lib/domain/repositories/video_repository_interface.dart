import '../entities/video.dart';

/// 動画管理のリポジトリインターフェース
/// Data層で実装される
abstract class IVideoRepository {
  /// チャンネルの動画一覧を取得
  /// [channelId] チャンネルID
  /// 戻り値: 動画のリスト
  Future<List<Video>> getVideos(String channelId);

  /// 動画を取得
  /// [videoId] 動画ID
  /// 戻り値: 動画（存在しない場合はnull）
  Future<Video?> getVideo(String videoId);

  /// 動画をFirestoreに保存
  /// [video] 動画エンティティ
  Future<void> saveVideo(Video video);

  /// チャンネル設定ファイルから動画リストを同期
  /// [channelId] チャンネルID
  /// [videos] 設定ファイルから読み込んだ動画情報リスト
  Future<void> syncVideosFromConfig(
    String channelId,
    List<dynamic> videos,
  );

  /// チャンネルの全動画を削除
  /// [channelId] チャンネルID
  Future<void> deleteVideosByChannel(String channelId);
}
