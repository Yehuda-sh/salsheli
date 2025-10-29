// 📄 File: lib/providers/user_context.dart
//
// 🇮🇱 מנהל את ההקשר של המשתמש באפליקציה עם Firebase Authentication:
//     - מחזיק את פרטי המשתמש (UserEntity) והעדפותיו
//     - מאזין לשינויים ב-Firebase Auth (real-time)
//     - טוען/שומר/מוחק משתמש דרך UserRepository
//     - עוקב אחרי סטטיסטיקות ושומר העדפות UI
//     - מספק Single Source of Truth למצב משתמש
//
// 🇬🇧 Manages user context in the app with Firebase Authentication:
//     - Holds user profile (UserEntity) and preferences
//     - Listens to Firebase Auth changes (real-time)
//     - Loads/saves/deletes user via UserRepository
//     - Tracks stats and UI preferences
//     - Provides Single Source of Truth for user state
//
// 📦 Dependencies:
//     - firebase_auth - Firebase Authentication
//     - shared_preferences - UI preferences storage
//     - models/user_entity.dart - מודל המשתמש
//     - repositories/user_repository.dart - Repository interface
//     - services/auth_service.dart - שירות אימות
//
// 🔗 Related:
//     - firebase_user_repository.dart - המימוש של Repository
//     - auth_service.dart - שירות ההתחברות
//     - main.dart - רישום ה-Provider
//
// 🎯 Usage:
//     ```dart
//     // קריאה
//     final userContext = context.watch<UserContext>();
//     if (userContext.isLoggedIn) {
//       print('User: ${userContext.displayName}');
//     }
//     
//     // פעולות
//     await userContext.signIn(email: '...', password: '...');
//     await userContext.signOut();
//     
//     // העדפות UI
//     userContext.setThemeMode(ThemeMode.dark);
//     userContext.toggleCompactView();
//     ```
//
// 📝 Version: 2.1 - Enhanced Safety & Logging
// 📅 Updated: 14/10/2025
// 
// 🆕 Changes in v2.1:
//     - 🔒 Added bounds checking for ThemeMode.values (prevents RangeError)
//     - 🔒 Enhanced null-safety for currentUser access
//     - 🗑️ Selective deletion in clearAll() (only UserContext keys)
//     - 📝 Improved logging consistency with emojis
//     - 📖 Enhanced documentation

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';

/// Provider המנהל את הקשר המשתמש באפליקציה
/// 
/// **אחריות:**
/// - ניהול state המשתמש המחובר
/// - האזנה לשינויים ב-Firebase Auth
/// - סנכרון עם Firestore דרך Repository
/// - שמירת העדפות UI ב-SharedPreferences
/// - Error handling ו-recovery
/// 
/// **Pattern: Single Source of Truth**
/// 
/// UserContext הוא המקור היחיד לאמת עבור מצב המשתמש.
/// כל widget/screen צריך לקרוא ממנו, לא מ-Firebase Auth ישירות!
/// 
/// ```dart
/// // ✅ טוב - קריאה מ-UserContext
/// final isLoggedIn = context.watch<UserContext>().isLoggedIn;
/// 
/// // ❌ רע - קריאה ישירה מ-Firebase
/// final user = FirebaseAuth.instance.currentUser;
/// ```
/// 
/// **Lifecycle:**
/// 
/// 1. נוצר ב-main.dart עם Repository + AuthService
/// 2. מאזין ל-authStateChanges (real-time)
/// 3. כשמשתמש מתחבר → טוען מ-Firestore
/// 4. כשמשתמש מתנתק → מנקה state
/// 5. notifyListeners() מעדכן את כל הWidgets
/// 
/// See also:
/// - [UserRepository] - הממשק לגישה לנתונים
/// - [AuthService] - שירות ההתחברות
class UserContext with ChangeNotifier {
  final UserRepository _repository;
  final AuthService _authService;

  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  
  // 🔒 דגל למניעת Race Condition בזמן רישום
  bool _isSigningUp = false;
  
  // 🔒 דגל לבדיקה אם ה-context כבר disposed
  bool _isDisposed = false;

  // --- UI Preferences ---
  ThemeMode _themeMode = ThemeMode.system;
  bool _compactView = false;
  bool _showPrices = true;

