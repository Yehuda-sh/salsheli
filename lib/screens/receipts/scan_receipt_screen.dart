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
      appBar: AppBar(
        title: const Text('צילום קבלה'),
        backgroundColor: cs.surfaceContainer,
      ),
      body: _isProcessing
          ? _buildLoadingState()
          : _imageFile == null
              ? _buildInitialState()
              : _buildPreviewState(),
    );
  }

  /// מצב התחלתי - בחירת מקור תמונה
  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📷 אייקון
            Container(
              padding: const EdgeInsets.all(kSpacingXLarge),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: kSpacingXLarge),

            // 📝 הסבר
            Text(
              'צלם או בחר תמונה של הקבלה',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'המערכת תזהה אוטומטית את הפרטים',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingXXLarge),

            // 🎯 כפתור מצלמה
            FilledButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('צלם עכשיו'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // 🖼️ כפתור גלריה
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('בחר מהגלריה'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingXLarge,
                  vertical: kSpacingMedium,
                ),
              ),
            ),

            // ⚠️ הודעת שגיאה
            if (_errorMessage != null) ...[
              const SizedBox(height: kSpacingXLarge),
              Container(
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
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
            ],
          ],
        ),
      ),
    );
  }

  /// מצב טעינה
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: kSpacingMedium),
          Text(
            'מעבד קבלה...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'זה ייקח רגע',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
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
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 🗑️ מחק
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _errorMessage = null;
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('מחק'),
              ),

              // ✅ אשר
              FilledButton.icon(
                onPressed: _processReceipt,
                icon: const Icon(Icons.check),
                label: const Text('המשך'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
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
