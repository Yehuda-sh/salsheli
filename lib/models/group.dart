// 📄 File: lib/models/group.dart
//
// 🇮🇱 מודל קבוצה (Group) - תומך בכל סוגי הקבוצות:
//     - סוגי קבוצות: משפחה, ועד בית, ועד גן, חברים, אירוע, שותפים, אחר
//     - ניהול חברים עם הרשאות שונות (כמו SharedUser)
//     - הגדרות מותאמות לכל סוג קבוצה
//     - תמיכה ב-JSON serialization עם Firestore
//
// 🇬🇧 Group model - supports all group types:
//     - Group types: family, building, kindergarten, friends, event, roommates, other
//     - Member management with different roles (like SharedUser)
//     - Custom settings per group type
//     - JSON serialization with Firestore support
//
// 🏗️ Firestore Structure:
//     groups/{groupId}: {
//       name, type, created_by, created_at, updated_at,
//       members: { "userId1": { role, name, email, ... }, ... },
//       settings: { notifications, ... },
//       extra_fields: { ... }
//     }
//
// 🔗 Related:
//     - shared_user.dart - דפוס דומה ל-members כ-Map
//     - user_role.dart - תפקידים (owner/admin/editor/viewer)
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'enums/user_role.dart';
import 'timestamp_converter.dart';

part 'group.g.dart';

// ============================================================
// GROUP TYPE ENUM
// ============================================================

/// 🇮🇱 סוגי קבוצות
/// 🇬🇧 Group types
/// ✅ unknown: fallback למניעת קריסה אם מגיע ערך לא מוכר מהשרת
/// 📌 בשדות שמשתמשים ב-GroupType יש להוסיף: @JsonKey(unknownEnumValue: GroupType.unknown)
@JsonEnum(valueField: 'value')
enum GroupType {
  /// 👨‍👩‍👧 משפחה - רשימות קניות ומזווה משותף
  family('family'),

  /// 🏢 ועד בית - הצבעות ומשימות לבניין
  building('building'),

  /// 🧒 ועד גן/כיתה - אירועים וגיוסים להורים
  kindergarten('kindergarten'),

  /// 👫 חברים - טיולים ואירועים משותפים
  friends('friends'),

  /// 🎉 אירוע - חתונה, בר מצווה, יום הולדת
  event('event'),

  /// 🏠 שותפים לדירה - ניהול דירה משותפת
  roommates('roommates'),

  /// 📋 אחר - לכל מטרה אחרת
  other('other'),

  /// ❓ סוג לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown type value
  unknown('unknown');

  const GroupType(this.value);
  final String value;

