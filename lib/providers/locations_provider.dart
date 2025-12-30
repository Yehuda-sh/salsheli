// 📄 File: lib/providers/locations_provider.dart
//
// 🎯 Purpose: Provider לניהול מיקומי אחסון מותאמים אישית - משותף לכל household
//
// 🏗️ Architecture: Provider + Repository + UserContext
//     - טוען מיקומים מ-Repository לפי household_id
//     - מאזין לשינויים ב-UserContext ומריענן אוטומטית
//     - מספק CRUD מלא עם error handling
//     - אופטימיזציה: עדכון local במקום ריענון מלא
//
// 📦 Dependencies:
//     - LocationsRepository: data source
//     - UserContext: household_id + auth state
//
// ✨ Features:
//     - ➕ הוספת מיקומים: יצירת מיקומי אחסון חדשים עם אימוג'י
//     - 🗑️ מחיקת מיקומים: הסרת מיקומים מותאמים
//     - 🔄 Auto-sync: סנכרון אוטומטי בין כל המכשירים ב-household
//     - ✅ Validation: בדיקת קיום + שם ריק + תווים לא חוקיים
//     - 💾 Cloud Storage: שמירה ב-Firestore (משותף לכל household)
//     - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<LocationsProvider>();
// final customLocations = provider.customLocations;
//
// // בהוספת מיקום:
// final success = await provider.addLocation('מקפיא נוסף', emoji: '🧊');
//
// // במחיקת מיקום:
// await provider.deleteLocation('מקפיא_נוסף');
//
// // Error Recovery:
// if (provider.hasError) {
//   await provider.retry();
// }
// ```
//
// 🔑 Key Generation:
//     שם: "מקפיא נוסף" → key: "מקפיא_נוסף" (lowercase + spaces→underscores)
//
// 🔄 State Flow:
//     1. UserContext changes → _onUserChanged() → _loadLocations()
//     2. User action → addLocation/deleteLocation → _repository.save/delete → _loadLocations()
//     3. _loadLocations() → Repository.fetch(household_id) → notifyListeners()
//
// ⚠️ Note:
//     - כל המיקומים משותפים לכל household
//     - מיקומים נשמרים ב-Firestore
//     - עדכון במכשיר אחד משפיע על כל המכשירים
//
// Version: 3.0 - Firebase Integration
// Last Updated: 13/10/2025
//

import 'package:flutter/foundation.dart';

import '../models/custom_location.dart';
import '../repositories/locations_repository.dart';
import 'user_context.dart';

/// Provider לניהול מיקומי אחסון מותאמים
class LocationsProvider with ChangeNotifier {
  final LocationsRepository _repository;
  UserContext? _userContext;
  bool _listening = false;

  bool _isLoading = false;
  String? _errorMessage;
  List<CustomLocation> _customLocations = [];

  Future<void>? _loadingFuture; // מניעת טעינות כפולות

  LocationsProvider({
    required LocationsRepository repository,
    required UserContext userContext,
  }) : _repository = repository {
    updateUserContext(userContext);
  }

  // === Getters ===
  
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _customLocations.isEmpty;
  List<CustomLocation> get customLocations => List.unmodifiable(_customLocations);

