import 'package:intl/intl.dart';
import 'app_logger.dart';

/// 時間處理工具類
/// 處理時區轉換和時間格式化
class DateTimeUtils {
  DateTimeUtils._();

  /// 將伺服器時間字串（UTC）轉換為本地DateTime
  static DateTime parseServerDateTime(String serverDateTimeString) {
    try {
      // 伺服器現在設定為 'UTC'，傳送的是 UTC 時間
      DateTime utcDateTime = DateTime.parse(serverDateTimeString);

      // 如果解析的時間不是UTC，則強制設為UTC
      if (!utcDateTime.isUtc) {
        utcDateTime = DateTime.parse('${serverDateTimeString}Z');
      }

      // 轉換為本地時間
      return utcDateTime.toLocal();
    } catch (e, stack) {
      logger.e('Error parsing server datetime', error: e, stackTrace: stack);
      // 如果解析失敗，返回當前時間
      return DateTime.now();
    }
  }

  /// 根據伺服器時區資訊智慧解析時間
  static DateTime parseServerDateTimeWithTimezone(String serverDateTimeString, String? serverTimezone) {
    try {
      DateTime serverDateTime = DateTime.parse(serverDateTimeString);

      // 如果有明確的伺服器時區資訊
      if (serverTimezone != null) {
        if (serverTimezone == 'UTC') {
          // 如果是UTC，直接轉換為本地時間
          if (!serverDateTime.isUtc) {
            serverDateTime = DateTime.parse('${serverDateTimeString}Z');
          }
          return serverDateTime.toLocal();
        } else {
          // 如果是其他時區，使用原有的邏輯
          // 這裡可以根據需要擴展支援更多時區
          return parseServerDateTime(serverDateTimeString);
        }
      }

      // 如果沒有時區資訊，使用預設邏輯
      return parseServerDateTime(serverDateTimeString);
    } catch (e, stack) {
      logger.e('Error parsing server datetime with timezone', error: e, stackTrace: stack);
      return DateTime.now();
    }
  }

  /// 格式化時間為用戶友好的顯示格式
  static String formatUserFriendly(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 如果是今天
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '今天 ${DateFormat('HH:mm').format(dateTime)}';
    }

    // 如果是昨天
    final yesterday = now.subtract(const Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    }

    // 如果是一週內
    if (difference.inDays < 7) {
      return '${difference.inDays}天前 ${DateFormat('HH:mm').format(dateTime)}';
    }

    // 如果是今年
    if (dateTime.year == now.year) {
      return DateFormat('M月d日 HH:mm').format(dateTime);
    }

    // 完整日期
    return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
  }

  /// 格式化時間為詳細顯示格式（包含時區資訊）
  static String formatDetailed(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final timeZoneOffset = dateTime.timeZoneOffset;

    String offsetString;
    if (timeZoneOffset.isNegative) {
      offsetString = '-${timeZoneOffset.abs().inHours.toString().padLeft(2, '0')}:${(timeZoneOffset.abs().inMinutes % 60).toString().padLeft(2, '0')}';
    } else {
      offsetString = '+${timeZoneOffset.inHours.toString().padLeft(2, '0')}:${(timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0')}';
    }

    return '${formatter.format(dateTime)} (UTC$offsetString)';
  }

  /// 格式化時間為相對時間顯示（幾分鐘前、幾小時前等）
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '剛才';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}個月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}年前';
    }
  }

  /// 將本地時間轉換為UTC字串（用於發送到伺服器）
  static String toServerDateTimeString(DateTime localDateTime) {
    return localDateTime.toUtc().toIso8601String();
  }

  /// 檢查時間是否為今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// 檢查時間是否為昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// 獲取時區名稱
  static String getTimeZoneName() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes % 60;

    if (hours >= 0) {
      return 'UTC+${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return 'UTC${hours.toString().padLeft(3, '0')}:${minutes.abs().toString().padLeft(2, '0')}';
    }
  }
}