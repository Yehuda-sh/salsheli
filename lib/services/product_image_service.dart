// 📄 File: lib/services/product_image_service.dart
// 🎯 Purpose: שירות למשיכת תמונות מוצרים מ-Open Food Facts API
//
// 🌍 API: Open Food Facts
// - https://world.openfoodfacts.org/api/v2/product/{barcode}
// - חינמי לחלוטין
// - תמונות איכותיות + מידע תזונתי
//
// ✨ Features:
// - 🖼️ משיכת תמונות לפי ברקוד
// - 💾 Cache מקומי (SharedPreferences)
// - 🔄 Fallback לאייקון קטגוריה
// - ⚡ מהיר וקל לשימוש
//
// 📝 Usage:
// ```dart
// final service = ProductImageService();
// final imageUrl = await service.getProductImageUrl('7290000000000');
// ```
//
// Version: 1.0
// Created: 20/11/2025

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductImageService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  static const String _cachePrefix = 'product_image_';
  static const Duration _cacheDuration = Duration(days: 30); // Cache למשך 30 יום

  /// משיכת URL של תמונת מוצר לפי ברקוד
  ///
  /// [barcode] - ברקוד המוצר
  /// [useCache] - האם להשתמש ב-cache (default: true)
  ///
  /// Returns: URL של התמונה, או null אם לא נמצאה
  Future<String?> getProductImageUrl(
    String? barcode, {
    bool useCache = true,
  }) async {
    // אם אין ברקוד - אין תמונה
    if (barcode == null || barcode.isEmpty) {
      return null;
    }

    // בדוק אם יש ב-cache
    if (useCache) {
      final cachedUrl = await _getCachedImageUrl(barcode);
      if (cachedUrl != null) {
        return cachedUrl;
      }
    }

    try {
      // קרא ל-API
      final url = Uri.parse('$_baseUrl/$barcode');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MemoZap - Shopping List App - Version 1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      // Parse JSON
      final data = json.decode(response.body) as Map<String, dynamic>;

      // בדוק אם המוצר נמצא
      final status = data['status'] as int?;
      if (status != 1) {
        // מוצר לא נמצא - שמור null ב-cache למשך יום אחד
        await _cacheImageUrl(barcode, null, cacheDuration: const Duration(days: 1));
        return null;
      }

      // חלץ את ה-URL של התמונה
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) {
        return null;
      }

      // נסה למצוא תמונה (בסדר עדיפות)
      String? imageUrl;

      // 1. תמונה מוקטנת (מהירה יותר לטעינה)
      imageUrl = product['image_small_url'] as String?;

      // 2. תמונה רגילה
      imageUrl ??= product['image_url'] as String?;

      // 3. תמונה בגודל מלא
      imageUrl ??= product['image_front_url'] as String?;

      // שמור ב-cache
      await _cacheImageUrl(barcode, imageUrl);

      return imageUrl;
    } catch (e) {
      // שגיאה ברשת או ב-parsing
      return null;
    }
  }

  /// משיכת URL מה-cache
  Future<String?> _getCachedImageUrl(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$barcode';

      // בדוק אם יש ערך שמור
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) {
        return null;
      }

      // Parse את ה-cache data
      final data = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int?;
      final imageUrl = data['url'] as String?;

      if (timestamp == null) {
        return null;
      }

      // בדוק אם ה-cache עדיין תקף
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheDuration) {
        // Cache פג תוקף
        await prefs.remove(cacheKey);
        return null;
      }

      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  /// שמירת URL ב-cache
  Future<void> _cacheImageUrl(
    String barcode,
    String? imageUrl, {
    Duration? cacheDuration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$barcode';

      final data = {
        'url': imageUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(cacheKey, json.encode(data));
    } catch (e) {
      // Silent failure - not critical
    }
  }

  /// ניקוי ה-cache (למקרה שצריך)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silent failure
    }
  }

  /// קבלת מידע מלא על מוצר (אופציונלי - לעתיד)
  ///
  /// מחזיר גם ערכים תזונתיים, אלרגנים, רכיבים וכו'
  Future<Map<String, dynamic>?> getProductInfo(String? barcode) async {
    if (barcode == null || barcode.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/$barcode');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MemoZap - Shopping List App - Version 1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as int?;

      if (status != 1) {
        return null;
      }

      return data['product'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
