# Feedivo アプリケーションルート一覧

## 名前付きルート

| パス | 画面 | 説明 | 引数 |
|------|------|------|------|
| `/splash` | SplashScreen | スプラッシュ画面（初期表示） | なし |
| `/login` | LoginScreen | ログイン画面 | なし |
| `/home` | HomeScreen | ホーム画面（チャンネル一覧） | なし |
| `/settings` | SettingsScreen | 設定画面 | なし |
| `/add-channel` | AddChannelScreen | チャンネル追加画面 | なし |
| `/history` | HistoryScreen | 視聴履歴画面 | なし |
| `/channel-detail` | ChannelDetailScreen | チャンネル詳細画面 | `Channel channel` (必須) |
| `/video-player` | VideoPlayerScreen | 動画プレイヤー画面 | `Video video` (必須) |

## ルート遷移フロー

```
/splash
  ├─ (認証済み) → /home
  └─ (未認証) → /login
       └─ (ログイン成功) → /home

/home
  ├─ チャンネルタップ → /channel-detail
  ├─ 視聴履歴タブ → /history
  ├─ 設定アイコン → /settings
  └─ チャンネル追加ボタン → /add-channel

/channel-detail
  └─ 動画タップ → /video-player

/history
  └─ 動画タップ → /video-player

/settings
  └─ ログアウト → /login (すべてのルートをクリア)
```

## 実装方法

### 引数なしのルート
名前付きルートを使用：
```dart
Navigator.pushNamed(context, '/home');
```

### 引数ありのルート
引数をsettingsで渡す：
```dart
Navigator.pushNamed(
  context,
  '/channel-detail',
  arguments: channel,
);
```

画面側で引数を受け取る：
```dart
final channel = ModalRoute.of(context)!.settings.arguments as Channel;
```

## 未実装のルート

現在、すべての画面にルートが定義されています。

## 今後の拡張候補

- `/playlist` - プレイリスト機能
- `/search` - 検索機能
- `/notifications` - 通知一覧
- `/profile` - ユーザープロフィール編集
