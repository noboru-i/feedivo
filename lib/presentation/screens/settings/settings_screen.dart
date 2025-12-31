import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/constants.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

/// 設定画面
/// アカウント情報、アプリ設定、アプリ情報を表示
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('アカウント'),
          _buildProfileItem(context),
          _buildLogoutItem(context),

          _buildSectionHeader('アプリ情報'),
          _buildListItem(
            icon: Icons.info,
            title: 'バージョン',
            subtitle: AppConstants.appVersion,
          ),
          _buildListItem(
            icon: Icons.description,
            title: '利用規約',
            onTap: () {
              // TODO: 利用規約を表示
            },
          ),
          _buildListItem(
            icon: Icons.privacy_tip,
            title: 'プライバシーポリシー',
            onTap: () {
              // TODO: プライバシーポリシーを表示
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingL,
        AppDimensions.spacingM,
        AppDimensions.spacingS,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.sectionHeader.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return _buildListItem(
          icon: Icons.person,
          title: 'プロフィール',
          subtitle: user?.email ?? '',
          onTap: () {
            // TODO: プロフィール画面への遷移
          },
        );
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return _buildListItem(
          icon: Icons.logout,
          title: 'ログアウト',
          onTap: () async {
            final confirmed = await _showLogoutConfirmDialog(context);
            if (confirmed && context.mounted) {
              await authProvider.signOut();
              if (context.mounted) {
                await Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: AppDimensions.iconSizeStandard,
        color: AppColors.secondaryText,
      ),
      title: Text(
        title,
        style: AppTypography.body1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.body2.copyWith(
                color: AppColors.secondaryText,
              ),
            )
          : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Future<bool> _showLogoutConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
