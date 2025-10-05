// 📄 File: lib/screens/suggestions/smart_suggestions_screen.dart
// 
// 🎯 Purpose: מסך המלצות חכמות מבוסס AI - מציע מוצרים על בסיס היסטוריית קניות ומצב מלאי
//
// 📦 Dependencies:
// - SuggestionsProvider: חישוב והמלצות חכמות (מנתח inventory + רשימות)
// - ShoppingListsProvider: גישה לרשימות קניות פעילות
//
// 🎨 Features:
// - תצוגת המלצות ממוקדות (high/medium/low priority)
// - הוספה מהירה של מוצרים לרשימה פעילה
// - מצבי Empty/Loading/Error
// - תמיכה RTL מלאה
//
// 💡 Usage:
// ```dart
// Navigator.pushNamed(context, '/suggestions');
// ```

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/suggestions_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../core/constants.dart';
import '../../models/receipt.dart';
import '../../models/shopping_list.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SmartSuggestionsScreen.initState()');
    
    // רענון המלצות כשהמסך נטען
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('   ⟳ מרענן המלצות...');
        context.read<SuggestionsProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 SmartSuggestionsScreen.build()');
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('המלצות חכמות'),
          actions: [
            IconButton(
              tooltip: 'רענן המלצות',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                debugPrint('🔄 לחיצה על רענון');
                context.read<SuggestionsProvider>().refresh();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer2<SuggestionsProvider, ShoppingListsProvider>(
            builder: (context, suggestionsProvider, listsProvider, _) {
              final activeLists = listsProvider.lists
                  .where((list) => list.status == ShoppingList.statusActive)
                  .toList();
              
              debugPrint('   📊 isLoading: ${suggestionsProvider.isLoading}');
              debugPrint('   📊 hasError: ${suggestionsProvider.hasError}');
              debugPrint('   📊 suggestions: ${suggestionsProvider.suggestions.length}');
              debugPrint('   📊 active lists: ${activeLists.length}');

              // 1️⃣ Loading State
              if (suggestionsProvider.isLoading) {
                return _buildLoadingState(cs);
              }

              // 2️⃣ Error State
              if (suggestionsProvider.hasError) {
                return _buildErrorState(
                  context,
                  cs,
                  suggestionsProvider.errorMessage ?? 'שגיאה לא ידועה',
                );
              }

              // 3️⃣ Empty State - אין רשימות פעילות
              if (activeLists.isEmpty) {
                return _buildEmptyState(context, cs, type: 'no_lists');
              }

              // 4️⃣ Empty State - אין המלצות
              if (suggestionsProvider.suggestions.isEmpty) {
                return _buildEmptyState(context, cs, type: 'no_suggestions');
              }

              // 5️⃣ Content - יש המלצות!
              return _buildSuggestions(
                context,
                suggestionsProvider,
                listsProvider,
                cs,
              );
            },
          ),
        ),
      ),
    );
  }

  /// ⏳ Loading State
  Widget _buildLoadingState(ColorScheme cs) {
    debugPrint('   🎨 בונה Loading State');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: kSpacingMedium),
          Text(
            'מחשב המלצות...',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Error State
  Widget _buildErrorState(BuildContext context, ColorScheme cs, String error) {
    debugPrint('   🎨 בונה Error State: $error');
    return Center(
      child: Padding(
        padding: EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            SizedBox(height: kSpacingMedium),
            Text(
              'שגיאה בטעינת המלצות',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: kSpacingSmall),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: kSpacingLarge),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, kButtonHeight),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              onPressed: () {
                debugPrint('🔄 לחיצה על "נסה שוב"');
                context.read<SuggestionsProvider>().refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 Empty State
  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme cs, {
    required String type,
  }) {
    debugPrint('   🎨 בונה Empty State: $type');

    final isNoLists = type == 'no_lists';
    final icon = isNoLists ? Icons.list_alt : Icons.lightbulb_outline;
    final title = isNoLists ? 'אין רשימות פעילות' : 'אין המלצות כרגע';
    final message = isNoLists
        ? 'כדי לקבל המלצות חכמות, צריכה להיות לפחות רשימת קניות פעילה אחת.'
        : 'נראה שהמלאי מלא והקניות מעודכנות! 🎉\nכשיהיו מוצרים חסרים או דפוסי קנייה חדשים, נציע כאן המלצות.';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(kSpacingLarge),
        child: Container(
          padding: EdgeInsets.all(kSpacingLarge),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: cs.primary),
              SizedBox(height: kSpacingMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: kSpacingSmall),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              if (isNoLists) ...[
                SizedBox(height: kSpacingMedium),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, kButtonHeight),
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  onPressed: () {
                    debugPrint('➡️ ניווט ל-/shopping-lists');
                    Navigator.pushNamed(context, '/shopping-lists');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('צור רשימה חדשה'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 📦 תצוגת המלצות
  Widget _buildSuggestions(
    BuildContext context,
    SuggestionsProvider provider,
    ShoppingListsProvider listsProvider,
    ColorScheme cs,
  ) {
    debugPrint('   🎨 בונה Suggestions Content');
    
    final highPriority = provider.highPriority;
    final mediumPriority = provider.mediumPriority;
    final lowPriority = provider.lowPriority;

    debugPrint('      🔴 High: ${highPriority.length}');
    debugPrint('      🟡 Medium: ${mediumPriority.length}');
    debugPrint('      🟢 Low: ${lowPriority.length}');

    return SingleChildScrollView(
      padding: EdgeInsets.all(kSpacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(cs),
          SizedBox(height: kSpacingLarge),

          // High Priority
          if (highPriority.isNotEmpty) ...[
            _buildPrioritySection(
              context,
              '🔴 דחוף',
              highPriority,
              listsProvider,
              cs,
            ),
            SizedBox(height: kSpacingMedium),
          ],

          // Medium Priority
          if (mediumPriority.isNotEmpty) ...[
            _buildPrioritySection(
              context,
              '🟡 חשוב',
              mediumPriority,
              listsProvider,
              cs,
            ),
            SizedBox(height: kSpacingMedium),
          ],

          // Low Priority
          if (lowPriority.isNotEmpty) ...[
            _buildPrioritySection(
              context,
              '🟢 כדאי לשקול',
              lowPriority,
              listsProvider,
              cs,
            ),
          ],
        ],
      ),
    );
  }

  /// 🧠 Header
  Widget _buildHeader(ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
            borderRadius: BorderRadius.circular(kBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 28),
        ),
        SizedBox(width: kSpacingSmall),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "המלצות חכמות",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "מבוסס על ניתוח המלאי והיסטוריית הקניות שלך",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📋 Section לפי עדיפות
  Widget _buildPrioritySection(
    BuildContext context,
    String title,
    List suggestions,
    ShoppingListsProvider listsProvider,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: kSpacingSmall),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            final emoji = kCategoryEmojis[suggestion.category.toLowerCase()] ?? '📦';

            return Card(
              margin: EdgeInsets.only(bottom: kSpacingSmall),
              child: ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 32)),
                title: Text(
                  suggestion.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(suggestion.reasonText),
                trailing: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: 'הוסף לרשימה',
                    icon: Icon(Icons.add_circle, color: cs.tertiary, size: 28),
                    onPressed: () => _addToList(
                      context,
                      suggestion,
                      listsProvider,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// ➕ הוספת מוצר לרשימה
  void _addToList(
    BuildContext context,
    dynamic suggestion,
    ShoppingListsProvider listsProvider,
  ) {
    debugPrint('➕ SmartSuggestionsScreen._addToList()');
    debugPrint('   📦 מוצר: ${suggestion.productName}');

    // בחר רשימה פעילה (ברירת מחדל: הראשונה)
    final activeLists = listsProvider.lists
        .where((list) => list.status == ShoppingList.statusActive)
        .toList();
    if (activeLists.isEmpty) {
      debugPrint('   ❌ אין רשימות פעילות');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('אין רשימות פעילות. צור רשימה חדשה קודם.'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    final targetList = activeLists.first;
    debugPrint('   🎯 רשימה: ${targetList.name}');

    try {
      // הוסף לרשימה
      final newItem = ReceiptItem.manual(
        name: suggestion.productName,
        quantity: suggestion.suggestedQuantity ?? 1,
        unit: suggestion.unit,
        category: suggestion.category,
      );
      
      listsProvider.addItemToList(targetList.id, newItem);

      debugPrint('   ✅ נוסף בהצלחה');

      // הודעת הצלחה
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${suggestion.productName} נוסף לרשימה "${targetList.name}"'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'בטל',
            textColor: Colors.white,
            onPressed: () async {
              debugPrint('   ↩️ ביטול הוספה');
              // מצא את הרשימה המעודכנת
              final updatedList = listsProvider.getById(targetList.id);
              if (updatedList != null && updatedList.items.isNotEmpty) {
                // מחק את הפריט האחרון שנוסף
                final lastIndex = updatedList.items.length - 1;
                await listsProvider.removeItemFromList(updatedList.id, lastIndex);
                debugPrint('   ✅ פריט הוסר בהצלחה');
              }
            },
          ),
        ),
      );

      // הסר המלצה
      context.read<SuggestionsProvider>().removeSuggestion(suggestion.id);
      debugPrint('   🗑️ המלצה הוסרה');
    } catch (e) {
      debugPrint('   ❌ שגיאה בהוספה: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספת המוצר: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}
