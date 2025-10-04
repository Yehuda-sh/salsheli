// lib/widgets/add_product_to_catalog_dialog.dart
import 'package:flutter/material.dart';

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

  final Map<String, String> categories = const {
    "dry_goods": "מוצרים יבשים",
    "dairy": "מוצרי חלב",
    "meat": "בשר ודגים",
    "vegetables": "ירקות",
    "fruits": "פירות",
    "frozen": "מוצרים קפואים",
  };

  @override
  void initState() {
    super.initState();
    name = widget.initialProductName.trim();
  }

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    form.save();
    setState(() => isSaving = true);

    try {
      final newProduct = {
        "name": name.trim(),
        "category": category,
        "brand": brand.trim(),
        "package_size": packageSize.trim(),
      };

      await widget.onSave(newProduct);
      if (!mounted) return;
      widget.onOpenChange(false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("המוצר נשמר בהצלחה ✅")));
    } catch (e) {
      debugPrint("❌ Failed to save new product: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("שגיאה בשמירת המוצר. נסה שוב."),
            backgroundColor: Colors.redAccent,
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
                  children: const [
                    Icon(Icons.add_box, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
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
                  autofocus: name.isEmpty, // אם אין שם התחלתי – פוקוס אוטומטי
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

                // 📂 קטגוריה
                DropdownButtonFormField<String>(
                  value: category,
                  items: categories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
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

                // 🔘 כפתורים
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => widget.onOpenChange(false),
                      child: const Text("ביטול"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
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
