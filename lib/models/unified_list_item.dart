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
    bool isChecked = false,
    String? category,
    String? notes,
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
      productData: {
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (barcode != null) 'barcode': barcode,
        'unit': unit,
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
