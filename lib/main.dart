import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'domain/repositories/channel_repository_interface.dart';
import 'domain/repositories/google_drive_repository_interface.dart';
import 'domain/repositories/playback_repository_interface.dart';
import 'domain/repositories/video_repository_interface.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/channel_provider.dart';
import 'presentation/providers/playback_provider.dart';
import 'presentation/providers/video_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/channel/add_channel_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  // Flutter binding初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

        // Phase 2: Repositories
        Provider<IGoogleDriveRepository>(
          create: (_) => GoogleDriveRepository(
            driveService: GoogleDriveService(
              googleSignIn: GoogleSignIn(scopes: AppConstants.googleScopes),
              httpClient: http.Client(),
            ),
          ),
        ),
        Provider<IChannelRepository>(
          create: (context) => ChannelRepository(
            firestore: FirebaseFirestore.instance,
            driveRepo: context.read<IGoogleDriveRepository>(),
          ),
        ),
        Provider<IVideoRepository>(
          create: (_) => VideoRepository(
            firestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<IPlaybackRepository>(
          create: (_) => PlaybackRepository(
            firestore: FirebaseFirestore.instance,
          ),
        ),

        // Phase 3: Analytics
        Provider<AnalyticsService>(
          create: (_) => AnalyticsService(),
        ),

        // Phase 2: Providers
        ChangeNotifierProvider(
          create: (context) => ChannelProvider(
            context.read<IChannelRepository>(),
            context.read<AnalyticsService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => VideoProvider(
            context.read<IVideoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PlaybackProvider(
            context.read<IPlaybackRepository>(),
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
