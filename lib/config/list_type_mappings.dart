// 📄 File: lib/config/list_type_mappings.dart
//
// Purpose: מיפוי בין סוגי רשימות קניות לקטגוריות וחנויות רלוונטיות
//
// Features:
// - מיפוי type → קטגוריות מוצרים (const maps)
// - מיפוי type → חנויות/מותגים מומלצים
// - פריטים כלליים לכל סוג רשימה
// - תמיכה בכל 21 סוגי הרשימות (מלא!)
// - קטגוריות משותפות לאירועים (birthday, party, wedding, etc.)
// - Cache אוטומטי ל-getAllCategories/getAllStores (performance)
// - Logging מפורט לדיבוג
//
// Usage:
// ```dart
// // קבלת קטגוריות לסוג רשימה
// final categories = ListTypeMappings.getCategoriesForType(ListType.clothing);
// // → ['חולצות', 'מכנסיים', 'שמלות וחצאיות', ...]
//
// // קבלת חנויות מומלצות
// final stores = ListTypeMappings.getStoresForType(ListType.super_);
// // → ['שופרסל', 'רמי לוי', 'יוחננוף', ...]
//
// // פריטים מוצעים
// final items = ListTypeMappings.getSuggestedItemsForType(ListType.pharmacy);
// // → ['תרופת כאב', 'ויטמין D', ...]
//
// // בדיקת רלוונטיות
// final isRelevant = ListTypeMappings.isCategoryRelevantForType(
//   'מוצרי חלב',
//   ListType.super_,
// ); // → true
//
// // קבלת כל הקטגוריות (cached)
// final allCategories = ListTypeMappings.getAllCategories();
// ```
//
// Version: 3.0 - כל 21 הסוגים מוגדרים!
// Last Updated: 08/10/2025

import 'package:flutter/foundation.dart';
import '../core/constants.dart';

class ListTypeMappings {
  // ========================================
  // קטגוריות בסיס לאירועים (משותפות)
  // ========================================

  /// קטגוריות משותפות לכל סוגי האירועים
  /// 
  /// משמש כבסיס ל: birthday, party, wedding, picnic, holiday
  static const _baseEventCategories = [
    'אוכל ומשקאות',
    'קישוטים',
    'כלי הגשה',
    'מפיות ומגבות',
    'כלים חד-פעמיים',
    'מוצרי ניקיון',
  ];

  // ========================================
  // מיפוי Type → קטגוריות
  // ========================================

  /// מחזיר קטגוריות רלוונטיות לסוג הרשימה
  /// 
  /// אם [type] לא קיים, מחזיר קטגוריות של 'other' (fallback)
  static List<String> getCategoriesForType(String type) {
    final categories = _typeToCategories[type];
    
    if (categories == null) {
      debugPrint('⚠️ ListTypeMappings: Unknown list type "$type", using fallback "other"');
      return _typeToCategories[ListType.other]!;
    }
    
    debugPrint('📋 ListTypeMappings.getCategoriesForType($type) → ${categories.length} categories');
    return categories;
  }

