// 📄 File: lib/widgets/item_filters.dart
// ignore_for_file: deprecated_member_use

// תיאור: ווידג'ט סינון פריטים לפי קטגוריה וסטטוס
//
// תכונות:
// - סינון לפי קטגוריה (חלב, בשר, ירקות וכו')
// - סינון לפי סטטוס (ממתין, נלקח, חסר, הוחלף)
// - כפתור איפוס לכל הסינונים
// - תואם Material Design: גדלי מגע 48px, theme colors
//
// תלויות:
// - filters_config.dart (kCategories, kStatuses, getCategoryLabel, getStatusLabel)
// - Theme colors

import 'package:flutter/material.dart';

import '../config/filters_config.dart';
import '../theme/app_theme.dart';

// קבועים
const double _kContainerPadding = 16.0;
const double _kCardBorderRadius = 12.0;
const double _kTitleFontSize = 16.0;
const double _kLabelFontSize = 14.0;
const double _kResetButtonMinHeight = 48.0;

class ItemFilters extends StatelessWidget {
  final Map<String, String> filters;
  final void Function(Map<String, String>) setFilters;

  const ItemFilters({
    super.key,
    required this.filters,
    required this.setFilters,
  });

  void _updateFilter(String key, String? value) {
    if (value == null) return;
    setFilters({...filters, key: value});
  }

  void _resetFilters() {
    setFilters({"category": "all", "status": "all"});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: 'סינון פריטים',
      child: Container(
        padding: const EdgeInsets.all(_kContainerPadding),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
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
                  "סינון פריטים",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: _kTitleFontSize,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.filter_list,
                  color: brand?.accent ?? cs.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // סינון לפי קטגוריה
            _buildDropdown(
              context: context,
              label: "סינון לפי קטגוריה",
              value: filters["category"] ?? "all",
              items: kCategories,
              onChanged: (val) => _updateFilter("category", val),
            ),
            const SizedBox(height: 16),

            // סינון לפי סטטוס
            _buildDropdown(
              context: context,
              label: "סינון לפי סטטוס",
              value: filters["status"] ?? "all",
              items: kStatuses,
              onChanged: (val) => _updateFilter("status", val),
            ),
            const SizedBox(height: 16),

            // כפתור איפוס
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: _kResetButtonMinHeight,
                child: TextButton.icon(
                  onPressed: _resetFilters,
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

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // קבלת הטקסט הנוכחי
    final currentText = label.contains('קטגוריה')
        ? getCategoryLabel(value)
        : getStatusLabel(value);

    return Semantics(
      label: '$label: $currentText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // תווית
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: _kLabelFontSize,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: brand?.accent ?? cs.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              filled: true,
              fillColor: cs.surface,
            ),
            dropdownColor: cs.surfaceContainerHigh,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
            icon: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
            items: items.map((id) {
              final displayText = label.contains('קטגוריה')
                  ? getCategoryLabel(id)
                  : getStatusLabel(id);
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
