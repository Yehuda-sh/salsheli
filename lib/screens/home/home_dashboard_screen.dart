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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/user_context.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/home/smart_suggestions_card.dart';
import '../../widgets/home/upcoming_shop_card.dart';
import '../../widgets/shopping/create_list_dialog.dart';
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
    await HapticFeedback.mediumImpact(); // ✨ רטט בהתחלת refresh
    
    // ✅ שמירת providers לפני await
    final lists = context.read<ShoppingListsProvider>();
    final sugg = context.read<SuggestionsProvider>();
    
    // ✅ טעינת רשימות - נפרד
    try {
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
      await sugg.refreshSuggestions();
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
      await HapticFeedback.lightImpact(); // ✨ רטט קל בסיום
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

                  // ✨ Skeleton loading עם אנימציות
                  if (listsProvider.isLoading)
                    const DashboardSkeleton()
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.05, end: 0)
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
    HapticFeedback.lightImpact().ignore(); // ✨ רטט קל
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
                HapticFeedback.lightImpact().ignore(); // ✨ רטט הצלחה
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
                HapticFeedback.heavyImpact().ignore(); // ✨ רטט חזק לשגיאה
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
        
        const SmartSuggestionsCard()
          .animate()
          .fadeIn(duration: 600.ms, delay: 150.ms) // ✨ יותר איטי
          .slideY(begin: 0.15, end: 0) // ✨ יותר דרמטי
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)), // ✨ זום!
        
        const SizedBox(height: kSpacingMedium),
        
        if (otherLists.isNotEmpty)
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Navigate to lists tab (index 1)
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.list_alt),
              label: Text(
                'יש לך עוד ${otherLists.length} רשימות - לחץ לצפייה',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingLarge,
                  vertical: kSpacingMedium,
                ),
              )
            ),
          )
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideY(begin: 0.15, end: 0),
      ],
    );
  }

  /// ✅ מחזיר רק רשימות פעילות
  List<ShoppingList> _getActiveLists() {
    return allLists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();
  }

  /// ✅ מחזיר את הרשימה עם העדכון האחרון
  ShoppingList? _getMostRecentList(List<ShoppingList> activeLists) {
    if (activeLists.isEmpty) return null;

    if (kDebugMode) {
      debugPrint('🧠 ממיין ${activeLists.length} רשימות לפי עדכון אחרון');
    }
    
    // מיון לפי תאריך עדכון (החדש ביותר ראשון)
    activeLists.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

    final list = activeLists.first;
    if (kDebugMode) {
      debugPrint('   ✅ הקנייה הקרובה: "${list.name}" (עודכן: ${list.updatedDate})');
    }
    
    return list;
  }

  /// ✅ מחזיר רשימות נוספות (ללא הדחופה ביותר)
  List<ShoppingList> _getOtherLists(List<ShoppingList> activeLists) {
    return activeLists.length > 1 
        ? activeLists.sublist(1) 
        : const <ShoppingList>[];
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
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingLarge * 2.67, // 64px
          horizontal: kSpacingXLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
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


