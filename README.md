# Feedivo

<div align="center">
  <h3>Google Driveをポッドキャストのように楽しむ動画プレイヤー</h3>
  <p>クロスプラットフォーム対応の革新的な動画視聴アプリ</p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.38.5-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.10.4-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📖 概要

Feedivoは、Google Drive上の動画コンテンツをポッドキャスト形式で配信・視聴できるクロスプラットフォームアプリケーションです。

配信者はGoogle Drive上に設定ファイルを配置し、視聴者はそのURLを登録するだけで、動画リストへのアクセスと視聴位置の記憶が可能になります。

### ✨ 主な特徴

- **🎙️ ポッドキャスト形式**: URLを登録するだけで動画リストにアクセス
- **💾 視聴位置記憶**: 途中で止めても、続きから再生可能（自動保存）
- **📱 マルチプラットフォーム**: iOS、Android、Web で動作
- **🔐 セキュア**: Google OAuth認証による安全なアクセス
- **☁️ クラウド同期**: Firebase連携で複数デバイス間で視聴履歴を同期
- **📊 視聴履歴**: 過去の視聴記録を確認可能
- **📴 オフライン対応**: ネットワークなしでもメタデータを閲覧可能
- **🎨 モダンなデザイン**: Material Design 3に準拠

---

## 🎯 ユースケース

### 配信者側
1. Google Drive上に動画ファイルをアップロード
2. チャンネル設定ファイル（JSON）を作成
3. 設定ファイルの共有URLを視聴者に提供

### 視聴者側
1. アプリに配信者から提供されたURLを登録
2. 動画リストを閲覧
3. 好きな動画を視聴（途中再生、速度調整対応）
4. 複数デバイスで視聴履歴を同期

---

## 🛠️ 技術スタック

### フロントエンド
- **Flutter 3.38.5 / Dart 3.10.4** - クロスプラットフォーム開発
- **Material Design 3** - UIデザインシステム
- **Provider** - 状態管理
- **Clean Architecture** - 層分離とテスタビリティ

### バックエンド & API
- **Firebase Authentication** - Google Sign-in
- **Cloud Firestore** - データ永続化
- **Firebase Analytics** - 利用状況分析
- **Google Drive API v3** - 動画・設定ファイル取得
- **Google OAuth 2.0** - 認証・認可

### ストレージ
- **SQLite (sqflite 2.4.2)** - ローカルキャッシュ（オフライン対応）

### 動画・画像
- **video_player** - コア再生機能
- **chewie** - 拡張プレイヤーUI
- **cached_network_image** - 画像キャッシュ

### バックグラウンド音声（インフラのみ）
- **audio_service** - バックグラウンド音声再生サービス
- **just_audio** - オーディオプレイヤー
- ※ 完全統合は未実施（将来の拡張）

---

## 📋 必要要件

### 開発環境
- Flutter SDK: 3.38.5以上
- Dart: 3.10.4以上
- iOS: 16.0以上
- Android: API 33 (Android 13)以上

### アカウント
- Googleアカウント（OAuth認証用）
- Firebaseプロジェクト
- Google Cloud Console プロジェクト（Drive API有効化）

---

## 🚀 セットアップ

### クイックスタート

```bash
# リポジトリのクローン
git clone https://github.com/noboru-i/feedivo.git
cd feedivo

# 依存パッケージのインストール
flutter pub get

# アプリの起動
flutter run -d chrome  # Webの場合
flutter run            # 接続されたデバイス/エミュレータで実行
```

### 詳細なセットアップ手順

初回セットアップには、FirebaseとGoogle Cloudの設定が必要です。

📖 **詳細手順はこちら**:
- [Firebase & Google Cloud セットアップガイド](docs/setup/firebase-google-cloud-setup.md) - 新規環境構築（DEV/PROD）
- [ローカル開発環境セットアップ](docs/setup/local-setup-instructions.md) - 既存プロジェクトのクローン後の設定

