// 📄 lib/widgets/dialogs/legal_content_dialog.dart
//
// דיאלוג להצגת תוכן משפטי (תנאי שימוש / מדיניות פרטיות)
// עיצוב משודרג: סקשנים מתקפלים, אייקונים, סיכום קצר, היגליטים
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

/// מבנה סעיף משפטי
class _LegalSection {
  final IconData icon;
  final String title;
  final String content;
  final bool isHighlighted;

  const _LegalSection({
    required this.icon,
    required this.title,
    required this.content,
    this.isHighlighted = false,
  });
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

  IconData get _titleIcon {
    switch (type) {
      case LegalContentType.termsOfService:
        return Icons.gavel_rounded;
      case LegalContentType.privacyPolicy:
        return Icons.shield_rounded;
    }
  }

  String get _summary {
    switch (type) {
      case LegalContentType.termsOfService:
        return AppStrings.legal.termsOfServiceSummary;
      case LegalContentType.privacyPolicy:
        return AppStrings.legal.privacyPolicySummary;
    }
  }

  String get _lastUpdated => AppStrings.legal.lastUpdated;

  List<_LegalSection> get _sections {
    switch (type) {
      case LegalContentType.termsOfService:
        return _termsOfServiceSections;
      case LegalContentType.privacyPolicy:
        return _privacyPolicySections;
    }
  }

  List<_LegalSection> get _termsOfServiceSections => [
        _LegalSection(
          icon: Icons.menu_book_rounded,
          title: AppStrings.legal.termsSectionDefinitions,
          content: AppStrings.legal.termsSectionDefinitionsContent,
        ),
        _LegalSection(
          icon: Icons.info_outline_rounded,
          title: AppStrings.legal.termsSectionServiceDescription,
          content: AppStrings.legal.termsSectionServiceDescriptionContent,
        ),
        _LegalSection(
          icon: Icons.person_outline_rounded,
          title: AppStrings.legal.termsSectionAccount,
          content: AppStrings.legal.termsSectionAccountContent,
          isHighlighted: true,
        ),
        _LegalSection(
          icon: Icons.rule_rounded,
          title: AppStrings.legal.termsSectionUsageRules,
          content: AppStrings.legal.termsSectionUsageRulesContent,
        ),
        _LegalSection(
          icon: Icons.folder_outlined,
          title: AppStrings.legal.termsSectionUserContent,
          content: AppStrings.legal.termsSectionUserContentContent,
          isHighlighted: true,
        ),
        _LegalSection(
          icon: Icons.copyright_rounded,
          title: AppStrings.legal.termsSectionIntellectualProperty,
          content: AppStrings.legal.termsSectionIntellectualPropertyContent,
        ),
        _LegalSection(
          icon: Icons.warning_amber_rounded,
          title: AppStrings.legal.termsSectionLiability,
          content: AppStrings.legal.termsSectionLiabilityContent,
        ),
        _LegalSection(
          icon: Icons.cloud_done_outlined,
          title: AppStrings.legal.termsSectionAvailability,
          content: AppStrings.legal.termsSectionAvailabilityContent,
        ),
        _LegalSection(
          icon: Icons.update_rounded,
          title: AppStrings.legal.termsSectionChanges,
          content: AppStrings.legal.termsSectionChangesContent,
        ),
        _LegalSection(
          icon: Icons.balance_rounded,
          title: AppStrings.legal.termsSectionLaw,
          content: AppStrings.legal.termsSectionLawContent,
        ),
        _LegalSection(
          icon: Icons.email_outlined,
          title: AppStrings.legal.termsSectionContact,
          content: AppStrings.legal.termsSectionContactContent,
        ),
      ];

