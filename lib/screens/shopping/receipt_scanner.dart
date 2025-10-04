// lib/components/shopping/receipt_scanner.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ✨ שירות API
import '../../services/receipt_service.dart';
import '../../models/receipt.dart';

class ReceiptScanner extends StatefulWidget {
  final Function(Receipt)? onReceiptProcessed;

  const ReceiptScanner({super.key, this.onReceiptProcessed});

  @override
  State<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {
  bool isScanning = false;
  bool isProcessing = false;
  double progress = 0;
  String? error;
  Receipt? extractedReceipt;

  final ImagePicker _picker = ImagePicker();
  final ReceiptService _service = ReceiptService(); // ✅ שימוש כמופע

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        isScanning = true;
        progress = 0.0;
        error = null;
      });

      final picked = await _picker.pickImage(source: source, maxWidth: 1080);
      if (picked == null) {
        setState(() => isScanning = false);
        return;
      }

      // ✨ שלב 1 + 2: העלאה + ניתוח
      setState(() => progress = 0.7);
      final receipt = await _service.uploadAndParseReceipt(picked.path);

      // ✨ שלב 3: סיום
      setState(() {
        extractedReceipt = receipt;
        progress = 1.0;
        isScanning = false;
      });
    } catch (e) {
      setState(() {
        isScanning = false;
        error = "שגיאה בעיבוד הקבלה: $e";
      });
    }
  }

  Future<void> _saveReceipt() async {
    if (extractedReceipt == null) return;

    setState(() => isProcessing = true);

    try {
      // השרת מחזיר את הקבלה השמורה (לעיתים עם id/שדות מעודכנים)
      final saved = await _service.saveReceipt(extractedReceipt!);

      // העברת הקבלה המעודכנת חזרה למעלה
      if (widget.onReceiptProcessed != null) {
        widget.onReceiptProcessed!(saved);
      }

      setState(() {
        extractedReceipt = null;
        isProcessing = false;
      });
    } catch (e) {
      setState(() {
        error = "שגיאה בשמירת הקבלה: $e";
        isProcessing = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      extractedReceipt = null;
      error = null;
      isScanning = false;
      progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (extractedReceipt != null) {
      return _buildReceiptPreview();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "סריקת קבלות חכמה",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            if (isScanning) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              const Text("מעבד קבלה..."),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("צלם קבלה"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.upload),
                    label: const Text("העלה תמונה"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    final r = extractedReceipt!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "קבלה מ-${r.storeName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("סה״כ: ₪${r.totalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            // הימנעות מ-Expanded בלי גובה מוגדר
            SizedBox(
              height: 260,
              child: ListView.builder(
                itemCount: r.items.length,
                itemBuilder: (context, index) {
                  final item = r.items[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.name),
                    subtitle: Text("×${item.quantity}"),
                    trailing: Text("₪${item.totalPrice.toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _resetScanner,
                  child: const Text("ביטול"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isProcessing ? null : _saveReceipt,
                  child: Text(isProcessing ? "שומר..." : "שמור קבלה"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
