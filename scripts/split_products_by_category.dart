import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔄 מתחיל לחלק ולתקן מוצרים...\n');

  // === תיקון קטגוריות אוטומטי ===
  int fixedCount = 0;
  
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
    
    // תיקון קטגוריה אם שגויה
    String? category = product['category'] as String?;
    final correctedCategory = _detectCorrectCategory(product['name'] as String? ?? '', category);
    if (correctedCategory != null && correctedCategory != category) {
      product['category'] = correctedCategory;
      category = correctedCategory;
      fixedCount++;
    }
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

  print('\n📝 סיכום קטגוריות:');
  print('   • סה"כ מוצרים: ${products.length}');
  print('   • קטגוריות תוקנו: $fixedCount');
  if (unmappedCount > 0) {
    print('   • קטגוריות לא ממופות: $unmappedCount (הועברו ל-other.json)');
  }
  
  // === חלוקה לפי סוגי רשימות ===
  print('\n🎯 מחלק לפי סוגי רשימות...\n');
  
  final Map<String, List<Map<String, dynamic>>> productsByListType = {
    'supermarket': [],
    'pharmacy': [],
    'greengrocer': [],
    'butcher': [],
    'bakery': [],
    'market': [],
  };
  
  for (var product in products) {
    if (product is! Map<String, dynamic>) continue;
    
    final category = product['category'] as String?;
    if (category == null) continue;
    
    // סופרמרקט - הכל
    productsByListType['supermarket']!.add(product);
    
    // בית מרקחת - היגיינה וניקיון
    if (category == 'היגיינה אישית' || category == 'מוצרי ניקיון') {
      productsByListType['pharmacy']!.add(product);
    }
    
    // ירקן - ירקות ופירות
    if (category == 'ירקות' || category == 'פירות') {
      productsByListType['greengrocer']!.add(product);
    }
    
    // אטליז - בשר ודגים
    if (category == 'בשר ודגים') {
      productsByListType['butcher']!.add(product);
    }
    
    // מאפייה - לחמים ומאפים
    if (category == 'מאפים' || category == 'לחמים') {
      productsByListType['bakery']!.add(product);
    }
    
    // שוק - מעורב (פירות, ירקות, בשר, גבינות)
    if (category == 'ירקות' || category == 'פירות' || 
        category == 'בשר ודגים' || category == 'מוצרי חלב') {
      productsByListType['market']!.add(product);
    }
  }
  
  // יצירת תיקיית list_types
  final listTypesDir = Directory('assets/data/list_types');
  if (!listTypesDir.existsSync()) {
    listTypesDir.createSync(recursive: true);
    print('📁 נוצרה תיקיה: assets/data/list_types\n');
  }
  
  // שמירת כל סוג רשימה לקובץ
  final encoder = JsonEncoder.withIndent('  ');
  for (var entry in productsByListType.entries) {
    final listType = entry.key;
    final products = entry.value;
    
    final listTypeFile = File('assets/data/list_types/$listType.json');
    final prettyJson = encoder.convert(products);
    await listTypeFile.writeAsString(prettyJson);
    
    print('✅ $listType.json: ${products.length} מוצרים');
  }
  
  print('\n📝 סיכום סופי:');
  print('   • סה"כ מוצרים: ${products.length}');
  print('   • קטגוריות תוקנו: $fixedCount');
  print('   • קבצי קטגוריות: ${productsByFile.length}');
  print('   • קבצי סוגי רשימות: ${productsByListType.length}');
  print('\n🎉 הפיצול הושלם בהצלחה!');
  print('📂 קבצים:');
  print('   • categories/: חלוקה לפי קטגוריות');
  print('   • list_types/: חלוקה לפי סוגי רשימות');
}

