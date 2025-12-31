import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/channel_provider.dart';
import '../../widgets/channel_card.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/empty_state_widget.dart';

/// ホーム画面（チャンネル一覧）
/// 登録したチャンネルを一覧表示
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Analytics: 画面表示
    context.read<AnalyticsService>().logScreenView('home');

    // チャンネル一覧を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannels();
    });
  }

  Future<void> _loadChannels() async {
    final authProvider = context.read<AuthProvider>();
    final channelProvider = context.read<ChannelProvider>();

    final userId = authProvider.currentUser?.uid;
    if (userId != null) {
      await channelProvider.loadChannels(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイチャンネル'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: プロフィール画面への遷移
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-channel');
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, child) {
        if (channelProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (channelProvider.errorMessage != null) {
          return ErrorDisplay(
            message: channelProvider.errorMessage!,
            onRetry: _loadChannels,
          );
        }

        if (channelProvider.channels.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.video_library,
            message: 'チャンネルを追加してください',
            subMessage: 'FABボタンをタップして開始',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadChannels,
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacingM,
              bottom: 80, // FABの分の余白
            ),
            itemCount: channelProvider.channels.length,
            itemBuilder: (context, index) {
              final channel = channelProvider.channels[index];
              return ChannelCard(
                channel: channel,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/channel-detail',
                    arguments: channel,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: '履歴',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            // ホーム - 何もしない（既にホーム画面）
            break;
          case 1:
            // 履歴画面へ遷移
            Navigator.pushNamed(context, '/history').then((_) {
              // 履歴画面から戻ったときにホームをハイライト
              setState(() {
                _selectedIndex = 0;
              });
            });
          case 2:
            // 設定画面へ遷移
            Navigator.pushNamed(context, '/settings').then((_) {
              // 設定画面から戻ったときにホームをハイライト
              setState(() {
                _selectedIndex = 0;
              });
            });
        }
      },
    );
  }
}
