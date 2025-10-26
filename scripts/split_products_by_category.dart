import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔄 מתחיל לחלק מוצרים לפי קטגוריה...\n');

  // מיפוי בין שמות קטגוריות לשמות קבצים קיימים
  final Map<String, String> categoryMapping = {
    'פירות': 'fruits',
    'ירקות': 'vegetables',
    'מוצרי חלב': 'dairy',
    'בשר ודגים': 'meat_fish',
    'אורז ופסטה': 'rice_pasta',
    'תבלינים ואפייה': 'spices_baking',
    'ממתקים וחטיפים': 'sweets_snacks',
    'קפה ותה': 'coffee_tea',
    'היגיינה אישית': 'personal_hygiene',
    'אחר': 'other',
    // מיפוי גם לאנגלית למקרה ש-products.json באנגלית
    'fruits': 'fruits',
    'vegetables': 'vegetables',
    'dairy': 'dairy',
    'meat_fish': 'meat_fish',
    'rice_pasta': 'rice_pasta',
    'spices_baking': 'spices_baking',
    'sweets_snacks': 'sweets_snacks',
    'coffee_tea': 'coffee_tea',
    'personal_hygiene': 'personal_hygiene',
    'other': 'other',
  };

  // קריאת קובץ products.json
  final productsFile = File('assets/data/products.json');
  if (!productsFile.existsSync()) {
    print('❌ קובץ products.json לא נמצא!');
    return;
  }

  // פענוח JSON
  final jsonContent = await productsFile.readAsString();
  final List<dynamic> products = jsonDecode(jsonContent);
  
  print('✅ נמצאו ${products.length} מוצרים\n');

  // קיבוץ לפי קטגוריה
  final Map<String, List<Map<String, dynamic>>> productsByFile = {};
  
  // אתחול כל הקטגוריות
  for (var fileName in categoryMapping.values.toSet()) {
    productsByFile[fileName] = [];
  }
  
  int unmappedCount = 0;
  
  for (var product in products) {
    if (product is! Map<String, dynamic>) continue;
    
    final category = product['category'] as String?;
    if (category == null || category.isEmpty) {
      print('⚠️ מוצר ללא קטגוריה: ${product['name']}');
      productsByFile['other']!.add(product);
      continue;
    }

    // מציאת שם הקובץ המתאים
    final fileName = categoryMapping[category];
    
    if (fileName != null) {
      productsByFile[fileName]!.add(product);
    } else {
      print('⚠️ קטגוריה לא ממופה: "$category" (מוצר: ${product['name']})');
      productsByFile['other']!.add(product);
      unmappedCount++;
    }
  }

  print('📊 התפלגות מוצרים:\n');

  // יצירת תיקיית קטגוריות אם לא קיימת
  final categoryDir = Directory('assets/data/categories');
  if (!categoryDir.existsSync()) {
    categoryDir.createSync(recursive: true);
    print('📁 נוצרה תיקיה: assets/data/categories\n');
  }

  // שמירת כל קטגוריה לקובץ מתאים
  for (var entry in productsByFile.entries) {
    final fileName = entry.key;
    final products = entry.value;
    
    if (products.isEmpty) {
      print('⚪ $fileName.json: ריק (לא נמצאו מוצרים)');
      continue;
    }
    
    final categoryFile = File('assets/data/categories/$fileName.json');
    
    // המרה ל-JSON יפה
    final encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(products);
    
    await categoryFile.writeAsString(prettyJson);
    
    print('✅ $fileName.json: ${products.length} מוצרים');
  }

  print('\n📝 סיכום:');
  print('   • סה"כ מוצרים: ${products.length}');
  if (unmappedCount > 0) {
    print('   • קטגוריות לא ממופות: $unmappedCount (הועברו ל-other.json)');
  }
  print('\n🎉 הפיצול הושלם בהצלחה!');
  print('📂 הקבצים נמצאים ב: assets/data/categories/');
}
