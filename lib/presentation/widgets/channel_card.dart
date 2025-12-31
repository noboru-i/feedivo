import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_typography.dart';
import '../../domain/entities/channel.dart';

/// チャンネルカードウィジェット
/// ホーム画面でチャンネル一覧を表示するためのカード
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    required this.channel,
    required this.onTap,
    super.key,
  });

  final Channel channel;
  final VoidCallback onTap;

  // グラデーション背景のバリエーション
  static const List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // Peach
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // Orange
  ];

  LinearGradient _getGradient() {
    final index = channel.id.hashCode.abs() % _gradients.length;
    final colors = _gradients[index];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: AppDimensions.spacingM,
        right: AppDimensions.spacingM,
        bottom: AppDimensions.spacingM,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイルエリア
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusM),
                  topRight: Radius.circular(AppDimensions.radiusM),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.video_library,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // チャンネル情報
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // チャンネル名
                  Text(
                    channel.name,
                    style: AppTypography.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  // 説明文
                  Text(
                    channel.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
