// 📄 File: lib/models/receipt.dart
//
// 🇮🇱 מודלים לייצוג קבלה (Receipt) ופריטים בקבלה (ReceiptItem):
//     - המרה מלאה ל־JSON כולל Converters (תאריכים, double).
//     - כולל חישובי סה"כ, בדיקות התאמה, ולוגיקת עזר.
//     - מתאים לניהול רשימות קניות, ניתוח הוצאות, סנכרון עם API.
//
// 🇬🇧 Models for Receipt and ReceiptItem:
//     - Full JSON serialization with converters (dates, doubles).
//     - Includes totals, validations, and helper logic.
//     - Useful for shopping lists, expense analysis, and API sync.
//
// 🔗 Related:
//     - timestamp_converter.dart - Converters מרכזיים
//     - receipts_repository.dart - אחסון Firestore
//
// Version: 1.1 - Use centralized converters, add immutability
// Last Updated: 13/01/2026

import 'package:flutter/foundation.dart' show immutable;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'timestamp_converter.dart';

part 'receipt.g.dart';

/// ─────────────────────────────────────────────
/// Receipt (קבלה שלמה)
/// ─────────────────────────────────────────────

@immutable
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Receipt {
  /// מזהה ייחודי של הקבלה
  @JsonKey(defaultValue: '')
  final String id;

  /// שם החנות
  @JsonKey(defaultValue: 'חנות ללא שם')
  final String storeName;

  /// תאריך הקנייה
  /// 🔧 תומך ב-Timestamp (Firestore) + String (ISO) + DateTime
  @FlexibleDateTimeConverter()
  final DateTime date;

  /// תאריך יצירת הרשומה (לא תמיד קיים)
  /// 🔧 תומך ב-Timestamp (Firestore) + String (ISO) + DateTime
  @NullableFlexibleDateTimeConverter()
  final DateTime? createdDate;

  /// סכום כולל לפי הקבלה
  @FlexDoubleConverter()
  final double totalAmount;

  /// פריטים בקבלה
  /// 🔒 Unmodifiable - נוצר דרך List.unmodifiable ב-factory
  final List<ReceiptItem> items;

  /// קישור מקורי לקבלה (לזיהוי כפילויות)
  /// 📌 nullable - אם אין URL, יהיה null (לא '')
  final String? originalUrl;

  /// קישור לקובץ ב-Firebase Storage
  /// 📌 nullable - אם אין קובץ, יהיה null (לא '')
  final String? fileUrl;

  /// 🆕 קישור לרשימת קניות (קבלה וירטואלית)
  /// 🇬🇧 Link to shopping list (virtual receipt)
  @JsonKey(name: 'linked_shopping_list_id')
  final String? linkedShoppingListId;

  /// 🆕 האם קבלה וירטואלית (נוצרה אוטומטית מסיום קנייה)
  /// 🇬🇧 Is this a virtual receipt (created automatically from shopping)
  @JsonKey(name: 'is_virtual', defaultValue: false)
  final bool isVirtual;

  /// 🆕 מי יצר את הקבלה (ה-Starter שסיים קנייה)
  /// 🇬🇧 Who created the receipt (the Starter who finished shopping)
  @JsonKey(name: 'created_by')
  final String? createdBy;

  /// 🔒 מזהה משק הבית (אבטחה - חובה!)
  /// 🇬🇧 Household ID (security - required!)
  @JsonKey(name: 'household_id')
  final String householdId;

  /// 🔒 Private constructor - משתמש ב-factory Receipt() לאכיפת immutability
  const Receipt._({
    required this.id,
    required this.storeName,
    required this.date,
    this.createdDate,
    required this.totalAmount,
    required this.items,
    this.originalUrl,
    this.fileUrl,
    this.linkedShoppingListId,
    this.isVirtual = false,
    this.createdBy,
    required this.householdId,
  });

  /// 🔧 Factory constructor - עוטף items ב-List.unmodifiable
  factory Receipt({
    required String id,
    required String storeName,
    required DateTime date,
    DateTime? createdDate,
    required double totalAmount,
    required List<ReceiptItem> items,
    String? originalUrl,
    String? fileUrl,
    String? linkedShoppingListId,
    bool isVirtual = false,
    String? createdBy,
    required String householdId,
  }) {
    return Receipt._(
      id: id,
      storeName: storeName,
      date: date,
      createdDate: createdDate,
      totalAmount: totalAmount,
      items: List.unmodifiable(items),
      originalUrl: originalUrl,
      fileUrl: fileUrl,
      linkedShoppingListId: linkedShoppingListId,
      isVirtual: isVirtual,
      createdBy: createdBy,
      householdId: householdId,
    );
  }

  /// 🇮🇱 האם קבלה וירטואלית (ללא סריקה)
  /// 🇬🇧 Is this a virtual receipt (no scan)
  bool get isVirtualReceipt => isVirtual && fileUrl == null;

  /// 🇮🇱 האם קבלה וירטואלית עם סריקה מחוברת
  /// 🇬🇧 Is this a virtual receipt with connected scan
  bool get isRealConnected => isVirtual && fileUrl != null;

  /// 🇮🇱 האם קבלה אמיתית סרוקה
  /// 🇬🇧 Is this a real scanned receipt
  bool get isRealScanned => !isVirtual && fileUrl != null;

  /// יצירת קבלה חדשה עם id אוטומטי
  factory Receipt.newReceipt({
    required String storeName,
    required DateTime date,
    required String householdId,
    double totalAmount = 0.0,
    List<ReceiptItem> items = const [],
    String? originalUrl,
    String? fileUrl,
    String? linkedShoppingListId,
    bool isVirtual = false,
    String? createdBy,
  }) {
    return Receipt(
      id: const Uuid().v4(),
      storeName: storeName,
      date: date,
      totalAmount: totalAmount,
      items: List.unmodifiable(items),
      createdDate: DateTime.now(),
      originalUrl: originalUrl,
      fileUrl: fileUrl,
      linkedShoppingListId: linkedShoppingListId,
      isVirtual: isVirtual,
      createdBy: createdBy,
      householdId: householdId,
    );
  }

  /// 🆕 יצירת קבלה וירטואלית מסיום קנייה
  /// 🇬🇧 Create virtual receipt from shopping completion
  factory Receipt.virtual({
    required String linkedShoppingListId,
    required String createdBy,
    required String householdId,
    required String storeName,
    required List<ReceiptItem> items,
    DateTime? date,
  }) {
    return Receipt(
      id: const Uuid().v4(),
      storeName: '$storeName (וירטואלי)',
      date: date ?? DateTime.now(),
      totalAmount: 0.0, // מחיר משומן יהיה אחרי קישור קבלה אמיתית
      items: List.unmodifiable(items),
      createdDate: DateTime.now(),
      linkedShoppingListId: linkedShoppingListId,
      isVirtual: true,
      createdBy: createdBy,
      householdId: householdId,
      fileUrl: null, // אין סריקה
    );
  }

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptToJson(this);

  @override
  String toString() =>
      'Receipt(id: $id, store: $storeName, items: ${items.length}, total: $totalAmount)';
}

