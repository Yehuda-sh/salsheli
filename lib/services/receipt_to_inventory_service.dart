// 📄 File: lib/services/receipt_to_inventory_service.dart
//
// 🎯 מטרה: שירות להעברת פריטים מקבלה למלאי
// מנהל את הזרימה של הוספת קבלה חדשה למלאי הבית

import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../models/inventory_item.dart';
import '../models/product_location_memory.dart';
import '../providers/inventory_provider.dart';
import '../config/storage_locations_config.dart';

class ReceiptToInventoryService {
  final InventoryProvider inventoryProvider;
  final Map<String, ProductLocationMemory> _locationMemory = {};
  
  // 🔒 הגבלת גודל זיכרון למניעת Memory Leak
  static const int _maxMemorySize = 100;
  static const int _cleanupThreshold = 20; // כמה למחוק כשמגיעים למקסימום
  
  ReceiptToInventoryService({required this.inventoryProvider});
  
  /// מעבד קבלה ומחזיר רשימת פריטים לאישור
  Future<List<ReceiptToInventoryItem>> processReceipt(Receipt receipt) async {
    final items = <ReceiptToInventoryItem>[];
    
    for (var receiptItem in receipt.items) {
      if (receiptItem.name == null || receiptItem.name!.isEmpty) continue;
      
      final normalizedName = receiptItem.name!.toLowerCase().trim();
      
      // בדוק אם המוצר כבר קיים במלאי
      InventoryItem? existingItem;
      try {
        existingItem = inventoryProvider.items.firstWhere(
          (item) => item.productName.toLowerCase() == normalizedName,
        );
      } catch (_) {
        existingItem = null;
      }
      
      // נחש מיקום לפי קטגוריה או היסטוריה
      String suggestedLocation = StorageLocationsConfig.mainPantry;
      
      // בדוק בזיכרון
      if (_locationMemory.containsKey(normalizedName)) {
        suggestedLocation = _locationMemory[normalizedName]!.defaultLocation;
      } else if (existingItem != null) {
        // אם המוצר קיים, קח את המיקום שלו
        suggestedLocation = existingItem.location;
      } else {
        // נחש לפי קטגוריה
        suggestedLocation = _guessLocationByCategory(receiptItem.category);
      }
      
      items.add(ReceiptToInventoryItem(
        receiptItem: receiptItem,
        existingInventoryItem: existingItem,
        suggestedLocation: suggestedLocation,
        shouldAdd: true,
        quantity: receiptItem.quantity,
      ));
    }
    
    return items;
  }
  
  /// מוסיף פריטים מאושרים למלאי
  Future<void> addApprovedItemsToInventory(List<ReceiptToInventoryItem> items) async {
    for (var item in items) {
      if (!item.shouldAdd) continue;
      
      final name = item.receiptItem.name ?? '';
      final normalizedName = name.toLowerCase().trim();
      
      // שמור בזיכרון את המיקום
      _cleanupOldMemoriesIfNeeded(); // נקה זיכרון ישן אם צריך
      _locationMemory[normalizedName] = ProductLocationMemory(
        productName: normalizedName,
        defaultLocation: item.suggestedLocation,
        category: item.receiptItem.category,
        lastUpdated: DateTime.now(),
        usageCount: (_locationMemory[normalizedName]?.usageCount ?? 0) + 1,
      );
      
      if (item.existingInventoryItem != null) {
        // עדכן כמות של פריט קיים
        final newQuantity = item.existingInventoryItem!.quantity + item.quantity;
        final updated = item.existingInventoryItem!.copyWith(
          quantity: newQuantity,
          location: item.suggestedLocation,
        );
        await inventoryProvider.updateItem(updated);
      } else {
        // צור פריט חדש
        await inventoryProvider.createItem(
          productName: name,
          category: item.receiptItem.category ?? 'כללי',
          location: item.suggestedLocation,
          quantity: item.quantity,
          unit: item.receiptItem.unit ?? 'יח\'',
        );
      }
    }
  }
  
  /// ניקוי אוטומטי של זיכרון ישן
  /// 
  /// כשהמפה מגיעה ל-100 items, מוחק את ה-20 הישנים ביותר.
  /// מונע Memory Leak ושומר על ביצועים.
  void _cleanupOldMemoriesIfNeeded() {
    if (_locationMemory.length >= _maxMemorySize) {
      // מיין לפי תאריך עדכון (הישנים ביותר ראשונים)
      final sorted = _locationMemory.entries.toList()
        ..sort((a, b) => a.value.lastUpdated.compareTo(b.value.lastUpdated));
      
      // מחק את ה-20 הישנים ביותר
      for (int i = 0; i < _cleanupThreshold && i < sorted.length; i++) {
        _locationMemory.remove(sorted[i].key);
      }
    }
  }
  
  /// נחש מיקום לפי קטגוריה
  String _guessLocationByCategory(String? category) {
    if (category == null) return StorageLocationsConfig.mainPantry;
    
    final cat = category.toLowerCase();
    
    // מוצרי חלב, ירקות, פירות, בשר טרי
    if (cat.contains('חלב') || cat.contains('ירק') || 
        cat.contains('פיר') || cat.contains('בשר')) {
      return StorageLocationsConfig.refrigerator;
    }
    
    // קפואים
    if (cat.contains('קפוא') || cat.contains('גליד')) {
      return StorageLocationsConfig.freezer;
    }
    
    // ברירת מחדל - מזווה
    return StorageLocationsConfig.mainPantry;
  }
}

/// פריט להעברה מקבלה למלאי
class ReceiptToInventoryItem {
  final ReceiptItem receiptItem;
  final InventoryItem? existingInventoryItem;
  String suggestedLocation;
  bool shouldAdd;
  int quantity;
  
  ReceiptToInventoryItem({
    required this.receiptItem,
    this.existingInventoryItem,
    required this.suggestedLocation,
    this.shouldAdd = true,
    required this.quantity,
  });
  
  bool get isNewItem => existingInventoryItem == null;
  String get productName => receiptItem.name ?? '';
}
