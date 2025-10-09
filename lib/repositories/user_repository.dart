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
//
// 📦 Dependencies:
//     - models/user_entity.dart - מודל המשתמש
//
// 🔗 Related:
//     - firebase_user_repository.dart - מימוש Firebase
//     - user_context.dart - Provider שמשתמש ב-interface
//
// 🎯 Usage:
//     ```dart
//     // יצירת Repository
//     final repository = FirebaseUserRepository();
//     
//     // שימוש ב-UserContext
//     final userContext = UserContext(
//       repository: repository,
//       authService: authService,
//     );
//     ```
//
// 📝 Version: 2.0 - Full Documentation
// 📅 Updated: 09/10/2025

import '../models/user_entity.dart';

// === Exceptions ===

/// Exception שנזרק כאשר יש שגיאה בפעולות Repository
/// 
/// מכיל הודעת שגיאה ו-cause אופציונלי (שגיאה מקורית)
/// 
/// Example:
/// ```dart
/// try {
///   await repository.fetchUser('abc123');
/// } catch (e) {
///   if (e is UserRepositoryException) {
///     print('שגיאה: ${e.message}');
///     print('סיבה: ${e.cause}');
///   }
/// }
/// ```
class UserRepositoryException implements Exception {
  /// הודעת השגיאה
  final String message;
  
  /// השגיאה המקורית (אם קיימת)
  final Object? cause;

  UserRepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
      'UserRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

// === Abstract Repository ===

/// ממשק Repository לניהול משתמשים
/// 
/// מגדיר את כל הפעולות הנדרשות לניהול משתמשים במערכת.
/// כל מימוש של Repository (Firebase, SQLite, וכו') צריך לממש ממשק זה.
/// 
/// **CRUD Operations:**
/// - [fetchUser] - קריאת משתמש
/// - [saveUser] - יצירה/עדכון משתמש
/// - [deleteUser] - מחיקת משתמש
/// 
/// **Query Operations:**
/// - [existsUser] - בדיקת קיום משתמש
/// - [getAllUsers] - קבלת כל המשתמשים
/// - [findByEmail] - חיפוש לפי אימייל
/// 
/// **Utility Operations:**
/// - [updateLastLogin] - עדכון זמן התחברות אחרון
/// - [clearAll] - ניקוי כל המשתמשים (לטסטים)
/// 
/// Example:
/// ```dart
/// class FirebaseUserRepository implements UserRepository {
///   @override
///   Future<UserEntity?> fetchUser(String userId) async {
///     // מימוש...
///   }
///   
///   // ... שאר ה-methods
/// }
/// ```
abstract class UserRepository {
  /// טוען משתמש לפי מזהה ייחודי
  /// 
  /// מחזיר [UserEntity] אם המשתמש נמצא, אחרת `null`.
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - שגיאת רשת
  /// - שגיאת מסד נתונים
  /// - שגיאת המרת נתונים
  /// 
  /// Example:
  /// ```dart
  /// final user = await repository.fetchUser('abc123');
  /// if (user != null) {
  ///   print('נמצא: ${user.name}');
  /// } else {
  ///   print('משתמש לא קיים');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [findByEmail] - חיפוש לפי אימייל
  /// - [existsUser] - בדיקת קיום בלבד
  Future<UserEntity?> fetchUser(String userId);

  /// שומר או מעדכן משתמש במערכת
  /// 
  /// אם המשתמש קיים - מעדכן את הפרטים (merge).
  /// אם המשתמש לא קיים - יוצר חדש.
  /// 
  /// מחזיר את המשתמש המעודכן (עם `lastLoginAt` חדש).
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - שגיאת רשת
  /// - שגיאת מסד נתונים
  /// - נתונים לא תקינים
  /// 
  /// Example:
  /// ```dart
  /// final user = UserEntity.newUser(
  ///   id: 'abc123',
  ///   email: 'user@example.com',
  ///   name: 'יוני כהן',
  /// );
  /// 
  /// final savedUser = await repository.saveUser(user);
  /// print('נשמר: ${savedUser.lastLoginAt}');
  /// ```
  /// 
  /// See also:
  /// - [updateLastLogin] - עדכון זמן התחברות בלבד
  Future<UserEntity> saveUser(UserEntity user);

