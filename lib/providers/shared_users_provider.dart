import 'package:flutter/foundation.dart';
import '../models/shared_user.dart';
import '../models/enums/user_role.dart';
import '../repositories/shopping_lists_repository.dart';

/// Provider לניהול משתמשים משותפים ברשימה
class SharedUsersProvider extends ChangeNotifier {
  final ShoppingListsRepository _repository;

  SharedUsersProvider(this._repository);

  // === State ===

  List<SharedUser> _sharedUsers = [];
  bool _isLoading = false;
  String? _error;

  // === Getters ===

  List<SharedUser> get sharedUsers => List.unmodifiable(_sharedUsers);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // משתמשים לפי תפקיד
  List<SharedUser> get owners =>
      _sharedUsers.where((u) => u.role == UserRole.owner).toList();
  List<SharedUser> get admins =>
      _sharedUsers.where((u) => u.role == UserRole.admin).toList();
  List<SharedUser> get editors =>
      _sharedUsers.where((u) => u.role == UserRole.editor).toList();
  List<SharedUser> get viewers =>
      _sharedUsers.where((u) => u.role == UserRole.viewer).toList();

  // === Methods ===

  /// טוען את רשימת המשתמשים המשותפים
  void loadSharedUsers(List<SharedUser> users) {
    _sharedUsers = users;
    _error = null;
    notifyListeners();
  }

  /// מוסיף משתמש משותף
  Future<void> addSharedUser({
    required String listId,
    required String userId,
    required UserRole role,
    String? userName,
    String? userEmail,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addSharedUser(
        listId,
        userId,
        role.name,
        userName,
        userEmail,
      );

      // הוסף לרשימה המקומית
      final newUser = SharedUser(
        userId: userId,
        role: role,
        sharedAt: DateTime.now(),
        userName: userName,
        userEmail: userEmail,
      );

      _sharedUsers.add(newUser);
      debugPrint('✅ [SharedUsersProvider] הוסף משתמש: $userName ($role)');
    } catch (e) {
      _error = 'שגיאה בהוספת משתמש: $e';
      debugPrint('❌ [SharedUsersProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// מסיר משתמש משותף
  Future<void> removeSharedUser({
    required String listId,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.removeSharedUser(listId, userId);

      // הסר מהרשימה המקומית
      _sharedUsers.removeWhere((u) => u.userId == userId);
      debugPrint('✅ [SharedUsersProvider] הסיר משתמש: $userId');
    } catch (e) {
      _error = 'שגיאה בהסרת משתמש: $e';
      debugPrint('❌ [SharedUsersProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// מעדכן תפקיד משתמש
  Future<void> updateUserRole({
    required String listId,
    required String userId,
    required UserRole newRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUserRole(listId, userId, newRole.name);

      // עדכן ברשימה המקומית
      final index = _sharedUsers.indexWhere((u) => u.userId == userId);
      if (index != -1) {
        _sharedUsers[index] = _sharedUsers[index].copyWith(role: newRole);
      }

      debugPrint('✅ [SharedUsersProvider] עדכן תפקיד: $userId → $newRole');
    } catch (e) {
      _error = 'שגיאה בעדכון תפקיד: $e';
      debugPrint('❌ [SharedUsersProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// מחזיר משתמש לפי ID
  SharedUser? getUserById(String userId) {
    try {
      return _sharedUsers.firstWhere((u) => u.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// בדיקה אם משתמש קיים
  bool hasUser(String userId) {
    return _sharedUsers.any((u) => u.userId == userId);
  }

  /// ניקוי state
  void clear() {
    _sharedUsers = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
