// 📄 File: lib/models/receipt.dart
//
// 🇮🇱 מודלים לייצוג קבלה (Receipt) ופריטים בקבלה (ReceiptItem):
//     - המרה מלאה ל־JSON כולל Converters (תאריכים, double).
//     - כולל חישובי סה"כ, בדיקות התאמה, ולוגיקת עזר.
//     - מתאים לניהול רשימות קניות, ניתוח הוצאות, סנכרון עם API.
//
// 💡 רעיונות עתידיים:
//     - הוספת שדה "אמצעי תשלום" (מזומן / אשראי).
//     - שמירת "מספר חשבונית" לשחזור מהחנות.
//     - חיבור ל־OCR לסריקה אוטומטית של קבלות.
//
// 🇬🇧 Models for Receipt and ReceiptItem:
//     - Full JSON serialization with converters (dates, doubles).
//     - Includes totals, validations, and helper logic.
//     - Useful for shopping lists, expense analysis, and API sync.
//
// 💡 Future ideas:
//     - Add "payment method" field (cash/credit).
//     - Store "invoice number" for store lookups.
//     - Integrate OCR for automatic receipt scanning.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'receipt.g.dart';

/// ─────────────────────────────────────────────
/// Converters (DateTime, Double)
/// ─────────────────────────────────────────────

/// 🇮🇱 ממיר תאריכים ISO8601 ↔ DateTime.
/// 🇬🇧 Converts ISO8601 strings ↔ DateTime.
class IsoDateTimeConverter implements JsonConverter<DateTime, String> {
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

/// 🇮🇱 ממיר תאריכים אופציונליים.
/// 🇬🇧 Nullable ISO8601 date converter.
class IsoDateTimeNullableConverter
    implements JsonConverter<DateTime?, String?> {
  const IsoDateTimeNullableConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}

/// 🇮🇱 ממיר double גמיש (מספרים/מחרוזות עם פסיק).
/// 🇬🇧 Flexible double converter (num/string with comma support).
class FlexDoubleConverter implements JsonConverter<double, Object?> {
  const FlexDoubleConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) {
      final cleaned = json.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Object toJson(double object) => object;
}

/// ─────────────────────────────────────────────
/// Receipt (קבלה שלמה)
/// ─────────────────────────────────────────────

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Receipt {
  /// מזהה ייחודי של הקבלה
  final String id;

  /// שם החנות
  final String storeName;

  /// תאריך הקנייה
  @IsoDateTimeConverter()
  final DateTime date;

  /// תאריך יצירת הרשומה (לא תמיד קיים)
  @IsoDateTimeNullableConverter()
  final DateTime? createdDate;

  /// סכום כולל לפי הקבלה
  @FlexDoubleConverter()
  final double totalAmount;

  /// פריטים בקבלה
  final List<ReceiptItem> items;

  const Receipt({
    required this.id,
    required this.storeName,
    required this.date,
    this.createdDate,
    required this.totalAmount,
    required this.items,
  });

  /// יצירת קבלה חדשה עם id אוטומטי
  factory Receipt.newReceipt({
    required String storeName,
    required DateTime date,
    double totalAmount = 0.0,
    List<ReceiptItem> items = const [],
  }) {
    return Receipt(
      id: const Uuid().v4(),
      storeName: storeName,
      date: date,
      totalAmount: totalAmount,
      items: List.unmodifiable(items),
      createdDate: DateTime.now(),
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

@JsonSerializable(fieldRename: FieldRename.snake)
class ReceiptItem {
  /// מזהה ייחודי לפריט
  final String id;

  /// שם המוצר (אופציונלי - יכול להיות null אם OCR נכשל)
  @JsonKey(defaultValue: '')
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

  const ReceiptItem({
    required this.id,
    this.name,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.isChecked = false,
    this.barcode,
    this.manufacturer,
    this.category,
    this.unit,
  }) : assert(quantity >= 0, 'Quantity must be >= 0'),
       assert(unitPrice >= 0, 'Unit price must be >= 0');

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
    );
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptItemToJson(this);

  @override
  String toString() =>
      'ReceiptItem(id: $id, name: ${name ?? "ללא שם"}, qty: $quantity, price: $unitPrice)';
}
