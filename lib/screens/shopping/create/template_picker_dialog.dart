// 📄 File: lib/screens/shopping/create/template_picker_dialog.dart
//
// Purpose: דיאלוג לבחירת תבנית רשימה מוכנה
//
// Version: 1.0
// Last Updated: 26/11/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_strings.dart';
import '../../../services/template_service.dart';

/// דיאלוג לבחירת תבנית רשימה מוכנה
class TemplatePickerDialog extends StatelessWidget {
  final List<TemplateInfo> templates;

  const TemplatePickerDialog({super.key, required this.templates});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.createListDialog;

    // 🔧 RTL wrapper להבטחת כיווניות נכונה
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(strings.selectTemplateTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: templates.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.noTemplatesAvailable, style: TextStyle(fontSize: 16, color: cs.outline)),
                        SizedBox(height: 8),
                        Text(
                          strings.noTemplatesMessage,
                          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(template.icon, style: const TextStyle(fontSize: 32)),
                        title: Text(template.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: template.description != null ? Text(template.description!) : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          Navigator.pop(context, template);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancelButton))],
      ),
    );
  }
}
