// 📄 File: lib/providers/user_context.dart
//
// 🇮🇱 מנהל את ההקשר של המשתמש באפליקציה:
//     - מחזיק את פרטי המשתמש (UserEntity) והעדפותיו.
//     - טוען/שומר/מוחק משתמש בעזרת UserRepository.
//     - עוקב אחרי סטטיסטיקות ושומר העדפות UI.
//     - מאפשר ל-UI להגיב לשינויים (ChangeNotifier).
//
// 🇬🇧 Manages user context in the app:
//     - Holds user profile (UserEntity) and preferences.
//     - Loads/saves/deletes user via UserRepository.
//     - Tracks stats and UI preferences.
//     - Notifies UI of changes (ChangeNotifier).
//

import 'package:flutter/material.dart';
import '../models/user_entity.dart';
import '../repositories/user_repository.dart';

class UserContext with ChangeNotifier {
  final UserRepository _repository;

  UserEntity? _user;
  bool _isLoading = false;

  // --- UI Preferences ---
  ThemeMode _themeMode = ThemeMode.system;
  bool _compactView = false;
  bool _showPrices = true;

  UserContext({required UserRepository repository}) : _repository = repository;

  // === Getters ===
  UserEntity? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get displayName => _user?.name;

  ThemeMode get themeMode => _themeMode;
  bool get compactView => _compactView;
  bool get showPrices => _showPrices;

  // === User lifecycle ===
  Future<void> loadUser(String userId) async {
    debugPrint('👤 UserContext.loadUser: מתחיל לטעון משתמש $userId');
    _isLoading = true;
    notifyListeners();
    debugPrint('   🔔 UserContext: notifyListeners() #1 (isLoading=true)');

    try {
      _user = await _repository.fetchUser(userId);
      debugPrint('   ✅ UserContext: משתמש נטען: ${_user?.email}');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('   🔔 UserContext: notifyListeners() #2 (isLoading=false, user=${_user?.email})');
    }
  }

  Future<void> saveUser(UserEntity user) async {
    _user = await _repository.saveUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    if (_user != null) {
      await _repository.deleteUser(_user!.id);
    }
    _user = null;
    _resetPreferences();
    notifyListeners();
  }

  // === Preferences ===
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleCompactView() {
    _compactView = !_compactView;
    notifyListeners();
  }

  void toggleShowPrices() {
    _showPrices = !_showPrices;
    notifyListeners();
  }

  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _compactView = false;
    _showPrices = true;
  }
}
