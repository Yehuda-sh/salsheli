// 📄 File: lib/services/price_updater.dart
//
// Service: מוריד קובץ מחירים (gzip או xml), מפרק ל-PriceData, וממזג לתוך קובץ JSON מקומי.
// שדרוגים עיקריים:
// - תמיכה ב-gzip או xml רגיל (זיהוי אוטומטי).
// - טיימאאוטים + User-Agent.
// - יצירת נתיב קובץ בטוח (כולל יצירת תיקייה).
// - מיזוג עדין: לא דורס name קיים אם ריק, לא מכניס price=0, שומר שדות קיימים.
// - אפשרות לבנות אינסטנס “נוח” מ-AppDocumentsDirectory.
//
// דרישות:
// - תלות: archive, xml, path_provider, flutter/services (rootBundle).

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/price_data.dart';

class PriceUpdater {
  final String priceUrl;

  /// נתיב לקובץ JSON מקומי שמחזיק את המוצרים: מפת ברקוד → אובייקט מוצר
  final String localProductsJsonPath;

  /// קובץ ברירת־מחדל מה-assets (למקרה שאין עדיין קובץ מקומי)
  final String? fallbackAssetPath;

  /// אם true – לא נדרוס name קיים בשם ריק מהמקור.
  final bool preserveExistingName;

  /// אם true – לא נעדכן מחיר אם ה־price מהמקור הוא 0.
  final bool ignoreZeroPrices;

  PriceUpdater({
    required this.priceUrl,
    required this.localProductsJsonPath,
    this.fallbackAssetPath, // לדוגמה: 'assets/data/products.json'
    this.preserveExistingName = true,
    this.ignoreZeroPrices = true,
  });

  /// בונה שירות עם נתיב בקבצי האפליקציה (Documents) + שם קובץ (למשל 'products.json')
  static Future<PriceUpdater> inAppDocuments({
    required String priceUrl,
    required String filename,
    String? fallbackAssetPath,
    bool preserveExistingName = true,
    bool ignoreZeroPrices = true,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, filename);
    return PriceUpdater(
      priceUrl: priceUrl,
      localProductsJsonPath: filePath,
      fallbackAssetPath: fallbackAssetPath,
      preserveExistingName: preserveExistingName,
      ignoreZeroPrices: ignoreZeroPrices,
    );
  }

