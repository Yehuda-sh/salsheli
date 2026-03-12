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

import 'base_config.dart';

/// Store category types
enum StoreCategory {
  supermarket,
  minimarket,
  pharmacy,
  // ❌ liquorStore - הוסר (לא חלק מהליבה)
}

/// מידע על חנות מוכרת
class StoreInfo {
  final String code;
  final String displayName;
  final StoreCategory category;

  const StoreInfo({
    required this.code,
    required this.displayName,
    required this.category,
  });
}

/// Configuration for stores
///
/// ✅ רשימה פתוחה - משתמש יכול להזין חנות חופשית!
/// החנויות המוכרות משמשות ל:
/// - אוטוקומפליט / הצעות
/// - קטגוריזציה אוטומטית
/// - תצוגת שם מותאם
class StoresConfig with ConfigValidation {
  StoresConfig._(); // Prevent instantiation
  static final StoresConfig _instance = StoresConfig._();

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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 Lookup API
  // ═══════════════════════════════════════════════════════════════════════════

  /// האם זו חנות מוכרת? (לא חוסם - רק מזהה)
  ///
  /// מקבל קוד או שם עברי
  static bool isKnown(String storeNameOrCode) {
    _instance.ensureValid();
    return _storeData.containsKey(storeNameOrCode) ||
        _hebrewToCode.containsKey(storeNameOrCode);
  }

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

  /// ✅ Validation implementation - replaces old ensureSanity()
  @override
  void performValidation() {
    // 1. Check for duplicates
    ConfigValidation.validateNoDuplicates(allCodes, 'StoresConfig.allCodes');

    // 2. Check all codes exist in data
    ConfigValidation.validateOneToOneMapping(
      allCodes.toSet(),
      _storeData,
      'StoresConfig'
    );

    // 3. Check Hebrew mapping points to valid codes
    for (final entry in _hebrewToCode.entries) {
      if (!_storeData.containsKey(entry.value)) {
        throw AssertionError(
          'StoresConfig: Hebrew name "${entry.key}" points to non-existent code "${entry.value}"'
        );
      }
    }
  }
}
