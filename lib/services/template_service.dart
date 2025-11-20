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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static bool _isLoading = false;

  /// טוען את כל קבצי המוצרים לזיכרון (lazy loading)
  static Future<void> _loadProductsIfNeeded() async {
    if (_productsCache != null) {
      debugPrint('✅ [TemplateService] מוצרים כבר נטענו מהמטמון');
      return;
    }

    if (_isLoading) {
      debugPrint('⏳ [TemplateService] טעינה כבר בתהליך, ממתין...');
      // ממתין שהטעינה תסתיים
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isLoading = true;
    debugPrint('🔄 [TemplateService] מתחיל לטעון מוצרים...');

    _productsCache = {};

    // רשימת כל החנויות
    final sources = [
      'supermarket',
      'bakery',
      'butcher',
      'greengrocer',
      'pharmacy',
      'market'
    ];

    for (var source in sources) {
      try {
        final String json = await rootBundle.loadString(
          'assets/data/list_types/$source.json',
        );
        _productsCache![source] = List<Map<String, dynamic>>.from(
          jsonDecode(json) as List,
        );
        debugPrint(
            '   ✅ נטען $source: ${_productsCache![source]!.length} מוצרים');
      } catch (e) {
        debugPrint('   ❌ שגיאה בטעינת $source: $e');
        _productsCache![source] = [];
      }
    }

    _isLoading = false;
    debugPrint(
        '✅ [TemplateService] סיים לטעון כל המוצרים (${_productsCache!.values.fold(0, (sum, list) => sum + list.length)} סה"כ)');
  }

  /// מחפש מוצר לפי טקסט חיפוש
  ///
  /// החיפוש: case-insensitive, מחפש אם `searchTerm` מופיע בשם המוצר
  static Map<String, dynamic>? findProduct(String source, String searchTerm) {
    final products = _productsCache?[source] ?? [];

    if (products.isEmpty) {
      debugPrint('   ⚠️ אין מוצרים ב-$source');
      return null;
    }

    // חיפוש - מוצר שמכיל את המילה (case insensitive)
    final normalizedSearch = searchTerm.toLowerCase();

    try {
      final found = products.firstWhere(
        (product) {
          final name = (product['name'] as String).toLowerCase();
          return name.contains(normalizedSearch);
        },
      );

      debugPrint('      ✅ נמצא: ${found['name']} (ב-$source)');
      return found;
    } catch (e) {
      debugPrint('      ⚠️ לא נמצא "$searchTerm" ב-$source');
      return null;
    }
  }

  /// טוען תבנית ממקור ויוצר רשימת פריטים
  ///
  /// תהליך:
  /// 1. טוען את קובץ התבנית
  /// 2. לכל item: מחפש מוצר אמיתי או יוצר fallback
  /// 3. מחזיר רשימת UnifiedListItem מוכנה
  static Future<List<UnifiedListItem>> loadTemplateItems(
      String templateFile) async {
    debugPrint('📋 [TemplateService] טוען תבנית: $templateFile');

    // 1. ודא שהמוצרים נטענו
    await _loadProductsIfNeeded();

    // 2. קרא את קובץ התבנית
    final String json = await rootBundle.loadString(
      'assets/templates/$templateFile',
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    final templateName = data['templateName'] as String;
    debugPrint('   📝 שם תבנית: $templateName');

    final items = <UnifiedListItem>[];

    // 3. לכל item בתבנית
    for (var templateItem in data['items'] as List) {
      final source = templateItem['source'] as String;
      final searchTerm = templateItem['searchTerm'] as String;
      final quantity = (templateItem['quantity'] as num).toDouble();
      final unit = templateItem['unit'] as String;
      final fallbackName = templateItem['fallbackName'] as String;

      debugPrint('   🔍 מחפש: "$searchTerm" ב-$source');

      // 4. חפש את המוצר האמיתי
      final product = findProduct(source, searchTerm);

      // 5. צור UnifiedListItem
      if (product != null) {
        // מצאנו מוצר אמיתי! 🎉
        items.add(UnifiedListItem.product(
          name: product['name'] as String,
          quantity: quantity.toInt(),
          unitPrice: ((product['price'] as num?) ?? 0.0).toDouble(),
          barcode: product['barcode'] as String?,
          unit: (product['unit'] as String?) ?? unit,
          category: (product['category'] as String?) ?? '',
          notes: 'מ-${product['brand'] ?? 'לא ידוע'}',
        ));
      } else {
        // לא מצאנו - צור פריט גנרי עם fallback
        items.add(UnifiedListItem.product(
          name: fallbackName,
          quantity: quantity.toInt(),
          unitPrice: 0.0,
          barcode: null,
          unit: unit,
          category: '',
        ));

        debugPrint('      ⚠️ משתמש ב-fallback: $fallbackName');
      }
    }

    debugPrint(
        '✅ [TemplateService] סיים לטעון תבנית: ${items.length} פריטים');
    return items;
  }

  /// טוען את רשימת כל התבניות הזמינות
  static Future<List<TemplateInfo>> loadTemplatesList() async {
    debugPrint('📚 [TemplateService] טוען רשימת תבניות...');

    final String json = await rootBundle.loadString(
      'assets/templates/list_templates.json',
    );
    final data = jsonDecode(json) as Map<String, dynamic>;

    final templates = <TemplateInfo>[];

    // תבניות ראשיות
    for (var category in data['categories'] as List) {
      if (category['templateFile'] != null) {
        templates.add(TemplateInfo(
          id: category['id'] as String,
          name: category['name'] as String,
          templateFile: category['templateFile'] as String,
          icon: _getIconForCategory(category['id'] as String),
        ));
      }
    }

    // תת-תבניות (אירועים)
    for (var subTemplate in (data['subTemplates'] as List?) ?? []) {
      for (var sub in subTemplate['sub'] as List) {
        if (sub['templateFile'] != null) {
          templates.add(TemplateInfo(
            id: sub['id'] as String,
            name: sub['name'] as String,
            templateFile: sub['templateFile'] as String,
            icon: _getIconForCategory(sub['id'] as String),
          ));
        }
      }
    }

    debugPrint('✅ [TemplateService] נמצאו ${templates.length} תבניות');
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

  /// מחזיר אייקון לפי מקור המוצר
  static String _getIconForSource(String source) {
    switch (source) {
      case 'butcher':
        return '🥩';
      case 'bakery':
        return '🍞';
      case 'greengrocer':
        return '🥬';
      case 'pharmacy':
        return '💊';
      case 'supermarket':
      case 'market':
      default:
        return '🛒';
    }
  }

  /// מנקה את המטמון (לדוגמה: אחרי עדכון מוצרים)
  static void clearCache() {
    _productsCache = null;
    debugPrint('🗑️ [TemplateService] המטמון נוקה');
  }
}