/// זיהוי קטגוריה נכונה לפי שם המוצר
String? _detectCorrectCategory(String name, String? currentCategory) {
  if (name.isEmpty) return null;
  
  final nameLower = name.toLowerCase();
  
  // היגיינה אישית
  if (nameLower.contains('קרפרי') || nameLower.contains('תחבושת') ||
      nameLower.contains('טמפון') || nameLower.contains('משחת שיניים') ||
      nameLower.contains('שמפו') || nameLower.contains('סבון') ||
      nameLower.contains('מברשת שיניים') || nameLower.contains('דאודורנט') ||
      nameLower.contains('תער') || nameLower.contains('קצף גילוח')) {
    return 'היגיינה אישית';
  }
  
  // ממתקים וחטיפים
  if (nameLower.contains('קרקר') || nameLower.contains('ביסלי') ||
      nameLower.contains('במבה') || nameLower.contains('שוקולד') ||
      nameLower.contains('וופל') || nameLower.contains('עוגיות') ||
      nameLower.contains('חטיף') || nameLower.contains('סוכריות')) {
    return 'ממתקים וחטיפים';
  }
  
  // אורז ופסטה
  if (nameLower.contains('רביולי') || nameLower.contains('פסטה') ||
      nameLower.contains('ספגטי') || nameLower.contains('אורז') ||
      nameLower.contains('ניוקי') || nameLower.contains('קוסקוס') ||
      nameLower.contains('פתיתים')) {
    return 'אורז ופסטה';
  }
  
  // מוצרי חלב
  if (nameLower.contains('גבינה') || nameLower.contains('קשקבל') ||
      nameLower.contains('חלב') || nameLower.contains('יוגורט') ||
      nameLower.contains('קוטג') || nameLower.contains('שמנת') ||
      nameLower.contains('חמאה') || nameLower.contains('לבנה') ||
      nameLower.contains('צפתית') || nameLower.contains('בולגרית')) {
    return 'מוצרי חלב';
  }
  
  // בשר ודגים
  if (nameLower.contains('עוף') || nameLower.contains('בשר') ||
      nameLower.contains('דג') || nameLower.contains('סלמון') ||
      nameLower.contains('טונה') || nameLower.contains('נקניק') ||
      nameLower.contains('קבב') || nameLower.contains('המבורגר') ||
      nameLower.contains('שניצל') || nameLower.contains('סטייק')) {
    return 'בשר ודגים';
  }
  
  // פירות
  if (nameLower.contains('תפוח') || nameLower.contains('בננה') ||
      nameLower.contains('תפוז') || nameLower.contains('אבטיח') ||
      nameLower.contains('אפרסק') || nameLower.contains('ענבים') ||
      nameLower.contains('תות') || nameLower.contains('מנגו') ||
      nameLower.contains('אגס') || nameLower.contains('שזיף')) {
    return 'פירות';
  }
  
  // ירקות
  if (nameLower.contains('עגבנ') || nameLower.contains('מלפפון') ||
      nameLower.contains('בצל') || nameLower.contains('גזר') ||
      nameLower.contains('חסה') || nameLower.contains('כרוב') ||
      nameLower.contains('פלפל') || nameLower.contains('בטטה') ||
      nameLower.contains('תפוח אדמה') || nameLower.contains('דלעת')) {
    return 'ירקות';
  }
  
  // תבלינים ואפייה
  if (nameLower.contains('קמח') || nameLower.contains('שמרים') ||
      nameLower.contains('אבקת אפייה') || nameLower.contains('וניל') ||
      nameLower.contains('סוכר') || nameLower.contains('מלח') ||
      nameLower.contains('פלפל שחור') || nameLower.contains('כורכום') ||
      nameLower.contains('פפריקה') || nameLower.contains('קינמון')) {
    return 'תבלינים ואפייה';
  }
  
  // קפה ותה
  if (nameLower.contains('קפה') || nameLower.contains('נס קפה') ||
      nameLower.contains('תה') || nameLower.contains('עלי תה') ||
      nameLower.contains('תה ירוק') || nameLower.contains('חליטה')) {
    return 'קפה ותה';
  }
  
  // מוצרי ניקיון
  if (nameLower.contains('אקונומיקה') || nameLower.contains('ניקיון') ||
      nameLower.contains('אבקת כביסה') || nameLower.contains('מרכך') ||
      nameLower.contains('נייר טואלט') || nameLower.contains('מגבות נייר') ||
      nameLower.contains('סבון כלים') || nameLower.contains('אקונומיקה')) {
    return 'מוצרי ניקיון';
  }
  
  // אם לא זוהה - החזר את הקטגוריה הנוכחית
  return null;
}
