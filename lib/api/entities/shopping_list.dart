// 📄 File: lib/api/entities/shopping_list.dart
//
// ✅ גרסה מלאה עם כל השדות החדשים

class ApiShoppingList {
  final String id;
  final String name;
  final String? updatedDate;
  final String householdId;
  final String? status;
  final String? type;
  final double? budget;
  final bool? isShared;
  final String? createdBy;
  final List<String>? sharedWith;
  final List<ApiReceiptItem>? items;

  const ApiShoppingList({
    required this.id,
    required this.name,
    required this.householdId,
    this.updatedDate,
    this.status,
    this.type,
    this.budget,
    this.isShared,
    this.createdBy,
    this.sharedWith,
    this.items,
  });

  DateTime? get updatedAt => (updatedDate == null || updatedDate!.isEmpty)
      ? null
      : DateTime.tryParse(updatedDate!);

  factory ApiShoppingList.fromJson(Map<String, dynamic> json) {
    return ApiShoppingList(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      updatedDate: json['updated_date']?.toString(),
      householdId: (json['household_id'] ?? '').toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      budget: json['budget'] != null
          ? (json['budget'] as num).toDouble()
          : null,
      isShared: json['is_shared'] as bool?,
      createdBy: json['created_by']?.toString(),
      sharedWith: (json['shared_with'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ApiReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updated_date': updatedDate,
    'household_id': householdId,
    if (status != null) 'status': status,
    if (type != null) 'type': type,
    if (budget != null) 'budget': budget,
    if (isShared != null) 'is_shared': isShared,
    if (createdBy != null) 'created_by': createdBy,
    if (sharedWith != null) 'shared_with': sharedWith,
    if (items != null) 'items': items?.map((e) => e.toJson()).toList(),
  };

  ApiShoppingList copyWith({
    String? id,
    String? name,
    String? updatedDate,
    String? householdId,
    String? status,
    String? type,
    double? budget,
    bool? isShared,
    String? createdBy,
    List<String>? sharedWith,
    List<ApiReceiptItem>? items,
  }) {
    return ApiShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedDate: updatedDate ?? this.updatedDate,
      householdId: householdId ?? this.householdId,
      status: status ?? this.status,
      type: type ?? this.type,
      budget: budget ?? this.budget,
      isShared: isShared ?? this.isShared,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? this.sharedWith,
      items: items ?? this.items,
    );
  }

  @override
  String toString() =>
      'ApiShoppingList(id: $id, name: $name, type: $type, status: $status, items: ${items?.length ?? 0})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// פריט ברשימת קניות (API)
class ApiReceiptItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final bool? isChecked;
  final String? barcode;

  const ApiReceiptItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.isChecked,
    this.barcode,
  });

  double get totalPrice => quantity * unitPrice;

  factory ApiReceiptItem.fromJson(Map<String, dynamic> json) {
    return ApiReceiptItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['is_checked'] as bool?,
      barcode: json['barcode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    if (isChecked != null) 'is_checked': isChecked,
    if (barcode != null) 'barcode': barcode,
  };

  @override
  String toString() => 'ApiReceiptItem(id: $id, name: $name, qty: $quantity)';
}
