# Google 帳號登入實作規劃

## 目標

在 HoldYourBeer Flutter 應用程式中實作 Google 帳號登入功能，讓使用者可以使用 Google 帳號快速註冊或登入。

## 整體架構

```
┌─────────────────────────────────────┐
│      Flutter App (前端)              │
│  ┌───────────────────────────────┐  │
│  │  Google Sign-In Button        │  │
│  └───────────────┬───────────────┘  │
│                  │                   │
│  ┌───────────────▼───────────────┐  │
│  │  google_sign_in package       │  │
│  │  (獲取 Google ID Token)        │  │
│  └───────────────┬───────────────┘  │
│                  │                   │
│  ┌───────────────▼───────────────┐  │
│  │  AuthService                  │  │
│  │  (發送 ID Token 到後端)       │  │
│  └───────────────┬───────────────┘  │
└──────────────────┼───────────────────┘
                   │ HTTP POST
                   │ /auth/google
                   │ {id_token: "..."}
┌──────────────────▼───────────────────┐
│      Laravel Backend (後端)          │
│  ┌───────────────────────────────┐  │
│  │  GoogleAuthController         │  │
│  └───────────────┬───────────────┘  │
│                  │                   │
│  ┌───────────────▼───────────────┐  │
│  │  Google API Client            │  │
│  │  (驗證 ID Token)               │  │
│  └───────────────┬───────────────┘  │
│                  │                   │
│  ┌───────────────▼───────────────┐  │
│  │  User Model                   │  │
│  │  (建立或更新用戶)              │  │
│  └───────────────┬───────────────┘  │
│                  │                   │
│  ┌───────────────▼───────────────┐  │
│  │  Laravel Sanctum              │  │
│  │  (產生 Access Token)           │  │
│  └───────────────┬───────────────┘  │
└──────────────────┼───────────────────┘
                   │
                   │ Response
                   │ {user: {...}, token: "..."}
                   │
┌──────────────────▼───────────────────┐
│      Flutter App                     │
│  儲存 Token，導航到主畫面            │
└──────────────────────────────────────┘
```

## 前端實作（Flutter）

### 1. 需要的套件

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  # 現有的套件...

  # Google Sign-In
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.3  # iOS Apple 登入（可選）
```

### 2. 設定檔案修改

#### Android 設定 (`android/app/build.gradle`)

```gradle
android {
    defaultConfig {
        // 添加
        minSdkVersion 21  // Google Sign-In 最低要求
    }
}

dependencies {
    // 添加 Google Play Services
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

#### iOS 設定 (`ios/Runner/Info.plist`)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 從 Google Cloud Console 取得 -->
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>

<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

### 3. 需要新增/修改的檔案

#### 3.1 服務層：`lib/core/services/google_auth_service.dart`

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // 從環境變數或設定檔載入
    clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID' : null,
  );

  // 登入並取得 ID Token
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken; // 返回 ID Token
    } catch (e) {
      throw Exception('Google 登入失敗: $e');
    }
  }

  // 登出
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // 檢查是否已登入
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
```

#### 3.2 認證服務擴充：`lib/core/services/auth_service.dart`

在現有的 `AuthService` 中添加：

```dart
// 在 AuthService 類別中添加
Future<LoginResponse> loginWithGoogle(String idToken) async {
  try {
    final response = await _apiClient.dio.post(
      '/auth/google',
      data: {'id_token': idToken},
    );

    if (response.statusCode == 200) {
      // 驗證回應
      final validationResult = _loginValidator.validateJson(response.data);
      if (!validationResult.isValid) {
        logger.e('Google login response validation failed');
        throw ValidationException(validationResult);
      }

      final loginResponse = LoginResponse.fromJson(response.data);

      // 儲存 token 和用戶資料
      await _apiClient.setAuthToken(loginResponse.token);
      await _storage.write(
        key: AppConstants.userDataKey,
        value: loginResponse.user.toJson().toString(),
      );

      return loginResponse;
    } else {
      throw Exception('Google 登入失敗：${response.statusMessage}');
    }
  } on DioException catch (e) {
    throw _handleDioError(e);
  }
}
```

#### 3.3 認證 Provider 擴充：`lib/core/auth/auth_provider.dart`

在 `AuthNotifier` 類別中添加：

```dart
// 在 AuthNotifier 類別中添加
final GoogleAuthService _googleAuthService = GoogleAuthService();

