import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/todo_model.dart';

void main() {
  group('Todo Model', () {
    test('should create a todo with default values', () {
      final todo = Todo(
        title: 'Test Todo',
        userId: 'user123',
      );

      expect(todo.title, 'Test Todo');
      expect(todo.userId, 'user123');
      expect(todo.isCompleted, false);
      expect(todo.priority, TodoPriority.medium);
      expect(todo.description, null);
      expect(todo.dueDate, null);
      expect(todo.id, isNotEmpty);
      expect(todo.createdAt, isA<DateTime>());
      expect(todo.updatedAt, isA<DateTime>());
    });

    test('should create a todo with all properties', () {
      final dueDate = DateTime.now().add(const Duration(days: 1));
      final todo = Todo(
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,
        priority: TodoPriority.high,
        dueDate: dueDate,
        userId: 'user123',
      );

      expect(todo.title, 'Test Todo');
      expect(todo.description, 'Test Description');
      expect(todo.isCompleted, true);
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, dueDate);
      expect(todo.userId, 'user123');
    });

    test('should create a copy with updated values', () {
      final original = Todo(
        title: 'Original',
        userId: 'user123',
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.userId, original.userId);
      expect(updated.id, original.id);
      expect(updated.updatedAt, isNot(original.updatedAt));
    });

    test('should convert to and from Firestore', () {
      final todo = Todo(
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,
        priority: TodoPriority.high,
        dueDate: DateTime(2024, 1, 1),
        userId: 'user123',
      );

      final firestoreData = todo.toFirestore();
      final restored = Todo.fromFirestore(firestoreData);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.description, todo.description);
      expect(restored.isCompleted, todo.isCompleted);
      expect(restored.priority, todo.priority);
      expect(restored.userId, todo.userId);
    });
  });
}

