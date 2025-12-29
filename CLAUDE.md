# CLAUDE.md - AI開発支援コンテキスト

このドキュメントは、ClaudeなどのAIアシスタントがFeedivoプロジェクトに関する作業を効率的に行うための包括的なコンテキスト情報を提供します。

## 📌 プロジェクト概要

### コアコンセプト
Feedivoは「Google Driveをポッドキャストのように楽しむ」というコンセプトの動画視聴アプリです。
既存の動画プラットフォームやポッドキャストアプリとは異なり、以下の特徴的な組み合わせを実現します：

1. **Google Driveホスティング**: 配信者が自分のGoogle Drive上に動画を保存
2. **セルフマネージドRSSフィード**: JSONベースの設定ファイルで動画リストを管理
3. **ポッドキャスト型視聴**: URLを登録するだけでコンテンツにアクセス
4. **視聴位置記憶**: 途中再生機能とクロスプラットフォーム同期

### ターゲットユーザー
- **配信者**: 独自の動画コンテンツを簡易的に配信したい個人・小規模団体
- **視聴者**: 特定の配信者のコンテンツを継続的に視聴したいユーザー

## 🎨 デザインシステム

### ブランディング
- **アプリ名**: Feedivo（フィーディーヴォ）
  - コインドターム（造語）で商標衝突リスクが最小
  - "Feed"（フィード）と"Video"（動画）の組み合わせ

