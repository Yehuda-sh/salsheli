// 📄 File: lib/models/shopping_list.dart
//
// 🇮🇱 מודל רשימת קניות:
//     - מייצג רשימת קניות עם פריטים, תקציב, וסטטוס.
//     - תומך בשיתוף בין משתמשים במשק בית.
//     - כולל סוגי רשימות: סופרמרקט, בית מרקחת, אחר.
//     - מחשב אוטומטית התקדמות, סכומים, וחריגה מתקציב.
//     - נתמך ע"י JSON לצורך סנכרון עם שרת ושמירה מקומית.
//
// 💡 רעיונות עתידיים:
//     - סנכרון בזמן אמת בין משתמשים (collaborative shopping).
//     - התראות כשמשתמש אחר מוסיף/מסמן פריטים.
//     - המלצות חכמות: "המוצרים האלה בדרך כלל נקנים ביחד".
//     - אופטימיזציה של מסלול בחנות (shelf layout).
//     - היסטוריה: "קנית את זה ב-15% פחות בשבוע שעבר".
//     - שיתוף רשימות בין משקי בית (משפחה מורחבת).
//
// 🇬🇧 Shopping list model:
//     - Represents a shopping list with items, budget, and status.
//     - Supports sharing between household members.
//     - Includes list types: supermarket, pharmacy, other.
//     - Auto-calculates progress, totals, and budget overruns.
//     - Supports JSON for server sync and local storage.
//
// 💡 Future ideas:
//     - Real-time sync between users (collaborative shopping).
//     - Notifications when another user adds/checks items.
//     - Smart suggestions: "These products are usually bought together".
//     - In-store route optimization (shelf layout).
//     - History: "You bought this 15% cheaper last week".
//     - Share lists between households (extended family).
//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'receipt.dart';
import '../api/entities/shopping_list.dart' as api;

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
  final DateTime updatedDate;

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
  final bool isShared;

  /// 🇮🇱 מזהה המשתמש שיצר את הרשימה
  /// 🇬🇧 User ID who created the list
  final String createdBy;

  /// 🇮🇱 מזהי משתמשים איתם הרשימה שותפה
  /// 🇬🇧 User IDs with whom the list is shared
  final List<String> sharedWith;

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
    this.status = statusActive,
    this.type = typeSuper,
    this.budget,
    this.isShared = false,
    required this.createdBy,
    List<String> sharedWith = const [],
    List<ReceiptItem> items = const [],
  })  : sharedWith = List<String>.unmodifiable(sharedWith),
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
    bool isShared = false,
    List<String> sharedWith = const [],
    List<ReceiptItem> items = const [],
    DateTime? now,
  }) {
    return ShoppingList(
      id: id,
      name: name,
      createdBy: createdBy,
      type: type,
      budget: budget,
      isShared: isShared,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<ReceiptItem>.unmodifiable(items),
      updatedDate: now ?? DateTime.now(),
      status: statusActive,
    );
  }

  // ---- Computed Properties ----

  /// 🇮🇱 מספר פריטים ברשימה
  /// 🇬🇧 Number of items in list
  int get itemCount => items.length;

  /// 🇮🇱 סה״כ יחידות (כמויות)
  /// 🇬🇧 Total quantity (units)
  int get totalQuantity => items.fold<int>(0, (sum, it) => sum + it.quantity);

  /// 🇮🇱 סה״כ סכום (מחיר מצטבר, ₪)
  /// 🇬🇧 Total amount (cumulative price, ₪)
  double get totalAmount =>
      items.fold<double>(0.0, (sum, it) => sum + it.totalPrice);

  /// 🇮🇱 האם הרשימה פעילה
  /// 🇬🇧 Is the list active
  bool get isActive => status == statusActive;

  /// 🇮🇱 האם הרשימה הושלמה
  /// 🇬🇧 Is the list completed
  bool get isCompleted => status == statusCompleted;

  /// 🇮🇱 האם הרשימה בארכיון
  /// 🇬🇧 Is the list archived
  bool get isArchived => status == statusArchived;

  /// 🇮🇱 כמה פריטים מסומנים כנקנו
  /// 🇬🇧 How many items are checked as purchased
  int get checkedCount => items.where((it) => it.isChecked).length;

  /// 🇮🇱 כמה פריטים שנותרו
  /// 🇬🇧 How many items remain
  int get uncheckedCount => items.length - checkedCount;

  /// 🇮🇱 התקדמות (0..1), 0 אם הרשימה ריקה
  /// 🇬🇧 Progress (0..1), 0 if list is empty
  double get progress =>
      items.isEmpty ? 0.0 : checkedCount / items.length.toDouble();

  /// 🇮🇱 בדיקה אם חרגנו מהתקציב
  /// 🇬🇧 Check if over budget
  bool get isOverBudget => budget != null && totalAmount > budget!;

  /// 🇮🇱 כמה כסף נותר מהתקציב (₪)
  /// 🇬🇧 Remaining budget amount (₪)
  double? get remainingBudget => budget != null ? budget! - totalAmount : null;

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? updatedDate,
    String? status,
    String? type,
    double? budget,
    bool? isShared,
    String? createdBy,
    List<String>? sharedWith,
    List<ReceiptItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedDate: updatedDate ?? this.updatedDate,
      status: status ?? this.status,
      type: type ?? this.type,
      budget: budget ?? this.budget,
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

  /// 🇮🇱 עדכון פריט לפי אינדקס
  /// 🇬🇧 Update item by index
  ShoppingList updateItemAt(
    int index,
    ReceiptItem Function(ReceiptItem) update,
  ) {
    if (index < 0 || index >= items.length) return this;
    final updated = [...items];
    updated[index] = update(updated[index]);
    return copyWith(items: updated, updatedDate: DateTime.now());
  }

  /// 🇮🇱 הוספה או עדכון של פריט (לפי שם)
  /// 🇬🇧 Add or update item (by name)
  ShoppingList addOrUpdate({
    required String name,
    required int quantity,
    double? unitPrice,
  }) {
    final idx = items.indexWhere((it) => it.name == name);
    if (idx == -1) {
      return withItemAdded(
        ReceiptItem.manual(
          name: name,
          quantity: quantity,
          unitPrice: unitPrice ?? 0,
        ),
      );
    }
    return updateItemAt(idx, (it) {
      final q = it.quantity + quantity;
      return it.copyWith(quantity: q, unitPrice: unitPrice ?? it.unitPrice);
    });
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

  // ---- API Bridging ----

  /// 🇮🇱 יצירה מתשובת API
  /// 🇬🇧 Create from API response
  factory ShoppingList.fromApi(
    api.ApiShoppingList src, {
    List<ReceiptItem>? items,
  }) {
    debugPrint('🔄 ShoppingList.fromApi: ${src.id} - ${src.name}');
    return ShoppingList(
      id: src.id,
      name: src.name,
      updatedDate: _parseApiDate(src.updatedDate) ?? DateTime.now(),
      status: src.status ?? statusActive,
      type: src.type ?? typeSuper,
      budget: src.budget,
      isShared: src.isShared ?? false,
      createdBy: src.createdBy ?? '',
      sharedWith: List<String>.unmodifiable(src.sharedWith ?? []),
      items: List<ReceiptItem>.unmodifiable(items ?? []),
    );
  }

  /// 🇮🇱 המרה לפורמט API
  /// 🇬🇧 Convert to API format
  api.ApiShoppingList toApi(String householdId) {
    debugPrint('🔄 ShoppingList.toApi: $id - $name (household: $householdId)');
    return api.ApiShoppingList(
      id: id,
      name: name,
      householdId: householdId,
      createdDate: null, // API יגדיר אוטומטית
      updatedDate: updatedDate.toIso8601String(),
      status: status,
      type: type,
      budget: budget,
      isShared: isShared,
      createdBy: createdBy,
      sharedWith: sharedWith.toList(),
      items: items.map((item) => _receiptItemToApi(item)).toList(),
    );
  }

  /// 🇮🇱 המרת ReceiptItem ל-ApiShoppingListItem
  /// 🇬🇧 Convert ReceiptItem to ApiShoppingListItem
  static api.ApiShoppingListItem _receiptItemToApi(ReceiptItem item) {
    return api.ApiShoppingListItem(
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      isChecked: item.isChecked,
      barcode: item.barcode,
      category: item.category,
      unit: item.unit,
    );
  }

  // ---- Utilities ----

  /// 🇮🇱 ניתוח תאריך מ-API (ISO 8601)
  /// 🇬🇧 Parse date from API (ISO 8601)
  static DateTime? _parseApiDate(String? iso) =>
      (iso == null || iso.isEmpty) ? null : DateTime.tryParse(iso);

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