  static const Map<String, List<String>> _typeToCategories = {
    // סופרמרקט - מזון ומוצרי בית
    ListType.super_: [
      'מוצרי חלב',
      'בשר ודגים',
      'פירות וירקות',
      'מאפים',
      'אורז ופסטה',
      'שימורים',
      'משקאות',
      'ממתקים וחטיפים',
      'תבלינים ואפייה',
      'שמנים ורטבים',
      'קפואים',
      'מוצרי בוקר',
    ],

    // בית מרקחת - בריאות וטיפוח
    ListType.pharmacy: [
      'תרופות',
      'ויטמינים ותוספי תזונה',
      'טיפוח הגוף',
      'טיפוח השיער',
      'היגיינה אישית',
      'קוסמטיקה',
      'מוצרי תינוקות',
      'עזרים רפואיים',
    ],

    // חומרי בניין - כלים וחומרים
    ListType.hardware: [
      'כלי עבודה',
      'חומרי בניין',
      'צבעים',
      'חשמל ותאורה',
      'אינסטלציה',
      'גינון',
      'בטיחות',
    ],

    // ביגוד - בגדים והנעלה
    ListType.clothing: [
      'חולצות',
      'מכנסיים',
      'שמלות וחצאיות',
      'הנעלה',
      'תחתונים וגרביים',
      'מעילים וז\'קטים',
      'ביגוד ספורט',
      'אביזרים',
    ],

    // אלקטרוניקה - מוצרי חשמל
    ListType.electronics: [
      'מחשבים וטאבלטים',
      'סמארטפונים',
      'אוזניות ורמקולים',
      'טלוויזיות',
      'מצלמות',
      'אביזרים',
      'משחקים',
    ],

    // חיות מחמד
    ListType.pets: [
      'מזון לכלבים',
      'מזון לחתולים',
      'חטיפים לחיות',
      'אביזרים',
      'משחקים לחיות',
      'טיפוח',
      'בריאות',
    ],

    // קוסמטיקה - יופי וטיפוח
    ListType.cosmetics: [
      'איפור פנים',
      'טיפוח העור',
      'בשמים',
      'טיפוח שיער',
      'מניקור ופדיקור',
      'אביזרי איפור',
    ],

    // ציוד משרדי
    ListType.stationery: [
      'כלי כתיבה',
      'מחברות ופנקסים',
      'ניירת',
      'ארגון משרדי',
      'אמנות ויצירה',
      'מדפסות ודיו',
    ],

    // צעצועים ומשחקים
    ListType.toys: [
      'צעצועים לגיל הרך',
      'משחקי קופסה',
      'משחקי חשיבה',
      'בובות ודמויות',
      'משחקי חוץ',
      'לגו ובניה',
      'אמנות ויצירה',
      'משחקי וידאו',
    ],

    // ספרים וחומרי קריאה
    ListType.books: [
      'ספרות בדיונית',
      'ספרי עיון',
      'ספרי ילדים',
      'קומיקס ומנגה',
      'מגזינים',
      'ספרי לימוד',
      'ספרי בישול',
      'ספרי השראה',
    ],

    // ציוד ספורט וכושר
    ListType.sports: [
      'ביגוד ספורט',
      'נעלי ספורט',
      'כדורים',
      'משקולות וציוד כוח',
      'מזרני יוגה',
      'אביזרי ריצה',
      'ציוד שחייה',
      'תוספי תזונה',
    ],

    // עיצוב הבית וריהוט
    ListType.homeDecor: [
      'ריהוט',
      'תמונות ומסגרות',
      'כריות ושטיחים',
      'וילונות',
      'תאורה',
      'אביזרי מטבח',
      'צמחי נוי',
      'נרות וריחות',
    ],

    // רכב ואביזרים
    ListType.automotive: [
      'שמן מנוע',
      'נוזל שמשות',
      'מסנן אוויר',
      'מטאטא לרכב',
      'מוצרי ניקוי רכב',
      'אביזרי נוחות',
      'כיסוי הגה',
      'מטען לרכב',
    ],

    // תינוקות (מורחב מעבר ל-pharmacy)
    ListType.baby: [
      'חיתולים',
      'מגבונים',
      'מזון תינוקות',
      'בקבוקים ומוצצים',
      'מוצרי רחצה',
      'ביגוד תינוקות',
      'מוצרי בטיחות',
      'צעצועי התפתחות',
    ],

    // מתנות (כללי)
    ListType.gifts: [
      'מתנות לגברים',
      'מתנות לנשים',
      'מתנות לילדים',
      'מתנות לבית',
      'שוברי מתנה',
      'ניירות עטיפה',
      'כרטיסי ברכה',
      'סלסלות מתנה',
    ],

    // יום הולדת (base + specific)
    ListType.birthday: [
      ..._baseEventCategories,
      'עוגת יום הולדת',
      'נרות ליום הולדת',
      'בלונים',
      'כובעי מסיבה',
      'מתנות',
      'שקיות הפתעה',
      'משחקים למסיבה',
    ],

    // מסיבה (base + specific)
    ListType.party: [
      ..._baseEventCategories,
      'מוזיקה',
      'אלכוהול',
      'מזון למסיבה',
      'פופקורן וחטיפים',
      'משחקי חברה',
      'תחפושות',
      'תאורה מיוחדת',
    ],

    // חתונה (base + specific)
    ListType.wedding: [
      ..._baseEventCategories,
      'פרחים',
      'הזמנות',
      'מתנות לאורחים',
      'אלכוהול',
      'עיטורי שולחן',
      'חופה',
      'תפריט',
      'צילום ווידאו',
    ],

    // פיקניק (base + specific)
    ListType.picnic: [
      'כריכים',
      'סלטים',
      'פירות',
      'משקאות קרים',
      'שמיכת פיקניק',
      'צידנית',
      'כלים חד-פעמיים',
      'משחקי חוץ',
      'דוחה יתושים',
    ],

    // חג (base + specific)
    ListType.holiday: [
      ..._baseEventCategories,
      'מאכלי החג',
      'יין וקידוש',
      'נרות',
      'צלחות מיוחדות',
      'ספרי תפילה',
      'מתנות לאורחים',
      'עיטורי חג',
    ],

    // אחר - כללי
    ListType.other: [
      'כללי',
    ],
  };

