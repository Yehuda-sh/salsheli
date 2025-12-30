// 📄 File: lib/repositories/firebase_group_repository.dart
// 🎯 Purpose: Firebase implementation לניהול קבוצות
//
// 📋 Database Structure:
// /groups/{groupId}
//   ├── id: string
//   ├── name: string
//   ├── type: string (family/building/kindergarten/friends/event/roommates/other)
//   ├── description: string?
//   ├── image_url: string?
//   ├── created_by: string
//   ├── created_at: timestamp
//   ├── updated_at: timestamp
//   ├── members: Map<userId, GroupMember>
//   ├── settings: GroupSettings
//   └── extra_fields: Map<string, dynamic>?
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/enums/user_role.dart';
import '../models/group.dart';
import 'group_repository.dart';

class FirebaseGroupRepository implements GroupRepository {
  final FirebaseFirestore _firestore;

  // Collection name
  static const String _collectionName = 'groups';

  // 🔧 Cache למניעת טעינות מיותרות ב-watchUserGroups
  // כאשר משתמש משנה תמונת פרופיל, לא צריך לטעון שוב את כל הקבוצות!
  List<String>? _lastGroupIds;
  List<Group>? _cachedGroups;

  FirebaseGroupRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference ל-collection
  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection(_collectionName);

  // ============================================================
  // GROUP CRUD
  // ============================================================

  @override
  Future<Group> createGroup(Group group) async {
    try {
      if (kDebugMode) {
        debugPrint('📝 FirebaseGroupRepository.createGroup: ${group.name}');
        debugPrint('   Type: ${group.type.hebrewName}');
        debugPrint('   Creator: ${group.createdBy}');
      }

      // שמירה ל-Firestore
      await _collection.doc(group.id).set(group.toJson());

      // עדכון ה-user document עם ה-group ID
      await _updateUserGroups(group.createdBy, group.id, add: true);

      if (kDebugMode) {
        debugPrint('✅ Group created successfully: ${group.id}');
      }

      return group;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.createGroup failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to create group', e);
    }
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    try {
      if (kDebugMode) {
        debugPrint('📖 FirebaseGroupRepository.getGroup: $groupId');
      }

      final doc = await _collection.doc(groupId).get();

      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Group not found');
        }
        return null;
      }

