import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/repositories/video_repository_interface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playback_provider.dart';
import '../../widgets/history/history_empty_state.dart';
import '../../widgets/history/history_list_item.dart';

/// 視聴履歴画面
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, Video> _videoMap = {};
  bool _isLoadingVideos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    final playbackProvider = context.read<PlaybackProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      return;
    }

    // 視聴履歴を読み込み
    await playbackProvider.loadHistory(userId, limit: 50);

    // 動画情報を読み込み
    await _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoadingVideos = true;
    });

    final playbackProvider = context.read<PlaybackProvider>();
    final videoRepository = context.read<IVideoRepository>();

    // 各視聴位置に対応する動画情報を取得
    for (final position in playbackProvider.positions.values) {
      try {
        final video = await videoRepository.getVideo(position.videoId);
        if (video != null) {
          _videoMap[position.videoId] = video;
        }
      } on Exception {
        // エラーは無視（動画が削除された場合など）
      }
    }

    setState(() {
      _isLoadingVideos = false;
    });
  }

  void _navigateToVideo(Video video) {
    Navigator.pushNamed(
      context,
      '/video-player',
      arguments: video,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('視聴履歴'),
      ),
      body: Consumer<PlaybackProvider>(
        builder: (context, provider, child) {
          // ローディング中
          if (provider.isLoading || _isLoadingVideos) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          // エラー表示
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppColors.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // 視聴履歴を時系列でソート
          final historyPositions = provider.positions.values.toList()
            ..sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));

          // 動画情報が取得できたもののみフィルタ
          final validHistory = historyPositions
              .where((position) => _videoMap.containsKey(position.videoId))
              .toList();

          // 履歴なし
          if (validHistory.isEmpty) {
            return const HistoryEmptyState();
          }

          // 履歴リスト表示
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: validHistory.length,
            itemBuilder: (context, index) {
              final position = validHistory[index];
              final video = _videoMap[position.videoId]!;

              return HistoryListItem(
                position: position,
                video: video,
                onTap: () => _navigateToVideo(video),
              );
            },
          );
        },
      ),
    );
  }
}
