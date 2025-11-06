/// Google OAuth 認證設定
///
/// 此檔案包含 Google Sign-In 所需的 Client ID 設定
/// 實際的 Client ID 應該從環境變數或安全配置載入
class GoogleAuthConfig {
  // Android Client ID
  // 從 Google Cloud Console 取得
  // 格式: YOUR_PROJECT_ID.apps.googleusercontent.com
  static const String androidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue: '', // 請在此處填入您的 Android Client ID
  );

  // iOS Client ID
  // 從 Google Cloud Console 取得
  // 格式: YOUR_PROJECT_ID.apps.googleusercontent.com
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '', // 請在此處填入您的 iOS Client ID
  );

  // Web Client ID (用於 ID Token 驗證)
  // 此 Client ID 會被發送到後端進行驗證
  // 格式: YOUR_PROJECT_ID.apps.googleusercontent.com
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '', // 請在此處填入您的 Web Client ID
  );

  // Google Sign-In 請求的權限範圍
  static const List<String> scopes = [
    'email',
    'profile',
  ];

  /// 檢查是否已配置 Google 認證
  static bool get isConfigured {
    return androidClientId.isNotEmpty ||
        iosClientId.isNotEmpty ||
        webClientId.isNotEmpty;
  }
}
