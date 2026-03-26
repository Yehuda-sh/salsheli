// 📄 File: lib/repositories/user_repository.dart
//
// 🎯 Purpose: Interface לניהול משתמשים (Users)
//
// 📋 Features:
//     - תמיכה בנתוני Onboarding מורחבים (createUser)
//     - ניהול Exceptions אחיד (UserRepositoryException)
//     - תיעוד Intellisense מלא
//     - Real-time Updates (watchUser)
//
// 🏗️ Architecture: Repository Pattern
//     - Interface מופשט - שכבת ביניים בין Provider ל-Data Source
//     - מאפשר החלפת מימוש (Firebase / Mock) ללא שינוי UI
//
// 📋 Implementations:
//     - FirebaseUserRepository - מימוש הייצור (Firestore)
//
// 🔗 Related:
//     - lib/repositories/firebase_user_repository.dart - המימוש
//     - lib/providers/user_context.dart - Provider שמשתמש ב-repository
//     - lib/models/user_entity.dart - מבנה הנתונים
//
// 📜 History:
//     - v1.0: Interface ראשוני
//     - v2.0 (09/10/2025): הוספת docstrings, Onboarding fields
//     - v3.0 (22/02/2026): ארגון לפי קטגוריות, תיעוד מלא, סנכרון מול Implementation
//
// Version: 3.0
// Last Updated: 22/02/2026

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../models/user_entity.dart';

// ========================================
// Exceptions
// ========================================

/// Exception שנזרק כאשר יש שגיאה בפעולות Repository
///
/// מכיל הודעת שגיאה ו-cause אופציונלי (שגיאה מקורית).
///
/// Example:
/// ```dart
/// try {
///   await repository.fetchUser('abc123');
/// } catch (e) {
///   if (e is UserRepositoryException) {
///     print('שגיאה: ${e.message}, סיבה: ${e.cause}');
///   }
/// }
/// ```
class UserRepositoryException implements Exception {
  final String message;
  final Object? cause;

  UserRepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
      'UserRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

// ========================================
// Abstract Repository
// ========================================

/// Interface לניהול משתמשים
///
/// מגדיר חוזה לגישת נתונים למשתמשים במערכת.
/// כל מקור נתונים (Firebase, Mock) חייב לממש את הממשק הזה.
///
/// המתודות מחולקות לארבעה עולמות:
/// - **CRUD** - יצירה, קריאה, עדכון ומחיקה
/// - **Query** - חיפוש ושליפה
/// - **Real-time** - האזנה לשינויים
/// - **Utility** - פעולות עזר
abstract class UserRepository {
  // ========================================
  // CRUD - יצירה, קריאה, עדכון ומחיקה
  // ========================================

  /// טוען משתמש לפי מזהה ייחודי
  ///
  /// Path: `/users/{userId}`
  ///
  /// Parameters:
  ///   - [userId]: מזהה ייחודי (בד"כ מ-Firebase Auth)
  ///
  /// Returns: [UserEntity] אם נמצא, `null` אחרת
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// final user = await repository.fetchUser('abc123');
  /// if (user != null) print('נמצא: ${user.name}');
  /// ```
  Future<UserEntity?> fetchUser(String userId);

