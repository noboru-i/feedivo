import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';

/// 動画の再生時間を表示するバッジ
/// サムネイル上に重ねて表示
class DurationBadge extends StatelessWidget {
  const DurationBadge({
    required this.duration,
    super.key,
  });

  final int duration; // 秒数

  /// 秒数を時:分:秒の文字列に変換
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      child: Text(
        _formatDuration(duration),
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Widget Previews

@Preview(
  group: 'DurationBadge',
  name: 'Short Video (45 seconds)',
  brightness: Brightness.light,
)
Widget durationBadgeShort() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: DurationBadge(
          duration: 45, // 00:45
        ),
      ),
    ),
  );
}

@Preview(
  group: 'DurationBadge',
  name: 'Medium Video (10:30)',
  brightness: Brightness.light,
)
Widget durationBadgeMedium() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: DurationBadge(
          duration: 630, // 10:30
        ),
      ),
    ),
  );
}

@Preview(
  group: 'DurationBadge',
  name: 'Long Video (1:30:45)',
  brightness: Brightness.light,
)
Widget durationBadgeLong() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: DurationBadge(
          duration: 5445, // 01:30:45
        ),
      ),
    ),
  );
}

@Preview(
  group: 'DurationBadge',
  name: 'Very Long Video (10:05:30)',
  brightness: Brightness.light,
)
Widget durationBadgeVeryLong() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: DurationBadge(
          duration: 36330, // 10:05:30
        ),
      ),
    ),
  );
}

@Preview(
  group: 'DurationBadge',
  name: 'Dark Mode',
  brightness: Brightness.dark,
)
Widget durationBadgeDark() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const Scaffold(
      body: Center(
        child: DurationBadge(
          duration: 630, // 10:30
        ),
      ),
    ),
  );
}
