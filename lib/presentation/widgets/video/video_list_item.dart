import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/video.dart';
import '../../providers/playback_provider.dart';
import 'duration_badge.dart';
import 'video_thumbnail.dart';

/// 動画リストアイテムウィジェット
/// チャンネル詳細画面で動画を一覧表示するためのカード
class VideoListItem extends StatelessWidget {
  const VideoListItem({
    required this.video,
    required this.onTap,
    super.key,
  });

  final Video video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();
    final playbackPosition = playbackProvider.getPosition(video.id);
    final watchPercentage = playbackPosition?.watchPercentage ?? 0.0;
    final isCompleted = playbackPosition?.isCompleted ?? false;

    return Card(
      margin: const EdgeInsets.only(
        left: AppDimensions.spacingM,
        right: AppDimensions.spacingM,
        bottom: AppDimensions.spacingM,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // サムネイルエリア
              Stack(
                children: [
                  VideoThumbnail(
                    thumbnailFileId: video.thumbnailFileId,
                    width: 160,
                    height: 90,
                  ),

                  // 視聴進捗バー
                  if (watchPercentage > 0 && !isCompleted)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: watchPercentage,
                        backgroundColor: Colors.black.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                        minHeight: 3,
                      ),
                    ),

                  // 視聴済みマーク
                  if (isCompleted)
                    Positioned(
                      top: AppDimensions.spacingXS,
                      left: AppDimensions.spacingXS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingXS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXS,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '視聴済み',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 再生時間バッジ
                  Positioned(
                    bottom: AppDimensions.spacingXS,
                    right: AppDimensions.spacingXS,
                    child: DurationBadge(duration: video.duration),
                  ),
                ],
              ),

              const SizedBox(width: AppDimensions.spacingM),

              // 動画情報エリア
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      video.title,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppDimensions.spacingXS),

                    // 説明文
                    Text(
                      video.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppDimensions.spacingS),

                    // 公開日
                    Text(
                      _formatDate(video.publishedAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.disabledText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今日';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }
}
