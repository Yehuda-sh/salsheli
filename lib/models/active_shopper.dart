// 📄 File: lib/models/active_shopper.dart
//
// 🎯 Purpose: מודל של קונה פעיל בקנייה משותפת
//
// ✨ Features:
// - תמיכה בקנייה משותפת (מספר אנשים קונים ביחד)
// - מעקב אחרי מי התחיל את הקנייה (isStarter)
// - מעקב אחרי מי פעיל ומי עזב (isActive)
// - JSON serialization לסנכרון עם Firebase
//
// 🔄 Usage:
// ```dart
// // התחלת קנייה - אבא מתחיל
// final starter = ActiveShopper(
//   userId: 'אבא',
//   joinedAt: DateTime.now(),
//   isStarter: true,
// );
//
// // הצטרפות - אמא מצטרפת
// final helper = ActiveShopper(
//   userId: 'אמא',
//   joinedAt: DateTime.now(),
//   isStarter: false,
// );
//
// // עזיבה - אבא עוזב
// final left = starter.copyWith(isActive: false);
// ```

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'timestamp_converter.dart';

part 'active_shopper.g.dart';

/// 🇮🇱 קונה פעיל בקנייה משותפת
/// 🇬🇧 Active shopper in collaborative shopping
@immutable
@JsonSerializable()
class ActiveShopper {
  /// 🇮🇱 מזהה המשתמש
  /// 🇬🇧 User ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// 🇮🇱 מתי הצטרף לקנייה
  /// 🇬🇧 When joined the shopping session
  @TimestampConverter()
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  /// 🇮🇱 האם זה האדם שהתחיל את הקנייה (הראשון)
  /// 🇬🇧 Is this the person who started the shopping (first one)
  @JsonKey(name: 'is_starter', defaultValue: false)
  final bool isStarter;

  /// 🇮🇱 האם עדיין פעיל (או שעזב)
  /// 🇬🇧 Is still active (or left)
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

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
  factory ActiveShopper.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('📥 ActiveShopper.fromJson: userId=${json['user_id']}, isStarter=${json['is_starter']}');
    }
    return _$ActiveShopperFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    if (kDebugMode) {
      debugPrint('📤 ActiveShopper.toJson: userId=$userId, isStarter=$isStarter, isActive=$isActive');
    }
    return _$ActiveShopperToJson(this);
  }

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
