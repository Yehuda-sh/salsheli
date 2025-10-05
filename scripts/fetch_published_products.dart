// scripts/fetch_published_products.dart
//
// סקריפט לשליפת מוצרים ממערכת "מחירון" (מחיר לצרכן)
// ושמירתם ב-products.json
// 
// שימוש:
// dart run scripts/fetch_published_products.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

// ================ תצורה ================

/// שם רשת למשיכת המוצרים
const String? chainName = 'רמי לוי';

/// נתיב הקובץ היעד
const String outputFile = 'assets/data/products.json';

/// האם לשמור רק מוצרים ייחודיים (לפי barcode)
const bool uniqueOnly = true;

/// מספר מוצרים מקסימלי לשמירה (null = הכל)
const int? maxProducts = 5000;

/// מחיר מינימלי (כדי להסיר מוצרים לא רלוונטיים)
const double minPrice = 0.5;

// =======================================

// פרטי חיבור למערכת מחירון
const String _baseUrl = 'https://url.publishedprices.co.il';
const String _loginPath = '/login/user';  // 🔴 שונה מ-/login!
const String _filesPath = '/file/d';
const String _username = 'RamiLevi';
const String _password = '';

void main() async {
  print('🛒 מתחיל שליפת מוצרים ממערכת מחירון...\n');
  
  try {
    // 1. התחברות
    print('🔐 מתחבר למערכת...');
    final sessionCookie = await login();
    
    if (sessionCookie == null) {
      print('❌ התחברות נכשלה');
      exit(1);
    }
    
    print('✅ התחברות הצליחה\n');
    
    // 2. קבלת רשימת קבצים
    print('📂 מחפש קבצי מחירים...');
    final files = await getAvailableFiles(sessionCookie, chainName: chainName);
    
    if (files.isEmpty) {
      print('❌ לא נמצאו קבצים');
      exit(1);
    }
    
    print('✓ נמצאו ${files.length} קבצים\n');
    
    // 3. הורדה ופענוח
    print('⬇️  מוריד ומפענח מוצרים...');
    final products = await downloadAndParse(sessionCookie, files.first['url']!);
    
    if (products.isEmpty) {
      print('❌ לא נמצאו מוצרים בקובץ');
      exit(1);
    }
    
    print('✓ פוענחו ${products.length} מוצרים גולמיים\n');
    
    // 4. עיבוד
    print('🔄 מעבד מוצרים...');
    final processed = processProducts(products);
    
    print('✓ עובדו ${processed.length} מוצרים\n');
    
    // 5. שמירה
    print('💾 שומר לקובץ...');
    await saveToFile(processed);
    
    // 6. סיכום
    printSummary(processed);
    
    print('\n✅ הסתיים בהצלחה!');
    print('📂 הקובץ נשמר ב: $outputFile');
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
    exit(1);
  }
}

/// התחברות למערכת מחירון
Future<String?> login() async {
  try {
    final client = http.Client();
    
    print('   📝 שולח: username=$_username, password=${_password.isEmpty ? "(ריק)" : "****"}');
    
    final response = await client.post(
      Uri.parse('$_baseUrl$_loginPath'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': _username,
        'password': _password,
        'r': '/file/d',  // 🆕 redirect destination
      },
    ).timeout(const Duration(seconds: 30));
    
    print('   📡 תגובה: status=${response.statusCode}');
    
    // בדיקה אם יש הפניה (redirect)
    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers['location'];
      print('   ↪️  הפניה ל: $location');
    }
    
    // אם התחברות הצליחה, בדרך כלל מקבלים 200 או 302
    if (response.statusCode == 200 || response.statusCode == 302) {
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final sessionCookie = cookies.split(';')[0];
        print('   🍪 Cookie: ${sessionCookie.substring(0, sessionCookie.length > 50 ? 50 : sessionCookie.length)}...');
        
        // בדיקת session - ננסה לגשת לדף הקבצים
        print('   🔄 בודק את ה-session...');
        final testResponse = await client.get(
          Uri.parse('$_baseUrl$_filesPath'),
          headers: {'Cookie': sessionCookie},
        ).timeout(const Duration(seconds: 10));
        
        if (testResponse.body.contains('Not currently logged in')) {
          print('   ❌ ה-session לא תקף!');
          print('   💡 בדוק שה-username וה-password נכונים');
          return null;
        } else {
          print('   ✅ ה-session תקף!');
        }
        
        return sessionCookie;
      } else {
        print('   ⚠️  אין cookie בתגובה');
      }
    } else {
      print('   ❌ status code לא מצביע על הצלחה');
      final body = response.body;
      if (body.length > 200) {
        print('   תוכן: ${body.substring(0, 200)}...');
      } else {
        print('   תוכן: $body');
      }
    }
    
    return null;
  } catch (e) {
    print('שגיאה בהתחברות: $e');
    return null;
  }
}

