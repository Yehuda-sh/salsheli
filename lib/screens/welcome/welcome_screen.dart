// 📄 File: lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - מציג לוגו, פיצ'רים לדוגמה, וכפתורי התחברות/הרשמה
//
// 📋 Features:
// - עיצוב Sticky Notes מלא 🎨📝
// - הצגת פיצ'רים: רשימות קניות, מזווה, שיתוף משפחתי
// - רקע מחברת עם קווים כחולים
// - פתקים צבעוניים עם צללים מציאותיים
// - נגישות מלאה
// - אנימציות חלקות
//
// 🔗 Related:
// - NotebookBackground - רקע מחברת
// - StickyNote / StickyNoteLogo - פתקים
// - StickyButton - כפתורים
// - ui_constants.dart - קבועים
// - app_theme.dart - AppBrand
//
// 🎨 Design:
// - עיצוב Sticky Notes System
// - רקע נייר קרם עם קווים כחולים
// - פתקים צבעוניים: צהוב, ורוד, כתום
// - צללים מציאותיים לאפקט הדבקה
// - סיבובים קלים לכל פתק
//
// 📝 Version: 2.0 - No Groups (27/01/2026)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/dialogs/legal_content_dialog.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// מטפל בלחיצה על כפתור התחברות
  void _handleLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  /// מטפל בלחיצה על כפתור הרשמה (CTA ראשי)
  void _handleRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<AppBrand>();
    final accent = brand?.accent ?? theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: brand?.paperBackground ?? kPaperBackground,
      body: Stack(
        children: [
          // 📄 רקע נייר עם קווים
          const NotebookBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
              ),
              child: Column(
                children: [
                  // 📱 תוכן עליון - scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: isSmallScreen ? kSpacingSmall : kSpacingMedium),

                          // 🎨 לוגו וסלוגן משולבים - עיצוב חדש
                          _LogoAndSlogan(
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(height: isSmallScreen ? kSpacingSmall : kSpacingMedium),

                          // 🛒 כרטיס רשימות קניות
                          _FeatureCardWithPreview(
                            emoji: AppStrings.welcome.group1Emoji,
                            title: AppStrings.welcome.group1Title,
                            question: AppStrings.welcome.group1Question,
                            color: brand?.stickyPink ?? kStickyPink,
                            rotation: 0.012,
                            previewWidget: const _MiniShoppingList(),
                            clipColor: Colors.red.shade400,
                            clipPosition: 0.12,
                            clipAngle: 0.15,
                          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // 📦 כרטיס מזווה דיגיטלי
                          _FeatureCardWithPreview(
                            emoji: AppStrings.welcome.group2Emoji,
                            title: AppStrings.welcome.group2Title,
                            question: AppStrings.welcome.group2Question,
                            color: brand?.stickyYellow ?? kStickyYellow,
                            rotation: -0.01,
                            previewWidget: const _MiniPantry(),
                            clipColor: Colors.blue.shade400,
                            clipPosition: 0.18,
                            clipAngle: -0.1,
                          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // 👨‍👩‍👧‍👦 כרטיס שיתוף משפחתי
                          _FeatureCardWithPreview(
                            emoji: AppStrings.welcome.group3Emoji,
                            title: AppStrings.welcome.group3Title,
                            question: AppStrings.welcome.group3Question,
                            color: kStickyOrange,
                            rotation: 0.008,
                            previewWidget: const _MiniSharing(),
                            clipColor: Colors.green.shade500,
                            clipPosition: 0.08,
                            clipAngle: 0.05,
                          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // סלוגן סיום
                          Text(
                            AppStrings.welcome.moreGroupsHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                          const SizedBox(height: kSpacingMedium),
                        ],
                      ),
                    ),
                  ),

                  // 🔘 כפתורי פעולה - צמודים לתחתית
                  // CTA ראשי - הרשמה
                  StickyButton(
                    color: accent,
                    label: AppStrings.welcome.startButton,
                    icon: Icons.person_add,
                    onPressed: () => _handleRegister(context),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // 💡 הסבר קצר למה צריך להירשם
                  Text(
                    AppStrings.welcome.authExplanation,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // לינק התחברות - בולט יותר
                  TextButton(
                    onPressed: () => _handleLogin(context),
                    child: Text(
                      AppStrings.welcome.loginLink,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // 📜 לינקים משפטיים - תנאי שימוש ופרטיות
                  // ♿ שומרים אזור לחיצה מינימלי לנגישות (48x48)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => showTermsOfServiceDialog(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(48, 36),
                        ),
                        child: Text(
                          AppStrings.welcome.termsOfService,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () => showPrivacyPolicyDialog(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(48, 36),
                        ),
                        child: Text(
                          AppStrings.welcome.privacyPolicy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
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

/// 🎨 שם וסלוגן - עיצוב נקי בלי לוגו
class _LogoAndSlogan extends StatelessWidget {
  final bool isSmallScreen;

  const _LogoAndSlogan({
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Semantics(
      header: true,
      label: '${AppStrings.welcome.title} - ${AppStrings.welcome.subtitle}',
      child: Column(
        children: [
          // 📝 שם האפליקציה - גדול ובולט
          Text(
            AppStrings.welcome.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: onSurface.withValues(alpha: 0.87),
              fontWeight: FontWeight.w800,
              fontSize: isSmallScreen ? 36 : 44,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: onSurface.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          // 🏷️ סלוגן - טקסט ברור יותר
          Text(
            AppStrings.welcome.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 15 : 17,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
        ],
      ),
    );
  }
}

/// 📌 כרטיס פיצ'ר עם Mini UI Preview
/// מציג פיצ'ר עם תצוגה מוחשית של הממשק - כמו פתק מודבק על מחברת
class _FeatureCardWithPreview extends StatelessWidget {
  final String emoji;
  final String title;
  final String question;
  final Color color;
  final double rotation;
  final Widget previewWidget;
  final Color? clipColor;
  final double clipPosition; // 0.0-1.0 מיקום יחסי מימין
  final double clipAngle;

  const _FeatureCardWithPreview({
    required this.emoji,
    required this.title,
    required this.question,
    required this.color,
    required this.previewWidget,
    this.rotation = 0.0,
    this.clipColor,
    this.clipPosition = 0.15,
    this.clipAngle = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final actualClipColor = clipColor ?? Colors.grey.shade500;

    // ♿ Semantics: קורא מסך יקרא רק את ה-label הכולל, לא את הילדים
    return Semantics(
      label: '$title - $question',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 📌 הפתק עצמו - גדול יותר
          StickyNote(
            color: color,
            rotation: rotation,
            child: Padding(
              // ✅ RTL-aware: EdgeInsetsDirectional במקום EdgeInsets.only
              padding: const EdgeInsetsDirectional.only(top: 20, end: 16, bottom: 16, start: 16),
              child: Row(
                children: [
                  // צד ימין (ב-RTL): Emoji + Title + Question
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji + Title
                        Row(
                          children: [
                            Text(
                              emoji,
                              style: const TextStyle(fontSize: 34, height: 1.0),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: onSurface.withValues(alpha: 0.87),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Question - סגנון כתב יד
                        Text(
                          question,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // צד שמאל (ב-RTL): Mini UI Preview - דקורטיבי
                  Expanded(
                    flex: 5,
                    child: previewWidget,
                  ),
                ],
              ),
            ),
          ),
          // 📎 סיכת נייר / קליפס מתכתי למעלה
          // ✅ RTL-aware: PositionedDirectional(end:) במקום Positioned(right:)
          PositionedDirectional(
            top: -8,
            end: MediaQuery.of(context).size.width * clipPosition,
            child: Transform.rotate(
              angle: clipAngle,
              child: _PaperClip(color: actualClipColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// 📎 קליפס מתכתי מציאותי
class _PaperClip extends StatelessWidget {
  final Color color;

  const _PaperClip({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 36),
      painter: _PaperClipPainter(color: color),
    );
  }
}

/// 🎨 ציור קליפס מתכתי
class _PaperClipPainter extends CustomPainter {
  final Color color;

  _PaperClipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // צל
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final path = Path();

    // צורת קליפס קלאסית
    final w = size.width;
    final h = size.height;

    // קו חיצוני למעלה
    path.moveTo(w * 0.2, h * 0.1);
    path.lineTo(w * 0.2, h * 0.85);
    path.quadraticBezierTo(w * 0.2, h * 0.95, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.8, h * 0.95, w * 0.8, h * 0.85);
    path.lineTo(w * 0.8, h * 0.25);
    path.quadraticBezierTo(w * 0.8, h * 0.15, w * 0.5, h * 0.15);
    path.quadraticBezierTo(w * 0.35, h * 0.15, w * 0.35, h * 0.25);
    path.lineTo(w * 0.35, h * 0.75);
    path.quadraticBezierTo(w * 0.35, h * 0.82, w * 0.5, h * 0.82);
    path.quadraticBezierTo(w * 0.65, h * 0.82, w * 0.65, h * 0.75);
    path.lineTo(w * 0.65, h * 0.35);

    // ציור צל
    canvas.save();
    canvas.translate(1.5, 1.5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // ציור קליפס
    canvas.drawPath(path, paint);

    // הייליט מתכתי
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path();
    highlightPath.moveTo(w * 0.25, h * 0.15);
    highlightPath.lineTo(w * 0.25, h * 0.5);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🛒 Mini Shopping List Preview - רשימת קניות מיניאטורית עם כמויות
/// ✅ תומך Dark Mode
class _MiniShoppingList extends StatelessWidget {
  const _MiniShoppingList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת הרשימה (דמו)
          _MiniHeader(text: '🛒 סופר'),
          SizedBox(height: 6),
          _MiniListItemWithQty(text: 'חלב', qty: '2', checked: true),
          _MiniListItemWithQty(text: 'לחם', qty: '1', checked: true),
          _MiniListItemWithQty(text: 'ביצים', qty: 'L', checked: false),
        ],
      ),
    );
  }
}

/// 📦 Mini Pantry Preview - מזווה מיניאטורי
/// ✅ תומך Dark Mode
class _MiniPantry extends StatelessWidget {
  const _MiniPantry();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniHeader(text: '📦 מזווה'),
          SizedBox(height: 6),
          _MiniPantryItem(text: 'חלב', qty: '2', isLow: false),
          _MiniPantryItem(text: 'ביצים', qty: '6', isLow: false),
          _MiniPantryItem(text: 'לחם', qty: '0', isLow: true),
        ],
      ),
    );
  }
}

/// 👨‍👩‍👧‍👦 Mini Sharing Preview - שיתוף משפחתי
/// ✅ תומך Dark Mode
class _MiniSharing extends StatelessWidget {
  const _MiniSharing();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniHeader(text: '👨‍👩‍👧‍👦 משפחה'),
          SizedBox(height: 6),
          _MiniShareUser(name: 'אבא', isOnline: true),
          _MiniShareUser(name: 'אמא', isOnline: true),
          _MiniShareUser(name: 'דני', isOnline: false),
        ],
      ),
    );
  }
}

/// 📋 Mini Header - כותרת לרשימה מיניאטורית
/// ✅ תומך Dark Mode
class _MiniHeader extends StatelessWidget {
  final String text;

  const _MiniHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: cs.onSurface.withValues(alpha: 0.87),
      ),
    );
  }
}

/// 📝 Mini List Item with Quantity - פריט עם כמות ליד השם
/// ✅ תומך Dark Mode
class _MiniListItemWithQty extends StatelessWidget {
  final String text;
  final String qty;
  final bool checked;

  const _MiniListItemWithQty({
    required this.text,
    required this.qty,
    required this.checked,
  });

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
          // כמות ליד השם
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              qty,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // שם המוצר
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
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

/// 📦 Mini Pantry Item - פריט מזווה מיניאטורי
/// ✅ תומך Dark Mode
class _MiniPantryItem extends StatelessWidget {
  final String text;
  final String qty;
  final bool isLow;

  const _MiniPantryItem({
    required this.text,
    required this.qty,
    required this.isLow,
  });

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
            isLow ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            size: 14,
            color: isLow ? warningColor : successColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.87),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isLow
                  ? warningColor.withValues(alpha: 0.2)
                  : cs.onSurfaceVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              qty,
              style: TextStyle(
                fontSize: 10,
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

/// 👤 Mini Share User - משתמש משותף מיניאטורי
/// ✅ תומך Dark Mode
class _MiniShareUser extends StatelessWidget {
  final String name;
  final bool isOnline;

  const _MiniShareUser({required this.name, required this.isOnline});

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
            Icons.person,
            size: 14,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.87),
              ),
            ),
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
            isOnline ? 'מחובר' : 'לא מחובר',
            style: TextStyle(
              fontSize: 9,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