      final data = doc.data()!;
      return Group.fromJson({...data, 'id': doc.id});
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.getGroup failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to get group', e);
    }
  }

  @override
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('📚 FirebaseGroupRepository.getUserGroups: $userId');
      }

      // מציאת קבוצות שהמשתמש חבר בהן
      // Firestore לא תומך ב-query על Map keys, אז נשתמש ב-array-contains
      // נצטרך לשמור רשימת group IDs גם ב-user document

      // Option 1: Query where user is in members map
      // זה לא עובד ישירות ב-Firestore, אז נשתמש ב-user document

      // קודם נקבל את רשימת ה-groups מה-user
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          debugPrint('   ⚠️ User not found');
        }
        return [];
      }

      final userData = userDoc.data()!;
      final groupIds = List<String>.from(userData['group_ids'] ?? []);

      if (groupIds.isEmpty) {
        if (kDebugMode) {
          debugPrint('   ℹ️ User has no groups');
        }
        return [];
      }

      // קבלת כל הקבוצות
      // Firestore מגביל whereIn ל-30 פריטים, אז נחלק לקבוצות
      final List<Group> groups = [];

      for (var i = 0; i < groupIds.length; i += 30) {
        final batch = groupIds.skip(i).take(30).toList();
        final snapshot = await _collection.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          groups.add(Group.fromJson({...data, 'id': doc.id}));
        }
      }

      // מיון לפי תאריך עדכון
      groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (kDebugMode) {
        debugPrint('✅ Found ${groups.length} groups for user');
      }

      return groups;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.getUserGroups failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to get user groups', e);
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    try {
      if (kDebugMode) {
        debugPrint('✏️ FirebaseGroupRepository.updateGroup: ${group.id}');
      }

      await _collection.doc(group.id).update({...group.toJson(), 'updated_at': FieldValue.serverTimestamp()});

      if (kDebugMode) {
        debugPrint('✅ Group updated successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.updateGroup failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to update group', e);
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ FirebaseGroupRepository.deleteGroup: $groupId');
      }

      // קודם נקבל את הקבוצה כדי לעדכן את כל החברים
      final group = await getGroup(groupId);
      if (group == null) {
        throw GroupRepositoryException('Group not found');
      }

      // עדכון כל החברים - הסרת ה-group מהרשימה שלהם
      final batch = _firestore.batch();

      for (final member in group.membersList) {
        final userRef = _firestore.collection('users').doc(member.userId);
        batch.update(userRef, {
          'group_ids': FieldValue.arrayRemove([groupId]),
        });
      }

      // מחיקת הקבוצה
      batch.delete(_collection.doc(groupId));

      await batch.commit();

      if (kDebugMode) {
        debugPrint('✅ Group deleted successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.deleteGroup failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to delete group', e);
    }
  }

  // ============================================================
  // MEMBER MANAGEMENT
  // ============================================================

  @override
  Future<void> addMember(String groupId, GroupMember member) async {
    try {
      if (kDebugMode) {
        debugPrint('➕ FirebaseGroupRepository.addMember:');
        debugPrint('   Group: $groupId');
        debugPrint('   Member: ${member.name} (${member.role.hebrewName})');
      }

      // עדכון הקבוצה
      final groupRef = _collection.doc(groupId);
      await groupRef.update({'members.${member.userId}': member.toJson(), 'updated_at': FieldValue.serverTimestamp()});

      // עדכון ה-user רק אם הוא קיים במערכת (לא מוזמן חיצוני)
      if (!member.userId.startsWith('invited_')) {
        final userRef = _firestore.collection('users').doc(member.userId);
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          await userRef.update({
            'group_ids': FieldValue.arrayUnion([groupId]),
          });
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Member added successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.addMember failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to add member', e);
    }
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('➖ FirebaseGroupRepository.removeMember:');
        debugPrint('   Group: $groupId');
        debugPrint('   User: $userId');
      }

      // Transaction לעדכון אטומי
      await _firestore.runTransaction((transaction) async {
        // הסרה מהקבוצה
        final groupRef = _collection.doc(groupId);
        transaction.update(groupRef, {
          'members.$userId': FieldValue.delete(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        // הסרה מה-user
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'group_ids': FieldValue.arrayRemove([groupId]),
        });
      });

      if (kDebugMode) {
        debugPrint('✅ Member removed successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.removeMember failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to remove member', e);
    }
  }

  @override
  Future<void> updateMemberRole(String groupId, String userId, UserRole newRole) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 FirebaseGroupRepository.updateMemberRole:');
        debugPrint('   Group: $groupId');
        debugPrint('   User: $userId');
        debugPrint('   New Role: ${newRole.hebrewName}');
      }

      // לא ניתן לשנות ל-owner
      if (newRole == UserRole.owner) {
        throw GroupRepositoryException('Cannot assign owner role directly');
      }

      await _collection.doc(groupId).update({
        'members.$userId.role': newRole.name,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Member role updated successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseGroupRepository.updateMemberRole failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw GroupRepositoryException('Failed to update member role', e);
    }
  }

  // ============================================================
  // STREAMS (Real-time)
  // ============================================================

  @override
  Stream<Group?> watchGroup(String groupId) {
    if (kDebugMode) {
      debugPrint('👁️ FirebaseGroupRepository.watchGroup: $groupId');
    }

    return _collection.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return Group.fromJson({...data, 'id': doc.id});
    });
  }

  @override
  Stream<List<Group>> watchUserGroups(String userId) {
    if (kDebugMode) {
      debugPrint('👁️ FirebaseGroupRepository.watchUserGroups: $userId');
    }

    // האזנה לשינויים ב-user document
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) {
        _lastGroupIds = null;
        _cachedGroups = null;
        return <Group>[];
      }

      final userData = userDoc.data()!;
      final groupIds = List<String>.from(userData['group_ids'] ?? []);

      if (groupIds.isEmpty) {
        _lastGroupIds = [];
        _cachedGroups = [];
        return <Group>[];
      }

      // 🔧 בדיקה אם group_ids השתנו - אם לא, מחזיר cache
      // זה מונע טעינות מיותרות כשהמשתמש משנה תמונת פרופיל וכד'
      if (_lastGroupIds != null &&
          _cachedGroups != null &&
          listEquals(_lastGroupIds, groupIds)) {
        if (kDebugMode) {
          debugPrint('   📦 Using cached groups (group_ids unchanged)');
        }
        return _cachedGroups!;
      }

      if (kDebugMode) {
        debugPrint('   🔄 Loading groups from Firestore (group_ids changed)');
      }

      // טעינת כל הקבוצות
      final List<Group> groups = [];

      for (var i = 0; i < groupIds.length; i += 30) {
        final batch = groupIds.skip(i).take(30).toList();
        final snapshot = await _collection.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          groups.add(Group.fromJson({...data, 'id': doc.id}));
        }
      }

      groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // 🔧 שמירה ב-cache
      _lastGroupIds = List.from(groupIds);
      _cachedGroups = groups;

      return groups;
    });
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// עדכון רשימת הקבוצות של משתמש
  Future<void> _updateUserGroups(String userId, String groupId, {required bool add}) async {
    final userRef = _firestore.collection('users').doc(userId);

    if (add) {
      await userRef.update({
        'group_ids': FieldValue.arrayUnion([groupId]),
      });
    } else {
      await userRef.update({
        'group_ids': FieldValue.arrayRemove([groupId]),
      });
    }
  }
}
