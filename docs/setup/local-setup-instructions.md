# ローカル開発環境セットアップ手順

このドキュメントでは、Feedivoプロジェクトをローカルで実行するための初期セットアップ手順を説明します。

## 前提条件

- Flutter SDK 3.38.5以上
- Firebase プロジェクトとGoogle Cloudプロジェクトの設定が完了していること
  - 詳細は [firebase-google-cloud-setup.md](./firebase-google-cloud-setup.md) を参照

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/noboru-i/feedivo.git
cd feedivo
```

### 2. 依存パッケージのインストール

```bash
flutter pub get
```

### 3. Firebase設定ファイルの生成

#### 3-1. FlutterFire CLIのインストール

```bash
# Firebase CLIインストール（未インストールの場合）
npm install -g firebase-tools

# Firebase CLIにログイン
firebase login

# FlutterFire CLIインストール
dart pub global activate flutterfire_cli
```

#### 3-2. Firebase設定の実行

```bash
flutterfire configure
```

対話形式で以下を選択:
1. Firebaseプロジェクトを選択
2. プラットフォームを選択（iOS, Android, Web すべて選択）

以下のファイルが自動生成されます:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`

### 4. Web用設定ファイルの作成

#### 4-1. index.htmlの作成

テンプレートファイルをコピー:

```bash
cp web/index.html.template web/index.html
```

`web/index.html`を開き、以下の行を編集:

```html
<!-- 変更前 -->
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">

<!-- 変更後: Google Cloud ConsoleのWeb OAuth クライアントIDに置き換え -->
<meta name="google-signin-client_id" content="943246669976-egeokhqqs5bcqgft3p91h6ksm21mkitn.apps.googleusercontent.com">
```

**Web OAuth クライアントIDの取得方法**:
1. Google Cloud Console → APIとサービス → 認証情報
2. OAuth 2.0 クライアントID の「Web client」を選択
3. クライアントIDをコピー

### 5. iOS用設定ファイルの作成

#### 5-1. Info.plistの作成

テンプレートファイルをコピー:

```bash
cp ios/Runner/Info.plist.template ios/Runner/Info.plist
```

`ios/Runner/Info.plist`を開き、以下の行を編集:

```xml
<!-- 変更前 -->
<string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>

<!-- 変更後: iOS Reversed Client IDに置き換え -->
<string>com.googleusercontent.apps.943246669976-uabeaacvimtlk81fvs0vd9j7bef1kn51</string>
```

**iOS Reversed Client IDの取得方法**:
1. Google Cloud Console → APIとサービス → 認証情報
2. OAuth 2.0 クライアントID の「iOS client」を選択
3. クライアントIDをコピー（例: `943246669976-uabeaacvimtlk81fvs0vd9j7bef1kn51.apps.googleusercontent.com`）
4. 逆順形式に変換:
   - クライアントID: `943246669976-uabeaacvimtlk81fvs0vd9j7bef1kn51.apps.googleusercontent.com`
   - Reversed Client ID: `com.googleusercontent.apps.943246669976-uabeaacvimtlk81fvs0vd9j7bef1kn51`

#### 5-2. Podのインストール

```bash
cd ios
pod install
cd ..
```

### 6. Android用設定ファイルの確認

`flutterfire configure`で自動生成された`android/app/google-services.json`が存在することを確認:

```bash
ls -la android/app/google-services.json
```

存在しない場合は、再度`flutterfire configure`を実行してください。

### 7. 動作確認

#### Web

```bash
flutter run -d chrome --web-port=8080
```

ブラウザで http://localhost:8080 にアクセス

#### iOS

```bash
flutter run -d ios
```

#### Android

```bash
flutter run -d android
```

## トラブルシューティング

### 「ファイルが見つからない」エラー

設定ファイルが生成されているか確認:

```bash
# 必須ファイルのチェック
ls -la lib/firebase_options.dart
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
ls -la web/index.html
ls -la ios/Runner/Info.plist
ls -la firebase.json
```

存在しない場合は、該当するセットアップ手順を再実行してください。

### Google Sign-in エラー

- **People API 403エラー**: Google Cloud ConsoleでPeople APIが有効化されているか確認
- **OAuth同意画面エラー**: テストユーザーとして登録されているか確認
- **iOS エラー**: `Info.plist`のReversed Client IDが正しいか確認
- **Android エラー**: SHA-1フィンガープリントがGoogle Cloud Consoleに登録されているか確認

詳細は [firebase-google-cloud-setup.md](./firebase-google-cloud-setup.md) のトラブルシューティングセクションを参照してください。

## 設定ファイルの管理について

以下のファイルにはプロジェクト固有の秘匿情報が含まれており、`.gitignore`で除外されています:

### 自動生成されるファイル（FlutterFire CLI）

- `lib/firebase_options.dart` - Firebase設定
- `android/app/google-services.json` - Firebase Android設定
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS設定
- `firebase.json` - Firebase プロジェクト設定

これらは`flutterfire configure`コマンドで自動生成されます。

### 手動で作成するファイル（テンプレートあり）

- `web/index.html` - Web OAuth クライアントID（`web/index.html.template`から作成）
- `ios/Runner/Info.plist` - iOS Reversed Client ID（`ios/Runner/Info.plist.template`から作成）

テンプレートファイル（`*.template`）をコピーして、上記の手順に従って編集してください。
