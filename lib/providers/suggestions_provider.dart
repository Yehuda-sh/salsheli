import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/smart_suggestion.dart';
import '../services/suggestions_service.dart';
import 'inventory_provider.dart';

/// 💡 Provider לניהול המלצות חכמות
///
/// מנהל תור המלצות מהמזווה ומתעדכן אוטומטית
///
/// Persistence: מוצרים מוחרגים נשמרים ב-Hive
///
/// 🆕 תמיכה בקרוסלה:
///    - [הוסף] → מוסיף לרשימה, לא יופיע שוב
///    - [הבא] → עובר להמלצה הבאה, יחזור בסוף הסבב
///    - [לא עכשיו] → לא יופיע בקנייה הזו, כן בקנייה הבאה
class SuggestionsProvider with ChangeNotifier {
  final InventoryProvider _inventoryProvider;
  static const String _excludedProductsBoxName = 'excluded_products';

  List<SmartSuggestion> _suggestions = [];
  SmartSuggestion? _currentSuggestion;
  bool _isLoading = false;
  String? _error;
  Set<String> _excludedProducts = {}; // מוצרים שנמחקו לצמיתות (persistent)

  // 🆕 Carousel state
  int _currentIndex = 0; // אינדקס נוכחי בקרוסלה
  final Set<String> _sessionSkippedProducts = {}; // מוצרים שנדלגו בסשן הזה בלבד

  SuggestionsProvider({
    required InventoryProvider inventoryProvider,
  })  : _inventoryProvider = inventoryProvider {
    _init();
  }

  // ========== Persistence ==========

  /// 💾 טעינת מוצרים מוחרגים מ-Hive
  Future<void> _loadExcludedProducts() async {
    try {
      if (!Hive.isBoxOpen(_excludedProductsBoxName)) {
        await Hive.openBox<String>(_excludedProductsBoxName);
      }

      final box = Hive.box<String>(_excludedProductsBoxName);
      _excludedProducts = box.values.toSet();
    } catch (e) {
      debugPrint('❌ [SuggestionsProvider] שגיאה בטעינת excluded products: $e');
      _excludedProducts = {};
    }
  }

  /// 💾 שמירת מוצרים מוחרגים ב-Hive
  Future<void> _saveExcludedProducts() async {
    try {
      if (!Hive.isBoxOpen(_excludedProductsBoxName)) {
        await Hive.openBox<String>(_excludedProductsBoxName);
      }

      final box = Hive.box<String>(_excludedProductsBoxName);
      await box.clear();
      await box.addAll(_excludedProducts);
    } catch (e) {
      debugPrint('❌ [SuggestionsProvider] שגיאה בשמירת excluded products: $e');
    }
  }

  // ========== Getters ==========

  List<SmartSuggestion> get suggestions => List.unmodifiable(_suggestions);
  SmartSuggestion? get currentSuggestion => _currentSuggestion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCurrentSuggestion => _currentSuggestion != null;
  int get pendingSuggestionsCount =>
      _suggestions.where((s) => s.isActive).length;

  /// 🆕 המלצות פעילות (לא כולל session skipped)
  List<SmartSuggestion> get _activeSuggestions {
    return SuggestionsService.getActiveSuggestions(_suggestions)
        .where((s) => !_sessionSkippedProducts.contains(s.productName))
        .toList();
  }

  /// 🆕 כמה המלצות פעילות יש בקרוסלה
  int get carouselCount => _activeSuggestions.length;

  /// 🆕 אינדקס נוכחי בקרוסלה (1-based לתצוגה)
  int get currentPosition => carouselCount > 0 ? _currentIndex + 1 : 0;

  // ========== Initialization ==========

  void _init() async {
    // טעינת מוצרים מוחרגים מ-Hive
    await _loadExcludedProducts();
    
    // האזנה לשינויים במלאי
    _inventoryProvider.addListener(_onInventoryChanged);
    
    // 🔄 קריאה ידנית לטעינה ראשונית (listener לא מופעל אוטומטית בפעם הראשונה)
    _onInventoryChanged();
  }

