// lib/screens/home/dashboard/home_dashboard_screen.dart — Home dashboard — error banner, active-shopper banner, pending actions, action center, active lists, onboarding tips

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
import '../../../services/tutorial_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/list_type_icon.dart';
import '../../../widgets/common/notebook_background.dart';
import 'widgets/action_center_card.dart';
import 'widgets/active_shopper_banner.dart';
import 'widgets/onboarding_tips_card.dart';
import 'widgets/pending_actions_card.dart';

// Layout tokens specific to the active-list card.
// Avatar grew 44→72 so the paper-cut sticker reads as the card's hero
// element instead of a small icon competing with the progress ring.
const double _kAvatarSize = 72.0;
const double _kStickerSize = 60.0;
const double _kProgressStrokeWidth = 4.0;
// Home dashboard shows only the top-N most recent active lists. Beyond
// that the user sees a "See all" button that pushes a dedicated full-
// list screen — 20+ hero cards on the dashboard read as wall-of-noise
// per Apr-30 review.
const int _kDashboardActiveListLimit = 5;
const double _kListAccentBarWidth = 5.0;
// List card vertical padding — kSpacingSmallPlus (12) leaves the card
// feeling tight against the icon row, kSpacingMedium (16) over-spaces
// it. 14 is the in-between that reads as "comfortable but compact"; the
// previous `kSpacingSmallPlus + 2` hid the magic value behind addition.
const double _kListCardVerticalPadding = 14.0;
// Refresh indicator grace period: after the data load future resolves,
// we wait this long before dismissing the pull-to-refresh animation so
// the user perceives the refresh as a deliberate operation rather than
// an instantaneous flash. Felt-too-fast UX was the original complaint.
const Duration _kRefreshAnimationGrace = Duration(milliseconds: 300);
// Tight gap between the error banner's title and message — full
// kSpacingXTiny (4) reads as a paragraph break, this stays as a
// title/subtitle pair. Literal instead of `kSpacingXTiny / 2` since
// dividing a token by 2 hides the intent.
const double _kErrorTitleGap = 2.0;

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

    await Future.delayed(_kRefreshAnimationGrace);

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

    return Scaffold(
      backgroundColor: Colors.transparent,
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

                  // === 1. באנרים שגיאה + Active Shopper (real-time) ===
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

                  // === 2. פעולות ממתינות — כרטיס יחיד מאחד 3 באנרים שהיו פה: ===
                  //   - הזמנות נכנסות (היה PendingInvitesBanner)
                  //   - אימות אימייל (היה EmailVerificationBanner)
                  //   - הזמן את הבית (היה _buildInviteFamilyBanner)
                  _staggered(
                    const RepaintBoundary(child: PendingActionsCard()),
                    sectionIndex++,
                  ),

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

                  // === רשימות פעילות ===
                  // 🔄 פאזה 2: כרטיס "הצעות להיום" הוסר — חוסרי המזווה נכנסים
                  //    לרשימה הפעילה אוטומטית (LIVE_LIST_SPEC §3), בלי כרטיס נפרד.
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
                  ),

                  // === "מה לבשל הערב?" — מוסתר אחרי המיקוד-לסופר (PRODUCT_DIRECTION §6).
                  // הקוד נשמר ב-widgets/whats_for_dinner_card.dart (הפיך). להחזרה:
                  // להחזיר את ה-import למעלה + _staggered(WhatsForDinnerCard()) כאן.

                  // 🔄 פאזה 3: ה-FAB הוסר — אין צורך ב-clearance תחתון מוגדל.
                  const SizedBox(height: kSpacingMedium),
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
                const SizedBox(height: _kErrorTitleGap),
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
    final isSingle = activeLists.length == 1;

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
                  // 🔄 פאזה 6: רשימה אחת = כותרת יחיד בלי מונה ("הרשימה הפעילה"),
                  // במודל "רשימה אחת חיה" המונה "1" מיותר ומוזר בעברית.
                  isSingle ? strings.singleActiveListTitle : strings.activeListsTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (!isSingle) ...[
                  const SizedBox(width: kSpacingXTiny),
                  Text(
                    '${activeLists.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: kSpacingSmall),

        // רשימות פעילות — 🔄 פאזה 3: auto-ensure מבטיח שתמיד יש לפחות אחת,
        // אז מצב ה-empty ("צור רשימה ראשונה") הוסר.
        // Show only the top-N most recent lists; the rest live in the
        // dedicated `/all-lists` screen behind a "See all" button.
        ...activeLists
            .take(_kDashboardActiveListLimit)
            .map((list) => _buildListCard(context, list)),
        if (activeLists.length > _kDashboardActiveListLimit)
          _buildSeeAllButton(context, activeLists.length),
      ],
    );
  }

  /// "ראה הכל (N)" button at the bottom of the active-lists preview.
  /// Pushes the full `ShoppingListsScreen` which has search/filter/sort
  /// for users juggling many lists.
  Widget _buildSeeAllButton(BuildContext context, int totalCount) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.homeDashboard;
    return Padding(
      padding: const EdgeInsets.only(top: kSpacingSmall),
      child: TextButton.icon(
        onPressed: () {
          unawaited(HapticFeedback.lightImpact());
          Navigator.pushNamed(context, '/all-lists');
        },
        icon: Icon(Icons.arrow_back_ios_new, size: kIconSizeSmall, color: cs.primary),
        label: Text(
          '${strings.seeAll} ($totalCount)',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
        ),
      ),
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
      // Subtle type-tinted surface — 5% of the list-type color blended
      // over the translucent surface gives the card a quiet "this is
      // a green/orange/etc. list" personality without becoming loud.
      // Previously the card was pure surface, which read as a neutral
      // table row next to the colorful sticky notes elsewhere on screen.
      color: Color.alphaBlend(
        accentColor.withValues(alpha: 0.05),
        cs.surface.withValues(alpha: kOpacityStrong),
      ),
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
                    vertical: _kListCardVerticalPadding,
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
                                  // Background ring bumped from kOpacitySoft
                                  // (0.15) to kOpacityLight (0.3) — at 0%
                                  // progress the ring was nearly invisible,
                                  // making fresh lists look "ringless"
                                  // rather than "ready to start".
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: _kProgressStrokeWidth,
                                    backgroundColor: accentColor.withValues(alpha: kOpacityLight),
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
                              // Sticker is now hero-sized (60px in a 72px
                              // avatar = 83%). The paper-cut details
                              // become readable instead of reading as a
                              // pastel blob inside the progress ring.
                              ListTypeIcon(
                                typeKey: list.type,
                                size: _kStickerSize,
                                fallbackColor: accentColor,
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
                              // 🔄 פאזה 6: רשימה ריקה במודל "רשימה אחת חיה"
                              // = הכל נקנה. במקום CTA "מת" ("הוסף פריטים"),
                              // מסר חגיגי שמסביר שהמזווה ימלא אוטומטית את מה
                              // שייגמר — המשתמש מבין שהריק זמני ומכוון.
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: kFontSizeSmall,
                                        color: successColor,
                                      ),
                                      const SizedBox(width: kSpacingXTiny),
                                      Text(
                                        strings.emptyListAllBought,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: successColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: kSpacingXTiny),
                                  Text(
                                    strings.emptyListAutoFillHint,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
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
