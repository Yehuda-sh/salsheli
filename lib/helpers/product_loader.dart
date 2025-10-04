// lib/helpers/product_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

const String kProductsAssetPath = "assets/data/products.json";

Map<String, dynamic>? _productsCache;

Future<Map<String, dynamic>> loadLocalProducts([
  String assetPath = kProductsAssetPath,
]) async {
  if (_productsCache != null) return _productsCache!;
  try {
    final content = await rootBundle.loadString(assetPath);
    final data = json.decode(content);
    if (data is Map<String, dynamic>) {
      _productsCache = data;
      return data;
    }
  } on FlutterError catch (e) {
    debugPrint("❌ קובץ מוצרים לא נמצא: $assetPath ($e)");
  } on FormatException catch (e) {
    debugPrint("❌ שגיאת פורמט JSON בקובץ מוצרים: $assetPath ($e)");
  } catch (e) {
    debugPrint("❌ שגיאה כללית בקריאת קובץ מוצרים: $assetPath ($e)");
  }
  _productsCache = {};
  return _productsCache!;
}

Future<List<Map<String, dynamic>>> loadProductsAsList([
  String assetPath = kProductsAssetPath,
]) async {
  final map = await loadLocalProducts(assetPath);
  return map.values.whereType<Map<String, dynamic>>().toList();
}

Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
  final map = await loadLocalProducts();
  final p = map[barcode];
  return (p is Map<String, dynamic>) ? p : null;
}

void clearProductsCache() {
  _productsCache = null;
}
