// lib/config/product_images_config.dart — CDN image URLs — Rami Levy + Shufersal + Open Food Facts, supports 7-13 digit barcodes

class ProductImagesConfig {
  ProductImagesConfig._();

  /// Rami Levy CDN base URL
  static const String _ramiLevyCdnBase = 'https://img.rami-levy.co.il/product';

  /// Shufersal Cloudinary base URL
  static const String _shufersalCdnBase =
      'https://res.cloudinary.com/shufersal/image/upload/f_auto,q_auto,w_200/v1/products/products_zoomed';

  /// Open Food Facts image base URL (global free product DB)
  /// URL format requires barcode split into groups: e.g.
  /// 7290116537849 → 729/011/653/7849
  static const String _openFoodFactsBase =
      'https://images.openfoodfacts.org/images/products';

  /// Standard barcode lengths (EAN-8, UPC-A, EAN-13) — used for
  /// Shufersal and Open Food Facts CDNs which require real EAN codes.
  static const Set<int> _standardEanLengths = {8, 12, 13};

  /// Rami Levy internal product IDs are typically 7 digits. Their CDN
  /// accepts both internal IDs and standard EAN barcodes, so we always
  /// include the Rami Levy URL regardless of barcode length.
  static const int _minBarcodeLength = 7;

  /// Generate all available image URLs for a barcode (primary first).
  /// Rami Levy CDN is always included (works with internal 7-digit IDs).
  /// Shufersal and Open Food Facts are only added for standard EAN lengths.
  static List<String> getImageUrls(String? barcode) {
    if (barcode == null || barcode.length < _minBarcodeLength) {
      return const [];
    }
    final urls = ['$_ramiLevyCdnBase/$barcode/small.jpg'];
    if (_standardEanLengths.contains(barcode.length)) {
      urls.add('$_shufersalCdnBase/$barcode');
      urls.add(_openFoodFactsUrl(barcode));
    }
    return urls;
  }

  /// Generate primary image URL from barcode (Rami Levy).
  /// Returns null if barcode is too short.
  static String? getImageUrl(String? barcode) {
    if (barcode == null || barcode.length < _minBarcodeLength) {
      return null;
    }
    return '$_ramiLevyCdnBase/$barcode/small.jpg';
  }

  /// Build Open Food Facts image URL from a barcode.
  /// Open Food Facts uses a directory structure: groups of 3 digits.
  /// For 13-digit EAN: AAA/BBB/CCC/DDDD
  /// For 12-digit UPC-A: it's converted to EAN-13 with leading 0.
  static String _openFoodFactsUrl(String barcode) {
    // Convert UPC-A (12) to EAN-13 by prepending '0'
    final ean13 = barcode.length == 12 ? '0$barcode' : barcode;

    if (ean13.length == 13) {
      // 13-digit: AAA/BBB/CCC/DDDD
      final p1 = ean13.substring(0, 3);
      final p2 = ean13.substring(3, 6);
      final p3 = ean13.substring(6, 9);
      final p4 = ean13.substring(9);
      return '$_openFoodFactsBase/$p1/$p2/$p3/$p4/front_he.200.jpg';
    } else {
      // 8-digit EAN-8: just the code
      return '$_openFoodFactsBase/$ean13/front_he.200.jpg';
    }
  }
}
