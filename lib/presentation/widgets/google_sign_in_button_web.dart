import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// Web版専用のGoogle Sign-inボタン
/// Google Identity Services SDKが提供するボタンをレンダリング
class GoogleSignInButtonWeb extends StatelessWidget {
  const GoogleSignInButtonWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return web.renderButton();
  }
}
