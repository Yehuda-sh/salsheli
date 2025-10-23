import 'package:flutter/foundation.dart';
import 'package:memozap/models/suggestions/smart_suggestion.dart';
import 'package:memozap/models/suggestions/suggestion_status.dart';
import 'package:memozap/services/suggestions/suggestions_service.dart';
import 'package:memozap/providers/inventory_provider.dart';

/// 💡 Provider לניהול המלצות חכמות
/// 
/// מנהל תור המלצות מהמזווה ומתעדכן אוטומטית
class SuggestionsProvider with ChangeNotifier {
  final SuggestionsService _service;
  final InventoryProvider _inventoryProvider;

  List<SmartSuggestion> _suggestions = [];
  SmartSuggestion? _currentSuggestion;
  bool _isLoading = false;
  String? _error;

  SuggestionsProvider({
    required SuggestionsService service,
    required InventoryProvider inventoryProvider,
  })  : _service = service,
        _inventoryProvider = inventoryProvider {
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
      
      // יצירת המלצות חדשות
      _suggestions = await _service.generateSuggestions(inventoryItems);
      
      // עדכון המלצות קיימות
      if (_suggestions.isNotEmpty) {
        await _service.updateSuggestionsFromInventory(
          _suggestions,
          inventoryItems,
        );
      }

      // ניקוי ישנות
      await _service.cleanupOldSuggestions(_suggestions);

      // טעינת המלצה נוכחית
      _currentSuggestion = _service.getNextSuggestion(_suggestions);

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
  Future<void> addCurrentSuggestion() async {
    if (_currentSuggestion == null) {
      debugPrint('⚠️ [SuggestionsProvider] אין המלצה נוכחית להוספה');
      return;
    }

    try {
      debugPrint('➕ [SuggestionsProvider] מוסיף המלצה: ${_currentSuggestion!.productName}');
      
      // עדכון סטטוס ל-added
      await _service.addSuggestion(_currentSuggestion!);
      
      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = _currentSuggestion!.copyWith(
          status: SuggestionStatus.added,
        );
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
      
      // דחייה לשבוע
      const duration = Duration(days: 7);
      await _service.dismissSuggestion(_currentSuggestion!, duration);
      
      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = _currentSuggestion!.copyWith(
          status: SuggestionStatus.dismissed,
          dismissedUntil: DateTime.now().add(duration),
        );
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
      
      // מחיקה
      await _service.deleteSuggestion(_currentSuggestion!, duration);
      
      // עדכון ברשימה המקומית
      final index = _suggestions.indexWhere((s) => s.id == _currentSuggestion!.id);
      if (index != -1) {
        _suggestions[index] = _currentSuggestion!.copyWith(
          status: SuggestionStatus.deleted,
          dismissedUntil: duration != null ? DateTime.now().add(duration) : null,
        );
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
    _currentSuggestion = _service.getNextSuggestion(_suggestions);
    debugPrint('💡 [SuggestionsProvider] המלצה הבאה: ${_currentSuggestion?.productName ?? "אין עוד"}');
  }

  /// 🔄 איפוס שגיאה
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
