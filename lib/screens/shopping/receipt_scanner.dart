/// Receipt scanner screen with OCR capabilities.
///
/// Features:
/// - Camera capture
/// - Gallery upload
/// - OCR text extraction
/// - Receipt parsing
/// - Preview and confirmation
///
/// Design: Sticky Notes theme
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Core
import '../../core/ui_constants.dart';

// Models
import '../../models/receipt.dart';

// Providers
import '../../providers/user_context.dart';

// Services
import '../../services/ocr_service.dart';
import '../../services/receipt_parser_service.dart';

// Widgets
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

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

  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }

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

      if (!mounted) return;
      setState(() => progress = 0.3);
      debugPrint('✅ ReceiptScanner: תמונה נבחרה - ${picked.path}');

      // שלב 2: OCR - חילוץ טקסט (70%)
      debugPrint('🔍 ReceiptScanner: מתחיל OCR...');
      final text = await OcrService.extractTextFromImage(picked.path);
      
      if (text.isEmpty) {
        throw Exception('לא זוהה טקסט בתמונה');
      }

      if (!mounted) return;
      setState(() => progress = 0.7);
      debugPrint('✅ ReceiptScanner: OCR הושלם - ${text.length} תווים');

      // שלב 3: ניתוח לקבלה (90%)
      debugPrint('📝 ReceiptScanner: מנתח קבלה...');
      final userContext = context.read<UserContext>();
      final householdId = userContext.householdId ?? '';
      final receipt = ReceiptParserService.parseReceiptText(text, householdId);
      
      if (!mounted) return;
      setState(() => progress = 0.9);
      debugPrint('✅ ReceiptScanner: קבלה נותחה - ${receipt.items.length} פריטים');

      // שלב 4: סיום (100%)
      if (!mounted) return;
      setState(() {
        extractedReceipt = receipt;
        progress = 1.0;
        isScanning = false;
      });

      debugPrint('🎉 ReceiptScanner: סריקה הושלמה בהצלחה!');
    } catch (e, stackTrace) {
      debugPrint('❌ ReceiptScanner: שגיאה בעיבוד - $e');
      debugPrintStack(stackTrace: stackTrace);
      
      if (!mounted) return;
      setState(() {
        isScanning = false;
        error = "שגיאה בעיבוד הקבלה: ${e.toString()}";
      });
    }
  }

  /// Confirms and processes the extracted receipt.
  /// Validates data before sending to parent.
  Future<void> _confirmReceipt() async {
    if (extractedReceipt == null) return;

    // Validation
    if (extractedReceipt!.storeName.trim().isEmpty) {
      setState(() {
        error = 'שם החנות חובה';
      });
      return;
    }

    if (extractedReceipt!.totalAmount <= 0) {
      setState(() {
        error = 'סכום לא תקין';
      });
      return;
    }

    debugPrint('💾 ReceiptScanner: מאשר קבלה...');
    setState(() => isProcessing = true);

    try {
      // העברת הקבלה למעלה (ל-Provider/Repository לשמירה ב-Firebase)
      if (widget.onReceiptProcessed != null) {
        widget.onReceiptProcessed!(extractedReceipt!);
        debugPrint('✅ ReceiptScanner: קבלה הועברה לעיבוד');
      }

      if (!mounted) return;
      setState(() {
        extractedReceipt = null;
        isProcessing = false;
      });

      debugPrint('🎉 ReceiptScanner: קבלה אושרה בהצלחה!');
    } catch (e, stackTrace) {
      debugPrint('❌ ReceiptScanner: שגיאה באישור - $e');
      debugPrintStack(stackTrace: stackTrace);
      
      if (!mounted) return;
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

  /// Opens receipt editing screen (future feature).
  void _editReceipt() {
    debugPrint('✏️ ReceiptScanner: עריכת קבלה');
    
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
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

    return StickyNote(
      color: kStickyYellow,
      rotation: -0.01,
      child: Padding(
        padding: EdgeInsets.all(kSpacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.green.shade700),
                const SizedBox(width: kSpacingSmall),
                const Text(
                  'סריקת קבלות חכמה',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            if (error != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(kSpacingSmall),
                margin: EdgeInsets.only(bottom: kSpacingMedium),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  border: Border.all(
                    color: Colors.red.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: kFontSizeSmall,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => error = null),
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            if (isScanning) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                _getProgressText(),
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.grey.shade700,
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: StickyButton(
                      label: 'צלם',
                      icon: Icons.camera_alt,
                      color: Colors.green.shade400,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: StickyButton(
                      label: 'העלה',
                      icon: Icons.upload,
                      color: Colors.blue.shade300,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                '💡 טיפ: ודא תאורה טובה וקבלה ישרה',
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  color: Colors.grey.shade600,
                ),
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
    return StickyNote(
      color: kStickyPink,
      rotation: 0.015,
      child: Padding(
        padding: EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.green.shade700, size: 28),
                const SizedBox(width: kSpacingMedium),
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
                        'סה״כ: ₪${r.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
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
                  color: Colors.grey.shade700,
                ),
              ],
            ),
            const Divider(height: kSpacingLarge),

            // Items List
            if (r.items.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        'לא זוהו פריטים',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'לחץ על ערוך להוספה ידנית',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: kFontSizeTiny,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                '${r.items.length} פריטים:',
                style: const TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: kSpacingSmall),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: r.items.length,
                  itemBuilder: (context, index) {
                    final item = r.items[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: kSpacingSmall,
                      ),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: kFontSizeTiny,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                      title: Text(
                        item.name ?? 'ללא שם',
                        style: const TextStyle(fontSize: kFontSizeSmall),
                      ),
                      trailing: Text(
                        '₪${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: kFontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const Divider(height: kSpacingLarge),

            // Actions
            Row(
              children: [
                Expanded(
                  child: StickyButton(
                  label: 'ביטול',
                    icon: Icons.close,
                    color: Colors.white,
                    textColor: Colors.red.shade700,
                    onPressed: _resetScanner,
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: StickyButton(
                  label: isProcessing ? 'שומר...' : 'אישור',
                    icon: isProcessing ? null : Icons.check,
                    color: Colors.green.shade400,
                    onPressed: isProcessing ? () {} : _confirmReceipt,
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
