# Firestoreデータ構造とセキュリティルール

## データ構造

### コレクション階層

```
users/{userId}/
  ├── channels/{channelId}/
  │   ├── id: String
  │   ├── userId: String
  │   ├── name: String
  │   ├── description: String
  │   ├── thumbnailFileId: String?
  │   ├── configFileId: String
  │   ├── createdAt: Timestamp
  │   ├── updatedAt: Timestamp
  │   ├── lastFetchedAt: Timestamp?
  │   └── videos/{videoId}/
  │       ├── id: String
  │       ├── channelId: String
  │       ├── title: String
  │       ├── description: String
  │       ├── videoFileId: String
  │       ├── thumbnailFileId: String?
  │       ├── duration: Integer
  │       └── publishedAt: Timestamp
  └── playback_positions/{videoId}/
      ├── videoId: String
      ├── channelId: String
      ├── position: Integer (秒)
      ├── duration: Integer (秒)
      ├── lastPlayedAt: Timestamp
      ├── isCompleted: Boolean
      └── watchPercentage: Double (0.0-1.0)
```

## データモデル詳細

### channels/{channelId}

チャンネル情報を格納します。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | String | チャンネルID（ドキュメントIDと同じ） |
| `userId` | String | チャンネルを追加したユーザーのID |
| `name` | String | チャンネル名 |
| `description` | String | チャンネルの説明 |
| `thumbnailFileId` | String? | サムネイル画像のGoogle Drive File ID |
| `configFileId` | String | 設定ファイルのGoogle Drive File ID |
| `createdAt` | Timestamp | 作成日時 |
| `updatedAt` | Timestamp | 最終更新日時 |
| `lastFetchedAt` | Timestamp? | 設定ファイルの最終取得日時 |

### videos/{videoId}

動画情報を格納します（channelsのサブコレクション）。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `id` | String | 動画ID（ドキュメントIDと同じ） |
| `channelId` | String | 所属チャンネルのID |
| `title` | String | 動画タイトル |
| `description` | String | 動画の説明 |
| `videoFileId` | String | 動画ファイルのGoogle Drive File ID |
| `thumbnailFileId` | String? | サムネイル画像のGoogle Drive File ID |
| `duration` | Integer | 動画の長さ（秒） |
| `publishedAt` | Timestamp | 公開日時 |

### playback_positions/{videoId}

視聴位置情報を格納します。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `videoId` | String | 動画ID（ドキュメントIDと同じ） |
| `channelId` | String | 所属チャンネルのID |
| `position` | Integer | 視聴位置（秒） |
| `duration` | Integer | 動画の長さ（秒） |
| `lastPlayedAt` | Timestamp | 最終再生日時 |
| `isCompleted` | Boolean | 視聴完了フラグ |
| `watchPercentage` | Double | 視聴進捗率（0.0-1.0） |

## セキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザー配下のすべてのドキュメントへのアクセス制御
    match /users/{userId} {
      // 認証済みかつ自分のデータのみアクセス可能
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      // サブコレクションにも同じルールが適用される
      match /{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

## セキュリティルールの説明

### 基本方針

- すべてのデータはユーザー配下に保存
- 認証済みユーザーのみアクセス可能
- 自分のデータのみ読み書き可能
- サブコレクション（channels, videos, playback_positions）にも同じルールを適用

### ルールの詳細

- `request.auth != null`: ユーザーが認証されているかチェック
- `request.auth.uid == userId`: リクエストユーザーIDとドキュメントのユーザーIDが一致するかチェック
- `match /{document=**}`: すべてのサブコレクションに再帰的にルールを適用

## オフライン永続化

Feedivoでは、Firestoreのネイティブオフライン永続化機能を使用しています。

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

これにより、オフラインでもデータへのアクセスが可能になります。
