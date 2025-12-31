import '../entities/playback_position.dart';

/// 視聴位置管理のリポジトリインターフェース
/// Data層で実装される
abstract class IPlaybackRepository {
  /// 視聴位置を保存
  /// [userId] ユーザーID
  /// [position] 視聴位置エンティティ
  Future<void> savePlaybackPosition(
    String userId,
    PlaybackPosition position,
  );

  /// 視聴位置を取得
  /// [userId] ユーザーID
  /// [videoId] 動画ID
  /// 戻り値: 視聴位置（存在しない場合はnull）
  Future<PlaybackPosition?> getPlaybackPosition(
    String userId,
    String videoId,
  );

  /// 動画を視聴完了としてマーク
  /// [userId] ユーザーID
  /// [videoId] 動画ID
  Future<void> markAsCompleted(String userId, String videoId);

  /// ユーザーの視聴履歴一覧を取得
  /// [userId] ユーザーID
  /// [limit] 取得件数（オプション）
  /// 戻り値: 視聴位置のリスト
  Future<List<PlaybackPosition>> getPlaybackHistory(
    String userId, {
    int? limit,
  });

  /// チャンネルの視聴位置をすべて削除
  /// [userId] ユーザーID
  /// [channelId] チャンネルID
  Future<void> deletePlaybackPositionsByChannel(
    String userId,
    String channelId,
  );
}
