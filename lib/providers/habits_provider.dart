// 📄 File: lib/providers/habits_provider.dart
//
// 🇮🇱 **Habits Provider** - ניהול מצב הרגלי קנייה
//
// **מטרה:**
// - ניהול רשימת הרגלי קנייה
// - סנכרון עם Firestore
// - חיפוש וסינון
// - Error handling + Recovery
//
// **Dependencies:**
// - UserContext (household_id)
// - FirebaseHabitsRepository
//
// **State:**
// - _habits: רשימת כל ההרגלים
// - _isLoading: האם בטעינה
// - _errorMessage: הודעת שגיאה
//
// **Version:** 1.0

import 'package:flutter/foundation.dart';
import '../models/habit_preference.dart';
import '../repositories/firebase_habits_repository.dart';
import 'user_context.dart';

class HabitsProvider with ChangeNotifier {
  final FirebaseHabitsRepository _repository;
  UserContext? _userContext;
  bool _listening = false;

  // State
  List<HabitPreference> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  HabitsProvider(this._repository);

  // Getters
  List<HabitPreference> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _habits.isEmpty;

  /// 📊 הרגלים לפי תדירות
  List<HabitPreference> get habitsByFrequency {
    final sorted = List<HabitPreference>.from(_habits);
    sorted.sort((a, b) => a.frequencyDays.compareTo(b.frequencyDays));
    return sorted;
  }

  /// 🚨 הרגלים שדורשים קנייה (פחות מיום)
  List<HabitPreference> get dueHabits {
    return _habits.where((h) => h.isDueForPurchase).toList();
  }

  /// 🔄 חיבור UserContext
  void updateUserContext(UserContext newContext) {
    debugPrint('🧠 HabitsProvider.updateUserContext');

    // ניקוי listener ישן
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }

    // חיבור listener חדש
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    _initialize();
  }

  /// 🎬 אתחול
  void _initialize() {
    debugPrint('🧠 HabitsProvider._initialize');

    if (_userContext?.isLoggedIn == true) {
      loadHabits();
    } else {
      _clearData();
    }
  }

  /// 👤 טיפול בשינוי משתמש
  void _onUserChanged() {
    debugPrint('🧠 HabitsProvider._onUserChanged: isLoggedIn=${_userContext?.isLoggedIn}');

    if (_userContext?.isLoggedIn == true) {
      loadHabits();
    } else {
      _clearData();
    }
  }

  /// 📥 טעינת הרגלים
  Future<void> loadHabits() async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.loadHabits: אין household_id');
      return;
    }

    debugPrint('🧠 HabitsProvider.loadHabits: household=$householdId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _repository.fetchHabits(householdId);
      debugPrint('   ✅ ${_habits.length} הרגלים נטענו');
    } catch (e) {
      _errorMessage = 'שגיאה בטעינת הרגלים: $e';
      debugPrint('   ❌ $_errorMessage');
      notifyListeners(); // חשוב! notify גם בשגיאה
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ יצירת הרגל חדש
  Future<void> createHabit({
    required String preferredProduct,
    required String genericName,
    required int frequencyDays,
    DateTime? lastPurchased,
  }) async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.createHabit: אין household_id');
      throw Exception('נדרש household_id');
    }

    debugPrint('🧠 HabitsProvider.createHabit: "$preferredProduct"');

    final now = DateTime.now();
    final habit = HabitPreference(
      id: '', // יוצר ב-Firestore
      preferredProduct: preferredProduct,
      genericName: genericName,
      frequencyDays: frequencyDays,
      lastPurchased: lastPurchased ?? now,
      createdDate: now,
      updatedDate: now,
    );

    try {
      final created = await _repository.createHabit(habit, householdId);
      _habits.add(created);
      debugPrint('   ✅ הרגל נוסף: ${created.id}');
      notifyListeners();
    } catch (e) {
      debugPrint('   ❌ שגיאה ביצירת הרגל: $e');
      rethrow;
    }
  }

  /// ✏️ עדכון הרגל
  Future<void> updateHabit(HabitPreference updatedHabit) async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.updateHabit: אין household_id');
      throw Exception('נדרש household_id');
    }

    debugPrint('🧠 HabitsProvider.updateHabit: ${updatedHabit.id}');

    try {
      await _repository.updateHabit(updatedHabit, householdId);

      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit.copyWith(updatedDate: DateTime.now());
        debugPrint('   ✅ הרגל עודכן במקומית');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('   ❌ שגיאה בעדכון הרגל: $e');
      rethrow;
    }
  }

  /// מוחק הרגל קנייה
  /// 
  /// מוודא שיש household_id לפני המחיקה, מבצע מחיקה ב-Firestore,
  /// ומעדכן את המצב המקומי.
  /// 
  /// Parameters:
  ///   - [habitId]: מזהה ההרגל למחיקה
  /// 
  /// Throws:
  ///   - Exception אם אין household_id
  ///   - HabitsRepositoryException אם המחיקה נכשלת
  /// 
  /// Example:
  /// ```dart
  /// await habitsProvider.deleteHabit('habit_123');
  /// ```
  Future<void> deleteHabit(String habitId) async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.deleteHabit: אין household_id');
      throw Exception('נדרש household_id');
    }

    debugPrint('🧠 HabitsProvider.deleteHabit: $habitId');

    try {
      await _repository.deleteHabit(habitId, householdId);
      _habits.removeWhere((h) => h.id == habitId);
      debugPrint('   ✅ הרגל נמחק');
      notifyListeners();
    } catch (e) {
      debugPrint('   ❌ שגיאה במחיקת הרגל: $e');
      rethrow;
    }
  }

  /// ↩️ שחזור הרגל שנמחק
  Future<void> restoreHabit(HabitPreference habit) async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.restoreHabit: אין household_id');
      throw Exception('נדרש household_id');
    }

    debugPrint('🧠 HabitsProvider.restoreHabit: ${habit.preferredProduct}');

    try {
      final restored = await _repository.createHabit(habit, householdId);
      _habits.add(restored);
      debugPrint('   ✅ הרגל שוחזר: ${restored.id}');
      notifyListeners();
    } catch (e) {
      debugPrint('   ❌ שגיאה בשחזור הרגל: $e');
      rethrow;
    }
  }

  /// 🔍 חיפוש לפי מוצר
  Future<HabitPreference?> findByProduct(String productName) async {
    final householdId = _userContext?.householdId;
    if (householdId == null) {
      debugPrint('🧠 HabitsProvider.findByProduct: אין household_id');
      return null;
    }

    debugPrint('🧠 HabitsProvider.findByProduct: "$productName"');

    try {
      return await _repository.findByProduct(productName, householdId);
    } catch (e) {
      debugPrint('   ❌ שגיאה בחיפוש: $e');
      return null;
    }
  }

  /// 🔁 נסה שוב (recovery)
  Future<void> retry() async {
    debugPrint('🧠 HabitsProvider.retry');
    _errorMessage = null;
    await loadHabits();
  }

  /// 🧹 ניקוי מלא
  void clearAll() {
    debugPrint('🧠 HabitsProvider.clearAll');
    _habits = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 🗑️ ניקוי נתונים
  void _clearData() {
    debugPrint('🧠 HabitsProvider._clearData');
    _habits = [];
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🧠 HabitsProvider.dispose');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