  /// יוצר משתמש חדש במערכת
  ///
  /// אם המשתמש כבר קיים - מחזיר את הקיים (לא יוצר כפילות).
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? phone,
    String? householdId,
    bool? seenOnboarding,
    String? profileImageUrl,
  });

  /// שומר או מעדכן משתמש (**עדכון מלא**)
  ///
  /// אם קיים - merge. אם לא - יוצר חדש.
  /// מעדכן גם `lastLoginAt` אוטומטית.
  ///
  /// Parameters:
  ///   - [user]: ה-[UserEntity] לשמירה
  ///
  /// Returns: המשתמש המעודכן (עם timestamps מהשרת)
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// final saved = await repository.saveUser(user);
  /// print('נשמר: ${saved.lastLoginAt}');
  /// ```
  ///
  /// See also: [updateProfile] לעדכון חלקי (שם/תמונה בלבד)
  Future<UserEntity> saveUser(UserEntity user);

  /// מעדכן פרופיל של משתמש (**עדכון חלקי**)
  ///
  /// מעדכן רק את השדות שנשלחו (לא null).
  /// שאר השדות נשארים ללא שינוי.
  /// **לא** מעדכן `lastLoginAt` (בניגוד ל-[saveUser]).
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש (חובה)
  ///   - [name]: שם חדש (אופציונלי)
  ///   - [avatar]: URL לתמונת פרופיל (אופציונלי)
  ///
  /// Returns: המשתמש המעודכן (לעדכון מצב מקומי ב-Provider)
  ///
  /// Throws: [UserRepositoryException] אם המשתמש לא קיים או שגיאת רשת
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.updateProfile(
  ///   userId: 'abc123',
  ///   name: 'יוני כהן החדש',
  /// );
  /// ```
  ///
  /// See also: [saveUser] לעדכון מלא של כל הפרופיל
  Future<UserEntity> updateProfile({
    required String userId,
    String? name,
    String? avatar,
  });

  /// מוחק משתמש מהמערכת
  ///
  /// מוחק את כל נתוני המשתמש. **פעולה בלתי הפיכה!**
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש למחיקה
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת/הרשאות
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteUser('abc123');
  /// ```
  ///
  /// See also: [clearAll] למחיקת כל המשתמשים (testing)
  Future<void> deleteUser(String userId);

  // ========================================
  // Query - חיפוש ושליפה
  // ========================================

  /// בודק האם משתמש קיים במערכת
  ///
  /// מהיר יותר מ-[fetchUser] - לא טוען את כל הנתונים.
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש
  ///
  /// Returns: `true` אם קיים, `false` אחרת
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת
  /// (לא להניח ש-`false` = לא קיים, יכול להיות שגיאה)
  ///
  /// Example:
  /// ```dart
  /// if (await repository.existsUser('abc123')) {
  ///   print('משתמש קיים');
  /// }
  /// ```
  Future<bool> existsUser(String userId);

  /// מחזיר רשימה של משתמשים
  ///
  /// Parameters:
  ///   - [householdId]: אם מסופק → רק משתמשי אותו משק בית.
  ///     אם `null` → **כל** המשתמשים (admin בלבד!)
  ///
  /// Returns: רשימת משתמשים (ריקה אם אין)
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת/DB
  ///
  /// Example:
  /// ```dart
  /// // משתמשי משק בית (מומלץ)
  /// final users = await repository.getAllUsers(householdId: 'house_demo');
  ///
  /// // כל המשתמשים (admin)
  /// final all = await repository.getAllUsers();
  /// ```
  Future<List<UserEntity>> getAllUsers({String? householdId});

  /// מחפש משתמש לפי כתובת אימייל
  ///
  /// האימייל **מנורמל** אוטומטית (toLowerCase + trim) לפני החיפוש.
  ///
  /// Parameters:
  ///   - [email]: כתובת אימייל לחיפוש
  ///   - [householdId]: אם מסופק → חיפוש רק במשק בית זה (מומלץ).
  ///     אם `null` → חיפוש גלובלי
  ///
  /// Returns: [UserEntity] אם נמצא, `null` אחרת
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת
  ///
  /// Example:
  /// ```dart
  /// // חיפוש במשק בית (מומלץ)
  /// final user = await repository.findByEmail(
  ///   'user@example.com', householdId: 'house_demo',
  /// );
  ///
  /// // חיפוש גלובלי (הרשמה)
  /// final existing = await repository.findByEmail('user@example.com');
  /// ```
  Future<UserEntity?> findByEmail(String email, {String? householdId});

  /// מחפש משתמש לפי מספר טלפון
  ///
  /// הטלפון **מנורמל** אוטומטית (ללא רווחים/מקפים) לפני החיפוש.
  ///
  /// Parameters:
  ///   - [phone]: מספר טלפון לחיפוש
  ///
  /// Returns: [UserEntity] אם נמצא, `null` אחרת
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת
  ///
  /// Example:
  /// ```dart
  /// final user = await repository.findByPhone('0501234567');
  /// if (user != null) print('נמצא: ${user.name}');
  /// ```
  Future<UserEntity?> findByPhone(String phone);

  // ========================================
  // Real-time - האזנה לשינויים
  // ========================================

  /// מאזין לשינויים במשתמש בזמן אמת
  ///
  /// Path: `/users/{userId}`
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש
  ///
  /// Returns: Stream של [UserEntity?] - `null` אם נמחק/לא קיים.
  /// מתעדכן אוטומטית כאשר הפרופיל משתנה.
  ///
  /// **חשוב:** לבטל את ה-subscription כשלא צריך!
  ///
  /// Example:
  /// ```dart
  /// final sub = repository.watchUser('abc123').listen((user) {
  ///   if (user != null) print('עודכן: ${user.name}');
  /// });
  /// // ...
  /// sub.cancel(); // חשוב!
  /// ```
  Stream<UserEntity?> watchUser(String userId);

  // ========================================
  // Utility - פעולות עזר
  // ========================================

  /// מעדכן את זמן ההתחברות האחרון
  ///
  /// מעדכן רק את `lastLoginAt` ל-`DateTime.now()`.
  ///
  /// Parameters:
  ///   - [userId]: מזהה המשתמש
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת
  ///
  /// Example:
  /// ```dart
  /// await repository.updateLastLogin('abc123');
  /// ```
  ///
  /// See also: [saveUser] מעדכן lastLoginAt אוטומטית
  Future<void> updateLastLogin(String userId);

  /// מעדכן שם קבוצה של משתמש
  ///
  /// אם [householdName] הוא null או ריק → מנקה את השדה ב-Firestore.
  ///
  /// Throws: [UserRepositoryException] אם הוולידציה נכשלה או שגיאת רשת
  Future<void> updateHouseholdName(String userId, String? householdName);

  /// מוחק את כל המשתמשים מהמערכת
  ///
  /// **פעולה בלתי הפיכה! מיועד לטסטים בלבד!**
  ///
  /// Parameters:
  ///   - [householdId]: אם מסופק → רק משתמשי אותו משק בית.
  ///     אם `null` → **כל** המשתמשים!
  ///
  /// Throws: [UserRepositoryException] בשגיאת רשת
  ///
  /// Example:
  /// ```dart
  /// // ניקוי משק בית (מומלץ)
  /// await repository.clearAll(householdId: 'house_demo');
  ///
  /// // ניקוי הכל (testing בלבד!)
  /// await repository.clearAll();
  /// ```
  @visibleForTesting
  Future<void> clearAll({String? householdId});
}
