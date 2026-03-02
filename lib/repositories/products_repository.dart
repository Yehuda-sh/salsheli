// 📄 File: lib/repositories/products_repository.dart
//
// 🎯 Purpose: Interface למוצרים - מגדיר את החוזה לכל מימושי Products Repository
//
// 📋 Features:
//     - תיעוד מקיף ל-Intellisense
//     - תמיכה בחיפוש Reactive (Streams)
//     - Pagination support (limit/offset)
//     - Fallback אוטומטי לסופרמרקט עבור סוגי רשימות לא נתמכים
//
// 📋 Implementations:
//     - HybridProductsRepository - מימוש הייצור (Local + Firebase)
//     - LocalProductsRepository - JSON assets
//     - FirebaseProductsRepository - Firestore fallback
//
// 🔗 Related:
//     - lib/repositories/hybrid_products_repository.dart - המימוש המשולב
//     - lib/repositories/local_products_repository.dart - JSON storage
//     - lib/repositories/firebase_products_repository.dart - Firestore fallback
//     - lib/providers/products_provider.dart - Provider שמשתמש ב-repository
//
// 📜 History:
//     - v1.0 (09/10/2025): Interface ראשוני
//     - v2.0 (09/10/2025): הוספת docstrings + getProductsByListType
//     - v3.0 (22/02/2026): ארגון לפי קטגוריות, searchProductsStream, תיעוד מלא
//
// Version: 3.0
// Last Updated: 22/02/2026

/// Interface למוצרים - מגדיר methods חובה לכל Repository
///
/// כל מקור נתונים (Local JSON, Firebase, Hybrid) חייב לממש את הממשק הזה.
///
/// המתודות מחולקות לשלושה עולמות:
/// - **Fetch** - טעינת מוצרים (לפי סוג, קטגוריה, ברקוד)
/// - **Search** - חיפוש טקסט חופשי (Future + Stream)
/// - **Management** - רענון וקטגוריות
abstract class ProductsRepository {
  // ========================================
  // Fetch - טעינת מוצרים
  // ========================================

  /// טוען את כל המוצרים מה-Repository
  ///
  /// Parameters:
  ///   - [limit]: מספר מקסימלי של מוצרים להחזיר (null = הכל)
  ///   - [offset]: כמה מוצרים לדלג (לדפדוף)
  ///
  /// Returns: רשימת כל המוצרים הזמינים
  ///
  /// Example:
  /// ```dart
  /// final all = await repository.getAllProducts();
  /// final page2 = await repository.getAllProducts(limit: 100, offset: 100);
  /// ```
  Future<List<Map<String, dynamic>>> getAllProducts({
    int? limit,
    int? offset,
  });

  /// טוען מוצרים לפי סוג רשימה (list_type)
  ///
  /// Parameters:
  ///   - [listType]: סוג הרשימה:
  ///     - `supermarket` - כל המוצרים
  ///     - `pharmacy` - היגיינה וניקיון
  ///     - `greengrocer` - פירות וירקות
  ///     - `butcher` - בשר ועוף
  ///     - `bakery` - לחם ומאפים
  ///     - `market` - מעורב
  ///     - `household` / `other` - **Fallback אוטומטי ל-supermarket**
  ///   - [limit]: מספר מקסימלי של מוצרים (null = הכל)
  ///   - [offset]: כמה מוצרים לדלג (לדפדוף)
  ///
  /// Returns: רשימת מוצרים מסוננת לפי סוג הרשימה
  ///
  /// Note: אם הסוג לא נתמך (household/other), ייעשה **fallback אוטומטי**
  /// ל-supermarket ללא שגיאה.
  ///
  /// Example:
  /// ```dart
  /// final bakery = await repository.getProductsByListType('bakery');
  /// final first100 = await repository.getProductsByListType('supermarket', limit: 100);
  /// ```
  Future<List<Map<String, dynamic>>> getProductsByListType(
    String listType, {
    int? limit,
    int? offset,
  });

  /// טוען מוצרים לפי קטגוריה
  ///
  /// Parameters:
  ///   - [category]: שם הקטגוריה (למשל: 'מוצרי חלב', 'ירקות')
  ///
  /// Returns: רשימת מוצרים מהקטגוריה המבוקשת
  ///
  /// Example:
  /// ```dart
  /// final dairy = await repository.getProductsByCategory('מוצרי חלב');
  /// ```
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category);

  /// חיפוש מוצר לפי ברקוד (חיפוש מדויק)
  ///
  /// Parameters:
  ///   - [barcode]: מספר הברקוד (למשל: '7290000000001')
  ///
  /// Returns: נתוני המוצר או `null` אם לא נמצא
  ///
  /// Example:
  /// ```dart
  /// final product = await repository.getProductByBarcode('7290000000001');
  /// if (product != null) print('נמצא: ${product['name']}');
  /// ```
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);

  // ========================================
  // Search - חיפוש
  // ========================================

  /// חיפוש מוצרים לפי טקסט חופשי (one-shot)
  ///
  /// Parameters:
  ///   - [query]: מחרוזת חיפוש (שם או מותג)
  ///
  /// Returns: רשימת מוצרים שמתאימים לחיפוש
  ///
  /// Example:
  /// ```dart
  /// final results = await repository.searchProducts('חלב');
  /// ```
  Future<List<Map<String, dynamic>>> searchProducts(String query);

  /// חיפוש מוצרים Reactive - מחזיר Stream של תוצאות
  ///
  /// מאפשר ל-UI להציג תוצאות מתעדכנות בזמן אמת
  /// בזמן שהמשתמש מקליד (type-ahead).
  ///
  /// Parameters:
  ///   - [query]: מחרוזת חיפוש (שם או מותג)
  ///
  /// Returns: Stream חד-פעמי עם תוצאות החיפוש
  ///
  /// Example:
  /// ```dart
  /// repository.searchProductsStream('חלב').listen((results) {
  ///   print('נמצאו ${results.length} תוצאות');
  /// });
  /// ```
  Stream<List<Map<String, dynamic>>> searchProductsStream(String query);

  // ========================================
  // Management - ניהול וקטגוריות
  // ========================================

  /// מחזיר את רשימת כל הקטגוריות הזמינות
  ///
  /// Returns: רשימת שמות קטגוריות ייחודיות (ממוינת)
  ///
  /// Example:
  /// ```dart
  /// final categories = await repository.getCategories();
  /// ```
  Future<List<String>> getCategories();

  /// רענון נתוני המוצרים
  ///
  /// Parameters:
  ///   - [force]: אם `true`, מאלץ עדכון גם אם הנתונים עדכניים
  ///
  /// Example:
  /// ```dart
  /// await repository.refreshProducts();         // רגיל
  /// await repository.refreshProducts(force: true); // מאולץ
  /// ```
  Future<void> refreshProducts({bool force = false});
}
