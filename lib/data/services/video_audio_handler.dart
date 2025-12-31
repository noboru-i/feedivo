import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// バックグラウンド音声再生ハンドラ
/// 動画の音声をバックグラウンドで再生し、通知コントロールを提供
class VideoAudioHandler extends BaseAudioHandler with SeekHandler {
  VideoAudioHandler() {
    // プレイヤーの状態変更を監視
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // 再生完了時は停止状態にする
        stop();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  /// 動画URLと認証ヘッダーを設定して再生準備
  Future<void> setVideoSource({
    required String videoUrl,
    required Map<String, String> headers,
    required String title,
    required String channelName,
    String? thumbnailUrl,
  }) async {
    try {
      // メディア情報を設定
      mediaItem.add(
        MediaItem(
          id: videoUrl,
          title: title,
          artist: channelName,
          artUri: thumbnailUrl != null ? Uri.parse(thumbnailUrl) : null,
        ),
      );

      // 音声ソースを設定
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(videoUrl),
          headers: headers,
        ),
      );
    } on Exception catch (e) {
      // エラーハンドリング
      throw Exception('Failed to set audio source: $e');
    }
  }

  /// 再生状態をブロードキャスト
  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    // 10秒早送り
    final newPosition = _player.position + const Duration(seconds: 10);
    await _player.seek(newPosition);
  }

  @override
  Future<void> skipToPrevious() async {
    // 10秒巻き戻し
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(
      newPosition > Duration.zero ? newPosition : Duration.zero,
    );
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// 現在の再生位置を取得
  Duration get position => _player.position;

  /// 動画の長さを取得
  Duration? get duration => _player.duration;

  /// 再生中かどうか
  bool get playing => _player.playing;

  /// 位置ストリーム
  Stream<Duration> get positionStream => _player.positionStream;

  /// 再生状態ストリーム
  Stream<bool> get playingStream => _player.playingStream;

  /// リソースを解放
  Future<void> dispose() async {
    await _player.dispose();
  }
}