  // ========================================
  // מיפוי Type → חנויות/מותגים
  // ========================================

  /// מחזיר רשימת חנויות/מותגים מומלצים לסוג הרשימה
  /// 
  /// אם [type] לא קיים או אין חנויות מוצעות, מחזיר רשימה ריקה
  static List<String> getStoresForType(String type) {
    final stores = _typeToStores[type] ?? [];
    debugPrint('🏪 ListTypeMappings.getStoresForType($type) → ${stores.length} stores');
    return stores;
  }

  static const Map<String, List<String>> _typeToStores = {
    ListType.super_: [
      'שופרסל',
      'רמי לוי',
      'יוחננוף',
      'ויקטורי',
      'טיב טעם',
      'אושר עד',
      'סופר פארם',
      'שוק מחנה יהודה',
    ],

    ListType.pharmacy: [
      'סופר-פארם',
      'ניו-פארם',
      'BE',
      'לייף',
      'אסתי לאודר',
      'MAC',
    ],

    ListType.hardware: [
      'איס הרדוור',
      'בנק הכלים',
      'טוטל סנטר',
      'מאסטרפיקס',
      'דקסטר',
    ],

    ListType.clothing: [
      'קסטרו',
      'פוקס',
      'גולף',
      'H&M',
      'זארה',
      'מנגו',
      'רנואר',
      'טרמינל X',
      'נייקי',
      'אדידס',
    ],

    ListType.electronics: [
      'KSP',
      'יוניון',
      'בי אנד אייץ\'',
      'אלקטרה',
      'מחסני חשמל',
      'פוני',
      'באג',
      'iDigital',
    ],

    ListType.pets: [
      'פטקס',
      'זוטוב',
      'פט פלאנט',
      'פט שופ',
      'פטזון',
    ],

    ListType.cosmetics: [
      'סופר-פארם',
      'ליליאן',
      'M.A.C',
      'סקורה',
      'המשביר לצרכן',
    ],

    ListType.stationery: [
      'סטימצקי',
      'אופיס דיפו',
      'פנטסטיק',
      'מנור',
    ],

    ListType.toys: [
      'יוחאנן',
      'צעצועים "ר" אס',
      'המשביר לצרכן',
      'טויז "ר" אס',
    ],

    ListType.books: [
      'סטימצקי',
      'צומת ספרים',
      'בוק אוף ליין',
      'אמזון',
    ],

    ListType.sports: [
      'ספורט 5',
      'דקתלון',
      'טרמינל X',
      'משקולות בנימין',
      'פולס',
    ],

    ListType.homeDecor: [
      'איקיאה',
      'המשביר לצרכן',
      'טרמינל X',
      'רוזנפלד',
    ],

    ListType.automotive: [
      'יוניון',
      'דלק',
      'פז',
      'איס הרדוור',
    ],

    ListType.baby: [
      'יוחאנן',
      'המשביר לצרכן',
      'סופר-פארם',
      'ביבילוב',
    ],

    ListType.gifts: [
      'סטימצקי',
      'המשביר לצרכן',
      'איקיאה',
      'טרמינל X',
    ],

    ListType.birthday: [],
    ListType.party: [],
    ListType.wedding: [],
    ListType.picnic: [],
    ListType.holiday: [],

    ListType.other: [],
  };

