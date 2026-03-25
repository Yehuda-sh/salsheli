// 📄 File: lib/services/template_service.dart
//
// 🎯 מטרה: שירות לטעינת תבניות רשימות קניות מוכנות
//
// 📝 תהליך:
// 1. טעינת קבצי מוצרים מ-list_types/ (פעם אחת)
// 2. טעינת תבניות מ-templates/
// 3. חיפוש מוצרים אמיתיים לפי searchTerm
// 4. המרה ל-UnifiedListItem עם מחירים ופרטים מלאים
//
// 💡 יתרונות:
// - מוצרים עם מחירים אמיתיים (לא גנריים)
// - אין כפילויות - כל מוצר מהמקור שלו
// - אפשר למקס מוצרים מחנויות שונות
//
// Version: 2.0 - Fixed busy-wait, safe casting, kDebugMode
// Last Updated: 13/01/2026

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_item.dart';
import '../models/unified_list_item.dart';

/// מידע על תבנית זמינה
class TemplateInfo {
  final String id;
  final String name;
  final String templateFile;
  final String icon;
  final String? description;

  TemplateInfo({
    required this.id,
    required this.name,
    required this.templateFile,
    required this.icon,
    this.description,
  });

  @override
  String toString() => 'TemplateInfo($name, file: $templateFile)';
}

/// שירות לטעינת תבניות
class TemplateService {
  // מטמון של מוצרים - נטען פעם אחת בלבד
  static Map<String, List<Map<String, dynamic>>>? _productsCache;

  // ✅ FIX #1: Completer pattern במקום busy-wait loop
  static Completer<void>? _loadingCompleter;

  /// טוען את כל קבצי המוצרים לזיכרון (lazy loading)
  static Future<void> _loadProductsIfNeeded() async {
    // כבר נטען
    if (_productsCache != null) {
      if (kDebugMode) debugPrint('✅ [TemplateService] מוצרים כבר נטענו מהמטמון');
      return;
    }

    // טעינה בתהליך - await על אותו Future (לא busy-wait!)
    if (_loadingCompleter != null) {
      if (kDebugMode) debugPrint('⏳ [TemplateService] טעינה כבר בתהליך, ממתין...');
      await _loadingCompleter!.future;
      return;
    }

    // מתחילים טעינה חדשה
    _loadingCompleter = Completer<void>();
    if (kDebugMode) debugPrint('🔄 [TemplateService] מתחיל לטעון מוצרים...');

    try {
      _productsCache = {};

      // רשימת כל החנויות
      const sources = [
        'supermarket',
        'bakery',
        'butcher',
        'greengrocer',
        'pharmacy',
        'market'
      ];

      for (final source in sources) {
        try {
          final String json = await rootBundle.loadString(
            'assets/data/list_types/$source.json',
          );
          // ✅ FIX #3: Safe casting עם whereType
          final decoded = jsonDecode(json);
          if (decoded is List) {
            _productsCache![source] = decoded
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
          } else {
            _productsCache![source] = [];
          }
        } catch (e) {
          if (kDebugMode) debugPrint('   ❌ שגיאה בטעינת $source: $e');
          _productsCache![source] = [];
        }
      }

      _loadingCompleter!.complete();
    } catch (e) {
      // שגיאה - נאפס את ה-completer כדי לאפשר ניסיון חוזר
      _productsCache = null;
      _loadingCompleter!.completeError(e);
      _loadingCompleter = null;
      rethrow;
    }
  }

  // ════════════════════════════════════════════
  // 🔧 Helper Methods
  // ════════════════════════════════════════════

