// 📄 File: lib/models/group.dart
// 🎯 Purpose: מודל קבוצה (Group) - תומך בכל סוגי הקבוצות
//
// 📋 Features:
// - סוגי קבוצות: משפחה, ועד בית, ועד גן, חברים, אירוע, שותפים, אחר
// - ניהול חברים עם הרשאות שונות
// - הגדרות מותאמות לכל סוג קבוצה
// - תמיכה ב-JSON serialization
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enums/user_role.dart';
import 'timestamp_converter.dart';

part 'group.g.dart';

// ============================================================
// GROUP TYPE ENUM
// ============================================================

/// סוגי קבוצות
enum GroupType {
  /// 👨‍👩‍👧 משפחה - רשימות קניות ומזווה משותף
  family,

  /// 🏢 ועד בית - הצבעות ומשימות לבניין
  building,

  /// 🧒 ועד גן/כיתה - אירועים וגיוסים להורים
  kindergarten,

  /// 👫 חברים - טיולים ואירועים משותפים
  friends,

  /// 🎉 אירוע - חתונה, בר מצווה, יום הולדת
  event,

  /// 🏠 שותפים לדירה - ניהול דירה משותפת
  roommates,

  /// 📋 אחר - לכל מטרה אחרת
  other;

  /// שם בעברית
  String get hebrewName {
    switch (this) {
      case GroupType.family:
        return 'משפחה';
      case GroupType.building:
        return 'ועד בית';
      case GroupType.kindergarten:
        return 'ועד גן/כיתה';
      case GroupType.friends:
        return 'חברים';
      case GroupType.event:
        return 'אירוע';
      case GroupType.roommates:
        return 'שותפים לדירה';
      case GroupType.other:
        return 'אחר';
    }
  }

  /// אימוג'י לסוג
  String get emoji {
    switch (this) {
      case GroupType.family:
        return '👨‍👩‍👧';
      case GroupType.building:
        return '🏢';
      case GroupType.kindergarten:
        return '🧒';
      case GroupType.friends:
        return '👫';
      case GroupType.event:
        return '🎉';
      case GroupType.roommates:
        return '🏠';
      case GroupType.other:
        return '📋';
    }
  }

  /// אייקון Material
  IconData get icon {
    switch (this) {
      case GroupType.family:
        return Icons.family_restroom;
      case GroupType.building:
        return Icons.apartment;
      case GroupType.kindergarten:
        return Icons.child_care;
      case GroupType.friends:
        return Icons.group;
      case GroupType.event:
        return Icons.celebration;
      case GroupType.roommates:
        return Icons.home;
      case GroupType.other:
        return Icons.list_alt;
    }
  }

  /// האם יש מזווה משותף?
  bool get hasPantry {
    switch (this) {
      case GroupType.family:
      case GroupType.roommates:
        return true;
      default:
        return false;
    }
  }

  /// האם יש מצב קנייה?
  bool get hasShoppingMode {
    switch (this) {
      case GroupType.family:
      case GroupType.roommates:
        return true;
      default:
        return false;
    }
  }

  /// האם יש הצבעות?
  bool get hasVoting {
    switch (this) {
      case GroupType.family:
        return false;
      default:
        return true;
    }
  }

  /// האם יש "מי מביא"?
  bool get hasWhosBringing {
    switch (this) {
      case GroupType.family:
        return false;
      default:
        return true;
    }
  }

  /// סוגי רשימות זמינים לקבוצה זו
  List<String> get availableListTypes {
    switch (this) {
      case GroupType.family:
        return ['shopping', 'checklist'];
      case GroupType.roommates:
        return ['shopping', 'checklist', 'vote', 'whos_bringing', 'survey'];
      case GroupType.building:
      case GroupType.kindergarten:
      case GroupType.friends:
      case GroupType.event:
      case GroupType.other:
        return ['vote', 'whos_bringing', 'checklist', 'survey'];
    }
  }
}

// ============================================================
// GROUP MEMBER MODEL
// ============================================================

/// 👤 חבר קבוצה
@immutable
@JsonSerializable()
class GroupMember {
  /// מזהה המשתמש
  @JsonKey(name: 'user_id')
  final String userId;

  /// שם המשתמש
  final String name;

  /// אימייל
  final String email;

  /// תמונת פרופיל (אימוג'י או URL)
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// תפקיד בקבוצה
  final UserRole role;

  /// תאריך הצטרפות
  @JsonKey(name: 'joined_at')
  @NullableTimestampConverter()
  final DateTime? joinedAt;

  /// מי הזמין (null אם owner מקורי)
  @JsonKey(name: 'invited_by')
  final String? invitedBy;

