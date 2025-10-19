// 📄 File: lib/screens/home/home_dashboard_screen.dart
// 🎯 Purpose: מסך דשבורד הבית - Dashboard Screen
//
// 📋 Features:
// ✅ Pull-to-Refresh (רשימות + הצעות)
// ✅ מיון חכם לפי priority (אירועים + עדכונים)
// ✅ Empty state משופר עם אנימציה
// ✅ כרטיסים: הקנייה הבאה, הצעות חכמות, קבלות, תובנות, רשימות פעילות
// ✅ Dismissible lists עם undo
// ✅ AppStrings - i18n ready
// ✅ ui_constants - עיצוב עקבי
//
// 🔗 Dependencies:
// - ShoppingListsProvider - רשימות קניות
// - SuggestionsProvider - הצעות חכמות
// - UserContext - פרטי משתמש
// - ReceiptProvider - קבלות
// - flutter_animate - אנימציות
//
// 🎨 Material 3:
// - צבעים רק דרך Theme/ColorScheme
// - RTL support מלא
// - Accessibility compliant

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/user_context.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/home/upcoming_shop_card.dart';
import '../../widgets/home/smart_suggestions_card.dart';
import '../../widgets/create_list_dialog.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../theme/app_theme.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import 'home_dashboard_screen_ux.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboardScreen.initState()');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboardScreen.dispose()');
    }
    super.dispose();
  }

  Future<void> _refresh(BuildContext context) async {
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: מתחיל refresh...');
    }
    HapticFeedback.mediumImpact(); // ✨ רטט בהתחלת refresh
    
    // ✅ טעינת רשימות - נפרד
    try {
      final lists = context.read<ShoppingListsProvider>();
      await lists.loadLists();
      if (kDebugMode) {
        debugPrint('   ✅ רשימות נטענו: ${lists.lists.length}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ שגיאה בטעינת רשימות: $e');
      }
      // ממשיכים להצעות
    }

    if (!context.mounted) return;

    // ✅ טעינת הצעות - נפרד
    try {
      final sugg = context.read<SuggestionsProvider>();
      await sugg.refresh();
      if (kDebugMode) {
        debugPrint('   ✅ הצעות נטענו: ${sugg.suggestions.length}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ⚠️ לא ניתן לטעון הצעות: $e');
      }
      // זה לא קריטי
    }
    
    // ✨ עיכוב קצר כדי לראות את ההתקדמות
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (context.mounted) {
      HapticFeedback.lightImpact(); // ✨ רטט קל בסיום
    }
    
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: refresh הושלם');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final userContext = context.watch<UserContext>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: kPaperBackground,  // ✅ Sticky Notes background
      body: Stack(
        children: [
          const NotebookBackground(),  // ✅ רקע מחברת
          SafeArea(
            child: RefreshIndicator(
              color: Theme.of(context).extension<AppBrand>()?.accent ?? cs.primary,
              backgroundColor: kPaperBackground,
              strokeWidth: 4.0, // ✨ עבה יותר
              displacement: 50.0, // ✨ יותר רחוק
              onRefresh: () => _refresh(context),
              child: ListView(
                padding: const EdgeInsets.all(kSpacingMedium),
                children: [
                  _Header(userName: userContext.displayName),
                  const SizedBox(height: kSpacingMedium),

                  // ✨ תמיד נראה skeleton בהתחלה
                  if (listsProvider.isLoading)
                    const DashboardSkeleton()
                  else if (listsProvider.lists.isEmpty)
                    _ImprovedEmptyState(
                      onCreateList: () => _showCreateListDialog(context),
                    )
                  else
                    _Content(allLists: listsProvider.lists),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    HapticFeedback.lightImpact(); // ✨ רטט קל
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: פותח דיאלוג יצירת רשימה');
    }
    
    final provider = context.read<ShoppingListsProvider>();
    // ✅ שמירת scaffoldMessenger לפני async
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onCreateList: (listData) async {
          Navigator.of(dialogContext).pop();

          final name = listData['name'] as String?;
          final type = listData['type'] as String? ?? 'super';
          final budget = listData['budget'] as double?;
          final eventDate = listData['eventDate'] as DateTime?;

          if (kDebugMode) {
            debugPrint('🏠 HomeDashboard: יוצר רשימה "$name" (סוג: $type, תאריך: $eventDate)');
          }

          if (name != null && name.trim().isNotEmpty) {
            try {
              await provider.createList(
                name: name, 
                type: type, 
                budget: budget,
                eventDate: eventDate,
              );
              if (kDebugMode) {
                debugPrint('   ✅ רשימה נוצרה בהצלחה');
              }
              
              // ✅ שימוש ב-scaffoldMessenger שנשמר
              if (mounted) {
                HapticFeedback.lightImpact(); // ✨ רטט הצלחה
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 24),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            'הרשימה "$name" נוצרה בהצלחה ✨',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                );
              }
            } on Exception catch (e) {
              if (kDebugMode) {
                debugPrint('   ❌ שגיאה ביצירת רשימה: $e');
              }
              
              if (mounted) {
                HapticFeedback.heavyImpact(); // ✨ רטט חזק לשגיאה
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 24),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            AppStrings.home.createListError(e.toString()),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    action: SnackBarAction(
                      label: 'נסה שוב',
                      textColor: Colors.white,
                      onPressed: () => _showCreateListDialog(context),
                    ),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    // ✅ Header על פתק צהוב
    return StickyNote(
      color: kStickyYellow,
      rotation: -0.02,
      child: Row(
        children: [
          CircleAvatar(
            radius: kSpacingMedium, // 16px
            backgroundColor: (brand?.accent ?? cs.secondary).withValues(
              alpha: 0.18,
            ),
            child: Icon(
              Icons.home_outlined,
              size: kIconSizeSmall, // 16px
              color: brand?.accent ?? cs.secondary,
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Text(
              AppStrings.home.welcomeUser(
                (userName?.trim().isEmpty ?? true) 
                  ? AppStrings.home.guestUser 
                  : userName!,
              ),
              style: t.titleMedium?.copyWith(
                color: Colors.black87,  // ✅ טקסט כהה על פתק צהוב
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final List<ShoppingList> allLists;
  const _Content({required this.allLists});

  @override
  Widget build(BuildContext context) {
    final activeLists = _getActiveLists();
    final mostRecentList = _getMostRecentList(activeLists);
    final otherLists = _getOtherLists(activeLists);

    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard._Content: פעילות=${activeLists.length}, אחרות=${otherLists.length}');
    }

    return Column(
      children: [
        // ✨ אנימציות יותר איטיות ודרמטיות!
        UpcomingShopCard(list: mostRecentList)
          .animate()
          .fadeIn(duration: 600.ms) // ✨ יותר איטי
          .slideY(begin: 0.15, end: 0) // ✨ יותר דרמטי
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)), // ✨ זום!
        
        const SizedBox(height: kSpacingMedium),
        
        SmartSuggestionsCard(mostRecentList: mostRecentList)
          .animate()
          .fadeIn(duration: 600.ms, delay: 150.ms) // ✨ יותר איטי
          .slideY(begin: 0.15, end: 0) // ✨ יותר דרמטי
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)), // ✨ זום!
        
        const SizedBox(height: kSpacingMedium),
        
        const _ReceiptsCard()
          .animate()
          .fadeIn(duration: 600.ms, delay: 300.ms) // ✨ יותר איטי
          .slideY(begin: 0.15, end: 0) // ✨ יותר דרמטי
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)), // ✨ זום!
        
        const SizedBox(height: kSpacingMedium),
        
        // 🆕 כרטיס תובנות חכמות
        const _InsightsCard()
          .animate()
          .fadeIn(duration: 600.ms, delay: 400.ms)
          .slideY(begin: 0.15, end: 0)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        
        const SizedBox(height: kSpacingMedium),
        
        if (otherLists.isNotEmpty)
          _ActiveListsCard(lists: otherLists)
            .animate()
            .fadeIn(duration: 600.ms, delay: 550.ms) // ✨ עיכוב מעודכן
            .slideY(begin: 0.15, end: 0) // ✨ יותר דרמטי
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)), // ✨ זום!
      ],
    );
  }

  /// ✅ מחזיר רק רשימות פעילות
  List<ShoppingList> _getActiveLists() {
    return allLists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();
  }

  /// ✅ מחשב ומחזיר את הרשימה הכי דחופה
  ShoppingList? _getMostRecentList(List<ShoppingList> activeLists) {
    if (activeLists.isEmpty) return null;

    if (kDebugMode) {
      debugPrint('🧠 מחשב דחיפות עבור ${activeLists.length} רשימות:');
    }
    
    activeLists.sort((a, b) {
      final priorityA = _calculateListPriority(a);
      final priorityB = _calculateListPriority(b);
      if (kDebugMode) {
        debugPrint('   "${a.name}": $priorityA נקודות vs "${b.name}": $priorityB נקודות');
      }
      return priorityB.compareTo(priorityA); // גבוה לנמוך
    });

    final list = activeLists.first;
    final finalPriority = _calculateListPriority(list);
    if (kDebugMode) {
      debugPrint('   ✅ הקנייה הקרובה: "${list.name}" ($finalPriority נקודות)');
    }
    
    return list;
  }

  /// ✅ מחזיר רשימות נוספות (ללא הדחופה ביותר)
  List<ShoppingList> _getOtherLists(List<ShoppingList> activeLists) {
    return activeLists.length > 1 
        ? activeLists.sublist(1) 
        : const <ShoppingList>[];
  }

  /// 🧠 חישוב דחיפות רשימה לפי 3 קריטריונים:
  /// 1. תאריך אירוע קרוב (100 נקודות אם בעוד פחות משבוע)
  /// 2. מלאי שנגמר (60 נקודות אם 3+ פריטים)
  /// 3. עדכון אחרון (20 נקודות אם עודכן היום)
  int _calculateListPriority(ShoppingList list) {
    int priority = 0;
    final now = DateTime.now();

    // 📅 קריטריון 1: תאריך אירוע
    if (list.eventDate != null) {
      final daysUntilEvent = list.eventDate!.difference(now).inDays;
      
      if (daysUntilEvent <= 7 && daysUntilEvent >= -1) {
        // שבוע לפני האירוע (או האירוע היה אתמול)
        priority += 100;
        if (kDebugMode) {
          debugPrint('   📅 "${list.name}": אירוע בעוד $daysUntilEvent ימים (+100)');
        }
      } else if (daysUntilEvent <= 14 && daysUntilEvent > 7) {
        // שבועיים לפני האירוע
        priority += 50;
        if (kDebugMode) {
          debugPrint('   📅 "${list.name}": אירוע בעוד $daysUntilEvent ימים (+50)');
        }
      }
    }

    // 🛒 קריטריון 2: מלאי שנגמר
    // TODO(v2.0): חיבור למערכת מלאי
    // final outOfStockCount = _checkInventoryForList(list);
    // if (outOfStockCount >= 3) priority += 60;
    // else if (outOfStockCount >= 1) priority += 30;

    // ⏰ קריטריון 3: עדכון אחרון
    final daysSinceUpdate = now.difference(list.updatedDate).inDays;
    if (daysSinceUpdate == 0) {
      priority += 20;
      if (kDebugMode) {
        debugPrint('   ⏰ "${list.name}": עודכן היום (+20)');
      }
    } else if (daysSinceUpdate == 1) {
      priority += 10;
      if (kDebugMode) {
        debugPrint('   ⏰ "${list.name}": עודכן אתמול (+10)');
      }
    }

    return priority;
  }


}

class _ImprovedEmptyState extends StatelessWidget {
  final VoidCallback onCreateList;

  const _ImprovedEmptyState({required this.onCreateList});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: kSpacingLarge * 2.67, // 64px
          horizontal: kSpacingXLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: kSpacingXLarge * 3.75, // 120px
                  height: kSpacingXLarge * 3.75, // 120px
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: kSpacingLarge * 2.67, // 64px
                    color: accent,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                )
                .then()
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(1.05, 1.05),
                  end: const Offset(0.95, 0.95),
                ),

            const SizedBox(height: kSpacingLarge),

            Text(
              AppStrings.home.noActiveLists,
              style: t.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: kBorderRadius),

            Text(
              AppStrings.home.emptyStateMessage,
              style: t.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: kSpacingXLarge),

            FilledButton.icon(
              onPressed: onCreateList,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(AppStrings.home.createFirstList),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
                textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}

class _ReceiptsCard extends StatelessWidget {
  const _ReceiptsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final receiptProvider = context.watch<ReceiptProvider>();

    final receiptsCount = receiptProvider.receipts.length;
    final totalAmount = receiptProvider.receipts.fold<double>(
      0.0,
      (sum, r) => sum + r.totalAmount,
    );

    return StickyNote(
      color: kStickyPink,  // ✅ פתק ורוד
      rotation: 0.015,
      child: InkWell(
        onTap: () {
          if (kDebugMode) {
            debugPrint('🏠 HomeDashboard: ניווט למסך קבלות');
          }
          Navigator.pushNamed(context, '/receipts');
        },
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: EdgeInsets.zero,  // StickyNote כבר יש padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(kSpacingSmall),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.orange,
                          size: kIconSizeSmall + 4, // 20px
                        ),
                      ),
                      // ✨ Badge חדש!
                      if (receiptsCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$receiptsCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: kBorderRadius),
                  Expanded(
                    child: Text(
                      AppStrings.home.myReceipts,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,  // ✅ טקסט כהה על פתק
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: Colors.black54),
                ],
              ),
              const SizedBox(height: kBorderRadius),
              if (receiptProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(kSpacingMedium),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (receiptsCount == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
                  child: Text(
                    AppStrings.home.noReceipts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.home.receiptsCount(receiptsCount),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        // ✨ הוסף אחוז
                        Text(
                          '${(receiptsCount / kMaxReceiptsForProgress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₪${totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    LinearProgressIndicator(
                      value: receiptsCount / kMaxReceiptsForProgress,
                      backgroundColor: cs.surfaceContainerHighest,
                      color: Colors.orange,
                      minHeight: kBorderWidthThick * 2, // 4px
                      borderRadius: BorderRadius.circular(kBorderWidthThick),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 450.ms, delay: 200.ms).slideY(begin: 0.1);
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StickyNote(
      color: kStickyPurple,  // ✅ פתק סגול
      rotation: 0.01,
      child: InkWell(
        onTap: () {
          if (kDebugMode) {
            debugPrint('🏠 HomeDashboard: ניווט למסך תובנות');
          }
          Navigator.pushNamed(context, '/insights');
        },
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: EdgeInsets.zero,  // StickyNote כבר יש padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: const Icon(
                      Icons.insights_outlined,
                      color: Colors.deepPurple,
                      size: kIconSizeSmall + 4, // 20px
                    ),
                  ),
                  const SizedBox(width: kBorderRadius),
                  Expanded(
                    child: Text(
                      'תובנות חכמות',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,  // ✅ טקסט כהה על פתק
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: Colors.black54),
                ],
              ),
              const SizedBox(height: kBorderRadius),
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.deepPurple,
                    size: kIconSizeSmall,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'ראה סטטיסטיקות על הרגלי הקנייה שלך',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: kIconSizeSmall,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'קבל המלצות לשיפור וחיסכון',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveListsCard extends StatelessWidget {
  final List<ShoppingList> lists;

  const _ActiveListsCard({required this.lists});

  Future<void> _deleteList(
    BuildContext context,
    ShoppingList list,
  ) async {
    HapticFeedback.mediumImpact(); // ✨ רטט בינוני למחיקה
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: מוחק רשימה "${list.name}" (${list.id})');
    }
    
    final provider = context.read<ShoppingListsProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context); // 👈 שמירה לפני async

    try {
      // שמירת כל הנתונים לפני מחיקה
      final deletedList = list;

      // מחיקה מיידית
      await provider.deleteList(list.id);
      if (kDebugMode) {
        debugPrint('   ✅ רשימה נמחקה');
      }

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.home.listDeleted(deletedList.name)),
            action: SnackBarAction(
              label: AppStrings.home.undo,
              onPressed: () async {
                if (kDebugMode) {
                  debugPrint('🏠 HomeDashboard: משחזר רשימה "${deletedList.name}"');
                }
                await provider.restoreList(deletedList);
                if (kDebugMode) {
                  debugPrint('   ✅ רשימה שוחזרה');
                }
              },
            ),
            duration: kSnackBarDurationLong,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ שגיאה במחיקת רשימה: $e');
      }
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.home.deleteListError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? cs.primary;

    return StickyNote(
      color: kStickyGreen,  // ✅ פתק ירוק
      rotation: -0.01,
      child: Padding(
        padding: EdgeInsets.zero,  // StickyNote כבר יש padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: accent,
                    size: kIconSizeSmall + 4, // 20px
                  ),
                ),
                const SizedBox(width: kBorderRadius),
                Expanded(
                child: Text(
                AppStrings.home.otherActiveLists,
                style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,  // ✅ טקסט כהה על פתק
                ),
                ),
                ),
                IconButton(
                  icon: const Icon(Icons.list_alt),
                  onPressed: () {
                    if (kDebugMode) {
                      debugPrint('🏠 HomeDashboard: ניווט לכל הרשימות');
                    }
                    Navigator.pushNamed(context, "/shopping-lists");
                  },
                  tooltip: AppStrings.home.allLists,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            ...lists.map((list) {
              return _DismissibleListTile(
                list: list,
                onDelete: () => _deleteList(context, list),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DismissibleListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onDelete;

  const _DismissibleListTile({required this.list, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final itemsCount = list.items.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: Dismissible(
        key: Key(list.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: kIconSizeSmall + 4), // 20px
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.delete_outline, color: Colors.white),
              const SizedBox(width: kSpacingSmall),
              Text(
                AppStrings.common.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: Material(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
            side: BorderSide(
              color: cs.outline.withValues(alpha: 0.2),
              width: kBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: () {
              if (kDebugMode) {
                debugPrint('🏠 HomeDashboard: ניווט לרשימה "${list.name}"');
              }
              Navigator.pushNamed(
                context,
                "/manage-list",
                arguments: {
                  "listId": list.id,
                  "listName": list.name,
                  "existingList": list,
                },
              );
            },
            borderRadius: BorderRadius.circular(kBorderRadius - 2), // 10px
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kBorderRadius,
                vertical: kBorderRadius - 2, // 10px
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kSpacingMedium - 2, // 14px
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.list_alt,
                      size: kIconSizeSmall,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: kBorderRadius - 2), // 10px
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: kBorderWidthThick),
                        Text(
                          AppStrings.home.itemsCount(itemsCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
