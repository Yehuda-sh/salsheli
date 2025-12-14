// 📄 File: lib/repositories/group_repository.dart
// 🎯 Purpose: Interface לניהול קבוצות (Groups)
//
// 📋 Features:
// - CRUD לקבוצות
// - ניהול חברים
// - Stream לעדכונים בזמן אמת
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import '../models/enums/user_role.dart';
import '../models/group.dart';

/// Interface לניהול קבוצות
abstract class GroupRepository {
  // ============================================================
  // GROUP CRUD
  // ============================================================

  /// יצירת קבוצה חדשה
  Future<Group> createGroup(Group group);

  /// קבלת קבוצה לפי ID
  Future<Group?> getGroup(String groupId);

  /// קבלת כל הקבוצות של משתמש
  Future<List<Group>> getUserGroups(String userId);

  /// עדכון קבוצה
  Future<void> updateGroup(Group group);

  /// מחיקת קבוצה
  Future<void> deleteGroup(String groupId);

  // ============================================================
  // MEMBER MANAGEMENT
  // ============================================================

  /// הוספת חבר לקבוצה
  Future<void> addMember(String groupId, GroupMember member);

  /// הסרת חבר מקבוצה
  Future<void> removeMember(String groupId, String userId);

  /// עדכון תפקיד חבר
  Future<void> updateMemberRole(
    String groupId,
    String userId,
    UserRole newRole,
  );

  // ============================================================
  // STREAMS (Real-time)
  // ============================================================

  /// Stream לקבוצה ספציפית
  Stream<Group?> watchGroup(String groupId);

  /// Stream לכל הקבוצות של משתמש
  Stream<List<Group>> watchUserGroups(String userId);
}

/// Exception עבור שגיאות repository
class GroupRepositoryException implements Exception {
  final String message;
  final Object? cause;

  GroupRepositoryException(this.message, [this.cause]);

  @override
  String toString() => 'GroupRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}
