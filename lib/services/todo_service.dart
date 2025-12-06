import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  String get _userId => FirebaseService.auth.currentUser?.uid ?? '';

  Stream<List<Todo>> getTodosStream() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    // Use stream without orderBy to avoid index requirement
    // Sort in the map function instead
    return _firestore
        .collection(AppConstants.todosCollection)
        .where('user_id', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final todos = snapshot.docs
          .map((doc) => Todo.fromFirestore(doc.data()))
          .toList();
      
      // Sort by created_at descending
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return todos;
    });
  }

  Future<List<Todo>> getTodos() async {
    try {
      if (_userId.isEmpty) {
        return [];
      }

      // Try with orderBy first (requires index)
      try {
        final snapshot = await _firestore
            .collection(AppConstants.todosCollection)
            .where('user_id', isEqualTo: _userId)
            .orderBy('created_at', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => Todo.fromFirestore(doc.data()))
            .toList();
      } catch (e) {
        // If index error, fallback to query without orderBy and sort in code
        if (e.toString().contains('index') || e.toString().contains('failed-precondition')) {
          final snapshot = await _firestore
              .collection(AppConstants.todosCollection)
              .where('user_id', isEqualTo: _userId)
              .get();

          final todos = snapshot.docs
              .map((doc) => Todo.fromFirestore(doc.data()))
              .toList();

          // Sort by created_at descending
          todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return todos;
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Error getting todos: $e');
    }
  }

  Future<Todo> getTodoById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.todosCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception(AppConstants.errorNotFound);
      }

      return Todo.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Error getting todo: $e');
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    try {
      if (_userId.isEmpty) {
        throw Exception(AppConstants.errorAuth);
      }

      final todoWithUserId = todo.copyWith(userId: _userId);
      final data = todoWithUserId.toFirestore();

      await _firestore
          .collection(AppConstants.todosCollection)
          .doc(todoWithUserId.id)
          .set(data);

      // Schedule notifications if due date is set
      if (todoWithUserId.dueDate != null) {
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.scheduleTodoReminder(todoWithUserId);
        await notificationService.scheduleDueDateNotification(todoWithUserId);
      }

      return todoWithUserId;
    } catch (e) {
      throw Exception('Error creating todo: $e');
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    try {
      if (_userId.isEmpty) {
        throw Exception(AppConstants.errorAuth);
      }

      if (todo.userId != _userId) {
        throw Exception(AppConstants.errorPermission);
      }

      final updatedTodo = todo.copyWith();
      final data = updatedTodo.toFirestore();

      await _firestore
          .collection(AppConstants.todosCollection)
          .doc(todo.id)
          .update(data);

      // Update notifications
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.cancelTodoNotification(todo.id);
      
      if (updatedTodo.dueDate != null && !updatedTodo.isCompleted) {
        await notificationService.scheduleTodoReminder(updatedTodo);
        await notificationService.scheduleDueDateNotification(updatedTodo);
      }

      return updatedTodo;
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      if (_userId.isEmpty) {
        throw Exception(AppConstants.errorAuth);
      }

      final todo = await getTodoById(id);
      if (todo.userId != _userId) {
        throw Exception(AppConstants.errorPermission);
      }

      // Cancel notifications
      final notificationService = NotificationService();
      await notificationService.cancelTodoNotification(id);

      await _firestore
          .collection(AppConstants.todosCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }

  Future<void> toggleTodoComplete(String id) async {
    try {
      final todo = await getTodoById(id);
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await updateTodo(updatedTodo);
    } catch (e) {
      throw Exception('Error toggling todo: $e');
    }
  }

  Future<List<Todo>> searchTodos(String query) async {
    try {
      if (_userId.isEmpty) {
        return [];
      }

      final todos = await getTodos();
      final lowerQuery = query.toLowerCase();

      return todos.where((todo) {
        return todo.title.toLowerCase().contains(lowerQuery) ||
            (todo.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error searching todos: $e');
    }
  }

  Future<List<Todo>> filterTodos({
    bool? isCompleted,
    TodoPriority? priority,
  }) async {
    try {
      if (_userId.isEmpty) {
        return [];
      }

      // Get all todos for user first, then filter and sort in code
      // This avoids needing multiple composite indexes
      final snapshot = await _firestore
          .collection(AppConstants.todosCollection)
          .where('user_id', isEqualTo: _userId)
          .get();

      var todos = snapshot.docs
          .map((doc) => Todo.fromFirestore(doc.data()))
          .toList();

      // Apply filters
      if (isCompleted != null) {
        todos = todos.where((todo) => todo.isCompleted == isCompleted).toList();
      }

      if (priority != null) {
        todos = todos.where((todo) => todo.priority == priority).toList();
      }

      // Sort by created_at descending
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return todos;
    } catch (e) {
      throw Exception('Error filtering todos: $e');
    }
  }
}

