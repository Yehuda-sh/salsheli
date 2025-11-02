// 📄 File: lib/widgets/inventory/pantry_filters.dart
//
// 🎯 Purpose: ווידג'ט סינון למסך המזווה - קטגוריה בלבד
//
// ✨ Features:
// - סינון לפי קטגוריה (חלב, בשר, ירקות וכו')
// - כפתור איפוס
// - תואם Material Design: גדלי מגע 48px, theme colors
// - מופשט מ-ItemFilters אבל ללא status filter
//
// 📋 Usage:
// ```dart
// PantryFilters(
//   currentCategory: _selectedCategory,
//   onCategoryChanged: (category) {
//     setState(() => _selectedCategory = category);
//   },
// )
// ```
//
// 🔗 Related:
// - filters_config.dart (kCategories, getCategoryLabel)
// - my_pantry_screen.dart (משתמש בwidget זה)
// - Theme colors (AppBrand)

import 'package:flutter/material.dart';

import 'package:memozap/config/filters_config.dart';
import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/theme/app_theme.dart';

class PantryFilters extends StatelessWidget {
  /// הקטגוריה הנוכחית הנבחרת (למשל 'dairy' או 'all')
  final String currentCategory;
  
  /// Callback שנקרא כשהמשתמש משנה קטגוריה
  final void Function(String) onCategoryChanged;

  const PantryFilters({
    super.key,
    required this.currentCategory,
    required this.onCategoryChanged,
  });

  /// איפוס הסינון לערך ברירת המחדל ('all')
  ///
  /// קורא ל-onCategoryChanged עם 'all' כדי להציג את כל הפריטים
  void _resetFilter() {
    onCategoryChanged('all');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: AppStrings.inventory.filterLabel,
      child: Container(
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // כותרת
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppStrings.inventory.filterByCategory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSizeBody,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Icon(
                  Icons.filter_list,
                  color: brand?.accent ?? cs.primary,
                  size: kIconSizeMedium,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // Dropdown קטגוריה
            _buildCategoryDropdown(context),
            
            const SizedBox(height: kSpacingMedium),

            // כפתור איפוס
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: kButtonHeight,
                child: TextButton.icon(
                  onPressed: _resetFilter,
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: brand?.accent ?? cs.primary,
                  ),
                  label: Text(
                    AppStrings.common.resetFilter,
                    style: TextStyle(
                      color: brand?.accent ?? cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// בנייה של Dropdown לבחירת קטגוריה
  ///
  /// מפוצל ל-2 פונקציות עזר: _buildDropdownLabel + _buildDropdownField
  Widget _buildCategoryDropdown(BuildContext context) {
    final currentText = getCategoryLabel(currentCategory);

    return Semantics(
      label: '${AppStrings.inventory.filterByCategory}: $currentText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildDropdownLabel(context),
          const SizedBox(height: kSpacingSmall),
          _buildDropdownField(context),
        ],
      ),
    );
  }

  /// בנייה של תווית הDropdown
  Widget _buildDropdownLabel(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Text(
      AppStrings.inventory.categoryLabel,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: kFontSizeSmall,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
    );
  }

  /// בנייה של שדה הDropdown עצמו
  ///
  /// תכונות:
  /// - DropdownButtonFormField עם כל הקטגוריות מ-kCategories
  /// - RTL support: textDirection: TextDirection.rtl
  /// - Theme-aware: צבעים מ-AppBrand + colorScheme
  /// - Styling: border, focused color, dropdownColor
  Widget _buildDropdownField(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return DropdownButtonFormField<String>(
      initialValue: currentCategory,
      onChanged: (newCategory) {
        if (newCategory != null) {
          onCategoryChanged(newCategory);
        }
      },
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide(
            color: brand?.accent ?? cs.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmallPlus,
          vertical: kSpacingSmallPlus + 2,
        ),
        filled: true,
        fillColor: cs.surface,
      ),
      dropdownColor: cs.surfaceContainerHigh,
      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
      icon: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
      items: kCategories.map((id) {
        final displayText = getCategoryLabel(id);
        return DropdownMenuItem<String>(
          value: id,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              displayText,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

