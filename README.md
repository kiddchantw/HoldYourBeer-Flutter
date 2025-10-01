# HoldYourBeer Flutter App

HoldYourBeer 的 Flutter 手機應用程式，用於追蹤啤酒消費記錄。

## 🛠️ 技術堆疊

- **Framework**: Flutter 3.x
- **狀態管理**: Riverpod 2.0
- **網路請求**: Dio + Retrofit
- **本地儲存**: Hive + Flutter Secure Storage
- **路由管理**: Go Router
- **UI適配**: ScreenUtil

## 📁 專案結構

```
lib/
├── core/                    # 核心功能
│   ├── api/                # API 相關配置
│   ├── auth/               # 認證管理
│   ├── constants/          # 常數定義
│   └── utils/              # 工具函數
├── data/                   # 資料層
│   ├── models/             # 資料模型
│   ├── repositories/       # 資料倉庫
│   └── services/           # API 服務
├── features/               # 功能模組
│   ├── auth/               # 認證功能
│   ├── beer_tracking/      # 啤酒追蹤
│   ├── brand_management/   # 品牌管理
│   └── tasting_history/    # 品嚐歷史
└── shared/                 # 共用元件
    ├── widgets/            # UI 元件
    └── themes/             # 主題配置
```

## 🚀 開始開發

### 前置需求

1. 安裝 Flutter SDK (3.0.0+)
2. 安裝 Android Studio 或 Xcode
3. 設定開發環境

### 安裝依賴

```bash
flutter pub get
```

### 程式碼生成

```bash
flutter packages pub run build_runner build
```

### 執行應用程式

```bash
flutter run
```

## 🔧 API 整合

此應用程式連接到 Laravel 後端 API：
- **Base URL**: `http://localhost/api` (開發環境)
- **認證方式**: Laravel Sanctum Bearer Token
- **API 文件**: 參考 Laravel 專案的 OpenAPI 規格

## 📱 核心功能

- ✅ 使用者註冊與登入
- ✅ 啤酒追蹤與計數
- ✅ 品牌管理
- ✅ 品嚐歷史記錄
- ✅ 離線資料同步

## 🧪 測試

```bash
# 執行所有測試
flutter test

# 執行特定測試
flutter test test/unit/auth_test.dart

# 產生測試覆蓋率報告
flutter test --coverage
```

## 🏗️ 建置

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```