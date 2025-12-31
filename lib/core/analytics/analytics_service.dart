import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_events.dart';

/// Firebase Analytics統合サービス
/// ユーザー行動を追跡し、データドリブンな改善を可能にする
class AnalyticsService {
  AnalyticsService() : _analytics = FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// 画面表示イベントを送信
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } on Exception {
      // エラーは無視（Analytics送信失敗しても処理を継続）
    }
  }

  /// 動画再生開始イベントを送信
  Future<void> logVideoPlayStart({
    required String videoId,
    required String channelId,
    String? source,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.videoPlayStart,
        parameters: {
          'video_id': videoId,
          'channel_id': channelId,
          'source': source ?? 'unknown',
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// 動画視聴完了イベントを送信
  Future<void> logVideoCompleted({
    required String videoId,
    required int watchDuration,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.videoCompleted,
        parameters: {
          'video_id': videoId,
          'watch_duration': watchDuration,
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// 再生速度変更イベントを送信
  Future<void> logPlaybackSpeedChanged({
    required String videoId,
    required double speed,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.playbackSpeedChanged,
        parameters: {
          'video_id': videoId,
          'speed': speed,
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// チャンネル追加イベントを送信
  Future<void> logChannelAdded({
    required String channelId,
    String? source,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.channelAdded,
        parameters: {
          'channel_id': channelId,
          'source': source ?? 'manual',
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// チャンネル削除イベントを送信
  Future<void> logChannelDeleted({
    required String channelId,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.channelDeleted,
        parameters: {
          'channel_id': channelId,
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// チャンネル更新イベントを送信
  Future<void> logChannelRefreshed({
    required String channelId,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.channelRefreshed,
        parameters: {
          'channel_id': channelId,
        },
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// 履歴クリアイベントを送信
  Future<void> logHistoryCleared() async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.historyCleared,
      );
    } on Exception {
      // エラーは無視
    }
  }

  /// 履歴アイテムタップイベントを送信
  Future<void> logHistoryItemTapped({
    required String videoId,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.historyItemTapped,
        parameters: {
          'video_id': videoId,
        },
      );
    } on Exception {
      // エラーは無視
    }
  }
}
