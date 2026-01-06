import 'dart:async';

import 'package:flutter/material.dart';

/// Web版動画プレイヤー（スタブ実装）
/// モバイル/デスクトップ環境では使用されない
class WebVideoPlayer extends StatelessWidget {
  const WebVideoPlayer({
    required this.controller,
    super.key,
  });

  final WebVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError('WebVideoPlayer is not supported on this platform');
  }
}

/// Web版動画プレイヤーコントローラー（スタブ実装）
/// モバイル/デスクトップ環境では使用されない
class WebVideoPlayerController {
  WebVideoPlayerController({
    required this.videoUrl,
    this.autoPlay = false,
  });

  final String videoUrl;
  final bool autoPlay;

  bool get isInitialized => false;
  bool get isPlaying => false;
  Duration get position => Duration.zero;
  Duration get duration => Duration.zero;
  double get playbackSpeed => 1;

  Stream<void> get onInitialized => const Stream.empty();
  Stream<Duration> get onPositionChanged => const Stream.empty();

  Future<void> initialize() async {}
  Future<void> play() async {}
  Future<void> pause() async {}
  Future<void> seekTo(Duration position) async {}
  Future<void> setPlaybackSpeed(double speed) async {}
  void dispose() {}
}
