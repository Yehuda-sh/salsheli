// 📄 File: lib/config/category_config.dart
// 📌 Purpose: Defines UI/display config for product categories.
//     Includes emoji, Hebrew/English names, colors (Tailwind-like parsing),
//     sort order, fallback support, and utilities for hex and JSON parsing.

import 'dart:collection';
import 'package:flutter/material.dart';

/// קונפיגורציית קטגוריה לתצוגה ולוגיקה.
/// - color נשמר כ-Color חזק (לא String)
/// - שמות גם בעברית וגם באנגלית (ל־i18n)
@immutable
class CategoryConfig {
  final String id;
  final String nameHe;
  final String? nameEn;
  final String emoji; // אימוג'י לתצוגה
  final Color color;
  final int sort; // סדר קבוע ב־UI

  const CategoryConfig({
    required this.id,
    required this.nameHe,
    this.nameEn,
    required this.emoji,
    required this.color,
    this.sort = 0,
  });

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    return CategoryConfig(
      id: json['id']?.toString() ?? '',
      nameHe: json['name_he']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      emoji: json['emoji']?.toString() ?? '🛒',
      color: _parseColorToken(json['color']?.toString() ?? '#e5e7eb'),
      sort: json['sort'] is num ? (json['sort'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_he': nameHe,
      'name_en': nameEn,
      'emoji': emoji,
      'color': _colorToHex(color),
      'sort': sort,
    };
  }

  CategoryConfig copyWith({
    String? id,
    String? nameHe,
    String? nameEn,
    String? emoji,
    Color? color,
    int? sort,
  }) {
    return CategoryConfig(
      id: id ?? this.id,
      nameHe: nameHe ?? this.nameHe,
      nameEn: nameEn ?? this.nameEn,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      sort: sort ?? this.sort,
    );
  }

  @override
  String toString() =>
      'CategoryConfig(id: $id, nameHe: $nameHe, emoji: $emoji, color: ${_colorToHex(color)}, sort: $sort)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryConfig &&
          other.id == id &&
          other.nameHe == nameHe &&
          other.nameEn == nameEn &&
          other.emoji == emoji &&
          other.color.value == color.value &&
          other.sort == sort);

  @override
  int get hashCode => Object.hash(id, nameHe, nameEn, emoji, color.value, sort);
}

/// ----------------------------
/// Tailwind-like tokens → Color
/// ----------------------------
const Map<String, int> _tailwindSwatches = {
  // slate / gray
  'slate-50': 0xFFF8FAFC,
  'slate-100': 0xFFF1F5F9,
  'slate-200': 0xFFE2E8F0,
  'slate-300': 0xFFCBD5E1,
  'slate-700': 0xFF334155,
  'slate-800': 0xFF1F2937,
  'slate-900': 0xFF0F172A,
  // amber
  'amber-50': 0xFFFFFBEB,
  'amber-100': 0xFFFEF3C7,
  'amber-200': 0xFFFDE68A,
  'amber-300': 0xFFFBBF24,
  // red
  'red-50': 0xFFFEF2F2,
  'red-100': 0xFFFEE2E2,
  'red-200': 0xFFFECACA,
  'red-300': 0xFFFCA5A5,
  // green
  'green-50': 0xFFF0FDF4,
  'green-100': 0xFFDCFCE7,
  'green-200': 0xFFBBF7D0,
  'green-300': 0xFF86EFAC,
  // blue
  'blue-50': 0xFFEFF6FF,
  'blue-100': 0xFFDBEAFE,
  'blue-200': 0xFFBFDBFE,
  'blue-300': 0xFF93C5FD,
};

Color _parseColorToken(String token) {
  final t = token.trim().toLowerCase();

  // tailwind-like (e.g., "amber-100")
  if (_tailwindSwatches.containsKey(t)) {
    return Color(0xFF000000 | _tailwindSwatches[t]!);
    // 0xFF is opaque alpha
  }

  // hex notations: #RGB / #RGBA / #RRGGBB / #RRGGBBAA
  if (t.startsWith('#')) {
    final hex = t.substring(1);
    if (hex.length == 3) {
      // #RGB → #RRGGBB
      final r = '${hex[0]}${hex[0]}';
      final g = '${hex[1]}${hex[1]}';
      final b = '${hex[2]}${hex[2]}';
      return Color(int.parse('FF$r$g$b', radix: 16)); // FF alpha
    } else if (hex.length == 4) {
      // #RGBA → #RRGGBBAA
      final r = '${hex[0]}${hex[0]}';
      final g = '${hex[1]}${hex[1]}';
      final b = '${hex[2]}${hex[2]}';
      final a = '${hex[3]}${hex[3]}';
      return Color(int.parse('$a$r$g$b', radix: 16)); // AARRGGBB
    } else if (hex.length == 6) {
      // #RRGGBB
      return Color(int.parse('FF$hex', radix: 16)); // FF alpha
    } else if (hex.length == 8) {
      // #RRGGBBAA
      final a = hex.substring(6, 8);
      final rgb = hex.substring(0, 6);
      return Color(int.parse('$a$rgb', radix: 16)); // AARRGGBB
    }
  }

  // fallback
  return const Color(0xFFE5E7EB); // slate-200
}

