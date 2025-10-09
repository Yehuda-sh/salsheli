// 📄 File: lib/widgets/pantry_filters.dart
// ignore_for_file: deprecated_member_use

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

import '../config/filters_config.dart';
import '../core/ui_constants.dart';
import '../theme/app_theme.dart';

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

  void _resetFilter() {
    onCategoryChanged('all');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ PantryFilters.build: currentCategory=$currentCategory');
    
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: 'סינון מזווה',
      child: Container(
        padding: const EdgeInsets.all(kSpacingMedium),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.3),
            width: 1,
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
                  "סינון לפי קטגוריה",
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
                    "איפוס סינון",
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

  Widget _buildCategoryDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // קבלת הטקסט הנוכחי
    final currentText = getCategoryLabel(currentCategory);

    return Semantics(
      label: 'סינון לפי קטגוריה: $currentText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // תווית
          Text(
            "קטגוריה",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: kFontSizeSmall,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingSmall),

          // Dropdown
          DropdownButtonFormField<String>(
            value: currentCategory,
            onChanged: (newCategory) {
              if (newCategory != null) {
                debugPrint('📝 PantryFilters: category changed to $newCategory');
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
          ),
        ],
      ),
    );
  }
}
