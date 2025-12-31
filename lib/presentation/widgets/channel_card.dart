import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_typography.dart';
import '../../domain/entities/channel.dart';

/// チャンネルカードウィジェット
/// ホーム画面でチャンネル一覧を表示するためのカード
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    required this.channel,
    required this.onTap,
    super.key,
  });

  final Channel channel;
  final VoidCallback onTap;

  // グラデーション背景のバリエーション
  static const List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // Peach
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // Orange
  ];

  LinearGradient _getGradient() {
    final index = channel.id.hashCode.abs() % _gradients.length;
    final colors = _gradients[index];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: AppDimensions.spacingM,
        right: AppDimensions.spacingM,
        bottom: AppDimensions.spacingM,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイルエリア
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusM),
                  topRight: Radius.circular(AppDimensions.radiusM),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.video_library,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // チャンネル情報
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // チャンネル名
                  Text(
                    channel.name,
                    style: AppTypography.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  // 説明文
                  Text(
                    channel.description,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Previews

Channel createSampleChannel({
  required String id,
  required String name,
  required String description,
}) {
  final now = DateTime.now();
  return Channel(
    id: id,
    userId: 'preview-user',
    name: name,
    description: description,
    configFileId: 'preview-config-file-id',
    createdAt: now,
    updatedAt: now,
  );
}

@Preview(
  group: 'ChannelCard',
  name: 'Light - Purple Gradient',
  brightness: Brightness.light,
)
Widget channelCardLightPurple() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChannelCard(
          channel: createSampleChannel(
            id: 'channel-1',
            name: 'テクノロジーチャンネル',
            description: '最新のテクノロジーニュースや解説動画を配信しています。プログラミング、AI、クラウドなど幅広いトピックを扱います。',
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}

@Preview(
  group: 'ChannelCard',
  name: 'Dark - Purple Gradient',
  brightness: Brightness.dark,
)
Widget channelCardDarkPurple() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: Center(
        child: ChannelCard(
          channel: createSampleChannel(
            id: 'channel-1',
            name: 'テクノロジーチャンネル',
            description: '最新のテクノロジーニュースや解説動画を配信しています。プログラミング、AI、クラウドなど幅広いトピックを扱います。',
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}

@Preview(
  group: 'ChannelCard',
  name: 'Pink Gradient',
  brightness: Brightness.light,
)
Widget channelCardPink() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChannelCard(
          channel: createSampleChannel(
            id: 'channel-2',
            name: '料理チャンネル',
            description: '簡単で美味しいレシピを紹介します。',
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}

@Preview(
  group: 'ChannelCard',
  name: 'Blue Gradient',
  brightness: Brightness.light,
)
Widget channelCardBlue() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChannelCard(
          channel: createSampleChannel(
            id: 'channel-3',
            name: '旅行チャンネル',
            description: '世界中の素敵な場所を紹介します。',
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}

@Preview(
  group: 'ChannelCard',
  name: 'Long Text Overflow',
  brightness: Brightness.light,
)
Widget channelCardLongText() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChannelCard(
          channel: createSampleChannel(
            id: 'channel-4',
            name: 'とても長いチャンネル名がここに表示されますがオーバーフローで省略されます',
            description:
                'とても長い説明文がここに表示されます。この説明文は2行以上になる可能性がありますが、最大2行までしか表示されずに省略記号が表示されるはずです。',
          ),
          onTap: () {},
        ),
      ),
    ),
  );
}
