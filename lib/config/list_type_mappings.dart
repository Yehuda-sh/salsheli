// 📄 File: lib/config/list_type_mappings.dart
//
// Purpose: מיפוי בין סוגי רשימות קניות לקטגוריות וחנויות רלוונטיות
//
// Features:
// - מיפוי type → קטגוריות מוצרים (const maps)
// - מיפוי type → חנויות/מותגים מומלצים
// - פריטים כלליים לכל סוג רשימה
// - תמיכה בכל 9 סוגי הרשימות
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
// Version: 2.0
// Last Updated: 06/10/2025

import 'package:flutter/foundation.dart';
import '../core/constants.dart';

class ListTypeMappings {
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
