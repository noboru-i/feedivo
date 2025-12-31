# CLAUDE.md - AI開発支援コンテキスト

このドキュメントは、ClaudeなどのAIアシスタントがFeedivoプロジェクトに関する作業を効率的に行うための包括的なコンテキスト情報を提供します。

---

## 📌 プロジェクト概要

### コアコンセプト
Feedivoは「Google Driveをポッドキャストのように楽しむ」というコンセプトの動画視聴アプリです。

**特徴**:
1. **Google Driveホスティング**: 配信者が自分のGoogle Drive上に動画を保存
2. **セルフマネージドRSSフィード**: JSONベースの設定ファイルで動画リストを管理
3. **ポッドキャスト型視聴**: URLを登録するだけでコンテンツにアクセス
4. **視聴位置記憶**: 途中再生機能とクロスプラットフォーム同期

### ターゲットユーザー
- **配信者**: 独自の動画コンテンツを簡易的に配信したい個人・小規模団体
- **視聴者**: 特定の配信者のコンテンツを継続的に視聴したいユーザー

---

## 🎯 現在の開発状態

### Phase 1-4完了（プロダクション準備完了）

| Phase | 状態 | 主要機能 |
|-------|------|---------|
| Phase 1 | ✅ 完了 | 基盤構築、Google OAuth認証 |
| Phase 2 | ✅ 完了 | チャンネル管理、動画再生、視聴位置保存 |
| Phase 3 | ✅ 完了 | 視聴履歴、Analytics、オフライン対応 |
| Phase 4 | ✅ 完了 | パフォーマンス最適化、エラーハンドリング統一 |

**詳細**: `docs/archive/implementation-history.md`

### 実装済み機能

#### コア機能
- ✅ Google認証（Firebase Authentication）
- ✅ チャンネル追加・管理・削除
- ✅ 動画リスト表示
- ✅ 動画再生（再生速度変更対応）
- ✅ 視聴位置の保存・復元

#### 拡張機能
- ✅ 視聴履歴管理
- ✅ Firebase Analytics統合
- ✅ オフライン対応（SQLiteキャッシュ）
- ✅ バックグラウンド再生インフラ（iOS/Android設定済み）

#### 品質・最適化
- ✅ 画像キャッシュ最適化（CachedNetworkImage）
- ✅ データ整合性の確保
- ✅ エラーハンドリング統一
- ✅ Lint 0エラー

---

## 🏗️ アーキテクチャ

### レイヤードアーキテクチャ

```
lib/
├── main.dart                          # エントリーポイント
├── config/                            # 環境設定
│   ├── constants.dart                 # アプリ定数
│   └── theme/                         # Material Design 3テーマ
├── core/                              # コア機能
│   ├── analytics/                     # Firebase Analytics
│   └── errors/                        # エラー定義
├── domain/                            # ドメイン層
│   └── entities/                      # エンティティ
├── data/                              # データ層
│   ├── models/                        # データモデル
│   ├── repositories/                  # リポジトリ
│   └── services/                      # 外部サービス連携
└── presentation/                      # プレゼンテーション層
    ├── providers/                     # 状態管理（Provider）
    ├── screens/                       # 画面
    └── widgets/                       # 再利用可能なウィジェット
```

### 主要な技術決定

#### フレームワーク
- **Flutter 3.38.5 / Dart 3.10.4**: クロスプラットフォーム開発
- **Material Design 3**: UIデザインシステム
- **レイヤードアーキテクチャ**: 層分離とシンプルな依存関係

#### 状態管理
- **Provider**: シンプルで効果的な状態管理

#### バックエンド
- **Firebase Authentication**: Google Sign-in
- **Cloud Firestore**: データ永続化
- **Firebase Analytics**: 利用状況分析

#### ストレージ
- **Google Drive API v3**: 動画・設定ファイル取得
- **SQLite (sqflite)**: ローカルキャッシュ

#### 動画・画像
- **video_player, chewie**: 動画再生
- **cached_network_image**: 画像キャッシュ

---

## 🎨 デザインシステム

### ブランディング
- **アプリ名**: Feedivo（フィーディーヴォ）
- **コンセプト**: "Feed" + "Video" の造語

