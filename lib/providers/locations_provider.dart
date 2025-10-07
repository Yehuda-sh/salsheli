// 📄 File: lib/providers/locations_provider.dart
//
// 🎯 Purpose: Provider לניהול מיקומי אחסון מותאמים אישית - מאפשר למשתמש להוסיף מיקומים חדשים
//
// 📦 Dependencies:
// - SharedPreferences: אחסון מקומי של מיקומים מותאמים
//
// ✨ Features:
// - ➕ הוספת מיקומים: יצירת מיקומי אחסון חדשים עם אימוג'י
// - 🗑️ מחיקת מיקומים: הסרת מיקומים מותאמים
// - 💾 אחסון מתמשך: שמירה ב-SharedPreferences
// - ✅ Validation: בדיקת קיום + שם ריק
// - 🔄 Auto-load: טעינה אוטומטית בבנאי
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
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
// // באיפוס הכל:
// await provider.reset();
// ```
//
// 🔄 State Flow:
// 1. Constructor → _loadLocations() → טעינה מ-SharedPreferences
// 2. User action → addLocation/deleteLocation → _saveLocations() → notifyListeners()
//
// 🔑 Key Generation:
// - שם: "מקפיא נוסף" → key: "מקפיא_נוסף" (lowercase + spaces→underscores)
//
// ⚠️ Note:
// - כל המיקומים הם מותאמים אישית
// - מיקומים נשמרים ב-SharedPreferences
//
// Version: 2.0 (עם logging מלא + תיעוד מקיף)
// Last Updated: 06/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/custom_location.dart';

/// Provider לניהול מיקומי אחסון מותאמים
class LocationsProvider with ChangeNotifier {
  // רשימת מיקומים מותאמים פרטית
  List<CustomLocation> _customLocations = [];
  
  // Error handling
  String? _errorMessage;

  /// מפתח לשמירה ב-SharedPreferences
  static const String _prefsKey = 'custom_storage_locations';

  /// קונסטרקטור - טוען נתונים אוטומטית מ-SharedPreferences
  LocationsProvider() {
    debugPrint('🚀 LocationsProvider: נוצר');
    _loadLocations();
  }

  /// קבלת רשימת מיקומים מותאמים (unmodifiable)
  /// 
  /// Example:
  /// ```dart
  /// final locations = locationsProvider.customLocations;
  /// ```
  List<CustomLocation> get customLocations =>
      List.unmodifiable(_customLocations);

  /// בדיקה אם הרשימה ריקה
  /// 
  /// Example:
  /// ```dart
  /// if (provider.isEmpty) {
  ///   print('אין מיקומים מותאמים');
  /// }
  /// ```
  bool get isEmpty => _customLocations.isEmpty;

  /// בדיקה אם יש שגיאה
  bool get hasError => _errorMessage != null;

  /// קבלת הודעת שגיאה (null אם אין שגיאה)
  String? get errorMessage => _errorMessage;

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

  /// טעינת מיקומים מותאמים מ-SharedPreferences
  Future<void> _loadLocations() async {
    debugPrint('📥 LocationsProvider._loadLocations: מתחיל טעינה');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getString(_prefsKey);

      if (locationsJson != null) {
        final decoded = jsonDecode(locationsJson) as List;
        _customLocations = decoded
            .map(
              (item) => CustomLocation.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        debugPrint('✅ LocationsProvider: נטענו ${_customLocations.length} מיקומים מותאמים');
        
        // Log כל מיקום
        for (var loc in _customLocations) {
          debugPrint('   ${loc.emoji} ${loc.name} (${loc.key})');
        }
      } else {
        debugPrint('ℹ️ LocationsProvider: אין מיקומים מותאמים שמורים');
      }
      
      _errorMessage = null;  // אין שגיאה - נקה שגיאות קודמות
    } catch (e, st) {
      _errorMessage = 'שגיאה בטעינת מיקומים: $e';
      debugPrint('❌ LocationsProvider._loadLocations: שגיאה - $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();  // עדכן UI על השגיאה
    }
  }

  /// ניסיון חוזר לטעינת מיקומים אחרי שגיאה
  /// 
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    debugPrint('🔄 LocationsProvider.retry: מנסה לטעון מחדש');
    _errorMessage = null;
    await _loadLocations();
  }

  /// שמירת מיקומים מותאמים ב-SharedPreferences
  Future<void> _saveLocations() async {
    debugPrint('💾 LocationsProvider._saveLocations: שומר ${_customLocations.length} מיקומים');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _customLocations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));

      debugPrint('✅ LocationsProvider: מיקומים נשמרו בהצלחה');
      _errorMessage = null;  // שמירה הצליחה - נקה שגיאות
    } catch (e, st) {
      _errorMessage = 'שגיאה בשמירת מיקומים: $e';
      debugPrint('❌ LocationsProvider._saveLocations: שגיאה - $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();  // עדכן UI על השגיאה
    }
  }

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

    // הוספה לרשימה
    final newLocation = CustomLocation(
      key: key,
      name: name.trim(),
      emoji: emoji,
    );

    _customLocations.add(newLocation);
    debugPrint('   ✅ נוסף מיקום חדש - ${newLocation.emoji} ${newLocation.name}');

    await _saveLocations();
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (location added)');

    return true;
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
    
    // תמיכה בשם או key
    final key = _normalizeKey(nameOrKey);
    debugPrint('   🔑 Normalized key: "$key"');
    
    final exists = locationExists(key);
    
    if (!exists) {
      debugPrint('   ⚠️ מיקום "$key" לא נמצא למחיקה');
      return false;
    }

    _customLocations.removeWhere((loc) => loc.key == key);
    debugPrint('   ✅ מיקום "$key" נמחק (נשארו: ${_customLocations.length})');
    
    await _saveLocations();
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (location deleted)');
    
    return true;
  }

  /// איפוס - מחיקת כל המיקומים המותאמים
  /// 
  /// Example:
  /// ```dart
  /// await locationsProvider.reset();
  /// ```
  Future<void> reset() async {
    debugPrint('🔄 LocationsProvider.reset: מוחק ${_customLocations.length} מיקומים מותאמים');
    
    _customLocations.clear();

    await _saveLocations();
    notifyListeners();
    debugPrint('   🔔 LocationsProvider: notifyListeners() (reset)');
  }

  @override
  void dispose() {
    debugPrint('🧹 LocationsProvider.dispose');
    super.dispose();
  }
}
