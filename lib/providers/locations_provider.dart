// 📄 File: lib/providers/locations_provider.dart
// תיאור: Provider לניהול מיקומי אחסון מותאמים אישית
//
// תפקידים:
// - ניהול רשימת מיקומים שהמשתמש הוסיף
// - שמירה/טעינה מ-SharedPreferences
// - הוספה, מחיקה, קריאה
//
// שימוש:
// ```dart
// final provider = context.read<LocationsProvider>();
// await provider.addLocation("מקפיא נוסף");
// ```

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/custom_location.dart';
import '../core/constants.dart';

/// Provider לניהול מיקומי אחסון מותאמים
class LocationsProvider with ChangeNotifier {
  // רשימת מיקומים מותאמים פרטית
  List<CustomLocation> _customLocations = [];

  /// מפתח לשמירה ב-SharedPreferences
  static const String _prefsKey = 'custom_storage_locations';

  /// קונסטרקטור - טוען נתונים אוטומטית
  LocationsProvider() {
    _loadLocations();
  }

  /// קבלת רשימת מיקומים מותאמים (unmodifiable)
  List<CustomLocation> get customLocations =>
      List.unmodifiable(_customLocations);

  /// בדיקה אם מיקום קיים (גם בברירת מחדל וגם במותאמים)
  bool locationExists(String key) {
    return kStorageLocations.containsKey(key) ||
        _customLocations.any((loc) => loc.key == key);
  }

  /// טעינת מיקומים מותאמים מהזיכרון
  Future<void> _loadLocations() async {
    try {
      debugPrint('📂 LocationsProvider: טוען מיקומים מותאמים...');

      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getString(_prefsKey);

      if (locationsJson != null) {
        final decoded = jsonDecode(locationsJson) as List;
        _customLocations = decoded
            .map(
              (item) => CustomLocation.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        debugPrint(
          '✅ LocationsProvider: נטענו ${_customLocations.length} מיקומים',
        );
      } else {
        debugPrint('ℹ️ LocationsProvider: אין מיקומים מותאמים שמורים');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ LocationsProvider: שגיאה בטעינת מיקומים - $e');
    }
  }

  /// שמירת מיקומים מותאמים
  Future<void> _saveLocations() async {
    try {
      debugPrint(
        '💾 LocationsProvider: שומר ${_customLocations.length} מיקומים...',
      );

      final prefs = await SharedPreferences.getInstance();
      final jsonList = _customLocations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));

      debugPrint('✅ LocationsProvider: מיקומים נשמרו בהצלחה');
    } catch (e) {
      debugPrint('❌ LocationsProvider: שגיאה בשמירת מיקומים - $e');
    }
  }

  /// הוספת מיקום חדש
  ///
  /// מחזיר true אם הצליח, false אם המיקום כבר קיים
  Future<bool> addLocation(String name, {String emoji = "📍"}) async {
    if (name.trim().isEmpty) {
      debugPrint('⚠️ LocationsProvider: שם ריק - מבטל');
      return false;
    }

    // יצירת key ייחודי
    final key = name.trim().toLowerCase().replaceAll(" ", "_");

    // בדיקה אם קיים
    if (locationExists(key)) {
      debugPrint('⚠️ LocationsProvider: מיקום "$key" כבר קיים');
      return false;
    }

    // הוספה לרשימה
    final newLocation = CustomLocation(
      key: key,
      name: name.trim(),
      emoji: emoji,
    );

    _customLocations.add(newLocation);
    debugPrint('✅ LocationsProvider: נוסף מיקום חדש - ${newLocation.name}');

    await _saveLocations();
    notifyListeners();

    return true;
  }

  /// מחיקת מיקום מותאם
  ///
  /// מחזיר true אם הצליח למחוק
  Future<bool> deleteLocation(String key) async {
    final initialLength = _customLocations.length;

    _customLocations.removeWhere((loc) => loc.key == key);

    if (_customLocations.length < initialLength) {
      debugPrint('✅ LocationsProvider: מיקום "$key" נמחק');
      await _saveLocations();
      notifyListeners();
      return true;
    }

    debugPrint('⚠️ LocationsProvider: מיקום "$key" לא נמצא למחיקה');
    return false;
  }

  /// איפוס - מחיקת כל המיקומים המותאמים
  Future<void> reset() async {
    _customLocations.clear();
    debugPrint('🔄 LocationsProvider: כל המיקומים המותאמים נמחקו');

    await _saveLocations();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('👋 LocationsProvider: Disposing...');
    super.dispose();
  }
}
