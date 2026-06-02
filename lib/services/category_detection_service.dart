// lib/services/category_detection_service.dart — Category detection — auto-categorize products by Hebrew name keywords

class CategoryDetectionService {
  /// מיפוי מותגים לקטגוריות
  static const Map<String, String> _brandToCategory = {
    // מוצרי חלב
    'שטראוס': 'מוצרי חלב',
    'תנובה': 'מוצרי חלב',
    'יטבתה': 'מוצרי חלב',
    'טרה': 'מוצרי חלב',
    'גד': 'מוצרי חלב',
    'דנון': 'מוצרי חלב',
    // מאפים
    'אנג\'ל': 'מאפים',
    'ברמן': 'מאפים',
    'פרג': 'מאפים',
    // בשר
    'זוגלובק': 'בשר ודגים',
    'עוף העמק': 'בשר ודגים',
    // ניקיון
    'סנו': 'מוצרי ניקיון',
    // משקאות
    'טמפו': 'משקאות',
    'יפאורה תבורי': 'משקאות',
    // חטיפים
    'אסם': 'חטיפים',
    'עלית': 'חטיפים',
    'כרמית': 'חטיפים',
  };

  /// מילות מפתח לזיהוי קטגוריות
  /// הסדר חשוב — ביטויים ארוכים/ספציפיים קודם כדי למנוע false positives
  static const Map<String, List<String>> _categoryKeywords = {
    'מוצרי חלב': [
      'חלב טרי', 'חלב ',
      'גבינה', 'גבינת',
      'יוגורט',
      'קוטג\'',
      'שמנת',
      'חמאה',
      'דנונה', 'גמדים', 'מילקי',
      'בולגרי',
    ],
    'פירות': [
      'תפוח עץ',
      'בננ',
      'אבטיח',
      'תות שדה',
      'ענבים',
      'אפרסק',
      'שזיף',
      'אגס ',
      'תמר',
      'קיווי',
      'מנגו',
      'דובדבן',
      'אבוקדו',
      'תפוז',
    ],
    'ירקות': [
      'תפוח אדמה',
      'עגבני',
      'מלפפון',
      'חסה',
      'כרוב',
      'גזר',
      'בצל',
      'שום ',
      'פלפל',
      'דלעת',
      'בטטה',
      'קישוא',
      'ברוקולי',
      'כרובית',
      'מנגולד',
    ],
    'בשר ודגים': [
      'חזה עוף', 'שניצל עוף', 'כרעיים',
      'אנטריקוט', 'בשר טחון', 'בשר בקר',
      'סלמון', 'פילה דג',
      'נקניק', 'נקניקיות',
      'המבורגר',
      'קבב',
    ],
    'מאפים': [
      'לחם ',
      'חלה ',
      'פיתה',
      'באגט',
      'עוגה',
      'עוגיות',
      'קרואסון',
      'דונאט',
      'מאפה',
      'בורקס',
    ],
    'מוצרי ניקיון': [
      'נוזל כלים',
      'אבקת כביסה', 'מרכך כביסה', 'ג\'ל כביסה',
      'אקונומיקה',
      'נייר טואלט',
      'שקיות אשפה',
    ],
    'היגיינה אישית': [
      'שמפו',
      'דאודורנט',
      'משחת שיניים',
      'מברשת שיניים',
      'מגבונים',
    ],
    'משקאות': [
      'מיץ ',
      'מים מינרל',
      'קולה',
      'בירה',
      'יין ',
      'סודה',
    ],
    'חטיפים': [
      'במבה',
      'ביסלי',
      'צ\'יפס',
      'שוקולד',
      'חטיף',
    ],
    'קפה ותה': [
      'קפה',
      'נס קפה',
      'תה ',
    ],
    'קפואים': [
      'קפוא',
      'מוקפא',
      'גלידה',
    ],
    'שימורים': [
      'טונה בשמן', 'טונה ב',
      'שימורי',
      'תירס מתוק',
      'זיתים',
    ],
  };

  /// מילות-המפתח משוטחות וממוינות לפי אורך יורד — כך מילה ספציפית
  /// ("עגבניה", "שוקולד") מנצחת substring כללי קצר ("תמר", "קפה").
  static final List<MapEntry<String, String>> _sortedKeywords = () {
    final list = <MapEntry<String, String>>[];
    _categoryKeywords.forEach((category, keywords) {
      for (final kw in keywords) {
        list.add(MapEntry(kw.toLowerCase(), category));
      }
    });
    list.sort((a, b) => b.key.length.compareTo(a.key.length));
    return list;
  }();

  /// קטגוריות שבהן שם-מוצר עלול להיות רק "טעם" ולא הקטגוריה עצמה.
  // 🔧 לא כולל 'קפה ותה': longest-match-first כבר מטפל ב"שוקולד בטעם קפה"
  // (שוקולד > קפה), והכללתו פסלה בטעות "קפה בטעם וניל" → 'אחר'.
  static const Set<String> _flavorableCategories = {
    'פירות',
    'ירקות',
  };

  /// סימני "מוצר מעובד / בטעם" — נוכחותם פוסלת התאמת פרי/ירק/קפה,
  /// כדי ש"מיץ תפוז" יהיה משקה ו"מעדן בננה" לא יהיה פרי.
  static const List<String> _flavorSignals = [
    'מיץ',
    'בטעם',
    'מעדן',
    'יופלה',
    'משקה',
    'מילקי',
    'שוקו',
    'סוכרי',
    'ריבת',
    'ממרח',
  ];

  /// זיהוי קטגוריה ממוצר JSON
  static String detectFromProductJson(Map<String, dynamic> product) {
    return _detectCategory(
      productName: product['name'] as String? ?? '',
      brand: product['brand'] as String?,
      currentCategory: product['category'] as String?,
    );
  }

  /// זיהוי קטגוריה אוטומטי
  static String _detectCategory({
    required String productName,
    String? brand,
    String? currentCategory,
  }) {
    // אם יש קטגוריה קיימת ותקינה - השתמש בה
    if (currentCategory != null &&
        currentCategory != 'אחר' &&
        currentCategory.isNotEmpty) {
      return currentCategory;
    }

    final nameLower = productName.toLowerCase();

    // 1. זיהוי לפי מותג
    if (brand != null && brand.isNotEmpty) {
      final brandLower = brand.toLowerCase();
      for (final entry in _brandToCategory.entries) {
        if (brandLower.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }

    // 2. זיהוי לפי מילות מפתח — הארוך-ביותר-קודם, כדי ששם ספציפי
    //    ינצח substring כללי ("עגבניה" מנצח "תמר", "שוקולד" מנצח "קפה").
    final hasFlavorSignal = _flavorSignals.any(nameLower.contains);
    for (final entry in _sortedKeywords) {
      if (!nameLower.contains(entry.key)) continue;
      // שם פרי/ירק/קפה בתוך מוצר מעובד הוא טעם, לא הקטגוריה האמיתית
      // ("מיץ תפוז" → משקה, "מעדן בננה" → מחלבה). דלג ותן למילה ספציפית יותר.
      if (hasFlavorSignal && _flavorableCategories.contains(entry.value)) {
        continue;
      }
      return entry.value;
    }

    return currentCategory ?? 'אחר';
  }
}
