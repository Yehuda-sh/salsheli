// File: lib/models/group_invite.dart
// Purpose: מודל הזמנה לקבוצה - לניהול הזמנות ממתינות
//
// Database Structure:
// /group_invites/{inviteId}
//   - id: string
//   - group_id: string
//   - group_name: string
//   - invited_phone: string?
//   - invited_email: string?
//   - invited_name: string?
//   - role: string (admin/editor/viewer)
//   - invited_by: string (userId)
//   - invited_by_name: string
//   - created_at: timestamp
//   - status: string (pending/accepted/rejected/expired)
//   - responded_at: timestamp?
//   - accepted_by_user_id: string?
//
// Version: 1.1 - Fixed field names in documentation
// Created: 16/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'enums/user_role.dart';
import 'timestamp_converter.dart';

part 'group_invite.g.dart';

/// סטטוס הזמנה
enum InviteStatus {
  /// ממתין לאישור
  pending,

  /// התקבל
  accepted,

  /// נדחה
  rejected,

  /// פג תוקף
  expired;

  String get hebrewName {
    switch (this) {
      case InviteStatus.pending:
        return 'ממתין';
      case InviteStatus.accepted:
        return 'התקבל';
      case InviteStatus.rejected:
        return 'נדחה';
      case InviteStatus.expired:
        return 'פג תוקף';
    }
  }
}

/// מודל הזמנה לקבוצה
@JsonSerializable()
class GroupInvite {
  /// מזהה ייחודי
  final String id;

  /// מזהה הקבוצה
  @JsonKey(name: 'group_id')
  final String groupId;

  /// שם הקבוצה (cache)
  @JsonKey(name: 'group_name')
  final String groupName;

  /// טלפון המוזמן (אחד מהשניים חובה)
  @JsonKey(name: 'invited_phone')
  final String? invitedPhone;

  /// אימייל המוזמן (אחד מהשניים חובה)
  @JsonKey(name: 'invited_email')
  final String? invitedEmail;

  /// שם המוזמן (אופציונלי)
  @JsonKey(name: 'invited_name')
  final String? invitedName;

  /// תפקיד מוצע בקבוצה
  final UserRole role;

  /// מזהה המזמין
  @JsonKey(name: 'invited_by')
  final String invitedBy;

  /// שם המזמין (cache)
  @JsonKey(name: 'invited_by_name')
  final String invitedByName;

  /// תאריך יצירה
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime createdAt;

  /// סטטוס ההזמנה
  final InviteStatus status;

  /// תאריך אישור/דחייה
  @JsonKey(name: 'responded_at')
  @NullableTimestampConverter()
  final DateTime? respondedAt;

  /// מזהה המשתמש שאישר (אחרי הרשמה)
  @JsonKey(name: 'accepted_by_user_id')
  final String? acceptedByUserId;

  const GroupInvite({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.invitedPhone,
    this.invitedEmail,
    this.invitedName,
    required this.role,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdAt,
    required this.status,
    this.respondedAt,
    this.acceptedByUserId,
  });

  // === Getters ===

  /// האם יש מידע ליצירת קשר
  bool get hasContactInfo => invitedPhone != null || invitedEmail != null;

  /// האם ההזמנה ממתינה
  bool get isPending => status == InviteStatus.pending;

  /// האם ההזמנה התקבלה
  bool get isAccepted => status == InviteStatus.accepted;

  /// האם ההזמנה נדחתה
  bool get isRejected => status == InviteStatus.rejected;

  /// הטלפון המנורמל (ללא מקפים ורווחים)
  String? get normalizedPhone {
    if (invitedPhone == null) return null;
    return invitedPhone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// טקסט זמן יצירה
  String get timeAgoText {
    final minutes = DateTime.now().difference(createdAt).inMinutes;
    if (minutes < 60) {
      return 'לפני $minutes דק\'';
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return 'לפני $hours שעות';
    }
    final days = hours ~/ 24;
    return 'לפני $days ימים';
  }

  // === Factory Constructors ===

  /// יצירת הזמנה חדשה
  factory GroupInvite.create({
    required String groupId,
    required String groupName,
    String? invitedPhone,
    String? invitedEmail,
    String? invitedName,
    required UserRole role,
    required String invitedBy,
    required String invitedByName,
  }) {
    return GroupInvite(
      id: const Uuid().v4(),
      groupId: groupId,
      groupName: groupName,
      invitedPhone: invitedPhone,
      invitedEmail: invitedEmail,
      invitedName: invitedName,
      role: role,
      invitedBy: invitedBy,
      invitedByName: invitedByName,
      createdAt: DateTime.now(),
      status: InviteStatus.pending,
    );
  }

  // === JSON ===

  factory GroupInvite.fromJson(Map<String, dynamic> json) =>
      _$GroupInviteFromJson(json);

  Map<String, dynamic> toJson() => _$GroupInviteToJson(this);

  /// יצירה מ-Firestore document
  factory GroupInvite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupInvite.fromJson({...data, 'id': doc.id});
  }

  // === Copy With ===

  GroupInvite copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? invitedPhone,
    String? invitedEmail,
    String? invitedName,
    UserRole? role,
    String? invitedBy,
    String? invitedByName,
    DateTime? createdAt,
    InviteStatus? status,
    DateTime? respondedAt,
    String? acceptedByUserId,
  }) {
    return GroupInvite(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      invitedPhone: invitedPhone ?? this.invitedPhone,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      invitedName: invitedName ?? this.invitedName,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
      acceptedByUserId: acceptedByUserId ?? this.acceptedByUserId,
    );
  }

  /// סימון כהתקבל
  GroupInvite markAccepted(String userId) {
    return copyWith(
      status: InviteStatus.accepted,
      respondedAt: DateTime.now(),
      acceptedByUserId: userId,
    );
  }

  /// סימון כנדחה
  GroupInvite markRejected() {
    return copyWith(
      status: InviteStatus.rejected,
      respondedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupInvite &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GroupInvite(id: $id, group: $groupName, phone: $invitedPhone, email: $invitedEmail, status: ${status.hebrewName})';
}
