// 📄 File: lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - Hybrid Premium
//
// 📋 Design:
// - רקע מחברת עדין (brand texture בלבד)
// - כרטיסי פיצ'ר נקיים על Surface (לא Sticky Notes)
// - CTA אחד ברור (M3 FilledButton)
// - 8pt grid, radius 14px, טיפוגרפיה נקייה
// - WhatsApp-like: פשוט, נקי, מקצועי
//
// ✨ Features:
// - עומק Glassmorphic מוגבר
// - אנימציות כניסה מדורגות (Staggered Entrance)
// - משוב Haptic מבוסס הקשר
// - אופטימיזציה לביצועי Render
//
// 📝 Version: 4.0 - Hybrid Premium (Immersive Depth + Sensory) (22/02/2026)

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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _handleLogin(BuildContext context) {
    unawaited(HapticFeedback.lightImpact());
    Navigator.pushNamed(context, '/login');
  }

  void _handleRegister(BuildContext context) {
    unawaited(HapticFeedback.mediumImpact());
    Navigator.pushNamed(context, '/register');
  }

  void _handleLegalLink(BuildContext context, VoidCallback showDialog) {
    unawaited(HapticFeedback.selectionClick());
    showDialog();
  }

  bool _isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  double _horizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 12.0 : screenWidth > 400 ? 20.0 : kSpacingMedium;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final isSmallScreen = _isSmallScreen(context);
    final horizontalPadding = _horizontalPadding(context);

    // ⏱️ Staggered entrance delays (80ms apart)
    const staggerDelay = 80;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // רקע מחברת עדין - brand texture בלבד
          const NotebookBackground(
            lineOpacity: 0.16,
            lineColor: kNotebookBlueSoft,
            showRedLine: true,
            redLineOpacity: 0.14,
            redLineWidth: 1.5,
            fadeEdges: true,
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  // תוכן עליון - scrollable (RepaintBoundary לביצועים)
                  Expanded(
                    child: RepaintBoundary(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: isSmallScreen ? kSpacingSmall : kSpacingLarge),

                            // לוגו וסלוגן
                            _LogoAndSlogan(isSmallScreen: isSmallScreen)
                                .animate()
                                .fadeIn(duration: 400.ms, curve: Curves.easeOutBack)
                                .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutBack)
                                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: kSpacingLarge),

                            // כרטיסי פיצ'רים נקיים - Staggered Entrance
                            _FeatureCard(
                                  emoji: AppStrings.welcome.group1Emoji,
                                  title: AppStrings.welcome.group1Title,
                                  description: AppStrings.welcome.group1Question,
                                  accentColor: kStickyGreen,
                                  previewWidget: const _MiniShoppingList(),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (staggerDelay * 1).ms, curve: Curves.easeOutBack)
                                .slideY(begin: 0.2, duration: 400.ms, delay: (staggerDelay * 1).ms, curve: Curves.easeOutBack)
                                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, delay: (staggerDelay * 1).ms, curve: Curves.easeOutBack),
                            const SizedBox(height: kSpacingSmallPlus),

                            _FeatureCard(
                                  emoji: AppStrings.welcome.group2Emoji,
                                  title: AppStrings.welcome.group2Title,
                                  description: AppStrings.welcome.group2Question,
                                  accentColor: kStickyOrange,
                                  previewWidget: const _MiniPantry(),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (staggerDelay * 2).ms, curve: Curves.easeOutBack)
                                .slideY(begin: 0.2, duration: 400.ms, delay: (staggerDelay * 2).ms, curve: Curves.easeOutBack)
                                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, delay: (staggerDelay * 2).ms, curve: Curves.easeOutBack),
                            const SizedBox(height: kSpacingSmallPlus),

                            _FeatureCard(
                                  emoji: AppStrings.welcome.group3Emoji,
                                  title: AppStrings.welcome.group3Title,
                                  description: AppStrings.welcome.group3Question,
                                  accentColor: kStickyCyan,
                                  previewWidget: const _MiniSharing(),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (staggerDelay * 3).ms, curve: Curves.easeOutBack)
                                .slideY(begin: 0.2, duration: 400.ms, delay: (staggerDelay * 3).ms, curve: Curves.easeOutBack)
                                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, delay: (staggerDelay * 3).ms, curve: Curves.easeOutBack),
                            const SizedBox(height: kSpacingMedium),

                            // סלוגן סיום
                            Text(
                              AppStrings.welcome.moreGroupsHint,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (staggerDelay * 4).ms, curve: Curves.easeOutBack),
                            const SizedBox(height: kSpacingMedium),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // הפרדה דקה - "כאן מתחיל אזור פעולה"
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Divider(height: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.12)),
                  ),

                  // Scrim עליון - מאחורי CTA + הסבר
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingSmall,
                          vertical: kSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: (brand?.paperBackground ?? kPaperBackground).withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // CTA ראשי - M3 FilledButton.tonal (premium, brand accent)
                            SizedBox(
                              width: double.infinity,
                              height: kButtonHeight,
                              child: FilledButton.tonalIcon(
                                onPressed: () => _handleRegister(context),
                                icon: const Icon(Icons.person_add),
                                label: Text(
                                  AppStrings.welcome.startButton,
                                  style: const TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.w600),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: (brand?.accent ?? cs.primary).withValues(alpha: 0.18),
                                  foregroundColor: brand?.accent ?? cs.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                                    side: BorderSide(
                                      color: (brand?.accent ?? cs.primary).withValues(alpha: 0.28),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                // ✨ Shimmer עדין - אחת ל-5 שניות למשיכת העין
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(
                                  delay: 3500.ms,
                                  duration: 1500.ms,
                                  color: (brand?.accent ?? cs.primary).withValues(alpha: 0.08),
                                ),
                            const SizedBox(height: kSpacingTiny),
                            // הסבר קצר
                            Text(
                              AppStrings.welcome.authExplanation,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (staggerDelay * 5).ms, curve: Curves.easeOutBack)
                      .slideY(begin: 0.2, duration: 400.ms, delay: (staggerDelay * 5).ms, curve: Curves.easeOutBack)
                      .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, delay: (staggerDelay * 5).ms, curve: Curves.easeOutBack),
                  const SizedBox(height: kSpacingSmall),

                  // Scrim תחתון - מאחורי לינק התחברות
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                        decoration: BoxDecoration(
                          color: (brand?.paperBackground ?? kPaperBackground).withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(kBorderRadiusUnified),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _handleLogin(context),
                          icon: Icon(
                            Icons.login_rounded,
                            size: 18,
                            color: (brand?.accent ?? cs.primary).withValues(alpha: 0.65),
                          ),
                          label: Text(
                            AppStrings.welcome.loginLink,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: (brand?.accent ?? cs.primary).withValues(alpha: 0.75),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.2,
                              decorationColor: (brand?.accent ?? cs.primary).withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // לינקים משפטיים
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _handleLegalLink(
                          context,
                          () => showTermsOfServiceDialog(context),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(44, 32),
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
                        onPressed: () => _handleLegalLink(
                          context,
                          () => showPrivacyPolicyDialog(context),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(44, 32),
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
                  const SizedBox(height: kSpacingSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// לוגו וסלוגן - נקי עם halo עדין מאחורי אזור הלוגו
class _LogoAndSlogan extends StatelessWidget {
  final bool isSmallScreen;

  const _LogoAndSlogan({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final onSurface = cs.onSurface;
    final bgColor = brand?.paperBackground ?? kPaperBackground;
    final accentColor = brand?.accent ?? cs.primary;

    final borderRadius = BorderRadius.circular(kBorderRadiusUnified);

    return Semantics(
      header: true,
      label: '${AppStrings.welcome.title} - ${AppStrings.welcome.subtitle}',
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? kSpacingSmallPlus : kSpacingMedium,
              horizontal: kSpacingLarge,
            ),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.93),
              borderRadius: borderRadius,
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
                        color: onSurface.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w800,
                        fontSize: isSmallScreen ? 36 : 44,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_rounded,
                        size: isSmallScreen ? 18 : 22,
                        color: accentColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: kSpacingSmall),
                Text(
                  AppStrings.welcome.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 17,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// כרטיס פיצ'ר - Glassmorphic עם פס צבעוני, קווי מחברת נראים מבעד
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Widget previewWidget;
  final Color accentColor;

  const _FeatureCard({
    required this.emoji,
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
    final borderRadius = BorderRadius.circular(kBorderRadiusUnified);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Semantics(
          label: '$title - $description',
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kSpacingSmallPlus),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.65),
                  // borderRadius handled by ClipRRect parent
                  border: Border(
                    top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.18), width: 0.9),
                    bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.18), width: 0.9),
                    left: BorderSide(
                      color: isRtl ? cs.outlineVariant.withValues(alpha: 0.18) : accentColor.withValues(alpha: 0.65),
                      width: isRtl ? 0.9 : 4,
                    ),
                    right: BorderSide(
                      color: isRtl ? accentColor.withValues(alpha: 0.65) : cs.outlineVariant.withValues(alpha: 0.18),
                      width: isRtl ? 4 : 0.9,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // כותרת: emoji + title + description
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: Text(emoji, style: const TextStyle(fontSize: 24, height: 1.0)),
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.87),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.58),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingSmall),
                    // Mini preview - ללא רקע נפרד
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: previewWidget,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini Shopping List Preview
class _MiniShoppingList extends StatelessWidget {
  const _MiniShoppingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem1, qty: '2', checked: true),
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem2, qty: '1', checked: true),
        _MiniListItemWithQty(text: AppStrings.welcome.demoItem3, qty: 'L', checked: false),
      ],
    );
  }
}

