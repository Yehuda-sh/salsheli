// 📄 File: lib/repositories/price_data_repository.dart
//
// 🇮🇱 Repository לניהול מידע מחירים (PriceData):
//     - משמש כשכבת ביניים בין Providers ↔ מקור הנתונים.
//     - מאפשר חיפוש מחירים לפי מוצר או ברקוד.
//     - קל להחלפה (Mock ↔ Firebase/API).
//
// 🇬🇧 Repository for managing price data:
//     - Bridge between Providers ↔ data sources.
//     - Supports fetching by product name or barcode.
//     - Swappable implementations (Mock ↔ Firebase/API).
//

import '../models/price_data.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (API, Firebase, Mock) יצטרך לממש.
/// 🇬🇧 Any data source (API, Firebase, Mock) must implement.
abstract class PriceDataRepository {
  Future<PriceData?> fetchPriceByProduct(String productName);
  Future<PriceData?> fetchPriceByBarcode(String barcode);
  Future<void> savePriceData(PriceData data);
  Future<void> deletePriceData(String productName);
}

/// === Mock Implementation ===
///
/// 🇮🇱 מימוש בזיכרון בלבד – שימושי לפיתוח ודמו.
/// 🇬🇧 In-memory implementation – useful for dev/demo.
class MockPriceDataRepository implements PriceDataRepository {
  final Map<String, PriceData> _byName = {};
  final Map<String, PriceData> _byBarcode = {};

  @override
  Future<PriceData?> fetchPriceByProduct(String productName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _byName[productName];
  }

  @override
  Future<PriceData?> fetchPriceByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _byBarcode[barcode];
  }

  @override
  Future<void> savePriceData(PriceData data) async {
    _byName[data.productName] = data;

    // שמירה גם לפי ברקודים אם קיימים
    for (final item in data.items ?? []) {
      _byBarcode[item.code] = data;
    }
  }

  @override
  Future<void> deletePriceData(String productName) async {
    final data = _byName.remove(productName);
    if (data != null && data.items != null) {
      for (final item in data.items!) {
        _byBarcode.remove(item.code);
      }
    }
  }
}
