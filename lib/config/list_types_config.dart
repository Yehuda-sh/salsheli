// 📄 lib/config/list_types_config.dart
//
// 🎯 מטרה: הגדרה מרכזית של כל סוגי הרשימות (9 סוגים)
//
// ✨ יתרונות:
// - מקור אמת יחיד (Single Source of Truth)
// - תמיכה מלאה ב-i18n דרך AppStrings
// - עקביות ויזואלית (צבעים ואייקונים) בכל האפליקציה
//
// 📜 חוקי עבודה:
// - key לא מוכר → fallback ל-ListTypeKeys.other
// - סדר all = סדר UX, other חייב להיות אחרון
// - חייב להיות 1:1 עם ListTypeKeys.all
//
// 🔗 Related: list_type_keys.dart, AppStrings, AppTheme

import 'package:flutter/material.dart';

import '../core/ui_constants.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'base_config.dart';
import 'list_type_keys.dart';

/// 📦 הגדרת סוג רשימה אחד
/// מכיל את כל המידע הויזואלי והטקסטואלי
class ListTypeConfig {
  /// מפתח ייחודי (תואם ל-ListTypeKeys)
  final String key;

  /// שם מלא להצגה (נמשך מ-AppStrings)
  final String fullName;

  /// שם קצר להצגה (למשל ב-Dropdown או בטאבים קטנים)
  final String shortName;

  /// אימוג'י ייצוגי
  final String emoji;

  /// אייקון Material
  final IconData icon;

  /// צבע אחיד לסוג הרשימה (Sticky Note style)
  final Color? color;

  const ListTypeConfig({
    required this.key,
    required this.fullName,
    required this.shortName,
    required this.emoji,
    required this.icon,
    this.color,
  });
}

/// 🗂️ כל סוגי הרשימות במערכת
class ListTypes with ConfigValidation {
  ListTypes._(); // מניעת instances
  static final ListTypes _instance = ListTypes._();

  /// רשימת כל הסוגים (מחובר ל-AppStrings)
  static List<ListTypeConfig> get all => [
    ListTypeConfig(
      key: ListTypeKeys.supermarket,
      fullName: AppStrings.shopping.typeSupermarket,
      shortName: 'סופר',
      emoji: '🛒',
      icon: Icons.shopping_cart,
      color: kStickyGreen,
    ),
    ListTypeConfig(
      key: ListTypeKeys.pharmacy,
      fullName: AppStrings.shopping.typePharmacy,
      shortName: 'מרקחת',
      emoji: '💊',
      icon: Icons.medication,
      color: kStickyPink,
    ),
    ListTypeConfig(
      key: ListTypeKeys.greengrocer,
      fullName: AppStrings.shopping.typeGreengrocer,
      shortName: 'ירקן',
      emoji: '🥬',
      icon: Icons.local_florist,
      color: kStickyCyan,
    ),
    ListTypeConfig(
      key: ListTypeKeys.butcher,
      fullName: AppStrings.shopping.typeButcher,
      shortName: 'אטליז',
      emoji: '🥩',
      icon: Icons.set_meal,
      color: kStickyOrange,
    ),
    ListTypeConfig(
      key: ListTypeKeys.bakery,
      fullName: AppStrings.shopping.typeBakery,
      shortName: 'מאפייה',
      emoji: '🥖',
      icon: Icons.bakery_dining,
      color: kStickyYellow,
    ),
    ListTypeConfig(
      key: ListTypeKeys.market,
      fullName: AppStrings.shopping.typeMarket,
      shortName: 'שוק',
      emoji: '🏪',
      icon: Icons.store,
      color: kStickyGreen,
    ),
    ListTypeConfig(
      key: ListTypeKeys.household,
      fullName: AppStrings.shopping.typeHousehold,
      shortName: 'בית',
      emoji: '🏠',
      icon: Icons.home,
      color: kStickyCyan,
    ),
    ListTypeConfig(
      key: ListTypeKeys.event,
      fullName: AppStrings.shopping.typeEvent,
      shortName: 'אירוע',
      emoji: '🎉',
      icon: Icons.celebration,
      color: kStickyPurple,
    ),
    ListTypeConfig(
      key: ListTypeKeys.other,
      fullName: AppStrings.shopping.typeOther,
      shortName: 'אחר',
      emoji: '📝',
      icon: Icons.more_horiz,
    ),
  ];

  // ========================================
  // 🎨 Color API
  // ========================================

  /// צבע לפי סוג רשימה - תומך ב-Dark Mode דרך AppBrand
  static Color getColor(String typeKey, ColorScheme cs, AppBrand? brand) {
    if (brand != null) {
      switch (typeKey) {
        case ListTypeKeys.supermarket:
        case ListTypeKeys.market:
          return brand.stickyGreen;
        case ListTypeKeys.pharmacy:
          return brand.stickyPink;
        case ListTypeKeys.greengrocer:
        case ListTypeKeys.household:
          return brand.stickyCyan;
        case ListTypeKeys.bakery:
          return brand.stickyYellow;
        case ListTypeKeys.event:
          return brand.stickyPurple;
      }
    }
    // Fallback: צבע הקונפיגורציה או צבע הנושא הראשי
    return getByKeySafe(typeKey).color ?? cs.primary;
  }

  // ========================================
  // 🔍 Lookup API
  // ========================================

  /// מצא config לפי key - תמיד מחזיר Config בטוח לשימוש ב-UI
  static ListTypeConfig getByKeySafe(String? key) {
    _instance.ensureValid();

    if (key == null) return _otherConfig;

    // חיפוש יעיל ברשימה
    for (final config in all) {
      if (config.key == key) return config;
    }

    return _otherConfig;
  }

  /// Cache ל-Config ברירת המחדל (ביצועים)
  static const ListTypeConfig _otherConfig = ListTypeConfig(
    key: ListTypeKeys.other,
    fullName: 'אחר',
    shortName: 'אחר',
    emoji: '📝',
    icon: Icons.more_horiz,
  );

  /// ✅ Validation implementation - replaces old ensureSanity()
  @override
  void performValidation() {
    final configKeys = all.map((c) => c.key).toList();
    const expectedKeys = ListTypeKeys.all;

    // 1. Check for duplicates in config keys
    ConfigValidation.validateNoDuplicates(configKeys, 'ListTypes.all.keys');

    // 2. Check 1:1 mapping with ListTypeKeys
    if (configKeys.length != expectedKeys.length || !configKeys.every(expectedKeys.contains)) {
      throw AssertionError(
        'ListTypes: Config keys don\'t match ListTypeKeys.all\n'
        'Config keys: $configKeys\n'
        'Expected keys: $expectedKeys'
      );
    }

    // 3. Check fallback position
    if (all.isNotEmpty && all.last.key != ListTypeKeys.other) {
      throw AssertionError(
        'ListTypes: "${ListTypeKeys.other}" must be last in all list! '
        'Found: "${all.last.key}"'
      );
    }
  }
}