  UserContext({
    required UserRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService {
    // האזנה לשינויים ב-Firebase Auth
    _listenToAuthChanges();
    // טעינת העדפות UI
    _loadPreferences();
  }

  // === Getters ===

  /// המשתמש הנוכחי (null אם לא מחובר)
  /// 
  /// ⚠️ Note: UserEntity is immutable - use copyWith() to modify
  UserEntity? get user => _user;

  /// האם משתמש מחובר כרגע
  /// 
  /// בודק גם את UserEntity וגם את Firebase Auth.
  bool get isLoggedIn => _user != null && _authService.isSignedIn;

  /// האם בתהליך טעינה
  bool get isLoading => _isLoading;

  /// האם יש שגיאה
  bool get hasError => _errorMessage != null;

  /// הודעת השגיאה (null אם אין שגיאה)
  String? get errorMessage => _errorMessage;

  /// שם התצוגה של המשתמש
  /// 
  /// מחזיר מ-UserEntity אם קיים, אחרת מ-Firebase Auth.
  String? get displayName => _user?.name ?? _authService.currentUserDisplayName;

  /// מזהה המשתמש
  /// 
  /// מחזיר מ-UserEntity אם קיים, אחרת מ-Firebase Auth.
  String? get userId => _user?.id ?? _authService.currentUserId;

  /// אימייל המשתמש
  /// 
  /// מחזיר מ-UserEntity אם קיים, אחרת מ-Firebase Auth.
  String? get userEmail => _user?.email ?? _authService.currentUserEmail;

  /// מזהה משק הבית של המשתמש
  String? get householdId => _user?.householdId;

  // UI Preferences Getters
  
  /// מצב ערכת נושא נוכחי (Light/Dark/System)
  ThemeMode get themeMode => _themeMode;

  /// האם בתצוגה קומפקטית
  bool get compactView => _compactView;

  /// האם להציג מחירים
  bool get showPrices => _showPrices;

  // === טעינת העדפות UI ===

  /// טוען העדפות UI מ-SharedPreferences
  /// 
  /// נקרא אוטומטית ב-constructor.
  /// 
  /// העדפות שנטענות:
  /// - themeMode (Light/Dark/System)
  /// - compactView (תצוגה קומפקטית)
  /// - showPrices (הצגת מחירים)
  /// 
  /// במקרה של שגיאה - נשאר עם ערכי ברירת מחדל ומעדכן Listeners.
  /// 
  /// ⚠️ **חשוב:** בודק גבולות לפני גישה ל-ThemeMode.values למניעת RangeError
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔒 בדיקת גבולות לפני גישה ל-ThemeMode.values
      final themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
      if (themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      } else {
        _themeMode = ThemeMode.system;
        debugPrint('⚠️ themeMode index לא תקין ($themeModeIndex), משתמש בברירת מחדל');
      }

      _compactView = prefs.getBool('compactView') ?? false;
      _showPrices = prefs.getBool('showPrices') ?? true;
    } catch (e) {
      debugPrint('⚠️ UserContext._loadPreferences: שגיאה בטעינת העדפות - $e');
      // נשאר עם ערכי ברירת מחדל
    } finally {
      // 🔒 בדוק אם ה-context עדיין חי לפני notifyListeners
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// שומר העדפות UI ל-SharedPreferences
  /// 
  /// נקרא אוטומטית כשמשנים העדפה (setThemeMode, toggleCompactView, וכו').
  /// 
  /// במקרה של שגיאה - ממשיך בלי לזרוק Exception, אבל מעדכן Listeners.
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setBool('compactView', _compactView);
      await prefs.setBool('showPrices', _showPrices);
    } catch (e) {
      debugPrint('❌ UserContext._savePreferences: שגיאה בשמירת העדפות - $e');
    }
    // Note: notifyListeners() נקרא על ידי הפונקציה הקוראת (setThemeMode/toggleCompactView/toggleShowPrices)
  }

  // === האזנה לשינויים ב-Auth ===

