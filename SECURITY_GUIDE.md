# 🔒 Security Guidelines - Comprehensive Security Strategy

> **מטרה:** הנחיות אבטחה למערכת Firebase + Flutter  
> **מוקד:** Authentication + Authorization + Data Security  
> **גרסה:** 1.0 | **עדכון:** 15/10/2025

---

## 🏗️ Architecture Overview

```
Flutter App
    ↓
Firebase Auth (Authentication)
    ↓
Firebase Firestore (Database)
    ↓
Security Rules (Authorization)
    ↓
Sensitive Data
```

---

## 🔐 Authentication

### 1. Firebase Auth Setup

```dart
// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Signing up: $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Sign up successful: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up error: ${e.code}');
      throw _mapAuthException(e);
    }
  }

  // ✅ Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Signing in: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Sign in successful: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in error: ${e.code}');
      throw _mapAuthException(e);
    }
  }

  // ✅ Sign Out
  Future<void> signOut() async {
    try {
      debugPrint('🔐 Signing out');
      await _auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw Exception('Failed to sign out');
    }
  }

  // ✅ Get Current User
  User? getCurrentUser() {
    final user = _auth.currentUser;
    debugPrint('📍 Current user: ${user?.uid}');
    return user;
  }

  // ✅ Auth State Stream
  Stream<User?> get authStateStream {
    return _auth.authStateChanges();
  }

  // Exception mapping
  Exception _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Password is too weak');
      case 'email-already-in-use':
        return Exception('Email already registered');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-not-found':
        return Exception('User not found');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try later');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }

  // ✅ Password Reset
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔐 Resetting password for: $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');
      throw Exception('Failed to send reset email');
    }
  }
}
```

### 2. Auth Error Handling

```dart
// ✅ Comprehensive error handling
try {
  await authService.signIn(email: email, password: password);
} on FirebaseAuthException catch (e) {
  // Show user-friendly error message
  switch (e.code) {
    case 'too-many-requests':
      showSnackBar('Too many login attempts. Try again later.');
      break;
    case 'wrong-password':
      showSnackBar('Incorrect password.');
      break;
    case 'user-not-found':
      showSnackBar('User not found.');
      break;
    default:
      showSnackBar('Login failed: ${e.message}');
  }
} catch (e) {
  showSnackBar('Unexpected error: $e');
}
```

---

## 🛡️ Firestore Security Rules

### 1. Basic Rule Structure

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // 🔴 Rule 1: Default deny (most restrictive)
    match /{document=**} {
      allow read, write: if false;
    }
    
    // 🟢 Rule 2: Specific collections
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // 🟢 Rule 3: Household-based access
    match /households/{householdId} {
      allow read, write: if isMember(householdId);
    }
    
    // 🟢 Rule 4: Function definitions
    function isMember(householdId) {
      return request.auth != null &&
             get(/databases/$(database)/documents/households/$(householdId))
               .data.members.hasAny([request.auth.uid]);
    }
  }
}
```

### 2. Complete Rules Example

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // 🔐 Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isHouseholdMember(householdId) {
      return isSignedIn() &&
             get(/databases/$(database)/documents/households/$(householdId))
               .data.members.hasAny([request.auth.uid]);
    }
    
    function isHouseholdAdmin(householdId) {
      return isSignedIn() &&
             get(/databases/$(database)/documents/households/$(householdId))
               .data.admins.hasAny([request.auth.uid]);
    }
    
    // 👥 Users collection - private
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      match /preferences/{document=**} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // 🏠 Households collection
    match /households/{householdId} {
      allow create: if isSignedIn() &&
                       request.resource.data.owner == request.auth.uid &&
                       request.resource.data.members[0] == request.auth.uid;
      
      allow read: if isHouseholdMember(householdId);
      allow update: if isHouseholdAdmin(householdId);
      allow delete: if isHouseholdAdmin(householdId);
    }
    
    // 🛒 Shopping Lists - household-based
    match /shopping_lists/{listId} {
      allow create: if isSignedIn() &&
                       resource.data.household_id != null &&
                       isHouseholdMember(resource.data.household_id);
      
      allow read: if isHouseholdMember(resource.data.household_id);
      
      allow update: if isHouseholdMember(resource.data.household_id) &&
                       // Don't allow changing household
                       resource.data.household_id == request.resource.data.household_id;
      
      allow delete: if isHouseholdMember(resource.data.household_id);
    }
    
    // 📦 Inventory - household-based
    match /inventory/{itemId} {
      allow read: if isHouseholdMember(resource.data.household_id);
      allow create: if isHouseholdMember(request.resource.data.household_id);
      allow update: if isHouseholdMember(resource.data.household_id) &&
                       resource.data.household_id == request.resource.data.household_id;
      allow delete: if isHouseholdMember(resource.data.household_id);
    }
    
    // 📋 Templates - system + personal + shared
    match /templates/{templateId} {
      allow read: if resource.data.is_system == true ||
                     resource.data.created_by == request.auth.uid ||
                     resource.data.shared_with.hasAny([request.auth.uid]);
      
      allow create: if isSignedIn() &&
                       resource.data.created_by == request.auth.uid &&
                       // Only admin can create system templates
                       (resource.data.is_system == false ||
                        request.auth.uid in ['admin-uid-here']);
      
      allow update: if resource.data.created_by == request.auth.uid &&
                       resource.data.is_system == false &&
                       // Can't change is_system flag
                       resource.data.is_system == request.resource.data.is_system;
      
      allow delete: if resource.data.created_by == request.auth.uid &&
                       resource.data.is_system == false;
    }
    
    // 🔐 Audit Logs - admin only
    match /audit_logs/{logId} {
      allow read: if request.auth.uid in ['admin-uid-here'];
      allow create: if request.auth != null; // All can write, admin can read
      allow update, delete: if false; // Never modify logs
    }
  }
}
```

