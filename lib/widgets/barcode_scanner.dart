// lib/widgets/barcode_scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void toggleCamera() {
    setState(() {
      facing = facing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
    });
  }

  void toggleTorch() {
    setState(() {
      torchOn = !torchOn;
    });
  }

  void handleManualSubmit() {
    final barcode = _manualController.text.trim();
    if (barcode.isEmpty) return;

    widget.onBarcodeScanned(barcode);
    Navigator.pop(context);
  }

  void handleDetectedBarcode(BarcodeCapture capture) {
    if (isProcessing) return;

    final barcode = capture.barcodes.first.rawValue ?? "";
    if (barcode.isEmpty) return;

    setState(() => isProcessing = true);
    widget.onBarcodeScanned(barcode);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: manualMode
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.keyboard_alt,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "הזנת ברקוד ידנית",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "מספר ברקוד",
                        hintText: "7290000000000",
                      ),
                      onSubmitted: (_) => handleManualSubmit(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => manualMode = false),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("חזרה למצלמה"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: handleManualSubmit,
                            child: const Text("אישור"),
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
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: "הפעל/כבה פנס",
                            icon: Icon(
                              torchOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                            onPressed: toggleTorch,
                          ),
                          IconButton(
                            tooltip: "החלף מצלמה",
                            icon: const Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                            ),
                            onPressed: toggleCamera,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => manualMode = true),
                            icon: const Icon(Icons.keyboard_alt),
                            label: const Text("הזנה ידנית"),
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
