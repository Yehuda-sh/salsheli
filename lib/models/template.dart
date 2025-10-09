// 📄 File: lib/models/template.dart
//
// 🎯 Purpose: Template model - תבנית רשימה עם פריטים ברירת מחדל
//
// 📦 Features:
// - תבניות מערכת (system) וקבועות (household)
// - פריטים מוצעים ברירת מחדל
// - פורמט ברירת מחדל (shared/assigned/personal)
// - תמיכה בסוגי רשימות (21 types)
// - JSON serialization לFirestore
// - Timestamp conversion אוטומטי
//
// 🔥 Firebase Integration:
// - household_id: null = תבנית מערכת (זמינה לכולם)
// - household_id: string = תבנית פרטית של משק בית
// - is_system: true = לא ניתן למחיקה
//
// 📝 Usage:
// ```dart
// // תבנית מערכת
// final template = Template.newTemplate(
//   id: 'template_super',
//   type: ListType.super_,
//   name: 'סופרמרקט שבועי',
//   description: 'קניות שבועיות למשפחה',
//   icon: '🛒',
//   createdBy: 'system',
//   isSystem: true,
//   defaultItems: [
//     TemplateItem(name: 'חלב', category: 'מוצרי חלב', quantity: 2),
//     TemplateItem(name: 'לחם', category: 'מאפים', quantity: 1),
//   ],
// );
//
// // תבנית משתמש
// final userTemplate = Template.newTemplate(
//   id: 'template_custom_123',
//   type: ListType.other,
//   name: 'הרשימה שלי',
//   description: 'רשימה מותאמת אישית',
//   icon: '📝',
//   createdBy: userId,
//   householdId: householdId,
//   isSystem: false,
// );
// ```
//
// Version: 1.0
// Last Updated: 10/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'timestamp_converter.dart';

part 'template.g.dart';

/// תבנית רשימה - מכילה פריטים ברירת מחדל והגדרות
@JsonSerializable(explicitToJson: true)
class Template {
  /// מזהה ייחודי (בדרך כלל: template_{type} או template_custom_{uuid})
  final String id;

  /// סוג הרשימה (מ-ListType: 'super', 'pharmacy', 'birthday', etc.)
  final String type;

  /// שם התבנית
  final String name;

  /// תיאור קצר
  final String description;

  /// אייקון (emoji)
  final String icon;

  /// פורמט ברירת מחדל
  /// 
  /// Values: 'shared' | 'assigned' | 'personal'
  @JsonKey(name: 'default_format', defaultValue: 'shared')
  final String defaultFormat;

  /// פריטים בסיסיים מוצעים
  /// 
  /// רשימת פריטים שיווצרו אוטומטית בעת יצירת רשימה מהתבנית
  @JsonKey(name: 'default_items', defaultValue: [])
  final List<TemplateItem> defaultItems;

  /// האם תבנית מערכת (לא ניתנת למחיקה)
  /// 
  /// true = תבנית מערכת קבועה
  /// false = תבנית של משתמש (ניתנת למחיקה/עריכה)
  @JsonKey(name: 'is_system', defaultValue: false)
  final bool isSystem;

  /// מי יצר את התבנית
  /// 
  /// Values: 'system' | user_id
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// מזהה משק בית (null = זמין לכולם)
  /// 
  /// null = תבנית מערכת (זמינה לכל המשתמשים)
  /// string = תבנית פרטית של משק בית ספציפי
  @JsonKey(name: 'household_id')
  final String? householdId;

  /// תאריך יצירה
  @TimestampConverter()
  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  /// תאריך עדכון
  @TimestampConverter()
  @JsonKey(name: 'updated_date')
  final DateTime updatedDate;

  /// סדר תצוגה (למיון)
  /// 
  /// משמש למיון התבניות בממשק המשתמש
  /// ערך נמוך = יופיע קודם
  @JsonKey(name: 'sort_order', defaultValue: 0)
  final int sortOrder;

