// scripts/fetch_shufersal_products.dart
//
// סקריפט להורדת מוצרים משופרסל - ללא צורך בהתחברות!
// הקבצים פומביים וזמינים להורדה ישירה
// 
// שימוש:
// dart run scripts/fetch_shufersal_products.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

// ================ תצורה ================

/// נתיב הקובץ היעד
const String outputFile = 'assets/data/products.json';

/// מספר מוצרים מקסימלי לשמירה (בדיקה)
const int maxProducts = 20;

/// מחיר מינימלי
const double minPrice = 0.5;

// =======================================

// שופרסל - קבצי מחירים פומביים
const String _baseUrl = 'https://prices.shufersal.co.il/';

void main() async {
  print('🛒 מוריד מוצרים משופרסל...\n');
  
  try {
    // 1. קבלת רשימת קבצים זמינים
    print('📂 מחפש קבצי מחירים...');
    final fileUrls = await getFileUrls();
    
    if (fileUrls.isEmpty) {
      print('❌ לא נמצאו קבצי מחירים');
      exit(1);
    }
    
    print('✓ נמצאו ${fileUrls.length} קבצי מחירים\n');
    
    // 2. הורדת מספר קבצים (לא רק הראשון)
    print('⬇️  מוריד קבצי מחירים מסניפים שונים...');
    final allProducts = <Map<String, dynamic>>[];
    
    // נוריד מקסימום 3 סניפים כדי לא להכביד
    final filesToDownload = fileUrls.take(3).toList();
    
    for (var i = 0; i < filesToDownload.length; i++) {
      print('\n📦 סניף ${i + 1}/${filesToDownload.length}:');
      final products = await downloadAndParse(filesToDownload[i]);
      
      if (products.isNotEmpty) {
        allProducts.addAll(products);
        print('   ✓ נוספו ${products.length} מוצרים (סה"כ: ${allProducts.length})');
      }
    }
    
    if (allProducts.isEmpty) {
      print('❌ לא נמצאו מוצרים בקובץ');
      exit(1);
    }
    
    print('\n✓ פוענחו ${allProducts.length} מוצרים גולמיים\n');
    
    // 3. עיבוד (עם חיפוש חכם)
    print('🔄 מעבד מוצרים...');
    final processed = await processProducts(allProducts);
    
    print('✓ עובדו ${processed.length} מוצרים\n');
    
    // 4. שמירה
    print('💾 שומר לקובץ...');
    await saveToFile(processed);
    
    // 5. סיכום
    printSummary(processed);
    
    print('\n✅ הסתיים בהצלחה!');
    print('📂 הקובץ נשמר ב: $outputFile');
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
    exit(1);
  }
}

/// קבלת רשימת קישורי קבצים מהאתר
Future<List<String>> getFileUrls() async {
  try {
    print('   🌐 מתחבר ל-prices.shufersal.co.il...');
    
    final response = await http.get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 30));
    
    if (response.statusCode != 200) {
      print('   ❌ שגיאה: ${response.statusCode}');
      return [];
    }
    
    print('   ✓ קיבל תגובה (${response.body.length} תווים)');
    
    // חיפוש קישורי הורדה בעמוד
    // הקישור כולל SAS token עם פרמטרים רבים
    final regex = RegExp(
      r'https://pricesprodpublic\.blob\.core\.windows\.net/[^\s"<>]+\.gz[^\s"<>]*',
      caseSensitive: false,
    );
    
    final matches = regex.allMatches(response.body);
    final urls = <String>[];
    
    for (final match in matches) {
      final url = match.group(0);
      if (url != null && url.contains('Price')) {
        // 🆕 HTML decode - המר &amp; ל-&
        final decodedUrl = url
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"');
        urls.add(decodedUrl);
      }
    }
    
    print('   ✓ נמצאו ${urls.length} קישורי הורדה');
    
    // נציג דוגמה מלאה
    if (urls.isNotEmpty) {
      final firstUrl = urls.first;
      print('   📎 URL מלא ראשון (${firstUrl.length} תווים):');
      // נציג את כל ה-URL
      if (firstUrl.length > 200) {
        print('   ${firstUrl.substring(0, 200)}');
        print('   ...${firstUrl.substring(firstUrl.length - 50)}');
      } else {
        print('   $firstUrl');
      }
    }
    
    return urls;
    
  } catch (e) {
    print('   ❌ שגיאה בחיפוש קבצים: $e');
    return [];
  }
}

