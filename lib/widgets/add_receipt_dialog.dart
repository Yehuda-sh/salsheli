// 📄 File: lib/widgets/add_receipt_dialog.dart
// 🎯 Purpose: Dialog לבחירת שיטת הוספת קבלה
//
// 📋 Features:
// ✅ 2 אופציות: צילום / קישור SMS
// ✅ Material Design 3
// ✅ אנימציות חלקות
// ✅ RTL Support מלא
//
// 🔗 Navigation:
// - צילום → ScanReceiptScreen
// - קישור → LinkReceiptScreen
//
// Version: 1.0
// Created: 17/10/2025

import 'package:flutter/material.dart';
import '../core/ui_constants.dart';
import '../core/status_colors.dart';
import '../screens/receipts/scan_receipt_screen.dart';
import '../screens/receipts/link_receipt_screen.dart';

class AddReceiptDialog extends StatelessWidget {
  const AddReceiptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📌 כותרת
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  decoration: BoxDecoration(
                    color: StatusColors.getStatusOverlay('warning', context),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: StatusColors.getStatusColor('warning', context),
                    size: 28,
                  ),
                ),
                const SizedBox(width: kSpacingMedium),
                Expanded(
                  child: Text(
                    'הוסף קבלה חדשה',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingLarge),

            // 🎯 אופציה 1: צילום
            _OptionCard(
              icon: Icons.camera_alt,
              iconStatus: 'info',
              title: 'צילום קבלה',
              subtitle: 'צלם את הקבלה עם המצלמה',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanReceiptScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingMedium),

            // 🎯 אופציה 2: קישור
            _OptionCard(
              icon: Icons.link,
              iconStatus: 'success',
              title: 'קישור מ-SMS',
              subtitle: 'הדבק קישור לקבלה דיגיטלית',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LinkReceiptScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: kSpacingMedium),

            // ❌ כפתור ביטול
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
          ],
        ),
      ),
    );
  }
}

/// כרטיס אופציה אינטראקטיבי
///
/// מציג אייקון, כותרת, תיאור וחץ ניווט.
/// לחיצה על הכרטיס קוראת ל-[onTap] callback.
///
/// Parameters:
/// - [icon]: האייקון להצגה
/// - [iconStatus]: סטטוס לצבע האייקון (מ-StatusColors)
/// - [title]: כותרת ראשית
/// - [subtitle]: תיאור משני
/// - [onTap]: פעולה ללחיצה
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String iconStatus;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconStatus,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = StatusColors.getStatusColor(iconStatus, context);
    final overlayColor = StatusColors.getStatusOverlay(iconStatus, context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 🎨 אייקון
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: kSpacingMedium),

            // 📝 טקסט
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ➡️ חץ
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