  /// ✅ FIX #5: המרת מחיר בטוחה (כמו FlexDoubleConverter)
  /// תומך ב: num, String (עם פסיק או נקודה), null
  static double _parsePrice(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// ✅ FIX #4: קריאת שם מוצר בטוחה
  static String? _getProductName(Map<String, dynamic> product) {
    final name = product['name'];
    if (name is String && name.isNotEmpty) return name;
    return null;
  }

  /// מחפש מוצר לפי טקסט חיפוש
  ///
  /// החיפוש: case-insensitive, מחפש אם `searchTerm` מופיע בשם המוצר
  static Map<String, dynamic>? _findProduct(String source, String searchTerm) {
    final products = _productsCache?[source] ?? [];

    if (products.isEmpty) {
      if (kDebugMode) debugPrint('   ⚠️ אין מוצרים ב-$source');
      return null;
    }

    // חיפוש - מוצר שמכיל את המילה (case insensitive)
    final normalizedSearch = searchTerm.toLowerCase();

    // ✅ FIX #4: קריאה בטוחה של שם המוצר
    for (final product in products) {
      final name = _getProductName(product);
      if (name != null && name.toLowerCase().contains(normalizedSearch)) {
        if (kDebugMode) debugPrint('      ✅ נמצא: $name (ב-$source)');
        return product;
      }
    }

    if (kDebugMode) debugPrint('      ⚠️ לא נמצא "$searchTerm" ב-$source');
    return null;
  }

  /// טוען תבנית ממקור ויוצר רשימת פריטים
  ///
  /// תהליך:
  /// 1. טוען את קובץ התבנית
  /// 2. לכל item: מחפש מוצר אמיתי או יוצר fallback
  /// 3. מחזיר רשימת UnifiedListItem מוכנה
  static Future<List<UnifiedListItem>> loadTemplateItems(
      String templateFile) async {
    if (kDebugMode) debugPrint('📋 [TemplateService] טוען תבנית: $templateFile');

    // 1. ודא שהמוצרים נטענו
    await _loadProductsIfNeeded();

    // 2. קרא את קובץ התבנית
    final String json = await rootBundle.loadString(
      'assets/templates/$templateFile',
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    final templateName = data['templateName'] as String?;
    if (kDebugMode) debugPrint('   📝 שם תבנית: $templateName');

    final items = <UnifiedListItem>[];

    // 3. לכל item בתבנית
    final templateItems = data['items'];
    if (templateItems is! List) return items;

    for (final templateItem in templateItems) {
      if (templateItem is! Map) continue;

      final source = templateItem['source'] as String?;
      final searchTerm = templateItem['searchTerm'] as String?;
      final quantity = (templateItem['quantity'] as num?)?.toDouble() ?? 1.0;
      final unit = templateItem['unit'] as String? ?? 'יח׳';
      final fallbackName = templateItem['fallbackName'] as String? ?? searchTerm ?? 'פריט';

      if (source == null || searchTerm == null) continue;

      if (kDebugMode) debugPrint('   🔍 מחפש: "$searchTerm" ב-$source');

      // 4. חפש את המוצר האמיתי
      final product = _findProduct(source, searchTerm);

      // 5. צור UnifiedListItem
      if (product != null) {
        // מצאנו מוצר אמיתי! 🎉
        final productName = _getProductName(product) ?? fallbackName;
        final brand = product['brand'] as String?;

        items.add(UnifiedListItem.product(
          name: productName,
          quantity: quantity.toInt(),
          // ✅ FIX #5: שימוש ב-_parsePrice לתמיכה ב-String/num/null
          unitPrice: _parsePrice(product['price']),
          barcode: product['barcode'] as String?,
          unit: (product['unit'] as String?) ?? unit,
          // ✅ FIX #6: null במקום '' כשאין קטגוריה
          category: (product['category'] as String?)?.isNotEmpty == true
              ? product['category'] as String
              : null,
          // ✅ FIX #6: brand בלבד (בלי "מ-") - פחות hardcoded Hebrew
          notes: brand,
        ));
      } else {
        // לא מצאנו - צור פריט גנרי עם fallback
        items.add(UnifiedListItem.product(
          name: fallbackName,
          quantity: quantity.toInt(),
          unitPrice: 0.0,
          unit: unit,
        ));

        if (kDebugMode) debugPrint('      ⚠️ משתמש ב-fallback: $fallbackName');
      }
    }

    return items;
  }

  /// טוען את רשימת כל התבניות הזמינות
  static Future<List<TemplateInfo>> loadTemplatesList() async {
    if (kDebugMode) debugPrint('📚 [TemplateService] טוען רשימת תבניות...');

    final String json = await rootBundle.loadString(
      'assets/templates/list_templates.json',
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    final templates = <TemplateInfo>[];

    // תבניות ראשיות
    final categories = data['categories'];
    if (categories is List) {
      for (final category in categories) {
        if (category is Map && category['templateFile'] != null) {
          templates.add(TemplateInfo(
            id: category['id'] as String? ?? '',
            name: category['name'] as String? ?? '',
            templateFile: category['templateFile'] as String,
            icon: _getIconForCategory(category['id'] as String? ?? ''),
          ));
        }
      }
    }

    // תת-תבניות (אירועים)
    final subTemplates = data['subTemplates'];
    if (subTemplates is List) {
      for (final subTemplate in subTemplates) {
        if (subTemplate is! Map) continue;
        final subs = subTemplate['sub'];
        if (subs is! List) continue;
        for (final sub in subs) {
          if (sub is Map && sub['templateFile'] != null) {
            templates.add(TemplateInfo(
              id: sub['id'] as String? ?? '',
              name: sub['name'] as String? ?? '',
              templateFile: sub['templateFile'] as String,
              icon: _getIconForCategory(sub['id'] as String? ?? ''),
            ));
          }
        }
      }
    }

    if (kDebugMode) debugPrint('✅ [TemplateService] נמצאו ${templates.length} תבניות');
    return templates;
  }

  /// מחזיר אייקון לפי קטגוריית תבנית
  static String _getIconForCategory(String id) {
    switch (id) {
      case 'bbq':
        return '🔥';
      case 'shopping':
        return '🛒';
      case 'pantry':
        return '🏺';
      case 'friends':
        return '🎉';
      case 'birthday':
        return '🎂';
      default:
        return '📋';
    }
  }

  /// מחזיר סוג רשימה לפי ID תבנית
  ///
  /// משמש לקביעת הסוג האוטומטי כשבוחרים תבנית
  static String getListTypeForTemplate(String templateId) {
    switch (templateId) {
      case 'bbq':
      case 'birthday':
      case 'friends':
        return 'event';
      case 'shopping':
        return 'supermarket';
      case 'pantry':
        return 'household';
      default:
        return 'supermarket';
    }
  }

  /// האם התבנית היא של אירוע?
  static bool isEventTemplate(String templateId) {
    return ['bbq', 'birthday', 'friends'].contains(templateId);
  }

  /// מחזיר מצב אירוע ברירת מחדל לפי ID תבנית ונראות
  ///
  /// - תבנית אירוע + משותף (לא פרטי) → 'who_brings' (מי מביא מה)
  /// - תבנית אירוע + פרטי → 'tasks' (משימות אישיות)
  /// - תבנית רגילה → null (קנייה רגילה)
  static String? getEventModeForTemplate(String templateId, {required bool isPrivate}) {
    // רק תבניות אירוע מקבלות eventMode
    if (!isEventTemplate(templateId)) {
      return null;
    }

    // אירוע פרטי = משימות אישיות (צ'קליסט)
    // אירוע משותף = מי מביא מה
    return isPrivate ? 'tasks' : 'who_brings';
  }

  /// 🏺 טוען פריטי starter למזווה (Onboarding)
  ///
  /// מחזיר רשימת InventoryItem מוכנה להוספה למזווה
  /// משמש כאשר משתמש נכנס למזווה ריק ורוצה להתחיל עם מוצרי יסוד
  ///
  /// [defaultCategory] - קטגוריית ברירת מחדל (ניתן להעביר מבחוץ לתמיכה ב-i18n)
  /// [defaultLocation] - מיקום ברירת מחדל
  static Future<List<InventoryItem>> loadPantryStarterItems({
    String defaultCategory = 'מזווה',
    String defaultLocation = 'מזווה',
  }) async {
    if (kDebugMode) debugPrint('🏺 [TemplateService] טוען פריטי starter למזווה...');

    // 1. ודא שהמוצרים נטענו
    await _loadProductsIfNeeded();

    // 2. קרא את קובץ התבנית
    final String json = await rootBundle.loadString(
      'assets/templates/pantry_basic.json',
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    final items = <InventoryItem>[];
    const uuid = Uuid();

    // 3. לכל item בתבנית
    final templateItems = data['items'];
    if (templateItems is! List) return items;

    for (final templateItem in templateItems) {
      if (templateItem is! Map) continue;

      final source = templateItem['source'] as String?;
      final searchTerm = templateItem['searchTerm'] as String?;
      final quantity = (templateItem['quantity'] as num?)?.toInt() ?? 1;
      final unit = templateItem['unit'] as String? ?? 'יח׳';
      final fallbackName = templateItem['fallbackName'] as String? ?? searchTerm ?? 'פריט';

      if (source == null || searchTerm == null) continue;

      // 4. חפש את המוצר האמיתי
      final product = _findProduct(source, searchTerm);

      // 5. צור InventoryItem
      final productName = product != null
          ? (_getProductName(product) ?? fallbackName)
          : fallbackName;
      final category = (product?['category'] as String?)?.isNotEmpty == true
          ? product!['category'] as String
          : defaultCategory;

      items.add(InventoryItem(
        id: uuid.v4(),
        productName: productName,
        category: category,
        location: defaultLocation,
        quantity: quantity,
        unit: (product?['unit'] as String?) ?? unit,
        minQuantity: 1,
      ));
    }

    return items;
  }

  /// מנקה את המטמון (לדוגמה: אחרי עדכון מוצרים)
  static void clearCache() {
    _productsCache = null;
    _loadingCompleter = null; // ✅ Reset completer too
    if (kDebugMode) debugPrint('🗑️ [TemplateService] המטמון נוקה');
  }
}
