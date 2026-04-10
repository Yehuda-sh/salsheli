// 📄 lib/config/product_images_config.dart
//
// Purpose: Image URL generation for products using Rami Levy CDN
//
// Uses Rami Levy's image proxy (_ipx) which serves optimized WebP images.
// URL pattern: https://www.rami-levy.co.il/_ipx/w_{size},f_webp/https://img.rami-levy.co.il/product/{barcode}/small.jpg
//
// Version: 4.0
// Last Updated: 10/04/2026

/// Product image URL helper using Rami Levy image proxy
class ProductImagesConfig {
  ProductImagesConfig._();

  /// Credit source name
  static const String creditSource = 'רמי לוי';

  /// Credit URL
  static const String creditUrl = 'https://www.rami-levy.co.il';

  /// HTTP headers for image proxy access
  static const Map<String, String> imageHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Referer': 'https://www.rami-levy.co.il/',
    'Accept': 'image/webp,image/*,*/*',
  };

  /// Generate product image URL from barcode.
  /// Uses Rami Levy's _ipx proxy for optimized WebP delivery.
  /// Returns null if barcode is invalid or too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < 7) return null;
    return 'https://www.rami-levy.co.il/_ipx/w_200,f_webp/'
        'https://img.rami-levy.co.il/product/$barcode/small.jpg';
  }
}
