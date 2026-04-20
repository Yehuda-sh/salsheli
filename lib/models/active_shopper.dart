// lib/models/active_shopper.dart — Active shopper model — who is currently shopping (userId, startedAt, isActive)

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'timestamp_converter.dart';

part 'active_shopper.g.dart';

// ---- Backward Compatibility Helpers ----
// 🔄 תמיכה גם ב-snake_case וגם ב-camelCase מהשרת

/// קורא user_id או userId (תאימות לאחור)
Object? _readUserId(Map<dynamic, dynamic> json, String key) =>
    json['user_id'] ?? json['userId'];

/// קורא joined_at או joinedAt (תאימות לאחור)
Object? _readJoinedAt(Map<dynamic, dynamic> json, String key) =>
    json['joined_at'] ?? json['joinedAt'];

/// קורא is_starter או isStarter (תאימות לאחור)
Object? _readIsStarter(Map<dynamic, dynamic> json, String key) =>
    json['is_starter'] ?? json['isStarter'];

/// קורא is_active או isActive (תאימות לאחור)
Object? _readIsActive(Map<dynamic, dynamic> json, String key) =>
    json['is_active'] ?? json['isActive'];

/// 🇮🇱 קונה פעיל בקנייה משותפת
/// 🇬🇧 Active shopper in collaborative shopping
@immutable
@JsonSerializable()
class ActiveShopper {
  /// 🇮🇱 מזהה המשתמש
  /// 🇬🇧 User ID
  /// 🔄 תאימות לאחור: קורא גם user_id וגם userId
  @JsonKey(name: 'user_id', readValue: _readUserId, defaultValue: '')
  final String userId;

  /// 🇮🇱 מתי הצטרף לקנייה
  /// 🇬🇧 When joined the shopping session
  /// 🔄 תאימות לאחור: קורא גם joined_at וגם joinedAt
  @TimestampConverter()
  @JsonKey(name: 'joined_at', readValue: _readJoinedAt)
  final DateTime joinedAt;

  /// 🇮🇱 האם זה האדם שהתחיל את הקנייה (הראשון)
  /// 🇬🇧 Is this the person who started the shopping (first one)
  @JsonKey(name: 'is_starter', readValue: _readIsStarter, defaultValue: false)
  final bool isStarter;

  /// 🇮🇱 האם עדיין פעיל (או שעזב)
  /// 🇬🇧 Is still active (or left)
  @JsonKey(name: 'is_active', readValue: _readIsActive, defaultValue: true)
  final bool isActive;

  // ---- Helper Getters ----

  /// 🇮🇱 האם הקונה עזב את הקנייה
  /// 🇬🇧 Has the shopper left the shopping session
  bool get hasLeft => !isActive;

  /// 🇮🇱 האם זה עוזר (לא ה-starter)
  /// 🇬🇧 Is this a helper (not the starter)
  bool get isHelper => !isStarter;

  const ActiveShopper({
    required this.userId,
    required this.joinedAt,
    required this.isStarter,
    this.isActive = true,
  });

  /// 🇮🇱 יצירת קונה חדש שמתחיל קנייה
  /// 🇬🇧 Create new shopper who starts shopping
  factory ActiveShopper.starter({
    required String userId,
    DateTime? now,
  }) {
    return ActiveShopper(
      userId: userId,
      joinedAt: now ?? DateTime.now(),
      isStarter: true,
    );
  }

  /// 🇮🇱 יצירת קונה חדש שמצטרף לקנייה
  /// 🇬🇧 Create new shopper who joins shopping
  factory ActiveShopper.helper({
    required String userId,
    DateTime? now,
  }) {
    return ActiveShopper(
      userId: userId,
      joinedAt: now ?? DateTime.now(),
      isStarter: false,
    );
  }

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  ActiveShopper copyWith({
    String? userId,
    DateTime? joinedAt,
    bool? isStarter,
    bool? isActive,
  }) {
    return ActiveShopper(
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      isStarter: isStarter ?? this.isStarter,
      isActive: isActive ?? this.isActive,
    );
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory ActiveShopper.fromJson(Map<String, dynamic> json) =>
      _$ActiveShopperFromJson(json);

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() => _$ActiveShopperToJson(this);

  @override
  String toString() => 'ActiveShopper(userId: $userId, isStarter: $isStarter, isActive: $isActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveShopper &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          joinedAt == other.joinedAt &&
          isStarter == other.isStarter &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(userId, joinedAt, isStarter, isActive);
}
