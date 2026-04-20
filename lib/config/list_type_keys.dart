// lib/config/list_type_keys.dart — List type string constants — supermarket, pharmacy, greengrocer, butcher, bakery, market, etc.

import 'base_config.dart';

/// 🗂️ מפתחות סוגי רשימות
///
/// משמש כ-Single Source of Truth למפתחות (keys) בלבד.
/// ה-metadata (אמוג'י, שם, אייקון) מנוהל בנפרד ב-ListTypesConfig.
class ListTypeKeys with ConfigValidation {
  ListTypeKeys._();
  static final ListTypeKeys _instance = ListTypeKeys._();

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

  /// Set for O(1) lookup in resolve()
  static final Set<String> _allSet = all.toSet();

  /// המרת String למפתח מוכר (עם Fallback)
  /// שימושי בטעינת נתונים מה-Database (Firestore)
  static String resolve(String? key) {
    _instance.ensureValid();
    if (key == null) return other;
    final normalized = key.trim().toLowerCase();
    if (!_allSet.contains(normalized)) return other;
    return normalized;
  }

  @override
  void performValidation() {
    ConfigValidation.validateNoDuplicates(all, 'ListTypeKeys.all');

    if (all.isNotEmpty && all.last != other) {
      throw AssertionError(
        'ListTypeKeys: "$other" must be last in all, found: "${all.last}"',
      );
    }
  }
}
