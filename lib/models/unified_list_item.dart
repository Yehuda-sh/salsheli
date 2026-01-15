// 📄 File: lib/models/unified_list_item.dart
//
// 🇮🇱 פריט מאוחד ברשימת קניות (Hybrid Approach):
//     - תומך גם במוצרים (product) וגם במשימות (task)
//     - שדות משותפים: id, name, type, isChecked, category, notes
//     - שדות ייחודיים למוצרים: productData (quantity, unitPrice, barcode, unit)
//     - שדות ייחודיים למשימות: taskData (dueDate, assignedTo, priority)
//     - סוגי משנה: task/whoBrings/voting (דרך itemSubType)
//     - Helpers: quantity, totalPrice, dueDate, isUrgent, isWhoBrings, isVoting
//     - Migration: fromReceiptItem() להמרה מהמבנה הישן
//
// 🇬🇧 Unified list item (Hybrid Approach):
//     - Supports both products and tasks
//     - Shared fields: id, name, type, isChecked, category, notes
//     - Product-specific: productData (quantity, unitPrice, barcode, unit)
//     - Task-specific: taskData (dueDate, assignedTo, priority)
//     - Sub-types: task/whoBrings/voting (via itemSubType)
//     - Helpers for easy access
//     - Migration support from ReceiptItem
//
// Version: 2.1 - Round-trip safety, safe parsing, immutable Maps, snake_case support
// Last Updated: 13/01/2026
//

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/foundation.dart' show immutable, kDebugMode;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums/item_type.dart';
import 'receipt.dart';

part 'unified_list_item.g.dart';

// ════════════════════════════════════════════
// JSON Read Helpers (backward compat + safe casting)
// ════════════════════════════════════════════

/// 🔧 קורא productData עם תמיכה ב-snake_case וקאסט בטוח מ-Firestore
Object? _readProductData(Map<dynamic, dynamic> json, String key) {
  final data = json['productData'] ?? json['product_data'];
  if (data == null) return null;
  if (data is! Map) return null;
  // Safe cast from Map<dynamic, dynamic> to Map<String, dynamic>
  return Map<String, dynamic>.from(data);
}

/// 🔧 קורא taskData עם תמיכה ב-snake_case וקאסט בטוח מ-Firestore
Object? _readTaskData(Map<dynamic, dynamic> json, String key) {
  final data = json['taskData'] ?? json['task_data'];
  if (data == null) return null;
  if (data is! Map) return null;
  // Safe cast from Map<dynamic, dynamic> to Map<String, dynamic>
  return Map<String, dynamic>.from(data);
}

/// 🔧 קורא checkedAt עם תמיכה ב-snake_case
Object? _readCheckedAt(Map<dynamic, dynamic> json, String key) =>
    json['checked_at'] ?? json['checkedAt'];

/// 🔧 קורא checkedBy עם תמיכה ב-snake_case
Object? _readCheckedBy(Map<dynamic, dynamic> json, String key) =>
    json['checked_by'] ?? json['checkedBy'];

/// 🔧 קורא imageUrl עם תמיכה ב-snake_case
Object? _readImageUrl(Map<dynamic, dynamic> json, String key) =>
    json['image_url'] ?? json['imageUrl'];

// ════════════════════════════════════════════
// Safe Parsing Helpers
// ════════════════════════════════════════════

/// 🔧 פרסור בטוח של DateTime מכל סוג (nullable)
/// 🇬🇧 Safe DateTime parsing from any type (nullable)
///
/// תומך ב: String (ISO), Timestamp (Firestore), int (epoch ms), DateTime, null
/// מחזיר null על טיפוס לא מוכר או ערך לא תקין
DateTime? _safeParseDateTimeNullable(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  // Unknown type - return null instead of throwing
  if (kDebugMode) {
    // ignore: avoid_print
    print('⚠️ _safeParseDateTimeNullable: unknown type ${value.runtimeType}');
  }
  return null;
}

