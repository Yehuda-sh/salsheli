// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using Rami Levy CDN
//
// URL pattern: https://img.rami-levy.co.il/product/{barcode}/small.jpg
//
// Version: 4.1
// Last Updated: 10/04/2026

/// Product image URL helper using Rami Levy image CDN
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Image CDN base URL
  static const String _cdnBase = 'https://img.rami-levy.co.il/product';

  /// Credit source name
  static const String creditSource = 'רמי לוי';

  /// Credit URL
  static const String creditUrl = 'https://www.rami-levy.co.il';

  /// Generate product image URL from barcode.
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 7) return null;
    return '$_cdnBase/$barcode/small.jpg';
  }
}
