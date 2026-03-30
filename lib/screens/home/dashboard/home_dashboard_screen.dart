// 📄 lib/screens/home/dashboard/home_dashboard_screen.dart
//
// מסך הבית - פשוט ונקי:
// 1. Header: ברכה דינמית (בוקר/צהריים/ערב) + שם הבית + התראות
// 2. באנרים (Active Shopper, Pending Invite)
// 3. Quick Actions
// 4. הצעות להיום (≤3 פריטים)
// 5. רשימות פעילות (Cards)
// 6. פיד פעילות הבית
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../config/list_types_config.dart';
import '../../../core/ui_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/shopping_list.dart';
import '../../../providers/receipt_provider.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../../../providers/user_context.dart';
// notifications_service import removed — bell moved to AppBar
import '../../../services/tutorial_service.dart';
import '../../../theme/app_theme.dart';
import '../../settings/household_members_screen.dart';
import '../../../widgets/common/email_verification_banner.dart';
import '../../../widgets/common/notebook_background.dart';
import 'widgets/active_shopper_banner.dart';
import 'widgets/household_activity_feed.dart';
import 'widgets/suggestions_today_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const HomeDashboardScreen({super.key, this.onTabSelected});

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        TutorialService.showHomeTutorialIfNeeded(context);
        setState(() => _hasAnimated = true);
      }
    });
  }

  Future<void> _refresh(BuildContext context) async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);


    final lists = context.read<ShoppingListsProvider>();
    final sugg = context.read<SuggestionsProvider>();
    final receipts = context.read<ReceiptProvider>();

    unawaited(HapticFeedback.mediumImpact());

    try {
      await Future.wait([
        lists.loadLists(),
        receipts.loadReceipts(),
      ]);
    } on Exception catch (_) {
      // Silently handle - data will show cached state
    }

    if (!context.mounted) return;

    try {
      await sugg.refreshSuggestions();
    } on Exception catch (_) {
      // Silently handle - suggestions are non-critical
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (context.mounted) {
      unawaited(HapticFeedback.lightImpact());
    }


    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  /// מחזיר שם הבית להצגה:
  /// 1. בית אישי → "הבית שלי"
  /// 2. householdName קיים → מחזיר אותו
  /// 3. fallback → גוזר מהשם האחרון של המשתמש ("הבית של כהן")
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

    var sectionIndex = 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () {
          unawaited(HapticFeedback.lightImpact());
          Navigator.pushNamed(context, '/create-list');
        },
        tooltip: AppStrings.homeDashboard.newListButton,
        child: Image.asset('assets/images/icon_new_list.webp', width: kSpacingLarge, height: kSpacingLarge),
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(kSpacingMedium),
                children: [
                  // === 1. באנרים (Error / Active Shopper) ===
                  _staggered(
                    Column(
                      children: [
                        if (listsProvider.hasError)
                          _buildErrorBanner(context, listsProvider.errorMessage!),
                        const ActiveShopperBanner(),
                      ],
                    ),
                    sectionIndex++,
                  ),

                  // === 2. ברכה קומפקטית + אימות אימייל ===
                  // === 2. אימות אימייל (אם צריך) ===
                  const EmailVerificationBanner(),

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
                      child: _buildActiveListsSection(context, activeLists),
                    ),
                    sectionIndex++,
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === 6. פיד פעילות הבית ===
                  _staggered(
                    RepaintBoundary(
                      child: HouseholdActivityFeed(
                        onSeeAllHistory: widget.onTabSelected != null
                            ? () => widget.onTabSelected!(2)
                            : null,
                      ),
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
  Widget _buildErrorBanner(BuildContext context, String errorMessage) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final strings = AppStrings.homeDashboard;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: cs.onErrorContainer,
            size: kIconSizeMedium,
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
            icon: Icon(Icons.refresh, color: cs.onErrorContainer, size: kIconSizeSmall),
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
  // 2. COMPACT GREETING — שורת ברכה קומפקטית (avatar עבר ל-AppBar)
  // ============================================
  Widget _buildCompactGreeting(BuildContext context, UserContext userContext, int activeListsCount) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final strings = AppStrings.homeDashboard;
    final userName = userContext.displayName;

    final hour = DateTime.now().hour;
    final greetingAsset = hour < 12
        ? 'assets/images/greeting_morning.webp'
        : hour < 17
            ? 'assets/images/greeting_afternoon.webp'
            : hour < 21
                ? 'assets/images/greeting_evening.webp'
                : 'assets/images/greeting_night.webp';

    return Row(
      children: [
        Image.asset(greetingAsset, width: kIconSizeMedium, height: kIconSizeMedium),
        const SizedBox(width: kSpacingSmall),
        Flexible(
          child: Text(
            strings.timeBasedGreeting(userName, hour),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        if (activeListsCount > 0)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HouseholdMembersScreen()),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.activeListsSubtitle(activeListsCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: kIconSizeSmall,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Bottom sheet עם פרטי המשתמש
  void _showUserInfoSheet(BuildContext context, String? userName, String? familyName) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final userContext = context.read<UserContext>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar גדול — תמונת פרופיל מ-Google או initials
            CircleAvatar(
              radius: 36,
              backgroundColor: cs.primaryContainer,
              backgroundImage: userContext.profileImageUrl != null
                  ? NetworkImage(userContext.profileImageUrl!)
                  : null,
              onBackgroundImageError: userContext.profileImageUrl != null
                  ? (_, _) {} // fallback to child
                  : null,
              child: userContext.profileImageUrl == null
                  ? Text(
                      (userName ?? '?').split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: kSpacingMedium),
            // שם
            Text(
              userName ?? AppStrings.homeDashboard.userFallback,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (familyName != null) ...[
              const SizedBox(height: kSpacingTiny),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: kIconSizeSmall, color: cs.onSurfaceVariant),
                  const SizedBox(width: kSpacingXTiny),
                  Text(familyName, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
            const SizedBox(height: kSpacingSmall),
            // סטטוס
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
                ),
                const SizedBox(width: kSpacingTiny),
                Text(AppStrings.common.connected, style: theme.textTheme.bodySmall?.copyWith(color: cs.primary)),
              ],
            ),
            if (userContext.userEmail != null) ...[
              const SizedBox(height: kSpacingSmall),
              Text(userContext.userEmail!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            const SizedBox(height: kSpacingMedium),
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
  ) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final strings = AppStrings.homeDashboard;

    return Column(
      children: [
        // כותרת — ממורכזת
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icon_active_lists.webp', width: kIconSizeLarge, height: kIconSizeLarge),
            const SizedBox(width: kSpacingSmall),
            Text(
              strings.activeListsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: kSpacingSmall),
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
            color: cs.secondaryContainer.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
              side: BorderSide(
                color: cs.secondary.withValues(alpha: 0.15),
              ),
            ),
            child: InkWell(
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.pushNamed(context, '/create-list');
              },
              borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: kSpacingXLarge, horizontal: kSpacingLarge),
                child: Column(
                  children: [
                    // Illustration
                    Image.asset(
                      'assets/images/empty_cart.webp',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: kSpacingMedium),
                    Text(
                      strings.noActiveLists,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: kSpacingTiny),
                    Text(
                      strings.createListHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kSpacingMedium),
                    // CTA button
                    FilledButton.icon(
                      onPressed: () {
                        unawaited(HapticFeedback.mediumImpact());
                        Navigator.pushNamed(context, '/create-list');
                      },
                      icon: const Icon(Icons.add),
                      label: Text(strings.createFirstList),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...activeLists.map((list) => _buildListCard(context, list)),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, ShoppingList list) {
    final cs = Theme.of(context).colorScheme;
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
        borderRadius: BorderRadius.circular(kBorderRadius),
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
        borderRadius: BorderRadius.circular(kBorderRadius),
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
                          topRight: Radius.circular(kBorderRadius),
                          bottomRight: Radius.circular(kBorderRadius),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(kBorderRadius),
                          bottomLeft: Radius.circular(kBorderRadius),
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
                      // Material Icon בעיגול צבעוני — Hero animation to details
                      Hero(
                        tag: 'list_hero_${list.id}',
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              ListTypes.getByKeySafe(list.type).icon,
                              color: accentColor,
                              size: kIconSizeMedium,
                            ),
                          ),
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
                            const SizedBox(height: kSpacingTiny),
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
                              const SizedBox(height: kSpacingXTiny),
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
                                  const SizedBox(width: kSpacingXTiny),
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
                        size: kIconSizeSmallPlus,
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

}
