// 📄 File: lib/features/household/models/household_member.dart
// 🎯 Purpose: מודל חבר משפחה (household member)
//
// 📋 Features:
// - מייצג משתמש ב-household
// - תפקיד: owner / admin / editor / viewer
// - מידע על מי הזמין ומתי הצטרף
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/enums/user_role.dart';

part 'household_member.g.dart';

/// 👨‍👩‍👧‍👦 מודל חבר משפחה
@immutable
@JsonSerializable()
class HouseholdMember {
  /// 🆔 מזהה המשתמש
  @JsonKey(name: 'user_id')
  final String userId;

  /// 👤 שם המשתמש
  final String name;

  /// 📧 אימייל
  final String email;

  /// 🖼️ תמונת פרופיל (אופציונלי)
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// 🔐 תפקיד במשפחה
  final UserRole role;

  /// 📅 תאריך הצטרפות
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  /// 👤 מזהה מי הזמין (null אם owner מקורי)
  @JsonKey(name: 'invited_by')
  final String? invitedBy;

  /// 📅 פעילות אחרונה (אופציונלי)
  @JsonKey(name: 'last_active_at')
  final DateTime? lastActiveAt;

  const HouseholdMember({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.invitedBy,
    this.lastActiveAt,
  });

  /// 🆕 יצירת חבר חדש (owner)
  factory HouseholdMember.owner({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    return HouseholdMember(
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: UserRole.owner,
      joinedAt: DateTime.now(),
    );
  }

  /// 🆕 יצירת חבר חדש (מוזמן)
  factory HouseholdMember.invited({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
    required UserRole role,
    required String invitedBy,
  }) {
    return HouseholdMember(
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
      joinedAt: DateTime.now(),
      invitedBy: invitedBy,
    );
  }

  /// 👑 האם owner?
  bool get isOwner => role == UserRole.owner;

  /// 🔧 האם admin?
  bool get isAdmin => role == UserRole.admin;

  /// ✏️ האם editor?
  bool get isEditor => role == UserRole.editor;

  /// 👀 האם viewer?
  bool get isViewer => role == UserRole.viewer;

  /// ✅ האם יכול לערוך? (owner, admin, editor)
  bool get canEdit => isOwner || isAdmin || isEditor;

  /// ✅ האם יכול לנהל משתמשים? (owner, admin)
  bool get canManageUsers => isOwner || isAdmin;

  /// ✅ האם יכול להזמין? (owner, admin)
  bool get canInvite => isOwner || isAdmin;

  /// 🎨 אימוג'י לפי תפקיד
  String get roleEmoji {
    switch (role) {
      case UserRole.owner:
        return '👑';
      case UserRole.admin:
        return '🔧';
      case UserRole.editor:
        return '✏️';
      case UserRole.viewer:
        return '👀';
    }
  }

  /// 📝 שם תפקיד בעברית
  String get roleDisplayName {
    switch (role) {
      case UserRole.owner:
        return 'בעלים';
      case UserRole.admin:
        return 'מנהל';
      case UserRole.editor:
        return 'עורך';
      case UserRole.viewer:
        return 'צופה';
    }
  }

  // === JSON Serialization ===

  factory HouseholdMember.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMemberFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdMemberToJson(this);

  // === Copy With ===

  HouseholdMember copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    DateTime? joinedAt,
    String? invitedBy,
    DateTime? lastActiveAt,
  }) {
    return HouseholdMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  String toString() =>
      'HouseholdMember(name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
