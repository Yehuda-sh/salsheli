// 📄 lib/widgets/dialogs/inventory_settings_dialog.dart
//
// דיאלוג הגדרות מזווה - התראות מלאי נמוך, תפוגה, ותצוגה.
// כולל מצב מזווה (אישי/משותף), שמירה ב-SharedPreferences, ועיצוב sticky note.
//
// ✅ תיקונים:
//    - SingleChildScrollView למניעת overflow במסכים קטנים
//    - צבעים מ-Theme (scheme/brand) במקום Colors קשיחים
//    - כל הטקסטים מ-AppStrings
//    - שורת switch קליקבילית במלואה (InkWell)
//    - barrierDismissible: false למניעת סגירה בטעות
//    - EdgeInsetsDirectional במקום EdgeInsets.only(right:)
//    - הסרת Directionality wrapper - נתן ל-Locale לקבוע
//    - Semantics label מ-AppStrings
//    - צבע sticky מ-brand?.stickyYellow (Theme-aware)
//    - מניעת double-toggle ב-Switch עם AbsorbPointer
//    - SnackBar משתמש ב-errorContainer מה-Theme
//
// 🔗 Related: InventorySettings, InventoryProvider, StickyNote, AppBrand

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../common/sticky_note.dart';

/// מפתחות שמירה ב-SharedPreferences
class _PrefKeys {
  static const lowStockAlert = 'inventory_low_stock_alert';
  static const expiryAlert = 'inventory_expiry_alert';
  static const expiryAlertDays = 'inventory_expiry_alert_days';
  static const showExpiredFirst = 'inventory_show_expired_first';
}

/// הגדרות מזווה
class InventorySettings {
  /// התראה על מלאי נמוך
  final bool lowStockAlert;

  /// התראה על תפוגה קרובה
  final bool expiryAlert;

  /// ימים לפני תפוגה להתראה (ברירת מחדל: 7)
  final int expiryAlertDays;

  /// האם להציג פריטים שפג תוקפם ראשונים
  final bool showExpiredFirst;

  const InventorySettings({
    this.lowStockAlert = true,
    this.expiryAlert = true,
    this.expiryAlertDays = 7,
    this.showExpiredFirst = true,
  });

  InventorySettings copyWith({
    bool? lowStockAlert,
    bool? expiryAlert,
    int? expiryAlertDays,
    bool? showExpiredFirst,
  }) {
    return InventorySettings(
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      expiryAlert: expiryAlert ?? this.expiryAlert,
      expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
      showExpiredFirst: showExpiredFirst ?? this.showExpiredFirst,
    );
  }

  /// טעינה מ-SharedPreferences
  static Future<InventorySettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return InventorySettings(
        lowStockAlert: prefs.getBool(_PrefKeys.lowStockAlert) ?? true,
        expiryAlert: prefs.getBool(_PrefKeys.expiryAlert) ?? true,
        expiryAlertDays: prefs.getInt(_PrefKeys.expiryAlertDays) ?? 7,
        showExpiredFirst: prefs.getBool(_PrefKeys.showExpiredFirst) ?? true,
      );
    } catch (e) {
      return const InventorySettings();
    }
  }

  /// שמירה ל-SharedPreferences
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_PrefKeys.lowStockAlert, lowStockAlert);
      await prefs.setBool(_PrefKeys.expiryAlert, expiryAlert);
      await prefs.setInt(_PrefKeys.expiryAlertDays, expiryAlertDays);
      await prefs.setBool(_PrefKeys.showExpiredFirst, showExpiredFirst);
    } catch (e) {
      // שגיאה בשמירה - התעלם
    }
  }
}

/// מציג דיאלוג הגדרות מזווה
///
/// Example:
/// ```dart
/// final settings = await showInventorySettingsDialog(
///   context: context,
///   inventoryProvider: inventoryProvider,
/// );
/// ```
Future<InventorySettings?> showInventorySettingsDialog({
  required BuildContext context,
  InventoryProvider? inventoryProvider,
}) async {
  final settings = await InventorySettings.load();

  if (!context.mounted) return null;

  return showDialog<InventorySettings>(
    context: context,
    // ✅ מניעת סגירה בלחיצה מחוץ לדיאלוג
    barrierDismissible: false,
    builder: (context) => _InventorySettingsDialog(
      initialSettings: settings,
      inventoryProvider: inventoryProvider,
    ),
  );
}

class _InventorySettingsDialog extends StatefulWidget {
  final InventorySettings initialSettings;
  final InventoryProvider? inventoryProvider;

  const _InventorySettingsDialog({
    required this.initialSettings,
    this.inventoryProvider,
  });

  @override
  State<_InventorySettingsDialog> createState() =>
      _InventorySettingsDialogState();
}

