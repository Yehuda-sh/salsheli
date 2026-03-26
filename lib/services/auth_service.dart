// 📄 lib/services/auth_service.dart
//
// שירות אימות עוטף Firebase Auth - הרשמה, התחברות, התנתקות, איפוס סיסמה.
// כולל הודעות שגיאה בעברית (AppStrings), עדכון פרופיל, ומחיקת חשבון.
//
// ✅ תיקונים:
//    - AuthException typed exception עם AuthErrorCode enum
//    - signOut() מחזיר bool להצלחה/כישלון
//    - AuthUser & SocialLoginResult DTOs — חוסמים דליפת firebase_auth ל-providers
//
// 🔗 Related: FirebaseAuth, AppStrings.auth, UserContext

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../l10n/app_strings.dart';

// ========================================
// 🆕 Auth DTOs — חוסמים דליפת firebase_auth
// ========================================

/// DTO פשוט למשתמש מאומת — חוסם דליפת firebase_auth.User ל-providers
///
/// מכיל רק את השדות שה-UI/Provider צריכים.
/// UserContext מאזין ל-Stream<AuthUser?> במקום Stream<firebase_auth.User?>.
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
  });

  /// יוצר AuthUser מ-firebase_auth.User
  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
    );
  }
}

/// תוצאת Social Login (Google/Apple) — חוסם דליפת UserCredential ל-providers
///
/// מכיל את כל המידע שה-Provider צריך כדי ליצור פרופיל למשתמש חדש,
/// בלי לחשוף את firebase_auth.UserCredential.
class SocialLoginResult {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isNewUser;

  const SocialLoginResult({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.isNewUser,
  });

  /// יוצר SocialLoginResult מ-firebase_auth.UserCredential
  factory SocialLoginResult.fromCredential(UserCredential credential) {
    final user = credential.user!;
    return SocialLoginResult(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
    );
  }
}

// ========================================
// 🆕 Typed Auth Exceptions
// ========================================

/// קודי שגיאות אימות - Type-Safe!
///
/// מאפשר ל-UI layer לזהות סוג שגיאה בקלות:
/// ```dart
/// try {
///   await authService.signIn(email: '...', password: '...');
/// } on AuthException catch (e) {
///   if (e.code == AuthErrorCode.requiresRecentLogin) {
///     // בקש re-authentication
///   }
/// }
/// ```
enum AuthErrorCode {
  // === שגיאות כלליות ===
  unknown,
  noUserLoggedIn,
  networkError,
  timeout,

  // === שגיאות התחברות/הרשמה ===
  userNotFound,
  wrongPassword,
  invalidEmail,
  emailInUse,
  weakPassword,
  userDisabled,
  invalidCredential,
  tooManyRequests,
  operationNotAllowed,

  // === שגיאות פעולות רגישות ===
  requiresRecentLogin,

  // === שגיאות Social Login ===
  socialLoginCancelled,
  socialLoginFailed,
}

// ========================================
// 🆕 Timeout & Retry Constants
// ========================================

/// Timeout לפעולות אימות
/// 120s to allow Firebase Auth SDK to exhaust reCAPTCHA Enterprise retries
const Duration kAuthTimeout = Duration(seconds: 120);

/// שגיאת אימות מותאמת - Type-Safe!
///
/// כוללת:
/// - [code] - קוד שגיאה (enum) לזיהוי סוג השגיאה
/// - [message] - הודעה בעברית להצגה למשתמש
/// - [originalError] - השגיאה המקורית (לדיבוג)
///
/// **Usage:**
/// ```dart
/// try {
///   await authService.signIn(email: '...', password: '...');
/// } on AuthException catch (e) {
///   switch (e.code) {
///     case AuthErrorCode.userNotFound:
///       // הצג הודעה מתאימה
///       break;
///     case AuthErrorCode.requiresRecentLogin:
///       // בקש re-authentication
///       break;
///     default:
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(e.message)),
///       );
///   }
/// }
/// ```
class AuthException implements Exception {
  /// קוד השגיאה (enum)
  final AuthErrorCode code;

  /// הודעה בעברית להצגה למשתמש
  final String message;

  /// השגיאה המקורית (לדיבוג)
  final Object? originalError;

