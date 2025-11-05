# HoldYourBeer 環境與部署規劃

**專案名稱**：HoldYourBeer - 啤酒消費追蹤應用程式
**架構**：Flutter (Mobile) + Laravel (API Backend)
**策略**：漸進式單人開發部署策略
**規劃日期**：2025-11-05
**目標**：最小成本、最大效益、易於維護

---

## 📋 目錄

1. [環境架構設計](#環境架構設計)
2. [階段性部署策略](#階段性部署策略)
3. [技術選型與成本](#技術選型與成本)
4. [環境設定詳細步驟](#環境設定詳細步驟)
5. [CI/CD 自動化](#cicd-自動化)
6. [監控與維護](#監控與維護)
7. [擴展計畫](#擴展計畫)

---

## 環境架構設計

### 整體架構圖

```
┌─────────────────────────────────────────────────────┐
│                   開發階段（現在）                     │
├─────────────────────────────────────────────────────┤
│                                                       │
│  本地開發環境 (localhost)                              │
│  ┌──────────────┐     ┌──────────────┐              │
│  │   Flutter    │────▶│   Laravel    │              │
│  │ (Debug Build)│     │  php artisan │              │
│  │              │     │    serve     │              │
│  └──────────────┘     └───────┬──────┘              │
│                               │                       │
│                        ┌──────▼──────┐               │
│                        │   MySQL     │               │
│                        │  (Local DB) │               │
│                        └─────────────┘               │
│                                                       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│              Beta 測試階段（1-2 個月後）               │
├─────────────────────────────────────────────────────┤
│                                                       │
│  開發環境 (localhost)     線上環境 (Cloud)             │
│  ┌──────────────┐       ┌──────────────┐            │
│  │   Flutter    │       │   Flutter    │            │
│  │ (Debug Build)│       │  (Beta APK)  │            │
│  └──────┬───────┘       └───────┬──────┘            │
│         │                       │                    │
│         ▼                       ▼                    │
│  ┌──────────────┐       ┌──────────────┐            │
│  │   Laravel    │       │   Laravel    │            │
│  │   (Local)    │       │  (Railway)   │            │
│  └──────┬───────┘       └───────┬──────┘            │
│         │                       │                    │
│         ▼                       ▼                    │
│  ┌──────────────┐       ┌──────────────┐            │
│  │   MySQL      │       │  PostgreSQL  │            │
│  │   (Local)    │       │  (Railway)   │            │
│  └──────────────┘       └──────────────┘            │
│                                                       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│            正式發布階段（3 個月後，視需求）             │
├─────────────────────────────────────────────────────┤
│                                                       │
│  Local Dev        Production            Monitoring   │
│  ┌─────────┐     ┌─────────────┐      ┌─────────┐  │
│  │ Flutter │     │   Flutter   │      │ Sentry  │  │
│  │ Laravel │     │   (Store)   │      │Firebase │  │
│  │  MySQL  │     └──────┬──────┘      │Analytics│  │
│  └─────────┘            │             └─────────┘  │
│                         ▼                            │
│                 ┌───────────────┐                   │
│                 │  Laravel API  │                   │
│                 │   (Railway/   │                   │
│                 │    Render)    │                   │
│                 └───────┬───────┘                   │
│                         │                            │
│                         ▼                            │
│                 ┌───────────────┐                   │
│                 │  PostgreSQL   │                   │
│                 │   Database    │                   │
│                 └───────────────┘                   │
│                                                       │
└─────────────────────────────────────────────────────┘
```

### 環境定義

| 環境 | 用途 | 時機 | 資料 | 部署位置 |
|------|------|------|------|----------|
| **Development** | 開發新功能、實驗 | 隨時 | 假資料、測試資料 | 本地 (localhost) |
| **Production** | Beta 測試 → 正式用戶 | Beta 開始 | 真實資料 | Cloud (Railway/Render) |
| **Staging** | 進階測試（未來選配） | 用戶 >1000 | 生產資料副本 | Cloud (可選) |

---

## 階段性部署策略

### 階段 1：本地開發期（現在 - MVP 完成）

**目標**：專注開發，快速迭代

**環境配置**：
```yaml
環境: Local Development Only

前端 (Flutter):
  - 開發工具: VS Code / Android Studio
  - 測試裝置: Android Emulator + iOS Simulator
  - 建置模式: Debug build
  - 熱重載: ✅ 支援

後端 (Laravel):
  - 運行方式: php artisan serve
  - 資料庫: MySQL 8.0 (Local)
  - API 測試: Postman / Insomnia
  - Debug: Laravel Telescope

成本: $0
維護時間: 0 (開發即維護)
```

**環境變數設定**：

**Flutter** (`lib/core/config/env_config.dart`):
```dart
class EnvConfig {
  // 環境判斷
  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  // API 設定
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.holdyourbeer.com';
    }
    // 開發環境 - 根據平台自動選擇
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api'; // iOS Simulator
    }
    return 'http://192.168.1.124:8000/api'; // 實體裝置 (改成你的 IP)
  }

  // 功能開關
  static const bool enableDebugFeatures = !isProduction;
  static const bool enableLogging = !isProduction;
}
```

**Laravel** (`.env`):
```env
APP_NAME=HoldYourBeer
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=holdyourbeer
DB_USERNAME=root
DB_PASSWORD=

# Google OAuth (開發用)
GOOGLE_CLIENT_ID=your-dev-client-id
GOOGLE_CLIENT_SECRET=your-dev-secret
```

**執行指令**：
```bash
# Laravel 後端
cd backend
php artisan serve

# Flutter 前端
cd flutter_app
flutter run
```

---

### 階段 2：Beta 測試期（1-2 個月後）

**目標**：招募測試者，獲得真實反饋

**部署時機**：
- ✅ 核心功能完成（認證、啤酒追蹤、歷史記錄）
- ✅ 本地測試通過
- ✅ UI/UX 基本完善
- ✅ 準備好處理用戶反饋

**環境配置**：
```yaml
環境 1: Local Development (持續開發)
環境 2: Production Beta (線上測試)

後端部署:
  平台: Railway (推薦) 或 Render
  方案: Hobby Plan ($5/月) 或 Free Tier
  資料庫: PostgreSQL 14+
  域名: api.holdyourbeer.com (Cloudflare DNS)
  SSL: 自動 (Let's Encrypt)

前端分發:
  Android:
    - Firebase App Distribution (Beta 測試)
    - Google Play Store (內部測試 track)
  iOS:
    - TestFlight (Beta 測試)
    - App Store (稍後)

成本: $0-10/月
維護時間: 2-3 小時/週
```

**Beta 測試管理**：
```sql
-- 在 users 表增加欄位
ALTER TABLE users ADD COLUMN user_type ENUM('internal', 'beta', 'regular') DEFAULT 'regular';
ALTER TABLE users ADD COLUMN beta_access_code VARCHAR(50) UNIQUE;
```

**Beta 邀請流程**：
1. 生成 Beta Access Code
2. 分享給測試者
3. 註冊時輸入 code → 標記為 beta_user
4. Beta 用戶可存取新功能

---

### 階段 3：正式發布期（3 個月後）

**目標**：公開發布，穩定運營

**部署策略**：
```yaml
環境:
  - Local Development (持續)
  - Production (穩定版)
  - Staging (可選，視情況)

後端部署:
  平台: Railway Pro / Render / DigitalOcean
  方案: $10-20/月
  資料庫: PostgreSQL (備份機制)
  CDN: Cloudflare (免費)
  監控: Sentry + Uptime Robot

前端分發:
  Android: Google Play Store (正式發布)
  iOS: App Store (正式發布)

發布策略:
  - 灰度發布: 先 20% 用戶 → 50% → 100%
  - 版本管理: Semantic Versioning (v1.0.0)
  - 更新頻率: 每 2 週一個小版本

成本: $20-40/月
維護時間: 5-8 小時/週
```

---

## 技術選型與成本

### 後端部署平台比較

| 平台 | 免費方案 | 付費方案 | 優點 | 缺點 | 推薦度 |
|------|----------|----------|------|------|--------|
| **Railway** | ✅ $5 credit/月 | $5-20/月 | 部署簡單、支援 Laravel | Credit 用完需付費 | ⭐⭐⭐⭐⭐ |
| **Render** | ✅ 有限制 | $7-25/月 | 穩定、文件完善 | 免費版 cold start | ⭐⭐⭐⭐ |
| **Heroku** | ❌ 2022 取消 | $7-25/月 | 成熟、生態好 | 無免費方案 | ⭐⭐⭐ |
| **DigitalOcean** | ❌ 無免費 | $6-12/月 | 完全控制、便宜 | 需要自己設定 | ⭐⭐⭐ |
| **Vercel** | ✅ 很慷慨 | $20/月 | 極快、適合前端 | ❌ 不支援 Laravel | ⭐ |
| **AWS/GCP** | ✅ 12 月 | 依用量 | 強大、可擴展 | 複雜、可能爆費用 | ⭐⭐ |

### 推薦組合方案

#### 方案 A：Railway (推薦新手)

**優點**：
- ✅ 一鍵部署 Laravel
- ✅ 自動配置 PostgreSQL
- ✅ 內建 SSL
- ✅ GitHub 自動部署

**成本**：
```
月費: $5 (Hobby)
資料庫: 包含在內
流量: 100 GB
```

**設定難度**：⭐ (非常簡單)

#### 方案 B：Render (推薦穩定性)

**優點**：
- ✅ 穩定性高
- ✅ 文件詳細
- ✅ 自動備份
- ✅ 免費 SSL

**成本**：
```
Web Service: $7/月
PostgreSQL: $7/月 (或免費版)
總計: $7-14/月
```

**設定難度**：⭐⭐ (簡單)

#### 方案 C：DigitalOcean (推薦進階)

**優點**：
- ✅ 完全控制
- ✅ 便宜
- ✅ 可安裝任何軟體
- ✅ 固定 IP

**成本**：
```
Droplet: $6/月 (1GB RAM)
資料庫: $0 (自己安裝)
備份: $1.2/月 (可選)
總計: $6-7.2/月
```

**設定難度**：⭐⭐⭐⭐ (需要 Linux 知識)

### 資料庫選擇

| 資料庫 | 開發環境 | 生產環境 | 備註 |
|--------|----------|----------|------|
| MySQL | ✅ 推薦 | ⚠️ 可用 | Laravel 預設 |
| PostgreSQL | ✅ 可用 | ✅ 推薦 | 功能更強、免費方案多 |
| SQLite | ✅ 快速測試 | ❌ 不推薦 | 不適合多用戶 |

**建議**：
- 開發環境：MySQL（已經用了，保持一致）
- 生產環境：PostgreSQL（Railway/Render 都支援）

**遷移計畫**：
```bash
# 1. 更新 Laravel database config 支援兩者
# 2. 確保 migration 相容
# 3. 部署時自動使用 PostgreSQL
```

### 前端分發平台

#### Android

| 方式 | 用途 | 成本 | 設定 |
|------|------|------|------|
| **Firebase App Distribution** | Beta 測試 | 免費 | 簡單 |
| **Google Play Console** | 正式發布 | $25 一次性 | 中等 |
| APK Direct | 個人測試 | 免費 | 最簡單 |

#### iOS

| 方式 | 用途 | 成本 | 設定 |
|------|------|------|------|
| **TestFlight** | Beta 測試 | $99/年 (Apple Developer) | 中等 |
| **App Store** | 正式發布 | $99/年 | 複雜 |

### 其他服務成本

| 服務 | 用途 | 免費方案 | 付費方案 | 推薦 |
|------|------|----------|----------|------|
| **Cloudflare** | CDN + DNS | ✅ 慷慨 | $20/月 | ⭐⭐⭐⭐⭐ |
| **Sentry** | 錯誤追蹤 | 5k events/月 | $26/月 | ⭐⭐⭐⭐⭐ |
| **Firebase** | Analytics + Crashlytics | ✅ 免費 | - | ⭐⭐⭐⭐⭐ |
| **Uptime Robot** | 服務監控 | 50 monitors | $7/月 | ⭐⭐⭐⭐ |
| **Mailgun** | Email 發送 | 5k emails/月 | $35/月 | ⭐⭐⭐⭐ |
| **Google Cloud** | OAuth + Storage | ✅ 免費額度 | 依用量 | ⭐⭐⭐⭐ |

### 總成本預估

#### Phase 1: 本地開發（現在）
```
✅ 完全免費 $0/月
```

#### Phase 2: Beta 測試（1-2 個月後）
```
Railway Hobby:          $5/月
Cloudflare:             $0 (免費)
Sentry:                 $0 (免費額度)
Firebase:               $0 (免費)
Domain (.com):          $12/年 ≈ $1/月
───────────────────────────────
總計:                   $6/月

或選擇 Render Free:     $0/月 (有限制)
```

#### Phase 3: 正式發布（3 個月後）
```
Railway Pro:            $20/月
或 Render Web + DB:     $14/月
Google Play:            $25 一次性
Apple Developer:        $99/年 ≈ $8.25/月
Domain:                 $1/月
Cloudflare:             $0
Sentry:                 $0 (免費額度)
───────────────────────────────
總計:                   $35-40/月 首月
之後:                   $21-35/月
```

---

## 環境設定詳細步驟

### Phase 2 部署：Railway (推薦)

#### 步驟 1：準備 Laravel 專案

**1.1 建立 Procfile**
```bash
# 在 Laravel 專案根目錄建立 Procfile
echo "web: php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=$PORT" > Procfile
```

**1.2 更新 .env.example**
```env
APP_NAME=HoldYourBeer
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.holdyourbeer.com

DB_CONNECTION=pgsql
DB_HOST=${DATABASE_HOST}
DB_PORT=${DATABASE_PORT}
DB_DATABASE=${DATABASE_DATABASE}
DB_USERNAME=${DATABASE_USERNAME}
DB_PASSWORD=${DATABASE_PASSWORD}

# Railway 會自動提供上述 DATABASE_* 變數
```

**1.3 確保 composer.json 正確**
```json
{
  "require": {
    "php": "^8.1",
    "laravel/framework": "^10.0",
    // ... 其他套件
  },
  "scripts": {
    "post-install-cmd": [
      "php artisan optimize:clear",
      "php artisan config:cache",
      "php artisan route:cache"
    ]
  }
}
```

**1.4 提交到 GitHub**
```bash
git add .
git commit -m "chore: prepare for Railway deployment"
git push origin main
```

#### 步驟 2：Railway 部署

**2.1 建立 Railway 專案**
```
1. 前往 https://railway.app/
2. 使用 GitHub 登入
3. 點擊 "New Project"
4. 選擇 "Deploy from GitHub repo"
5. 選擇 HoldYourBeer-Backend repository
6. 選擇 main 分支
```

**2.2 新增 PostgreSQL**
```
1. 在專案頁面點擊 "New"
2. 選擇 "Database" → "PostgreSQL"
3. Railway 會自動建立並連接
```

**2.3 設定環境變數**
```
在 Railway 專案的 Variables 頁面設定：

APP_KEY=base64:xxx (用 php artisan key:generate --show)
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-app.up.railway.app

GOOGLE_CLIENT_ID=your-production-client-id
GOOGLE_CLIENT_SECRET=your-production-secret

# 其他 DATABASE_* 會自動配置
```

**2.4 部署**
```
Railway 會自動：
1. 檢測到 Laravel 專案
2. 安裝 PHP 和 Composer
3. 執行 composer install
4. 執行 Procfile 中的命令
5. 提供公開 URL
```

**2.5 設定自訂域名**
```
1. 在 Railway 專案設定中點擊 "Settings"
2. 在 "Domains" 區塊點擊 "Generate Domain"
3. 或添加自訂域名：api.holdyourbeer.com
4. 在 Cloudflare DNS 設定 CNAME 記錄
```

#### 步驟 3：Flutter 環境設定

**3.1 更新 API 設定**
```dart
// lib/core/config/env_config.dart
class EnvConfig {
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.holdyourbeer.com'; // Railway URL
    }
    return 'http://localhost:8000/api';
  }
}
```

**3.2 建置 Beta 版本**

**Android (Firebase App Distribution)**:
```bash
# 1. 安裝 Firebase CLI
npm install -g firebase-tools

# 2. 登入 Firebase
firebase login

# 3. 初始化 Firebase
cd flutter_app
firebase init

# 4. 建置 APK
flutter build apk --release --dart-define=PRODUCTION=true

# 5. 上傳到 Firebase App Distribution
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups beta-testers \
  --release-notes "Beta v0.1.0: Initial beta release"
```

**iOS (TestFlight)**:
```bash
# 1. 在 Xcode 中設定 Signing
# 2. 選擇 Archive
# 3. Upload to App Store Connect
# 4. 在 App Store Connect 中提交到 TestFlight
```

---

### 替代方案：Render 部署

#### 步驟 1：建立 render.yaml

```yaml
# render.yaml (放在專案根目錄)
services:
  - type: web
    name: holdyourbeer-api
    env: php
    buildCommand: composer install --no-dev --optimize-autoloader
    startCommand: php artisan serve --host=0.0.0.0 --port=$PORT
    envVars:
      - key: APP_ENV
        value: production
      - key: APP_DEBUG
        value: false
      - key: APP_KEY
        generateValue: true
      - key: DATABASE_URL
        fromDatabase:
          name: holdyourbeer-db
          property: connectionString

databases:
  - name: holdyourbeer-db
    databaseName: holdyourbeer
    user: holdyourbeer
```

#### 步驟 2：在 Render 部署

```
1. 前往 https://render.com/
2. 使用 GitHub 登入
3. 點擊 "New +"
4. 選擇 "Blueprint" (會自動讀取 render.yaml)
5. 選擇 repository
6. 點擊 "Apply"
```

---

## CI/CD 自動化

### GitHub Actions 設定

**目標**：每次 push 到 main，自動部署到 Railway

**建立 `.github/workflows/deploy.yml`**:
```yaml
name: Deploy to Railway

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'

      - name: Install Dependencies
        run: composer install --no-dev --optimize-autoloader

      - name: Run Tests
        run: php artisan test

      - name: Deploy to Railway
        if: github.ref == 'refs/heads/main'
        run: |
          curl -X POST ${{ secrets.RAILWAY_WEBHOOK_URL }}
```

**設定 Secrets**:
```
1. 在 GitHub repo 的 Settings → Secrets
2. 添加 RAILWAY_WEBHOOK_URL
3. 從 Railway 專案設定取得 webhook URL
```

### Flutter 自動建置（選擇性）

```yaml
# .github/workflows/build-flutter.yml
name: Build Flutter APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release --dart-define=PRODUCTION=true

      - name: Upload to Firebase
        run: |
          npm install -g firebase-tools
          firebase appdistribution:distribute \
            build/app/outputs/flutter-apk/app-release.apk \
            --app ${{ secrets.FIREBASE_APP_ID }} \
            --token ${{ secrets.FIREBASE_TOKEN }}
```

---

## 監控與維護

### 錯誤追蹤：Sentry

**Laravel 安裝**:
```bash
composer require sentry/sentry-laravel
php artisan sentry:publish --dsn=your-dsn
```

**設定** (`.env`):
```env
SENTRY_LARAVEL_DSN=https://xxx@xxx.ingest.sentry.io/xxx
SENTRY_TRACES_SAMPLE_RATE=1.0
```

**Flutter 安裝**:
```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0
```

```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'your-dsn';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

### 服務監控：Uptime Robot

**設定步驟**:
```
1. 前往 https://uptimerobot.com/
2. 註冊免費帳號（50 monitors）
3. 添加 HTTP(s) monitor
4. URL: https://api.holdyourbeer.com/health
5. 監控間隔: 5 分鐘
6. 設定 Alert：Email + Discord/Slack
```

**Laravel Health Check**:
```php
// routes/api.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'database' => DB::connection()->getPdo() ? 'connected' : 'disconnected',
    ]);
});
```

### Analytics：Firebase + Google Analytics

**Flutter 設定**:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
```

```dart
// 追蹤使用者行為
FirebaseAnalytics.instance.logEvent(
  name: 'beer_added',
  parameters: {
    'beer_name': beerName,
    'brand': brandName,
  },
);
```

### 備份策略

**資料庫自動備份**:

**Railway**:
```
Railway Pro plan 自動提供 snapshot
或使用 Cron Job:
```

**手動備份腳本**:
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="holdyourbeer"

# 建立備份
pg_dump $DATABASE_URL > $BACKUP_DIR/backup_$DATE.sql

# 上傳到 S3 或其他儲存
aws s3 cp $BACKUP_DIR/backup_$DATE.sql s3://my-backups/

# 刪除 7 天前的備份
find $BACKUP_DIR -type f -mtime +7 -delete
```

**設定 Cron**:
```
0 2 * * * /path/to/backup.sh  # 每天凌晨 2 點
```

---

## 擴展計畫

### 當用戶數成長時的擴展路徑

#### 階段 1: 0-100 用戶
```
✅ 當前架構足夠
- Railway Hobby ($5/月)
- 單一伺服器
- PostgreSQL 內建
```

#### 階段 2: 100-1000 用戶
```
需要考慮:
- 升級到 Railway Pro ($20/月)
- 增加 database connection pool
- 啟用 Redis cache
- 考慮 CDN (Cloudflare 免費版即可)
```

#### 階段 3: 1000-10000 用戶
```
需要考慮:
- 分離 Database ($20-50/月)
- 增加 Staging 環境
- Load balancer (選配)
- 專業監控 (Datadog/New Relic)
- 考慮改用 DigitalOcean Kubernetes
```

#### 階段 4: 10000+ 用戶
```
需要考慮:
- 微服務架構
- 資料庫讀寫分離
- CDN for static assets
- Auto-scaling
- 專職 DevOps
```

**目前不需要擔心這些！專注在做出好產品** 🚀

---

## 部署檢查清單

### Beta 部署前 Checklist

**後端**:
- [ ] 所有測試通過 (`php artisan test`)
- [ ] 環境變數正確設定
- [ ] Database migration 準備好
- [ ] API 文件更新
- [ ] Error handling 完善
- [ ] Rate limiting 設定
- [ ] CORS 設定正確

**前端**:
- [ ] 所有功能測試通過
- [ ] Production API URL 設定
- [ ] Google OAuth 生產憑證設定
- [ ] 應用程式圖示和啟動畫面
- [ ] 版本號更新
- [ ] Release notes 撰寫

**服務**:
- [ ] Domain 購買並設定
- [ ] SSL 證書啟用
- [ ] Sentry 設定
- [ ] Firebase Analytics 設定
- [ ] Uptime Robot 監控設定

**測試**:
- [ ] 本地 production build 測試
- [ ] API 連線測試
- [ ] Google Sign-In 測試
- [ ] 支付流程測試（如有）
- [ ] 效能測試

---

## 緊急應變計畫

### 伺服器當機

**立即行動**:
```
1. 檢查 Uptime Robot 通知
2. 登入 Railway Dashboard
3. 查看 logs
4. 如需要，restart service
5. 在 Twitter 發布狀態更新
```

**聯絡方式**:
- Railway Status: https://railway.statuspage.io/
- Support: Railway Discord

### 資料庫損壞

**立即行動**:
```
1. 停止寫入操作
2. 從最近備份恢復
3. 檢查資料完整性
4. 通知受影響用戶
```

### 應用程式 Bug

**處理流程**:
```
1. 從 Sentry 接收通知
2. 評估嚴重性
3. 如果嚴重: 緊急 hotfix
4. 如果輕微: 排入下次更新
5. 發布 patch 版本
```

---

## 總結與建議

### 立即行動（現階段）

```
✅ 繼續在本地開發
✅ 專注完成 MVP 功能
✅ 不需要立即部署
```

### 1 個月後（Beta 準備）

```
□ 註冊 Railway 帳號（或 Render）
□ 購買 domain (holdyourbeer.com)
□ 設定 Cloudflare DNS
□ 建立 Firebase 專案（App Distribution）
□ 設定 Sentry 錯誤追蹤
□ 準備 Beta 測試邀請連結
```

### 2-3 個月後（正式發布）

```
□ 申請 Google Play Developer 帳號 ($25)
□ 申請 Apple Developer 帳號 ($99/年)
□ 準備應用程式商店素材（截圖、描述）
□ 撰寫隱私權政策和服務條款
□ 準備 Product Hunt Launch
□ 設定 Google Analytics
```

### 關鍵建議

1. **不要過早優化**：現在專注開發，部署可以晚點
2. **逐步投入**：從免費方案開始，有需要再升級
3. **自動化優先**：CI/CD 設定好，節省時間
4. **監控必備**：Sentry + Uptime Robot 早點設定
5. **文件齊全**：記錄所有設定，未來自己會感謝

---

## 附錄

### A. Railway 替代方案快速比較

如果 Railway 不適合，這是決策樹：

```
需要完全控制？
├─ 是 → DigitalOcean VPS
└─ 否 → 繼續

預算非常緊？
├─ 是 → Render (免費層) 或 Fly.io
└─ 否 → 繼續

需要最簡單？
├─ 是 → Railway
└─ 否 → Render (更穩定但稍複雜)
```

### B. 常用指令快速參考

**Railway CLI**:
```bash
# 安裝
npm install -g @railway/cli

# 登入
railway login

# 連結專案
railway link

# 查看 logs
railway logs

# 執行指令
railway run php artisan migrate

# 設定環境變數
railway variables set KEY=value
```

**Flutter 建置**:
```bash
# Android Debug
flutter build apk --debug

# Android Release
flutter build apk --release --dart-define=PRODUCTION=true

# iOS (需要 Mac)
flutter build ios --release --dart-define=PRODUCTION=true

# 檢查建置大小
flutter build apk --analyze-size
```

**Laravel 部署**:
```bash
# 清除快取
php artisan optimize:clear

# 建立快取
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 執行 migration
php artisan migrate --force

# 查看路由
php artisan route:list
```

### C. 有用的連結

**部署平台**:
- Railway: https://railway.app/
- Render: https://render.com/
- DigitalOcean: https://www.digitalocean.com/

**監控服務**:
- Sentry: https://sentry.io/
- Uptime Robot: https://uptimerobot.com/
- Firebase Console: https://console.firebase.google.com/

**DNS & CDN**:
- Cloudflare: https://www.cloudflare.com/
- Namecheap: https://www.namecheap.com/

**文件**:
- Laravel Deployment: https://laravel.com/docs/deployment
- Flutter Deployment: https://docs.flutter.dev/deployment

---

**版本**：v1.0
**最後更新**：2025-11-05
**文件擁有者**：HoldYourBeer Project

---

_Remember: Perfect is the enemy of done. Ship it! 🚀_
