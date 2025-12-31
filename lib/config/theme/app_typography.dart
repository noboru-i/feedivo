import 'package:flutter/material.dart';

/// Feedivoアプリのタイポグラフィ定義
/// Material Design 3準拠、visual_design.md 1.3に基づく
class AppTypography {
  AppTypography._(); // プライベートコンストラクタ

  // Headline Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    height: 32 / 24, // Line height
    letterSpacing: 0,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 28 / 20,
    letterSpacing: 0,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 24 / 18,
    letterSpacing: 0,
  );

  // Body Styles
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 24 / 16,
    letterSpacing: 0.15,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 16 / 12,
    letterSpacing: 0.4,
  );

  // Button Style
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 20 / 14,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 20 / 16,
    letterSpacing: 0.5,
  );

  // Section Header Style (設定画面等で使用)
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
  );
}
