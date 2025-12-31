import 'package:audio_service/audio_service.dart';

import 'video_audio_handler.dart';

/// バックグラウンド音声再生サービス
/// iOS/Androidでのバックグラウンド再生を管理
class BackgroundAudioService {
  BackgroundAudioService._();

  static VideoAudioHandler? _audioHandler;

  /// AudioHandlerを初期化
  static Future<VideoAudioHandler> init() async {
    if (_audioHandler != null) {
      return _audioHandler!;
    }

    _audioHandler = await AudioService.init(
      builder: VideoAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.feedivo.channel.audio',
        androidNotificationChannelName: 'Feedivo Audio',
        androidNotificationOngoing: true,
      ),
    );

    return _audioHandler!;
  }

  /// 既存のAudioHandlerを取得（初期化済みの場合のみ）
  static VideoAudioHandler? get handler => _audioHandler;

  /// AudioHandlerが初期化済みかどうか
  static bool get isInitialized => _audioHandler != null;

  /// リソースを解放
  static Future<void> dispose() async {
    if (_audioHandler != null) {
      await _audioHandler!.dispose();
      _audioHandler = null;
    }
  }
}
