// 📄 File: scripts/fix_json_categories.dart
//
// 🛠️ סקריפט לתיקון אוטומטי של קטגוריות בקבצי JSON
//     - קורא את כל קבצי ה-JSON בתיקיית list_types
//     - מזהה ומתקן קטגוריות שגויות
//     - שומר גיבוי לפני השינוי
//     - מדפיס דוח מפורט
//
// 🚀 הרצה:
//     dart scripts/fix_json_categories.dart
//
// 📊 הסקריפט יציג:
//     - כמה מוצרים נבדקו
//     - כמה תוקנו
//     - דוח מפורט על כל תיקון

import 'dart:convert';
import 'dart:io';

// העתקת לוגיקת זיהוי הקטגוריות מ-CategoryDetectionService
class CategoryDetector {
  /// מיפוי מותגים לקטגוריות
  static const Map<String, String> _brandToCategory = {
    // מוצרי חלב
    'שטראוס': 'מוצרי חלב',
    'תנובה': 'מוצרי חלב',
    'יטבתה': 'מוצרי חלב',
    'גד': 'מוצרי חלב',
    'דנון': 'מוצרי חלב',
    'מילקי': 'מוצרי חלב',
    'קוטג\'': 'מוצרי חלב',

    // מאפים
    'אנג\'ל': 'מאפים',
    'ברמן': 'מאפים',
    'שניצר': 'לחמים',
    'פרג': 'מאפים',

    // בשר
    'טיב טעם': 'בשר ודגים',
    'זוגלובק': 'בשר ודגים',
    'עוף העמק': 'בשר ודגים',

    // ניקיון
    'סנו': 'מוצרי ניקיון',
    'קלין': 'מוצרי ניקיון',
    'ביו': 'מוצרי ניקיון',
  };

  /// מילות מפתח לזיהוי קטגוריות
  static const Map<String, List<String>> _categoryKeywords = {
    'מוצרי חלב': [
      'חלב',
      'גבינה',
      'יוגורט',
      'קוטג',
      'שמנת',
      'חמאה',
      'דנונה',
      'גמדים',
      'מילקי',
      'ביו',
      'פרו',
      'לבן',
      'בולגרי',
      'גבינת',
      'שמנ',
    ],
    'פירות': [
      'תפוח',
      'בנ',
      'אבטיח',
      'תות',
      'ענב',
      'אפרסק',
      'שזיף',
      'אגס',
      'תמר',
      'קיוי',
      'מנגו',
      'פטל',
      'דובדבן',
    ],
    'ירקות': [
      'עגבני',
      'מלפפון',
      'חסה',
      'כרוב',
      'גזר',
      'בצל',
      'שום',
      'פלפל',
      'דלעת',
      'תפוח אדמה',
      'בטטה',
      'קישוא',
    ],
    'בשר ודגים': [
      'בשר',
      'עוף',
      'הודו',
      'כבש',
      'בקר',
      'דג',
      'סלמון',
      'טונה',
      'נקניק',
      'נקנק',
      'המבורגר',
      'קבב',
      'שניצל',
    ],
    'מאפים': [
      'לחם',
      'חלה',
      'פיתה',
      'בגט',
      'כיכר',
      'עוגה',
      'עוגיות',
      'קרואסון',
      'דונאט',
      'מאפה',
      'בורקס',
      'ביס',
    ],
    'מוצרי ניקיון': [
      'ניקוי',
      'סבון',
      'אקונומיקה',
      'מרכך',
      'כביסה',
      'כלים',
      'אסלות',
      'רצפות',
      'חלון',
      'אבקת',
      'ג\'ל',
      'נוזל כלים',
    ],
    'היגיינה אישית': [
      'שמפו',
      'סבון גוף',
      'דאודורנט',
      'משחת שיניים',
      'מברשת שיניים',
      'טישו',
      'נייר טואלט',
      'חיתולים',
      'מגבונים',
    ],
    'קפואים': [
      'קפוא',
      'גלידה',
      'פיצה קפואה',
      'ירקות קפואים',
      'שניצל קפוא',
    ],
    'שימורים': [
      'שימור',
      'קופסא',
      'שימורי',
      'טונה בקופסא',
      'תירס שימורי',
      'חומוס בקופסא',
    ],
  };

