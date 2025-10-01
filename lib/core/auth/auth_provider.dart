import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../network/api_client.dart';
import '../../features/navigation/screens/main_scaffold_new.dart';
import '../../features/profile/screens/privacy_settings_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/tasting_history/screens/tasting_history_screen.dart';

// 用戶模型 - 基於 API 回應
class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
  });

  factory User.fromUserData(UserData userData) {
    return User(
      id: userData.id,
      name: userData.name,
      email: userData.email,
      emailVerifiedAt: userData.emailVerifiedAt,
    );
  }
}

// Auth State Classes
abstract class AuthState {}

class Loading extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String token;

  Authenticated(this.user, this.token);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(Loading()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // 先檢查本地是否有 token，如果有則設為已認證狀態
        // 不在初始化時呼叫 API，避免連線問題
        final token = await _authService.getAuthToken();
        if (token != null) {
          // 建立一個臨時用戶資料，實際資料會在需要時從 API 獲取
          final tempUser = User(
            id: 0,
            name: 'Loading...',
            email: 'loading@example.com',
          );
          state = Authenticated(tempUser, token);

          // 背景中嘗試更新用戶資料
          _updateUserDataInBackground();
        } else {
          state = Unauthenticated();
        }
      } else {
        state = Unauthenticated();
      }
    } catch (e) {
      state = Unauthenticated();
    }
  }

  Future<void> _updateUserDataInBackground() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        final token = await _authService.getAuthToken();
        state = Authenticated(
          User.fromUserData(userData),
          token ?? '',
        );
      }
    } catch (e) {
      // 如果背景更新失敗，保持當前狀態，不做任何處理
      print('Background user data update failed: $e');
    }
  }

  Future<void> login(String email, String password) async {
    state = Loading();
    try {
      final loginResponse = await _authService.login(email, password);
      state = Authenticated(
        User.fromUserData(loginResponse.user),
        loginResponse.token,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = Loading();
    try {
      final registerResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = Authenticated(
        User.fromUserData(registerResponse.user),
        registerResponse.token,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // 即使 logout API 失敗，也要更新狀態
      print('Logout error: $e');
    } finally {
      state = Unauthenticated();
    }
  }

  void clearError() {
    if (state is AuthError) {
      state = Unauthenticated();
    }
  }
}

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState is Authenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/beers/:id/history',
        builder: (context, state) {
          final beerId = state.pathParameters['id']!;
          final title = state.uri.queryParameters['title'];
          return TastingHistoryScreen(beerId: beerId, title: title);
        },
      ),
    ],
  );
});