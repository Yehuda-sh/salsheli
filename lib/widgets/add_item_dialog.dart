// lib/widgets/add_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// סימולציית LLM/ברקוד (השארת כפי שנתת)
Future<Map<String, dynamic>> invokeLLM(String barcode) async {
  await Future.delayed(const Duration(seconds: 1));
  return {
    "found": true,
    "product_name": "פסטה ברילה",
    "category": "pasta_rice",
    "unit": "ק\"ג",
    "brand": "Barilla",
  };
}

class AddItemDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAddItem;

  const AddItemDialog({super.key, required this.onAddItem});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController(text: "1");
  final _estimatedPriceController = TextEditingController();

  String unit = "יחידות";
  String category = "pasta_rice";
  String location = "main_pantry";
  DateTime? expiryDate;
  String barcode = "";
  bool isSaving = false;

  final unitOptions = const ["יחידות", "ק\"ג", "גרם", "ליטר", "מ\"ל"];

  final locationOptions = const {
    "main_pantry": "מזווה ראשי",
    "refrigerator": "מקרר",
    "freezer": "מקפיא",
    "secondary_storage": "אחסון משני",
  };

  final categoryOptions = const {
    "pasta_rice": "פסטה ואורז",
    "vegetables": "ירקות",
    "fruits": "פירות",
    "meat": "בשר",
    "dairy": "מוצרי חלב",
    "bakery": "מאפים",
    "other": "אחר",
  };

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _estimatedPriceController.dispose();
    super.dispose();
  }

  int _parseQuantitySafe() {
    final q = int.tryParse(_quantityController.text.trim());
    if (q == null || q <= 0) return 1;
    return q.clamp(1, 999);
  }

  double? _parsePrice(String text) {
    if (text.trim().isEmpty) return null;
    final normalized = text.replaceAll(',', '.');
    final v = double.tryParse(normalized);
    if (v == null || v < 0) return null;
    return double.parse(v.toStringAsFixed(2));
  }

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = _parseQuantitySafe();
    final estimatedPrice = _parsePrice(_estimatedPriceController.text);

    setState(() => isSaving = true);
    FocusScope.of(context).unfocus();

    final newItem = {
      "product_name": _productNameController.text.trim(),
      "quantity": quantity,
      "unit": unit,
      "category": category,
      "location": location,
      "estimated_price": estimatedPrice, // אופציונלי
      "expiry_date": expiryDate != null
          ? DateFormat("yyyy-MM-dd").format(expiryDate!)
          : null,
      "barcode": barcode.isEmpty ? null : barcode,
      "added_at": DateTime.now().toIso8601String(),
    };

    // סימולציה קלה לשמירה
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    widget.onAddItem(newItem);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("פריט נשמר בהצלחה ✅")));

    if (mounted) setState(() => isSaving = false);
  }

  Future<void> scanBarcode() async {
    FocusScope.of(context).unfocus();
    final result = await invokeLLM("1234567890");

    if (!mounted) return;
    if (result["found"] == true) {
      setState(() {
        _productNameController.text = (result["product_name"] ?? "").toString();
        category = (result["category"] ?? category).toString();
        unit = (result["unit"] ?? unit).toString();
        barcode = "1234567890";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("נמצא מוצר: ${result["product_name"]} ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("לא נמצא מוצר עם הברקוד הזה")),
      );
    }
  }

  Future<void> pickExpiryDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale("he", "IL"),
    );
    if (picked != null && mounted) {
      setState(() => expiryDate = picked);
    }
  }

  void _incQty() {
    final q = (_parseQuantitySafe() + 1).clamp(1, 999);
    _quantityController.text = q.toString();
    setState(() {});
  }

  void _decQty() {
    final q = (_parseQuantitySafe() - 1).clamp(1, 999);
    _quantityController.text = q.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text("הוספת פריט חדש למזווה"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // שם מוצר
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: "שם מוצר",
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? "חובה למלא שם מוצר"
                    : null,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 8),

              // כמות + כפתורים
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "כמות",
                        prefixIcon: Icon(Icons.onetwothree),
                      ),
                      validator: (val) {
                        final q = int.tryParse((val ?? '').trim());
                        if (q == null || q <= 0)
                          return "כמות חייבת להיות חיובית";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _qtyBtn(icon: Icons.remove, onTap: _decQty, cs: cs),
                  const SizedBox(width: 6),
                  _qtyBtn(icon: Icons.add, onTap: _incQty, cs: cs),
                ],
              ),

              const SizedBox(height: 8),

              // יחידה
              DropdownButtonFormField<String>(
                value: unit,
                decoration: const InputDecoration(
                  labelText: "יחידה",
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: unitOptions
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => unit = val!),
              ),

              const SizedBox(height: 8),

              // קטגוריה
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "קטגוריה",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categoryOptions.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),

              const SizedBox(height: 8),

              // מיקום
              DropdownButtonFormField<String>(
                value: location,
                decoration: const InputDecoration(
                  labelText: "מיקום",
                  prefixIcon: Icon(Icons.kitchen_outlined),
                ),
                items: locationOptions.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => location = val!),
              ),

              const SizedBox(height: 8),

              // מחיר מוערך (אופציונלי)
              TextFormField(
                controller: _estimatedPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: ui.TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: "מחיר מוערך (אופציונלי)",
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: "₪ ",
                ),
                // לא חובה; אם מולא – נוודא חיובי
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final v = _parsePrice(val);
                  if (v == null) return "נא להזין מחיר חוקי";
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // פעולות: ברקוד + תוקף
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("סרוק ברקוד"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: pickExpiryDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("תאריך תוקף"),
                  ),
                ],
              ),

              // לייבלים קטנים
              if (expiryDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "תוקף: ${DateFormat('dd/MM/yyyy').format(expiryDate!)}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              if (barcode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "ברקוד: $barcode",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: const Text("ביטול"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveItem,
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("שמור"),
        ),
      ],
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return Material(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: cs.primary, size: 18),
        ),
      ),
    );
  }
}
