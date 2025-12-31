import '../entities/channel.dart';

/// チャンネル管理のリポジトリインターフェース
/// Data層で実装される
abstract class IChannelRepository {
  /// ユーザーのチャンネル一覧を取得
  /// [userId] ユーザーID
  /// 戻り値: チャンネルのリスト
  Future<List<Channel>> getChannels(String userId);

  /// チャンネルを取得
  /// [channelId] チャンネルID
  /// 戻り値: チャンネル（存在しない場合はnull）
  Future<Channel?> getChannel(String channelId);

  /// チャンネルを追加
  /// [userId] ユーザーID
  /// [configFileId] 設定ファイルのGoogle Drive File ID
  /// 戻り値: 追加されたチャンネル
  Future<Channel> addChannel(String userId, String configFileId);

  /// チャンネルを削除
  /// [channelId] チャンネルID
  Future<void> deleteChannel(String channelId);

  /// チャンネル設定を更新（Google Driveから再取得）
  /// [channelId] チャンネルID
  /// 戻り値: 更新されたチャンネル
  Future<Channel> refreshChannel(String channelId);
}
