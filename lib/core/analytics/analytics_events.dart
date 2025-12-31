/// Firebase Analyticsイベント名定数
class AnalyticsEvents {
  const AnalyticsEvents._();

  // 画面表示イベント
  static const String screenView = 'screen_view';

  // 動画関連イベント
  static const String videoPlayStart = 'video_play_start';
  static const String videoCompleted = 'video_completed';
  static const String playbackSpeedChanged = 'playback_speed_changed';

  // チャンネル関連イベント
  static const String channelAdded = 'channel_added';
  static const String channelDeleted = 'channel_deleted';
  static const String channelRefreshed = 'channel_refreshed';

  // 履歴関連イベント
  static const String historyCleared = 'history_cleared';
  static const String historyItemTapped = 'history_item_tapped';
}
