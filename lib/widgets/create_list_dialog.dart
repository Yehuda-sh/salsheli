// 📄 File: lib/widgets/create_list_dialog.dart - REFACTORED
//
// ✅ שיפורים:
// 1. קריאת listTypes מ-constants.dart במקום hard-coded
// 2. הוספת validation למניעת שמות כפולים
// 3. הוספת validation לתקציב (> 0)
// 4. הוספת preview ויזואלי לסוג הרשימה

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart'; // ✅ קריאה מ-constants
import '../providers/shopping_lists_provider.dart';

class CreateListDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreateList;

  const CreateListDialog({super.key, required this.onCreateList});

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _type = "super";
  double? _budget;

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final listData = {
      "name": _name,
      "type": _type,
      "status": "active",
      if (_budget != null) "budget": _budget,
    };

    widget.onCreateList(listData);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ShoppingListsProvider>(context, listen: false);

    return AlertDialog(
      title: const Text("יצירת רשימת קניות חדשה", textAlign: TextAlign.right),
      content: Form(
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

                  // ✅ חדש: בדיקת שם כפול
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
              ),
              const SizedBox(height: 16),

              // 📋 סוג הרשימה - ✅ משתמש ב-kListTypes מ-constants
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: "סוג הרשימה"),
                items: kListTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry.value["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              entry.value["description"]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value["icon"]!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _type = value ?? "super"),
              ),
              const SizedBox(height: 16),

              // ✅ חדש: Preview של הסוג שנבחר
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kListTypes[_type]!["icon"]!,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kListTypes[_type]!["name"]!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          kListTypes[_type]!["description"]!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 💰 תקציב - ✅ עם validation משופר
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
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("בטל"),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text("צור רשימה"),
        ),
      ],
    );
  }
}
