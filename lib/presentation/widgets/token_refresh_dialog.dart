import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// トークンリフレッシュダイアログ
/// Web版でアクセストークンの有効期限が切れた場合に表示
class TokenRefreshDialog extends StatelessWidget {
  const TokenRefreshDialog({super.key});

  /// ダイアログを表示
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TokenRefreshDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AlertDialog(
          title: const Text('再認証が必要です'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Google Driveへのアクセス権限が期限切れになりました。\n'
                '続けて操作を行うには、再度Googleアカウントで認証してください。',
              ),
              if (authProvider.isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  authProvider.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () {
                      authProvider
                        ..clearError()
                        ..clearTokenRefreshRequest();
                      Navigator.of(context).pop(false);
                    },
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      final success = await authProvider.refreshAccessToken();
                      if (success && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
              child: const Text('再認証'),
            ),
          ],
        );
      },
    );
  }
}
