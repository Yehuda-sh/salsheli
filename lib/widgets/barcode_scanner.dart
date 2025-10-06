// 📄 File: lib/widgets/barcode_scanner.dart
// 🎯 Purpose: Dialog לסריקת ברקוד דרך מצלמה או הזנה ידנית
// 
// 📋 Features:
// - סריקה אוטומטית עם mobile_scanner
// - הזנה ידנית כחלופה (עם validation)
// - פנס והחלפת מצלמה
// - מניעת סריקות כפולות (isProcessing flag)
// - Visual feedback עם SnackBar
// - Touch targets 48x48
// - Accessibility labels
//
// 🎯 Used by: AddItemDialog, InventoryScreen, PopulateListScreen
//
// 💡 Usage:
// ```dart
// showDialog(
//   context: context,
//   builder: (context) => BarcodeScannerDialog(
//     onBarcodeScanned: (barcode) {
//       print('Scanned: $barcode');
//     },
//   ),
// );
// ```

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/ui_constants.dart';
import '../core/constants.dart';

class BarcodeScannerDialog extends StatefulWidget {
  final void Function(String barcode) onBarcodeScanned;

  const BarcodeScannerDialog({super.key, required this.onBarcodeScanned});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  bool manualMode = false;
  bool torchOn = false;
  bool isProcessing = false;
  CameraFacing facing = CameraFacing.back;

  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('📷 BarcodeScanner.initState: mode=camera');
  }

  @override
  void dispose() {
    debugPrint('🗑️  BarcodeScanner.dispose');
    _manualController.dispose();
    super.dispose();
  }

  void toggleCamera() {
    debugPrint('📷 BarcodeScanner.toggleCamera');
    setState(() {
      facing = facing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
    });
    debugPrint('   ✅ Switched to: $facing');
  }

  void toggleTorch() {
    debugPrint('💡 BarcodeScanner.toggleTorch');
    setState(() {
      torchOn = !torchOn;
    });
    debugPrint('   ✅ Torch: ${torchOn ? "ON" : "OFF"}');
  }

  void handleManualSubmit() {
    final barcode = _manualController.text.trim();
    debugPrint('⌨️  BarcodeScanner.handleManualSubmit: "$barcode"');

    // Validation 1: Empty
    if (barcode.isEmpty) {
      debugPrint('   ⚠️  Empty input');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('נא להזין מספר ברקוד'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Validation 2: Numeric only
    if (!RegExp(r'^\d+$').hasMatch(barcode)) {
      debugPrint('   ⚠️  Invalid format (not numeric)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ברקוד צריך להכיל רק ספרות'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Validation 3: Length (8-13 digits for standard barcodes)
    if (barcode.length < 8 || barcode.length > 13) {
      debugPrint('   ⚠️  Invalid length: ${barcode.length} (expected 8-13)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ברקוד צריך להיות בין 8-13 ספרות'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    debugPrint('   ✅ Valid barcode');
    
    // Visual feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ברקוד הוזן: $barcode'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );
    }

    widget.onBarcodeScanned(barcode);
    
    // Close after short delay (let user see the success message)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void handleDetectedBarcode(BarcodeCapture capture) {
    debugPrint('📷 BarcodeScanner.handleDetectedBarcode');

    if (isProcessing) {
      debugPrint('   ⚠️  Already processing - ignoring');
      return;
    }

    final barcode = capture.barcodes.first.rawValue ?? "";
    if (barcode.isEmpty) {
      debugPrint('   ⚠️  Empty barcode detected');
      return;
    }

    debugPrint('   ✅ Barcode detected: $barcode');
    setState(() => isProcessing = true);

    // Visual feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ברקוד נסרק: $barcode'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );
    }

    widget.onBarcodeScanned(barcode);

    // Close after short delay (let user see the success message)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(kSpacingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Container(
        width: double.infinity,
        height: 500,
        padding: EdgeInsets.all(kSpacingMedium),
        child: manualMode
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'הזנה ידנית',
                      child: const Icon(
                        Icons.keyboard_alt,
                        size: kButtonHeight,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: kSpacingMedium),
                    const Text(
                      "הזנת ברקוד ידנית",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: kSpacingSmall),
                    TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "מספר ברקוד",
                        hintText: "7290000000000",
                        helperText: "8-13 ספרות",
                      ),
                      onSubmitted: (_) => handleManualSubmit(),
                    ),
                    SizedBox(height: kSpacingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: 'חזור למצב סריקה',
                            child: SizedBox(
                              height: kButtonHeight,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  debugPrint('🔄 Switching to camera mode');
                                  setState(() => manualMode = false);
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("חזרה למצלמה"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Tooltip(
                            message: 'שלח ברקוד',
                            child: SizedBox(
                              height: kButtonHeight,
                              child: ElevatedButton(
                                onPressed: handleManualSubmit,
                                child: const Text("אישור"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  MobileScanner(
                    controller: MobileScannerController(
                      facing: facing,
                      torchEnabled: torchOn,
                    ),
                    onDetect: handleDetectedBarcode,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.all(kSpacingMedium),
                      padding: EdgeInsets.symmetric(
                        horizontal: kSpacingSmall + 4,
                        vertical: kSpacingSmall - 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(kSpacingSmall),
                      ),
                      child: const Text(
                        "מקם את הברקוד במסגרת",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(kSpacingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Torch button
                          Semantics(
                            button: true,
                            hint: torchOn ? 'כבה פנס' : 'הפעל פנס',
                            child: SizedBox(
                              width: kButtonHeight,
                              height: kButtonHeight,
                              child: IconButton(
                                tooltip: "הפעל/כבה פנס",
                                icon: Icon(
                                  torchOn ? Icons.flash_on : Icons.flash_off,
                                  color: Colors.white,
                                ),
                                onPressed: toggleTorch,
                              ),
                            ),
                          ),
                          
                          // Switch camera button
                          Semantics(
                            button: true,
                            hint: 'החלף מצלמה',
                            child: SizedBox(
                              width: kButtonHeight,
                              height: kButtonHeight,
                              child: IconButton(
                                tooltip: "החלף מצלמה",
                                icon: const Icon(
                                  Icons.cameraswitch,
                                  color: Colors.white,
                                ),
                                onPressed: toggleCamera,
                              ),
                            ),
                          ),
                          
                          // Manual input button
                          Tooltip(
                            message: 'מעבר להזנה ידנית',
                            child: SizedBox(
                              height: kButtonHeight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  debugPrint('🔄 Switching to manual mode');
                                  setState(() => manualMode = true);
                                },
                                icon: const Icon(Icons.keyboard_alt),
                                label: const Text("הזנה ידנית"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
