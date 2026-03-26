// 📄 lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים — Clean onboarding with logo, carousel, benefits
//
// 📋 Design:
// - רקע מחברת עדין (NotebookBackground.subtle)
// - Logo image + subtitle
// - Carousel פשוט — illustration + title + description
// - Benefits + CTA בתחתית (unified bottom section)
//
// 🔗 Related: ui_constants.dart, app_theme.dart, NotebookBackground

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';

// Updated automatically — change this string to verify new builds.
const _kBuildTimestamp = '2026-03-23 23:45 ✅ Patch Test OK';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _startAutoPlay();
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      setState(() => _pageOffset = _pageController.page ?? 0.0);
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onUserSwipe(int index) {
    setState(() => _currentPage = index);
    _startAutoPlay();
  }

  void _handleLogin() {
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/login');
  }

  void _handleRegister() {
    unawaited(HapticFeedback.mediumImpact());
    Navigator.pushNamed(context, '/register');
  }

  void _handleLegalLink(VoidCallback showDialog) {
    unawaited(HapticFeedback.selectionClick());
    showDialog();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // Parallax: background moves at 30% of carousel speed
          Transform.translate(
            offset: Offset(_pageOffset * 30, 0),
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
                    .slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOut),

                // === Carousel ===
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    reverse: true,
                    onPageChanged: _onUserSwipe,
                    children: [
                      _SimpleFeatureCard(
                        illustrationAsset: 'assets/images/onboarding_shopping.webp',
                        title: AppStrings.welcome.group1Title,
                        description: AppStrings.welcome.group1Question,
                      ),
                      _SimpleFeatureCard(
                        illustrationAsset: 'assets/images/onboarding_pantry.webp',
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

                // === Dots (worm effect) ===
                _WormDotIndicator(
                  count: 3,
                  pageOffset: _pageOffset,
                  activeColor: cs.primary,
                  inactiveColor: cs.outlineVariant,
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
                    .slideY(begin: 0.15, duration: 400.ms, delay: 300.ms),
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
            Image.asset(
              'assets/images/logo.png',
              height: screenHeight * 0.08,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: kSpacingXTiny),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: kFontSizeDisplay,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: kSpacingXTiny),
            Text(
              AppStrings.welcome.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
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
          // Illustration — flex 2, text flex 1
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              child: ExcludeSemantics(
                child: Image.asset(
                  illustrationAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Title + Description — always visible
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.87),
                    fontWeight: FontWeight.w800,
                    fontSize: kFontSizeTitle,
                  ),
                ),
                const SizedBox(height: kSpacingTiny),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
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
      height: 10,
      child: CustomPaint(
        size: Size(count * 18.0, 10),
        painter: _WormPainter(
          count: count,
          pageOffset: isRtl ? (count - 1 - pageOffset) : pageOffset,
          activeColor: activeColor,
          inactiveColor: inactiveColor.withValues(alpha: 0.35),
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
    const dotRadius = 4.0;
    const spacing = 18.0;
    final startX = (size.width - (count - 1) * spacing) / 2;
    final y = size.height / 2;

    // Draw inactive dots
    final inactivePaint = Paint()..color = inactiveColor;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(Offset(startX + i * spacing, y), dotRadius, inactivePaint);
    }

    // Draw active "worm" that stretches between dots
    final activePaint = Paint()..color = activeColor;
    final currentIndex = pageOffset.floor().clamp(0, count - 1);
    final nextIndex = (currentIndex + 1).clamp(0, count - 1);
    final progress = pageOffset - currentIndex;

    final fromX = startX + currentIndex * spacing;
    final toX = startX + nextIndex * spacing;

    // Worm: stretches from current to next based on progress
    final wormLeft = lerpDouble(fromX, toX, (progress * 2).clamp(0, 1))! - dotRadius;
    final wormRight = lerpDouble(fromX, toX, ((progress - 0.5) * 2).clamp(0, 1))! + dotRadius;

    canvas.drawRRect(
      RRect.fromLTRBR(
        wormLeft < wormRight ? wormLeft : wormRight,
        y - dotRadius,
        wormLeft < wormRight ? wormRight : wormLeft,
        y + dotRadius,
        const Radius.circular(dotRadius),
      ),
      activePaint,
    );
  }

  double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _WormPainter old) =>
      pageOffset != old.pageOffset || activeColor != old.activeColor;
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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.only(
            left: kSpacingMedium,
            right: kSpacingMedium,
            top: kSpacingMedium,
            bottom: bottomPadding + kSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.12),
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
              // === Benefits — compact, inline ===
              _BenefitChip(
                icon: FontAwesomeIcons.userGroup,
                text: AppStrings.welcome.benefit1Title,
                color: cs.primary,
              ),
              const SizedBox(height: kSpacingSmall),
              _BenefitChip(
                icon: FontAwesomeIcons.listCheck,
                text: AppStrings.welcome.benefit2Title,
                color: cs.primary,
              ),
              const SizedBox(height: kSpacingSmall),
              _BenefitChip(
                icon: FontAwesomeIcons.jar,
                text: AppStrings.welcome.benefit3Title,
                color: cs.primary,
              ),

              const SizedBox(height: kSpacingMedium),

              // === Register button with colored shadow ===
              Container(
                width: double.infinity,
                height: kButtonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.person_add),
                  label: Text(
                    AppStrings.welcome.startButton,
                    style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
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
                  minimumSize: const Size(44, 36),
                ),
                child: Text(
                  AppStrings.welcome.loginLink,
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),

              // === Legal links ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onTerms,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXTiny),
                      minimumSize: const Size(44, 32),
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
                      minimumSize: const Size(44, 32),
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

              // === Build date (debug only) ===
              if (const bool.fromEnvironment('dart.vm.product') == false)
                Text(
                  'Build: $_kBuildTimestamp',
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: cs.onSurface.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Benefit Chip (compact — icon + text in one line)
// ============================================================

class _BenefitChip extends StatelessWidget {
  final IconData icon;
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: kIconSizeSmallPlus, color: color.withValues(alpha: 0.7)),
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
