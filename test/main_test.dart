import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/main.dart';
import 'package:flutter_project/providers/auth_provider.dart';
import 'package:flutter_project/providers/todo_provider.dart';

void main() {
  testWidgets('MyApp initializes correctly', (WidgetTester tester) async {
    // Skip this test as it requires Firebase initialization
    // In a real scenario, you would mock Firebase services
  }, skip: true);
}
