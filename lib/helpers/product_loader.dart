// lib/helpers/product_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

const String kProductsAssetPath = "assets/data/products.json";

List<Map<String, dynamic>>? _productsListCache;

/// ✅ טעינת products.json (Array של מוצרים)
/// Cache משותף לכל הפרויקט - נטען פעם אחת בלבד
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
  
  debugPrint('⚠️ product_loader: מחזיר רשימה ריקה');
  _productsListCache = [];
  return _productsListCache!;
}

/// חיפוש מוצר לפי ברקוד
Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
  final products = await loadProductsAsList();
  
  try {
    return products.firstWhere(
      (p) => p['barcode']?.toString() == barcode,
    );
  } catch (e) {
    return null;
  }
}

/// ניקוי cache
void clearProductsCache() {
  _productsListCache = null;
  debugPrint('🧹 product_loader cache נוקה');
}

/// תאימות לאחור - ממיר Array לMap (לפי ברקוד כמפתח)
@deprecated
Future<Map<String, dynamic>> loadLocalProducts([
  String assetPath = kProductsAssetPath,
]) async {
  final list = await loadProductsAsList(assetPath);
  
  // המרה לMap: {barcode: product}
  return {
    for (var item in list) 
      item['barcode']?.toString() ?? '': item
  };
}
