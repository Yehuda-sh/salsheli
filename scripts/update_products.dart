// 📄 File: scripts/update_products.dart
//
// 🔄 סקריפט לעדכון מחירי מוצרים מ-Shufersal
//     - מעדכן מחירים למוצרים קיימים (לפי barcode)
//     - מוסיף מוצרים חדשים אם אין ברשימה
//     - עובד על assets/data/list_types/*.json
//
// 🚀 הרצה:
//     dart run scripts/update_products.dart
//
// 💡 תלויות:
//     flutter pub add http archive xml

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

// ========== תצורה ==========
const String shufersalBaseUrl = 'https://prices.shufersal.co.il/';
const int maxFilesToFetch = 3; // מספר קבצים מקסימלי לעיבוד
const double minPrice = 0.5; // מחיר מינימלי

// מיפוי קטגוריות שופרסל לקבצי list_types שלנו
const Map<String, String> categoryToListType = {
  'לחם ומאפים': 'bakery',
  'מאפים': 'bakery',
  'בשר': 'butcher',
  'בשר ודגים': 'butcher',
  'ירקות': 'greengrocer',
  'פירות': 'greengrocer',
  'תרופות': 'pharmacy',
  'ויטמינים': 'pharmacy',
  'תוספי תזונה': 'pharmacy',
  'מעדנייה': 'market',
  'דגים': 'market',
  'גבינות': 'market',
  'זיתים וכבושים': 'market',
  'תבלינים': 'market',
  'אוכל מוכן': 'market',
  // default: supermarket
};

void main() async {
  print('🔄 מעדכן מחירי מוצרים מ-Shufersal');
  print('=' * 50);

  try {
    // 1. טען מוצרים מ-Shufersal
    print('\n📥 מוריד מוצרים מ-Shufersal...');
    final shufersalProducts = await _fetchShufersalProducts();
    print('✅ התקבלו ${shufersalProducts.length} מוצרים\n');

    if (shufersalProducts.isEmpty) {
      print('⚠️  לא נמצאו מוצרים. מפסיק.');
      return;
    }

    // 2. טען קבצים קיימים
    final listTypesDir = Directory('assets/data/list_types');
    if (!listTypesDir.existsSync()) {
      print('❌ תיקיית list_types לא נמצאה!');
      exit(1);
    }

    final jsonFiles = listTypesDir
        .listSync()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => File(f.path))
        .toList();

    print('📁 נמצאו ${jsonFiles.length} קבצי list_types\n');

    // 3. עדכן כל קובץ
    int totalUpdated = 0;
    int totalAdded = 0;

    for (final file in jsonFiles) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final listType = fileName.replaceAll('.json', '');

      print('📄 מעבד: $fileName');

      // קרא קובץ קיים
      final existingContent = await file.readAsString();
      final existingProducts = (jsonDecode(existingContent) as List)
          .cast<Map<String, dynamic>>();

      print('   📦 ${existingProducts.length} מוצרים קיימים');

      // צור מפה לפי barcode לחיפוש מהיר
      final existingByBarcode = <String, Map<String, dynamic>>{};
      for (var product in existingProducts) {
        final barcode = product['barcode'] as String?;
        if (barcode != null && barcode.isNotEmpty) {
          existingByBarcode[barcode] = product;
        }
      }

      // סנן מוצרים רלוונטיים מ-Shufersal
      final relevantProducts = _filterProductsForListType(
        shufersalProducts,
        listType,
      );

      print('   🔍 נמצאו ${relevantProducts.length} מוצרים רלוונטיים');

      int updated = 0;
      int added = 0;

      for (var shufProduct in relevantProducts) {
        final barcode = shufProduct['barcode'] as String?;
        if (barcode == null || barcode.isEmpty) continue;

        if (existingByBarcode.containsKey(barcode)) {
          // עדכן מחיר
          final existing = existingByBarcode[barcode]!;
          final oldPrice = existing['price'];
          final newPrice = shufProduct['price'];

          if (oldPrice != newPrice) {
            existing['price'] = newPrice;
            updated++;
            print('   💰 עודכן: ${existing['name']} | $oldPrice → $newPrice ₪');
          }
        } else {
          // הוסף מוצר חדש
          existingProducts.add(shufProduct);
          added++;
          print('   ➕ נוסף: ${shufProduct['name']} | ${shufProduct['price']} ₪');
        }
      }

      // שמור קובץ מעודכן
      if (updated > 0 || added > 0) {
        // גיבוי
        final backupPath = '${file.path}.backup';
        await file.copy(backupPath);

        // שמירה
        const encoder = JsonEncoder.withIndent('  ');
        final updatedContent = encoder.convert(existingProducts);
        await file.writeAsString(updatedContent);

        print('   ✅ $updated עודכנו, $added נוספו');
        print('   💾 גיבוי: ${backupPath.split(Platform.pathSeparator).last}\n');

        totalUpdated += updated;
        totalAdded += added;
      } else {
        print('   ✅ אין שינויים\n');
      }
    }

    // 4. סיכום
    print('=' * 50);
    print('✅ הסתיים בהצלחה!');
    print('📊 סיכום:');
    print('   💰 $totalUpdated מחירים עודכנו');
    print('   ➕ $totalAdded מוצרים נוספו');
  } catch (e, stack) {
    print('❌ שגיאה: $e');
    print(stack);
    exit(1);
  }
}