  /// מוחק משתמש מהמערכת
  /// 
  /// מוחק את כל הנתונים של המשתמש מ-Repository.
  /// 
  /// ⚠️ **אזהרה:** פעולה זו בלתי הפיכה!
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - משתמש לא קיים
  /// - שגיאת רשת
  /// - שגיאת הרשאות
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await repository.deleteUser('abc123');
  ///   print('משתמש נמחק בהצלחה');
  /// } catch (e) {
  ///   print('שגיאה במחיקה: $e');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [clearAll] - מחיקת כל המשתמשים
  Future<void> deleteUser(String userId);

  /// בודק האם משתמש קיים במערכת
  /// 
  /// מחזיר `true` אם המשתמש קיים, `false` אחרת.
  /// 
  /// פעולה זו מהירה יותר מ-[fetchUser] כי לא טוענת את כל הנתונים.
  /// 
  /// מחזיר `false` גם במקרה של שגיאה (במקום לזרוק Exception).
  /// 
  /// Example:
  /// ```dart
  /// if (await repository.existsUser('abc123')) {
  ///   print('משתמש קיים');
  /// } else {
  ///   print('משתמש לא קיים');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [fetchUser] - קבלת נתוני המשתמש המלאים
  Future<bool> existsUser(String userId);

  /// מחזיר רשימה של כל המשתמשים במערכת
  /// 
  /// ⚠️ **אזהרה:** פעולה זו יכולה להיות איטית עם הרבה משתמשים!
  /// 
  /// שימושי בעיקר ל:
  /// - מסכי ניהול (admin)
  /// - דוחות ואנליטיקה
  /// - טסטים ו-debugging
  /// 
  /// מחזיר רשימה ריקה אם אין משתמשים.
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאת רשת/DB.
  /// 
  /// Example:
  /// ```dart
  /// final users = await repository.getAllUsers();
  /// print('סה"כ משתמשים: ${users.length}');
  /// 
  /// for (final user in users) {
  ///   print('${user.name} - ${user.email}');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [findByEmail] - חיפוש משתמש ספציפי
  Future<List<UserEntity>> getAllUsers();

  /// מחפש משתמש לפי כתובת אימייל
  /// 
  /// מחזיר [UserEntity] אם נמצא משתמש עם האימייל, אחרת `null`.
  /// 
  /// ⚠️ **חשוב:** האימייל מנורמל (toLowerCase + trim) לפני החיפוש.
  /// 
  /// שימושי ל:
  /// - בדיקת אימייל קיים בהרשמה
  /// - שחזור חשבון
  /// - חיפוש משתמש במסך ניהול
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - שגיאת רשת
  /// - אימייל ריק (`ArgumentError`)
  /// 
  /// Example:
  /// ```dart
  /// final user = await repository.findByEmail('user@example.com');
  /// if (user != null) {
  ///   print('משתמש קיים: ${user.id}');
  /// } else {
  ///   print('אימייל פנוי לרישום');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [existsUser] - בדיקת קיום לפי ID
  Future<UserEntity?> findByEmail(String email);

  /// מעדכן את זמן ההתחברות האחרון של משתמש
  /// 
  /// מעדכן רק את השדה `lastLoginAt` ל-DateTime.now().
  /// 
  /// שימושי ל:
  /// - מעקב אחרי פעילות משתמשים
  /// - סטטיסטיקות
  /// - התנתקות אוטומטית אחרי תקופה
  /// 
  /// ⚠️ **הערה:** [saveUser] מעדכן גם את lastLoginAt אוטומטית.
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאה.
  /// 
  /// Example:
  /// ```dart
  /// // אחרי login מוצלח:
  /// await repository.updateLastLogin(userId);
  /// print('זמן התחברות עודכן');
  /// ```
  /// 
  /// See also:
  /// - [saveUser] - עדכון כל הפרופיל (כולל lastLoginAt)
  Future<void> updateLastLogin(String userId);

  /// מוחק את כל המשתמשים מהמערכת
  /// 
  /// ⚠️ **אזהרה קריטית:** פעולה זו בלתי הפיכה!
  /// 
  /// שימושי **רק** ל:
  /// - איפוס מסד נתונים בטסטים
  /// - סביבת פיתוח (dev/staging)
  /// - סקריפטים של ניקוי
  /// 
  /// ❌ **אסור להשתמש ב-Production!**
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאה.
  /// 
  /// Example:
  /// ```dart
  /// // בטסטים בלבד!
  /// await repository.clearAll();
  /// print('כל המשתמשים נמחקו');
  /// 
  /// // בדיקה
  /// final users = await repository.getAllUsers();
  /// assert(users.isEmpty);
  /// ```
  /// 
  /// See also:
  /// - [deleteUser] - מחיקת משתמש בודד
  Future<void> clearAll();
}
