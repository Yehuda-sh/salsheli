// 📄 File: lib/screens/welcome/welcome_screen.dart
// 🎯 Purpose: מסך קבלת פנים - מציג לוגו, קבוצות לדוגמה, וכפתורי התחברות/הרשמה
//
// 📋 Features:
// - עיצוב Sticky Notes מלא 🎨📝
// - הצגת סוגי קבוצות עם שאלות ופיצ'רים
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
// - עיצוב Sticky Notes System 2025
// - רקע נייר קרם עם קווים כחולים
// - פתקים צבעוניים: צהוב, ורוד, כתום
// - צללים מציאותיים לאפקט הדבקה
// - סיבובים קלים לכל פתק
//
// Version: 10.0 - Mini UI Previews (16/12/2025) 🎨✨
// - 📝 סלוגן: "רשימות משותפות. מקום אחד."
// - 👨‍👩‍👧‍👦 3 כרטיסי קבוצות עם Mini UI previews
// - 🎯 תצוגה מוחשית של הממשק במקום Emojis
// - 📋 Mini list preview, Mini pantry, Mini voting
// - 🚀 כפתור CTA: "בואו נתחיל!"
// - 🔗 לינק התחברות: "יש לי חשבון? להתחבר"

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

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

                          // 📝 לוגו על פתק צהוב
                          Hero(
                            tag: 'app_logo',
                            child: Transform.scale(
                              scale: isSmallScreen ? 0.75 : 0.85,
                              child: StickyNoteLogo(
                                color: brand?.stickyYellow ?? kStickyYellow,
                                icon: Icons.shopping_basket_outlined,
                                iconColor: accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall),

                          // 📋 כותרת וסלוגן על פתק לבן
                          StickyNote(
                            color: Colors.white,
                            rotation: -0.01,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  Text(
                                    AppStrings.welcome.title,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 26 : 30,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.welcome.subtitle,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.black54,
                                      fontSize: isSmallScreen ? 13 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? kSpacingSmall : kSpacingMedium),

                          // 👨‍👩‍👧‍👦 כרטיס משפחה - עם Mini UI
                          _GroupCardWithPreview(
                            emoji: AppStrings.welcome.group1Emoji,
                            title: AppStrings.welcome.group1Title,
                            question: AppStrings.welcome.group1Question,
                            color: brand?.stickyPink ?? kStickyPink,
                            rotation: 0.012,
                            previewWidget: const _MiniShoppingList(),
                          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // 🏠 כרטיס ועד בית - עם Mini UI
                          _GroupCardWithPreview(
                            emoji: AppStrings.welcome.group2Emoji,
                            title: AppStrings.welcome.group2Title,
                            question: AppStrings.welcome.group2Question,
                            color: brand?.stickyYellow ?? kStickyYellow,
                            rotation: -0.01,
                            previewWidget: const _MiniTasksVoting(),
                          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // 🎒 כרטיס ועד גן - עם Mini UI
                          _GroupCardWithPreview(
                            emoji: AppStrings.welcome.group3Emoji,
                            title: AppStrings.welcome.group3Title,
                            question: AppStrings.welcome.group3Question,
                            color: kStickyOrange,
                            rotation: 0.008,
                            previewWidget: const _MiniAssignment(),
                          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),
                          const SizedBox(height: kSpacingSmall),

                          // + עוד קבוצות - בולט יותר
                          Text(
                            AppStrings.welcome.moreGroupsHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
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
                    icon: Icons.rocket_launch,
                    onPressed: () => _handleRegister(context),
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // לינק התחברות - בולט יותר
                  TextButton(
                    onPressed: () => _handleLogin(context),
                    child: Text(
                      AppStrings.welcome.loginLink,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 📌 כרטיס קבוצה עם Mini UI Preview
/// מציג סוג קבוצה עם תצוגה מוחשית של הממשק
class _GroupCardWithPreview extends StatelessWidget {
  final String emoji;
  final String title;
  final String question;
  final Color color;
  final double rotation;
  final Widget previewWidget;

  const _GroupCardWithPreview({
    required this.emoji,
    required this.title,
    required this.question,
    required this.color,
    required this.previewWidget,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StickyNote(
      color: color,
      rotation: rotation,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // צד ימין: Emoji + Title + Question
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji + Title
                  Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 28, height: 1.0),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Question
                  Text(
                    question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // צד שמאל: Mini UI Preview
            Expanded(
              flex: 2,
              child: previewWidget,
            ),
          ],
        ),
      ),
    );
  }
}

/// 🛒 Mini Shopping List Preview - רשימת קניות מיניאטורית עם כמויות
class _MiniShoppingList extends StatelessWidget {
  const _MiniShoppingList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת הרשימה
          _MiniHeader(text: '🛒 סופר'),
          SizedBox(height: 4),
          _MiniListItemWithQty(text: 'חלב', qty: '2', checked: true),
          _MiniListItemWithQty(text: 'לחם', qty: '1', checked: true),
          _MiniListItemWithQty(text: 'ביצים', qty: 'L', checked: false),
        ],
      ),
    );
  }
}

/// ✅ Mini Tasks & Voting Preview - הצבעה עם תוצאות
class _MiniTasksVoting extends StatelessWidget {
  const _MiniTasksVoting();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת ההצבעה
          _MiniHeader(text: '🗳️ צבע לובי?'),
          SizedBox(height: 4),
          _MiniVoteOption(text: 'לבן', votes: 3, selected: true),
          _MiniVoteOption(text: 'בז\'', votes: 2, selected: false),
          _MiniVoteOption(text: 'אפור', votes: 1, selected: false),
        ],
      ),
    );
  }
}

/// 🙋 Mini Assignment Preview - חלוקה למסיבת חנוכה
class _MiniAssignment extends StatelessWidget {
  const _MiniAssignment();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת הרשימה
          _MiniHeader(text: '🕎 מסיבת חנוכה'),
          SizedBox(height: 4),
          _MiniAssignItem(item: 'סופגניות', person: 'דנה'),
          _MiniAssignItem(item: 'נרות', person: 'יוסי'),
          _MiniAssignItem(item: 'צלחות', person: 'מיכל'),
          _MiniAssignItem(item: 'שתייה', person: '?'),
        ],
      ),
    );
  }
}

/// 📋 Mini Header - כותרת לרשימה מיניאטורית
class _MiniHeader extends StatelessWidget {
  final String text;

  const _MiniHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

/// 📝 Mini List Item with Quantity - פריט עם כמות ליד השם
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 12,
            color: checked ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 3),
          // כמות ליד השם
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              qty,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 3),
          // שם המוצר
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black87,
                decoration: checked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🗳️ Mini Vote Option - אפשרות הצבעה עם מספר קולות
class _MiniVoteOption extends StatelessWidget {
  final String text;
  final int votes;
  final bool selected;

  const _MiniVoteOption({
    required this.text,
    required this.votes,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 12,
            color: selected ? Colors.deepPurple : Colors.grey,
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.deepPurple.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$votes',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.deepPurple : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🙋 Mini Assign Item - חלוקה מיניאטורית
class _MiniAssignItem extends StatelessWidget {
  final String item;
  final String person;

  const _MiniAssignItem({required this.item, required this.person});

  @override
  Widget build(BuildContext context) {
    final isUnassigned = person == '?';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isUnassigned ? Icons.help_outline : Icons.person,
            size: 10,
            color: isUnassigned ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            person,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isUnassigned ? Colors.orange : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