  // ========================================
  // פריטים מוצעים לפי Type
  // ========================================

  /// מחזיר רשימת פריטים כלליים מוצעים לסוג הרשימה
  /// 
  /// (לא מוצרים ספציפיים, אלא רעיונות כלליים)
  /// אם [type] לא קיים או אין פריטים מוצעים, מחזיר רשימה ריקה
  static List<String> getSuggestedItemsForType(String type) {
    final items = _typeToSuggestedItems[type] ?? [];
    debugPrint('🛒 ListTypeMappings.getSuggestedItemsForType($type) → ${items.length} items');
    return items;
  }

  static const Map<String, List<String>> _typeToSuggestedItems = {
    ListType.super_: [
      'חלב',
      'לחם',
      'ביצים',
      'עגבניות',
      'מלפפונים',
      'בננות',
      'תפוחים',
      'עוף',
      'בקר',
      'אורז',
      'פסטה',
      'שמן',
      'סוכר',
      'קמח',
      'שוקולד',
      'משקה',
    ],

    ListType.pharmacy: [
      'תרופת כאב',
      'ויטמין D',
      'ויטמין C',
      'משחת שיניים',
      'מברשת שיניים',
      'שמפו',
      'מרכך',
      'סבון',
      'קרם לחות',
      'חיתולים',
      'מגבונים',
    ],

    ListType.hardware: [
      'פטיש',
      'מברגים',
      'ברגים',
      'מסמרים',
      'צבע לבן',
      'מברשות',
      'דבק',
      'מטר',
      'מקדחה',
      'נורות',
    ],

    ListType.clothing: [
      'חולצה לבנה',
      'חולצת טי',
      'ג\'ינס',
      'נעליים שחורות',
      'גרביים',
      'תחתונים',
      'שמלה',
      'מעיל',
      'צעיף',
      'כובע',
    ],

    ListType.electronics: [
      'אוזניות',
      'כבל USB',
      'מטען',
      'עכבר',
      'מקלדת',
      'זיכרון נייד',
      'כיסוי לטלפון',
      'מגן מסך',
    ],

    ListType.pets: [
      'מזון יבש לכלב',
      'מזון יבש לחתול',
      'חטיפים',
      'צעצוע',
      'קולר',
      'רצועה',
      'קערה',
      'חול לחתול',
    ],

    ListType.cosmetics: [
      'שפתון',
      'מסקרה',
      'בושם',
      'קרם לחות',
      'סרום',
      'מייק אפ',
      'מסיר איפור',
      'לק',
    ],

    ListType.stationery: [
      'עטים',
      'מחברת',
      'פנקס',
      'דבק',
      'מחק',
      'מחדד',
      'סרגל',
      'מדבקות',
      'מדגשים',
    ],

    ListType.toys: [
      'לגו',
      'בובה',
      'מכונית שלט',
      'משחק קופסה',
      'פאזל',
      'כדור',
      'צבעים',
      'צעצוע מוזיקלי',
    ],

    ListType.books: [
      'ספר בדיונית',
      'ספר בישול',
      'ספר ילדים',
      'מגזין',
      'קומיקס',
      'ספר עיון',
      'ספר השראה',
    ],

    ListType.sports: [
      'נעלי ריצה',
      'מזרן יוגה',
      'בקבוק מים',
      'משקולות',
      'חבל קפיצה',
      'חולצת ספורט',
      'כדור',
      'פרוטאין',
    ],

    ListType.homeDecor: [
      'כרית',
      'שטיח',
      'תמונה',
      'מסגרת',
      'נר',
      'אגרטל',
      'צמח נוי',
      'וילון',
    ],

    ListType.automotive: [
      'שמן מנוע',
      'נוזל שמשות',
      'מסנן',
      'מטאטא',
      'מטען',
      'כיסוי הגה',
      'מסיר קרח',
    ],

    ListType.baby: [
      'חיתולים',
      'מגבונים',
      'תחליב תינוקות',
      'בקבוק',
      'מוצץ',
      'קרם לעכוז',
      'שמפו לתינוקות',
      'צעצוע לתינוק',
    ],

    ListType.gifts: [
      'שובר מתנה',
      'נייר עטיפה',
      'כרטיס ברכה',
      'סל מתנה',
      'סרט',
      'שוקולדים',
      'בקבוק יין',
    ],

    ListType.birthday: [
      'עוגה',
      'נרות',
      'בלונים',
      'צלחות חד-פעמיות',
      'מתנות',
      'משקאות',
      'חטיפים',
      'שקיות הפתעה',
    ],

    ListType.party: [
      'משקאות',
      'אלכוהול',
      'חטיפים',
      'פופקורן',
      'קישוטים',
      'מפיות',
      'כלים חד-פעמיים',
      'מוזיקה',
    ],

    ListType.wedding: [
      'פרחים',
      'הזמנות',
      'מתנות לאורחים',
      'אלכוהול',
      'קישוטי שולחן',
      'כלי הגשה',
      'מפות',
      'עיטורים',
    ],

    ListType.picnic: [
      'כריכים',
      'סלטים',
      'פירות',
      'מים',
      'מיץ',
      'שמיכה',
      'צידנית',
      'כדור',
    ],

    ListType.holiday: [
      'יין',
      'חלה',
      'נרות',
      'מאכלי החג',
      'צלחות מיוחדות',
      'מתנות',
      'קישוטים',
    ],

    ListType.other: [],
  };

