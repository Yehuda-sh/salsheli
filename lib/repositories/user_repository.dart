// 📄 File: lib/repositories/user_repository.dart
//
// 🇮🇱 Repository לניהול משתמשים - ממשק בלבד:
//     - מגדיר את ה-methods החובה שכל Repository צריך לממש
//     - משמש כ-contract בין Providers ל-Data Sources
//     - מאפשר החלפת מימושים (לדוגמה Firebase)
//
// 🇬🇧 User repository interface:
//     - Defines required methods for any Repository implementation
//     - Acts as a contract between Providers and Data Sources
//     - Allows swapping implementations (e.g., Firebase)

import '../models/user_entity.dart';

// === Exceptions ===
class UserRepositoryException implements Exception {
  final String message;
  final Object? cause;

  UserRepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
      'UserRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

// === Abstract Repository ===
abstract class UserRepository {
  Future<UserEntity?> fetchUser(String userId);
  Future<UserEntity> saveUser(UserEntity user);
  Future<void> deleteUser(String userId);

  // 🆕 פונקציות נוספות
  Future<bool> existsUser(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> findByEmail(String email);
  Future<void> updateLastLogin(String userId);
  Future<void> clearAll();
}


