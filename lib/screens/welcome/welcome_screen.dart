// 📄 lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים — Notebook + Carousel + Sticky CTA
//
// 📋 Design:
// - רקע מחברת (NotebookBackground)
// - Carousel עם 3 פיצ'רים (swipe)
// - Sticky CTA בתחתית (תמיד נראה)
// - אנימציות כניסה + Haptic feedback
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // רקע מחברת
          const NotebookBackground(
            lineOpacity: 0.16,
            lineColor: kNotebookBlueSoft,
            showRedLine: true,
            redLineOpacity: 0.14,
            redLineWidth: 1.5,
          ),

          // תוכן ראשי
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // === לוגו וסלוגן ===
                Padding(
                  padding: const EdgeInsets.only(top: kSpacingMedium, bottom: kSpacingSmall),
                  child: _LogoAndSlogan()
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOutBack)
                      .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutBack)
                      .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
                ),

                // === Dots + Swipe hint ===
                Padding(
                  padding: const EdgeInsets.only(bottom: kSpacingSmall),
                  child: Column(
                    children: [
                      _DotIndicator(
                        count: 3,
                        current: _currentPage,
                        activeColor: brand?.accent ?? cs.primary,
                        inactiveColor: cs.outlineVariant,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.welcome.moreGroupsHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms),

                // === Carousel ===
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          children: [
                            _FeatureCard(
                              emoji: AppStrings.welcome.group1Emoji,
                              illustrationAsset: 'assets/images/onboarding_shopping.webp',
                              title: AppStrings.welcome.group1Title,
                              description: AppStrings.welcome.group1Question,
                              accentColor: kStickyGreen,
                              previewWidget: const _MiniShoppingList(),
                            ),
                            _FeatureCard(
                              emoji: AppStrings.welcome.group2Emoji,
                              illustrationAsset: 'assets/images/onboarding_pantry.webp',
                              title: AppStrings.welcome.group2Title,
                              description: AppStrings.welcome.group2Question,
                              accentColor: kStickyOrange,
                              previewWidget: const _MiniPantry(),
                            ),
                            _FeatureCard(
                              emoji: AppStrings.welcome.group3Emoji,
                              illustrationAsset: 'assets/images/onboarding_sharing.webp',
                              title: AppStrings.welcome.group3Title,
                              description: AppStrings.welcome.group3Question,
                              accentColor: kStickyCyan,
                              previewWidget: const _MiniSharing(),
                            ),
                          ],
                        ),
                      ),

                      // רווח ל-sticky bar
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
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
                .slideY(begin: 0.3, duration: 400.ms, delay: 400.ms),
          ),
        ],
      ),
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
    final accentColor = brand?.accent ?? cs.primary;

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
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CTA ראשי
              SizedBox(
                width: double.infinity,
                height: kButtonHeight,
                child: FilledButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.person_add),
                  label: Text(
                    AppStrings.welcome.startButton,
                    style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.w700),
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
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    delay: 3500.ms,
                    duration: 1500.ms,
                    color: cs.onPrimary.withValues(alpha: 0.15),
                  ),

              const SizedBox(height: kSpacingSmall),

              // כפתור התחברות
              SizedBox(
                width: double.infinity,
                height: kButtonHeight - 4,
                child: OutlinedButton.icon(
                  onPressed: onLogin,
                  icon: Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    AppStrings.welcome.loginLink,
                    style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: kSpacingTiny),

              // לינקים משפטיים
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onTerms,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  Text(
                    ' \u2022 ',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: kFontSizeSmall),
                  ),
                  TextButton(
                    onPressed: onPrivacy,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          margin: const EdgeInsets.symmetric(horizontal: 4),
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
// Logo & Slogan
// ============================================================

class _LogoAndSlogan extends StatelessWidget {
  const _LogoAndSlogan();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final accentColor = brand?.accent ?? cs.primary;

    final bgColor = brand?.paperBackground ?? kPaperBackground;

    return Semantics(
      header: true,
      label: '${AppStrings.welcome.title} - ${AppStrings.welcome.subtitle}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: kSpacingSmallPlus, horizontal: kSpacingLarge),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.93),
              borderRadius: BorderRadius.circular(kBorderRadius),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.welcome.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w800,
                        fontSize: 42,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: accentColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingSmall),
                Text(
                  AppStrings.welcome.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
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
// Feature Card (Carousel page)
// ============================================================

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String? illustrationAsset;
  final String title;
  final String description;
  final Widget previewWidget;
  final Color accentColor;

  const _FeatureCard({
    required this.emoji,
    this.illustrationAsset,
    required this.title,
    required this.description,
    required this.previewWidget,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingSmall),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Semantics(
            label: '$title - $description',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kBorderRadiusLarge),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingLarge),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.65),
                    border: Border(
                      top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.18), width: 0.9),
                      bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.18), width: 0.9),
                      left: BorderSide(
                        color: isRtl ? cs.outlineVariant.withValues(alpha: 0.18) : accentColor.withValues(alpha: 0.8),
                        width: isRtl ? 0.9 : 5,
                      ),
                      right: BorderSide(
                        color: isRtl ? accentColor.withValues(alpha: 0.8) : cs.outlineVariant.withValues(alpha: 0.18),
                        width: isRtl ? 5 : 0.9,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // איור או Emoji
                      ExcludeSemantics(
                        child: illustrationAsset != null
                            ? Image.asset(
                                illustrationAsset!,
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(emoji, style: const TextStyle(fontSize: 48, height: 1.0)),
                                ),
                              ),
                      ),
                      const SizedBox(height: kSpacingMedium),

                      // כותרת
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.87),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: kSpacingTiny),

                      // תיאור
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontSize: kFontSizeBody,
                        ),
                      ),
                      const SizedBox(height: kSpacingLarge),

                      // Divider עדין
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                        indent: kSpacingLarge,
                        endIndent: kSpacingLarge,
                      ),
                      const SizedBox(height: kSpacingMedium),

                      // Mini preview
                      previewWidget,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Mini Previews (unchanged logic, center-aligned)
