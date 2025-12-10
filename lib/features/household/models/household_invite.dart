// 📄 File: lib/features/household/models/household_invite.dart
// 🎯 Purpose: מודל הזמנה למשפחה
//
// 📋 Features:
// - קוד הזמנה ייחודי (6 תווים)
// - תוקף הזמנה (7 ימים)
// - סטטוס: active / used / expired
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

part 'household_invite.g.dart';

/// 📨 סטטוס הזמנה
enum InviteStatus {
  active,   // פעילה - ממתינה לשימוש
  used,     // נוצלה - מישהו הצטרף
  expired,  // פג תוקף
  cancelled // בוטלה ידנית
}

/// 📨 מודל הזמנה למשפחה
@immutable
@JsonSerializable()
class HouseholdInvite {
  /// 🆔 מזהה ייחודי
  final String id;

  /// 🔑 קוד הזמנה (6 תווים - אותיות ומספרים)
  final String code;

  /// 🏠 מזהה ה-household שאליו מזמינים
  @JsonKey(name: 'household_id')
  final String householdId;

  /// 👤 מזהה המזמין
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 👤 שם המזמין (להצגה למוזמן)
  @JsonKey(name: 'created_by_name')
  final String createdByName;

  /// 📅 תאריך יצירה
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// 📅 תאריך תפוגה
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  /// 📊 סטטוס ההזמנה
  @JsonKey(unknownEnumValue: InviteStatus.expired)
  final InviteStatus status;

  /// 👤 מזהה מי השתמש בהזמנה (אם נוצלה)
  @JsonKey(name: 'used_by')
  final String? usedBy;

  /// 📅 תאריך שימוש (אם נוצלה)
  @JsonKey(name: 'used_at')
  final DateTime? usedAt;

  const HouseholdInvite({
    required this.id,
    required this.code,
    required this.householdId,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.usedBy,
    this.usedAt,
  });

  /// 🆕 יצירת הזמנה חדשה
  factory HouseholdInvite.create({
    required String householdId,
    required String createdBy,
    required String createdByName,
    int expirationDays = 7,
  }) {
    final now = DateTime.now();
    return HouseholdInvite(
      id: const Uuid().v4(),
      code: _generateCode(),
      householdId: householdId,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: now,
      expiresAt: now.add(Duration(days: expirationDays)),
      status: InviteStatus.active,
    );
  }

  /// 🔑 יצירת קוד הזמנה (6 תווים - אותיות גדולות ומספרים)
  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // ללא O,0,1,I למניעת בלבול
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// ✅ האם ההזמנה עדיין תקפה?
  bool get isValid =>
    status == InviteStatus.active &&
    DateTime.now().isBefore(expiresAt);

  /// ⏰ כמה זמן נשאר עד תפוגה
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  /// 📊 ימים עד תפוגה
  int get daysUntilExpiration => timeUntilExpiration.inDays;

  // === JSON Serialization ===

  factory HouseholdInvite.fromJson(Map<String, dynamic> json) =>
      _$HouseholdInviteFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdInviteToJson(this);

  // === Copy With ===

  HouseholdInvite copyWith({
    String? id,
    String? code,
    String? householdId,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? expiresAt,
    InviteStatus? status,
    String? usedBy,
    DateTime? usedAt,
  }) {
    return HouseholdInvite(
      id: id ?? this.id,
      code: code ?? this.code,
      householdId: householdId ?? this.householdId,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      usedBy: usedBy ?? this.usedBy,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  /// 🔄 סימון ההזמנה כנוצלה
  HouseholdInvite markAsUsed(String userId) {
    return copyWith(
      status: InviteStatus.used,
      usedBy: userId,
      usedAt: DateTime.now(),
    );
  }

  /// ❌ ביטול ההזמנה
  HouseholdInvite cancel() {
    return copyWith(status: InviteStatus.cancelled);
  }

  @override
  String toString() =>
      'HouseholdInvite(code: $code, status: $status, expiresAt: $expiresAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdInvite &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
