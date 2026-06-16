// lib/config/list_types_config.dart — List types config — 9 shopping list types with Hebrew names, emoji, and colors

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

  /// אימוג'י ייצוגי (fallback בלבד — לטקסטים, accessibility)
  final String emoji;

  /// אייקון Material — fallback אם אין sticker (כרגע רק household)
  final IconData icon;

  /// 🎨 Sticker מותאם (PNG ב-`assets/icons/list_types/`).
  /// כשמסופק, ה-UI מציג אותו במקום ה-Material icon — Notebook design language.
  /// אם null — חזרה ל-Material icon (זמני, עד יצירת sticker).
  final String? stickerAsset;

  /// צבע אחיד לסוג הרשימה (Sticky Note style) — light/fallback const.
  final Color? color;

  /// Dark-mode-aware resolver via AppBrand. Lives next to [color] so the
  /// type→color mapping has a single home (was duplicated in getColor's
  /// switch). null → fall back to [color] / theme primary.
  final Color Function(AppBrand)? brandColor;

  const ListTypeConfig({
    required this.key,
    required this.fullName,
    required this.shortName,
    required this.emoji,
    required this.icon,
    this.stickerAsset,
    this.color,
    this.brandColor,
  });
}

/// 🗂️ כל סוגי הרשימות במערכת
class ListTypes with ConfigValidation {
  ListTypes._(); // מניעת instances
  static final ListTypes _instance = ListTypes._();

  /// רשימת כל הסוגים (מחובר ל-AppStrings)
  static final List<ListTypeConfig> all = [
    ListTypeConfig(
      key: ListTypeKeys.supermarket,
      fullName: AppStrings.shopping.typeSupermarket,
      shortName: AppStrings.shopping.typeSupermarketShort,
      emoji: '🛒',
      icon: Icons.shopping_cart,
      stickerAsset: 'assets/icons/list_types/supermarket.png',
      color: kStickyGreen,
      brandColor: (b) => b.stickyGreen,
    ),
    ListTypeConfig(
      key: ListTypeKeys.pharmacy,
      fullName: AppStrings.shopping.typePharmacy,
      shortName: AppStrings.shopping.typePharmacyShort,
      emoji: '💊',
      icon: Icons.medication,
      stickerAsset: 'assets/icons/list_types/pharmacy.png',
      color: kStickyPink,
      brandColor: (b) => b.stickyPink,
    ),
    ListTypeConfig(
      key: ListTypeKeys.greengrocer,
      fullName: AppStrings.shopping.typeGreengrocer,
      shortName: AppStrings.shopping.typeGreengrocerShort,
      emoji: '🥬',
      icon: Icons.local_florist,
      stickerAsset: 'assets/icons/list_types/greengrocer.png',
      color: kStickyCyan,
      brandColor: (b) => b.stickyCyan,
    ),
    ListTypeConfig(
      key: ListTypeKeys.butcher,
      fullName: AppStrings.shopping.typeButcher,
      shortName: AppStrings.shopping.typeButcherShort,
      emoji: '🥩',
      icon: Icons.set_meal,
      stickerAsset: 'assets/icons/list_types/butcher.png',
      color: kStickyOrange,
      brandColor: (b) => b.stickyOrange,
    ),
    ListTypeConfig(
      key: ListTypeKeys.bakery,
      fullName: AppStrings.shopping.typeBakery,
      shortName: AppStrings.shopping.typeBakeryShort,
      emoji: '🥖',
      icon: Icons.bakery_dining,
      stickerAsset: 'assets/icons/list_types/bakery.png',
      color: kStickyYellow,
      brandColor: (b) => b.stickyYellow,
    ),
    ListTypeConfig(
      key: ListTypeKeys.market,
      fullName: AppStrings.shopping.typeMarket,
      shortName: AppStrings.shopping.typeMarketShort,
      emoji: '🏪',
      icon: Icons.store,
      stickerAsset: 'assets/icons/list_types/market.png',
      color: kStickyGreen,
      brandColor: (b) => b.stickyGreen,
    ),
    ListTypeConfig(
      key: ListTypeKeys.household,
      fullName: AppStrings.shopping.typeHousehold,
      shortName: AppStrings.shopping.typeHouseholdShort,
      emoji: '🏠',
      icon: Icons.home,
      // 🚧 TODO: add assets/icons/list_types/household.png — falls back to Material icon for now.
      color: kStickyCyan,
      brandColor: (b) => b.stickyCyan,
    ),
    ListTypeConfig(
      key: ListTypeKeys.event,
      fullName: AppStrings.shopping.typeEvent,
      shortName: AppStrings.shopping.typeEventShort,
      emoji: '🎉',
      icon: Icons.celebration,
      stickerAsset: 'assets/icons/list_types/event.png',
      color: kStickyPurple,
      brandColor: (b) => b.stickyPurple,
    ),
    ListTypeConfig(
      key: ListTypeKeys.other,
      fullName: AppStrings.shopping.typeOther,
      shortName: AppStrings.shopping.typeOtherShort,
      emoji: '📝',
      icon: Icons.more_horiz,
      stickerAsset: 'assets/icons/list_types/other.png',
    ),
  ];

  /// Map for O(1) lookup by key
  static final Map<String, ListTypeConfig> _byKey = {
    for (final config in all) config.key: config,
  };

  // ========================================
  // 🎨 Color API
  // ========================================

  /// צבע לפי סוג רשימה - תומך ב-Dark Mode דרך AppBrand.
  /// Single source: each config declares its own [brandColor] resolver.
  static Color getColor(String typeKey, ColorScheme cs, AppBrand? brand) {
    final config = getByKeySafe(typeKey);
    if (brand != null && config.brandColor != null) {
      return config.brandColor!(brand);
    }
    // Fallback: light const color, or theme primary (e.g. 'other').
    return config.color ?? cs.primary;
  }

  // ========================================
  // 🔍 Lookup API
  // ========================================

  /// מצא config לפי key - תמיד מחזיר Config בטוח לשימוש ב-UI.
  /// `_byKey[other]!` — `'other'` is enforced to exist in `all` by
  /// performValidation(); the const list itself is hardcoded above.
  static ListTypeConfig getByKeySafe(String? key) {
    _instance.ensureValid();
    if (key == null) return _byKey[ListTypeKeys.other]!;
    return _byKey[key] ?? _byKey[ListTypeKeys.other]!;
  }

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
