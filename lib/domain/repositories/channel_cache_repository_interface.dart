import '../entities/channel.dart';

/// チャンネルキャッシュリポジトリインターフェース
/// SQLiteを使用したローカルキャッシュを管理
abstract class IChannelCacheRepository {
  /// チャンネル一覧をキャッシュから取得
  Future<List<Channel>> getChannels(String userId);

  /// チャンネルをキャッシュに保存
  Future<void> saveChannel(Channel channel);

  /// 複数のチャンネルをキャッシュに保存
  Future<void> saveChannels(List<Channel> channels);

  /// チャンネルをキャッシュから削除
  Future<void> deleteChannel(String channelId);

  /// 特定ユーザーのすべてのチャンネルをキャッシュから削除
  Future<void> deleteChannelsByUser(String userId);
}
