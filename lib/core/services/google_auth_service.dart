import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../config/google_auth_config.dart';
import '../utils/app_logger.dart';

/// Google 認證服務
///
/// 處理 Google Sign-In 的相關操作，包括登入、登出、取得 ID Token 等
class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      scopes: GoogleAuthConfig.scopes,
      // Web 平台需要指定 clientId
      clientId: kIsWeb ? GoogleAuthConfig.webClientId : null,
    );
  }

  /// 使用 Google 帳號登入
  ///
  /// 返回 Google ID Token，如果失敗或使用者取消則返回 null
  Future<String?> signInWithGoogle() async {
    try {
      logger.d('Starting Google Sign-In');

      // 1. 觸發 Google 登入流程
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // 使用者取消登入
        logger.i('User cancelled Google Sign-In');
        return null;
      }

      logger.d('Google Sign-In account obtained: ${account.email}');

      // 2. 取得認證資訊
      final GoogleSignInAuthentication auth = await account.authentication;

      // 3. 返回 ID Token（用於後端驗證）
      if (auth.idToken == null) {
        logger.e('Failed to obtain ID Token from Google');
        throw Exception('無法取得 Google ID Token');
      }

      logger.d('Google ID Token obtained successfully');
      return auth.idToken;
    } catch (e, stack) {
      logger.e('Google Sign-In failed', error: e, stackTrace: stack);
      throw Exception('Google 登入失敗: $e');
    }
  }

  /// 登出 Google 帳號
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      logger.d('Google Sign-Out successful');
    } catch (e, stack) {
      logger.e('Google Sign-Out failed', error: e, stackTrace: stack);
      // 即使登出失敗也不拋出異常，因為本地清除更重要
    }
  }

  /// 檢查是否已登入 Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      logger.w('Failed to check Google sign-in status', error: e);
      return false;
    }
  }

  /// 靜默登入（如果之前已登入）
  ///
  /// 嘗試在背景中自動登入，不會顯示登入介面
  Future<String?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        logger.d('Silent sign-in failed - no cached account');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        logger.w('Silent sign-in obtained account but no ID token');
        return null;
      }

      logger.d('Silent sign-in successful');
      return auth.idToken;
    } catch (e, stack) {
      logger.w('Silent sign-in failed', error: e, stackTrace: stack);
      return null;
    }
  }

  /// 取得當前登入的 Google 帳號資訊
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      logger.w('Failed to get current Google user', error: e);
      return null;
    }
  }

  /// 中斷連結 Google 帳號
  ///
  /// 這會撤銷應用程式的存取權限
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      logger.d('Google account disconnected');
    } catch (e, stack) {
      logger.e('Failed to disconnect Google account', error: e, stackTrace: stack);
      throw Exception('中斷 Google 帳號連結失敗: $e');
    }
  }
}
