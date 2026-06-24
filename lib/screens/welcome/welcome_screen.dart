// lib/screens/welcome/welcome_screen.dart — Welcome screen — onboarding carousel with auto-play, shown only before first login

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_wordmark.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';

const int _kOnboardingPages = 3;
const Duration _kAutoPlayInterval = Duration(seconds: 4);
const Duration _kPageTransition = Duration(milliseconds: 600);
const double _kParallaxIntensity = 30.0;
const double _kDotRadius = 4.0;
const double _kDotSpacing = 18.0;
const double _kDotIndicatorHeight = 10.0;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  // ValueNotifier instead of plain double + setState: scrolling fires
  // ~60 frames/sec, and rebuilding the whole screen on every frame is
  // wasteful when only the parallax background and the worm dots
  // actually depend on the offset. Both widgets subscribe directly.
  final _pageOffset = ValueNotifier<double>(0.0);
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  // Auto-play is a gentle "here's what we offer" loop — but the moment
  // the user takes control (a manual swipe) it stops for good, so the
  // carousel never "runs away" from someone reading at their own pace.
  bool _autoPlayActive = true;
  // animateToPage also fires onPageChanged; this flag lets us tell our
  // own auto-advance apart from a genuine user swipe.
  bool _isAutoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _startAutoPlay();
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      _pageOffset.value = _pageController.page ?? 0.0;
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _pageOffset.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_kAutoPlayInterval, (_) {
      if (!_pageController.hasClients) return;
      // One-time gentle tour: advance forward and stop at the last page.
      // Looping with a modulo wrap would animate a jarring backward sweep
      // across every page on each cycle.
      if (_currentPage >= _kOnboardingPages - 1) {
        _autoPlayActive = false;
        _autoPlayTimer?.cancel();
        return;
      }
      _isAutoAdvancing = true;
      _pageController
          .animateToPage(
            _currentPage + 1,
            duration: _kPageTransition,
            curve: Curves.easeInOutCubic,
          )
          .whenComplete(() => _isAutoAdvancing = false);
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    // A genuine user swipe (not our own auto-advance) stops the loop for
    // good — the user is now in control.
    if (!_isAutoAdvancing && _autoPlayActive) {
      _autoPlayActive = false;
      _autoPlayTimer?.cancel();
    }
  }

  void _handleLogin() {
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/login');
  }

  void _handleRegister() {
    unawaited(HapticFeedback.mediumImpact());
    Navigator.pushNamed(context, '/register');
  }

  void _handleLegalLink(VoidCallback onTap) {
    unawaited(HapticFeedback.selectionClick());
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // PageView already honours Directionality (RTL → page 1 on the right,
    // advancing right-to-left), so we must NOT pass reverse — that would
    // double-flip it back to LTR. The worm dots and parallax below are
    // hand-drawn (canvas/Transform don't auto-flip), so they keep their
    // own isRtl handling and now stay consistent with the page direction.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // Parallax: background moves at 30px per page-step. Scoped
          // ValueListenableBuilder keeps the rest of the tree static.
          // Direction follows the carousel's reverse setting — without
          // the isRtl flip, the background moves *with* the swipe in
          // RTL instead of against it, and the parallax illusion dies.
          ValueListenableBuilder<double>(
            valueListenable: _pageOffset,
            builder: (_, offset, child) => Transform.translate(
              offset: Offset(
                offset * _kParallaxIntensity * (isRtl ? -1 : 1),
                0,
              ),
              child: child,
            ),
            child: const NotebookBackground.subtle(),
          ),

          // === Content — single Column, no overlap ===
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // === Logo ===
                _LogoSection(screenHeight: screenHeight)
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),

                // === Carousel ===
                Expanded(
                  child: Semantics(
                    label: AppStrings.welcome.carouselLabel,
                    child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _SimpleFeatureCard(
                        illustrationAsset: 'assets/images/onboarding_pantry.webp',
                        title: AppStrings.welcome.group1Title,
                        description: AppStrings.welcome.group1Question,
                      ),
                      _SimpleFeatureCard(
                        illustrationAsset: 'assets/images/onboarding_shopping.webp',
                        title: AppStrings.welcome.group2Title,
                        description: AppStrings.welcome.group2Question,
                      ),
                      _SimpleFeatureCard(
                        illustrationAsset: 'assets/images/onboarding_sharing.webp',
                        title: AppStrings.welcome.group3Title,
                        description: AppStrings.welcome.group3Question,
                      ),
                    ],
                  ),
                  ),
                ),

                // === Dots (worm effect) ===
                ValueListenableBuilder<double>(
                  valueListenable: _pageOffset,
                  builder: (_, offset, _) => _WormDotIndicator(
                    count: _kOnboardingPages,
                    pageOffset: offset,
                    activeColor: cs.primary,
                    inactiveColor: cs.outlineVariant,
                  ),
                ),
                const SizedBox(height: kSpacingSmall),

                // === Bottom Section: Benefits + CTA + Legal ===
                _BottomSection(
                  bottomPadding: bottomPadding,
                  onRegister: _handleRegister,
                  onLogin: _handleLogin,
                  onTerms: () => _handleLegalLink(() => showTermsOfServiceDialog(context)),
                  onPrivacy: () => _handleLegalLink(() => showPrivacyPolicyDialog(context)),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.2, duration: 400.ms, delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Logo Section
// ============================================================

class _LogoSection extends StatelessWidget {
  final double screenHeight;

  const _LogoSection({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      header: true,
      label: AppStrings.welcome.logoLabel,
      child: Padding(
        padding: const EdgeInsets.only(top: kSpacingXLarge, bottom: kSpacingSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔷 מסגרת-אריח עדינה מאחורי הלוגו: מרימה את ה"פתק" הקרם מעל
            // הרקע הבהיר (ניגודיות) ונותנת תחושת app-icon מכוונת.
            // שינוי ויזואלי — לבדוק על המכשיר; להסרה: להחזיר את ה-Image בלבד.
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(kBorderRadiusXLarge),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: kOpacitySubtle),
                    blurRadius: kSpacingSmallPlus,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.08,
                fit: BoxFit.contain,
                // Source is 1533×1533 but renders at ~64px. Without
                // cacheWidth the full bitmap (~9MB decoded) sits in memory
                // for a thumbnail — decode to a fraction instead.
                cacheWidth: 256,
                errorBuilder: (_, _, _) => Icon(
                  Icons.shopping_basket_rounded,
                  size: screenHeight * 0.08,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: kSpacingXTiny),
            const AppWordmark(),
            const SizedBox(height: kSpacingXTiny),
            Text(
              AppStrings.welcome.subtitle,
              textAlign: TextAlign.center,
              // tagline רך ושקט (קול משני) — כדי שכותרת השקופית למטה תהיה
              // הכותרת הברורה היחידה, בלי שתיהן מתחרות בולד-על-בולד.
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Simple Feature Card
// ============================================================

class _SimpleFeatureCard extends StatelessWidget {
  final String illustrationAsset;
  final String title;
  final String description;

  const _SimpleFeatureCard({
    required this.illustrationAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration takes the lion's share; title + description sit
          // below at their natural height.
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              child: ExcludeSemantics(
                child: Image.asset(
                  illustrationAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: kIconSizeXLarge,
                      color: cs.onSurface.withValues(alpha: kOpacityLight),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Title + Description — always visible
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    // 0.87 = Material "high-emphasis" text opacity. titleLarge
                    // only carries the font family here; size/weight are
                    // overridden deliberately for the carousel headline.
                    color: cs.onSurface.withValues(alpha: 0.87),
                    fontWeight: FontWeight.w800,
                    fontSize: kFontSizeTitle,
                  ),
                ),
                ),
                const SizedBox(height: kSpacingTiny),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: kOpacityMedium),
                      fontSize: kFontSizeBody,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Dot Indicator
// ============================================================

class _WormDotIndicator extends StatelessWidget {
  final int count;
  final double pageOffset;
  final Color activeColor;
  final Color inactiveColor;

  const _WormDotIndicator({
    required this.count,
    required this.pageOffset,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: _kDotIndicatorHeight,
      // Repaints on every scroll frame (~60fps); isolate it so the worm
      // doesn't mark the surrounding column dirty.
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(count * _kDotSpacing, _kDotIndicatorHeight),
          painter: _WormPainter(
            count: count,
            pageOffset: isRtl ? (count - 1 - pageOffset) : pageOffset,
            activeColor: activeColor,
            inactiveColor: inactiveColor.withValues(alpha: kOpacityLight),
          ),
        ),
      ),
    );
  }
}

class _WormPainter extends CustomPainter {
  final int count;
  final double pageOffset;
  final Color activeColor;
  final Color inactiveColor;

  _WormPainter({
    required this.count,
    required this.pageOffset,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = (size.width - (count - 1) * _kDotSpacing) / 2;
    final y = size.height / 2;

    // Draw inactive dots
    final inactivePaint = Paint()..color = inactiveColor;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(startX + i * _kDotSpacing, y),
        _kDotRadius,
        inactivePaint,
      );
    }

    // Draw active "worm" that stretches between dots
    final activePaint = Paint()..color = activeColor;
    final currentIndex = pageOffset.floor().clamp(0, count - 1);
    final nextIndex = (currentIndex + 1).clamp(0, count - 1);
    final progress = pageOffset - currentIndex;

    final fromX = startX + currentIndex * _kDotSpacing;
    final toX = startX + nextIndex * _kDotSpacing;

    // Worm: stretches from current to next based on progress.
    // lerpDouble comes from dart:ui.
    final wormLeft = lerpDouble(fromX, toX, (progress * 2).clamp(0, 1))! - _kDotRadius;
    final wormRight = lerpDouble(fromX, toX, ((progress - 0.5) * 2).clamp(0, 1))! + _kDotRadius;

    canvas.drawRRect(
      RRect.fromLTRBR(
        wormLeft < wormRight ? wormLeft : wormRight,
        y - _kDotRadius,
        wormLeft < wormRight ? wormRight : wormLeft,
        y + _kDotRadius,
        const Radius.circular(_kDotRadius),
      ),
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WormPainter old) =>
      pageOffset != old.pageOffset ||
      activeColor != old.activeColor ||
      inactiveColor != old.inactiveColor ||
      count != old.count;
}

// ============================================================
// Bottom Section (Benefits + CTA + Legal — unified)
// ============================================================

class _BottomSection extends StatelessWidget {
  final double bottomPadding;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _BottomSection({
    required this.bottomPadding,
    required this.onRegister,
    required this.onLogin,
    required this.onTerms,
    required this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final bgColor = brand?.paperBackground ?? kPaperBackground;
    // כחול-מותג קבוע (לא cs.primary שנודד עם Material You לפי הטפט) —
    // לוורדמרק, ל-trust chips ולקישור, כך שכל הכחולים יהיו אחד עקבי.
    final brandBlue = brand?.notebookBlue ?? cs.primary;
    // "Forward / proceed" arrow flips with locale: arrow_back points left
    // = forward in Hebrew RTL, arrow_forward (right) in English LTR. Same
    // convention as onboarding_tips_card / pending_actions_card.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Solid paper panel. At ~92% opacity the old BackdropFilter blur was
    // barely visible yet cost a GPU pass every frame — an opaque panel
    // reads identically and is lighter. (Removed ClipRRect + blur.)
    return Container(
          padding: EdgeInsets.only(
            left: kSpacingMedium,
            right: kSpacingMedium,
            top: kSpacingMedium,
            bottom: bottomPadding + kSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: kOpacitySubtle),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: kSpacingMedium,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === Benefits — compact, staggered entrance ===
              _BenefitChip(
                icon: FontAwesomeIcons.gift,
                text: AppStrings.welcome.benefit1Title,
                color: brandBlue,
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms)
               .slideX(begin: 0.2, duration: 300.ms, delay: 400.ms),
              const SizedBox(height: kSpacingSmall),
              _BenefitChip(
                icon: FontAwesomeIcons.shieldHalved,
                text: AppStrings.welcome.benefit2Title,
                color: brandBlue,
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms)
               .slideX(begin: 0.2, duration: 300.ms, delay: 500.ms),
              const SizedBox(height: kSpacingSmall),
              _BenefitChip(
                icon: FontAwesomeIcons.bolt,
                text: AppStrings.welcome.benefit3Title,
                color: brandBlue,
              ).animate().fadeIn(duration: 300.ms, delay: 600.ms)
               .slideX(begin: 0.2, duration: 300.ms, delay: 600.ms),

              const SizedBox(height: kSpacingMedium),

              // === Register button with colored shadow ===
              Container(
                width: double.infinity,
                height: kButtonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  boxShadow: [
                    // Colored "lifted" glow under the primary CTA — the
                    // 0.35 alpha + soft offset make the green button feel
                    // raised off the paper. Tuned values, not tokens.
                    BoxShadow(
                      color: (brand?.success ?? cs.primary).withValues(alpha: 0.35),
                      blurRadius: kSpacingMedium,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: onRegister,
                  icon: Icon(
                    isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    AppStrings.welcome.startButton,
                    style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    // Use the brand's green (success) instead of cs.primary
                    // which can shift to blue/purple on Material You devices.
                    backgroundColor: brand?.success ?? cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: kSpacingSmall),

              // === Login text link ===
              TextButton(
                onPressed: onLogin,
                style: TextButton.styleFrom(
                  minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                ),
                child: Text(
                  AppStrings.welcome.loginLink,
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: brandBlue,
                  ),
                ),
              ),

              // === Legal links ===
              // Deliberate "fine print" de-emphasis: 0.45 keeps the links
              // legible but quiet, 0.25 fades the separator further. These
              // sit between kOpacityLight/Medium, hence raw values.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onTerms,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                      minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                    ),
                    child: Text(
                      AppStrings.welcome.termsOfService,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    '|',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.25), fontSize: kFontSizeSmall),
                  ),
                  TextButton(
                    onPressed: onPrivacy,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                      minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                    ),
                    child: Text(
                      AppStrings.welcome.privacyPolicy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }
}

// ============================================================
// Benefit Chip (compact — icon + text in one line)
// ============================================================

class _BenefitChip extends StatelessWidget {
  final FaIconData icon;
  final String text;
  final Color color;

  const _BenefitChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // The Text already provides the semantic label; the icon is pure
    // decoration → ExcludeSemantics avoids a duplicate/garbled announcement.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: FaIcon(icon, size: kIconSizeSmallPlus, color: color.withValues(alpha: kOpacityStrong)),
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          text,
          style: TextStyle(
            fontSize: kFontSizeMedium,
            color: cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
