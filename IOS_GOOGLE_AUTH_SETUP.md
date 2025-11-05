# iOS 平台 Google 認證設定指南

本文件說明如何在 iOS 平台上設定 Google Sign-In 功能。

## 前置條件

- 已完成 [Google Cloud Console 設定](GOOGLE_AUTH_IMPLEMENTATION_PLAN.md#google-cloud-console-設定)
- 已取得 iOS OAuth 2.0 Client ID
- 已在 macOS 上安裝 Xcode
- 擁有 Apple Developer 帳號（用於真機測試或發布）

---

## 步驟 1: 取得 iOS Client ID

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 選擇您的專案
3. 前往「API 和服務」→「憑證」
4. 點擊「建立憑證」→「OAuth 用戶端 ID」
5. 應用程式類型選擇「iOS」
6. 輸入您的 Bundle ID（例如：`com.holdyourbeer.app`）
7. 建立後，記錄以下資訊：
   - **Client ID**（格式：`123456789-abc.apps.googleusercontent.com`）
   - **iOS URL scheme**（反向 Client ID，格式：`com.googleusercontent.apps.123456789-abc`）

---

## 步驟 2: 更新 Info.plist

編輯 `ios/Runner/Info.plist`，在 `<dict>` 標籤內添加以下內容：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 替換為您的反向 Client ID -->
            <string>com.googleusercontent.apps.123456789-abc</string>
        </array>
    </dict>
</array>

<!-- 客戶端 ID（可選，用於某些場景） -->
<key>GIDClientID</key>
<string>123456789-abc.apps.googleusercontent.com</string>
```

**重要**：
- `CFBundleURLSchemes` 中的值是**反向** Client ID
- 如果 Client ID 是 `123456789-abc.apps.googleusercontent.com`
- 則反向格式為 `com.googleusercontent.apps.123456789-abc`

### 完整的 Info.plist 範例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>

    <key>CFBundleDisplayName</key>
    <string>HoldYourBeer</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <!-- Google Sign-In URL Scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.123456789-abc</string>
            </array>
        </dict>
    </array>

    <!-- Google Client ID -->
    <key>GIDClientID</key>
    <string>123456789-abc.apps.googleusercontent.com</string>

    <!-- 其他設定 -->
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <!-- ... 其他現有設定 -->
</dict>
</plist>
```

---

## 步驟 3: 設定 Bundle ID

確保您的 Bundle ID 與 Google Cloud Console 中註冊的一致。

### 3.1 在 Xcode 中設定

1. 開啟 `ios/Runner.xcworkspace`（**不是** `.xcodeproj`）
2. 選擇左側的 `Runner` 專案
3. 選擇 `Runner` target
4. 在「General」分頁中，確認「Bundle Identifier」
5. 確保與 Google Cloud Console 中的 Bundle ID 一致

### 3.2 檢查 Podfile 設定

編輯 `ios/Podfile`，確保包含：

```ruby
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

**重要**：最低 iOS 版本建議設為 12.0 或更高。

---

## 步驟 4: 安裝 CocoaPods 依賴

```bash
cd ios
pod install
cd ..
```

如果遇到問題，可以先清除快取：

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

---

## 步驟 5: 更新 GoogleAuthConfig

在 `lib/core/config/google_auth_config.dart` 中填入您的 iOS Client ID：

```dart
class GoogleAuthConfig {
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
  );

  // ... 其他設定
}
```

或者，使用環境變數：

```bash
flutter run --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

---

## 步驟 6: 測試

### 6.1 使用模擬器測試

```bash
flutter run -d "iPhone 15 Pro"
```

**注意**：某些 iOS 模擬器可能無法正常使用 Google Sign-In，建議使用真機測試。

### 6.2 使用真機測試

1. 連接 iPhone/iPad 到 Mac
2. 在 Xcode 中設定開發者帳號：
   - Xcode → Preferences → Accounts
   - 添加您的 Apple ID
3. 選擇您的裝置作為目標：
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

### 6.3 測試 Google 登入流程

1. 開啟應用程式
2. 前往登入或註冊畫面
3. 點擊「使用 Google 帳號登入」按鈕
4. Safari 或內建瀏覽器會開啟
5. 選擇 Google 帳號並授權
6. 應用程式會自動返回並完成登入

---

## 常見問題排解

### 問題 1: 錯誤 "No application found to handle URL scheme"

**原因**：`Info.plist` 中的 URL scheme 未正確設定。