  const GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.joinedAt,
    this.invitedBy,
  });

  /// יצירת Owner
  factory GroupMember.owner({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    return GroupMember(
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: UserRole.owner,
      joinedAt: DateTime.now(),
    );
  }

  /// יצירת חבר מוזמן
  factory GroupMember.invited({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
    required UserRole role,
    required String invitedBy,
  }) {
    return GroupMember(
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
      joinedAt: DateTime.now(),
      invitedBy: invitedBy,
    );
  }

  // === Getters ===

  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;
  bool get canManageUsers => role == UserRole.owner || role == UserRole.admin;
  bool get canInvite => role == UserRole.owner || role == UserRole.admin;
  bool get canEdit => role != UserRole.viewer;

  // === JSON ===

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  // === Copy With ===

  GroupMember copyWith({
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    DateTime? joinedAt,
    String? invitedBy,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'GroupMember(name: $name, role: ${role.hebrewName})';
}

// ============================================================
// GROUP SETTINGS MODEL
// ============================================================

/// ⚙️ הגדרות קבוצה
@immutable
@JsonSerializable()
class GroupSettings {
  /// התראות על פעילות בקבוצה
  final bool notifications;

  /// התראות על מלאי נמוך (למשפחה/שותפים)
  @JsonKey(name: 'low_stock_alerts')
  final bool lowStockAlerts;

  /// התראות על הצבעות חדשות
  @JsonKey(name: 'voting_alerts')
  final bool votingAlerts;

  /// התראות על "מי מביא" חדש
  @JsonKey(name: 'whos_bringing_alerts')
  final bool whosBringingAlerts;

  const GroupSettings({
    this.notifications = true,
    this.lowStockAlerts = true,
    this.votingAlerts = true,
    this.whosBringingAlerts = true,
  });

  factory GroupSettings.defaults() => const GroupSettings();

  factory GroupSettings.fromJson(Map<String, dynamic> json) =>
      _$GroupSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GroupSettingsToJson(this);

  GroupSettings copyWith({
    bool? notifications,
    bool? lowStockAlerts,
    bool? votingAlerts,
    bool? whosBringingAlerts,
  }) {
    return GroupSettings(
      notifications: notifications ?? this.notifications,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      votingAlerts: votingAlerts ?? this.votingAlerts,
      whosBringingAlerts: whosBringingAlerts ?? this.whosBringingAlerts,
    );
  }
}

// ============================================================
// GROUP MODEL
// ============================================================

/// 👥 מודל קבוצה
@immutable
@JsonSerializable(explicitToJson: true)
class Group {
  /// מזהה ייחודי
  final String id;

  /// שם הקבוצה
  final String name;

  /// סוג הקבוצה
  final GroupType type;

  /// תיאור (אופציונלי)
  final String? description;

  /// תמונת קבוצה (URL או null)
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// מזהה היוצר
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// תאריך יצירה
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime createdAt;

  /// תאריך עדכון אחרון
  @JsonKey(name: 'updated_at')
  @TimestampConverter()
  final DateTime updatedAt;

  /// חברי הקבוצה (Map: userId -> GroupMember)
  final Map<String, GroupMember> members;

  /// הגדרות הקבוצה
  final GroupSettings settings;

  /// שדות נוספים לפי סוג (כתובת בניין, שם גן, תאריך אירוע)
  @JsonKey(name: 'extra_fields')
  final Map<String, dynamic>? extraFields;

  const Group({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.settings,
    this.extraFields,
  });

  /// יצירת קבוצה חדשה
  factory Group.create({
    required String id,
    required String name,
    required GroupType type,
    String? description,
    String? imageUrl,
    required String creatorId,
    required String creatorName,
    required String creatorEmail,
    String? creatorAvatar,
    Map<String, dynamic>? extraFields,
  }) {
    final now = DateTime.now();
    final owner = GroupMember.owner(
      userId: creatorId,
      name: creatorName,
      email: creatorEmail,
      avatarUrl: creatorAvatar,
    );

    return Group(
      id: id,
      name: name,
      type: type,
      description: description,
      imageUrl: imageUrl,
      createdBy: creatorId,
      createdAt: now,
      updatedAt: now,
      members: {creatorId: owner},
      settings: GroupSettings.defaults(),
      extraFields: extraFields,
    );
  }

  // === Getters ===

  /// מספר החברים
  int get memberCount => members.length;

  /// רשימת החברים
  List<GroupMember> get membersList => members.values.toList();

  /// הבעלים של הקבוצה
  GroupMember? get owner =>
      members.values.where((m) => m.isOwner).firstOrNull;

  /// האדמינים בקבוצה
  List<GroupMember> get admins =>
      members.values.where((m) => m.isAdmin).toList();

  /// האם יש מזווה?
  bool get hasPantry => type.hasPantry;

  /// האם יש מצב קנייה?
  bool get hasShoppingMode => type.hasShoppingMode;

  /// סוגי רשימות זמינים
  List<String> get availableListTypes => type.availableListTypes;

  /// שם עם אימוג'י
  String get displayName => '${type.emoji} $name';

  // === Firestore path ===

  /// נתיב ל-Firestore
  static String firestorePath(String groupId) => 'groups/$groupId';

  /// נתיב ל-collection
  static String get collectionPath => 'groups';

  // === Member Management ===

  /// בדיקה אם משתמש חבר בקבוצה
  bool isMember(String userId) => members.containsKey(userId);

  /// קבלת חבר לפי ID
  GroupMember? getMember(String userId) => members[userId];

  /// בדיקה אם משתמש הוא owner
  bool isOwnerUser(String userId) => members[userId]?.isOwner ?? false;

  /// בדיקה אם משתמש יכול לנהל
  bool canUserManage(String userId) =>
      members[userId]?.canManageUsers ?? false;

  // === JSON ===

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);

  /// יצירה מ-Firestore document
  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group.fromJson({...data, 'id': doc.id});
  }

  // === Copy With ===

  Group copyWith({
    String? id,
    String? name,
    GroupType? type,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, GroupMember>? members,
    GroupSettings? settings,
    Map<String, dynamic>? extraFields,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      members: members ?? this.members,
      settings: settings ?? this.settings,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  /// הוספת חבר
  Group addMember(GroupMember member) {
    return copyWith(
      members: {...members, member.userId: member},
    );
  }

  /// הסרת חבר
  Group removeMember(String userId) {
    final newMembers = Map<String, GroupMember>.from(members);
    newMembers.remove(userId);
    return copyWith(members: newMembers);
  }

  /// עדכון תפקיד חבר
  Group updateMemberRole(String userId, UserRole newRole) {
    final member = members[userId];
    if (member == null) return this;

    return copyWith(
      members: {
        ...members,
        userId: member.copyWith(role: newRole),
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Group(id: $id, name: $name, type: ${type.hebrewName}, members: $memberCount)';
}
