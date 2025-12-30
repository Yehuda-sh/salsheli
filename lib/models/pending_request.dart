// 📄 File: lib/models/pending_request.dart
//
// 🇮🇱 מודל לבקשה ממתינה לאישור:
//     - Editor שולח בקשה להוספה/עריכה/מחיקה
//     - Owner/Admin מאשר או דוחה
//     - תומך ב-3 סוגי בקשות: addItem, editItem, deleteItem
//     - כולל מטאדאטה (cache) לשמות המבקש והמאשר
//     - ולידציה לפי type (isValidForType)
//
// 🇬🇧 Model for pending approval request:
//     - Editor sends request for add/edit/delete
//     - Owner/Admin approves or rejects
//     - Supports 3 request types: addItem, editItem, deleteItem
//     - Includes metadata (cache) for requester/reviewer names
//     - Validation by type (isValidForType)
//
// 📋 Request Data Structure (by type):
//     - addItem:    { name, quantity?, unitPrice?, barcode?, ... }
//     - editItem:   { itemId, changes: { name?, quantity?, ... } }
//     - deleteItem: { itemId }
//
// 🔗 Related:
//     - request_type.dart - סוגי בקשות (addItem/editItem/deleteItem)
//     - request_status.dart - סטטוסים (pending/approved/rejected)
//     - firebase_shopping_lists_repository.dart - שמירה/אישור/דחייה
//
// Version: 1.1 - DateTime converter, validation helpers, equality fix
// Last Updated: 30/12/2025

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums/request_type.dart';
import 'enums/request_status.dart';
import 'shared_user.dart' show FlexibleDateTimeConverter, NullableFlexibleDateTimeConverter;

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
  @FlexibleDateTimeConverter()
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
    this.listName,
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

  // === Request Data Helpers ===
  // 🔧 גישה בטוחה לנתוני הבקשה לפי type

  /// 🔧 מזהה הפריט (ל-editItem/deleteItem)
  String? get targetItemId => requestData['itemId'] as String?;

  /// 🔧 שם המוצר המבוקש (ל-addItem)
  String? get requestedName => requestData['name'] as String?;

  /// 🔧 השינויים המבוקשים (ל-editItem)
  Map<String, dynamic>? get changes {
    final data = requestData['changes'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  /// 🔧 האם הבקשה תקינה לפי הסוג שלה
  ///
  /// - addItem: חייב להיות name
  /// - editItem: חייב להיות itemId + changes
  /// - deleteItem: חייב להיות itemId
  /// - inviteToList: חייב להיות userId או email
  bool get isValidForType {
    switch (type) {
      case RequestType.addItem:
        return requestedName != null && requestedName!.isNotEmpty;
      case RequestType.editItem:
        return targetItemId != null && targetItemId!.isNotEmpty && changes != null;
      case RequestType.deleteItem:
        return targetItemId != null && targetItemId!.isNotEmpty;
      case RequestType.inviteToList:
        final userId = requestData['userId'] as String?;
        final email = requestData['email'] as String?;
        return (userId?.isNotEmpty ?? false) || (email?.isNotEmpty ?? false);
    }
  }

  // === Reviewer Validation Helpers ===

  /// 🔧 האם יש נתוני reviewer מלאים (id + תאריך)
  bool get hasReviewerData => reviewerId != null && reviewedAt != null;

  /// 🔧 האם יש סיבת דחייה (רלוונטי רק ל-rejected)
  bool get hasRejectionReason => isRejected && (rejectionReason?.isNotEmpty ?? false);

  /// 🔧 האם הבקשה תקינה מבחינת נתוני אישור/דחייה
  ///
  /// - pending: לא צריך reviewer data
  /// - approved/rejected: צריך reviewer data
  /// - rejected: עדיף שיהיה גם rejectionReason
  bool get hasValidReviewData {
    if (isPending) return true; // לא צריך עדיין
    return hasReviewerData;
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
      requestData: requestData,
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
      requestData: requestData ?? this.requestData,
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