  /// מאזין לשינויים ב-Firebase Auth (real-time)
  /// 
  /// נקרא אוטומטית ב-constructor.
  /// 
  /// תהליך:
  /// 1. משתמש מתחבר → טוען מ-Firestore (async)
  /// 2. משתמש מתנתק → מנקה state
  /// 3. שגיאה → logging בלבד
  /// 
  /// ⚠️ **חשוב:** ה-subscription מתבטל ב-dispose()!
  /// ⚠️ **Performance:** משתמש ב-.then() במקום await למניעת blocking
  void _listenToAuthChanges() {
    debugPrint('👂 UserContext: מתחיל להאזין לשינויים ב-Auth');

    // 🔒 ביטול listener קיים לפני יצירת חדש (למניעת האזנה כפולה)
    _authSubscription?.cancel();

    _authSubscription = _authService.authStateChanges.listen(
      (firebaseUser) {
        debugPrint('🔄 UserContext: שינוי ב-Auth state');

        if (firebaseUser != null) {
          // 🔒 אם אנחנו בתהליך רישום - אל תיצור משתמש כאן!
          if (_isSigningUp) {
            return;
          }
          
          // משתמש התחבר - טען את הפרטים מ-Firestore (async)
          _loadUserFromFirestore(firebaseUser.uid).catchError((error) {
            debugPrint('   ❌ שגיאה בטעינת משתמש: $error');
          });
        } else {
          // משתמש התנתק - נקה state
          _user = null;
          _resetPreferences();
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('❌ UserContext: שגיאה בהאזנה ל-Auth - $error');
      },
    );
  }

  // === טעינת משתמש מ-Firestore ===

  /// טוען משתמש מ-Firestore לפי ID
  /// 
  /// נקרא אוטומטית כש-Firebase Auth מזהה התחברות.
  /// 
  /// תהליך:
  /// 1. ניסיון לטעון מ-Repository
  /// 2. אם לא נמצא → יוצר משתמש חדש דרך Repository
  /// 3. מעדכן state + notifyListeners
  /// 
  /// במקרה של שגיאה:
  /// - State נשאר ללא שינוי
  /// - errorMessage מתעדכן
  /// - notifyListeners נקרא בכל מקרה
  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      _user = await _repository.fetchUser(userId);

      if (_user == null) {
        // ✅ צור משתמש חדש דרך Repository.createUser()
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          _user = await _repository.createUser(
            userId: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'משתמש חדש',
          );
        }
      }

