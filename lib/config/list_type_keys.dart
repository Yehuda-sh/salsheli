// lib/config/list_type_keys.dart — List type string constants — supermarket, pharmacy, greengrocer, butcher, bakery, market, etc.

/// 🗂️ מפתחות סוגי רשימות — Single Source of Truth ל-keys בלבד.
/// ה-metadata (אמוג'י, שם, אייקון) מנוהל בנפרד ב-ListTypesConfig.
///
/// אין כאן validation runtime — בדיקת השלמות (duplicates, סדר 'other'
/// בסוף, 1:1 מול ListTypesConfig) מתבצעת ב-ListTypes.performValidation()
/// שמתבצע ב-warmup הראשון של ListTypes.getByKeySafe().
class ListTypeKeys {
  ListTypeKeys._();

  /// 🛒 סופרמרקט - כל המוצרים הכלליים
  static const String supermarket = 'supermarket';

  /// 💊 בית מרקחת - מוצרי פארם, היגיינה וניקיון
  static const String pharmacy = 'pharmacy';

  /// 🥬 ירקן - פירות וירקות טריים
  static const String greengrocer = 'greengrocer';

  /// 🥩 אטליז - בשר, עוף ודגים
  static const String butcher = 'butcher';

  /// 🍞 מאפייה - לחם, מאפים ועוגות
  static const String bakery = 'bakery';

  /// 🏪 שוק - רשימות מעורבות (כמו מחנה יהודה)
  static const String market = 'market';

  /// 🏠 צרכי בית - מוצרי תחזוקה, גינה או כלי בית
  static const String household = 'household';

  /// 🎉 אירוע - רשימות ייעודיות למסיבות, חגים או מנגלים
  static const String event = 'event';

  /// ➕ אחר - סוג רשימה כללי (Fallback)
  static const String other = 'other';

  /// רשימת כל המפתחות (לשימוש ב-UI או ב-Validators)
  /// ✅ סדר תצוגה קבוע - other תמיד מופיע בסוף
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
