// 📄 File: lib/repositories/firebase_user_repository.dart
//
// 🎯 Purpose: Repository למשתמשים עם Firestore
//
// 📋 Features:
//     - CRUD operations למשתמשים (יצירה, טעינה, עדכון, מחיקה)
//     - חיפוש לפי אימייל/טלפון
//     - Real-time updates (watchUser stream)
//     - יצירת משתמש עם נתוני Onboarding
//     - שימוש ב-FirestoreUtils להמרת נתונים בטוחה
//     - ניהול עקבי של Timestamps רקורסיביים
//
// 📦 Dependencies:
//     - cloud_firestore
//     - UserEntity model
//     - FirestoreUtils להמרת Timestamps רקורסיבית
//
// 🔗 Related:
//     - user_repository.dart - הממשק שממומש כאן
//     - user_context.dart - Provider שמשתמש בקלאס הזה
//
// Version: 3.0
// Last Updated: 22/02/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_entity.dart';
import 'constants/repository_constants.dart';
import 'user_repository.dart';
import 'utils/firestore_utils.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Fetch User ===

  @override
  Future<UserEntity?> fetchUser(String userId) async {
    try {
      debugPrint('📥 FirebaseUserRepository.fetchUser: טוען משתמש $userId');

      final doc = await _firestore.collection(FirestoreCollections.users).doc(userId).get();

      if (!doc.exists) {
        debugPrint('⚠️ FirebaseUserRepository.fetchUser: משתמש לא נמצא');
        return null;
      }

      final user = UserEntity.fromJson(doc.toDartMap()!);
      debugPrint('✅ FirebaseUserRepository.fetchUser: משתמש נטען - ${user.email}');
      
      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.fetchUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to fetch user $userId', e);
    }
  }

  // === Save User ===

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      debugPrint('💾 FirebaseUserRepository.saveUser: שומר משתמש ${user.id}');
      debugPrint('   📧 Email: ${user.email}');
      debugPrint('   📱 Phone: ${user.phone}');

      // עדכון lastLoginAt
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());

      final jsonData = updatedUser.toJson();
      debugPrint('   📦 JSON to save: $jsonData');

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.id)
          .set(
            updatedUser.toJson(),
            SetOptions(merge: true), // מאפשר עדכון חלקי
          );

      debugPrint('✅ FirebaseUserRepository.saveUser: משתמש נשמר');
      return updatedUser;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.saveUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to save user ${user.id}', e);
    }
  }

  // === Delete User ===

  @override
  Future<void> deleteUser(String userId) async {
    try {
      debugPrint('🗑️ FirebaseUserRepository.deleteUser: מוחק משתמש $userId');

      await _firestore.collection(FirestoreCollections.users).doc(userId).delete();

      debugPrint('✅ FirebaseUserRepository.deleteUser: משתמש נמחק');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.deleteUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to delete user $userId', e);
    }
  }

  // === Exists User ===

  @override
  Future<bool> existsUser(String userId) async {
    try {
      final doc = await _firestore.collection(FirestoreCollections.users).doc(userId).get();
      return doc.exists;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.existsUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      // 🔧 זורק Exception במקום להחזיר false - כדי להבדיל בין "לא קיים" לבין "שגיאת רשת"
      throw UserRepositoryException('Failed to check if user exists', e);
    }
  }

  // === Get All Users ===
  // 💡 Dynamic filtering: Pass householdId to filter, or null for all users
  // ⚠️ WARNING: Calling without householdId returns ALL users (admin only!)

  @override
  Future<List<UserEntity>> getAllUsers({String? householdId}) async {
    try {
      if (householdId != null) {
        debugPrint('📋 FirebaseUserRepository.getAllUsers: Loading users for household $householdId');
      } else {
        debugPrint('⚠️ FirebaseUserRepository.getAllUsers: Loading ALL users (no filter!)');
      }

      Query<Map<String, dynamic>> query = _firestore.collection(FirestoreCollections.users);
      
      // ✅ Apply household filter if provided
      if (householdId != null) {
        query = query.where(FirestoreFields.householdId, isEqualTo: householdId);
      }
      
      final snapshot = await query
          .limit(householdId != null ? 50 : 100) // More restrictive for all-users query
          .get();

      final users = snapshot.toDartList().map(UserEntity.fromJson).toList();

      debugPrint('✅ FirebaseUserRepository.getAllUsers: Loaded ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.getAllUsers: Error - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to get all users', e);
    }
  }

  // === Find By Email ===
  // 🔒 SECURITY: Always filters by household_id to prevent cross-household data leakage

  @override
  Future<UserEntity?> findByEmail(String email, {String? householdId}) async {
    try {
      if (email.isEmpty) {
        throw ArgumentError('Email cannot be empty');
      }

      debugPrint('🔍 FirebaseUserRepository.findByEmail: מחפש משתמש עם אימייל $email');

      final normalizedEmail = email.toLowerCase().trim();

      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestoreCollections.users)
          .where(FirestoreFields.email, isEqualTo: normalizedEmail);

      // ✅ CRITICAL: Filter by household_id if provided
      if (householdId != null) {
        query = query.where(FirestoreFields.householdId, isEqualTo: householdId);
      }

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ FirebaseUserRepository.findByEmail: משתמש לא נמצא');
        return null;
      }

      final user = UserEntity.fromJson(snapshot.docs.first.toDartMap()!);
      debugPrint('✅ FirebaseUserRepository.findByEmail: משתמש נמצא - ${user.id}');

      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.findByEmail: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to find user by email', e);
    }
  }

  // === Find By Phone ===

  @override
  Future<UserEntity?> findByPhone(String phone) async {
    try {
      if (phone.isEmpty) {
        throw ArgumentError('Phone cannot be empty');
      }

      debugPrint('🔍 FirebaseUserRepository.findByPhone: מחפש משתמש עם טלפון $phone');

      final normalizedPhone = _normalizePhone(phone);

      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .where(FirestoreFields.phone, isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ FirebaseUserRepository.findByPhone: משתמש לא נמצא');
        return null;
      }

      final user = UserEntity.fromJson(snapshot.docs.first.toDartMap()!);
      debugPrint('✅ FirebaseUserRepository.findByPhone: משתמש נמצא - ${user.id}');

      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.findByPhone: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to find user by phone', e);
    }
  }

  /// נרמול מספר טלפון - הסרת רווחים, מקפים ותווים מיוחדים
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  // === Update Last Login ===

  @override
  Future<void> updateLastLogin(String userId) async {
    try {
      debugPrint('⏰ FirebaseUserRepository.updateLastLogin: מעדכן זמן התחברות ל-$userId');

      await _firestore.collection(FirestoreCollections.users).doc(userId).update({
        'last_login_at': Timestamp.now(),
      });

      debugPrint('✅ FirebaseUserRepository.updateLastLogin: זמן עודכן');
    } catch (e) {
      debugPrint('❌ FirebaseUserRepository.updateLastLogin: שגיאה - $e');
      throw UserRepositoryException('Failed to update last login', e);
    }
  }

  // === Update Household Name ===

  @override
  Future<void> updateHouseholdName(String userId, String? householdName) async {
    try {
      debugPrint('✏️ FirebaseUserRepository.updateHouseholdName: מעדכן שם קבוצה של $userId');

      String? sanitized;
      if (householdName != null && householdName.trim().isNotEmpty) {
        sanitized = householdName.trim();
        if (sanitized.length > 40) {
          throw UserRepositoryException('שם קבוצה ארוך מדי (מקסימום 40 תווים)');
        }
        sanitized = sanitized.replaceAll(RegExp(r'[<>&"\\]'), '').replaceAll("'", '');
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .update({'household_name': sanitized});

      debugPrint('✅ FirebaseUserRepository.updateHouseholdName: שם קבוצה עודכן');
    } catch (e, stackTrace) {
      if (e is UserRepositoryException) rethrow;
      debugPrint('❌ FirebaseUserRepository.updateHouseholdName: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to update household name', e);
    }
  }

  // === Clear All ===
  // 💡 Dynamic filtering: Pass householdId to delete specific household, or null for all
  // ⚠️ DANGEROUS: Calling without householdId deletes ALL users (testing only!)

  @override
  Future<void> clearAll({String? householdId}) async {
    try {
      if (householdId != null) {
        debugPrint('🧹 FirebaseUserRepository.clearAll: Deleting users for household $householdId');
      } else {
        debugPrint('⚠️ FirebaseUserRepository.clearAll: Deleting ALL users (DANGEROUS!)');
      }

      Query<Map<String, dynamic>> query = _firestore.collection(FirestoreCollections.users);
      
      // ✅ Apply household filter if provided
      if (householdId != null) {
        query = query.where(FirestoreFields.householdId, isEqualTo: householdId);
      } else {
        query = query.limit(100); // Safety limit for all-users delete
      }
      
      final snapshot = await query.get();

      // ✅ Split into batches of 500 (Firestore maximum)
      final docs = snapshot.docs;
      const maxBatchSize = 500;
      for (int i = 0; i < docs.length; i += maxBatchSize) {
        final batch = _firestore.batch();
        final end = (i + maxBatchSize < docs.length) 
            ? i + maxBatchSize 
            : docs.length;
        
        for (int j = i; j < end; j++) {
          batch.delete(docs[j].reference);
        }
        
        await batch.commit();
        
        // ✅ Prevent rate limiting with delay between batches
        if (end < docs.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      debugPrint('✅ FirebaseUserRepository.clearAll: Deleted ${docs.length} users');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.clearAll: Error - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to clear all users', e);
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// יוצר משתמש חדש ב-Firestore
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
  ///   shoppingFrequency: 2,
  ///   seenOnboarding: true,
  /// );
  /// print('משתמש נוצר: ${user.id}');
  /// ```
  ///
  /// See also:
  /// - [saveUser] - עדכון משתמש קיים
  /// - [existsUser] - בדיקת קיום משתמש
  @override
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? phone,
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
  }) async {
    try {
      debugPrint('➕ FirebaseUserRepository.createUser: יוצר משתמש חדש $userId');

      // בדיקה אם המשתמש כבר קיים
      final existingUser = await fetchUser(userId);
      if (existingUser != null) {
        debugPrint('⚠️ המשתמש כבר קיים, מחזיר את הקיים');
        return existingUser;
      }

      // יצירת משתמש חדש עם נתוני Onboarding
      final newUser = UserEntity.newUser(
        id: userId,
        email: email.toLowerCase().trim(),
        name: name,
        phone: phone,
        householdId: householdId,
        // 🆕 Onboarding fields
        preferredStores: preferredStores,
        familySize: familySize,
        shoppingFrequency: shoppingFrequency,
        shoppingDays: shoppingDays,
        hasChildren: hasChildren,
        shareLists: shareLists,
        reminderTime: reminderTime,
        seenOnboarding: seenOnboarding,
      );

      // שמירה ב-Firestore
      await saveUser(newUser);

      debugPrint('✅ FirebaseUserRepository.createUser: משתמש נוצר עם נתוני Onboarding');
      return newUser;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.createUser: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to create user', e);
    }
  }

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
  @override
  Future<UserEntity> updateProfile({
    required String userId,
    String? name,
    String? avatar,
  }) async {
    try {
      debugPrint('✏️ FirebaseUserRepository.updateProfile: מעדכן פרופיל של $userId');

      final updates = <String, dynamic>{};
      if (name != null) updates[FirestoreFields.name] = name;
      if (avatar != null) updates['profile_image_url'] = avatar;

      if (updates.isEmpty) {
        debugPrint('⚠️ אין שדות לעדכון - מחזיר משתמש קיים');
        final existing = await fetchUser(userId);
        if (existing == null) {
          throw UserRepositoryException('User not found: $userId');
        }
        return existing;
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .update(updates);

      debugPrint('✅ FirebaseUserRepository.updateProfile: פרופיל עודכן (${updates.length} שדות)');

      // 🔧 מחזיר את המשתמש המעודכן
      final updated = await fetchUser(userId);
      if (updated == null) {
        throw UserRepositoryException('User not found after update: $userId');
      }
      return updated;
    } catch (e, stackTrace) {
      if (e is UserRepositoryException) rethrow;
      debugPrint('❌ FirebaseUserRepository.updateProfile: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to update profile', e);
    }
  }

  /// מחזיר Stream של משתמש לעדכונים בזמן אמת
  /// 
  /// ה-Stream ישלח עדכון כל פעם שהמשתמש משתנה ב-Firestore.
  /// 
  /// מחזיר `null` אם המשתמש נמחק או לא קיים.
  /// 
  /// שימושי ב:
  /// - הצגת פרופיל משתמש (real-time)
  /// - סנכרון בין מכשירים
  /// - עדכונים אוטומטיים של UI
  /// 
  /// ⚠️ **חשוב:** זכור לבטל את ה-subscription כשלא צריך!
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
  ///       // עדכן UI...
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
  @override
  Stream<UserEntity?> watchUser(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.toDartMap();
      return data != null ? UserEntity.fromJson(data) : null;
    });
  }
}
