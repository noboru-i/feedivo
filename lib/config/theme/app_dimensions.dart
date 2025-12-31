/// Feedivoアプリのスペーシングと角丸の定義
/// Material Design 3準拠、visual_design.md 1.4, 1.6に基づく
class AppDimensions {
  AppDimensions._(); // プライベートコンストラクタ

  // Spacing Scale (padding, margin)
  static const double spacingXXS = 2.0; // 最小余白
  static const double spacingXS = 4.0; // 極小余白
  static const double spacingS = 8.0; // 小余白
  static const double spacingM = 16.0; // 標準余白（最も頻繁に使用）
  static const double spacingL = 24.0; // 大余白
  static const double spacingXL = 32.0; // 特大余白
  static const double spacingXXL = 48.0; // 最大余白

  // Touch Target (タッチターゲット最小サイズ)
  static const double touchTargetMin = 48.0;

  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeStandard = 24.0;
  static const double iconSizeLarge = 40.0;
  static const double iconSizeHuge = 48.0;
  static const double iconSizeXXL = 64.0;

  // Border Radius (角丸)
  static const double radiusXS = 4.0; // テキストフィールド、プログレスバー
  static const double radiusS = 8.0; // ボタン、小カード、バッジ
  static const double radiusM = 12.0; // チャンネルカード
  static const double radiusL = 20.0; // ロゴ、大型要素
  static const double radiusXL = 30.0; // スマホフレーム
  static const double radiusCircle = 999.0; // 完全な円（大きな値を指定）

  // Elevation (Material Design 3のエレベーション)
  static const double elevation0 = 0.0; // なし
  static const double elevation1 = 1.0; // 動画カード（通常状態）
  static const double elevation2 = 2.0; // チャンネルカード、AppBar
  static const double elevation4 = 4.0; // GoogleログインボタンPrimary Button
  static const double elevation6 = 6.0; // FAB
  static const double elevation8 = 8.0; // カードホバー状態、ダイアログ

  // AppBar
  static const double appBarHeight = 56.0;

  // Bottom Navigation
  static const double bottomNavHeight = 56.0;

  // FAB (Floating Action Button)
  static const double fabSize = 56.0;

  // Button Heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightStandard = 48.0;

  // Card Dimensions
  static const double cardPadding = spacingM; // 16dp
  static const double cardMargin = spacingS; // 8dp

  // Video Thumbnail (動画サムネイル)
  static const double videoThumbnailWidthSmall = 120.0;
  static const double videoThumbnailHeightSmall = 68.0; // 16:9比率
  static const double videoThumbnailWidthMedium = 160.0;
  static const double videoThumbnailHeightMedium = 90.0;
  static const double videoThumbnailWidthLarge = 200.0;
  static const double videoThumbnailHeightLarge = 112.0;

  // Channel Thumbnail (チャンネルサムネイル)
  static const double channelThumbnailHeight = 180.0;
  static const double channelThumbnailSquare = 80.0;

  // Progress Bar
  static const double progressBarHeight = 3.0;
  static const double progressBarHeightThick = 4.0;

  // Circular Progress Indicator
  static const double progressIndicatorSizeSmall = 20.0;
  static const double progressIndicatorSizeStandard = 40.0;
  static const double progressIndicatorSizeLarge = 64.0;

  // Dialog
  static const double dialogWidthMobile = 280.0;
  static const double dialogWidthTablet = 400.0;
  static const double dialogPadding = spacingL; // 24dp
}
