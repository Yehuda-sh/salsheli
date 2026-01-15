// 📄 File: lib/providers/product_location_provider.dart
//
// 🎯 מטרה: ניהול זיכרון מיקומי אחסון למוצרים

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/storage_locations_config.dart';
import '../models/product_location_memory.dart';
import 'user_context.dart';

class ProductLocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserContext? _userContext;

  // 🔒 מפת זיכרון - keyed לפי uniqueKey (barcode או שם מנורמל)
  final Map<String, ProductLocationMemory> _locationMemory = {};
  bool _isLoading = false;

  // 🔒 הגנות סטנדרטיות
  bool _isDisposed = false;
  int _loadGeneration = 0;
  Future<void>? _loadingFuture;

  bool get isLoading => _isLoading;

  // === Safe Notify ===

  /// 🔒 קורא ל-notifyListeners רק אם לא disposed
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // === UserContext Integration ===

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    // Guard: אם אותו context - לא עושים כלום
    if (_userContext == newContext) {
      return;
    }

    _userContext = newContext;

    // ⚠️ חובה microtask! אחרת notifyListeners נקרא בזמן build (ProxyProvider)
    Future.microtask(_loadMemory);
  }
  
  Future<void> _loadMemory() {
    // 🔒 מניעת טעינות כפולות
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    final householdId = _userContext?.user?.householdId;

    // Logout או לא מחובר - איפוס מלא
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _locationMemory.clear();
      _isLoading = false;
      _loadGeneration++;
      _notifySafe();
      return;
    }

    final currentGeneration = ++_loadGeneration;

    _isLoading = true;
    _notifySafe();

    try {
      final snapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('product_locations')
          .get();

      // 🔒 בדיקה: אם logout קרה בזמן הטעינה - מתעלמים מהתוצאות
      if (currentGeneration != _loadGeneration || _isDisposed) {
        return;
      }

      _locationMemory.clear();
      for (var doc in snapshot.docs) {
        final memory = ProductLocationMemory.fromJson(doc.data());
        // 🔧 FIX: שימוש ב-uniqueKey במקום productName.toLowerCase()
        _locationMemory[memory.uniqueKey] = memory;
      }

      if (kDebugMode) {
        debugPrint('📍 ProductLocationProvider: Loaded ${_locationMemory.length} locations');
      }
    } catch (e) {
      // 🔒 בדיקה גם ב-catch
      if (currentGeneration != _loadGeneration || _isDisposed) {
        return;
      }

      if (kDebugMode) {
        debugPrint('❌ ProductLocationProvider._loadMemory: $e');
      }
    }

    // 🔒 בדיקה לפני notify סופי
    if (currentGeneration != _loadGeneration || _isDisposed) {
      return;
    }

    _isLoading = false;
    _notifySafe();
  }
  
  /// מחזיר מיקום ידוע למוצר או מנחש לפי קטגוריה
  /// 🔧 מחפש קודם לפי barcode (אם יש), אחרת לפי שם מנורמל
  String? getProductLocation(
    String productName, {
    String? barcode,
    String? category,
  }) {
    // 🔧 חיפוש לפי uniqueKey: barcode (אם יש) או שם מנורמל
    final normalizedName = productName.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final key = barcode ?? normalizedName;
    final memory = _locationMemory[key];

    if (memory != null) {
      return memory.defaultLocation;
    }

    // אם לא מצאנו לפי barcode, ננסה גם לפי שם מנורמל
    if (barcode != null) {
      final memoryByName = _locationMemory[normalizedName];
      if (memoryByName != null) {
        return memoryByName.defaultLocation;
      }
    }

    // ניחוש לפי קטגוריה
    return _guessLocationByCategory(category);
  }
  
  /// שומר מיקום למוצר
  /// 🔧 משתמש ב-updateWithLocation() לעדכון confidence נכון
  Future<void> saveProductLocation(
    String productName,
    String location, {
    String? barcode,
    String? category,
  }) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    // 🔧 נרמול location
    final normalizedLocation = ProductLocationMemory.normalizeLocation(location);

    // 🔧 חישוב uniqueKey: barcode אם יש, אחרת שם מנורמל
    final normalizedName = productName.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final uniqueKey = barcode ?? normalizedName;

    final existing = _locationMemory[uniqueKey];

    // 🔧 FIX: שימוש ב-updateWithLocation() לעדכון confidence נכון
    final memory = existing != null
        ? existing.updateWithLocation(normalizedLocation).copyWith(
            category: category ?? existing.category,
          )
        : ProductLocationMemory(
            productName: productName.trim(), // שמור שם תצוגה מקורי
            barcode: barcode,
            defaultLocation: normalizedLocation,
            category: category,
            lastUpdated: DateTime.now(),
            householdId: householdId,
          );

    final gen = _loadGeneration;

    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('product_locations')
          .doc(uniqueKey) // 🔧 FIX: שימוש ב-uniqueKey במקום normalizedName
          .set(memory.toJson());

      // 🔒 בדיקה: אם logout קרה בזמן ה-await - מתעלמים
      if (gen != _loadGeneration || _isDisposed) {
        return;
      }

      _locationMemory[uniqueKey] = memory;
      _notifySafe();
    } catch (e) {
      // 🔒 בדיקה גם ב-catch
      if (gen != _loadGeneration || _isDisposed) {
        return;
      }

      if (kDebugMode) {
        debugPrint('❌ ProductLocationProvider.saveProductLocation: $e');
      }
    }
  }
  
  /// ניחוש מיקום לפי קטגוריה
  /// 🔧 תומך בעברית ואנגלית
  String _guessLocationByCategory(String? category) {
    if (category == null) return StorageLocationsConfig.mainPantry;

    final cat = category.toLowerCase();

    // 🔧 חלבי, ירקות, פירות, בשר, דגים → מקרר (עברית + אנגלית)
    if (cat.contains('חלב') ||
        cat.contains('dairy') ||
        cat.contains('milk') ||
        cat.contains('ירק') ||
        cat.contains('vegetable') ||
        cat.contains('פיר') ||
        cat.contains('fruit') ||
        cat.contains('בשר') ||
        cat.contains('meat') ||
        cat.contains('דג') ||
        cat.contains('fish')) {
      return StorageLocationsConfig.refrigerator;
    }

    // 🔧 קפוא, גלידה → מקפיא (עברית + אנגלית)
    if (cat.contains('קפוא') ||
        cat.contains('frozen') ||
        cat.contains('גליד') ||
        cat.contains('ice cream') ||
        cat.contains('icecream')) {
      return StorageLocationsConfig.freezer;
    }

    // ברירת מחדל → מזווה
    return StorageLocationsConfig.mainPantry;
  }
  
  /// בדיקה אם מכירים את המוצר
  /// 🔧 מחפש לפי barcode (אם יש) או שם מנורמל
  bool isProductKnown(String productName, {String? barcode}) {
    final normalizedName = productName.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final key = barcode ?? normalizedName;

    if (_locationMemory.containsKey(key)) {
      return true;
    }

    // אם לא מצאנו לפי barcode, ננסה גם לפי שם מנורמל
    if (barcode != null) {
      return _locationMemory.containsKey(normalizedName);
    }

    return false;
  }

  /// קבלת רשימת כל המוצרים הידועים
  List<String> get knownProducts => List.unmodifiable(_locationMemory.keys.toList());

  // === Lifecycle ===

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}