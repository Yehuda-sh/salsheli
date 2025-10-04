// scripts/test_api.dart
//
// סקריפט בדיקה - בודק חיבור ל-API ומציג דוגמה למוצרים
// לא שומר כלום לקובץ
//
// שימוש:
// dart run scripts/test_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ================ תצורה ================
// העתק את ההגדרות מ-fetch_products.dart

const String apiBaseUrl = 'https://api.example.com';
const String productsEndpoint = '/products';
const String? authToken = null;

// =======================================

void main() async {
  print('🧪 בודק חיבור ל-API...\n');
  print('📍 API: $apiBaseUrl$productsEndpoint\n');
  
  try {
    // 1. בדיקת חיבור
    final products = await fetchProductsFromApi();
    
    if (products.isEmpty) {
      print('⚠️  ה-API החזיר רשימה רקה');
      exit(0);
    }
    
    // 2. הצג סטטיסטיקה
    print('✅ חיבור תקין!\n');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 סה"כ מוצרים: ${products.length}');
    
    // 3. הצג 5 מוצרים ראשונים
    print('\n📦 דוגמה ל-${products.length > 5 ? "5" : products.length} מוצרים ראשונים:\n');
    
    for (var i = 0; i < products.length && i < 5; i++) {
      final p = products[i];
      print('${i + 1}. ${_formatProduct(p)}');
    }
    
    if (products.length > 5) {
      print('   ... ועוד ${products.length - 5} מוצרים');
    }
    
    // 4. סטטיסטיקות נוספות
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _printStats(products);
    
    print('\n✅ הכל נראה תקין! אפשר להריץ fetch_products.dart');
    
  } catch (e) {
    print('❌ שגיאה: $e');
    print('\n💡 טיפים לפתרון בעיות:');
    print('   1. בדוק שכתובת ה-API נכונה');
    print('   2. בדוק שיש חיבור לאינטרנט');
    print('   3. אם נדרש אימות - ודא שה-token תקין');
    exit(1);
  }
}

Future<List<Map<String, dynamic>>> fetchProductsFromApi() async {
  final url = Uri.parse('$apiBaseUrl$productsEndpoint');
  
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };
  if (authToken != null && authToken!.isNotEmpty) {
    headers['Authorization'] = 'Bearer $authToken';
  }
  
  print('⏳ שולח בקשה...');
  final response = await http.get(url, headers: headers).timeout(
    const Duration(seconds: 30),
  );
  
  if (response.statusCode != 200) {
    throw Exception(
      'שגיאת API: ${response.statusCode}\n${response.body}',
    );
  }
  
  final data = jsonDecode(response.body);
  
  if (data is List) {
    return List<Map<String, dynamic>>.from(
      data.map((item) => item as Map<String, dynamic>),
    );
  } else if (data is Map<String, dynamic>) {
    final items = data['products'] ?? data['data'] ?? data['items'];
    if (items is List) {
      return List<Map<String, dynamic>>.from(
        items.map((item) => item as Map<String, dynamic>),
      );
    }
  }
  
  throw Exception('פורמט תשובה לא תקין');
}

String _formatProduct(Map<String, dynamic> p) {
  final name = p['name'] ?? 'ללא שם';
  final price = p['price']?.toString() ?? '-';
  final category = p['category'] ?? '';
  
  var result = name;
  if (category.isNotEmpty) result += ' ($category)';
  if (price != '-') result += ' - ₪$price';
  
  return result;
}

void _printStats(List<Map<String, dynamic>> products) {
  // ספירת מוצרים עם מחיר
  final withPrice = products.where((p) => p['price'] != null).length;
  
  // קטגוריות ייחודיות
  final categories = products
      .map((p) => p['category']?.toString() ?? 'ללא קטגוריה')
      .toSet()
      .toList();
  
  print('💰 מוצרים עם מחיר: $withPrice / ${products.length}');
  print('📁 קטגוריות: ${categories.length}');
  
  if (categories.length <= 10) {
    print('   קטגוריות: ${categories.join(", ")}');
  }
}
