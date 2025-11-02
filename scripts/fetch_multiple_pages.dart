// scripts/fetch_multiple_pages.dart
// הורדת מוצרים מכמה עמודים

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

const String _baseUrl = 'https://prices.shufersal.co.il/';
const int _pagesToFetch = 10; // כמה עמודים להוריד
const int _maxProductsPerPage = 50; // מקסימום מוצרים לעמוד (למנוע עומס)

void main() async {
  print('🛒 מוריד מוצרים מ-$_pagesToFetch עמודים ראשונים...\n');
  
  final allProducts = <Map<String, dynamic>>[];
  
  try {
    for (var page = 1; page <= _pagesToFetch; page++) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📄 עמוד $page/$_pagesToFetch');
      print('━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      // קבלת URL-ים מהעמוד
      final pageUrl = page == 1 ? _baseUrl : '$_baseUrl?page=$page';
      print('🌐 מתחבר ל: $pageUrl');
      
      final fileUrls = await getFileUrlsFromPage(pageUrl);
      
      if (fileUrls.isEmpty) {
        print('⚠️  לא נמצאו קבצים בעמוד $page\n');
        continue;
      }
      
      print('✓ נמצאו ${fileUrls.length} קבצים\n');
      
      // הורדה - רק כמה קבצים מכל עמוד
      final filesToDownload = fileUrls.take(_maxProductsPerPage).toList();
      
      for (var i = 0; i < filesToDownload.length; i++) {
        print('📦 קובץ ${i + 1}/${filesToDownload.length}:');
        final products = await downloadAndParse(filesToDownload[i]);
        
        if (products.isNotEmpty) {
          allProducts.addAll(products);
          print('   ✓ נוספו ${products.length} מוצרים (סה"כ: ${allProducts.length})');
        }
      }
      
      print('\n✅ עמוד $page הושלם - סה"כ ${allProducts.length} מוצרים גולמיים\n');
      
      // המתנה קצרה בין עמודים
      if (page < _pagesToFetch) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    
    if (allProducts.isEmpty) {
      print('❌ לא נמצאו מוצרים');
      exit(1);
    }
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✓ פוענחו ${allProducts.length} מוצרים גולמיים\n');
    
    // עיבוד
    print('🔄 מעבד מוצרים...');
    final processed = await processProducts(allProducts);
    print('✓ עובדו ${processed.length} מוצרים ייחודיים\n');
    
    // שמירה
    print('💾 שומר לקובץ...');
    await saveToFile(processed);
    
    // סיכום
    printSummary(processed);
    
    print('\n✅ הסתיים בהצלחה!');
    print('📂 הקבצים נשמרו ב:');
    print('   - assets/data/by_list_type/');
    print('   - assets/data/by_category/');
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
    exit(1);
  }
}

/// קבלת רשימת קישורי קבצים מעמוד
Future<List<String>> getFileUrlsFromPage(String pageUrl) async {
  try {
    final response = await http.get(Uri.parse(pageUrl))
        .timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      print('   ❌ שגיאה: ${response.statusCode}');
      return [];
    }
    
    // חיפוש קישורי הורדה
    final regex = RegExp(
      r'https://pricesprodpublic\.blob\.core\.windows\.net/[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    final urls = <String>[];
    for (final match in regex.allMatches(response.body)) {
      final url = match.group(0);
      if (url != null && url.contains('Price')) {
        final decodedUrl = url
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"');
        urls.add(decodedUrl);
      }
    }
    
    return urls;
    
  } catch (e) {
    print('   ❌ שגיאה בטעינת עמוד: $e');
    return [];
  }
}

/// הורדה ופענוח של קובץ מחירים
Future<List<Map<String, dynamic>>> downloadAndParse(String fileUrl) async {
  try {
    final response = await http.get(Uri.parse(fileUrl))
        .timeout(const Duration(minutes: 2));
    
    if (response.statusCode != 200) {
      print('   ❌ שגיאה בהורדה: ${response.statusCode}');
      return [];
    }
    
    final bytes = response.bodyBytes;
    
    // פענוח GZ
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final xmlContent = utf8.decode(decompressed);
    
    // פענוח XML
    return parseXmlProducts(xmlContent);
    
  } catch (e) {
    print('   ⚠️  שגיאה: $e');
    return [];
  }
}

/// פענוח קובץ XML למוצרים
List<Map<String, dynamic>> parseXmlProducts(String xmlContent) {
  try {
    final document = xml.XmlDocument.parse(xmlContent);
    final items = document.findAllElements('Item');
    
    final products = <Map<String, dynamic>>[];
    
    for (final item in items) {
      try {
        final itemCode = _getXmlValue(item, 'ItemCode');
        final itemName = _getXmlValue(item, 'ItemName');
        
        if (itemCode.isEmpty || itemName.isEmpty) continue;
        
        final product = {
          'barcode': itemCode,
          'name': itemName,
          'brand': _getXmlValue(item, 'ManufacturerName'),
          'price': double.tryParse(_getXmlValue(item, 'ItemPrice')) ?? 0.0,
          'unit': _getXmlValue(item, 'UnitOfMeasure'),
          'quantity': double.tryParse(_getXmlValue(item, 'Quantity')) ?? 0.0,
          'store': 'שופרסל',
        };
        
        products.add(product);
      } catch (e) {
        continue;
      }
    }
    
    return products;
    
  } catch (e) {
    return [];
  }
}

String _getXmlValue(xml.XmlElement element, String tagName) {
  try {
    return element.findElements(tagName).first.innerText.trim();
  } catch (e) {
    return '';
  }
}

/// עיבוד וסינון מוצרים
Future<List<Map<String, dynamic>>> processProducts(
  List<Map<String, dynamic>> products,
) async {
  var processed = <Map<String, dynamic>>[];
  
  // טען מוצרים קיימים
  final existingProductsByBarcode = await _loadAllExistingProducts();
  print('   📦 נטענו ${existingProductsByBarcode.length} מוצרים קיימים\n');
  
  for (final p in products) {
    final price = p['price'] as double? ?? 0.0;
    
    if (price < 0.5) continue;
    
    final rawName = p['name']?.toString() ?? '';
    if (rawName.isEmpty) continue;
    
    final name = _cleanProductName(rawName);
    final barcode = p['barcode']?.toString() ?? '';
    final brand = p['brand']?.toString() ?? '';
    
    String category;
    final existingProduct = existingProductsByBarcode[barcode];
    
    if (existingProduct != null) {
      final existingCategory = existingProduct['category']?.toString() ?? 'אחר';
      
      if (existingCategory != 'אחר') {
        category = existingCategory;
      } else {
        category = guessCategoryByBrand(brand) ?? guessCategory(name);
      }
    } else {
      category = guessCategoryByBrand(brand) ?? guessCategory(name);
    }
    
    final imageUrl = 'https://media.shufersal.co.il/product_images/products_360/$barcode/files/360_assets/index/images/${barcode}_1.jpg';
    final fallbackImageUrl = 'https://media.shufersal.co.il/product_images/products_360/default/files/360_assets/index/images/default_1.jpg';
    
    processed.add({
      'name': name,
      'category': category,
      'icon': getCategoryIcon(category),
      'price': price,
      'barcode': barcode,
      'brand': p['brand'],
      'unit': p['unit'],
      'store': p['store'],
      'image_url': imageUrl,
      'fallback_image_url': fallbackImageUrl,
    });
  }
  
  // מחיקת כפילויות
  final seen = <String>{};
  processed = processed.where((p) {
    final barcode = p['barcode']?.toString() ?? '';
    if (barcode.isEmpty) return true;
    
    if (seen.contains(barcode)) return false;
    seen.add(barcode);
    return true;
  }).toList();
  
  // מיון
  processed.sort((a, b) {
    final nameA = a['name']?.toString() ?? '';
    final nameB = b['name']?.toString() ?? '';
    return nameA.compareTo(nameB);
  });
  
  return processed;
}

// כל הפונקציות הנוספות - העתקתי מהסקריפט המקורי
Future<Map<String, Map<String, dynamic>>> _loadAllExistingProducts() async {
  final Map<String, Map<String, dynamic>> allProducts = {};
  
  final listTypeDir = Directory('assets/data/by_list_type');
  if (await listTypeDir.exists()) {
    await for (final file in listTypeDir.list()) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          final List<dynamic> products = json.decode(content);
          for (final p in products) {
            if (p is Map<String, dynamic>) {
              final barcode = p['barcode']?.toString();
              if (barcode != null && barcode.isNotEmpty) {
                allProducts[barcode] = Map<String, dynamic>.from(p);
              }
            }
          }
        } catch (e) {
          // Skip invalid files
        }
      }
    }
  }
  
  return allProducts;
}

