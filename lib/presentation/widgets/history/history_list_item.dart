import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

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

// Widget Previews

Video _createSampleVideo({
  required String id,
  required String title,
  required String description,
  required int duration,
}) {
  return Video(
    id: id,
    channelId: 'sample-channel',
    title: title,
    description: description,
    videoFileId: 'sample-video-file-id',
    thumbnailFileId: 'sample-thumbnail-file-id',
    duration: duration,
    publishedAt: DateTime.now().subtract(const Duration(days: 7)),
  );
}

PlaybackPosition _createSamplePosition({
  required String videoId,
  required int position,
  required int duration,
  required DateTime lastPlayedAt,
  required bool isCompleted,
}) {
  return PlaybackPosition(
    videoId: videoId,
    channelId: 'sample-channel',
    position: position,
    duration: duration,
    lastPlayedAt: lastPlayedAt,
    isCompleted: isCompleted,
  );
}

@Preview(
  group: 'HistoryListItem',
  name: 'Light - In Progress (50%)',
  brightness: Brightness.light,
)
Widget historyListItemInProgress() {
  final video = _createSampleVideo(
    id: 'video-1',
    title: 'Flutterの基礎を学ぼう',
    description: 'Flutterの基本的な使い方と、ウィジェットの概念について解説します。',
    duration: 630, // 10:30
  );

  final position = _createSamplePosition(
    videoId: 'video-1',
    position: 315, // 5:15 (50%)
    duration: 630,
    lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isCompleted: false,
  );

  return MaterialApp(
    home: Scaffold(
      body: HistoryListItem(
        position: position,
        video: video,
        onTap: () {},
      ),
    ),
  );
}

@Preview(
  group: 'HistoryListItem',
  name: 'Dark - In Progress (50%)',
  brightness: Brightness.dark,
)
Widget historyListItemDark() {
  final video = _createSampleVideo(
    id: 'video-1',
    title: 'Flutterの基礎を学ぼう',
    description: 'Flutterの基本的な使い方と、ウィジェットの概念について解説します。',
    duration: 630, // 10:30
  );

  final position = _createSamplePosition(
    videoId: 'video-1',
    position: 315, // 5:15 (50%)
    duration: 630,
    lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isCompleted: false,
  );

  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: HistoryListItem(
        position: position,
        video: video,
        onTap: () {},
      ),
    ),
  );
}

@Preview(
  group: 'HistoryListItem',
  name: 'Completed',
  brightness: Brightness.light,
)
Widget historyListItemCompleted() {
  final video = _createSampleVideo(
    id: 'video-2',
    title: '状態管理の実装パターン',
    description: 'Provider、Riverpod、Blocなど、様々な状態管理手法を比較しながら解説します。',
    duration: 1800, // 30:00
  );

  final position = _createSamplePosition(
    videoId: 'video-2',
    position: 1800,
    duration: 1800,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 1)),
    isCompleted: true,
  );

  return MaterialApp(
    home: Scaffold(
      body: HistoryListItem(
        position: position,
        video: video,
        onTap: () {},
      ),
    ),
  );
}

@Preview(
  group: 'HistoryListItem',
  name: 'Just Watched (5 minutes ago)',
  brightness: Brightness.light,
)
Widget historyListItemRecent() {
  final video = _createSampleVideo(
    id: 'video-3',
    title: 'アニメーションの実装方法',
    description: 'Flutterで美しいアニメーションを実装する方法を、実例を交えて詳しく解説します。',
    duration: 1200, // 20:00
  );

  final position = _createSamplePosition(
    videoId: 'video-3',
    position: 800, // 13:20 (66%)
    duration: 1200,
    lastPlayedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    isCompleted: false,
  );

  return MaterialApp(
    home: Scaffold(
      body: HistoryListItem(
        position: position,
        video: video,
        onTap: () {},
      ),
    ),
  );
}

@Preview(
  group: 'HistoryListItem',
  name: 'Long Text Overflow',
  brightness: Brightness.light,
)
Widget historyListItemLongText() {
  final video = _createSampleVideo(
    id: 'video-4',
    title: 'とても長いタイトルがここに表示されますがオーバーフローで省略されるはずです',
    description:
        'とても長い説明文がここに表示されます。この説明文は複数行になる可能性がありますが、最大2行までしか表示されずに省略記号が表示されるはずです。',
    duration: 3600, // 1:00:00
  );

  final position = _createSamplePosition(
    videoId: 'video-4',
    position: 1800, // 30:00 (50%)
    duration: 3600,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 7)),
    isCompleted: false,
  );

  return MaterialApp(
    home: Scaffold(
      body: HistoryListItem(
        position: position,
        video: video,
        onTap: () {},
      ),
    ),
  );
}