/// הורדה ופענוח של קובץ מחירים
Future<List<Map<String, dynamic>>> downloadAndParse(String fileUrl) async {
  try {
    print('   🌐 URL מלא (${fileUrl.length} תווים):');
    if (fileUrl.length > 150) {
      print('      ${fileUrl.substring(0, 100)}');
      print('      ...${fileUrl.substring(fileUrl.length - 50)}');
    } else {
      print('      $fileUrl');
    }
    print('   ⬇️  מוריד קובץ...');
    
    final response = await http.get(Uri.parse(fileUrl))
        .timeout(const Duration(minutes: 5));
    
    if (response.statusCode != 200) {
      print('   ❌ שגיאה בהורדה: ${response.statusCode}');
      return [];
    }
    
    final bytes = response.bodyBytes;
    print('   ✓ הורד ${bytes.length} bytes');
    
    // פענוח GZ
    print('   📦 מפענח GZ...');
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final xmlContent = utf8.decode(decompressed);
    
    print('   ✓ פוענח XML (${xmlContent.length} תווים)');
    
    // פענוח XML
    return parseXmlProducts(xmlContent);
    
  } catch (e) {
    print('   ❌ שגיאה בהורדה/פענוח: $e');
    return [];
  }
}

/// פענוח קובץ XML למוצרים
List<Map<String, dynamic>> parseXmlProducts(String xmlContent) {
  try {
    print('   📋 מפענח XML למוצרים...');
    
    final document = xml.XmlDocument.parse(xmlContent);
    final items = document.findAllElements('Item');
    
    print('   ✓ נמצאו ${items.length} פריטים ב-XML');
    
    // 🔍 הדפס את כל השדות של הפריט הראשון
    if (items.isNotEmpty) {
      print('\n   🔍 שדות זמינים בפריט ראשון:');
      final firstItem = items.first;
      for (final element in firstItem.children.whereType<xml.XmlElement>()) {
        final tagName = element.name.toString();
        final value = element.innerText.trim();
        if (value.isNotEmpty) {
          print('      - $tagName: ${value.substring(0, value.length > 50 ? 50 : value.length)}${value.length > 50 ? '...' : ''}');
        }
      }
      print('');
    }
    
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
    
    print('   ✓ פוענחו ${products.length} מוצרים');
    return products;
    
  } catch (e) {
    print('   ❌ שגיאה בפענוח XML: $e');
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

/// עיבוד וסינון מוצרים (עם חיפוש חכם)
Future<List<Map<String, dynamic>>> processProducts(
  List<Map<String, dynamic>> products,
) async {
  var processed = <Map<String, dynamic>>[];
  
  // 🆕 טען products.json קיים (אם יש)
  final existingProductsByBarcode = await _loadExistingProducts();
  print('   📦 נטענו ${existingProductsByBarcode.length} מוצרים קיימים מ-products.json\n');
  
  for (final p in products) {
    final price = p['price'] as double? ?? 0.0;
    
    // סינון לפי מחיר
    if (price < minPrice) continue;
    
    final rawName = p['name']?.toString() ?? '';
    if (rawName.isEmpty) continue;
    
    // 🆕 נקה את שם המוצר
    final name = _cleanProductName(rawName);
    
    // 🆕 זיהוי קטגוריה חכם - אופציה C!
    final barcode = p['barcode']?.toString() ?? '';
    final brand = p['brand']?.toString() ?? '';
    
    String category;
    final existingProduct = existingProductsByBarcode[barcode];
    
    if (existingProduct != null) {
      final existingCategory = existingProduct['category']?.toString() ?? 'אחר';
      
      if (existingCategory != 'אחר') {
        // קטגוריה קיימת ותקינה → השתמש בה!
        category = existingCategory;
      } else {
        // קטגוריה "אחר" → נסה לזהות מחדש
        category = guessCategoryByBrand(brand) ?? guessCategory(name);
      }
    } else {
      // מוצר חדש → זיהוי חכם
      category = guessCategoryByBrand(brand) ?? guessCategory(name);
    }
    
    // 🆕 הוסף קישור לתמונה משופרסל (media.shufersal.co.il)
    // פורמט: /product_images/products_360/{barcode}/files/360_assets/index/images/{barcode}_1.jpg
    // Fallback: תמונת ברירת מחדל (אייקון קטגוריה)
    final imageUrl = 'https://media.shufersal.co.il/product_images/products_360/${barcode}/files/360_assets/index/images/${barcode}_1.jpg';
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
  
  // הגבלת מספר
  if (processed.length > maxProducts) {
    processed = processed.take(maxProducts).toList();
  }
  
  // מיון
  processed.sort((a, b) {
    final nameA = a['name']?.toString() ?? '';
    final nameB = b['name']?.toString() ?? '';
    return nameA.compareTo(nameB);
  });
  
  return processed;
}

/// טעינת מוצרים קיימים מ-products.json
Future<Map<String, Map<String, dynamic>>> _loadExistingProducts() async {
  final file = File(outputFile);
  
  if (!await file.exists()) {
    return {};
  }
  
  try {
    final jsonContent = await file.readAsString();
    final List<dynamic> productsList = json.decode(jsonContent);
    
    final Map<String, Map<String, dynamic>> byBarcode = {};
    
    for (final p in productsList) {
      if (p is Map<String, dynamic>) {
        final barcode = p['barcode']?.toString();
        if (barcode != null && barcode.isNotEmpty) {
          byBarcode[barcode] = Map<String, dynamic>.from(p);
        }
      }
    }
    
    return byBarcode;
  } catch (e) {
    print('   ⚠️  שגיאה בטעינת products.json: $e');
    return {};
  }
}

/// ניקוי שם מוצר (משופר)
String _cleanProductName(String name) {
  var cleaned = name.trim();
  
  // הוסף רווח אחרי מספרים (12ביצים → 12 ביצים, 140ג → 140 ג)
  cleaned = cleaned.replaceAllMapped(
    RegExp(r'(\d)([א-ת])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  cleaned = cleaned.replaceAllMapped(
    RegExp(r'(\d)([a-zA-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  
  // הסר רווחים כפולים
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
  
  // הסר תווים מיוחדים מיותרים
  cleaned = cleaned.replaceAll(RegExp(r'[\*\+\#\@\$\%\^]'), '');
  
  // תקן גרש בעברית (g' → ג', kg → ק"ג)
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*g\b', caseSensitive: false), r'$1 גרם');
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*kg\b', caseSensitive: false), r'$1 ק"ג');
  cleaned = cleaned.replaceAll(RegExp(r'(\d+)\s*ml\b', caseSensitive: false), r'$1 מ"ל');
  
  return cleaned.trim();
}

/// זיהוי קטגוריה לפי מותג (עדיפות ראשונה)
String? guessCategoryByBrand(String brand) {
  if (brand.isEmpty) return null;
  
  final brandLower = brand.toLowerCase();
  
  // מוצרי חלב
  if (brandLower.contains('תנובה') ||
      brandLower.contains('יוטבתה') ||
      brandLower.contains('שטראוס') ||
      brandLower.contains('דנונה') ||
      brandLower.contains('גד') ||
      brandLower.contains('המשביר') ||
      brandLower.contains('טרה')) return 'מוצרי חלב';
  
  // ממתקים
  if (brandLower.contains('אסם') ||
      brandLower.contains('עלית') ||
      brandLower.contains('מאפיית חלבי') ||
      brandLower.contains('טעמן') ||
      brandLower.contains('נסטלה') ||
      brandLower.contains('פררו') ||
      brandLower.contains('קליק')) return 'ממתקים וחטיפים';
  
  // קפה ותה
  if (brandLower.contains('נסקפה') ||
      brandLower.contains('עלית קפה') ||
      brandLower.contains('לנדוור') ||
      brandLower.contains('ויסוצקי') ||
      brandLower.contains('אילנית')) return 'קפה ותה';
  
  // מוצרי ניקיון
  if (brandLower.contains('סנו') ||
      brandLower.contains('בריל') ||
      brandLower.contains('פרסיל') ||
      brandLower.contains('דורית') ||
      brandLower.contains('מאסטר') ||
      brandLower.contains('קלין')) return 'מוצרי ניקיון';
  
  // היגיינה
  if (brandLower.contains('ג\'ונסון') ||
      brandLower.contains('קולגייט') ||
      brandLower.contains('הד אנד שולדרס') ||
      brandLower.contains('דאב') ||
      brandLower.contains('ניוויאה') ||
      brandLower.contains('אקס סנס')) return 'היגיינה אישית';
  
  // בשר ודגים
  if (brandLower.contains('טיב טעם') ||
      brandLower.contains('זוגלובק') ||
      brandLower.contains('יהלום')) return 'בשר ודגים';
  
  return null;
}

/// ניחוש קטגוריה לפי שם המוצר (משופר)
String guessCategory(String itemName) {
  final name = itemName.toLowerCase();
  
  // 🥚 מוצרי חלב וביצים (מורחב)
  if (name.contains('חלב') ||
      name.contains('גבינה') ||
      name.contains('יוגורט') ||
      name.contains('חמאה') ||
      name.contains('שמנת') ||
      name.contains('קוטג') ||
      name.contains('קוטאג') ||
      name.contains('ביצים') ||
      name.contains('ביצה') ||
      name.contains('לבן') ||
      name.contains('לבנה') ||
      name.contains('עמק') ||
      name.contains('צפתית') ||
      name.contains('בולגרית') ||
      name.contains('פטה') ||
      name.contains('מוצרלה') ||
      name.contains('צהוב') ||
      name.contains('אמנטל') ||
      name.contains('פרמזן') ||
      name.contains('קממבר') ||
      name.contains('גאודה') ||
      name.contains('חלבי')) return 'מוצרי חלב';
  
  // 🍞 מאפים (מורחב)
  if (name.contains('לחם') ||
      name.contains('חלה') ||
      name.contains('בורקס') ||
      name.contains('מאפה') ||
      name.contains('פיתה') ||
      name.contains('פיתות') ||
      name.contains('בגט') ||
      name.contains('לחמניה') ||
      name.contains('לחמנייה') ||
      name.contains('בייגל') ||
      name.contains('קרואסון') ||
      name.contains('רוגלך') ||
      name.contains('סמבוסק') ||
      name.contains('מלווח') ||
      name.contains('לאפה')) return 'מאפים';
  
  // 🥬 ירקות (מורחב)
  if (name.contains('עגבני') ||
      name.contains('מלפפון') ||
      name.contains('חסה') ||
      name.contains('גזר') ||
      name.contains('בצל') ||
      name.contains('שום') ||
      name.contains('פלפל') ||
      name.contains('כרוב') ||
      name.contains('ברוקולי') ||
      name.contains('קונופיה') ||
      name.contains('קישוא') ||
      name.contains('בטטה') ||
      name.contains('תפוח אדמה') ||
      name.contains('תפו"א') ||
      name.contains('תירס') ||
      name.contains('חציל') ||
      name.contains('דלעת') ||
      name.contains('סלק') ||
      name.contains('צנון') ||
      name.contains('כרפס') ||
      name.contains('פטרוזיליה') ||
      name.contains('כוסברה') ||
      name.contains('נענע') ||
      name.contains('בזיליקום') ||
      name.contains('רוקט')) return 'ירקות';
  
  // 🍎 פירות (מורחב)
  if (name.contains('תפוח') && !name.contains('אדמה') || // לא תפוח אדמה!
      name.contains('בננה') ||
      name.contains('תפוז') ||
      name.contains('אבטיח') ||
      name.contains('ענבים') ||
      name.contains('מלון') ||
      name.contains('אגס') ||
      name.contains('אפרסק') ||
      name.contains('שזיף') ||
      name.contains('אגוזים') ||
      name.contains('קלמנטינה') ||
      name.contains('פומלה') ||
      name.contains('גרייפ') ||
      name.contains('קיוי') ||
      name.contains('מנגו') ||
      name.contains('פפאיה') ||
      name.contains('אננס') ||
      name.contains('רימון') ||
      name.contains('תות') ||
      name.contains('אוכמנייה') ||
      name.contains('דובדבן') ||
      name.contains('משמש') ||
      name.contains('אבוקדו')) return 'פירות';
  
  // 🥩 בשר ודגים (מורחב)
  if (name.contains('עוף') ||
      name.contains('בשר') ||
      name.contains('דג') ||
      name.contains('סלמון') ||
      name.contains('טונה') ||
      name.contains('שניצל') ||
      name.contains('פילה') ||
      name.contains('המבורגר') ||
      name.contains('קבב') ||
      name.contains('נקניק') ||
      name.contains('סטייק') ||
      name.contains('אנטריקוט') ||
      name.contains('צלי') ||
      name.contains('כרעיים') ||
      name.contains('שוקיים') ||
      name.contains('כנפיים') ||
      name.contains('חזה') ||
      name.contains('ירך') ||
      name.contains('כבד') ||
      name.contains('לב') ||
      name.contains('קורנדביף') ||
      name.contains('פסטרמה') ||
      name.contains('סרדינים') ||
      name.contains('הרינג') ||
      name.contains('בקלה')) return 'בשר ודגים';
  
  // 🍚 אורז ופסטה (מורחב)
  if (name.contains('אורז') ||
      name.contains('פסטה') ||
      name.contains('ספגטי') ||
      name.contains('קוסקוס') ||
      name.contains('נודלס') ||
      name.contains('רביולי') ||
      name.contains('פנה') ||
      name.contains('פוזילי') ||
      name.contains('ריגטוני') ||
      name.contains('פרפלה') ||
      name.contains('לזניה') ||
      name.contains('טורטיליני') ||
      name.contains('ניוקי') ||
      name.contains('בורגול') ||
      name.contains('קינואה') ||
      name.contains('פתיתים')) return 'אורז ופסטה';
  
  // 🫗 שמנים ורטבים (מורחב)
  if (name.contains('שמן') ||
      name.contains('קטשופ') ||
      name.contains('קצ\'אפ') ||
      name.contains('מיונז') ||
      name.contains('מיוניז') ||
      name.contains('חומוס') ||
      name.contains('טחינה') ||
      name.contains('חרדל') ||
      name.contains('רוטב') ||
      name.contains('מרינרה') ||
      name.contains('פסטו') ||
      name.contains('טריאקי') ||
      name.contains('סויה') ||
      name.contains('חומץ') ||
      name.contains('בלסמי') ||
      name.contains('ויניגרט') ||
      name.contains('ברביקיו') ||
      name.contains('צ\'ילי') ||
      name.contains('סלסה') ||
      name.contains('זיתים') ||
      name.contains('כבושים') ||
      name.contains('חמוצים') ||
      name.contains('ממרח')) return 'שמנים ורטבים';
  
  // 🧂 תבלינים ואפייה (מורחב)
  if (name.contains('סוכר') ||
      name.contains('מלח') ||
      name.contains('פלפל') && !name.contains('ירק') || // לא פלפל ירק!
      name.contains('קמח') ||
      name.contains('תבלין') ||
      name.contains('כמון') ||
      name.contains('קוריאנדר') ||
      name.contains('קרי') ||
      name.contains('שמרים') ||
      name.contains('אבקת אפיה') ||
      name.contains('אבקת סודה') ||
      name.contains('וניל') ||
      name.contains('קינמון') ||
      name.contains('הל') ||
      name.contains('פפריקה') ||
      name.contains('כורכום') ||
      name.contains('זעתר') ||
      name.contains('אורגנו') ||
      name.contains('בזיליקום') && name.contains('יבש') ||
      name.contains('רוזמרין') ||
      name.contains('זנגביל') ||
      name.contains('מוסקט') ||
      name.contains('קציצות תבלין') ||
      name.contains('שומשום') ||
      name.contains('קוקוס') && (name.contains('גרור') || name.contains('קמח'))) return 'תבלינים ואפייה';
  
  // 🍫 ממתקים וחטיפים (מורחב)
  if (name.contains('שוקולד') ||
      name.contains('ממתק') ||
      name.contains('חטיף') ||
      name.contains('ביסלי') ||
      name.contains('במבה') ||
      name.contains('גלידה') ||
      name.contains('עוגה') ||
      name.contains('עוגי') ||
      name.contains('וופל') ||
      name.contains('וייפר') ||
      name.contains('קרקר') ||
      name.contains('פריכית') ||
      name.contains('פצפוצי') ||
      name.contains('דורית') ||
      name.contains('צ\'יפס') ||
      name.contains('טורטיה') ||
      name.contains('נאצ\'וס') ||
      name.contains('חלבה') ||
      name.contains('דבש') ||
      name.contains('ריבה') ||
      name.contains('מרמלדה') ||
      name.contains('נוטלה') ||
      name.contains('סוכריה') ||
      name.contains('גומי') ||
      name.contains('מסטיק') ||
      name.contains('בונבון') ||
      name.contains('טופי') ||
      name.contains('קרמל')) return 'ממתקים וחטיפים';
  
  // 🥤 משקאות (מורחב)
  if (name.contains('קוקה') ||
      name.contains('מיץ') ||
      name.contains('משקה') ||
      name.contains('בירה') ||
      name.contains('יין') ||
      name.contains('ספרייט') ||
      name.contains('ספרינג') ||
      name.contains('מים') && (name.contains('מינרל') || name.contains('בקבוק')) ||
      name.contains('פפסי') ||
      name.contains('פאנטה') ||
      name.contains('שוופס') ||
      name.contains('סודה') ||
      name.contains('טוניק') ||
      name.contains('אייס טי') ||
      name.contains('נסטי') ||
      name.contains('ליפטון') ||
      name.contains('אנרג\' דרינק') ||
      name.contains('רד בול') ||
      name.contains('אקסטרה') ||
      name.contains('מי תפוז') ||
      name.contains('לימונדה') ||
      name.contains('משקה קל')) return 'משקאות';
  
  // ☕ קפה ותה (מורחב)
  if (name.contains('קפה') ||
      name.contains('קפסול') ||
      name.contains('נספרסו') ||
      name.contains('תה') && !name.contains('חלב') || // לא חלב תה!
      name.contains('קפואין') ||
      name.contains('אספרסו') ||
      name.contains('קפוצ\'ינו') ||
      name.contains('נס') && name.contains('קפה') ||
      name.contains('חליטה') ||
      name.contains('תמצית קפה') ||
      name.contains('קפה פילטר')) return 'קפה ותה';
  
  // 🧼 מוצרי ניקיון (מורחב)
  if (name.contains('סבון') && name.contains('כלים') ||
      name.contains('ניקוי') ||
      name.contains('אקונומיקה') ||
      name.contains('מטהר') ||
      name.contains('אמוניה') ||
      name.contains('לבנדר') ||
      name.contains('מרכך') && name.contains('כביסה') ||
      name.contains('אבקת כביסה') ||
      name.contains('ג\'ל כביסה') ||
      name.contains('מלבין') ||
      name.contains('כלורית') ||
      name.contains('כלור') ||
      name.contains('ווש') ||
      name.contains('ספוגים') ||
      name.contains('מגבות נייר') ||
      name.contains('נייר טואלט') ||
      name.contains('שקית אשפה') ||
      name.contains('כפפות') && name.contains('ניקיון') ||
      name.contains('מטליות') && name.contains('ניקיון')) return 'מוצרי ניקיון';
  
  // 🧴 היגיינה אישית (מורחב)
  if (name.contains('שמפו') ||
      name.contains('משחת שיניים') ||
      name.contains('משחה') && name.contains('שיניים') ||
      name.contains('דאודורנט') ||
      name.contains('סבון') && !name.contains('כלים') && !name.contains('כביסה') ||
      name.contains('תחבושת') ||
      name.contains('קרפרי') ||
      name.contains('טמפון') ||
      name.contains('מגבות') && name.contains('לחות') ||
      name.contains('מטליות') && name.contains('לחות') ||
      name.contains('קיסמי') ||
      name.contains('חוט דנטלי') ||
      name.contains('מברשת שיניים') ||
      name.contains('שפתון') ||
      name.contains('קרם') && (name.contains('פנים') || name.contains('גוף') || name.contains('ידיים')) ||
      name.contains('תער') ||
      name.contains('קצף גילוח') ||
      name.contains('ג\'ל גילוח') ||
      name.contains('מסיכה') && name.contains('פנים') ||
      name.contains('מחטבי') ||
      name.contains('תחתונים') ||
      name.contains('אטבי')) return 'היגיינה אישית';
  
  // 🥫 שימורים (מורחב)
  if (name.contains('שימורים') ||
      name.contains('שימור') ||
      name.contains('קונסרבה') ||
      name.contains('קופסת שימורים') ||
      name.contains('בקופסה') && (name.contains('טונה') || name.contains('תירס') || name.contains('אפונה')) ||
      name.contains('שעועית') && name.contains('קופסה') ||
      name.contains('חומוס') && name.contains('קופסה') ||
      name.contains('עגבניות') && name.contains('קופסה') ||
      name.contains('רסק עגבניות')) return 'שימורים';
  
  // ❄️ קפואים (מורחב)
  if (name.contains('קפוא') ||
      name.contains('קפואה') ||
      name.contains('קפואים') ||
      name.contains('קרח') ||
      name.contains('פיצה קפואה') ||
      name.contains('ירקות קפואים') ||
      name.contains('דגים קפואים') ||
      name.contains('משולשים קפואים') ||
      name.contains('פלפל קפוא') ||
      name.contains('ברוקולי קפוא')) return 'קפואים';
  
  return 'אחר';
}

/// אייקון לפי קטגוריה
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

/// שמירה חכמה לקובץ - מעדכן מחירים ומוסיף מוצרים חדשים
Future<void> saveToFile(List<Map<String, dynamic>> newProducts) async {
  final file = File(outputFile);
  
  final dir = file.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  print('\n🔄 משתמש במצב עדכון חכם...');
  
  // 1. קריאת קובץ קיים (אם יש)
  Map<String, Map<String, dynamic>> existingProducts = {};
  
  if (await file.exists()) {
    try {
      final existingJson = await file.readAsString();
      final List<dynamic> existingList = json.decode(existingJson);
      
      // המרה ל-Map לפי barcode (לחיפוש מהיר)
      for (final p in existingList) {
        if (p is Map<String, dynamic>) {
          final barcode = p['barcode']?.toString();
          if (barcode != null && barcode.isNotEmpty) {
            existingProducts[barcode] = Map<String, dynamic>.from(p);
          }
        }
      }
      
      print('   📦 נטענו ${existingProducts.length} מוצרים קיימים');
    } catch (e) {
      print('   ⚠️  לא הצלחתי לקרוא קובץ קיים, יוצר חדש: $e');
    }
  } else {
    print('   📝 קובץ לא קיים - יוצר חדש');
  }
  
  // 2. עדכון והוספה
  int updatedPrices = 0;
  int addedProducts = 0;
  int unchangedProducts = 0;
  
  for (final newProduct in newProducts) {
    final barcode = newProduct['barcode']?.toString();
    if (barcode == null || barcode.isEmpty) continue;
    
    if (existingProducts.containsKey(barcode)) {
      // מוצר קיים - עדכון מחיר + תמונות
      final existing = existingProducts[barcode]!;
      final oldPrice = existing['price'] as double? ?? 0.0;
      final newPrice = newProduct['price'] as double? ?? 0.0;
      
      if ((newPrice - oldPrice).abs() > 0.01) {
        // המחיר השתנה
        existing['price'] = newPrice;
        existing['store'] = newProduct['store'];
        updatedPrices++;
      } else {
        // המחיר לא השתנה
        unchangedProducts++;
      }
      
      // 🆕 עדכון תמונות תמיד (גם אם המחיר לא השתנה)
      existing['image_url'] = newProduct['image_url'];
      existing['fallback_image_url'] = newProduct['fallback_image_url'];
    } else {
      // מוצר חדש - הוספה
      existingProducts[barcode] = newProduct;
      addedProducts++;
    }
  }
  
  print('   ✅ עודכנו $updatedPrices מחירים');
  print('   ➕ נוספו $addedProducts מוצרים חדשים');
  print('   ⏸️  $unchangedProducts מוצרים ללא שינוי');
  print('   📦 סה"כ ${existingProducts.length} מוצרים בקובץ המעודכן');
  
  // 3. המרה חזרה ל-List
  final finalProducts = existingProducts.values.toList();
  
  // 4. מיון לפי שם
  finalProducts.sort((a, b) {
    final nameA = a['name']?.toString() ?? '';
    final nameB = b['name']?.toString() ?? '';
    return nameA.compareTo(nameB);
  });
  
  // 5. שמירה
  const encoder = JsonEncoder.withIndent('  ');
  final jsonStr = encoder.convert(finalProducts);
  
  await file.writeAsString(jsonStr);
  
  print('   💾 הקובץ נשמר בהצלחה!');
}

/// סיכום
void printSummary(List<Map<String, dynamic>> products) {
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 סיכום');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  print('📦 סה"כ מוצרים: ${products.length}');
  
  // קטגוריות
  final categories = <String, int>{};
  for (final p in products) {
    final cat = p['category']?.toString() ?? 'אחר';
    categories[cat] = (categories[cat] ?? 0) + 1;
  }
  
  print('\n📁 מוצרים לפי קטגוריות:');
  final sortedCats = categories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  for (final entry in sortedCats.take(10)) {
    final icon = getCategoryIcon(entry.key);
    print('   $icon ${entry.key}: ${entry.value}');
  }
  
  // מחירים
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
  
  // דוגמה
  print('\n📦 דוגמה ל-5 מוצרים:');
  for (var i = 0; i < products.length && i < 5; i++) {
    final p = products[i];
    final name = p['name'] ?? 'ללא שם';
    final price = p['price'] != null ? '₪${(p['price'] as double).toStringAsFixed(2)}' : '-';
    final cat = p['category'] ?? 'אחר';
    print('   ${i + 1}. $name ($cat) - $price');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
