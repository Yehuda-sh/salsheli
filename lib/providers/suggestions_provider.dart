import 'package:flutter/foundation.dart';
import '../models/smart_suggestion.dart';
import '../models/enums/suggestion_status.dart';
import '../services/suggestions_service.dart';
import 'inventory_provider.dart';

/// 💡 Provider לניהול המלצות חכמות
/// 
/// מנהל תור המלצות מהמזווה ומתעדכן אוטומטית
class SuggestionsProvider with ChangeNotifier {
  final InventoryProvider _inventoryProvider;

  List<SmartSuggestion> _suggestions = [];
  SmartSuggestion? _currentSuggestion;
  bool _isLoading = false;
  String? _error;
  Set<String> _excludedProducts = {}; // מוצרים שנמחקו לצמיתות

  SuggestionsProvider({
    required InventoryProvider inventoryProvider,
  })  : _inventoryProvider = inventoryProvider {
    _init();
  }

  // ========== Getters ==========

  List<SmartSuggestion> get suggestions => List.unmodifiable(_suggestions);
  SmartSuggestion? get currentSuggestion => _currentSuggestion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCurrentSuggestion => _currentSuggestion != null;
  int get pendingSuggestionsCount =>
      _suggestions.where((s) => s.isActive).length;

  // ========== Initialization ==========

  void _init() {
    // האזנה לשינויים במלאי
    _inventoryProvider.addListener(_onInventoryChanged);
    
    // טעינה ראשונית
    refreshSuggestions();
  }

  @override
  void dispose() {
    _inventoryProvider.removeListener(_onInventoryChanged);
    super.dispose();
  }

  void _onInventoryChanged() {
    debugPrint('💡 [SuggestionsProvider] מלאי השתנה - מעדכן המלצות');
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

      debugPrint('💡 [SuggestionsProvider] רענון הושלם: ${_suggestions.length} המלצות');
      debugPrint('💡 [SuggestionsProvider] המלצה נוכחית: ${_currentSuggestion?.productName ?? "אין"}');
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
      debugPrint('⚠️ [SuggestionsProvider] אין המלצה נוכחית להוספה');
      return;
    }

    try {
      debugPrint('➕ [SuggestionsProvider] מוסיף המלצה: ${_currentSuggestion!.productName}');
      
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
      debugPrint('⚠️ [SuggestionsProvider] אין המלצה נוכחית לדחייה');
      return;
    }

    try {
      debugPrint('⏭️ [SuggestionsProvider] דוחה המלצה: ${_currentSuggestion!.productName}');
      
      // דחייה לשבוע (static method)
      const duration = Duration(days: 7);
      final updatedSuggestion = SuggestionsService.dismissSuggestion(
        _currentSuggestion!,
        duration: duration,
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
      debugPrint('⚠️ [SuggestionsProvider] אין המלצה נוכחית למחיקה');
      return;
    }

    try {
      final durationText = duration == null
          ? 'לצמיתות'
          : '${duration.inDays} ימים';
      debugPrint('❌ [SuggestionsProvider] מוחק המלצה $durationText: ${_currentSuggestion!.productName}');
      
      // מחיקה (static method)
      final updatedSuggestion = SuggestionsService.deleteSuggestion(
        _currentSuggestion!,
        duration: duration,
      );
      
      // אם מחיקה קבועה - הוסף לרשימת מוצרים מוחרגים
      if (duration == null) {
        _excludedProducts.add(_currentSuggestion!.productName);
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

  /// 📊 טעינת המלצה הבאה מהתור
  Future<void> _loadNextSuggestion() async {
    _currentSuggestion = SuggestionsService.getNextSuggestion(_suggestions);
    debugPrint('💡 [SuggestionsProvider] המלצה הבאה: ${_currentSuggestion?.productName ?? "אין עוד"}');
  }

  /// 🔄 איפוס שגיאה
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
