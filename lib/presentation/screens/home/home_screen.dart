import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/channel_provider.dart';
import '../../widgets/channel_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../channel/channel_detail_screen.dart';

/// ホーム画面（チャンネル一覧）
/// 登録したチャンネルを一覧表示
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorColor,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  channelProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ElevatedButton(
                  onPressed: _loadChannels,
                  child: const Text('再試行'),
                ),
              ],
            ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ChannelDetailScreen(
                        channel: channel,
                      ),
                    ),
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: '履歴',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
      onTap: (index) {
        if (index == 2) {
          Navigator.pushNamed(context, '/settings');
        }
        // TODO: Phase 2で各画面への遷移を実装
      },
    );
  }
}
