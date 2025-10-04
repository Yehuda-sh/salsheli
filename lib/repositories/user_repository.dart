// 📄 File: lib/repositories/user_repository.dart
//
// 🇮🇱 Repository לניהול משתמשים עם שיפורים:
//     - Error handling מלא
//     - Validation על כל הפרמטרים
//     - פונקציות repository נוספות
//     - Logging מפורט
//     - Thread safety בסיסי
//     - שמירה ב-SharedPreferences (אופציונלי)
//
// 🇬🇧 User repository with improvements:
//     - Complete error handling
//     - Parameter validation
//     - Additional repository methods
//     - Detailed logging
//     - Basic thread safety
//     - SharedPreferences persistence (optional)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_entity.dart';

// === Exceptions ===
class UserRepositoryException implements Exception {
  final String message;
  final Object? cause;

  UserRepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
      'UserRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

// === Abstract Repository ===
abstract class UserRepository {
  Future<UserEntity?> fetchUser(String userId);
  Future<UserEntity> saveUser(UserEntity user);
  Future<void> deleteUser(String userId);

  // 🆕 פונקציות נוספות
  Future<bool> existsUser(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> findByEmail(String email);
  Future<void> updateLastLogin(String userId);
  Future<void> clearAll();
}

// === Mock Implementation with Improvements ===
class MockUserRepository implements UserRepository {
  final Map<String, UserEntity> _storage = {};
  final bool _enablePersistence;
  final String _storagePrefix = 'mock_user_';

  // 🔒 Basic thread safety
  final _lock = Object();

  MockUserRepository({bool enablePersistence = false})
    : _enablePersistence = enablePersistence {
    _initializeDemoUsers();
    if (_enablePersistence) {
      _loadFromPreferences();
    }
  }

  void _initializeDemoUsers() {
    debugPrint('🌱 UserRepository: Initializing demo users');
    _storage['yoni_123'] = UserEntity.demo(
      id: 'yoni_123',
      name: 'יוני',
      email: 'yoni@example.com',
      householdId: 'house_demo',
    );
    _storage['dana_456'] = UserEntity.demo(
      id: 'dana_456',
      name: 'דנה',
      email: 'dana@example.com',
      householdId: 'house_demo',
    );
  }

  // === Core Methods ===

  @override
  Future<UserEntity?> fetchUser(String userId) async {
    try {
      _validateUserId(userId);
      debugPrint('🔍 UserRepository: Fetching user $userId');

      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // simulate latency

      synchronized(_lock, () async {
        final existing = _storage[userId];
        if (existing != null) {
          debugPrint('✅ UserRepository: Found existing user $userId');
          final updated = existing.copyWith(lastLoginAt: DateTime.now());
          _storage[userId] = updated;
          _saveToPreferences(userId, updated);
          return updated;
        }

        // Auto-provisioning for new users
        debugPrint('🆕 UserRepository: Auto-provisioning new user $userId');
        final friendlyName = _displayNameFromId(userId);
        final created = UserEntity.demo(id: userId, name: friendlyName);
        _storage[userId] = created;
        _saveToPreferences(userId, created);
        return created;
      });

      return _storage[userId];
    } catch (e, stack) {
      debugPrint('❌ UserRepository.fetchUser failed: $e');
      debugPrintStack(stackTrace: stack);
      throw UserRepositoryException('Failed to fetch user $userId', e);
    }
  }

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      _validateUser(user);
      debugPrint('💾 UserRepository: Saving user ${user.id}');

      await synchronized(_lock, () async {
        _storage[user.id] = user;
        await _saveToPreferences(user.id, user);
      });

      debugPrint('✅ UserRepository: User ${user.id} saved successfully');
      return user;
    } catch (e, stack) {
      debugPrint('❌ UserRepository.saveUser failed: $e');
      debugPrintStack(stackTrace: stack);
      throw UserRepositoryException('Failed to save user ${user.id}', e);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      _validateUserId(userId);
      debugPrint('🗑️ UserRepository: Deleting user $userId');

      await synchronized(_lock, () async {
        _storage.remove(userId);
        await _removeFromPreferences(userId);
      });

      debugPrint('✅ UserRepository: User $userId deleted');
    } catch (e, stack) {
      debugPrint('❌ UserRepository.deleteUser failed: $e');
      debugPrintStack(stackTrace: stack);
      throw UserRepositoryException('Failed to delete user $userId', e);
    }
  }

  // === 🆕 Additional Methods ===

  @override
  Future<bool> existsUser(String userId) async {
    try {
      _validateUserId(userId);
      return _storage.containsKey(userId);
    } catch (e) {
      debugPrint('❌ UserRepository.existsUser failed: $e');
      return false;
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      debugPrint(
        '📋 UserRepository: Getting all users (${_storage.length} users)',
      );
      await Future.delayed(const Duration(milliseconds: 100));
      return List.unmodifiable(_storage.values);
    } catch (e) {
      debugPrint('❌ UserRepository.getAllUsers failed: $e');
      throw UserRepositoryException('Failed to get all users', e);
    }
  }

