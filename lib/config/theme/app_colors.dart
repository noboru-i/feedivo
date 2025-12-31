import 'package:flutter/material.dart';

/// Feedivoアプリのカラーパレット
/// Material Design 3準拠、visual_design.md 1.2に基づく
class AppColors {
  AppColors._(); // プライベートコンストラクタ（インスタンス化を防ぐ）

  // Primary Colors
  static const Color primaryColor = Color(0xFF1E3A5F); // 深いネイビー（メインカラー）
  static const Color primaryLight = Color(0xFF2C5282); // ライトネイビー（ホバー状態）
  static const Color primaryDark = Color(0xFF0F1E2F); // ダークネイビー（スプラッシュ背景）

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF4A5568); // スレートグレー
  static const Color secondaryLight = Color(0xFF718096); // ライトグレー
  static const Color secondaryDark = Color(0xFF2D3748); // ダークグレー

  // Background Colors
  static const Color backgroundColor = Color(0xFFF7FAFC); // ライトグレー（画面背景）
  static const Color surfaceColor = Color(0xFFFFFFFF); // 白（カード、ダイアログ）
  static const Color cardColor = Color(0xFFFFFFFF); // 白（カード背景）

  // Text Colors
  static const Color primaryText = Color(0xFF1A202C); // ほぼ黒（メインテキスト）
  static const Color secondaryText = Color(0xFF718096); // グレー（補足テキスト）
  static const Color disabledText = Color(0xFFA0AEC0); // ライトグレー（無効状態）
  static const Color onPrimary = Color(0xFFFFFFFF); // 白（プライマリ背景上のテキスト）

  // Status Colors
  static const Color successColor = Color(0xFF48BB78); // グリーン（成功、完了）
  static const Color errorColor = Color(0xFFF56565); // レッド（エラー）
  static const Color warningColor = Color(0xFFED8936); // オレンジ（警告）
  static const Color infoColor = Color(0xFF4299E1); // ブルー（情報）

  // Dark Mode Colors
  static const Color darkPrimaryColor = Color(0xFF3B82F6); // 明るいブルー
  static const Color darkPrimaryLight = Color(0xFF60A5FA);
  static const Color darkPrimaryDark = Color(0xFF2563EB);
  static const Color darkBackgroundColor = Color(0xFF0F1419); // ほぼ黒
  static const Color darkSurfaceColor = Color(0xFF1A202C); // ダークグレー
  static const Color darkCardColor = Color(0xFF2D3748); // ミディアムグレー
  static const Color darkPrimaryText = Color(0xFFF7FAFC); // ほぼ白
  static const Color darkSecondaryText = Color(0xFFA0AEC0); // ライトグレー
  static const Color darkDisabledText = Color(0xFF4A5568); // ダークグレー

  // Gradient Colors (for channel/video thumbnails)
  static const List<List<Color>> gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // Peach
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // Orange
  ];

  // Border Colors
  static const Color borderColor = Color(0xFFCBD5E0);
  static const Color borderLightColor = Color(0xFFE2E8F0);

  // Overlay Color
  static Color overlayColor = Colors.black.withValues(alpha: 0.6);
}
