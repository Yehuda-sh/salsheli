// 📄 lib/services/published_prices_service.dart
//
// 🎯 שירות לשליפת מחירים ממערכת "מחירון" של משרד הכלכלה
// - התחברות למערכת https://url.publishedprices.co.il
// - הורדת קבצי XML/JSON של מחירים
// - פענוח וטיפול בנתונים
// - שמירה מקומית

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:archive/archive.dart';

/// מודל למוצר ממערכת מחירון
class PublishedProduct {
  final String chainId;
  final String chainName;
  final String storeId;
  final String itemCode;
  final String itemName;
  final String manufacturerName;
  final String manufacturerCountry;
  final String unitOfMeasure;
  final double quantity;
  final double price;
  final String currency;
  final DateTime updateDate;
  final String? itemType;
  final String? unitOfMeasurePrice;

  PublishedProduct({
    required this.chainId,
    required this.chainName,
    required this.storeId,
    required this.itemCode,
    required this.itemName,
    required this.manufacturerName,
    required this.manufacturerCountry,
    required this.unitOfMeasure,
    required this.quantity,
    required this.price,
    required this.currency,
    required this.updateDate,
    this.itemType,
    this.unitOfMeasurePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'chain_id': chainId,
      'chain_name': chainName,
      'store_id': storeId,
      'item_code': itemCode,
      'item_name': itemName,
      'manufacturer_name': manufacturerName,
      'manufacturer_country': manufacturerCountry,
      'unit_of_measure': unitOfMeasure,
      'quantity': quantity,
      'price': price,
      'currency': currency,
      'update_date': updateDate.toIso8601String(),
      'item_type': itemType,
      'unit_of_measure_price': unitOfMeasurePrice,
    };
  }

  factory PublishedProduct.fromJson(Map<String, dynamic> json) {
    return PublishedProduct(
      chainId: json['chain_id']?.toString() ?? '',
      chainName: json['chain_name']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      manufacturerName: json['manufacturer_name']?.toString() ?? '',
      manufacturerCountry: json['manufacturer_country']?.toString() ?? '',
      unitOfMeasure: json['unit_of_measure']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'NIS',
      updateDate: json['update_date'] != null
          ? DateTime.parse(json['update_date'])
          : DateTime.now(),
      itemType: json['item_type']?.toString(),
      unitOfMeasurePrice: json['unit_of_measure_price']?.toString(),
    );
  }

  // המרה לפורמט האפליקציה
  Map<String, dynamic> toAppFormat() {
    return {
      'name': itemName,
      'category': _guessCategory(itemName),
      'icon': _getCategoryIcon(_guessCategory(itemName)),
      'price': price,
      'unit': unitOfMeasure,
      'barcode': itemCode,
      'brand': manufacturerName,
      'store': chainName,
    };
  }

  static String _guessCategory(String itemName) {
    final name = itemName.toLowerCase();

    if (name.contains('חלב') ||
        name.contains('גבינה') ||
        name.contains('יוגורט') ||
        name.contains('חמאה') ||
        name.contains('שמנת')) {
      return 'מוצרי חלב';
    }
    if (name.contains('לחם') ||
        name.contains('חלה') ||
        name.contains('בורקס') ||
        name.contains('מאפה')) {
      return 'מאפים';
    }
    if (name.contains('עגבני') ||
        name.contains('מלפפון') ||
        name.contains('חסה') ||
        name.contains('גזר') ||
        name.contains('בצל') ||
        name.contains('שום') ||
        name.contains('פלפל')) {
      return 'ירקות';
    }
    if (name.contains('תפוח') ||
        name.contains('בננה') ||
        name.contains('תפוז') ||
        name.contains('אבטיח') ||
        name.contains('ענבים')) {
      return 'פירות';
    }
    if (name.contains('עוף') ||
        name.contains('בשר') ||
        name.contains('דג') ||
        name.contains('סלמון')) {
      return 'בשר ודגים';
    }
    if (name.contains('אורז') ||
        name.contains('פסטה') ||
        name.contains('קוסקוס') ||
        name.contains('נודלס')) {
      return 'אורז ופסטה';
    }
    if (name.contains('שמן') ||
        name.contains('קטשופ') ||
        name.contains('מיונז') ||
        name.contains('חומוס') ||
        name.contains('טחינה')) {
      return 'שמנים ורטבים';
    }
    if (name.contains('סוכר') ||
        name.contains('מלח') ||
        name.contains('פלפל') ||
        name.contains('קמח')) {
      return 'תבלינים ואפייה';
    }
    if (name.contains('שוקולד') ||
        name.contains('ממתק') ||
        name.contains('חטיף') ||
        name.contains('ביסלי')) {
      return 'ממתקים וחטיפים';
    }
    if (name.contains('קוקה') ||
        name.contains('מיץ') ||
        name.contains('משקה') ||
        name.contains('בירה') ||
        name.contains('יין')) {
      return 'משקאות';
    }
    if (name.contains('סבון') ||
        name.contains('ניקוי') ||
        name.contains('אקונומיקה') ||
        name.contains('מטהר')) {
      return 'מוצרי ניקיון';
    }

    return 'אחר';
  }

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
      'מוצרי ניקיון': '🧼',
      'היגיינה אישית': '🧴',
    };
    return iconMap[category] ?? '🛒';
  }
}

