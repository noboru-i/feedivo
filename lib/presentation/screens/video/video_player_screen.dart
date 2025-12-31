import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/repositories/google_drive_repository_interface.dart';
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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Google Drive APIアクセストークンを取得
      final driveRepo = context.read<IGoogleDriveRepository>();
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
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '動画の読み込みに失敗しました: $e';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);
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
