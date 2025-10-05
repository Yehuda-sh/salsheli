// 📄 File: lib/config/list_type_mappings.dart
//
// Purpose: מיפוי בין סוגי רשימות קניות לקטגוריות וחנויות רלוונטיות
//
// Features:
// - מיפוי type → קטגוריות מוצרים
// - מיפוי type → חנויות/מותגים מומלצים
// - פריטים כלליים לכל סוג רשימה
// - תמיכה בכל 9 סוגי הרשימות
//
// Usage:
// final categories = ListTypeMappings.getCategoriesForType('clothing');
// final stores = ListTypeMappings.getStoresForType('clothing');
// final items = ListTypeMappings.getSuggestedItemsForType('clothing');

import '../core/constants.dart';

class ListTypeMappings {
  // ========================================
  // מיפוי Type → קטגוריות
  // ========================================

  /// מחזיר קטגוריות רלוונטיות לסוג הרשימה
  static List<String> getCategoriesForType(String type) {
    return _typeToCategories[type] ?? _typeToCategories[ListType.other]!;
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

    // אחר - כללי
    ListType.other: [
      'כללי',
    ],
  };

  // ========================================
  // מיפוי Type → חנויות/מותגים
  // ========================================

  /// מחזיר רשימת חנויות/מותגים מומלצים לסוג הרשימה
  static List<String> getStoresForType(String type) {
    return _typeToStores[type] ?? [];
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

    ListType.other: [],
  };

  // ========================================
  // פריטים מוצעים לפי Type
  // ========================================

  /// מחזיר רשימת פריטים כלליים מוצעים לסוג הרשימה
  /// (לא מוצרים ספציפיים, אלא רעיונות כלליים)
  static List<String> getSuggestedItemsForType(String type) {
    return _typeToSuggestedItems[type] ?? [];
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

    ListType.other: [],
  };

  // ========================================
  // Helper Methods
  // ========================================

  /// בדיקה אם קטגוריה רלוונטית לסוג רשימה
  static bool isCategoryRelevantForType(String category, String type) {
    final relevantCategories = getCategoriesForType(type);
    return relevantCategories.any(
      (cat) => category.toLowerCase().contains(cat.toLowerCase()) ||
          cat.toLowerCase().contains(category.toLowerCase()),
    );
  }

  /// קבלת כל הקטגוריות הייחודיות מכל הסוגים
  static List<String> getAllCategories() {
    final allCategories = <String>{};
    for (final categories in _typeToCategories.values) {
      allCategories.addAll(categories);
    }
    return allCategories.toList()..sort();
  }

  /// קבלת כל החנויות הייחודיות מכל הסוגים
  static List<String> getAllStores() {
    final allStores = <String>{};
    for (final stores in _typeToStores.values) {
      allStores.addAll(stores);
    }
    return allStores.toList()..sort();
  }
}