  /// 🗑️ מחיקת מוצר מרשימת המוחרגים (שחזור המלצות)
  ///
  /// Example:
  /// ```dart
  /// await provider.removeFromExcluded('חלב');
  /// ```
  Future<void> removeFromExcluded(String productName) async {
    if (_excludedProducts.remove(productName)) {
      await _saveExcludedProducts();
      await refreshSuggestions();
    }
  }

  /// 📋 קבלת רשימת מוצרים מוחרגים
  Set<String> get excludedProducts => Set.unmodifiable(_excludedProducts);

  @override
  void dispose() {
    _inventoryProvider.removeListener(_onInventoryChanged);
    super.dispose();
  }

  void _onInventoryChanged() {
    // ⏭️ דלג אם המלאי עדיין טוען (isLoading=true)
    if (_inventoryProvider.isLoading) {
      return;
    }

    refreshSuggestions();
  }

  // ========== Main Actions ==========

  /// 🔄 רענון המלצות מהמזווה
  Future<void> refreshSuggestions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final inventoryItems = _inventoryProvider.items;

      // יצירת המלצות חדשות (static method)
      _suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: inventoryItems,
        excludedProducts: _excludedProducts,
      );

      // טעינת המלצה נוכחית (static method)
      _currentSuggestion = SuggestionsService.getNextSuggestion(_suggestions);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה ברענון: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ הוספת המלצה נוכחית לרשימה
  Future<void> addCurrentSuggestion(String listId) async {
    if (_currentSuggestion == null) {
      return;
    }

    try {
      // עדכון סטטוס ל-added (static method)
      final updatedSuggestion = SuggestionsService.markAsAdded(
        _currentSuggestion!,
        listId: listId,
      );

      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = updatedSuggestion;
      }

      // טעינת המלצה חדשה
      await _loadNextSuggestion();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה בהוספת המלצה: $e');
      notifyListeners();
    }
  }

  /// ⏭️ דחיית המלצה נוכחית
  Future<void> dismissCurrentSuggestion() async {
    if (_currentSuggestion == null) {
      return;
    }

    try {
      // דחייה לשבוע (static method)
      final updatedSuggestion = SuggestionsService.dismissSuggestion(
        _currentSuggestion!,
      );

      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = updatedSuggestion;
      }

      // טעינת המלצה חדשה
      await _loadNextSuggestion();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה בדחיית המלצה: $e');
      notifyListeners();
    }
  }

  /// ❌ מחיקת המלצה נוכחית
  Future<void> deleteCurrentSuggestion(Duration? duration) async {
    if (_currentSuggestion == null) {
      return;
    }

    try {
      // מחיקה (static method)
      final updatedSuggestion = SuggestionsService.deleteSuggestion(
        _currentSuggestion!,
        duration: duration,
      );

      // אם מחיקה קבועה - הוסף לרשימת מוצרים מוחרגים + שמור
      if (duration == null) {
        _excludedProducts.add(_currentSuggestion!.productName);
        await _saveExcludedProducts(); // 💾 שמירה persistent
      }

      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = updatedSuggestion;
      }

      // טעינת המלצה חדשה
      await _loadNextSuggestion();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה במחיקת המלצה: $e');
      notifyListeners();
    }
  }

  /// 📊 טעינת המלצה הבאה מהתור (קרוסלה)
  Future<void> _loadNextSuggestion() async {
    final active = _activeSuggestions;

    if (active.isEmpty) {
      _currentSuggestion = null;
      _currentIndex = 0;
      return;
    }

    // וודא שהאינדקס בטווח
    if (_currentIndex >= active.length) {
      _currentIndex = 0; // חזור להתחלה (קרוסלה)
    }

    _currentSuggestion = active[_currentIndex];
  }

  // ========== 🆕 Carousel Actions ==========

  /// ⏭️ עבור להמלצה הבאה (קרוסלה - יחזור בסוף הסבב)
  ///
  /// משתמש בכפתור "הבא" - לא מוחק, רק עובר הלאה
  Future<void> moveToNext() async {
    final active = _activeSuggestions;

    if (active.isEmpty) {
      _currentSuggestion = null;
      return;
    }

    // עבור לאינדקס הבא (עם wrap-around)
    _currentIndex = (_currentIndex + 1) % active.length;
    _currentSuggestion = active[_currentIndex];

    notifyListeners();
  }

  /// ⏮️ חזור להמלצה הקודמת (קרוסלה)
  Future<void> moveToPrevious() async {
    final active = _activeSuggestions;

    if (active.isEmpty) {
      _currentSuggestion = null;
      return;
    }

    // חזור לאינדקס הקודם (עם wrap-around)
    _currentIndex = (_currentIndex - 1 + active.length) % active.length;
    _currentSuggestion = active[_currentIndex];

    notifyListeners();
  }

  /// 🚫 דלג על המלצה בסשן הזה בלבד (כפתור "לא עכשיו")
  ///
  /// לא יופיע בקנייה הנוכחית, אבל כן בקנייה הבאה
  Future<void> skipForSession() async {
    if (_currentSuggestion == null) return;

    // הוסף לרשימת הדילוגים של הסשן
    _sessionSkippedProducts.add(_currentSuggestion!.productName);

    // עדכן את האינדקס והמלצה נוכחית
    final active = _activeSuggestions;

    if (active.isEmpty) {
      _currentSuggestion = null;
      _currentIndex = 0;
    } else {
      // וודא שהאינדקס בטווח
      if (_currentIndex >= active.length) {
        _currentIndex = 0;
      }
      _currentSuggestion = active[_currentIndex];
    }

    notifyListeners();
  }

  /// 🔄 נקה דילוגי סשן (קריאה כשמסיימים קנייה או יוצאים)
  void clearSessionSkips() {
    _sessionSkippedProducts.clear();
    _currentIndex = 0;
    _loadNextSuggestion();
    notifyListeners();
  }

  /// 🔄 איפוס שגיאה
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== 🆕 Methods by ID (for multi-item views) ==========

  /// ➕ הוספת המלצה לפי ID לרשימה
  ///
  /// משמש לתצוגות שמציגות מספר המלצות בו-זמנית (כמו SuggestionsTodayCard)
  Future<void> addSuggestionById(String suggestionId, String listId) async {
    final suggestionIndex = _suggestions.indexWhere((s) => s.id == suggestionId);
    if (suggestionIndex == -1) return;

    try {
      final suggestion = _suggestions[suggestionIndex];

      // עדכון סטטוס ל-added
      final updatedSuggestion = SuggestionsService.markAsAdded(
        suggestion,
        listId: listId,
      );

      // עדכון ברשימה המקומית
      _suggestions[suggestionIndex] = updatedSuggestion;

      // אם זו ההמלצה הנוכחית - טען את הבאה
      if (_currentSuggestion?.id == suggestionId) {
        await _loadNextSuggestion();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה בהוספת המלצה לפי ID: $e');
      notifyListeners();
    }
  }

  /// ⏭️ דחיית המלצה לפי ID
  ///
  /// משמש לתצוגות שמציגות מספר המלצות בו-זמנית
  Future<void> dismissSuggestionById(String suggestionId) async {
    final suggestionIndex = _suggestions.indexWhere((s) => s.id == suggestionId);
    if (suggestionIndex == -1) return;

    try {
      final suggestion = _suggestions[suggestionIndex];

      // דחייה לשבוע
      final updatedSuggestion = SuggestionsService.dismissSuggestion(suggestion);

      // עדכון ברשימה המקומית
      _suggestions[suggestionIndex] = updatedSuggestion;

      // אם זו ההמלצה הנוכחית - טען את הבאה
      if (_currentSuggestion?.id == suggestionId) {
        await _loadNextSuggestion();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [SuggestionsProvider] שגיאה בדחיית המלצה לפי ID: $e');
      notifyListeners();
    }
  }
}