**主な手順**:
1. Firebaseプロジェクトの作成
2. Google Cloud APIの有効化（Drive API, People API）
3. OAuth同意画面の設定
4. OAuth クライアントIDの作成（iOS/Android/Web）
5. 設定ファイルの生成と配置

詳細は上記ドキュメントを参照してください。

---

## 📁 プロジェクト構造（Clean Architecture）

```
lib/
├── main.dart                          # エントリーポイント
│
├── config/                            # 環境設定
│   ├── constants.dart                 # アプリ定数
│   └── theme/                         # Material Design 3テーマ
│       ├── app_colors.dart
│       ├── app_dimensions.dart
│       └── app_typography.dart
│
├── core/                              # コア機能
│   ├── analytics/                     # Firebase Analytics
│   │   ├── analytics_service.dart
│   │   └── analytics_events.dart
│   └── errors/                        # エラー定義
│       └── exceptions.dart
│
├── domain/                            # ドメイン層
│   ├── entities/                      # エンティティ
│   │   ├── channel.dart
│   │   ├── video.dart
│   │   └── playback_position.dart
│   └── repositories/                  # リポジトリインターフェース
│       ├── channel_repository_interface.dart
│       ├── video_repository_interface.dart
│       ├── playback_repository_interface.dart
│       ├── google_drive_repository_interface.dart
│       ├── channel_cache_repository_interface.dart
│       └── video_cache_repository_interface.dart
│
├── data/                              # データ層
│   ├── models/                        # データモデル
│   │   ├── channel_model.dart
│   │   ├── channel_config_model.dart
│   │   ├── video_model.dart
│   │   └── playback_position_model.dart
│   ├── repositories/                  # リポジトリ実装
│   │   ├── auth_repository.dart
│   │   ├── channel_repository.dart
│   │   ├── video_repository.dart
│   │   ├── playback_repository.dart
│   │   ├── google_drive_repository.dart
│   │   ├── channel_cache_repository.dart
│   │   └── video_cache_repository.dart
│   └── services/                      # 外部サービス連携
│       ├── google_drive_service.dart
│       ├── database_service.dart
│       ├── background_audio_service.dart
│       └── video_audio_handler.dart
│
└── presentation/                      # プレゼンテーション層
    ├── providers/                     # 状態管理（Provider）
    │   ├── auth_provider.dart
    │   ├── channel_provider.dart
    │   ├── video_provider.dart
    │   └── playback_provider.dart
    ├── screens/                       # 画面
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── channel/
    │   │   ├── add_channel_screen.dart
    │   │   └── channel_detail_screen.dart
    │   ├── video/
    │   │   └── video_player_screen.dart
    │   ├── history/
    │   │   └── history_screen.dart
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/                       # 再利用可能なウィジェット
        ├── channel_card.dart
        ├── empty_state_widget.dart
        ├── common/
        │   └── error_display.dart
        ├── video/
        │   ├── video_list_item.dart
        │   └── video_thumbnail.dart
        └── history/
            ├── history_list_item.dart
            └── history_empty_state.dart
```

---

## 🎬 チャンネル設定ファイルフォーマット

配信者はGoogle Drive上に以下の形式のJSONファイルを配置します：

```json
{
  "version": "1.0",
  "channel": {
    "id": "unique_channel_id",
    "name": "チャンネル名",
    "description": "チャンネルの説明",
    "thumbnail_file_id": "drive_file_id_for_thumbnail",
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "videos": [
    {
      "id": "unique_video_id",
      "title": "動画タイトル",
      "description": "動画の説明",
      "video_file_id": "drive_file_id_for_video",
      "thumbnail_file_id": "drive_file_id_for_thumbnail",
      "duration": 1800,
      "published_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

詳細: [チャンネルセットアップガイド](docs/test_channel_setup.md)

---

## 🔒 セキュリティ

- ユーザーは自分のGoogleアカウントで認証
- 読み取り専用スコープでGoogle Driveにアクセス
- Firestoreセキュリティルールでユーザーごとのデータ分離
- 動画ファイルは直接ストリーミング（サーバー保存なし）

### Firestoreセキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## 📊 Firestoreデータ構造

```
users/{userId}/
  ├── channels/{channelId}/
  │   ├── id, userId, name, description
  │   ├── thumbnailFileId, configFileId
  │   ├── createdAt, updatedAt, lastFetchedAt
  │   └── videos/{videoId}/
  │       ├── id, channelId, title, description
  │       ├── videoFileId, thumbnailFileId
  │       ├── duration, publishedAt
  │       └── ...
  └── playback_positions/{videoId}/
      ├── videoId, channelId
      ├── position, duration
      ├── lastPlayedAt, isCompleted
      └── watchPercentage
