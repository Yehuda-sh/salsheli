// 📄 File: lib/config/list_types_config.dart
//
// 🎯 מטרה: הגדרה מרכזית של כל סוגי הרשימות
// 
// ✨ יתרונות:
// - מקור אמת יחיד (Single Source of Truth)
// - קל להוסיף סוג חדש (רק במקום אחד)
// - עקביות בכל האפליקציה
// - קל לתחזוקה ולבדיקה

import 'package:flutter/material.dart';
import 'package:memozap/models/shopping_list.dart';

/// 📦 הגדרת סוג רשימה אחד
/// מכיל את כל המידע הויזואלי והטקסטואלי
class ListTypeConfig {
  /// מפתח ייחודי (תואם ל-ShoppingList constants)
  final String key;
  
  /// שם מלא להצגה (למשל ב-Drawer)
  final String fullName;
  
  /// שם קצר להצגה (למשל ב-Dropdown)
  final String shortName;
  
  /// אימוג'י ייצוגי
  final String emoji;
  
  /// אייקון Material
  final IconData icon;
  
  /// צבע אופציונלי (לשימוש עתידי)
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
class ListTypes {
  /// רשימת כל הסוגים (7 סוגים + "אחר")
  static const List<ListTypeConfig> all = [
    ListTypeConfig(
      key: ShoppingList.typeSupermarket,
      fullName: 'סופרמרקט',
      shortName: 'סופר',
      emoji: '🛒',
      icon: Icons.shopping_cart,
    ),
    ListTypeConfig(
      key: ShoppingList.typePharmacy,
      fullName: 'בית מרקחת',
      shortName: 'מרקחת',
      emoji: '💊',
      icon: Icons.medication,
    ),
    ListTypeConfig(
      key: ShoppingList.typeGreengrocer,
      fullName: 'ירקן',
      shortName: 'ירקן',
      emoji: '🥬',
      icon: Icons.local_florist,
    ),
    ListTypeConfig(
      key: ShoppingList.typeButcher,
      fullName: 'אטליז',
      shortName: 'אטליז',
      emoji: '🥩',
      icon: Icons.set_meal,
    ),
    ListTypeConfig(
      key: ShoppingList.typeBakery,
      fullName: 'מאפייה',
      shortName: 'מאפייה',
      emoji: '🥖',
      icon: Icons.bakery_dining,
    ),
    ListTypeConfig(
      key: ShoppingList.typeMarket,
      fullName: 'שוק',
      shortName: 'שוק',
      emoji: '🏪',
      icon: Icons.store,
    ),
    ListTypeConfig(
      key: ShoppingList.typeHousehold,
      fullName: 'צרכי בית',
      shortName: 'בית',
      emoji: '🏠',
      icon: Icons.home,
    ),
    ListTypeConfig(
      key: ShoppingList.typeOther,
      fullName: 'אחר',
      shortName: 'אחר',
      emoji: '📝',
      icon: Icons.more_horiz,
    ),
  ];

  /// 🔍 מצא config לפי key
  static ListTypeConfig? getByKey(String key) {
    try {
      return all.firstWhere((config) => config.key == key);
    } catch (e) {
      return null;
    }
  }

  /// 🎨 קבל אימוג'י לפי key
  static String getEmoji(String key) {
    final config = getByKey(key);
    return config?.emoji ?? '📝';
  }

  /// 📝 קבל שם מלא לפי key
  static String getFullName(String key) {
    final config = getByKey(key);
    return config?.fullName ?? 'אחר';
  }

  /// 📋 קבל שם קצר לפי key
  static String getShortName(String key) {
    final config = getByKey(key);
    return config?.shortName ?? 'אחר';
  }

  /// 🎭 קבל אייקון לפי key
  static IconData getIcon(String key) {
    final config = getByKey(key);
    return config?.icon ?? Icons.more_horiz;
  }

  /// 🗺️ Map של אימוג'ים (לתאימות לאחור)
  static Map<String, String> get emojis {
    return Map.fromEntries(
      all.map((config) => MapEntry(config.key, config.emoji)),
    );
  }
}
