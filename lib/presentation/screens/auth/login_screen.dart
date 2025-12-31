import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/constants.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

/// ログイン画面
/// Google Sign-inでの認証を行う
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingL,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // ロゴ
                  _buildLogo(),
                  const SizedBox(height: AppDimensions.spacingL),

                  // アプリ名
                  Text(
                    AppConstants.appName,
                    style: AppTypography.h1.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),

                  // タグライン
                  _buildTagline(),
                  const SizedBox(height: 60),

                  // Googleログインボタン
                  _buildGoogleSignInButton(context),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  // フッター
                  _buildFooter(),
                  const SizedBox(height: AppDimensions.spacingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: const Center(
        child: Text(
          '📺',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return SizedBox(
      width: 280,
      child: Text(
        AppConstants.appDescription,
        style: AppTypography.body1.copyWith(
          color: AppColors.onPrimary.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ElevatedButton(
          onPressed: authProvider.isLoading
              ? null
              : () async {
                  final success = await authProvider.signInWithGoogle();
                  if (success && context.mounted) {
                    await Navigator.pushReplacementNamed(context, '/home');
                  } else if (authProvider.errorMessage != null &&
                      context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.errorMessage!),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.onPrimary,
            foregroundColor: AppColors.primaryText,
            minimumSize: const Size(280, AppDimensions.buttonHeightStandard),
            elevation: AppDimensions.elevation4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  width: AppDimensions.progressIndicatorSizeSmall,
                  height: AppDimensions.progressIndicatorSizeSmall,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔐', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text(
                      'Googleでログイン',
                      style: AppTypography.button,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Text(
      '利用規約 ・ プライバシーポリシー',
      style: AppTypography.caption.copyWith(
        color: AppColors.onPrimary.withValues(alpha: 0.6),
      ),
    );
  }
}