/// שירות לניהול המחירים הפרסומיים
class PublishedPricesService {
  static const String _baseUrl = 'https://url.publishedprices.co.il';
  static const String _loginPath = '/login';
  static const String _filesPath = '/file/d';

  // פרטי התחברות - מעודכן לשופרסל
  static const String _username = 'Shufersal';  // 🆕 שופרסל!
  static const String _password = ''; // ריק

  final http.Client _client = http.Client();
  String? _sessionCookie;

  // Cache
  static const String _cacheFileName = 'published_prices_cache.json';
  static const Duration _cacheDuration = Duration(days: 1);

  /// התחברות למערכת
  Future<bool> login() async {
    try {
      debugPrint('🔐 מתחבר למערכת מחירון...');

      final response = await _client
          .post(
            Uri.parse('$_baseUrl$_loginPath'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'username': _username, 'password': _password},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 302) {
        // שמירת ה-session cookie
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          _sessionCookie = cookies.split(';')[0];
          debugPrint('✅ התחברות הצליחה');
          return true;
        }
      }

      debugPrint('❌ התחברות נכשלה: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('❌ שגיאה בהתחברות: $e');
      return false;
    }
  }

  /// קבלת רשימת קבצים זמינים
  Future<List<Map<String, dynamic>>> getAvailableFiles({
    String? chainName,
    String? fileType = 'Prices', // או 'Stores', 'Promos'
  }) async {
    try {
      if (_sessionCookie == null) {
        final loggedIn = await login();
        if (!loggedIn) return [];
      }

      final queryParams = <String, String>{};
      if (chainName != null) queryParams['sn'] = chainName;
      if (fileType != null) queryParams['st'] = fileType;

      final uri = Uri.parse(
        '$_baseUrl$_filesPath',
      ).replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: {'Cookie': _sessionCookie!})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // פענוח ה-HTML לקבלת רשימת הקבצים
        // (נצטרך לפרסר HTML כאן - נשתמש ב-regex פשוט)
        final files = _parseFilesList(response.body);
        debugPrint('📂 נמצאו ${files.length} קבצים');
        return files;
      }

