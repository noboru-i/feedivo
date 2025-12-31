# Phase 3-4: バックグラウンド再生 - 実装状況

## 📋 概要

Phase 3-4では、iOS/Androidでアプリがバックグラウンドに移行しても音声再生を継続できる機能を実装する予定でした。

## ✅ 完了した実装

### 1. パッケージ追加
- `audio_service: ^0.18.18` - バックグラウンド音声再生サービス
- `just_audio: ^0.9.46` - 音声プレイヤー

### 2. サービスクラス作成
- `VideoAudioHandler` - バックグラウンド音声再生ハンドラ
- `BackgroundAudioService` - アプリ全体でのバックグラウンド音声再生管理

### 3. プラットフォーム固有の設定

#### Android (`AndroidManifest.xml`)
```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

<!-- Audio Service -->
<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>
```

#### iOS (`Info.plist`)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

## ⚠️ 技術的制約と課題

### 1. video_player と audio_service の統合の複雑さ

現在のVideoPlayerScreenは`video_player`パッケージと`chewie`パッケージを使用しています。

**問題点**:
- `video_player`: 動画（映像+音声）の再生に特化
- `just_audio`: 音声のみの再生に特化
- 両者を同時に使用する統合が非常に複雑

**技術的な選択肢**:

#### オプション1: 完全な audio_service 統合
- フォアグラウンド: `video_player`で動画再生
- バックグラウンド: アプリがバックグラウンドに移行時、`video_player`を停止して`just_audio`に切り替え
- 課題: 状態管理が非常に複雑、シームレスな切り替えが困難

#### オプション2: video_player のバックグラウンド拡張
- `video_player`のバックグラウンド再生を有効化
- プラットフォーム固有のコードで通知コントロールを追加
- 課題: プラットフォームごとのネイティブコードが必要

#### オプション3: 段階的実装（推奨）
- **Phase 3-4a（現在）**: インフラストラクチャのみ実装
  - パッケージ追加 ✅
  - サービスクラス作成 ✅
  - プラットフォーム設定 ✅
- **Phase 3-4b（将来）**: 完全統合
  - VideoPlayerScreenの大幅な書き換え
  - 状態管理の統合
  - ロック画面コントロールの実装

## 📝 現在の状態

### 実装済み
- ✅ `audio_service` と `just_audio` パッケージのインストール
- ✅ `VideoAudioHandler` クラスの実装
- ✅ `BackgroundAudioService` クラスの実装
- ✅ Android のパーミッションとサービス宣言
- ✅ iOS のバックグラウンドモード設定

### 未実装
- ⏳ VideoPlayerScreen への統合
- ⏳ バックグラウンド/フォアグラウンド切り替えロジック
- ⏳ ロック画面コントロールの実装
- ⏳ 視聴位置の同期（バックグラウンド再生時）

## 🎯 次のステップ（Phase 3-4b）

Phase 3-4bで完全な統合を実装する場合の推奨アプローチ：

### 1. プラットフォーム検出
```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
```

### 2. VideoPlayerScreen のリファクタリング
```dart
class VideoPlayerScreen extends StatefulWidget {
  @override
  State<VideoPlayerScreen> createState() {
    if (isMobile) {
      return _MobileVideoPlayerState(); // audio_service 使用
    } else {
      return _WebVideoPlayerState(); // 既存の video_player 使用
    }
  }
}
```

### 3. ライフサイクル管理
```dart
class _MobileVideoPlayerState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // バックグラウンドに移行 → audio_service に切り替え
        _switchToBackgroundAudio();
        break;
      case AppLifecycleState.resumed:
        // フォアグラウンドに復帰 → video_player に切り替え
        _switchToVideoPlayer();
        break;
    }
  }
}
```

## 🔍 代替アプローチ

### シンプルな実装（推奨）
`video_player`のバックグラウンド音声のみを有効化し、完全なコントロールは諦める：

```dart
// プラットフォーム固有の設定のみで、コード変更は最小限
// ロック画面コントロールは限定的だが、実装は簡単
```

### 完全な実装（複雑）
`audio_service`と`video_player`を完全に統合：

```dart
// 完全なロック画面コントロール
// シームレスなバックグラウンド/フォアグラウンド切り替え
// 実装コストが高く、バグのリスクも高い
```

## 📊 実装コスト見積もり

| アプローチ | 実装時間 | 複雑度 | ユーザー体験 |
|-----------|---------|--------|------------|
| インフラのみ（現在） | 1日 | 低 | 限定的 |
| シンプル実装 | 2-3日 | 中 | 中程度 |
| 完全統合 | 1-2週間 | 高 | 最高 |

## 🎓 学習リソース

- [audio_service 公式ドキュメント](https://pub.dev/packages/audio_service)
- [just_audio 公式ドキュメント](https://pub.dev/packages/just_audio)
- [Flutter バックグラウンド処理ガイド](https://docs.flutter.dev/development/packages-and-plugins/background-processes)

## 💡 推奨事項

Phase 3-4の完全な実装は**Phase 4（最適化フェーズ）またはPhase 5（将来の拡張）に延期**することを推奨します。

理由：
1. 技術的複雑度が非常に高い
2. ユーザーにとっての優先度は中程度（Phase 3-1〜3-3より低い）
3. 段階的な実装により、リスクを最小化できる

現時点では、インフラストラクチャが整っているため、将来の拡張が容易になっています。
