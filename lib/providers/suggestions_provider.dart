// lib/providers/suggestions_provider.dart — Suggestions provider — smart restock recommendations from inventory low-stock analysis

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/error_utils.dart';
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
  bool _isDisposed = false;
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
      if (kDebugMode) debugPrint('❌ [SuggestionsProvider] שגיאה בטעינת excluded products: $e');
      _excludedProducts = {};
    }
  }

  // ========== Safe Notify ==========

  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // ========== Getters ==========

  List<SmartSuggestion> get suggestions => List.unmodifiable(_suggestions);
  SmartSuggestion? get currentSuggestion => _currentSuggestion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🆕 המלצות פעילות (לא כולל session skipped)
  List<SmartSuggestion> get _activeSuggestions {
    return SuggestionsService.getActiveSuggestions(_suggestions)
        .where((s) => !_sessionSkippedProducts.contains(s.productName))
        .toList();
  }

  // ========== Initialization ==========

  Future<void> _init() async {
    try {
      // טעינת מוצרים מוחרגים מ-Hive
      await _loadExcludedProducts();
    } catch (e) {
      // Hive failure is non-fatal — continue without excluded products
      debugPrint('⚠️ SuggestionsProvider._init: $e');
    }

    // האזנה לשינויים במלאי
    _inventoryProvider.addListener(_onInventoryChanged);

    // 🔄 קריאה ידנית לטעינה ראשונית (listener לא מופעל אוטומטית בפעם הראשונה)
    _onInventoryChanged();
  }

  @override
  void dispose() {
    _isDisposed = true;
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
      _notifySafe();

      final inventoryItems = _inventoryProvider.items;

      // יצירת המלצות חדשות (static method)
      _suggestions = SuggestionsService.generateSuggestions(
        inventoryItems: inventoryItems,
        excludedProducts: _excludedProducts,
      );

      // טעינת המלצה נוכחית (static method)
      _currentSuggestion = SuggestionsService.getNextSuggestion(_suggestions);
    } catch (e) {
      _error = userFriendlyError(e, context: 'refreshSuggestions');
      if (kDebugMode) debugPrint('❌ [SuggestionsProvider] שגיאה ברענון: $e');
    } finally {
      _isLoading = false;
      _notifySafe();
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

      _notifySafe();
    } catch (e) {
      _error = userFriendlyError(e, context: 'addSuggestion');
      if (kDebugMode) debugPrint('❌ [SuggestionsProvider] שגיאה בהוספת המלצה: $e');
      _notifySafe();
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

    _notifySafe();
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

    _notifySafe();
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

      _notifySafe();
    } catch (e) {
      _error = userFriendlyError(e, context: 'addSuggestionById');
      if (kDebugMode) debugPrint('❌ [SuggestionsProvider] שגיאה בהוספת המלצה לפי ID: $e');
      _notifySafe();
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

      _notifySafe();
    } catch (e) {
      _error = userFriendlyError(e, context: 'dismissSuggestionById');
      if (kDebugMode) debugPrint('❌ [SuggestionsProvider] שגיאה בדחיית המלצה לפי ID: $e');
      _notifySafe();
    }
  }
}
