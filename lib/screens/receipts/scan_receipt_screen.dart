// 📄 File: lib/screens/receipts/scan_receipt_screen.dart
// 🎯 Purpose: מסך צילום קבלה עם המצלמה
//
// 📋 Features:
// ✅ צילום תמונה (מצלמה/גלריה)
// ✅ תצוגה מקדימה של התמונה
// ✅ שמירת קבלה ב-Firebase (data בלבד)
// ✅ Placeholder ל-OCR (יתווסף בעתיד)
// ✅ Loading State + Error Handling
// ✅ RTL Support מלא
//
// 🔗 Dependencies:
// - image_picker - צילום/בחירת תמונה
// - ReceiptProvider - שמירת קבלה
//
// 📊 Flow:
// 1. משתמש לוחץ "צלם"
// 2. פותח מצלמה/גלריה
// 3. בוחר תמונה
// 4. מציג preview
// 5. OCR (placeholder - יתווסף)
// 6. שומר ב-Firebase
//
// Version: 1.0
// Created: 17/10/2025

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/ui_constants.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/sticky_button.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('📷 ScanReceiptScreen: initState');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: kPaperBackground,
      appBar: AppBar(
        title: const Text('צילום קבלה'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Stack(
        children: [
          const NotebookBackground(),
          _isProcessing
              ? _buildLoadingState()
              : _imageFile == null
                  ? _buildInitialState()
                  : _buildPreviewState(),
        ],
      ),
    );
  }

  /// מצב התחלתי - בחירת מקור תמונה
  Widget _buildInitialState() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: kSpacingMedium),

              // 📷 לוגו מצלמה
              StickyNote(
                color: kStickyYellow,
                rotation: -0.02,
                child: Container(
                  padding: const EdgeInsets.all(kSpacingXLarge),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: kSpacingMedium),

              // 📝 הסבר
              StickyNote(
                color: kStickyPink,
                rotation: 0.015,
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Column(
                    children: [
                      Text(
                        'צלם או בחר תמונה של הקבלה',
                        style: const TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Text(
                        'המערכת תזהה אוטומטית את הפרטים',
                        style: TextStyle(
                          fontSize: kFontSizeBody,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kSpacingLarge),

              // 🎯 כפתור מצלמה
              StickyButton(
                label: 'צלם עכשיו',
                icon: Icons.camera_alt,
                color: Colors.blue,
                textColor: Colors.white,
                height: 48,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: kSpacingMedium),

              // 🖼️ כפתור גלריה
              StickyButton(
                label: 'בחר מהגלריה',
                icon: Icons.photo_library,
                color: Colors.white,
                textColor: Colors.blue,
                height: 48,
                onPressed: () => _pickImage(ImageSource.gallery),
              ),

              // ⚠️ הודעת שגיאה
              if (_errorMessage != null) ...[
                const SizedBox(height: kSpacingLarge),
                StickyNote(
                  color: Colors.red.shade100,
                  rotation: -0.01,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingMedium),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: kSpacingMedium),
            ],
          ),
        ),
      ),
    );
  }

  /// מצב טעינה
  Widget _buildLoadingState() {
    return SafeArea(
      child: Center(
        child: StickyNote(
          color: kStickyYellow,
          rotation: 0.01,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingXLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: kSpacingMedium),
                const Text(
                  'מעבד קבלה...',
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
                Text(
                  'זה ייקח רגע',
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// מצב תצוגה מקדימה
  Widget _buildPreviewState() {
    return Column(
      children: [
        // 🖼️ תצוגת התמונה
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                File(_imageFile!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // 🎛️ פס כלים
        Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          color: kPaperBackground,
          child: Row(
            children: [
              // 🗑️ מחק
              Expanded(
                child: StickyButton(
                  label: 'מחק',
                  icon: Icons.delete,
                  color: Colors.red.shade100,
                  textColor: Colors.red,
                  height: 48,
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _errorMessage = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: kSpacingMedium),

              // ✅ אשר
              Expanded(
                child: StickyButton(
                  label: 'המשך',
                  icon: Icons.check,
                  color: Colors.green,
                  textColor: Colors.white,
                  height: 48,
                  onPressed: _processReceipt,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// בוחר תמונה (מצלמה/גלריה)
  Future<void> _pickImage(ImageSource source) async {
    debugPrint('📷 ScanReceiptScreen: בוחר תמונה מ-$source');

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('❌ ScanReceiptScreen: משתמש ביטל בחירת תמונה');
        return;
      }

      debugPrint('✅ ScanReceiptScreen: תמונה נבחרה - ${image.path}');

      setState(() {
        _imageFile = image;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('❌ ScanReceiptScreen: שגיאה בבחירת תמונה - $e');
      setState(() {
        _errorMessage = 'שגיאה בבחירת תמונה: $e';
      });
    }
  }

  /// מעבד את הקבלה (OCR + שמירה)
  Future<void> _processReceipt() async {
    debugPrint('🔄 ScanReceiptScreen: מעבד קבלה...');

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // ⏳ Placeholder ל-OCR (יתווסף בעתיד)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: OCR - זיהוי טקסט מהתמונה
      // final text = await _performOCR(_imageFile!.path);
      // final receiptData = _parseReceipt(text);

      // 💾 שמירה ב-Firebase (data בלבד, לא תמונה)
      if (!mounted) return;

      final provider = context.read<ReceiptProvider>();
      await provider.createReceipt(
        storeName: 'קבלה ממצלמה', // TODO: OCR יזהה את החנות
        date: DateTime.now(),
        items: [], // TODO: OCR יזהה את הפריטים
      );

      debugPrint('✅ ScanReceiptScreen: קבלה נשמרה בהצלחה');

      if (!mounted) return;

      // 🎉 הודעת הצלחה
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ קבלה נשמרה בהצלחה!'),
          backgroundColor: Colors.green,
          duration: kSnackBarDuration,
        ),
      );

      // 🔙 חזרה למסך הקודם
      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ ScanReceiptScreen: שגיאה בעיבוד קבלה - $e');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage = 'שגיאה בעיבוד הקבלה: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ שגיאה: $e'),
          backgroundColor: Colors.red,
          duration: kSnackBarDuration,
        ),
      );
    }
  }

  @override
  void dispose() {
    debugPrint('📷 ScanReceiptScreen: dispose');
    super.dispose();
  }
}
