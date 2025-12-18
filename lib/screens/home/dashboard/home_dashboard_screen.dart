// 📄 File: lib/screens/home/home_dashboard_screen.dart
// 🎯 Purpose: מסך דשבורד הבית - Dashboard Screen
//
// 📋 Features:
// ✅ Header עם ברכה
// ✅ אזור "דורש תשומת לב" - התראות חשובות
// ✅ כפתורי גישה מהירה (מזווה + קנייה)
// ✅ פעילות אחרונה
// ✅ קיצורי קבוצות
// ✅ Pull-to-Refresh
//
// 📝 Version: 2.0
// 📅 Updated: 14/12/2025

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../services/tutorial_service.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/group.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/groups_provider.dart';
import '../../../providers/pending_invites_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../../../providers/user_context.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_note.dart';

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

    // 📚 הצג הדרכה למשתמשים חדשים
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        TutorialService.showHomeTutorialIfNeeded(context);
        // 📨 בדוק הזמנות ממתינות
        _checkPendingInvites();
      }
    });
  }

  /// 📨 בדיקת הזמנות ממתינות לקבוצות
  Future<void> _checkPendingInvites() async {
    final userContext = context.read<UserContext>();
    final pendingInvitesProvider = context.read<PendingInvitesProvider>();

    // אל תבדוק שוב אם כבר בדקנו
    if (pendingInvitesProvider.hasChecked) {
      if (kDebugMode) {
        debugPrint('📨 HomeDashboard: Already checked, skipping');
      }
      return;
    }

    // חכה לטעינת המשתמש אם צריך (מקסימום 3 שניות)
    for (int i = 0; i < 30 && mounted; i++) {
      if (userContext.user != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final user = userContext.user;
    if (user == null) {
      if (kDebugMode) {
        debugPrint('📨 HomeDashboard: User is null, skipping invite check');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📨 HomeDashboard: Checking invites for phone=${user.phone}, email=${user.email}');
    }

    await pendingInvitesProvider.checkPendingInvites(
      phone: user.phone,
      email: user.email,
    );

    if (kDebugMode) {
      debugPrint('📨 HomeDashboard: Found ${pendingInvitesProvider.pendingCount} pending invites');
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

    final lists = context.read<ShoppingListsProvider>();
    final sugg = context.read<SuggestionsProvider>();

    await HapticFeedback.mediumImpact();

    try {
      await lists.loadLists();
      if (kDebugMode) {
        debugPrint('   ✅ רשימות נטענו: ${lists.lists.length}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ שגיאה בטעינת רשימות: $e');
      }
    }

    if (!context.mounted) return;

    try {
      await sugg.refreshSuggestions();
      if (kDebugMode) {
        debugPrint('   ✅ הצעות נטענו: ${sugg.suggestions.length}');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ⚠️ לא ניתן לטעון הצעות: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (context.mounted) {
      await HapticFeedback.lightImpact();
    }

    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: refresh הושלם');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final groupsProvider = context.watch<GroupsProvider>();
    final pendingInvitesProvider = context.watch<PendingInvitesProvider>();
    final userContext = context.watch<UserContext>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: kPaperBackground,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: RefreshIndicator(
              color: Theme.of(context).extension<AppBrand>()?.accent ??
                  cs.primary,
              backgroundColor: kPaperBackground,
              strokeWidth: 4.0,
              displacement: 50.0,
              onRefresh: () => _refresh(context),
              child: ListView(
                padding: const EdgeInsets.all(kSpacingMedium),
                children: [
                  // === 1. Header עם ברכה ===
                  _GreetingHeader(userName: userContext.displayName)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: kSpacingMedium),

                  // === 2. הזמנות ממתינות ===
                  if (pendingInvitesProvider.pendingCount > 0)
                    _PendingInvitesCard(
                      count: pendingInvitesProvider.pendingCount,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideX(begin: -0.1, end: 0),

                  if (pendingInvitesProvider.pendingCount > 0)
                    const SizedBox(height: kSpacingMedium),

                  // === 3. דורש תשומת לב ===
                  _AttentionSection(
                    lists: listsProvider.lists,
                    groups: groupsProvider.groups,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 150.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: kSpacingMedium),

                  // === 3. כפתורי גישה מהירה ===
                  _QuickAccessButtons(
                    hasActiveLists: listsProvider.lists
                        .any((l) => l.status == ShoppingList.statusActive),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1)),

                  const SizedBox(height: kSpacingMedium),

                  // === 4. פעילות אחרונה ===
                  _RecentActivitySection(lists: listsProvider.lists)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: kSpacingMedium),

                  // === 5. קיצורי קבוצות ===
                  _GroupsShortcuts(groups: groupsProvider.groups)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: kSpacingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 1. GREETING HEADER
// =============================================================================

class _GreetingHeader extends StatelessWidget {
  final String? userName;
  const _GreetingHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final greeting = _getGreeting();
    final displayName = (userName?.trim().isEmpty ?? true)
        ? AppStrings.home.guestUser
        : userName!;

    return StickyNote(
      color: kStickyYellow,
      rotation: -0.015,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getGreetingEmoji(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: t.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    displayName,
                    style: t.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'לילה טוב';
    if (hour < 12) return 'בוקר טוב';
    if (hour < 17) return 'צהריים טובים';
    if (hour < 21) return 'ערב טוב';
    return 'לילה טוב';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 5) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌆';
    return '🌙';
  }
}

// =============================================================================
// 2. ATTENTION SECTION - דורש תשומת לב
// =============================================================================

class _AttentionSection extends StatelessWidget {
  final List<ShoppingList> lists;
  final List<Group> groups;

  const _AttentionSection({
    required this.lists,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = _getAlerts();

    // אם אין התראות, לא מציג כלום
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return StickyNote(
      color: kStickyPink,
      rotation: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 20),
                SizedBox(width: kSpacingSmall),
                Text(
                  'דורש תשומת לב',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),
            ...alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(alert.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.message,
                          style: const TextStyle(
                            fontSize: kFontSizeSmall,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<_Alert> _getAlerts() {
    final alerts = <_Alert>[];

    // התראות על רשימות
    final activeLists =
        lists.where((l) => l.status == ShoppingList.statusActive).toList();

    // רשימות ריקות
    final emptyLists = activeLists.where((l) => l.items.isEmpty).toList();
    if (emptyLists.length == 1) {
      alerts.add(_Alert('📝', '${emptyLists.first.name} - אין פריטים'));
    } else if (emptyLists.length > 1) {
      alerts.add(_Alert('📝', '${emptyLists.length} רשימות ריקות'));
    }

    // רשימות עם פריטים רבים שלא נקנו
    for (final list in activeLists) {
      final uncheckedCount =
          list.items.where((i) => !i.isChecked).length;
      if (uncheckedCount >= 10) {
        alerts.add(_Alert('🛒', '${list.name} - $uncheckedCount פריטים ממתינים'));
      }
    }

    return alerts.take(5).toList(); // מקסימום 5 התראות
  }
}

class _Alert {
  final String emoji;
  final String message;
  _Alert(this.emoji, this.message);
}

// =============================================================================
// 3. QUICK ACCESS BUTTONS - כפתורי גישה מהירה
// =============================================================================

class _QuickAccessButtons extends StatelessWidget {
  final bool hasActiveLists;

  const _QuickAccessButtons({required this.hasActiveLists});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // כפתור משפחה (רשימות + מזווה)
        Expanded(
          child: _QuickAccessButton(
            emoji: '👨‍👩‍👧',
            label: 'משפחה',
            color: kStickyPink,
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to Family tab (index 1)
              _navigateToTab(context, 1);
            },
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        // כפתור קנייה
        Expanded(
          child: _QuickAccessButton(
            emoji: '🛒',
            label: 'קנייה',
            color: kStickyCyan,
            badge: hasActiveLists ? null : 'חדש',
            onTap: () {
              HapticFeedback.lightImpact();
              if (hasActiveLists) {
                // Navigate to Family tab (lists)
                _navigateToTab(context, 1);
              } else {
                // Create new list
                Navigator.pushNamed(context, '/create-list');
              }
            },
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        // כפתור קבוצות
        Expanded(
          child: _QuickAccessButton(
            emoji: '👥',
            label: 'קבוצות',
            color: kStickyPurple,
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to Groups tab (index 2)
              _navigateToTab(context, 2);
            },
          ),
        ),
      ],
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // Use a callback to notify the parent MainNavigationScreen
    // For now, just show a message
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null) {
      // Navigate using named route with tab index
      Navigator.of(context).pushReplacementNamed('/home', arguments: index);
    }
  }
}

class _QuickAccessButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: StickyNote(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingMedium,
            horizontal: kSpacingSmall,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. RECENT ACTIVITY - פעילות אחרונה
// =============================================================================

class _RecentActivitySection extends StatelessWidget {
  final List<ShoppingList> lists;

  const _RecentActivitySection({required this.lists});

  @override
  Widget build(BuildContext context) {
    // מציג 5 רשימות אחרונות
    final recentLists = lists.take(5).toList();

    if (recentLists.isEmpty) {
      return const SizedBox.shrink();
    }

    return StickyNote(
      color: kStickyYellow.withValues(alpha: 0.7),
      rotation: -0.005,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, size: 18, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      'פעילות אחרונה',
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    DefaultTabController.of(context).animateTo(1);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('ראה הכל'),
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),
            ...recentLists.map((list) => _ActivityItem(list: list)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ShoppingList list;

  const _ActivityItem({required this.list});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          '/shopping-list-details',
          arguments: list,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(list.typeEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${list.items.length} פריטים • ${_getRelativeTime(list.updatedDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'עכשיו';
    } else if (difference.inMinutes < 60) {
      return 'לפני ${difference.inMinutes} דק\'';
    } else if (difference.inHours < 24) {
      return 'לפני ${difference.inHours} שעות';
    } else if (difference.inDays < 7) {
      return 'לפני ${difference.inDays} ימים';
    } else {
      return 'לפני ${(difference.inDays / 7).round()} שבועות';
    }
  }
}

// =============================================================================
// 5. GROUPS SHORTCUTS - קיצורי קבוצות
// =============================================================================

class _GroupsShortcuts extends StatelessWidget {
  final List<Group> groups;

  const _GroupsShortcuts({required this.groups});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StickyNote(
      color: kStickyGreen.withValues(alpha: 0.7),
      rotation: 0.008,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.groups, size: 18, color: Colors.black54),
                SizedBox(width: 6),
                Text(
                  'הקבוצות שלי',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),
            if (groups.isEmpty)
              // אין קבוצות - הצג הודעה וכפתור יצירה
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/create-group');
                },
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Container(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'צור את הקבוצה הראשונה שלך',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // יש קבוצות - הצג chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...groups.take(5).map((group) => _GroupChip(group: group)),
                  // כפתור + ליצירת קבוצה חדשה
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('חדש'),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/create-group');
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final Group group;

  const _GroupChip({required this.group});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Text(group.type.emoji, style: const TextStyle(fontSize: 14)),
      label: Text(
        group.name,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide.none,
      onPressed: () {
        HapticFeedback.lightImpact();
        // Navigate to group details
        Navigator.pushNamed(
          context,
          '/group-details',
          arguments: group.id,
        );
      },
    );
  }
}

// =============================================================================
// 6. PENDING INVITES CARD - הזמנות ממתינות
// =============================================================================

class _PendingInvitesCard extends StatelessWidget {
  final int count;

  const _PendingInvitesCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, '/pending-group-invites');
      },
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: StickyNote(
        color: Colors.orange.shade100,
        rotation: 0.01,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Row(
            children: [
              // אייקון עם badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.group_add,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: kSpacingMedium),
              // טקסט
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count == 1
                          ? 'יש לך הזמנה לקבוצה!'
                          : 'יש לך $count הזמנות לקבוצות!',
                      style: const TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'לחץ כדי לצפות ולאשר',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // חץ
              const Icon(
                Icons.chevron_left,
                color: Colors.orange,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
