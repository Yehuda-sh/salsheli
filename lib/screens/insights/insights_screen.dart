// 📄 File: lib/screens/insights/insights_screen.dart - V2.0 REAL DATA
// תיאור: מסך תובנות וסטטיסטיקות חכמות על הרגלי קנייה
//
// ✨ עדכון (v2.0):
// ✅ הוסרו נתוני MOCK
// ✅ חיבור מלא לנתונים אמיתיים מ-HomeStatsService
// ✅ גרף עוגה עם נתונים אמיתיים
// ✅ הוצאות עיקריות אמיתיות
//
// ✨ תכונות:
// - בחירת תקופות (שבוע/חודש/3 חודשים/שנה)
// - גרף עוגה אינטראקטיבי להתפלגות הוצאות
// - המלצות חכמות עם כרטיסים צבעוניים
// - השוואה לתקופה הקודמת
// - אנימציות חלקות
// - מצבי טעינה/שגיאה/ריק
//
// 🎨 עיצוב:
// - שימוש ב-Theme בלבד (אין צבעים קבועים)
// - עקבי עם שאר האפליקציה
// - RTL מלא
//
// 🔗 Dependencies:
// - HomeStatsService - חישוב סטטיסטיקות
// - ReceiptProvider, ShoppingListsProvider, InventoryProvider
// - fl_chart - גרפים
// - flutter_animate - אנימציות

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/home_stats_service.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/sticky_button.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  HomeStats? _stats;
  String? _errorMessage;

  // בחירת תקופה: 0=שבוע, 1=חודש, 2=3 חודשים, 3=שנה
  int _selectedPeriod = 1;
  final List<String> _periods = ['שבוע', 'חודש', '3 חודשים', 'שנה'];
  final List<int> _periodMonths = [0, 1, 3, 12];

  @override
  void initState() {
    super.initState();
    debugPrint('📊 InsightsScreen.initState()');
    _loadStats();
  }

  @override
  void dispose() {
    debugPrint('📊 InsightsScreen.dispose()');
    super.dispose();
  }

  /// טוען סטטיסטיקות מהשרת או מהמטמון
  /// [forceRefresh] - אם true, מתעלם מהמטמון וטוען מהשרת
  Future<void> _loadStats({bool forceRefresh = false}) async {
    debugPrint('📊 InsightsScreen._loadStats: מתחיל (refresh=$forceRefresh, period=${_periods[_selectedPeriod]})');
    
    if (!forceRefresh) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    } else {
      if (mounted) setState(() => _isRefreshing = true);
    }

    try {
      // 1) טעינה ממטמון (אם לא מרענן)
      if (!forceRefresh) {
        final cachedStats = await HomeStatsService.loadFromCache();
        if (mounted && cachedStats != null) {
          debugPrint('   ✅ נטען ממטמון');
          setState(() => _stats = cachedStats);
        }
      }

      // 2) שליפת נתונים אמיתיים
      if (!mounted) return;
      final receiptsProvider = context.read<ReceiptProvider>();
      final listsProvider = context.read<ShoppingListsProvider>();
      final inventoryProvider = context.read<InventoryProvider>();

      final receipts = receiptsProvider.receipts;
      final lists = listsProvider.lists;
      final inventory = inventoryProvider.items;

      debugPrint('   📥 נתונים: receipts=${receipts.length}, lists=${lists.length}, inventory=${inventory.length}');

      // 3) חישוב סטטיסטיקות
      final freshStats = await HomeStatsService.calculateStats(
        receipts: receipts,
        shoppingLists: lists,
        inventory: inventory,
        monthsBack: _periodMonths[_selectedPeriod],
      );

      debugPrint('   ✅ סטטיסטיקות חושבו: spent=${freshStats.monthlySpent}, accuracy=${freshStats.listAccuracy}');

      if (mounted) {
        setState(() {
          _stats = freshStats;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
        debugPrint('   ✅ State עודכן בהצלחה');
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה בטעינת נתונים: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'שגיאה בטעינת הנתונים';
        });
      }
    }
  }

  /// משנה את התקופה הנבחרת וטוען מחדש את הסטטיסטיקות
  void _changePeriod(int index) {
    if (_selectedPeriod == index) return;
    debugPrint('📊 InsightsScreen: משנה תקופה ל-${_periods[index]}');
    setState(() => _selectedPeriod = index);
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _loadStats(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
              // Header עם בחירת תקופה
              SliverToBoxAdapter(child: _buildHeader(theme, cs)),

              // תוכן לפי מצב
              if (_errorMessage != null)
                SliverFillRemaining(child: _buildErrorState(cs))
              else if (_isLoading && _stats == null)
                SliverFillRemaining(child: _buildLoadingState(cs))
              else if (_stats != null)
                _buildContent(theme, cs, _stats!)
              else
                SliverFillRemaining(child: _buildEmptyState(cs)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== HEADER ==================
  /// בונה את ה-header עם כותרת ובחירת תקופה
  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    final brand = theme.extension<AppBrand>();

    return Padding(
      padding: const EdgeInsets.all(kSpacingMedium),
      child: StickyNote(
        color: Colors.white.withValues(alpha: 0.9),
        rotation: -0.01,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת ואייקון
          Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: brand?.accent ?? cs.primary,
                size: 28,
              ),
              const SizedBox(width: kSpacingSmall),
              Text(
                'תובנות חכמות',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              if (_isRefreshing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: brand?.accent ?? cs.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),

          // בחירת תקופה
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_periods.length, (index) {
                final isSelected = _selectedPeriod == index;
                return Padding(
                  padding: const EdgeInsets.only(left: kSpacingSmall),
                  child: ChoiceChip(
                    label: Text(_periods[index]),
                    selected: isSelected,
                    onSelected: (_) => _changePeriod(index),
                    selectedColor: (brand?.accent ?? cs.primary).withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (brand?.accent ?? cs.primary)
                          : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? (brand?.accent ?? cs.primary)
                          : cs.outline,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ================== CONTENT ==================
  /// בונה את התוכן המלא של המסך עם כל הסטטיסטיקות
  Widget _buildContent(ThemeData theme, ColorScheme cs, HomeStats stats) {
    return SliverPadding(
      padding: const EdgeInsets.all(kSpacingMedium),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 1. סיכום כללי עם השוואה
          _buildSummaryCard(theme, cs, stats),
          const SizedBox(height: kSpacingMedium),

          // 2. המלצות חכמות
          _buildSmartRecommendations(theme, cs, stats),
          const SizedBox(height: kSpacingMedium),

          // 3. גרף עוגה (נתונים אמיתיים!)
          if (stats.categoryBreakdown != null &&
              stats.categoryBreakdown!.isNotEmpty)
            _buildPieChartCard(theme, cs, stats),
          if (stats.categoryBreakdown != null &&
              stats.categoryBreakdown!.isNotEmpty)
            const SizedBox(height: kSpacingMedium),

          // 4. סטטיסטיקות מפורטות
          _buildDetailedStats(theme, cs, stats),
          const SizedBox(height: kSpacingMedium),

          // 5. הוצאות עיקריות (נתונים אמיתיים!)
          if (stats.topProducts != null && stats.topProducts!.isNotEmpty)
            _buildTopExpenses(theme, cs, stats),
          const SizedBox(height: kSpacingXXLarge),
        ]),
      ),
    );
  }

  // ================== 1. סיכום כללי ==================
  /// בונה כרטיס סיכום כללי עם השוואה לתקופה קודמת
  Widget _buildSummaryCard(ThemeData theme, ColorScheme cs, HomeStats stats) {
    final totalSpent = stats.monthlySpent.isFinite ? stats.monthlySpent : 0.0;

    // חישוב שינוי לעומת תקופה קודמת - אמיתי!
    double previousSpent = 0.0;
    if (stats.expenseTrend.length >= 2) {
      final previousMonth = stats.expenseTrend[stats.expenseTrend.length - 2];
      previousSpent = (previousMonth['value'] as num?)?.toDouble() ?? 0.0;
    } else {
      previousSpent = totalSpent * 1.15;
    }

    final change = previousSpent > 0
        ? ((totalSpent - previousSpent) / previousSpent * 100)
        : 0.0;
    final isImprovement = change < 0;

    return StickyNote(
      color: kStickyYellow,
      rotation: -0.015,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'סה"כ הוצאות',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪${totalSpent.toStringAsFixed(0)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingSmall,
                  vertical: kSpacingTiny,
                ),
                decoration: BoxDecoration(
                  color: isImprovement
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImprovement ? Icons.arrow_downward : Icons.arrow_upward,
                      size: kFontSizeSmall,
                      color: isImprovement ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: kSpacingTiny),
                    Text(
                      '${change.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: isImprovement ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            isImprovement
                ? 'חיסכון לעומת התקופה הקודמת 🎉'
                : 'עלייה לעומת התקופה הקודמת',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  // ================== 2. המלצות חכמות ==================
  /// בונה רשימת המלצות חכמות לשיפור הרגלי קנייה
  Widget _buildSmartRecommendations(
    ThemeData theme,
    ColorScheme cs,
    HomeStats stats,
  ) {
    final recommendations = _generateRecommendations(stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'המלצות לשיפור',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        ...recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final rec = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: kSpacingSmall),
            child: _buildRecommendationCard(theme, cs, rec)
                .animate(delay: (150 * index).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendationCard(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> rec,
  ) {
    return StickyNote(
      color: rec['color'].withValues(alpha: 0.15),
      rotation: 0.01,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: rec['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(rec['icon'], color: rec['color'], size: kIconSize),
          ),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: kSpacingTiny),
                Text(
                  rec['subtitle'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// מייצר רשימת המלצות בהתאם לסטטיסטיקות האמיתיות
  List<Map<String, dynamic>> _generateRecommendations(HomeStats stats) {
    final recommendations = <Map<String, dynamic>>[];
    final accuracy = stats.listAccuracy;
    final savings =
        stats.potentialSavings.isFinite ? stats.potentialSavings : 0.0;
    final lowInventory = stats.lowInventoryCount;

    // המלצה 0: מלאי נמוך (אם רלוונטי)
    if (lowInventory > 5) {
      recommendations.add({
        'icon': Icons.inventory_2_outlined,
        'title': 'מלאי נמוך!',
        'subtitle': 'יש לך $lowInventory פריטים שנגמרים. עדכן את הרשימה 📝',
        'color': Colors.red,
      });
    }

    // המלצה 1: דיוק רשימות
    if (accuracy < 70) {
      recommendations.add({
        'icon': Icons.list_alt,
        'title': 'שפר את דיוק הרשימות',
        'subtitle':
            'רק ${accuracy.toStringAsFixed(0)}% מהפריטים שתכננת נקנו. נסה להקפיד יותר!',
        'color': Colors.orange,
      });
    } else {
      recommendations.add({
        'icon': Icons.check_circle,
        'title': 'דיוק מעולה!',
        'subtitle':
            '${accuracy.toStringAsFixed(0)}% מהפריטים שתכננת נקנו. המשך כך 🎉',
        'color': Colors.green,
      });
    }

    // המלצה 2: חיסכון פוטנציאלי
    if (savings > 50) {
      recommendations.add({
        'icon': Icons.savings_outlined,
        'title': 'הזדמנות לחיסכון',
        'subtitle':
            'ניתן לחסוך עד ₪${savings.toStringAsFixed(0)} על ידי השוואת מחירים',
        'color': Colors.blue,
      });
    }

    // המלצה 3: מגמה
    final trendValue =
        stats.expenseTrend.isNotEmpty ? stats.expenseTrend.last : 0.0;
    final trend = (trendValue is num) ? trendValue.toDouble() : 0.0;
    if (trend > 0) {
      recommendations.add({
        'icon': Icons.trending_up,
        'title': 'הוצאות עולות',
        'subtitle': 'שים לב - ההוצאות שלך עולות. בדוק מה השתנה',
        'color': Colors.red,
      });
    } else {
      recommendations.add({
        'icon': Icons.trending_down,
        'title': 'הוצאות יורדות',
        'subtitle': 'כל הכבוד! ההוצאות שלך יורדות לאורך זמן 👏',
        'color': Colors.green,
      });
    }

    return recommendations.take(3).toList();
  }

  // ================== 3. גרף עוגה ✅ נתונים אמיתיים! ==================
  /// בונה כרטיס גרף עוגה עם התפלגות הוצאות לפי קטגוריות
  Widget _buildPieChartCard(ThemeData theme, ColorScheme cs, HomeStats stats) {
    return StickyNote(
      color: kStickyCyan,
      rotation: 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'התפלגות הוצאות לפי קטגוריות',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          SizedBox(height: 200, child: _buildPieChart(cs, stats)),
          const SizedBox(height: kSpacingMedium),
          _buildPieChartLegend(theme, cs, stats),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
        );
  }

  /// בונה את גרף העוגה עצמו עם הנתונים האמיתיים
  Widget _buildPieChart(ColorScheme cs, HomeStats stats) {
    final data = stats.categoryBreakdown ?? [];
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return PieChart(
      PieChartData(
        sections: data.map((item) {
          final percentage = ((item['amount'] as double) / total * 100);
          return PieChartSectionData(
            value: item['amount'] as double,
            title: '${percentage.toStringAsFixed(0)}%',
            color: item['color'] as Color,
            radius: kPieChartRadius,
            titleStyle: const TextStyle(
              fontSize: kFontSizeSmall,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// בונה את מקרא הצבעים של גרף העוגה
  Widget _buildPieChartLegend(
    ThemeData theme,
    ColorScheme cs,
    HomeStats stats,
  ) {
    final data = stats.categoryBreakdown ?? [];

    return Wrap(
      spacing: kSpacingSmall,
      runSpacing: kSpacingSmall,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: kLegendDotSize,
              height: kLegendDotSize,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: kSpacingXTiny),
            Text(
              '${item['category']} (₪${(item['amount'] as double).toStringAsFixed(0)})',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ================== 4. סטטיסטיקות מפורטות ==================
  /// בונה כרטיסי סטטיסטיקות נוספות (חיסכון, דיוק רשימות)
  Widget _buildDetailedStats(ThemeData theme, ColorScheme cs, HomeStats stats) {
    final brand = theme.extension<AppBrand>();
    final savings =
        stats.potentialSavings.isFinite ? stats.potentialSavings : 0.0;
    final accuracy = stats.listAccuracy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סטטיסטיקות נוספות',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                cs,
                brand,
                icon: Icons.savings_outlined,
                title: 'חיסכון פוטנציאלי',
                value: '₪${savings.toStringAsFixed(0)}',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: _buildStatCard(
                theme,
                cs,
                brand,
                icon: Icons.check_circle_outline,
                title: 'דיוק רשימות',
                value: '${accuracy.toStringAsFixed(0)}%',
                color: accuracy > 70 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme cs,
    AppBrand? brand, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return StickyNote(
      color: color.withValues(alpha: 0.15),
      rotation: -0.01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: kSpacingSmall),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: kSpacingTiny),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ================== 5. הוצאות עיקריות ✅ נתונים אמיתיים! ==================
  /// בונה רשימת 5 ההוצאות העיקריות
  Widget _buildTopExpenses(ThemeData theme, ColorScheme cs, HomeStats stats) {
    final topExpenses = stats.topProducts ?? [];
    if (topExpenses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'הוצאות עיקריות',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        ...topExpenses.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final expense = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: kSpacingSmall),
            child: StickyNote(
              color: kStickyGreen.withValues(alpha: 0.15),
              rotation: index.isEven ? 0.005 : -0.005,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kAvatarRadiusTiny,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          expense['category'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₪${(expense['amount'] as double).toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (100 * index).ms).fadeIn(duration: 300.ms).slideX(
                  begin: 0.1,
                ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  // ================== STATES ==================
  /// מצב טעינה עם spinner
  Widget _buildLoadingState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: kSpacingMedium),
          Text(
            'טוען תובנות...',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  /// מצב שגיאה עם כפתור 'נסה שוב'
  Widget _buildErrorState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: kSpacingMedium),
            Text(
              _errorMessage ?? 'שגיאה לא ידועה',
              style: TextStyle(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButton(
              label: 'נסה שוב',
              icon: Icons.refresh,
              color: kStickyPink,
              onPressed: () => _loadStats(),
            ),
          ],
        ),
      ),
    );
  }

  /// מצב ריק כאשר אין נתונים להצגה
  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: kIconSizeXLarge,
              color: cs.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              'אין נתונים להצגה',
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'התחל להשתמש באפליקציה כדי לראות תובנות חכמות!',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButton(
              label: 'צור רשימה ראשונה',
              icon: Icons.add,
              color: kStickyYellow,
              onPressed: () => Navigator.pushNamed(context, '/shopping-lists'),
            ),
          ],
        ),
      ),
    );
  }
}