/// 🔧 פרסור בטוח של List<Map> מכל סוג
/// 🇬🇧 Safe List<Map> parsing from any type
///
/// מסנן ערכים שאינם Map, מחזיר רשימה ריקה אם הקלט לא תקין
List<Map<String, dynamic>> _safeParseListOfMaps(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  return value
      .whereType<Map>() // Filter only Map items
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// 🇮🇱 פריט מאוחד ברשימה (מוצר או משימה)
/// 🇬🇧 Unified list item (product or task)
@immutable
@JsonSerializable(explicitToJson: true)
class UnifiedListItem {
  /// מזהה ייחודי
  final String id;

  /// שם המוצר/משימה
  final String name;

  /// סוג הפריט (product/task)
  /// ✅ unknownEnumValue: מונע קריסה אם מגיע ערך לא מוכר מהשרת
  @JsonKey(unknownEnumValue: ItemType.unknown)
  final ItemType type;

  /// 🆕 ערך הטיפוס המקורי (לשימור round-trip כשהסוג לא מוכר)
  /// 🇬🇧 Original type value (preserves round-trip when type is unknown)
  ///
  /// ⚠️ זה שדה פנימי! משמש רק לשמירה על הערך המקורי ב-toJson.
  /// אם `type == ItemType.unknown`, נשמור כאן את הערך המקורי (למשל "service")
  /// כדי לא לאבד מידע בשמירה חוזרת.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? _originalTypeValue;

  /// האם סומן (✅)
  @JsonKey(defaultValue: false)
  final bool isChecked;

  /// קטגוריה (אופציונלי)
  final String? category;

  /// הערות (אופציונלי)
  final String? notes;

  /// 🖼️ קישור לתמונת המוצר (אופציונלי)
  /// 🔄 readValue: תמיכה ב-image_url וגם imageUrl
  @JsonKey(name: 'image_url', readValue: _readImageUrl)
  final String? imageUrl;

  /// 🆕 שדות ייחודיים למוצרים (Map)
  /// quantity, unitPrice, barcode, unit
  /// 🔄 readValue: תמיכה ב-snake_case + קאסט בטוח מ-Firestore
  @JsonKey(readValue: _readProductData)
  final Map<String, dynamic>? productData;

  /// 🆕 שדות ייחודיים למשימות (Map)
  /// dueDate, assignedTo, priority
  /// 🔄 readValue: תמיכה ב-snake_case + קאסט בטוח מ-Firestore
  @JsonKey(readValue: _readTaskData)
  final Map<String, dynamic>? taskData;

  /// 🆕 מזהה המשתמש שסימן את הפריט
  /// 🔄 readValue: תמיכה ב-checked_by וגם checkedBy
  @JsonKey(name: 'checked_by', readValue: _readCheckedBy)
  final String? checkedBy;

  /// 🆕 מתי סומן הפריט
  /// 🔄 readValue: תמיכה ב-checked_at וגם checkedAt
  @JsonKey(name: 'checked_at', readValue: _readCheckedAt)
  final String? checkedAt;

  const UnifiedListItem({
    required this.id,
    required this.name,
    required this.type,
    String? originalTypeValue,
    this.isChecked = false,
    this.category,
    this.notes,
    this.imageUrl,
    this.productData,
    this.taskData,
    this.checkedBy,
    this.checkedAt,
  }) : _originalTypeValue = originalTypeValue;

  // ════════════════════════════════════════════
  // Product Helpers (גישה קלה לשדות מוצר)
  // ════════════════════════════════════════════

  /// 🇮🇱 כמות (רק למוצרים)
  /// 🇬🇧 Quantity (products only)
  /// 🔧 תומך ב-int ו-num מ-Firestore/JSON
  int? get quantity => (productData?['quantity'] as num?)?.toInt();

  /// 🇮🇱 מחיר ליחידה (רק למוצרים)
  /// 🇬🇧 Unit price (products only)
  /// 🔧 תומך ב-int, double, num + snake_case (unit_price)
  double? get unitPrice =>
      ((productData?['unitPrice'] ?? productData?['unit_price']) as num?)?.toDouble();

  /// 🇮🇱 ברקוד (רק למוצרים)
  /// 🇬🇧 Barcode (products only)
  String? get barcode => productData?['barcode'] as String?;

  /// 🇮🇱 יחידת מידה (רק למוצרים)
  /// 🇬🇧 Unit (products only)
  String? get unit => productData?['unit'] as String? ?? 'יח\'';

  /// 🇮🇱 מותג/חברה (רק למוצרים)
  /// 🇬🇧 Brand (products only)
  String? get brand => productData?['brand'] as String?;

  /// 🇮🇱 מחיר כולל (כמות × מחיר ליחידה)
  /// 🇬🇧 Total price (quantity × unit price)
  double? get totalPrice {
    if (type != ItemType.product) return null;
    return (quantity ?? 0) * (unitPrice ?? 0.0);
  }

  // ════════════════════════════════════════════
  // Task Helpers (גישה קלה לשדות משימה)
  // ════════════════════════════════════════════

  /// 🇮🇱 סוג פריט משנה (task/whoBrings/voting)
  /// 🇬🇧 Sub item type (task/whoBrings/voting)
  ///
  /// מזהה את הסוג המדויק של פריט מסוג task:
  /// - 'task' - משימה רגילה
  /// - 'whoBrings' - פריט "מי מביא"
  /// - 'voting' - פריט הצבעה
  /// 🔧 תמיכה ב-itemType וגם item_type
  String get itemSubType =>
      taskData?['itemType'] as String? ?? taskData?['item_type'] as String? ?? 'task';

  /// 🇮🇱 האם פריט "מי מביא"
  /// 🇬🇧 Is this a "Who Brings" item
  bool get isWhoBrings => itemSubType == 'whoBrings';

  /// 🇮🇱 האם פריט הצבעה
  /// 🇬🇧 Is this a voting item
  bool get isVoting => itemSubType == 'voting';

  /// 🇮🇱 האם משימה רגילה (לא whoBrings ולא voting)
  /// 🇬🇧 Is this a regular task (not whoBrings or voting)
  bool get isRegularTask => type == ItemType.task && itemSubType == 'task';

  /// 🇮🇱 תאריך יעד (רק למשימות)
  /// 🇬🇧 Due date (tasks only)
  /// 🔧 תומך ב-String (ISO), Timestamp (Firestore), int (epoch), DateTime
  DateTime? get dueDate {
    final value = taskData?['dueDate'] ?? taskData?['due_date'];
    return _safeParseDateTimeNullable(value);
  }

  /// 🇮🇱 למי הוקצה (רק למשימות)
  /// 🇬🇧 Assigned to (tasks only)
  /// 🔧 תמיכה ב-assignedTo וגם assigned_to
  String? get assignedTo =>
      taskData?['assignedTo'] as String? ?? taskData?['assigned_to'] as String?;

  /// 🇮🇱 עדיפות (low/medium/high)
  /// 🇬🇧 Priority (low/medium/high)
  String get priority => taskData?['priority'] as String? ?? 'medium';

  /// 🇮🇱 האם משימה דחופה (פחות מ-3 ימים)
  /// 🇬🇧 Is task urgent (less than 3 days)
  ///
  /// ⚠️ עובד רק למשימות רגילות (לא whoBrings/voting)
  bool get isUrgent {
    // רק משימות רגילות יכולות להיות דחופות
    if (!isRegularTask) return false;
    final due = dueDate;
    if (due == null) return false;
    return due.difference(DateTime.now()).inDays <= 3;
  }

  // ════════════════════════════════════════════
  // "Who Brings" Helpers (גישה קלה לשדות מי מביא)
  // ════════════════════════════════════════════

  /// 🇮🇱 כמות אנשים נדרשים להביא (ברשימות "מי מביא")
  /// 🇬🇧 Number of people needed to bring (for "Who Brings" lists)
  /// 🔧 תומך ב-int, num + snake_case (needed_count)
  int get neededCount =>
      ((taskData?['neededCount'] ?? taskData?['needed_count']) as num?)?.toInt() ?? 1;

  /// 🇮🇱 רשימת מתנדבים שאמרו "אני מביא"
  /// 🇬🇧 List of volunteers who said "I'll bring"
  /// 🔧 בטוח - מסנן ערכים שאינם Map
  List<Map<String, dynamic>> get volunteers =>
      _safeParseListOfMaps(taskData?['volunteers']);

  /// 🇮🇱 כמות מתנדבים נוכחית
  /// 🇬🇧 Current volunteer count
  int get volunteerCount => volunteers.length;

  /// 🇮🇱 האם הפריט מלא (כל המתנדבים הצטרפו)
  /// 🇬🇧 Is the item full (all volunteers joined)
  bool get isVolunteersFull => volunteerCount >= neededCount;

  /// 🇮🇱 האם משתמש מסוים כבר התנדב
  /// 🇬🇧 Has a specific user already volunteered
  bool hasUserVolunteered(String userId) {
    return volunteers.any((v) => v['userId'] == userId);
  }

  /// 🇮🇱 קבל שמות המתנדבים
  /// 🇬🇧 Get volunteer names
  List<String> get volunteerNames {
    return volunteers
        .map((v) => v['displayName'] as String? ?? 'אנונימי')
        .toList();
  }

  /// 🇮🇱 קבל תצוגת מתנדבים (עם "..." אם יותר מדי)
  /// 🇬🇧 Get volunteer display (with "..." if too many)
  String getVolunteerDisplay({int maxNames = 2}) {
    final names = volunteerNames;
    if (names.isEmpty) return '';
    if (names.length <= maxNames) return names.join(', ');
    return '${names.take(maxNames).join(', ')}...';
  }

  // ════════════════════════════════════════════
  // Voting Helpers (גישה קלה לשדות הצבעה)
  // ════════════════════════════════════════════

  /// 🇮🇱 רשימת מצביעים בעד
  /// 🇬🇧 List of voters in favor
  /// 🔧 בטוח - מסנן ערכים שאינם Map + snake_case
  List<Map<String, dynamic>> get votesFor =>
      _safeParseListOfMaps(taskData?['votesFor'] ?? taskData?['votes_for']);

  /// 🇮🇱 רשימת מצביעים נגד
  /// 🇬🇧 List of voters against
  /// 🔧 בטוח - מסנן ערכים שאינם Map + snake_case
  List<Map<String, dynamic>> get votesAgainst =>
      _safeParseListOfMaps(taskData?['votesAgainst'] ?? taskData?['votes_against']);

  /// 🇮🇱 רשימת נמנעים
  /// 🇬🇧 List of abstained voters
  /// 🔧 בטוח - מסנן ערכים שאינם Map + snake_case
  List<Map<String, dynamic>> get votesAbstain =>
      _safeParseListOfMaps(taskData?['votesAbstain'] ?? taskData?['votes_abstain']);

  /// 🇮🇱 סה"כ מצביעים
  /// 🇬🇧 Total vote count
  int get totalVotes => votesFor.length + votesAgainst.length + votesAbstain.length;

  /// 🇮🇱 אחוז בעד
  /// 🇬🇧 Percentage in favor
  double get forPercentage {
    if (totalVotes == 0) return 0;
    return (votesFor.length / totalVotes) * 100;
  }

  /// 🇮🇱 אחוז נגד
  /// 🇬🇧 Percentage against
  double get againstPercentage {
    if (totalVotes == 0) return 0;
    return (votesAgainst.length / totalVotes) * 100;
  }

  /// 🇮🇱 האם הצבעה חשאית
  /// 🇬🇧 Is voting anonymous
  /// 🔧 תמיכה ב-isAnonymous וגם is_anonymous
  bool get isAnonymousVoting =>
      taskData?['isAnonymous'] as bool? ?? taskData?['is_anonymous'] as bool? ?? false;

  /// 🇮🇱 תאריך סיום הצבעה
  /// 🇬🇧 Voting end date
  /// 🔧 תומך ב-String (ISO), Timestamp (Firestore), int (epoch), DateTime
  DateTime? get votingEndDate {
    final value = taskData?['votingEndDate'] ?? taskData?['voting_end_date'];
    return _safeParseDateTimeNullable(value);
  }

  /// 🇮🇱 האם ההצבעה הסתיימה
  /// 🇬🇧 Has voting ended
  bool get hasVotingEnded {
    final endDate = votingEndDate;
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate);
  }

  /// 🇮🇱 האם משתמש כבר הצביע
  /// 🇬🇧 Has a user already voted
  bool hasUserVoted(String userId) {
    return votesFor.any((v) => v['userId'] == userId) ||
        votesAgainst.any((v) => v['userId'] == userId) ||
        votesAbstain.any((v) => v['userId'] == userId);
  }

  /// 🇮🇱 קבל את ההצבעה של משתמש
  /// 🇬🇧 Get user's vote (for/against/abstain/null)
  String? getUserVote(String userId) {
    if (votesFor.any((v) => v['userId'] == userId)) return 'for';
    if (votesAgainst.any((v) => v['userId'] == userId)) return 'against';
    if (votesAbstain.any((v) => v['userId'] == userId)) return 'abstain';
    return null;
  }

  /// 🇮🇱 תוצאת ההצבעה (for/against/tie/pending)
  /// 🇬🇧 Voting result
  String get votingResult {
    if (!hasVotingEnded) return 'pending';
    if (votesFor.length > votesAgainst.length) return 'for';
    if (votesAgainst.length > votesFor.length) return 'against';
    return 'tie';
  }

  // ════════════════════════════════════════════
  // Factory Constructors
  // ════════════════════════════════════════════

  /// 🇮🇱 יצירת פריט מוצר
  /// 🇬🇧 Create product item
  factory UnifiedListItem.product({
    String? id,
    required String name,
    required int quantity,
    required double unitPrice,
    String? barcode,
    String unit = 'יח\'',
    String? brand,
    bool isChecked = false,
    String? category,
    String? notes,
    String? imageUrl,
    String? checkedBy,
    String? checkedAt,
  }) {
    return UnifiedListItem(
      id: id ?? const Uuid().v4(),
      name: name,
      type: ItemType.product,
      isChecked: isChecked,
      category: category,
      notes: notes,
      imageUrl: imageUrl,
      productData: {
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (barcode != null) 'barcode': barcode,
        'unit': unit,
        if (brand != null) 'brand': brand,
      },
      taskData: null,
      checkedBy: checkedBy,
      checkedAt: checkedAt,
    );
  }

  /// 🇮🇱 יצירת פריט משימה
  /// 🇬🇧 Create task item
  factory UnifiedListItem.task({
    String? id,
    required String name,
    DateTime? dueDate,
    String? assignedTo,
    String priority = 'medium',
    bool isChecked = false,
    String? category,
    String? notes,
    String? imageUrl,
    String? checkedBy,
    String? checkedAt,
  }) {
    return UnifiedListItem(
      id: id ?? const Uuid().v4(),
      name: name,
      type: ItemType.task,
      isChecked: isChecked,
      category: category,
      notes: notes,
      imageUrl: imageUrl,
      productData: null,
      taskData: {
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (assignedTo != null) 'assignedTo': assignedTo,
        'priority': priority,
      },
      checkedBy: checkedBy,
      checkedAt: checkedAt,
    );
  }

  /// 🇮🇱 יצירת פריט "מי מביא"
  /// 🇬🇧 Create "Who Brings" item
  factory UnifiedListItem.whoBrings({
    String? id,
    required String name,
    int neededCount = 1,
    List<Map<String, dynamic>>? volunteers,
    bool isChecked = false,
    String? category,
    String? notes,
    String? imageUrl,
  }) {
    return UnifiedListItem(
      id: id ?? const Uuid().v4(),
      name: name,
      type: ItemType.task, // משתמש ב-task כי זה לא מוצר רגיל
      isChecked: isChecked,
      category: category,
      notes: notes,
      imageUrl: imageUrl,
      taskData: {
        'neededCount': neededCount,
        'volunteers': volunteers ?? [],
        'itemType': 'whoBrings', // סימון מיוחד לזיהוי הסוג
      },
    );
  }

  /// 🇮🇱 יצירת פריט הצבעה
  /// 🇬🇧 Create voting item
  factory UnifiedListItem.voting({
    String? id,
    required String name,
    DateTime? votingEndDate,
    bool isAnonymous = false,
    bool isChecked = false,
    String? category,
    String? notes,
    String? imageUrl,
  }) {
    return UnifiedListItem(
      id: id ?? const Uuid().v4(),
      name: name,
      type: ItemType.task,
      isChecked: isChecked,
      category: category,
      notes: notes,
      imageUrl: imageUrl,
      taskData: {
        'votesFor': const <Map<String, dynamic>>[],
        'votesAgainst': const <Map<String, dynamic>>[],
        'votesAbstain': const <Map<String, dynamic>>[],
        'isAnonymous': isAnonymous,
        if (votingEndDate != null) 'votingEndDate': votingEndDate.toIso8601String(),
        'itemType': 'voting', // סימון מיוחד לזיהוי הסוג
      },
    );
  }

  /// 🇮🇱 המרה מ-ReceiptItem (migration)
  /// 🇬🇧 Convert from ReceiptItem (migration)
  factory UnifiedListItem.fromReceiptItem(ReceiptItem item) {
    return UnifiedListItem.product(
      id: item.id.isEmpty ? const Uuid().v4() : item.id,
      name: item.name ?? 'מוצר ללא שם',
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      barcode: item.barcode,
      unit: item.unit ?? 'יח\'',
      isChecked: item.isChecked,
      category: item.category,
      checkedBy: item.checkedBy,
      checkedAt: item.checkedAt?.toIso8601String(),
    );
  }

  /// 🇮🇱 יצירה מתוכן בקשה (למערכת Sharing)
  /// 🇬🇧 Create from request data (for Sharing system)
  ///
  /// מקבל Map עם השדות:
  /// - name (חובה)
  /// - quantity (אופציונלי, ברירת מחדל: 1)
  /// - unitPrice (אופציונלי, ברירת מחדל: 0.0)
  /// - barcode, unit, category, notes, image_url (אופציונליים)
  factory UnifiedListItem.fromRequestData(Map<String, dynamic> data) {
    return UnifiedListItem.product(
      name: data['name'] as String,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      barcode: data['barcode'] as String?,
      unit: data['unit'] as String? ?? 'יח\'',
      category: data['category'] as String?,
      notes: data['notes'] as String?,
      // 🔧 תומך גם ב-imageUrl וגם ב-image_url (לעקביות עם JSON)
      imageUrl: data['image_url'] as String? ?? data['imageUrl'] as String?,
    );
  }

  // ════════════════════════════════════════════
  // JSON Serialization
  // ════════════════════════════════════════════

  /// 🇮🇱 יצירה מ-JSON עם שימור ערך type מקורי
  /// 🇬🇧 Create from JSON with original type value preservation
  ///
  /// ⚠️ Round-trip safety: אם type הוא ערך לא מוכר (למשל "service"),
  /// נשמור את הערך המקורי כדי לא לאבד מידע בשמירה חוזרת.
  factory UnifiedListItem.fromJson(Map<String, dynamic> json) {
    final item = _$UnifiedListItemFromJson(json);

    // Capture original type value for round-trip safety
    if (item.type == ItemType.unknown) {
      final rawType = json['type']?.toString();
      return item.copyWith(originalTypeValue: rawType);
    }
    return item;
  }

  /// 🇮🇱 המרה ל-JSON עם שימור ערך type מקורי
  /// 🇬🇧 Convert to JSON with original type value preservation
  ///
  /// ⚠️ Round-trip safety: אם type הוא unknown ויש לנו את הערך המקורי,
  /// נשתמש בו במקום "unknown" כדי לא לאבד מידע.
  Map<String, dynamic> toJson() {
    final json = _$UnifiedListItemToJson(this);

    // Preserve original type value for round-trip safety
    if (type == ItemType.unknown && _originalTypeValue != null) {
      json['type'] = _originalTypeValue;
    }
    return json;
  }

  // ════════════════════════════════════════════
  // Display Helpers
  // ════════════════════════════════════════════

  /// 🇮🇱 שם לתצוגה (שם + כמות למוצרים)
  /// 🇬🇧 Display name (name + quantity for products)
  String get displayName {
    if (type == ItemType.product && quantity != null) {
      return '$name (x$quantity)';
    }
    return name;
  }

  // ════════════════════════════════════════════
  // CopyWith & Equality
  // ════════════════════════════════════════════

  /// 🔧 יוצר עותק חדש עם שינויים
  ///
  /// **הערה:** productData ו-taskData מועתקים (deep copy) לשמירה על immutability.
  /// אם אתה רוצה לשנות ערך ב-productData, העבר Map חדש עם הערכים הרצויים.
  UnifiedListItem copyWith({
    String? id,
    String? name,
    ItemType? type,
    String? originalTypeValue,
    bool? isChecked,
    String? category,
    String? notes,
    String? imageUrl,
    Map<String, dynamic>? productData,
    Map<String, dynamic>? taskData,
    String? checkedBy,
    String? checkedAt,
  }) {
    return UnifiedListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      originalTypeValue: originalTypeValue ?? _originalTypeValue,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      // 🔧 Deep copy כדי לשמור על immutability
      productData: productData != null
          ? Map<String, dynamic>.from(productData)
          : (this.productData != null ? Map<String, dynamic>.from(this.productData!) : null),
      taskData: taskData != null
          ? Map<String, dynamic>.from(taskData)
          : (this.taskData != null ? Map<String, dynamic>.from(this.taskData!) : null),
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  String toString() =>
      'UnifiedListItem(id: $id, name: $name, type: $type, isChecked: $isChecked)';

  /// 🔧 שוויון לפי id בלבד
  ///
  /// **הערה חשובה:** השוואה נעשית לפי `id` בלבד, לא לפי barcode או שדות אחרים.
  ///
  /// משמעות:
  /// - שני פריטים עם אותו barcode אבל id שונה נחשבים **שונים**
  /// - מאפשר להחזיק כמה פריטים מאותו מוצר ברשימה
  /// - אם צריך למזג פריטים לפי barcode, יש לעשות זאת בשכבת הלוגיקה העסקית
  ///
  /// דוגמה:
  /// ```dart
  /// final item1 = UnifiedListItem.product(id: 'a', name: 'חלב', barcode: '123');
  /// final item2 = UnifiedListItem.product(id: 'b', name: 'חלב', barcode: '123');
  /// print(item1 == item2); // false - id שונה
  /// ```
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnifiedListItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
