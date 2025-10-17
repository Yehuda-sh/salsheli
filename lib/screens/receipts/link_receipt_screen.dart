// 📄 File: lib/screens/receipts/link_receipt_screen.dart
// 🎯 Purpose: מסך הזנת קישור/טקסט לקבלה דיגיטלית
//
// 📋 Features:
// ✅ הזנת טקסט חופשי (כל הודעת SMS)
// ✅ Regex חכם - מחלץ קישור אוטומטית
// ✅ Validation של הקישור
// ✅ הורדת קבלה מהקישור
// ✅ העלאה ל-Firebase Storage
// ✅ בדיקת כפילויות (אם קיימת → הודעה)
// ✅ שמירה ב-Firebase (data + originalUrl + fileUrl)
// ✅ Loading State + Error Handling
// ✅ RTL Support מלא
//
// 🔗 Supported Links:
// - רמי לוי: https://rami-levy.pairzon.com/...
// - PDF ישיר: https://pdf1.pairzon.com/pdf/...
// - שופרסל (בעתיד)
// - Victory (בעתיד)
//
// 📊 Flow:
// 1. משתמש מדביק טקסט (כל ההודעה)
// 2. Regex מחלץ קישור
// 3. בדיקת תקינות
// 4. בדיקת כפילויות
// 5. הורדת הקבלה
// 6. העלאה ל-Firebase Storage
// 7. OCR (placeholder - יתווסף)
// 8. שמירה ב-Firebase
//
// Version: 2.0 - Smart Link Extraction + Firebase Storage
// Created: 17/10/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/ui_constants.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/user_context.dart';

class LinkReceiptScreen extends StatefulWidget {
  const LinkReceiptScreen({super.key});

  @override
  State<LinkReceiptScreen> createState() => _LinkReceiptScreenState();
}

