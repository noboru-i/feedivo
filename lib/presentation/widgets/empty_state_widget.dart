import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_typography.dart';

/// 空状態表示ウィジェット
/// データがない場合に表示するメッセージとアイコン
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.message,
    this.subMessage,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? subMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            message,
            style: AppTypography.h2.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              subMessage!,
              style: AppTypography.body2.copyWith(
                color: AppColors.disabledText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Widget Previews

@Preview(
  group: 'EmptyStateWidget',
  name: 'Light - With SubMessage',
  brightness: Brightness.light,
)
Widget emptyStateWithSubMessage() {
  return const MaterialApp(
    home: Scaffold(
      body: EmptyStateWidget(
        icon: Icons.video_library_outlined,
        message: 'チャンネルがありません',
        subMessage: '右下のボタンからチャンネルを追加してください',
      ),
    ),
  );
}

@Preview(
  group: 'EmptyStateWidget',
  name: 'Dark - With SubMessage',
  brightness: Brightness.dark,
)
Widget emptyStateDarkWithSubMessage() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const Scaffold(
      body: EmptyStateWidget(
        icon: Icons.video_library_outlined,
        message: 'チャンネルがありません',
        subMessage: '右下のボタンからチャンネルを追加してください',
      ),
    ),
  );
}

@Preview(
  group: 'EmptyStateWidget',
  name: 'Without SubMessage',
  brightness: Brightness.light,
)
Widget emptyStateWithoutSubMessage() {
  return const MaterialApp(
    home: Scaffold(
      body: EmptyStateWidget(
        icon: Icons.videocam_off_outlined,
        message: '動画がありません',
      ),
    ),
  );
}

@Preview(
  group: 'EmptyStateWidget',
  name: 'Search Empty',
  brightness: Brightness.light,
)
Widget emptyStateSearch() {
  return const MaterialApp(
    home: Scaffold(
      body: EmptyStateWidget(
        icon: Icons.search_off,
        message: '検索結果が見つかりません',
        subMessage: '別のキーワードで検索してみてください',
      ),
    ),
  );
}

@Preview(
  group: 'EmptyStateWidget',
  name: 'History Empty',
  brightness: Brightness.light,
)
Widget emptyStateHistory() {
  return const MaterialApp(
    home: Scaffold(
      body: EmptyStateWidget(
        icon: Icons.history,
        message: '視聴履歴がありません',
        subMessage: '動画を視聴すると、ここに履歴が表示されます',
      ),
    ),
  );
}

@Preview(
  group: 'EmptyStateWidget',
  name: 'Error State',
  brightness: Brightness.light,
)
Widget emptyStateError() {
  return const MaterialApp(
    home: Scaffold(
      body: EmptyStateWidget(
        icon: Icons.error_outline,
        message: 'データの読み込みに失敗しました',
        subMessage: 'ネットワーク接続を確認してください',
      ),
    ),
  );
}
