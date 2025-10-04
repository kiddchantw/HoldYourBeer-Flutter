# 背景元件使用說明

此目錄包含模組化的背景視覺效果元件，保留了登入畫面的所有原始特效。

## 元件清單

### 1. BeerGradientBackground
提供啤酒主題的漸層背景。

```dart
BeerGradientBackground(
  child: YourContent(),
  customColors: [Colors.red, Colors.blue], // 可選：自訂漸層顏色
  begin: Alignment.topLeft,                  // 可選：漸層起點
  end: Alignment.bottomRight,                // 可選：漸層終點
)
```

### 2. BeerBubbleDecoration
提供泡泡裝飾效果，包含所有原始的泡泡位置和顏色。

```dart
BeerBubbleDecoration(
  enableAnimation: true,        // 啟用泡泡動畫效果
  animationDuration: 4.0,      // 動畫持續時間（秒）
)
```

### 3. LoginBackground (整合元件)
結合漸層背景和泡泡裝飾的完整登入背景元件。

```dart
LoginBackground(
  enableBubbleAnimation: true,           // 啟用泡泡動畫
  bubbleAnimationDuration: 4.0,         // 泡泡動畫持續時間
  customGradientColors: [...],          // 可選：自訂漸層顏色
  child: YourLoginContent(),
)
```

## 功能特色

- ✅ **完整保留原始設計**：所有泡泡位置、大小、顏色都完全保留
- ✅ **模組化設計**：可以單獨使用漸層背景或泡泡裝飾
- ✅ **動畫效果**：可選的泡泡動畫效果，讓背景更生動
- ✅ **可自訂性**：支援自訂漸層顏色和動畫參數
- ✅ **易於重用**：可在其他畫面使用相同的視覺效果

## 使用範例

### 基本使用（登入畫面）
```dart
Scaffold(
  body: LoginBackground(
    enableBubbleAnimation: true,
    child: SafeArea(
      child: YourLoginForm(),
    ),
  ),
)
```

### 自訂顏色的背景
```dart
LoginBackground(
  customGradientColors: [
    Colors.blue.shade200,
    Colors.blue.shade100,
    Colors.white,
  ],
  enableBubbleAnimation: false,
  child: YourContent(),
)
```

### 只使用漸層背景
```dart
BeerGradientBackground(
  child: YourContent(),
)
```

### 只使用泡泡裝飾
```dart
Stack(
  children: [
    Container(color: Colors.amber.shade100),
    BeerBubbleDecoration(enableAnimation: true),
    YourContent(),
  ],
)
```

## 動畫效果

泡泡動畫包含：
- **縮放動畫**：泡泡會在 0.8 到 1.2 倍之間緩慢縮放
- **透明度動畫**：泡泡透明度在 0.3 到 0.8 之間變化
- **緩動曲線**：使用 `Curves.easeInOut` 讓動畫更自然
- **循環播放**：動畫會自動反向循環播放

## 導入方式

```dart
import '../../../shared/widgets/background/background.dart';
```

此 barrel 檔案會自動導入所有背景相關元件。