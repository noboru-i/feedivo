# GitHub Actions Scripts

This directory contains helper scripts for GitHub Actions workflows.

## Scripts

### preflight-check.sh

Pre-flight check script that validates the repository is properly configured for CI/CD.

**Usage:**

```bash
# From the repository root
bash .github/scripts/preflight-check.sh
```

**What it checks:**

- ✅ Flutter configuration files (pubspec.yaml, lib/main.dart)
- ✅ Workflow files (.github/workflows/*.yml)
- ✅ Documentation files
- ✅ Platform-specific configurations
- ✅ .gitignore properly excludes sensitive files

**Exit codes:**

- `0`: All checks passed (or passed with warnings)
- `1`: One or more critical checks failed

**Notes:**

- Firebase configuration files (firebase_options.dart, google-services.json, GoogleService-Info.plist) are expected to be missing locally as they should be configured as GitHub Secrets
- Run this script before pushing changes to ensure your CI/CD setup is correct
