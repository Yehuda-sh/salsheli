// 📄 lib/widgets/inventory/pantry_suggestions.dart
//
// 🧠 הצעות חכמות למזווה — "כדאי שיהיה בבית"
//
// חוקי הצגה:
// - 0 פריטים → עד 8 הצעות
// - 1-14 → עד 4 הצעות
// - 15+ → לא מציג
// - הצעה שנדחתה → לא חוזרת (SharedPreferences)
// - "הסתר הצעות" → נעלם ל-24 שעות, אחר כך חוזר

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

const _kDismissedKey = 'pantry_dismissed_suggestions';
const _kHiddenUntilKey = 'pantry_suggestions_hidden_until';

/// Suggestion item from pantry_basic.json
class _Suggestion {
  final String name; // שם מלא מהקטלוג
  final String displayName; // שם גנרי להצגה
  final String category; // קטגוריה מהקטלוג
  final String emoji;
  final int quantity;
  final String unit;

  _Suggestion({
    required this.name,
    required this.displayName,
    required this.category,
    required this.emoji,
    required this.quantity,
    required this.unit,
  });
}

class PantrySuggestions extends StatefulWidget {
  /// מספר הפריטים הנוכחי במזווה
  final int currentItemCount;

  /// שמות המוצרים שכבר במזווה (lowercase)
  final Set<String> existingProductNames;

  /// Callback להוספת מוצר למזווה
  final Future<void> Function(String name, String category, int quantity, String unit)
      onAddItem;

  const PantrySuggestions({
    required this.currentItemCount,
    required this.existingProductNames,
    required this.onAddItem,
    super.key,
  });

  @override
  State<PantrySuggestions> createState() => _PantrySuggestionsState();
}

class _PantrySuggestionsState extends State<PantrySuggestions> {
  List<_Suggestion> _suggestions = [];
  Set<String> _dismissed = {};
  bool _hidden = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenUntilMs = prefs.getInt(_kHiddenUntilKey) ?? 0;
    _hidden = DateTime.now().millisecondsSinceEpoch < hiddenUntilMs;
    final dismissedJson = prefs.getStringList(_kDismissedKey) ?? [];
    _dismissed = dismissedJson.toSet();

    if (_hidden) {
      setState(() => _loaded = true);
      return;
    }

    try {
      final jsonStr =
          await rootBundle.loadString('assets/templates/pantry_basic.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final items = data['items'] as List;

      final suggestions = <_Suggestion>[];
      for (final item in items) {
        final fullName = item['name'] as String;
        final displayName = item['displayName'] as String;
        final nameLower = displayName.toLowerCase();

        // Skip if already in pantry or dismissed
        if (widget.existingProductNames.contains(nameLower)) continue;
        if (widget.existingProductNames.contains(fullName.toLowerCase())) continue;
        if (_dismissed.contains(nameLower)) continue;

        suggestions.add(_Suggestion(
          name: fullName,
          displayName: displayName,
          category: (item['category'] as String?) ?? 'כללי',
          emoji: (item['emoji'] as String?) ?? '📦',
          quantity: (item['quantity'] as num).toInt(),
          unit: item['unit'] as String,
        ));
      }

      setState(() {
        _suggestions = suggestions;
        _loaded = true;
      });
    } catch (_) {
      setState(() => _loaded = true);
    }
  }

  Future<void> _dismissSuggestion(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _dismissed.add(name.toLowerCase());
    await prefs.setStringList(_kDismissedKey, _dismissed.toList());
    setState(() {
      _suggestions.removeWhere((s) => s.name.toLowerCase() == name.toLowerCase());
    });
  }

  Future<void> _hideAll() async {
    final prefs = await SharedPreferences.getInstance();
    final hideUntil = DateTime.now().add(const Duration(hours: 24));
    await prefs.setInt(_kHiddenUntilKey, hideUntil.millisecondsSinceEpoch);
    setState(() => _hidden = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _hidden) return const SizedBox.shrink();

    // חוקי הצגה
    final maxSuggestions = widget.currentItemCount == 0
        ? 8
        : widget.currentItemCount < 15
            ? 4
            : 0;

    if (maxSuggestions == 0 || _suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = _suggestions.take(maxSuggestions).toList();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '💡 ${AppStrings.pantry.suggestionsTitle}',
                style: TextStyle(
                  fontSize: kFontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _hideAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.pantry.hideSuggestions,
                  style: TextStyle(
                    fontSize: kFontSizeTiny,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          // Suggestion chips
          Wrap(
            spacing: kSpacingSmall,
            runSpacing: kSpacingSmall,
            children: visible.map((s) => _buildChip(s, cs)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(_Suggestion s, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add button
          InkWell(
            onTap: () async {
              await widget.onAddItem(s.name, s.category, s.quantity, s.unit);
              if (mounted) {
                setState(() {
                  _suggestions.remove(s);
                });
              }
            },
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(kBorderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: kSpacingTiny,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.emoji, style: const TextStyle(fontSize: kFontSizeBody)),
                  const SizedBox(width: 4),
                  Text(
                    s.displayName,
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.add_circle_outline,
                      size: kIconSizeSmall, color: cs.primary),
                ],
              ),
            ),
          ),
          // Dismiss button
          InkWell(
            onTap: () => _dismissSuggestion(s.displayName),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(kBorderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingTiny,
                vertical: kSpacingTiny,
              ),
              child: Icon(Icons.close,
                  size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
