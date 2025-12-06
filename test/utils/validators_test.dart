import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('invalid@'), isNotNull);
        expect(Validators.validateEmail('@domain.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('password123'), isNull);
        expect(Validators.validatePassword('123456'), isNull);
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });
    });

    group('validateConfirmPassword', () {
      test('should return null when passwords match', () {
        expect(
          Validators.validateConfirmPassword('password123', 'password123'),
          isNull,
        );
      });

      test('should return error when passwords do not match', () {
        expect(
          Validators.validateConfirmPassword('password123', 'password456'),
          isNotNull,
        );
      });

      test('should return error for empty confirm password', () {
        expect(
          Validators.validateConfirmPassword('', 'password123'),
          isNotNull,
        );
        expect(
          Validators.validateConfirmPassword(null, 'password123'),
          isNotNull,
        );
      });
    });

    group('validateTitle', () {
      test('should return null for valid title', () {
        expect(Validators.validateTitle('Valid Title'), isNull);
        expect(Validators.validateTitle('A' * 100), isNull);
      });

      test('should return error for empty title', () {
        expect(Validators.validateTitle(''), isNotNull);
        expect(Validators.validateTitle(null), isNotNull);
      });

      test('should return error for title too long', () {
        expect(Validators.validateTitle('A' * 101), isNotNull);
      });
    });

    group('validateDescription', () {
      test('should return null for valid description', () {
        expect(Validators.validateDescription('Valid description'), isNull);
        expect(Validators.validateDescription(null), isNull);
        expect(Validators.validateDescription('A' * 500), isNull);
      });

      test('should return error for description too long', () {
        expect(Validators.validateDescription('A' * 501), isNotNull);
      });
    });
  });
}

