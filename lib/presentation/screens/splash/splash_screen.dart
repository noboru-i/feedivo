import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

/// スプラッシュ画面
/// アプリ起動時に表示され、認証状態を確認して適切な画面に遷移
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// アプリ初期化と画面遷移
  Future<void> _initializeApp() async {
    // 最小表示時間（UX向上のため）
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 認証状態に応じて遷移
    if (authProvider.isAuthenticated) {
      await Navigator.pushReplacementNamed(context, '/home');
    } else {
      await Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴエリア
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: const Center(
                child: Text(
                  '📺',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.radiusL),

            // アプリ名
            Text(
              'Feedivo',
              style: AppTypography.h1.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 80),

            // ローディングインジケーター
            const SizedBox(
              width: AppDimensions.progressIndicatorSizeStandard,
              height: AppDimensions.progressIndicatorSizeStandard,
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
