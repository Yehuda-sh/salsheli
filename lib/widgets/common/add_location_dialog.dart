// 📄 lib/widgets/common/add_location_dialog.dart
//
// 🎯 דיאלוג משותף להוספת מיקום אחסון חדש
// משמש ב: my_pantry_screen, pantry_product_selection_sheet

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locations_provider.dart';
import 'app_dialog.dart';

/// רשימת אימוג'י לבחירה — למיקומים מותאמים אישית בלבד
/// (מיקומים מובנים כבר קיימים ב-StorageLocations עם אימוג'ים משלהם)
/// מקור: Unicode Emoji v17.0 — Household Objects
const kLocationEmojis = [
  // חדרים (אין להם מיקום מובנה)
  '🛏️', // חדר שינה
  '🛋️', // סלון
  '👶', // חדר ילדים
  '💼', // חדר עבודה / משרד
  // אזורים נוספים
  '🚗', // רכב / חניה
  '🌤️', // מרפסת
  '🏠', // בית כללי
  '🧹', // חדר שירות
  // אחסון מותאם
  '🗄️', // ארון / מגירות
  '🧰', // ארגז כלים
  '📍', // מיקום אחר
];

/// מציג דיאלוג להוספת מיקום חדש.
/// מחזיר את ה-key של המיקום החדש, או null אם בוטל.
Future<String?> showAddLocationDialog(BuildContext context) async {
  final controller = TextEditingController();
  String selectedEmoji = kLocationEmojis.first;

  final result = await AppDialog.show<String>(
    context: context,
    child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            final cs = Theme.of(ctx).colorScheme;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(AppStrings.inventory.addLocationTitle),
                content: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppStrings.inventory.selectEmojiLabel,
                        style: const TextStyle(fontSize: kFontSizeTiny)),
                    const SizedBox(height: kSpacingSmall),
                    Wrap(
                      spacing: kSpacingSmall,
                      runSpacing: kSpacingSmall,
                      children: kLocationEmojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji;
                        return GestureDetector(
                          onTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            setDialogState(() => selectedEmoji = emoji);
                          },
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                            padding: const EdgeInsets.all(kSpacingSmall),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(kBorderRadiusSmall),
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : Colors.transparent,
                                width: kBorderWidthThick,
                              ),
                            ),
                            child: Text(emoji,
                                style: const TextStyle(fontSize: kIconSize)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    TextField(
                      controller: controller,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.locationNameLabel,
                        hintText: AppStrings.inventory.locationNameHint,
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppStrings.common.cancel),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_location_alt, size: kIconSizeSmall),
                    label: Text(AppStrings.inventory.addLocationButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                    ),
                    onPressed: controller.text.trim().isEmpty ? null : () async {
                      final name = controller.text.trim();

                      final provider = ctx.read<LocationsProvider>();
                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(ctx);

                      final success =
                          await provider.addLocation(name, emoji: selectedEmoji);

                      if (!ctx.mounted) return;

                      if (success) {
                        final newLoc = provider.customLocations.lastOrNull;
                        navigator.pop(newLoc?.key);
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                              content:
                                  Text(AppStrings.inventory.locationExists)),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
  );

  return result;
}
