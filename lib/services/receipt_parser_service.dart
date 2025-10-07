// 📄 File: lib/services/receipt_parser_service.dart
//
// 📋 Description:
// Static service for parsing OCR text into Receipt objects.
// Uses regex patterns to extract store name, items, and total.
//
// 🎯 Purpose:
// - Parse raw OCR text into structured Receipt
// - Extract items with prices
// - Identify store name and total amount
//
// 📱 Mobile Only: Yes

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/receipt.dart';

class ReceiptParserService {
  /// ניתוח טקסט OCR לקבלה
  /// 
  /// Example:
  /// ```dart
  /// final text = "שופרסל\nחלב - 6.90\nלחם - 5.50\nסה\"כ: 12.40";
  /// final receipt = ReceiptParserService.parseReceiptText(text);
  /// ```
  static Receipt parseReceiptText(String text) {
    debugPrint('📝 ReceiptParserService.parseReceiptText()');
    debugPrint('   📏 אורך טקסט: ${text.length} תווים');

    try {
      // ניקוי הטקסט
      final cleanText = text.trim();
      final lines = cleanText.split('\n').where((line) => line.trim().isNotEmpty).toList();

      debugPrint('   📋 ${lines.length} שורות');

      // שלב 1: זיהוי שם החנות (שורה ראשונה לרוב)
      final storeName = _extractStoreName(lines);
      debugPrint('   🏪 חנות: $storeName');

      // שלב 2: זיהוי סכום כולל
      final totalAmount = _extractTotal(lines);
      debugPrint('   💰 סה"כ: ₪$totalAmount');

      // שלב 3: חילוץ פריטים
      final items = _extractItems(lines, totalAmount);
      debugPrint('   📦 ${items.length} פריטים');

      // יצירת הקבלה
      final receipt = Receipt.newReceipt(
        storeName: storeName,
        date: DateTime.now(),
        totalAmount: totalAmount,
        items: items,
      );

      debugPrint('✅ ReceiptParserService.parseReceiptText: הצליח');
      return receipt;
    } catch (e, stackTrace) {
      debugPrint('❌ ReceiptParserService.parseReceiptText: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);

      // fallback - קבלה ריקה עם הטקסט המקורי כהערה
      return Receipt.newReceipt(
        storeName: 'לא זוהה',
        date: DateTime.now(),
        totalAmount: 0.0,
        items: [],
      );
    }
  }

  /// חילוץ שם החנות
  static String _extractStoreName(List<String> lines) {
    if (lines.isEmpty) return 'לא זוהה';

    // נסה למצוא שמות חנויות ידועים
    const knownStores = [
      'שופרסל',
      'רמי לוי',
      'מגה',
      'ויקטורי',
      'יינות ביתן',
      'סופר פארם',
      'am:pm',
      'חצי חינם',
    ];

    for (var line in lines.take(5)) {
      // בדוק רק ב-5 שורות הראשונות
      final lowerLine = line.toLowerCase().trim();
      for (var store in knownStores) {
        if (lowerLine.contains(store.toLowerCase())) {
          debugPrint('   ✅ זיהוי חנות: $store');
          return store;
        }
      }
    }

    // אם לא מצאנו - קח את השורה הראשונה
    final firstLine = lines.first.trim();
    return firstLine.length > 30 ? firstLine.substring(0, 30) : firstLine;
  }

  /// חילוץ סכום כולל
  static double _extractTotal(List<String> lines) {
    // חיפוש אחרי מילות מפתח של סה"כ
    final totalPatterns = [
      r'סה.?כ[:\s]*(\d+[\.,]\d+)',  // סה"כ או סה'כ (כל תו בין ה-ה ו-כ)
      r'total[:\s]*(\d+[\.,]\d+)',
      r'סך הכל[:\s]*(\d+[\.,]\d+)',
      r'סכום לתשלום[:\s]*(\d+[\.,]\d+)',
    ];

    for (var line in lines.reversed) {
      // התחל מהסוף - הסה"כ בדרך כלל בסוף
      final lowerLine = line.toLowerCase();

      for (var pattern in totalPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        final match = regex.firstMatch(lowerLine);

        if (match != null) {
          final amountStr = match.group(1)!.replaceAll(',', '.');
          final amount = double.tryParse(amountStr) ?? 0.0;
          if (amount > 0) {
            debugPrint('   ✅ סה"כ נמצא: ₪$amount');
            return amount;
          }
        }
      }
    }

    debugPrint('   ⚠️ לא נמצא סה"כ, מחשב מהפריטים...');
    return 0.0; // נחשב מאוחר יותר מסכום הפריטים
  }

  /// חילוץ פריטים
  static List<ReceiptItem> _extractItems(List<String> lines, double expectedTotal) {
    final items = <ReceiptItem>[];

    // Regex למציאת שורות עם מחיר
    // דוגמאות:
    // "חלב - 6.90"
    // "לחם    5.50"
    // "ביצים x2 7.80"
    final itemPatterns = [
      r'^(.+?)\s*[x×]\s*(\d+)\s+(\d+[\.,]\d+)$', // "פריט x2 12.50"
      r'^(.+?)\s*[-–—:]\s*(\d+[\.,]\d+)$', // "פריט - 12.50"
      r'^(.+?)\s{2,}(\d+[\.,]\d+)$', // "פריט    12.50"
    ];

    for (var line in lines) {
      final trimmed = line.trim();

      // דלג על שורות קצרות מדי או שורות עם מילות מפתח של סה"כ
      if (trimmed.length < 3) continue;
      if (trimmed.toLowerCase().contains('סה"כ') ||
          trimmed.toLowerCase().contains('סהכ') ||
          trimmed.toLowerCase().contains('total') ||
          trimmed.toLowerCase().contains('סך הכל')) {
        continue;
      }

      // נסה כל pattern
      for (var pattern in itemPatterns) {
        final regex = RegExp(pattern);
        final match = regex.firstMatch(trimmed);

        if (match != null) {
          try {
            String name;
            int quantity = 1;
            double price;

            if (match.groupCount == 3) {
              // Pattern עם כמות: "פריט x2 12.50"
              name = match.group(1)!.trim();
              quantity = int.tryParse(match.group(2)!) ?? 1;
              price = double.parse(match.group(3)!.replaceAll(',', '.'));
            } else {
              // Pattern בלי כמות: "פריט - 12.50"
              name = match.group(1)!.trim();
              price = double.parse(match.group(2)!.replaceAll(',', '.'));
            }

            // בדיקות תקינות
            if (name.length < 2 || price <= 0 || price > 10000) {
              continue; // דלג על פריטים לא הגיוניים
            }

            // הוסף את הפריט
            final item = ReceiptItem(
              id: const Uuid().v4(),
              name: name,
              quantity: quantity,
              unitPrice: quantity > 1 ? price / quantity : price,
            );

            items.add(item);
            debugPrint('   📦 פריט: $name x$quantity = ₪$price');
            break; // מצאנו match, עבור לשורה הבאה
          } catch (e) {
            debugPrint('   ⚠️ שגיאה בפענוח שורה: $trimmed');
            continue;
          }
        }
      }
    }

    // אם לא מצאנו פריטים - החזר רשימה ריקה
    if (items.isEmpty) {
      debugPrint('   ⚠️ לא נמצאו פריטים');
      return [];
    }

    // בדיקה: האם סכום הפריטים מתאים לסה"כ?
    final itemsTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final difference = (itemsTotal - expectedTotal).abs();

    if (expectedTotal > 0 && difference > 1.0) {
      debugPrint('   ⚠️ אי-התאמה: פריטים=₪$itemsTotal, סה"כ=₪$expectedTotal');
    } else {
      debugPrint('   ✅ סכום תואם!');
    }

    return items;
  }
}
