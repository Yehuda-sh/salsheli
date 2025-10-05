// 📄 File: lib/providers/user_context.dart
//
// 🇮🇱 מנהל את ההקשר של המשתמש באפליקציה עם Firebase Authentication:
//     - מחזיק את פרטי המשתמש (UserEntity) והעדפותיו
//     - מאזין לשינויים ב-Firebase Auth (real-time)
//     - טוען/שומר/מוחק משתמש דרך FirebaseUserRepository
//     - עוקב אחרי סטטיסטיקות ושומר העדפות UI
//
// 🇬🇧 Manages user context in the app with Firebase Authentication:
//     - Holds user profile (UserEntity) and preferences
//     - Listens to Firebase Auth changes (real-time)
//     - Loads/saves/deletes user via FirebaseUserRepository
//     - Tracks stats and UI preferences

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_entity.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class UserContext with ChangeNotifier {
  final UserRepository _repository;
  final AuthService _authService;

  UserEntity? _user;
  bool _isLoading = false;
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
  UserEntity? get user => _user;
  bool get isLoggedIn => _user != null && _authService.isSignedIn;
  bool get isLoading => _isLoading;
  String? get displayName => _user?.name ?? _authService.currentUserDisplayName;
  String? get userId => _user?.id ?? _authService.currentUserId;
  String? get userEmail => _user?.email ?? _authService.currentUserEmail;

  ThemeMode get themeMode => _themeMode;
  bool get compactView => _compactView;
  bool get showPrices => _showPrices;

  // === טעינת העדפות UI ===

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
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setBool('compactView', _compactView);
      await prefs.setBool('showPrices', _showPrices);

      debugPrint('💾 העדפות נשמרו');
    } catch (e) {
      debugPrint('⚠️ שגיאה בשמירת העדפות: $e');
    }
  }

  // === האזנה לשינויים ב-Auth ===

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
    } catch (e) {
      debugPrint('❌ UserContext._loadUserFromFirestore: שגיאה - $e');
    }

    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (user=${_user?.email})');
  }

  // === רישום משתמש חדש ===

  /// רושם משתמש חדש עם Firebase Auth ויוצר רשומה ב-Firestore
  /// 
  /// Example:
  /// ```dart
  /// await userContext.signUp(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  ///   name: 'יוני כהן',
  /// );
  /// ```
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

      // ה-listener של authStateChanges יטפל בעדכון הסופי
    } catch (e) {
      debugPrint('❌ UserContext.signUp: שגיאה - $e');
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false, error)');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false, finally)');
    }
  }

  // === התחברות ===

  /// מתחבר עם אימייל וסיסמה
  /// 
  /// Example:
  /// ```dart
  /// await userContext.signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
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
      
      // ה-listener של authStateChanges יטפל בטעינת המשתמש
    } catch (e) {
      debugPrint('❌ UserContext.signIn: שגיאה - $e');
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false, error)');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() (isLoading=false, finally)');
    }
  }

  // === התנתקות ===

  /// מתנתק מהמערכת
  /// 
  /// Example:
  /// ```dart
  /// await userContext.signOut();
  /// ```
  Future<void> signOut() async {
    debugPrint('👋 UserContext.signOut: מתנתק');

    try {
      await _authService.signOut();
      debugPrint('✅ UserContext.signOut: התנתקות הושלמה');
      
      // ה-listener של authStateChanges יטפל בניקוי ה-state
    } catch (e) {
      debugPrint('❌ UserContext.signOut: שגיאה - $e');
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
  /// Example:
  /// ```dart
  /// final updatedUser = user.copyWith(name: 'שם חדש');
  /// await userContext.saveUser(updatedUser);
  /// ```
  Future<void> saveUser(UserEntity user) async {
    debugPrint('💾 UserContext.saveUser: שומר משתמש ${user.id}');

    try {
      _user = await _repository.saveUser(user);
      notifyListeners();
      debugPrint('✅ UserContext.saveUser: משתמש נשמר');
    } catch (e) {
      debugPrint('❌ UserContext.saveUser: שגיאה - $e');
      rethrow;
    }
  }

  // === איפוס סיסמה ===

  /// שולח מייל לאיפוס סיסמה
  /// 
  /// Example:
  /// ```dart
  /// await userContext.sendPasswordResetEmail('user@example.com');
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('📧 UserContext.sendPasswordResetEmail: שולח מייל ל-$email');

    try {
      await _authService.sendPasswordResetEmail(email);
      debugPrint('✅ UserContext.sendPasswordResetEmail: מייל נשלח');
    } catch (e) {
      debugPrint('❌ UserContext.sendPasswordResetEmail: שגיאה - $e');
      rethrow;
    }
  }

  // === Preferences ===

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (themeMode=$mode)');
  }

  void toggleCompactView() {
    _compactView = !_compactView;
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (compactView=$_compactView)');
  }

  void toggleShowPrices() {
    _showPrices = !_showPrices;
    _savePreferences();
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() (showPrices=$_showPrices)');
  }

  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _compactView = false;
    _showPrices = true;
  }

  // === Cleanup ===

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