  // ========================================
  // Format Constants
  // ========================================

  /// רשימה משותפת - כולם יכולים להוסיף ולערוך
  static const String formatShared = 'shared';

  /// חלוקת תפקידים - כל פריט מוקצה למשתמש ספציפי
  static const String formatAssigned = 'assigned';

  /// רשימה אישית - רק היוצר רואה ומערוך
  static const String formatPersonal = 'personal';

  /// רשימת כל הפורמטים הזמינים
  static const List<String> allFormats = [
    formatShared,
    formatAssigned,
    formatPersonal,
  ];

  // ========================================
  // Constructor
  // ========================================

  Template({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    this.defaultFormat = formatShared,
    this.defaultItems = const [],
    this.isSystem = false,
    required this.createdBy,
    this.householdId,
    required this.createdDate,
    required this.updatedDate,
    this.sortOrder = 0,
  });

  // ========================================
  // Factory Constructors
  // ========================================

  /// יצירת תבנית חדשה בקלות
  /// 
  /// Example:
  /// ```dart
  /// final template = Template.newTemplate(
  ///   id: 'template_super',
  ///   type: ListType.super_,
  ///   name: 'סופרמרקט שבועי',
  ///   description: 'קניות שבועיות',
  ///   icon: '🛒',
  ///   createdBy: 'system',
  ///   isSystem: true,
  /// );
  /// ```
  factory Template.newTemplate({
    required String id,
    required String type,
    required String name,
    required String description,
    required String icon,
    required String createdBy,
    String defaultFormat = formatShared,
    List<TemplateItem> defaultItems = const [],
    String? householdId,
    bool isSystem = false,
    int sortOrder = 0,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return Template(
      id: id,
      type: type,
      name: name,
      description: description,
      icon: icon,
      createdBy: createdBy,
      defaultFormat: defaultFormat,
      defaultItems: List<TemplateItem>.unmodifiable(defaultItems),
      householdId: householdId,
      isSystem: isSystem,
      sortOrder: sortOrder,
      createdDate: timestamp,
      updatedDate: timestamp,
    );
  }

  // ========================================
  // Copy & Update
  // ========================================

  /// יצירת עותק עם שינויים
  /// 
  /// Example:
  /// ```dart
  /// final updated = template.copyWith(
  ///   name: 'שם חדש',
  ///   description: 'תיאור חדש',
  /// );
  /// ```
  Template copyWith({
    String? id,
    String? type,
    String? name,
    String? description,
    String? icon,
    String? defaultFormat,
    List<TemplateItem>? defaultItems,
    bool? isSystem,
    String? createdBy,
    String? householdId,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? sortOrder,
  }) {
    return Template(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      defaultItems: defaultItems ?? this.defaultItems,
      isSystem: isSystem ?? this.isSystem,
      createdBy: createdBy ?? this.createdBy,
      householdId: householdId ?? this.householdId,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // ========================================
  // Items Manipulation
  // ========================================

  /// הוספת פריט לתבנית
  /// 
  /// Example:
  /// ```dart
  /// final updated = template.withItemAdded(
  ///   TemplateItem(name: 'סוכר', category: 'יבשים', quantity: 1),
  /// );
  /// ```
  Template withItemAdded(TemplateItem item) {
    return copyWith(
      defaultItems: [...defaultItems, item],
      updatedDate: DateTime.now(),
    );
  }

  /// הסרת פריט לפי אינדקס
  /// 
  /// Example:
  /// ```dart
  /// final updated = template.withItemRemoved(0);
  /// ```
  Template withItemRemoved(int index) {
    if (index < 0 || index >= defaultItems.length) return this;
    final updated = [...defaultItems]..removeAt(index);
    return copyWith(
      defaultItems: updated,
      updatedDate: DateTime.now(),
    );
  }

  /// עדכון פריט לפי אינדקס
  /// 
  /// Example:
  /// ```dart
  /// final updated = template.withItemUpdated(
  ///   0,
  ///   TemplateItem(name: 'חלב 3%', category: 'מוצרי חלב', quantity: 2),
  /// );
  /// ```
  Template withItemUpdated(int index, TemplateItem newItem) {
    if (index < 0 || index >= defaultItems.length) return this;
    final updated = [...defaultItems];
    updated[index] = newItem;
    return copyWith(
      defaultItems: updated,
      updatedDate: DateTime.now(),
    );
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// בדיקה אם התבנית זמינה למשק בית מסוים
  /// 
  /// Example:
  /// ```dart
  /// if (template.isAvailableFor('house_123')) {
  ///   // התבנית זמינה
  /// }
  /// ```
  bool isAvailableFor(String householdId) {
    // תבנית מערכת זמינה לכולם
    if (this.householdId == null) return true;
    // תבנית של משק בית - רק למשק הבית הספציפי
    return this.householdId == householdId;
  }

  /// בדיקה אם התבנית ניתנת למחיקה
  /// 
  /// Example:
  /// ```dart
  /// if (template.isDeletable) {
  ///   // ניתן למחוק
  /// }
  /// ```
  bool get isDeletable => !isSystem;

  /// בדיקה אם התבנית ניתנת לעריכה
  /// 
  /// Example:
  /// ```dart
  /// if (template.isEditable) {
  ///   // ניתן לערוך
  /// }
  /// ```
  bool get isEditable => !isSystem;

  /// בדיקה אם הפורמט תקין
  /// 
  /// Example:
  /// ```dart
  /// if (Template.isValidFormat('shared')) { ... }  // true
  /// if (Template.isValidFormat('invalid')) { ... }  // false
  /// ```
  static bool isValidFormat(String format) => allFormats.contains(format);

  // ========================================
  // JSON Serialization
  // ========================================

  /// יצירה מ-JSON
  factory Template.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 Template.fromJson:');
    debugPrint('   id: ${json['id']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   type: ${json['type']}');
    debugPrint('   items: ${(json['default_items'] as List?)?.length ?? 0}');
    return _$TemplateFromJson(json);
  }

  /// המרה ל-JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 Template.toJson:');
    debugPrint('   id: $id');
    debugPrint('   name: $name');
    debugPrint('   type: $type');
    debugPrint('   items: ${defaultItems.length}');
    return _$TemplateToJson(this);
  }

  @override
  String toString() => 'Template(id: $id, name: $name, type: $type, '
      'items: ${defaultItems.length}, isSystem: $isSystem)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Template && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ========================================
// TemplateItem - פריט בתוך תבנית
// ========================================

/// פריט בתוך תבנית - מייצג מוצר מוצע
@JsonSerializable()
class TemplateItem {
  /// שם הפריט
  final String name;

  /// קטגוריה (אופציונלי)
  final String? category;

  /// כמות
  @JsonKey(defaultValue: 1)
  final int quantity;

  /// יחידת מידה
  @JsonKey(defaultValue: 'יח׳')
  final String unit;

  /// הערה (אופציונלי)
  final String? note;

  const TemplateItem({
    required this.name,
    this.category,
    this.quantity = 1,
    this.unit = 'יח׳',
    this.note,
  });

  /// יצירת עותק עם שינויים
  TemplateItem copyWith({
    String? name,
    String? category,
    int? quantity,
    String? unit,
    String? note,
  }) {
    return TemplateItem(
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }

  factory TemplateItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateItemFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateItemToJson(this);

  @override
  String toString() => 'TemplateItem($name x$quantity $unit${category != null ? ' [$category]' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          category == other.category &&
          quantity == other.quantity &&
          unit == other.unit;

  @override
  int get hashCode =>
      name.hashCode ^ category.hashCode ^ quantity.hashCode ^ unit.hashCode;
}
