// 📄 File: test/models/inventory_item_test.dart
//
// Unit tests for InventoryItem model
// Tests: creation, copyWith, JSON serialization, isLowStock

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/core/constants.dart';
import 'package:memozap/core/status_colors.dart';
import 'package:memozap/models/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    // ===== Creation Tests =====
    group('Creation', () {
      test('should create InventoryItem with required fields', () {
        final item = InventoryItem(
          id: 'test-id-1',
          productName: 'חלב 3%',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
        );

        expect(item.id, 'test-id-1');
        expect(item.productName, 'חלב 3%');
        expect(item.category, 'מוצרי חלב');
        expect(item.location, 'מקרר');
        expect(item.quantity, 5);
        expect(item.unit, 'יח\'');
        expect(item.minQuantity, 2); // default value
      });

      test('should create InventoryItem with custom minQuantity', () {
        final item = InventoryItem(
          id: 'test-id-2',
          productName: 'לחם',
          category: 'מאפים',
          location: 'ארון',
          quantity: 1,
          unit: 'יח\'',
          minQuantity: 3,
        );

        expect(item.minQuantity, 3);
      });
    });

    // ===== copyWith Tests =====
    group('copyWith', () {
      late InventoryItem originalItem;

      setUp(() {
        originalItem = InventoryItem(
          id: 'original-id',
          productName: 'ביצים',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 12,
          unit: 'יח\'',
          minQuantity: 6,
        );
      });

      test('should create copy with updated productName', () {
        final copy = originalItem.copyWith(productName: 'ביצים אורגניות');

        expect(copy.id, originalItem.id); // ID should NOT change
        expect(copy.productName, 'ביצים אורגניות');
        expect(copy.quantity, originalItem.quantity);
      });

      test('should create copy with updated quantity', () {
        final copy = originalItem.copyWith(quantity: 6);

        expect(copy.quantity, 6);
        expect(copy.productName, originalItem.productName);
      });

      test('should create copy with updated minQuantity', () {
        final copy = originalItem.copyWith(minQuantity: 10);

        expect(copy.minQuantity, 10);
      });

      test('should preserve id when copyWith is called', () {
        final copy = originalItem.copyWith(
          productName: 'New Name',
          category: 'New Category',
          location: 'New Location',
          quantity: 100,
          unit: 'kg',
          minQuantity: 50,
        );

        // ID should ALWAYS remain the same
        expect(copy.id, 'original-id');
      });
    });

    // ===== isLowStock Tests =====
    group('isLowStock', () {
      test('should return true when quantity is below minQuantity', () {
        final item = InventoryItem(
          id: 'low-stock-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 1,
          unit: 'יח\'',
          minQuantity: 2,
        );

        expect(item.isLowStock, true);
      });

      test('should return false when quantity equals minQuantity', () {
        final item = InventoryItem(
          id: 'equal-stock-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'יח\'',
          minQuantity: 2,
        );

        // isLowStock uses strict < comparison, not <=
        expect(item.isLowStock, false);
      });

      test('should return false when quantity is above minQuantity', () {
        final item = InventoryItem(
          id: 'high-stock-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
          minQuantity: 2,
        );

        expect(item.isLowStock, false);
      });

      test('should return true when quantity is 0', () {
        final item = InventoryItem(
          id: 'zero-stock-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 0,
          unit: 'יח\'',
          minQuantity: 2,
        );

        expect(item.isLowStock, true);
      });
    });

    // ===== JSON Serialization Tests =====
    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final item = InventoryItem(
          id: 'json-test-id',
          productName: 'גבינה צהובה',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 3,
          unit: 'יח\'',
          minQuantity: 2,
        );

        final json = item.toJson();

        expect(json['id'], 'json-test-id');
        expect(json['product_name'], 'גבינה צהובה'); // snake_case in JSON
        expect(json['category'], 'מוצרי חלב');
        expect(json['location'], 'מקרר');
        expect(json['quantity'], 3);
        expect(json['unit'], 'יח\'');
        expect(json['min_quantity'], 2); // snake_case in JSON
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'json-deserialize-id',
          'product_name': 'יוגורט',
          'category': 'מוצרי חלב',
          'location': 'מקרר',
          'quantity': 4,
          'unit': 'יח\'',
          'min_quantity': 3,
        };

        final item = InventoryItem.fromJson(json);

        expect(item.id, 'json-deserialize-id');
        expect(item.productName, 'יוגורט');
        expect(item.category, 'מוצרי חלב');
        expect(item.location, 'מקרר');
        expect(item.quantity, 4);
        expect(item.unit, 'יח\'');
        expect(item.minQuantity, 3);
      });

      test('should use default values when fields are missing in JSON', () {
        final json = {
          'id': 'minimal-json-id',
        };

        final item = InventoryItem.fromJson(json);

        expect(item.id, 'minimal-json-id');
        expect(item.productName, ''); // default is empty string
        expect(item.category, 'other'); // default
        expect(item.location, 'other'); // default
        expect(item.quantity, 0); // default
        expect(item.unit, 'יח\''); // default
        expect(item.minQuantity, 2); // default
      });

      test('should roundtrip serialize/deserialize correctly', () {
        final original = InventoryItem(
          id: 'roundtrip-id',
          productName: 'עגבניות',
          category: 'ירקות',
          location: 'מקרר',
          quantity: 10,
          unit: 'ק"ג',
          minQuantity: 5,
        );

        final json = original.toJson();
        final restored = InventoryItem.fromJson(json);

        expect(restored, original);
      });
    });

    // ===== Equality Tests =====
    group('Equality', () {
      test('should be equal when all fields match', () {
        final item1 = InventoryItem(
          id: 'same-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
          minQuantity: 2,
        );

        final item2 = InventoryItem(
          id: 'same-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
          minQuantity: 2,
        );

        expect(item1, item2);
        expect(item1.hashCode, item2.hashCode);
      });

      test('should not be equal when id differs', () {
        final item1 = InventoryItem(
          id: 'id-1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
        );

        final item2 = InventoryItem(
          id: 'id-2',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
        );

        expect(item1, isNot(item2));
      });

      test('should not be equal when quantity differs', () {
        final item1 = InventoryItem(
          id: 'same-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
        );

        final item2 = InventoryItem(
          id: 'same-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 10,
          unit: 'יח\'',
        );

        expect(item1, isNot(item2));
      });
    });

    // ===== toString Tests =====
    group('toString', () {
      test('should return readable string representation', () {
        final item = InventoryItem(
          id: 'to-string-id',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 5,
          unit: 'יח\'',
          minQuantity: 2,
        );

        final str = item.toString();

        expect(str, contains('to-string-id'));
        expect(str, contains('חלב'));
        expect(str, contains('5'));
        expect(str, contains('יח\''));
        expect(str, contains('מקרר'));
      });
    });

    // ===== Edge Cases =====
    group('Edge Cases', () {
      test('should handle zero quantity', () {
        final item = InventoryItem(
          id: 'zero-qty-id',
          productName: 'Product',
          category: 'Category',
          location: 'Location',
          quantity: 0,
          unit: 'unit',
        );

        expect(item.quantity, 0);
        expect(item.isLowStock, true);
      });

      test('should handle negative quantity in JSON', () {
        final json = {
          'id': 'negative-qty-id',
          'product_name': 'Product',
          'quantity': -5,
        };

        final item = InventoryItem.fromJson(json);
        expect(item.quantity, -5);
        expect(item.isLowStock, true);
      });

      test('should handle special characters in productName', () {
        final item = InventoryItem(
          id: 'special-chars-id',
          productName: 'מוצר "מיוחד" (100%)',
          category: 'קטגוריה/תת-קטגוריה',
          location: 'מקום & מיקום',
          quantity: 1,
          unit: 'יח\'',
        );

        final json = item.toJson();
        final restored = InventoryItem.fromJson(json);

        expect(restored.productName, 'מוצר "מיוחד" (100%)');
        expect(restored.category, 'קטגוריה/תת-קטגוריה');
        expect(restored.location, 'מקום & מיקום');
      });

      test('should handle empty strings', () {
        final item = InventoryItem(
          id: '',
          productName: '',
          category: '',
          location: '',
          quantity: 0,
          unit: '',
        );

        expect(item.id, '');
        expect(item.productName, '');
      });
    });

    // ===== Expiry Tests =====
    group('Expiry', () {
      test('hasExpiryDate returns true when set', () {
        final item = InventoryItem(
          id: 'exp-1',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 10)),
        );
        expect(item.hasExpiryDate, true);
      });

      test('hasExpiryDate returns false when null', () {
        const item = InventoryItem(
          id: 'exp-2',
          productName: 'אורז',
          category: 'dry',
          location: 'cabinet',
          quantity: 3,
          unit: 'יח\'',
        );
        expect(item.hasExpiryDate, false);
      });

      test('isExpired returns true for past date', () {
        final item = InventoryItem(
          id: 'exp-3',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(item.isExpired, true);
      });

      test('isExpired returns false for future date', () {
        final item = InventoryItem(
          id: 'exp-4',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        );
        expect(item.isExpired, false);
      });

      test('isExpired returns false when no expiry', () {
        const item = InventoryItem(
          id: 'exp-5',
          productName: 'אורז',
          category: 'dry',
          location: 'cabinet',
          quantity: 2,
          unit: 'יח\'',
        );
        expect(item.isExpired, false);
      });

      test('isExpiringSoon returns true within 7 days', () {
        final item = InventoryItem(
          id: 'exp-6',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 3)),
        );
        expect(item.isExpiringSoon, true);
      });

      test('isExpiringSoon returns false beyond 7 days', () {
        final item = InventoryItem(
          id: 'exp-7',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        );
        expect(item.isExpiringSoon, false);
      });

      test('expiresWithinDays with custom threshold', () {
        final item = InventoryItem(
          id: 'exp-8',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 10)),
        );
        expect(item.expiresWithinDays(14), true);
        expect(item.expiresWithinDays(7), false);
      });

      test('expiresWithinDays returns false for expired items', () {
        final item = InventoryItem(
          id: 'exp-9',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(item.expiresWithinDays(7), false);
      });

      test('expiresWithinDays returns false when no expiry', () {
        const item = InventoryItem(
          id: 'exp-10',
          productName: 'אורז',
          category: 'dry',
          location: 'cabinet',
          quantity: 2,
          unit: 'יח\'',
        );
        expect(item.expiresWithinDays(30), false);
      });

      test('daysUntilExpiry returns positive for future', () {
        final item = InventoryItem(
          id: 'exp-11',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().add(const Duration(days: 10)),
        );
        expect(item.daysUntilExpiry, greaterThanOrEqualTo(9));
      });

      test('daysUntilExpiry returns negative for past', () {
        final item = InventoryItem(
          id: 'exp-12',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 2,
          unit: 'יח\'',
          expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(item.daysUntilExpiry, lessThan(0));
      });

      test('daysUntilExpiry returns null when no expiry', () {
        const item = InventoryItem(
          id: 'exp-13',
          productName: 'אורז',
          category: 'dry',
          location: 'cabinet',
          quantity: 2,
          unit: 'יח\'',
        );
        expect(item.daysUntilExpiry, isNull);
      });
    });

    // ===== Purchase Stats Tests =====
    group('Purchase Stats', () {
      test('wasRecentlyPurchased true within 30 days', () {
        final item = InventoryItem(
          id: 'pur-1',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          lastPurchased: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(item.wasRecentlyPurchased, true);
      });

      test('wasRecentlyPurchased false beyond 30 days', () {
        final item = InventoryItem(
          id: 'pur-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          lastPurchased: DateTime.now().subtract(const Duration(days: 60)),
        );
        expect(item.wasRecentlyPurchased, false);
      });

      test('wasRecentlyPurchased false when null', () {
        const item = InventoryItem(
          id: 'pur-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
        );
        expect(item.wasRecentlyPurchased, false);
      });

      test('isPopular true when purchaseCount >= 4', () {
        const item = InventoryItem(
          id: 'pop-1',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          purchaseCount: 5,
        );
        expect(item.isPopular, true);
      });

      test('isPopular false when purchaseCount < 4', () {
        const item = InventoryItem(
          id: 'pop-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          purchaseCount: 3,
        );
        expect(item.isPopular, false);
      });
    });

    // ===== v4.0 Status Getters =====
    group('v4.0 Status Getters', () {
      test('stockPercentage 0.0 when empty', () {
        const item = InventoryItem(
          id: 'st-1',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 0,
          unit: 'יח\'',
          minQuantity: 5,
        );
        expect(item.stockPercentage, 0.0);
      });

      test('stockPercentage 1.0 when full', () {
        const item = InventoryItem(
          id: 'st-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 10,
          unit: 'יח\'',
          minQuantity: 5,
        );
        expect(item.stockPercentage, 1.0);
      });

      test('stockPercentage 0.5 at half', () {
        const item = InventoryItem(
          id: 'st-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          minQuantity: 6,
        );
        expect(item.stockPercentage, 0.5);
      });

      test('stockPercentage 1.0 when minQuantity is 0', () {
        const item = InventoryItem(
          id: 'st-4',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          minQuantity: 0,
        );
        expect(item.stockPercentage, 1.0);
      });

      test('status returns LimitStatus values', () {
        const safe = InventoryItem(
          id: 'ls-1', productName: 'a', category: 'c', location: 'l',
          quantity: 10, unit: 'u', minQuantity: 5,
        );
        const low = InventoryItem(
          id: 'ls-2', productName: 'a', category: 'c', location: 'l',
          quantity: 4, unit: 'u', minQuantity: 5,
        );
        expect(safe.status, LimitStatus.full);
        expect(low.isLowStock, true);
      });

      test('statusType error when expired', () {
        final item = InventoryItem(
          id: 'stt-1',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 5,
          unit: 'יח\'',
          minQuantity: 2,
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(item.statusType, StatusType.error);
      });

      test('statusType warning when low stock', () {
        const item = InventoryItem(
          id: 'stt-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 1,
          unit: 'יח\'',
          minQuantity: 5,
        );
        expect(item.statusType, StatusType.warning);
      });

      test('statusType warning when expiring soon', () {
        final item = InventoryItem(
          id: 'stt-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 10,
          unit: 'יח\'',
          minQuantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 3)),
        );
        expect(item.statusType, StatusType.warning);
      });

      test('statusType success when all good', () {
        const item = InventoryItem(
          id: 'stt-4',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 10,
          unit: 'יח\'',
          minQuantity: 2,
        );
        expect(item.statusType, StatusType.success);
      });

      test('recommendedHaptic heavy when expired', () {
        final item = InventoryItem(
          id: 'hap-1',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 5,
          unit: 'יח\'',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(item.recommendedHaptic, 'heavy');
      });

      test('recommendedHaptic medium when low stock', () {
        const item = InventoryItem(
          id: 'hap-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 1,
          unit: 'יח\'',
          minQuantity: 5,
        );
        expect(item.recommendedHaptic, 'medium');
      });

      test('recommendedHaptic light when success', () {
        const item = InventoryItem(
          id: 'hap-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 10,
          unit: 'יח\'',
          minQuantity: 2,
        );
        expect(item.recommendedHaptic, 'light');
      });

      test('needsUrgentAttention when expired', () {
        final item = InventoryItem(
          id: 'urg-1',
          productName: 'יוגורט',
          category: 'dairy',
          location: 'fridge',
          quantity: 5,
          unit: 'יח\'',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(item.needsUrgentAttention, true);
      });

      test('needsUrgentAttention when quantity is 0', () {
        const item = InventoryItem(
          id: 'urg-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 0,
          unit: 'יח\'',
          minQuantity: 2,
        );
        expect(item.needsUrgentAttention, true);
      });

      test('needsUrgentAttention false when all good', () {
        const item = InventoryItem(
          id: 'urg-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 10,
          unit: 'יח\'',
          minQuantity: 2,
        );
        expect(item.needsUrgentAttention, false);
      });
    });

    // ===== copyWith Clearable Fields =====
    group('copyWith clearable fields', () {
      test('clearExpiryDate sets to null', () {
        final item = InventoryItem(
          id: 'clr-1',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          expiryDate: DateTime(2026, 6, 1),
        );
        final cleared = item.copyWith(clearExpiryDate: true);
        expect(cleared.expiryDate, isNull);
      });

      test('clearNotes sets to null', () {
        const item = InventoryItem(
          id: 'clr-2',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          notes: 'some notes',
        );
        final cleared = item.copyWith(clearNotes: true);
        expect(cleared.notes, isNull);
      });

      test('clearEmoji sets to null', () {
        const item = InventoryItem(
          id: 'clr-3',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          emoji: '🥛',
        );
        final cleared = item.copyWith(clearEmoji: true);
        expect(cleared.emoji, isNull);
      });

      test('clearLastPurchased sets to null', () {
        final item = InventoryItem(
          id: 'clr-4',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          lastPurchased: DateTime(2026, 3, 1),
        );
        final cleared = item.copyWith(clearLastPurchased: true);
        expect(cleared.lastPurchased, isNull);
      });

      test('clearLastUpdatedBy sets to null', () {
        const item = InventoryItem(
          id: 'clr-5',
          productName: 'חלב',
          category: 'dairy',
          location: 'fridge',
          quantity: 3,
          unit: 'יח\'',
          lastUpdatedBy: 'user-1',
        );
        final cleared = item.copyWith(clearLastUpdatedBy: true);
        expect(cleared.lastUpdatedBy, isNull);
      });
    });
  });
}