  // ========================================
  // Helper Methods
  // ========================================

  /// בדיקה אם קטגוריה רלוונטית לסוג רשימה
  /// 
  /// בודק התאמה חלקית (contains) בשני הכיוונים
  static bool isCategoryRelevantForType(String category, String type) {
    final relevantCategories = getCategoriesForType(type);
    final isRelevant = relevantCategories.any(
      (cat) => category.toLowerCase().contains(cat.toLowerCase()) ||
          cat.toLowerCase().contains(category.toLowerCase()),
    );
    
    debugPrint('🔍 ListTypeMappings.isCategoryRelevantForType("$category", $type) → $isRelevant');
    return isRelevant;
  }

  // Cache לשיפור ביצועים (נוצר פעם אחת בלבד)
  static List<String>? _cachedAllCategories;
  static List<String>? _cachedAllStores;

  /// קבלת כל הקטגוריות הייחודיות מכל הסוגים
  /// 
  /// משתמש ב-cache פנימי - נוצר פעם אחת בלבד
  static List<String> getAllCategories() {
    if (_cachedAllCategories != null) {
      debugPrint('📦 ListTypeMappings.getAllCategories() → ${_cachedAllCategories!.length} categories (cached)');
      return _cachedAllCategories!;
    }
    
    final allCategories = <String>{};
    for (final categories in _typeToCategories.values) {
      allCategories.addAll(categories);
    }
    
    _cachedAllCategories = allCategories.toList()..sort();
    debugPrint('📦 ListTypeMappings.getAllCategories() → ${_cachedAllCategories!.length} categories (created cache)');
    return _cachedAllCategories!;
  }

  /// קבלת כל החנויות הייחודיות מכל הסוגים
  /// 
  /// משתמש ב-cache פנימי - נוצר פעם אחת בלבד
  static List<String> getAllStores() {
    if (_cachedAllStores != null) {
      debugPrint('🏬 ListTypeMappings.getAllStores() → ${_cachedAllStores!.length} stores (cached)');
      return _cachedAllStores!;
    }
    
    final allStores = <String>{};
    for (final stores in _typeToStores.values) {
      allStores.addAll(stores);
    }
    
    _cachedAllStores = allStores.toList()..sort();
    debugPrint('🏬 ListTypeMappings.getAllStores() → ${_cachedAllStores!.length} stores (created cache)');
    return _cachedAllStores!;
  }
  
  /// ניקוי Cache (לשימוש בטסטים או reload)
  /// 
  /// ⚠️ רק לשימוש פנימי - בדרך כלל אין צורך
  static void clearCache() {
    _cachedAllCategories = null;
    _cachedAllStores = null;
    debugPrint('🗑️ ListTypeMappings.clearCache() - Cache cleared (categories + stores)');
  }
}
