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
// - lib/providers/products_provider.dart - Provider שמשתמש ב-repository
//
// 📱 Mobile Only: Yes
//
// 📝 Version: 2.0 - Added docstrings + version info
// 📅 Last Updated: 09/10/2025
//

/// Interface למוצרים - מגדיר methods חובה לכל Repository
abstract class ProductsRepository {
  /// טוען את כל המוצרים מה-Repository
  ///
  /// Returns: רשימת כל המוצרים הזמינים (עם/בלי מחירים)
  ///
  /// Example:
  /// ```dart
  /// final products = await repository.getAllProducts();
  /// print('נמצאו ${products.length} מוצרים');
  /// ```
  Future<List<Map<String, dynamic>>> getAllProducts();
  
  /// טוען מוצרים לפי קטגוריה מסוימת
  ///
  /// [category] - שם הקטגוריה (למשל: 'מוצרי חלב', 'ירקות')
  ///
  /// Returns: רשימת מוצרים מהקטגוריה המבוקשת
  ///
  /// Example:
  /// ```dart
  /// final dairy = await repository.getProductsByCategory('מוצרי חלב');
  /// print('${dairy.length} מוצרים בקטגוריה');
  /// ```
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category);
  
  /// חיפוש מוצר לפי ברקוד (חיפוש מדויק)
  ///
  /// [barcode] - מספר הברקוד (למשל: '7290000000001')
  ///
  /// Returns: נתוני המוצר או null אם לא נמצא
  ///
  /// Example:
  /// ```dart
  /// final product = await repository.getProductByBarcode('7290000000001');
  /// if (product != null) {
  ///   print('נמצא: ${product['name']}');
  /// }
  /// ```
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);
  
  /// חיפוש מוצרים לפי טקסט חופשי
  ///
  /// [query] - מחרוזת חיפוש (שם, מותג, קטגוריה)
  ///
  /// Returns: רשימת מוצרים שמתאימים לחיפוש
  ///
  /// Note: החיפוש מבוצע בשדות: name, brand, category
  ///
  /// Example:
  /// ```dart
  /// final results = await repository.searchProducts('חלב');
  /// print('נמצאו ${results.length} תוצאות');
  /// ```
  Future<List<Map<String, dynamic>>> searchProducts(String query);
  
  /// מחזיר את רשימת כל הקטגוריות הזמינות
  ///
  /// Returns: רשימת שמות קטגוריות ייחודיות
  ///
  /// Example:
  /// ```dart
  /// final categories = await repository.getCategories();
  /// print('${categories.length} קטגוריות זמינות');
  /// ```
  Future<List<String>> getCategories();
  
  /// רענון נתוני המוצרים (עדכון מחירים מ-API)
  ///
  /// [force] - אם true, מאלץ עדכון גם אם המחירים עדכניים
  ///
  /// Note: Method זה מעדכן **רק מחירים**, לא את פרטי המוצרים עצמם.
  ///       העדכון מתבצע מול API חיצוני (שופרסל).
  ///
  /// Example:
  /// ```dart
  /// // עדכון רגיל (רק אם עבר זמן)
  /// await repository.refreshProducts();
  ///
  /// // עדכון מאולץ
  /// await repository.refreshProducts(force: true);
  /// ```
  Future<void> refreshProducts({bool force = false});
}
