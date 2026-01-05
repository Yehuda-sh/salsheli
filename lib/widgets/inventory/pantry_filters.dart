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
import 'package:flutter/services.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingSmall,
          vertical: kSpacingXTiny,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // כפתור איפוס - disabled כשכבר ב-'all'
            Semantics(
              label: AppStrings.common.resetFilter,
              button: true,
              enabled: currentCategory != 'all',
              child: IconButton(
                onPressed: currentCategory == 'all' ? null : _resetFilter,
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: currentCategory == 'all'
                      ? cs.onSurface.withValues(alpha: 0.3)
                      : (brand?.accent ?? cs.primary),
                ),
                tooltip: AppStrings.common.resetFilter,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
            
            const SizedBox(width: kSpacingSmall),
            
            // Dropdown קטגוריה
            Expanded(
              child: _buildCompactDropdown(context),
            ),
            
            const SizedBox(width: kSpacingSmall),
            
            // אייקון וכותרת - עם אינדיקציה לפילטר פעיל
            Icon(
              Icons.filter_list,
              color: currentCategory != 'all'
                  ? cs.primary  // פילטר פעיל - צבע בולט
                  : (brand?.accent ?? cs.primary),
              size: kIconSizeSmall,
            ),
            const SizedBox(width: kSpacingXTiny),
            Text(
              AppStrings.inventory.filterByCategory,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: currentCategory != 'all'
                    ? cs.primary  // פילטר פעיל - צבע בולט
                    : cs.onSurface,
              ),
            ),
            // ✅ Badge לפילטר פעיל
            if (currentCategory != 'all')
              Container(
                margin: const EdgeInsets.only(right: kSpacingXTiny),
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXTiny,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Text(
                  '1',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// בנייה של Dropdown קומפקטי לבחירת קטגוריה
  Widget _buildCompactDropdown(BuildContext context) {
    final currentText = getCategoryLabel(currentCategory);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: '${AppStrings.inventory.filterByCategory}: $currentText',
      child: DropdownButtonFormField<String>(
        initialValue: currentCategory,
        onChanged: (newCategory) {
          if (newCategory != null) {
            HapticFeedback.selectionClick();
            onCategoryChanged(newCategory);
          }
        },
        isExpanded: true,
        isDense: true,
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
            horizontal: kSpacingSmall,
            vertical: kSpacingXTiny,
          ),
          filled: true,
          fillColor: cs.surface,
        ),
        dropdownColor: cs.surfaceContainerHigh,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