Future<void> loginWithGoogle() async {
  state = Loading();
  try {
    // 1. 使用 Google Sign-In 獲取 ID Token
    final idToken = await _googleAuthService.signInWithGoogle();

    if (idToken == null) {
      state = AuthError('Google 登入已取消');
      return;
    }

    // 2. 將 ID Token 發送到後端進行驗證
    final loginResponse = await _authService.loginWithGoogle(idToken);

    // 3. 更新狀態
    state = Authenticated(
      User.fromUserData(loginResponse.user),
      loginResponse.token,
    );
  } catch (e) {
    state = AuthError(e.toString());
  }
}
```

#### 3.4 UI 元件：`lib/features/auth/widgets/google_sign_in_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoogleSignInButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    Key? key,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                height: 24.h,
                width: 24.w,
              ),
        label: Text(
          isLoading ? '登入中...' : '使用 Google 帳號登入',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
```

#### 3.5 更新登入畫面：`lib/features/auth/screens/login_screen.dart`

在登入表單中添加 Google 登入按鈕：

```dart
// 在 _buildLoginForm() 中的登入按鈕後添加

SizedBox(height: 16.h),

// 分隔線
Row(
  children: [
    Expanded(child: Divider(color: BeerColors.gray400)),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        '或',
        style: TextStyle(
          fontSize: 14.sp,
          color: BeerColors.gray600,
        ),
      ),
    ),
    Expanded(child: Divider(color: BeerColors.gray400)),
  ],
),

SizedBox(height: 16.h),

// Google 登入按鈕
GoogleSignInButton(
  isLoading: authState is Loading,
  onPressed: () {
    ref.read(authStateProvider.notifier).loginWithGoogle();
  },
),
```

### 4. 環境變數配置

建立 `lib/core/config/google_auth_config.dart`：

```dart
class GoogleAuthConfig {
  // 從環境變數或安全配置載入
  static const String androidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue: 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com',
  );

  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
  );

  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );
}
```

### 5. 資源檔案

需要準備：
- `assets/images/google_logo.png` - Google 商標圖示

---

## 後端實作（Laravel）

### 1. 需要的套件

```bash
composer require google/apiclient
```

或使用 Laravel Socialite（更推薦）：

```bash
composer require laravel/socialite
composer require socialiteproviders/google
```

### 2. 環境變數設定（`.env`）

```env
# Google OAuth
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET
GOOGLE_REDIRECT_URI=https://your-domain.com/auth/google/callback
```

### 3. 設定檔（`config/services.php`）

```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],
```

### 4. 需要新增/修改的檔案

#### 4.1 資料庫遷移：新增 OAuth 相關欄位

```bash
php artisan make:migration add_google_auth_fields_to_users_table
```

檔案內容：

```php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('google_id')->nullable()->unique()->after('id');
        $table->string('avatar')->nullable()->after('email');
        $table->string('provider')->default('email')->after('password');
        $table->string('password')->nullable()->change(); // 密碼改為可選
    });
}

public function down()
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn(['google_id', 'avatar', 'provider']);
    });
}
```

#### 4.2 User Model 更新（`app/Models/User.php`）

```php
protected $fillable = [
    'name',
    'email',
    'password',
    'google_id',
    'avatar',
    'provider',
];

protected $hidden = [
    'password',
    'remember_token',
    'google_id', // 隱藏敏感資訊
];
```

#### 4.3 API 路由（`routes/api.php`）

```php
use App\Http\Controllers\Api\GoogleAuthController;

