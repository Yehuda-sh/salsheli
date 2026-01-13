// 📄 lib/config/list_type_keys.dart
//
// 🎯 מפתחות סוגי רשימות - קובץ משותף למניעת circular imports
//
// ✅ השימוש:
// - ListTypes (config) מייבא את הקובץ הזה
// - ShoppingList (model) יכול לייבא גם ListTypes וגם הקובץ הזה
// - אין מעגל תלות!
//
// 🔗 Related: list_types_config.dart, shopping_list.dart

/// 🗂️ מפתחות סוגי רשימות
///
/// משמש כ-Single Source of Truth למפתחות (keys) בלבד.
/// ה-metadata (emoji, name, icon) נמצא ב-ListTypes.
class ListTypeKeys {
  ListTypeKeys._(); // מניעת instances

  /// 🛒 סופרמרקט - כל המוצרים
  static const String supermarket = 'supermarket';

  /// 💊 בית מרקחת - היגיינה וניקיון
  static const String pharmacy = 'pharmacy';

  /// 🥬 ירקן - פירות וירקות
  static const String greengrocer = 'greengrocer';

  /// 🥩 אטליז - בשר ועוף
  static const String butcher = 'butcher';

  /// 🍞 מאפייה - לחם ומאפים
  static const String bakery = 'bakery';

  /// 🏪 שוק - מעורב
  static const String market = 'market';

  /// 🏠 צרכי בית - מוצרים מותאמים
  static const String household = 'household';

  /// 🎉 אירוע - מסיבות ומנגלים
  static const String event = 'event';

  /// ➕ אחר
  static const String other = 'other';

  /// רשימת כל המפתחות (לשימוש בלולאות/בדיקות)
  static const List<String> all = [
    supermarket,
    pharmacy,
    greengrocer,
    butcher,
    bakery,
    market,
    household,
    event,
    other,
  ];
}
