// 📄 File: lib/widgets/add_product_to_catalog_dialog.dart
// 🎯 Purpose: Dialog להוספת מוצר חדש לקטלוג כשלא נמצא בחיפוש
// 📋 Used by: PopulateListScreen, InventoryScreen
// 
// 💡 Features:
// - טופס מאומת עם 4 שדות (שם, קטגוריה, מותג, גודל)
// - תמיכה ב-keyboard actions (next/done)
// - Loading state עם disable buttons
// - Error handling עם SnackBar
// - Visual feedback (ירוק להצלחה, אדום לשגיאה)
// - Accessibility labels
// - Touch targets 48x48
//
// 🔗 Related:
// - lib/core/constants.dart - kCategoryEmojis

import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/ui_constants.dart';

class AddProductToCatalogDialog extends StatefulWidget {
  final bool open;
  final void Function(bool) onOpenChange;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final String initialProductName;

  const AddProductToCatalogDialog({
    super.key,
    required this.open,
    required this.onOpenChange,
    required this.onSave,
    this.initialProductName = '',
  });

  @override
  State<AddProductToCatalogDialog> createState() =>
      _AddProductToCatalogDialogState();
}

class _AddProductToCatalogDialogState extends State<AddProductToCatalogDialog> {
  final _formKey = GlobalKey<FormState>();

  late String name;
  String category = 'dry_goods';
  String brand = '';
  String packageSize = '';
  bool isSaving = false;

  // מיפוי קטגוריות עם אמוג'י מ-constants.dart
  // כל קטגוריה מכילה: key (אנגלית), name (עברית), emoji
  final Map<String, Map<String, String>> categories = {
    "dry_goods": {
      "name": "מוצרים יבשים",
      "emoji": kCategoryEmojis['pasta_rice'] ?? '📦',
    },
    "dairy": {
      "name": "מוצרי חלב",
      "emoji": kCategoryEmojis['dairy'] ?? '🥛',
    },
    "meat": {
      "name": "בשר ודגים",
      "emoji": kCategoryEmojis['meat'] ?? '🥩',
    },
    "vegetables": {
      "name": "ירקות",
      "emoji": kCategoryEmojis['vegetables'] ?? '🥬',
    },
    "fruits": {
      "name": "פירות",
      "emoji": kCategoryEmojis['fruits'] ?? '🍎',
    },
    "frozen": {
      "name": "מוצרים קפואים",
      "emoji": kCategoryEmojis['frozen'] ?? '🧊',
    },
  };

  @override
  void initState() {
    super.initState();
    name = widget.initialProductName.trim();
    debugPrint('📝 AddProductDialog.initState: initialName="$name"');
  }

  Future<void> _handleSave() async {
    debugPrint('💾 AddProductDialog._handleSave()');
    
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      debugPrint('   ⚠️  Validation failed');
      return;
    }

    form.save();
    setState(() => isSaving = true);

    try {
      final newProduct = {
        "name": name.trim(),
        "category": category,
        "brand": brand.trim(),
        "package_size": packageSize.trim(),
      };

      debugPrint('   📦 Saving: name="$name", category=$category');
      await widget.onSave(newProduct);
      debugPrint('   ✅ הצלחה');
      
      if (!mounted) return;
      widget.onOpenChange(false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("המוצר נשמר בהצלחה ✅"),
          backgroundColor: Colors.green, // ✅ Visual feedback - ירוק
        ),
      );
    } catch (e) {
      debugPrint("   ❌ Failed to save: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("שגיאה בשמירת המוצר. נסה שוב."),
            backgroundColor: Colors.redAccent, // ✅ Visual feedback - אדום
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Semantics(
                      label: 'הוספת מוצר לקטלוג',
                      child: const Icon(Icons.add_box, color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "הוספת מוצר חדש לקטלוג",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "המוצר לא נמצא. הוסיפו אותו לקטלוג כדי שתוכלו להשתמש בו בעתיד.",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // 📝 שם מוצר
                TextFormField(
                  initialValue: name,
                  autofocus: name.isEmpty,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "שם המוצר *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? "נדרש שם מוצר"
                      : null,
                  onSaved: (val) => name = (val ?? "").trim(),
                ),
                const SizedBox(height: 16),

                // 📂 קטגוריה - עם אמוג'י
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: categories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Row(
                            children: [
                              Text(
                                e.value['emoji']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(e.value['name']!),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: "קטגוריה *",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      setState(() => category = val ?? "dry_goods"),
                ),
                const SizedBox(height: 16),

                // 🏷 מותג
                TextFormField(
                  initialValue: brand,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "מותג (אופציונלי)",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => brand = (val ?? "").trim(),
                ),
                const SizedBox(height: 16),

                // 📦 גודל אריזה
                TextFormField(
                  initialValue: packageSize,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isSaving) _handleSave();
                  },
                  decoration: const InputDecoration(
                    labelText: "גודל אריזה",
                    hintText: "לדוגמה: 1 ליטר, 500 גרם",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => packageSize = (val ?? "").trim(),
                ),
                const SizedBox(height: 24),

                // 🔘 כפתורים - Touch targets 48x48
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'סגור ללא שמירה',
                      child: SizedBox(
                        height: kButtonHeight, // 48px
                        child: OutlinedButton(
                          onPressed: () => widget.onOpenChange(false),
                          child: const Text("ביטול"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'שמור והוסף לרשימה',
                      child: SizedBox(
                        height: kButtonHeight, // 48px
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : _handleSave,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(isSaving ? "שומר..." : "שמור והוסף לרשימה"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
