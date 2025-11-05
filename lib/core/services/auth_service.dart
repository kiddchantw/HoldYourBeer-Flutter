import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../models/auth_models.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';
import '../validation/validators/user_data_validator.dart';
import '../validation/validation_result.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginResponseValidator _loginValidator = LoginResponseValidator();
  final UserDataValidator _userValidator = UserDataValidator();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _apiClient.dio.post(
        '/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Validate API response
        final validationResult = _loginValidator.validateJson(response.data);
        if (!validationResult.isValid) {
          logger.e('Login response validation failed: ${validationResult.errorMessage}');
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
        throw Exception('登入失敗：${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('登入時發生未知錯誤：$e');
    }
  }

  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await _apiClient.dio.post(
        '/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        // Validate API response
        final validationResult = _loginValidator.validateJson(response.data);
        if (!validationResult.isValid) {
          logger.e('Register response validation failed: ${validationResult.errorMessage}');
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
        throw Exception('註冊失敗：${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('註冊時發生未知錯誤：$e');
    }
  }

  Future<void> logout() async {
    try {
      // 嘗試呼叫後端 logout API
      await _apiClient.dio.post('/logout');
    } catch (e, stack) {
      // 即使 API 調用失敗，也要清除本地資料
      logger.w('Logout API call failed', error: e, stackTrace: stack);
    } finally {
      // 清除本地儲存的認證資料
      await _apiClient.clearAuthToken();
    }
  }

  Future<UserData?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/user');
      if (response.statusCode == 200) {
        // Validate API response
        final validationResult = _userValidator.validateJson(response.data);
        if (!validationResult.isValid) {
          logger.w('User data validation failed: ${validationResult.errorMessage}');
          return null;
        }

        return UserData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserData> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/profile', data: {
        'name': name,
        'email': email,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];

        // Validate user data
        final validationResult = _userValidator.validateJson(userData);
        if (!validationResult.isValid) {
          logger.e('User data validation failed: ${validationResult.errorMessage}');
          throw ValidationException(validationResult);
        }

        return UserData.fromJson(userData);
      }
      throw Exception('更新個人資料失敗');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.put('/password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      });

      if (response.statusCode != 200) {
        throw Exception('變更密碼失敗');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAuthToken();
    return token != null;
  }

  Future<String?> getAuthToken() async {
    return await _apiClient.getAuthToken();
  }

  Future<UserData?> getStoredUserData() async {
    try {
      final userDataString = await _storage.read(key: AppConstants.userDataKey);
      if (userDataString != null) {
        // 這裡需要解析 JSON 字串，但為了簡化先返回 null
        // 實際使用時可以用 json.decode 解析
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('連線超時，請檢查網路連線');
      case DioExceptionType.receiveTimeout:
        return Exception('接收資料超時，請稍後再試');
      case DioExceptionType.sendTimeout:
        return Exception('發送資料超時，請稍後再試');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 422 && data != null) {
          // 驗證錯誤
          final errors = data['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return Exception(firstError.first.toString());
            }
          }
          return Exception('輸入資料有誤，請檢查後重試');
        } else if (statusCode == 401) {
          return Exception('帳號或密碼錯誤');
        } else if (statusCode == 500) {
          return Exception('伺服器錯誤，請稍後再試');
        }
        return Exception('請求失敗：HTTP $statusCode');
      case DioExceptionType.cancel:
        return Exception('請求已取消');
      case DioExceptionType.connectionError:
        return Exception('網路連線失敗，請檢查網路設定');
      default:
        return Exception('網路錯誤：${error.message}');
    }
  }
}