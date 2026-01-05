import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../data/repositories/google_drive_repository.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../domain/entities/playback_position.dart';
import '../../../domain/entities/video.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playback_provider.dart';
import '../../widgets/video/playback_speed_selector.dart';

/// 動画再生画面
/// Google Driveから動画をストリーミング再生
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    required this.video,
    super.key,
  });

  final Video video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  double _playbackSpeed = 1;
  Timer? _saveTimer;
  int _lastSavedPosition = 0;

  @override
  void initState() {
    super.initState();

    // Analytics: 動画再生開始と画面表示
    context.read<AnalyticsService>()
      ..logVideoPlayStart(
        videoId: widget.video.id,
        channelId: widget.video.channelId,
        source: 'video_list',
      )
      ..logScreenView('video_player');

    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Google Drive APIアクセストークンを取得
      final driveRepo = context.read<GoogleDriveRepository>();
      final token = await driveRepo.getAccessToken();

      // ストリーミングURL構築
      final videoUrl =
          'https://www.googleapis.com/drive/v3/files/${widget.video.videoFileId}?alt=media';

      // VideoPlayerController初期化
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'Authorization': 'Bearer $token',
        },
      );

      await _videoController!.initialize();

      // ChewieController初期化
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.primaryColor,
          bufferedColor: AppColors.primaryLight.withValues(alpha: 0.3),
          backgroundColor: AppColors.disabledText.withValues(alpha: 0.3),
        ),
        placeholder: const ColoredBox(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return ColoredBox(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
        customControls: const MaterialControls(),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
      );

      setState(() {
        _isLoading = false;
      });

      // 動画詳細画面への遷移時に視聴情報を記録
      await _recordViewStart();

      // 視聴位置を復元
      await _restorePlaybackPosition();

      // 定期保存タイマーを開始（5秒ごと）
      _startSaveTimer();
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '動画の読み込みに失敗しました: $e';
      });
    }
  }

  /// 動画詳細画面への遷移時に視聴開始情報を記録
  Future<void> _recordViewStart() async {
    if (!mounted ||
        _videoController == null ||
        !_videoController!.value.isInitialized) {
      return;
    }

    try {
      // 実際の動画のdurationを取得
      final actualDuration = _videoController!.value.duration.inSeconds;

      // videosコレクションの視聴情報を更新
      final videoRepo = context.read<VideoRepository>();
      await videoRepo.updateViewInfo(
        widget.video.channelId,
        widget.video.id,
        actualDuration,
      );
    } on Exception {
      // エラーは無視（保存失敗してもプレイヤーは続行）
    }
  }

  /// 視聴位置を復元
  Future<void> _restorePlaybackPosition() async {
    if (!mounted) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final playbackProvider = context.read<PlaybackProvider>();
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        return;
      }

      await playbackProvider.loadPosition(userId, widget.video.id);
      final position = playbackProvider.getPosition(widget.video.id);

      if (position != null && position.position > 0 && !position.isCompleted) {
        await _videoController?.seekTo(Duration(seconds: position.position));
      }
    } on Exception {
      // エラーは無視（視聴位置がないだけの可能性）
    }
  }

  /// 定期保存タイマーを開始
  void _startSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _savePlaybackPosition();
    });
  }

  /// 視聴位置を保存
  Future<void> _savePlaybackPosition() async {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final playbackProvider = context.read<PlaybackProvider>();
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        return;
      }

      final position = _videoController!.value.position.inSeconds;
      final duration = _videoController!.value.duration.inSeconds;

      // 位置が変わっていない場合はスキップ
      if (position == _lastSavedPosition) {
        return;
      }

      _lastSavedPosition = position;

      final playbackPosition = PlaybackPosition(
        videoId: widget.video.id,
        channelId: widget.video.channelId,
        position: position,
        duration: duration,
        lastPlayedAt: DateTime.now(),
        isCompleted: false,
      );

      await playbackProvider.savePosition(userId, playbackPosition);

      // 90%以上再生で視聴完了マーク
      if (duration > 0 && position / duration >= 0.9) {
        await playbackProvider.markCompleted(userId, widget.video.id);

        // Analytics: 動画視聴完了
        if (mounted) {
          await context.read<AnalyticsService>().logVideoCompleted(
            videoId: widget.video.id,
            watchDuration: duration,
          );
        }
      }
    } on Exception {
      // エラーは無視（保存失敗してもプレイヤーは続行）
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);

    // Analytics: 再生速度変更
    context.read<AnalyticsService>().logPlaybackSpeedChanged(
      videoId: widget.video.id,
      speed: speed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.title,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // 再生速度変更ボタン
          IconButton(
            icon: Text(
              '${_playbackSpeed}x',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              PlaybackSpeedSelector.show(
                context,
                currentSpeed: _playbackSpeed,
                onSpeedSelected: _changePlaybackSpeed,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    return Column(
      children: [
        // 動画プレイヤー
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Chewie(
                controller: _chewieController!,
              ),
            ),
          ),
        ),

        // 動画情報
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.video.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
