// 📄 File: lib/models/shopping_list.dart
//
// 🇮🇱 מודל רשימת קניות:
//     - מייצג רשימת קניות עם פריטים, תקציב, וסטטוס.
//     - תומך בשיתוף בין משתמשים במשק בית.
//     - כולל סוגי רשימות: סופרמרקט, בית מרקחת, אחר.
//     - מחשב אוטומטית התקדמות, סכומים, וחריגה מתקציב.
//     - נתמך ע"י JSON לצורך סנכרון עם Firebase Firestore.
//
// 🔥 Firebase Integration:
//     - household_id מנוהל ע"י Repository (לא חלק מהמודל)
//     - כל רשימה שייכת למשק בית אחד
//     - Repository מוסיף את household_id בזמן שמירה
//     - Repository מסנן לפי household_id בזמן טעינה
//

//
// 🇬🇧 Shopping list model:
//     - Represents a shopping list with items, budget, and status.
//     - Supports sharing between household members.
//     - Includes list types: supermarket, pharmacy, other.
//     - Auto-calculates progress, totals, and budget overruns.
//     - Supports JSON for server sync and local storage.
//

//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'receipt.dart';
import 'timestamp_converter.dart';

part 'shopping_list.g.dart';

/// 🇮🇱 מודל רשימת קניות
/// 🇬🇧 Shopping list model
@JsonSerializable(explicitToJson: true)
class ShoppingList {
  /// 🇮🇱 מזהה ייחודי לרשימה
  /// 🇬🇧 Unique list identifier
  final String id;

  /// 🇮🇱 שם הרשימה (למשל "סופר יומי")
  /// 🇬🇧 List name (e.g., "Daily Supermarket")
  final String name;

  /// 🇮🇱 מתי עודכנה הרשימה לאחרונה
  /// 🇬🇧 Last update date
  @TimestampConverter()
  @JsonKey(name: 'updated_date')
  final DateTime updatedDate;

  /// 🇮🇱 מתי נוצרה הרשימה
  /// 🇬🇧 Creation date
  @TimestampConverter()
  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  /// 🇮🇱 סטטוס הרשימה: "active" | "completed" | "archived"
  /// 🇬🇧 List status: "active" | "completed" | "archived"
  @JsonKey(defaultValue: 'active')
  final String status;

  /// 🇮🇱 סוג הרשימה: "super" | "pharmacy" | "other"
  /// 🇬🇧 List type: "super" | "pharmacy" | "other"
  @JsonKey(defaultValue: 'super')
  final String type;

  /// 🇮🇱 תקציב משוער (אופציונלי, ₪)
  /// 🇬🇧 Estimated budget (optional, ₪)
  final double? budget;

  /// 🇮🇱 האם הרשימה משותפת עם משתמשים נוספים
  /// 🇬🇧 Is the list shared with other users
  @JsonKey(name: 'is_shared', defaultValue: false)
  final bool isShared;

  /// 🇮🇱 מזהה המשתמש שיצר את הרשימה
  /// 🇬🇧 User ID who created the list
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 🇮🇱 מזהי משתמשים איתם הרשימה שותפה
  /// 🇬🇧 User IDs with whom the list is shared
  @JsonKey(name: 'shared_with', defaultValue: [])
  final List<String> sharedWith;

  /// 🇮🇱 תאריך אירוע מתוכנן (אופציונלי) - למשל יום הולדת, אירוח
  /// 🇬🇧 Planned event date (optional) - e.g., birthday, hosting
  @TimestampConverter()
  @JsonKey(name: 'event_date')
  final DateTime? eventDate;

  /// 🇮🇱 פריטי הקניות ברשימה
  /// 🇬🇧 Shopping items in the list
  final List<ReceiptItem> items;

  // ---- Status constants ----
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';
  static const String statusCompleted = 'completed';

  // ---- Type constants ----
  static const String typeSuper = 'super';
  static const String typePharmacy = 'pharmacy';
  static const String typeOther = 'other';

  /// Constructor
  ShoppingList({
    required this.id,
    required this.name,
    required this.updatedDate,
    DateTime? createdDate,
    this.status = statusActive,
    this.type = typeSuper,
    this.budget,
    this.eventDate,
    this.isShared = false,
    required this.createdBy,
    List<String> sharedWith = const [],
    List<ReceiptItem> items = const [],
  })  : createdDate = createdDate ?? updatedDate,
        sharedWith = List<String>.unmodifiable(sharedWith),
        items = List<ReceiptItem>.unmodifiable(items);

  // ---- Factory Constructors ----

  /// 🇮🇱 יצירת רשימה חדשה בקלות
  /// 🇬🇧 Easily create a new list
  factory ShoppingList.newList({
    required String id,
    required String name,
    required String createdBy,
    String type = typeSuper,
    double? budget,
    DateTime? eventDate,
    bool isShared = false,
    List<String> sharedWith = const [],
    List<ReceiptItem> items = const [],
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ShoppingList(
      id: id,
      name: name,
      createdBy: createdBy,
      type: type,
      budget: budget,
      eventDate: eventDate,
      isShared: isShared,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<ReceiptItem>.unmodifiable(items),
      updatedDate: timestamp,
      createdDate: timestamp,
      status: statusActive,
    );
  }

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? updatedDate,
    DateTime? createdDate,
    String? status,
    String? type,
    double? budget,
    DateTime? eventDate,
    bool? isShared,
    String? createdBy,
    List<String>? sharedWith,
    List<ReceiptItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedDate: updatedDate ?? this.updatedDate,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      type: type ?? this.type,
      budget: budget ?? this.budget,
      eventDate: eventDate ?? this.eventDate,
      isShared: isShared ?? this.isShared,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? this.sharedWith,
      items: items ?? this.items,
    );
  }

  // ---- Items Manipulation ----

  /// 🇮🇱 הוספת פריט לרשימה
  /// 🇬🇧 Add item to list
  ShoppingList withItemAdded(ReceiptItem item) {
    return copyWith(items: [...items, item], updatedDate: DateTime.now());
  }

  /// 🇮🇱 הסרת פריט לפי אינדקס
  /// 🇬🇧 Remove item by index
  ShoppingList withItemRemoved(int index) {
    if (index < 0 || index >= items.length) return this;
    final updated = [...items]..removeAt(index);
    return copyWith(items: updated, updatedDate: DateTime.now());
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 ShoppingList.fromJson:');
    debugPrint('   id: ${json['id']}');
    debugPrint('   name: ${json['name']}');
    debugPrint('   type: ${json['type']}');
    debugPrint('   status: ${json['status']}');
    debugPrint('   items: ${(json['items'] as List?)?.length ?? 0}');
    return _$ShoppingListFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    debugPrint('📤 ShoppingList.toJson:');
    debugPrint('   id: $id');
    debugPrint('   name: $name');
    debugPrint('   type: $type');
    debugPrint('   status: $status');
    debugPrint('   items: ${items.length}');
    return _$ShoppingListToJson(this);
  }

  @override
  String toString() =>
      'ShoppingList(id: $id, name: $name, type: $type, status: $status, items: ${items.length}, budget: $budget)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
