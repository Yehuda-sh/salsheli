// lib/models/pending_request.dart — Pending request model — editor's add/edit/delete requests awaiting admin approval

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'enums/request_status.dart';
import 'enums/request_type.dart';
import 'timestamp_converter.dart' show FlexibleDateTimeConverter, NullableFlexibleDateTimeConverter;


part 'pending_request.g.dart';

// ---- JSON Converters ----

/// 🔧 ממיר ל-requestData עם:
/// - null → {} ריק
/// - המרת keys ל-String (Firestore לפעמים מחזיר `Map<dynamic, dynamic>`)
/// - עטיפה ב-Map.unmodifiable
class _RequestDataConverter
    implements JsonConverter<Map<String, dynamic>, Object?> {
  const _RequestDataConverter();

  @override
  Map<String, dynamic> fromJson(Object? json) {
    if (json == null) return const {};
    if (json is! Map) return const {};

    // המרה בטוחה + unmodifiable
    return Map.unmodifiable(
      Map<String, dynamic>.from(
        json.map((k, v) => MapEntry(k.toString(), v)),
      ),
    );
  }

  @override
  Object toJson(Map<String, dynamic> data) => data;
}

/// בקשה ממתינה לאישור
@immutable
@JsonSerializable(explicitToJson: true)
class PendingRequest {
  /// מזהה הבקשה
  @JsonKey(defaultValue: '')
  final String id;

  /// מזהה הרשימה
  @JsonKey(name: 'list_id', defaultValue: '')
  final String listId;

  /// מזהה המשתמש שביקש
  @JsonKey(name: 'requester_id', defaultValue: '')
  final String requesterId;

  /// סוג הבקשה
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: RequestType.unknown)
  final RequestType type;

  /// סטטוס הבקשה
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: RequestStatus.unknown)
  final RequestStatus status;

  /// מתי נוצרה הבקשה
  @FlexibleDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// תוכן הבקשה (משתנה לפי type)
  ///
  /// דוגמאות:
  /// - addItem: { name, quantity, unitPrice, ... }
  /// - editItem: { itemId, changes: { name: 'new', quantity: 5 } }
  /// - deleteItem: { itemId }
  ///
  /// 🔒 Unmodifiable via _RequestDataConverter
  /// 🔧 Handles: null → {}, `Map<dynamic,dynamic>` → `Map<String,dynamic>`
  @JsonKey(name: 'request_data')
  @_RequestDataConverter()
  final Map<String, dynamic> requestData;

  // === אישור/דחייה ===

  /// מזהה המשתמש שאישר/דחה
  @JsonKey(name: 'reviewer_id')
  final String? reviewerId;

  /// מתי אושר/נדחה
  @NullableFlexibleDateTimeConverter()
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;

  /// סיבת דחייה
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  // === מטאדאטה (cache) ===

  /// שם המשתמש שביקש (cache)
  @JsonKey(name: 'requester_name')
  final String? requesterName;

  /// שם המשתמש שאישר/דחה (cache)
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;

  /// 🔧 שם הרשימה (cache) - לתצוגה ברשימת בקשות ללא fetch נוסף
  @JsonKey(name: 'list_name')
  final String? listName;

  /// 🔒 Private constructor - משתמש ב-factory PendingRequest() לאכיפת immutability
  const PendingRequest._({
    required this.id,
    required this.listId,
    required this.requesterId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.requestData,
    this.reviewerId,
    this.reviewedAt,
    this.rejectionReason,
    this.requesterName,
    this.reviewerName,
    this.listName,
  });

  /// 🔧 Factory constructor - עוטף requestData ב-Map.unmodifiable
  factory PendingRequest({
    required String id,
    required String listId,
    required String requesterId,
    required RequestType type,
    required RequestStatus status,
    required DateTime createdAt,
    required Map<String, dynamic> requestData,
    String? reviewerId,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? requesterName,
    String? reviewerName,
    String? listName,
  }) {
    return PendingRequest._(
      id: id,
      listId: listId,
      requesterId: requesterId,
      type: type,
      status: status,
      createdAt: createdAt,
      requestData: Map.unmodifiable(requestData),
      reviewerId: reviewerId,
      reviewedAt: reviewedAt,
      rejectionReason: rejectionReason,
      requesterName: requesterName,
      reviewerName: reviewerName,
      listName: listName,
    );
  }

  /// JSON serialization
  factory PendingRequest.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestToJson(this);

  // === Helpers ===

  /// האם הבקשה ממתינה (כולל unknown - שלא ייעלמו מה-UI)
  bool get isPending => status.isPending;

  /// האם הבקשה אושרה
  bool get isApproved => status.isApproved;

  /// האם הבקשה נדחתה
  bool get isRejected => status.isRejected;

  // === Request Data Helpers ===
  // 🔧 גישה בטוחה לנתוני הבקשה לפי type

  /// 🔧 השינויים המבוקשים (ל-editItem)
  Map<String, dynamic>? get changes {
    final data = requestData['changes'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  // === Factory Constructors ===

  /// יצירת בקשה חדשה
  factory PendingRequest.newRequest({
    String? id,
    required String listId,
    required String requesterId,
    required RequestType type,
    required Map<String, dynamic> requestData,
    String? requesterName,
    String? listName,
  }) {
    return PendingRequest(
      id: id ?? const Uuid().v4(),
      listId: listId,
      requesterId: requesterId,
      type: type,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      requestData: requestData, // Factory עוטף ב-Map.unmodifiable
      requesterName: requesterName,
      listName: listName,
    );
  }

  /// Copy with
  PendingRequest copyWith({
    String? id,
    String? listId,
    String? requesterId,
    RequestType? type,
    RequestStatus? status,
    DateTime? createdAt,
    Map<String, dynamic>? requestData,
    String? reviewerId,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? requesterName,
    String? reviewerName,
    String? listName,
  }) {
    return PendingRequest(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      requesterId: requesterId ?? this.requesterId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requestData: requestData ?? this.requestData, // Factory עוטף ב-Map.unmodifiable
      reviewerId: reviewerId ?? this.reviewerId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requesterName: requesterName ?? this.requesterName,
      reviewerName: reviewerName ?? this.reviewerName,
      listName: listName ?? this.listName,
    );
  }

  // === Equality ===
  // 🔧 שוויון לפי id בלבד - כמו בשאר המודלים

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PendingRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PendingRequest(id: $id, type: $type, status: $status, requester: $requesterName)';
  }
}
