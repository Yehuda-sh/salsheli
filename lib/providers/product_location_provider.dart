// 📄 File: lib/providers/product_location_provider.dart
//
// 🎯 מטרה: ניהול זיכרון מיקומי אחסון למוצרים

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_location_memory.dart';
import '../config/storage_locations_config.dart';
import 'user_context.dart';

class ProductLocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserContext? _userContext;
  
  final Map<String, ProductLocationMemory> _locationMemory = {};
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  
  void updateUserContext(UserContext newContext) {
    _userContext = newContext;
    _loadMemory();
  }
  
  Future<void> _loadMemory() async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('product_locations')
          .get();
          
      _locationMemory.clear();
      for (var doc in snapshot.docs) {
        final memory = ProductLocationMemory.fromJson(doc.data());
        _locationMemory[memory.productName.toLowerCase()] = memory;
      }
      
      debugPrint('📍 Loaded ${_locationMemory.length} product locations');
    } catch (e) {
      debugPrint('❌ Error loading product locations: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// מחזיר מיקום ידוע למוצר או מנחש לפי קטגוריה
  String? getProductLocation(String productName, {String? category}) {
    final normalizedName = productName.toLowerCase();
    final memory = _locationMemory[normalizedName];
    
    if (memory != null) {
      return memory.defaultLocation;
    }
    
    // ניחוש לפי קטגוריה
    return _guessLocationByCategory(category);
  }
  
  /// שומר מיקום למוצר
  Future<void> saveProductLocation(
    String productName,
    String location, {
    String? category,
  }) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;
    
    final normalizedName = productName.toLowerCase();
    final existing = _locationMemory[normalizedName];
    
    final memory = existing != null
        ? existing.copyWith(
            defaultLocation: location,
            usageCount: existing.usageCount + 1,
            lastUpdated: DateTime.now(),
            category: category ?? existing.category,
          )
        : ProductLocationMemory(
            productName: normalizedName,
            defaultLocation: location,
            category: category,
            lastUpdated: DateTime.now(),
            householdId: householdId,
          );
    
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('product_locations')
          .doc(normalizedName)
          .set(memory.toJson());
          
      _locationMemory[normalizedName] = memory;
      notifyListeners();
      
      debugPrint('✅ Saved location for $productName: $location');
    } catch (e) {
      debugPrint('❌ Error saving product location: $e');
    }
  }
  
  /// ניחוש מיקום לפי קטגוריה
  String _guessLocationByCategory(String? category) {
    if (category == null) return StorageLocationsConfig.mainPantry;
    
    final cat = category.toLowerCase();
    
    // חלבי, ירקות, פירות, בשר → מקרר
    if (cat.contains('חלב') || cat.contains('ירק') || 
        cat.contains('פיר') || cat.contains('בשר')) {
      return StorageLocationsConfig.refrigerator;
    }
    
    // קפוא, גלידה → מקפיא
    if (cat.contains('קפוא') || cat.contains('גליד')) {
      return StorageLocationsConfig.freezer;
    }
    
    // ברירת מחדל → מזווה
    return StorageLocationsConfig.mainPantry;
  }
  
  /// בדיקה אם מכירים את המוצר
  bool isProductKnown(String productName) {
    return _locationMemory.containsKey(productName.toLowerCase());
  }
  
  /// קבלת רשימת כל המוצרים הידועים
  List<String> get knownProducts => _locationMemory.keys.toList();
}