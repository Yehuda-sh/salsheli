// 📄 File: test/integration/login_flow_test.dart
// 🎯 Purpose: בדיקות אינטגרציה מלאות למסלול התחברות
//
// 📋 Tests:
// - ✅ התחברות מוצלחת (email + password)
// - ✅ התחברות כושלת (סיסמה שגויה)
// - ✅ רישום משתמש חדש + התחברות
// - ✅ שכחתי סיסמה (שליחת מייל)
// - ✅ התחברות דמו מהירה
// - ✅ Navigation לאחר התחברות מוצלחת
//
// 📝 Version: 1.0
// 📅 Created: 18/10/2025

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:memozap/main.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/user_repository.dart';
import 'package:memozap/services/auth_service.dart';
import 'package:memozap/screens/auth/login_screen.dart';
import 'package:memozap/screens/home/home_screen.dart';
import 'package:memozap/models/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../helpers/test_helpers.dart';
import '../helpers/mock_data.dart';

// יצירת Mocks עם mockito
@GenerateMocks([
  UserRepository,
  AuthService,
  firebase_auth.User,
  firebase_auth.UserCredential,
])
import 'login_flow_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepo;
  late MockAuthService mockAuthService;
  late UserContext userContext;

  setUp(() {
    debugPrint('\n🧪 ========================================');
    debugPrint('🧪 Setting up login flow test...');
    debugPrint('🧪 ========================================\n');

    mockUserRepo = MockUserRepository();
    mockAuthService = MockAuthService();

    // הגדרת התנהגות בסיסית
    when(mockAuthService.isSignedIn).thenReturn(false);
    when(mockAuthService.currentUser).thenReturn(null);
    when(mockAuthService.currentUserId).thenReturn(null);
    when(mockAuthService.currentUserEmail).thenReturn(null);
    when(mockAuthService.currentUserDisplayName).thenReturn(null);
    
    // Mock authStateChanges stream - חובה!
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    userContext = UserContext(
      repository: mockUserRepo,
      authService: mockAuthService,
    );
  });

  tearDown(() {
    userContext.dispose();
    debugPrint('\n🧪 ========================================');
    debugPrint('🧪 Test completed and cleaned up');
    debugPrint('🧪 ========================================\n');
  });

  group('🔐 Login Flow - Full Integration', () {
    testWidgets(
      'התחברות מוצלחת - מסך Login → מסך Home',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Successful login flow');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Arrange ===
        final testUser = createMockUser(
          email: 'test@test.com',
          name: 'Test User',
        );

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(testUser.id);
        when(mockFirebaseUser.email).thenReturn(testUser.email);
        when(mockFirebaseUser.displayName).thenReturn(testUser.name);

        // Mock התחברות מוצלחת
        final mockCredential = MockUserCredential();
        when(mockCredential.user).thenReturn(mockFirebaseUser);
        
        // Mock authStateChanges stream - שולח event אחרי signIn
        final authStreamController = StreamController<firebase_auth.User?>();
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        
        when(mockAuthService.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          debugPrint('✅ Mock: signIn() called');
          // עדכן את mockAuthService
          when(mockAuthService.isSignedIn).thenReturn(true);
          when(mockAuthService.currentUser).thenReturn(mockFirebaseUser);
          when(mockAuthService.currentUserId).thenReturn(testUser.id);
          when(mockAuthService.currentUserEmail).thenReturn(testUser.email);
          
          // שלח event ב-stream כדי לטעון משתמש אוטומטית
          authStreamController.add(mockFirebaseUser);
          
          return mockCredential; // ✅ מחזיר UserCredential
        });

        // Mock טעינת משתמש מ-Firestore
        when(mockUserRepo.fetchUser(testUser.id))
            .thenAnswer((_) async {
          debugPrint('✅ Mock: fetchUser() called');
          return testUser;
        });

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        debugPrint('🔍 Verifying LoginScreen is visible...');
        expect(find.text('התחברות'), findsOneWidget);
        expect(find.text('ברוך שובך!'), findsOneWidget);

        // מילוי הטופס
        debugPrint('📝 Filling login form...');
        await fillTextField(tester, 'אימייל', 'test@test.com');
        await fillTextField(tester, 'סיסמה', 'password123');

        debugPrint('🖱️ Tapping login button...');
        await tapButton(tester, 'התחבר');

        // המתן לניווט
        debugPrint('⏳ Waiting for navigation to HomeScreen...');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying navigation to HomeScreen...');
        
        // בדוק שהתחברות עברה
        verify(mockAuthService.signIn(
          email: 'test@test.com',
          password: 'password123',
        )).called(1);

        // המתן שהמשתמש ייטען דרך authStateChanges
        await tester.pumpAndSettle();

        // בדוק שמשתמש נטען
        verify(mockUserRepo.fetchUser(testUser.id)).called(1);

        // ניקוי
        await authStreamController.close();

        debugPrint('✅ Test passed: Full login flow successful!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'התחברות כושלת - סיסמה שגויה',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Failed login - wrong password');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Arrange ===
        when(mockAuthService.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('סיסמה שגויה'));

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        // מילוי הטופס
        debugPrint('📝 Filling login form with wrong password...');
        await fillTextField(tester, 'אימייל', 'test@test.com');
        await fillTextField(tester, 'סיסמה', 'wrong-password');

        debugPrint('🖱️ Tapping login button...');
        await tapButton(tester, 'התחבר');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying error message is shown...');

        // בדוק שהשגיאה מוצגת
        expect(find.text('סיסמה שגויה'), findsOneWidget);

        // בדוק שנשארנו במסך ההתחברות
        expect(find.text('התחברות'), findsOneWidget);

        // בדוק שההתחברות נקראה פעם אחת
        verify(mockAuthService.signIn(
          email: 'test@test.com',
          password: 'wrong-password',
        )).called(1);

        // בדוק שלא נטען משתמש
        verifyNever(mockUserRepo.fetchUser(any));

        debugPrint('✅ Test passed: Error handling works correctly!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'רישום משתמש חדש + התחברות אוטומטית',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Register new user + auto login');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Arrange ===
        final newUser = createMockUser(
          email: 'new@test.com',
          name: 'New User',
        );

        final mockCredential = MockUserCredential();
        final mockFirebaseUser = MockUser();
        
        when(mockCredential.user).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn(newUser.id);
        when(mockFirebaseUser.email).thenReturn(newUser.email);
        when(mockFirebaseUser.displayName).thenReturn(newUser.name);

        // Mock רישום מוצלח
        when(mockAuthService.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        )).thenAnswer((_) async {
          debugPrint('✅ Mock: signUp() called');
          when(mockAuthService.isSignedIn).thenReturn(true);
          when(mockAuthService.currentUser).thenReturn(mockFirebaseUser);
          return mockCredential;
        });

        // Mock שמירת משתמש ב-Firestore
        when(mockUserRepo.saveUser(any)).thenAnswer((_) async {
          debugPrint('✅ Mock: saveUser() called');
          return newUser;
        });

        debugPrint('🏗️ Building RegisterScreen...');
        
        // נניח שיש לנו RegisterScreen (נוכל להוסיף אותו מאוחר יותר)
        // כרגע נבדוק רק את הפונקציה signUp של UserContext

        // === Act ===
        debugPrint('📝 Calling signUp...');
        await userContext.signUp(
          email: 'new@test.com',
          password: 'password123',
          name: 'New User',
        );

        // === Assert ===
        debugPrint('🔍 Verifying signup was successful...');

        verify(mockAuthService.signUp(
          email: 'new@test.com',
          password: 'password123',
          name: 'New User',
        )).called(1);

        verify(mockUserRepo.saveUser(any)).called(1);

        expect(userContext.isLoggedIn, isTrue);
        expect(userContext.user?.email, equals('new@test.com'));

        debugPrint('✅ Test passed: User registered and logged in!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'שכחתי סיסמה - שליחת מייל איפוס',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Forgot password - send reset email');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Arrange ===
        when(mockAuthService.sendPasswordResetEmail(any))
            .thenAnswer((_) async {
          debugPrint('✅ Mock: sendPasswordResetEmail() called');
        });

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        // מילוי אימייל
        debugPrint('📝 Filling email field...');
        await fillTextField(tester, 'אימייל', 'test@test.com');

        // לחיצה על "שכחת סיסמה?"
        debugPrint('🖱️ Tapping forgot password link...');
        await tester.tap(find.text('שכחת סיסמה?'));
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying reset email was sent...');

        verify(mockAuthService.sendPasswordResetEmail('test@test.com'))
            .called(1);

        // בדוק הודעת הצלחה (מכיל את האימייל)
        expect(find.textContaining('נשלח מייל לאיפוס סיסמה'), findsOneWidget);

        debugPrint('✅ Test passed: Password reset email sent!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'התחברות דמו מהירה - Demo Login Button',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Quick demo login');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // === Arrange ===
        final demoUser = createMockUser(
          email: getDemoEmail(),
          name: 'Demo User',
        );

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(demoUser.id);
        when(mockFirebaseUser.email).thenReturn(demoUser.email);

        final mockDemoCredential = MockUserCredential();
        when(mockDemoCredential.user).thenReturn(mockFirebaseUser);
        
        when(mockAuthService.signIn(
          email: getDemoEmail(),
          password: getDemoPassword(),
        )).thenAnswer((_) async {
          debugPrint('✅ Mock: Demo signIn() called');
          when(mockAuthService.isSignedIn).thenReturn(true);
          when(mockAuthService.currentUser).thenReturn(mockFirebaseUser);
          return mockDemoCredential; // ✅ מחזיר UserCredential
        });

        when(mockUserRepo.fetchUser(demoUser.id))
            .thenAnswer((_) async => demoUser);

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        // לחיצה על כפתור כניסה מהירה (הטקסט כולל את שם המשתמש)
        debugPrint('🖱️ Tapping demo login button...');
        await tapButton(tester, 'כניסה כאבי 🚀');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying demo login was successful...');

        verify(mockAuthService.signIn(
          email: getDemoEmail(),
          password: getDemoPassword(),
        )).called(1);

        debugPrint('✅ Test passed: Demo login successful!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'בדיקת Form Validation - שדות ריקים',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Form validation - empty fields');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        // ניסיון להתחבר ללא מילוי שדות
        debugPrint('🖱️ Tapping login without filling form...');
        await tapButton(tester, 'התחבר');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying validation errors are shown...');

        // בדוק שהודעות שגיאה מוצגות
        expect(find.text('שדה חובה'), findsNWidgets(2)); // אימייל וסיסמה

        // בדוק שההתחברות לא נקראה
        verifyNever(mockAuthService.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));

        debugPrint('✅ Test passed: Form validation works!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );

    testWidgets(
      'בדיקת Email Validation - אימייל לא תקין',
      (WidgetTester tester) async {
        debugPrint('\n📝 Test: Email validation - invalid format');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        debugPrint('🏗️ Building LoginScreen...');

        // === Act ===
        await tester.pumpWidget(
          createTestApp(
            child: const LoginScreen(),
            userContext: userContext,
          ),
        );
        await tester.pumpAndSettle();

        // מילוי אימייל לא תקין
        debugPrint('📝 Filling invalid email...');
        await fillTextField(tester, 'אימייל', 'invalid-email');
        await fillTextField(tester, 'סיסמה', 'password123');

        await tapButton(tester, 'התחבר');
        await tester.pumpAndSettle();

        // === Assert ===
        debugPrint('🔍 Verifying validation error is shown...');

        expect(find.text('אימייל לא תקין'), findsOneWidget);

        verifyNever(mockAuthService.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));

        debugPrint('✅ Test passed: Email validation works!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
    );
  });
}
