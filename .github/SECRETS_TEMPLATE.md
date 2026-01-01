# GitHub Secrets Template

This file serves as a checklist for setting up GitHub Secrets for CI/CD workflows.
DO NOT commit actual secret values to this file.

## Setup Instructions

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret below with its corresponding value

## Common Secrets (Required for all platforms)

- [ ] `FIREBASE_OPTIONS_DART`
  - Description: Content of lib/firebase_options.dart
  - How to get: Copy the entire content of lib/firebase_options.dart
  - Format: Plain text (no encoding)

## Android Secrets

- [ ] `GOOGLE_SERVICES_JSON`
  - Description: Google Services configuration for Android
  - How to get: Copy content of android/app/google-services.json
  - Format: Plain text JSON (no encoding)

- [ ] `PLAY_STORE_SERVICE_ACCOUNT` (Required only for deployment)
  - Description: Service account for Google Play Console
  - How to get: Google Play Console → Settings → API Access → Create Service Account
  - Format: Plain text JSON (no encoding)

## iOS Secrets

- [ ] `GOOGLE_SERVICE_INFO_PLIST`
  - Description: Google Services configuration for iOS
  - How to get: Copy content of ios/Runner/GoogleService-Info.plist
  - Format: Plain text XML (no encoding)

### iOS Code Signing (Required only for deployment)

- [ ] `BUILD_CERTIFICATE_BASE64`
  - Description: Distribution certificate
  - How to get: Export .p12 from Keychain, then: `base64 -i cert.p12`
  - Format: Base64 encoded string

- [ ] `P12_PASSWORD`
  - Description: Password for the .p12 certificate
  - How to get: Password you set when exporting the certificate
  - Format: Plain text

- [ ] `BUILD_PROVISION_PROFILE_BASE64`
  - Description: Provisioning profile for distribution
  - How to get: Download from Apple Developer, then: `base64 -i profile.mobileprovision`
  - Format: Base64 encoded string

- [ ] `KEYCHAIN_PASSWORD`
  - Description: Temporary keychain password for CI
  - How to get: Generate a random strong password
  - Format: Plain text (e.g., random 32-character string)

### iOS App Store Connect API (Required only for TestFlight deployment)

- [ ] `APP_STORE_CONNECT_API_KEY_ID`
  - Description: API Key ID from App Store Connect
  - How to get: App Store Connect → Users and Access → Keys
  - Format: Plain text (e.g., ABC123DEF4)

- [ ] `APP_STORE_CONNECT_ISSUER_ID`
  - Description: Issuer ID from App Store Connect
  - How to get: App Store Connect → Users and Access → Keys
  - Format: UUID format

- [ ] `APP_STORE_CONNECT_API_KEY_CONTENT`
  - Description: Content of the .p8 API key file
  - How to get: Download .p8 file from App Store Connect, then: `cat AuthKey_XXX.p8`
  - Format: Plain text (including BEGIN and END lines)

## Web Secrets

### Firebase Hosting Deployment

- [ ] `FIREBASE_SERVICE_ACCOUNT`
  - Description: Service account for Firebase Hosting deployment
  - How to get: Firebase Console → Project Settings → Service Accounts → Generate New Private Key
  - Format: Plain text JSON (no encoding)

- [ ] `FIREBASE_PROJECT_ID`
  - Description: Firebase project ID
  - How to get: Firebase Console → Project Settings → General
  - Format: Plain text (e.g., my-project-12345)

### Optional Web Configuration

- [ ] `WEB_CONFIG_JSON`
  - Description: Firebase configuration for web (optional)
  - How to get: Firebase Console → Project Settings → General → Your apps → Web app → Config
  - Format: Plain text JSON

## Verification Checklist

After setting up all required secrets:

- [ ] All common secrets are set
- [ ] Platform-specific secrets are set (at least for one platform)
- [ ] Workflow files are present in `.github/workflows/`
- [ ] Test workflow runs successfully
- [ ] Build artifacts are generated correctly

## Security Notes

⚠️ **IMPORTANT**:
- Never commit actual secret values to version control
- Use strong, randomly generated passwords for keychain and certificates
- Rotate secrets periodically
- Grant minimum required permissions to service accounts
- Review and revoke unused API keys and service accounts

## Troubleshooting

If workflows fail:
1. Check that secret names exactly match those in workflow files
2. Verify secret values don't have extra whitespace or newlines
3. Ensure Base64 encoding is correct (no line breaks for some systems)
4. Check GitHub Actions logs for specific error messages
5. Refer to docs/setup/github-actions-setup.md for detailed instructions
