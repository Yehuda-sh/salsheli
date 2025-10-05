// 📄 File: lib/repositories/firebase_inventory_repository.dart
//
// 🇮🇱 Repository למלאי עם Firestore:
//     - שמירת פריטי מלאי ב-Firestore
//     - טעינת מלאי לפי householdId
//     - עדכון פריטים
//     - מחיקת פריטים
//     - Real-time updates
//
// 🇬🇧 Inventory repository with Firestore:
//     - Save inventory items to Firestore
//     - Load inventory by householdId
//     - Update items
//     - Delete items
//     - Real-time updates

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import 'inventory_repository.dart';

class FirebaseInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'inventory';

  FirebaseInventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Fetch Items ===

  @override
  Future<List<InventoryItem>> fetchItems(String householdId) async {
    try {
      debugPrint('📥 FirebaseInventoryRepository.fetchItems: טוען מלאי ל-$householdId');

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .orderBy('product_name')
          .get();

      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();

      debugPrint('✅ FirebaseInventoryRepository.fetchItems: נטענו ${items.length} פריטים');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.fetchItems: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to fetch inventory for $householdId', e);
    }
  }

  // === Save Item ===

  @override
  Future<InventoryItem> saveItem(InventoryItem item, String householdId) async {
    try {
      debugPrint('💾 FirebaseInventoryRepository.saveItem: שומר פריט ${item.id}');

      // הוספת household_id לנתונים
      final data = item.toJson();
      data['household_id'] = householdId;

      await _firestore
          .collection(_collectionName)
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

  // === Delete Item ===

  @override
  Future<void> deleteItem(String id, String householdId) async {
    try {
      debugPrint('🗑️ FirebaseInventoryRepository.deleteItem: מוחק פריט $id');

      // וידוא שהפריט שייך ל-household
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ פריט לא קיים');
        return;
      }

      final data = doc.data();
      if (data?['household_id'] != householdId) {
        debugPrint('⚠️ פריט לא שייך ל-household זה');
        throw InventoryRepositoryException('Item does not belong to household', null);
      }

      await _firestore.collection(_collectionName).doc(id).delete();

      debugPrint('✅ FirebaseInventoryRepository.deleteItem: פריט נמחק');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.deleteItem: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to delete item $id', e);
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// מחזיר stream של מלאי (real-time updates)
  /// 
  /// Example:
  /// ```dart
  /// repository.watchInventory('house_demo').listen((items) {
  ///   print('Inventory updated: ${items.length} items');
  /// });
  /// ```
  Stream<List<InventoryItem>> watchInventory(String householdId) {
    return _firestore
        .collection(_collectionName)
        .where('household_id', isEqualTo: householdId)
        .orderBy('product_name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return InventoryItem.fromJson(data);
      }).toList();
    });
  }

  /// מחזיר פריט לפי ID
  /// 
  /// Example:
  /// ```dart
  /// final item = await repository.getItemById('item_123', 'house_demo');
  /// ```
  Future<InventoryItem?> getItemById(String itemId, String householdId) async {
    try {
      debugPrint('🔍 FirebaseInventoryRepository.getItemById: מחפש פריט $itemId');

      final doc = await _firestore.collection(_collectionName).doc(itemId).get();

      if (!doc.exists) {
        debugPrint('⚠️ פריט לא נמצא');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      
      // בדיקה שהפריט שייך ל-household
      if (data['household_id'] != householdId) {
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
  /// Example:
  /// ```dart
  /// final items = await repository.getItemsByLocation('refrigerator', 'house_demo');
  /// ```
  Future<List<InventoryItem>> getItemsByLocation(String location, String householdId) async {
    try {
      debugPrint('📍 FirebaseInventoryRepository.getItemsByLocation: מחפש פריטים ב-$location');

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .where('location', isEqualTo: location)
          .orderBy('product_name')
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
  /// Example:
  /// ```dart
  /// final items = await repository.getItemsByCategory('dairy', 'house_demo');
  /// ```
  Future<List<InventoryItem>> getItemsByCategory(String category, String householdId) async {
    try {
      debugPrint('🏷️ FirebaseInventoryRepository.getItemsByCategory: מחפש פריטים בקטגוריה $category');

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .where('category', isEqualTo: category)
          .orderBy('product_name')
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
  /// Example:
  /// ```dart
  /// final lowItems = await repository.getLowStockItems(
  ///   threshold: 2,
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<List<InventoryItem>> getLowStockItems({
    required int threshold,
    required String householdId,
  }) async {
    try {
      debugPrint('⚠️ FirebaseInventoryRepository.getLowStockItems: מחפש פריטים עם כמות <= $threshold');

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('household_id', isEqualTo: householdId)
          .where('quantity', isLessThanOrEqualTo: threshold)
          .orderBy('quantity')
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
  /// Example:
  /// ```dart
  /// await repository.updateQuantity(
  ///   itemId: 'item_123',
  ///   newQuantity: 5,
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<void> updateQuantity({
    required String itemId,
    required int newQuantity,
    required String householdId,
  }) async {
    try {
      debugPrint('🔢 FirebaseInventoryRepository.updateQuantity: מעדכן כמות ל-$newQuantity');

      // וידוא שהפריט שייך ל-household
      final doc = await _firestore.collection(_collectionName).doc(itemId).get();
      
      if (!doc.exists) {
        debugPrint('⚠️ פריט לא קיים');
        throw InventoryRepositoryException('Item not found', null);
      }

      final data = doc.data();
      if (data?['household_id'] != householdId) {
        debugPrint('⚠️ פריט לא שייך ל-household זה');
        throw InventoryRepositoryException('Item does not belong to household', null);
      }

      await _firestore
          .collection(_collectionName)
          .doc(itemId)
          .update({'quantity': newQuantity});

      debugPrint('✅ FirebaseInventoryRepository.updateQuantity: כמות עודכנה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseInventoryRepository.updateQuantity: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw InventoryRepositoryException('Failed to update quantity', e);
    }
  }
}

/// Exception class for inventory repository errors
class InventoryRepositoryException implements Exception {
  final String message;
  final Object? cause;

  InventoryRepositoryException(this.message, this.cause);

  @override
  String toString() => 'InventoryRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
