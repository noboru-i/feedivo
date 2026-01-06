import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web版動画プレイヤー
/// HTML `<video>`要素を使用してBlob URLの動画を再生
class WebVideoPlayer extends StatefulWidget {
  const WebVideoPlayer({
    required this.controller,
    super.key,
  });

  final WebVideoPlayerController controller;

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller._attach();
  }

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: widget.controller._viewType,
    );
  }
}

/// Web版動画プレイヤーコントローラー
/// VideoPlayerControllerと同等のAPIを提供
class WebVideoPlayerController {
  WebVideoPlayerController({
    required this.videoUrl,
    this.autoPlay = false,
  }) {
    _viewType = 'video-player-${_nextViewId++}';
    // コンストラクタでvideoエレメントを登録
    _registerVideoElement();
  }

  final String videoUrl;
  final bool autoPlay;

  late final String _viewType;
  static int _nextViewId = 0;

  web.HTMLVideoElement? _videoElement;

  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1;

  Timer? _positionTimer;

  final _onInitializedController = StreamController<void>.broadcast();
  final _onPositionChangedController = StreamController<Duration>.broadcast();

  Stream<void> get onInitialized => _onInitializedController.stream;
  Stream<Duration> get onPositionChanged => _onPositionChangedController.stream;

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;

  void _attach() {
    // VideoElementは既にコンストラクタで登録済み
    // ここでは何もしない
  }

  void _detach() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _registerVideoElement() {
    debugPrint('[WebVideoPlayerController] VideoElement登録開始: $videoUrl');

    // VideoElementを作成
    _videoElement = web.document.createElement('video') as web.HTMLVideoElement
      ..src = videoUrl
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'black';

    // イベントリスナーを追加
    _videoElement!.addEventListener(
      'loadedmetadata',
      (web.Event _) {
        debugPrint('[WebVideoPlayerController] loadedmetadataイベント受信');
        _duration = Duration(
          milliseconds: (_videoElement!.duration * 1000).toInt(),
        );
        _isInitialized = true;
        _onInitializedController.add(null);

        if (autoPlay) {
          play();
        }
      }.toJS,
    );

    _videoElement!.addEventListener(
      'play',
      (web.Event _) {
        _isPlaying = true;
        _startPositionTimer();
      }.toJS,
    );

    _videoElement!.addEventListener(
      'pause',
      (web.Event _) {
        _isPlaying = false;
        _positionTimer?.cancel();
      }.toJS,
    );

    _videoElement!.addEventListener(
      'ended',
      (web.Event _) {
        _isPlaying = false;
        _positionTimer?.cancel();
      }.toJS,
    );

    _videoElement!.addEventListener(
      'error',
      (web.Event event) {
        debugPrint('[WebVideoPlayerController] 動画エラー: $event');
      }.toJS,
    );

    // VideoElementをFlutterに登録
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement!,
    );
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_videoElement != null && !_videoElement!.paused) {
        _position = Duration(
          milliseconds: (_videoElement!.currentTime * 1000).toInt(),
        );
        _onPositionChangedController.add(_position);
      }
    });
  }

  Future<void> initialize() async {
    debugPrint('[WebVideoPlayerController] initialize開始');

    // HTML VideoElementの場合、loadedmetadataイベントで初期化完了
    if (_isInitialized) {
      debugPrint('[WebVideoPlayerController] 既に初期化済み');
      return;
    }

    debugPrint('[WebVideoPlayerController] loadedmetadataイベントを待機中...');
    // 初期化完了を待つ
    await onInitialized.first;
    debugPrint('[WebVideoPlayerController] initialize完了');
  }

  Future<void> play() async {
    if (_videoElement == null) {
      return;
    }

    try {
      await _videoElement!.play().toDart;
    } on Exception catch (e) {
      debugPrint('[WebVideoPlayerController] 再生エラー: $e');
    }
  }

  Future<void> pause() async {
    if (_videoElement == null) {
      return;
    }

    _videoElement!.pause();
  }

  Future<void> seekTo(Duration position) async {
    if (_videoElement == null) {
      return;
    }

    _videoElement!.currentTime = position.inMilliseconds / 1000;
    _position = position;
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoElement == null) {
      return;
    }

    _videoElement!.playbackRate = speed;
    _playbackSpeed = speed;
  }

  void dispose() {
    _positionTimer?.cancel();
    _videoElement?.pause();
    _videoElement?.remove();
    _videoElement = null;
    _onInitializedController.close();
    _onPositionChangedController.close();
  }
}