```

---

## 🎨 デザイン

- **プライマリカラー**: Deep Navy (#1E3A5F)
- **デザインシステム**: Material Design 3準拠
- **デザインフィロソフィー**: 穏やかで落ち着いた美的感覚

詳細: [ビジュアルデザインガイド](docs/visual_design.md)

---

## 📚 ドキュメント

### セットアップガイド
- [Firebase & Google Cloud セットアップ](docs/setup/firebase-google-cloud-setup.md)
- [ローカル開発環境セットアップ](docs/setup/local-setup-instructions.md)
- [テスト用チャンネルセットアップ](docs/test_channel_setup.md)

### 開発ガイド
- [CLAUDE.md](CLAUDE.md) - AI開発支援コンテキスト
- [実装履歴](docs/archive/implementation-history.md) - Phase 1-4の詳細

### デザイン
- [ビジュアルデザインガイド](docs/visual_design.md)

---

## 🚀 開発状態

### Phase 1-4完了（プロダクション準備完了）

| Phase | 状態 | 主要機能 |
|-------|------|---------|
| Phase 1 | ✅ 完了 | 基盤構築、Google OAuth認証 |
| Phase 2 | ✅ 完了 | チャンネル管理、動画再生、視聴位置保存 |
| Phase 3 | ✅ 完了 | 視聴履歴、Analytics、オフライン対応 |
| Phase 4 | ✅ 完了 | パフォーマンス最適化、エラーハンドリング統一 |

### 実装済み機能

#### コア機能
- ✅ Google認証（Firebase Authentication）
- ✅ チャンネル追加・管理・削除
- ✅ 動画リスト表示
- ✅ 動画再生（再生速度変更対応: 0.5x〜2.0x）
- ✅ 視聴位置の自動保存・復元（5秒ごと）

#### 拡張機能
- ✅ 視聴履歴管理
- ✅ Firebase Analytics統合
- ✅ オフライン対応（SQLiteキャッシュ）
- ✅ バックグラウンド再生インフラ（iOS/Android設定済み）

#### 品質・最適化
- ✅ 画像キャッシュ最適化
- ✅ データ整合性の確保
- ✅ エラーハンドリング統一
- ✅ Lint 0エラー

### 将来の拡張候補（Phase 5+）
- プレイリスト機能
- 検索機能
- コメント機能
- バックグラウンド再生の完全統合
- Google Picker API統合

詳細: [CLAUDE.md](CLAUDE.md)

---

## 🧪 テスト

```bash
# 単体テスト
flutter test

# 統合テスト
flutter drive --target=test_driver/app.dart

# コード解析
dart analyze --fatal-infos

# コードフォーマット
dart format lib/
```

---

## 📝 ライセンス

このプロジェクトは [MIT License](LICENSE) の下でライセンスされています。

---

## 📮 お問い合わせ

- GitHub Issues: [https://github.com/noboru-i/feedivo/issues](https://github.com/noboru-i/feedivo/issues)
- プロジェクト作者: [@noboru-i](https://github.com/noboru-i)

---

## 🙏 謝辞

このプロジェクトは以下のオープンソースプロジェクトを活用しています：
- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [Provider](https://pub.dev/packages/provider)
- その他多数のパッケージ（詳細は [pubspec.yaml](pubspec.yaml) を参照）