  // === חיבור UserContext ===
  
  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    // ⚠️ חייב להיות ב-microtask כי updateUserContext נקרא מ-ProxyProvider במהלך build
    Future.microtask(_initialize);
  }

  void _onUserChanged() {
    _loadLocations();
  }

  void _initialize() {
    _loadLocations();
  }

  // === טעינת מיקומים ===

  Future<void> _loadLocations() {
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _customLocations = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customLocations = await _repository.fetchLocations(householdId);
      if (kDebugMode) {
        debugPrint('✅ LocationsProvider: נטענו ${_customLocations.length} מיקומים');
      }
    } catch (e, st) {
      _errorMessage = 'שגיאה בטעינת מיקומים: $e';
      if (kDebugMode) {
        debugPrint('❌ LocationsProvider._doLoad: שגיאה - $e');
        debugPrintStack(label: 'LocationsProvider._doLoad', stackTrace: st);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// טוען את כל המיקומים מחדש מה-Repository
  ///
  /// Example:
  /// ```dart
  /// await locationsProvider.loadLocations();
  /// ```
  Future<void> loadLocations() {
    return _loadLocations();
  }

  // === בדיקות ===
  
  /// בדיקה אם מיקום קיים במיקומים המותאמים
  /// 
  /// Example:
  /// ```dart
  /// if (provider.locationExists('מקפיא_נוסף')) {
  ///   print('מיקום כבר קיים');
  /// }
  /// ```
  bool locationExists(String key) {
    return _customLocations.any((loc) => loc.key == key);
  }

  /// חיפוש מיקום לפי key
  ///
  /// Example:
  /// ```dart
  /// final location = provider.getLocationByKey('מקפיא_נוסף');
  /// if (location != null) {
  ///   print('נמצא: ${location.name}');
  /// }
  /// ```
  CustomLocation? getLocationByKey(String key) {
    return _customLocations.where((loc) => loc.key == key).firstOrNull;
  }

  /// נרמול key - ממיר שם למפתח תקני
  /// 'מקפיא נוסף' → 'מקפיא_נוסף'
  String _normalizeKey(String input) {
    return input.trim().toLowerCase().replaceAll(' ', '_');
  }

  // === יצירה/מחיקה ===
  
  /// הוספת מיקום מותאם חדש
  ///
  /// Returns: true אם הצליח, false אם המיקום כבר קיים או השם ריק
  ///
  /// Example:
  /// ```dart
  /// final success = await locationsProvider.addLocation(
  ///   'מקפיא נוסף',
  ///   emoji: '🧊',
  /// );
  ///
  /// if (success) {
  ///   print('מיקום נוסף בהצלחה');
  /// } else {
  ///   print('מיקום כבר קיים');
  /// }
  /// ```
  Future<bool> addLocation(String name, {String emoji = '📍'}) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      return false;
    }

    if (name.trim().isEmpty) {
      return false;
    }

    // יצירת key ייחודי: "מקפיא נוסף" → "מקפיא_נוסף"
    // הערה: לא מגבילים תווים - _normalizeKey יוצר key בטוח לשימוש ב-Firestore
    final key = _normalizeKey(name);

    // בדיקה אם קיים
    if (locationExists(key)) {
      return false;
    }

    try {
      // יצירת מיקום חדש
      final newLocation = CustomLocation(
        key: key,
        name: name.trim(),
        emoji: emoji,
      );

      await _repository.saveLocation(newLocation, householdId);

      // אופטימיזציה: הוספה local במקום ריענון מלא
      _customLocations = [..._customLocations, newLocation];
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LocationsProvider.addLocation: שגיאה - $e');
      }
      _errorMessage = 'שגיאה בהוספת מיקום';
      notifyListeners();
      return false;
    }
  }

  /// מחיקת מיקום מותאם
  ///
  /// Returns: true אם הצליח למחוק, false אם לא נמצא
  ///
  /// Example:
  /// ```dart
  /// final deleted = await locationsProvider.deleteLocation('מקפיא_נוסף');
  ///
  /// if (deleted) {
  ///   print('מיקום נמחק');
  /// }
  /// ```
  Future<bool> deleteLocation(String nameOrKey) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      return false;
    }

    // ולידציה
    if (nameOrKey.trim().isEmpty) {
      return false;
    }

    // תמיכה בשם או key
    final key = _normalizeKey(nameOrKey);

    if (!locationExists(key)) {
      return false;
    }

    try {
      await _repository.deleteLocation(key, householdId);

      // אופטימיזציה: מחיקה local במקום ריענון מלא
      _customLocations = _customLocations.where((loc) => loc.key != key).toList();
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LocationsProvider.deleteLocation: שגיאה - $e');
      }
      _errorMessage = 'שגיאה במחיקת מיקום';
      notifyListeners();
      return false;
    }
  }

  // === Error Recovery ===

  /// מנקה שגיאות ומטעין מחדש את המיקומים
  ///
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    _errorMessage = null;
    notifyListeners();
    await _loadLocations();
  }

  /// מנקה את כל הנתונים והשגיאות
  ///
  /// Example:
  /// ```dart
  /// locationsProvider.clearAll();
  /// ```
  void clearAll() {
    _customLocations = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // === Cleanup ===

  @override
  void dispose() {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }

    super.dispose();
  }
}