  /// האם זה סוג תקין (לא unknown)
  bool get isKnown => this != GroupType.unknown;

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
      case GroupType.unknown:
        return 'לא ידוע';
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
      case GroupType.unknown:
        return '❓';
    }
  }

  /// 🔧 מזהה אייקון Material (למיפוי ב-UI)
  ///
  /// השימוש ב-String מאפשר לשמור את המודל נקי מתלות ב-Flutter UI.
  /// ב-UI יש למפות את המזהה ל-IconData:
  /// ```dart
  /// IconData getIcon(GroupType type) {
  ///   switch (type.iconName) {
  ///     case 'family_restroom': return Icons.family_restroom;
  ///     // ...
  ///   }
  /// }
  /// ```
  String get iconName {
    switch (this) {
      case GroupType.family:
        return 'family_restroom';
      case GroupType.building:
        return 'apartment';
      case GroupType.kindergarten:
        return 'child_care';
      case GroupType.friends:
        return 'group';
      case GroupType.event:
        return 'celebration';
      case GroupType.roommates:
        return 'home';
      case GroupType.other:
        return 'list_alt';
      case GroupType.unknown:
        return 'help_outline';
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
  /// ⚠️ unknown מקבל רשימה בסיסית (checklist בלבד) מטעמי אבטחה
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
      case GroupType.unknown:
        return ['checklist']; // מינימלי - בטוח
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
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: UserRole.unknown)
  final UserRole role;

  /// תאריך הצטרפות
  @JsonKey(name: 'joined_at')
  @NullableTimestampConverter()
  final DateTime? joinedAt;

  /// מי הזמין (null אם owner מקורי)
  @JsonKey(name: 'invited_by')
  final String? invitedBy;

  /// 🆕 האם יכול להתחיל קנייה (ניתן ע"י owner/admin)
  /// 🇬🇧 Can start shopping (granted by owner/admin)
  ///
  /// ברירת מחדל: false - רק owner/admin יכולים להתחיל קנייה.
  /// כשמופעל: גם editor יכול להתחיל קנייה בקבוצה זו.
  @JsonKey(name: 'can_start_shopping', defaultValue: false)
  final bool canStartShopping;

  const GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.joinedAt,
    this.invitedBy,
    this.canStartShopping = false,
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
  // ⚠️ כל הבדיקות משתמשות ב-allowlist pattern - בטוח יותר מ-denylist אם יתווסף role חדש

  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;
  bool get canManageUsers => role == UserRole.owner || role == UserRole.admin;
  bool get canInvite => role == UserRole.owner || role == UserRole.admin;

  /// ✅ Allowlist pattern - unknown לא יקבל הרשאות עריכה
  bool get canEdit =>
      role == UserRole.owner ||
      role == UserRole.admin ||
      role == UserRole.editor;

  /// 🆕 האם יכול להתחיל קנייה
  /// owner/admin - תמיד יכולים
  /// editor - רק אם canStartShopping מופעל
  /// viewer/unknown - לעולם לא
  bool get canShop =>
      role == UserRole.owner ||
      role == UserRole.admin ||
      (role == UserRole.editor && canStartShopping);

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
    bool? canStartShopping,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
      canStartShopping: canStartShopping ?? this.canStartShopping,
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
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: GroupType.unknown)
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
  /// 🔒 Unmodifiable - נוצר דרך Map.unmodifiable ב-factory
  final Map<String, GroupMember> members;

  /// הגדרות הקבוצה
  final GroupSettings settings;

  /// שדות נוספים לפי סוג (כתובת בניין, שם גן, תאריך אירוע)
  /// 🔒 Unmodifiable - נוצר דרך Map.unmodifiable ב-factory
  @JsonKey(name: 'extra_fields')
  final Map<String, dynamic>? extraFields;

  /// 🔒 Private constructor - משתמש ב-factory Group() לאכיפת immutability
  const Group._({
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

  /// 🔧 Factory constructor - עוטף Maps ב-Map.unmodifiable
  factory Group({
    required String id,
    required String name,
    required GroupType type,
    String? description,
    String? imageUrl,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required Map<String, GroupMember> members,
    required GroupSettings settings,
    Map<String, dynamic>? extraFields,
  }) {
    return Group._(
      id: id,
      name: name,
      type: type,
      description: description,
      imageUrl: imageUrl,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      members: Map.unmodifiable(members),
      settings: settings,
      extraFields: extraFields != null ? Map.unmodifiable(extraFields) : null,
    );
  }

  /// יצירת קבוצה חדשה
  ///
  /// 🔧 אם לא עובר id, נוצר אוטומטית עם Uuid
  factory Group.create({
    String? id,
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
      id: id ?? const Uuid().v4(),
      name: name,
      type: type,
      description: description,
      imageUrl: imageUrl,
      createdBy: creatorId,
      createdAt: now,
      updatedAt: now,
      members: {creatorId: owner},
      settings: GroupSettings.defaults(),
      extraFields: extraFields != null ? Map<String, dynamic>.from(extraFields) : null,
    );
  }

  // === Getters ===

  /// מספר החברים
  int get memberCount => members.length;

  /// רשימת החברים
  List<GroupMember> get membersList => members.values.toList();

  /// הבעלים של הקבוצה
  /// 🔧 שימוש ב-cast + firstWhere במקום firstOrNull (תואם Dart ישן יותר)
  GroupMember? get owner {
    final owners = members.values.where((m) => m.isOwner);
    return owners.isEmpty ? null : owners.first;
  }

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
  ///
  /// 🔧 המרה בטוחה של Maps מ-Firestore
  factory Group.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    if (rawData == null) {
      throw ArgumentError('Document data is null for id: ${doc.id}');
    }

    // המרה בטוחה של ה-data הראשי
    final Map<String, dynamic> data;
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(
        rawData.map((k, v) => MapEntry(k.toString(), v)),
      );
    } else {
      throw ArgumentError('Cannot convert ${rawData.runtimeType} to Map<String, dynamic>');
    }

    // 🔧 המרה בטוחה של members (nested Map)
    // ✅ תמיד ממיר - גם אם הסוג נראה תקין, הערכים הפנימיים עלולים להיות Map<dynamic, dynamic>
    final rawMembers = data['members'];
    if (rawMembers != null && rawMembers is Map) {
      data['members'] = Map<String, dynamic>.from(
        rawMembers.map((k, v) {
          final memberData = v is Map
              ? Map<String, dynamic>.from(
                  v.map((mk, mv) => MapEntry(mk.toString(), mv)),
                )
              : v;
          return MapEntry(k.toString(), memberData);
        }),
      );
    }

    // 🔧 המרה בטוחה של extra_fields (nested Map)
    // ✅ תמיד ממיר - Firestore עלול להחזיר Map<dynamic, dynamic>
    final rawExtraFields = data['extra_fields'];
    if (rawExtraFields != null && rawExtraFields is Map) {
      data['extra_fields'] = Map<String, dynamic>.from(
        rawExtraFields.map((k, v) => MapEntry(k.toString(), v)),
      );
    }

    return Group.fromJson({...data, 'id': doc.id});
  }

  // === Copy With ===

  /// 🔧 יוצר עותק חדש עם שינויים
  ///
  /// **הערה:** members ו-extraFields מועתקים (shallow copy) לשמירה על immutability.
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
      // 🔧 Deep copy של Maps לשמירה על immutability
      members: members != null
          ? Map<String, GroupMember>.from(members)
          : Map<String, GroupMember>.from(this.members),
      settings: settings ?? this.settings,
      extraFields: extraFields != null
          ? Map<String, dynamic>.from(extraFields)
          : (this.extraFields != null ? Map<String, dynamic>.from(this.extraFields!) : null),
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
