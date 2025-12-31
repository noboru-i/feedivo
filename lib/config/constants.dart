/// アプリ全体で使用する定数
class AppConstants {
  AppConstants._(); // プライベートコンストラクタ

  // アプリ情報
  static const String appName = 'Feedivo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Google Driveの動画をポッドキャストのように楽しむ';

  // Google OAuth スコープ
  static const List<String> googleScopes = [
    'email',
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  // Firestoreコレクション名
  static const String usersCollection = 'users';
  static const String channelsCollection = 'channels';
  static const String videosCollection = 'videos';

  // SharedPreferences キー
  static const String keyThemeMode = 'theme_mode';
  static const String keyAutoPlay = 'auto_play';
  static const String keyBackgroundPlay = 'background_play';
  static const String keyDefaultPlaybackSpeed = 'default_playback_speed';

  // デフォルト値
  static const double defaultPlaybackSpeed = 1;
  static const bool defaultAutoPlay = true;
  static const bool defaultBackgroundPlay = true;
}
