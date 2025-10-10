// 📄 File: lib/screens/lists/templates_screen.dart
//
// Purpose: מסך ראשי לניהול תבניות רשימות
//
// Features:
// - רשימת תבניות (System + Personal + Shared)
// - Tabs/Filters: הכל / שלי / משותפות / מערכת
// - 3 Empty States: Loading/Error/Empty
// - FAB ליצירת תבנית חדשה
// - כרטיס לכל תבנית: שם, אייקון, מספר פריטים, פורמט
// - לחיצה → ניווט לעריכה או שימוש ישיר
//
// Dependencies:
// - TemplatesProvider - קריאת תבניות
// - constants.dart - kListTypes (אייקונים)
// - AppStrings - מחרוזות UI
//
// Usage:
// Navigator.pushNamed(context, '/templates');

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/templates_provider.dart';
import '../../models/template.dart';
import '../../core/constants.dart';
import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import 'template_form_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedFilter = 'all'; // all, mine, shared, system

  @override
  void initState() {
    super.initState();
    debugPrint('📋 TemplatesScreen.initState()');
    
    // טען תבניות
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplatesProvider>().loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 TemplatesScreen.build()');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.templates.title),
        centerTitle: true,
      ),
      body: Consumer<TemplatesProvider>(
        builder: (context, provider, _) {
          // ========================================
          // Loading State
          // ========================================
          if (provider.isLoading) {
            debugPrint('⏳ TemplatesScreen: Loading...');
            return _buildLoading();
          }

          // ========================================
          // Error State
          // ========================================
          if (provider.hasError) {
            debugPrint('❌ TemplatesScreen: Error - ${provider.errorMessage}');
            return _buildError(
              provider.errorMessage!,
              () => provider.loadTemplates(),
            );
          }

          // ========================================
          // Content
          // ========================================
          final templates = _getFilteredTemplates(provider);
          
          debugPrint('✅ TemplatesScreen: ${templates.length} תבניות');

          return Column(
            children: [
              // ========================================
              // Filters
              // ========================================
              _buildFilters(theme),

              // ========================================
              // Empty State
              // ========================================
              if (templates.isEmpty)
                Expanded(child: _buildEmptyState()),

              // ========================================
              // Templates List
              // ========================================
              if (templates.isNotEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.loadTemplates(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return _buildTemplateCard(template, provider);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      
      // ========================================
      // FAB - יצירת תבנית חדשה
      // ========================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.templates.createButton),
        tooltip: AppStrings.templates.createButton,
      ),
    );
  }

  // ========================================
  // Filters Row
  // ========================================
  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', AppStrings.templates.filterAll, theme),
            const SizedBox(width: kSpacingSmall),
            _buildFilterChip('mine', AppStrings.templates.filterMine, theme),
            const SizedBox(width: kSpacingSmall),
            _buildFilterChip('shared', AppStrings.templates.filterShared, theme),
            const SizedBox(width: kSpacingSmall),
            _buildFilterChip('system', AppStrings.templates.filterSystem, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          debugPrint('🔄 סינון שונה ל: $value');
          setState(() => _selectedFilter = value);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  // ========================================
  // Template Card
  // ========================================
  Widget _buildTemplateCard(Template template, TemplatesProvider provider) {
    final theme = Theme.of(context);
    final typeInfo = kListTypes[template.type] ?? kListTypes['other']!;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      elevation: kCardElevation,
      child: InkWell(
        onTap: () => _navigateToForm(context, template: template),
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================
              // Header: אייקון + שם + פורמט
              // ========================================
              Row(
                children: [
                  // אייקון
                  Container(
                    width: kIconSizeLarge * 1.5,
                    height: kIconSizeLarge * 1.5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Center(
                      child: Text(
                        typeInfo['icon']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingMedium),

                  // שם + תיאור
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (template.description.isNotEmpty) ...[
                          const SizedBox(height: kSpacingTiny),
                          Text(
                            template.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // פורמט Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: _getFormatColor(template.defaultFormat, theme),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      _getFormatLabel(template.defaultFormat),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),

              // ========================================
              // Footer: מספר פריטים + Actions
              // ========================================
              Row(
                children: [
                  // מספר פריטים
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: kIconSizeMedium,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: kSpacingXTiny),
                  Text(
                    AppStrings.templates.itemsCount(template.defaultItems.length),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  // ========================================
                  // Actions (רק אם לא system)
                  // ========================================
                  if (!template.isSystem) ...[
                    // כפתור עריכה
                    IconButton(
                      onPressed: () => _navigateToForm(context, template: template),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: AppStrings.templates.editButton,
                      iconSize: kIconSizeMedium,
                    ),

                    // כפתור מחיקה
                    IconButton(
                      onPressed: () => _confirmDelete(context, template, provider),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: AppStrings.templates.deleteButton,
                      color: theme.colorScheme.error,
                      iconSize: kIconSizeMedium,
                    ),
                  ],

                  // כפתור שימוש
                  IconButton(
                    onPressed: () => _useTemplate(context, template),
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: AppStrings.templates.useTemplateButton,
                    iconSize: kIconSizeMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // Loading State
  // ========================================
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: kSpacingMedium),
          Text('טוען תבניות...'),
        ],
      ),
    );
  }

  // ========================================
  // Error State
  // ========================================
  Widget _buildError(String error, VoidCallback onRetry) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: kIconSizeXLarge,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              'שגיאה בטעינת תבניות',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.priceComparison.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Empty State
  // ========================================
  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    // בחירת Empty State לפי סינון
    String title;
    String message;
    String? buttonText;

    switch (_selectedFilter) {
      case 'mine':
        title = AppStrings.templates.emptyMyTemplatesTitle;
        message = AppStrings.templates.emptyMyTemplatesMessage;
        buttonText = AppStrings.templates.emptyStateButton;
        break;
      case 'shared':
        title = AppStrings.templates.emptySharedTemplatesTitle;
        message = AppStrings.templates.emptySharedTemplatesMessage;
        buttonText = null; // אין כפתור - תלוי בחברי קבוצה
        break;
      case 'system':
        title = 'תבניות המערכת';
        message = 'תבניות המערכת עדיין בפיתוח';
        buttonText = null;
        break;
      default:
        title = AppStrings.templates.emptyStateTitle;
        message = AppStrings.templates.emptyStateMessage;
        buttonText = AppStrings.templates.emptyStateButton;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: kIconSizeXLarge,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null) ...[
              const SizedBox(height: kSpacingLarge),
              ElevatedButton.icon(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, kButtonHeight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========================================
  // Helpers
  // ========================================

  /// סינון תבניות לפי הפילטר שנבחר
  List<Template> _getFilteredTemplates(TemplatesProvider provider) {
    switch (_selectedFilter) {
      case 'mine':
        return provider.personalTemplates;
      case 'shared':
        return provider.sharedTemplates;
      case 'system':
        return provider.systemTemplates;
      default:
        return provider.templates;
    }
  }

  /// קבלת צבע לפי פורמט
  Color _getFormatColor(String format, ThemeData theme) {
    switch (format) {
      case 'system':
        return theme.colorScheme.tertiaryContainer;
      case 'shared':
        return theme.colorScheme.secondaryContainer;
      case 'assigned':
        return theme.colorScheme.errorContainer;
      default:
        return theme.colorScheme.primaryContainer;
    }
  }

  /// קבלת תווית לפי פורמט
  String _getFormatLabel(String format) {
    switch (format) {
      case 'system':
        return AppStrings.templates.formatSystem;
      case 'shared':
        return AppStrings.templates.formatShared;
      case 'assigned':
        return AppStrings.templates.formatAssigned;
      default:
        return AppStrings.templates.formatPersonal;
    }
  }

  // ========================================
  // Navigation & Actions
  // ========================================

  /// ניווט לטופס יצירה/עריכה
  Future<void> _navigateToForm(
    BuildContext context, {
    Template? template,
  }) async {
    debugPrint('➡️ ניווט לטופס${template != null ? ' עריכה' : ' יצירה'}');

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateFormScreen(template: template),
      ),
    );

    // רענון אם נוצר/עודכן
    if (result == true) {
      if (!mounted) return;
      debugPrint('✅ חזרה מטופס - מרענן רשימה');
      context.read<TemplatesProvider>().loadTemplates();
    }
  }

  /// שימוש בתבנית
  /// TODO: ליישם - ניווט למסך יצירת רשימה עם הפריטים מהתבנית
  void _useTemplate(BuildContext context, Template template) {
    debugPrint('✨ שימוש בתבנית: ${template.name}');
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('שימוש בתבנית "${template.name}" - בקרוב!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// אישור מחיקה
  Future<void> _confirmDelete(
    BuildContext context,
    Template template,
    TemplatesProvider provider,
  ) async {
    debugPrint('🗑️ בקשת מחיקה: ${template.name}');

    // שמירת theme לפני async
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.templates.deleteConfirmTitle),
        content: Text(AppStrings.templates.deleteConfirmMessage(template.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.templates.deleteCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(AppStrings.templates.deleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteTemplate(context, template, provider);
    }
  }

  /// ביצוע מחיקה עם Undo
  Future<void> _deleteTemplate(
    BuildContext context,
    Template template,
    TemplatesProvider provider,
  ) async {
    debugPrint('🗑️ מוחק תבנית: ${template.name}');

    // שמירת references לפני async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      await provider.deleteTemplate(template.id);

      if (!mounted) return;

      // הצגת Undo SnackBar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.templates.templateDeleted(template.name)),
          duration: kSnackBarDurationLong,
          backgroundColor: theme.colorScheme.error,
          action: SnackBarAction(
            label: AppStrings.templates.undo,
            textColor: Colors.white,
            onPressed: () async {
              debugPrint('↩️ משחזר תבנית: ${template.name}');
              await provider.restoreTemplate(template);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ שגיאה במחיקת תבנית: $e');
      
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.templates.deleteError(e.toString())),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}