  @override
  Future<UserEntity?> findByEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw ArgumentError('Email cannot be empty');
      }

      debugPrint('🔍 UserRepository: Finding user by email $email');
      await Future.delayed(const Duration(milliseconds: 150));

      final normalizedEmail = email.toLowerCase().trim();
      return _storage.values.firstWhere(
        (user) => user.email.toLowerCase().trim() == normalizedEmail,
        orElse: () => null as dynamic,
      );
    } catch (e) {
      debugPrint('❌ UserRepository.findByEmail failed: $e');
      throw UserRepositoryException('Failed to find user by email', e);
    }
  }

  @override
  Future<void> updateLastLogin(String userId) async {
    try {
      _validateUserId(userId);

      final user = _storage[userId];
      if (user != null) {
        final updated = user.copyWith(lastLoginAt: DateTime.now());
        await saveUser(updated);
      }
    } catch (e) {
      debugPrint('❌ UserRepository.updateLastLogin failed: $e');
      throw UserRepositoryException('Failed to update last login', e);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      debugPrint('🧹 UserRepository: Clearing all users');

      await synchronized(_lock, () async {
        _storage.clear();
        if (_enablePersistence) {
          final prefs = await SharedPreferences.getInstance();
          final keys = prefs
              .getKeys()
              .where((key) => key.startsWith(_storagePrefix))
              .toList();
          for (final key in keys) {
            await prefs.remove(key);
          }
        }
      });

      _initializeDemoUsers(); // Re-add demo users
      debugPrint('✅ UserRepository: All users cleared');
    } catch (e) {
      debugPrint('❌ UserRepository.clearAll failed: $e');
      throw UserRepositoryException('Failed to clear users', e);
    }
  }

  // === Private Helpers ===

  void _validateUserId(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (userId.length > 100) {
      throw ArgumentError('User ID too long (max 100 chars)');
    }
    if (!RegExp(r'^[\w\-\.@]+$').hasMatch(userId)) {
      throw ArgumentError('User ID contains invalid characters');
    }
  }

  void _validateUser(UserEntity user) {
    _validateUserId(user.id);

    if (user.name.isEmpty) {
      throw ArgumentError('User name cannot be empty');
    }
    if (user.name.length > 50) {
      throw ArgumentError('User name too long (max 50 chars)');
    }

    if (user.email.isNotEmpty) {
      if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(user.email)) {
        throw ArgumentError('Invalid email format');
      }
    }
  }

  String _displayNameFromId(String userId) {
    // משופר: מטפל במקרי קצה טוב יותר
    final cleaned = userId
        .replaceAll(RegExp(r'[_\-\.@]+'), ' ')
        .replaceAll(RegExp(r'\d+'), '') // מסיר מספרים
        .trim();

    if (cleaned.isEmpty) return 'משתמש חדש';

    // Capitalize each word
    final words = cleaned.split(' ').where((w) => w.isNotEmpty);
    final capitalized = words
        .map((word) {
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');

    return capitalized.isEmpty ? 'משתמש חדש' : capitalized;
  }

  // === Persistence Methods ===

  Future<void> _saveToPreferences(String userId, UserEntity user) async {
    if (!_enablePersistence) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final json = jsonEncode(user.toJson());
      await prefs.setString(key, json);
      debugPrint('💾 Saved user $userId to preferences');
    } catch (e) {
      debugPrint('⚠️ Failed to save user to preferences: $e');
    }
  }

  Future<void> _removeFromPreferences(String userId) async {
    if (!_enablePersistence) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_storagePrefix$userId');
      debugPrint('🗑️ Removed user $userId from preferences');
    } catch (e) {
      debugPrint('⚠️ Failed to remove user from preferences: $e');
    }
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith(_storagePrefix))
          .toList();

      debugPrint('📥 Loading ${keys.length} users from preferences');

      for (final key in keys) {
        try {
          final json = prefs.getString(key);
          if (json != null) {
            final data = jsonDecode(json) as Map<String, dynamic>;
            final user = UserEntity.fromJson(data);
            _storage[user.id] = user;
          }
        } catch (e) {
          debugPrint('⚠️ Failed to load user from $key: $e');
        }
      }

      debugPrint('✅ Loaded ${_storage.length} users total');
    } catch (e) {
      debugPrint('⚠️ Failed to load users from preferences: $e');
    }
  }
}

// === Utility function for thread safety ===
Future<T> synchronized<T>(Object lock, Future<T> Function() action) async {
  // Basic synchronization - in production, use proper synchronization package
  return await action();
}
