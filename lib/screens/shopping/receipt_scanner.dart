// lib/screens/shopping/receipt_scanner.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ✨ שירותי OCR + Parser
import '../../services/ocr_service.dart';
import '../../services/receipt_parser_service.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        isScanning = true;
        progress = 0.0;
        error = null;
      });

      // שלב 1: בחירת תמונה (30%)
      debugPrint('📸 ReceiptScanner: בוחר תמונה...');
      final picked = await _picker.pickImage(source: source, maxWidth: 1080);
      if (picked == null) {
        debugPrint('⚠️ ReceiptScanner: בחירה בוטלה');
        setState(() => isScanning = false);
        return;
      }

      setState(() => progress = 0.3);
      debugPrint('✅ ReceiptScanner: תמונה נבחרה - ${picked.path}');

      // שלב 2: OCR - חילוץ טקסט (70%)
      debugPrint('🔍 ReceiptScanner: מתחיל OCR...');
      final text = await OcrService.extractTextFromImage(picked.path);
      
      if (text.isEmpty) {
        throw Exception('לא זוהה טקסט בתמונה');
      }

      setState(() => progress = 0.7);
      debugPrint('✅ ReceiptScanner: OCR הושלם - ${text.length} תווים');

      // שלב 3: ניתוח לקבלה (90%)
      debugPrint('📝 ReceiptScanner: מנתח קבלה...');
      final receipt = ReceiptParserService.parseReceiptText(text);
      setState(() => progress = 0.9);
      debugPrint('✅ ReceiptScanner: קבלה נותחה - ${receipt.items.length} פריטים');

      // שלב 4: סיום (100%)
      setState(() {
        extractedReceipt = receipt;
        progress = 1.0;
        isScanning = false;
      });

      debugPrint('🎉 ReceiptScanner: סריקה הושלמה בהצלחה!');
    } catch (e, stackTrace) {
      debugPrint('❌ ReceiptScanner: שגיאה בעיבוד - $e');
      debugPrintStack(stackTrace: stackTrace);
      
      setState(() {
        isScanning = false;
        error = "שגיאה בעיבוד הקבלה: ${e.toString()}";
      });
    }
  }

  Future<void> _confirmReceipt() async {
    if (extractedReceipt == null) return;

    debugPrint('💾 ReceiptScanner: מאשר קבלה...');
    setState(() => isProcessing = true);

    try {
      // העברת הקבלה למעלה (ל-Provider/Repository לשמירה ב-Firebase)
      if (widget.onReceiptProcessed != null) {
        widget.onReceiptProcessed!(extractedReceipt!);
        debugPrint('✅ ReceiptScanner: קבלה הועברה לעיבוד');
      }

      setState(() {
        extractedReceipt = null;
        isProcessing = false;
      });

      debugPrint('🎉 ReceiptScanner: קבלה אושרה בהצלחה!');
    } catch (e, stackTrace) {
      debugPrint('❌ ReceiptScanner: שגיאה באישור - $e');
      debugPrintStack(stackTrace: stackTrace);
      
      setState(() {
        error = "שגיאה באישור הקבלה: ${e.toString()}";
        isProcessing = false;
      });
    }
  }

  void _resetScanner() {
    debugPrint('🔄 ReceiptScanner: איפוס');
    setState(() {
      extractedReceipt = null;
      error = null;
      isScanning = false;
      progress = 0;
    });
  }

  void _editReceipt() {
    debugPrint('✏️ ReceiptScanner: עריכת קבלה');
    // TODO: פתח מסך עריכה
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('עריכת קבלה - בקרוב!'),
        backgroundColor: Colors.orange,
      ),
    );
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => error = null),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            if (isScanning) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(
                _getProgressText(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("צלם קבלה"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.upload),
                    label: const Text("העלה תמונה"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '💡 טיפ: ודא תאורה טובה וקבלה ישרה',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProgressText() {
    if (progress < 0.3) return 'בוחר תמונה...';
    if (progress < 0.7) return 'קורא טקסט מהקבלה... 🔍';
    if (progress < 0.9) return 'מנתח פריטים... 📝';
    return 'כמעט סיימנו... ✨';
  }

  Widget _buildReceiptPreview() {
    final r = extractedReceipt!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "סה״כ: ₪${r.totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editReceipt,
                  tooltip: 'ערוך קבלה',
                ),
              ],
            ),
            const Divider(height: 24),

            // Items List
            if (r.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'לא זוהו פריטים',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'לחץ על ערוך להוספה ידנית',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                '${r.items.length} פריטים:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: r.items.length,
                  itemBuilder: (context, index) {
                    final item = r.items[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green[100],
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                      title: Text(
                        item.name ?? 'ללא שם',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        '₪${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const Divider(height: 24),

            // Actions
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.close),
                  label: const Text("ביטול"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: isProcessing ? null : _confirmReceipt,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(isProcessing ? "שומר..." : "אישור"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
