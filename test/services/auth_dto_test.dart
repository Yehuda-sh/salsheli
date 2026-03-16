// 📄 test/services/auth_dto_test.dart
// Tests for AuthUser, SocialLoginResult DTOs, and AuthException.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/services/auth_service.dart';

void main() {
  group('AuthUser DTO', () {
    test('construction with all fields', () {
      const user = AuthUser(
        uid: 'uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        phoneNumber: '+972501234567',
      );
      expect(user.uid, 'uid-123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.phoneNumber, '+972501234567');
    });

    test('construction with only uid', () {
      const user = AuthUser(uid: 'uid-minimal');
      expect(user.uid, 'uid-minimal');
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.phoneNumber, isNull);
    });
  });

  group('SocialLoginResult DTO', () {
    test('new user flag', () {
      const result = SocialLoginResult(
        uid: 'social-1',
        email: 'new@google.com',
        displayName: 'New User',
        isNewUser: true,
      );
      expect(result.isNewUser, true);
      expect(result.uid, 'social-1');
    });

    test('existing user flag', () {
      const result = SocialLoginResult(
        uid: 'social-2',
        email: 'existing@google.com',
        isNewUser: false,
      );
      expect(result.isNewUser, false);
    });

    test('nullable fields', () {
      const result = SocialLoginResult(
        uid: 'social-3',
        isNewUser: true,
      );
      expect(result.email, isNull);
      expect(result.displayName, isNull);
      expect(result.phoneNumber, isNull);
    });
  });

  group('AuthException', () {
    test('construction', () {
      const exception = AuthException(
        code: AuthErrorCode.userNotFound,
        message: 'משתמש לא נמצא',
      );
      expect(exception.code, AuthErrorCode.userNotFound);
      expect(exception.message, 'משתמש לא נמצא');
      expect(exception.originalError, isNull);
    });

    test('with original error', () {
      final original = Exception('Firebase error');
      final exception = AuthException(
        code: AuthErrorCode.networkError,
        message: 'שגיאת רשת',
        originalError: original,
      );
      expect(exception.originalError, original);
    });

    test('toString includes code and message', () {
      const exception = AuthException(
        code: AuthErrorCode.emailInUse,
        message: 'האימייל כבר בשימוש',
      );
      final str = exception.toString();
      expect(str, contains('emailInUse'));
      expect(str, contains('האימייל כבר בשימוש'));
    });

    test('fromFirebaseCode maps known codes', () {
      final exception = AuthException.fromFirebaseCode(
        'user-not-found',
        'Not found',
      );
      expect(exception.code, AuthErrorCode.userNotFound);
    });

    test('fromFirebaseCode maps unknown codes to unknown', () {
      final exception = AuthException.fromFirebaseCode(
        'some-future-error',
        'Unknown',
      );
      expect(exception.code, AuthErrorCode.unknown);
    });
  });

  group('AuthErrorCode - Firebase code mapping', () {
    final expectedMappings = {
      'user-not-found': AuthErrorCode.userNotFound,
      'wrong-password': AuthErrorCode.wrongPassword,
      'invalid-email': AuthErrorCode.invalidEmail,
      'email-already-in-use': AuthErrorCode.emailInUse,
      'weak-password': AuthErrorCode.weakPassword,
      'user-disabled': AuthErrorCode.userDisabled,
      'invalid-credential': AuthErrorCode.invalidCredential,
      'too-many-requests': AuthErrorCode.tooManyRequests,
      'operation-not-allowed': AuthErrorCode.operationNotAllowed,
      'requires-recent-login': AuthErrorCode.requiresRecentLogin,
      'network-request-failed': AuthErrorCode.networkError,
    };

    for (final entry in expectedMappings.entries) {
      test('${entry.key} → ${entry.value}', () {
        final exception = AuthException.fromFirebaseCode(entry.key, 'test');
        expect(exception.code, entry.value);
      });
    }
  });
}