// ============================================================

class _MiniShoppingList extends StatelessWidget {
  const _MiniShoppingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem1, qty: '2', checked: true),
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem2, qty: '1', checked: true),
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem3, qty: 'L', checked: false),
      ],
    );
  }
}

class _MiniPantry extends StatelessWidget {
  const _MiniPantry();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem1, qty: '2', isLow: false),
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem2, qty: '6', isLow: false),
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem3, qty: '0', isLow: true),
      ],
    );
  }
}

class _MiniSharing extends StatelessWidget {
  const _MiniSharing();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MiniShareUser(name: AppStrings.welcome.demoUser1, isOnline: true, avatarColor: kStickyCyan),
        _MiniShareUser(name: AppStrings.welcome.demoUser2, isOnline: true, avatarColor: kStickyPurple),
        _MiniShareUser(name: AppStrings.welcome.demoUser3, isOnline: false, avatarColor: kStickyOrange),
      ],
    );
  }
}

class _MiniListItemWithQty extends StatelessWidget {
  final String text;
  final String qty;
  final bool checked;

  const _MiniListItemWithQty({required this.text, required this.qty, required this.checked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final successColor = brand?.success ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: checked ? successColor : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              qty,
              style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, height: 1.2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: kFontSizeSmall,
                height: 1.2,
                color: cs.onSurface.withValues(alpha: 0.87),
                decoration: checked ? TextDecoration.lineThrough : null,
                decorationColor: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPantryItem extends StatelessWidget {
  final String text;
  final String qty;
  final bool isLow;

  const _MiniPantryItem({required this.text, required this.qty, required this.isLow});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final warningColor = brand?.warning ?? cs.error;
    final successColor = brand?.success ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 18,
            color: isLow ? warningColor : successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: kFontSizeBody, height: 1.3, color: cs.onSurface.withValues(alpha: 0.87))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isLow ? warningColor.withValues(alpha: 0.15) : cs.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kBorderRadiusSmall),
            ),
            child: Text(
              qty,
              style: TextStyle(
                fontSize: kFontSizeTiny,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: isLow ? warningColor : cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniShareUser extends StatelessWidget {
  final String name;
  final bool isOnline;
  final Color? avatarColor;

  const _MiniShareUser({required this.name, required this.isOnline, this.avatarColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final successColor = brand?.success ?? cs.primary;
    final bgColor = avatarColor ?? cs.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor.withValues(alpha: 0.7),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light
                      ? cs.onSurface
                      : cs.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: TextStyle(fontSize: kFontSizeBody, height: 1.3, color: cs.onSurface.withValues(alpha: 0.87))),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? successColor : cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? AppStrings.welcome.statusOnline : AppStrings.welcome.statusOffline,
            style: TextStyle(fontSize: kFontSizeTiny, height: 1.2, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
