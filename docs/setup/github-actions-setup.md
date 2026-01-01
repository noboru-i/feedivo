# GitHub Actions CI/CD セットアップガイド

このドキュメントでは、Feedivoアプリの継続的インテグレーション（CI）と継続的デリバリー（CD）のためのGitHub Actionsワークフローの設定方法を説明します。

## 📋 目次

1. [概要](#概要)
2. [クイックスタート](#クイックスタート)
3. [必要なGitHub Secrets](#必要なgithub-secrets)
4. [Android セットアップ](#android-セットアップ)
5. [iOS セットアップ](#ios-セットアップ)
6. [Web セットアップ](#web-セットアップ)
7. [ワークフローの実行](#ワークフローの実行)
8. [トラブルシューティング](#トラブルシューティング)

## 概要

Feedivoプロジェクトには3つのGitHub Actionsワークフローが含まれています：

- **android.yml**: Android APK/AABのビルドとGoogle Play Storeへのデプロイ
- **ios.yml**: iOS IPAのビルドとTestFlightへのデプロイ
- **web.yml**: Webアプリのビルドとホスティング（Firebase Hosting / GitHub Pages）

各ワークフローは以下のトリガーで実行されます：
- `main`または`develop`ブランチへのプッシュ
- `main`または`develop`ブランチへのプルリクエスト
- 手動実行（workflow_dispatch）

## クイックスタート

### セットアップの確認

リポジトリがCI/CD用に正しく設定されているか確認するには、プリフライトチェックスクリプトを実行します：

```bash
# リポジトリのルートディレクトリから実行
bash .github/scripts/preflight-check.sh
```

このスクリプトは以下を確認します：
- 必要な設定ファイルの存在
- ワークフローファイルの存在
- .gitignoreの正しい設定

### 最小限のセットアップ

CI/CDを開始するために最低限必要なステップ：

1. **共通シークレットの設定**（すべてのプラットフォームで必須）
   - `FIREBASE_OPTIONS_DART`

2. **プラットフォーム別シークレット**（使用するプラットフォームのみ）
   - Android: `GOOGLE_SERVICES_JSON`
   - iOS: `GOOGLE_SERVICE_INFO_PLIST`
   - Web: なし（ビルドのみの場合）

3. **ワークフローの実行**
   - `main`または`develop`ブランチにプッシュ
   - または GitHub Actions UIから手動実行

デプロイが必要な場合は、追加のシークレット（署名証明書、サービスアカウントなど）が必要です。

## 必要なGitHub Secrets

GitHub Secretsの設定方法：
1. GitHubリポジトリページを開く
2. **Settings** → **Secrets and variables** → **Actions** に移動
3. **New repository secret** をクリック
4. 以下のシークレットを追加

### 共通シークレット

すべてのプラットフォームで必要：

| シークレット名 | 説明 | 取得方法 |
|--------------|------|---------|
| `FIREBASE_OPTIONS_DART` | Firebase設定ファイル | `lib/firebase_options.dart`の内容をbase64エンコードせずにそのまま保存 |

### Androidシークレット

| シークレット名 | 説明 | 取得方法 |
|--------------|------|---------|
| `GOOGLE_SERVICES_JSON` | Google Services設定ファイル | `android/app/google-services.json`の内容をbase64エンコードせずにそのまま保存 |
| `PLAY_STORE_SERVICE_ACCOUNT` | Google Play Console サービスアカウント | Google Play Consoleで作成したサービスアカウントのJSON鍵ファイルの内容 |

### iOSシークレット

| シークレット名 | 説明 | 取得方法 |
|--------------|------|---------|
| `GOOGLE_SERVICE_INFO_PLIST` | Google Services設定ファイル（iOS） | `ios/Runner/GoogleService-Info.plist`の内容をbase64エンコードせずにそのまま保存 |
| `BUILD_CERTIFICATE_BASE64` | iOS配布証明書（Base64） | 下記参照 |
| `P12_PASSWORD` | P12証明書のパスワード | 証明書作成時に設定したパスワード |
| `BUILD_PROVISION_PROFILE_BASE64` | プロビジョニングプロファイル（Base64） | 下記参照 |
| `KEYCHAIN_PASSWORD` | CI用キーチェーンパスワード | 任意の強力なパスワード（例：ランダム文字列） |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API キーID | App Store Connect で作成 |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect 発行者ID | App Store Connect で確認 |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | App Store Connect API キーの内容 | `.p8`ファイルの内容 |

### Webシークレット

| シークレット名 | 説明 | 取得方法 |
|--------------|------|---------|
| `WEB_CONFIG_JSON` | Web用Firebase設定（オプション） | Firebase Consoleから取得したWeb用設定 |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase Hosting デプロイ用 | Firebase Consoleでサービスアカウントを作成してJSON鍵をダウンロード |
| `FIREBASE_PROJECT_ID` | FirebaseプロジェクトID | Firebase ConsoleのプロジェクトIDまたは設定から取得 |

## Android セットアップ

### 1. Firebase設定ファイルの準備

```bash
# google-services.jsonの内容をシークレットに追加
cat android/app/google-services.json
# 上記の出力をGitHub SecretsのGOOGLE_SERVICES_JSONに設定
```

### 2. Play Store サービスアカウントの作成

1. [Google Play Console](https://play.google.com/console) にアクセス
2. **設定** → **API アクセス** に移動
3. **新しいサービスアカウントを作成** をクリック
4. Google Cloud Consoleでサービスアカウントを作成
5. JSON鍵をダウンロード
6. JSON鍵の内容をGitHub Secretsの`PLAY_STORE_SERVICE_ACCOUNT`に設定

### 3. アプリのパッケージ名確認

`android/app/build.gradle`でパッケージ名を確認し、ワークフローファイルの`packageName`を更新：

```kotlin
android {
    namespace = "com.example.feedivo"  // このパッケージ名を使用
    // ...
}
```

### 4. 署名の設定（オプション）

リリースビルドに署名が必要な場合：

```bash
# キーストアの作成
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# キーストアをBase64エンコード
base64 -i upload-keystore.jks | pbcopy  # macOS
base64 -w 0 upload-keystore.jks  # Linux
```

## iOS セットアップ

### 1. Firebase設定ファイルの準備

```bash
# GoogleService-Info.plistの内容をシークレットに追加
cat ios/Runner/GoogleService-Info.plist
# 上記の出力をGitHub SecretsのGOOGLE_SERVICE_INFO_PLISTに設定
```

### 2. 証明書とプロビジョニングプロファイルの準備

#### 配布証明書のエクスポート

1. **Keychain Access**を開く
2. **My Certificates**から配布証明書を選択
3. 右クリック → **Export**
4. `.p12`形式で保存（パスワードを設定）

```bash
# P12をBase64エンコード
base64 -i Certificates.p12 | pbcopy  # macOS
base64 -w 0 Certificates.p12  # Linux
# 出力をBUILD_CERTIFICATE_BASE64に設定
```

#### プロビジョニングプロファイルのエクスポート

1. [Apple Developer](https://developer.apple.com)にアクセス
2. **Certificates, Identifiers & Profiles** → **Profiles** に移動
3. App Store配布用プロファイルをダウンロード

```bash
# プロビジョニングプロファイルをBase64エンコード
base64 -i profile.mobileprovision | pbcopy  # macOS
base64 -w 0 profile.mobileprovision  # Linux
# 出力をBUILD_PROVISION_PROFILE_BASE64に設定
```

### 3. App Store Connect API キーの作成

1. [App Store Connect](https://appstoreconnect.apple.com)にアクセス
2. **Users and Access** → **Keys** → **App Store Connect API** に移動
3. **+** をクリックして新しいキーを作成
4. キー名を入力し、**Developer**アクセス権限を選択
5. `.p8`ファイルをダウンロード
6. キーIDと発行者IDをメモ

```bash
# .p8ファイルの内容をシークレットに追加
cat AuthKey_XXXXXXXXXX.p8
# 上記の出力をAPP_STORE_CONNECT_API_KEY_CONTENTに設定
```

## Web セットアップ

### オプション1: Firebase Hostingへのデプロイ

#### 1. Firebase プロジェクトの準備

```bash
# Firebase CLIのインストール
npm install -g firebase-tools

# Firebaseにログイン
firebase login

# プロジェクトの初期化（Hostingを選択）
firebase init hosting
```

#### 2. サービスアカウントの作成

1. [Firebase Console](https://console.firebase.google.com)にアクセス
2. プロジェクトを選択
3. **プロジェクトの設定** → **サービスアカウント** に移動
4. **新しい秘密鍵の生成** をクリック
5. JSON鍵をダウンロード
6. JSON鍵の内容をGitHub Secretsの`FIREBASE_SERVICE_ACCOUNT`に設定

#### 3. プロジェクトIDの設定

```bash
# firebase.jsonまたはFirebase Consoleで確認
cat firebase.json | grep "project"
# プロジェクトIDをFIREBASE_PROJECT_IDに設定
```

### オプション2: GitHub Pagesへのデプロイ

#### 1. GitHub Pagesの有効化

1. GitHubリポジトリの **Settings** → **Pages** に移動
2. **Source** を **GitHub Actions** に設定

#### 2. カスタムドメインの設定（オプション）

1. **Custom domain** にドメインを入力
2. DNSレコードを設定
3. **Enforce HTTPS** を有効化

### Web設定ファイルの準備

`web/index.html.template`が存在する場合、Firebase設定を含める必要があります：

```bash
# web/index.htmlの生成（ローカル）
cp web/index.html.template web/index.html
# Firebase設定を手動で追加
```

## ワークフローの実行

### 自動実行

以下の場合に自動的にワークフローが実行されます：

- `main`ブランチへのプッシュ → ビルド + デプロイ
- `develop`ブランチへのプッシュ → ビルドのみ
- プルリクエスト → ビルドのみ（検証目的）

### 手動実行

1. GitHubリポジトリの **Actions** タブを開く
2. 実行したいワークフロー（Android Build、iOS Build、Web Buildなど）を選択
3. **Run workflow** をクリック
4. ブランチを選択して **Run workflow** を実行

## デプロイのカスタマイズ

### Android: デプロイトラックの変更

`android.yml`の`track`を変更：

```yaml
track: internal  # internal, alpha, beta, production
```

### iOS: デプロイ先の変更

デフォルトではTestFlightにアップロードされます。App Storeへの直接リリースには追加の設定が必要です。

### Web: デプロイ先の選択

両方のデプロイジョブが有効になっています。不要な方を削除またはコメントアウト：

```yaml
# Firebase Hostingのみ使用する場合
jobs:
  build:
    # ...
  deploy-firebase:
    # ...
  # deploy-github-pages:  # コメントアウト
    # ...
```

## トラブルシューティング

### よくある問題

#### 1. "google-services.json not found"

**原因**: `GOOGLE_SERVICES_JSON`シークレットが正しく設定されていない

**解決策**:
- シークレットの値がJSONファイルの完全な内容であることを確認
- Base64エンコードではなく、そのままの内容を使用

#### 2. iOS Build: "No matching provisioning profiles found"

**原因**: プロビジョニングプロファイルが正しくデコードされていない

**解決策**:
- `BUILD_PROVISION_PROFILE_BASE64`が正しくBase64エンコードされているか確認
- プロビジョニングプロファイルの有効期限を確認

#### 3. Web Deploy: Firebase Hosting失敗

**原因**: `FIREBASE_SERVICE_ACCOUNT`またはプロジェクトIDが正しくない

**解決策**:
- サービスアカウントJSONの内容を確認
- `FIREBASE_PROJECT_ID`がFirebase Consoleのプロジェクトと一致しているか確認

#### 4. Flutter analyze エラー

**原因**: コードに静的解析エラーがある

**解決策**:
```bash
# ローカルで解析実行
flutter analyze --fatal-infos

# エラーを修正
dart fix --apply
```

### ログの確認

1. GitHubの **Actions** タブを開く
2. 失敗したワークフロー実行をクリック
3. 失敗したジョブとステップを確認
4. ログを確認して問題を特定

## セキュリティのベストプラクティス

1. **シークレットの管理**
   - シークレットは決してコードにコミットしない
   - 定期的にAPI鍵とサービスアカウントをローテーション

2. **アクセス制御**
   - リポジトリへのアクセスを最小限に制限
   - サービスアカウントには必要最小限の権限のみ付与

3. **デプロイの承認**
   - 本番環境へのデプロイには手動承認を追加することを検討
   - GitHub Environmentsを使用して保護ルールを設定

## 次のステップ

1. ✅ すべての必要なシークレットを設定
2. ✅ ワークフローをテスト実行
3. ✅ ビルドが成功することを確認
4. ✅ デプロイ設定を本番環境用に調整
5. ✅ チームメンバーにCI/CDプロセスを共有

## 参考リンク

- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Firebase Hosting Deploy Action](https://github.com/FirebaseExtended/action-hosting-deploy)
- [Upload to Play Store Action](https://github.com/r0adkll/upload-google-play)
