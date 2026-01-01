#!/bin/bash
# Pre-flight check script for GitHub Actions workflows
# This script validates that all necessary configuration files exist

set -e

echo "🔍 Feedivo CI/CD Pre-flight Check"
echo "=================================="
echo ""

ERRORS=0
WARNINGS=0

# Function to check if file exists
check_file() {
    local file=$1
    local required=$2
    
    if [ -f "$file" ]; then
        echo "✓ Found: $file"
    else
        if [ "$required" = "true" ]; then
            echo "✗ Missing (Required): $file"
            ERRORS=$((ERRORS + 1))
        else
            echo "⚠ Missing (Optional): $file"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

echo "Checking Flutter configuration..."
check_file "pubspec.yaml" "true"
check_file "lib/main.dart" "true"
echo ""

echo "Checking Firebase configuration files..."
echo "Note: These files should exist locally but NOT be committed to Git"
check_file "lib/firebase_options.dart" "false"
check_file "android/app/google-services.json" "false"
check_file "ios/Runner/GoogleService-Info.plist" "false"
echo ""

echo "Checking workflow files..."
check_file ".github/workflows/android.yml" "true"
check_file ".github/workflows/ios.yml" "true"
check_file ".github/workflows/web.yml" "true"
echo ""

echo "Checking documentation..."
check_file "docs/setup/github-actions-setup.md" "true"
check_file ".github/QUICK_START.md" "true"
check_file ".github/SECRETS_TEMPLATE.md" "true"
echo ""

echo "Checking platform-specific configurations..."
check_file "android/app/build.gradle.kts" "true"
check_file "ios/Runner.xcodeproj/project.pbxproj" "true"
check_file "web/index.html.template" "false"
echo ""

# Check for common issues
echo "Checking for common issues..."

# Check if .gitignore properly excludes Firebase config files
if grep -q "lib/firebase_options.dart" .gitignore; then
    echo "✓ .gitignore properly excludes firebase_options.dart"
else
    echo "⚠ .gitignore should exclude firebase_options.dart"
    WARNINGS=$((WARNINGS + 1))
fi

if grep -q "google-services.json" .gitignore; then
    echo "✓ .gitignore properly excludes google-services.json"
else
    echo "⚠ .gitignore should exclude google-services.json"
    WARNINGS=$((WARNINGS + 1))
fi

if grep -q "GoogleService-Info.plist" .gitignore; then
    echo "✓ .gitignore properly excludes GoogleService-Info.plist"
else
    echo "⚠ .gitignore should exclude GoogleService-Info.plist"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=================================="
echo "Summary:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ Pre-flight check FAILED"
    echo "Please fix the errors above before running CI/CD workflows."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Pre-flight check PASSED with warnings"
    echo "Review the warnings above. Firebase config files are expected"
    echo "to be missing locally as they should be set as GitHub Secrets."
    exit 0
else
    echo "✅ Pre-flight check PASSED"
    echo "All checks passed! You're ready to use GitHub Actions."
    exit 0
fi
