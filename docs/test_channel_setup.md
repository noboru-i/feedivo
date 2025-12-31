# テストチャンネルの作成手順

Phase 2-2で実装したチャンネル追加機能をテストするための手順です。

## 手順1: サンプルJSONファイルを取得

プロジェクトに含まれるサンプルファイルを使用します：
```
docs/sample_channel_config.json
```

## 手順2: Google Driveにアップロード

1. [Google Drive](https://drive.google.com)にアクセス
2. 「新規」→「ファイルのアップロード」を選択
3. `sample_channel_config.json` をアップロード

## 手順3: ファイルを共有設定

1. アップロードしたファイルを右クリック → 「共有」を選択
2. 「一般的なアクセス」を **「リンクを知っている全員」** に変更
3. 権限は **「閲覧者」** のまま（推奨）
4. 「リンクをコピー」をクリック

**共有リンクの例**:
```
https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing
```

## 手順4: Feedivoアプリでチャンネル追加

### 方法A: 共有URL全体をコピー&ペースト（推奨）

1. Feedivoアプリを起動してログイン
2. ホーム画面の「+」ボタンをタップ
3. **共有リンク全体**をペースト：
   ```
   https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing
   ```
4. 「チャンネルを追加」ボタンをタップ

アプリが自動的にURLからFile IDを抽出します。

### 方法B: File IDのみを入力

1. 共有リンクから `/d/` の後の部分（File ID）を抽出：
   ```
   1a2b3c4d5e6f7g8h9i0j
   ```
2. Feedivoアプリの入力欄にFile IDのみを貼り付け
3. 「チャンネルを追加」ボタンをタップ

## 手順5: 動作確認

### 成功時
- 「チャンネルを追加しました」のメッセージが表示される
- ホーム画面に「テストチャンネル」のカードが表示される
- カードにはグラデーション背景と動画ライブラリアイコンが表示される

### エラー時
エラーメッセージを確認してください：

- **「有効なGoogle Drive URLではありません」**
  → URL形式が間違っています。手順3でコピーしたリンクを再確認してください

- **「File IDまたはURLを入力してください」**
  → 入力欄が空です

- **「チャンネルの追加に失敗しました」**
  → 以下を確認：
    - Google Driveファイルが「リンクを知っている全員」に共有されているか
    - ログインしているGoogleアカウントでDriveにアクセスできるか
    - ネットワーク接続が正常か

## Phase 2-3用のテストデータ（今後使用）

Phase 2-3（動画リスト表示）の実装後、以下のような動画データを含むJSONを作成します：

```json
{
  "version": "1.0",
  "channel": {
    "id": "test-channel-002",
    "name": "動画付きテストチャンネル",
    "description": "動画リスト表示テスト用",
    "thumbnail_file_id": null,
    "updated_at": "2025-12-31T00:00:00Z"
  },
  "videos": [
    {
      "id": "video-001",
      "title": "テスト動画 #1",
      "description": "最初のテスト動画です",
      "video_file_id": "YOUR_VIDEO_FILE_ID",
      "thumbnail_file_id": null,
      "duration": 120,
      "published_at": "2025-12-30T00:00:00Z"
    },
    {
      "id": "video-002",
      "title": "テスト動画 #2",
      "description": "2番目のテスト動画です",
      "video_file_id": "YOUR_VIDEO_FILE_ID",
      "thumbnail_file_id": null,
      "duration": 300,
      "published_at": "2025-12-31T00:00:00Z"
    }
  ]
}
```

**注意**: Phase 2-3では実際の動画ファイルをGoogle Driveにアップロードし、そのFile IDを設定する必要があります。

## トラブルシューティング

### 1. 「Permission denied」エラー

**原因**: ファイルの共有設定が正しくない

**解決策**:
1. Google Driveで該当ファイルを開く
2. 「共有」設定を確認
3. 「一般的なアクセス」が「リンクを知っている全員」になっているか確認
4. 権限が「閲覧者」以上になっているか確認

### 2. 「Invalid JSON」エラー

**原因**: JSONファイルの形式が間違っている

**解決策**:
1. `sample_channel_config.json` を再度ダウンロード
2. テキストエディタでJSONの構文を確認（[JSONLint](https://jsonlint.com/)で検証）
3. Google Driveに再アップロード

### 3. 「Network error」

**原因**: ネットワーク接続の問題

**解決策**:
1. デバイスのインターネット接続を確認
2. Google Driveにブラウザからアクセスできるか確認
3. VPNを使用している場合は無効化してみる

## 参考情報

- JSONスキーマ仕様: `/Users/noboruishikura/.claude/plans/distributed-churning-ullman.md`（Phase 2-1セクション）
- Google Drive API scopes: `drive.readonly`（Phase 1で設定済み）
