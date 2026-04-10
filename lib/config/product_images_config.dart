// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using Rami Levy CDN
//
// Generates product image URLs from barcodes using Rami Levy's
// image CDN (img.rami-levy.co.il).
//
// URL pattern: https://img.rami-levy.co.il/product/{barcode}/small.jpg
//
// Version: 3.1
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

  /// HTTP headers required for CDN access (browser-like)
  static const Map<String, String> imageHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Referer': 'https://www.rami-levy.co.il/',
  };

  /// Generate product image URL from barcode.
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 7) return null;
    return '$_cdnBase/$barcode/small.jpg';
  }
}