  const AuthException({
    required this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AuthException($code): $message';

  /// יצירת AuthException מקוד Firebase
  factory AuthException.fromFirebaseCode(String firebaseCode, String message) {
    final code = _mapFirebaseCode(firebaseCode);
    return AuthException(code: code, message: message);
  }

  /// המרת קוד Firebase ל-AuthErrorCode
  static AuthErrorCode _mapFirebaseCode(String firebaseCode) {
    switch (firebaseCode) {
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'email-already-in-use':
        return AuthErrorCode.emailInUse;
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'user-disabled':
        return AuthErrorCode.userDisabled;
      case 'invalid-credential':
        return AuthErrorCode.invalidCredential;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      case 'operation-not-allowed':
        return AuthErrorCode.operationNotAllowed;
      case 'requires-recent-login':
        return AuthErrorCode.requiresRecentLogin;
      case 'network-request-failed':
        return AuthErrorCode.networkError;
      default:
        return AuthErrorCode.unknown;
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// מבצע פעולה עם timeout
  Future<T> _withTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = kAuthTimeout,
  }) {
    return operation().timeout(
      timeout,
      onTimeout: () {
        throw AuthException(
          code: AuthErrorCode.timeout,
          message: AppStrings.auth.errorTimeout,
        );
      },
    );
  }

  // === Getters ===

  /// Stream של מצב התחברות — מחזיר AuthUser? במקום firebase_auth.User?
  ///
  /// חוסם דליפת firebase_auth ל-providers.
  Stream<AuthUser?> get authUserChanges =>
      _auth.authStateChanges().map((user) =>
          user != null ? AuthUser.fromFirebaseUser(user) : null);

  /// Stream מקורי של Firebase Auth — לשימוש פנימי בלבד
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// משתמש נוכחי — firebase_auth.User (לשימוש פנימי בלבד)
  User? get currentUser => _auth.currentUser;

  /// משתמש נוכחי כ-AuthUser DTO — בטוח לשימוש ב-providers
  AuthUser? get currentAuthUser {
    final user = _auth.currentUser;
    return user != null ? AuthUser.fromFirebaseUser(user) : null;
  }

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
  /// - [AuthException] עם קוד שגיאה והודעה בעברית אם הרישום נכשל
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
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.emailInUse) {
  ///     print('האימייל כבר בשימוש');
  ///   } else {
  ///     print('שגיאה: ${e.message}');
  ///   }
  /// }
  /// ```
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {

    try {
      // ✅ יצירת משתמש עם timeout ו-retry
      final credential = await _withTimeout(
        operation: () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

      // עדכון שם התצוגה (ללא retry - לא קריטי)
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      return credential;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      // ✅ AuthException typed במקום Exception גנרי
      final errorMessage = _getSignUpErrorMessage(e.code);
      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.signUpError(e.toString()),
        originalError: e,
      );
    }
  }

  // === התחברות ===

  /// מתחבר עם אימייל וסיסמה
  ///
  /// Throws:
  /// - [AuthException] עם קוד שגיאה והודעה בעברית אם ההתחברות נכשלה
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authService.signIn(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('התחברת בהצלחה!');
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.userNotFound) {
  ///     print('משתמש לא קיים');
  ///   } else {
  ///     print('שגיאה: ${e.message}');
  ///   }
  /// }
  /// ```
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {

    try {
      // ✅ עם timeout ו-retry
      final credential = await _withTimeout(
        operation: () => _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

      return credential;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      // ✅ AuthException typed במקום Exception גנרי
      final errorMessage = _getSignInErrorMessage(e.code);
      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.signInError(e.toString()),
        originalError: e,
      );
    }
  }

  // === Social Login ===

  /// התחברות עם Google
  ///
  /// מחזיר [SocialLoginResult] — DTO שחוסם דליפת firebase_auth ל-providers.
  /// אם המשתמש מבטל את הפעולה, זורק [AuthException] עם קוד [AuthErrorCode.socialLoginCancelled].
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await authService.signInWithGoogle();
  ///   if (result.isNewUser) {
  ///     // משתמש חדש - צור פרופיל
  ///   }
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.socialLoginCancelled) {
  ///     // המשתמש ביטל
  ///   }
  /// }
  /// ```
  Future<SocialLoginResult> signInWithGoogle() async {
    try {

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw AuthException(
          code: AuthErrorCode.socialLoginCancelled,
          message: AppStrings.auth.socialLoginCancelled,
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return SocialLoginResult.fromCredential(userCredential);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, AppStrings.auth.socialLoginError);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.socialLoginFailed,
        message: AppStrings.auth.socialLoginError,
        originalError: e,
      );
    }
  }

  /// התחברות עם Apple
  ///
  /// מחזיר [SocialLoginResult] — DTO שחוסם דליפת firebase_auth ל-providers.
  /// אם המשתמש מבטל את הפעולה, זורק [AuthException] עם קוד [AuthErrorCode.socialLoginCancelled].
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await authService.signInWithApple();
  ///   if (result.isNewUser) {
  ///     // משתמש חדש - צור פרופיל
  ///   }
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.socialLoginCancelled) {
  ///     // המשתמש ביטל
  ///   }
  /// }
  /// ```
  Future<SocialLoginResult> signInWithApple() async {
    try {

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      return SocialLoginResult.fromCredential(userCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException(
          code: AuthErrorCode.socialLoginCancelled,
          message: AppStrings.auth.socialLoginCancelled,
          originalError: e,
        );
      }
      throw AuthException(
        code: AuthErrorCode.socialLoginFailed,
        message: AppStrings.auth.socialLoginError,
        originalError: e,
      );
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, AppStrings.auth.socialLoginError);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.socialLoginFailed,
        message: AppStrings.auth.socialLoginError,
        originalError: e,
      );
    }
  }

