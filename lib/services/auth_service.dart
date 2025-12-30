// 📄 lib/services/auth_service.dart
//
// שירות אימות עוטף Firebase Auth - הרשמה, התחברות, התנתקות, איפוס סיסמה.
// כולל הודעות שגיאה בעברית (AppStrings), עדכון פרופיל, ומחיקת חשבון.
//
// 🔗 Related: FirebaseAuth, AppStrings.auth, UserContext

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_strings.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // === Getters ===
  
  /// Stream של מצב התחברות - מאזין לשינויים בזמן אמת
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// משתמש נוכחי (null אם לא מחובר)
  User? get currentUser => _auth.currentUser;

  /// האם המשתמש מחובר
  bool get isSignedIn => _auth.currentUser != null;

  /// userId של המשתמש הנוכחי
  String? get currentUserId => _auth.currentUser?.uid;

  /// אימייל של המשתמש הנוכחי
  String? get currentUserEmail => _auth.currentUser?.email;

  /// שם התצוגה של המשתמש הנוכחי
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  /// האם האימייל אומת
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // === רישום משתמש חדש ===

  /// רושם משתמש חדש עם אימייל וסיסמה
  /// 
  /// Throws:
  /// - Exception עם הודעה בעברית מ-AppStrings.auth אם הרישום נכשל
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authService.signUp(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///     name: 'יוני כהן',
  ///   );
  ///   print('נרשמת בהצלחה!');
  /// } catch (e) {
  ///   print('שגיאה: $e'); // הודעה בעברית
  /// }
  /// ```
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 AuthService.signUp: רושם משתמש חדש');
      }

      // יצירת משתמש ב-Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // עדכון שם התצוגה
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      if (kDebugMode) {
        debugPrint('✅ AuthService.signUp: רישום הושלם - ${credential.user?.uid}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.signUp: שגיאת Firebase - ${e.code}');
      }

      // המרת קודי שגיאה לעברית דרך AppStrings
      final errorMessage = _getSignUpErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.signUp: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.signUpError(e.toString()));
    }
  }

  // === התחברות ===

  /// מתחבר עם אימייל וסיסמה
  /// 
  /// Throws:
  /// - Exception עם הודעה בעברית מ-AppStrings.auth אם ההתחברות נכשלה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authService.signIn(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('התחברת בהצלחה!');
  /// } catch (e) {
  ///   print('שגיאה: $e'); // הודעה בעברית
  /// }
  /// ```
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 AuthService.signIn: מתחבר');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ AuthService.signIn: התחברות הושלמה - ${credential.user?.uid}');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.signIn: שגיאת Firebase - ${e.code}');
      }

      // המרת קודי שגיאה לעברית דרך AppStrings
      final errorMessage = _getSignInErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.signIn: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.signInError(e.toString()));
    }
  }

  // === התנתקות ===

  /// מתנתק מהמערכת
  /// 
  /// Example:
  /// ```dart
  /// await authService.signOut();
  /// ```
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 AuthService.signOut: מתנתק');
      }
      await _auth.signOut();
      if (kDebugMode) {
        debugPrint('✅ AuthService.signOut: התנתקות הושלמה');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.signOut: שגיאה - $e');
      }
      throw Exception(AppStrings.auth.signOutError(e.toString()));
    }
  }

  // === איפוס סיסמה ===

  /// שולח מייל לאיפוס סיסמה
  /// 
  /// Throws:
  /// - Exception עם הודעה בעברית אם השליחה נכשלה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.sendPasswordResetEmail('user@example.com');
  ///   print(AppStrings.auth.resetEmailSent);
  /// } catch (e) {
  ///   print('שגיאה: $e');
  /// }
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 AuthService.sendPasswordResetEmail: שולח מייל');
      }
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        debugPrint('✅ AuthService.sendPasswordResetEmail: מייל נשלח');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.sendPasswordResetEmail: שגיאת Firebase - ${e.code}');
      }

      final errorMessage = _getResetPasswordErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.sendPasswordResetEmail: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.resetEmailError(e.toString()));
    }
  }

  // === שליחת אימות אימייל ===

  /// שולח מייל אימות למשתמש הנוכחי
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר או אם השליחה נכשלה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.sendEmailVerification();
  ///   print(AppStrings.auth.verificationEmailSent);
  /// } catch (e) {
  ///   print('שגיאה: $e');
  /// }
  /// ```
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.sendEmailVerification: שולח מייל אימות');
      }
      await _auth.currentUser!.sendEmailVerification();
      if (kDebugMode) {
        debugPrint('✅ AuthService.sendEmailVerification: מייל נשלח');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.sendEmailVerification: שגיאה - $e');
      }
      throw Exception(AppStrings.auth.verificationEmailError(e.toString()));
    }
  }

  // === עדכון פרופיל ===

  /// מעדכן את שם התצוגה של המשתמש
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר או אם העדכון נכשל
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updateDisplayName('יוני כהן');
  ///   print(AppStrings.auth.displayNameUpdated);
  /// } catch (e) {
  ///   print('שגיאה: $e');
  /// }
  /// ```
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.updateDisplayName: מעדכן שם');
      }
      await _auth.currentUser!.updateDisplayName(displayName);
      await _auth.currentUser!.reload();
      if (kDebugMode) {
        debugPrint('✅ AuthService.updateDisplayName: שם עודכן');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.updateDisplayName: שגיאה - $e');
      }
      throw Exception(AppStrings.auth.updateDisplayNameError(e.toString()));
    }
  }

  /// מעדכן את האימייל של המשתמש
  /// 
  /// ⚠️ דורש re-authentication לפני שימוש!
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר, אם דורש re-auth, או אם העדכון נכשל
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   // רק אם המשתמש התחבר לאחרונה
  ///   await authService.updateEmail('newemail@example.com');
  ///   print(AppStrings.auth.emailUpdated);
  /// } on Exception catch (e) {
  ///   if (e.toString().contains('requires-recent-login')) {
  ///     // צריך re-authentication
  ///     await authService.reauthenticate(email: '...', password: '...');
  ///     await authService.updateEmail('newemail@example.com');
  ///   }
  /// }
  /// ```
  Future<void> updateEmail(String newEmail) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.updateEmail: מעדכן אימייל');
      }
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
      await _auth.currentUser!.reload();
      if (kDebugMode) {
        debugPrint('✅ AuthService.updateEmail: אימייל עודכן');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.updateEmail: שגיאת Firebase - ${e.code}');
      }

      if (e.code == 'requires-recent-login') {
        throw Exception(AppStrings.auth.errorRequiresRecentLogin);
      } else if (e.code == 'email-already-in-use') {
        throw Exception(AppStrings.auth.errorEmailInUse);
      } else if (e.code == 'invalid-email') {
        throw Exception(AppStrings.auth.errorInvalidEmail);
      }

      throw Exception(AppStrings.auth.updateEmailError(e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.updateEmail: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.updateEmailError(e.toString()));
    }
  }

  /// מעדכן את הסיסמה של המשתמש
  /// 
  /// ⚠️ דורש re-authentication לפני שימוש!
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר, אם דורש re-auth, או אם העדכון נכשל
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   // רק אם המשתמש התחבר לאחרונה
  ///   await authService.updatePassword('newPassword123');
  ///   print(AppStrings.auth.passwordUpdated);
  /// } on Exception catch (e) {
  ///   if (e.toString().contains('requires-recent-login')) {
  ///     // צריך re-authentication
  ///     await authService.reauthenticate(email: '...', password: '...');
  ///     await authService.updatePassword('newPassword123');
  ///   }
  /// }
  /// ```
  Future<void> updatePassword(String newPassword) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.updatePassword: מעדכן סיסמה');
      }
      await _auth.currentUser!.updatePassword(newPassword);
      if (kDebugMode) {
        debugPrint('✅ AuthService.updatePassword: סיסמה עודכנה');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.updatePassword: שגיאת Firebase - ${e.code}');
      }

      if (e.code == 'requires-recent-login') {
        throw Exception(AppStrings.auth.errorRequiresRecentLogin);
      } else if (e.code == 'weak-password') {
        throw Exception(AppStrings.auth.errorWeakPassword);
      }

      throw Exception(AppStrings.auth.updatePasswordError(e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.updatePassword: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.updatePasswordError(e.toString()));
    }
  }

  // === Re-Authentication ===

  /// מבצע re-authentication למשתמש הנוכחי
  /// 
  /// נדרש לפני פעולות רגישות כמו:
  /// - מחיקת חשבון
  /// - עדכון אימייל
  /// - עדכון סיסמה
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר או אם ה-re-auth נכשל
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   // לפני עדכון אימייל
  ///   await authService.reauthenticate(
  ///     email: currentUser.email!,
  ///     password: userPassword,
  ///   );
  ///   await authService.updateEmail('newemail@example.com');
  /// } catch (e) {
  ///   print('Re-authentication נכשל: $e');
  /// }
  /// ```
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.reauthenticate: מבצע re-authentication');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
      if (kDebugMode) {
        debugPrint('✅ AuthService.reauthenticate: הושלם בהצלחה');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.reauthenticate: שגיאת Firebase - ${e.code}');
      }

      final errorMessage = _getSignInErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.reauthenticate: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.signInError(e.toString()));
    }
  }

  // === מחיקת חשבון ===

  /// מוחק את חשבון המשתמש הנוכחי
  /// 
  /// ⚠️ פעולה בלתי הפיכה!
  /// ⚠️ דורש re-authentication לפני שימוש!
  /// 
  /// Throws:
  /// - Exception אם אין משתמש מחובר, אם דורש re-auth, או אם המחיקה נכשלה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   // דרוש re-authentication קודם
  ///   await authService.reauthenticate(email: '...', password: '...');
  ///   await authService.deleteAccount();
  ///   print(AppStrings.auth.accountDeleted);
  /// } catch (e) {
  ///   print('שגיאה: $e');
  /// }
  /// ```
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.deleteAccount: מוחק חשבון');
      }
      await _auth.currentUser!.delete();
      if (kDebugMode) {
        debugPrint('✅ AuthService.deleteAccount: חשבון נמחק');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.deleteAccount: שגיאת Firebase - ${e.code}');
      }

      if (e.code == 'requires-recent-login') {
        throw Exception(AppStrings.auth.errorRequiresRecentLogin);
      }

      throw Exception(AppStrings.auth.deleteAccountError(e.message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.deleteAccount: שגיאה כללית - $e');
      }
      throw Exception(AppStrings.auth.deleteAccountError(e.toString()));
    }
  }

  // === טעינה מחדש של המשתמש ===

  /// טוען מחדש את פרטי המשתמש מהשרת
  /// 
  /// שימושי לאחר:
  /// - עדכון פרופיל
  /// - אימות אימייל
  /// - כל שינוי בפרטי המשתמש
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updateDisplayName('שם חדש');
  ///   await authService.reloadUser(); // רענון הפרטים
  ///   print(authService.currentUserDisplayName); // שם מעודכן
  /// } catch (e) {
  ///   print('שגיאה: $e');
  /// }
  /// ```
  Future<void> reloadUser() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception(AppStrings.auth.errorNoUserLoggedIn);
      }

      if (kDebugMode) {
        debugPrint('🔐 AuthService.reloadUser: טוען מחדש');
      }
      await _auth.currentUser!.reload();
      if (kDebugMode) {
        debugPrint('✅ AuthService.reloadUser: נטען מחדש');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthService.reloadUser: שגיאה - $e');
      }
      throw Exception(AppStrings.auth.reloadUserError(e.toString()));
    }
  }

  // ========================================
  // Private Helper Methods - Error Messages
  // ========================================

  /// מחזיר הודעת שגיאה מתאימה לקוד שגיאת רישום
  String _getSignUpErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return AppStrings.auth.errorWeakPassword;
      case 'email-already-in-use':
        return AppStrings.auth.errorEmailInUse;
      case 'invalid-email':
        return AppStrings.auth.errorInvalidEmail;
      case 'operation-not-allowed':
        return AppStrings.auth.errorOperationNotAllowed;
      case 'network-request-failed':
        return AppStrings.auth.errorNetworkRequestFailed;
      default:
        return AppStrings.auth.signUpError(code);
    }
  }

  /// מחזיר הודעת שגיאה מתאימה לקוד שגיאת התחברות
  String _getSignInErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return AppStrings.auth.errorUserNotFound;
      case 'wrong-password':
        return AppStrings.auth.errorWrongPassword;
      case 'invalid-email':
        return AppStrings.auth.errorInvalidEmail;
      case 'user-disabled':
        return AppStrings.auth.errorUserDisabled;
      case 'invalid-credential':
        return AppStrings.auth.errorInvalidCredential;
      case 'too-many-requests':
        return AppStrings.auth.errorTooManyRequests;
      case 'network-request-failed':
        return AppStrings.auth.errorNetworkRequestFailed;
      default:
        return AppStrings.auth.signInError(code);
    }
  }

  /// מחזיר הודעת שגיאה מתאימה לקוד שגיאת איפוס סיסמה
  String _getResetPasswordErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return AppStrings.auth.errorUserNotFound;
      case 'invalid-email':
        return AppStrings.auth.errorInvalidEmail;
      case 'network-request-failed':
        return AppStrings.auth.errorNetworkRequestFailed;
      default:
        return AppStrings.auth.resetEmailError(code);
    }
  }
}
