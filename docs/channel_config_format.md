# チャンネル設定ファイルフォーマット

## 概要

Feedivoでは、Google Drive上のJSONファイルでチャンネルと動画リストを管理します。

## ファイル構造

### channel_config.json

```json
{
  "id": "unique-channel-id",
  "name": "チャンネル名",
  "description": "チャンネルの説明",
  "thumbnail_file_id": "GoogleDriveのファイルID（省略可）",
  "videos": [
    {
      "id": "video-001",
      "title": "動画タイトル",
      "description": "動画の説明",
      "video_file_id": "GoogleDriveの動画ファイルID",
      "thumbnail_file_id": "GoogleDriveのサムネイルファイルID（省略可）",
      "duration": 3600,
      "published_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## フィールド説明

### チャンネル情報

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `id` | String | ✓ | チャンネルの一意識別子 |
| `name` | String | ✓ | チャンネル名 |
| `description` | String | ✓ | チャンネルの説明 |
| `thumbnail_file_id` | String | - | チャンネルサムネイルのGoogle Drive File ID |
| `videos` | Array | ✓ | 動画リスト（空配列可） |

### 動画情報

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `id` | String | ✓ | 動画の一意識別子 |
| `title` | String | ✓ | 動画タイトル |
| `description` | String | ✓ | 動画の説明 |
| `video_file_id` | String | ✓ | 動画ファイルのGoogle Drive File ID |
| `thumbnail_file_id` | String | - | サムネイルのGoogle Drive File ID |
| `duration` | Integer | ✓ | 動画の長さ（秒） |
| `published_at` | String | ✓ | 公開日時（ISO 8601形式） |

## 将来の拡張機能

### videosフィールドが無い場合の自動検出（TODO）

JSONファイルに`videos`フィールドが無い場合、同一ディレクトリ内のmp4ファイルを自動的に検出して再生リストを生成する機能を実装予定。

```json
{
  "id": "simple-channel",
  "name": "シンプルチャンネル",
  "description": "同一フォルダのmp4を自動検出"
}
```

この場合、channel_config.jsonと同じGoogle Driveフォルダ内の.mp4ファイルが自動的にvideosリストとして扱われます。

## セットアップ方法

詳細は`docs/test_channel_setup.md`を参照してください。
