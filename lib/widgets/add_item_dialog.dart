// 📄 File: lib/widgets/add_item_dialog.dart
// ignore_for_file: deprecated_member_use

/// Dialog for adding new inventory items to pantry
/// 
/// Features:
/// - Form validation for all fields
/// - Barcode scanning simulation (LLM)
/// - Expiry date picker with Hebrew locale
/// - Category & location dropdowns
/// - Optional price estimation
/// - Quantity +/- buttons
/// - Full accessibility support
/// - Loading states for async operations
/// 
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => AddItemDialog(
///     onAddItem: (item) {
///       inventoryProvider.addItem(item);
///     },
///   ),
/// );
/// ```
/// 
/// Dependencies:
/// - intl package for date formatting
/// - Material 3 design
/// - ui_constants.dart
/// - pantry_config.dart (units, categories, locations)
/// 
/// Version: 3.0 - Config Integration + Loading States (10/10/2025)

library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../core/ui_constants.dart';
import '../config/pantry_config.dart';

// ========================================
// 🎭 DEMO/MOCK: Barcode Scanner
// ========================================

/// 🎭 DEMO/MOCK: סימולציית LLM לזיהוי ברקוד
/// 
/// ⚠️ **זהירות:** זוהי פונקציה Demo בלבד!
/// - תמיד מחזיר אותו מוצר: "פסטה ברילה"
/// - לא מתחבר לשירות אמיתי
/// - נועד רק להדגמת UI Flow
/// 
/// 🔮 **TODO - Production:**
/// - להחליף ב-OcrService.scanBarcode()
/// - או להתחבר ל-BarcodeScanner API
/// - או להשתמש ב-ML Kit Barcode Scanning
/// 
/// Example:
/// ```dart
/// // ❌ DEMO (current):
/// final result = await invokeLLM("1234567890");
/// 
/// // ✅ Production (future):
/// final result = await context.read<OcrService>().scanBarcode();
/// ```
Future<Map<String, dynamic>> invokeLLM(String barcode) async {
  // סימולציית עיכוב רשת
  await Future.delayed(kAnimationDurationLong);
  
  // ⚠️ תמיד מחזיר אותו מוצר (MOCK)
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

  String unit = PantryConfig.defaultUnit;
  String category = PantryConfig.defaultCategory;
  String location = PantryConfig.defaultLocation;
  DateTime? expiryDate;
  String barcode = "";
  
  bool isSaving = false;
  bool _isScanning = false; // ✅ Loading state חדש

  @override
  void initState() {
    super.initState();
    debugPrint('🎨 AddItemDialog.initState');
  }

  @override
  void dispose() {
    debugPrint('🗑️ AddItemDialog.dispose');
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
    final productName = _productNameController.text.trim();

    debugPrint('💾 AddItemDialog.saveItem: $productName');

    setState(() => isSaving = true);
    FocusScope.of(context).unfocus();

    final newItem = {
      "product_name": productName,
      "quantity": quantity,
      "unit": unit,
      "category": category,
      "location": location,
      "estimated_price": estimatedPrice,
      "expiry_date": expiryDate != null
          ? DateFormat("yyyy-MM-dd").format(expiryDate!)
          : null,
      "barcode": barcode.isEmpty ? null : barcode,
      "added_at": DateTime.now().toIso8601String(),
    };

    // סימולציה קלה לשמירה
    await Future.delayed(kAnimationDurationMedium);

    if (!mounted) return;
    widget.onAddItem(newItem);

    if (!mounted) return;
    Navigator.pop(context); // סגור דיאלוג
    
    // SnackBar אחרי סגירה
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("פריט נשמר בהצלחה ✅")),
    );

    if (mounted) setState(() => isSaving = false);
  }

  Future<void> scanBarcode() async {
    FocusScope.of(context).unfocus();
    debugPrint('📷 AddItemDialog.scanBarcode - invoking LLM...');
    
    // ✅ הצגת Loading state
    setState(() => _isScanning = true);

    try {
      final result = await invokeLLM("1234567890");

      if (!mounted) return;
      
      if (result["found"] == true) {
        setState(() {
          _productNameController.text = (result["product_name"] ?? "").toString();
          category = PantryConfig.getCategorySafe(result["category"]?.toString());
          unit = result["unit"]?.toString() ?? unit;
          barcode = "1234567890";
        });

        debugPrint('   ✅ מוצר נמצא: ${result["product_name"]}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("נמצא מוצר: ${result["product_name"]} ✅")),
        );
      } else {
        debugPrint('   ❌ מוצר לא נמצא');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("לא נמצא מוצר עם הברקוד הזה")),
        );
      }
    } catch (e) {
      debugPrint('   ❌ שגיאה בסריקת ברקוד: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("שגיאה בסריקה: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
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
      debugPrint('📅 AddItemDialog.pickExpiryDate: ${DateFormat('dd/MM/yyyy').format(picked)}');
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
                  prefixIcon: Icon(
                    Icons.shopping_bag_outlined,
                    semanticLabel: 'שם מוצר',
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "חובה למלא שם מוצר";
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: kSpacingSmall),

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
                        prefixIcon: Icon(
                          Icons.onetwothree,
                          semanticLabel: 'כמות',
                        ),
                      ),
                      validator: (val) {
                        final q = int.tryParse((val ?? '').trim());
                        if (q == null || q <= 0) {
                          return "כמות חייבת להיות חיובית";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  _qtyBtn(icon: Icons.remove, onTap: _decQty, cs: cs, label: 'הפחת כמות'),
                  const SizedBox(width: kSpacingXTiny),
                  _qtyBtn(icon: Icons.add, onTap: _incQty, cs: cs, label: 'הוסף כמות'),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // יחידה
              DropdownButtonFormField<String>(
                value: unit,
                decoration: const InputDecoration(
                  labelText: "יחידה",
                  prefixIcon: Icon(
                    Icons.straighten,
                    semanticLabel: 'יחידת מדידה',
                  ),
                ),
                items: PantryConfig.unitOptions
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => unit = val!),
              ),

              const SizedBox(height: kSpacingSmall),

              // קטגוריה
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "קטגוריה",
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    semanticLabel: 'קטגוריה',
                  ),
                ),
                items: PantryConfig.categoryOptions.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),

              const SizedBox(height: kSpacingSmall),

              // מיקום
              DropdownButtonFormField<String>(
                value: location,
                decoration: const InputDecoration(
                  labelText: "מיקום",
                  prefixIcon: Icon(
                    Icons.kitchen_outlined,
                    semanticLabel: 'מיקום אחסון',
                  ),
                ),
                items: PantryConfig.locationOptions.map((locationId) {
                  final locationName = PantryConfig.getLocationName(locationId);
                  return DropdownMenuItem(
                    value: locationId,
                    child: Text(locationName),
                  );
                }).toList(),
                onChanged: (val) => setState(() => location = val!),
              ),

              const SizedBox(height: kSpacingSmall),

              // מחיר מוערך (אופציונלי)
              TextFormField(
                controller: _estimatedPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: ui.TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: "מחיר מוערך (אופציונלי)",
                  prefixIcon: Icon(
                    Icons.attach_money,
                    semanticLabel: 'מחיר',
                  ),
                  prefixText: "₪ ",
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final v = _parsePrice(val);
                  if (v == null) {
                    return "נא להזין מחיר חוקי";
                  }
                  return null;
                },
              ),

              const SizedBox(height: kSpacingSmall),

              // פעולות: ברקוד + תוקף
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : scanBarcode, // ✅ disabled כש-scanning
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, kMinTouchTarget),
                    ),
                    icon: _isScanning
                        ? const SizedBox(
                            width: kIconSizeMedium,
                            height: kIconSizeMedium,
                            child: CircularProgressIndicator(
                              strokeWidth: kBorderWidthThin,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.qr_code_scanner,
                            semanticLabel: 'סרוק ברקוד',
                          ),
                    label: Text(_isScanning ? "סורק..." : "סרוק ברקוד"), // ✅ משתנה לפי מצב
                  ),
                  const SizedBox(width: kSpacingSmall),
                  ElevatedButton.icon(
                    onPressed: pickExpiryDate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, kMinTouchTarget),
                    ),
                    icon: const Icon(
                      Icons.calendar_today,
                      semanticLabel: 'תאריך תוקף',
                    ),
                    label: const Text("תאריך תוקף"),
                  ),
                ],
              ),

              // לייבלים קטנים
              if (expiryDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: kSpacingSmall),
                  child: Text(
                    "תוקף: ${DateFormat('dd/MM/yyyy').format(expiryDate!)}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              if (barcode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: kSpacingTiny),
                  child: Text(
                    "ברקוד: $barcode",
                    style: TextStyle(fontSize: kFontSizeTiny, color: Colors.grey),
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
          style: TextButton.styleFrom(
            minimumSize: const Size(0, kMinTouchTarget),
          ),
          child: const Text("ביטול"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveItem,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, kMinTouchTarget),
          ),
          child: isSaving
              ? const SizedBox(
                  width: kIconSizeMedium,
                  height: kIconSizeMedium,
                  child: CircularProgressIndicator(
                    strokeWidth: kBorderWidthThick,
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
    required String label,
  }) {
    return SizedBox(
      width: kMinTouchTarget,
      height: kMinTouchTarget,
      child: Material(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon, 
              color: cs.primary, 
              size: kIconSizeMedium,
              semanticLabel: label,
            ),
          ),
        ),
      ),
    );
  }
}
