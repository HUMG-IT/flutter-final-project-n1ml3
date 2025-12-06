import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create a user with required fields', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, null);
      expect(user.photoUrl, null);
      expect(user.createdAt, isA<DateTime>());
      expect(user.updatedAt, isA<DateTime>());
    });

    test('should create a user with all properties', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should create a copy with updated values', () {
      final original = UserModel(
        id: 'user123',
        email: 'test@example.com',
      );

      final updated = original.copyWith(
        displayName: 'Updated Name',
      );

      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.displayName, 'Updated Name');
      expect(updated.updatedAt, isNot(original.updatedAt));
    });

    test('should convert to and from Firestore', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
      );

      final firestoreData = user.toFirestore();
      final restored = UserModel.fromFirestore(firestoreData);

      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.displayName, user.displayName);
      expect(restored.photoUrl, user.photoUrl);
    });
  });
}

