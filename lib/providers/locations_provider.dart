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
    debugPrint('🔄 LocationsProvider.updateUserContext');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    debugPrint('✅ Listener הוסף, מתחיל initialization');
    _initialize();
  }

  void _onUserChanged() {
    debugPrint('👤 LocationsProvider._onUserChanged: משתמש השתנה');
    _loadLocations();
  }

  void _initialize() {
    debugPrint('🔧 LocationsProvider._initialize');
    _loadLocations();  // _doLoad יטפל בכל הלוגיקה (מחובר/לא מחובר)
  }

  // === טעינת מיקומים ===
  
  Future<void> _loadLocations() {
    debugPrint('📥 LocationsProvider._loadLocations');
    
    if (_loadingFuture != null) {
      debugPrint('   ⏳ טעינה כבר בתהליך, ממתין...');
      return _loadingFuture!;
    }
    
    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    debugPrint('🔄 LocationsProvider._doLoad: מתחיל טעינה');
    
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      debugPrint('   ⚠️ אין household_id, מנקה רשימה');
      _customLocations = [];
      notifyListeners();
      debugPrint('   🔔 LocationsProvider: notifyListeners() (no household_id)');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (isLoading=true)');

    try {
      _customLocations = await _repository.fetchLocations(householdId);
      debugPrint('✅ LocationsProvider._doLoad: נטענו ${_customLocations.length} מיקומים');
    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת מיקומים: $e";
      debugPrint('❌ LocationsProvider._doLoad: שגיאה - $e');
      debugPrintStack(label: 'LocationsProvider._doLoad', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (isLoading=false, locations=${_customLocations.length})');
  }

  /// טוען את כל המיקומים מחדש מה-Repository
  /// 
  /// Example:
  /// ```dart
  /// await locationsProvider.loadLocations();
  /// ```
  Future<void> loadLocations() {
    debugPrint('🔄 LocationsProvider.loadLocations: רענון ידני');
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
    try {
      return _customLocations.firstWhere((loc) => loc.key == key);
    } catch (e) {
      return null;
    }
  }

  /// נרמול key - ממיר שם למפתח תקני
  /// "מקפיא נוסף" → "מקפיא_נוסף"
  String _normalizeKey(String input) {
    return input.trim().toLowerCase().replaceAll(" ", "_");
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
  Future<bool> addLocation(String name, {String emoji = "📍"}) async {
    debugPrint('➕ LocationsProvider.addLocation: "$name" ($emoji)');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('❌ householdId לא נמצא');
      return false;
    }
    
    if (name.trim().isEmpty) {
      debugPrint('   ⚠️ שם ריק - מבטל');
      return false;
    }

    // בדיקת תווים לא חוקיים
    final invalidChars = RegExp(r'[/\\:*?"<>|]');
    if (invalidChars.hasMatch(name)) {
      debugPrint('   ⚠️ תווים לא חוקיים בשם - מבטל');
      return false;
    }

    // יצירת key ייחודי: "מקפיא נוסף" → "מקפיא_נוסף"
    final key = _normalizeKey(name);
    debugPrint('   🔑 Key: "$key"');

    // בדיקה אם קיים
    if (locationExists(key)) {
      debugPrint('   ⚠️ מיקום "$key" כבר קיים');
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
      debugPrint('✅ מיקום נשמר ב-Repository: ${newLocation.emoji} ${newLocation.name}');
      
      // אופטימיזציה: הוספה local במקום ריענון מלא
      _customLocations.add(newLocation);
      notifyListeners();
      debugPrint('   🔔 LocationsProvider: notifyListeners() (location added: ${newLocation.key})');
      
      return true;
    } catch (e) {
      debugPrint('❌ LocationsProvider.addLocation: שגיאה - $e');
      _errorMessage = 'שגיאה בהוספת מיקום';
      notifyListeners();
      debugPrint('   🔔 LocationsProvider: notifyListeners() (error)');
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
    debugPrint('🗑️ LocationsProvider.deleteLocation: "$nameOrKey"');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ householdId לא נמצא, מדלג');
      return false;
    }
    
    // תמיכה בשם או key
    final key = _normalizeKey(nameOrKey);
    debugPrint('   🔑 Normalized key: "$key"');
    
    final exists = locationExists(key);
    
    if (!exists) {
      debugPrint('   ⚠️ מיקום "$key" לא נמצא למחיקה');
      return false;
    }

    try {
      await _repository.deleteLocation(key, householdId);
      debugPrint('✅ מיקום נמחק מ-Repository');
      
      // אופטימיזציה: מחיקה local במקום ריענון מלא
      _customLocations.removeWhere((loc) => loc.key == key);
      notifyListeners();
      debugPrint('   🔔 LocationsProvider: notifyListeners() (location deleted: $key)');
      
      return true;
    } catch (e) {
      debugPrint('❌ LocationsProvider.deleteLocation: שגיאה - $e');
      _errorMessage = 'שגיאה במחיקת מיקום';
      notifyListeners();
      debugPrint('   🔔 LocationsProvider: notifyListeners() (error)');
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
    debugPrint('🔄 LocationsProvider.retry: מנסה שוב');
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (error cleared)');
    await _loadLocations();
  }

  /// מנקה את כל הנתונים והשגיאות
  /// 
  /// Example:
  /// ```dart
  /// locationsProvider.clearAll();
  /// ```
  void clearAll() {
    debugPrint('🧹 LocationsProvider.clearAll: מנקה הכל');
    _customLocations = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (all cleared)');
  }

  // === Cleanup ===
  
  @override
  void dispose() {
    debugPrint('🧹 LocationsProvider.dispose');
    
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      debugPrint('   ✅ Listener הוסר');
    }
    
    super.dispose();
  }
}
