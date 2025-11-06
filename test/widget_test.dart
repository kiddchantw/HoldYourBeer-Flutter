// Widget tests for HoldYourBeer Flutter app
// These tests verify that the app initializes correctly and routing works

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:holdyourbeer_flutter/main.dart';
import 'package:holdyourbeer_flutter/core/auth/auth_provider.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('App should initialize without crashing', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify that the app widget exists
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('Unauthenticated user should be redirected to login screen',
        (WidgetTester tester) async {
      // Create a container with overridden auth state
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => AuthNotifier()),
        ],
      );

      // Build the app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // Wait for navigation and initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify login screen elements are present
      // Looking for common login screen widgets
      expect(
        find.byType(TextField).evaluate().isNotEmpty ||
            find.byType(TextFormField).evaluate().isNotEmpty,
        true,
        reason: 'Login screen should contain text input fields',
      );

      // Clean up
      container.dispose();
    });

    testWidgets('App should use Material design', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify MaterialApp is being used
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('App Configuration Tests', () {
    testWidgets('App should have proper theme configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify theme exists
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('App should support localization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify localization delegates exist
      expect(materialApp.localizationsDelegates, isNotEmpty);
    });
  });
}
