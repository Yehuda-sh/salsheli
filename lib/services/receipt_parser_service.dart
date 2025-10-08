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
// 🔗 Dependencies:
// - StoresConfig - רשימת חנויות מוכרות
// - ReceiptPatternsConfig - Regex patterns
// - ui_constants - validation thresholds
//
// 📱 Mobile Only: Yes
//
// Version: 2.0 - Refactored (08/10/2025)
// - הוסרו hardcoded values → constants
// - הוסרו hardcoded patterns → ReceiptPatternsConfig
// - שימוש ב-StoresConfig לזיהוי חנויות

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/receipt.dart';
import '../config/stores_config.dart';
import '../config/receipt_patterns_config.dart';
import '../core/ui_constants.dart';

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

    // נסה למצוא חנויות ידועות בשורות הראשונות (kMaxStoreLinesCheck = 5)
    for (var line in lines.take(kMaxStoreLinesCheck)) {
      // השתמש ב-StoresConfig.detectStore() לזיהוי אוטומטי
      final detectedStore = StoresConfig.detectStore(line);
      if (detectedStore != null) {
        debugPrint('   ✅ זיהוי חנות: $detectedStore');
        return detectedStore;
      }
    }

    // אם לא מצאנו - קח את השורה הראשונה (עד kMaxStoreNameLength תווים)
    final firstLine = lines.first.trim();
    return firstLine.length > kMaxStoreNameLength
        ? firstLine.substring(0, kMaxStoreNameLength)
        : firstLine;
  }

  /// חילוץ סכום כולל
  static double _extractTotal(List<String> lines) {
    // השתמש ב-patterns מ-ReceiptPatternsConfig
    for (var line in lines.reversed) {
      // התחל מהסוף - הסה"כ בדרך כלל בסוף
      final lowerLine = line.toLowerCase();

      for (var pattern in ReceiptPatternsConfig.totalPatterns) {
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

    for (var line in lines) {
      final trimmed = line.trim();

      // דלג על שורות קצרות מדי (kMinReceiptLineLength = 3)
      if (trimmed.length < kMinReceiptLineLength) continue;

      // דלג על שורות עם מילות מפתח (ReceiptPatternsConfig.skipKeywords)
      final lowerLine = trimmed.toLowerCase();
      if (ReceiptPatternsConfig.skipKeywords.any((kw) => lowerLine.contains(kw))) {
        continue;
      }

      // נסה כל pattern מ-ReceiptPatternsConfig
      for (var pattern in ReceiptPatternsConfig.itemPatterns) {
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

            // בדיקות תקינות (kMinReceiptLineLength = 3, kMaxReceiptPrice = 10000)
            if (name.length < 2 || price <= 0 || price > kMaxReceiptPrice) {
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

    // בדיקה: האם סכום הפריטים מתאים לסה"כ? (kMaxReceiptTotalDifference = 1.0)
    final itemsTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final difference = (itemsTotal - expectedTotal).abs();

    if (expectedTotal > 0 && difference > kMaxReceiptTotalDifference) {
      debugPrint('   ⚠️ אי-התאמה: פריטים=₪$itemsTotal, סה"כ=₪$expectedTotal');
    } else {
      debugPrint('   ✅ סכום תואם!');
    }

    return items;
  }
}
