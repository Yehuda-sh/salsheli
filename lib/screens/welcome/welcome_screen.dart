// 📄 lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים — Clean onboarding with logo, carousel, benefits
//
// 📋 Design:
// - רקע מחברת עדין (NotebookBackground.subtle)
// - Logo image + subtitle
// - Carousel פשוט — illustration + title + description
// - Benefits strip — 3 icon+text rows
// - Sticky CTA בתחתית
//
// 🔗 Related: ui_constants.dart, app_theme.dart, NotebookBackground

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic spacer for bottom bar
    final bottomBarHeight = kButtonHeight + kSpacingSmallPlus + kButtonHeightSmall +
        kSpacingSmall + 44 + kSpacingSmall + bottomPadding;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // רקע מחברת עדין — per CLAUDE.md: auth screens are clean
          const NotebookBackground.subtle(),

          // תוכן ראשי
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // === לוגו ===
                _LogoSection(screenHeight: screenHeight)
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOut),

                // === Carousel ===
                Expanded(
                  child: PageView(
                    controller: _pageController,
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

                // === Dots — below carousel ===
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus),
                  child: _DotIndicator(
                    count: 3,
                    current: _currentPage,
                    activeColor: brand?.accent ?? cs.primary,
                    inactiveColor: cs.outlineVariant,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                // === Benefits strip ===
                const _BenefitsStrip()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),

                // Dynamic spacer for bottom bar
                SizedBox(height: bottomBarHeight),
              ],
            ),
          ),

          // === Sticky Bottom CTA ===
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StickyBottomBar(
              bottomPadding: bottomPadding,
              onRegister: _handleRegister,
              onLogin: _handleLogin,
              onTerms: () => _handleLegalLink(() => showTermsOfServiceDialog(context)),
              onPrivacy: () => _handleLegalLink(() => showPrivacyPolicyDialog(context)),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.2, duration: 400.ms, delay: 400.ms),
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
        padding: const EdgeInsets.only(top: kSpacingLarge, bottom: kSpacingSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.webp',
              height: screenHeight * 0.08,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              AppStrings.welcome.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65),
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
// Simple Feature Card (Carousel page)
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
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingSmall),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Semantics(
            label: '$title - $description',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration — flexible, takes available space
                Flexible(
                  child: ExcludeSemantics(
                    child: Image.asset(
                      illustrationAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: kSpacingMedium),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.87),
                    fontWeight: FontWeight.w800,
                    fontSize: kFontSizeTitle,
                  ),
                ),
                const SizedBox(height: kSpacingSmall),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                    fontSize: kFontSizeBody,
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

// ============================================================
// Dot Indicator
// ============================================================

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ============================================================
// Benefits Strip
// ============================================================

class _BenefitsStrip extends StatelessWidget {
  const _BenefitsStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BenefitRow(
            icon: Icons.group_rounded,
            color: kStickyCyan,
            title: AppStrings.welcome.benefit1Title,
            subtitle: AppStrings.welcome.benefit1Subtitle,
          ),
          const SizedBox(height: kSpacingSmall),
          _BenefitRow(
            icon: Icons.checklist_rounded,
            color: kStickyGreen,
            title: AppStrings.welcome.benefit2Title,
            subtitle: AppStrings.welcome.benefit2Subtitle,
          ),
          const SizedBox(height: kSpacingSmall),
          _BenefitRow(
            icon: Icons.kitchen_rounded,
            color: kStickyOrange,
            title: AppStrings.welcome.benefit3Title,
            subtitle: AppStrings.welcome.benefit3Subtitle,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: kSpacingXLarge,
          height: kSpacingXLarge,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Icon(icon, size: kIconSizeSmall, color: color),
        ),
        const SizedBox(width: kSpacingSmallPlus),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.87),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Sticky Bottom Bar
// ============================================================

class _StickyBottomBar extends StatelessWidget {
  final double bottomPadding;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _StickyBottomBar({
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            left: kSpacingMedium,
            right: kSpacingMedium,
            top: kSpacingSmallPlus,
            bottom: bottomPadding + kSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.08),
                blurRadius: kSpacingSmallPlus,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CTA ראשי — register
              SizedBox(
                width: double.infinity,
                height: kButtonHeight,
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
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: kSpacingSmallPlus),

              // Login — text link only
              TextButton(
                onPressed: onLogin,
                child: Text(
                  AppStrings.welcome.loginLink,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),

              const SizedBox(height: kSpacingSmall),

              // Legal links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onTerms,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      AppStrings.welcome.termsOfService,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingXTiny),
                    child: Text(
                      '|',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: kFontSizeSmall),
                    ),
                  ),
                  TextButton(
                    onPressed: onPrivacy,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmallPlus, vertical: kSpacingSmall),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      AppStrings.welcome.privacyPolicy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
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