  /// יוצר nonce אקראי לאבטחת Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// מחשב SHA256 של מחרוזת
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // === התנתקות ===

  /// מתנתק מהמערכת
  ///
  /// ✅ מחזיר `true` אם ההתנתקות הצליחה, `false` אם נכשלה.
  /// לא זורק שגיאות - מאפשר ל-Provider לדעת אם לנקות state נוסף.
  ///
  /// Example:
  /// ```dart
  /// final success = await authService.signOut();
  /// if (success) {
  ///   // נקה caches, reset providers וכו'
  ///   await inventoryProvider.clearCache();
  ///   await shoppingListsProvider.clearCache();
  /// } else {
  ///   // הצג הודעת שגיאה
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('ההתנתקות נכשלה')),
  ///   );
  /// }
  /// ```
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  // === איפוס סיסמה ===

  /// שולח מייל לאיפוס סיסמה
  ///
  /// Throws:
  /// - [AuthException] עם קוד שגיאה והודעה בעברית אם השליחה נכשלה
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.sendPasswordResetEmail('user@example.com');
  ///   print(AppStrings.auth.resetEmailSent);
  /// } on AuthException catch (e) {
  ///   print('שגיאה: ${e.message}');
  /// }
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {

      final errorMessage = _getResetPasswordErrorMessage(e.code);
      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.resetEmailError(e.toString()),
        originalError: e,
      );
    }
  }

  // === שליחת אימות אימייל ===

  /// שולח מייל אימות למשתמש הנוכחי
  ///
  /// Throws:
  /// - [AuthException] אם אין משתמש מחובר או אם השליחה נכשלה
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.sendEmailVerification();
  ///   print(AppStrings.auth.verificationEmailSent);
  /// } on AuthException catch (e) {
  ///   print('שגיאה: ${e.message}');
  /// }
  /// ```
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.sendEmailVerification();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.verificationEmailError(e.toString()),
        originalError: e,
      );
    }
  }

  // === עדכון פרופיל ===

  /// מעדכן את שם התצוגה של המשתמש
  ///
  /// Throws:
  /// - [AuthException] אם אין משתמש מחובר או אם העדכון נכשל
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updateDisplayName('יוני כהן');
  ///   print(AppStrings.auth.displayNameUpdated);
  /// } on AuthException catch (e) {
  ///   print('שגיאה: ${e.message}');
  /// }
  /// ```
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.updateDisplayName(displayName);
      await _auth.currentUser!.reload();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.updateDisplayNameError(e.toString()),
        originalError: e,
      );
    }
  }

  /// מעדכן את האימייל של המשתמש
  ///
  /// ⚠️ דורש re-authentication לפני שימוש!
  ///
  /// Throws:
  /// - [AuthException] אם אין משתמש מחובר, אם דורש re-auth, או אם העדכון נכשל
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updateEmail('newemail@example.com');
  ///   print(AppStrings.auth.emailUpdated);
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.requiresRecentLogin) {
  ///     // צריך re-authentication
  ///     await authService.reauthenticate(email: '...', password: '...');
  ///     await authService.updateEmail('newemail@example.com');
  ///   }
  /// }
  /// ```
  Future<void> updateEmail(String newEmail) async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
      await _auth.currentUser!.reload();
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = AppStrings.auth.errorRequiresRecentLogin;
      } else if (e.code == 'email-already-in-use') {
        errorMessage = AppStrings.auth.errorEmailInUse;
      } else if (e.code == 'invalid-email') {
        errorMessage = AppStrings.auth.errorInvalidEmail;
      } else {
        errorMessage = AppStrings.auth.updateEmailError(e.message);
      }

      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.updateEmailError(e.toString()),
        originalError: e,
      );
    }
  }

  /// מעדכן את הסיסמה של המשתמש
  ///
  /// ⚠️ דורש re-authentication לפני שימוש!
  ///
  /// Throws:
  /// - [AuthException] אם אין משתמש מחובר, אם דורש re-auth, או אם העדכון נכשל
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updatePassword('newPassword123');
  ///   print(AppStrings.auth.passwordUpdated);
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.requiresRecentLogin) {
  ///     // צריך re-authentication
  ///     await authService.reauthenticate(email: '...', password: '...');
  ///     await authService.updatePassword('newPassword123');
  ///   }
  /// }
  /// ```
  Future<void> updatePassword(String newPassword) async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.updatePassword(newPassword);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = AppStrings.auth.errorRequiresRecentLogin;
      } else if (e.code == 'weak-password') {
        errorMessage = AppStrings.auth.errorWeakPassword;
      } else {
        errorMessage = AppStrings.auth.updatePasswordError(e.message);
      }

      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.updatePasswordError(e.toString()),
        originalError: e,
      );
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
  /// - [AuthException] אם אין משתמש מחובר או אם ה-re-auth נכשל
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.reauthenticate(
  ///     email: currentUser.email!,
  ///     password: userPassword,
  ///   );
  ///   await authService.updateEmail('newemail@example.com');
  /// } on AuthException catch (e) {
  ///   print('Re-authentication נכשל: ${e.message}');
  /// }
  /// ```
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }


      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      final errorMessage = _getSignInErrorMessage(e.code);
      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.signInError(e.toString()),
        originalError: e,
      );
    }
  }

  // === מחיקת חשבון ===

  /// מוחק את חשבון המשתמש הנוכחי
  ///
  /// ⚠️ פעולה בלתי הפיכה!
  /// ⚠️ דורש re-authentication לפני שימוש!
  ///
  /// Throws:
  /// - [AuthException] אם אין משתמש מחובר, אם דורש re-auth, או אם המחיקה נכשלה
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   // דרוש re-authentication קודם
  ///   await authService.reauthenticate(email: '...', password: '...');
  ///   await authService.deleteAccount();
  ///   print(AppStrings.auth.accountDeleted);
  /// } on AuthException catch (e) {
  ///   if (e.code == AuthErrorCode.requiresRecentLogin) {
  ///     // צריך re-authentication
  ///   }
  /// }
  /// ```
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.delete();
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {

      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = AppStrings.auth.errorRequiresRecentLogin;
      } else {
        errorMessage = AppStrings.auth.deleteAccountError(e.message);
      }

      throw AuthException.fromFirebaseCode(e.code, errorMessage);
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.deleteAccountError(e.toString()),
        originalError: e,
      );
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
  /// } on AuthException catch (e) {
  ///   print('שגיאה: ${e.message}');
  /// }
  /// ```
  Future<void> reloadUser() async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(
          code: AuthErrorCode.noUserLoggedIn,
          message: AppStrings.auth.errorNoUserLoggedIn,
        );
      }

      await _auth.currentUser!.reload();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: AppStrings.auth.reloadUserError(e.toString()),
        originalError: e,
      );
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
        return AppStrings.common.unknownErrorGeneric;
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
        return AppStrings.common.unknownErrorGeneric;
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
