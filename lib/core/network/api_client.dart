import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import 'interceptors/retry_interceptor.dart';
import '../utils/app_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio();

    // 基礎設定
    _dio.options = BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加攔截器（順序很重要！）
    // 1. Retry Interceptor - 第一個處理錯誤重試
    _dio.interceptors.add(RetryInterceptor(
      maxRetries: 3,
      initialDelay: Duration(milliseconds: 500),
    ));

    // 2. Auth Interceptor - 添加 token 和處理 401
    _dio.interceptors.add(_createAuthInterceptor());

    // 3. Logging Interceptor - 最後記錄所有請求（僅 debug 模式）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    logger.i('ApiClient initialized with retry interceptor');
  }

  String _getBaseUrl() {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) {
      return AppConstants.webBaseUrl;
    }
    return AppConstants.apiBaseUrl;
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自動添加 Bearer token
        final token = await _storage.read(key: AppConstants.authTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 處理 401 未授權錯誤
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: AppConstants.authTokenKey);
          await _storage.delete(key: AppConstants.userDataKey);
        }
        handler.next(error);
      },
    );
  }

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: AppConstants.authTokenKey);
    await _storage.delete(key: AppConstants.userDataKey);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }
}