  /// תהליך מלא:
  /// 1) ודא קובץ מקומי קיים (או העתק מה-assets)
  /// 2) הורדה ופענוח (gzip או xml)
  /// 3) ניתוח ל-PriceData
  /// 4) מיזוג לתוך JSON מקומי
  /// 5) שמירה
  Future<void> updatePrices() async {
    try {
      await _ensureLocalFileExists();
      final xmlString = await _downloadPriceXml(priceUrl);
      if (xmlString == null || xmlString.isEmpty) {
        debugPrint('PriceUpdater: no XML content');
        return;
      }

      final priceData = _parsePriceXml(xmlString);
      final localMap = await _loadLocalProducts();

      int updated = 0;
      int inserted = 0;

      for (final item in priceData.items ?? const <PriceItem>[]) {
        final barcode = item.code.trim();
        if (barcode.isEmpty) continue;

        final existing = localMap[barcode] as Map<String, dynamic>?;

        if (existing != null) {
          // עדכון עדין
          final double newPrice = item.price;
          final String newName = item.name.trim();
          final String? manufacturer = item.manufacturer?.trim();

          if (!(ignoreZeroPrices && (newPrice == 0))) {
            existing['price'] = newPrice;
          }
          if (!(preserveExistingName && newName.isEmpty)) {
            // נעדכן שם אם קיבלנו שם לא ריק, או אם preserveExistingName=false
            if (newName.isNotEmpty) {
              existing['name'] = newName;
            }
          }
          if (manufacturer != null && manufacturer.isNotEmpty) {
            existing['manufacturer'] = manufacturer;
          }

          existing['barcode'] = barcode;
          existing['lastUpdated'] = (priceData.lastUpdated ?? DateTime.now())
              .toIso8601String();
          updated++;
        } else {
          // מוצר חדש
          final double price = item.price;
          if (ignoreZeroPrices && price == 0) {
            // דלג על מוצר עם מחיר 0 אם בחרנו להתעלם
            continue;
          }

          localMap[barcode] = {
            'barcode': barcode,
            'name': item.name.trim().isEmpty ? 'ללא שם' : item.name.trim(),
            'price': price,
            'manufacturer': item.manufacturer,
            'isNew': true,
            'lastUpdated': (priceData.lastUpdated ?? DateTime.now())
                .toIso8601String(),
          };
          inserted++;
        }
      }

      await _saveLocalProducts(localMap);
      debugPrint(
        'PriceUpdater: merged ${localMap.length} products (updated=$updated, inserted=$inserted)',
      );
    } catch (e, st) {
      debugPrint('PriceUpdater:updatePrices error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// אם הקובץ המקומי לא קיים – נדאג שהתיקייה קיימת, ונעתיק מה-assets אם סופק.
  Future<void> _ensureLocalFileExists() async {
    final file = File(localProductsJsonPath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    if (await file.exists()) return;

    if (fallbackAssetPath != null) {
      try {
        final content = await rootBundle.loadString(fallbackAssetPath!);
        await file.writeAsString(content);
        debugPrint(
          'PriceUpdater: copied fallback JSON from assets → $localProductsJsonPath',
        );
      } catch (e) {
        debugPrint('PriceUpdater: failed to load fallback JSON: $e');
        await file.writeAsString('{}'); // התחל ממפה ריקה
      }
    } else {
      await file.writeAsString('{}'); // התחל ממפה ריקה
    }
  }

  /// הורדת הנתונים: תומך גם ב־gzip וגם ב־xml רגיל (זיהוי לפי סיומת/כותרת/תוכן).
  Future<String?> _downloadPriceXml(String url) async {
    HttpClient? httpClient;
    try {
      final uri = Uri.parse(url);
      httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 12)
        ..userAgent = 'Salsheli-PriceUpdater/1.0 (+flutter)';

      final request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'gzip, deflate');
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode != 200) {
        debugPrint('PriceUpdater: HTTP ${response.statusCode} from $url');
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      // נסה לזהות gzip:
      // 1) סיומת .gz
      final isGzByUrl = url.toLowerCase().endsWith('.gz');
      // 2) magic number של gzip: 1F 8B
      final isGzByMagic =
          bytes.length >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B;

      if (isGzByUrl || isGzByMagic) {
        final decompressed = GZipDecoder().decodeBytes(bytes);
        return utf8.decode(decompressed);
      } else {
        // כנראה טקסט XML רגיל
        return utf8.decode(bytes);
      }
    } catch (e) {
      debugPrint('PriceUpdater:_downloadPriceXml error: $e');
      return null;
    } finally {
      httpClient?.close(force: true);
    }
  }

  /// המרה של XML ל־PriceData
  PriceData _parsePriceXml(String xmlString) {
    final xmlDoc = XmlDocument.parse(xmlString);

    final items = <PriceItem>[];
    for (final elem in xmlDoc.findAllElements('Item')) {
      final code = elem.getElement('ItemCode')?.innerText.trim() ?? '';
      final name = elem.getElement('ItemName')?.innerText.trim() ?? '';
      final priceText = elem.getElement('ItemPrice')?.innerText.trim() ?? '0';
      final manufacturer = elem
          .getElement('ManufacturerName')
          ?.innerText
          .trim();

      // תמחור: החלפת פסיקים בנקודה ואז parse
      final price = double.tryParse(priceText.replaceAll(',', '.')) ?? 0.0;

      if (code.isEmpty) continue;

      items.add(
        PriceItem(
          code: code,
          name: name,
          price: price,
          manufacturer: manufacturer?.isEmpty == true ? null : manufacturer,
        ),
      );
    }

    // חישובי min/max/avg
    double minP = double.infinity;
    double maxP = 0.0;
    double sum = 0.0;
    for (final it in items) {
      sum += it.price;
      if (it.price < minP) minP = it.price;
      if (it.price > maxP) maxP = it.price;
    }
    final avg = items.isNotEmpty ? sum / items.length : 0.0;

    return PriceData(
      productName: 'bulk', // קובץ מחירים כולל – לא מוצר יחיד
      averagePrice: avg,
      minPrice: items.isNotEmpty ? minP : 0.0,
      maxPrice: items.isNotEmpty ? maxP : 0.0,
      stores: const <StorePrice>[],
      items: items,
      lastUpdated: DateTime.now(),
    );
  }

  /// קריאת JSON מקומי: מצפה ל־Map<String, dynamic> (ברקוד → אובייקט מוצר)
  Future<Map<String, dynamic>> _loadLocalProducts() async {
    final file = File(localProductsJsonPath);
    if (!await file.exists()) return {};
    final content = await file.readAsString();
    try {
      final obj = json.decode(content);
      if (obj is Map<String, dynamic>) {
        return obj;
      }
      return {};
    } catch (_) {
      // אם פגום – נתחיל נקי
      return {};
    }
  }

  /// כתיבת JSON עם הזחה יפה
  Future<void> _saveLocalProducts(Map<String, dynamic> map) async {
    final file = File(localProductsJsonPath);
    final encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(map);
    await file.writeAsString(jsonString);
  }
}
