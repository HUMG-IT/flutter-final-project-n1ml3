import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/widgets/todo_item.dart';
import 'package:flutter_project/models/todo_model.dart';

void main() {
  group('TodoItem Widget', () {
    testWidgets('should display todo title', (WidgetTester tester) async {
      final todo = Todo(
        title: 'Test Todo',
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onTap: () {},
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Todo'), findsOneWidget);
    });

    testWidgets('should display completed todo with strikethrough',
        (WidgetTester tester) async {
      final todo = Todo(
        title: 'Completed Todo',
        userId: 'user123',
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onTap: () {},
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Completed Todo'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should call onToggle when checkbox is tapped',
        (WidgetTester tester) async {
      var toggleCalled = false;
      final todo = Todo(
        title: 'Test Todo',
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onTap: () {},
              onToggle: () {
                toggleCalled = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(toggleCalled, isTrue);
    });

    testWidgets('should call onDelete when delete button is tapped',
        (WidgetTester tester) async {
      var deleteCalled = false;
      final todo = Todo(
        title: 'Test Todo',
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onTap: () {},
              onToggle: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleteCalled, isTrue);
    });

    testWidgets('should display priority badge', (WidgetTester tester) async {
      final todo = Todo(
        title: 'High Priority Todo',
        userId: 'user123',
        priority: TodoPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoItem(
              todo: todo,
              onTap: () {},
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cao'), findsOneWidget);
    });
  });
}

