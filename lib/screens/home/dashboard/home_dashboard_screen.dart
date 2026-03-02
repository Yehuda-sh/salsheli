// 📄 lib/screens/home/dashboard/home_dashboard_screen.dart
//
// מסך הבית - פשוט ונקי:
// 1. Header: ברכה דינמית (בוקר/צהריים/ערב) + שם משפחה + התראות
// 2. באנרים (Active Shopper, Pending Invite)
// 3. Quick Add
// 4. הצעות להיום (≤3 פריטים)
// 5. רשימות פעילות (Cards)
// 6. היסטוריה (2 קבלות + "ראה הכל")
//
// 📋 Features:
// - ברכת בוקר/ערב דינמית
// - אנימציות כניסה מדורגות (Staggered)
// - Glassmorphic Header משופר
// - Haptic Feedback מלא ב-Refresh ובניווט
//
// Version: 7.0 (22/02/2026) - Hybrid Premium dashboard
// 🔗 Related: ShoppingListsProvider, ReceiptProvider, NotificationsService

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/receipt.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/receipt_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../../../providers/user_context.dart';
import '../../../services/notifications_service.dart';
import '../../../services/tutorial_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../history/shopping_history_screen.dart';
import 'widgets/active_shopper_banner.dart';
import 'widgets/pending_invites_banner.dart';
import 'widgets/suggestions_today_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isRefreshing = false;

  /// דגל לאנימציית כניסה חד-פעמית (רק בטעינה ראשונה)
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🏠 HomeDashboardScreen.initState()');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        TutorialService.showHomeTutorialIfNeeded(context);
        setState(() => _hasAnimated = true);
      }
    });
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

    unawaited(HapticFeedback.mediumImpact());

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
      unawaited(HapticFeedback.lightImpact());
    }

    if (kDebugMode) {
      debugPrint('🏠 HomeDashboard: refresh הושלם');
    }

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  /// מחזיר שם קבוצה להצגה:
  /// 1. משפחה אישית → "משפחה אישית"
  /// 2. householdName קיים → מחזיר אותו
  /// 3. fallback → גוזר מהשם האחרון של המשתמש ("משפחת כהן")
  String _getFamilyDisplayName(UserContext userContext) {
    final strings = AppStrings.homeDashboard;
    final householdId = userContext.householdId;
    final userId = userContext.userId;

    if (householdId == null || userId == null) {
      return strings.personalFamily;
    }

    // בדיקה אם זו משפחה אישית (auto-generated)
    if (householdId == 'house_$userId' ||
        householdId == 'house_${userId.hashCode.abs()}') {
      return strings.personalFamily;
    }

    // שם קבוצה אמיתי
    final householdName = userContext.householdName;
    if (householdName != null && householdName.trim().isNotEmpty) {
      return householdName;
    }

    // fallback: גזירה מהשם האחרון של המשתמש
    final displayName = userContext.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(' ');
      final lastName = parts.length >= 2 ? parts.last : parts.first;
      return '${strings.familyOf}$lastName';
    }

    return strings.sharedFamily;
  }

  /// עוטף widget באנימציית כניסה מדורגת (רק בפעם הראשונה)
  Widget _staggered(Widget child, int index) {
    if (_hasAnimated) return child;
    return child
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: (index * 50).ms,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          delay: (index * 50).ms,
          curve: Curves.easeOut,
        );
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

    // רשימות פעילות בלבד, ממוינות לפי עדכון אחרון (חדש קודם)
    final activeLists = listsProvider.lists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList()
      ..sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

    // קבלות ממוינות לפי תאריך (חדש לישן)
    final sortedReceipts = List<Receipt>.from(receiptProvider.receipts)
      ..sort((a, b) => b.date.compareTo(a.date));

    // שם משפחה להצגה
    final familyName = _getFamilyDisplayName(userContext);

    var sectionIndex = 0;

    return Scaffold(
      backgroundColor: paperBg,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () {
          unawaited(HapticFeedback.lightImpact());
          Navigator.pushNamed(context, '/create-list');
        },
        icon: const Icon(Icons.add),
        label: Text(AppStrings.homeDashboard.newListButton),
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 500.ms,
            delay: 300.ms,
            curve: Curves.elasticOut,
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
                  // === 1. באנרים (Error / Active Shopper / Pending Invites) ===
                  _staggered(
                    Column(
                      children: [
                        if (listsProvider.hasError)
                          _buildErrorBanner(context, listsProvider.errorMessage!, cs),
                        const ActiveShopperBanner(),
                        const PendingInvitesBanner(),
                      ],
                    ),
                    sectionIndex++,
                  ),

                  // === 2. Header עם ברכה דינמית ===
                  _staggered(
                    _buildHeader(
                      context,
                      userName: userContext.displayName,
                      familyName: familyName,
                    ),
                    sectionIndex++,
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === 4. הצעות להיום ===
                  _staggered(
                    const RepaintBoundary(
                      child: SuggestionsTodayCard(),
                    ),
                    sectionIndex++,
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === 5. רשימות פעילות ===
                  _staggered(
                    RepaintBoundary(
                      child: _buildActiveListsSection(context, activeLists, cs),
                    ),
                    sectionIndex++,
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === 6. היסטוריה ===
                  _staggered(
                    RepaintBoundary(
                      child: _buildHistorySection(context, sortedReceipts, cs),
                    ),
                    sectionIndex++,
                  ),

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
    final strings = AppStrings.homeDashboard;

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
                  strings.errorTitle,
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
              strings.retryButton,
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
  // 1. HEADER - Glassmorphic + ברכה דינמית לפי שעה
  // ============================================
  Widget _buildHeader(
    BuildContext context, {
    required String? userName,
    required String? familyName,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final userContext = context.watch<UserContext>();
    final notificationsService = context.read<NotificationsService?>();
    final strings = AppStrings.homeDashboard;

    // ברכה דינמית לפי שעה
    final greeting = strings.timeBasedGreeting(
      userName,
      DateTime.now().hour,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kGlassBlurMedium,
          sigmaY: kGlassBlurMedium,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(kBorderRadiusLarge),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Row(
            children: [
              // אייקון/אימוג'י עם Pulse
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: const Text(
                    '👋',
                    style: TextStyle(fontSize: 28),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.08, 1.08),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
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
                stream: (userContext.userId != null && notificationsService != null)
                    ? notificationsService.watchUnreadCount(userId: userContext.userId!)
                    : const Stream.empty(),
                initialData: 0,
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Badge.count(
                      count: unreadCount,
                      isLabelVisible: unreadCount > 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.7),
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
    final strings = AppStrings.homeDashboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת
        Row(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              strings.activeListsTitle,
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
                      strings.noActiveLists,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.createListHint,
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
    final strings = AppStrings.homeDashboard;
    final uncheckedCount = list.items.where((i) => !i.isChecked).length;
    final checkedCount = list.items.where((i) => i.isChecked).length;
    final totalCount = list.items.length;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    // צבע לפי סוג הרשימה (מרכזי ב-ListTypes)
    final typeColor = ListTypes.getColor(list.type, cs, brand);
    final successColor = brand?.success ?? kStickyGreen;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDone = totalCount > 0 && uncheckedCount == 0;
    final accentColor = isDone ? successColor : typeColor;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      clipBehavior: Clip.antiAlias,
      color: cs.surface.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: () {
          unawaited(HapticFeedback.lightImpact());
          Navigator.pushNamed(
            context,
            '/list-details',
            arguments: list,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // פס צבע צד ימין (RTL) / שמאל (LTR)
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: isRtl
                      ? const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                ),
              ),
              // תוכן הכרטיסייה
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingMedium,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // אימוג'י בעיגול צבעוני
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(list.typeEmoji,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: kSpacingMedium),
                      // שם + סטטוס + progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              list.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (totalCount == 0)
                              Text(
                                strings.emptyList,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            else ...[
                              // Progress bar - עבה יותר עם קצוות מעוגלים
                              ClipRRect(
                                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      cs.surfaceContainerHighest,
                                  valueColor:
                                      AlwaysStoppedAnimation(accentColor),
                                  minHeight: kProgressIndicatorHeight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // סטטוס טקסט
                              Row(
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.shopping_bag_outlined,
                                    size: 13,
                                    color: isDone
                                        ? successColor
                                        : cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDone
                                        ? strings.completed
                                        : strings.remainingItems(
                                            uncheckedCount),
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: isDone
                                          ? successColor
                                          : cs.onSurfaceVariant,
                                      fontWeight: isDone
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  const Spacer(),
                                  // ספירה קומפקטית
                                  Text(
                                    '$checkedCount/$totalCount',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      // חץ - RTL aware
                      Icon(
                        isRtl ? Icons.chevron_left : Icons.chevron_right,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final strings = AppStrings.homeDashboard;
    // ✅ FIX: RTL-aware chevron icon
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
              strings.historyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (hasMore)
              TextButton(
                onPressed: () {
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
                      strings.seeAll,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      isRtl ? Icons.chevron_left : Icons.chevron_right,
                      size: 16,
                      color: cs.primary,
                    ),
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
    final strings = AppStrings.homeDashboard;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoppingHistoryScreen(initialReceiptId: receipt.id),
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
              strings.itemsCount(receipt.items.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final strings = AppStrings.homeDashboard;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return strings.today;
    } else if (difference.inDays == 1) {
      return strings.yesterday;
    } else if (difference.inDays < 7) {
      return strings.daysAgo(difference.inDays);
    } else {
      return strings.dateFormat(date.day, date.month, date.year);
    }
  }
}