/// קבלת רשימת קבצים זמינים
Future<List<Map<String, String>>> getAvailableFiles(
  String sessionCookie, {
  String? chainName,
}) async {
  try {
    final client = http.Client();
    
    final queryParams = <String, String>{};
    if (chainName != null) queryParams['sn'] = chainName;
    queryParams['st'] = 'Prices';
    
    final uri = Uri.parse('$_baseUrl$_filesPath').replace(
      queryParameters: queryParams,
    );
    
    print('🌐 URL: $uri');
    print('📋 פרמטרים: $queryParams');
    
    final response = await client.get(
      uri,
      headers: {'Cookie': sessionCookie},
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      print('📄 תגובת השרת (${response.body.length} תווים)');
      print('🔍 5 שורות ראשונות:');
      final lines = response.body.split('\n').take(5).toList();
      for (var i = 0; i < lines.length; i++) {
        print('   ${i + 1}. ${lines[i].substring(0, lines[i].length > 80 ? 80 : lines[i].length)}...');
      }
      
      // שמירת ה-HTML לבדיקה
      final debugFile = File('debug_response.html');
      await debugFile.writeAsString(response.body);
      print('💾 התגובה נשמרה ל-debug_response.html');
      
      final files = parseFilesList(response.body);
      print('✓ נמצאו ${files.length} קישורים תואמים');
      return files;
    }
    
    return [];
  } catch (e) {
    print('שגיאה בקבלת רשימת קבצים: $e');
    return [];
  }
}

/// פענוח רשימת קבצים מ-HTML
List<Map<String, String>> parseFilesList(String html) {
  final files = <Map<String, String>>[];
  
  // Regex לחילוץ קישורים
  final linkRegex = RegExp(
    r'<a[^>]*href="([^"]*)"[^>]*>([^<]*(?:Price|פריס)[^<]*\.(?:xml|gz))',
    caseSensitive: false,
  );
  
  print('🔍 מחפש קישורים ב-HTML...');
  final matches = linkRegex.allMatches(html);
  print('   נמצאו ${matches.length} התאמות ל-regex');
  
  for (final match in matches) {
    final url = match.group(1);
    final filename = match.group(2);
    
    print('   ✓ נמצא: $filename -> $url');
    
    if (url != null && filename != null) {
      files.add({
        'url': url.startsWith('http') ? url : '$_baseUrl$url',
        'filename': filename.trim(),
      });
    }
  }
  
  if (files.isEmpty) {
    print('   ⚠️ לא נמצאו קבצים - בדוק את debug_response.html');
  }
  
  return files;
}

/// הורדה ופענוח של קובץ מחירים
Future<List<Map<String, dynamic>>> downloadAndParse(
  String sessionCookie,
  String fileUrl,
) async {
  try {
    final client = http.Client();
    
    final response = await client.get(
      Uri.parse(fileUrl),
      headers: {'Cookie': sessionCookie},
    ).timeout(const Duration(minutes: 5));
    
    if (response.statusCode != 200) {
      print('שגיאה בהורדה: ${response.statusCode}');
      return [];
    }
    
    final bytes = response.bodyBytes;
    
    // בדיקה אם זה קובץ דחוס
    String xmlContent;
    if (fileUrl.endsWith('.gz')) {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      xmlContent = utf8.decode(decompressed);
    } else {
      xmlContent = utf8.decode(bytes);
    }
    
    return parseXmlProducts(xmlContent);
  } catch (e) {
    print('שגיאה בהורדה/פענוח: $e');
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
        final itemCode = getXmlValue(item, 'ItemCode');
        final itemName = getXmlValue(item, 'ItemName');
        
        if (itemCode.isEmpty || itemName.isEmpty) continue;
        
        final product = {
          'barcode': itemCode,
          'name': itemName,
          'brand': getXmlValue(item, 'ManufacturerName'),
          'price': double.tryParse(getXmlValue(item, 'ItemPrice')) ?? 0.0,
          'unit': getXmlValue(item, 'UnitOfMeasure'),
          'quantity': double.tryParse(getXmlValue(item, 'Quantity')) ?? 0.0,
          'store': getXmlValue(item, 'ChainName'),
          'manufacturer_country': getXmlValue(item, 'ManufactureCountry'),
        };
        
        products.add(product);
      } catch (e) {
        continue;
      }
    }
    
    return products;
  } catch (e) {
    print('שגיאה בפענוח XML: $e');
    return [];
  }
}

