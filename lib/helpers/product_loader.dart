// 📄 File: lib/helpers/product_loader.dart
// 
// 📦 Purpose:
// Helper לטעינת מוצרים מ-assets/data/products.json
// משתמש ב-cache משותף לכל הפרויקט (נטען פעם אחת בלבד)
//
// 🔧 Dependencies:
// - assets/data/products.json (Array של מוצרים)
//
// 💡 Usage:
// ```dart
// final products = await loadProductsAsList();
// final product = await getProductByBarcode('7290000000001');
// clearProductsCache(); // ניקוי cache במצבי debug
// ```
//
// 🔗 Used by:
// - lib/data/demo_shopping_lists.dart
// - lib/data/rich_demo_data.dart
// - (עתידי: Providers/Repositories)

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

const String kProductsAssetPath = "assets/data/products.json";

/// 💾 Cache משותף - נטען פעם אחת בלבד
List<Map<String, dynamic>>? _productsListCache;

/// 📂 טעינת products.json (Array של מוצרים)
///
/// הפונקציה טוענת את קובץ המוצרים מ-assets ומחזירה רשימה של מוצרים.
/// משתמשת ב-cache משותף - נטען פעם אחת בלבד בכל הפרויקט.
///
/// Parameters:
/// - [assetPath]: נתיב לקובץ JSON (default: assets/data/products.json)
///
/// Returns:
/// - List<Map<String, dynamic>>: רשימת מוצרים
/// - רשימה ריקה במקרה של שגיאה
///
/// Example:
/// ```dart
/// final products = await loadProductsAsList();
/// print('נטענו ${products.length} מוצרים');
/// ```
Future<List<Map<String, dynamic>>> loadProductsAsList([
  String assetPath = kProductsAssetPath,
]) async {
  // החזרת cache אם קיים
  if (_productsListCache != null) {
    debugPrint('📦 product_loader: משתמש ב-cache (${_productsListCache!.length} מוצרים)');
    return _productsListCache!;
  }
  
  try {
    debugPrint('📂 product_loader: קורא קובץ: $assetPath');
    final content = await rootBundle.loadString(assetPath);
    
    debugPrint('   📄 גודל: ${content.length} תווים');
    
    // פרסור JSON
    final data = json.decode(content);
    
    if (data is List) {
      // המרה לרשימת Map
      _productsListCache = data
          .whereType<Map<String, dynamic>>()
          .toList();
      
      debugPrint('✅ product_loader: נטענו ${_productsListCache!.length} מוצרים');
      return _productsListCache!;
    } else {
      debugPrint('⚠️ product_loader: JSON לא Array, זה: ${data.runtimeType}');
    }
  } catch (e, stack) {
    debugPrint("❌ product_loader: שגיאה בקריאת $assetPath");
    debugPrint("   שגיאה: $e");
    if (kDebugMode) debugPrint("   Stack: $stack");
  }
  
  debugPrint('⚠️ product_loader: מחזיר רשימה ריקה (fallback)');
  _productsListCache = [];
  return _productsListCache!;
}

/// 🔍 חיפוש מוצר לפי ברקוד
///
/// מחפש מוצר ברשימה לפי barcode.
/// טוען את הרשימה מה-cache (או מהקובץ אם עדיין לא נטען).
///
/// Parameters:
/// - [barcode]: ברקוד לחיפוש (String)
///
/// Returns:
/// - Map<String, dynamic>? מוצר שנמצא
/// - null אם לא נמצא
///
/// Example:
/// ```dart
/// final product = await getProductByBarcode('7290000000001');
/// if (product != null) {
///   print('מצאתי: ${product["name"]}');
/// }
/// ```
Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
  debugPrint('🔍 product_loader: מחפש ברקוד: $barcode');
  final products = await loadProductsAsList();
  
  try {
    final product = products.firstWhere(
      (p) => p['barcode']?.toString() == barcode,
    );
    debugPrint('   ✅ נמצא: ${product["name"] ?? "לא ידוע"}');
    return product;
  } catch (e) {
    debugPrint('   ⚠️ לא נמצא ברקוד: $barcode');
    return null;
  }
}

/// 🧹 ניקוי cache
///
/// מנקה את ה-cache של המוצרים.
/// שימושי ב-debug או כשצריך לטעון מחדש את הנתונים.
///
/// Example:
/// ```dart
/// clearProductsCache();
/// final products = await loadProductsAsList(); // טעינה חדשה
/// ```
void clearProductsCache() {
  _productsListCache = null;
  debugPrint('🧹 product_loader: cache נוקה');
}
