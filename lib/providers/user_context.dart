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
// 📝 Version: 2.0 - Full Documentation
// 📅 Updated: 09/10/2025

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_entity.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

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
  /// במקרה של שגיאה - נשאר עם ערכי ברירת מחדל.
  Future<void> _loadPreferences() async {
    debugPrint('📥 UserContext._loadPreferences: טוען העדפות');

    try {
      final prefs = await SharedPreferences.getInstance();

      _themeMode = ThemeMode.values[
        prefs.getInt('themeMode') ?? ThemeMode.system.index
      ];
      _compactView = prefs.getBool('compactView') ?? false;
      _showPrices = prefs.getBool('showPrices') ?? true;

      debugPrint('✅ העדפות נטענו: theme=$_themeMode, compact=$_compactView, prices=$_showPrices');
    } catch (e) {
      debugPrint('⚠️ שגיאה בטעינת העדפות: $e');
      // נשאר עם ערכי ברירת מחדל
    } finally {
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (preferences loaded)');
    }
  }

  /// שומר העדפות UI ל-SharedPreferences
  /// 
  /// נקרא אוטומטית כשמשנים העדפה (setThemeMode, toggleCompactView, וכו').
  /// 
  /// במקרה של שגיאה - ממשיך בלי לזרוק Exception.
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setBool('compactView', _compactView);
      await prefs.setBool('showPrices', _showPrices);

      debugPrint('💾 העדפות נשמרו');
    } catch (e) {
      debugPrint('⚠️ שגיאה בשמירת העדפות: $e');
    } finally {
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (preferences saved)');
    }
  }

  // === האזנה לשינויים ב-Auth ===

  /// מאזין לשינויים ב-Firebase Auth (real-time)
  /// 
  /// נקרא אוטומטית ב-constructor.
  /// 
  /// תהליך:
  /// 1. משתמש מתחבר → טוען מ-Firestore
  /// 2. משתמש מתנתק → מנקה state
  /// 3. שגיאה → logging בלבד
  /// 
  /// ⚠️ **חשוב:** ה-subscription מתבטל ב-dispose()!
  void _listenToAuthChanges() {
    debugPrint('👂 UserContext: מתחיל להאזין לשינויים ב-Auth');

    _authSubscription = _authService.authStateChanges.listen(
      (firebaseUser) async {
        debugPrint('🔄 UserContext: שינוי ב-Auth state');
        debugPrint('   User: ${firebaseUser?.email ?? "null"}');

        if (firebaseUser != null) {
          // משתמש התחבר - טען את הפרטים מ-Firestore
          await _loadUserFromFirestore(firebaseUser.uid);
        } else {
          // משתמש התנתק - נקה state
          _user = null;
          _resetPreferences();
          notifyListeners();
          debugPrint('   🔔 UserContext: notifyListeners() (user=null)');
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
  /// 2. אם לא נמצא → יוצר משתמש חדש
  /// 3. מעדכן state + notifyListeners
  /// 
  /// במקרה של שגיאה:
  /// - State נשאר ללא שינוי
  /// - errorMessage מתעדכן
  /// - notifyListeners נקרא בכל מקרה
  Future<void> _loadUserFromFirestore(String userId) async {
    debugPrint('📥 UserContext._loadUserFromFirestore: טוען משתמש $userId');

    try {
      _user = await _repository.fetchUser(userId);

      if (_user == null) {
        debugPrint('⚠️ משתמש לא נמצא ב-Firestore, יוצר חדש');

        // צור משתמש חדש אם לא קיים
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          _user = UserEntity.newUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'משתמש חדש',
          );

          await _repository.saveUser(_user!);
          debugPrint('✅ משתמש חדש נוצר ב-Firestore');
        }
      }

      debugPrint('✅ UserContext: משתמש נטען - ${_user?.email}');
      _errorMessage = null; // נקה שגיאות קודמות
    } catch (e) {
      debugPrint('❌ UserContext._loadUserFromFirestore: שגיאה - $e');
      _errorMessage = 'שגיאה בטעינת פרטי משתמש';
    }

    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (user=${_user?.email})');
  }

  // === רישום משתמש חדש ===

  /// רושם משתמש חדש עם Firebase Auth ויוצר רשומה ב-Firestore
  /// 
  /// תהליך:
  /// 1. רישום ב-Firebase Auth
  /// 2. יצירת UserEntity חדש
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
    debugPrint('📝 UserContext.signUp: רושם משתמש - $email');

    _isLoading = true;
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (isLoading=true)');

    try {
      // רישום ב-Firebase Auth
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      // יצירת רשומה ב-Firestore
      if (credential.user != null) {
        _user = UserEntity.newUser(
          id: credential.user!.uid,
          email: email.toLowerCase().trim(),
          name: name,
        );

        await _repository.saveUser(_user!);
        debugPrint('✅ UserContext.signUp: משתמש נוצר בהצלחה');
      }

      _errorMessage = null; // נקה שגיאות קודמות
      // ה-listener של authStateChanges יטפל בעדכון הסופי
    } catch (e) {
      debugPrint('❌ UserContext.signUp: שגיאה - $e');
      _errorMessage = 'שגיאה ברישום: ${e.toString()}';
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (error occurred)');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false)');
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
    debugPrint('🔐 UserContext.signIn: מתחבר - $email');

    _isLoading = true;
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (isLoading=true)');

    try {
      await _authService.signIn(email: email, password: password);
      debugPrint('✅ UserContext.signIn: התחברות הושלמה');
      _errorMessage = null; // נקה שגיאות קודמות
      
      // ה-listener של authStateChanges יטפל בטעינת המשתמש
    } catch (e) {
      debugPrint('❌ UserContext.signIn: שגיאה - $e');
      _errorMessage = 'שגיאה בהתחברות: ${e.toString()}';
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (error occurred)');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false)');
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
  /// - [logout] - Alias ל-signOut
  /// - [signIn] - התחברות
  Future<void> signOut() async {
    debugPrint('👋 UserContext.signOut: מתנתק');

    try {
      await _authService.signOut();
      debugPrint('✅ UserContext.signOut: התנתקות הושלמה');
      _errorMessage = null; // נקה שגיאות
      
      // ה-listener של authStateChanges יטפל בניקוי ה-state
    } catch (e) {
      debugPrint('❌ UserContext.signOut: שגיאה - $e');
      _errorMessage = 'שגיאה בהתנתקות';
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (error occurred)');
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
  Future<void> saveUser(UserEntity user) async {
    debugPrint('💾 UserContext.saveUser: שומר משתמש ${user.id}');

    try {
      _user = await _repository.saveUser(user);
      _errorMessage = null;
      notifyListeners();
      debugPrint('✅ UserContext.saveUser: משתמש נשמר');
      debugPrint('   🔔 UserContext: notifyListeners() (user saved)');
    } catch (e) {
      debugPrint('❌ UserContext.saveUser: שגיאה - $e');
      _errorMessage = 'שגיאה בשמירת פרטי משתמש';
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (error occurred)');
      rethrow;
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
  ///     SnackBar(content: Text('מייל נשלח בהצלחה')),
  ///   );
  /// } catch (e) {
  ///   showError('שגיאה בשליחת מייל');
  /// }
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('📧 UserContext.sendPasswordResetEmail: שולח מייל ל-$email');

    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
      debugPrint('✅ UserContext.sendPasswordResetEmail: מייל נשלח');
    } catch (e) {
      debugPrint('❌ UserContext.sendPasswordResetEmail: שגיאה - $e');
      _errorMessage = 'שגיאה בשליחת מייל לאיפוס סיסמה';
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (error occurred)');
      rethrow;
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
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (themeMode=$mode)');
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
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (compactView=$_compactView)');
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
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (showPrices=$_showPrices)');
  }

  /// מאפס את כל העדפות UI לברירת מחדל
  /// 
  /// נקרא אוטומטית כשמשתמש מתנתק.
  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _compactView = false;
    _showPrices = true;
    debugPrint('🔄 UserContext._resetPreferences: העדפות אופסו');
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
    debugPrint('🔄 UserContext.retry: מנסה שוב');

    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (error cleared)');

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserFromFirestore(currentUser.uid);
    } else {
      debugPrint('⚠️ UserContext.retry: אין משתמש מחובר');
    }
  }

  /// ניקוי מלא של כל ה-state
  /// 
  /// מנקה:
  /// - UserEntity (user = null)
  /// - שגיאות (errorMessage = null)
  /// - loading state (isLoading = false)
  /// - העדפות UI (חזרה לברירת מחדל)
  /// - SharedPreferences
  /// 
  /// ⚠️ **אזהרה:** פעולה זו לא מתנתקת מ-Firebase Auth!
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
    debugPrint('🗑️ UserContext.clearAll: מנקה state');

    _user = null;
    _errorMessage = null;
    _isLoading = false;
    _resetPreferences();

    // נקה גם SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ UserContext.clearAll: SharedPreferences נוקה');
    } catch (e) {
      debugPrint('⚠️ שגיאה בניקוי SharedPreferences: $e');
    }

    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (all cleared)');
  }

  // === Cleanup ===

  @override
  void dispose() {
    debugPrint('🗑️ UserContext.dispose()');
    _authSubscription?.cancel();
    super.dispose();
  }
}
