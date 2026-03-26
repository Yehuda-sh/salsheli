// 📄 lib/widgets/dialogs/legal_content_dialog.dart
//
// דיאלוג להצגת תוכן משפטי (תנאי שימוש / מדיניות פרטיות)
//
// 🔗 Related: welcome_screen.dart, settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../common/app_dialog.dart';

/// סוג התוכן המשפטי
enum LegalContentType {
  termsOfService,
  privacyPolicy,
}

/// מציג דיאלוג תנאי שימוש
Future<void> showTermsOfServiceDialog(BuildContext context) {
  return showLegalContentDialog(
    context: context,
    type: LegalContentType.termsOfService,
  );
}

/// מציג דיאלוג מדיניות פרטיות
Future<void> showPrivacyPolicyDialog(BuildContext context) {
  return showLegalContentDialog(
    context: context,
    type: LegalContentType.privacyPolicy,
  );
}

/// מציג דיאלוג תוכן משפטי
Future<void> showLegalContentDialog({
  required BuildContext context,
  required LegalContentType type,
}) {
  return AppDialog.show(
    context: context,
    child: _LegalContentDialog(type: type),
  );
}

class _LegalContentDialog extends StatelessWidget {
  final LegalContentType type;

  const _LegalContentDialog({required this.type});

  String get _title {
    switch (type) {
      case LegalContentType.termsOfService:
        return AppStrings.welcome.termsOfService;
      case LegalContentType.privacyPolicy:
        return AppStrings.welcome.privacyPolicy;
    }
  }

  String get _content {
    switch (type) {
      case LegalContentType.termsOfService:
        return AppStrings.legal.termsOfServiceContent;
      case LegalContentType.privacyPolicy:
        return AppStrings.legal.privacyPolicyContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === כותרת ===
              Container(
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kBorderRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      type == LegalContentType.termsOfService
                          ? Icons.description_outlined
                          : Icons.privacy_tip_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        _title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: scheme.onPrimaryContainer,
                      tooltip: AppStrings.common.close,
                    ),
                  ],
                ),
              ),

              // === תוכן עם fade hint בתחתית ===
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.surface,
                      scheme.surface,
                      scheme.surface.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.85, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      kSpacingMedium, kSpacingMedium, kSpacingMedium, kSpacingLarge,
                    ),
                    child: Text(
                      _content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
              ),

              // === כפתור סגירה ===
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    child: Text(AppStrings.common.understood),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
