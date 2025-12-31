import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../config/theme/app_colors.dart';

/// エラー表示ウィジェット
/// ユーザーフレンドリーなエラーメッセージとリトライ機能を提供
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget Previews

@Preview(
  group: 'ErrorDisplay',
  name: 'Light - With Retry',
  brightness: Brightness.light,
)
Widget errorDisplayWithRetry() {
  return MaterialApp(
    home: Scaffold(
      body: ErrorDisplay(
        message: 'データの読み込みに失敗しました',
        onRetry: () {},
      ),
    ),
  );
}

@Preview(
  group: 'ErrorDisplay',
  name: 'Dark - With Retry',
  brightness: Brightness.dark,
)
Widget errorDisplayDark() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: ErrorDisplay(
        message: 'データの読み込みに失敗しました',
        onRetry: () {},
      ),
    ),
  );
}

@Preview(
  group: 'ErrorDisplay',
  name: 'Without Retry Button',
  brightness: Brightness.light,
)
Widget errorDisplayWithoutRetry() {
  return const MaterialApp(
    home: Scaffold(
      body: ErrorDisplay(
        message: 'このコンテンツは利用できません',
      ),
    ),
  );
}

@Preview(
  group: 'ErrorDisplay',
  name: 'Network Error',
  brightness: Brightness.light,
)
Widget errorDisplayNetworkError() {
  return MaterialApp(
    home: Scaffold(
      body: ErrorDisplay(
        message: 'ネットワークに接続できません\nインターネット接続を確認してください',
        icon: Icons.wifi_off,
        onRetry: () {},
      ),
    ),
  );
}

@Preview(
  group: 'ErrorDisplay',
  name: 'Long Error Message',
  brightness: Brightness.light,
)
Widget errorDisplayLongMessage() {
  return MaterialApp(
    home: Scaffold(
      body: ErrorDisplay(
        message:
            'データの読み込み中に予期しないエラーが発生しました。しばらく時間をおいてから再度お試しください。問題が解決しない場合は、アプリを再起動してください。',
        onRetry: () {},
      ),
    ),
  );
}
