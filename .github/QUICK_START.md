# GitHub Actions Quick Start Guide

## Required GitHub Secrets

Set these secrets in your repository settings (**Settings** → **Secrets and variables** → **Actions**):

### Common (All Platforms)

- `FIREBASE_PROJECT_ID`: Your Firebase project ID (e.g., my-project-12345)

**Note**: Firebase configuration files are now automatically generated using `flutterfire configure`. You no longer need to manually set `FIREBASE_OPTIONS_DART`, `GOOGLE_SERVICES_JSON`, or `GOOGLE_SERVICE_INFO_PLIST`.

### Android (Deployment only)

- `PLAY_STORE_SERVICE_ACCOUNT`: Google Play Console service account JSON key

### iOS (Deployment only)

- `BUILD_CERTIFICATE_BASE64`: Base64-encoded .p12 certificate
- `P12_PASSWORD`: Password for the .p12 certificate
- `BUILD_PROVISION_PROFILE_BASE64`: Base64-encoded provisioning profile
- `KEYCHAIN_PASSWORD`: Random strong password for CI keychain
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect Issuer ID
- `APP_STORE_CONNECT_API_KEY_CONTENT`: Content of .p8 API key file

### Web (Deployment only)

- `FIREBASE_SERVICE_ACCOUNT`: Firebase service account JSON key (for Firebase Hosting)

## Quick Commands

### Encode files to Base64

```bash
# macOS
base64 -i file.p12 | pbcopy

# Linux
base64 -w 0 file.p12
```

### Test workflows locally

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze --fatal-infos

# Build for each platform
flutter build apk --release
flutter build ios --release --no-codesign
flutter build web --release
```

## Workflow Triggers

- **Push to `main`**: Build + Deploy to production
- **Pull Request**: Static analysis only (validation)
- **Manual**: Via GitHub Actions UI

## Deployment Targets

- **Android**: Google Play Store (internal track by default)
- **iOS**: TestFlight
- **Web**: Firebase Hosting and/or GitHub Pages

## Notes

1. Firebase configuration files are automatically generated using `flutterfire configure`
2. Only `FIREBASE_PROJECT_ID` is required for builds - no manual file management needed
3. Both Firebase Hosting and GitHub Pages deployments are enabled for web by default - disable one if not needed
4. For complete setup instructions, see `docs/setup/github-actions-setup.md`