### カラースキーム
- **プライマリカラー**: Deep Navy (#1E3A5F)
- **デザインシステム**: Material Design 3準拠
- **デザインフィロソフィー**: 穏やかで落ち着いた美的感覚

---

## 🔧 開発ガイドライン

### コーディング原則

#### レイヤー分離
```
Domain層  : エンティティ（ビジネスロジックの核）
Data層    : モデル、リポジトリ、サービス（データアクセス）
Presentation層: Provider、画面、ウィジェット（UI）
```

**設計方針**:
- 過度な抽象化を避け、シンプルな実装を優先
- リポジトリは具象クラスとして実装（インターフェースなし）
- Providerで依存性注入を行う

#### Null Safety
- Dartのnull安全性を最大限活用
- 適切な`?`と`!`の使用

#### エラーハンドリング
- ユーザーフレンドリーなエラーメッセージ（`ErrorDisplay`ウィジェット）
- 適切なログ記録（Firebase Analytics）
- ネットワークエラーへの対応（オフラインキャッシュ）

#### パフォーマンス
- 画像キャッシュ（`CachedNetworkImage`）
- リスト最適化（`ListView.builder`）
- Firestoreクエリの最小化（ローカルキャッシュ優先）

### コード品質
- **lint**: dart analyze --fatal-infos で0エラー
- **format**: dart format で整形
- **const**: 可能な限りconstコンストラクタを使用

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

### Firestoreセキュリティルール
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null
                     && request.auth.uid == userId;
}
```

---

## 🔍 既知の制約と将来の拡張

### 技術的制約

#### Google Drive API制限
- 1日あたり1,000,000リクエスト
- レート制限への対応が必要

#### Web版の制約
- バックグラウンド再生の制限
- プッシュ通知非対応

#### バックグラウンド再生
- インフラのみ実装済み（iOS/Android設定完了）
- VideoPlayerScreenへの完全統合は未実施（技術的複雑度が高い）
- 詳細: `docs/archive/phase3-4-background-playback.md`

### 将来の拡張候補（Phase 5+）

#### 追加機能
- [ ] プレイリスト機能
- [ ] 検索機能（チャンネル・動画）
- [ ] コメント機能
- [ ] 通知機能（新動画アップロード）
- [ ] Google Picker API統合（チャンネル追加UX改善）

#### バックグラウンド再生完全統合（Phase 3-4b）
- [ ] VideoPlayerScreenの書き換え
- [ ] バックグラウンド/フォアグラウンド切り替え
- [ ] ロック画面コントロール

#### 追加最適化
- [ ] Firestoreクエリの最適化（リアルタイムリスナー）
- [ ] スケルトンローディングの導入
- [ ] Pull-to-refresh機能

#### 設定画面の拡張
- [ ] キャッシュクリア機能
- [ ] デフォルト再生速度の設定
- [ ] ダークモード切り替え

---

## 📚 重要なドキュメント

### セットアップ
- `docs/setup/firebase-google-cloud-setup.md` - Firebase & Google Cloud設定
- `docs/setup/local-setup-instructions.md` - ローカル開発環境設定

### 実装履歴
- `docs/archive/implementation-history.md` - Phase 1-4の詳細実装履歴
- `docs/archive/phase4-completion-summary.md` - Phase 4完了サマリー
- `docs/archive/phase3-4-background-playback.md` - バックグラウンド再生実装状況

### デザイン
- `docs/visual_design.md` - ビジュアルデザインガイド

### テスト
- `docs/test_channel_setup.md` - テスト用チャンネルセットアップ

---

## 💡 AI支援時の注意事項

### Claudeに期待すること
1. **プロジェクトコンテキストの理解**: このドキュメントを参照して一貫性のある提案を行う
2. **技術的な妥当性**: 最新のFlutter/Firebase/Google APIのベストプラクティスに基づく
3. **セキュリティ意識**: 常にセキュリティとプライバシーを考慮
4. **シンプルな設計**: 過度な抽象化を避け、必要十分な実装を提案
5. **コード品質**: lint 0エラーを維持

### 回答時のガイドライン
- 不明点は推測せず「わかりません」と回答
- レイヤー分離を維持し、シンプルな依存関係を保つ
- 既存のコーディングスタイルに従う
- パフォーマンスとユーザー体験を考慮
- バージョン情報を含める（古い情報を避ける）

### よく使用するパターン

#### Provider統合
```dart
ChangeNotifierProvider(
  create: (context) => SomeProvider(
    context.read<SomeRepository>(),
  ),
)
```

#### エラー表示
```dart
ErrorDisplay(
  message: 'エラーメッセージ',
  onRetry: () => _loadData(),
)
```

#### 画像表示
```dart
CachedNetworkImage(
  imageUrl: 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
  memCacheWidth: width.toInt() * 2,
  memCacheHeight: height.toInt() * 2,
)
```

---

## 🚀 現在の状態

**Feedivoアプリは現在、プロダクション環境へのデプロイ準備が整った状態です。**

すべてのコア機能と拡張機能が実装され、パフォーマンスが最適化され、コード品質が確保されています。

### 次のステップ

1. **追加機能の実装**（Phase 5）
2. **テスト自動化**（単体テスト、統合テスト）
3. **デプロイ準備**（App Store / Play Store申請）
4. **ユーザーフィードバック**（ベータテスト）

---

## 🔄 このドキュメントの更新

このCLAUDE.mdは「生きたドキュメント」です。以下の場合に更新してください：

- 重要な技術的決定を行った時
- 新しい制約や課題が見つかった時
- アーキテクチャに変更があった時
- 新しいPhaseが開始された時
