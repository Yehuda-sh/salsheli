// 📄 File: lib/services/category_detection_service.dart
//
// 🤖 שירות זיהוי אוטומטי של קטגוריות מוצרים
//     - זיהוי לפי שם המוצר
//     - זיהוי לפי מותג
//     - פתרון לבעיות סיווג שגוי ב-JSON
//
// 🇬🇧 Automatic product category detection service
//     - Detection by product name
//     - Detection by brand
//     - Fallback for miscategorized products in JSON

import 'package:flutter/foundation.dart';

/// 🤖 שירות זיהוי אוטומטי של קטגוריות
class CategoryDetectionService {
  /// מיפוי מותגים לקטגוריות
  static const Map<String, String> _brandToCategory = {
    // מוצרי חלב
    'שטראוס': 'מוצרי חלב',
    'תנובה': 'מוצרי חלב',
    'יטבתה': 'מוצרי חלב',
    'גד': 'מוצרי חלב',
    'דנון': 'מוצרי חלב',
    'מילקי': 'מוצרי חלב',
    'קוטג\'': 'מוצרי חלב',

    // מאפים
    'אנג\'ל': 'מאפים',
    'ברמן': 'מאפים',
    'שניצר': 'לחמים',
    'פרג': 'מאפים',

    // בשר
    'טיב טעם': 'בשר ודגים',
    'זוגלובק': 'בשר ודגים',
    'עוף העמק': 'בשר ודגים',

    // ניקיון
    'סנו': 'מוצרי ניקיון',
    'קלין': 'מוצרי ניקיון',
    'ביו': 'מוצרי ניקיון',
  };

  /// מילות מפתח לזיהוי קטגוריות
  static const Map<String, List<String>> _categoryKeywords = {
    'מוצרי חלב': [
      'חלב',
      'גבינה',
      'יוגורט',
      'קוטג',
      'שמנת',
      'חמאה',
      'דנונה',
      'גמדים',
      'מילקי',
      'ביו',
      'פרו',
      'לבן',
      'בולגרי',
      'גבינת',
      'שמנ',
    ],
    'פירות': [
      'תפוח',
      'בנ',
      'אבטיח',
      'תות',
      'ענב',
      'אפרסק',
      'שזיף',
      'אגס',
      'תמר',
      'קיוי',
      'מנגו',
      'פטל',
      'דובדבן',
    ],
    'ירקות': [
      'עגבני',
      'מלפפון',
      'חסה',
      'כרוב',
      'גזר',
      'בצל',
      'שום',
      'פלפל',
      'דלעת',
      'תפוח אדמה',
      'בטטה',
      'קישוא',
    ],
    'בשר ודגים': [
      'בשר',
      'עוף',
      'הודו',
      'כבש',
      'בקר',
      'דג',
      'סלמון',
      'טונה',
      'נקניק',
      'נקנק',
      'המבורגר',
      'קבב',
      'שניצל',
    ],
    'מאפים': [
      'לחם',
      'חלה',
      'פיתה',
      'בגט',
      'כיכר',
      'עוגה',
      'עוגיות',
      'קרואסון',
      'דונאט',
      'מאפה',
      'בורקס',
      'ביס',
    ],
    'מוצרי ניקיון': [
      'ניקוי',
      'סבון',
      'אקונומיקה',
      'מרכך',
      'כביסה',
      'כלים',
      'אסלות',
      'רצפות',
      'חלון',
      'אבקת',
      'ג\'ל',
      'נוזל כלים',
    ],
    'היגיינה אישית': [
      'שמפו',
      'סבון גוף',
      'דאודורנט',
      'משחת שיניים',
      'מברשת שיניים',
      'טישו',
      'נייר טואלט',
      'חיתולים',
      'מגבונים',
    ],
    'קפואים': [
      'קפוא',
      'גלידה',
      'פיצה קפואה',
      'ירקות קפואים',
      'שניצל קפוא',
    ],
    'שימורים': [
      'שימור',
      'קופסא',
      'שימורי',
      'טונה בקופסא',
      'תירס שימורי',
      'חומוס בקופסא',
    ],
  };

  /// זיהוי קטגוריה אוטומטי
  ///
  /// מחזיר את הקטגוריה המזוהה, או null אם לא הצליח לזהות
  static String? detectCategory({
    required String productName,
    String? brand,
    String? currentCategory,
  }) {
    if (kDebugMode) {
      debugPrint('🤖 CategoryDetection: מזהה קטגוריה עבור "$productName" (brand: $brand, current: $currentCategory)');
    }

    // אם יש קטגוריה קיימת ותקינה - השתמש בה
    if (currentCategory != null &&
        currentCategory != 'אחר' &&
        currentCategory.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('   ✅ משתמש בקטגוריה קיימת: $currentCategory');
      }
      return currentCategory;
    }

    final nameLower = productName.toLowerCase();

    // 1. נסה זיהוי לפי מותג
    if (brand != null && brand.isNotEmpty) {
      final brandLower = brand.toLowerCase();
      for (final entry in _brandToCategory.entries) {
        if (brandLower.contains(entry.key.toLowerCase())) {
          if (kDebugMode) {
            debugPrint('   ✅ זוהה לפי מותג: ${entry.value}');
          }
          return entry.value;
        }
      }
    }

    // 2. נסה זיהוי לפי מילות מפתח
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (nameLower.contains(keyword.toLowerCase())) {
          if (kDebugMode) {
            debugPrint('   ✅ זוהה לפי מילת מפתח "$keyword": ${entry.key}');
          }
          return entry.key;
        }
      }
    }

    // 3. לא הצליח לזהות
    if (kDebugMode) {
      debugPrint('   ❌ לא הצליח לזהות קטגוריה');
    }
    return currentCategory ?? 'אחר';
  }

  /// זיהוי קטגוריה ממוצר JSON
  static String detectFromProductJson(Map<String, dynamic> product) {
    return detectCategory(
      productName: product['name'] as String? ?? '',
      brand: product['brand'] as String?,
      currentCategory: product['category'] as String?,
    ) ?? 'אחר';
  }
}
