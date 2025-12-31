import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';
import '../../../config/theme/app_dimensions.dart';

/// ホーム画面（チャンネル一覧）
/// 登録したチャンネルを一覧表示
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイチャンネル'),
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
          // TODO: チャンネル追加画面への遷移
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('チャンネル追加機能は準備中です')),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    // TODO: Phase 2でチャンネルリストを実装
    // 現在はEmpty Stateを表示
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📺',
            style: TextStyle(fontSize: AppDimensions.iconSizeXXL),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'チャンネルを追加してください',
            style: AppTypography.body1.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'FABボタンをタップして開始',
            style: AppTypography.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
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
        // TODO: Phase 2で各画面への遷移を実装
      },
    );
  }
}
