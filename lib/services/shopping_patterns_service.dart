// 📄 File: lib/services/shopping_patterns_service.dart
//
// 🎯 Purpose: ניתוח דפוסי קנייה וסידור אוטומטי של רשימות
//
// ✨ Features:
// - 📊 שמירת סדר הקנייה (איזה מוצר נקנה ראשון, שני, וכו')
// - 🧠 למידת מסלולי קנייה בחנות
// - 🔄 סידור אוטומטי של רשימה הבאה לפי הדפוס הנלמד
// - 📈 חישוב דירוג עבור כל מוצר (איך לסדר)
//
// 🔥 Firebase Collection:
// shopping_patterns/{patternId}
//   - userId: string
//   - householdId: string (CRITICAL!)
//   - storeType: string (supermarket, pharmacy, etc.)
//   - purchaseOrder: array[itemName, purchaseIndex, timestamp]
//   - createdAt: timestamp
//   - updatedAt: timestamp
//
// Usage:
// ```dart
// final service = ShoppingPatternsService(
//   firestore: FirebaseFirestore.instance,
//   userContext: userContext,
// );
//
// // שמירת דפוס קנייה
// await service.saveShoppingPattern(
//   listType: 'supermarket',
//   purchasedItems: ['חלב', 'לחם', 'ביצים'],
// );
//
// // סידור רשימה לפי דפוס נלמד
// final sortedList = await service.sortListByPattern(
//   shoppingList: myList,
// );
// ```

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/shopping_list.dart';
import '../models/unified_list_item.dart';
import '../providers/user_context.dart';
import '../repositories/constants/repository_constants.dart';


class ShoppingPatternsService {
  final FirebaseFirestore _firestore;
  final UserContext _userContext;

  ShoppingPatternsService({
    required FirebaseFirestore firestore,
    required UserContext userContext,
  })  : _firestore = firestore,
        _userContext = userContext;

  // ========================================
  // 💾 שמירת דפוס קנייה
  // ========================================

  /// שומר את סדר הקנייה של המשתמש
  /// 
  /// [listType] - סוג הרשימה (supermarket, pharmacy, etc.)
  /// [purchasedItems] - רשימת המוצרים שנקנו, בסדר הקנייה
  Future<void> saveShoppingPattern({
    required String listType,
    required List<String> purchasedItems,
  }) async {
    try {

      final userId = _userContext.userId;
      final householdId = _userContext.householdId;

      if (userId == null || householdId == null) {
        return;
      }

      if (purchasedItems.isEmpty) {
        return;
      }

      // יצירת מסמך pattern
      final patternId = '${userId}_${listType}_${DateTime.now().millisecondsSinceEpoch}';
      final purchaseOrder = purchasedItems
          .asMap()
          .entries
          .map((entry) => {
                'itemName': entry.value,
                'purchaseIndex': entry.key,
                'timestamp': FieldValue.serverTimestamp(),
              })
          .toList();

      await _firestore.collection(FirestoreCollections.shoppingPatterns).doc(patternId).set({
        'userId': userId,
        'householdId': householdId,
        'storeType': listType,
        'purchaseOrder': purchaseOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ShoppingPatterns.save: $e');
    }
  }

  // ========================================
  // 🔄 סידור רשימה לפי דפוס
  // ========================================

  /// מסדר רשימת קניות לפי הדפוס הנלמד
  /// 
  /// מחזיר רשימה חדשה מסודרת, או את הרשימה המקורית אם אין דפוס
  Future<ShoppingList> sortListByPattern({
    required ShoppingList shoppingList,
  }) async {
    try {

      final userId = _userContext.userId;
      final householdId = _userContext.householdId;

      if (userId == null || householdId == null) {
        return shoppingList;
      }

      // טען דפוסים קיימים
      final patterns = await _loadPatterns(
        userId: userId,
        householdId: householdId,
        storeType: shoppingList.type,
      );

      if (patterns.isEmpty) {
        return shoppingList;
      }

      // חשב דירוג עבור כל מוצר
      final itemScores = <String, double>{};
      for (final item in shoppingList.items) {
        itemScores[item.name] = _calculateItemScore(item.name, patterns);
      }

      // מיין את הפריטים לפי הדירוג
      final sortedItems = List<UnifiedListItem>.from(shoppingList.items);
      sortedItems.sort((a, b) {
        final scoreA = itemScores[a.name] ?? 999.0;
        final scoreB = itemScores[b.name] ?? 999.0;
        return scoreA.compareTo(scoreB);
      });


      // החזר רשימה חדשה עם הפריטים המסודרים
      return shoppingList.copyWith(items: sortedItems);
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ShoppingPatterns.sort: $e');
      return shoppingList;
    }
  }

  // ========================================
  // 🧮 חישוב דירוג מוצר
  // ========================================

  /// מחשב דירוג ממוצע עבור מוצר לפי הדפוסים הקיימים
  /// 
  /// דירוג נמוך = נקנה מוקדם (מוצר ראשון בדרך)
  /// דירוג גבוה = נקנה מאוחר
  double _calculateItemScore(String itemName, List<Map<String, dynamic>> patterns) {
    final scores = <int>[];

    for (final pattern in patterns) {
      final purchaseOrder = pattern['purchaseOrder'] as List<dynamic>?;
      if (purchaseOrder == null) continue;

      // חפש את המוצר בדפוס הזה
      for (var i = 0; i < purchaseOrder.length; i++) {
        final entry = purchaseOrder[i] as Map<String, dynamic>;
        final name = entry['itemName'] as String?;
        if (name == itemName) {
          scores.add(i); // השמור את המיקום בדפוס הזה
          break;
        }
      }
    }

    if (scores.isEmpty) {
      return 999.0; // אם אין דפוס למוצר הזה - שים בסוף
    }

    // חשב ממוצע
    final average = scores.reduce((a, b) => a + b) / scores.length;
    return average;
  }

  // ========================================
  // 📥 טעינת דפוסים קיימים
  // ========================================

  /// טוען את 10 הדפוסים האחרונים עבור סוג חנות מסוים
  Future<List<Map<String, dynamic>>> _loadPatterns({
    required String userId,
    required String householdId,
    required String storeType,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.shoppingPatterns)
          .where('userId', isEqualTo: userId)
          .where('householdId', isEqualTo: householdId) // ✅ CRITICAL!
          .where('storeType', isEqualTo: storeType)
          .orderBy('createdAt', descending: true)
          .limit(kMaxRecentPatterns)
          .get();

      final patterns = snapshot.docs.map((doc) => doc.data()).toList();
      return patterns;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ShoppingPatterns.load: $e');
      return [];
    }
  }

  // ========================================
  // 🗑️ ניקוי דפוסים ישנים (אופציונלי)
  // ========================================

  /// מוחק דפוסים ישנים (מעל 90 ימים)
  Future<void> cleanupOldPatterns() async {
    try {

      final userId = _userContext.userId;
      final householdId = _userContext.householdId;

      if (userId == null || householdId == null) {
        return;
      }

      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final snapshot = await _firestore
          .collection(FirestoreCollections.shoppingPatterns)
          .where('userId', isEqualTo: userId)
          .where('householdId', isEqualTo: householdId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

    } catch (_) {
      // Silent: cleanup is best-effort
    }
  }
}
