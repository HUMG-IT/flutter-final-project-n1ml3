import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/main.dart';
import 'package:flutter_project/providers/auth_provider.dart';
import 'package:flutter_project/providers/todo_provider.dart';

void main() {
  testWidgets('MyApp initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TodoProvider()),
        ],
        child: const MyApp(
          firebaseInitialized: true,
        ),
      ),
    );

    // App should build without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
