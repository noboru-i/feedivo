import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/channel.dart';
import '../../providers/channel_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/video/video_list_item.dart';

/// チャンネル詳細画面
/// チャンネル情報と動画リストを表示
class ChannelDetailScreen extends StatefulWidget {
  const ChannelDetailScreen({
    required this.channel,
    super.key,
  });

  final Channel channel;

  @override
  State<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends State<ChannelDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 動画リストを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideos();
    });
  }

  Future<void> _loadVideos() async {
    final videoProvider = context.read<VideoProvider>();
    await videoProvider.loadVideos(widget.channel.id);
  }

  Future<void> _refreshChannel() async {
    final channelProvider = context.read<ChannelProvider>();
    final videoProvider = context.read<VideoProvider>();

    // チャンネル設定ファイルを再取得
    await channelProvider.refreshChannel(widget.channel.id);

    // 動画リストを再読み込み
    await videoProvider.loadVideos(widget.channel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (videoProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorColor,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  videoProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ElevatedButton(
                  onPressed: _loadVideos,
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshChannel,
          child: CustomScrollView(
            slivers: [
              // チャンネル情報ヘッダー
              SliverToBoxAdapter(
                child: _buildChannelHeader(),
              ),

              // 動画リスト
              if (videoProvider.videos.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.video_library,
                    message: '動画がありません',
                    subMessage: 'チャンネル設定ファイルに動画を追加してください',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingM,
                    bottom: AppDimensions.spacingL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = videoProvider.videos[index];
                        return VideoListItem(
                          video: video,
                          onTap: () {
                            // TODO: Phase 2-4で動画再生画面に遷移
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('動画再生機能は準備中です'),
                              ),
                            );
                          },
                        );
                      },
                      childCount: videoProvider.videos.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLightColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // チャンネル名
          Text(
            widget.channel.name,
            style: AppTypography.h2,
          ),

          const SizedBox(height: AppDimensions.spacingS),

          // チャンネル説明
          Text(
            widget.channel.description,
            style: AppTypography.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // 最終更新日時
          Row(
            children: [
              const Icon(
                Icons.update,
                size: 16,
                color: AppColors.disabledText,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Text(
                '最終更新: ${_formatDateTime(widget.channel.updatedAt)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.disabledText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