      return [];
    } catch (e) {
      debugPrint('❌ שגיאה בקבלת רשימת קבצים: $e');
      return [];
    }
  }

  /// הורדת קובץ מחירים
  Future<List<PublishedProduct>> downloadPriceFile(String fileUrl) async {
    try {
      if (_sessionCookie == null) {
        final loggedIn = await login();
        if (!loggedIn) return [];
      }

      debugPrint('⬇️ מוריד קובץ מחירים: $fileUrl');

      final response = await _client
          .get(Uri.parse(fileUrl), headers: {'Cookie': _sessionCookie!})
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // בדיקה אם זה קובץ ZIP
        if (fileUrl.endsWith('.gz') || fileUrl.endsWith('.zip')) {
          return _parseCompressedFile(bytes);
        } else if (fileUrl.endsWith('.xml')) {
          return _parseXmlFile(utf8.decode(bytes));
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ שגיאה בהורדת קובץ: $e');
      return [];
    }
  }

  /// פענוח קובץ XML
  List<PublishedProduct> _parseXmlFile(String xmlContent) {
    try {
      final document = xml.XmlDocument.parse(xmlContent);
      final items = document.findAllElements('Item');

      final products = <PublishedProduct>[];

      for (final item in items) {
        try {
          final product = PublishedProduct(
            chainId: _getXmlValue(item, 'ChainId'),
            chainName: _getXmlValue(item, 'ChainName'),
            storeId: _getXmlValue(item, 'StoreId'),
            itemCode: _getXmlValue(item, 'ItemCode'),
            itemName: _getXmlValue(item, 'ItemName'),
            manufacturerName: _getXmlValue(item, 'ManufacturerName'),
            manufacturerCountry: _getXmlValue(item, 'ManufactureCountry'),
            unitOfMeasure: _getXmlValue(item, 'UnitOfMeasure'),
            quantity: double.tryParse(_getXmlValue(item, 'Quantity')) ?? 0.0,
            price: double.tryParse(_getXmlValue(item, 'ItemPrice')) ?? 0.0,
            currency: 'NIS',
            updateDate: DateTime.now(),
            itemType: _getXmlValue(item, 'ItemType'),
            unitOfMeasurePrice: _getXmlValue(item, 'UnitOfMeasurePrice'),
          );

          products.add(product);
        } catch (e) {
          debugPrint('⚠️ שגיאה בפענוח פריט: $e');
          continue;
        }
      }

      debugPrint('✅ פוענחו ${products.length} מוצרים');
      return products;
    } catch (e) {
      debugPrint('❌ שגיאה בפענוח XML: $e');
      return [];
    }
  }

  /// פענוח קובץ דחוס
  List<PublishedProduct> _parseCompressedFile(List<int> bytes) {
    try {
      final archive = GZipDecoder().decodeBytes(bytes);
      final xmlContent = utf8.decode(archive);
      return _parseXmlFile(xmlContent);
    } catch (e) {
      debugPrint('❌ שגיאה בפענוח קובץ דחוס: $e');
      return [];
    }
  }

  /// עזר לקריאת ערך מ-XML
  String _getXmlValue(xml.XmlElement element, String tagName) {
    try {
      return element.findElements(tagName).first.innerText;
    } catch (e) {
      return '';
    }
  }

  /// פענוח רשימת קבצים מ-HTML
  List<Map<String, dynamic>> _parseFilesList(String html) {
    final files = <Map<String, dynamic>>[];

    // Regex לחילוץ קישורים לקבצים
    final linkRegex = RegExp(
      r'<a[^>]*href="([^"]*)"[^>]*>([^<]*Price[^<]*\.xml[^<]*)</a>',
      caseSensitive: false,
    );

    final matches = linkRegex.allMatches(html);

    for (final match in matches) {
      final url = match.group(1);
      final filename = match.group(2);

      if (url != null && filename != null) {
        files.add({
          'url': url.startsWith('http') ? url : '$_baseUrl$url',
          'filename': filename.trim(),
          'type': 'prices',
        });
      }
    }

    return files;
  }

  /// שמירת מוצרים ב-cache
  Future<void> saveToCache(List<PublishedProduct> products) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');

      final jsonData = {
        'last_updated': DateTime.now().toIso8601String(),
        'count': products.length,
        'products': products.map((p) => p.toJson()).toList(),
      };

      await file.writeAsString(json.encode(jsonData));
      debugPrint('💾 נשמרו ${products.length} מוצרים ב-cache');
    } catch (e) {
      debugPrint('❌ שגיאה בשמירת cache: $e');
    }
  }

  /// טעינת מוצרים מ-cache
  Future<List<PublishedProduct>> loadFromCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final data = json.decode(contents);

      final products =
          (data['products'] as List?)
              ?.map((item) => PublishedProduct.fromJson(item))
              .toList() ??
          [];

      debugPrint('📂 נטענו ${products.length} מוצרים מ-cache');
      return products;
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת cache: $e');
      return [];
    }
  }

  /// בדיקה אם ה-cache תקף
  Future<bool> isCacheValid() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');

      if (!await file.exists()) return false;

      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);

      return age < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// קבלת מוצרים (מ-cache או מהשרת)
  Future<List<PublishedProduct>> getProducts({
    bool forceRefresh = false,
    String? chainName = 'שופרסל',  // 🆕 שופרסל!
  }) async {
    // אם ה-cache תקף ולא מאלצים רענון
    if (!forceRefresh && await isCacheValid()) {
      return await loadFromCache();
    }

    // אחרת, שולף מהשרת
    final files = await getAvailableFiles(chainName: chainName);

    if (files.isEmpty) {
      debugPrint('⚠️ לא נמצאו קבצים, משתמש ב-cache');
      return await loadFromCache();
    }

    // מוריד את הקובץ הראשון (האחרון)
    final latestFile = files.first;
    final products = await downloadPriceFile(latestFile['url']);

    if (products.isNotEmpty) {
      await saveToCache(products);
    }

    return products;
  }

  /// ניקוי משאבים
  void dispose() {
    _client.close();
  }
}
