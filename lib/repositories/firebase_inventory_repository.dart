// 📄 File: lib/repositories/firebase_inventory_repository.dart
//
// 🎯 מטרה: Repository למלאי עם Firestore
//
// 📋 כולל:
//     - שמירת פריטי מלאי ב-Firestore
//     - טעינת מלאי לפי householdId (⚠️ חובה!)
//     - עדכון פריטים
//     - מחיקת פריטים (עם בדיקת אבטחה)
//     - Real-time updates (watchInventory)
//     - Queries מתקדמים (לפי מיקום, קטגוריה, כמות נמוכה)
//
// 🔒 Security:
//     - כל query מסונן לפי household_id
//     - מחיקה רק אחרי בדיקת בעלות
//     - שימוש בקבועים מ-FirestoreCollections/Fields
//
// 📝 הערות:
//     - משתמש ב-FirestoreUtils לטיפול ב-timestamps
//     - כל הפונקציות זורקות InventoryRepositoryException בשגיאה
//     - Error handling מלא + logging
//
// Version: 2.0
// Last Updated: 17/10/2025
// Changes: ✅ שימוש מלא בקבועים, ✅ שיפור תיעוד, ✅ שיפור error handling

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../core/constants.dart';  // 🆕 שימוש ב-FirestoreCollections/Fields
import 'inventory_repository.dart';
import 'utils/firestore_utils.dart';

