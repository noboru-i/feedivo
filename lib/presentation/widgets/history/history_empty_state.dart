import 'package:flutter/material.dart';

import '../empty_state_widget.dart';

/// 視聴履歴がない場合の空状態表示
class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.history,
      message: '視聴履歴がありません',
      subMessage: '動画を再生すると、ここに履歴が表示されます',
    );
  }
}
