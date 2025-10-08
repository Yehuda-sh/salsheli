// 📄 File: lib/config/stores_config.dart
//
// 🎯 מטרה: קונפיגורציה של חנויות מוכרות במערכת
//
// 📋 כולל:
// - רשימת חנויות סופרמרקט מרכזיות בישראל
// - שמות מנורמלים לזיהוי בסריקת קבלות
//
// 🔗 קבצים קשורים:
// - lib/screens/onboarding/widgets/onboarding_steps.dart - בחירת חנויות מועדפות
// - lib/services/receipt_parser_service.dart - זיהוי חנויות מקבלות
//
// 📝 הערות:
// - שמות חנויות ללא ניקוד (לצורך השוואה פשוטה)
// - סדר לפי פופולריות
//
// Version: 1.0
// Last Updated: 08/10/2025

/// קונפיגורציה של חנויות
class StoresConfig {
  // מניעת instances
  const StoresConfig._();

  /// רשימת חנויות סופרמרקט מרכזיות
  /// 
  /// 🎯 שימוש:
  /// - Onboarding - בחירת חנויות מועדפות
  /// - Filters - סינון רשימות לפי חנות
  /// - OCR - זיהוי חנות מקבלה
  /// 
  /// **דוגמה:**
  /// ```dart
  /// // Dropdown של חנויות
  /// DropdownButton<String>(
  ///   items: StoresConfig.allStores.map((store) =>
  ///     DropdownMenuItem(value: store, child: Text(store))
  ///   ).toList(),
  /// )
  /// 
  /// // בדיקה אם חנות תקינה
  /// if (StoresConfig.allStores.contains(storeName)) { ... }
  /// ```
  static const List<String> allStores = [
    'שופרסל',
    'רמי לוי',
    'ויקטורי',
    'סופר פארם',
    'יינות ביתן',
    'טיב טעם',
    'מגה',
    'יוחננוף',
  ];

  /// מיפוי וריאציות שמות חנויות (לזיהוי מקבלות)
  /// 
  /// 🎯 שימוש: receipt_parser_service.dart
  /// 
  /// **דוגמה:**
  /// ```dart
  /// final storeName = receiptText.toLowerCase();
  /// for (final entry in StoresConfig.storeVariations.entries) {
  ///   if (entry.value.any((variant) => storeName.contains(variant))) {
  ///     return entry.key; // החנות המנורמלת
  ///   }
  /// }
  /// ```
  static const Map<String, List<String>> storeVariations = {
    'שופרסל': ['shufersal', 'shufershal', 'שופרסל'],
    'רמי לוי': ['rami levy', 'rami levi', 'ramilevy', 'רמי לוי'],
    'ויקטורי': ['victory', 'ויקטורי'],
    'סופר פארם': ['super pharm', 'superpharm', 'סופר פארם'],
    'יינות ביתן': ['bitan', 'ביתן'],
    'טיב טעם': ['tiv taam', 'tivtaam', 'טיב טעם'],
    'מגה': ['mega', 'מגה'],
    'יוחננוף': ['yohananof', 'יוחננוף'],
  };

  /// בדיקה אם חנות תקינה
  /// 
  /// **דוגמה:**
  /// ```dart
  /// if (StoresConfig.isValid('שופרסל')) { ... }  // true
  /// if (StoresConfig.isValid('unknown')) { ... }  // false
  /// ```
  static bool isValid(String store) => allStores.contains(store);

  /// זיהוי חנות מטקסט (לשימוש ב-OCR)
  /// 
  /// **דוגמה:**
  /// ```dart
  /// final text = 'SHUFERSAL DEAL LTD...';
  /// final store = StoresConfig.detectStore(text);
  /// print(store); // 'שופרסל'
  /// ```
  static String? detectStore(String text) {
    final normalized = text.toLowerCase();
    for (final entry in storeVariations.entries) {
      for (final variant in entry.value) {
        if (normalized.contains(variant.toLowerCase())) {
          return entry.key;
        }
      }
    }
    return null;
  }
}

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **גישה לרשימה:**
//    ```dart
//    import 'package:salsheli/config/stores_config.dart';
//    
//    StoresConfig.allStores  // רשימה מלאה
//    ```
//
// 2. **Validation:**
//    ```dart
//    if (!StoresConfig.isValid(input)) {
//      showError('חנות לא תקינה');
//    }
//    ```
//
// 3. **זיהוי מקבלה:**
//    ```dart
//    final store = StoresConfig.detectStore(receiptText);
//    if (store != null) {
//      print('נמצאה חנות: $store');
//    }
//    ```
//