// Google 認證路由
Route::post('/auth/google', [GoogleAuthController::class, 'handleGoogleAuth']);
```

#### 4.4 控制器（`app/Http/Controllers/Api/GoogleAuthController.php`）

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Google_Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class GoogleAuthController extends Controller
{
    public function handleGoogleAuth(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        try {
            // 驗證 Google ID Token
            $googleUser = $this->verifyGoogleToken($request->id_token);

            if (!$googleUser) {
                return response()->json([
                    'message' => 'Invalid Google ID Token'
                ], 401);
            }

            // 檢查用戶是否存在
            $user = User::where('google_id', $googleUser['sub'])
                ->orWhere('email', $googleUser['email'])
                ->first();

            if ($user) {
                // 更新現有用戶的 Google 資訊
                if (!$user->google_id) {
                    $user->update([
                        'google_id' => $googleUser['sub'],
                        'avatar' => $googleUser['picture'] ?? null,
                    ]);
                }
            } else {
                // 建立新用戶
                $user = User::create([
                    'name' => $googleUser['name'],
                    'email' => $googleUser['email'],
                    'google_id' => $googleUser['sub'],
                    'avatar' => $googleUser['picture'] ?? null,
                    'provider' => 'google',
                    'password' => Hash::make(Str::random(32)), // 隨機密碼
                    'email_verified_at' => now(), // Google 已驗證 email
                ]);
            }

            // 產生 Sanctum Token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'user' => $user,
                'token' => $token,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Google authentication failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 驗證 Google ID Token
     */
    private function verifyGoogleToken($idToken)
    {
        $client = new Google_Client(['client_id' => config('services.google.client_id')]);

        try {
            $payload = $client->verifyIdToken($idToken);

            if ($payload) {
                return $payload;
            }

            return null;
        } catch (\Exception $e) {
            \Log::error('Google token verification failed: ' . $e->getMessage());
            return null;
        }
    }
}
```

#### 4.5 API 測試（`tests/Feature/GoogleAuthTest.php`）

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class GoogleAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_google_auth_creates_new_user()
    {
        // Mock Google ID Token verification
        // 這裡需要 mock Google_Client 的驗證過程

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'mock_id_token',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'user' => ['id', 'name', 'email'],
                'token',
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
            'provider' => 'google',
        ]);
    }
}
```

---

## Google Cloud Console 設定

### 1. 建立 Google Cloud 專案

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案或選擇現有專案
3. 名稱：`HoldYourBeer` 或自訂名稱

### 2. 啟用 Google+ API

1. 在左側選單選擇「API 和服務」→「資料庫」
2. 搜尋「Google+ API」並啟用
3. 或搜尋「Google Identity Toolkit API」並啟用

### 3. 建立 OAuth 2.0 憑證

1. 前往「API 和服務」→「憑證」
2. 點擊「建立憑證」→「OAuth 用戶端 ID」
3. 應用程式類型選擇：
   - **Android**：輸入套件名稱 + SHA-1 憑證指紋
   - **iOS**：輸入 Bundle ID
   - **Web 應用程式**：設定授權的 JavaScript 來源和重新導向 URI

### 4. 取得憑證資訊

建立完成後會獲得：
- **Client ID** (用戶端 ID)
- **Client Secret** (用戶端密鑰，僅後端使用)

### 5. 設定 Android SHA-1 指紋

```bash
# Debug keystore (開發用)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (正式版)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

複製 SHA-1 指紋到 Google Cloud Console 的 Android 應用程式設定中。

### 6. iOS 反向 Client ID

在 Google Cloud Console 取得 iOS Client ID 後，反向格式：
- Client ID: `123456789-abc.apps.googleusercontent.com`
- 反向格式: `com.googleusercontent.apps.123456789-abc`

將反向格式加入 iOS 專案的 `Info.plist`。

---

## 實作步驟總結

### Phase 1: 後端準備（Laravel）

1. ✅ 安裝 `google/apiclient` 套件
2. ✅ 建立資料庫遷移，新增 `google_id`, `avatar`, `provider` 欄位
3. ✅ 執行遷移：`php artisan migrate`
4. ✅ 更新 User Model 的 `$fillable` 和 `$hidden`
5. ✅ 建立 `GoogleAuthController`
6. ✅ 新增 API 路由 `/auth/google`
7. ✅ 設定環境變數（`.env`）
8. ✅ 測試 API 端點

### Phase 2: Google Cloud Console 設定

1. ✅ 建立 Google Cloud 專案
2. ✅ 啟用必要的 API
3. ✅ 建立 Android OAuth 憑證（包含 SHA-1）
4. ✅ 建立 iOS OAuth 憑證
5. ✅ 建立 Web OAuth 憑證（如果支援 Web）
6. ✅ 記錄所有 Client ID 和 Client Secret

### Phase 3: 前端準備（Flutter）

1. ✅ 安裝 `google_sign_in` 套件
2. ✅ 設定 Android：
   - 更新 `build.gradle`
   - 下載並放置 `google-services.json`（Firebase 專案需要）
3. ✅ 設定 iOS：
   - 更新 `Info.plist`
   - 加入 reversed Client ID
