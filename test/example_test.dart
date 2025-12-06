import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Build our app with required parameters
    await tester.pumpWidget(
      const MyApp(
        firebaseInitialized: false,
        firebaseError: null,
      ),
    );

    // Basic test - verify app doesn't crash
    expect(find.byType(MyApp), findsOneWidget);
  });

  group('Navigation Tests', () {
    testWidgets('App displays content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MyApp(
          firebaseInitialized: false,
          firebaseError: null,
        ),
      );

      // Wait for initial navigation
      await tester.pumpAndSettle();

      // Verify that some UI element is displayed
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

