import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'HoldYourBeer';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String hiveBoxName = 'holdyourbeer';
  static const String userBoxName = 'user_data';
  static const String beerBoxName = 'beer_data';

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // API Configuration
  static const String apiBaseUrl = 'http://holdyourbeer.test/api'; // Android emulator
  static const String webBaseUrl = 'http://holdyourbeer.test/api'; // Web/iOS simulator

  // Network Configuration
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}

class AppLocales {
  AppLocales._();

  static const Locale zhTW = Locale('zh', 'TW');
  static const Locale enUS = Locale('en', 'US');

  static const List<Locale> supportedLocales = [
    zhTW,
    enUS,
  ];

  static const Locale defaultLocale = zhTW;
}