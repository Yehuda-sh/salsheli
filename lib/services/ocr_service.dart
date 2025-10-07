// 📄 File: lib/services/ocr_service.dart
//
// 📋 Description:
// Static service for OCR (Optical Character Recognition) using Google ML Kit.
// Extracts text from receipt images locally on the device.
//
// 🎯 Purpose:
// - Extract text from images using ML Kit
// - No internet connection required (offline)
// - Fast and free
//
// 📱 Mobile Only: Yes

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  /// חילוץ טקסט מתמונת קבלה
  /// 
  /// Example:
  /// ```dart
  /// final text = await OcrService.extractTextFromImage('/path/to/receipt.jpg');
  /// print('Extracted: $text');
  /// ```
  static Future<String> extractTextFromImage(String imagePath) async {
    debugPrint('📸 OcrService.extractTextFromImage()');
    debugPrint('   📁 imagePath: $imagePath');

    try {
      // יצירת InputImage מהנתיב
      final inputImage = InputImage.fromFilePath(imagePath);
      debugPrint('   ✅ InputImage נוצר');

      // יצירת TextRecognizer
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      debugPrint('   🔍 מתחיל זיהוי טקסט...');

      // זיהוי הטקסט
      final recognizedText = await textRecognizer.processImage(inputImage);
      debugPrint('   ✅ זיהוי הושלם: ${recognizedText.text.length} תווים');

      // סגירת ה-recognizer
      textRecognizer.close();
      debugPrint('   🗑️ TextRecognizer נסגר');

      final extractedText = recognizedText.text;
      debugPrint('✅ OcrService.extractTextFromImage: הצליח');
      debugPrint('   📝 טקסט: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');

      return extractedText;
    } catch (e, stackTrace) {
      debugPrint('❌ OcrService.extractTextFromImage: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// חילוץ טקסט מפורט (עם מיקומים)
  /// 
  /// מחזיר רשימת שורות עם מיקומים - שימושי לניתוח מתקדם
  /// 
  /// Example:
  /// ```dart
  /// final lines = await OcrService.extractTextLines('/path/to/receipt.jpg');
  /// for (var line in lines) {
  ///   print('Line: ${line.text}');
  /// }
  /// ```
  static Future<List<TextLine>> extractTextLines(String imagePath) async {
    debugPrint('📸 OcrService.extractTextLines()');
    debugPrint('   📁 imagePath: $imagePath');

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      debugPrint('   🔍 מתחיל זיהוי טקסט מפורט...');
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      textRecognizer.close();

      // איסוף כל השורות
      final lines = <TextLine>[];
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          lines.add(line);
        }
      }

      debugPrint('✅ OcrService.extractTextLines: ${lines.length} שורות');
      return lines;
    } catch (e, stackTrace) {
      debugPrint('❌ OcrService.extractTextLines: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
