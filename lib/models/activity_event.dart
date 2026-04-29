// lib/models/activity_event.dart — Activity event model — household activity log entries (type, actor, data, timestamp)

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

  @JsonValue('member_joined')
  memberJoined,

  @JsonValue('role_changed')
  roleChanged,

  @JsonValue('list_deleted')
  listDeleted,

  @JsonValue('list_shared')
  listShared,

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

  String? get listName => data['list_name'] as String?;
  String? get itemName => data['item_name'] as String?;
  String? get productName => data['product_name'] as String?;
  String? get targetName => data['target_name'] as String?;
  String? get newRole => data['new_role'] as String?;

  factory ActivityEvent.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityEventToJson(this);

  @override
  String toString() =>
      'ActivityEvent(id: $id, type: $type, actor: $actorName)';
}
