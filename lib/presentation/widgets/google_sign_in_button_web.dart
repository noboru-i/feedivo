import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_typography.dart';
import '../providers/auth_provider.dart';

/// Web版専用のGoogle Sign-inボタン
/// Firebase AuthenticationのsignInWithPopupを使用してスコープ付き認証
class GoogleSignInButtonWeb extends StatefulWidget {
  const GoogleSignInButtonWeb({super.key});

  @override
  State<GoogleSignInButtonWeb> createState() => _GoogleSignInButtonWebState();
}

class _GoogleSignInButtonWebState extends State<GoogleSignInButtonWeb> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase AuthenticationのGoogleプロバイダーにスコープを追加
      final provider = firebase_auth.GoogleAuthProvider()
        ..addScope('https://www.googleapis.com/auth/drive.readonly')
        ..setCustomParameters({'prompt': 'select_account'});

      // signInWithPopupを使用してスコープ付き認証
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithPopup(provider);

      if (!mounted) {
        return;
      }

      // AuthProviderを通じてユーザー情報を処理
      final authProvider = context.read<AuthProvider>();
      await authProvider.handleWebSignInResult(userCredential);

      if (!mounted) {
        return;
      }

      // ログイン成功時はHomeに遷移
      if (authProvider.isAuthenticated) {
        await Navigator.pushReplacementNamed(context, '/home');
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('[GoogleSignInButtonWeb] Firebase Auth Error: $e');
      if (!mounted) {
        return;
      }

      var errorMessage = 'ログインに失敗しました';
      if (e.code == 'popup-closed-by-user') {
        errorMessage = 'ログインがキャンセルされました';
      } else if (e.code == 'popup-blocked') {
        errorMessage = 'ポップアップがブロックされました。ブラウザの設定を確認してください。';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } on Exception catch (e) {
      print('[GoogleSignInButtonWeb] Error: $e');
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ログインに失敗しました: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.onPrimary,
        foregroundColor: AppColors.primaryText,
        minimumSize: const Size(280, AppDimensions.buttonHeightStandard),
        elevation: AppDimensions.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      child: _isLoading
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
  }
}
