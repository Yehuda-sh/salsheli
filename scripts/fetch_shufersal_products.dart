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

/// מספר מוצרים מקסימלי לשמירה
const int maxProducts = 5000;

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
    
    // 3. עיבוד
    print('🔄 מעבד מוצרים...');
    final processed = processProducts(allProducts);
    
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

/// עיבוד וסינון מוצרים
List<Map<String, dynamic>> processProducts(
  List<Map<String, dynamic>> products,
) {
  var processed = <Map<String, dynamic>>[];
  
  for (final p in products) {
    final price = p['price'] as double? ?? 0.0;
    
    // סינון לפי מחיר
    if (price < minPrice) continue;
    
    final rawName = p['name']?.toString() ?? '';
    if (rawName.isEmpty) continue;
    
    // 🆕 נקה את שם המוצר
    final name = _cleanProductName(rawName);
    
    final category = guessCategory(name);
    
    processed.add({
      'name': name,
      'category': category,
      'icon': getCategoryIcon(category),
      'price': price,
      'barcode': p['barcode'],
      'brand': p['brand'],
      'unit': p['unit'],
      'store': p['store'],
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

/// ניקוי שם מוצר
String _cleanProductName(String name) {
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

/// ניחוש קטגוריה לפי שם המוצר
String guessCategory(String itemName) {
  final name = itemName.toLowerCase();
  
  // 🥚 מוצרי חלב וביצים
  if (name.contains('חלב') ||
      name.contains('גבינה') ||
      name.contains('יוגורט') ||
      name.contains('חמאה') ||
      name.contains('שמנת') ||
      name.contains('קוטג') ||
      name.contains('ביצים') ||
      name.contains('ביצה')) return 'מוצרי חלב';
  
  // 🍞 מאפים
  if (name.contains('לחם') ||
      name.contains('חלה') ||
      name.contains('בורקס') ||
      name.contains('מאפה') ||
      name.contains('פיתה') ||
      name.contains('בגט') ||
      name.contains('לחמניה')) return 'מאפים';
  
  // 🥬 ירקות
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
      name.contains('בטטה')) return 'ירקות';
  
  // 🍎 פירות
  if (name.contains('תפוח') ||
      name.contains('בננה') ||
      name.contains('תפוז') ||
      name.contains('אבטיח') ||
      name.contains('ענבים') ||
      name.contains('מלון') ||
      name.contains('אגס') ||
      name.contains('אפרסק') ||
      name.contains('שזיף') ||
      name.contains('אגוזים')) return 'פירות';
  
  // 🥩 בשר ודגים
  if (name.contains('עוף') ||
      name.contains('בשר') ||
      name.contains('דג') ||
      name.contains('סלמון') ||
      name.contains('טונה') ||
      name.contains('שניצל') ||
      name.contains('פילה') ||
      name.contains('המבורגר')) return 'בשר ודגים';
  
  // 🍚 אורז ופסטה
  if (name.contains('אורז') ||
      name.contains('פסטה') ||
      name.contains('ספגטי') ||
      name.contains('קוסקוס') ||
      name.contains('נודלס')) return 'אורז ופסטה';
  
  // 🫝 שמנים ורטבים
  if (name.contains('שמן') ||
      name.contains('קטשופ') ||
      name.contains('קטשופ') ||
      name.contains('מיונז') ||
      name.contains('מיונז') ||
      name.contains('חומוס') ||
      name.contains('טחינה') ||
      name.contains('חרדל') ||
      name.contains('רוטב')) return 'שמנים ורטבים';
  
  // 🧂 תבלינים ואפייה
  if (name.contains('סוכר') ||
      name.contains('מלח') ||
      name.contains('פלפל') ||
      name.contains('קמח') ||
      name.contains('תבלין') ||
      name.contains('כמון') ||
      name.contains('קוריאנדר') ||
      name.contains('קרי') ||
      name.contains('שמרים')) return 'תבלינים ואפייה';
  
  // 🍫 ממתקים וחטיפים
  if (name.contains('שוקולד') ||
      name.contains('ממתק') ||
      name.contains('חטיף') ||
      name.contains('ביסלי') ||
      name.contains('במבה') ||
      name.contains('גלידה') ||
      name.contains('עוגה') ||
      name.contains('וופלים') ||
      name.contains('חטיף')) return 'ממתקים וחטיפים';
  
  // 🥤 משקאות
  if (name.contains('קוקה') ||
      name.contains('מיץ') ||
      name.contains('משקה') ||
      name.contains('בירה') ||
      name.contains('יין') ||
      name.contains('ספרייט') ||
      name.contains('מים מינרלים') ||
      name.contains('פפסי')) return 'משקאות';
  
  // ☕ קפה ותה
  if (name.contains('קפה') ||
      name.contains('קפסול') ||
      name.contains('נספרסו') ||
      name.contains('תה') ||
      name.contains('קפואין')) return 'קפה ותה';
  
  // 🧼 מוצרי ניקיון
  if (name.contains('סבון') ||
      name.contains('ניקוי') ||
      name.contains('אקונומיקה') ||
      name.contains('מטהר') ||
      name.contains('אמוניה') ||
      name.contains('לבנדר') ||
      name.contains('מרכך כביסה')) return 'מוצרי ניקיון';
  
  // 🧴 היגיינה אישית
  if (name.contains('שמפו') ||
      name.contains('משחת שיניים') ||
      name.contains('דאודורנט') ||
      name.contains('סבון גוף') ||
      name.contains('תחבושת') ||
      name.contains('מגבות') ||
      name.contains('מטליות') ||
      name.contains('קיסמי שיניים') ||
      name.contains('שתן')) return 'היגיינה אישית';
  
  // 🥫 שימורים
  if (name.contains('שימורים') ||
      name.contains('כבושים') ||
      name.contains('חמוצים') ||
      name.contains('טונה בקופסה') ||
      name.contains('שימור')) return 'שימורים';
  
  // 🥖 קפואים
  if (name.contains('קפוא') ||
      name.contains('קרח')) return 'קפואים';
  
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

/// שמירה לקובץ
Future<void> saveToFile(List<Map<String, dynamic>> products) async {
  final file = File(outputFile);
  
  final dir = file.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  const encoder = JsonEncoder.withIndent('  ');
  final jsonStr = encoder.convert(products);
  
  await file.writeAsString(jsonStr);
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
