# GitHub Actions Status Badges

Add these badges to your README.md to show the build status of your workflows.

## Badge Markdown

```markdown
[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)
[![iOS Build](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml)
[![Web Build](https://github.com/noboru-i/feedivo/actions/workflows/web.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/web.yml)
```

## Example Usage in README

Add to the top of your README.md, right after the title:

```markdown
# Feedivo

[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)
[![iOS Build](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml)
[![Web Build](https://github.com/noboru-i/feedivo/actions/workflows/web.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/web.yml)

Google Driveをポッドキャストのように楽しむ動画プレイヤー
```

## Branch-specific Badges

To show status for a specific branch (e.g., `main`):

```markdown
[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg?branch=main)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)
```

## Custom Badge Styles

GitHub supports different badge styles. Add `?style=` parameter:

```markdown
<!-- Flat style -->
[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg?style=flat)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)

<!-- Flat-square style -->
[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg?style=flat-square)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)

<!-- Plastic style -->
[![Android Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg?style=plastic)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml)
```

## All Platforms Combined Badge Section

```markdown
### Build Status

| Platform | Status |
|----------|--------|
| Android  | [![Build](https://github.com/noboru-i/feedivo/actions/workflows/android.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/android.yml) |
| iOS      | [![Build](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/ios.yml) |
| Web      | [![Build](https://github.com/noboru-i/feedivo/actions/workflows/web.yml/badge.svg)](https://github.com/noboru-i/feedivo/actions/workflows/web.yml) |
```

## Notes

- Badges automatically update based on the latest workflow run
- Clicking a badge takes you to the workflow runs page
- Badges show passing/failing status with different colors
- If a workflow hasn't run yet, the badge will show "no status"
