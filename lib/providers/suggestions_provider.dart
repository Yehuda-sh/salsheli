// 📄 File: lib/providers/suggestions_provider.dart
//
// 🎯 Purpose: Provider להמלצות חכמות - ניתוח מזווה והיסטוריית קניות ליצירת המלצות רלוונטיות
//
// 📦 Dependencies:
// - InventoryProvider: גישה למזווה ופריטים שנגמרים
// - ShoppingListsProvider: גישה להיסטוריית קניות
//
// ✨ Features:
// - 🧠 ניתוח חכם: מזהה מוצרים שנגמרים + מוצרים שנקנים לעיתים קרובות
// - 🔄 Auto-refresh: מאזין לשינויים במזווה ורשימות ומתעדכן אוטומטית
// - 🎯 עדיפויות: high/medium/low לפי דחיפות
// - 📊 מיזוג חכם: משלב המלצות כפולות ממקורות שונים
// - 🐛 Logging מפורט: כל שלב בניתוח עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<SuggestionsProvider>();
// final all = provider.suggestions;
// final urgent = provider.highPriority;
//
// // ברענון ידני:
// await context.read<SuggestionsProvider>().refresh();
//
// // בהסרת המלצה:
// context.read<SuggestionsProvider>().removeSuggestion(id);
// ```
//
// 🔄 State Flow:
// 1. Constructor → מאזין ל-InventoryProvider + ShoppingListsProvider
// 2. Data changes → _onDataChanged() → refresh()
// 3. refresh() → _analyzeInventory() + _analyzeHistory() → _mergeDuplicates()
// 4. notifyListeners() → UI מתעדכן
//
// 🧮 Logic:
// - Inventory: quantity ≤ 2 → suggestion (0=high, 1-2=medium)
// - History: מוצר שהופיע 3+ פעמים ב-30 הימים האחרונים
// - Merge: אותו מוצר ממקורות שונים → עדיפות מקסימלית + source='both'
//
// Version: 2.0 (עם logging מלא + תיעוד מקיף)
// Last Updated: 06/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/suggestion.dart';
import 'inventory_provider.dart';
import 'shopping_lists_provider.dart';

class SuggestionsProvider with ChangeNotifier {
  final InventoryProvider _inventoryProvider;
  final ShoppingListsProvider _listsProvider;

  bool _isLoading = false;
  String? _errorMessage;
  List<Suggestion> _suggestions = [];

  static final Uuid _uuid = Uuid();

