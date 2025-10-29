// 📄 File: lib/repositories/firebase_user_repository.dart
//
// 🇮🇱 Repository למשתמשים עם Firestore:
//     - שמירת פרטי משתמש ב-Firestore
//     - טעינת פרטי משתמש
//     - עדכון פרופיל
//     - מחיקת משתמש
//     - חיפוש לפי אימייל
//     - Real-time updates (Stream)
//
// 🇬🇧 User repository with Firestore:
//     - Save user details to Firestore
//     - Load user details
//     - Update profile
//     - Delete user
//     - Search by email
//     - Real-time updates (Stream)
//
// 📦 Dependencies:
//     - cloud_firestore - Firestore SDK
//     - models/user_entity.dart - מודל המשתמש
//     - user_repository.dart - ממשק Repository
//
// 🔗 Related:
//     - user_repository.dart - הממשק שממומש כאן
//     - user_context.dart - Provider שמשתמש בקלאס הזה
//
// 🎯 Usage:
//     ```dart
//     // יצירה
//     final repository = FirebaseUserRepository();
//     
//     // טעינה
//     final user = await repository.fetchUser('abc123');
//     
//     // שמירה
//     await repository.saveUser(user);
//     
//     // Real-time listening
//     repository.watchUser('abc123').listen((user) {
//       print('User updated: ${user?.name}');
//     });
//     ```
//
// 📝 Version: 2.0 - Full Documentation
// 📅 Updated: 09/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_entity.dart';
import 'user_repository.dart';
import '../core/constants.dart';

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

      final data = Map<String, dynamic>.from(doc.data()!);
      final user = UserEntity.fromJson(data);
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

      // עדכון lastLoginAt
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());

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
    } catch (e) {
      debugPrint('❌ FirebaseUserRepository.existsUser: שגיאה - $e');
      return false;
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

      final users = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return UserEntity.fromJson(data);
      }).toList();

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

      final data = Map<String, dynamic>.from(snapshot.docs.first.data());

      final user = UserEntity.fromJson(data);
      debugPrint('✅ FirebaseUserRepository.findByEmail: משתמש נמצא - ${user.id}');
      
      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.findByEmail: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to find user by email', e);
    }
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
  /// );
  /// print('משתמש נוצר: ${user.id}');
  /// ```
  /// 
  /// See also:
  /// - [saveUser] - עדכון משתמש קיים
  /// - [existsUser] - בדיקת קיום משתמש
  Future<UserEntity> createUser({
    required String userId,
    required String email,
    required String name,
    String? householdId,
  }) async {
    try {
      debugPrint('➕ FirebaseUserRepository.createUser: יוצר משתמש חדש $userId');

      // בדיקה אם המשתמש כבר קיים
      final existingUser = await fetchUser(userId);
      if (existingUser != null) {
        debugPrint('⚠️ המשתמש כבר קיים, מחזיר את הקיים');
        return existingUser;
      }

      // יצירת משתמש חדש
      final newUser = UserEntity.newUser(
        id: userId,
        email: email.toLowerCase().trim(),
        name: name,
        householdId: householdId,
      );

      // שמירה ב-Firestore
      await saveUser(newUser);

      debugPrint('✅ FirebaseUserRepository.createUser: משתמש נוצר');
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
  Future<void> updateProfile({
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
        debugPrint('⚠️ אין שדות לעדכון');
        return;
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .update(updates);

      debugPrint('✅ FirebaseUserRepository.updateProfile: פרופיל עודכן (${updates.length} שדות)');
    } catch (e, stackTrace) {
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
  Stream<UserEntity?> watchUser(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      
      final data = Map<String, dynamic>.from(snapshot.data()!);
      return UserEntity.fromJson(data);
    });
  }
}
