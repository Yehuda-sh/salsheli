// scripts/fetch_gov_products.dart
//
// סקריפט להורדת מוצרים ממאגר משרד הכלכלה - שקיפות מחירים
// API ציבורי ללא צורך בהתחברות
// 
// שימוש:
// dart run scripts/fetch_gov_products.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ================ תצורה ================

/// נתיב הקובץ היעד
const String outputFile = 'assets/data/products.json';

/// מספר מוצרים מקסימלי לשמירה
const int maxProducts = 5000;

/// מחיר מינימלי
const double minPrice = 0.5;

// =======================================

// API endpoints
const String _baseUrl = 'https://data.gov.il/api/3/action';

// 🔍 נחפש את ה-resource הנכוןה דינמית
const String _packageId = 'prices-shop'; // מזהה המאגר

void main() async {
  print('🛒 מוריד מוצרים ממשרד הכלכלה...\n');
  
  try {
    // 1. שליפת נתונים
    print('⬇️  מוריד מוצרים מ-data.gov.il...');
    final products = await fetchProducts();
    
    if (products.isEmpty) {
      print('❌ לא נמצאו מוצרים');
      exit(1);
    }
    
    print('✓ הורדו ${products.length} מוצרים\n');
    
    // 2. עיבוד
    print('🔄 מעבד מוצרים...');
    final processed = processProducts(products);
    
    print('✓ עובדו ${processed.length} מוצרים\n');
    
    // 3. שמירה
    print('💾 שומר לקובץ...');
    await saveToFile(processed);
    
    // 4. סיכום
    printSummary(processed);
    
    print('\n✅ הסתיים בהצלחה!');
    print('📂 הקובץ נשמר ב: $outputFile');
    
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print('\nStack trace:\n$stack');
    exit(1);
  }
}

/// שליפת מוצרים מ-API
Future<List<Map<String, dynamic>>> fetchProducts() async {
  try {
    // שלב 1: מצא את ה-resource הנכון
    print('   🔍 מחפש את ה-dataset...');
    final packageUrl = Uri.parse('$_baseUrl/package_show').replace(
      queryParameters: {'id': _packageId},
    );
    
    final packageResponse = await http.get(packageUrl).timeout(const Duration(seconds: 30));
    
    if (packageResponse.statusCode != 200) {
      print('   ❌ לא נמצא dataset: ${packageResponse.statusCode}');
      print('   💡 מנסה גישה ישירה...');
      return await fetchProductsDirect();
    }
    
    final packageData = json.decode(packageResponse.body);
    
    if (packageData['success'] != true || packageData['result']?['resources'] == null) {
      print('   ⚠️  dataset ריק, מנסה גישה חלופית...');
      return await fetchProductsDirect();
    }
    
    final resources = packageData['result']['resources'] as List;
    print('   ✓ נמצאו ${resources.length} resources');
    
    // מצא resource עם מוצרים
    String? resourceId;
    for (final resource in resources) {
      final name = resource['name']?.toString().toLowerCase() ?? '';
      final description = resource['description']?.toString().toLowerCase() ?? '';
      
      if (name.contains('product') || name.contains('item') || 
          description.contains('product') || name.contains('מוצר')) {
        resourceId = resource['id'];
        print('   ✓ נמצא resource: ${resource['name']}');
        break;
      }
    }
    
    if (resourceId == null && resources.isNotEmpty) {
      resourceId = resources.first['id'];
      print('   ⚠️  משתמש ב-resource ראשון: ${resources.first['name']}');
    }
    
    if (resourceId == null) {
      print('   ❌ לא נמצא resource מתאים');
      return [];
    }
    
    // שלב 2: שלוף את המוצרים
    print('   ⬇️  מוריד מוצרים...');
    final dataUrl = Uri.parse('$_baseUrl/datastore_search').replace(
      queryParameters: {
        'resource_id': resourceId,
        'limit': maxProducts.toString(),
      },
    );
    
    final response = await http.get(dataUrl).timeout(const Duration(minutes: 2));
    
    if (response.statusCode != 200) {
      print('   ❌ שגיאה בהורדת מוצרים: ${response.statusCode}');
      return [];
    }
    
    final data = json.decode(response.body);
    
    if (data['success'] == true && data['result']?['records'] != null) {
      final records = data['result']['records'] as List;
      print('   ✓ הורדו ${records.length} רשומות');
      return records.cast<Map<String, dynamic>>();
    }
    
    return [];
  } catch (e) {
    print('   ⚠️  שגיאה ב-API: $e');
    print('   💡 מנסה גישה ישירה...');
    return await fetchProductsDirect();
  }
}

/// גישה ישירה לקובץ מוצרים (אם API לא עובד)
Future<List<Map<String, dynamic>>> fetchProductsDirect() async {
  try {
    // נסה להוריד ישירות מה-URL הציבורי
    final directUrl = 'https://data.gov.il/dataset/de7448a9-f5d9-4c98-97cf-80630251a0de/resource/e4075f59-ec68-4e6a-a7c6-f2a2b0145495/download/pricesfull.csv';
    
    print('   🌐 מנסה גישה ישירה ל-CSV...');
    
    final response = await http.get(Uri.parse(directUrl)).timeout(const Duration(minutes: 3));
    
    if (response.statusCode != 200) {
      print('   ❌ גישה ישירה נכשלה: ${response.statusCode}');
      return [];
    }
    
    print('   ✓ הורד CSV (${response.bodyBytes.length} bytes)');
    
    // פענוח CSV פשוט
    final lines = utf8.decode(response.bodyBytes).split('\n');
    if (lines.isEmpty) return [];
    
    final headers = lines[0].split(',');
    print('   📋 headers: ${headers.take(5).join(", ")}...');
    
    final products = <Map<String, dynamic>>[];
    
    for (var i = 1; i < lines.length && products.length < maxProducts; i++) {
      final values = lines[i].split(',');
      if (values.length < headers.length) continue;
      
      final product = <String, dynamic>{};
      for (var j = 0; j < headers.length && j < values.length; j++) {
        product[headers[j].trim()] = values[j].trim();
      }
      
      products.add(product);
    }
    
    print('   ✓ פוענחו ${products.length} מוצרים מ-CSV');
    return products;
    
  } catch (e) {
    print('   ❌ גישה ישירה נכשלה: $e');
    return [];
  }
}

/// עיבוד וסינון מוצרים
List<Map<String, dynamic>> processProducts(
  List<Map<String, dynamic>> products,
) {
  var processed = <Map<String, dynamic>>[];
  
  for (final p in products) {
    try {
      final price = double.tryParse(p['ItemPrice']?.toString() ?? '0') ?? 0.0;
      
      // סינון לפי מחיר
      if (price < minPrice) continue;
      
      final name = p['ItemName']?.toString() ?? '';
      if (name.isEmpty) continue;
      
      final category = guessCategory(name);
      
      processed.add({
        'name': name,
        'category': category,
        'icon': getCategoryIcon(category),
        'price': price,
        'barcode': p['ItemCode']?.toString() ?? '',
        'brand': p['ManufacturerName']?.toString() ?? '',
        'unit': p['UnitOfMeasure']?.toString() ?? '',
        'store': p['ChainName']?.toString() ?? '',
      });
    } catch (e) {
      continue;
    }
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
