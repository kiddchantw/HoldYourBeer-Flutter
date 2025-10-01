# HoldYourBeer Flutter 專案設定指南

## 🚀 快速開始

### 1. 安裝 Flutter SDK

```bash
# macOS - 使用 Homebrew
brew install --cask flutter

# 或下載 Flutter SDK
https://docs.flutter.dev/get-started/install

# 驗證安裝
flutter doctor
```

### 2. 專案初始化

```bash
cd /Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter

# 安裝依賴
flutter pub get

# 生成程式碼 (Freezed, Retrofit, Riverpod)
flutter packages pub run build_runner build

# 如果遇到衝突，強制重新生成
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. 環境設定

確保你的 Laravel 後端正在運行：

```bash
# 在 Laravel 專案目錄
docker-compose -f ../../laradock/docker-compose.yml exec -w /var/www/beer/HoldYourBeer workspace php artisan serve
```

### 4. API 基礎 URL 設定

編輯 `lib/core/constants/app_constants.dart`:

```dart
// 本地開發
static const String baseUrl = 'http://localhost/api';

// 或 Android 模擬器
static const String baseUrl = 'http://10.0.2.2/api';

// 或 iOS 模擬器
static const String baseUrl = 'http://127.0.0.1/api';
```

## 📱 運行應用程式

### Android
```bash
# 列出可用設備
flutter devices

# 運行在 Android 設備/模擬器
flutter run
```

### iOS (僅 macOS)
```bash
# 安裝 iOS 依賴
cd ios && pod install && cd ..

# 運行在 iOS 模擬器
flutter run
```

## 🛠️ 開發指令

### 程式碼生成
```bash
# 監聽模式 - 自動重新生成
flutter packages pub run build_runner watch

# 單次生成
flutter packages pub run build_runner build
```

### 測試
```bash
# 運行所有測試
flutter test

# 運行特定測試檔案
flutter test test/unit/auth_test.dart

# 產生測試覆蓋率
flutter test --coverage
```

### 建置
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS (僅 macOS)
flutter build ios --release
```

## 🔧 故障排除

### 常見問題

1. **程式碼生成失敗**
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

2. **網路請求失敗**
- 檢查 API base URL 設定
- 確認 Laravel 後端正在運行
- Android 模擬器需要使用 `10.0.2.2`

3. **Hive 資料庫錯誤**
```dart
// 清除 Hive boxes
await Hive.deleteBoxFromDisk('holdyourbeer_box');
```

### IDE 設定

**VS Code 推薦擴展：**
- Flutter
- Dart
- Awesome Flutter Snippets

**Android Studio：**
- 安裝 Flutter 和 Dart 插件

## 📚 架構說明

### 狀態管理 (Riverpod)
```dart
// Provider 定義
final beerListProvider = StateNotifierProvider<BeerListNotifier, AsyncValue<List<Beer>>>(
  (ref) => BeerListNotifier(ref.watch(beerServiceProvider)),
);

// 使用 Provider
ref.watch(beerListProvider)  // 監聽狀態變化
ref.read(beerListProvider.notifier).loadBeers()  // 調用方法
```

### API 服務 (Retrofit)
```dart
// 服務定義
@RestApi()
abstract class BeerService {
  @GET('/beers')
  Future<HttpResponse<List<Beer>>> getMyBeers();
}

// 使用服務
final response = await beerService.getMyBeers();
```

### 資料模型 (Freezed)
```dart
// 模型定義
@freezed
class Beer with _$Beer {
  const factory Beer({
    required int id,
    required String name,
  }) = _Beer;

  factory Beer.fromJson(Map<String, dynamic> json) => _$BeerFromJson(json);
}
```

## 🎯 下一步

完成基本設定後，你可以：
1. 自訂 UI 主題和樣式
2. 新增更多功能頁面
3. 實作推播通知
4. 新增離線支援
5. 整合 Firebase 分析

## 📞 支援

如果遇到問題，請參考：
- [Flutter 官方文件](https://docs.flutter.dev/)
- [Riverpod 文件](https://riverpod.dev/)
- Laravel API 規格：`../HoldYourBeer/spec/api/api.yaml`