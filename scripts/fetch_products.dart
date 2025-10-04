// scripts/fetch_products.dart
//
// סקריפט חד-פעמי לשליפה ושמירת מוצרים מ-API לקובץ מקומי
// 
// שימוש:
// dart run scripts/fetch_products.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ================ תצורה ================

/// כתובת ה-API שלך (שנה בהתאם!)
const String apiBaseUrl = 'https://api.example.com';

/// נתיב ה-endpoint למוצרים
const String productsEndpoint = '/products';

/// (אופציונלי) אסימון אימות אם נדרש
const String? authToken = null; // או: 'YOUR_TOKEN_HERE'

/// נתיב הקובץ היעד
const String outputFile = 'assets/data/products.json';

// =======================================

void main() async {
  print('🔄 מתחיל שליפת מוצרים מ-API...\n');
  
  try {
    // 1. שלח בקשה ל-API
    final products = await fetchProductsFromApi();
    
    if (products.isEmpty) {
      print('⚠️  לא נמצאו מוצרים ב-API');
      exit(1);
    }
    
    print('✓ נמצאו ${products.length} מוצרים\n');
    
    // 2. המר לפורמט מסודר
    final formatted = formatProducts(products);
    
    // 3. שמור לקובץ
    await saveToFile(formatted);
    
    print('✅ המוצרים נשמרו בהצלחה ל-$outputFile');
    print('📊 סה"כ ${products.length} מוצרים נשמרו');
    
  } catch (e) {
    print('❌ שגיאה: $e');
    exit(1);
  }
}

/// שולף מוצרים מה-API
Future<List<Map<String, dynamic>>> fetchProductsFromApi() async {
  final url = Uri.parse('$apiBaseUrl$productsEndpoint');
  print('📡 שולח בקשה ל-$url');
  
  // הכן headers
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };
  if (authToken != null && authToken!.isNotEmpty) {
    headers['Authorization'] = 'Bearer $authToken';
  }
  
  // שלח בקשה
  final response = await http.get(url, headers: headers).timeout(
    const Duration(seconds: 30),
  );
  
  if (response.statusCode != 200) {
    throw Exception(
      'שגיאת API: ${response.statusCode}\n${response.body}',
    );
  }
  
  // נתח תשובה
  final data = jsonDecode(response.body);
  
  // תמיכה בפורמטים שונים של תשובה
  if (data is List) {
    return List<Map<String, dynamic>>.from(
      data.map((item) => item as Map<String, dynamic>),
    );
  } else if (data is Map<String, dynamic>) {
    // אולי יש key 'products' או 'data'
    final items = data['products'] ?? data['data'] ?? data['items'];
    if (items is List) {
      return List<Map<String, dynamic>>.from(
        items.map((item) => item as Map<String, dynamic>),
      );
    }
  }
  
  throw Exception('פורמט תשובה לא תקין מה-API');
}

/// מעצב את המוצרים לפורמט JSON קריא
String formatProducts(List<Map<String, dynamic>> products) {
  // סינון שדות רלוונטיים בלבד
  final cleaned = products.map((product) {
    return {
      'id': product['id'] ?? '',
      'name': product['name'] ?? '',
      if (product['description'] != null) 'description': product['description'],
      if (product['brand'] != null) 'brand': product['brand'],
      if (product['package_size'] != null || product['packageSize'] != null)
        'packageSize': product['package_size'] ?? product['packageSize'],
      if (product['category'] != null) 'category': product['category'],
      if (product['price'] != null) 'price': product['price'],
    };
  }).toList();
  
  // המרה ל-JSON מעוצב
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(cleaned);
}

/// שומר את המוצרים לקובץ
Future<void> saveToFile(String content) async {
  final file = File(outputFile);
  
  // יצירת תיקיה אם לא קיימת
  final dir = file.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
    print('📁 נוצרה תיקייה: ${dir.path}');
  }
  
  // שמירת הקובץ
  await file.writeAsString(content);
  print('💾 נשמר לקובץ: ${file.path}');
}
