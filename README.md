# Feedivo

<div align="center">
  <h3>Google Driveをポッドキャストのように楽しむ動画プレイヤー</h3>
  <p>クロスプラットフォーム対応の革新的な動画視聴アプリ</p>
</div>

## 📖 概要

Feedivoは、Google Drive上の動画コンテンツをポッドキャスト形式で配信・視聴できるクロスプラットフォームアプリケーションです。

配信者はGoogle Drive上に設定ファイルを配置し、視聴者はそのURLを登録するだけで、動画リストへのアクセスと視聴位置の記憶が可能になります。

### ✨ 主な特徴

- **🎙️ ポッドキャスト形式**: URLを登録するだけで動画リストにアクセス
- **💾 視聴位置記憶**: 途中で止めても、続きから再生可能
- **📱 マルチプラットフォーム**: iOS、Android、Web で動作
- **🔐 セキュア**: Google OAuth認証による安全なアクセス
- **☁️ クラウド同期**: Firebase連携で複数デバイス間で視聴履歴を同期
- **🎨 モダンなデザイン**: Material Design 3に準拠

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

## 🛠️ 技術スタック

### フロントエンド
- **Flutter** - クロスプラットフォーム開発
- **Material Design 3** - UIデザインシステム
- **Provider/Riverpod** - 状態管理

### バックエンド
- **Firebase Authentication** - Google Sign-in
- **Cloud Firestore** - データ永続化
- **Firebase Analytics** - 利用状況分析
- **Firebase Crashlytics** - クラッシュレポート
- **Firebase Performance Monitoring** - パフォーマンス監視

### API連携
- **Google Drive API v3** - 動画・設定ファイル取得
- **Google OAuth 2.0** - 認証・認可

### 動画再生
- **video_player** - コア再生機能
- **chewie** - 拡張プレイヤーUI

## 📋 必要要件

### 開発環境
- Flutter SDK: 3.16.0以上
- Dart: 3.2.0以上
- iOS: 14.0以上
- Android: API 26 (Android 8.0)以上

### アカウント
- Googleアカウント（OAuth認証用）
- Firebaseプロジェクト
- Google Cloud Console プロジェクト（Drive API有効化）

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

## 📁 プロジェクト構造

```
lib/
├── main.dart                 # エントリーポイント
├── app.dart                  # アプリケーション設定
├── config/                   # 環境設定
├── models/                   # データモデル
├── services/                 # ビジネスロジック
├── providers/                # 状態管理
├── repositories/             # データアクセス層
├── screens/                  # 画面
├── widgets/                  # 再利用可能なウィジェット
└── utils/                    # ユーティリティ
```

## 🎬 チャンネル設定ファイルフォーマット

配信者はGoogle Drive上に以下の形式のJSONファイルを配置します：

```json
{
  "version": "1.0",
  "channel": {
    "id": "unique_channel_id",
    "name": "チャンネル名",
    "description": "チャンネルの説明",
    "thumbnail": {
      "fileId": "drive_file_id_for_thumbnail"
    },
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "videos": [
    {
      "id": "unique_video_id",
      "title": "動画タイトル",
      "description": "動画の説明",
      "video": {
        "fileId": "drive_file_id_for_video",
        "mimeType": "video/mp4"
      },
      "thumbnail": {
        "fileId": "drive_file_id_for_thumbnail"
      },
      "duration": 1800,
      "published_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

## 🔒 セキュリティ

- ユーザーは自分のGoogleアカウントで認証
- 読み取り専用スコープでGoogle Driveにアクセス
- Firestoreセキュリティルールでユーザーごとのデータ分離
- 動画ファイルは直接ストリーミング（サーバー保存なし）

## 📝 ライセンス

このプロジェクトは [MIT License](LICENSE) の下でライセンスされています。

## 📮 お問い合わせ

- GitHub Issues: [https://github.com/noboru-i/feedivo/issues](https://github.com/noboru-i/feedivo/issues)
- プロジェクト作者: [@noboru-i](https://github.com/noboru-i)
