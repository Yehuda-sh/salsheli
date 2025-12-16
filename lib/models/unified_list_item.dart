// 📄 File: lib/models/unified_list_item.dart
//
// 🇮🇱 פריט מאוחד ברשימת קניות (Hybrid Approach):
//     - תומך גם במוצרים (product) וגם במשימות (task)
//     - שדות משותפים: id, name, type, isChecked, category, notes
//     - שדות ייחודיים למוצרים: productData (quantity, unitPrice, barcode, unit)
//     - שדות ייחודיים למשימות: taskData (dueDate, assignedTo, priority)
//     - Helpers: quantity, totalPrice, dueDate, isUrgent
//     - Migration: fromReceiptItem() להמרה מהמבנה הישן
//
// 🇬🇧 Unified list item (Hybrid Approach):
//     - Supports both products and tasks
//     - Shared fields: id, name, type, isChecked, category, notes
//     - Product-specific: productData (quantity, unitPrice, barcode, unit)
//     - Task-specific: taskData (dueDate, assignedTo, priority)
//     - Helpers for easy access
//     - Migration support from ReceiptItem
//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums/item_type.dart';
import 'receipt.dart';

part 'unified_list_item.g.dart';

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
  final ItemType type;

  /// האם סומן (✅)
  @JsonKey(defaultValue: false)
  final bool isChecked;

  /// קטגוריה (אופציונלי)
  final String? category;

  /// הערות (אופציונלי)
  final String? notes;

  /// 🖼️ קישור לתמונת המוצר (אופציונלי)
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 🆕 שדות ייחודיים למוצרים (Map)
  /// quantity, unitPrice, barcode, unit
  final Map<String, dynamic>? productData;

  /// 🆕 שדות ייחודיים למשימות (Map)
  /// dueDate, assignedTo, priority
  final Map<String, dynamic>? taskData;

  /// 🆕 מזהה המשתמש שסימן את הפריט
  @JsonKey(name: 'checked_by')
  final String? checkedBy;

  /// 🆕 מתי סומן הפריט
  @JsonKey(name: 'checked_at')
  final String? checkedAt;

  const UnifiedListItem({
    required this.id,
    required this.name,
    required this.type,
    this.isChecked = false,
    this.category,
    this.notes,
    this.imageUrl,
    this.productData,
    this.taskData,
    this.checkedBy,
    this.checkedAt,
  });

  // ════════════════════════════════════════════
  // Product Helpers (גישה קלה לשדות מוצר)
  // ════════════════════════════════════════════

  /// 🇮🇱 כמות (רק למוצרים)
  /// 🇬🇧 Quantity (products only)
  int? get quantity => productData?['quantity'] as int?;

  /// 🇮🇱 מחיר ליחידה (רק למוצרים)
  /// 🇬🇧 Unit price (products only)
  double? get unitPrice => productData?['unitPrice'] as double?;

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

  /// 🇮🇱 תאריך יעד (רק למשימות)
  /// 🇬🇧 Due date (tasks only)
  DateTime? get dueDate {
    final dateStr = taskData?['dueDate'] as String?;
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  /// 🇮🇱 למי הוקצה (רק למשימות)
  /// 🇬🇧 Assigned to (tasks only)
  String? get assignedTo => taskData?['assignedTo'] as String?;

  /// 🇮🇱 עדיפות (low/medium/high)
  /// 🇬🇧 Priority (low/medium/high)
  String get priority => taskData?['priority'] as String? ?? 'medium';

  /// 🇮🇱 האם משימה דחופה (פחות מ-3 ימים)
  /// 🇬🇧 Is task urgent (less than 3 days)
  bool get isUrgent {
    if (type != ItemType.task) return false;
    final due = dueDate;
    if (due == null) return false;
    return due.difference(DateTime.now()).inDays <= 3;
  }

  // ════════════════════════════════════════════
  // "Who Brings" Helpers (גישה קלה לשדות מי מביא)
  // ════════════════════════════════════════════

  /// 🇮🇱 כמות אנשים נדרשים להביא (ברשימות "מי מביא")
  /// 🇬🇧 Number of people needed to bring (for "Who Brings" lists)
  int get neededCount => taskData?['neededCount'] as int? ?? 1;

  /// 🇮🇱 רשימת מתנדבים שאמרו "אני מביא"
  /// 🇬🇧 List of volunteers who said "I'll bring"
  List<Map<String, dynamic>> get volunteers {
    final list = taskData?['volunteers'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

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
  List<Map<String, dynamic>> get votesFor {
    final list = taskData?['votesFor'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// 🇮🇱 רשימת מצביעים נגד
  /// 🇬🇧 List of voters against
  List<Map<String, dynamic>> get votesAgainst {
    final list = taskData?['votesAgainst'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// 🇮🇱 רשימת נמנעים
  /// 🇬🇧 List of abstained voters
  List<Map<String, dynamic>> get votesAbstain {
    final list = taskData?['votesAbstain'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

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
  bool get isAnonymousVoting => taskData?['isAnonymous'] as bool? ?? false;

  /// 🇮🇱 תאריך סיום הצבעה
  /// 🇬🇧 Voting end date
  DateTime? get votingEndDate {
    final dateStr = taskData?['votingEndDate'] as String?;
    return dateStr != null ? DateTime.parse(dateStr) : null;
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
  /// - barcode, unit, category, notes (אופציונליים)
  factory UnifiedListItem.fromRequestData(Map<String, dynamic> data) {
    return UnifiedListItem.product(
      name: data['name'] as String,
      quantity: data['quantity'] as int? ?? 1,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      barcode: data['barcode'] as String?,
      unit: data['unit'] as String? ?? 'יח\'',
      category: data['category'] as String?,
      notes: data['notes'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  // ════════════════════════════════════════════
  // JSON Serialization
  // ════════════════════════════════════════════

  factory UnifiedListItem.fromJson(Map<String, dynamic> json) {
    return _$UnifiedListItemFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$UnifiedListItemToJson(this);
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

  UnifiedListItem copyWith({
    String? id,
    String? name,
    ItemType? type,
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
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      productData: productData ?? this.productData,
      taskData: taskData ?? this.taskData,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  String toString() =>
      'UnifiedListItem(id: $id, name: $name, type: $type, isChecked: $isChecked)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnifiedListItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
