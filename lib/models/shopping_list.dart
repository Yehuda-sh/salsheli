// 📄 File: lib/models/shopping_list.dart - UPDATED
//
// ✅ עודכן:
// 1. הוספת שדה type (super/pharmacy/other)
// 2. הוספת שדה budget (תקציב אופציונלי)
// 3. עדכון כל ה-constructors והמתודות
// 4. הוספת קבועי type
// 5. תיקון withItemRemoved להחזיר ShoppingList
//
// 🇮🇱 מודל לרשימת קניות:
// - שדות בסיסיים + type + budget + JSON מלא + גשר ל־API
// - עזרי חישוב (סיכומים/התקדמות) ומניפולציות בטוחות על פריטים

import 'package:json_annotation/json_annotation.dart';
import 'receipt.dart';
import '../api/entities/shopping_list.dart' as api;

part 'shopping_list.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingList {
  /// מזהה ייחודי לרשימה
  final String id;

  /// שם הרשימה (למשל "סופר יומי")
  final String name;

  /// מתי עודכנה הרשימה לאחרונה
  final DateTime updatedDate;

  /// סטטוס הרשימה ("active", "completed", "archived")
  @JsonKey(defaultValue: 'active')
  final String status;

  /// ✅ חדש: סוג הרשימה ("super", "pharmacy", "other")
  @JsonKey(defaultValue: 'super')
  final String type;

  /// ✅ חדש: תקציב משוער (אופציונלי)
  final double? budget;

  /// האם הרשימה משותפת עם משתמשים נוספים
  final bool isShared;

  /// מזהה המשתמש שיצר את הרשימה
  final String createdBy;

  /// מזהי משתמשים איתם הרשימה שותפה
  final List<String> sharedWith;

  /// פריטי הקבלה/רשימה
  final List<ReceiptItem> items;

  // ---- Status constants ----
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';
  static const String statusCompleted = 'completed';

  // ---- Type constants ✅ חדש ----
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
  }) : sharedWith = List<String>.unmodifiable(sharedWith),
       items = List<ReceiptItem>.unmodifiable(items);

  // ---- Factory נוח ליצירת רשימה חדשה ----
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

  // ---- Helpers (חישובים) ----

  /// מספר פריטים ברשימה
  int get itemCount => items.length;

  /// סה״כ יחידות (כמויות)
  int get totalQuantity => items.fold<int>(0, (sum, it) => sum + it.quantity);

  /// סה״כ סכום (מחיר מצטבר)
  double get totalAmount =>
      items.fold<double>(0.0, (sum, it) => sum + it.totalPrice);

  /// סטטוסים
  bool get isActive => status == statusActive;
  bool get isCompleted => status == statusCompleted;
  bool get isArchived => status == statusArchived;

  /// כמה פריטים מסומנים כנקנו
  int get checkedCount => items.where((it) => it.isChecked).length;

  /// כמה פריטים שנותרו
  int get uncheckedCount => items.length - checkedCount;

  /// התקדמות (0..1), 0 אם הרשימה ריקה
  double get progress =>
      items.isEmpty ? 0.0 : checkedCount / items.length.toDouble();

  /// ✅ חדש: בדיקה אם חרגנו מהתקציב
  bool get isOverBudget => budget != null && totalAmount > budget!;

  /// ✅ חדש: כמה כסף נותר מהתקציב
  double? get remainingBudget => budget != null ? budget! - totalAmount : null;

  // ---- copyWith ----
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

  // ---- Items manipulation ----

  ShoppingList withItemAdded(ReceiptItem item) {
    return copyWith(items: [...items, item], updatedDate: DateTime.now());
  }

  ShoppingList withItemRemoved(int index) {
    if (index < 0 || index >= items.length) return this;
    final updated = [...items]..removeAt(index);
    return copyWith(items: updated, updatedDate: DateTime.now());
  }

  ShoppingList updateItemAt(
    int index,
    ReceiptItem Function(ReceiptItem) update,
  ) {
    if (index < 0 || index >= items.length) return this;
    final updated = [...items];
    updated[index] = update(updated[index]);
    return copyWith(items: updated, updatedDate: DateTime.now());
  }

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

  // ---- JSON ----
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return _$ShoppingListFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  // ---- API bridging ----
  factory ShoppingList.fromApi(
    api.ApiShoppingList src, {
    List<ReceiptItem>? items,
  }) {
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

  api.ApiShoppingList toApi(String householdId) {
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

  // ✅ המרת ReceiptItem ל-ApiShoppingListItem
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

  // ---- Utils ----
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