/// קריאת ערך מ-XML
String getXmlValue(xml.XmlElement element, String tagName) {
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
    
    final name = p['name']?.toString() ?? '';
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
  if (uniqueOnly) {
    final seen = <String>{};
    processed = processed.where((p) {
      final barcode = p['barcode']?.toString() ?? '';
      if (barcode.isEmpty) return true;
      
      if (seen.contains(barcode)) return false;
      seen.add(barcode);
      return true;
    }).toList();
  }
  
  // הגבלת מספר
  if (maxProducts != null && processed.length > maxProducts!) {
    processed = processed.take(maxProducts!).toList();
  }
  
  // מיון
  processed.sort((a, b) {
    final nameA = a['name']?.toString() ?? '';
    final nameB = b['name']?.toString() ?? '';
    return nameA.compareTo(nameB);
  });
  
  return processed;
}

/// ניחוש קטגוריה לפי שם המוצר
String guessCategory(String itemName) {
  final name = itemName.toLowerCase();
  
  if (name.contains('חלב') ||
      name.contains('גבינה') ||
      name.contains('יוגורט') ||
      name.contains('חמאה') ||
      name.contains('שמנת')) return 'מוצרי חלב';
  
  if (name.contains('לחם') ||
      name.contains('חלה') ||
      name.contains('בורקס') ||
      name.contains('מאפה')) return 'מאפים';
  
  if (name.contains('עגבני') ||
      name.contains('מלפפון') ||
      name.contains('חסה') ||
      name.contains('גזר') ||
      name.contains('בצל') ||
      name.contains('שום') ||
      name.contains('פלפל')) return 'ירקות';
  
  if (name.contains('תפוח') ||
      name.contains('בננה') ||
      name.contains('תפוז') ||
      name.contains('אבטיח') ||
      name.contains('ענבים')) return 'פירות';
  
  if (name.contains('עוף') ||
      name.contains('בשר') ||
      name.contains('דג') ||
      name.contains('סלמון')) return 'בשר ודגים';
  
  if (name.contains('אורז') ||
      name.contains('פסטה') ||
      name.contains('קוסקוס') ||
      name.contains('נודלס')) return 'אורז ופסטה';
  
  if (name.contains('שמן') ||
      name.contains('קטשופ') ||
      name.contains('מיונז') ||
      name.contains('חומוס') ||
      name.contains('טחינה')) return 'שמנים ורטבים';
  
  if (name.contains('סוכר') ||
      name.contains('מלח') ||
      name.contains('פלפל') ||
      name.contains('קמח')) return 'תבלינים ואפייה';
  
  if (name.contains('שוקולד') ||
      name.contains('ממתק') ||
      name.contains('חטיף') ||
      name.contains('ביסלי')) return 'ממתקים וחטיפים';
  
  if (name.contains('קוקה') ||
      name.contains('מיץ') ||
      name.contains('משקה') ||
      name.contains('בירה') ||
      name.contains('יין')) return 'משקאות';
  
  if (name.contains('סבון') ||
      name.contains('ניקוי') ||
      name.contains('אקונומיקה') ||
      name.contains('מטהר')) return 'מוצרי ניקיון';
  
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
      // מוצר קיים - עדכון מחיר בלבד
      final existing = existingProducts[barcode]!;
      final oldPrice = existing['price'] as double? ?? 0.0;
      final newPrice = newProduct['price'] as double? ?? 0.0;
      
      if ((newPrice - oldPrice).abs() > 0.01) {
        // המחיר השתנה
        existing['price'] = newPrice;
        existing['store'] = newProduct['store']; // עדכון גם את החנות
        updatedPrices++;
      } else {
        // המחיר לא השתנה
        unchangedProducts++;
      }
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