  List<_LegalSection> get _privacyPolicySections => [
        _LegalSection(
          icon: Icons.list_alt_rounded,
          title: AppStrings.legal.privacySectionDataCollected,
          content: AppStrings.legal.privacySectionDataCollectedContent,
          isHighlighted: true,
        ),
        _LegalSection(
          icon: Icons.analytics_outlined,
          title: AppStrings.legal.privacySectionDataUsage,
          content: AppStrings.legal.privacySectionDataUsageContent,
        ),
        _LegalSection(
          icon: Icons.share_outlined,
          title: AppStrings.legal.privacySectionDataSharing,
          content: AppStrings.legal.privacySectionDataSharingContent,
          isHighlighted: true,
        ),
        _LegalSection(
          icon: Icons.lock_outline_rounded,
          title: AppStrings.legal.privacySectionSecurity,
          content: AppStrings.legal.privacySectionSecurityContent,
        ),
        _LegalSection(
          icon: Icons.timer_outlined,
          title: AppStrings.legal.privacySectionRetention,
          content: AppStrings.legal.privacySectionRetentionContent,
        ),
        _LegalSection(
          icon: Icons.verified_user_outlined,
          title: AppStrings.legal.privacySectionRights,
          content: AppStrings.legal.privacySectionRightsContent,
          isHighlighted: true,
        ),
        _LegalSection(
          icon: Icons.child_care_rounded,
          title: AppStrings.legal.privacySectionMinAge,
          content: AppStrings.legal.privacySectionMinAgeContent,
        ),
        _LegalSection(
          icon: Icons.update_rounded,
          title: AppStrings.legal.privacySectionChanges,
          content: AppStrings.legal.privacySectionChangesContent,
        ),
        _LegalSection(
          icon: Icons.email_outlined,
          title: AppStrings.legal.privacySectionContact,
          content: AppStrings.legal.privacySectionContactContent,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sections = _sections;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === כותרת ===
              _buildHeader(theme, scheme),

              // === תוכן ===
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacingSmall,
                    vertical: kSpacingSmall,
                  ),
                  children: [
                    // סיכום קצר
                    _buildSummaryCard(theme, scheme),
                    const SizedBox(height: kSpacingSmall),

                    // סעיפים מתקפלים
                    ...List.generate(sections.length, (i) {
                      return _buildSectionTile(
                        context,
                        theme,
                        scheme,
                        sections[i],
                        i + 1,
                      );
                    }),

                    const SizedBox(height: kSpacingSmall),
                  ],
                ),
              ),

              // === כפתור סגירה ===
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kSpacingMedium,
                  kSpacingSmall,
                  kSpacingMedium,
                  kSpacingMedium,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildHeader(ThemeData theme, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
                child: Icon(
                  _titleIcon,
                  color: scheme.onPrimaryContainer,
                  size: kIconSizeMedium,
                ),
              ),
              const SizedBox(width: kSpacingSmallPlus),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: kSpacingXTiny),
                    Text(
                      _lastUpdated,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme scheme) {
    return Card(
      elevation: 0,
      color: scheme.tertiaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingSmallPlus),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: scheme.onTertiaryContainer,
              size: kIconSizeMedium,
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Text(
                _summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onTertiaryContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    _LegalSection section,
    int index,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: kSpacingXTiny),
      color: section.isHighlighted
          ? scheme.secondaryContainer.withValues(alpha: 0.3)
          : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        side: section.isHighlighted
            ? BorderSide(
                color: scheme.secondary.withValues(alpha: 0.3),
                width: 1,
              )
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: kIconSizeLarge,
          height: kIconSizeLarge,
          decoration: BoxDecoration(
            color: section.isHighlighted
                ? scheme.secondary.withValues(alpha: 0.15)
                : scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Icon(
            section.icon,
            size: kIconSizeSmall + 4,
            color: section.isHighlighted
                ? scheme.secondary
                : scheme.primary,
          ),
        ),
        title: Text(
          '$index. ${section.title}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          kSpacingMedium,
          0,
          kSpacingMedium,
          kSpacingSmallPlus,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: kSpacingSmall),
          Text(
            section.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