---

## 💾 Data Security

### 1. Firestore Data Validation

```dart
// ✅ Validate household_id before saving

class ShoppingListsProvider extends ChangeNotifier {
  Future<void> createList(ShoppingList list, String householdId) async {
    try {
      // 🔴 Critical: Validate household_id
      assert(householdId == userContext.currentHouseholdId,
        'household_id mismatch! $householdId != ${userContext.currentHouseholdId}');
      
      // 🔴 Critical: Ensure household_id is set
      if (list.householdId == null || list.householdId != householdId) {
        throw Exception('household_id not set correctly');
      }
      
      debugPrint('💾 Creating list: ${list.name}');
      await _repo.createList(list, householdId);
      debugPrint('✅ List created');
    } catch (e) {
      debugPrint('❌ Error creating list: $e');
      _errorMessage = 'Failed to create list: $e';
      notifyListeners();
      rethrow;
    }
  }
}
```

### 2. Sensitive Data Handling

```dart
// ✅ Never log sensitive information

// ❌ Wrong - logs email!
debugPrint('User logged in: $email');

// ✅ Correct - logs only uid
debugPrint('User logged in: ${user.uid}');

// ❌ Wrong - logs password!
debugPrint('Signing in with: $email / $password');

// ✅ Correct - logs action only
debugPrint('Signing in...');

// ✅ Sensitive data in SharedPreferences (iOS Keychain, Android Keystore)
final prefs = await SharedPreferences.getInstance();
// SharedPreferences is NOT secure for sensitive data!
// Use: flutter_secure_storage instead

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
const storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

### 3. API Key Security

```dart
// ❌ Never hardcode API keys in code
const String FIREBASE_API_KEY = 'AIza...'; // WRONG!

// ✅ Use Firebase initialization
// Firebase is automatically initialized in main.dart
// No need to expose API keys

// ✅ If needed, use environment variables
const String API_KEY = String.fromEnvironment('API_KEY');

// ✅ Store in separate config file (not in git)
// pubspec.yaml or .env (add to .gitignore)
```

---

## 👤 User Context & Access Control

### 1. UserContext with Household Verification

```dart
// lib/providers/user_context.dart

class UserContext extends ChangeNotifier {
  String? _currentHouseholdId;

  String? get currentHouseholdId => _currentHouseholdId;

  /// ✅ Set household with validation
  Future<void> setHousehold(String householdId) async {
    try {
      // Verify user is member of household
      final isMember = await _verifyHouseholdMembership(householdId);
      
      if (!isMember) {
        throw Exception('User is not a member of household: $householdId');
      }
      
      _currentHouseholdId = householdId;
      debugPrint('🏠 Household set: $householdId');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error setting household: $e');
      rethrow;
    }
  }

  /// ✅ Verify membership before any operation
  Future<bool> _verifyHouseholdMembership(String householdId) async {
    try {
      final doc = await _firestore
          .collection('households')
          .doc(householdId)
          .get();
      
      final members = List<String>.from(doc.data()?['members'] ?? []);
      final isMember = members.contains(_auth.currentUser?.uid);
      
      debugPrint('👥 Membership check: $isMember');
      return isMember;
    } catch (e) {
      debugPrint('❌ Membership check failed: $e');
      return false;
    }
  }
}
```

### 2. Authorization Checks in Repositories

```dart
// ✅ Check authorization before any operation

