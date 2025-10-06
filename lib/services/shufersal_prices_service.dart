// 📄 lib/services/shufersal_prices_service.dart
//
// 🎯 שירות להורדת מחירים משופרסל - פשוט ועובד!
// - הורדה ישירה מ-prices.shufersal.co.il (ללא התחברות!)
// - קבצים פומביים וזמינים
// - פענוח XML + GZ
// - עדכון חכם (מוצרים קיימים = עדכון מחיר בלבד)
//
// 💡 מבוסס על: scripts/fetch_shufersal_products.dart
//
// Version: 1.0
// Last Updated: 06/10/2025

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

/// מודל פשוט למוצר משופרסל
class ShufersalProduct {
  final String barcode;
  final String name;
  final String brand;
  final double price;
  final String unit;
  final double quantity;
  final String store;

  ShufersalProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.price,
    required this.unit,
    required this.quantity,
    this.store = 'שופרסל',
  });

  /// המרה לפורמט האפליקציה
  Map<String, dynamic> toAppFormat() {
    return {
      'barcode': barcode,
      'name': _cleanProductName(name),
      'brand': brand,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'store': store,
      'category': _guessCategory(name),
      'icon': _getCategoryIcon(_guessCategory(name)),
    };
  }

  /// ניקוי שם מוצר
  static String _cleanProductName(String name) {
    var cleaned = name.trim();

    // הוסף רווח אחרי מספרים (12ביצים → 12 ביצים)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(\d)([א-ת])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // הסר רווחים כפולים
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // הסר תווים מיוחדים מיותרים
    cleaned = cleaned.replaceAll(RegExp(r'[\*\+\#\@]'), '');

    return cleaned.trim();
  }

  /// ניחוש קטגוריה לפי שם
  static String _guessCategory(String itemName) {
    final name = itemName.toLowerCase();

    if (name.contains('חלב') ||
        name.contains('גבינה') ||
        name.contains('יוגורט') ||
        name.contains('חמאה') ||
        name.contains('שמנת') ||
        name.contains('קוטג') ||
        name.contains('ביצים') ||
        name.contains('ביצה')) return 'מוצרי חלב';

    if (name.contains('לחם') ||
        name.contains('חלה') ||
        name.contains('בורקס') ||
        name.contains('מאפה') ||
        name.contains('פיתה') ||
        name.contains('בגט') ||
        name.contains('לחמניה')) return 'מאפים';

    if (name.contains('עגבני') ||
        name.contains('מלפפון') ||
        name.contains('חסה') ||
        name.contains('גזר') ||
        name.contains('בצל') ||
        name.contains('שום') ||
        name.contains('פלפל') ||
        name.contains('כרוב') ||
        name.contains('ברוקולי')) return 'ירקות';

    if (name.contains('תפוח') ||
        name.contains('בננה') ||
        name.contains('תפוז') ||
        name.contains('אבטיח') ||
        name.contains('ענבים') ||
        name.contains('מלון') ||
        name.contains('אגס') ||
        name.contains('אפרסק')) return 'פירות';

    if (name.contains('עוף') ||
        name.contains('בשר') ||
        name.contains('דג') ||
        name.contains('סלמון') ||
        name.contains('טונה') ||
        name.contains('שניצל') ||
        name.contains('פילה') ||
        name.contains('המבורגר')) return 'בשר ודגים';

    if (name.contains('אורז') ||
        name.contains('פסטה') ||
        name.contains('ספגטי') ||
        name.contains('קוסקוס') ||
        name.contains('נודלס')) return 'אורז ופסטה';

    if (name.contains('שמן') ||
        name.contains('קטשופ') ||
        name.contains('מיונז') ||
        name.contains('חומוס') ||
        name.contains('טחינה') ||
        name.contains('חרדל') ||
        name.contains('רוטב')) return 'שמנים ורטבים';

    if (name.contains('סוכר') ||
        name.contains('מלח') ||
        name.contains('פלפל') ||
        name.contains('קמח') ||
        name.contains('תבלין') ||
        name.contains('כמון') ||
        name.contains('קוריאנדר') ||
        name.contains('קרי') ||
        name.contains('שמרים')) return 'תבלינים ואפייה';

    if (name.contains('שוקולד') ||
        name.contains('ממתק') ||
        name.contains('חטיף') ||
        name.contains('ביסלי') ||
        name.contains('במבה') ||
        name.contains('גלידה') ||
        name.contains('עוגה') ||
        name.contains('וופלים')) return 'ממתקים וחטיפים';

    if (name.contains('קוקה') ||
        name.contains('מיץ') ||
        name.contains('משקה') ||
        name.contains('בירה') ||
        name.contains('יין') ||
        name.contains('ספרייט') ||
        name.contains('מים מינרלים') ||
        name.contains('פפסי')) return 'משקאות';

    if (name.contains('קפה') ||
        name.contains('קפסול') ||
        name.contains('נספרסו') ||
        name.contains('תה')) return 'קפה ותה';

    if (name.contains('סבון') ||
        name.contains('ניקוי') ||
        name.contains('אקונומיקה') ||
        name.contains('מטהר') ||
        name.contains('אמוניה') ||
        name.contains('לבנדר') ||
        name.contains('מרכך כביסה')) return 'מוצרי ניקיון';

    if (name.contains('שמפו') ||
        name.contains('משחת שיניים') ||
        name.contains('דאודורנט') ||
        name.contains('סבון גוף') ||
        name.contains('תחבושת') ||
        name.contains('מגבות') ||
        name.contains('מטליות')) return 'היגיינה אישית';

    if (name.contains('שימורים') ||
        name.contains('כבושים') ||
        name.contains('חמוצים') ||
        name.contains('טונה בקופסה') ||
        name.contains('שימור')) return 'שימורים';

    if (name.contains('קפוא') || name.contains('קרח')) return 'קפואים';

    return 'אחר';
  }

  /// אייקון לפי קטגוריה
  static String _getCategoryIcon(String category) {
    const iconMap = {
      'מוצרי חלב': '🥛',
      'מאפים': '🍞',
      'ירקות': '🥬',
      'פירות': '🍎',
      'בשר ודגים': '🥩',
      'אורז ופסטה': '🍚',
      'שמנים ורטבים': '🫗',
      'תבלינים ואפייה': '🧂',
      'ממתקים וחטיפים': '🍫',
      'משקאות': '🥤',
      'קפה ותה': '☕',
      'מוצרי ניקיון': '🧼',
      'היגיינה אישית': '🧴',
      'שימורים': '🥫',
      'קפואים': '🥖',
    };
    return iconMap[category] ?? '🛒';
  }
}

