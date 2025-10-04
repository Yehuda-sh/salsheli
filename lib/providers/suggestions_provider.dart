// 📄 File: lib/providers/suggestions_provider.dart
// תיאור: Provider לניהול המלצות חכמות - מנתח מזווה והיסטוריית קניות

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/suggestion.dart';
import '../models/inventory_item.dart';
import '../models/shopping_list.dart';
import '../models/receipt.dart';
import 'inventory_provider.dart';
import 'shopping_lists_provider.dart';
import 'user_context.dart';

class SuggestionsProvider with ChangeNotifier {
  final InventoryProvider _inventoryProvider;
  final ShoppingListsProvider _listsProvider;
  UserContext? _userContext;

  bool _isLoading = false;
  String? _errorMessage;
  List<Suggestion> _suggestions = [];

  static final Uuid _uuid = Uuid();

  SuggestionsProvider({
    required InventoryProvider inventoryProvider,
    required ShoppingListsProvider listsProvider,
    UserContext? userContext,
  }) : _inventoryProvider = inventoryProvider,
       _listsProvider = listsProvider,
       _userContext = userContext {
    // האזנה לשינויים במזווה ורשימות
    _inventoryProvider.addListener(_onDataChanged);
    _listsProvider.addListener(_onDataChanged);

    // טעינה ראשונית
    refresh();
  }

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  List<Suggestion> get suggestions => List.unmodifiable(_suggestions);

  // קבלת המלצות לפי עדיפות
  List<Suggestion> get highPriority =>
      _suggestions.where((s) => s.priority == 'high').toList();

  List<Suggestion> get mediumPriority =>
      _suggestions.where((s) => s.priority == 'medium').toList();

  List<Suggestion> get lowPriority =>
      _suggestions.where((s) => s.priority == 'low').toList();

  void _onDataChanged() {
    // כשהמזווה או הרשימות משתנים, נרענן המלצות
    refresh();
  }

  /// רענון כל ההמלצות
  Future<void> refresh() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSuggestions = <Suggestion>[];

      // 1. המלצות מהמזווה (פריטים שנגמרים)
      final inventorySuggestions = _analyzeInventory();
      newSuggestions.addAll(inventorySuggestions);

      // 2. המלצות מהיסטוריה (פריטים שנקנים לעיתים קרובות)
      final historySuggestions = _analyzeHistory();
      newSuggestions.addAll(historySuggestions);

      // 3. מיזוג המלצות כפולות
      _suggestions = _mergeDuplicates(newSuggestions);

      _errorMessage = null;
    } catch (e, st) {
      _errorMessage = 'שגיאה בחישוב המלצות: $e';
      debugPrintStack(label: 'SuggestionsProvider.refresh', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ניתוח המזווה - מחזיר פריטים שנגמרים
  List<Suggestion> _analyzeInventory() {
    final suggestions = <Suggestion>[];
    final items = _inventoryProvider.items;

    for (var item in items) {
      // אם הכמות נמוכה (פחות מ-2) או 0
      if (item.quantity <= 2) {
        final priority = item.quantity == 0 ? 'high' : 'medium';

        suggestions.add(
          Suggestion(
            id: _uuid.v4(),
            productName: item.productName,
            reason: 'running_low',
            category: item.category,
            suggestedQuantity: 1,
            unit: item.unit,
            priority: priority,
            source: 'inventory',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return suggestions;
  }

  /// ניתוח היסטוריה - מחזיר פריטים שנקנים לעיתים קרובות
  List<Suggestion> _analyzeHistory() {
    final suggestions = <Suggestion>[];
    final lists = _listsProvider.lists;

    // ספירת תדירות כל מוצר ברשימות ה-30 יום האחרונים
    final productFrequency = <String, int>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    for (var list in lists) {
      // רק רשימות מהחודש האחרון
      if (list.updatedDate.isAfter(thirtyDaysAgo)) {
        for (var item in list.items) {
          final name = item.name.trim().toLowerCase();
          productFrequency[name] = (productFrequency[name] ?? 0) + 1;
        }
      }
    }

    // המלצה על מוצרים שהופיעו לפחות 3 פעמים
    productFrequency.forEach((productName, count) {
      if (count >= 3) {
        // בדוק אם המוצר כבר קיים במלאי
        final existsInInventory = _inventoryProvider.items.any(
          (item) => item.productName.toLowerCase() == productName,
        );

        // אם לא קיים במלאי - המלץ עליו
        if (!existsInInventory) {
          suggestions.add(
            Suggestion(
              id: _uuid.v4(),
              productName: _capitalize(productName),
              reason: 'frequently_bought',
              category: 'כללי',
              suggestedQuantity: 1,
              unit: 'יחידות',
              priority: count >= 5 ? 'medium' : 'low',
              source: 'history',
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    });

    return suggestions;
  }

  /// מיזוג המלצות כפולות (אותו מוצר ממקורות שונים)
  List<Suggestion> _mergeDuplicates(List<Suggestion> suggestions) {
    final merged = <String, Suggestion>{};

    for (var suggestion in suggestions) {
      final key = suggestion.productName.toLowerCase();

      if (merged.containsKey(key)) {
        // כבר יש המלצה למוצר הזה - שלב
        final existing = merged[key]!;

        // אם שניהם ממקורות שונים - שנה ל-both
        String newReason = existing.reason;
        String newSource = existing.source;

        if (existing.source != suggestion.source) {
          newReason = 'both';
          newSource = 'both';
        }

        // השתמש בעדיפות הגבוהה יותר
        String newPriority = existing.priority;
        if (suggestion.priority == 'high' || existing.priority == 'high') {
          newPriority = 'high';
        } else if (suggestion.priority == 'medium' ||
            existing.priority == 'medium') {
          newPriority = 'medium';
        }

        merged[key] = existing.copyWith(
          reason: newReason,
          source: newSource,
          priority: newPriority,
        );
      } else {
        merged[key] = suggestion;
      }
    }

    // מיון לפי עדיפות
    final sorted = merged.values.toList();
    sorted.sort((a, b) {
      const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return sorted;
  }

  /// הסרת המלצה
  void removeSuggestion(String id) {
    _suggestions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// ניקוי כל ההמלצות
  void clearAll() {
    _suggestions = [];
    notifyListeners();
  }

  /// עזר - הופך אות ראשונה לגדולה
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _inventoryProvider.removeListener(_onDataChanged);
    _listsProvider.removeListener(_onDataChanged);
    super.dispose();
  }
}
