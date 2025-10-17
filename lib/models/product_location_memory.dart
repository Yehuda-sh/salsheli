// 📄 File: lib/models/product_location_memory.dart
//
// 🎯 מטרה: זיכרון מיקומי אחסון למוצרים
// המערכת זוכרת איפה כל מוצר אמור להיות

import 'package:json_annotation/json_annotation.dart';

part 'product_location_memory.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductLocationMemory {
  final String productName;
  final String defaultLocation;
  final String? category;
  final int usageCount;
  final DateTime lastUpdated;
  final String? householdId;

  const ProductLocationMemory({
    required this.productName,
    required this.defaultLocation,
    this.category,
    this.usageCount = 1,
    required this.lastUpdated,
    this.householdId,
  });

  factory ProductLocationMemory.fromJson(Map<String, dynamic> json) =>
      _$ProductLocationMemoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductLocationMemoryToJson(this);

  ProductLocationMemory copyWith({
    String? productName,
    String? defaultLocation,
    String? category,
    int? usageCount,
    DateTime? lastUpdated,
    String? householdId,
  }) {
    return ProductLocationMemory(
      productName: productName ?? this.productName,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      householdId: householdId ?? this.householdId,
    );
  }
}