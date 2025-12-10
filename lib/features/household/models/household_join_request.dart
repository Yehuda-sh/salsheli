// 📄 File: lib/features/household/models/household_join_request.dart
// 🎯 Purpose: מודל בקשת הצטרפות למשפחה
//
// 📋 Features:
// - בקשה מיוזר להצטרף ל-household
// - סטטוס: pending / approved / rejected
// - הרשאה שנבחרה על ידי המאשר
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/enums/user_role.dart';

part 'household_join_request.g.dart';

/// 📊 סטטוס בקשת הצטרפות
enum JoinRequestStatus {
  pending,   // ממתינה לאישור
  approved,  // אושרה
  rejected,  // נדחתה
}

/// 📨 מודל בקשת הצטרפות למשפחה
@immutable
@JsonSerializable()
class HouseholdJoinRequest {
  /// 🆔 מזהה ייחודי
  final String id;

  /// 🔑 קוד ההזמנה שהוזן
  @JsonKey(name: 'invite_code')
  final String inviteCode;

  /// 🏠 מזהה ה-household המבוקש
  @JsonKey(name: 'household_id')
  final String householdId;

  /// 👤 מזהה המבקש
  @JsonKey(name: 'requester_id')
  final String requesterId;

  /// 👤 שם המבקש
  @JsonKey(name: 'requester_name')
  final String requesterName;

  /// 📧 אימייל המבקש
  @JsonKey(name: 'requester_email')
  final String requesterEmail;

  /// 🖼️ תמונת פרופיל המבקש (אופציונלי)
  @JsonKey(name: 'requester_avatar')
  final String? requesterAvatar;

  /// 📅 תאריך הבקשה
  @JsonKey(name: 'requested_at')
  final DateTime requestedAt;

  /// 📊 סטטוס הבקשה
  @JsonKey(unknownEnumValue: JoinRequestStatus.pending)
  final JoinRequestStatus status;

  /// 🔐 הרשאה שניתנה (רק אם אושרה)
  @JsonKey(name: 'assigned_role')
  final UserRole? assignedRole;

  /// 👤 מזהה המאשר/דוחה
  @JsonKey(name: 'reviewed_by')
  final String? reviewedBy;

  /// 📅 תאריך אישור/דחייה
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;

  /// 💬 הודעה מהמאשר/דוחה (אופציונלי)
  @JsonKey(name: 'review_message')
  final String? reviewMessage;

  const HouseholdJoinRequest({
    required this.id,
    required this.inviteCode,
    required this.householdId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    this.requesterAvatar,
    required this.requestedAt,
    required this.status,
    this.assignedRole,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewMessage,
  });

  /// 🆕 יצירת בקשה חדשה
  factory HouseholdJoinRequest.create({
    required String inviteCode,
    required String householdId,
    required String requesterId,
    required String requesterName,
    required String requesterEmail,
    String? requesterAvatar,
  }) {
    return HouseholdJoinRequest(
      id: const Uuid().v4(),
      inviteCode: inviteCode,
      householdId: householdId,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requesterAvatar: requesterAvatar,
      requestedAt: DateTime.now(),
      status: JoinRequestStatus.pending,
    );
  }

  /// ✅ האם הבקשה ממתינה?
  bool get isPending => status == JoinRequestStatus.pending;

  /// ✅ האם הבקשה אושרה?
  bool get isApproved => status == JoinRequestStatus.approved;

  /// ❌ האם הבקשה נדחתה?
  bool get isRejected => status == JoinRequestStatus.rejected;

  // === JSON Serialization ===

  factory HouseholdJoinRequest.fromJson(Map<String, dynamic> json) =>
      _$HouseholdJoinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdJoinRequestToJson(this);

  // === Copy With ===

  HouseholdJoinRequest copyWith({
    String? id,
    String? inviteCode,
    String? householdId,
    String? requesterId,
    String? requesterName,
    String? requesterEmail,
    String? requesterAvatar,
    DateTime? requestedAt,
    JoinRequestStatus? status,
    UserRole? assignedRole,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewMessage,
  }) {
    return HouseholdJoinRequest(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      householdId: householdId ?? this.householdId,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      requesterAvatar: requesterAvatar ?? this.requesterAvatar,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      assignedRole: assignedRole ?? this.assignedRole,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewMessage: reviewMessage ?? this.reviewMessage,
    );
  }

  /// ✅ אישור הבקשה
  HouseholdJoinRequest approve({
    required String reviewerId,
    required UserRole role,
    String? message,
  }) {
    return copyWith(
      status: JoinRequestStatus.approved,
      assignedRole: role,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewMessage: message,
    );
  }

  /// ❌ דחיית הבקשה
  HouseholdJoinRequest reject({
    required String reviewerId,
    String? message,
  }) {
    return copyWith(
      status: JoinRequestStatus.rejected,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewMessage: message,
    );
  }

  @override
  String toString() =>
      'HouseholdJoinRequest(requester: $requesterName, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdJoinRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
