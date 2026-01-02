# Firebase & Google Cloud セットアップガイド

このドキュメントは、Feedivoアプリの開発環境（DEV）または本番環境（PROD）を構築する際に必要なFirebaseとGoogle Cloudの設定手順をまとめたものです。

## 前提条件

- Googleアカウント
- Flutter開発環境（3.38.5以上）
- プロジェクトのソースコード

## セットアップ手順の概要

1. [Firebase プロジェクト作成](#1-firebase-プロジェクト作成)
2. [Firebase サービス有効化](#2-firebase-サービス有効化)
3. [Google Cloud API有効化](#3-google-cloud-api有効化)
4. [OAuth同意画面設定](#4-oauth同意画面設定)
5. [OAuth クライアントID作成](#5-oauth-クライアントid作成)
6. [アプリへの設定反映](#6-アプリへの設定反映)

---

## 1. Firebase プロジェクト作成

### 1-1. Firebase Consoleにアクセス

https://console.firebase.google.com/ にアクセス

### 1-2. プロジェクトを作成

1. 「プロジェクトを追加」ボタンをクリック
2. プロジェクト名を入力
   - DEV環境: `feedivo-dev`
   - PROD環境: `feedivo-prod`
3. 「続行」をクリック
4. Google Analyticsを有効化（推奨: オン）
5. Analyticsアカウントを選択または新規作成
6. 「プロジェクトを作成」をクリック

### 1-3. プロジェクトIDを記録

作成完了後、プロジェクトIDをメモしておく（例: `feedivo-dev-a1b2c3`）

---

## 2. Firebase サービス有効化

### 2-1. Authentication（認証）

1. Firebase Console左メニュー「構築」→「Authentication」
2. 「始める」ボタンをクリック
3. Sign-in method タブを選択
4. 「Google」を選択
5. 有効化スイッチをオン
6. プロジェクトのサポートメールを選択
7. 「保存」をクリック

### 2-2. Firestore Database

1. Firebase Console左メニュー「構築」→「Firestore Database」
2. 「データベースの作成」ボタンをクリック
3. セキュリティルールを選択:
   - **本番モード**を選択（推奨）
4. ロケーションを選択:
   - 日本: `asia-northeast1` (東京)
   - または `asia-northeast2` (大阪)
5. 「有効にする」をクリック

### 2-3. セキュリティルールの設定

Firestoreのルールタブで以下を設定:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーは自分のデータのみアクセス可能
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      // サブコレクションも同様
      match /{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

「公開」ボタンをクリック

### 2-4. Analytics（オプション）

プロジェクト作成時に有効化していれば、自動的に設定されています。
Firebase Console左メニュー「エンゲージ」→「Analytics」で確認できます。

---

## 3. Google Cloud API有効化

Firebase プロジェクトは自動的にGoogle Cloudプロジェクトとリンクされます。

### 3-1. Google Cloud Consoleにアクセス

https://console.cloud.google.com/ にアクセスし、Firebaseで作成したプロジェクトを選択

### 3-2. Google Drive API を有効化

1. 左メニュー「APIとサービス」→「ライブラリ」
2. 検索ボックスに「Google Drive API」と入力
3. 「Google Drive API」を選択
4. 「有効にする」ボタンをクリック

### 3-3. Google People API を有効化

**重要**: Google Sign-inでユーザー情報を取得するために必須です。

1. 左メニュー「APIとサービス」→「ライブラリ」
2. 検索ボックスに「People API」と入力
3. 「Google People API」を選択
4. 「有効にする」ボタンをクリック

有効化には数分かかる場合があります。

---

## 4. OAuth同意画面設定

### 4-1. OAuth同意画面の作成

1. Google Cloud Console「APIとサービス」→「OAuth同意画面」
2. ユーザータイプを選択:
   - **外部**を選択（一般ユーザー向け）
3. 「作成」をクリック

### 4-2. アプリ情報の入力

**必須項目**:
- アプリ名: `Feedivo` (または `Feedivo DEV`)
- ユーザーサポートメール: 自分のメールアドレス
- デベロッパーの連絡先情報: 自分のメールアドレス

「保存して次へ」をクリック

### 4-3. スコープの設定

1. 「スコープを追加または削除」をクリック
2. 以下のスコープを選択:
   - `email` - メールアドレスの表示
   - `profile` - 個人情報の表示
   - `https://www.googleapis.com/auth/drive.readonly` - Google Driveファイルの読み取り

3. 「更新」をクリック
4. 「保存して次へ」をクリック

**重要**:
- `drive.readonly`スコープは、アプリがGoogle Drive上のファイルを読み取り専用でアクセスすることを許可します
- 以前のバージョンでは`drive.file`スコープを使用していましたが、セキュリティ向上のため`drive.readonly`に変更されました
- 既存ユーザーは次回ログイン時に新しいスコープの承認を求められます

### 4-4. テストユーザーの追加（開発中）

公開前は、テストユーザーとして登録されたGoogleアカウントのみがサインインできます。

1. 「テストユーザーを追加」をクリック
2. 開発/テストで使用するGoogleアカウントのメールアドレスを入力
3. 「保存して次へ」をクリック

### 4-5. 確認と完了

内容を確認して「ダッシュボードに戻る」をクリック

---

## 5. OAuth クライアントID作成

アプリの各プラットフォーム（iOS、Android、Web）ごとにOAuthクライアントIDを作成します。

### 5-1. パッケージ名/バンドルIDの確認

**Android パッケージ名**: `dev.noboru.feedivo`
- 確認場所: `android/app/build.gradle.kts` の `applicationId`

**iOS バンドルID**: `dev.noboru.feedivo`
- 確認場所: `ios/Runner.xcodeproj/project.pbxproj` の `PRODUCT_BUNDLE_IDENTIFIER`

**注意**: DEV環境とPROD環境で異なるパッケージ名を使用する場合は適宜変更してください。
- 例: DEV環境 `dev.noboru.feedivo.dev` / PROD環境 `dev.noboru.feedivo`

### 5-2. Android SHA-1フィンガープリント取得

#### Debug用

```bash
# プロジェクトルートディレクトリで実行
cd android

# Debug APKをビルド（初回のみ、keystoreを生成）
cd ..
flutter build apk --debug

# SHA-1フィンガープリントを取得
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

出力から`SHA1`行をコピー（例: `14:75:27:FE:CC:BD:4B:25:50:44:BE:90:47:5E:4D:A3:0D:03:41:90`）

#### Release用（本番環境のみ）

```bash
# リリース用keystoreを作成（まだない場合）
keytool -genkey -v -keystore ~/feedivo-release.keystore -alias feedivo -keyalg RSA -keysize 2048 -validity 10000

# SHA-1フィンガープリントを取得
keytool -list -v -keystore ~/feedivo-release.keystore -alias feedivo
```

### 5-3. iOS OAuth クライアントID作成

1. Google Cloud Console「APIとサービス」→「認証情報」
2. 「認証情報を作成」→「OAuth クライアント ID」
3. アプリケーションの種類: **iOS**
4. 詳細を入力:
   - **名前**: `Feedivo iOS Client` (または `Feedivo DEV iOS Client`)
   - **バンドル ID**: `dev.noboru.feedivo`
5. 「作成」をクリック
6. **クライアントID**をコピーして保存
   - 形式: `XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com`

### 5-4. Android OAuth クライアントID作成

1. Google Cloud Console「APIとサービス」→「認証情報」
2. 「認証情報を作成」→「OAuth クライアント ID」
3. アプリケーションの種類: **Android**
4. 詳細を入力:
   - **名前**: `Feedivo Android Client` (または `Feedivo DEV Android Client`)
   - **パッケージ名**: `dev.noboru.feedivo`
   - **SHA-1 証明書フィンガープリント**: (5-2で取得したSHA-1)
5. 「作成」をクリック

### 5-5. Web OAuth クライアントID作成

1. Google Cloud Console「APIとサービス」→「認証情報」
2. 「認証情報を作成」→「OAuth クライアント ID」
3. アプリケーションの種類: **ウェブ アプリケーション**
4. 詳細を入力:
   - **名前**: `Feedivo Web Client` (または `Feedivo DEV Web Client`)

   - **承認済みの JavaScript 生成元**:
     ```
     http://localhost
     http://localhost:5000
     http://localhost:8080
     ```

     本番環境の場合は実際のドメインを追加:
     ```
     https://yourdomain.com
     ```

   - **承認済みのリダイレクト URI**: （上記と同じ）

5. 「作成」をクリック
6. **クライアントID**をコピーして保存

---

## 6. アプリへの設定反映

### 6-1. FlutterFire CLIのインストール

```bash
# Firebase CLIインストール（まだの場合）
npm install -g firebase-tools

# Firebase CLIにログイン
firebase login

# FlutterFire CLIインストール
dart pub global activate flutterfire_cli
```

### 6-2. FlutterFire設定の実行

プロジェクトルートディレクトリで以下を実行:

```bash
flutterfire configure
```

対話形式で以下を選択:
1. Firebase プロジェクトを選択（`feedivo-dev` または `feedivo-prod`）
2. プラットフォームを選択（iOS, Android, Web すべて選択）

自動的に以下のファイルが生成されます:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`

**注意**: これらのファイルには機密情報が含まれるため、`.gitignore`に追加されています。

### 6-3. iOS Info.plist設定

`ios/Runner/Info.plist`を開き、以下が自動追加されていることを確認:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX</string>
    </array>
  </dict>
</array>
```

`XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX`の部分は、5-3で作成したiOSクライアントIDの逆順です。

### 6-4. Web index.html設定

`web/index.html`を開き、`<head>`セクションに以下を追加:

```html
<!-- Google Sign-In -->
<meta name="google-signin-client_id" content="XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com">
```

`XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com`は5-5で作成したWebクライアントIDです。

### 6-5. 依存パッケージのインストール

```bash
flutter pub get
```

### 6-6. iOS Podのインストール

```bash
cd ios
pod install
cd ..
```

---

## 7. 動作確認

### 7-1. アプリのビルドと実行

**iOS**:
```bash
flutter run -d ios
```

**Android**:
```bash
flutter run -d android
```

**Web**:
```bash
flutter run -d chrome --web-port=8080
```

### 7-2. Google Sign-inのテスト

1. アプリを起動
2. スプラッシュ画面が表示される
3. ログイン画面が表示される
4. 「Googleでログイン」ボタンをタップ
5. Googleアカウント選択画面が表示される
6. アカウントを選択してログイン
7. ホーム画面に遷移する

### 7-3. Firebase Consoleでの確認

**Authentication**:
- https://console.firebase.google.com/project/[PROJECT_ID]/authentication/users
- ログインしたユーザーが表示されることを確認

**Firestore**:
- https://console.firebase.google.com/project/[PROJECT_ID]/firestore
- `users/{userId}`コレクションにユーザー情報が保存されることを確認

---

## トラブルシューティング

### スコープ変更後の権限不足エラー

アプリのスコープを`drive.file`から`drive.readonly`に変更した後、既存ユーザーが「ログインしていないか、権限が不足しています」というエラーに遭遇する場合があります。

**原因**: 既存の認証情報が古いスコープで取得されているため

**解決方法**:
1. アプリからログアウト
2. 再度Googleでログイン
3. 新しいスコープ（`drive.readonly`）の承認を行う

または、Google Cloud ConsoleでOAuth同意画面のスコープを更新してください：
1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 「APIとサービス」→「OAuth同意画面」
3. 「アプリを編集」をクリック
4. 「スコープ」セクションで`drive.file`を削除し、`drive.readonly`を追加
5. 変更を保存

### People API 403エラー

```
People API has not been used in project XXXXXXXXX before or it is disabled.
```

**解決方法**: [3-3. Google People API を有効化](#3-3-google-people-api-を有効化)を実行

### OAuth同意画面エラー

開発中、テストユーザーとして登録されていないアカウントでサインインしようとすると、アクセスが拒否されます。

**解決方法**: [4-4. テストユーザーの追加](#4-4-テストユーザーの追加開発中)でテストユーザーを追加

### iOS Google Sign-in エラー

**エラー**: `No valid iOS client IDs`

**解決方法**:
1. `ios/Runner/GoogleService-Info.plist`が存在するか確認
2. `ios/Runner/Info.plist`にReversed Client IDが設定されているか確認
3. Podfileのインストール: `cd ios && pod install`

### Android SHA-1エラー

**エラー**: `SHA-1 fingerprint mismatch`

**解決方法**:
1. 正しいkeystoreからSHA-1を取得しているか確認（debug/release）
2. Google Cloud ConsoleのAndroid OAuth設定に正しいSHA-1が登録されているか確認

### Web CORS エラー

**エラー**: `Access to XMLHttpRequest blocked by CORS policy`

**解決方法**:
1. `承認済みの JavaScript 生成元`に正しいURLが登録されているか確認
2. `http://localhost:8080`が含まれているか確認

---

## 環境別設定管理

DEV環境とPROD環境を分ける場合、以下のアプローチがあります:

### 方法1: Flavorを使用（推奨）

Flutter Flavorを使用して、ビルド時に環境を切り替えます。

### 方法2: 別プロジェクトとして管理

DEV用とPROD用で別のFirebaseプロジェクトを作成し、それぞれに対して上記の設定を行います。

### 設定ファイルの管理

機密情報を含む設定ファイルは、以下のように管理します:

- **リポジトリに含めない**: `.gitignore`に追加
- **環境変数**: CI/CDで環境変数として設定
- **セキュアストレージ**: Google Secret Manager等を使用

---

## チェックリスト

DEV/PROD環境のセットアップ時に、以下をチェックしてください:

- [ ] Firebase プロジェクトを作成
- [ ] Firebase Authentication (Google) を有効化
- [ ] Firebase Firestore を有効化・セキュリティルールを設定
- [ ] Google Drive API を有効化
- [ ] Google People API を有効化
- [ ] OAuth同意画面を設定
- [ ] テストユーザーを追加（開発中）
- [ ] iOS OAuth クライアントID を作成
- [ ] Android OAuth クライアントID を作成（Debug/Release両方）
- [ ] Web OAuth クライアントID を作成
- [ ] FlutterFire CLI を実行
- [ ] iOS Info.plist にReversed Client IDを確認
- [ ] Web index.html にクライアントIDを追加
- [ ] 各プラットフォームで動作確認
- [ ] Firebase Console でユーザー登録を確認
- [ ] Firebase Console でFirestoreデータを確認

---

## 参考リンク

- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Drive API](https://developers.google.com/drive/api/v3/about-sdk)
