import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/channel.dart';
import '../../providers/channel_provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/common/error_display.dart';
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

  Future<void> _handleRefresh() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _refreshChannel();

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('チャンネル設定を更新しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    // 削除確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('チャンネルを削除'),
        content: Text(
          'チャンネル「${widget.channel.name}」を削除してもよろしいですか？\n\n'
          'このチャンネルの動画データと視聴履歴も削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // チャンネルを削除
    final channelProvider = context.read<ChannelProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await channelProvider.deleteChannel(widget.channel.id);

      if (mounted) {
        // 画面を閉じる
        navigator.pop();

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('チャンネルを削除しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
        actions: [
          // JSON再読み込みボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'チャンネル設定を再読み込み',
            onPressed: _handleRefresh,
          ),
          // チャンネル削除ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'チャンネルを削除',
            onPressed: _handleDelete,
          ),
        ],
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
          return ErrorDisplay(
            message: videoProvider.errorMessage!,
            onRetry: _loadVideos,
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
                            Navigator.pushNamed(
                              context,
                              '/video-player',
                              arguments: video,
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
