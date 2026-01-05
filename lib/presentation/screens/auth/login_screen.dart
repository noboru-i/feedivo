import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/constants.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/google_sign_in_button_web.dart';

/// ログイン画面
/// Google Sign-inでの認証を行う
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();

    // Web版: 認証状態の変更を監視して画面遷移
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Analytics: 画面表示
        context.read<AnalyticsService>().logScreenView('login');

        print('[LoginScreen] Web版: 認証状態の監視開始');
        _authProvider = context.read<AuthProvider>();
        _authProvider!.addListener(_onAuthStateChanged);
      });
    } else {
      // モバイル版: Analytics
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AnalyticsService>().logScreenView('login');
      });
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _authProvider != null) {
      _authProvider!.removeListener(_onAuthStateChanged);
    }
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authProvider == null) {
      return;
    }

    print('[LoginScreen] 認証状態変更検知');
    print('[LoginScreen] isAuthenticated: ${_authProvider!.isAuthenticated}');

    if (_authProvider!.isAuthenticated && mounted) {
      print('[LoginScreen] ログイン成功、/homeに遷移');
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_authProvider!.errorMessage != null && mounted) {
      print('[LoginScreen] エラー: ${_authProvider!.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider!.errorMessage!),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

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
    if (kIsWeb) {
      // Web版: GoogleのSDKが提供するボタンを使用
      return const GoogleSignInButtonWeb();
    }

    // モバイル版: カスタムボタン
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