class FirebaseShoppingListsRepository {
  Future<void> deleteList(String listId, String householdId) async {
    try {
      // 🔴 Step 1: Verify user is member of household
      final isMember = await _verifyMembership(householdId);
      if (!isMember) {
        throw Exception('Unauthorized: Not a member of household');
      }

      // 🔴 Step 2: Verify list belongs to household
      final listDoc = await _firestore
          .collection('shopping_lists')
          .doc(listId)
          .get();
      
      if (listDoc.data()?['household_id'] != householdId) {
        throw Exception('Unauthorized: List does not belong to household');
      }

      // 🔴 Step 3: Delete
      await _firestore
          .collection('shopping_lists')
          .doc(listId)
          .delete();
      
      debugPrint('🗑️ List deleted: $listId');
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      rethrow;
    }
  }
}
```

---

## 🚨 Security Best Practices

### ✅ Do

```dart
// ✅ Validate input
if (email.isEmpty || !email.contains('@')) {
  throw Exception('Invalid email');
}

// ✅ Verify ownership/membership
if (data['created_by'] != currentUserId) {
  throw Exception('Unauthorized');
}

// ✅ Use HTTPS only
// Firebase handles this automatically

// ✅ Enable 2FA (two-factor authentication)
// Implement in future: firebase_auth multi-factor authentication

// ✅ Rate limiting
// Implement in Security Rules:
// allow write: if request.time > lastWrite.time + duration(1m);

// ✅ Audit logging
Future<void> _auditLog(String action, String resource) async {
  await _firestore.collection('audit_logs').add({
    'uid': _auth.currentUser?.uid,
    'action': action,
    'resource': resource,
    'timestamp': FieldValue.serverTimestamp(),
    'ip': 'logged-by-server',
  });
}

// ✅ Error recovery with retry
Future<T> _executeWithRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Access denied');
      }
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }
  }
  throw Exception('Max retries exceeded');
}
```

### ❌ Don't

```dart
// ❌ Trust client-side validation only
// Always validate server-side too

// ❌ Log sensitive data
debugPrint('Password: $password');  // NEVER!
debugPrint('Token: $token');        // NEVER!

// ❌ Store secrets in code
const API_KEY = 'secret-key-123'; // WRONG!

// ❌ Bypass Firebase Security Rules
// Always enforce rules, don't disable for "testing"

// ❌ Keep failed login attempts unlogged
// Log all auth attempts for security audit

// ❌ Share user data across households
// Always filter by household_id

// ❌ Delete audit logs
// Archive instead of delete

// ❌ Use predictable IDs
// Let Firestore generate random IDs

// ❌ Hardcode user IDs
// Always use Firebase Auth UID
```

---

## 📋 Deployment Checklist

### Before Production

- [ ] All Firestore rules reviewed by 2+ team members
- [ ] Authentication flow tested (sign up, sign in, sign out, reset)
- [ ] Authorization checks in all repositories
- [ ] No hardcoded secrets in code
- [ ] Sensitive data not logged
- [ ] Audit logging implemented
- [ ] Rate limiting configured
- [ ] Error messages don't reveal implementation details
- [ ] HTTPS enforced (Firebase default)
- [ ] API keys restricted to appropriate services
- [ ] Database backups configured
- [ ] Access logs enabled
- [ ] Monitoring alerts set up

### Post-Deployment

- [ ] Monitor auth failure rates
- [ ] Check audit logs regularly
- [ ] Review Firestore usage for anomalies
- [ ] Update security rules based on usage patterns
- [ ] Conduct security review monthly

---

## 🔍 Monitoring & Auditing

### 1. Audit Logging

```dart
// lib/services/audit_service.dart

class AuditService {
  static const String COLLECTION = 'audit_logs';

  // Log all sensitive actions
  static Future<void> logAction({
    required String action,    // 'create', 'update', 'delete'
    required String resource,  // 'shopping_list', 'user', 'household'
    required String resourceId,
    required String householdId,
  }) async {
    try {
      await _firestore.collection(COLLECTION).add({
        'uid': _auth.currentUser?.uid,
        'action': action,
        'resource': resource,
        'resource_id': resourceId,
        'household_id': householdId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Audit log failed: $e');
    }
  }
}
```

### 2. Error Monitoring

```dart
// Use Sentry for error tracking
import 'package:sentry/sentry.dart';

try {
  await operation();
} catch (exception, stackTrace) {
  // Log to Sentry
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    hint: Hint.withContexts({
      'user_id': userId,
      'household_id': householdId,
    }),
  );
}
```

---

## 📚 Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase Authentication Best Practices](https://firebase.google.com/docs/auth/security-rules)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://flutter.dev/docs/testing/security-testing)

---

**Made with ❤️ by AI & Humans** 🤖🤝👨‍💻  
**Version:** 1.0 | **Last Updated:** 15/10/2025
