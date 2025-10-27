// 📄 File: lib/services/list_type_filter_service.dart
//
// 🎯 Purpose: פילטור מוצרים לפי סוג רשימה
//
// Features:
// - מסנן מוצרים מ-API שופרסל לפי סוג החנות
// - מחזיר רק מוצרים רלוונטיים לכל סוג רשימה
// - תומך בהוספת מוצרים ידניים לכל סוג
//
// Version: 1.0
// Created: 27/10/2025

/// סוגי רשימות מורחבים
enum ExtendedListType {
  supermarket,    // סופרמרקט - כל המוצרים
  pharmacy,       // בית מרקחת - היגיינה וניקיון
  greengrocer,    // ירקן - ירקות ופירות
  butcher,        // אטליז - בשר ועוף
  bakery,         // מאפייה - לחמים ומאפים
  market,         // שוק - מוצרים מעורבים
  household,      // כלי בית - מוצרים שלא במאגר
}

class ListTypeFilterService {
  
  /// קטגוריות מותרות לכל סוג רשימה
  static final Map<ExtendedListType, List<String>> _allowedCategories = {
    ExtendedListType.supermarket: [
      // כל הקטגוריות - ללא סינון
    ],
    
    ExtendedListType.pharmacy: [
      'היגיינה אישית',
      'מוצרי ניקיון',
      'משחת שיניים',
      'שמפו',
      'סבון',
      'תחבושות',
      'תרופות ללא מרשם',
    ],
    
    ExtendedListType.greengrocer: [
      'ירקות',
      'פירות',
      'עשבי תיבול',
    ],
    
    ExtendedListType.butcher: [
      'בשר ודגים',
      'עוף',
      'דגים',
      'תבלינים ואפייה', // רק תבלינים לבשר
    ],
    
    ExtendedListType.bakery: [
      'מאפים',
      'לחמים',
      'עוגות',
      'קינוחים',
    ],
    
    ExtendedListType.market: [
      'ירקות',
      'פירות',
      'בשר ודגים',
      'גבינות',
      'זיתים',
      'מעדנים',
    ],
    
    ExtendedListType.household: [
      // מוצרים מותאמים אישית - לא מה-API
    ],
  };

  /// מסנן רשימת מוצרים לפי סוג הרשימה
  static List<Map<String, dynamic>> filterProductsByListType(
    List<Map<String, dynamic>> allProducts,
    ExtendedListType listType,
  ) {
    // סופרמרקט - החזר הכל
    if (listType == ExtendedListType.supermarket) {
      return allProducts;
    }

    // כלי בית - החזר רשימה ריקה (רק מוצרים ידניים)
    if (listType == ExtendedListType.household) {
      return [];
    }

    // סנן לפי קטגוריות מותרות
    final allowedCategories = _allowedCategories[listType] ?? [];
    if (allowedCategories.isEmpty) {
      return allProducts;
    }

    return allProducts.where((product) {
      final category = product['category'] as String?;
      if (category == null) return false;
      
      // בדוק אם הקטגוריה ברשימת המותרים
      return allowedCategories.contains(category);
    }).toList();
  }

