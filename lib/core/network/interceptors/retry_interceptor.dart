import 'dart:math';
import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Retry interceptor with exponential backoff
///
/// Automatically retries failed requests for transient network errors
/// Uses exponential backoff strategy to avoid overwhelming the server
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry this error
    if (_shouldRetry(err) && retryCount < maxRetries) {
      final newRetryCount = retryCount + 1;
      err.requestOptions.extra['retryCount'] = newRetryCount;

      // Calculate exponential backoff delay: initialDelay * 2^retryCount
      final delayMs = initialDelay.inMilliseconds * pow(2, retryCount).toInt();
      final delay = Duration(milliseconds: delayMs);

      logger.w(
        'Retrying request (${newRetryCount}/$maxRetries) after ${delay.inMilliseconds}ms: ${err.requestOptions.path}',
      );

      // Wait before retrying
      await Future.delayed(delay);

      try {
        // Create a new Dio instance to retry the request
        final dio = Dio();

        // Copy all options from the failed request
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          responseType: err.requestOptions.responseType,
          contentType: err.requestOptions.contentType,
          extra: err.requestOptions.extra,
        );

        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
        );

        logger.i('Retry successful for: ${err.requestOptions.path}');
        return handler.resolve(response);
      } on DioException catch (e) {
        logger.e('Retry failed for: ${err.requestOptions.path}');
        // Continue to the next error handler
        return super.onError(e, handler);
      }
    }

    // No more retries or not retriable, pass to next handler
    return super.onError(err, handler);
  }

  /// Determine if an error should be retried
  bool _shouldRetry(DioException err) {
    // Don't retry on these error types
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true; // Network errors are retriable

      case DioExceptionType.badResponse:
        // Only retry on 5xx server errors (temporary server issues)
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500 && statusCode < 600;

      case DioExceptionType.cancel:
        return false; // Don't retry cancelled requests

      case DioExceptionType.badCertificate:
        return false; // Don't retry certificate errors

      case DioExceptionType.unknown:
        return true; // Retry unknown errors (might be network issues)

      default:
        return false;
    }
  }
}
