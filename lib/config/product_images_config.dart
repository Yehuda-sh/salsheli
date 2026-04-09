// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using Open Food Facts
//
// Generates image URLs from barcodes using the Open Food Facts API.
// Provides credit attribution for images.
//
// Version: 1.0
// Last Updated: 09/04/2026

/// Product image URL helper using Open Food Facts database
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Credit source name
  static const String creditSource = 'Open Food Facts';

  /// Credit URL
  static const String creditUrl = 'https://openfoodfacts.org';

  /// Generate Open Food Facts image URL from barcode.
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 8) return null;

    final path = _barcodePath(barcode);
    return 'https://images.openfoodfacts.org/images/products/$path/1.400.jpg';
  }

  /// Split barcode into path segments for Open Food Facts URL.
  /// 13-digit EAN: XXX/XXX/XXX/XXXX
  /// Shorter barcodes: used as-is
  static String _barcodePath(String barcode) {
    if (barcode.length >= 13) {
      return '${barcode.substring(0, 3)}/${barcode.substring(3, 6)}/${barcode.substring(6, 9)}/${barcode.substring(9)}';
    }
    return barcode;
  }
}
