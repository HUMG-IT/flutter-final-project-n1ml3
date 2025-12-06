import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/todo_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    final locationName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(locationName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> scheduleTodoReminder(Todo todo) async {
    if (todo.dueDate == null || todo.isCompleted) {
      return;
    }

    // Schedule notification 1 hour before due date
    final reminderTime = todo.dueDate!.subtract(const Duration(hours: 1));

    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);
    
    await _notifications.zonedSchedule(
      todo.id.hashCode,
      'Todo sắp đến hạn: ${todo.title}',
      todo.description != null && todo.description!.isNotEmpty
          ? todo.description!
          : 'Todo này sẽ đến hạn trong 1 giờ',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Thông báo nhắc nhở cho todos sắp đến hạn',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDueDateNotification(Todo todo) async {
    if (todo.dueDate == null || todo.isCompleted) {
      return;
    }

    // Schedule notification at due date
    if (todo.dueDate!.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(todo.dueDate!, tz.local);
    
    await _notifications.zonedSchedule(
      todo.id.hashCode + 10000, // Different ID for due date notification
      'Todo đến hạn: ${todo.title}',
      todo.description != null && todo.description!.isNotEmpty
          ? todo.description!
          : 'Todo này đã đến hạn',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_due_dates',
          'Todo Due Dates',
          channelDescription: 'Thông báo khi todo đến hạn',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTodoNotification(String todoId) async {
    await _notifications.cancel(todoId.hashCode);
    await _notifications.cancel(todoId.hashCode + 10000);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

