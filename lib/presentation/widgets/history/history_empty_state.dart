import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

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

// Widget Previews

@Preview(
  group: 'HistoryEmptyState',
  name: 'Light',
  brightness: Brightness.light,
)
Widget historyEmptyStateLight() {
  return const MaterialApp(
    home: Scaffold(
      body: HistoryEmptyState(),
    ),
  );
}

@Preview(
  group: 'HistoryEmptyState',
  name: 'Dark',
  brightness: Brightness.dark,
)
Widget historyEmptyStateDark() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const Scaffold(
      body: HistoryEmptyState(),
    ),
  );
}
