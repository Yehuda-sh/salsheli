// 📄 File: lib/widgets/create_list_dialog.dart
// 
// Purpose: Dialog ליצירת רשימת קניות חדשה עם validation מלא
// 
// Features:
// - Validation למניעת שמות כפולים
// - Validation לתקציב (חייב > 0)
// - Preview ויזואלי לסוג הרשימה הנבחר
// - תמיכה בכל סוגי הרשימות מ-constants.dart (kListTypes)
// - Logging מלא לכל השלבים
// - 9 סוגי רשימות: סופר, מרקחת, חומרי בניין, ביגוד, אלקטרוניקה, חיות מחמד, קוסמטיקה, ציוד משרדי, אחר
//
// Dependencies:
// - ShoppingListsProvider - לבדיקת שמות כפולים
// - constants.dart - kListTypes (סוגי רשימות + אייקונים)
//
// Usage Example:
// showDialog(
//   context: context,
//   builder: (dialogContext) => CreateListDialog(
//     onCreateList: (data) async {
//       await context.read<ShoppingListsProvider>().createList(data);
//     },
//   ),
// );

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/shopping_lists_provider.dart';

class CreateListDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onCreateList;

  const CreateListDialog({super.key, required this.onCreateList});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _type = "super";
  double? _budget;
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    debugPrint('🔵 CreateListDialog._handleSubmit() התחיל');

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('   ⚠️ Validation נכשל');
      return;
    }

    _formKey.currentState?.save();
    debugPrint(
      '   📝 שם: "$_name", סוג: "$_type", תקציב: ${_budget ?? "לא הוגדר"}',
    );

    setState(() => _isSubmitting = true);

    final listData = {
      "name": _name,
      "type": _type,
      "status": "active",
      if (_budget != null) "budget": _budget,
    };

    try {
      debugPrint('   ✅ קורא ל-onCreateList');
      await widget.onCreateList(listData);
      debugPrint('   ✅ onCreateList הושלם בהצלחה');

      if (!mounted) {
        debugPrint('   ⚠️ Widget לא mounted - לא סוגר Dialog');
        return;
      }

      debugPrint('   ✅ סוגר Dialog');
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('   ❌ שגיאה ב-onCreateList: $e');

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת הרשימה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ShoppingListsProvider>();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text("יצירת רשימת קניות חדשה", textAlign: TextAlign.right),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 280, // גובה קבוע
          maxWidth: 400,
        ),
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📝 שם הרשימה
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "שם הרשימה",
                  hintText: "למשל: קניות השבוע",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "נא להזין שם רשימה";
                  }

                  // בדיקת שם כפול
                  final trimmedName = value.trim();
                  final exists = provider.lists.any(
                    (list) =>
                        list.name.trim().toLowerCase() ==
                        trimmedName.toLowerCase(),
                  );

                  if (exists) {
                    return "רשימה בשם זה כבר קיימת";
                  }

                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
                textDirection: TextDirection.rtl,
                autofocus: true,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 12),

              // 📋 סוג הרשימה
              Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButtonFormField<String>(
                  value: _type,
                  isExpanded: true, // מאפשר RTL מלא
                  decoration: const InputDecoration(
                    labelText: "סוג הרשימה",
                  ),
                items: kListTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            entry.value["name"]!,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value["icon"]!,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        debugPrint('🔄 סוג רשימה שונה ל: $value');
                        setState(() => _type = value ?? "super");
                      },
                ),
              ),
              const SizedBox(height: 12),

              // ✨ Preview של הסוג שנבחר
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kListTypes[_type]!["icon"]!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kListTypes[_type]!["name"]!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            kListTypes[_type]!["description"]!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 💰 תקציב
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "תקציב (אופציונלי)",
                  hintText: "₪500",
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+([.,]\d{0,2})?$'),
                  ),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final normalized = value.replaceAll(',', '.');
                    final amount = double.tryParse(normalized);

                    if (amount == null) {
                      return 'נא להזין מספר תקין';
                    }

                    if (amount <= 0) {
                      return 'תקציב חייב להיות גדול מ-0';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    final normalized = value.replaceAll(',', '.');
                    _budget = double.tryParse(normalized);
                  } else {
                    _budget = null;
                  }
                },
                textDirection: TextDirection.rtl,
                enabled: !_isSubmitting,
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("בטל"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(48, 48), // ✅ Touch target
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text("צור רשימה"),
        ),
      ],
    );
  }
}
