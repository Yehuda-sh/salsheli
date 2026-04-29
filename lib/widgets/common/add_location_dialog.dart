// lib/widgets/common/add_location_dialog.dart — Add location dialog — create custom pantry storage location

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/custom_location.dart';
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

  try {
    final result = await AppDialog.show<String>(
      context: context,
      // No Directionality(rtl) wrapper — inherit from MaterialApp's
      // locale instead. The previous wrapper would force RTL layout
      // even on an English-locale build.
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cs = Theme.of(ctx).colorScheme;
          return AlertDialog(
            title: Text(AppStrings.inventory.addLocationTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.inventory.selectEmojiLabel,
                    style: const TextStyle(fontSize: kFontSizeTiny),
                  ),
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
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
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
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: kFontSizeTitle),
                          ),
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
                    ),
                    autofocus: true,
                    // textDirection removed — TextField now follows the
                    // ambient Directionality, so an English location name
                    // ("Living Room") aligns LTR on an EN locale.
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
                icon: const Icon(Icons.add_location_alt, size: kIconSizeSmall),
                label: Text(AppStrings.inventory.addLocationButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                ),
                onPressed: controller.text.trim().isEmpty
                    ? null
                    : () async {
                        final name = controller.text.trim();

                        final provider = ctx.read<LocationsProvider>();
                        final navigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(ctx);

                        // Compute the key the same way the provider does,
                        // so we can return it without relying on the
                        // "last item in customLocations" assumption — that
                        // race-conditions if anything else mutates the
                        // list during the await.
                        final newKey = CustomLocation.normalizeKey(name);
                        // Distinguish "already exists" from other failures
                        // (network, permissions). The provider's bool
                        // return collapses both, so we check existence
                        // up front to surface the right message.
                        final alreadyExists = provider.locationExists(newKey);

                        final success = await provider.addLocation(
                          name,
                          emoji: selectedEmoji,
                        );

                        if (!ctx.mounted) return;

                        if (success) {
                          navigator.pop(newKey);
                          return;
                        }

                        messenger
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                alreadyExists
                                    ? AppStrings.inventory.locationExists
                                    : AppStrings.inventory.locationAddError,
                              ),
                            ),
                          );
                      },
              ),
            ],
          );
        },
      ),
    );

    return result;
  } finally {
    controller.dispose();
  }
}
