import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums/request_type.dart';
import 'enums/request_status.dart';

part 'pending_request.g.dart';

/// בקשה ממתינה לאישור
@JsonSerializable(explicitToJson: true)
class PendingRequest {
  /// מזהה הבקשה
  final String id;

  /// מזהה הרשימה
  @JsonKey(name: 'list_id')
  final String listId;

  /// מזהה המשתמש שביקש
  @JsonKey(name: 'requester_id')
  final String requesterId;

  /// סוג הבקשה
  final RequestType type;

  /// סטטוס הבקשה
  final RequestStatus status;

  /// מתי נוצרה הבקשה
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// תוכן הבקשה (משתנה לפי type)
  /// 
  /// דוגמאות:
  /// - addItem: { name, quantity, unitPrice, ... }
  /// - editItem: { itemId, changes: { name: 'new', quantity: 5 } }
  /// - deleteItem: { itemId }
  @JsonKey(name: 'request_data')
  final Map<String, dynamic> requestData;

  // === אישור/דחייה ===

  /// מזהה המשתמש שאישר/דחה
  @JsonKey(name: 'reviewer_id')
  final String? reviewerId;

  /// מתי אושר/נדחה
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

  const PendingRequest({
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
  });

  /// JSON serialization
  factory PendingRequest.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestToJson(this);

  // === Helpers ===

  /// האם הבקשה ממתינה
  bool get isPending => status == RequestStatus.pending;

  /// האם הבקשה אושרה
  bool get isApproved => status == RequestStatus.approved;

  /// האם הבקשה נדחתה
  bool get isRejected => status == RequestStatus.rejected;

  /// כמה זמן עבר מאז הבקשה (בדקות)
  int get minutesAgo {
    return DateTime.now().difference(createdAt).inMinutes;
  }

  /// טקסט של כמה זמן עבר
  String get timeAgoText {
    final minutes = minutesAgo;
    if (minutes < 60) {
      return 'לפני $minutes דק\'';
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return 'לפני $hours שעות';
    }
    final days = hours ~/ 24;
    return 'לפני $days ימים';
  }

  // === Factory Constructors ===

  /// יצירת בקשה חדשה
  factory PendingRequest.newRequest({
    required String listId,
    required String requesterId,
    required RequestType type,
    required Map<String, dynamic> requestData,
    String? requesterName,
  }) {
    return PendingRequest(
      id: const Uuid().v4(),
      listId: listId,
      requesterId: requesterId,
      type: type,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      requestData: requestData,
      requesterName: requesterName,
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
  }) {
    return PendingRequest(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      requesterId: requesterId ?? this.requesterId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requestData: requestData ?? this.requestData,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requesterName: requesterName ?? this.requesterName,
      reviewerName: reviewerName ?? this.reviewerName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PendingRequest &&
        other.id == id &&
        other.listId == listId &&
        other.requesterId == requesterId;
  }

  @override
  int get hashCode => id.hashCode ^ listId.hashCode ^ requesterId.hashCode;

  @override
  String toString() {
    return 'PendingRequest(id: $id, type: $type, status: $status, requester: $requesterName)';
  }
}