class _InventorySettingsDialogState extends State<_InventorySettingsDialog> {
  late InventorySettings _settings;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  /// עדכון הגדרה עם מעקב שינויים
  void _updateSetting(InventorySettings Function(InventorySettings) update) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _settings = update(_settings);
      _hasChanges = true;
    });
  }

  /// שמירת ההגדרות
  Future<void> _saveSettings() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    unawaited(HapticFeedback.mediumImpact());

    try {
      await _settings.save();
      if (!mounted) return;
      Navigator.pop(context, _settings);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final cs = Theme.of(context).colorScheme;
      // ✅ SnackBar עם errorContainer מה-Theme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: cs.onErrorContainer),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text(AppStrings.common.saveFailed)),
            ],
          ),
          backgroundColor: cs.errorContainer,
        ),
      );
    }
  }

  /// ביטול עם אזהרה אם יש שינויים
  Future<void> _cancel() async {
    if (_hasChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppStrings.common.unsavedChangesTitle),
          content: Text(AppStrings.common.unsavedChangesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.common.stayHere),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.common.exitWithoutSaving),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    unawaited(HapticFeedback.lightImpact());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = theme.extension<AppBrand>();
    final provider = widget.inventoryProvider;

    // ✅ צבע sticky מ-brand (Theme-aware, תומך Dark Mode אוטומטית)
    final stickyColor = brand?.stickyYellow ?? kStickyYellow;

    // ✅ הסרת Directionality - נתן ל-Locale של האפליקציה לקבוע
    return Semantics(
      // ✅ Semantics label מ-AppStrings
      label: AppStrings.inventory.settingsSemanticLabel,
      container: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: StickyNote(
            color: stickyColor,
            // ✅ SingleChildScrollView למניעת overflow
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === כותרת ===
                  Row(
                    children: [
                      Icon(Icons.settings, color: scheme.primary),
                      const SizedBox(width: kSpacingSmall),
                      Text(
                        AppStrings.inventory.settingsTitle,
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kSpacingMedium),

                  // === מצב מזווה (אם יש provider) ===
                  if (provider != null) ...[
                    Container(
                      padding: const EdgeInsets.all(kSpacingSmall),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          kBorderRadiusSmall,
                        ),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: kSpacingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.inventoryTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  AppStrings.inventory.pantryModePersonal,
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacingMedium),
                    const Divider(),
                    const SizedBox(height: kSpacingSmall),
                  ],

                  // === סעיף התראות ===
                  Text(
                    AppStrings.inventory.alertsSectionTitle,
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // התראת מלאי נמוך
                  _SettingSwitch(
                    icon: Icons.inventory_2,
                    iconColor: brand?.warning ?? scheme.tertiary,
                    title: AppStrings.inventory.settingsLowStockAlertTitle,
                    subtitle:
                        AppStrings.inventory.settingsLowStockAlertSubtitle,
                    value: _settings.lowStockAlert,
                    onChanged: (value) {
                      _updateSetting(
                        (s) => s.copyWith(lowStockAlert: value),
                      );
                    },
                  ),

                  // התראת תפוגה
                  _SettingSwitch(
                    icon: Icons.event_busy,
                    iconColor: scheme.error,
                    title: AppStrings.inventory.settingsExpiryAlertTitle,
                    subtitle:
                        AppStrings.inventory.settingsExpiryAlertSubtitle,
                    value: _settings.expiryAlert,
                    onChanged: (value) {
                      _updateSetting(
                        (s) => s.copyWith(expiryAlert: value),
                      );
                    },
                  ),

                  // ימים לפני תפוגה
                  if (_settings.expiryAlert)
                    Padding(
                      // ✅ EdgeInsetsDirectional במקום EdgeInsets.only(right:)
                      padding: const EdgeInsetsDirectional.only(
                        start: 40,
                        top: kSpacingSmall,
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppStrings
                                .inventory
                                .settingsExpiryAlertDaysPrefix,
                            style: TextStyle(color: scheme.onSurface),
                          ),
                          DropdownButton<int>(
                            value: _settings.expiryAlertDays,
                            underline: Container(
                              height: 1,
                              color: scheme.primary,
                            ),
                            items: [3, 5, 7, 14, 30].map((days) {
                              return DropdownMenuItem(
                                value: days,
                                child: Text('$days'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateSetting(
                                  (s) => s.copyWith(expiryAlertDays: value),
                                );
                              }
                            },
                          ),
                          Text(
                            AppStrings
                                .inventory
                                .settingsExpiryAlertDaysSuffix,
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: kSpacingMedium),
                  const Divider(),
                  const SizedBox(height: kSpacingSmall),

                  // === סעיף תצוגה ===
                  Text(
                    AppStrings.inventory.displaySectionTitle,
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // הצג פגי תוקף ראשונים
                  _SettingSwitch(
                    icon: Icons.sort,
                    iconColor: scheme.secondary,
                    title: AppStrings.inventory.showExpiredFirstTitle,
                    subtitle: AppStrings.inventory.showExpiredFirstSubtitle,
                    value: _settings.showExpiredFirst,
                    onChanged: (value) {
                      _updateSetting(
                        (s) => s.copyWith(showExpiredFirst: value),
                      );
                    },
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // === כפתורי פעולה ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: AppStrings.common.cancel,
                        child: TextButton(
                          onPressed: _isSaving ? null : _cancel,
                          child: Text(AppStrings.common.cancel),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Tooltip(
                        message: AppStrings.common.save,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveSettings,
                          child: _isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.onPrimary,
                                  ),
                                )
                              : Text(AppStrings.common.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch עם אייקון וכותרת - קליקבילי במלואו
class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // ✅ InkWell עוטף את כל השורה לקליקביליות מלאה
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: kSpacingTiny),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(kBorderRadiusSmall),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: kSpacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: kFontSizeSmall,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // ✅ AbsorbPointer מונע double-toggle (InkWell מטפל בכל האירועים)
            AbsorbPointer(
              child: Switch(value: value, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }
}
