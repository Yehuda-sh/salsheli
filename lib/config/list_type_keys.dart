// lib/config/list_type_keys.dart — List type string constants — supermarket + other (app is supermarket-only).

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

  /// ➕ אחר - סוג רשימה כללי (Fallback)
  static const String other = 'other';

  /// רשימת כל המפתחות (לשימוש ב-UI או ב-Validators)
  /// ✅ סדר תצוגה קבוע - other תמיד מופיע בסוף
  static const List<String> all = [
    supermarket,
    other,
  ];
}
