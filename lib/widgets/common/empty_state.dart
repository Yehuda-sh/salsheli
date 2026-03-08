import 'package:flutter/material.dart';
import 'package:salsheli/core/ui_constants.dart';

/// 📭 מצב ריק אחיד — אייקון + כותרת + תיאור + כפתור (אופציונלי)
///
/// שימוש:
/// ```dart
/// EmptyState(
///   icon: Icons.shopping_cart_outlined,
///   title: 'אין רשימות',
///   subtitle: 'צור רשימה חדשה כדי להתחיל',
///   actionLabel: 'רשימה חדשה',
///   onAction: () => ...,
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: cs.onSurfaceVariant),
            const SizedBox(height: kSpacingMedium),
            Text(
              title,
              style: t.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: kSpacingSmall),
              Text(
                subtitle!,
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: kSpacingLarge),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