4. ✅ 建立 `GoogleAuthService`
5. ✅ 擴充 `AuthService` 新增 `loginWithGoogle` 方法
6. ✅ 擴充 `AuthNotifier` 新增 Google 登入方法
7. ✅ 建立 `GoogleSignInButton` 元件
8. ✅ 更新 `LoginScreen` 和 `RegisterScreen`
9. ✅ 添加 Google Logo 資源

### Phase 4: 測試與除錯

1. ✅ 測試 Android 平台 Google 登入
2. ✅ 測試 iOS 平台 Google 登入
3. ✅ 測試新用戶註冊流程
4. ✅ 測試現有用戶綁定 Google 帳號
5. ✅ 測試錯誤處理（網路錯誤、取消登入、無效 Token）
6. ✅ 驗證 Token 儲存和自動登入
7. ✅ 測試登出功能

### Phase 5: UI/UX 優化

1. ✅ 添加國際化支援（中文、英文）
2. ✅ 優化載入狀態顯示
3. ✅ 優化錯誤訊息顯示
4. ✅ 添加使用者頭像顯示（從 Google 獲取）
5. ✅ 優化 OAuth 流程的使用者體驗

---

## 注意事項與最佳實踐

### 安全性

1. **ID Token 驗證**：後端必須驗證 ID Token 的有效性和簽發者
2. **HTTPS Only**：生產環境必須使用 HTTPS
3. **Token 儲存**：使用 `FlutterSecureStorage` 安全儲存 Token
4. **敏感資訊**：不要將 Client Secret 放在前端程式碼中
5. **權限最小化**：只請求必要的 Google 權限範圍（email, profile）

### 錯誤處理

1. **網路錯誤**：提供清晰的錯誤訊息和重試機制
2. **取消登入**：處理使用者取消 Google 登入的情況
3. **Token 過期**：實作 Token 刷新機制
4. **帳號衝突**：處理 Email 已存在但使用不同登入方式的情況

### 使用者體驗

1. **載入指示**：顯示登入進度
2. **錯誤訊息**：提供友善的錯誤訊息（中英文）
3. **快速登入**：記住上次登入方式
4. **帳號綁定**：允許使用者綁定多種登入方式

### 測試策略

1. **單元測試**：測試 GoogleAuthService 的各個方法
2. **整合測試**：測試完整的 OAuth 流程
3. **UI 測試**：測試登入按鈕和使用者互動
4. **端對端測試**：測試前後端整合

### 合規性

1. **隱私政策**：明確告知使用者 Google 登入會收集哪些資料
2. **使用條款**：遵守 Google 的品牌指南和使用條款
3. **GDPR/個資法**：確保符合資料保護法規

---

## 參考資源

### Flutter / Dart

- [google_sign_in 套件文件](https://pub.dev/packages/google_sign_in)
- [Flutter Google Sign-In 官方教學](https://firebase.flutter.dev/docs/auth/social)

### Laravel

- [Laravel Socialite 文件](https://laravel.com/docs/10.x/socialite)
- [Google API Client Library for PHP](https://github.com/googleapis/google-api-php-client)

### Google Cloud

- [Google Identity Platform 文件](https://cloud.google.com/identity-platform/docs)
- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)

### API 設計

- [OAuth 2.0 RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

---

## 預期成果

完成實作後，使用者將能夠：

1. ✅ 在登入畫面點擊「使用 Google 帳號登入」按鈕
2. ✅ 選擇或授權 Google 帳號
3. ✅ 自動完成註冊/登入流程
4. ✅ 進入應用程式主畫面
5. ✅ 在個人資料頁面看到從 Google 同步的頭像和資訊
6. ✅ 可以正常登出並再次使用 Google 登入

---

## 時程估算

- **Phase 1 (後端準備)**：1-2 天
- **Phase 2 (Google Cloud 設定)**：半天
- **Phase 3 (前端準備)**：2-3 天
- **Phase 4 (測試與除錯)**：1-2 天
- **Phase 5 (UI/UX 優化)**：1 天

**總計**：約 5-8 個工作天

---

## 後續擴展可能性

1. **Apple Sign-In**：iOS 平台必須提供（App Store 要求）
2. **Facebook Login**：增加社群登入選項
3. **LINE Login**：亞洲地區常用
4. **帳號綁定**：允許同一用戶綁定多種登入方式
5. **自動登入**：記住上次登入方式並快速登入
6. **個人資料同步**：定期同步 Google 個人資料更新

---

## 版本記錄

- **v1.0** (2025-11-05)：初始規劃文件
- 預留給後續更新...