**解決方案**：
1. 確認 `CFBundleURLSchemes` 中的反向 Client ID 正確
2. 確認格式為 `com.googleusercontent.apps.123456789-abc`
3. 清除專案並重新編譯：`flutter clean && flutter run`

### 問題 2: 錯誤 "GoogleSignIn: The operation couldn't be completed"

**原因**：Client ID 不正確或未設定。

**解決方案**：
1. 確認 `Info.plist` 中的 `GIDClientID` 正確
2. 確認 `GoogleAuthConfig` 中的 iOS Client ID 正確
3. 確認 Bundle ID 與 Google Cloud Console 設定一致

### 問題 3: 點擊按鈕後跳轉到 Safari 但無法返回應用程式

**原因**：URL scheme 註冊失敗或 AppDelegate 未正確設定。

**解決方案**：
1. 確認 `Info.plist` 中的 `CFBundleURLTypes` 設定正確
2. 檢查 Xcode 中的 URL Types 設定（Info 分頁）
3. 重新安裝應用程式

### 問題 4: 錯誤 "Bundle identifier doesn't match"

**原因**：Bundle ID 與 Google Cloud Console 設定不一致。

**解決方案**：
1. 在 Xcode 中檢查 Bundle Identifier
2. 前往 Google Cloud Console，確認 iOS OAuth 2.0 Client 的 Bundle ID
3. 確保兩者完全一致
4. 重新編譯應用程式

---

## 檢查清單

在完成設定後，請確認：

- [ ] 已在 Google Cloud Console 建立 iOS OAuth 2.0 Client
- [ ] 已取得 iOS Client ID 和反向 Client ID
- [ ] 已在 `Info.plist` 中添加 `CFBundleURLTypes`
- [ ] 已在 `Info.plist` 中添加 `GIDClientID`（可選）
- [ ] 反向 Client ID 格式正確（`com.googleusercontent.apps.xxx`）
- [ ] Bundle ID 與 Google Cloud Console 設定一致
- [ ] 已執行 `pod install`
- [ ] 已在 `GoogleAuthConfig` 中設定 iOS Client ID
- [ ] 已使用真機測試（模擬器可能不穩定）
- [ ] 成功執行 `flutter run` 並測試 Google 登入

---

## 發布到 App Store

當您準備發布應用程式到 App Store 時：

### 1. 設定簽名與能力

1. 在 Xcode 中開啟 `ios/Runner.xcworkspace`
2. 選擇 Runner target
3. 前往「Signing & Capabilities」分頁
4. 確認 Team 和 Bundle Identifier 設定正確
5. 啟用「Automatically manage signing」

### 2. 建置 Archive

```bash
# 方法 1: 使用 Flutter
flutter build ipa

# 方法 2: 使用 Xcode
# 1. Product → Archive
# 2. 等待建置完成
# 3. Organizer 視窗會自動開啟
```

### 3. 上傳到 App Store Connect

1. 在 Xcode Organizer 中選擇您的 Archive
2. 點擊「Distribute App」
3. 選擇「App Store Connect」
4. 跟隨指示完成上傳

### 4. 確認隱私權設定

Apple 要求應用程式說明資料使用方式。在 App Store Connect 中：

1. 前往「App Privacy」
2. 添加資料收集說明
3. 說明使用 Google Sign-In 收集的資料（Email、姓名、頭像等）

---

## 額外資源

- [Google Sign-In for iOS 官方文件](https://developers.google.com/identity/sign-in/ios)
- [google_sign_in Flutter 套件](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Apple Developer Portal](https://developer.apple.com/)
- [CocoaPods 官網](https://cocoapods.org/)

---

## iOS 特定注意事項

### URL Scheme 格式

確保理解正確的格式：
- **Client ID**: `123456789-abc.apps.googleusercontent.com`（完整格式）
- **Reversed Client ID**: `com.googleusercontent.apps.123456789-abc`（反向格式）
- 在 `Info.plist` 的 `CFBundleURLSchemes` 中使用**反向格式**
- 在 `Info.plist` 的 `GIDClientID` 中使用**完整格式**

### App Transport Security (ATS)

Google Sign-In 需要網路連線。如果您的應用程式有自訂的 ATS 設定，確保不會阻止 Google 伺服器的連線。

### Universal Links（可選）

如果您的應用程式支援 Universal Links，可能需要額外設定以避免與 Google Sign-In 的 URL scheme 衝突。

---

如有任何問題，請參考 [GOOGLE_AUTH_IMPLEMENTATION_PLAN.md](GOOGLE_AUTH_IMPLEMENTATION_PLAN.md) 或查閱官方文件。
