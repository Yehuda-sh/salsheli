// 📄 File: lib/repositories/firebase_user_repository.dart
//
// 🇮🇱 Repository למשתמשים עם Firestore:
//     - שמירת פרטי משתמש ב-Firestore
//     - טעינת פרטי משתמש
//     - עדכון פרופיל
//     - מחיקת משתמש
//     - חיפוש לפי אימייל
//
// 🇬🇧 User repository with Firestore:
//     - Save user details to Firestore
//     - Load user details
//     - Update profile
//     - Delete user
//     - Search by email

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_entity.dart';
import 'user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'users';

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Fetch User ===

  @override
  Future<UserEntity?> fetchUser(String userId) async {
    try {
      debugPrint('📥 FirebaseUserRepository.fetchUser: טוען משתמש $userId');

      final doc = await _firestore.collection(_collectionName).doc(userId).get();

      if (!doc.exists) {
        debugPrint('⚠️ FirebaseUserRepository.fetchUser: משתמש לא נמצא');
        return null;
      }

      // המרת Timestamps ל-Strings לפני fromJson
      final data = Map<String, dynamic>.from(doc.data()!);
      
      if (data['joined_at'] is Timestamp) {
        data['joined_at'] = (data['joined_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['last_login_at'] is Timestamp) {
        data['last_login_at'] = (data['last_login_at'] as Timestamp).toDate().toIso8601String();
      }

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
          .collection(_collectionName)
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

      await _firestore.collection(_collectionName).doc(userId).delete();

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
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ FirebaseUserRepository.existsUser: שגיאה - $e');
      return false;
    }
  }

  // === Get All Users ===

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      debugPrint('📋 FirebaseUserRepository.getAllUsers: טוען כל המשתמשים');

      final snapshot = await _firestore.collection(_collectionName).get();

      final users = snapshot.docs.map((doc) {
        // המרת Timestamps ל-Strings
        final data = Map<String, dynamic>.from(doc.data());
        
        if (data['joined_at'] is Timestamp) {
          data['joined_at'] = (data['joined_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['last_login_at'] is Timestamp) {
          data['last_login_at'] = (data['last_login_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return UserEntity.fromJson(data);
      }).toList();

      debugPrint('✅ FirebaseUserRepository.getAllUsers: נטענו ${users.length} משתמשים');
      return users;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.getAllUsers: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to get all users', e);
    }
  }

  // === Find By Email ===

  @override
  Future<UserEntity?> findByEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw ArgumentError('Email cannot be empty');
      }

      debugPrint('🔍 FirebaseUserRepository.findByEmail: מחפש משתמש עם אימייל $email');

      final normalizedEmail = email.toLowerCase().trim();

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ FirebaseUserRepository.findByEmail: משתמש לא נמצא');
        return null;
      }

      // המרת Timestamps ל-Strings
      final data = Map<String, dynamic>.from(snapshot.docs.first.data());
      
      if (data['joined_at'] is Timestamp) {
        data['joined_at'] = (data['joined_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['last_login_at'] is Timestamp) {
        data['last_login_at'] = (data['last_login_at'] as Timestamp).toDate().toIso8601String();
      }

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

      await _firestore.collection(_collectionName).doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });

      debugPrint('✅ FirebaseUserRepository.updateLastLogin: זמן עודכן');
    } catch (e) {
      debugPrint('❌ FirebaseUserRepository.updateLastLogin: שגיאה - $e');
      throw UserRepositoryException('Failed to update last login', e);
    }
  }

  // === Clear All ===

  @override
  Future<void> clearAll() async {
    try {
      debugPrint('🧹 FirebaseUserRepository.clearAll: מנקה את כל המשתמשים');

      final snapshot = await _firestore.collection(_collectionName).get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('✅ FirebaseUserRepository.clearAll: ${snapshot.docs.length} משתמשים נמחקו');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.clearAll: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to clear all users', e);
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// יוצר משתמש חדש ב-Firestore
  /// 
  /// Example:
  /// ```dart
  /// final user = await repository.createUser(
  ///   userId: 'abc123',
  ///   email: 'user@example.com',
  ///   name: 'יוני כהן',
  ///   householdId: 'house_demo',
  /// );
  /// ```
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

  /// מעדכן פרופיל של משתמש
  /// 
  /// Example:
  /// ```dart
  /// await repository.updateProfile(
  ///   userId: 'abc123',
  ///   name: 'יוני כהן',
  ///   avatar: 'https://...',
  /// );
  /// ```
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatar,
  }) async {
    try {
      debugPrint('✏️ FirebaseUserRepository.updateProfile: מעדכן פרופיל של $userId');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isEmpty) {
        debugPrint('⚠️ אין שדות לעדכון');
        return;
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update(updates);

      debugPrint('✅ FirebaseUserRepository.updateProfile: פרופיל עודכן');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseUserRepository.updateProfile: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw UserRepositoryException('Failed to update profile', e);
    }
  }

  /// מחזיר stream של משתמש (real-time updates)
  /// 
  /// Example:
  /// ```dart
  /// repository.watchUser('abc123').listen((user) {
  ///   print('User updated: ${user?.name}');
  /// });
  /// ```
  Stream<UserEntity?> watchUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      
      // המרת Timestamps ל-Strings
      final data = Map<String, dynamic>.from(snapshot.data()!);
      
      if (data['joined_at'] is Timestamp) {
        data['joined_at'] = (data['joined_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['last_login_at'] is Timestamp) {
        data['last_login_at'] = (data['last_login_at'] as Timestamp).toDate().toIso8601String();
      }
      
      return UserEntity.fromJson(data);
    });
  }
}
