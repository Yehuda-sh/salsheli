// 📄 lib/providers/locations_provider.dart
//
// Provider לניהול מיקומי אחסון מותאמים אישית - משותף לכל household.
// CRUD מלא עם סנכרון אוטומטי ב-Firestore.
//
// 🔗 Related: CustomLocation, LocationsRepository, UserContext

import 'package:flutter/foundation.dart';

import '../models/custom_location.dart';
import '../repositories/locations_repository.dart';
import 'user_context.dart';

/// Provider לניהול מיקומי אחסון מותאמים
class LocationsProvider with ChangeNotifier {
  final LocationsRepository _repository;
  UserContext? _userContext;
  bool _listening = false;
  bool _isDisposed = false;

  bool _isLoading = false;
  String? _errorMessage;
  List<CustomLocation> _customLocations = [];

  Future<void>? _loadingFuture; // מניעת טעינות כפולות
  int _loadGeneration = 0; // מונע תוצאות ישנות אחרי logout/שינוי household

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

  // === Safe Notify ===

  /// קורא ל-notifyListeners רק אם לא disposed
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // === חיבור UserContext ===

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    // Guard: אם אותו context - לא עושים כלום
    if (_userContext == newContext) {
      return;
    }

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

    // Logout או לא מחובר - איפוס מלא
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _customLocations = [];
      _isLoading = false;
      _errorMessage = null;
      _loadGeneration++;
      _notifySafe();
      return;
    }

    final currentGeneration = ++_loadGeneration;

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      final locations = await _repository.fetchLocations(householdId);

      // בדיקה: אם logout/שינוי household קרה בזמן הטעינה - מתעלמים מהתוצאות
      if (currentGeneration != _loadGeneration || _isDisposed) {
        return;
      }

      _customLocations = locations;
    } catch (e, st) {
      // בדיקה גם ב-catch
      if (currentGeneration != _loadGeneration || _isDisposed) {
        return;
      }

      _errorMessage = 'שגיאה בטעינת מיקומים: $e';
      if (kDebugMode) {
        debugPrintStack(label: 'LocationsProvider._doLoad', stackTrace: st);
      }
    }

    // בדיקה לפני notify סופי
    if (currentGeneration != _loadGeneration || _isDisposed) {
      return;
    }

    _isLoading = false;
    _notifySafe();
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
    // משתמש ב-CustomLocation.normalizeKey לעקביות עם המודל
    final key = CustomLocation.normalizeKey(name);

    // בדיקה אם קיים
    if (locationExists(key)) {
      return false;
    }

    // יצירת מיקום חדש
    final newLocation = CustomLocation(
      key: key,
      name: name.trim(),
      emoji: emoji,
    );

    // Optimistic UI: שמירת מצב קודם + עדכון מיידי
    final previousLocations = List<CustomLocation>.from(_customLocations);
    _customLocations = [..._customLocations, newLocation];
    _errorMessage = null;
    _notifySafe();

    try {
      await _repository.saveLocation(newLocation, householdId);
      return true;
    } catch (e) {
      // Rollback: שחזור למצב הקודם
      _customLocations = previousLocations;
      _errorMessage = 'שגיאה בהוספת מיקום';
      _notifySafe();
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
    final key = CustomLocation.normalizeKey(nameOrKey);

    if (!locationExists(key)) {
      return false;
    }

    // Optimistic UI: שמירת מצב קודם + מחיקה מיידית
    final previousLocations = List<CustomLocation>.from(_customLocations);
    _customLocations = _customLocations.where((loc) => loc.key != key).toList();
    _errorMessage = null;
    _notifySafe();

    try {
      await _repository.deleteLocation(key, householdId);
      return true;
    } catch (e) {
      // Rollback: שחזור המיקום שנמחק
      _customLocations = previousLocations;
      _errorMessage = 'שגיאה במחיקת מיקום';
      _notifySafe();
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
    _notifySafe();
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
    _notifySafe();
  }

  // === Cleanup ===

  @override
  void dispose() {
    _isDisposed = true;

    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }

    super.dispose();
  }
}