      _errorMessage = null; // נקה שגיאות קודמות
    } catch (e) {
      debugPrint('❌ UserContext._loadUserFromFirestore: שגיאה - $e');
      _errorMessage = 'שגיאה בטעינת פרטי משתמש';
    }

    notifyListeners();
  }

  // === רישום משתמש חדש ===

  /// רושם משתמש חדש עם Firebase Auth ויוצר רשומה ב-Firestore
  /// 
  /// תהליך:
  /// 1. רישום ב-Firebase Auth
  /// 2. יצירת UserEntity חדש דרך Repository
  /// 3. שמירה ב-Firestore דרך Repository
  /// 4. ה-Listener של authStateChanges מטפל בעדכון הסופי
  /// 
  /// זורק Exception במקרה של:
  /// - אימייל כבר קיים
  /// - סיסמה חלשה
  /// - שגיאת רשת
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await userContext.signUp(
  ///     email: 'user@example.com',
  ///     password: 'SecurePass123!',
  ///     name: 'יוני כהן',
  ///   );
  ///   // הצלחה - Navigation ל-Home
  /// } catch (e) {
  ///   // טיפול בשגיאה
  ///   showDialog(...);
  /// }
  /// ```
  /// 
  /// See also:
  /// - [signIn] - התחברות למשתמש קיים
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _isSigningUp = true; // 🔒 נעילת listener
    _errorMessage = null;
    notifyListeners();

    try {
      // רישום ב-Firebase Auth
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      // ✅ יצירת רשומה ב-Firestore דרך Repository.createUser()
      if (credential.user != null) {
        _user = await _repository.createUser(
          userId: credential.user!.uid,
          email: email,
          name: name,
        );
      }

      // ה-listener של authStateChanges יטפל בעדכון הסופי
    } catch (e) {
      debugPrint('❌ UserContext.signUp: שגיאה - $e');
      _errorMessage = 'שגיאה ברישום: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      _isSigningUp = false; // 🔓 שחרור listener
      notifyListeners();
    }
  }

  // === התחברות ===

  /// מתחבר עם אימייל וסיסמה
  /// 
  /// תהליך:
  /// 1. התחברות ב-Firebase Auth
  /// 2. ה-Listener של authStateChanges טוען את המשתמש מ-Firestore
  /// 
  /// ⚠️ **חשוב:** לא לבדוק isLoggedIn מיד אחרי signIn!
  /// 
  /// ```dart
  /// // ❌ רע - Race Condition
  /// await userContext.signIn(...);
  /// if (userContext.isLoggedIn) { ... } // עדיין false!
  /// 
  /// // ✅ טוב - Exception Pattern
  /// try {
  ///   await userContext.signIn(...);
  ///   // אם הגענו לכאן = הצלחנו!
  ///   Navigator.pushReplacementNamed('/home');
  /// } catch (e) {
  ///   // שגיאה בהתחברות
  ///   showError(e);
  /// }
  /// ```
  /// 
  /// זורק Exception במקרה של:
  /// - אימייל/סיסמה שגויים
  /// - משתמש לא קיים
  /// - שגיאת רשת
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await userContext.signIn(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   Navigator.pushReplacementNamed('/home');
  /// } catch (e) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('שגיאה: $e')),
  ///   );
  /// }
  /// ```
  /// 
  /// See also:
  /// - [signUp] - רישום משתמש חדש
  /// - [signOut] - התנתקות
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      
      // ה-listener של authStateChanges יטפל בטעינת המשתמש
    } catch (e) {
      debugPrint('❌ UserContext.signIn: שגיאה - $e');
      _errorMessage = 'שגיאה בהתחברות: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === התנתקות ===

  /// מתנתק מהמערכת
  /// 
  /// תהליך:
  /// 1. התנתקות מ-Firebase Auth
  /// 2. ה-Listener של authStateChanges מנקה את ה-state
  /// 
  /// זורק Exception רק במקרה של שגיאה קריטית.
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await userContext.signOut();
  ///   Navigator.pushReplacementNamed('/login');
  /// } catch (e) {
  ///   print('שגיאה בהתנתקות: $e');
  /// }
  /// ```
  /// 
  /// See also:
  /// - [signOutAndClearAllData] - התנתקות + מחיקת כל הנתונים
  /// - [logout] - Alias ל-signOut
  /// - [signIn] - התחברות
  Future<void> signOut() async {
    _errorMessage = null;

    try {
      await _authService.signOut();
      
      // ה-listener של authStateChanges יטפל בניקוי ה-state
    } catch (e) {
      debugPrint('❌ UserContext.signOut: שגיאה - $e');
      _errorMessage = 'שגיאה בהתנתקות';
      notifyListeners();
      rethrow;
    }
  }

  /// התנתקות מלאה + מחיקת כל הנתונים המקומיים
  /// 
  /// 🔥 **התנתקות נקייה מוחלטת** - כאילו התקנת את האפליקציה מחדש!
  /// 
  /// מוחק:
  /// 1. 🗄️ [REMOVED] Hive data - now using Firestore only
  /// 2. ⚙️ כל ההעדפות ב-SharedPreferences
  /// 3. 🔐 התנתקות מ-Firebase Auth
  /// 4. 🧹 ניקוי state ב-UserContext
  /// 
  /// ⚠️ **אזהרה:** פעולה בלתי הפיכה! כל הנתונים המקומיים יימחקו!
  /// 
  /// Example:
  /// ```dart
  /// // במסך הגדרות, כפתור "התנתק"
  /// ElevatedButton(
  ///   onPressed: () async {
  ///     final confirm = await showDialog<bool>(...);
  ///     if (confirm == true) {
  ///       await userContext.signOutAndClearAllData();
  ///       Navigator.pushReplacementNamed('/login');
  ///     }
  ///   },
  ///   child: Text('התנתק'),
  /// );
  /// ```
  /// 
  /// See also:
  /// - [signOut] - התנתקות רגילה (ללא מחיקת נתונים)
  /// - [clearAll] - ניקוי state בלבד
  Future<void> signOutAndClearAllData() async {
    debugPrint('🔥 UserContext.signOutAndClearAllData: התנתקות מלאה + מחיקת כל הנתונים!');

    _errorMessage = null;

    try {
      // 1️⃣ מחק את כל ה-SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2️⃣ Hive removed - using Firestore only

      // 3️⃣ נקה את ה-state המקומי
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      _resetPreferences();

      // 4️⃣ התנתק מ-Firebase Auth
      await _authService.signOut();

      debugPrint('🎉 UserContext.signOutAndClearAllData: הושלם בהצלחה!');
      
      // ה-listener של authStateChanges יטפל בעדכון הסופי
    } catch (e) {
      debugPrint('❌ UserContext.signOutAndClearAllData: שגיאה - $e');
      _errorMessage = 'שגיאה בהתנתקות ומחיקת נתונים';
      notifyListeners();
      rethrow;
    }
  }

  /// Alias ל-signOut() לתאימות אחורה
  /// 
  /// Example:
  /// ```dart
  /// await userContext.logout();
  /// ```
  Future<void> logout() async => signOut();

  // === שמירת משתמש ===

  /// שומר/מעדכן פרטי משתמש ב-Firestore
  /// 
  /// מעדכן גם את ה-state המקומי.
  /// 
  /// זורק Exception במקרה של שגיאה.
  /// 
  /// Example:
  /// ```dart
  /// final updatedUser = user.copyWith(name: 'שם חדש');
  /// await userContext.saveUser(updatedUser);
  /// ```
  /// 
  /// See also:
  /// - [signUp] - יצירת משתמש חדש
  /// - [updateUserProfile] - עדכון חלקי (שם/תמונה)
  Future<void> saveUser(UserEntity user) async {
    _errorMessage = null;

    try {
      _user = await _repository.saveUser(user);
    } catch (e) {
      debugPrint('❌ UserContext.saveUser: שגיאה - $e');
      _errorMessage = 'שגיאה בשמירת פרטי משתמש';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// מעדכן פרופיל משתמש (עדכון חלקי)
  /// 
  /// פונקציה נוחה לעדכון שם ו/או תמונת פרופיל.
  /// 
  /// מעדכן רק את השדות שנשלחו (לא null).
  /// שאר השדות נשארים ללא שינוי.
  /// 
  /// ⚠️ **הערה:** לא מעדכן את `lastLoginAt` (בניגוד ל-saveUser).
  /// 
  /// 💡 **יתרונות:**
  /// - עדכון מהיר בלי לטעון את כל הנתונים
  /// - API פשוט למסך הגדרות
  /// - לא משפיע על lastLoginAt
  /// 
  /// זורק [UserRepositoryException] במקרה של:
  /// - משתמש לא מחובר
  /// - שגיאת רשת
  /// - אין שדות לעדכון
  /// 
  /// Example:
  /// ```dart
  /// // עדכון שם בלבד
  /// await userContext.updateUserProfile(name: 'יוני כהן');
  /// 
  /// // עדכון תמונה בלבד
  /// await userContext.updateUserProfile(
  ///   avatar: 'https://example.com/avatar.jpg',
  /// );
  /// 
  /// // עדכון שניהם
  /// await userContext.updateUserProfile(
  ///   name: 'יוני',
  ///   avatar: 'https://example.com/avatar.jpg',
  /// );
  /// ```
  /// 
  /// See also:
  /// - [saveUser] - עדכון מלא של כל הפרופיל
  Future<void> updateUserProfile({String? name, String? avatar}) async {
    if (_user == null) {
      debugPrint('❌ UserContext.updateUserProfile: אין משתמש מחובר');
      throw UserRepositoryException('אין משתמש מחובר');
    }

    _errorMessage = null;

    try {
      // ✅ קורא ל-Repository.updateProfile()
      await _repository.updateProfile(
        userId: _user!.id,
        name: name,
        avatar: avatar,
      );

      // טען מחדש כדי לקבל את העדכונים
      _user = await _repository.fetchUser(_user!.id);
    } catch (e) {
      debugPrint('❌ UserContext.updateUserProfile: שגיאה - $e');
      _errorMessage = 'שגיאה בעדכון פרופיל';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // === איפוס סיסמה ===

  /// שולח מייל לאיפוס סיסמה
  /// 
  /// המשתמש יקבל מייל עם קישור לאיפוס הסיסמה.
  /// 
  /// זורק Exception במקרה של:
  /// - אימייל לא קיים
  /// - שגיאת רשת
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await userContext.sendPasswordResetEmail('user@example.com');
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('מייל נשלח בהצלחה'), duration: kSnackBarDurationLong),
  ///   );
  /// } catch (e) {
  ///   showError('שגיאה בשליחת מייל');
  /// }
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    _errorMessage = null;

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      debugPrint('❌ UserContext.sendPasswordResetEmail: שגיאה - $e');
      _errorMessage = 'שגיאה בשליחת מייל לאיפוס סיסמה';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // === Preferences ===

  /// מגדיר מצב ערכת נושא (Light/Dark/System)
  /// 
  /// השינוי נשמר ב-SharedPreferences אוטומטית.
  /// 
  /// Example:
  /// ```dart
  /// userContext.setThemeMode(ThemeMode.dark);
  /// ```
  void setThemeMode(ThemeMode mode) {
    // debugPrint('🎨 UserContext.setThemeMode: משנה ל-$mode');
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  /// משנה מצב תצוגה קומפקטית (On/Off)
  /// 
  /// השינוי נשמר ב-SharedPreferences אוטומטית.
  /// 
  /// Example:
  /// ```dart
  /// userContext.toggleCompactView();
  /// print('Compact: ${userContext.compactView}');
  /// ```
  void toggleCompactView() {
    _compactView = !_compactView;
    // debugPrint('📱 UserContext.toggleCompactView: compactView=$_compactView');
    _savePreferences();
    notifyListeners();
  }

  /// משנה מצב הצגת מחירים (Show/Hide)
  /// 
  /// השינוי נשמר ב-SharedPreferences אוטומטית.
  /// 
  /// Example:
  /// ```dart
  /// userContext.toggleShowPrices();
  /// print('Show prices: ${userContext.showPrices}');
  /// ```
  void toggleShowPrices() {
    _showPrices = !_showPrices;
    // debugPrint('💰 UserContext.toggleShowPrices: showPrices=$_showPrices');
    _savePreferences();
    notifyListeners();
  }

  /// מאפס את כל העדפות UI לברירת מחדל
  /// 
  /// נקרא אוטומטית כשמשתמש מתנתק.
  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _compactView = false;
    _showPrices = true;
  }

  // === Error Recovery ===

  /// ניסיון חוזר לטעינת משתמש אחרי שגיאה
  /// 
  /// מנקה את השגיאה ומנסה לטעון שוב מ-Firestore.
  /// 
  /// שימושי במסכי Error State עם כפתור "נסה שוב".
  /// 
  /// Example:
  /// ```dart
  /// if (userContext.hasError) {
  ///   ElevatedButton(
  ///     onPressed: () => userContext.retry(),
  ///     child: Text('נסה שוב'),
  ///   );
  /// }
  /// ```
  /// 
  /// See also:
  /// - [hasError] - בדיקת קיום שגיאה
  /// - [errorMessage] - הודעת השגיאה
  Future<void> retry() async {
    _errorMessage = null;
    notifyListeners();

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserFromFirestore(currentUser.uid);
    }
  }

  /// ניקוי מלא של כל ה-state
  /// 
  /// מנקה:
  /// - UserEntity (user = null)
  /// - שגיאות (errorMessage = null)
  /// - loading state (isLoading = false)
  /// - העדפות UI (חזרה לברירת מחדל)
  /// - SharedPreferences (רק המפתחות של UserContext)
  /// 
  /// ⚠️ **אזהרה:** פעולה זו לא מתנתקת מ-Firebase Auth!
  /// 
  /// ⚠️ **חשוב:** מחיקה סלקטיבית - רק המפתחות של UserContext!
  /// 
  /// שימושי ב:
  /// - Reset של האפליקציה
  /// - ניקוי לפני התנתקות
  /// - טסטים
  /// 
  /// Example:
  /// ```dart
  /// await userContext.clearAll();
  /// await userContext.signOut();
  /// Navigator.pushReplacementNamed('/login');
  /// ```
  /// 
  /// See also:
  /// - [signOut] - התנתקות מ-Firebase Auth
  Future<void> clearAll() async {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    _resetPreferences();

    // 🔒 מחיקה סלקטיבית - רק המפתחות של UserContext (לא prefs.clear!)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('themeMode');
      await prefs.remove('compactView');
      await prefs.remove('showPrices');
    } catch (e) {
      debugPrint('⚠️ שגיאה בניקוי SharedPreferences: $e');
    }

    notifyListeners();
  }

  // === Cleanup ===

  @override
  void dispose() {
    debugPrint('🗑️ UserContext.dispose()');
    _isDisposed = true; // 🔒 סמן ש-disposed
    _authSubscription?.cancel();
    super.dispose();
  }
}
