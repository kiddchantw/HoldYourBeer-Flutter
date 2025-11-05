import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'shared/themes/app_theme.dart';
import 'core/auth/auth_provider.dart';
import 'core/i18n/locale_provider.dart';
import 'core/network/api_client.dart';
import 'core/utils/app_logger.dart';
import 'features/beer_tracking/models/beer_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Client
  ApiClient().initialize();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(BeerItemAdapter());
  logger.i('Hive adapters registered');

  // Open Hive boxes
  await Hive.openBox(AppConstants.hiveBoxName);
  await Hive.openBox(AppConstants.userBoxName);
  await Hive.openBox<BeerItem>(AppConstants.beerBoxName);
  logger.i('Hive boxes opened successfully');

  runApp(
    const ProviderScope(
      child: HoldYourBeerApp(),
    ),
  );
}

class HoldYourBeerApp extends ConsumerWidget {
  const HoldYourBeerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 mini 基準
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routerConfig: ref.watch(routerProvider),
          // Localization configuration
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocales.supportedLocales,
        );
      },
    );
  }
}