/// Mini Pantry Preview
class _MiniPantry extends StatelessWidget {
  const _MiniPantry();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem1, qty: '2', isLow: false),
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem2, qty: '6', isLow: false),
        _MiniPantryItem(text: AppStrings.welcome.demoPantryItem3, qty: '0', isLow: true),
      ],
    );
  }
}

/// Mini Sharing Preview
class _MiniSharing extends StatelessWidget {
  const _MiniSharing();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniShareUser(name: AppStrings.welcome.demoUser1, isOnline: true, avatarColor: kStickyCyan),
        _MiniShareUser(name: AppStrings.welcome.demoUser2, isOnline: true, avatarColor: kStickyPurple),
        _MiniShareUser(name: AppStrings.welcome.demoUser3, isOnline: false, avatarColor: kStickyOrange),
      ],
    );
  }
}

/// Mini List Item with Quantity
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 14,
            color: checked ? successColor : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              qty,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, height: 1.2),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
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

/// Mini Pantry Item
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 14,
            color: isLow ? warningColor : successColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 11, height: 1.2, color: cs.onSurface.withValues(alpha: 0.87))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isLow ? warningColor.withValues(alpha: 0.15) : cs.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              qty,
              style: TextStyle(
                fontSize: 10,
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

/// Mini Share User
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // אווטר צבעוני עם אות ראשונה
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor.withValues(alpha: 0.7),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontSize: 9,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(name, style: TextStyle(fontSize: 11, height: 1.2, color: cs.onSurface.withValues(alpha: 0.87))),
          ),
          // נקודת סטטוס
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? successColor : cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? AppStrings.welcome.statusOnline : AppStrings.welcome.statusOffline,
            style: TextStyle(fontSize: 9, height: 1.2, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
