import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/playback_position.dart';
import '../../../domain/entities/video.dart';
import '../video/duration_badge.dart';
import '../video/video_thumbnail.dart';

/// 視聴履歴リストアイテムウィジェット
/// 視聴履歴画面で使用
class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    required this.position,
    required this.video,
    required this.onTap,
    super.key,
  });

  final PlaybackPosition position;
  final Video video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final watchPercentage = position.watchPercentage;
    final isCompleted = position.isCompleted;

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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppDimensions.spacingS),

                    // 最終視聴日時
                    Text(
                      _formatLastPlayedAt(position.lastPlayedAt),
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

  /// 最終視聴日時を相対表示でフォーマット
  String _formatLastPlayedAt(DateTime lastPlayedAt) {
    final now = DateTime.now();
    final difference = now.difference(lastPlayedAt);

    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else {
      return '${lastPlayedAt.year}年${lastPlayedAt.month}月${lastPlayedAt.day}日';
    }
  }
}
