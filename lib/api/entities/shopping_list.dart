// 📄 File: lib/api/entities/shopping_list.dart
// תיאור: Entity של רשימת קניות מה-API עם פריטים
//
// ✅ עודכן:
// 1. שינוי שם: ApiReceiptItem → ApiShoppingListItem
// 2. הוספת created_date
// 3. הוספת logging
// 4. תיקון תיעוד

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shopping_list.g.dart';

/// רשימת קניות (API Entity)
/// 
/// 🎯 משמש לתקשורת עם Firebase/API
/// 📝 מומר ל-ShoppingList (מודל מקומי) דרך mappers
@JsonSerializable(explicitToJson: true)
class ApiShoppingList {
  final String id;
  final String name;
  
  @JsonKey(name: 'created_date')
  final String? createdDate;
  
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
  
  final List<ApiShoppingListItem>? items;

  const ApiShoppingList({
    required this.id,
    required this.name,
    required this.householdId,
    this.createdDate,
    this.updatedDate,
    this.status,
    this.type,
    this.budget,
    this.isShared,
    this.createdBy,
    this.sharedWith,
    this.items,
  });

  /// ✅ פרסור תאריך יצירה
  DateTime? get createdAt => (createdDate == null || createdDate!.isEmpty)
      ? null
      : DateTime.tryParse(createdDate!);

  /// ✅ פרסור תאריך עדכון
  DateTime? get updatedAt => (updatedDate == null || updatedDate!.isEmpty)
      ? null
      : DateTime.tryParse(updatedDate!);

  factory ApiShoppingList.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 ApiShoppingList.fromJson: ${json['name']}');
    return _$ApiShoppingListFromJson(json);
  }

  Map<String, dynamic> toJson() {
    debugPrint('📤 ApiShoppingList.toJson: $name');
    return _$ApiShoppingListToJson(this);
  }

  ApiShoppingList copyWith({
    String? id,
    String? name,
    String? createdDate,
    String? updatedDate,
    String? householdId,
    String? status,
    String? type,
    double? budget,
    bool? isShared,
    String? createdBy,
    List<String>? sharedWith,
    List<ApiShoppingListItem>? items,
  }) {
    return ApiShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
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

/// פריט ברשימת קניות (API Entity)
/// 
/// 🎯 ייצוג של פריט בודד ברשימה
/// 📝 מומר ל-ReceiptItem (מודל מקומי) דרך mappers
@JsonSerializable(explicitToJson: true)
class ApiShoppingListItem {
  final String id;
  final String name;
  final int quantity;
  
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  
  @JsonKey(name: 'is_checked')
  final bool? isChecked;
  
  final String? barcode;
  final String? category;
  final String? unit;

  const ApiShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.isChecked,
    this.barcode,
    this.category,
    this.unit,
  });

  /// ✅ מחיר כולל
  double get totalPrice => quantity * unitPrice;

  factory ApiShoppingListItem.fromJson(Map<String, dynamic> json) {
    debugPrint('📥 ApiShoppingListItem.fromJson: ${json['name']}');
    return _$ApiShoppingListItemFromJson(json);
  }

  Map<String, dynamic> toJson() {
    debugPrint('📤 ApiShoppingListItem.toJson: $name');
    return _$ApiShoppingListItemToJson(this);
  }

  ApiShoppingListItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
    bool? isChecked,
    String? barcode,
    String? category,
    String? unit,
  }) {
    return ApiShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isChecked: isChecked ?? this.isChecked,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() => 'ApiShoppingListItem(id: $id, name: $name, qty: $quantity, checked: ${isChecked ?? false})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiShoppingListItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
