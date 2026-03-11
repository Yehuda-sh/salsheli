// 📄 lib/widgets/common/add_location_dialog.dart
//
// 🎯 דיאלוג משותף להוספת מיקום אחסון חדש
// משמש ב: my_pantry_screen, pantry_product_selection_sheet

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locations_provider.dart';

/// רשימת אמוג'י לבחירה
const kLocationEmojis = [
  '📍', '🏠', '❄️', '🧊', '📦', '🛁', '🧺', '🚗', '🧼', '🧂',
  '🍹', '🍕', '🎁', '🎒', '🧰', '🎨', '📚', '🔧', '🏺', '🗄️',
];

/// מציג דיאלוג להוספת מיקום חדש.
/// מחזיר את ה-key של המיקום החדש, או null אם בוטל.
Future<String?> showAddLocationDialog(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;
  final controller = TextEditingController();
  String selectedEmoji = '📍';

  final result = await showDialog<String>(
    context: context,
    barrierColor: cs.scrim.withValues(alpha: 0.3),
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: kGlassBlurLow, sigmaY: kGlassBlurLow),
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(AppStrings.inventory.addLocationTitle),
                content: Column(
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
                          onTap: () => setDialogState(() => selectedEmoji = emoji),
                          child: Container(
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
                      decoration: InputDecoration(
                        labelText: AppStrings.inventory.locationNameLabel,
                        hintText: AppStrings.inventory.locationNameHint,
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(AppStrings.common.cancel),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_location_alt, size: kIconSizeSmall),
                    label: Text(AppStrings.inventory.addLocationButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                    ),
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      final provider = context.read<LocationsProvider>();
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(context);

                      final success =
                          await provider.addLocation(name, emoji: selectedEmoji);

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
    },
  );

  return result;
}
