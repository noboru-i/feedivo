import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'config/theme/app_theme.dart';
import 'core/analytics/analytics_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/channel_repository.dart';
import 'data/repositories/google_drive_repository.dart';
import 'data/repositories/playback_repository.dart';
import 'data/repositories/video_repository.dart';
import 'data/services/google_drive_service.dart';
import 'domain/entities/channel.dart';
import 'domain/entities/video.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/channel_provider.dart';
import 'presentation/providers/playback_provider.dart';
import 'presentation/providers/video_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/channel/add_channel_screen.dart';
import 'presentation/screens/channel/channel_detail_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/video/video_player_screen.dart';

void main() async {
  // Flutter binding初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestoreオフライン永続化設定
  // すべてのプラットフォーム（iOS/Android/Web）で有効
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Google Sign-Inの初期化 (v7.x)
  await GoogleSignIn.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Phase 1: AuthProvider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepository(),
          ),
        ),

        // Phase 2: Repositories - Base Dependencies
        Provider<GoogleDriveRepository>(
          create: (_) => GoogleDriveRepository(
            driveService: GoogleDriveService(
              googleSignIn: GoogleSignIn.instance,
              httpClient: http.Client(),
            ),
          ),
        ),

        // Phase 3: Analytics
        Provider<AnalyticsService>(
          create: (_) => AnalyticsService(),
        ),

        // Phase 2: Repositories
        // VideoRepository must be created before ChannelRepository
        Provider<VideoRepository>(
          create: (context) => VideoRepository(
            firestore: FirebaseFirestore.instance,
            firebaseAuth: firebase_auth.FirebaseAuth.instance,
          ),
        ),
        Provider<ChannelRepository>(
          create: (context) => ChannelRepository(
            firestore: FirebaseFirestore.instance,
            driveRepo: context.read<GoogleDriveRepository>(),
            videoRepo: context.read<VideoRepository>(),
          ),
        ),
        Provider<PlaybackRepository>(
          create: (_) => PlaybackRepository(
            firestore: FirebaseFirestore.instance,
          ),
        ),

        // Phase 2: Providers
        ChangeNotifierProvider(
          create: (context) => ChannelProvider(
            context.read<ChannelRepository>(),
            context.read<AnalyticsService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => VideoProvider(
            context.read<VideoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PlaybackProvider(
            context.read<PlaybackRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // テーマ設定
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        // 初期ルート
        initialRoute: '/splash',

        // ルート定義
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/add-channel': (context) => const AddChannelScreen(),
          '/history': (context) => const HistoryScreen(),
        },

        // 引数付きルートの生成
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/channel-detail':
              final channel = settings.arguments as Channel?;
              if (channel == null) {
                return null;
              }
              return MaterialPageRoute(
                builder: (context) => ChannelDetailScreen(channel: channel),
                settings: settings,
              );

            case '/video-player':
              final video = settings.arguments as Video?;
              if (video == null) {
                return null;
              }
              return MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
                settings: settings,
              );

            default:
              return null;
          }
        },

        // 未定義ルートのハンドリング
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          );
        },
      ),
    );
  }
}