/// ─────────────────────────────────────────────
/// ReceiptItem (פריט יחיד בקבלה)
/// ─────────────────────────────────────────────

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class ReceiptItem {
  /// מזהה ייחודי לפריט
  @JsonKey(defaultValue: '')
  final String id;

  /// שם המוצר (אופציונלי - יכול להיות null אם OCR נכשל)
  /// 📌 nullable - אם אין שם, יהיה null (לא '')
  final String? name;

  /// כמות (>= 0)
  @JsonKey(defaultValue: 1)
  final int quantity;

  /// מחיר ליחידה
  @FlexDoubleConverter()
  final double unitPrice;

  /// האם סומן כנקנה
  @JsonKey(defaultValue: false)
  final bool isChecked;

  /// ברקוד (אם זמין)
  final String? barcode;

  /// יצרן/מותג (אם זמין)
  final String? manufacturer;

  /// קטגוריה (אם זמינה)
  final String? category;

  /// יחידת מידה (אם זימנה)
  final String? unit;

  /// 🆕 מזהה המשתמש שסימן את הפריט (קנייה משותפת)
  /// 🇬🇧 User ID who checked this item (collaborative shopping)
  @JsonKey(name: 'checked_by')
  final String? checkedBy;

  /// 🆕 מתי סומן הפריט
  /// 🇬🇧 When the item was checked
  /// 🔧 תומך ב-Timestamp (Firestore) + String (ISO) + DateTime
  @NullableFlexibleDateTimeConverter()
  @JsonKey(name: 'checked_at')
  final DateTime? checkedAt;

  const ReceiptItem({
    this.id = '',
    this.name,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.isChecked = false,
    this.barcode,
    this.manufacturer,
    this.category,
    this.unit,
    this.checkedBy,
    this.checkedAt,
  }) : assert(quantity >= 0, 'Quantity must be >= 0'),
       assert(unitPrice >= 0, 'Unit price must be >= 0');

  /// 🇮🇱 האם הפריט סומן על ידי מישהו (יש checkedBy)
  /// 🇬🇧 Was the item checked by someone (has checkedBy)
  bool get wasChecked => checkedBy != null;

  /// מחיר כולל (כמות * מחיר ליחידה)
  double get totalPrice => quantity * unitPrice;

  ReceiptItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
    bool? isChecked,
    String? barcode,
    String? manufacturer,
    String? category,
    String? unit,
    String? checkedBy,
    DateTime? checkedAt,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isChecked: isChecked ?? this.isChecked,
      barcode: barcode ?? this.barcode,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptItemToJson(this);

  @override
  String toString() =>
      'ReceiptItem(id: $id, name: ${name ?? "ללא שם"}, qty: $quantity, price: $unitPrice)';
}