  SuggestionsProvider({
    required InventoryProvider inventoryProvider,
    required ShoppingListsProvider listsProvider,
  }) : _inventoryProvider = inventoryProvider,
       _listsProvider = listsProvider {
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

  /// רענון כל ההמלצות - מנתח מזווה + היסטוריה
  /// 
  /// Example:
  /// ```dart
  /// await suggestionsProvider.refresh();
  /// ```
  Future<void> refresh() async {
    if (_isLoading) {
      debugPrint('⏳ SuggestionsProvider.refresh: כבר בתהליך ניתוח, מדלג');
      return;
    }

    debugPrint('\n═══════════════════════════════════════════');
    debugPrint('🔄 SuggestionsProvider.refresh() - מתחיל ניתוח');
    debugPrint('═══════════════════════════════════════════');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 SuggestionsProvider: notifyListeners() (isLoading=true)');

    try {
      final newSuggestions = <Suggestion>[];

      // 1. המלצות מהמזווה (פריטים שנגמרים)
      debugPrint('\n📦 שלב 1: ניתוח מזווה');
      final inventorySuggestions = _analyzeInventory();
      newSuggestions.addAll(inventorySuggestions);
      debugPrint('   ✅ נוצרו ${inventorySuggestions.length} המלצות ממזווה');

      // 2. המלצות מהיסטוריה (פריטים שנקנים לעיתים קרובות)
      debugPrint('\n📊 שלב 2: ניתוח היסטוריה');
      final historySuggestions = _analyzeHistory();
      newSuggestions.addAll(historySuggestions);
      debugPrint('   ✅ נוצרו ${historySuggestions.length} המלצות מהיסטוריה');

      // 3. מיזוג המלצות כפולות
      debugPrint('\n🔀 שלב 3: מיזוג המלצות כפולות');
      debugPrint('   לפני מיזוג: ${newSuggestions.length} המלצות');
      _suggestions = _mergeDuplicates(newSuggestions);
      debugPrint('   ✅ אחרי מיזוג: ${_suggestions.length} המלצות');

      _errorMessage = null;
      
      debugPrint('\n✅ SuggestionsProvider.refresh הושלם בהצלחה');
      debugPrint('   📊 סה"כ המלצות: ${_suggestions.length}');
      debugPrint('   🔴 High: ${highPriority.length}');
      debugPrint('   🟡 Medium: ${mediumPriority.length}');
      debugPrint('   🟢 Low: ${lowPriority.length}');
    } catch (e, st) {
      _errorMessage = 'שגיאה בחישוב המלצות: $e';
      debugPrint('❌ SuggestionsProvider.refresh: שגיאה - $e');
      debugPrintStack(label: 'SuggestionsProvider.refresh', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 SuggestionsProvider: notifyListeners() (isLoading=false)');
    debugPrint('═══════════════════════════════════════════\n');
  }

  /// ניתוח המזווה - מחזיר פריטים שנגמרים
  /// 
  /// Logic: quantity ≤ 2 → suggestion (0=high, 1-2=medium)
  List<Suggestion> _analyzeInventory() {
    final suggestions = <Suggestion>[];
    final items = _inventoryProvider.items;
    
    debugPrint('🔍 _analyzeInventory: בודק ${items.length} פריטים במזווה');

    int highCount = 0;
    int mediumCount = 0;

    for (var item in items) {
      // אם הכמות נמוכה (פחות מ-2) או 0
      if (item.quantity <= 2) {
        final priority = item.quantity == 0 ? 'high' : 'medium';
        
        if (priority == 'high') {
          highCount++;
          debugPrint('   🔴 נגמר: ${item.productName} (${item.category})');
        } else {
          mediumCount++;
          debugPrint('   🟡 נמוך: ${item.productName} כמות=${item.quantity}');
        }

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

    debugPrint('   📊 סיכום: $highCount נגמרו, $mediumCount נמוכים');
    return suggestions;
  }

  /// ניתוח היסטוריה - מחזיר פריטים שנקנים לעיתים קרובות
  /// 
  /// Logic: מוצר שהופיע 3+ פעמים ב-30 הימים האחרונים
  List<Suggestion> _analyzeHistory() {
    final suggestions = <Suggestion>[];
    final lists = _listsProvider.lists;
    
    debugPrint('🔍 _analyzeHistory: בודק ${lists.length} רשימות');

    // ספירת תדירות כל מוצר ברשימות ה-30 יום האחרונים
    final productFrequency = <String, int>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    int relevantLists = 0;
    int totalItems = 0;

    for (var list in lists) {
      // רק רשימות מהחודש האחרון
      if (list.updatedDate.isAfter(thirtyDaysAgo)) {
        relevantLists++;
        for (var item in list.items) {
          final name = item.name.trim().toLowerCase();
          productFrequency[name] = (productFrequency[name] ?? 0) + 1;
          totalItems++;
        }
      }
    }

    debugPrint('   📅 רשימות רלוונטיות (30 יום): $relevantLists/${lists.length}');
    debugPrint('   📦 סה"כ פריטים: $totalItems');
    debugPrint('   🔢 מוצרים ייחודיים: ${productFrequency.length}');

    int frequentCount = 0;
    int skippedExists = 0;

    // המלצה על מוצרים שהופיעו לפחות 3 פעמים
    productFrequency.forEach((productName, count) {
      if (count >= 3) {
        frequentCount++;
        
        // בדוק אם המוצר כבר קיים במלאי
        final existsInInventory = _inventoryProvider.items.any(
          (item) => item.productName.toLowerCase() == productName,
        );

        // אם לא קיים במלאי - המלץ עליו
        if (!existsInInventory) {
          final priority = count >= 5 ? 'medium' : 'low';
          debugPrint('   ${priority == "medium" ? "🟡" : "🟢"} המלצה: $productName (${count}x)');
          
          suggestions.add(
            Suggestion(
              id: _uuid.v4(),
              productName: _capitalize(productName),
              reason: 'frequently_bought',
              category: 'כללי',
              suggestedQuantity: 1,
              unit: 'יחידות',
              priority: priority,
              source: 'history',
              createdAt: DateTime.now(),
            ),
          );
        } else {
          skippedExists++;
        }
      }
    });

    debugPrint('   📊 מוצרים תכופים (3+): $frequentCount');
    debugPrint('   ⏭️ דולגים (כבר במלאי): $skippedExists');
    debugPrint('   ✅ המלצות חדשות: ${suggestions.length}');

    return suggestions;
  }

  /// מיזוג המלצות כפולות (אותו מוצר ממקורות שונים)
  /// 
  /// Logic:
  /// - מוצר ממקור אחד → שומר כמו שהוא
  /// - מוצר מ-2 מקורות → source='both', עדיפות מקסימלית
  /// - מיון: high → medium → low
  List<Suggestion> _mergeDuplicates(List<Suggestion> suggestions) {
    debugPrint('🔀 _mergeDuplicates: מעבד ${suggestions.length} המלצות');
    
    final merged = <String, Suggestion>{};
    int mergedCount = 0;

    for (var suggestion in suggestions) {
      final key = suggestion.productName.toLowerCase();

      if (merged.containsKey(key)) {
        mergedCount++;
        // כבר יש המלצה למוצר הזה - שלב
        final existing = merged[key]!;

        debugPrint('   🔄 מזג: $key (${existing.source} + ${suggestion.source})');

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

        debugPrint('      → priority: ${existing.priority} + ${suggestion.priority} = $newPriority');

        merged[key] = existing.copyWith(
          reason: newReason,
          source: newSource,
          priority: newPriority,
        );
      } else {
        merged[key] = suggestion;
      }
    }

    debugPrint('   📊 מוזגו: $mergedCount כפילויות');

    // מיון לפי עדיפות
    final sorted = merged.values.toList();
    sorted.sort((a, b) {
      const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return sorted;
  }

  /// הסרת המלצה ספציפית
  /// 
  /// Example:
  /// ```dart
  /// suggestionsProvider.removeSuggestion(suggestion.id);
  /// ```
  void removeSuggestion(String id) {
    debugPrint('🗑️ SuggestionsProvider.removeSuggestion: $id');
    
    final initialLength = _suggestions.length;
    _suggestions.removeWhere((s) => s.id == id);
    
    if (_suggestions.length < initialLength) {
      debugPrint('   ✅ המלצה הוסרה (נשארו: ${_suggestions.length})');
      notifyListeners();
      debugPrint('   🔔 SuggestionsProvider: notifyListeners() (suggestion removed)');
    } else {
      debugPrint('   ⚠️ המלצה לא נמצאה');
    }
  }

  /// ניקוי כל ההמלצות
  /// 
  /// Example:
  /// ```dart
  /// suggestionsProvider.clearAll();
  /// ```
  void clearAll() {
    debugPrint('🗑️ SuggestionsProvider.clearAll: מנקה ${_suggestions.length} המלצות');
    _suggestions = [];
    notifyListeners();
    debugPrint('   🔔 SuggestionsProvider: notifyListeners() (all cleared)');
  }

  /// עזר - הופך אות ראשונה לגדולה
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    debugPrint('🧹 SuggestionsProvider.dispose');
    _inventoryProvider.removeListener(_onDataChanged);
    _listsProvider.removeListener(_onDataChanged);
    debugPrint('   ✅ Listeners הוסרו');
    super.dispose();
  }
}