String _colorToHex(Color c) {
  // מחזיר כ־#RRGGBB או #RRGGBBAA אם האלפא != FF
  final rgb = c.value & 0x00FFFFFF;
  final base = '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  final a = c.alpha; // 0–255
  if (a != 0xFF) {
    final aa = a.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '$base$aa';
  }
  return base;
}

/// ----------------------------
/// קטגוריות ברירת־מחדל
/// ----------------------------

final Map<String, CategoryConfig> _categoryConfigsMutable =
    <String, CategoryConfig>{
      'dairy': CategoryConfig(
        id: 'dairy',
        nameHe: 'חלב וביצים',
        nameEn: 'Dairy & Eggs',
        emoji: '🥛',
        color: _parseColorToken('#FEF3C7'), // amber-100
        sort: 10,
      ),
      'meat': CategoryConfig(
        id: 'meat',
        nameHe: 'בשר ודגים',
        nameEn: 'Meat & Fish',
        emoji: '🥩',
        color: _parseColorToken('#FECACA'), // red-200
        sort: 20,
      ),
      'dry_goods': CategoryConfig(
        id: 'dry_goods',
        nameHe: 'מוצרים יבשים',
        nameEn: 'Dry Goods',
        emoji: '📦',
        color: _parseColorToken('#E5E7EB'), // slate-200
        sort: 30,
      ),
      'produce': CategoryConfig(
        id: 'produce',
        nameHe: 'פירות וירקות',
        nameEn: 'Produce',
        emoji: '🥦',
        color: _parseColorToken('green-100'),
        sort: 5,
      ),
      'bakery': CategoryConfig(
        id: 'bakery',
        nameHe: 'מאפים ולחמים',
        nameEn: 'Bakery',
        emoji: '🥐',
        color: _parseColorToken('amber-50'),
        sort: 15,
      ),
      'beverages': CategoryConfig(
        id: 'beverages',
        nameHe: 'משקאות',
        nameEn: 'Beverages',
        emoji: '🥤',
        color: _parseColorToken('blue-50'),
        sort: 40,
      ),
      'household': CategoryConfig(
        id: 'household',
        nameHe: 'ניקיון ובית',
        nameEn: 'Household',
        emoji: '🧽',
        color: _parseColorToken('slate-100'),
        sort: 50,
      ),
    };

/// מפה בלתי־ניתנת לשינוי לשימוש חיצוני
final Map<String, CategoryConfig> kCategoryConfigs = UnmodifiableMapView(
  _categoryConfigsMutable,
);

/// תאימות לאחור (למי שמשתמש בשם הישן CATEGORY_CONFIG)
@Deprecated('Use kCategoryConfigs instead')
Map<String, CategoryConfig> get CATEGORY_CONFIG => kCategoryConfigs;

/// רשימה ממוינת לפי sort ואז שם עברית
List<CategoryConfig> get kCategoriesSorted {
  final list = kCategoryConfigs.values.toList();
  list.sort((a, b) {
    final s = a.sort.compareTo(b.sort);
    if (s != 0) return s;
    return a.nameHe.compareTo(b.nameHe);
  });
  return list;
}

/// קבלת קטגוריה עם fallback בטוח
CategoryConfig categoryById(String id) {
  return kCategoryConfigs[id] ??
      const CategoryConfig(
        id: 'other',
        nameHe: 'אחר',
        nameEn: 'Other',
        emoji: '🛒',
        color: Color(0xFFE5E7EB), // slate-200
        sort: 999,
      );
}

/// כלי עזר פומבי אם תרצה להשתמש בו במקומות אחרים
Color hexToColor(String token) => _parseColorToken(token);