/// Firebase implementation של InventoryRepository
/// 
/// מנהל את כל פעולות המלאי מול Firestore:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Real-time updates דרך streams
/// - Queries מתקדמים (מיקום, קטגוריה, כמות נמוכה)
/// 
/// 🔒 Security:
/// - כל query מסונן לפי household_id
/// - בדיקת בעלות לפני מחיקה/עדכון
/// 
/// 📝 שימוש:
/// ```dart
/// final repo = FirebaseInventoryRepository();
/// final items = await repo.fetchItems('household_123');
/// ```
class FirebaseInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;

  /// יוצר instance חדש של FirebaseInventoryRepository
  /// 
  /// Parameters:
  ///   - [firestore]: instance של FirebaseFirestore (אופציונלי, ברירת מחדל: instance ראשי)
  /// 
  /// Example:
  /// ```dart
  /// // שימוש רגיל
  /// final repo = FirebaseInventoryRepository();
  /// 
  /// // עם FirebaseFirestore מותאם (למשל לבדיקות)
  /// final repo = FirebaseInventoryRepository(
  ///   firestore: FirebaseFirestore.instanceFor(app: myApp),
  /// );
  /// ```
  FirebaseInventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ========================================
  // CRUD Operations - פעולות בסיסיות
  // ========================================

  /// טוען את כל פריטי המלאי של משק בית
  /// 
  /// מבצע query ב-Firestore עם household_id ומסדר לפי שם המוצר.
  /// השימוש הוא דרך InventoryProvider שמנהל את המלאי.
  /// 
  /// 🔒 Security: מסונן לפי household_id
  /// 
  /// Parameters:
  ///   - [householdId]: מזהה המשק בית (חובה!)
  /// 
  /// Returns:
  ///   - List של InventoryItem ממוין לפי product_name
  /// 
  /// Throws:
  ///   - [InventoryRepositoryException] במקרה של שגיאת Firestore
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final items = await repo.fetchItems('household_demo');
  ///   print('נטענו ${items.length} פריטים במלאי');
  /// } catch (e) {
  ///   print('שגיאה בטעינת מלאי: $e');
  /// }
  /// ```
  @override
  Future<List<InventoryItem>> fetchItems(String householdId) async {
    try {
      debugPrint('📥 FirebaseInventoryRepository.fetchItems: טוען מלאי ל-$householdId');

      // ✅ שימוש מלא בקבועים
      final snapshot = await _firestore
          .collection(FirestoreCollections.inventory)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .orderBy(FirestoreFields.productName)
          .get();

      // מעבד כל מסמך בנפרד כדי לדלג על פריטים פגומים
      final items = <InventoryItem>[];
      int skippedCount = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          final item = InventoryItem.fromJson(data);
          items.add(item);
        } catch (e) {
          skippedCount++;
          debugPrint('⚠️ דולג על פריט פגום: ${doc.id} - $e');
        }
      }

      if (skippedCount > 0) {
        debugPrint('⚠️ FirebaseInventoryRepository.fetchItems: דולג על $skippedCount פריטים פגומים');
      }
      
      debugPrint('✅ FirebaseInventoryRepository.fetchItems: נטענו ${items.length} פריטים');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.fetchItems: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to fetch inventory for $householdId', e);
    }
  }

  /// שומר או מעדכן פריט במלאי
  /// 
  /// מוסיף את household_id לנתונים ושומר ב-Firestore עם merge.
  /// אם הפריט קיים, מעדכן רק את השדות שהשתנו.
  /// 
  /// 🔒 Security: מוסיף household_id אוטומטית
  /// 
  /// Parameters:
  ///   - [item]: הפריט לשמירה
  ///   - [householdId]: מזהה המשק בית שהפריט שייך אליו
  /// 
  /// Returns:
  ///   - את אותו InventoryItem שנשמר
  /// 
  /// Throws:
  ///   - [InventoryRepositoryException] במקרה של שגיאת שמירה
  /// 
  /// Example:
  /// ```dart
  /// final item = InventoryItem(
  ///   id: 'item_123',
  ///   productName: 'חלב',
  ///   quantity: 2,
  ///   location: 'refrigerator',
  /// );
  /// 
  /// final saved = await repo.saveItem(item, 'household_demo');
  /// print('פריט נשמר: ${saved.productName}');
  /// ```
  @override
  Future<InventoryItem> saveItem(InventoryItem item, String householdId) async {
    try {
      debugPrint('💾 FirebaseInventoryRepository.saveItem: שומר פריט ${item.id}');

      // הוספת household_id לנתונים
      final data = FirestoreUtils.addHouseholdId(
        item.toJson(),
        householdId,
      );

      // ✅ שימוש בקבועים
      await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(item.id)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ FirebaseInventoryRepository.saveItem: פריט נשמר');
      return item;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.saveItem: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to save item ${item.id}', e);
    }
  }

  /// מוחק פריט מהמלאי
  /// 
  /// מבצע בדיקת אבטחה - מוודא שהפריט שייך ל-household לפני מחיקה.
  /// אם הפריט לא קיים או לא שייך ל-household, לא מבצע מחיקה.
  /// 
  /// 🔒 Security: בדיקת בעלות חובה!
  /// 
  /// Parameters:
  ///   - [id]: מזהה הפריט למחיקה
  ///   - [householdId]: מזהה המשק בית (לאימות בעלות)
  /// 
  /// Throws:
  ///   - [InventoryRepositoryException] אם הפריט לא שייך ל-household או שגיאה במחיקה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await repo.deleteItem('item_123', 'household_demo');
  ///   print('פריט נמחק בהצלחה');
  /// } catch (e) {
  ///   print('שגיאה במחיקה: $e');
  /// }
  /// ```
  @override
  Future<void> deleteItem(String id, String householdId) async {
    try {
      debugPrint('🗑️ FirebaseInventoryRepository.deleteItem: מוחק פריט $id');

      // ✅ שימוש בקבועים
      final doc = await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        debugPrint('⚠️ פריט לא קיים');
        return;
      }

      final data = doc.data();
      
      // ✅ בדיקת בעלות עם קבוע
      if (data?[FirestoreFields.householdId] != householdId) {
        debugPrint('⚠️ פריט לא שייך ל-household זה');
        throw InventoryRepositoryException('Item does not belong to household', null);
      }

      // ✅ שימוש בקבועים
      await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(id)
          .delete();

      debugPrint('✅ FirebaseInventoryRepository.deleteItem: פריט נמחק');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.deleteItem: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to delete item $id', e);
    }
  }

  // ========================================
  // Real-time Updates - עדכונים בזמן אמת
  // ========================================

  /// מחזיר stream של מלאי (real-time updates)
  /// 
  /// 📡 Real-time: השינויים מתעדכנים אוטומטית
  /// 🔒 Security: מסונן לפי household_id
  /// 
  /// Parameters:
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - Stream<List<InventoryItem>> שמתעדכן בזמן אמת
  /// 
  /// Example:
  /// ```dart
  /// // האזנה לשינויים בזמן אמת
  /// repository.watchInventory('household_demo').listen((items) {
  ///   print('Inventory updated: ${items.length} items');
  /// });
  /// 
  /// // עם StreamBuilder ב-Widget
  /// StreamBuilder<List<InventoryItem>>(
  ///   stream: repository.watchInventory(householdId),
  ///   builder: (context, snapshot) {
  ///     if (snapshot.hasData) {
  ///       return ItemsList(items: snapshot.data!);
  ///     }
  ///     return CircularProgressIndicator();
  ///   },
  /// )
  /// ```
  Stream<List<InventoryItem>> watchInventory(String householdId) {
    // ✅ שימוש מלא בקבועים
    return _firestore
        .collection(FirestoreCollections.inventory)
        .where(FirestoreFields.householdId, isEqualTo: householdId)
        .orderBy(FirestoreFields.productName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();
    });
  }

  // ========================================
  // Advanced Queries - queries מתקדמים
  // ========================================

  /// מחזיר פריט לפי ID
  /// 
  /// 🔒 Security: בדיקת בעלות household
  /// 
  /// Parameters:
  ///   - [itemId]: מזהה הפריט
  ///   - [householdId]: מזהה המשק בית (לאימות)
  /// 
  /// Returns:
  ///   - InventoryItem או null אם לא נמצא / לא שייך ל-household
  /// 
  /// Example:
  /// ```dart
  /// final item = await repository.getItemById('item_123', 'household_demo');
  /// if (item != null) {
  ///   print('נמצא: ${item.productName}');
  /// } else {
  ///   print('פריט לא נמצא או לא שייך למשק בית');
  /// }
  /// ```
  Future<InventoryItem?> getItemById(String itemId, String householdId) async {
    try {
      debugPrint('🔍 FirebaseInventoryRepository.getItemById: מחפש פריט $itemId');

      // ✅ שימוש בקבועים
      final doc = await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ פריט לא נמצא');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      
      // ✅ בדיקה שהפריט שייך ל-household
      if (data[FirestoreFields.householdId] != householdId) {
        debugPrint('⚠️ פריט לא שייך ל-household זה');
        return null;
      }

      final item = InventoryItem.fromJson(data);
      debugPrint('✅ פריט נמצא');
      
      return item;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.getItemById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to get item by id', e);
    }
  }

  /// מחזיר פריטים לפי מיקום
  /// 
  /// 📍 סינון לפי מיקום אחסון (מקרר, מקפיא, מזווה וכו')
  /// 🔒 Security: מסונן לפי household_id
  /// 
  /// Parameters:
  ///   - [location]: מיקום האחסון (למשל: 'refrigerator', 'freezer')
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - List<InventoryItem> ממוין לפי שם מוצר
  /// 
  /// Example:
  /// ```dart
  /// // קבל את כל הפריטים במקרר
  /// final fridgeItems = await repository.getItemsByLocation(
  ///   'refrigerator',
  ///   'household_demo',
  /// );
  /// print('במקרר: ${fridgeItems.length} פריטים');
  /// ```
  Future<List<InventoryItem>> getItemsByLocation(String location, String householdId) async {
    try {
      debugPrint('📍 FirebaseInventoryRepository.getItemsByLocation: מחפש פריטים ב-$location');

      // ✅ שימוש מלא בקבועים
      final snapshot = await _firestore
          .collection(FirestoreCollections.inventory)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .where(FirestoreFields.location, isEqualTo: location)
          .orderBy(FirestoreFields.productName)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${items.length} פריטים');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.getItemsByLocation: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to get items by location', e);
    }
  }

  /// מחזיר פריטים לפי קטגוריה
  /// 
  /// 🏷️ סינון לפי קטגוריית מוצר (dairy, meat, produce וכו')
  /// 🔒 Security: מסונן לפי household_id
  /// 
  /// Parameters:
  ///   - [category]: קטגוריית המוצר (למשל: 'dairy', 'meat')
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - List<InventoryItem> ממוין לפי שם מוצר
  /// 
  /// Example:
  /// ```dart
  /// // קבל את כל מוצרי החלב
  /// final dairyItems = await repository.getItemsByCategory(
  ///   'dairy',
  ///   'household_demo',
  /// );
  /// print('מוצרי חלב: ${dairyItems.length}');
  /// ```
  Future<List<InventoryItem>> getItemsByCategory(String category, String householdId) async {
    try {
      debugPrint('🏷️ FirebaseInventoryRepository.getItemsByCategory: מחפש פריטים בקטגוריה $category');

      // ✅ שימוש מלא בקבועים
      final snapshot = await _firestore
          .collection(FirestoreCollections.inventory)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .where(FirestoreFields.category, isEqualTo: category)
          .orderBy(FirestoreFields.productName)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${items.length} פריטים');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.getItemsByCategory: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to get items by category', e);
    }
  }

  /// מחזיר פריטים עם כמות נמוכה
  /// 
  /// ⚠️ מציאת פריטים שהכמות שלהם נמוכה או שווה ל-threshold
  /// 🔒 Security: מסונן לפי household_id
  /// 
  /// Parameters:
  ///   - [threshold]: כמות מקסימלית (פריטים עם כמות <= threshold)
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - List<InventoryItem> ממוין לפי כמות (נמוך ביותר ראשון)
  /// 
  /// Example:
  /// ```dart
  /// // מצא פריטים עם 2 יחידות או פחות
  /// final lowItems = await repository.getLowStockItems(
  ///   threshold: 2,
  ///   householdId: 'household_demo',
  /// );
  /// 
  /// // התרעה למשתמש
  /// if (lowItems.isNotEmpty) {
  ///   print('התראה: ${lowItems.length} פריטים עם כמות נמוכה!');
  ///   for (final item in lowItems) {
  ///     print('- ${item.productName}: ${item.quantity} יחידות');
  ///   }
  /// }
  /// ```
  Future<List<InventoryItem>> getLowStockItems({
    required int threshold,
    required String householdId,
  }) async {
    try {
      debugPrint('⚠️ FirebaseInventoryRepository.getLowStockItems: מחפש פריטים עם כמות <= $threshold');

      // ✅ שימוש מלא בקבועים
      final snapshot = await _firestore
          .collection(FirestoreCollections.inventory)
          .where(FirestoreFields.householdId, isEqualTo: householdId)
          .where(FirestoreFields.quantity, isLessThanOrEqualTo: threshold)
          .orderBy(FirestoreFields.quantity)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${items.length} פריטים');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.getLowStockItems: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to get low stock items', e);
    }
  }

  /// מעדכן כמות של פריט
  /// 
  /// 🔢 עדכון מהיר של כמות בלבד (ללא שינוי שאר השדות)
  /// 🔒 Security: בדיקת בעלות household
  /// 
  /// Parameters:
  ///   - [itemId]: מזהה הפריט
  ///   - [newQuantity]: כמות חדשה
  ///   - [householdId]: מזהה המשק בית (לאימות)
  /// 
  /// Throws:
  ///   - [InventoryRepositoryException] אם הפריט לא נמצא או לא שייך ל-household
  /// 
  /// Example:
  /// ```dart
  /// // הפחת כמות אחרי שימוש
  /// await repository.updateQuantity(
  ///   itemId: 'item_123',
  ///   newQuantity: 3,  // היו 5, נשארו 3
  ///   householdId: 'household_demo',
  /// );
  /// 
  /// // בדוק אם צריך להזמין
  /// final item = await repository.getItemById('item_123', 'household_demo');
  /// if (item!.quantity <= 2) {
  ///   print('זמן להזמין ${item.productName}!');
  /// }
  /// ```
  Future<void> updateQuantity({
    required String itemId,
    required int newQuantity,
    required String householdId,
  }) async {
    try {
      debugPrint('🔢 FirebaseInventoryRepository.updateQuantity: מעדכן כמות ל-$newQuantity');

      // ✅ וידוא שהפריט שייך ל-household
      final doc = await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .get();
      
      if (!doc.exists) {
        debugPrint('⚠️ פריט לא קיים');
        throw InventoryRepositoryException('Item not found', null);
      }

      final data = doc.data();
      
      // ✅ בדיקת בעלות עם קבוע
      if (data?[FirestoreFields.householdId] != householdId) {
        debugPrint('⚠️ פריט לא שייך ל-household זה');
        throw InventoryRepositoryException('Item does not belong to household', null);
      }

      // ✅ שימוש בקבועים
      await _firestore
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .update({FirestoreFields.quantity: newQuantity});

      debugPrint('✅ FirebaseInventoryRepository.updateQuantity: כמות עודכנה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.updateQuantity: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to update quantity', e);
    }
  }
}

// ========================================
// Exception Class
// ========================================

/// Exception class for inventory repository errors
/// 
/// 📝 משמש לכל השגיאות של InventoryRepository
/// 
/// Example:
/// ```dart
/// try {
///   await repo.fetchItems(householdId);
/// } catch (e) {
///   if (e is InventoryRepositoryException) {
///     print('Repository error: ${e.message}');
///     if (e.cause != null) {
///       print('Caused by: ${e.cause}');
///     }
///   }
/// }
/// ```
class InventoryRepositoryException implements Exception {
  final String message;
  final Object? cause;

  InventoryRepositoryException(this.message, this.cause);

  @override
  String toString() => 'InventoryRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
