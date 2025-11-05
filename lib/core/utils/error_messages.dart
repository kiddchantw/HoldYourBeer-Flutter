import 'package:dio/dio.dart';

/// User-friendly error messages utility
///
/// Converts technical errors into user-friendly Chinese messages
class ErrorMessages {
  ErrorMessages._();

  /// Get user-friendly error message from any exception
  static String getMessage(dynamic error, {String? context}) {
    if (error is DioException) {
      return _getDioErrorMessage(error, context: context);
    }

    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Exception:')) {
        return message.replaceFirst('Exception:', '').trim();
      }
      return message;
    }

    return '發生未知錯誤，請稍後再試';
  }

  /// Get user-friendly message for Dio exceptions
  static String _getDioErrorMessage(DioException error, {String? context}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '連線逾時，請檢查網路連線後重試';

      case DioExceptionType.sendTimeout:
        return '發送資料逾時，請稍後再試';

      case DioExceptionType.receiveTimeout:
        return '伺服器回應逾時，請稍後再試';

      case DioExceptionType.badResponse:
        return _getBadResponseMessage(error, context: context);

      case DioExceptionType.cancel:
        return '請求已取消';

      case DioExceptionType.connectionError:
        return '無法連線到伺服器\n請檢查：\n• 網路連線是否正常\n• 伺服器是否可訪問';

      case DioExceptionType.badCertificate:
        return '伺服器憑證驗證失敗，請聯絡管理員';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return '網路連線失敗，請檢查網路設定';
        }
        return '網路錯誤，請稍後再試';

      default:
        return '網路錯誤：${error.message ?? "未知錯誤"}';
    }
  }

  /// Get user-friendly message for bad HTTP responses
  static String _getBadResponseMessage(DioException error, {String? context}) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract server error message
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;

      // Handle Laravel validation errors
      if (statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        return '輸入資料有誤，請檢查後重試';
      }
    }

    // Status code specific messages
    switch (statusCode) {
      case 400:
        return serverMessage ?? '請求格式錯誤，請重試';

      case 401:
        return _get401Message(context, serverMessage);

      case 403:
        return serverMessage ?? '權限不足，無法執行此操作';

      case 404:
        return _get404Message(context, serverMessage);

      case 422:
        return serverMessage ?? '資料驗證失敗，請檢查輸入';

      case 429:
        return '請求過於頻繁，請稍後再試';

      case 500:
        return '伺服器錯誤，請稍後再試';

      case 502:
        return '伺服器無回應，請稍後再試';

      case 503:
        return '伺服器維護中，請稍後再試';

      case 504:
        return '伺服器逾時，請稍後再試';

      default:
        if (statusCode != null && statusCode >= 500) {
          return '伺服器錯誤 ($statusCode)，請稍後再試';
        }
        return serverMessage ?? '請求失敗 (HTTP $statusCode)';
    }
  }

  /// Get context-aware 401 message
  static String _get401Message(String? context, String? serverMessage) {
    if (context == 'login') {
      return '帳號或密碼錯誤';
    }
    return serverMessage ?? '登入已過期，請重新登入';
  }

  /// Get context-aware 404 message
  static String _get404Message(String? context, String? serverMessage) {
    switch (context) {
      case 'beer':
        return '找不到該啤酒記錄';
      case 'user':
        return '找不到該使用者';
      default:
        return serverMessage ?? '找不到請求的資源';
    }
  }

  /// Get simple error title for different error types
  static String getErrorTitle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '連線逾時';

        case DioExceptionType.connectionError:
          return '網路連線失敗';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) return '未授權';
          if (statusCode == 403) return '權限不足';
          if (statusCode == 404) return '找不到資源';
          if (statusCode == 422) return '資料驗證失敗';
          if (statusCode != null && statusCode >= 500) return '伺服器錯誤';
          return '請求失敗';

        default:
          return '操作失敗';
      }
    }

    return '錯誤';
  }

  /// Check if error is a network error (retriable)
  static bool isNetworkError(dynamic error) {
    if (error is! DioException) return false;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;

      case DioExceptionType.badResponse:
        // 5xx errors are considered network/server errors
        final statusCode = error.response?.statusCode;
        return statusCode != null && statusCode >= 500;

      default:
        return false;
    }
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    if (error is! DioException) return false;
    return error.response?.statusCode == 401;
  }
}
