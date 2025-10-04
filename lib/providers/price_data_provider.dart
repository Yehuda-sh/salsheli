// 📄 File: lib/providers/price_data_provider.dart
//
// 🇮🇱 מנהל את מידע המחירים (PriceData):
//     - טוען נתוני מחירים לפי מוצר או ברקוד.
//     - שומר/מעדכן מחירים בזיכרון.
//     - מתבסס על Repository כדי לאפשר גמישות (Mock/Firebase/API).
//
// 🇬🇧 Manages product price data (PriceData):
//     - Loads price data by product or barcode.
//     - Saves/updates prices in memory.
//     - Uses a Repository for flexibility (Mock/Firebase/API).
//

import 'package:flutter/foundation.dart';
import '../models/price_data.dart';
import '../repositories/price_data_repository.dart';

class PriceDataProvider with ChangeNotifier {
  final PriceDataRepository _repository;

  PriceDataProvider({required PriceDataRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, PriceData> _cache = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PriceData> get allPrices => List.unmodifiable(_cache.values);

  /// === טען נתונים לפי שם מוצר ===
  Future<PriceData?> loadByProduct(String productName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.fetchPriceByProduct(productName);
      if (data != null) {
        _cache[productName] = data;
      }
      return data;
    } catch (e) {
      _errorMessage = "שגיאה בטעינת מחירים: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// === טען נתונים לפי ברקוד ===
  Future<PriceData?> loadByBarcode(String barcode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.fetchPriceByBarcode(barcode);
      if (data != null) {
        _cache[data.productName] = data;
      }
      return data;
    } catch (e) {
      _errorMessage = "שגיאה בטעינת מחירים: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// === שמירת מחירים ===
  Future<void> savePriceData(PriceData data) async {
    await _repository.savePriceData(data);
    _cache[data.productName] = data;
    notifyListeners();
  }

  /// === מחיקת מחירים ===
  Future<void> deletePriceData(String productName) async {
    await _repository.deletePriceData(productName);
    _cache.remove(productName);
    notifyListeners();
  }
}
