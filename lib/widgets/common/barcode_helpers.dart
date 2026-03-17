import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../providers/products_provider.dart';
import 'barcode_scanner_sheet.dart';

/// פותח את סורק הברקוד ומחזיר תוצאה (null = ביטול)
Future<BarcodeScanResult?> openBarcodeScanner(BuildContext context) {
  return showModalBottomSheet<BarcodeScanResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
    ),
    builder: (_) => const BarcodeScannerSheet(),
  );
}

/// סורק ברקוד ומחזיר מוצר מהקטלוג. null = לא נמצא או ביטול.
/// מציג snackbar שגיאה אם לא נמצא.
Future<Map<String, dynamic>?> scanAndLookupProduct(
  BuildContext context,
  ProductsProvider productsProvider,
) async {
  final result = await openBarcodeScanner(context);
  if (result == null || !context.mounted) return null;

  final product = productsProvider.getByBarcode(result.barcode);

  if (product == null && context.mounted) {
    unawaited(HapticFeedback.heavyImpact());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.shopping.barcodeNotFound(result.barcode)),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
    return null;
  }

  return product;
}
