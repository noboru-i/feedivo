/// Feedivoアプリのスペーシングと角丸の定義
/// Material Design 3準拠、visual_design.md 1.4, 1.6に基づく
class AppDimensions {
  AppDimensions._(); // プライベートコンストラクタ

  // Spacing Scale (padding, margin)
  static const double spacingXXS = 2; // 最小余白
  static const double spacingXS = 4; // 極小余白
  static const double spacingS = 8; // 小余白
  static const double spacingM = 16; // 標準余白（最も頻繁に使用）
  static const double spacingL = 24; // 大余白
  static const double spacingXL = 32; // 特大余白
  static const double spacingXXL = 48; // 最大余白

  // Touch Target (タッチターゲット最小サイズ)
  static const double touchTargetMin = 48;

  // Icon Sizes
  static const double iconSizeSmall = 20;
  static const double iconSizeStandard = 24;
  static const double iconSizeLarge = 40;
  static const double iconSizeHuge = 48;
  static const double iconSizeXXL = 64;

  // Border Radius (角丸)
  static const double radiusXS = 4; // テキストフィールド、プログレスバー
  static const double radiusS = 8; // ボタン、小カード、バッジ
  static const double radiusM = 12; // チャンネルカード
  static const double radiusL = 20; // ロゴ、大型要素
  static const double radiusXL = 30; // スマホフレーム
  static const double radiusCircle = 999; // 完全な円（大きな値を指定）

  // Elevation (Material Design 3のエレベーション)
  static const double elevation0 = 0; // なし
  static const double elevation1 = 1; // 動画カード（通常状態）
  static const double elevation2 = 2; // チャンネルカード、AppBar
  static const double elevation4 = 4; // GoogleログインボタンPrimary Button
  static const double elevation6 = 6; // FAB
  static const double elevation8 = 8; // カードホバー状態、ダイアログ

  // AppBar
  static const double appBarHeight = 56;

  // Bottom Navigation
  static const double bottomNavHeight = 56;

  // FAB (Floating Action Button)
  static const double fabSize = 56;

  // Button Heights
  static const double buttonHeightSmall = 40;
  static const double buttonHeightStandard = 48;

  // Card Dimensions
  static const double cardPadding = spacingM; // 16dp
  static const double cardMargin = spacingS; // 8dp

  // Video Thumbnail (動画サムネイル)
  static const double videoThumbnailWidthSmall = 120;
  static const double videoThumbnailHeightSmall = 68; // 16:9比率
  static const double videoThumbnailWidthMedium = 160;
  static const double videoThumbnailHeightMedium = 90;
  static const double videoThumbnailWidthLarge = 200;
  static const double videoThumbnailHeightLarge = 112;

  // Channel Thumbnail (チャンネルサムネイル)
  static const double channelThumbnailHeight = 180;
  static const double channelThumbnailSquare = 80;

  // Progress Bar
  static const double progressBarHeight = 3;
  static const double progressBarHeightThick = 4;

  // Circular Progress Indicator
  static const double progressIndicatorSizeSmall = 20;
  static const double progressIndicatorSizeStandard = 40;
  static const double progressIndicatorSizeLarge = 64;

  // Dialog
  static const double dialogWidthMobile = 280;
  static const double dialogWidthTablet = 400;
  static const double dialogPadding = spacingL; // 24dp
}