### カラースキーム
- **プライマリカラー**: Deep Navy (#1E3A5F)
  - 落ち着いた、洗練された印象
  - 長時間の視聴でも目に優しい
- **デザインシステム**: Material Design 3準拠
- **デザインフィロソフィー**: 穏やかで落ち着いた美的感覚

### UI/UXモックアップ
完成済みの画面モックアップが7つあり、インタラクティブプロトタイプも作成済み：
1. スプラッシュ画面
2. ログイン画面
3. チャンネル一覧（ホーム）
4. チャンネル追加
5. 動画リスト
6. 動画再生
7. 設定画面

## 🏗️ アーキテクチャ決定記録

### フレームワーク選定
**Flutter選定理由**:
- 真のクロスプラットフォーム（iOS/Android/Web）
- 単一コードベースでの開発効率
- Material Design 3の優れたサポート
- 活発なエコシステム

### 認証スコープの重要な決定

#### 検討された選択肢
1. **drive.readonly** (現在の選択)
   - 長所: セキュアで必要最小限の権限
   - 短所: ユーザーが個別に各ファイルへのアクセスを承認する必要がある
   
2. **drive.file** (代替案)
   - 長所: アプリが作成したファイルへの自動アクセス、スムーズなUX
   - 短所: より広い権限、ユーザーの懸念を招く可能性

#### 現在の方針
- **Phase 1**: `drive.readonly` で実装開始
- **理由**: セキュリティ優先、Google審査通過の容易性
- **将来**: UX問題が深刻な場合は `drive.file` への移行を検討
- **補完策**: Google Picker API統合でOAuth承認フローを簡素化

### データストレージ戦略

#### Firestore構造
```
users/{userId}/
  └── channels/{channelId}/
      └── videos/{videoId}/
```

**設計原則**:
- ユーザーごとのデータ分離
- 階層的なコレクション構造
- オフライン同期対応

#### ローカルDB (SQLite)
- **用途**: オフライン対応とキャッシュ
- **Firestoreとの役割分担**: 
  - Firestore = マスターデータと同期
  - SQLite = ローカルキャッシュと高速アクセス

## 🔧 技術仕様

### 主要パッケージ（バージョン管理）
```yaml
# 認証・Drive API
google_sign_in: ^6.1.0  # 最新7.xも調査済み
googleapis: ^11.0.0
googleapis_auth: ^1.4.0

# Firebase
firebase_core: ^2.24.0
firebase_auth: ^4.15.0
cloud_firestore: ^4.13.0
firebase_analytics: ^10.7.0

# 動画再生
video_player: ^2.8.0
chewie: ^1.7.0

# 状態管理（選択肢）
provider: ^6.1.0
# OR riverpod: ^2.4.0
```

**注意**: パッケージバージョンは実装時に最新の安定版を確認すること

### Google Drive API統合

#### 動画ストリーミング
```dart
// 認証付きストリーミングURL
final videoUrl = 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media';

VideoPlayerController.network(
  videoUrl,
  httpHeaders: {
    'Authorization': 'Bearer $accessToken',
  },
)
```

#### トークン管理
- 自動リフレッシュメカニズムの実装必須
- トークン期限切れのエラーハンドリング
- 最新のGoogle OAuth 2.0パターンに従う

### セキュリティルール

#### Firestore Security Rules
```javascript
// ユーザーは自分のデータのみアクセス可能
match /users/{userId} {
  allow read, write: if request.auth != null 
                     && request.auth.uid == userId;
}
```

**原則**:
- すべてのデータはユーザーごとに分離
- 認証必須
- 最小権限の原則

## 📊 開発フェーズと優先順位

### Phase 1: 基盤構築（2-3週間）
**優先度**: 🔴 最高
- [ ] Flutterプロジェクトセットアップ
- [ ] Firebase初期設定（Auth, Firestore, Analytics）
- [ ] Google OAuth認証実装
- [ ] 基本的な画面レイアウト（モックアップに基づく）

### Phase 2: コア機能（3-4週間）
**優先度**: 🔴 最高
- [ ] Google Drive API連携
- [ ] チャンネル追加・管理機能
- [ ] 動画リスト表示
- [ ] 動画再生機能（基本）
- [ ] 視聴位置の保存・復元

**焦点**: 視聴者機能（配信者ツールは後回し）

### Phase 3: 拡張機能（2-3週間）
**優先度**: 🟡 中
- [ ] 視聴履歴管理
- [ ] バックグラウンド再生
- [ ] オフライン対応（メタデータキャッシュ）
- [ ] Firebase Analytics実装

### Phase 4: 最適化・テスト（2週間）
**優先度**: 🟢 通常
- [ ] パフォーマンス最適化
- [ ] UI/UX改善
- [ ] 各プラットフォームでのテスト
- [ ] バグ修正

### 将来の拡張（Phase 5+）
**優先度**: 🔵 低
- オフライン動画ダウンロード
- プレイリスト機能
- 配信者向けツール（設定ファイル生成UI）
- 通知機能
- コメント機能

## 🎯 実装ガイドライン

### コーディング原則
1. **Clean Architecture**: 層分離を厳守
   - Presentation Layer (Screens/Widgets)
   - Business Logic Layer (Providers/Services)
   - Data Layer (Repositories/Models)

2. **Null Safety**: Dartのnull安全性を最大限活用

3. **エラーハンドリング**: 
   - ユーザーフレンドリーなエラーメッセージ
   - 適切なログ記録（Firebase Crashlytics）
   - ネットワークエラーへの対応

4. **テスト**:
   - 単体テスト: ビジネスロジック
   - ウィジェットテスト: UI コンポーネント
   - 統合テスト: クリティカルフロー

### パフォーマンス最適化
- **画像キャッシュ**: `cached_network_image` 使用
- **リスト最適化**: `ListView.builder` で遅延ロード
- **Firestore読み取り最小化**: 
  - ローカルキャッシュ優先
  - リアルタイムリスナーは最小限に

### Firebase Analytics イベント設計
**主要トラッキングイベント**:
```dart
// チャンネル追加
'channel_added' {channel_id, source}

// 動画再生
'video_play_start' {video_id, channel_id}
'video_completed' {video_id, watch_duration}

// ユーザーエンゲージメント
'screen_view' {screen_name}
```

## 🚨 既知の制約と課題

### 技術的制約
1. **Google Drive API制限**
   - 1日あたり1,000,000リクエスト
   - レート制限への対応が必要

2. **Web版の制約**
   - バックグラウンド再生の制限
   - プッシュ通知非対応
   - ローカルストレージ容量制限

3. **動画ストリーミング**
   - DRM保護コンテンツは再生不可
   - 大容量動画の帯域幅考慮

### UX課題と対応策
1. **OAuth承認の煩雑さ**
   - **課題**: `drive.readonly` では各ファイルごとに承認が必要
   - **対応**: Google Picker API統合で改善

2. **初回セットアップの複雑さ**
   - **対応**: チュートリアル画面の実装
   - **対応**: エラーメッセージの明確化

## 🔍 トラブルシューティング参考

### よくある問題
1. **OAuth認証エラー**
   - Client IDの設定確認
   - スコープの一致確認
   - リダイレクトURIの設定

2. **動画再生エラー**
   - アクセストークンの有効性
   - ファイルIDの正確性
   - ネットワーク接続

3. **Firestore権限エラー**
   - Security Rulesの確認
   - 認証状態の確認

## 📚 参考資料

### 公式ドキュメント
- [Flutter公式](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Google Drive API v3](https://developers.google.com/drive/api/v3/about-sdk)
- [Material Design 3](https://m3.material.io/)

### プロジェクト固有ドキュメント
- `/要件概要` - 初期要件定義
- `/外部設計書_DriveVideoPlayer.md` - 詳細設計仕様

### 重要な意思決定の経緯
プロジェクト名選定プロセス:
1. DriveCast → 既存サービスと衝突
2. VodCast → 既存サービスと衝突
3. PlayDrive → 既存サービスと衝突
4. **Feedivo** ✅ → コインドターム、衝突リスク最小

## 💡 AI支援時の注意事項

### Claudeに期待すること
1. **プロジェクトコンテキストの理解**: このドキュメントを参照して一貫性のある提案を行う
2. **技術的な妥当性**: 最新のFlutter/Firebase/Google APIのベストプラクティスに基づく
3. **セキュリティ意識**: 常にセキュリティとプライバシーを考慮
4. **ユーザー体験優先**: 技術的な実現可能性とUXのバランス

### 回答時のガイドライン
- 不明点は推測せず「わかりません」と回答
- 使用したソースやURLを明示
- 外部設計書との整合性を保つ
- バージョン情報を含める（古い情報を避ける）

## 🔄 このドキュメントの更新

このCLAUDE.mdは「生きたドキュメント」です。以下の場合に更新してください：

- 重要な技術的決定を行った時
- 新しい制約や課題が見つかった時
- アーキテクチャに変更があった時
- フェーズが進行した時