  /// מחזיר רשימת מוצרים מומלצים לסוג רשימה (ללא API)
  static List<Map<String, dynamic>> getSuggestedProducts(ExtendedListType listType) {
    switch (listType) {
      case ExtendedListType.greengrocer:
        return [
          {'name': 'עגבניות', 'unit': 'ק"ג', 'icon': '🍅'},
          {'name': 'מלפפונים', 'unit': 'יח\'', 'icon': '🥒'},
          {'name': 'בצל', 'unit': 'ק"ג', 'icon': '🧅'},
          {'name': 'תפוחים', 'unit': 'ק"ג', 'icon': '🍎'},
          {'name': 'בננות', 'unit': 'ק"ג', 'icon': '🍌'},
          {'name': 'תפוזים', 'unit': 'ק"ג', 'icon': '🍊'},
          {'name': 'גזר', 'unit': 'ק"ג', 'icon': '🥕'},
          {'name': 'פלפל', 'unit': 'יח\'', 'icon': '🫑'},
          {'name': 'חסה', 'unit': 'יח\'', 'icon': '🥬'},
          {'name': 'פטרוזיליה', 'unit': 'חבילה', 'icon': '🌿'},
        ];
        
      case ExtendedListType.butcher:
        return [
          {'name': 'חזה עוף', 'unit': 'ק"ג', 'icon': '🍗'},
          {'name': 'כרעיים עוף', 'unit': 'ק"ג', 'icon': '🍗'},
          {'name': 'בשר טחון', 'unit': 'ק"ג', 'icon': '🥩'},
          {'name': 'סטייק אנטריקוט', 'unit': 'ק"ג', 'icon': '🥩'},
          {'name': 'צלעות טלה', 'unit': 'ק"ג', 'icon': '🥩'},
          {'name': 'דג סלמון', 'unit': 'ק"ג', 'icon': '🐟'},
          {'name': 'דג דניס', 'unit': 'ק"ג', 'icon': '🐟'},
          {'name': 'קבב', 'unit': 'ק"ג', 'icon': '🥩'},
        ];
        
      case ExtendedListType.bakery:
        return [
          {'name': 'לחם אחיד', 'unit': 'יח\'', 'icon': '🍞'},
          {'name': 'חלה', 'unit': 'יח\'', 'icon': '🥖'},
          {'name': 'פיתה', 'unit': 'חבילה', 'icon': '🫓'},
          {'name': 'בגט', 'unit': 'יח\'', 'icon': '🥖'},
          {'name': 'עוגת שמרים', 'unit': 'יח\'', 'icon': '🍰'},
          {'name': 'קרואסון', 'unit': 'יח\'', 'icon': '🥐'},
          {'name': 'בורקס', 'unit': 'יח\'', 'icon': '🥟'},
        ];
        
      case ExtendedListType.household:
        return [
          {'name': 'סכו"ם חד פעמי', 'unit': 'חבילה', 'icon': '🍴'},
          {'name': 'צלחות חד פעמיות', 'unit': 'חבילה', 'icon': '🍽️'},
          {'name': 'כוסות חד פעמיות', 'unit': 'חבילה', 'icon': '🥤'},
          {'name': 'נייר אפייה', 'unit': 'יח\'', 'icon': '📄'},
          {'name': 'ניילון נצמד', 'unit': 'יח\'', 'icon': '🎬'},
          {'name': 'שקיות אשפה', 'unit': 'חבילה', 'icon': '🗑️'},
          {'name': 'נרות', 'unit': 'חבילה', 'icon': '🕯️'},
          {'name': 'גפרורים', 'unit': 'חבילה', 'icon': '🔥'},
          {'name': 'סוללות', 'unit': 'חבילה', 'icon': '🔋'},
        ];
        
      default:
        return [];
    }
  }
  
  /// מחזיר אייקון לסוג רשימה
  static String getListTypeIcon(ExtendedListType type) {
    switch (type) {
      case ExtendedListType.supermarket:
        return '🛒';
      case ExtendedListType.pharmacy:
        return '🏥';
      case ExtendedListType.greengrocer:
        return '🥬';
      case ExtendedListType.butcher:
        return '🥩';
      case ExtendedListType.bakery:
        return '🍞';
      case ExtendedListType.market:
        return '🏪';
      case ExtendedListType.household:
        return '🏠';
    }
  }
  
  /// מחזיר שם לסוג רשימה בעברית
  static String getListTypeNameHebrew(ExtendedListType type) {
    switch (type) {
      case ExtendedListType.supermarket:
        return 'סופרמרקט';
      case ExtendedListType.pharmacy:
        return 'בית מרקחת';
      case ExtendedListType.greengrocer:
        return 'ירקן';
      case ExtendedListType.butcher:
        return 'אטליז';
      case ExtendedListType.bakery:
        return 'מאפייה';
      case ExtendedListType.market:
        return 'שוק';
      case ExtendedListType.household:
        return 'כלי בית';
    }
  }

  /// ממיר מ-string (מה-DB) ל-enum
  static ExtendedListType fromString(String type) {
    switch (type) {
      case 'super':
      case 'supermarket':
        return ExtendedListType.supermarket;
      case 'pharmacy':
        return ExtendedListType.pharmacy;
      case 'greengrocer':
        return ExtendedListType.greengrocer;
      case 'butcher':
        return ExtendedListType.butcher;
      case 'bakery':
        return ExtendedListType.bakery;
      case 'market':
        return ExtendedListType.market;
      case 'household':
        return ExtendedListType.household;
      case 'other':
      default:
        return ExtendedListType.market;
    }
  }

  /// ממיר מ-enum ל-string (ל-DB)
  static String toString(ExtendedListType type) {
    switch (type) {
      case ExtendedListType.supermarket:
        return 'supermarket';
      case ExtendedListType.pharmacy:
        return 'pharmacy';
      case ExtendedListType.greengrocer:
        return 'greengrocer';
      case ExtendedListType.butcher:
        return 'butcher';
      case ExtendedListType.bakery:
        return 'bakery';
      case ExtendedListType.market:
        return 'market';
      case ExtendedListType.household:
        return 'household';
    }
  }
}
