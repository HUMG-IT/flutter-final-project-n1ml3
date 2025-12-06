import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';

enum TodoPriority { low, medium, high }

@JsonSerializable()
class Todo {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  final TodoPriority priority;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'user_id')
  final String userId;

  Todo({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.userId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId ?? this.userId,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Todo.fromFirestore(Map<String, dynamic> data) {
    return Todo(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      isCompleted: data['is_completed'] as bool? ?? false,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TodoPriority.medium,
      ),
      dueDate: data['due_date'] != null
          ? DateTime.parse(data['due_date'] as String)
          : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      userId: data['user_id'] as String,
    );
  }
}

