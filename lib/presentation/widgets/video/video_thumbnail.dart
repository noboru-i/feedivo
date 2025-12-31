import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';

/// 動画サムネイルウィジェット
/// Google Driveから画像を取得して表示
class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    this.thumbnailFileId,
    this.width = double.infinity,
    this.height = 120,
    super.key,
  });

  final String? thumbnailFileId;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: thumbnailFileId != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: CachedNetworkImage(
                imageUrl:
                    'https://www.googleapis.com/drive/v3/files/$thumbnailFileId?alt=media',
                width: width,
                height: height,
                fit: BoxFit.cover,
                memCacheWidth: width.toInt() * 2, // 2x resolution for retina
                memCacheHeight: height.toInt() * 2,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.play_circle_outline,
        size: 48,
        color: AppColors.secondaryText.withValues(alpha: 0.5),
      ),
    );
  }
}

// Widget Previews

@Preview(
  group: 'VideoThumbnail',
  name: 'Light - With Thumbnail ID',
  brightness: Brightness.light,
)
Widget videoThumbnailLight() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: VideoThumbnail(
          thumbnailFileId: 'sample-thumbnail-id',
          width: 200,
        ),
      ),
    ),
  );
}

@Preview(
  group: 'VideoThumbnail',
  name: 'Dark - With Thumbnail ID',
  brightness: Brightness.dark,
)
Widget videoThumbnailDark() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const Scaffold(
      body: Center(
        child: VideoThumbnail(
          thumbnailFileId: 'sample-thumbnail-id',
          width: 200,
        ),
      ),
    ),
  );
}

@Preview(
  group: 'VideoThumbnail',
  name: 'No Thumbnail - Placeholder',
  brightness: Brightness.light,
)
Widget videoThumbnailPlaceholder() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: VideoThumbnail(
          width: 200,
        ),
      ),
    ),
  );
}

@Preview(
  group: 'VideoThumbnail',
  name: 'Wide Aspect Ratio',
  brightness: Brightness.light,
)
Widget videoThumbnailWide() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: VideoThumbnail(
          thumbnailFileId: 'sample-thumbnail-id',
          width: 300,
          height: 169, // 16:9 aspect ratio
        ),
      ),
    ),
  );
}

@Preview(
  group: 'VideoThumbnail',
  name: 'Small Size',
  brightness: Brightness.light,
)
Widget videoThumbnailSmall() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: VideoThumbnail(
          width: 100,
          height: 60,
        ),
      ),
    ),
  );
}
