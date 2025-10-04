// 📄 File: lib/models/product.dart
//
// 🇮🇱 מודל נתונים עבור מוצר בקטלוג:
//     - כולל תמיכה מלאה ב-JSON (camelCase + snake_case).
//     - חיפוש טקסטואלי פשוט (שם, מותג, תיאור).
//     - מציג מחיר בפורמט שקל (₪).
//     - Immutable.
//     - אופציונלי: toCamelJson, fromLooseJson, copyWithPrice.
//
// 🇬🇧 Catalog Product model with JSON (camelCase & snake_case),
//     simple text search, ILS price formatting, and immutability.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class Product {
  /// Unique product identifier
  final String id;

  /// Product name
  final String name;

  /// Product description (optional)
  final String? description;

  /// Brand / manufacturer
  final String? brand;

  /// Package size (e.g. "1L", "500g")
  final String? packageSize;

  /// Category (e.g. "Dairy")
  final String? category;

  /// Product price (if available)
  final double? price;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.packageSize,
    this.category,
    this.price,
  });

  /// Empty product (useful for initial state)
  const Product.empty()
    : id = '',
      name = '',
      description = null,
      brand = null,
      packageSize = null,
      category = null,
      price = null;

  /// Create product from JSON (supports snake_case & camelCase)
  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Product.empty();
    String _s(Object? v) => (v is String ? v : v?.toString() ?? '').trim();

    return Product(
      id: _s(json['id'] ?? json['product_id']),
      name: _s(json['name'] ?? json['product_name']),
      description: _s(json['description']),
      brand: _s(json['brand']),
      packageSize: _s(json['packageSize'] ?? json['package_size']),
      category: _s(json['category'] ?? json['category_id']),
      price: _asDouble(json['price']),
    );
  }

  /// A looser parser that tolerates more input variations (optional)
  factory Product.fromLooseJson(Map<String, dynamic>? json) {
    if (json == null) return const Product.empty();
    String _s(Object? v) => (v is String ? v : v?.toString() ?? '').trim();

    // Try more aliases for id/name
    final id = _s(json['id'] ?? json['product_id'] ?? json['code'] ?? '');
    final name = _s(
      json['name'] ?? json['product_name'] ?? json['title'] ?? '',
    );

    return Product(
      id: id,
      name: name,
      description: _s(json['description'] ?? json['desc']),
      brand: _s(json['brand'] ?? json['manufacturer']),
      packageSize: _s(
        json['packageSize'] ?? json['package_size'] ?? json['size'],
      ),
      category: _s(json['category'] ?? json['category_id'] ?? json['cat']),
      price: _asDouble(json['price'] ?? json['unit_price'] ?? json['amount']),
    );
  }

  /// Convert back to JSON (snake_case)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (brand != null) 'brand': brand,
    if (packageSize != null) 'package_size': packageSize,
    if (category != null) 'category': category,
    if (price != null) 'price': price,
  };

  /// Optional: camelCase JSON (useful for some APIs/UI layers)
  Map<String, dynamic> toCamelJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (brand != null) 'brand': brand,
    if (packageSize != null) 'packageSize': packageSize,
    if (category != null) 'category': category,
    if (price != null) 'price': price,
  };

  /// Create a new copy with updates
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? brand,
    String? packageSize,
    String? category,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      packageSize: packageSize ?? this.packageSize,
      category: category ?? this.category,
      price: price ?? this.price,
    );
  }

  /// Convenience: copy with price only
  Product copyWithPrice(double? newPrice) => copyWith(price: newPrice);

  /// Whether product has a valid price
  bool get hasPrice => price != null && price! >= 0;

  static NumberFormat? _ils;
  static NumberFormat get _ilsFmt => _ils ??= NumberFormat.currency(
    locale: 'he_IL',
    symbol: '₪',
    decimalDigits: 2,
  );

  /// Returns price formatted with shekel (₪)
  String get formattedPrice {
    if (!hasPrice) return '—';
    return _ilsFmt.format(price);
  }

  /// Check if product matches text query (name, brand, category, description, packageSize)
  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
    return contains(name) ||
        contains(brand) ||
        contains(category) ||
        contains(description) ||
        contains(packageSize);
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: ${price ?? "-"}, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          brand == other.brand &&
          packageSize == other.packageSize &&
          category == other.category &&
          price == other.price;

  @override
  int get hashCode =>
      Object.hash(id, name, description, brand, packageSize, category, price);
}

/// ─────────────────────────────────────────────
/// Utilities
/// ─────────────────────────────────────────────

/// Try to convert value to double (supports strings with commas)
double? _asDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    return parsed;
  }
  return null;
}