String _cleanProductName(String name) {
  var cleaned = name.trim();
  
  cleaned = cleaned.replaceAllMapped(
    RegExp(r'(\d)([א-ת])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  cleaned = cleaned.replaceAllMapped(
    RegExp(r'(\d)([a-zA-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'[\*\+\#\@\$\%\^]'), '');
  
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*g\b', caseSensitive: false), r'$1 גרם');
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*kg\b', caseSensitive: false), r'$1 ק"ג');
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*ml\b', caseSensitive: false), r'$1 מ"ל');
  
  return cleaned.trim();
}

String? guessCategoryByBrand(String brand) {
  if (brand.isEmpty) return null;
  
  final brandLower = brand.toLowerCase();
  
  if (brandLower.contains('תנובה') || brandLower.contains('יוטבתה') ||
      brandLower.contains('שטראוס') || brandLower.contains('דנונה') ||
      brandLower.contains('גד') || brandLower.contains('המשביר') ||
      brandLower.contains('טרה')) return 'מוצרי חלב';
  
  if (brandLower.contains('אסם') || brandLower.contains('עלית') ||
      brandLower.contains('מאפיית חלבי') || brandLower.contains('טעמן') ||
      brandLower.contains('נסטלה') || brandLower.contains('פררו') ||
      brandLower.contains('קליק')) return 'ממתקים וחטיפים';
  
  if (brandLower.contains('נסקפה') || brandLower.contains('עלית קפה') ||
      brandLower.contains('לנדוור') || brandLower.contains('ויסוצקי') ||
      brandLower.contains('אילנית')) return 'קפה ותה';
  
  if (brandLower.contains('סנו') || brandLower.contains('בריל') ||
      brandLower.contains('פרסיל') || brandLower.contains('דורית') ||
      brandLower.contains('מאסטר') || brandLower.contains('קלין')) return 'מוצרי ניקיון';
  
  if (brandLower.contains('ג\'ונסון') || brandLower.contains('קולגייט') ||
      brandLower.contains('הד אנד שולדרס') || brandLower.contains('דאב') ||
      brandLower.contains('ניוויאה') || brandLower.contains('אקס סנס')) return 'היגיינה אישית';
  
  if (brandLower.contains('טיב טעם') || brandLower.contains('זוגלובק') ||
      brandLower.contains('יהלום')) return 'בשר ודגים';
  
  return null;
}

String guessCategory(String itemName) {
  final name = itemName.toLowerCase();
  
  // 🔥 בדיקת קמח ותבלינים לפני מאפים (קמח לאפיית לחם = תבלינים!)
  if (name.contains('קמח') || name.contains('סוכר') || name.contains('מלח') ||
      (name.contains('פלפל') && !name.contains('ירק')) ||
      name.contains('תבלין') || name.contains('כמון') || name.contains('קינמון') ||
      name.contains('שמרים') || name.contains('אבקת אפיה') || name.contains('וניל')) return 'תבלינים ואפייה';
  
  if (name.contains('חלב') || name.contains('גבינה') || name.contains('יוגורט') ||
      name.contains('חמאה') || name.contains('שמנת') || name.contains('קוטג') ||
      name.contains('ביצים') || name.contains('ביצה') || name.contains('לבן') ||
      name.contains('לבנה')) return 'מוצרי חלב';
  
  if (name.contains('לחם') || name.contains('חלה') || name.contains('בורקס') ||
      name.contains('מאפה') || name.contains('פיתה') || name.contains('בגט') ||
      name.contains('לחמניה')) return 'מאפים';
  
  if (name.contains('עגבני') || name.contains('מלפפון') || name.contains('חסה') ||
      name.contains('גזר') || name.contains('בצל') || name.contains('שום') ||
      name.contains('פלפל') || name.contains('כרוב') || name.contains('ברוקולי')) return 'ירקות';
  
  if ((name.contains('תפוח') && !name.contains('אדמה')) || name.contains('בננה') ||
      name.contains('תפוז') || name.contains('אבטיח') || name.contains('ענבים') ||
      name.contains('מלון') || name.contains('אגס') || name.contains('אפרסק') ||
      name.contains('אבוקדו')) return 'פירות';
  
  if (name.contains('עוף') || name.contains('בשר') || name.contains('דג') ||
      name.contains('סלמון') || name.contains('טונה') || name.contains('שניצל') ||
      name.contains('פילה') || name.contains('המבורגר')) return 'בשר ודגים';
  
  if (name.contains('אורז') || name.contains('פסטה') || name.contains('ספגטי') ||
      name.contains('קוסקוס') || name.contains('נודלס')) return 'אורז ופסטה';
  
  if (name.contains('שמן') || name.contains('קטשופ') || name.contains('מיונז') ||
      name.contains('חומוס') || name.contains('טחינה') || name.contains('חרדל') ||
      name.contains('רוטב')) return 'שמנים ורטבים';
  

  
  if (name.contains('שוקולד') || name.contains('ממתק') || name.contains('חטיף') ||
      name.contains('ביסלי') || name.contains('במבה') || name.contains('גלידה') ||
      name.contains('עוגה') || name.contains('עוגי')) return 'ממתקים וחטיפים';
  
  if (name.contains('קוקה') || name.contains('מיץ') || name.contains('משקה') ||
      name.contains('בירה') || name.contains('יין') || name.contains('ספרייט') ||
      (name.contains('מים') && (name.contains('מינרל') || name.contains('בקבוק')))) return 'משקאות';
  
  if (name.contains('קפה') || name.contains('קפסול') || name.contains('נספרסו') ||
      (name.contains('תה') && !name.contains('חלב'))) return 'קפה ותה';
  
  if ((name.contains('סבון') && name.contains('כלים')) || name.contains('ניקוי') ||
      name.contains('אקונומיקה') || name.contains('מטהר') || name.contains('אמוניה') ||
      name.contains('מרכך') && name.contains('כביסה')) return 'מוצרי ניקיון';
  
  if (name.contains('שמפו') || name.contains('משחת שיניים') ||
      name.contains('דאודורנט') || (name.contains('סבון') && !name.contains('כלים'))) return 'היגיינה אישית';
  
  if (name.contains('שימורים') || name.contains('שימור') ||
      name.contains('קונסרבה')) return 'שימורים';
  
  if (name.contains('קפוא') || name.contains('קפואה') ||
      name.contains('קפואים') || name.contains('קרח')) return 'קפואים';
  
  return 'אחר';
}

String getCategoryIcon(String category) {
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

Future<void> saveToFile(List<Map<String, dynamic>> newProducts) async {
  print('\n🔄 מפצל מוצרים לפי list_type ו-category...');
  
  Map<String, Map<String, dynamic>> existingProducts = await _loadAllExistingProducts();
  print('   📦 נטענו ${existingProducts.length} מוצרים קיימים');
  
  int updatedPrices = 0;
  int addedProducts = 0;
  int unchangedProducts = 0;
  
  for (final newProduct in newProducts) {
    final barcode = newProduct['barcode']?.toString();
    if (barcode == null || barcode.isEmpty) continue;
    
    if (existingProducts.containsKey(barcode)) {
      final existing = existingProducts[barcode]!;
      final oldPrice = existing['price'] as double? ?? 0.0;
      final newPrice = newProduct['price'] as double? ?? 0.0;
      
      if ((newPrice - oldPrice).abs() > 0.01) {
        existing['price'] = newPrice;
        existing['store'] = newProduct['store'];
        updatedPrices++;
      } else {
        unchangedProducts++;
      }
      
      existing['image_url'] = newProduct['image_url'];
      existing['fallback_image_url'] = newProduct['fallback_image_url'];
    } else {
      existingProducts[barcode] = newProduct;
      addedProducts++;
    }
  }
  
  print('   ✅ עודכנו $updatedPrices מחירים');
  print('   ➕ נוספו $addedProducts מוצרים חדשים');
  print('   ⏸️  $unchangedProducts מוצרים ללא שינוי');
  print('   📦 סה"כ ${existingProducts.length} מוצרים\n');
  
  final byListType = <String, List<Map<String, dynamic>>>{};
  final byCategory = <String, List<Map<String, dynamic>>>{};
  
  for (final product in existingProducts.values) {
    final category = product['category']?.toString() ?? 'אחר';
    final listType = _getListTypeForProduct(category);
    
    byListType.putIfAbsent(listType, () => []);
    byListType[listType]!.add(product);
    
    byCategory.putIfAbsent(category, () => []);
    byCategory[category]!.add(product);
  }
  
  await _saveByListType(byListType);
  await _saveByCategory(byCategory);
  
  print('   💾 כל הקבצים נשמרו בהצלחה!');
}

String _getListTypeForProduct(String category) {
  const mapping = {
    'pharmacy': ['היגיינה אישית', 'מוצרי ניקיון'],
    'greengrocer': ['ירקות', 'פירות'],
    'butcher': ['בשר ודגים'],
    'bakery': ['מאפים'],
  };
  
  for (final entry in mapping.entries) {
    if (entry.value.contains(category)) {
      return entry.key;
    }
  }
  
  return 'supermarket';
}

Future<void> _saveByListType(Map<String, List<Map<String, dynamic>>> byListType) async {
  final dir = Directory('assets/data/by_list_type');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  const encoder = JsonEncoder.withIndent('  ');
  
  for (final entry in byListType.entries) {
    final listType = entry.key;
    final products = entry.value;
    
    products.sort((a, b) {
      final nameA = a['name']?.toString() ?? '';
      final nameB = b['name']?.toString() ?? '';
      return nameA.compareTo(nameB);
    });
    
    final file = File('assets/data/by_list_type/$listType.json');
    final jsonStr = encoder.convert(products);
    await file.writeAsString(jsonStr);
  }
}

Future<void> _saveByCategory(Map<String, List<Map<String, dynamic>>> byCategory) async {
  final dir = Directory('assets/data/by_category');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  const encoder = JsonEncoder.withIndent('  ');
  
  for (final entry in byCategory.entries) {
    final category = entry.key;
    final products = entry.value;
    
    products.sort((a, b) {
      final nameA = a['name']?.toString() ?? '';
      final nameB = b['name']?.toString() ?? '';
      return nameA.compareTo(nameB);
    });
    
    final fileName = _categoryToFileName(category);
    final file = File('assets/data/by_category/$fileName.json');
    final jsonStr = encoder.convert(products);
    await file.writeAsString(jsonStr);
  }
}

String _categoryToFileName(String category) {
  const mapping = {
    'מוצרי חלב': 'dairy',
    'מאפים': 'bakery',
    'ירקות': 'vegetables',
    'פירות': 'fruits',
    'בשר ודגים': 'meat',
    'אורז ופסטה': 'pasta',
    'שמנים ורטבים': 'sauces',
    'תבלינים ואפייה': 'spices',
    'ממתקים וחטיפים': 'snacks',
    'משקאות': 'beverages',
    'קפה ותה': 'coffee_tea',
    'מוצרי ניקיון': 'cleaning',
    'היגיינה אישית': 'toiletries',
    'שימורים': 'canned',
    'קפואים': 'frozen',
    'אחר': 'other',
  };
  
  return mapping[category] ?? 'other';
}

void printSummary(List<Map<String, dynamic>> products) {
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 סיכום');
  print('━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  print('📦 סה"כ מוצרים: ${products.length}');
  
  final categories = <String, int>{};
  for (final p in products) {
    final cat = p['category']?.toString() ?? 'אחר';
    categories[cat] = (categories[cat] ?? 0) + 1;
  }
  
  print('\n📁 מוצרים לפי קטגוריות (10 הראשונות):');
  final sortedCats = categories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  for (final entry in sortedCats.take(10)) {
    final icon = getCategoryIcon(entry.key);
    print('   $icon ${entry.key}: ${entry.value}');
  }
  
  final prices = products
      .map((p) => p['price'] as double?)
      .where((p) => p != null && p > 0)
      .cast<double>()
      .toList();
  
  if (prices.isNotEmpty) {
    prices.sort();
    final avg = prices.reduce((a, b) => a + b) / prices.length;
    
    print('\n💰 סטטיסטיקות מחירים:');
    print('   מינימום: ₪${prices.first.toStringAsFixed(2)}');
    print('   מקסימום: ₪${prices.last.toStringAsFixed(2)}');
    print('   ממוצע: ₪${avg.toStringAsFixed(2)}');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━');
}
