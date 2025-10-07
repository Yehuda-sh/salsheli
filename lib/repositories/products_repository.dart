// 📄 File: lib/repositories/products_repository.dart
//
// 🎯 Purpose: Interface למוצרים - מגדיר את החוזה לכל מימושי Products Repository
//
// 📋 Implementations:
// - HybridProductsRepository (main.dart) - מימוש הייצור הרשמי
// - LocalProductsRepository - גישה ישירה ל-Hive
// - FirebaseProductsRepository - גישה ישירה ל-Firestore (fallback)
//
// 🔗 Related:
// - lib/repositories/hybrid_products_repository.dart - המימוש המשולב
// - lib/repositories/local_products_repository.dart - Hive storage
// - lib/repositories/firebase_products_repository.dart - Firestore fallback
//
// 📱 Mobile Only: Yes

/// Interface למוצרים - מגדיר methods חובה לכל Repository
abstract class ProductsRepository {
  /// טעינת כל המוצרים
  Future<List<Map<String, dynamic>>> getAllProducts();
  
  /// טעינת מוצרים לפי קטגוריה
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category);
  
  /// חיפוש מוצר לפי ברקוד
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);
  
  /// חיפוש מוצרים לפי טקסט
  Future<List<Map<String, dynamic>>> searchProducts(String query);
  
  /// קבלת כל הקטגוריות
  Future<List<String>> getCategories();
  
  /// רענון מוצרים (עדכון מחירים)
  Future<void> refreshProducts({bool force = false});
}
