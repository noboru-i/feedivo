# DriveVideo Player 画面デザイン仕様書

**バージョン**: 1.0  
**作成日**: 2025年12月29日  
**対象プラットフォーム**: iOS / Android / Web  
**デザインフレームワーク**: Material Design 3

---

## 目次

1. [デザインシステム](#1-デザインシステム)
2. [画面一覧](#2-画面一覧)
3. [画面別詳細仕様](#3-画面別詳細仕様)
4. [コンポーネント仕様](#4-コンポーネント仕様)
5. [インタラクション仕様](#5-インタラクション仕様)
6. [レスポンシブ対応](#6-レスポンシブ対応)
7. [アクセシビリティ](#7-アクセシビリティ)
8. [ダークモード対応](#8-ダークモード対応)

---

## 1. デザインシステム

### 1.1 デザインコンセプト

**キーワード**: 落ち着き、信頼性、シンプル

DriveVideo Playerは、Google Driveの動画コンテンツをポッドキャスト形式で視聴するアプリです。長時間の視聴を想定し、目に優しく落ち着いた配色を採用しています。Material Design 3の原則に基づき、直感的で使いやすいインターフェースを実現します。

---

### 1.2 カラーパレット

#### プライマリカラー

```yaml
Primary:
  Main: #1E3A5F        # 深いネイビー（メインカラー）
  Light: #2C5282       # ライトネイビー（ホバー状態）
  Dark: #0F1E2F        # ダークネイビー（スプラッシュ背景）
  
使用箇所:
  - AppBar背景
  - FAB（フローティングアクションボタン）
  - プライマリボタン
  - アクセント要素
  - リンク
  - プログレスバー
```

#### セカンダリカラー

```yaml
Secondary:
  Main: #4A5568        # スレートグレー
  Light: #718096       # ライトグレー
  Dark: #2D3748        # ダークグレー
  
使用箇所:
  - セカンダリテキスト
  - アイコン（非アクティブ）
  - ボーダー
```

#### 背景カラー

```yaml
Background:
  Surface: #FFFFFF     # 白（カード、ダイアログ）
  Background: #F7FAFC  # ライトグレー（画面背景）
  Card: #FFFFFF        # 白（カード背景）
  Overlay: rgba(0, 0, 0, 0.6)  # 半透明黒（オーバーレイ）
```

#### テキストカラー

```yaml
Text:
  Primary: #1A202C     # ほぼ黒（メインテキスト）
  Secondary: #718096   # グレー（補足テキスト）
  Disabled: #A0AEC0    # ライトグレー（無効状態）
  OnPrimary: #FFFFFF   # 白（プライマリ背景上のテキスト）
```

#### ステータスカラー

```yaml
Status:
  Success: #48BB78     # グリーン（成功、完了）
  Error: #F56565       # レッド（エラー）
  Warning: #ED8936     # オレンジ（警告）
  Info: #4299E1        # ブルー（情報）
```

#### グラデーション（装飾用）

```yaml
Gradients:
  Purple: linear-gradient(135deg, #667eea 0%, #764ba2 100%)
  Pink: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)
  Blue: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)
  Peach: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)
  Orange: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)
  
使用箇所:
  - チャンネルサムネイル（デフォルト表示）
  - 動画サムネイル（デフォルト表示）
```

---

### 1.3 タイポグラフィ

#### フォントファミリー

```yaml
Font Family:
  - Primary: Roboto (Android)
  - Primary: SF Pro (iOS)
  - Fallback: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif
  
Font Weight:
  - Regular: 400
  - Medium: 500
  - Semi-bold: 600
  - Bold: 700
```

#### 見出し（Headline）

```yaml
H1:
  Font Size: 24sp
  Line Height: 32sp
  Font Weight: Bold (700)
  Letter Spacing: 0sp
  使用箇所: アプリ名、大見出し

H2:
  Font Size: 20sp
  Line Height: 28sp
  Font Weight: Semi-bold (600)
  Letter Spacing: 0sp
  使用箇所: AppBarタイトル、セクションタイトル

H3:
  Font Size: 18sp
  Line Height: 24sp
  Font Weight: Semi-bold (600)
  Letter Spacing: 0sp
  使用箇所: カードタイトル、動画タイトル
```

#### 本文（Body）

```yaml
Body1:
  Font Size: 16sp
  Line Height: 24sp
  Font Weight: Regular (400)
  Letter Spacing: 0.15sp
  使用箇所: メインテキスト、設定項目

Body2:
  Font Size: 14sp
  Line Height: 20sp
  Font Weight: Regular (400)
  Letter Spacing: 0.25sp
  使用箇所: 補足テキスト、説明文

Caption:
  Font Size: 12sp
  Line Height: 16sp
  Font Weight: Regular (400)
  Letter Spacing: 0.4sp
  使用箇所: タイムスタンプ、メタ情報、フッター
```

#### ボタンテキスト

```yaml
Button:
  Font Size: 14sp
  Line Height: 20sp
  Font Weight: Medium (500)
  Letter Spacing: 0.5sp
  Text Transform: None（大文字変換なし）
```

---

### 1.4 スペーシング

#### スペーシングスケール

```yaml
Spacing Scale:
  XXS: 2dp   # 最小余白
  XS: 4dp    # 極小余白
  S: 8dp     # 小余白
  M: 16dp    # 標準余白（最も頻繁に使用）
  L: 24dp    # 大余白
  XL: 32dp   # 特大余白
  XXL: 48dp  # 最大余白
```

#### 適用ルール

```yaml
カード内padding: M (16dp)
画面外側margin: M (16dp)
要素間margin: S (8dp) ～ M (16dp)
セクション間margin: L (24dp)

タッチターゲット最小サイズ: 48dp × 48dp
アイコンサイズ: 24dp（標準）、20dp（小）、40dp（大）
```

---

### 1.5 シャドウとエレベーション

Material Design 3のエレベーションシステムに準拠：

```yaml
Elevation 0 (なし):
  Box Shadow: none
  使用: 背景、フラット要素

Elevation 1:
  Box Shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)
  使用: 動画カード（通常状態）

Elevation 2:
  Box Shadow: 0 2px 4px rgba(0,0,0,0.1)
  使用: チャンネルカード、ヘッダー、AppBar

Elevation 4:
  Box Shadow: 0 4px 8px rgba(0,0,0,0.15)
  使用: GoogleログインボタンPrimary Button

Elevation 6:
  Box Shadow: 0 4px 12px rgba(0,0,0,0.2)
  使用: FAB（フローティングアクションボタン）

Elevation 8:
  Box Shadow: 0 4px 12px rgba(0,0,0,0.15)
  使用: カードホバー状態、ダイアログ
```

---

### 1.6 角丸（Border Radius）

```yaml
Corner Radius:
  XS: 4dp    # テキストフィールド、プログレスバー
  S: 8dp     # ボタン、小カード、バッジ
  M: 12dp    # チャンネルカード
  L: 20dp    # ロゴ、大型要素
  XL: 30dp   # スマホフレーム
  Circle: 50% # アイコンボタン、FAB、トグルスイッチ
```

---

## 2. 画面一覧

| No. | 画面名 | 説明 | 優先度 |
|-----|--------|------|--------|
| 1 | スプラッシュ画面 | アプリ起動時の初期化画面 | 高 |
| 2 | ログイン画面 | Google OAuth認証 | 高 |
| 3 | チャンネル一覧画面（ホーム） | 登録チャンネルの一覧表示 | 高 |
| 4 | チャンネル追加画面 | 新規チャンネル登録 | 高 |
| 5 | 動画リスト画面 | チャンネル内の動画一覧 | 高 |
| 6 | 動画再生画面 | 動画プレイヤー | 高 |
| 7 | 設定画面 | アプリ設定・アカウント管理 | 中 |
| 8 | プロフィール画面 | ユーザー情報表示 | 低 |

---

## 3. 画面別詳細仕様

### 3.1 スプラッシュ画面

#### レイアウト構成

```
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│                             │
│         [アプリロゴ]          │
│       (100×100dp)           │
│                             │
│     DriveVideo Player       │
│          (24sp)             │
│                             │
│      ━━━━━━━━━━━━━━          │
│    [ローディング表示]         │
│                             │
│                             │
│                             │
└─────────────────────────────┘
```

#### 詳細仕様

**背景**
- Color: Primary Dark (#0F1E2F)
- Gradient: なし（単色）

**ロゴエリア**
- サイズ: 100dp × 100dp
- 背景色: rgba(255, 255, 255, 0.1)
- Border Radius: 24dp
- アイコン: 📺 または カスタムロゴ（50sp）
- Position: 画面中央、やや上寄り

**アプリ名**
- Text: "DriveVideo Player"
- Font Size: 24sp
- Font Weight: Bold (700)
- Color: White (#FFFFFF)
- Margin Top: 24dp

**ローディングインジケーター**
- Type: Circular Progress Indicator
- Size: 40dp
- Color: Primary Light (#2C5282)
- Position: アプリ名から80dp下
- Animation: 1秒間で1回転

**アニメーション**
- フェードイン: 300ms (起動時)
- フェードアウト: 300ms (認証完了後)

**表示時間**
- 最小表示時間: 1秒
- 最大表示時間: 3秒（認証処理待ち）

---

### 3.2 ログイン画面

#### レイアウト構成

```
┌─────────────────────────────┐
│                             │
│                             │
│        [アプリロゴ]           │
│       (80×80dp)             │
│                             │
│    DriveVideo Player        │
│         (24sp)              │
│                             │
│   Google Driveの動画を       │
│   ポッドキャストのように       │
│   楽しもう                    │
│      (16sp, 3行)            │
│                             │
│  ┌───────────────────────┐  │
│  │ 🔐 Googleでログイン    │  │
│  └───────────────────────┘  │
│         (48dp高)            │
│                             │
│   利用規約 ・ プライバシー    │
│         (12sp)              │
└─────────────────────────────┘
```

#### 詳細仕様

**背景**
- Gradient: linear-gradient(135deg, #0F1E2F 0%, #1E3A5F 100%)
- Direction: 左上から右下へ

**ロゴエリア**
- サイズ: 80dp × 80dp
- 背景色: rgba(255, 255, 255, 0.1)
- Border Radius: 20dp
- アイコン: 📺（40sp）
- Margin Bottom: 20dp

**アプリ名**
- Font Size: 24sp
- Font Weight: Bold (700)
- Color: White
- Margin Bottom: 40dp

**タグライン**
- Font Size: 16sp
- Line Height: 24sp
- Color: rgba(255, 255, 255, 0.8)
- Text Align: Center
- Width: 最大280dp
- Margin Bottom: 60dp

**Googleログインボタン**
- Width: 280dp
- Height: 48dp
- Background: White (#FFFFFF)
- Border Radius: 8dp
- Elevation: 4
- Padding: 0 16dp

ボタン内容:
- アイコン: 🔐（20sp）
- Text: "Googleでログイン"（14sp, Medium）
- Color: Primary Text (#1A202C)
- Gap: 12dp

ホバー/タップ状態:
- Elevation: 8に上昇
- Scale: 0.98に縮小（100ms）

**フッターリンク**
- Position: Absolute, Bottom 20dp
- Font Size: 12sp
- Color: rgba(255, 255, 255, 0.6)
- Text: "利用規約 ・ プライバシーポリシー"
- Links: タップ可能、下線なし

---

### 3.3 チャンネル一覧画面（ホーム）

#### レイアウト構成

```
┌─────────────────────────────┐
│ ☰  マイチャンネル      👤 ⚙️ │ ← AppBar (56dp)
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │  [サムネイル 16:9]      │ │
│ │  (180dp高)              │ │
│ │                         │ │
│ │  チャンネル名 (18sp)     │ │
│ │  動画 12本・新着 3本     │ │ ← Channel Card
│ └─────────────────────────┘ │   (16dp margin)
│                             │
│ ┌─────────────────────────┐ │
│ │  [サムネイル]           │ │
│ │                         │ │
│ │  チャンネル名            │ │
│ │  動画 8本               │ │
│ └─────────────────────────┘ │
│                             │
│                    [+]      │ ← FAB (56dp)
└─────────────────────────────┘
│   🏠    📊    ⚙️           │ ← Bottom Nav (56dp)
└─────────────────────────────┘
```

#### 詳細仕様

**AppBar**
- Height: 56dp
- Background: Primary (#1E3A5F)
- Elevation: 2
- Padding: 0 16dp

AppBar要素:
- メニューアイコン (☰): 24dp, 左端
- タイトル: "マイチャンネル"（20sp, Semi-bold, White）
- プロフィールアイコン (👤): 24dp, 右から2番目
- 設定アイコン (⚙️): 24dp, 右端
- アイコン間Gap: 16dp

**コンテンツエリア**
- Padding: 16dp（上下左右）
- Padding Bottom: 72dp（Bottom Nav分）
- Background: Background (#F7FAFC)

**チャンネルカード**
- Width: 画面幅 - 32dp
- Background: White
- Border Radius: 12dp
- Elevation: 2
- Margin Bottom: 16dp
- Overflow: Hidden

サムネイルエリア:
- Width: 100%
- Height: 180dp
- Aspect Ratio: 16:9
- Background: グラデーション（各カード異なる）
- アイコン: 📺（48sp）、中央配置

カード情報エリア:
- Padding: 16dp

チャンネル名:
- Font Size: 18sp
- Font Weight: Semi-bold (600)
- Color: Primary Text (#1A202C)
- Margin Bottom: 8dp
- Max Lines: 1
- Overflow: Ellipsis

統計情報:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Layout: 横並び、Gap 12dp
- 内容: "動画 X本" ・ "新着 Y本"（オプション）

新着バッジ:
- Background: Primary (#1E3A5F)
- Color: White
- Padding: 2dp 8dp
- Border Radius: 4dp
- Font Size: 12sp
- Font Weight: Medium (500)

**カードインタラクション**
- ホバー時: Elevation 2 → 8、Y軸に-2dp移動（300ms）
- タップ時: Scale 0.98（150ms）
- リップル効果: Primary色、透過度20%

**FAB（フローティングアクションボタン）**
- Position: Absolute, Right 16dp, Bottom 72dp
- Size: 56dp × 56dp
- Background: Primary (#1E3A5F)
- Elevation: 6
- Border Radius: 50%（完全な円）
- Icon: +（24sp, White, 太字）

FABインタラクション:
- ホバー時: Elevation 8、Scale 1.1（200ms）
- タップ時: Scale 0.9 → 1.1 → 1.0（200ms）

**Bottom Navigation**
- Position: Fixed Bottom
- Height: 56dp
- Background: White
- Elevation: 2（上向きシャドウ）
- Box Shadow: 0 -2px 4px rgba(0,0,0,0.1)

ナビゲーションアイテム（3つ）:
- Width: 33.33%
- Layout: 縦並び（アイコン上、ラベル下）
- Gap: 4dp
- Padding: 8dp

アイコン:
- Size: 24sp
- Color (Active): Primary (#1E3A5F)
- Color (Inactive): Secondary Text (#718096)

ラベル:
- Font Size: 12sp
- Color: アイコンと同じ
- Font Weight (Active): Medium (500)
- Font Weight (Inactive): Regular (400)

インタラクション:
- タップ時: リップル効果、色変化（300ms）
- アクティブ時: アイコンとラベルが Primary色に

**Empty State（チャンネルなし）**
- Icon: 📺（64sp）
- Text: "チャンネルを追加してください"
- Sub Text: "FABボタンをタップして開始"
- Color: Secondary Text
- Layout: 画面中央配置

---

### 3.4 チャンネル追加画面

#### レイアウト構成

```
┌─────────────────────────────┐
│ ←  チャンネル追加            │ ← AppBar
├─────────────────────────────┤
│                             │
│  Google Driveから           │
│  設定ファイルを選択           │
│      (16sp, Center)         │
│                             │
│ ┌─────────────────────────┐ │
│ │        📁               │ │
│ │      (48sp)             │ │
│ │                         │ │
│ │   ファイルを選択          │ │
│ │   (14sp)                │ │ ← File Picker
│ │                         │ │   (200dp高)
│ │  channel_config.json    │ │
│ │  (12sp, Gray)           │ │
│ └─────────────────────────┘ │
│                             │
│        または                │
│     (Center, Gray)          │
│                             │
│ ┌─────────────────────────┐ │
│ │ ファイルIDを入力         │ │ ← Text Field
│ └─────────────────────────┘ │
│                             │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                             │
│ ┌─────────────────────────┐ │
│ │   チャンネル追加 (48dp)  │ │ ← Primary Button
│ └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

#### 詳細仕様

**AppBar**
- 戻るボタン (←): 左端、24sp
- タイトル: "チャンネル追加"（20sp, Semi-bold）
- その他: ホーム画面と同じ仕様

**コンテンツエリア**
- Padding: 16dp

**説明テキスト**
- Text: "Google Driveから\n設定ファイルを選択"
- Font Size: 16sp
- Color: Secondary Text (#718096)
- Text Align: Center
- Line Height: 24sp
- Margin: 24dp 0

**File Picker Button**
- Width: 100%
- Height: 200dp
- Background: Background (#F7FAFC)
- Border: 2dp dashed Secondary Light (#718096)
- Border Radius: 8dp
- Layout: 縦並び、中央揃え
- Gap: 16dp
- Cursor: Pointer

File Picker内容:
- アイコン: 📁（48sp, Secondary #4A5568）
- メインテキスト: "ファイルを選択"（14sp, Secondary Text）
- サブテキスト: "channel_config.json"（12sp, Disabled #A0AEC0）

ホバー状態:
- Border Color: Primary (#1E3A5F)
- Background: rgba(30, 58, 95, 0.05)

**区切りテキスト**
- Text: "または"
- Font Size: 14sp
- Color: Disabled (#A0AEC0)
- Text Align: Center
- Position: Relative
- Margin: 24dp 0

区切り線:
- Before/After疑似要素
- Width: 各40%
- Height: 1px
- Background: #E2E8F0
- Position: 横並び、テキスト両脇

**Text Field（ファイルID入力）**
- Width: 100%
- Height: 48dp
- Padding: 14dp 16dp
- Border: 1dp solid #CBD5E0
- Border Radius: 4dp
- Font Size: 16sp
- Placeholder: "ファイルIDを入力"
- Placeholder Color: Disabled (#A0AEC0)

フォーカス状態:
- Border Color: Primary (#1E3A5F)
- Border Width: 2dp
- Box Shadow: 0 0 0 3px rgba(30, 58, 95, 0.1)

**プライマリボタン**
- Width: 100%
- Height: 48dp
- Background: Primary (#1E3A5F)
- Color: White
- Border: None
- Border Radius: 8dp
- Font Size: 16sp
- Font Weight: Medium (500)
- Margin Top: 24dp
- Cursor: Pointer

ホバー状態:
- Background: Primary Light (#2C5282)
- Transform: translateY(-2dp)
- Box Shadow: 0 4px 12px rgba(30, 58, 95, 0.3)

無効状態:
- Background: #E2E8F0
- Color: #A0AEC0
- Cursor: Not-allowed

**エラー表示**
- Position: Text Field下部
- Font Size: 12sp
- Color: Error (#F56565)
- Margin Top: 4dp

**Loading State**
- ボタン内にCircular Progress（20dp, White）
- Text: "追加中..."

---

### 3.5 動画リスト画面

#### レイアウト構成

```
┌─────────────────────────────┐
│ ←  チャンネル名          🔄  │ ← AppBar
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │ [📺]  チャンネル情報     │ │
│ │ 80×  説明文...          │ │ ← Channel Header
│ │ 80dp 最終更新: 2時間前   │ │
│ └─────────────────────────┘ │
│                             │
│ ┌───────┬─────────────────┐ │
│ │[サム] │ 動画タイトル     │ │
│ │ネイル │ (16sp, Bold)    │ │
│ │120×  │                 │ │ ← Video Card
│ │68dp  │ 30:45  2日前    │ │
│ │[━━━] │                 │ │
│ └───────┴─────────────────┘ │
│                             │
│ ┌───────┬─────────────────┐ │
│ │[サム] │ 動画タイトル     │ │
│ │ネイル │                 │ │
│ │[━━━━]│ 45:20 ✓ 1週間前 │ │
│ └───────┴─────────────────┘ │
│                             │
└─────────────────────────────┘
```

#### 詳細仕様

**AppBar**
- 戻るボタン: あり
- タイトル: チャンネル名（動的）
- 更新アイコン (🔄): 右端、24sp
- タップで再読み込み

**チャンネルヘッダー**
- Width: 100%
- Background: rgba(30, 58, 95, 0.05)
- Padding: 16dp
- Layout: 横並び
- Gap: 16dp

ヘッダーサムネイル:
- Size: 80dp × 80dp
- Border Radius: 8dp
- Background: グラデーション
- アイコン: 📺（32sp）

ヘッダー情報:
- Flex: 1（残りスペース全て）

チャンネル説明:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Line Height: 20sp (1.4)
- Max Lines: 2
- Overflow: Ellipsis
- Margin Bottom: 8dp

最終更新:
- Font Size: 12sp
- Color: Disabled (#A0AEC0)
- Format: "最終更新: X時間前"

**動画カード**
- Width: 画面幅 - 32dp
- Background: White
- Border Radius: 8dp
- Padding: 12dp
- Margin: 8dp 16dp
- Layout: 横並び
- Gap: 12dp
- Elevation: 1

動画サムネイル:
- Size: 120dp × 68dp（16:9）
- Border Radius: 4dp
- Background: グラデーション（デフォルト）
- Position: Relative
- Flex Shrink: 0
- アイコン: 🎬（24sp）

プログレスバー（視聴進捗）:
- Position: Absolute, Bottom 0
- Height: 3dp
- Background: Primary (#1E3A5F)
- Width: 視聴率（0-100%）
- Border Radius: 0 0 4dp 4dp

動画情報エリア:
- Flex: 1
- Layout: 縦並び
- Justify Content: Space Between

動画タイトル:
- Font Size: 16sp
- Font Weight: Semi-bold (600)
- Color: Primary Text (#1A202C)
- Line Height: 20sp (1.3)
- Max Lines: 2
- Overflow: Ellipsis

動画メタ情報:
- Layout: 横並び
- Justify Content: Space Between
- Align Items: Center

時間表示:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Format: "MM:SS"

投稿日:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Format: "X日前", "X週間前"

完了アイコン（視聴済み）:
- Icon: ✓
- Size: 16sp
- Color: Success (#48BB78)
- Position: 時間表示の右

**カードインタラクション**
- ホバー時: Elevation 1 → 4
- タップ時: リップル効果

**Empty State（動画なし）**
- Icon: 🎬（64sp）
- Text: "動画がありません"
- Sub Text: "チャンネルを更新してください"
- Color: Secondary Text

---

### 3.6 動画再生画面

#### レイアウト構成

```
┌─────────────────────────────┐
│                             │
│                             │
│    [動画プレイヤーエリア]     │
│        16:9比率             │
│      (211dp高)              │
│    [再生コントロール]         │
│                             │
├─────────────────────────────┤
│ 動画タイトル (18sp, Bold)    │
│ チャンネル名 (14sp, Gray)    │
│                             │
│ ┌─ 説明 ──────────────────┐ │
│ │ 動画の説明文...          │ │
│ │ (展開可能)              │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─ 次の動画 ──────────────┐ │
│ │ [サムネ] タイトル        │ │
│ └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

#### 詳細仕様

**動画プレイヤーエリア**
- Width: 100%
- Height: 211dp（375dp × 9/16）
- Aspect Ratio: 16:9（固定）
- Background: Black (#000000)
- Position: Relative

動画表示:
- Width: 100%
- Height: 100%
- Object Fit: Contain

**プレイヤーオーバーレイ**
- Position: Absolute
- Width: 100%
- Height: 100%
- Background: rgba(0, 0, 0, 0.3)
- Display: Flex
- Justify Content: Center
- Align Items: Center
- Gap: 40dp
- Opacity: 1（表示時）、0（非表示時）
- Transition: 300ms

オーバーレイボタン:

10秒戻るボタン:
- Size: 48dp × 48dp
- Background: rgba(255, 255, 255, 0.9)
- Border Radius: 50%
- Icon: ⏪（24sp）

再生/一時停止ボタン（中央）:
- Size: 80dp × 80dp
- Background: rgba(255, 255, 255, 0.9)
- Border Radius: 50%
- Icon: ▶️ or ⏸（32sp）

10秒進むボタン:
- Size: 48dp × 48dp
- Background: rgba(255, 255, 255, 0.9)
- Border Radius: 50%
- Icon: ⏩（24sp）

ボタンホバー:
- Background: White (1.0)
- Scale: 1.1

**プレイヤーコントロール**
- Position: Absolute, Bottom 0
- Width: 100%
- Padding: 16dp
- Background: linear-gradient(transparent, rgba(0, 0, 0, 0.8))

シークバー:
- Width: 100%
- Height: 4dp
- Background: rgba(255, 255, 255, 0.3)
- Border Radius: 2dp
- Margin Bottom: 8dp
- Cursor: Pointer

シーク進捗:
- Height: 4dp
- Background: Primary (#1E3A5F)
- Border Radius: 2dp
- Width: 再生位置（0-100%）

時間表示:
- Layout: 横並び、Space Between
- Font Size: 12sp
- Color: White
- Format: "MM:SS / MM:SS"

**コントロールバー（下部）**
- Layout: 横並び、Space Between
- Padding: 8dp 16dp

左側コントロール:
- 再生速度ボタン: 32dp、"1.0x"表示
- ボタンタップ: 0.5x / 1.0x / 1.25x / 1.5x / 2.0x

右側コントロール:
- 全画面ボタン: 24dp
- ボタンタップ: 全画面モード切替

**動画詳細エリア**
- Background: White
- Padding: 16dp

動画タイトル:
- Font Size: 18sp
- Font Weight: Semi-bold (600)
- Color: Primary Text (#1A202C)
- Line Height: 24sp
- Margin Bottom: 8dp

チャンネル名:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Margin Bottom: 16dp

**説明セクション（Expandable）**
- Background: Background (#F7FAFC)
- Border Radius: 8dp
- Padding: 16dp
- Margin Top: 16dp
- Cursor: Pointer

セクションタイトル:
- Font Size: 14sp
- Font Weight: Semi-bold (600)
- Color: Primary Text (#1A202C)
- Margin Bottom: 8dp
- Layout: 横並び
- 展開アイコン: ▼ or ▲（右端）

セクションコンテンツ:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Line Height: 22sp (1.6)
- Max Lines: 3（折りたたみ時）
- Max Lines: None（展開時）
- Transition: 300ms

**次の動画カード**
- Background: White
- Margin: 16dp
- Border Radius: 8dp
- Padding: 12dp
- Layout: 横並び
- Gap: 12dp
- Elevation: 1
- Cursor: Pointer

次の動画サムネイル:
- Size: 100dp × 56dp
- Border Radius: 4dp
- Background: グラデーション

次の動画情報:
- "次の動画"ラベル: 12sp, Secondary Text
- タイトル: 14sp, Semi-bold, Primary Text

**全画面モード**
- Orientation: Landscape
- Player: 画面全体
- Controls: 同じだが配置調整
- システムUI: 非表示

**ミニプレイヤー（Picture-in-Picture）**
- Size: 160dp × 90dp
- Position: 右下固定
- Elevation: 8
- Border Radius: 8dp
- Drag可能
- タップで元に戻る

---

### 3.7 設定画面

#### レイアウト構成

```
┌─────────────────────────────┐
│ ←  設定                      │ ← AppBar
├─────────────────────────────┤
│                             │
│ ━━ アカウント ━━━━━━━━━━━━  │ ← Section Header
│                             │
│  👤  プロフィール              │
│      user@example.com       │ ← Settings Item
│                             │
│  🚪  ログアウト               │
│                             │
│ ━━ 再生設定 ━━━━━━━━━━━━━  │
│                             │
│  ▶️  自動再生          [ON]  │
│                             │
│  🎵  バックグラウンド再生 [ON]│
│                             │
│  ⚡  デフォルト再生速度   1.0x│
│                             │
│ ━━ データ ━━━━━━━━━━━━━━  │
│                             │
│  💾  キャッシュをクリア       │
│                             │
│  📊  使用容量: 125 MB        │
│                             │
│ ━━ アプリ情報 ━━━━━━━━━━━  │
│                             │
│  📄  利用規約                 │
│  🔒  プライバシーポリシー      │
│  ℹ️   バージョン 1.0.0        │
│                             │
└─────────────────────────────┘
```

#### 詳細仕様

**AppBar**
- 標準仕様と同じ
- タイトル: "設定"

**コンテンツエリア**
- Background: Background (#F7FAFC)
- Padding Bottom: 16dp

**セクションヘッダー**
- Padding: 24dp 16dp 8dp 16dp
- Font Size: 12sp
- Font Weight: Medium (500)
- Color: Secondary Text (#718096)
- Text Transform: Uppercase
- Letter Spacing: 0.5sp
- Background: Transparent

**設定アイテム**
- Width: 100%
- Background: White
- Padding: 16dp
- Layout: 横並び
- Gap: 16dp
- Align Items: Center
- Border Bottom: 1dp solid rgba(0, 0, 0, 0.05)
- Cursor: Pointer

設定アイコン:
- Size: 24dp
- Display: Flex
- Align: Center
- Color: Secondary (#718096)

設定コンテンツ:
- Flex: 1
- Layout: 縦並び

設定ラベル:
- Font Size: 16sp
- Color: Primary Text (#1A202C)
- Margin Bottom: 2dp

設定サブラベル:
- Font Size: 14sp
- Color: Secondary Text (#718096)
- Display: 値がある場合のみ

**トグルスイッチ**
- Width: 48dp
- Height: 28dp
- Background (OFF): #CBD5E0
- Background (ON): Primary (#1E3A5F)
- Border Radius: 14dp
- Position: Relative
- Cursor: Pointer
- Transition: 300ms

トグルノブ:
- Size: 24dp × 24dp
- Background: White
- Border Radius: 50%
- Position: Absolute, Top 2dp
- Left (OFF): 2dp
- Left (ON): 22dp
- Transition: 300ms
- Box Shadow: 0 2dp 4dp rgba(0, 0, 0, 0.2)

**設定アイテムのインタラクション**
- ホバー時: Background rgba(30, 58, 95, 0.05)
- タップ時: リップル効果
- Transition: 300ms

**特殊アイテム**

プロフィール:
- サブラベルにメールアドレス表示
- タップで詳細画面へ

デフォルト再生速度:
- サブラベルに現在値表示（例: "1.0x"）
- タップでピッカー表示
- 選択肢: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 1.75x, 2.0x

使用容量:
- サブラベルに容量表示（例: "125 MB"）
- タップ不可（表示のみ）

バージョン:
- サブラベルにバージョン番号（例: "1.0.0"）
- タップ不可（表示のみ）

**確認ダイアログ**

キャッシュクリア確認:
```
┌─────────────────────────┐
│  キャッシュをクリア      │
│                         │
│  すべてのキャッシュを    │
│  削除しますか？          │
│                         │
│  [キャンセル]  [削除]   │
└─────────────────────────┘
```

- Width: 280dp
- Background: White
- Border Radius: 12dp
- Padding: 24dp
- Elevation: 8

タイトル:
- Font Size: 18sp
- Font Weight: Semi-bold
- Margin Bottom: 16dp

メッセージ:
- Font Size: 14sp
- Color: Secondary Text
- Line Height: 20sp
- Margin Bottom: 24dp

ボタン:
- Layout: 横並び、Gap 8dp
- Height: 40dp
- Border Radius: 4dp

キャンセルボタン:
- Background: Transparent
- Color: Secondary Text
- Border: 1dp solid #E2E8F0

削除ボタン:
- Background: Error (#F56565)
- Color: White
- Border: None

---

## 4. コンポーネント仕様

### 4.1 ボタン

#### プライマリボタン（Primary Button）

```yaml
Default State:
  Width: 280dp ～ 100%（コンテキスト依存）
  Height: 48dp
  Background: Primary (#1E3A5F)
  Color: White
  Border: None
  Border Radius: 8dp
  Font Size: 16sp
  Font Weight: Medium (500)
  Elevation: 0
  Cursor: Pointer
  Transition: All 300ms

Hover State:
  Background: Primary Light (#2C5282)
  Transform: translateY(-2dp)
  Elevation: 4
  Box Shadow: 0 4px 12px rgba(30, 58, 95, 0.3)

Pressed State:
  Transform: scale(0.98)
  Elevation: 2

Disabled State:
  Background: #E2E8F0
  Color: #A0AEC0
  Cursor: Not-allowed
  Elevation: 0

Loading State:
  Spinner: Circular, 20dp, White
  Text: "処理中..."
  Disabled: True
```

#### セカンダリボタン（Secondary Button）

```yaml
Default State:
  Background: Transparent
  Color: Primary (#1E3A5F)
  Border: 1dp solid Primary
  その他: Primary Buttonと同じ

Hover State:
  Background: rgba(30, 58, 95, 0.05)
  Border: 2dp solid Primary

Pressed State:
  Background: rgba(30, 58, 95, 0.1)
```

#### テキストボタン（Text Button）

```yaml
Default State:
  Background: Transparent
  Color: Primary (#1E3A5F)
  Border: None
  Padding: 8dp 16dp
  Font Size: 14sp
  Font Weight: Medium

Hover State:
  Background: rgba(30, 58, 95, 0.05)
  Border Radius: 4dp

Pressed State:
  Background: rgba(30, 58, 95, 0.1)
```

#### アイコンボタン（Icon Button）

```yaml
Size: 40dp × 40dp
Icon Size: 24dp
Background: Transparent
Border Radius: 50%
Cursor: Pointer

Hover State:
  Background: rgba(255, 255, 255, 0.1)（暗背景）
  Background: rgba(0, 0, 0, 0.05)（明背景）

Pressed State:
  Background: rgba(255, 255, 255, 0.2)（暗背景）
  Background: rgba(0, 0, 0, 0.1)（明背景）
  Scale: 0.95
```

---

### 4.2 入力フィールド

#### テキストフィールド（Text Field）

```yaml
Default State:
  Width: 100%
  Height: 48dp
  Padding: 14dp 16dp
  Background: Transparent
  Border: 1dp solid #CBD5E0
  Border Radius: 4dp
  Font Size: 16sp
  Color: Primary Text (#1A202C)
  
Placeholder:
  Color: Disabled (#A0AEC0)
  Font Style: Italic（オプション）

Focus State:
  Border: 2dp solid Primary (#1E3A5F)
  Box Shadow: 0 0 0 3px rgba(30, 58, 95, 0.1)
  Outline: None

Error State:
  Border: 2dp solid Error (#F56565)
  Box Shadow: 0 0 0 3px rgba(245, 101, 101, 0.1)
  
Error Message:
  Position: Below field
  Font Size: 12sp
  Color: Error (#F56565)
  Margin Top: 4dp
  Icon: ⚠️（オプション）

Disabled State:
  Background: #F7FAFC
  Border: 1dp solid #E2E8F0
  Color: Disabled (#A0AEC0)
  Cursor: Not-allowed

Label (Optional):
  Position: Above field
  Font Size: 14sp
  Color: Primary Text
  Margin Bottom: 8dp
  Font Weight: Medium

Helper Text (Optional):
  Position: Below field
  Font Size: 12sp
  Color: Secondary Text
  Margin Top: 4dp
```

---

### 4.3 カード

#### 標準カード

```yaml
Width: 画面幅 - 32dp（margin含む）
Background: White
Border Radius: 12dp
Padding: 16dp
Margin: 8dp 16dp
Elevation: 2
Overflow: Hidden

Hover State:
  Elevation: 4
  Transform: translateY(-2dp)
  Transition: 300ms

Pressed State:
  Scale: 0.98
  Transition: 150ms

Ripple Effect:
  Color: Primary (#1E3A5F)
  Opacity: 0.2
```

#### コンパクトカード

```yaml
Padding: 12dp
Elevation: 1
その他: 標準カードと同じ
```

---

### 4.4 リスト

#### リストアイテム

```yaml
Height: 56dp（標準）、72dp（2行）
Padding: 16dp
Layout: 横並び
Gap: 16dp
Background: White
Border Bottom: 1dp solid rgba(0, 0, 0, 0.05)

Leading Icon:
  Size: 24dp
  Color: Secondary (#718096)

Content:
  Flex: 1
  Primary Text: 16sp, Primary Text
  Secondary Text: 14sp, Secondary Text

Trailing:
  アイコン、テキスト、スイッチなど

Hover State:
  Background: rgba(0, 0, 0, 0.02)

Pressed State:
  Background: rgba(0, 0, 0, 0.05)
  Ripple Effect: Primary色、透過度10%
```

---

### 4.5 ダイアログ

#### 標準ダイアログ

```yaml
Width: 280dp（モバイル）、400dp（タブレット）
Max Width: 画面幅 - 48dp
Background: White
Border Radius: 12dp
Padding: 24dp
Elevation: 8
Box Shadow: 0 8px 24px rgba(0, 0, 0, 0.15)

Title:
  Font Size: 18sp
  Font Weight: Semi-bold
  Color: Primary Text
  Margin Bottom: 16dp

Content:
  Font Size: 14sp
  Color: Secondary Text
  Line Height: 20sp
  Margin Bottom: 24dp

Actions:
  Layout: 横並び、右寄せ
  Gap: 8dp
  Buttons: Text Buttons

Backdrop:
  Background: rgba(0, 0, 0, 0.5)
  Animation: Fade In 200ms
```

#### フルスクリーンダイアログ

```yaml
Width: 100%
Height: 100vh
Background: White
Border Radius: 0

AppBar:
  左: 閉じるボタン (×)
  中央: タイトル
  右: 保存ボタン（オプション）

Content:
  Padding: 16dp
  Scroll: 縦スクロール可能
```

---

### 4.6 トースト・スナックバー

#### スナックバー（Snackbar）

```yaml
Position: Fixed Bottom
Bottom: 16dp
Left/Right: 16dp（モバイル）、中央配置（タブレット）
Max Width: 600dp
Height: 48dp～（コンテンツ依存）
Background: #2D3748
Color: White
Border Radius: 4dp
Padding: 14dp 16dp
Elevation: 6
Z-Index: 9999

Layout: 横並び
Gap: 16dp

Message:
  Font Size: 14sp
  Color: White
  Flex: 1

Action Button:
  Font Size: 14sp
  Font Weight: Medium
  Color: Primary Light (#2C5282)
  Text Transform: Uppercase
  Padding: 0

Animation:
  Enter: Slide Up + Fade In (300ms)
  Exit: Fade Out (200ms)
  Duration: 4秒（自動消去）

Types:
  - Info: 標準（グレー背景）
  - Success: #48BB78背景
  - Error: #F56565背景
  - Warning: #ED8936背景
```

---

### 4.7 ローディング

#### Circular Progress Indicator

```yaml
Size: 40dp（標準）、24dp（小）、64dp（大）
Stroke Width: 4dp
Color: Primary (#1E3A5F)
Animation: 回転（1秒/回転）

Indeterminate Mode:
  使用場所: 処理時間不明
  Animation: 無限回転

Determinate Mode:
  使用場所: ダウンロード進捗など
  Value: 0-100%
  Animation: スムーズに進捗
```

#### Linear Progress Indicator

```yaml
Width: 100%
Height: 4dp
Background: rgba(30, 58, 95, 0.1)
Progress Color: Primary (#1E3A5F)
Border Radius: 2dp

Indeterminate Mode:
  Animation: 左右に移動

Determinate Mode:
  Value: 0-100%
  Animation: スムーズに拡大
```

#### Skeleton Loader

```yaml
Background: #E2E8F0
Animation: Shimmer効果
Border Radius: 要素に合わせる

Shimmer:
  Gradient: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)
  Animation Duration: 1.5s
  Animation: 左から右へ移動
```

---

### 4.8 バッジ

#### 通知バッジ

```yaml
Size: 18dp × 18dp（最小）
Background: Error (#F56565)
Color: White
Border Radius: 9dp
Font Size: 11sp
Font Weight: Bold
Padding: 2dp 6dp（数字に応じて）

Position:
  Absolute: 親要素の右上
  Top: -4dp
  Right: -4dp

Max Value: 99（"99+"表示）
```

#### ステータスバッジ

```yaml
Height: 20dp
Background: Primary (#1E3A5F)
Color: White
Border Radius: 4dp
Font Size: 12sp
Font Weight: Medium
Padding: 2dp 8dp
Text Transform: None

Variants:
  - Primary: Primary背景
  - Success: Success背景
  - Warning: Warning背景
  - Error: Error背景
  - Secondary: Secondary背景
```

---

## 5. インタラクション仕様

### 5.1 アニメーション

#### 画面遷移

```yaml
Type: Material Hero Animation
Duration: 300ms
Easing: cubic-bezier(0.4, 0.0, 0.2, 1)

Push Transition:
  新画面: Slide In from Right
  旧画面: Fade Out + Slide Left少し

Pop Transition:
  前画面: Slide In from Left
  現画面: Slide Out to Right

Fade Transition:
  Duration: 200ms
  使用: モーダル、ダイアログ
```

#### タップフィードバック

```yaml
Ripple Effect:
  Color: Primary (#1E3A5F)
  Opacity: 0.2
  Duration: 400ms
  Origin: タップ位置

Scale Animation:
  Duration: 150ms
  Scale: 0.98
  Easing: ease-out

Elevation Change:
  Duration: 300ms
  Easing: ease-in-out
```

#### FABアニメーション

```yaml
Tap:
  Scale: 0.9 → 1.1 → 1.0
  Duration: 200ms each
  Easing: ease-in-out

Hover:
  Scale: 1.1
  Elevation: 6 → 8
  Duration: 200ms

Scroll Behavior:
  Hide: 下スクロール時（速度依存）
  Show: 上スクロール時
  Animation: Scale + Fade
  Duration: 200ms
```

#### プログレスバーアニメーション

```yaml
Width Change:
  Duration: 500ms
  Easing: ease-in-out

Indeterminate:
  Duration: 2s
  Animation: 左から右へ無限ループ
```

#### スケルトンローディング

```yaml
Shimmer Effect:
  Gradient: linear-gradient(90deg, 
    transparent 0%, 
    rgba(255,255,255,0.4) 50%, 
    transparent 100%)
  Duration: 1.5s
  Animation: translateX(-100% → 100%)
  Timing: linear, infinite
```

---

### 5.2 ジェスチャー

#### スワイプ

```yaml
Swipe to Dismiss (リストアイテム):
  Direction: 左右
  Threshold: 40%
  Animation: Slide + Fade
  Feedback: Haptic（iOS）

Pull to Refresh:
  Direction: 下
  Threshold: 80dp
  Indicator: Circular Progress
  Offset: 80dp
  Feedback: Haptic on release

Swipe Between Pages:
  Direction: 左右
  Animation: Page transition
  Velocity: 最低1000dp/s
```

#### ピンチズーム

```yaml
Target: 動画プレイヤー、画像
Min Scale: 1.0
Max Scale: 3.0
Duration: 300ms（自動調整時）
Easing: ease-out
```

#### ロングプレス

```yaml
Duration: 500ms
Feedback: Haptic（iOS）
Visual: Scale 0.95
Action: コンテキストメニュー表示
```

---

### 5.3 スクロール

#### スクロール挙動

```yaml
Momentum Scrolling: 有効
Overscroll Effect: バウンス（iOS）、グロー（Android）
Scroll Bar: 自動非表示
Scroll Indicator: 薄いグレー

Pull to Refresh:
  Enabled: チャンネル一覧、動画リスト
  Indicator Color: Primary (#1E3A5F)
  Offset: 80dp
```

#### AppBar Scroll Behavior

```yaml
Normal Scroll:
  AppBar: 固定表示
  Elevation: 2（常時）

Scroll Collapse:
  Trigger: 下スクロール（速度依存）
  Animation: Slide Up
  Duration: 300ms

Scroll Expand:
  Trigger: 上スクロール
  Animation: Slide Down
  Duration: 300ms
```

---

### 5.4 フォーカス状態

#### キーボードフォーカス

```yaml
Outline:
  Color: Primary (#1E3A5F)
  Width: 2dp
  Offset: 2dp
  Border Radius: 要素に準拠

Tab Order:
  Direction: 上から下、左から右
  Skip: disabled要素

Focus Visible:
  Keyboard: Outline表示
  Mouse/Touch: Outline非表示
```

---

## 6. レスポンシブ対応

### 6.1 ブレークポイント

```yaml
Breakpoints:
  Mobile: 0dp - 599dp
  Tablet: 600dp - 839dp
  Desktop: 840dp +

Phone Sizes:
  Small: 360dp × 640dp
  Medium: 375dp × 667dp（基準）
  Large: 414dp × 896dp

Tablet Sizes:
  Small: 600dp × 960dp
  Large: 768dp × 1024dp
```

---

### 6.2 レイアウト適応

#### モバイル（< 600dp）

```yaml
チャンネル一覧:
  Columns: 1
  Card Width: 100% - 32dp

動画リスト:
  Layout: 縦並び
  Thumbnail: 120dp × 68dp

FAB: 表示（右下固定）
Bottom Navigation: 表示
```

#### タブレット（600dp - 839dp）

```yaml
チャンネル一覧:
  Columns: 2
  Gap: 16dp
  Card Width: (100% - 48dp) / 2

動画リスト:
  Layout: 縦並び
  Thumbnail: 160dp × 90dp

FAB: 表示（右下固定）
Bottom Navigation: 表示
```

#### デスクトップ（840dp +）

```yaml
チャンネル一覧:
  Columns: 3
  Gap: 16dp
  Card Width: (100% - 64dp) / 3
  Max Width: 1200dp（コンテナ）

動画リスト:
  Layout: 横並び可能（オプション）
  Thumbnail: 200dp × 112dp

Navigation:
  Type: Side Drawer（常時表示）
  Width: 256dp
  
FAB: 表示（調整）
Bottom Navigation: 非表示
```

---

### 6.3 テキストスケーリング

```yaml
Font Size Scaling:
  Min: 0.85x（システム設定）
  Max: 2.0x（システム設定）
  
Responsive Font Sizes:
  H1: 20sp - 28sp
  H2: 18sp - 24sp
  Body: 14sp - 18sp
  Caption: 11sp - 14sp

Layout Adaptation:
  Large Text: 行高さ自動調整
  Max Lines: 適宜調整
```

---

## 7. アクセシビリティ

### 7.1 色覚対応

```yaml
Color Contrast Ratio:
  Normal Text (Body): 4.5:1以上
  Large Text (H1-H3): 3:1以上
  UI Components: 3:1以上
  
準拠: WCAG 2.1 Level AA

Color Independence:
  - 色だけに依存しない情報伝達
  - アイコン、テキストと組み合わせ
  - Success: ✓ + グリーン
  - Error: ⚠️ + レッド
```

---

### 7.2 タッチターゲット

```yaml
Minimum Touch Target:
  Size: 48dp × 48dp
  Spacing: 8dp以上

Small Elements:
  Visual Size: 24dp可
  Touch Area: 48dp（透明パディング）

Large Targets (推奨):
  Primary Actions: 48dp以上
  FAB: 56dp
```

---

### 7.3 スクリーンリーダー対応

```yaml
Semantic Labels:
  - 全インタラクティブ要素にラベル
  - 画像に代替テキスト（contentDescription）
  - ボタンに明確な説明

Reading Order:
  - 論理的な順序
  - Z-orderに依存しない

Announcements:
  - 重要な状態変化を通知
  - エラーメッセージの読み上げ
  - 成功フィードバック

Live Regions:
  - 動的コンテンツの更新通知
  - プログレス状態の通知
```

---

### 7.4 キーボードナビゲーション

```yaml
Tab Navigation:
  - すべてのインタラクティブ要素
  - 論理的な順序
  - スキップリンク対応（Web）

Keyboard Shortcuts:
  - Space: 再生/一時停止
  - Arrow Keys: シーク、ボリューム
  - F: 全画面
  - Esc: モーダルを閉じる

Focus Indicator:
  - 明確な視覚フィードバック
  - High Contrast: より強調
```

---

## 8. ダークモード対応

### 8.1 ダークモードカラーパレット

```yaml
Primary Colors:
  Primary: #3B82F6        # 明るいブルー
  Primary Light: #60A5FA
  Primary Dark: #2563EB

Background:
  Surface: #1A202C        # ダークグレー
  Background: #0F1419     # ほぼ黒
  Card: #2D3748           # ミディアムグレー

Text:
  Primary: #F7FAFC        # ほぼ白
  Secondary: #A0AEC0      # ライトグレー
  Disabled: #4A5568       # ダークグレー

Status Colors:
  Success: #68D391        # 明るいグリーン
  Error: #FC8181          # 明るいレッド
  Warning: #F6AD55        # 明るいオレンジ
  Info: #63B3ED           # 明るいブルー
```

---

### 8.2 適用ルール

```yaml
System Setting:
  - OS設定に自動追従
  - 手動切替も可能（設定画面）

Components:
  - カード: Elevation強調
  - ボーダー: より明るく
  - シャドウ: より強調

Video Player:
  - 常に黒背景（変更なし）
  - コントロール: より明るく

Images:
  - オーバーレイなし
  - 明るさ調整なし
```

---

### 8.3 ダークモード専用調整

```yaml
Elevation:
  - より強調されたシャドウ
  - オーバーレイによる区別

Border:
  - ライトモード: 1dp, rgba(0,0,0,0.1)
  - ダークモード: 1dp, rgba(255,255,255,0.1)

Hover State:
  - ライトモード: rgba(0,0,0,0.05)
  - ダークモード: rgba(255,255,255,0.05)

Disabled State:
  - より暗いグレー
  - コントラスト維持
```

---

## 9. 実装ガイドライン

### 9.1 優先順位

#### Phase 1: 必須画面（MVP）
1. ログイン画面
2. チャンネル一覧（ホーム）
3. チャンネル追加
4. 動画リスト
5. 動画再生

#### Phase 2: 基本機能
6. 設定画面
7. ダークモード対応
8. レスポンシブ対応

#### Phase 3: 拡張機能
9. アニメーション最適化
10. アクセシビリティ強化
11. ミニプレイヤー

---

### 9.2 デザイントークン

Flutterでの実装例：

```dart
class AppTheme {
  // Colors
  static const primaryColor = Color(0xFF1E3A5F);
  static const primaryLight = Color(0xFF2C5282);
  static const primaryDark = Color(0xFF0F1E2F);
  
  // Typography
  static const headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  
  // Spacing
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 16.0;
  static const spacingL = 24.0;
  
  // Border Radius
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 20.0;
}
```

---

### 9.3 デザインチェックリスト

**各画面完成時の確認事項:**

- [ ] カラーパレット準拠
- [ ] タイポグラフィ準拠
- [ ] スペーシング統一
- [ ] タッチターゲット48dp以上
- [ ] コントラスト比達成
- [ ] アニメーション実装
- [ ] ダークモード対応
- [ ] レスポンシブ対応
- [ ] アクセシビリティラベル
- [ ] エラー状態実装
- [ ] ローディング状態実装

---

## 10. まとめ

### 10.1 デザインの特徴

✅ **落ち着いた配色**: 深いネイビーを基調とした目に優しいカラーパレット  
✅ **Material Design 3準拠**: 最新のデザインガイドライン適用  
✅ **アクセシビリティ**: WCAG 2.1 AA準拠  
✅ **レスポンシブ**: モバイル/タブレット/デスクトップ対応  
✅ **ダークモード**: システム設定連動  
✅ **アニメーション**: スムーズで直感的なインタラクション  

---

### 10.2 デザインファイル

**モックアップ**: `drivevideo_mockup.html`  
- インタラクティブなプロトタイプ
- 全7画面を確認可能
- ホバー/タップ効果実装済み

---

### 10.3 次のステップ

1. **ロゴデザイン作成**: アプリアイコン・スプラッシュ用
2. **アセット準備**: アイコン、イラスト素材
3. **Flutter実装**: デザインシステムのコード化
4. **ユーザーテスト**: プロトタイプでのユーザビリティ検証
5. **デザイン改善**: フィードバックに基づく調整

---

**バージョン履歴:**
- v1.0 (2025-12-29): 初版作成

**参考資料:**
- Material Design 3: https://m3.material.io/
- WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/
- Flutter Design: https://docs.flutter.dev/ui/design
