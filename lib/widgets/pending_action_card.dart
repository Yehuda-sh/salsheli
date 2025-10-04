// 📄 File: lib/widgets/pending_action_card.dart
// תיאור: כרטיס פעולה ממתינה לאישור/דחייה
//
// תכונות:
// - תצוגת פעולות ממתינות (החלפת פריט, וכו')
// - כפתורי אישור/דחייה
// - תמיכה ב-timeago עברית
// - תואם Material Design: גדלי מגע 48px, theme colors
//
// תלויות:
// - timeago package (לפורמט תאריכים יחסיים)
// - Theme colors (AppBrand)

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kCardPadding = 12.0;
const double _kCardBorderRadius = 12.0;
const double _kCardElevation = 2.0;
const double _kUserInfoFontSize = 12.0;
const double _kMessageFontSize = 13.0;
const double _kPillPadding = 8.0;
const double _kPillBorderRadius = 6.0;
const double _kButtonSize = 48.0; // Material Design minimum
const double _kIconSize = 20.0;
const double _kSpinnerSize = 28.0;

// ============================
// Models
// ============================

/// מייצג פעולה ממתינה לאישור/דחייה
class PendingAction {
  /// שם המשתמש שביקש את הפעולה
  final String requestedBy;

  /// סוג הפעולה (למשל: "replace_item")
  final String actionType;

  /// נתונים ספציפיים לפעולה
  final Map<String, dynamic> actionData;

  /// הודעה אופציונלית מהמשתמש
  final String? message;

  /// מתי הפעולה נוצרה
  final DateTime createdDate;

  const PendingAction({
    required this.requestedBy,
    required this.actionType,
    required this.actionData,
    this.message,
    required this.createdDate,
  });
}

// ============================
// Widget
// ============================

class PendingActionCard extends StatelessWidget {
  final PendingAction action;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;

  const PendingActionCard({
    super.key,
    required this.action,
    required this.onApprove,
    required this.onReject,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // הגדרת תמיכה בעברית ל-timeago
    timeago.setLocaleMessages('he', _HebrewMessages());

    return Semantics(
      label: 'פעולה ממתינה מ-${action.requestedBy}',
      child: Card(
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: (brand?.accent ?? cs.primary).withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
        ),
        elevation: _kCardElevation,
        child: Padding(
          padding: const EdgeInsets.all(_kCardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // תוכן הפעולה
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // מי ביקש + מתי
                    Text(
                      '${action.requestedBy} · ${timeago.format(action.createdDate, locale: 'he')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: _kUserInfoFontSize,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // פרטי הפעולה
                    _buildActionDetails(context, cs, brand),

                    // הודעה אופציונלית
                    if (action.message != null &&
                        action.message!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(_kPillPadding),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            _kPillBorderRadius,
                          ),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '"${action.message}"',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: _kMessageFontSize,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // כפתורי פעולה
              _buildActionButtons(context, cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionDetails(
    BuildContext context,
    ColorScheme cs,
    AppBrand? brand,
  ) {
    switch (action.actionType) {
      case 'replace_item':
        final oldItem = action.actionData['original_item_name'] ?? '';
        final newItem = action.actionData['proposed_alternative'] ?? '';
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'רוצה להחליף את',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
            ),
            _buildPill(context, text: oldItem, color: cs.error),
            Icon(
              Icons.arrow_left,
              size: _kIconSize,
              color: cs.onSurfaceVariant,
            ),
            _buildPill(
              context,
              text: newItem,
              color: const Color(0xFF10B981), // green-500
            ),
          ],
        );

      default:
        return Text(
          'פעולה לא ידועה: ${action.actionType}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
        );
    }
  }

  Widget _buildPill(
    BuildContext context, {
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kPillPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_kPillBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme cs) {
    if (isLoading) {
      return SizedBox(
        width: _kSpinnerSize,
        height: _kSpinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).extension<AppBrand>()?.accent ?? cs.primary,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // כפתור דחייה
        Semantics(
          button: true,
          label: 'דחה בקשה',
          child: SizedBox(
            width: _kButtonSize,
            height: _kButtonSize,
            child: IconButton(
              onPressed: onReject,
              style: IconButton.styleFrom(
                backgroundColor: cs.errorContainer,
                foregroundColor: cs.onErrorContainer,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close, size: _kIconSize),
              tooltip: 'דחה',
            ),
          ),
        ),
        const SizedBox(width: 8),

        // כפתור אישור
        Semantics(
          button: true,
          label: 'אשר בקשה',
          child: SizedBox(
            width: _kButtonSize,
            height: _kButtonSize,
            child: IconButton(
              onPressed: onApprove,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // green-500
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.check, size: _kIconSize),
              tooltip: 'אשר',
            ),
          ),
        ),
      ],
    );
  }
}

// ============================
// Hebrew TimeAgo Messages
// ============================

class _HebrewMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'בעוד';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'פחות מדקה';
  @override
  String aboutAMinute(int minutes) => 'דקה';
  @override
  String minutes(int minutes) => '$minutes דקות';
  @override
  String aboutAnHour(int minutes) => 'שעה';
  @override
  String hours(int hours) => '$hours שעות';
  @override
  String aDay(int hours) => 'יום';
  @override
  String days(int days) => '$days ימים';
  @override
  String aboutAMonth(int days) => 'חודש';
  @override
  String months(int months) => '$months חודשים';
  @override
  String aboutAYear(int year) => 'שנה';
  @override
  String years(int years) => '$years שנים';
  @override
  String wordSeparator() => ' ';
}
