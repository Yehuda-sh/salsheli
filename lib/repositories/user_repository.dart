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
  /// 💡 **Dynamic filtering:** מקבל פרמטר אופציונלי [householdId]:
  /// - אם [householdId] מסופק → מחזיר רק משתמשים של אותו משק בית
  /// - אם [householdId] הוא null → מחזיר **כל** המשתמשים (admin בלבד!)
  /// 
  /// ⚠️ **אזהרה:** שימוש ללא householdId יכול להיות איטי עם הרבה משתמשים!
  /// 
  /// שימושי בעיקר ל:
  /// - מסכי ניהול משק בית (עם householdId) ✅
  /// - מסכי ניהול admin (ללא householdId) ⚠️
  /// - דוחות ואנליטיקה
  /// - טסטים ו-debugging
  /// 
  /// מחזיר רשימה ריקה אם אין משתמשים.
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאת רשת/DB.
  /// 
  /// Example:
  /// ```dart
  /// // קבלת משתמשים של משק בית מסוים (מומלץ)
  /// final householdUsers = await repository.getAllUsers(
  ///   householdId: 'house_abc123',
  /// );
  /// print('משתמשי המשק: ${householdUsers.length}');
  /// 
  /// // קבלת כל המשתמשים (admin בלבד)
  /// final allUsers = await repository.getAllUsers();
  /// print('סה"כ משתמשים: ${allUsers.length}');
  /// ```
  /// 
  /// See also:
  /// - [findByEmail] - חיפוש משתמש ספציפי
  Future<List<UserEntity>> getAllUsers({String? householdId});

  /// מחפש משתמש לפי כתובת אימייל
  /// 
  /// מחזיר [UserEntity] אם נמצא משתמש עם האימייל, אחרת `null`.
  /// 
  /// 🔒 **SECURITY:** מקבל פרמטר אופציונלי [householdId]:
  /// - אם [householdId] מסופק → מחפש רק במשק בית זה ✅ (מומלץ)
  /// - אם [householdId] הוא null → מחפש בכל המשתמשים ⚠️ (admin בלבד)
  /// 
  /// ⚠️ **חשוב:** האימייל מנורמל (toLowerCase + trim) לפני החיפוש.
  /// 
  /// שימושי ל:
  /// - הוספת משתמש למשק בית (עם householdId) ✅
  /// - בדיקת אימייל קיים בהרשמה (ללא householdId)
  /// - שחזור חשבון
  /// - חיפוש משתמש במסך ניהול
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - שגיאת רשת
  /// - אימייל ריק (`ArgumentError`)
  /// 
  /// Example:
  /// ```dart
  /// // חיפוש במשק בית מסוים (מומלץ)
  /// final user = await repository.findByEmail(
  ///   'user@example.com',
  ///   householdId: 'house_abc123',
  /// );
  /// if (user != null) {
  ///   print('משתמש במשק: ${user.id}');
  /// }
  /// 
  /// // חיפוש גלובלי (הרשמה חדשה)
  /// final existingUser = await repository.findByEmail('user@example.com');
  /// if (existingUser != null) {
  ///   print('אימייל כבר קיים במערכת');
  /// } else {
  ///   print('אימייל פנוי לרישום');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [existsUser] - בדיקת קיום לפי ID
  /// - [getAllUsers] - קבלת כל משתמשי המשק
  Future<UserEntity?> findByEmail(String email, {String? householdId});

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

  /// יוצר משתמש חדש במערכת
  ///
  /// פונקציה עוטפת נוחה ל-[saveUser] שמטפלת ביצירת משתמש חדש.
  ///
  /// אם המשתמש כבר קיים - מחזיר את המשתמש הקיים (לא יוצר כפילות).
  ///
  /// **פרמטרים:**
  /// - [userId] - מזהה ייחודי (בד"כ מ-Firebase Auth)
  /// - [email] - כתובת אימייל (מנורמלת אוטומטית)
  /// - [name] - שם המשתמש
  /// - [householdId] - מזהה משק בית (אופציונלי)
  /// - 🆕 [preferredStores] - חנויות מועדפות (מ-Onboarding)
  /// - 🆕 [familySize] - גודל משפחה (מ-Onboarding)
  /// - 🆕 [shoppingFrequency] - תדירות קניות (מ-Onboarding)
  /// - 🆕 [shoppingDays] - ימי קניות קבועים (מ-Onboarding)
  /// - 🆕 [hasChildren] - האם יש ילדים (מ-Onboarding)
  /// - 🆕 [shareLists] - האם לשתף רשימות (מ-Onboarding)
  /// - 🆕 [reminderTime] - זמן תזכורת (מ-Onboarding)
  /// - 🆕 [seenOnboarding] - האם עבר Onboarding (מ-Onboarding)
  ///
  /// מחזיר את המשתמש החדש/הקיים.
  ///
  /// שימושי ב:
  /// - תהליך הרשמה (Sign Up)
  /// - יצירת משתמשי דמו
  /// - מיגרציה של משתמשים
  ///
  /// זורק [UserRepositoryException] במקרה של שגיאה.
  ///
  /// Example:
  /// ```dart
  /// final user = await repository.createUser(
  ///   userId: 'abc123',
  ///   email: 'user@example.com',
  ///   name: 'יוני כהן',
  ///   householdId: 'house_demo',
  ///   // 🆕 Onboarding data
  ///   preferredStores: ['שופרסל', 'רמי לוי'],
  ///   familySize: 4,
  ///   seenOnboarding: true,
  /// );
  /// print('משתמש נוצר: ${user.id}');
  /// ```
  ///
  /// See also:
  /// - [saveUser] - שמירה/עדכון משתמש קיים
  /// - [existsUser] - בדיקת קיום משתמש
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? householdId,
    // 🆕 Onboarding fields
    List<String>? preferredStores,
    int? familySize,
    int? shoppingFrequency,
    List<int>? shoppingDays,
    bool? hasChildren,
    bool? shareLists,
    String? reminderTime,
    bool? seenOnboarding,
  });

  /// מעדכן פרופיל של משתמש (עדכון חלקי)
  /// 
  /// מעדכן רק את השדות שנשלחו (לא null).
  /// שאר השדות נשארים ללא שינוי.
  /// 
  /// **פרמטרים:**
  /// - [userId] - מזהה המשתמש לעדכון (חובה)
  /// - [name] - שם חדש (אופציונלי)
  /// - [avatar] - URL לתמונת פרופיל (אופציונלי)
  /// 
  /// שימושי ב:
  /// - מסך הגדרות פרופיל
  /// - עדכון שם/תמונה מהיר
  /// - עדכון חלקי ללא טעינת כל הנתונים
  /// 
  /// ⚠️ **הערה:** לא מעדכן את `lastLoginAt` (בניגוד ל-saveUser).
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - משתמש לא קיים
  /// - שגיאת רשת
  /// - אין שדות לעדכון
  /// 
  /// Example:
  /// ```dart
  /// // עדכון שם בלבד
  /// await repository.updateProfile(
  ///   userId: 'abc123',
  ///   name: 'יוני כהן החדש',
  /// );
  /// 
  /// // עדכון תמונה בלבד
  /// await repository.updateProfile(
  ///   userId: 'abc123',
  ///   avatar: 'https://example.com/avatar.jpg',
  /// );
  /// 
  /// // עדכון שניהם
  /// await repository.updateProfile(
  ///   userId: 'abc123',
  ///   name: 'יוני',
  ///   avatar: 'https://example.com/avatar.jpg',
  /// );
  /// ```
  /// 
  /// See also:
  /// - [saveUser] - עדכון מלא של כל הפרופיל
  /// - [fetchUser] - קריאת הפרופיל הנוכחי
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatar,
  });

  /// מחזיר Stream של משתמש לעדכונים בזמן אמת
  /// 
  /// ה-Stream ישלח עדכון כל פעם שהמשתמש משתנה במערכת.
  /// 
  /// מחזיר `null` אם המשתמש נמחק או לא קיים.
  /// 
  /// 💡 **שימושי ב:**
  /// - הצגת פרופיל משתמש (real-time)
  /// - סנכרון בין מכשירים
  /// - עדכונים אוטומטיים של UI
  /// - מעקב אחר שינויים בפרופיל
  /// 
  /// ⚠️ **חשוב:** זכור לבטל את ה-subscription כשלא צריך!
  /// 
  /// 📝 **הערת מימוש:**
  /// - Firebase: Real-time Firestore snapshots
  /// - SQLite: Periodic polling או manual refresh
  /// - Mock: Stream.periodic למטרות testing
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאת חיבור או הרשאות.
  /// 
  /// Example:
  /// ```dart
  /// // האזנה לשינויים
  /// final subscription = repository.watchUser('abc123').listen((user) {
  ///   if (user != null) {
  ///     print('User updated: ${user.name}');
  ///   } else {
  ///     print('User deleted or not found');
  ///   }
  /// });
  /// 
  /// // ביטול ההאזנה (חשוב!)
  /// subscription.cancel();
  /// ```
  /// 
  /// Example עם Provider:
  /// ```dart
  /// class UserProfileScreen extends StatefulWidget {
  ///   @override
  ///   _UserProfileScreenState createState() => _UserProfileScreenState();
  /// }
  /// 
  /// class _UserProfileScreenState extends State<UserProfileScreen> {
  ///   StreamSubscription? _subscription;
  ///   
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     final repository = context.read<UserRepository>();
  ///     _subscription = repository.watchUser('abc123').listen((user) {
  ///       if (mounted && user != null) {
  ///         setState(() {
  ///           // עדכן UI...
  ///         });
  ///       }
  ///     });
  ///   }
  ///   
  ///   @override
  ///   void dispose() {
  ///     _subscription?.cancel(); // ביטול!
  ///     super.dispose();
  ///   }
  /// }
  /// ```
  /// 
  /// See also:
  /// - [fetchUser] - קריאה חד-פעמית
  /// - [saveUser] - עדכון המשתמש
  Stream<UserEntity?> watchUser(String userId);

  /// מוחק את כל המשתמשים מהמערכת
  /// 
  /// 💡 **Dynamic filtering:** מקבל פרמטר אופציונלי [householdId]:
  /// - אם [householdId] מסופק → מוחק רק משתמשים של אותו משק בית ✅
  /// - אם [householdId] הוא null → מוחק **כל** המשתמשים (מסוכן!) ⚠️
  /// 
  /// ⚠️ **אזהרה קריטית:** פעולה זו בלתי הפיכה!
  /// 
  /// שימושי **רק** ל:
  /// - ניקוי משק בית מסוים (עם householdId) ✅
  /// - איפוס מסד נתונים בטסטים (ללא householdId)
  /// - סביבת פיתוח (dev/staging)
  /// - סקריפטים של ניקוי
  /// 
  /// ❌ **אסור להשתמש ב-Production ללא householdId!**
  /// 
  /// זורק [UserRepositoryException] במקרה של שגיאה.
  /// 
  /// Example:
  /// ```dart
  /// // ניקוי משק בית מסוים (מומלץ)
  /// await repository.clearAll(householdId: 'house_abc123');
  /// print('משתמשי המשק נמחקו');
  /// 
  /// // ניקוי כל המשתמשים (בטסטים בלבד!)
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
  Future<void> clearAll({String? householdId});
}
