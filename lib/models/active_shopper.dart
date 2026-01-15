// 📄 File: lib/models/active_shopper.dart
//
// 🇮🇱 קונה פעיל בקנייה משותפת:
//     - userId: מזהה המשתמש
//     - joinedAt: מתי הצטרף לקנייה
//     - isStarter: האם הוא זה שהתחיל (הראשון)
//     - isActive: האם עדיין פעיל (או עזב)
//
// 🇬🇧 Active shopper in collaborative shopping:
//     - userId: User identifier
//     - joinedAt: When joined the shopping session
//     - isStarter: Is the one who started (first)
//     - isActive: Is still active (or left)
//
// 💡 תרחיש שימוש:
//     1. אבא מתחיל קנייה → ActiveShopper.starter(userId: 'dad')
//     2. אמא מצטרפת → ActiveShopper.helper(userId: 'mom')
//     3. אבא עוזב → shopper.copyWith(isActive: false)
//     4. hasLeft == true
//
// 🔗 Related:
//     - ShoppingSession (models/shopping_session.dart)
//     - ActiveShoppingScreen (screens/shopping/active/)
//     - ShoppingProvider (providers/shopping_provider.dart)

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

/// 🇮🇱 קונה פעיל בקנייה משותפת
/// 🇬🇧 Active shopper in collaborative shopping
@immutable
@JsonSerializable()
class ActiveShopper {
  /// 🇮🇱 מזהה המשתמש
  /// 🇬🇧 User ID
  /// 🔄 תאימות לאחור: קורא גם user_id וגם userId
  @JsonKey(name: 'user_id', readValue: _readUserId)
  final String userId;

  /// 🇮🇱 מתי הצטרף לקנייה
  /// 🇬🇧 When joined the shopping session
  /// 🔄 תאימות לאחור: קורא גם joined_at וגם joinedAt
  @TimestampConverter()
  @JsonKey(name: 'joined_at', readValue: _readJoinedAt)
  final DateTime joinedAt;

  /// 🇮🇱 האם זה האדם שהתחיל את הקנייה (הראשון)
  /// 🇬🇧 Is this the person who started the shopping (first one)
  @JsonKey(name: 'is_starter', defaultValue: false)
  final bool isStarter;

  /// 🇮🇱 האם עדיין פעיל (או שעזב)
  /// 🇬🇧 Is still active (or left)
  @JsonKey(name: 'is_active', defaultValue: true)
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
      isActive: true,
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
      isActive: true,
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
