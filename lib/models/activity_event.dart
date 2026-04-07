// 📄 File: lib/models/activity_event.dart
//
// מודל אירוע פעילות — רישום פעולות חברי הבית ביומן משותף.
//
// 🔗 Related:
//     - ActivityLogService (services/activity_log_service.dart)
//     - ActivityLogProvider (providers/activity_log_provider.dart)
//     - Firestore: /households/{householdId}/activity_log/{eventId}
//
// Version: 1.0
// Last Updated: 07/04/2026

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';

import 'timestamp_converter.dart';

part 'activity_event.g.dart';

/// סוגי אירועים ביומן הפעילות
enum ActivityType {
  @JsonValue('shopping_completed')
  shoppingCompleted,

  @JsonValue('shopping_started')
  shoppingStarted,

  @JsonValue('shopping_joined')
  shoppingJoined,

  @JsonValue('list_created')
  listCreated,

  @JsonValue('item_added')
  itemAdded,

  @JsonValue('stock_updated')
  stockUpdated,

  @JsonValue('member_left')
  memberLeft,

  @JsonValue('role_changed')
  roleChanged,

  @JsonValue('unknown')
  unknown;
}

/// 🔧 ממיר ל-data עם: null → {}, keys ל-String, Map.unmodifiable
class _EventDataConverter
    implements JsonConverter<Map<String, dynamic>, Object?> {
  const _EventDataConverter();

  @override
  Map<String, dynamic> fromJson(Object? json) {
    if (json == null) return const {};
    if (json is! Map) return const {};
    return Map.unmodifiable(
      Map<String, dynamic>.from(
        json.map((k, v) => MapEntry(k.toString(), v)),
      ),
    );
  }

  @override
  Object toJson(Map<String, dynamic> data) => data;
}

/// אירוע פעילות בבית
@immutable
@JsonSerializable(explicitToJson: true)
class ActivityEvent {
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(name: 'household_id', defaultValue: '')
  final String householdId;

  /// סוג האירוע
  @JsonKey(unknownEnumValue: ActivityType.unknown)
  final ActivityType type;

  /// uid של מי שביצע את הפעולה
  @JsonKey(name: 'actor_id', defaultValue: '')
  final String actorId;

  /// שם מי שביצע (cache — למניעת lookup)
  @JsonKey(name: 'actor_name', defaultValue: '')
  final String actorName;

  /// מתי קרה
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// מידע ספציפי לסוג האירוע
  @_EventDataConverter()
  final Map<String, dynamic> data;

  const ActivityEvent({
    required this.id,
    required this.householdId,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.createdAt,
    this.data = const {},
  });

  // ── Data helpers ──

  String? get listId => data['list_id'] as String?;
  String? get listName => data['list_name'] as String?;
  String? get storeName => data['store_name'] as String?;
  String? get itemName => data['item_name'] as String?;
  String? get productName => data['product_name'] as String?;
  int? get itemCount => data['item_count'] as int?;
  String? get targetName => data['target_name'] as String?;
  String? get newRole => data['new_role'] as String?;

  factory ActivityEvent.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityEventToJson(this);

  @override
  String toString() =>
      'ActivityEvent(id: $id, type: $type, actor: $actorName)';
}
