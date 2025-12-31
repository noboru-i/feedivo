import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';

/// 再生速度選択ボトムシート
/// 0.5x ~ 2.0xの再生速度を選択可能
class PlaybackSpeedSelector extends StatelessWidget {
  const PlaybackSpeedSelector({
    required this.currentSpeed,
    required this.onSpeedSelected,
    super.key,
  });

  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  static const List<double> speeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '再生速度',
                  style: AppTypography.h3,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingS),

          // 速度リスト
          ...speeds.map((speed) {
            final isSelected = (speed - currentSpeed).abs() < 0.01;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.disabledText,
              ),
              title: Text(
                '${speed}x',
                style: AppTypography.body1.copyWith(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              subtitle: speed == 1.0
                  ? Text(
                      '標準',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    )
                  : null,
              onTap: () {
                onSpeedSelected(speed);
                Navigator.of(context).pop();
              },
            );
          }),

          const SizedBox(height: AppDimensions.spacingS),
        ],
      ),
    );
  }

  /// ボトムシートを表示
  // ignore: unreachable_from_main
  static void show(
    BuildContext context, {
    required double currentSpeed,
    required ValueChanged<double> onSpeedSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => PlaybackSpeedSelector(
        currentSpeed: currentSpeed,
        onSpeedSelected: onSpeedSelected,
      ),
    );
  }
}

// Widget Previews

@Preview(
  group: 'PlaybackSpeedSelector',
  name: 'Light - Normal Speed (1.0x)',
  brightness: Brightness.light,
)
Widget playbackSpeedSelectorNormal() {
  return MaterialApp(
    home: Scaffold(
      body: PlaybackSpeedSelector(
        currentSpeed: 1,
        onSpeedSelected: (speed) {},
      ),
    ),
  );
}

@Preview(
  group: 'PlaybackSpeedSelector',
  name: 'Dark - Normal Speed (1.0x)',
  brightness: Brightness.dark,
)
Widget playbackSpeedSelectorDark() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: PlaybackSpeedSelector(
        currentSpeed: 1,
        onSpeedSelected: (speed) {},
      ),
    ),
  );
}

@Preview(
  group: 'PlaybackSpeedSelector',
  name: 'Slow Speed (0.75x)',
  brightness: Brightness.light,
)
Widget playbackSpeedSelectorSlow() {
  return MaterialApp(
    home: Scaffold(
      body: PlaybackSpeedSelector(
        currentSpeed: 0.75,
        onSpeedSelected: (speed) {},
      ),
    ),
  );
}

@Preview(
  group: 'PlaybackSpeedSelector',
  name: 'Fast Speed (1.5x)',
  brightness: Brightness.light,
)
Widget playbackSpeedSelectorFast() {
  return MaterialApp(
    home: Scaffold(
      body: PlaybackSpeedSelector(
        currentSpeed: 1.5,
        onSpeedSelected: (speed) {},
      ),
    ),
  );
}

@Preview(
  group: 'PlaybackSpeedSelector',
  name: 'Maximum Speed (2.0x)',
  brightness: Brightness.light,
)
Widget playbackSpeedSelectorMaximum() {
  return MaterialApp(
    home: Scaffold(
      body: PlaybackSpeedSelector(
        currentSpeed: 2,
        onSpeedSelected: (speed) {},
      ),
    ),
  );
}
