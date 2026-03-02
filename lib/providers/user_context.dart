// 📄 lib/providers/user_context.dart
//
// Provider לניהול הקשר המשתמש - פרופיל, אימות, והעדפות UI.
// מאזין ל-Firebase Auth ומספק Single Source of Truth למצב משתמש.
//
// 🔗 Related: UserEntity, UserRepository, AuthService

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:memozap/data/onboarding_data.dart';

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

  // 🆕 v2.2: מצב מיוחד - Auth הצליח אבל Profile נכשל
  bool _hasAuthButNoProfile = false;

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

  // ==========================================================================
  // 🆕 v2.2: SAFE NOTIFICATION HELPERS
  // ==========================================================================

  /// 🔒 קורא ל-notifyListeners() רק אם ה-provider לא disposed
  ///
  /// **מטרה:** למנוע crash של "A ChangeNotifier was used after being disposed"
  ///
  /// **מתי זה קורה:**
  /// - משתמש עוזב מסך באמצע פעולה async
  /// - Navigation מהיר בין מסכים
  /// - Hot reload בזמן פיתוח
  @protected
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      debugPrint('⚠️ UserContext._notifySafe: Skipped (disposed)');
    }
  }

  /// 🔒 מריץ פעולה async עם טיפול בשגיאות ובדיקת dispose
  ///
  /// **מטרה:** להפחית boilerplate של try-catch-finally
  ///
  /// **Parameters:**
  /// - [operation]: שם הפעולה (לצורכי logging)
  /// - [action]: הפעולה ה-async לביצוע
  /// - [setLoading]: האם לעדכן את _isLoading (ברירת מחדל: true)
  /// - [rethrowError]: האם לזרוק מחדש שגיאות (ברירת מחדל: true)
  /// - [errorMessagePrefix]: prefix להודעת שגיאה
  ///
  /// **Returns:** הערך שהוחזר מה-action, או null אם נכשל
  Future<T?> _runAsync<T>({
    required String operation,
    required Future<T> Function() action,
    bool setLoading = true,
    bool rethrowError = true,
    String? errorMessagePrefix,
  }) async {
    if (_isDisposed) {
      debugPrint('⚠️ UserContext.$operation: Aborted (disposed)');
      return null;
    }

    if (setLoading) {
      _isLoading = true;
      _errorMessage = null;
      _notifySafe();
    }

    try {
      final result = await action();
      _errorMessage = null;
      return result;
    } catch (e) {
      debugPrint('❌ UserContext.$operation: שגיאה - $e');
      _errorMessage = errorMessagePrefix != null
          ? '$errorMessagePrefix: ${e.toString()}'
          : e.toString();
      if (rethrowError) rethrow;
      return null;
    } finally {
      if (setLoading) {
        _isLoading = false;
      }
      _notifySafe();
    }
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// המשתמש הנוכחי (null אם לא מחובר)
  UserEntity? get user => _user;

  /// האם משתמש מחובר כרגע (יש Auth + Profile)
  bool get isLoggedIn => _user != null && _authService.isSignedIn;

  /// 🆕 v2.2: האם יש Auth אבל אין Profile (מצב שגיאה ניתן לשחזור)
  bool get hasAuthButNoProfile => _hasAuthButNoProfile;

  /// האם בתהליך טעינה
  bool get isLoading => _isLoading;

  /// האם יש שגיאה
  bool get hasError => _errorMessage != null;

  /// הודעת השגיאה (null אם אין שגיאה)
  String? get errorMessage => _errorMessage;

  /// שם התצוגה של המשתמש
  String? get displayName => _user?.name ?? _authService.currentUserDisplayName;

  /// מזהה המשתמש
  String? get userId => _user?.id ?? _authService.currentUserId;

  /// אימייל המשתמש
  String? get userEmail => _user?.email ?? _authService.currentUserEmail;

  /// מזהה משק הבית של המשתמש
  String? get householdId => _user?.householdId;

  /// 🔒 האם ה-Provider כבר disposed (לטסטים)
  @visibleForTesting
  bool get isDisposed => _isDisposed;

  // UI Preferences Getters
  ThemeMode get themeMode => _themeMode;
  bool get compactView => _compactView;
  bool get showPrices => _showPrices;

  // ==========================================================================
  // PREFERENCES
  // ==========================================================================

  /// טוען העדפות UI מ-SharedPreferences
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
    } finally {
      _notifySafe();
    }
  }

  /// שומר העדפות UI ל-SharedPreferences
  Future<void> _savePreferences() async {
    if (_isDisposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setBool('compactView', _compactView);
      await prefs.setBool('showPrices', _showPrices);
    } catch (e) {
      debugPrint('❌ UserContext._savePreferences: שגיאה בשמירת העדפות - $e');
    }
  }

  /// מגדיר מצב ערכת נושא
  void setThemeMode(ThemeMode mode) {
    if (_isDisposed) return;
    _themeMode = mode;
    _savePreferences();
    _notifySafe();
  }

  /// משנה מצב תצוגה קומפקטית
  void toggleCompactView() {
    if (_isDisposed) return;
    _compactView = !_compactView;
    _savePreferences();
    _notifySafe();
  }

  /// משנה מצב הצגת מחירים
  void toggleShowPrices() {
    if (_isDisposed) return;
    _showPrices = !_showPrices;
    _savePreferences();
    _notifySafe();
  }

  /// מאפס את כל העדפות UI לברירת מחדל
  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _compactView = false;
    _showPrices = true;
  }

  // ==========================================================================
  // AUTH LISTENER
  // ==========================================================================

  /// מאזין לשינויים ב-Firebase Auth (real-time)
  void _listenToAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription = _authService.authStateChanges.listen(
      (firebaseUser) {
        // 🔒 בדיקת dispose לפני טיפול באירוע
        if (_isDisposed) return;

        if (firebaseUser != null) {
          // 🔒 אם בתהליך רישום - אל תיצור משתמש כאן
          if (_isSigningUp) return;

          // משתמש התחבר - טען את הפרטים מ-Firestore
          _loadUserFromFirestore(firebaseUser.uid).catchError((error) {
            if (_isDisposed) return;
            debugPrint('❌ שגיאה בטעינת משתמש: $error');
          });
        } else {
          // משתמש התנתק - נקה state
          _user = null;
          _hasAuthButNoProfile = false;
          _resetPreferences();
          _notifySafe();
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        debugPrint('❌ UserContext: שגיאה בהאזנה ל-Auth - $error');
      },
    );
  }

  // ==========================================================================
  // USER LOADING
  // ==========================================================================

  /// טוען משתמש מ-Firestore לפי ID
  ///
  /// 🆕 v2.2: מזהה מצב של "Auth OK but Profile Failed" לשחזור
  /// 🆕 v2.3: מנהל _isLoading בעצמו - UI מציג Loader בזמן טעינה ראשונית
  Future<void> _loadUserFromFirestore(String userId) async {
    if (_isDisposed) return;

    _isLoading = true;
    _notifySafe();

    try {
      _user = await _repository.fetchUser(userId);

      if (_user == null) {
        // צור משתמש חדש דרך Repository
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null && !_isDisposed) {
          _user = await _repository.createUser(
            userId: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'משתמש חדש',
          );
        }
      } else {
        // סנכרון נתוני Onboarding מהשרת למכשיר
        await _syncOnboardingFromServer(_user!);
      }

      _errorMessage = null;
      _hasAuthButNoProfile = false;
    } catch (e) {
      debugPrint('❌ UserContext._loadUserFromFirestore: שגיאה - $e');
      _errorMessage = 'שגיאה בטעינת פרטי משתמש';

      // 🆕 v2.2: סמן שיש Auth אבל אין Profile
      _hasAuthButNoProfile = _authService.isSignedIn && _user == null;
    } finally {
      _isLoading = false;
      _notifySafe();
    }
  }

  /// סנכרון נתוני Onboarding מהשרת ל-SharedPreferences
  Future<void> _syncOnboardingFromServer(UserEntity user) async {
    if (_isDisposed) return;

    try {
      debugPrint('🔄 UserContext: מסנכרן נתוני Onboarding מהשרת...');

      final serverOnboarding = OnboardingData(
        familySize: user.familySize,
        preferredStores: user.preferredStores.toSet(),
        shoppingFrequency: user.shoppingFrequency,
        shoppingDays: user.shoppingDays.toSet(),
        hasChildren: user.hasChildren,
        shareLists: user.shareLists,
        reminderTime: user.reminderTime,
      );

      await serverOnboarding.save();

      if (user.seenOnboarding) {
        await OnboardingData.markAsCompleted();
      }

      debugPrint('✅ UserContext: נתוני Onboarding סונכרנו מהשרת');
    } catch (e) {
      debugPrint('⚠️ UserContext._syncOnboardingFromServer: שגיאה - $e');
      // לא זורקים שגיאה - זה לא קריטי
    }
  }

  // ==========================================================================
  // AUTHENTICATION
  // ==========================================================================

  /// רושם משתמש חדש עם Firebase Auth ויוצר רשומה ב-Firestore
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isSigningUp = true;
    try {
      await _runAsync(
        operation: 'signUp',
        errorMessagePrefix: 'שגיאה ברישום',
        action: () async {
          final credential = await _authService.signUp(
            email: email,
            password: password,
            name: name,
          );

          if (credential.user != null && !_isDisposed) {
            try {
              final onboardingData = await OnboardingData.load();
              final hasSeenOnboarding = await OnboardingData.hasSeenOnboarding();

              debugPrint('📋 UserContext.signUp: טוען נתוני Onboarding לסנכרון');

              _user = await _repository.createUser(
                userId: credential.user!.uid,
                email: email,
                name: name,
                phone: phone,
                preferredStores: onboardingData.preferredStores.toList(),
                familySize: onboardingData.familySize,
                shoppingFrequency: onboardingData.shoppingFrequency,
                shoppingDays: onboardingData.shoppingDays.toList(),
                hasChildren: onboardingData.hasChildren,
                shareLists: onboardingData.shareLists,
                reminderTime: onboardingData.reminderTime,
                seenOnboarding: hasSeenOnboarding,
              );

              debugPrint('✅ UserContext.signUp: נתוני Onboarding נשמרו בשרת!');
            } catch (profileError) {
              // 🔄 Rollback: אם יצירת הפרופיל נכשלה - מחק את המשתמש מ-Auth
              debugPrint('❌ UserContext.signUp: יצירת פרופיל נכשלה, מבצע rollback');
              try {
                await credential.user?.delete();
                debugPrint('🗑️ UserContext.signUp: משתמש Auth נמחק (rollback)');
              } catch (deleteError) {
                debugPrint('⚠️ UserContext.signUp: לא הצלחתי למחוק Auth user - $deleteError');
              }
              rethrow;
            }
          }
        },
      );
    } finally {
      _isSigningUp = false;
    }
  }

  /// מתחבר עם אימייל וסיסמה
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _runAsync(
      operation: 'signIn',
      errorMessagePrefix: 'שגיאה בהתחברות',
      action: () async {
        await _authService.signIn(email: email, password: password);
        // ה-listener של authStateChanges יטפל בטעינת המשתמש
      },
    );
  }

  /// התחברות/הרשמה עם Google
  ///
  /// אם משתמש חדש - יוצר פרופיל אוטומטית מנתוני Google.
  /// אם משתמש קיים - מתחבר כרגיל.
  Future<void> signInWithGoogle() async {
    await _runAsync(
      operation: 'signInWithGoogle',
      errorMessagePrefix: 'שגיאה בהתחברות עם Google',
      action: () async {
        final credential = await _authService.signInWithGoogle();
        // בדיקה אם משתמש חדש - יצירת פרופיל
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserFromSocialLogin(credential);
        }
        // ה-listener של authStateChanges יטפל בטעינת המשתמש
      },
    );
  }

  /// התחברות/הרשמה עם Apple
  ///
  /// אם משתמש חדש - יוצר פרופיל אוטומטית מנתוני Apple.
  /// אם משתמש קיים - מתחבר כרגיל.
  Future<void> signInWithApple() async {
    await _runAsync(
      operation: 'signInWithApple',
      errorMessagePrefix: 'שגיאה בהתחברות עם Apple',
      action: () async {
        final credential = await _authService.signInWithApple();
        // בדיקה אם משתמש חדש - יצירת פרופיל
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserFromSocialLogin(credential);
        }
        // ה-listener של authStateChanges יטפל בטעינת המשתמש
      },
    );
  }

  /// יצירת משתמש חדש מ-Social Login (Google/Apple)
  ///
  /// מחלץ את פרטי המשתמש מ-credential ויוצר רשומה ב-Firestore.
  Future<void> _createUserFromSocialLogin(firebase_auth.UserCredential credential) async {
    final user = credential.user!;
    final name = user.displayName ?? user.email?.split('@').first ?? 'משתמש';

    debugPrint('📋 UserContext._createUserFromSocialLogin: יוצר פרופיל עבור ${user.uid}');

    _user = await _repository.createUser(
      userId: user.uid,
      name: name,
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
    );

    debugPrint('✅ UserContext._createUserFromSocialLogin: פרופיל נוצר בהצלחה!');
  }

  /// התנתקות רגילה מהמערכת (שומר seenOnboarding)
  Future<void> signOut() async {
    await _runAsync(
      operation: 'signOut',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בהתנתקות',
      action: () async {
        debugPrint('🚪 UserContext.signOut: התנתקות רגילה (שומר seenOnboarding)');

        // 🔒 קודם כל מתנתקים מ-Firebase - אם זה נכשל, לא מנקים state מקומי
        await _authService.signOut();

        // רק אחרי הצלחת ההתנתקות - מנקים נתונים מקומיים
        final prefs = await SharedPreferences.getInstance();
        final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

        await prefs.clear();

        if (seenOnboarding) {
          await prefs.setBool('seenOnboarding', true);
        }

        _user = null;
        _isLoading = false;
        _hasAuthButNoProfile = false;
        _resetPreferences();

        debugPrint('✅ UserContext.signOut: הושלם בהצלחה');
      },
    );
  }

  /// התנתקות מלאה + מחיקת כל הנתונים המקומיים
  Future<void> signOutAndClearAllData() async {
    await _runAsync(
      operation: 'signOutAndClearAllData',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בהתנתקות ומחיקת נתונים',
      action: () async {
        debugPrint('🔥 UserContext.signOutAndClearAllData: התנתקות מלאה!');

        // 🔒 קודם כל מתנתקים מ-Firebase - אם זה נכשל, לא מנקים state מקומי
        await _authService.signOut();

        // רק אחרי הצלחת ההתנתקות - מנקים נתונים מקומיים
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        _user = null;
        _isLoading = false;
        _hasAuthButNoProfile = false;
        _resetPreferences();

        debugPrint('🎉 UserContext.signOutAndClearAllData: הושלם בהצלחה!');
      },
    );
  }

  /// Alias ל-signOut() לתאימות אחורה
  Future<void> logout() async => signOut();

  // ==========================================================================
  // USER MANAGEMENT
  // ==========================================================================

  /// שומר/מעדכן פרטי משתמש ב-Firestore
  Future<void> saveUser(UserEntity user) async {
    await _runAsync(
      operation: 'saveUser',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בשמירת פרטי משתמש',
      action: () async {
        _user = await _repository.saveUser(user);
      },
    );
  }

  /// מעדכן פרופיל משתמש (עדכון חלקי)
  Future<void> updateUserProfile({String? name, String? avatar}) async {
    if (_user == null) {
      debugPrint('❌ UserContext.updateUserProfile: אין משתמש מחובר');
      throw UserRepositoryException('אין משתמש מחובר');
    }

    await _runAsync(
      operation: 'updateUserProfile',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בעדכון פרופיל',
      action: () async {
        await _repository.updateProfile(
          userId: _user!.id,
          name: name,
          avatar: avatar,
        );
        _user = await _repository.fetchUser(_user!.id);
      },
    );
  }

  /// שולח מייל לאיפוס סיסמה
  Future<void> sendPasswordResetEmail(String email) async {
    await _runAsync(
      operation: 'sendPasswordResetEmail',
      setLoading: false,
      errorMessagePrefix: 'שגיאה בשליחת מייל לאיפוס סיסמה',
      action: () async {
        await _authService.sendPasswordResetEmail(email);
      },
    );
  }

  // ==========================================================================
  // ERROR RECOVERY
  // ==========================================================================

  /// ניסיון חוזר לטעינת משתמש אחרי שגיאה
  ///
  /// 🔄 _loadUserFromFirestore מנהל את _isLoading בעצמו,
  /// אז retry רק מנקה שגיאה קודמת ומעביר את הקריאה.
  Future<void> retry() async {
    if (_isDisposed) return;

    _errorMessage = null;

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserFromFirestore(currentUser.uid);
    }
  }

  /// ניקוי מלא של כל ה-state
  Future<void> clearAll() async {
    if (_isDisposed) return;

    _user = null;
    _errorMessage = null;
    _isLoading = false;
    _hasAuthButNoProfile = false;
    _resetPreferences();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('themeMode');
      await prefs.remove('compactView');
      await prefs.remove('showPrices');
    } catch (e) {
      debugPrint('⚠️ שגיאה בניקוי SharedPreferences: $e');
    }

    _notifySafe();
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  @override
  void dispose() {
    debugPrint('🗑️ UserContext.dispose()');
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
