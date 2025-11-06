# Android 平台 Google 認證設定指南

本文件說明如何在 Android 平台上設定 Google Sign-In 功能。

## 前置條件

- 已完成 [Google Cloud Console 設定](GOOGLE_AUTH_IMPLEMENTATION_PLAN.md#google-cloud-console-設定)
- 已取得 Android OAuth 2.0 Client ID
- 已在本機安裝 Java JDK 和 Android SDK

---

## 步驟 1: 更新 build.gradle

### 1.1 更新專案層級的 build.gradle

編輯 `android/build.gradle`：

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        // 如果使用 Firebase（可選）
        // classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 1.2 更新應用層級的 build.gradle

編輯 `android/app/build.gradle`：

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.holdyourbeer.app"  // 您的應用程式 ID
        minSdkVersion 21  // Google Sign-In 最低要求
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }

    // ... 其他設定
}

dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
    // 如果使用 Firebase（可選）
    // implementation platform('com.google.firebase:firebase-bom:32.3.1')
    // implementation 'com.google.firebase:firebase-auth'
}

// 如果使用 Firebase（可選）
// apply plugin: 'com.google.gms.google-services'
```

---

## 步驟 2: 取得 SHA-1 憑證指紋

Google Sign-In 需要您應用程式的 SHA-1 憑證指紋。

### 2.1 取得 Debug Keystore 的 SHA-1（開發用）

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

輸出範例：
```
Certificate fingerprints:
  MD5:  XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
  SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
  SHA256: ...
```

複製 **SHA1** 行的值。

### 2.2 取得 Release Keystore 的 SHA-1（正式版）

```bash
keytool -list -v \
  -keystore /path/to/your/release.keystore \
  -alias your-key-alias
```

系統會要求輸入 keystore 密碼，然後顯示憑證資訊。

**重要**：開發和正式版需要分別在 Google Cloud Console 中註冊。

---

## 步驟 3: 在 Google Cloud Console 註冊 SHA-1

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 選擇您的專案
3. 前往「API 和服務」→「憑證」
4. 找到您的 Android OAuth 2.0 Client ID，點擊編輯
5. 在「SHA-1 憑證指紋」欄位中，新增您的 SHA-1 值
6. 儲存變更

**提示**：可以同時註冊 debug 和 release 的 SHA-1。

---

## 步驟 4: 設定 AndroidManifest.xml

編輯 `android/app/src/main/AndroidManifest.xml`：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.holdyourbeer.app">

    <!-- 網路權限（通常已經包含） -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="HoldYourBeer"
        android:icon="@mipmap/ic_launcher">

        <!-- 您的其他設定 -->

        <activity
            android:name=".MainActivity"
            ...>
            <!-- 您的 intent-filter -->
        </activity>

        <!-- 不需要額外的 activity 或 meta-data -->
    </application>
</manifest>
```

---

## 步驟 5: 更新 GoogleAuthConfig

在 `lib/core/config/google_auth_config.dart` 中填入您的 Android Client ID：

```dart
class GoogleAuthConfig {
  static const String androidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue: 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com',
  );

  // ... 其他設定
}
```

或者，使用環境變數：

```bash
flutter run --dart-define=GOOGLE_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
```

---

## 步驟 6: 測試

### 6.1 清理並重新編譯

```bash
flutter clean
flutter pub get
flutter run
```

### 6.2 測試 Google 登入流程

1. 開啟應用程式
2. 前往登入或註冊畫面
3. 點擊「使用 Google 帳號登入」按鈕
4. 選擇 Google 帳號
5. 授權應用程式
6. 應該會成功登入並導航到主畫面

---

## 常見問題排解

### 問題 1: 錯誤 "Google Sign-In failed: DEVELOPER_ERROR"

**原因**：SHA-1 指紋不正確或未註冊。

**解決方案**：
1. 確認您使用的 keystore 的 SHA-1 已在 Google Cloud Console 中註冊
2. 確認應用程式的 package name 與 Google Cloud Console 中的一致
3. 等待幾分鐘讓 Google 伺服器更新設定
4. 清除應用程式快取：`flutter clean && flutter run`

### 問題 2: 錯誤 "PlatformException(sign_in_failed)"

**原因**：網路問題或 Client ID 不正確。

**解決方案**：
1. 檢查網路連線
2. 確認 `GoogleAuthConfig` 中的 Client ID 正確
3. 確認裝置上的 Google Play Services 已更新

### 問題 3: 點擊按鈕後沒有反應

**原因**：套件未正確安裝或 Google Play Services 未安裝。

**解決方案**：
1. 執行 `flutter pub get`
2. 確認測試裝置已安裝 Google Play Services
3. 使用實體裝置測試（某些模擬器可能沒有 Google Play Services）

### 問題 4: 錯誤 "The application's package name doesn't match"

**原因**：應用程式的 package name 與 Google Cloud Console 設定不一致。

**解決方案**：
1. 檢查 `android/app/build.gradle` 中的 `applicationId`
2. 確認與 Google Cloud Console 中的 package name 一致
3. 更新並重新編譯應用程式

---

## 檢查清單

在完成設定後，請確認：

- [ ] `android/app/build.gradle` 中的 `minSdkVersion >= 21`
- [ ] 已添加 `play-services-auth` 依賴
- [ ] 已取得 debug keystore 的 SHA-1 指紋
- [ ] 已取得 release keystore 的 SHA-1 指紋（如果要發布）
- [ ] 已在 Google Cloud Console 註冊所有 SHA-1 指紋
- [ ] 已在 `GoogleAuthConfig` 中設定 Android Client ID
- [ ] 測試裝置已安裝 Google Play Services
- [ ] 成功執行 `flutter run` 並測試 Google 登入

---

## 發布到 Google Play

當您準備發布應用程式到 Google Play 時：

1. **建立 Release Keystore**（如果還沒有）：
   ```bash
   keytool -genkey -v -keystore release.keystore -alias key -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **取得 Release SHA-1** 並在 Google Cloud Console 註冊

3. **更新 `android/key.properties`**：
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=key
   storeFile=/path/to/release.keystore
   ```

4. **編輯 `android/app/build.gradle`** 以使用 release keystore：
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

5. **建置 Release APK/AAB**：
   ```bash
   flutter build apk --release
   # 或
   flutter build appbundle --release
   ```

---

## 額外資源

- [Google Sign-In for Android 官方文件](https://developers.google.com/identity/sign-in/android)
- [google_sign_in Flutter 套件](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Android Keystore 管理](https://developer.android.com/studio/publish/app-signing)

---

如有任何問題，請參考 [GOOGLE_AUTH_IMPLEMENTATION_PLAN.md](GOOGLE_AUTH_IMPLEMENTATION_PLAN.md) 或查閱官方文件。
