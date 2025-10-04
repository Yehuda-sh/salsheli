// 📄 File: lib/api/entities/shopping_list.dart
// תיאור: Entity של רשימת קניות מה-API עם פריטים

import 'package:json_annotation/json_annotation.dart';

part 'shopping_list.g.dart';

/// רשימת קניות (API)
@JsonSerializable(explicitToJson: true)
class ApiShoppingList {
  final String id;
  final String name;
  @JsonKey(name: 'updated_date')
  final String? updatedDate;
  @JsonKey(name: 'household_id')
  final String householdId;
  final String? status;
  final String? type;
  final double? budget;
  @JsonKey(name: 'is_shared')
  final bool? isShared;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'shared_with')
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

  factory ApiShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ApiShoppingListFromJson(json);

  Map<String, dynamic> toJson() => _$ApiShoppingListToJson(this);

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
@JsonSerializable(explicitToJson: true)
class ApiReceiptItem {
  final String id;
  final String name;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  @JsonKey(name: 'is_checked')
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

  factory ApiReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ApiReceiptItemFromJson(json);

  Map<String, dynamic> toJson() => _$ApiReceiptItemToJson(this);

  ApiReceiptItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
    bool? isChecked,
    String? barcode,
  }) {
    return ApiReceiptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isChecked: isChecked ?? this.isChecked,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  String toString() => 'ApiReceiptItem(id: $id, name: $name, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiReceiptItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
