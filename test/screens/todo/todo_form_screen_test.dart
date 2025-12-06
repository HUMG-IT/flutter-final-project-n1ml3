import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/screens/todo/todo_form_screen.dart';
import 'package:flutter_project/providers/todo_provider.dart';
import 'package:flutter_project/providers/auth_provider.dart';
import 'package:flutter_project/models/todo_model.dart';

void main() {
  group('TodoFormScreen', () {
    testWidgets('should display create form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => TodoProvider()),
            ],
            child: const TodoFormScreen(),
          ),
        ),
      );

      expect(find.text('Tạo Todo'), findsOneWidget);
      expect(find.text('Tiêu đề *'), findsOneWidget);
      expect(find.text('Mô tả'), findsOneWidget);
    });

    testWidgets('should display edit form with todo data',
        (WidgetTester tester) async {
      final todo = Todo(
        title: 'Test Todo',
        description: 'Test Description',
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => TodoProvider()),
            ],
            child: TodoFormScreen(todo: todo),
          ),
        ),
      );

      expect(find.text('Sửa Todo'), findsOneWidget);
      expect(find.text('Test Todo'), findsOneWidget);
    });

    testWidgets('should validate required title field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => TodoProvider()),
            ],
            child: const TodoFormScreen(),
          ),
        ),
      );

      // Try to submit without title
      await tester.tap(find.text('Tạo'));
      await tester.pump();

      expect(find.text('Vui lòng nhập tiêu đề'), findsOneWidget);
    });
  });
}

