# Testing GitHub Actions Workflows Locally

This guide shows how to test the workflows before pushing to GitHub.

## Prerequisites

- Flutter SDK 3.38.5+
- For Android: Java 17
- For iOS: macOS with Xcode
- Firebase configuration files (for local testing)

## Quick Test

Run the preflight check to ensure everything is configured:

```bash
bash .github/scripts/preflight-check.sh
```

## Testing Individual Platforms

### Android

```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis (same as CI)
flutter analyze --fatal-infos

# 3. Build APK
flutter build apk --release

# 4. Build App Bundle
flutter build appbundle --release

# 5. Check outputs
ls -lh build/app/outputs/flutter-apk/app-release.apk
ls -lh build/app/outputs/bundle/release/app-release.aab
```

**Expected outputs:**
- `build/app/outputs/flutter-apk/app-release.apk` (APK file)
- `build/app/outputs/bundle/release/app-release.aab` (App Bundle file)

### iOS

```bash
# 1. Install dependencies
flutter pub get

# 2. Install CocoaPods dependencies
cd ios && pod install && cd ..

# 3. Run static analysis
flutter analyze --fatal-infos

# 4. Build iOS app (without code signing)
flutter build ios --release --no-codesign

# 5. Check outputs
ls -lh build/ios/iphoneos/Runner.app
```

**Expected outputs:**
- `build/ios/iphoneos/Runner.app` (iOS app bundle)

**Note:** Creating a signed IPA requires code signing certificates and is typically only done in CI or on a properly configured development machine.

### Web

```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis
flutter analyze --fatal-infos

# 3. Build web app
flutter build web --release --web-renderer canvaskit

# 4. Check outputs
ls -lh build/web/
```

**Expected outputs:**
- `build/web/` directory containing the web application files
- `build/web/index.html`
- `build/web/flutter.js`
- `build/web/main.dart.js`

### Local Web Server (Optional)

To test the web build locally:

```bash
# Using Python 3
cd build/web
python3 -m http.server 8000

# Or using Flutter's built-in server
flutter run -d web-server --web-port 8000
```

Then open http://localhost:8000 in your browser.

## Simulating CI Environment

### Using Docker (Advanced)

You can simulate the GitHub Actions environment using Docker:

```bash
# Pull the Flutter Docker image
docker pull cirrusci/flutter:stable

# Run the container
docker run -it -v $(pwd):/app -w /app cirrusci/flutter:stable bash

# Inside the container, run the build commands
flutter pub get
flutter analyze --fatal-infos
flutter build apk --release
```

## Troubleshooting

### "Flutter not found"

Ensure Flutter is in your PATH:

```bash
which flutter
flutter --version
```

### "Gradle build failed" (Android)

Try cleaning the build:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### "CocoaPods error" (iOS)

Try reinstalling pods:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### "Firebase configuration missing"

For local builds, you need the actual Firebase configuration files:

- `lib/firebase_options.dart`
- `android/app/google-services.json` (for Android)
- `ios/Runner/GoogleService-Info.plist` (for iOS)

These files should be created during the Firebase setup process. See `docs/setup/firebase-google-cloud-setup.md` for details.

## Common CI Failures

### Analysis Errors

If `flutter analyze --fatal-infos` fails:

```bash
# Run locally to see errors
flutter analyze --fatal-infos

# Auto-fix some issues
dart fix --apply

# Check again
flutter analyze
```

### Build Failures

If builds fail in CI but work locally:

1. Check Flutter version matches CI (3.38.5)
2. Verify all dependencies are in pubspec.yaml
3. Ensure no platform-specific code breaks on other platforms
4. Check that all required files are committed (not in .gitignore)

## Next Steps

Once local tests pass:

1. Commit and push changes
2. Check GitHub Actions tab for workflow runs
3. Review build logs if failures occur
4. Set up required secrets for deployment (see `docs/setup/github-actions-setup.md`)