/// 📥 הורדת מוצרים מ-Shufersal
Future<List<Map<String, dynamic>>> _fetchShufersalProducts() async {
  final allProducts = <Map<String, dynamic>>[];

  try {
    // 1. קבל רשימת קבצים מעמוד ראשון
    print('   🌐 גישה ל-$shufersalBaseUrl');
    final response = await http.get(Uri.parse(shufersalBaseUrl));

    if (response.statusCode != 200) {
      print('   ❌ שגיאה בגישה לאתר: ${response.statusCode}');
      return [];
    }

    // 2. חלץ קישורים לקבצי XML
    final fileUrls = _extractFileUrls(response.body);
    print('   📋 נמצאו ${fileUrls.length} קבצים זמינים');

    // 3. הורד ועבד קבצים
    final filesToProcess = fileUrls.take(maxFilesToFetch).toList();
    for (var i = 0; i < filesToProcess.length; i++) {
      final url = filesToProcess[i];
      print('   📦 מעבד קובץ ${i + 1}/$maxFilesToFetch...');

      final products = await _downloadAndParseFile(url);
      allProducts.addAll(products);
      print('      ✅ ${products.length} מוצרים');
    }
  } catch (e) {
    print('   ❌ שגיאה בהורדה: $e');
  }

  return allProducts;
}

/// 🔍 חילוץ URLs של קבצי XML מעמוד HTML
List<String> _extractFileUrls(String html) {
  final urls = <String>[];
  final regex = RegExp(r'href="([^"]*\.xml\.gz)"');
  final matches = regex.allMatches(html);

  for (final match in matches) {
    final url = match.group(1);
    if (url != null && !url.contains('..')) {
      urls.add('$shufersalBaseUrl$url');
    }
  }

  return urls;
}

/// 📦 הורדה ופענוח קובץ XML.gz
Future<List<Map<String, dynamic>>> _downloadAndParseFile(String url) async {
  try {
    // הורדה
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return [];

    // פירוק gzip
    final gzipBytes = response.bodyBytes;
    final decompressed = GZipDecoder().decodeBytes(gzipBytes);
    final xmlString = utf8.decode(decompressed);

    // פענוח XML
    final document = xml.XmlDocument.parse(xmlString);
    final items = document.findAllElements('Item');

    final products = <Map<String, dynamic>>[];

    for (final item in items) {
      try {
        final barcode = item.findElements('ItemCode').firstOrNull?.innerText;
        final name = item.findElements('ItemName').firstOrNull?.innerText;
        final priceStr = item.findElements('ItemPrice').firstOrNull?.innerText;
        final category = item.findElements('ItemType').firstOrNull?.innerText;
        final manufacturer = item.findElements('ManufacturerName').firstOrNull?.innerText;

        if (barcode == null || name == null || priceStr == null) continue;

        final price = double.tryParse(priceStr);
        if (price == null || price < minPrice) continue;

        products.add({
          'name': name.trim(),
          'barcode': barcode.trim(),
          'price': price,
          'category': category?.trim() ?? 'אחר',
          'brand': manufacturer?.trim() ?? '',
          'unit': 'יחידה',
          'store': 'שופרסל',
          'icon': _getCategoryIcon(category ?? ''),
        });
      } catch (e) {
        // דלג על מוצר בעייתי
        continue;
      }
    }

    return products;
  } catch (e) {
    return [];
  }
}

/// 🏷️ סינון מוצרים לפי list_type
List<Map<String, dynamic>> _filterProductsForListType(
  List<Map<String, dynamic>> products,
  String listType,
) {
  if (listType == 'supermarket') {
    // supermarket מקבל הכל
    return products;
  }

  return products.where((product) {
    final category = product['category'] as String? ?? '';
    final mappedType = categoryToListType[category] ?? 'supermarket';
    return mappedType == listType;
  }).toList();
}

/// 🎨 אייקון לפי קטגוריה
String _getCategoryIcon(String category) {
  if (category.contains('לחם') || category.contains('מאפ')) return '🍞';
  if (category.contains('בשר')) return '🥩';
  if (category.contains('ירק')) return '🥬';
  if (category.contains('פירות')) return '🍎';
  if (category.contains('חלב')) return '🥛';
  if (category.contains('משקאות')) return '🥤';
  if (category.contains('תרופ') || category.contains('ויטמין')) return '💊';
  return '📦';
}

extension on Iterable<xml.XmlElement> {
  xml.XmlElement? get firstOrNull => isEmpty ? null : first;
}
