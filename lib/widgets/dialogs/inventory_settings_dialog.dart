// 📄 File: lib/widgets/dialogs/inventory_settings_dialog.dart
// 🎯 Purpose: דיאלוג הגדרות מזווה מהירות
//
// 📋 Features:
// - הגדרת התראות מלאי נמוך
// - הגדרת התראות תפוגה
// - הגדרות תצוגה
// - מצב מזווה (אישי/משותף)
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_constants.dart';
import '../../providers/inventory_provider.dart';
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
  State<_InventorySettingsDialog> createState() => _InventorySettingsDialogState();
}

class _InventorySettingsDialogState extends State<_InventorySettingsDialog> {
  late InventorySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = widget.inventoryProvider;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: StickyNote(
            color: kStickyYellow,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === כותרת ===
                  Row(
                    children: [
                      Icon(Icons.settings, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      const Text(
                        'הגדרות מזווה',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
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
                        color: provider.isGroupMode
                            ? Colors.green.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                        border: Border.all(
                          color: provider.isGroupMode
                              ? Colors.green.shade200
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.isGroupMode
                                ? Icons.family_restroom
                                : Icons.person,
                            color: provider.isGroupMode
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
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
                                    color: provider.isGroupMode
                                        ? Colors.green.shade800
                                        : Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  provider.isGroupMode
                                      ? 'מחובר למזווה משותף של הקבוצה'
                                      : 'מזווה אישי - רק שלך',
                                  style: TextStyle(
                                    fontSize: kFontSizeSmall,
                                    color: Colors.grey.shade600,
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
                  const Text(
                    'התראות',
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // התראת מלאי נמוך
                  _SettingSwitch(
                    icon: Icons.inventory_2,
                    iconColor: Colors.orange,
                    title: 'התראת מלאי נמוך',
                    subtitle: 'קבל התראה כשפריט מגיע למינימום',
                    value: _settings.lowStockAlert,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(lowStockAlert: value);
                      });
                    },
                  ),

                  // התראת תפוגה
                  _SettingSwitch(
                    icon: Icons.event_busy,
                    iconColor: Colors.red,
                    title: 'התראת תפוגה',
                    subtitle: 'קבל התראה על מוצרים שעומדים לפוג',
                    value: _settings.expiryAlert,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(expiryAlert: value);
                      });
                    },
                  ),

                  // ימים לפני תפוגה
                  if (_settings.expiryAlert)
                    Padding(
                      padding: const EdgeInsets.only(right: 40, top: kSpacingSmall),
                      child: Row(
                        children: [
                          const Text('התראה '),
                          DropdownButton<int>(
                            value: _settings.expiryAlertDays,
                            underline: Container(
                              height: 1,
                              color: cs.primary,
                            ),
                            items: [3, 5, 7, 14, 30].map((days) {
                              return DropdownMenuItem(
                                value: days,
                                child: Text('$days'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _settings = _settings.copyWith(expiryAlertDays: value);
                                });
                              }
                            },
                          ),
                          const Text(' ימים לפני תפוגה'),
                        ],
                      ),
                    ),

                  const SizedBox(height: kSpacingMedium),
                  const Divider(),
                  const SizedBox(height: kSpacingSmall),

                  // === סעיף תצוגה ===
                  const Text(
                    'תצוגה',
                    style: TextStyle(
                      fontSize: kFontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // הצג פגי תוקף ראשונים
                  _SettingSwitch(
                    icon: Icons.sort,
                    iconColor: Colors.purple,
                    title: 'הצג פגי תוקף ראשונים',
                    subtitle: 'פריטים שפג תוקפם יופיעו בראש הרשימה',
                    value: _settings.showExpiredFirst,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(showExpiredFirst: value);
                      });
                    },
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // === כפתורי פעולה ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ביטול'),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      ElevatedButton(
                        onPressed: () async {
                          await _settings.save();
                          if (context.mounted) {
                            Navigator.pop(context, _settings);
                          }
                        },
                        child: const Text('שמור'),
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

/// Switch עם אייקון וכותרת
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
    return Padding(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
