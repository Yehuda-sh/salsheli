// 📄 File: lib/screens/habits/my_habits_screen.dart
//
// 🇮🇱 **מסך הרגלי קנייה** - Shopping Habits Screen
//
// **תכונות:**
// - רשימת העדפות קנייה חוזרות
// - עריכה/מחיקה/חיפוש
// - תחזית קנייה הבאה
// - Pull-to-refresh
// - Undo למחיקה (5 שניות)
//
// **Dependencies:**
// - `HabitsProvider` - ניהול הרגלים
// - `UserContext` - פרטי משתמש
// - `timeago` - תצוגת זמן יחסי
//
// **Material 3:**
// - צבעים רק דרך Theme/ColorScheme
// - RTL support מלא
// - Accessibility compliant
//
// **Version:** 2.0 (Production + Constants)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/habit_preference.dart';
import '../../providers/habits_provider.dart';
import '../../core/ui_constants.dart';

class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  String _query = '';
  String? _editingId;
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('🧠 MyHabitsScreen.initState');
    timeago.setLocaleMessages('he', timeago.HeMessages());

    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });

    // טעינה ראשונית
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabits();
    });
  }

  Future<void> _loadHabits() async {
    debugPrint('🧠 MyHabitsScreen._loadHabits');
    final provider = context.read<HabitsProvider>();
    await provider.loadHabits();
  }

  /// 🔍 סינון הרגלים לפי חיפוש
  List<HabitPreference> _getFilteredHabits(List<HabitPreference> habits) {
    if (_query.isEmpty) return habits;

    final q = _query.toLowerCase();
    return habits
        .where(
          (h) =>
              h.preferredProduct.toLowerCase().contains(q) ||
              h.genericName.toLowerCase().contains(q),
        )
        .toList();
  }

  /// ✏️ התחלת עריכה
  void _startEdit(HabitPreference habit) {
    debugPrint('🧠 MyHabitsScreen._startEdit: ${habit.id}');
    setState(() {
      _editingId = habit.id;
      _editController.text = habit.preferredProduct;
    });
  }

  /// 💾 שמירת עריכה
  Future<void> _saveEdit(String id) async {
    final newName = _editController.text.trim();
    if (newName.isEmpty) return;

    debugPrint('🧠 MyHabitsScreen._saveEdit: $id → "$newName"');

    final provider = context.read<HabitsProvider>();
    final habit = provider.habits.firstWhere((h) => h.id == id);

    try {
      await provider.updateHabit(
        habit.copyWith(preferredProduct: newName),
      );

      setState(() => _editingId = null);
      debugPrint('   ✅ עריכה נשמרה');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ "$newName" עודכן'),
            backgroundColor: Colors.green,
            duration: kSnackBarDuration,
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה בשמירה: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 🗑️ מחיקת הרגל
  Future<void> _deleteHabit(HabitPreference habit) async {
    debugPrint('🧠 MyHabitsScreen._deleteHabit: ${habit.id}');

    final provider = context.read<HabitsProvider>();

    try {
      await provider.deleteHabit(habit.id);
      debugPrint('   ✅ הרגל נמחק');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הוסרה ההעדפה: ${habit.preferredProduct}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'בטל',
              textColor: Colors.white,
              onPressed: () async {
                debugPrint('🧠 MyHabitsScreen: משחזר הרגל');
                await provider.restoreHabit(habit);
                debugPrint('   ✅ הרגל שוחזר');
              },
            ),
            duration: kSnackBarDurationLong,
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה במחיקה: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה במחיקה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🧠 MyHabitsScreen.dispose');
    _editController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<HabitsProvider>();

    final allHabits = provider.habits;
    final filteredHabits = _getFilteredHabits(allHabits);

    // מיון לפי תאריך קנייה אחרון (חדש לישן)
    filteredHabits.sort((a, b) => b.lastPurchased.compareTo(a.lastPurchased));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text("הרגלי הקנייה שלי"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHabits,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSearchBar(context)),

              // 🎭 3 Empty States
              if (provider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.hasError)
                SliverToBoxAdapter(
                  child: _buildErrorState(context, provider),
                )
              else if (filteredHabits.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyState(context, allHabits.isNotEmpty),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final habit = filteredHabits[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == filteredHabits.length - 1
                              ? 0
                              : kSpacingSmall,
                        ),
                        child: _buildHabitCard(context, habit),
                      );
                    },
                    childCount: filteredHabits.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: kSpacingMedium)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingMedium,
        kSpacingMedium,
        kSpacingSmall,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: kSpacingLarge + 2, // 26px
            backgroundColor: cs.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.psychology,
              size: kIconSize,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: kBorderRadius),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ההעדפות שלך",
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "נהל מוצרים ומותגים שנרכשים לעיתים תכופות – עריכה/מחיקה/חיפוש",
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingTiny,
        kSpacingMedium,
        kBorderRadius,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "חיפוש לפי מוצר/שם גנרי…",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'נקה חיפוש',
                  onPressed: () {
                    debugPrint('🧠 MyHabitsScreen: ניקוי חיפוש');
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.06),
        ),
      ),
    );
  }

  /// ❌ Error State
  Widget _buildErrorState(BuildContext context, HabitsProvider provider) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Card(
        color: cs.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingLarge + kSpacingMedium, // 40px
            horizontal: kSpacingMedium,
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: kButtonHeight, color: cs.error),
              const SizedBox(height: kBorderRadius),
              Text(
                "שגיאה בטעינת הרגלים",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onErrorContainer,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                provider.errorMessage ?? 'שגיאה לא ידועה',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onErrorContainer),
              ),
              const SizedBox(height: kSpacingMedium),
              FilledButton.icon(
                onPressed: () {
                  debugPrint('🧠 MyHabitsScreen: retry לטעינת הרגלים');
                  provider.retry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📭 Empty State
  Widget _buildEmptyState(BuildContext context, bool hasGlobalData) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Card(
        color: cs.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingLarge + kSpacingMedium, // 40px
            horizontal: kSpacingMedium,
          ),
          child: Column(
            children: [
              Icon(
                hasGlobalData ? Icons.search_off : Icons.star_border,
                size: kButtonHeight,
                color: cs.primary,
              ),
              const SizedBox(height: kBorderRadius),
              Text(
                hasGlobalData ? "לא נמצאו תוצאות" : "אין עדיין העדפות שמורות",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                hasGlobalData
                    ? 'נסה מילות חיפוש אחרות'
                    : "ככל שתשתמש, נלמד אוטומטית את ההרגלים ונציע התאמות.",
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎴 כרטיס הרגל
  Widget _buildHabitCard(BuildContext context, HabitPreference habit) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = _editingId == habit.id;

    final daysLeft = habit.daysUntilNextPurchase;
    final predictionText =
        daysLeft >= 0 ? "בעוד ~$daysLeft ימים" : "לפני ${daysLeft.abs()} ימים";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium - 2), // 14px
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // שורה עליונה: שם/עריכה + אקשנים
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isEditing
                      ? TextField(
                          controller: _editController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: "שם המוצר המועדף",
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveEdit(habit.id),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.preferredProduct,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (habit.genericName.isNotEmpty)
                              Text(
                                habit.genericName,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(width: kSpacingSmall),
                if (isEditing)
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'שמור',
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _saveEdit(habit.id),
                      ),
                      IconButton(
                        tooltip: 'בטל',
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () {
                          debugPrint('🧠 MyHabitsScreen: ביטול עריכה');
                          setState(() => _editingId = null);
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'ערוך',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _startEdit(habit),
                      ),
                      IconButton(
                        tooltip: 'מחק',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deleteHabit(habit),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: kBorderRadius),

            // צ'יפים של סטטוס
            Wrap(
              spacing: kSpacingSmall,
              runSpacing: kSpacingSmall,
              children: [
                Chip(
                  avatar: const Icon(Icons.repeat, size: kIconSizeSmall),
                  label: Text("נקנה כל ${habit.frequencyDays} ימים"),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule, size: kIconSizeSmall),
                  label: Text(
                    "נרכש ${timeago.format(habit.lastPurchased, locale: 'he')}",
                  ),
                ),
                Chip(
                  avatar:
                      const Icon(Icons.notifications_active, size: kIconSizeSmall),
                  label: Text("הבא: $predictionText"),
                  backgroundColor:
                      cs.tertiaryContainer.withValues(alpha: 0.25),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
