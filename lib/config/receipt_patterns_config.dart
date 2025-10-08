// 📄 File: lib/config/receipt_patterns_config.dart
//
// 🎯 מטרה: Regex patterns לניתוח קבלות (OCR parsing)
//
// 📋 כולל:
// - Patterns לזיהוי סכום כולל
// - Patterns לחילוץ פריטים ומחירים
// - דוגמאות שימוש מפורטות
//
// 🔗 קבצים קשורים:
// - lib/services/receipt_parser_service.dart - השימוש העיקרי
// - lib/services/ocr_service.dart - חילוץ הטקסט המקורי
//
// 📝 הערות:
// - Patterns מתייחסים גם לעברית וגם לאנגלית
// - תומכים בפסיקים ונקודות כמפרידי עשרוניים
// - רגישים לשגיאות OCR נפוצות
//
// Version: 1.0
// Last Updated: 08/10/2025

/// קונפיגורציה של Regex patterns לניתוח קבלות
class ReceiptPatternsConfig {
  // מניעת instances
  const ReceiptPatternsConfig._();

  // ========================================
  // Patterns לזיהוי סכום כולל
  // ========================================

  /// Patterns לחיפוש "סה"כ" או "total" בקבלה
  /// 
  /// 🎯 שימוש: _extractTotal() ב-receipt_parser_service.dart
  /// 
  /// **תואם:**
  /// - "סה"כ: 45.90"
  /// - "סהכ 45.90"
  /// - "total: 45.90"
  /// - "סך הכל: 45.90"
  /// - "סכום לתשלום: 45.90"
  /// 
  /// **דוגמה:**
  /// ```dart
  /// for (var pattern in ReceiptPatternsConfig.totalPatterns) {
  ///   final regex = RegExp(pattern, caseSensitive: false);
  ///   final match = regex.firstMatch(line);
  ///   if (match != null) {
  ///     final amount = match.group(1)!.replaceAll(',', '.');
  ///     return double.parse(amount);
  ///   }
  /// }
  /// ```
  static const List<String> totalPatterns = [
    r'סה.?כ[:\s]*(\d+[\.,]\d+)',        // סה"כ או סה'כ (כל תו בין ה-ה ו-כ)
    r'total[:\s]*(\d+[\.,]\d+)',         // total: 45.90
    r'סך הכל[:\s]*(\d+[\.,]\d+)',       // סך הכל: 45.90
    r'סכום לתשלום[:\s]*(\d+[\.,]\d+)',  // סכום לתשלום: 45.90
    r'לתשלום[:\s]*(\d+[\.,]\d+)',       // לתשלום: 45.90
  ];

  // ========================================
  // Patterns לחילוץ פריטים
  // ========================================

  /// Patterns לזיהוי שורות פריטים עם מחירים
  /// 
  /// 🎯 שימוש: _extractItems() ב-receipt_parser_service.dart
  /// 
  /// **תואם:**
  /// - "חלב x2 12.50" (עם כמות)
  /// - "חלב - 6.90" (עם מקף)
  /// - "חלב    6.90" (עם רווחים)
  /// 
  /// **דוגמה:**
  /// ```dart
  /// for (var pattern in ReceiptPatternsConfig.itemPatterns) {
  ///   final regex = RegExp(pattern);
  ///   final match = regex.firstMatch(line);
  ///   if (match != null) {
  ///     // חלץ שם, כמות, מחיר...
  ///   }
  /// }
  /// ```
  static const List<String> itemPatterns = [
    r'^(.+?)\s*[x×]\s*(\d+)\s+(\d+[\.,]\d+)$',  // "פריט x2 12.50" (עם כמות)
    r'^(.+?)\s*[-–—:]\s*(\d+[\.,]\d+)$',        // "פריט - 12.50" (מקף/מינוס)
    r'^(.+?)\s{2,}(\d+[\.,]\d+)$',              // "פריט    12.50" (2+ רווחים)
  ];

  // ========================================
  // מילות מפתח לדילוג
  // ========================================

  /// מילים שמציינות שזו לא שורת פריט רגילה
  /// 
  /// 🎯 שימוש: _extractItems() - דילוג על שורות אלה
  /// 
  /// **דוגמה:**
  /// ```dart
  /// final lowerLine = line.toLowerCase();
  /// if (ReceiptPatternsConfig.skipKeywords.any((kw) => lowerLine.contains(kw))) {
  ///   continue; // דלג על השורה
  /// }
  /// ```
  static const List<String> skipKeywords = [
    'סה"כ',
    'סהכ',
    'total',
    'סך הכל',
    'לתשלום',
    'סכום',
    'קופה',      // מספר קופה
    'קופאי',     // שם קופאי
    'תאריך',     // תאריך קבלה
    'שעה',       // שעת קנייה
    'ברקוד',     // ברקוד
    'מספר',      // מספר עסקה
    'עסקה',      // מספר עסקה
  ];
}

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **חיפוש סה"כ:**
//    ```dart
//    import 'package:salsheli/config/receipt_patterns_config.dart';
//    
//    for (var pattern in ReceiptPatternsConfig.totalPatterns) {
//      final regex = RegExp(pattern, caseSensitive: false);
//      final match = regex.firstMatch(receiptLine);
//      if (match != null) {
//        final amount = match.group(1)!.replaceAll(',', '.');
//        return double.parse(amount);
//      }
//    }
//    ```
//
// 2. **חילוץ פריטים:**
//    ```dart
//    for (var pattern in ReceiptPatternsConfig.itemPatterns) {
//      final regex = RegExp(pattern);
//      final match = regex.firstMatch(line);
//      
//      if (match != null) {
//        if (match.groupCount == 3) {
//          // Pattern עם כמות: "פריט x2 12.50"
//          name = match.group(1)!.trim();
//          quantity = int.parse(match.group(2)!);
//          price = double.parse(match.group(3)!.replaceAll(',', '.'));
//        } else {
//          // Pattern רגיל: "פריט - 12.50"
//          name = match.group(1)!.trim();
//          price = double.parse(match.group(2)!.replaceAll(',', '.'));
//        }
//      }
//    }
//    ```
//
// 3. **דילוג על שורות:**
//    ```dart
//    final lowerLine = line.toLowerCase();
//    if (ReceiptPatternsConfig.skipKeywords.any((kw) => 
//        lowerLine.contains(kw))) {
//      continue; // שורה לא רלוונטית
//    }
//    ```
//