  /// זיהוי קטגוריה אוטומטי
  static String? detectCategory({
    required String productName,
    String? brand,
    String? currentCategory,
  }) {
    // אם יש קטגוריה קיימת ותקינה - השתמש בה
    if (currentCategory != null &&
        currentCategory != 'אחר' &&
        currentCategory.isNotEmpty) {
      // בדיקה אם הקטגוריה באמת תקינה
      final nameLower = productName.toLowerCase();
      final brandLower = brand?.toLowerCase() ?? '';

      // אם המוצר מכיל מילות מפתח של קטגוריה אחרת - זה סימן לבעיה
      for (final entry in _categoryKeywords.entries) {
        if (entry.key != currentCategory) {
          for (final keyword in entry.value) {
            if (nameLower.contains(keyword.toLowerCase())) {
              // נמצאה סתירה - נמשיך לזיהוי מחדש
              print('   ⚠️  סתירה: "$productName" מסווג כ"$currentCategory" אבל מכיל "$keyword"');
              break;
            }
          }
        }
      }
    }

    final nameLower = productName.toLowerCase();

    // 1. נסה זיהוי לפי מותג
    if (brand != null && brand.isNotEmpty) {
      final brandLower = brand.toLowerCase();
      for (final entry in _brandToCategory.entries) {
        if (brandLower.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }

    // 2. נסה זיהוי לפי מילות מפתח
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (nameLower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    // 3. לא הצליח לזהות
    return currentCategory ?? 'אחר';
  }
}

void main() async {
  print('🛠️  סקריפט תיקון קטגוריות JSON');
  print('=' * 50);

  final listTypesDir = Directory('assets/data/list_types');
  if (!listTypesDir.existsSync()) {
    print('❌ תיקיית list_types לא נמצאה!');
    exit(1);
  }

  final jsonFiles = listTypesDir
      .listSync()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  print('📁 נמצאו ${jsonFiles.length} קבצי JSON\n');

  int totalProducts = 0;
  int totalFixed = 0;
  final fixes = <String, List<Map<String, String>>>{};

  for (final file in jsonFiles) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    print('📄 מעבד: $fileName');

    // קריאת הקובץ
    final content = await File(file.path).readAsString();
    final jsonData = jsonDecode(content);

    // תמיכה בשני פורמטים: Array או Object עם products
    final List<Map<String, dynamic>> products;
    final bool isArray;

    if (jsonData is List) {
      products = jsonData.cast<Map<String, dynamic>>();
      isArray = true;
    } else if (jsonData is Map<String, dynamic>) {
      products = (jsonData['products'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      isArray = false;
    } else {
      print('   ❌ פורמט JSON לא מזוהה');
      continue;
    }

    print('   📦 ${products.length} מוצרים');

    int fileFixed = 0;
    final fileChanges = <Map<String, String>>[];

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final name = product['name'] as String? ?? '';
      final brand = product['brand'] as String?;
      final currentCategory = product['category'] as String?;

      if (name.isEmpty) continue;

      totalProducts++;

      // זיהוי קטגוריה
      final detectedCategory = CategoryDetector.detectCategory(
        productName: name,
        brand: brand,
        currentCategory: currentCategory,
      );

      // בדיקה אם יש צורך בתיקון
      if (detectedCategory != null &&
          detectedCategory != currentCategory &&
          currentCategory != null &&
          currentCategory != 'אחר') {
        fileFixed++;
        totalFixed++;

        // שמירת השינוי
        product['category'] = detectedCategory;

        fileChanges.add({
          'name': name,
          'from': currentCategory,
          'to': detectedCategory,
        });
      }
    }

    if (fileFixed > 0) {
      print('   ✅ תוקנו $fileFixed קטגוריות');
      fixes[fileName] = fileChanges;

      // יצירת גיבוי
      final backupPath = '${file.path}.backup';
      await File(file.path).copy(backupPath);
      print('   💾 גיבוי נשמר: ${backupPath.split(Platform.pathSeparator).last}');

      // שמירת הקובץ המעודכן
      final encoder = const JsonEncoder.withIndent('  ');
      final updatedContent = isArray
          ? encoder.convert(products)
          : encoder.convert({'products': products});
      await File(file.path).writeAsString(updatedContent);
      print('   💾 קובץ עודכן');
    } else {
      print('   ✅ אין צורך בתיקונים');
    }

    print('');
  }

  // דוח סיכום
  print('=' * 50);
  print('📊 סיכום:');
  print('   📦 סה"כ מוצרים נבדקו: $totalProducts');
  print('   ✅ סה"כ תוקנו: $totalFixed');
  print('');

  if (fixes.isNotEmpty) {
    print('📝 דוח מפורט של תיקונים:');
    print('');
    fixes.forEach((fileName, changes) {
      print('📄 $fileName:');
      for (final change in changes) {
        print('   • ${change['name']}');
        print('     "${change['from']}" → "${change['to']}"');
      }
      print('');
    });
  }

  print('✅ הסקריפט הסתיים בהצלחה!');
  print('💡 קבצי גיבוי נשמרו עם סיומת .backup');
}
