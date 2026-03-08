// 📄 lib/config/stores_config.dart
//
// הגדרות חנויות - סופרמרקטים, מיניקמטים, בתי מרקחת.
// כולל קטגוריזציה לפי סוג חנות ופונקציות עזר.
//
// 📜 חוקי עבודה:
// - רשימת החנויות היא פתוחה (הצעה/אוטוקומפליט, לא חסימה)
// - חנות לא מוכרת → שומרים את הטקסט שהמשתמש כתב
// - שומרים לפי מותג בלבד (לא סניפים)
// - קודים פנימיים יציבים (לא עברית כ-ID)
//
// 🔗 Related: onboarding_data, OnboardingSteps

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
);
}

/// Configuration for stores
///
/// ✅ רשימה פתוחה - משתמש יכול להזין חנות חופשית!
/// החנויות המוכרות משמשות ל:
/// - אוטוקומפליט / הצעות
/// - קטגוריזציה אוטומטית
/// - תצוגת שם מותאם
class StoresConfig {
  StoresConfig._(); // Prevent instantiation

  // ═══════════════════════════════════════════════════════════════════════════
  // STORE CODES - קודים יציבים (לא לשנות!)
  // ═══════════════════════════════════════════════════════════════════════════

  // Supermarkets
  static const String shufersal = 'shufersal';
  static const String ramiLevy = 'rami_levy';
  static const String mega = 'mega';
  static const String hatziHinam = 'hatzi_hinam';
  static const String victory = 'victory';

  // Minimarkets
  static const String ampm = 'ampm';

  // Pharmacies
  static const String superPharm = 'super_pharm';

  // ═══════════════════════════════════════════════════════════════════════════
  // KNOWN STORES DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// מיפוי קודים למידע מלא
  static const Map<String, StoreInfo> _storeData = {
    shufersal: StoreInfo(
      code: shufersal,
      displayName: 'שופרסל',
      category: StoreCategory.supermarket,
    ),
    ramiLevy: StoreInfo(
      code: ramiLevy,
      displayName: 'רמי לוי',
      category: StoreCategory.supermarket,
    ),
    mega: StoreInfo(
      code: mega,
      displayName: 'מגה',
      category: StoreCategory.supermarket,
    ),
    hatziHinam: StoreInfo(
      code: hatziHinam,
      displayName: 'חצי חינם',
      category: StoreCategory.supermarket,
    ),
    victory: StoreInfo(
      code: victory,
      displayName: 'ויקטורי',
      category: StoreCategory.supermarket,
    ),
    ampm: StoreInfo(
      code: ampm,
      displayName: 'AM:PM',
      category: StoreCategory.minimarket,
    ),
    superPharm: StoreInfo(
      code: superPharm,
      displayName: 'סופר פארם',
      category: StoreCategory.pharmacy,
    ),
  };

  /// מיפוי שמות עברית לקודים (backward compatibility + resolve)
  static const Map<String, String> _hebrewToCode = {
    'שופרסל': shufersal,
    'רמי לוי': ramiLevy,
    'מגה': mega,
    'חצי חינם': hatziHinam,
    'ויקטורי': victory,
    'AM:PM': ampm,
    'סופר פארם': superPharm,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // LISTS BY CATEGORY
  // ═══════════════════════════════════════════════════════════════════════════

  /// קודי סופרמרקטים
  static const List<String> supermarkets = [
    shufersal,
    ramiLevy,
    mega,
    hatziHinam,
    victory,
  ];

  /// קודי מיניקמטים
  static const List<String> minimarkets = [
    ampm,
  ];

  /// קודי בתי מרקחת
  static const List<String> pharmacies = [
    superPharm,
  ];

  /// כל הקודים המוכרים
  static const List<String> allCodes = [
    ...supermarkets,
    ...minimarkets,
    ...pharmacies,
  ];

  /// שמות תצוגה (לאוטוקומפליט) - סדר UX
  static List<String> get allDisplayNames =>
      allCodes.map((code) => _storeData[code]!.displayName).toList();

  /// @deprecated השתמש ב-allDisplayNames לאוטוקומפליט
  static List<String> get allStores => allDisplayNames;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 Lookup API
  // ═══════════════════════════════════════════════════════════════════════════

  /// האם זו חנות מוכרת? (לא חוסם - רק מזהה)
  ///
  /// מקבל קוד או שם עברי
  static bool isKnown(String storeNameOrCode) {
    if (kDebugMode) ensureSanity();
    return _storeData.containsKey(storeNameOrCode) ||
        _hebrewToCode.containsKey(storeNameOrCode);
  }

  /// @deprecated השתמש ב-isKnown() במקום - שים לב שהרשימה פתוחה!
  static bool isValid(String store) => isKnown(store);

  /// ממיר שם/קוד לקוד קנוני
  ///
  /// - קוד מוכר → מחזיר אותו
  /// - שם עברי מוכר → מחזיר קוד
  /// - לא מוכר → מחזיר את הקלט כמו שהוא (טקסט חופשי)
  static String resolve(String storeNameOrCode) {
    if (_storeData.containsKey(storeNameOrCode)) {
      return storeNameOrCode; // כבר קוד
    }
    return _hebrewToCode[storeNameOrCode] ?? storeNameOrCode;
  }

  /// מחזיר שם תצוגה
  ///
  /// - קוד/שם מוכר → שם עברי
  /// - לא מוכר → מחזיר את הקלט כמו שהוא
  static String getDisplayName(String storeNameOrCode) {
    final code = resolve(storeNameOrCode);
    return _storeData[code]?.displayName ?? storeNameOrCode;
  }

  /// מחזיר קטגוריה (null אם לא מוכר)
  static StoreCategory? getCategory(String storeNameOrCode) {
    final code = resolve(storeNameOrCode);
    return _storeData[code]?.category;
  }

  /// מחזיר מידע מלא (null אם לא מוכר)
  static StoreInfo? getInfo(String storeNameOrCode) {
    final code = resolve(storeNameOrCode);
    return _storeData[code];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 Debug Validation
  // ═══════════════════════════════════════════════════════════════════════════

  static bool _sanityChecked = false;

  /// 🔍 Sanity check - בדיקת פיתוח בלבד
  ///
  /// מוודא:
  /// 1. אין כפילויות קודים
  /// 2. כל קוד ב-allCodes קיים ב-_storeData
  /// 3. כל ערך ב-_hebrewToCode מצביע לקוד תקין
  static void ensureSanity() {
    if (!kDebugMode) return;
    if (_sanityChecked) return;
    _sanityChecked = true;

    // 1️⃣ בדיקת כפילויות
    final seen = <String>{};
    for (final code in allCodes) {
      if (seen.contains(code)) {
        assert(false, '❌ StoresConfig: כפילות קוד! "$code"');
      }
      seen.add(code);
    }

    // 2️⃣ בדיקה שכל קוד ב-allCodes קיים ב-_storeData
    for (final code in allCodes) {
      if (!_storeData.containsKey(code)) {
        assert(false,
            '❌ StoresConfig: קוד "$code" ב-allCodes אך חסר ב-_storeData');
      }
    }

    // 3️⃣ בדיקה שכל ערך ב-_hebrewToCode מצביע לקוד תקין
    for (final entry in _hebrewToCode.entries) {
      if (!_storeData.containsKey(entry.value)) {
        assert(false,
            '❌ StoresConfig: "${entry.key}" מצביע לקוד לא קיים "${entry.value}"');
      }
    }

    debugPrint(
        '✅ StoresConfig.ensureSanity(): ${allCodes.length} חנויות מוכרות');
  }
}