/// שירות להורדת מחירים משופרסל
class ShufersalPricesService {
  static const String _baseUrl = 'https://prices.shufersal.co.il/';
  static const int _maxFilesToDownload = 3; // מס' סניפים להורדה
  static const Duration _timeout = Duration(minutes: 5);

  final http.Client _client = http.Client();

  /// קבלת רשימת URL של קבצי מחירים
  Future<List<String>> _getFileUrls() async {
    try {
      debugPrint('🌐 מתחבר ל-prices.shufersal.co.il...');

      final response =
          await _client.get(Uri.parse(_baseUrl)).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('❌ שגיאה: ${response.statusCode}');
        return [];
      }

      debugPrint('✅ קיבל תגובה (${response.body.length} תווים)');

      // חיפוש קישורי הורדה בעמוד (קבצי GZ עם Price)
      final regex = RegExp(
        r'https://pricesprodpublic\.blob\.core\.windows\.net/[^\s"<>]+\.gz[^\s"<>]*',
        caseSensitive: false,
      );

      final matches = regex.allMatches(response.body);
      final urls = <String>[];

      for (final match in matches) {
        final url = match.group(0);
        if (url != null && url.contains('Price')) {
          // HTML decode - המר &amp; ל-&
          final decodedUrl = url
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              .replaceAll('&quot;', '"');
          urls.add(decodedUrl);
        }
      }

      debugPrint('✅ נמצאו ${urls.length} קבצי מחירים');
      return urls;
    } catch (e) {
      debugPrint('❌ שגיאה בחיפוש קבצים: $e');
      return [];
    }
  }

  /// הורדה ופענוח של קובץ מחירים בודד
  Future<List<ShufersalProduct>> _downloadAndParse(String fileUrl) async {
    try {
      debugPrint('⬇️ מוריד קובץ...');

      final response =
          await _client.get(Uri.parse(fileUrl)).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('❌ שגיאה בהורדה: ${response.statusCode}');
        return [];
      }

      final bytes = response.bodyBytes;
      debugPrint('✅ הורד ${bytes.length} bytes');

      // פענוח GZ
      debugPrint('📦 מפענח GZ...');
      final decompressed = GZipDecoder().decodeBytes(bytes);
      final xmlContent = utf8.decode(decompressed);

      debugPrint('✅ פוענח XML (${xmlContent.length} תווים)');

      // פענוח XML
      return _parseXml(xmlContent);
    } catch (e) {
      debugPrint('❌ שגיאה בהורדה/פענוח: $e');
      return [];
    }
  }

  /// פענוח XML למוצרים
  List<ShufersalProduct> _parseXml(String xmlContent) {
    try {
      debugPrint('📋 מפענח XML למוצרים...');

      final document = xml.XmlDocument.parse(xmlContent);
      final items = document.findAllElements('Item');

      debugPrint('✅ נמצאו ${items.length} פריטים ב-XML');

      final products = <ShufersalProduct>[];

      for (final item in items) {
        try {
          final itemCode = _getXmlValue(item, 'ItemCode');
          final itemName = _getXmlValue(item, 'ItemName');

          if (itemCode.isEmpty || itemName.isEmpty) continue;

          final product = ShufersalProduct(
            barcode: itemCode,
            name: itemName,
            brand: _getXmlValue(item, 'ManufacturerName'),
            price: double.tryParse(_getXmlValue(item, 'ItemPrice')) ?? 0.0,
            unit: _getXmlValue(item, 'UnitOfMeasure'),
            quantity: double.tryParse(_getXmlValue(item, 'Quantity')) ?? 0.0,
          );

          // רק מוצרים עם מחיר > 0
          if (product.price > 0.5) {
            products.add(product);
          }
        } catch (e) {
          continue;
        }
      }

      debugPrint('✅ פוענחו ${products.length} מוצרים תקפים');
      return products;
    } catch (e) {
      debugPrint('❌ שגיאה בפענוח XML: $e');
      return [];
    }
  }

  /// קריאת ערך מ-XML
  String _getXmlValue(xml.XmlElement element, String tagName) {
    try {
      return element.findElements(tagName).first.innerText.trim();
    } catch (e) {
      return '';
    }
  }

  /// הורדת מוצרים משופרסל (API ציבורי)
  Future<List<ShufersalProduct>> getProducts() async {
    try {
      debugPrint('\n🛒 מוריד מחירים משופרסל...');

      // 1. קבלת רשימת קבצים
      final fileUrls = await _getFileUrls();

      if (fileUrls.isEmpty) {
        debugPrint('❌ לא נמצאו קבצי מחירים');
        return [];
      }

      // 2. הורדת מספר קבצים (לא הכל)
      final filesToDownload = fileUrls.take(_maxFilesToDownload).toList();
      final allProducts = <ShufersalProduct>[];

      debugPrint('📥 מוריד ${filesToDownload.length} קבצים...');

      for (var i = 0; i < filesToDownload.length; i++) {
        debugPrint('\n📦 סניף ${i + 1}/${filesToDownload.length}:');
        final products = await _downloadAndParse(filesToDownload[i]);

        if (products.isNotEmpty) {
          allProducts.addAll(products);
          debugPrint(
              '   ✅ נוספו ${products.length} מוצרים (סה"כ: ${allProducts.length})');
        }
      }

      // 3. הסרת כפילויות (לפי barcode)
      final seen = <String>{};
      final uniqueProducts = <ShufersalProduct>[];

      for (final product in allProducts) {
        if (!seen.contains(product.barcode)) {
          seen.add(product.barcode);
          uniqueProducts.add(product);
        }
      }

      debugPrint('\n✅ סה"כ ${uniqueProducts.length} מוצרים ייחודיים');
      return uniqueProducts;
    } catch (e) {
      debugPrint('❌ שגיאה כללית בהורדת מחירים: $e');
      return [];
    }
  }

  /// סגירת משאבים
  void dispose() {
    _client.close();
  }
}
