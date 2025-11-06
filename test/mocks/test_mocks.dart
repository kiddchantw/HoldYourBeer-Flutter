import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';

import 'package:holdyourbeer_flutter/core/network/api_client.dart';
import 'package:holdyourbeer_flutter/core/services/auth_service.dart';

// This file generates mocks for testing using Mockito's build_runner integration
// Run: flutter packages pub run build_runner build

@GenerateMocks([
  Dio,
  FlutterSecureStorage,
  ApiClient,
  AuthService,
])
void main() {
  // This is just a placeholder for the mock generator
}
