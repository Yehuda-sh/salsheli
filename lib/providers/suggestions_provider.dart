import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/smart_suggestion.dart';
import '../models/enums/suggestion_status.dart';
import '../services/suggestions_service.dart';
import 'inventory_provider.dart';

/// 💡 Provider לניהול המלצות חכמות
/// 
/// מנהל תור המלצות מהמזווה ומתעדכן אוטומטית
/// 
/// Persistence: מוצרים מוחרגים נשמרים ב-Hive
class SuggestionsProvider with ChangeNotifier {
  final InventoryProvider _inventoryProvider;
  static const String _excludedProductsBoxName = 'excluded_products';

  List<SmartSuggestion> _suggestions = [];
  SmartSuggestion? _currentSuggestion;
  bool _isLoading = false;
  String? _error;
  Set<String> _excludedProducts = {}; // מוצרים שנמחקו לצמיתות (persistent)

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
      
      debugPrint('💾 [SuggestionsProvider] נטענו ${_excludedProducts.length} מוצרים מוחרגים');
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
      
      debugPrint('💾 [SuggestionsProvider] נשמרו ${_excludedProducts.length} מוצרים מוחרגים');
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
      debugPrint('🗑️ [SuggestionsProvider] מוצר הוסר מהמוחרגים: $productName');
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
      debugPrint('⏭️ [SuggestionsProvider] מלאי טוען, ממתין לסיום');
      return;
    }
    
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
