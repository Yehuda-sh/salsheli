// 📄 File: lib/services/receipt_service_mock.dart
//
// Mock לשירות קבלות לשימוש בפיתוח/אופליין.
// - שמירה מקומית ב-SharedPreferences כמערך JSON אחד (עם מיגרציה מהפורמט הישן StringList).
// - uploadAndParseReceipt: סימולציה שמחזירה קבלה "מפורקת" בסיסית.
// - פעולות: רשימה, שליפה לפי מזהה, שמירה (upsert), מחיקה, ניקוי.
//
// הערות:
// * שומר בפורמט חדש תחת מפתח V2. אם מזהה את המפתח הישן – מבצע מיגרציה חד־פעמית.
//

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/receipt.dart';

class ReceiptServiceMock {
  // מפתח חדש: מערך JSON בודד
  static const String _storageKeyV2 = 'mock_receipts_v2.json';
  // מפתח ישן: רשימת מחרוזות (כל איבר JSON של קבלה)
  static const String _legacyKey = 'mock_receipts';

  static const _uuid = Uuid();

  /// --- API ציבורי --- ///

  /// מחזיר את כל הקבלות (אחרי מיגרציה במידת הצורך)
  static Future<List<Receipt>> getReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    await _maybeMigrate(prefs);

    final raw = prefs.getString(_storageKeyV2);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((m) => Receipt.fromJson(m))
            .toList();
      }
      return [];
    } catch (_) {
      // אם מסיבה כלשהי התוכן לא תקין – נתחיל מחדש
      await prefs.remove(_storageKeyV2);
      return [];
    }
  }

  /// שליפה לפי מזהה
  static Future<Receipt?> getReceiptById(String id) async {
    final all = await getReceipts();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// "מעלה ומנתח" קבלה – מחזיר קבלה מדומה לבדיקה (עם מספר פריטים)
  static Future<Receipt> uploadAndParseReceipt(String filePath) async {
    // סימולציית עיבוד רשת
    await Future.delayed(const Duration(milliseconds: 800));

    return Receipt(
      id: _uuid.v4(),
      storeName: "Mock Store",
      date: DateTime.now(),
      totalAmount: 27.4,
      items: [
        ReceiptItem.manual(name: 'חלב 3%', quantity: 1, unitPrice: 6.9),
        ReceiptItem.manual(name: 'לחם מלא', quantity: 1, unitPrice: 10.5),
        ReceiptItem.manual(name: 'ביצים M (12)', quantity: 1, unitPrice: 10.0),
      ],
    );
  }

  /// שמירת קבלה (upsert): אם קיימת עם אותו id – יעדכן; אחרת יוסיף
  static Future<void> saveReceipt(Receipt receipt) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getReceipts();

    final idx = all.indexWhere((r) => r.id == receipt.id);
    if (idx == -1) {
      all.add(receipt);
    } else {
      all[idx] = receipt;
    }
    await _writeAll(prefs, all);
  }

  /// מחיקה לפי מזהה
  static Future<void> deleteReceipt(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getReceipts();
    all.removeWhere((r) => r.id == id);
    await _writeAll(prefs, all);
  }

  /// ניקוי כל הקבלות
  static Future<void> clearReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKeyV2);
    // לא הכרחי למחוק את המפתח הישן – אבל שיהיה נקי:
    await prefs.remove(_legacyKey);
  }

  /// --- עזר פנימי --- ///

  static Future<void> _writeAll(
    SharedPreferences prefs,
    List<Receipt> all,
  ) async {
    final encoded = jsonEncode(all.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKeyV2, encoded);
  }

  /// מיגרציה מהפורמט הישן (StringList של JSONים) לפורמט החדש (JSON array אחד)
  static Future<void> _maybeMigrate(SharedPreferences prefs) async {
    // אם כבר יש V2 – אין מה לעשות
    if (prefs.containsKey(_storageKeyV2)) return;

    final legacyList = prefs.getStringList(_legacyKey);
    if (legacyList == null || legacyList.isEmpty) return;

    try {
      final receipts = legacyList
          .map((s) => jsonDecode(s))
          .whereType<Map<String, dynamic>>()
          .map((m) => Receipt.fromJson(m))
          .toList();

      // כתיבה בפורמט החדש
      await _writeAll(prefs, receipts);
      // ניקוי הישן
      await prefs.remove(_legacyKey);
    } catch (_) {
      // אם המיגרציה נכשלה – פשוט ננקה את הישן כדי שלא נתקע בלופ
      await prefs.remove(_legacyKey);
    }
  }
}
