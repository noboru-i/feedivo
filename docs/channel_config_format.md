# チャンネル設定ファイルフォーマット

## 概要

Feedivoでは、以下の3つの方法でチャンネルを登録できます:

1. **JSONファイル指定**: Google Drive上のJSONファイルでチャンネルと動画リストを管理
2. **フォルダ指定（JSON付き）**: フォルダ内の`channel_config.json`を自動検出
3. **フォルダ指定（JSONなし）**: フォルダ内の動画ファイルを自動検出してチャンネル生成

## 登録方法

### 1. JSONファイル指定

JSONファイルのURLまたはFile IDを指定してチャンネルを登録します。

**URL形式**:
```
https://drive.google.com/file/d/{fileId}/view
```

### 2. フォルダ指定

フォルダのURLまたはFolder IDを指定してチャンネルを登録します。

**URL形式**:
```
https://drive.google.com/drive/folders/{folderId}
```

**挙動**:
- フォルダ内に`channel_config.json`がある場合: JSONファイルを使用
- JSONがない場合: フォルダ名をチャンネル名として自動生成

### 3. 共有URL

共有URLからもチャンネルを登録できます。

**URL形式**:
```
https://drive.google.com/open?id={fileId}
```

## ファイル構造

### channel_config.json（完全版）

```json
{
  "version": "1.0",
  "channel": {
    "id": "unique-channel-id",
    "name": "チャンネル名",
    "description": "チャンネルの説明",
    "thumbnail_file_id": "GoogleDriveのファイルID（省略可）",
    "updated_at": "2025-01-05T00:00:00Z"
  },
  "videos": [
    {
      "id": "video-001",
      "title": "動画タイトル",
      "description": "動画の説明",
      "video_file_id": "GoogleDriveの動画ファイルID",
      "thumbnail_file_id": "GoogleDriveのサムネイルファイルID（省略可）",
      "duration": 3600,
      "published_at": "2025-01-05T00:00:00Z"
    }
  ]
}
```

### channel_config.json（最小版 - 動画自動検出）

```json
{
  "version": "1.0",
  "channel": {
    "id": "simple-channel",
    "name": "シンプルチャンネル",
    "description": "同一フォルダの動画を自動検出",
    "updated_at": "2025-01-05T00:00:00Z"
  }
}
```

`videos`フィールドを省略すると、同一フォルダ内の動画ファイルが自動的に検出されます。

## フィールド説明

### ルートレベル

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `version` | String | ✓ | 設定ファイルのバージョン（現在は"1.0"のみ） |
| `channel` | Object | ✓ | チャンネル情報 |
| `videos` | Array | - | 動画リスト（省略時は自動検出） |

### チャンネル情報

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `id` | String | ✓ | チャンネルの一意識別子 |
| `name` | String | ✓ | チャンネル名 |
| `description` | String | ✓ | チャンネルの説明 |
| `thumbnail_file_id` | String | - | チャンネルサムネイルのGoogle Drive File ID |
| `updated_at` | String | ✓ | 更新日時（ISO 8601形式） |

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

## 動画ファイル自動検出

### サポートされている動画形式

以下の動画形式がサポートされています:

| 形式 | MIMEタイプ | 拡張子 |
|------|-----------|--------|
| MP4 | video/mp4 | .mp4 |
| WebM | video/webm | .webm |
| QuickTime | video/quicktime | .mov |
| AVI | video/x-msvideo | .avi |
| Matroska | video/x-matroska | .mkv |

### 自動検出の挙動

#### パターン1: JSONの`videos`フィールドを省略

JSONファイルに`videos`フィールドがない場合、同一フォルダ内の動画ファイルが自動的に検出されます。

**例**:
```json
{
  "version": "1.0",
  "channel": {
    "id": "my-channel",
    "name": "マイチャンネル",
    "description": "動画を自動検出",
    "updated_at": "2025-01-05T00:00:00Z"
  }
}
```

#### パターン2: フォルダを直接指定（JSONなし）

フォルダURLを指定し、フォルダ内に`channel_config.json`がない場合:

- フォルダ名がチャンネル名になります
- チャンネルIDは `folder_{folderId}` として自動生成されます
- フォルダ内の全動画ファイルが検出されます

### 自動検出時の動画情報

自動検出された動画は以下のように設定されます:

- **id**: ファイルのDrive File ID
- **title**: ファイル名から拡張子を除去したもの
- **description**: ファイル名
- **video_file_id**: ファイルのDrive File ID
- **duration**: 0（再生時に実際の長さを取得）
- **published_at**: ファイルの作成日時または更新日時

## セットアップ方法

詳細は`docs/test_channel_setup.md`を参照してください。
