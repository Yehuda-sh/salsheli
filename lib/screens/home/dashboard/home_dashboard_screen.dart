// 📄 lib/screens/home/dashboard/home_dashboard_screen.dart
//
// מסך הבית החדש - פשוט ונקי:
// 1. Header: "שלום, [שם]" + שם משפחה + התראות
// 2. באנרים (Active Shopper, Pending Invite)
// 3. Quick Add
// 4. הצעות להיום (≤3 פריטים)
// 5. רשימות פעילות (Cards)
// 6. היסטוריה (2 קבלות + "ראה הכל")
//
// Version: 6.0 (08/01/2026) - Enhanced home screen
// 🔗 Related: ShoppingListsProvider, ReceiptProvider, NotificationsService

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../models/receipt.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/pending_invites_provider.dart';
import '../../../providers/receipt_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../../../providers/user_context.dart';
import '../../../services/notifications_service.dart';
import '../../../services/tutorial_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../history/receipt_details_screen.dart';
import 'widgets/active_shopper_banner.dart';
import 'widgets/pending_invite_banner.dart';
import 'widgets/quick_add_field.dart';
import 'widgets/suggestions_today_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboardScreen.initState()');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        TutorialService.showHomeTutorialIfNeeded(context);
        _initInviteCheck();
      }
    });
  }

  Future<void> _initInviteCheck() async {
    if (!mounted) return;

    final userContext = context.read<UserContext>();
    final pendingInvitesProvider = context.read<PendingInvitesProvider>();

    if (pendingInvitesProvider.hasChecked) return;

    final user = userContext.user;
    if (user != null) {
      if (kDebugMode) {
        debugPrint('📨 HomeDashboard: Checking invites for ${user.email}');
      }
      await pendingInvitesProvider.checkPendingInvites(
        phone: user.phone,
        email: user.email,
      );
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
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: מתחיל refresh...');
    }

    final lists = context.read<ShoppingListsProvider>();
    final sugg = context.read<SuggestionsProvider>();
    final receipts = context.read<ReceiptProvider>();

    await HapticFeedback.mediumImpact();

    try {
      await Future.wait([
        lists.loadLists(),
        receipts.loadReceipts(),
      ]);
      if (kDebugMode) {
        debugPrint('   ✅ רשימות וקבלות נטענו');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ שגיאה בטעינה: $e');
      }
    }

    if (!context.mounted) return;

    try {
      await sugg.refreshSuggestions();
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

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  /// מחזיר שם משפחה להצגה
  /// אם householdId מתחיל ב-"house_" + userId → "משפחה אישית"
  /// אחרת → "בית [שם]" (כרגע placeholder עד שנטמיע Family model)
  String _getFamilyDisplayName(UserContext userContext) {
    final householdId = userContext.householdId;
    final userId = userContext.userId;

    if (householdId == null || userId == null) {
      return 'משפחה אישית';
    }

    // בדיקה אם זו משפחה אישית (auto-generated)
    if (householdId == 'house_$userId' ||
        householdId == 'house_${userId.hashCode.abs()}') {
      return 'משפחה אישית';
    }

    // משפחה משותפת - כרגע מציג placeholder
    // TODO: Sprint 2 - טען שם משפחה מ-Family model
    return 'משפחה משותפת';
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ShoppingListsProvider>();
    final receiptProvider = context.watch<ReceiptProvider>();
    final userContext = context.watch<UserContext>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    final paperBg = brand?.paperBackground ?? theme.scaffoldBackgroundColor;

    // רשימות פעילות בלבד
    final activeLists = listsProvider.lists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList();

    // קבלות ממוינות לפי תאריך (חדש לישן)
    final sortedReceipts = List<Receipt>.from(receiptProvider.receipts)
      ..sort((a, b) => b.date.compareTo(a.date));

    // שם משפחה להצגה
    final familyName = _getFamilyDisplayName(userContext);

    return Scaffold(
      backgroundColor: paperBg,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/create-list');
        },
        icon: const Icon(Icons.add),
        label: const Text('רשימה חדשה'),
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: RefreshIndicator(
              color: brand?.accent ?? cs.primary,
              backgroundColor: paperBg,
              strokeWidth: 4.0,
              displacement: 50.0,
              onRefresh: () => _refresh(context),
              child: ListView(
                padding: const EdgeInsets.all(kSpacingMedium),
                children: [
                  // === 1. באנרים (לפי עדיפות: Error > Active Shopper > Pending Invite) ===
                  if (listsProvider.hasError)
                    _buildErrorBanner(context, listsProvider.errorMessage!, cs),
                  const ActiveShopperBanner(),
                  const PendingInviteBanner(),

                  // === 2. Header עם שם משפחה ===
                  _buildHeader(
                    context,
                    userName: userContext.displayName,
                    familyName: familyName,
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === 3. Quick Add ===
                  const QuickAddField(),

                  const SizedBox(height: kSpacingMedium),

                  // === 4. הצעות להיום ===
                  const SuggestionsTodayCard(),

                  const SizedBox(height: kSpacingMedium),

                  // === 5. רשימות פעילות ===
                  _buildActiveListsSection(context, activeLists, cs),

                  const SizedBox(height: kSpacingMedium),

                  // === 6. היסטוריה ===
                  _buildHistorySection(context, sortedReceipts, cs),

                  // מרווח לפני FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 0. ERROR BANNER - באנר שגיאה
  // ============================================
  Widget _buildErrorBanner(BuildContext context, String errorMessage, ColorScheme cs) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: cs.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'שגיאה בטעינת נתונים',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  errorMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onErrorContainer.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _refresh(context),
            icon: Icon(Icons.refresh, color: cs.onErrorContainer, size: 18),
            label: Text(
              'נסה שוב',
              style: TextStyle(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 1. HEADER - כרטיס ברכה צבעוני + שם משפחה
  // ============================================
  Widget _buildHeader(
    BuildContext context, {
    required String? userName,
    required String? familyName,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final userContext = context.watch<UserContext>();
    final notificationsService = context.read<NotificationsService>();

    final hasName = userName?.trim().isNotEmpty ?? false;
    final greeting = hasName ? 'שלום, $userName!' : 'שלום!';

    return Card(
      elevation: 0,
      color: cs.primaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Row(
          children: [
            // אייקון/אימוג'י
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '👋',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: kSpacingMedium),
            // ברכה + שם משפחה
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  if (familyName != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          familyName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // התראות - bell icon עם StreamBuilder לספירת התראות
            StreamBuilder<int>(
              stream: userContext.userId != null
                  ? notificationsService.watchUnreadCount(userId: userContext.userId!)
                  : const Stream.empty(),
              initialData: 0,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/notifications');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Badge.count(
                    count: unreadCount,
                    isLabelVisible: unreadCount > 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications_outlined, color: cs.primary),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 2. ACTIVE LISTS - רשימות פעילות
  // ============================================
  Widget _buildActiveListsSection(
    BuildContext context,
    List<ShoppingList> activeLists,
    ColorScheme cs,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת
        Row(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'רשימות פעילות',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${activeLists.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // רשימה או הודעה
        if (activeLists.isEmpty)
          Card(
            elevation: 0,
            color: cs.secondaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: cs.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/create-list');
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(kSpacingLarge),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        size: 32,
                        color: cs.secondary,
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    Text(
                      'אין רשימות פעילות',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'לחץ כאן ליצירת רשימה חדשה',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...activeLists.map((list) => _buildListCard(context, list, cs)),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, ShoppingList list, ColorScheme cs) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final uncheckedCount = list.items.where((i) => !i.isChecked).length;
    final checkedCount = list.items.where((i) => i.isChecked).length;
    final totalCount = list.items.length;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    // צבע לפי סוג הרשימה
    final typeColor = _getListTypeColor(list.type, cs, brand);

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(
            context,
            '/list-details',
            arguments: list,
          );
        },
        child: Column(
          children: [
            // פס צבע עליון
            Container(
              height: 4,
              color: typeColor,
            ),
            Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Row(
                children: [
                  // אימוג'י בעיגול צבעוני
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(list.typeEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),
                  // שם + מספר פריטים
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (totalCount == 0)
                          Text(
                            'רשימה ריקה',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                uncheckedCount == 0
                                    ? Icons.check_circle
                                    : Icons.shopping_bag_outlined,
                                size: 14,
                                color: uncheckedCount == 0
                                    ? Colors.green
                                    : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                uncheckedCount == 0
                                    ? 'הושלם! ✓'
                                    : 'נותרו $uncheckedCount פריטים',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: uncheckedCount == 0
                                      ? Colors.green
                                      : cs.onSurfaceVariant,
                                  fontWeight: uncheckedCount == 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // חץ
                  Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            // Progress bar בתחתית
            if (totalCount > 0)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  progress == 1.0 ? Colors.green : typeColor,
                ),
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }

  Color _getListTypeColor(String type, ColorScheme cs, AppBrand? brand) {
    switch (type) {
      case 'supermarket':
      case 'market':
        return brand?.stickyGreen ?? kStickyGreen;
      case 'pharmacy':
        return brand?.stickyPink ?? kStickyPink;
      case 'greengrocer':
        return brand?.stickyCyan ?? kStickyCyan;
      case 'butcher':
        return kStickyOrange;
      case 'bakery':
        return brand?.stickyYellow ?? kStickyYellow;
      case 'household':
        return brand?.stickyCyan ?? kStickyCyan;
      case 'event':
        return brand?.stickyPurple ?? kStickyPurple;
      default:
        return cs.primary;
    }
  }

  // ============================================
  // 3. HISTORY - היסטוריה (2 קבלות + "ראה הכל")
  // ============================================
  Widget _buildHistorySection(
    BuildContext context,
    List<Receipt> receipts,
    ColorScheme cs,
  ) {
    final theme = Theme.of(context);

    if (receipts.isEmpty) {
      return const SizedBox.shrink();
    }

    // מציג רק 2 קבלות אחרונות
    final recentReceipts = receipts.take(2).toList();
    final hasMore = receipts.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת
        Row(
          children: [
            Icon(Icons.history, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'היסטוריה',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (hasMore)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/history');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ראה הכל',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_left, size: 16, color: cs.primary),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // כרטיסי קבלות
        Card(
          child: Column(
            children: [
              ...recentReceipts.asMap().entries.map((entry) {
                final index = entry.key;
                final receipt = entry.value;
                return Column(
                  children: [
                    _buildReceiptTile(context, receipt, cs),
                    if (index < recentReceipts.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptTile(BuildContext context, Receipt receipt, ColorScheme cs) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptDetailsScreen(receipt: receipt),
          ),
        );
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          receipt.isVirtual ? Icons.receipt_long : Icons.receipt,
          color: cs.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        receipt.storeName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(receipt.date),
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      trailing: receipt.totalAmount > 0
          ? Text(
              '₪${receipt.totalAmount.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            )
          : Text(
              '${receipt.items.length} פריטים',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'היום';
    } else if (difference.inDays == 1) {
      return 'אתמול';
    } else if (difference.inDays < 7) {
      return 'לפני ${difference.inDays} ימים';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
