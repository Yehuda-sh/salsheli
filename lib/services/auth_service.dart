// 📄 File: lib/services/auth_service.dart
//
// 🇮🇱 שירות אימות משתמשים עם Firebase Authentication:
//     - רישום משתמשים חדשים
//     - התחברות עם אימייל וסיסמה
//     - התנתקות
//     - איפוס סיסמה
//     - מעקב אחר מצב ההתחברות (Stream)
//
// 🇬🇧 User authentication service with Firebase Authentication:
//     - Register new users
//     - Sign in with email & password
//     - Sign out
//     - Password reset
//     - Auth state tracking (Stream)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  // === רישום משתמש חדש ===

  /// רושם משתמש חדש עם אימייל וסיסמה
  /// 
  /// Throws:
  /// - Exception אם הרישום נכשל
  /// 
  /// Example:
  /// ```dart
  /// final credential = await authService.signUp(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  ///   name: 'יוני כהן',
  /// );
  /// ```
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('🔐 AuthService.signUp: רושם משתמש חדש - $email');

      // יצירת משתמש ב-Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // עדכון שם התצוגה
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      debugPrint('✅ AuthService.signUp: רישום הושלם - ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService.signUp: שגיאת Firebase - ${e.code}');

      // המרת קודי שגיאה לעברית
      switch (e.code) {
        case 'weak-password':
          throw Exception('הסיסמה חלשה מדי');
        case 'email-already-in-use':
          throw Exception('האימייל כבר בשימוש');
        case 'invalid-email':
          throw Exception('פורמט אימייל לא תקין');
        case 'operation-not-allowed':
          throw Exception('פעולה לא מורשית');
        default:
          throw Exception('שגיאה ברישום: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ AuthService.signUp: שגיאה כללית - $e');
      throw Exception('שגיאה ברישום: $e');
    }
  }

  // === התחברות ===

  /// מתחבר עם אימייל וסיסמה
  /// 
  /// Throws:
  /// - Exception אם ההתחברות נכשלה
  /// 
  /// Example:
  /// ```dart
  /// final credential = await authService.signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 AuthService.signIn: מתחבר - $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ AuthService.signIn: התחברות הושלמה - ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService.signIn: שגיאת Firebase - ${e.code}');

      // המרת קודי שגיאה לעברית
      switch (e.code) {
        case 'user-not-found':
          throw Exception('משתמש לא נמצא');
        case 'wrong-password':
          throw Exception('סיסמה שגויה');
        case 'invalid-email':
          throw Exception('פורמט אימייל לא תקין');
        case 'user-disabled':
          throw Exception('המשתמש חסום');
        case 'invalid-credential':
          throw Exception('פרטי התחברות שגויים');
        default:
          throw Exception('שגיאה בהתחברות: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ AuthService.signIn: שגיאה כללית - $e');
      throw Exception('שגיאה בהתחברות: $e');
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
      debugPrint('🔐 AuthService.signOut: מתנתק');
      await _auth.signOut();
      debugPrint('✅ AuthService.signOut: התנתקות הושלמה');
    } catch (e) {
      debugPrint('❌ AuthService.signOut: שגיאה - $e');
      throw Exception('שגיאה בהתנתקות: $e');
    }
  }

  // === איפוס סיסמה ===

  /// שולח מייל לאיפוס סיסמה
  /// 
  /// Throws:
  /// - Exception אם השליחה נכשלה
  /// 
  /// Example:
  /// ```dart
  /// await authService.sendPasswordResetEmail('user@example.com');
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('🔐 AuthService.sendPasswordResetEmail: שולח מייל ל-$email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ AuthService.sendPasswordResetEmail: מייל נשלח');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService.sendPasswordResetEmail: שגיאת Firebase - ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('משתמש לא נמצא');
        case 'invalid-email':
          throw Exception('פורמט אימייל לא תקין');
        default:
          throw Exception('שגיאה בשליחת מייל: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ AuthService.sendPasswordResetEmail: שגיאה כללית - $e');
      throw Exception('שגיאה בשליחת מייל: $e');
    }
  }

  // === מידע על המשתמש ===

  /// מחזיר את האימייל של המשתמש הנוכחי
  String? get currentUserEmail => _auth.currentUser?.email;

  /// מחזיר את שם התצוגה של המשתמש הנוכחי
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  /// מחזיר האם האימייל אומת
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // === שליחת אימות אימייל ===

  /// שולח מייל אימות למשתמש הנוכחי
  /// 
  /// Example:
  /// ```dart
  /// await authService.sendEmailVerification();
  /// ```
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('אין משתמש מחובר');
      }

      debugPrint('🔐 AuthService.sendEmailVerification: שולח מייל אימות');
      await _auth.currentUser!.sendEmailVerification();
      debugPrint('✅ AuthService.sendEmailVerification: מייל נשלח');
    } catch (e) {
      debugPrint('❌ AuthService.sendEmailVerification: שגיאה - $e');
      throw Exception('שגיאה בשליחת מייל אימות: $e');
    }
  }

  // === עדכון פרופיל ===

  /// מעדכן את שם התצוגה של המשתמש
  /// 
  /// Example:
  /// ```dart
  /// await authService.updateDisplayName('יוני כהן');
  /// ```
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('אין משתמש מחובר');
      }

      debugPrint('🔐 AuthService.updateDisplayName: מעדכן שם ל-$displayName');
      await _auth.currentUser!.updateDisplayName(displayName);
      await _auth.currentUser!.reload();
      debugPrint('✅ AuthService.updateDisplayName: שם עודכן');
    } catch (e) {
      debugPrint('❌ AuthService.updateDisplayName: שגיאה - $e');
      throw Exception('שגיאה בעדכון שם: $e');
    }
  }

  // === מחיקת חשבון ===

  /// מוחק את חשבון המשתמש הנוכחי
  /// 
  /// ⚠️ פעולה בלתי הפיכה!
  /// 
  /// Example:
  /// ```dart
  /// await authService.deleteAccount();
  /// ```
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('אין משתמש מחובר');
      }

      debugPrint('🔐 AuthService.deleteAccount: מוחק חשבון');
      await _auth.currentUser!.delete();
      debugPrint('✅ AuthService.deleteAccount: חשבון נמחק');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService.deleteAccount: שגיאת Firebase - ${e.code}');

      if (e.code == 'requires-recent-login') {
        throw Exception('נדרשת התחברות מחדש למחיקת החשבון');
      }

      throw Exception('שגיאה במחיקת חשבון: ${e.message}');
    } catch (e) {
      debugPrint('❌ AuthService.deleteAccount: שגיאה כללית - $e');
      throw Exception('שגיאה במחיקת חשבון: $e');
    }
  }

  // === טעינה מחדש של המשתמש ===

  /// טוען מחדש את פרטי המשתמש מהשרת
  /// 
  /// Example:
  /// ```dart
  /// await authService.reloadUser();
  /// ```
  Future<void> reloadUser() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('אין משתמש מחובר');
      }

      debugPrint('🔐 AuthService.reloadUser: טוען מחדש');
      await _auth.currentUser!.reload();
      debugPrint('✅ AuthService.reloadUser: נטען מחדש');
    } catch (e) {
      debugPrint('❌ AuthService.reloadUser: שגיאה - $e');
      throw Exception('שגיאה בטעינה מחדש: $e');
    }
  }
}