class _LinkReceiptScreenState extends State<LinkReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;
  String? _extractedLink;

  @override
  void initState() {
    super.initState();
    debugPrint('🔗 LinkReceiptScreen: initState');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('קישור לקבלה'),
        backgroundColor: cs.surfaceContainer,
      ),
      body: _isProcessing ? _buildLoadingState() : _buildFormState(),
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
            'מוריד → בודק כפילויות → מעלה לשרת',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// מצב טופס
  Widget _buildFormState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpacingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔗 אייקון
            Container(
              padding: const EdgeInsets.all(kSpacingXLarge),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.link,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: kSpacingXLarge),

            // 📝 הסבר
            Text(
              'הדבק את כל הודעת ה-SMS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              'המערכת תמצא את הקישור אוטומטית 🎯',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingXLarge),

            // 📱 שדה טקסט חופשי
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'הדבק את כל ההודעה',
                hintText: 'התקבלה קבלה חדשה מרמי לוי...\nlorem ipsum https://...',
                prefixIcon: const Icon(Icons.text_fields),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              minLines: 5,
              onChanged: (text) {
                // ניסיון לחלץ קישור בזמן אמת
                final link = _extractLink(text);
                setState(() {
                  _extractedLink = link;
                  _errorMessage = null;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'אנא הזן טקסט';
                }
                
                final link = _extractLink(value);
                if (link == null) {
                  return 'לא מצאתי קישור בטקסט';
                }
                
                return null;
              },
            ),
            const SizedBox(height: kSpacingSmall),

            // 🎯 קישור שנמצא
            if (_extractedLink != null) ...[
              Container(
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          'נמצא קישור! ✅',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _extractedLink!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontFamily: 'monospace',
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 💡 טיפ
              Container(
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        'העתק את כל ההודעה - המערכת תמצא את הקישור',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ⚠️ הודעת שגיאה
            if (_errorMessage != null) ...[
              const SizedBox(height: kSpacingMedium),
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
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

            const SizedBox(height: kSpacingXLarge),

            // ✅ כפתור המשך
            FilledButton.icon(
              onPressed: _extractedLink != null ? _processLink : null,
              icon: const Icon(Icons.download),
              label: const Text('הורד ושמור קבלה'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: kSpacingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// מחלץ קישור מטקסט חופשי באמצעות Regex
  /// 
  /// תומך ב:
  /// - רמי לוי: https://rami-levy.pairzon.com/...
  /// - PDF ישיר: https://pdf1.pairzon.com/pdf/...
  /// - שופרסל (בעתיד)
  /// - Victory (בעתיד)
  String? _extractLink(String text) {
    // Regex לחיפוש קישור HTTP/HTTPS
    final urlPattern = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );

    final matches = urlPattern.allMatches(text);

    for (final match in matches) {
      final url = match.group(0);
      if (url == null) continue;

      // בדוק אם זה קישור נתמך
      if (_isSupportedLink(url)) {
        debugPrint('🔗 LinkReceiptScreen: נמצא קישור נתמך - $url');
        return url;
      }
    }

    debugPrint('❌ LinkReceiptScreen: לא נמצא קישור נתמך');
    return null;
  }

  /// בודק אם הקישור נתמך
  bool _isSupportedLink(String url) {
    final supportedDomains = [
      'rami-levy.pairzon.com',
      'pdf1.pairzon.com',
      // TODO: להוסיף שופרסל, victory, וכו'
    ];

    return supportedDomains.any((domain) => url.contains(domain));
  }

  /// מעבד את הקישור (בדיקת כפילויות + הורדה + העלאה + שמירה)
  Future<void> _processLink() async {
    debugPrint('🔄 LinkReceiptScreen: מעבד קישור...');

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ LinkReceiptScreen: validation נכשל');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final text = _textController.text.trim();
      final originalUrl = _extractLink(text);
      
      if (originalUrl == null) {
        throw Exception('לא נמצא קישור בטקסט');
      }

      debugPrint('🔗 LinkReceiptScreen: קישור מקורי - $originalUrl');

      // 🔍 שלב 1: בדיקת כפילויות
      if (!mounted) return;
      final receiptProvider = context.read<ReceiptProvider>();
      
      final isDuplicate = await receiptProvider.checkDuplicateByUrl(originalUrl);
      
      if (isDuplicate) {
        debugPrint('⚠️ LinkReceiptScreen: קבלה כבר קיימת!');
        
        if (!mounted) return;
        
        setState(() {
          _isProcessing = false;
          _errorMessage = 'הקבלה הזאת כבר קיימת במערכת! 🔄';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ קבלה זו כבר קיימת במערכת'),
            backgroundColor: Colors.orange,
            duration: kSnackBarDuration,
          ),
        );
        
        return;
      }

      // 📥 שלב 2: הורדת הקבלה
      final pdfUrl = _extractPdfUrl(originalUrl);
      debugPrint('📄 LinkReceiptScreen: PDF URL - $pdfUrl');

      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode != 200) {
        throw Exception('שגיאה בהורדת הקבלה (${response.statusCode})');
      }

      debugPrint('✅ LinkReceiptScreen: קבלה הורדה (${response.bodyBytes.length} bytes)');

      // 📤 שלב 3: העלאה ל-Firebase Storage
      if (!mounted) return;
      
      final userContext = context.read<UserContext>();
      final householdId = userContext.householdId;
      
      if (householdId == null) {
        throw Exception('אין household_id - נא להתחבר');
      }

      // יצירת שם קובץ ייחודי
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_$timestamp.pdf';
      final storagePath = 'receipts/$householdId/$fileName';

      debugPrint('📤 LinkReceiptScreen: מעלה ל-Storage - $storagePath');

      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = await storageRef.putData(
        response.bodyBytes,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'originalUrl': originalUrl,
            'storeName': _extractStoreName(originalUrl),
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ LinkReceiptScreen: הועלה בהצלחה - $downloadUrl');

      // ⏳ שלב 4: OCR (placeholder - יתווסף בעתיד)
      await Future.delayed(const Duration(seconds: 1));

      // TODO: OCR - זיהוי טקסט מה-PDF
      // final text = await _performOCR(response.bodyBytes);
      // final receiptData = _parseReceipt(text);

      // 💾 שלב 5: שמירה ב-Firebase
      if (!mounted) return;

      await receiptProvider.createReceipt(
        storeName: _extractStoreName(originalUrl),
        date: DateTime.now(),
        items: [], // TODO: OCR יזהה את הפריטים
        originalUrl: originalUrl, // ✅ שמירת הקישור המקורי
        fileUrl: downloadUrl, // ✅ שמירת קישור Firebase Storage
      );

      debugPrint('✅ LinkReceiptScreen: קבלה נשמרה בהצלחה');

      if (!mounted) return;

      // 🎉 הודעת הצלחה
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ קבלה הועלתה ונשמרה בהצלחה!'),
          backgroundColor: Colors.green,
          duration: kSnackBarDuration,
        ),
      );

      // 🔙 חזרה למסך הקודם
      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ LinkReceiptScreen: שגיאה בעיבוד קישור - $e');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage = 'שגיאה: $e';
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

  /// מחלץ URL של ה-PDF מהקישור
  String _extractPdfUrl(String link) {
    // רמי לוי: https://rami-levy.pairzon.com/1143/3nrZUYygTni1oAcGaEDYI2
    // → PDF: https://pdf1.pairzon.com/pdf/6effac32.../1143

    if (link.contains('rami-levy.pairzon.com')) {
      // TODO: לוגיקה מדויקת לחילוץ PDF URL
      // כרגע - placeholder פשוט
      return link.replaceAll('rami-levy.pairzon.com', 'pdf1.pairzon.com/pdf');
    }

    if (link.contains('pdf1.pairzon.com')) {
      // זה כבר PDF ישיר
      return link;
    }

    throw Exception('לא הצלחתי לחלץ PDF URL מהקישור');
  }

  /// מחלץ שם חנות מהקישור
  String _extractStoreName(String link) {
    if (link.contains('rami-levy')) {
      return 'רמי לוי';
    }
    if (link.contains('shufersal')) {
      return 'שופרסל';
    }
    if (link.contains('victory')) {
      return 'Victory';
    }
    return 'קבלה מקישור';
  }

  @override
  void dispose() {
    debugPrint('🔗 LinkReceiptScreen: dispose');
    _textController.dispose();
    super.dispose();
  }
}
