// lib/screens/home/dashboard/home_dashboard_screen.dart — Home dashboard — active shopping banner, action center, lists, activity feed

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
import '../../../services/tutorial_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/email_verification_banner.dart';
import '../../../widgets/common/household_invite_dialog.dart';
import '../../../widgets/common/notebook_background.dart';
import 'widgets/action_center_card.dart';
import 'widgets/active_shopper_banner.dart';
import 'widgets/household_activity_feed.dart';
import 'widgets/onboarding_tips_card.dart';
import 'widgets/pending_invites_banner.dart';
import 'widgets/suggestions_today_card.dart';

// Layout tokens specific to the active-list card.
const double _kAvatarSize = 44.0;
const double _kProgressStrokeWidth = 3.0;
const double _kListAccentBarWidth = 5.0;
// Empty-state illustration size — keeps a stable footprint even when
// the asset fails to decode and the errorBuilder swaps in a fallback icon.
const double _kEmptyStateImageHeight = 100.0;

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

    // The stagger animation runs from postFrame for ~600ms (5 sections
    // × 50ms delay + 400ms duration). Showing the tutorial on top of
    // the slide-in dance feels chaotic. Flip _hasAnimated immediately
    // so the next build reads as "already animated" once the first
    // pass paints, but defer the tutorial dialog until after the
    // stagger finishes. Mount check guards against navigating away
    // during the wait.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _hasAnimated = true);
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        TutorialService.showHomeTutorialIfNeeded(context);
      }
    });
  }

  Future<void> _refresh(BuildContext context) async {
    if (_isRefreshing) return;

    // _isRefreshing isn't read in build() — only used as a re-entry
    // guard inside this method. No setState needed; the state change
    // shouldn't trigger a rebuild.
    _isRefreshing = true;

    // Cache the messenger before the await chain — using Scaffold.of()
    // post-await is unsafe if the user navigates away mid-refresh.
    final messenger = ScaffoldMessenger.of(context);
    final lists = context.read<ShoppingListsProvider>();
    final sugg = context.read<SuggestionsProvider>();
    final receipts = context.read<ReceiptProvider>();

    unawaited(HapticFeedback.mediumImpact());

    var hadError = false;
    try {
      await Future.wait([
        lists.loadLists(),
        receipts.loadReceipts(),
      ]);
    } on Exception catch (_) {
      hadError = true;
    }

    if (!context.mounted) return;

    try {
      await sugg.refreshSuggestions();
    } on Exception catch (_) {
      // Suggestions are non-critical — they don't bump the error flag.
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!context.mounted) return;

    unawaited(HapticFeedback.lightImpact());

    // Tell the user we couldn't refresh; UI is showing cached data.
    // Clear any prior SnackBar first so refresh feedback doesn't stack
    // on top of an unrelated message.
    if (hadError) {
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.homeDashboard.refreshOfflineMessage),
          duration: kSnackBarDuration,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _isRefreshing = false;
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // רשימות פעילות בלבד, ממוינות לפי עדכון אחרון (חדש קודם)
    final activeLists = listsProvider.lists
        .where((l) => l.status == ShoppingList.statusActive)
        .toList()
      ..sort((a, b) => b.updatedDate.compareTo(a.updatedDate));

    var sectionIndex = 0;

    // Empty state already shows a prominent "Create first list" CTA in
    // the active-lists card — duplicating it as a FAB clutters the
    // screen. Hide the FAB until the user has at least one list.
    final showFab = activeLists.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              heroTag: 'home_fab',
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.pushNamed(context, '/create-list');
              },
              tooltip: AppStrings.homeDashboard.newListButton,
              icon: Image.asset(
                'assets/images/icon_new_list.webp',
                width: kIconSizeMedium,
                height: kIconSizeMedium,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.add, size: kIconSizeMedium),
              ),
              label: Text(AppStrings.homeDashboard.newListButton),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  delay: 300.ms,
                  curve: Curves.elasticOut,
                )
          : null,
      body: Stack(
        children: [
          const NotebookBackground(),
          SafeArea(
            child: RefreshIndicator(
              color: brand?.accent ?? cs.primary,
              backgroundColor:
                  brand?.paperBackground ?? theme.scaffoldBackgroundColor,
              strokeWidth: 4.0,
              displacement: 50.0,
              onRefresh: () => _refresh(context),
              child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(kSpacingMedium),
                children: [
                  // (Offline banner is mounted once at main_navigation_screen
                  // so it covers all four tabs without stacking copies.)

                  // === 1. באנרים (Error / Active Shopper / Pending Invites) ===
                  _staggered(
                    Column(
                      children: [
                        if (listsProvider.hasError)
                          _buildErrorBanner(context, listsProvider.errorMessage!),
                        const ActiveShopperBanner(),
                        const PendingInvitesBanner(),
                      ],
                    ),
                    sectionIndex++,
                  ),

                  // === 2. אימות אימייל (אם צריך) ===
                  const EmailVerificationBanner(),

                  // === 2.5. הזמנת משפחה (solo households only) ===
                  _buildInviteFamilyBanner(context),

                  // === 3. Action Center — דורש טיפול (דחוף → למעלה) ===
                  _staggered(
                    RepaintBoundary(
                      child: ActionCenterCard(
                        onNavigateToList: (list) {
                          Navigator.pushNamed(context, '/list-details', arguments: list);
                        },
                        onNavigateToPantry: widget.onTabSelected != null
                            ? () => widget.onTabSelected!(1)
                            : null,
                      ),
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
                      child: _buildActiveListsSection(context, activeLists),
                    ),
                    sectionIndex++,
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // === 5.5. טיפים למשתמש חדש (נעלם אוטומטית) ===
                  // The card supplies its own bottom padding when it has
                  // tips to show, and a full SizedBox.shrink when it
                  // doesn't — no trailing gap when there's nothing to see.
                  OnboardingTipsCard(
                    onNavigateToPantry: widget.onTabSelected != null
                        ? () => widget.onTabSelected!(1)
                        : null,
                    onNavigateToCreateList: () => Navigator.pushNamed(context, '/create-list'),
                  ),

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

                  // FAB clearance (only when FAB is showing)
                  SizedBox(height: showFab ? kIconSizeXLarge + kSpacingXLarge : kSpacingMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 0.5. INVITE FAMILY BANNER — shown for solo households
  // ============================================
  Widget _buildInviteFamilyBanner(BuildContext context) {
    final userContext = context.watch<UserContext>();
    // Trust the explicit `isSolo` flag from the user document. The old
    // fallback that sniffed Hebrew/English substrings of householdName
    // ('של', 'Home') broke as soon as the user switched UI language and
    // wasn't reliable across naming choices anyway. If isSolo is null
    // (legacy users on older docs) the banner stays hidden — better to
    // miss a one-off banner than mis-classify a real household as solo.
    final isSolo = userContext.user?.isSolo ?? false;

    if (!isSolo) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmallPlus),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (brand?.stickyCyan ?? kStickyCyan).withValues(alpha: kOpacitySoft),
            (brand?.stickyCyan ?? kStickyCyan).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        border: Border.all(color: (brand?.stickyCyan ?? kStickyCyan).withValues(alpha: kOpacityLight)),
      ),
      child: Row(
        children: [
          // Plain house emoji — the previous family ZWJ sequence
          // (👨‍👩‍👧‍👦) renders as an empty box on older Android builds.
          // Decorative only — screen readers should jump straight to
          // the title text, not announce "house".
          const ExcludeSemantics(
            child: Text('🏠', style: TextStyle(fontSize: kFontSizeLarge)),
          ),
          const SizedBox(width: kSpacingSmallPlus),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeDashboard.inviteFamilyTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                Text(
                  AppStrings.homeDashboard.inviteFamilySubtitle,
                  style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              showHouseholdInviteDialog(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: brand?.stickyCyan ?? kStickyCyan,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus),
              minimumSize: const Size(0, kMinTapTarget),
            ),
            child: Text(AppStrings.homeDashboard.inviteFamilyAction),
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
        border: Border.all(color: cs.error.withValues(alpha: kOpacityLight)),
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
                const SizedBox(height: kSpacingXTiny / 2),
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
        // כותרת — ממורכזת, עם רקע paper לקריאות על קווי מחברת.
        // Marked as a Semantics header so screen readers announce
        // "active lists, 5" as a section break, not just inline text.
        Semantics(
          header: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingXTiny),
            decoration: BoxDecoration(
              color: theme.extension<AppBrand>()?.paperBackground.withValues(alpha: kOpacityHigh),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: kIconSizeSmallPlus, color: cs.onSurfaceVariant),
                const SizedBox(width: kSpacingSmall),
                Text(
                  strings.activeListsTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: kSpacingXTiny),
                Text(
                  '${activeLists.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // רשימה או הודעה
        if (activeLists.isEmpty)
          Card(
            elevation: 0,
            color: cs.secondaryContainer.withValues(alpha: kOpacityLow),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
              side: BorderSide(
                color: cs.secondary.withValues(alpha: kOpacitySoft),
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
                    // Illustration — falls back to a Material icon if the
                    // asset is missing so the empty-state still reads.
                    Image.asset(
                      'assets/images/empty_cart.webp',
                      height: _kEmptyStateImageHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.shopping_cart_outlined,
                        size: _kEmptyStateImageHeight,
                        color: cs.onSurfaceVariant.withValues(alpha: kOpacityMedium),
                      ),
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
    // Single-pass count instead of two `where().length` scans — saves
    // an extra O(n) walk per card per rebuild. Matters once the user
    // has multiple lists with many items each.
    var checkedCount = 0;
    final totalCount = list.items.length;
    for (final item in list.items) {
      if (item.isChecked) checkedCount++;
    }
    final uncheckedCount = totalCount - checkedCount;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    // צבע לפי סוג הרשימה (מרכזי ב-ListTypes)
    final typeColor = ListTypes.getColor(list.type, cs, brand);
    final successColor = brand?.success ?? kStickyGreen;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDone = totalCount > 0 && uncheckedCount == 0;
    final accentColor = isDone ? successColor : typeColor;

    // Compose a screen-reader label that matches what a sighted user
    // takes in at a glance: list name + progress + done flag. Without
    // this, TalkBack/VoiceOver reads the inner Text widgets piecemeal
    // ("4", "/", "12") with no indication this is a tappable card.
    final semanticLabel = isDone
        ? '${list.name}, ${strings.completed}'
        : totalCount == 0
            ? '${list.name}, ${strings.emptyList}'
            : '${list.name}, $checkedCount / $totalCount';

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      clipBehavior: Clip.antiAlias,
      color: cs.surface.withValues(alpha: kOpacityStrong),
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
                width: _kListAccentBarWidth,
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
                    vertical: kSpacingSmallPlus + 2,
                  ),
                  child: Row(
                    children: [
                      // Material Icon בעיגול צבעוני — Hero animation to details
                      // Progress ring wraps the icon so users can see
                      // completion at a glance without reading the counter.
                      Hero(
                        tag: 'list_hero_${list.id}',
                        child: SizedBox(
                          width: _kAvatarSize,
                          height: _kAvatarSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (totalCount > 0)
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: _kProgressStrokeWidth,
                                    backgroundColor: accentColor.withValues(alpha: kOpacitySoft),
                                    valueColor: AlwaysStoppedAnimation(accentColor),
                                  ),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: kOpacitySoft),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Icon(
                                ListTypes.getByKeySafe(list.type).icon,
                                color: accentColor,
                                size: kIconSizeMedium,
                              ),
                            ],
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: kSpacingTiny),
                            if (totalCount == 0)
                              // Inviting CTA instead of dead-end "Empty
                              // list". The card itself is tappable, so
                              // this nudges the user to use that.
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: kFontSizeSmall,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: kSpacingXTiny),
                                  Text(
                                    strings.emptyListCta,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                              // ספירה קומפקטית
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
                                        : '$checkedCount/$totalCount',
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
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      // חץ - RTL aware. Dropped the alpha 0.5 dimming —
                      // on light backgrounds it bleached the chevron to
                      // the point of invisibility. cs.onSurfaceVariant
                      // is already a softer-than-onSurface tone.
                      Icon(
                        isRtl ? Icons.chevron_left : Icons.chevron_right,
                        color: cs.onSurfaceVariant,
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
      ),
    );
  }

}
