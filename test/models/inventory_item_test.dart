import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    test('creates with all required fields', () {
      final item = InventoryItem(
        id: 'inv-123',
        productName: 'חלב 3%',
        category: 'מוצרי חלב',
        location: 'מקרר',
        quantity: 2,
        unit: 'ליטר',
      );

      expect(item.id, 'inv-123');
      expect(item.productName, 'חלב 3%');
      expect(item.category, 'מוצרי חלב');
      expect(item.location, 'מקרר');
      expect(item.quantity, 2);
      expect(item.unit, 'ליטר');
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = InventoryItem(
          id: 'inv-123',
          productName: 'חלב 3%',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        final updated = original.copyWith(
          productName: 'חלב 1%',
          quantity: 5,
          location: 'מזווה',
        );

        expect(updated.productName, 'חלב 1%');
        expect(updated.quantity, 5);
        expect(updated.location, 'מזווה');
        
        // Unchanged fields
        expect(updated.id, original.id);  // ID never changes
        expect(updated.category, original.category);
        expect(updated.unit, original.unit);
      });

      test('id remains immutable in copyWith', () {
        final original = InventoryItem(
          id: 'inv-123',
          productName: 'מוצר',
          category: 'כללי',
          location: 'מקרר',
          quantity: 1,
          unit: 'יח\'',
        );

        // Even if we try to change ID, it should remain the same
        final updated = original.copyWith(productName: 'מוצר חדש');

        expect(updated.id, 'inv-123');
        expect(updated.id, original.id);
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = InventoryItem(
          id: 'inv-456',
          productName: 'אורז בסמטי',
          category: 'יבשים',
          location: 'ארון',
          quantity: 3,
          unit: 'ק"ג',
        );

        final json = original.toJson();
        final restored = InventoryItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.productName, original.productName);
        expect(restored.category, original.category);
        expect(restored.location, original.location);
        expect(restored.quantity, original.quantity);
        expect(restored.unit, original.unit);
      });

      test('handles default values in JSON', () {
        final json = {
          'id': 'inv-minimal',
          'productName': null,  // Should use default
          'category': null,     // Should use default
          'location': null,     // Should use default
          'quantity': null,     // Should use default
          'unit': null,         // Should use default
        };

        final item = InventoryItem.fromJson(json);

        expect(item.id, 'inv-minimal');
        expect(item.productName, 'מוצר לא ידוע');
        expect(item.category, 'כללי');
        expect(item.location, 'כללי');
        expect(item.quantity, 0);
        expect(item.unit, 'יח\'');
      });

      test('handles missing fields with defaults', () {
        final json = {
          'id': 'inv-partial',
          // All other fields missing
        };

        final item = InventoryItem.fromJson(json);

        expect(item.id, 'inv-partial');
        expect(item.productName, 'מוצר לא ידוע');
        expect(item.category, 'כללי');
        expect(item.location, 'כללי');
        expect(item.quantity, 0);
        expect(item.unit, 'יח\'');
      });
    });

    group('Equality and HashCode', () {
      test('equality is based on all fields', () {
        final item1 = InventoryItem(
          id: 'inv-123',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        final item2 = InventoryItem(
          id: 'inv-123',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        final item3 = InventoryItem(
          id: 'inv-456',  // Different ID
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        final item4 = InventoryItem(
          id: 'inv-123',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 3,  // Different quantity
          unit: 'ליטר',
        );

        expect(item1 == item2, true);
        expect(item1 == item3, false);
        expect(item1 == item4, false);
        expect(item1.hashCode, item2.hashCode);
        expect(item1.hashCode, isNot(item3.hashCode));
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final item = InventoryItem(
          id: 'inv-123',
          productName: 'חלב 3%',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        final str = item.toString();

        expect(str, contains('inv-123'));
        expect(str, contains('חלב 3%'));
        expect(str, contains('2'));
        expect(str, contains('ליטר'));
        expect(str, contains('מקרר'));
      });
    });

    group('Common use cases', () {
      test('creates fridge item', () {
        final milk = InventoryItem(
          id: 'inv-milk-001',
          productName: 'חלב תנובה 3%',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );

        expect(milk.location, 'מקרר');
        expect(milk.category, 'מוצרי חלב');
        expect(milk.unit, 'ליטר');
      });

      test('creates pantry dry goods', () {
        final rice = InventoryItem(
          id: 'inv-rice-001',
          productName: 'אורז בסמטי',
          category: 'יבשים',
          location: 'מזווה',
          quantity: 3,
          unit: 'ק"ג',
        );

        expect(rice.location, 'מזווה');
        expect(rice.category, 'יבשים');
        expect(rice.unit, 'ק"ג');
      });

      test('creates freezer item', () {
        final chicken = InventoryItem(
          id: 'inv-chicken-001',
          productName: 'חזה עוף קפוא',
          category: 'בשר ודגים',
          location: 'מקפיא',
          quantity: 5,
          unit: 'חבילות',
        );

        expect(chicken.location, 'מקפיא');
        expect(chicken.category, 'בשר ודגים');
      });

      test('creates bathroom supplies', () {
        final toiletPaper = InventoryItem(
          id: 'inv-tp-001',
          productName: 'נייר טואלט לילי',
          category: 'מוצרי ניקיון',
          location: 'ארון אמבטיה',
          quantity: 12,
          unit: 'גלילים',
        );

        expect(toiletPaper.location, 'ארון אמבטיה');
        expect(toiletPaper.category, 'מוצרי ניקיון');
      });

      test('tracks zero quantity items', () {
        final emptyItem = InventoryItem(
          id: 'inv-empty-001',
          productName: 'שמן זית',
          category: 'תבלינים ושמנים',
          location: 'ארון',
          quantity: 0,
          unit: 'בקבוק',
        );

        expect(emptyItem.quantity, 0);
        expect(emptyItem.productName, 'שמן זית');
      });

      test('handles bulk items', () {
        final bulkWater = InventoryItem(
          id: 'inv-water-001',
          productName: 'מים מינרליים',
          category: 'משקאות',
          location: 'מחסן',
          quantity: 48,
          unit: 'בקבוקים',
        );

        expect(bulkWater.quantity, 48);
        expect(bulkWater.location, 'מחסן');
      });

      test('updates quantity when consuming', () {
        final originalEggs = InventoryItem(
          id: 'inv-eggs-001',
          productName: 'ביצים L',
          category: 'ביצים',
          location: 'מקרר',
          quantity: 12,
          unit: 'יח\'',
        );

        // Used 4 eggs
        final afterUse = originalEggs.copyWith(
          quantity: originalEggs.quantity - 4,
        );

        expect(afterUse.quantity, 8);
        expect(afterUse.id, originalEggs.id);
        expect(afterUse.productName, originalEggs.productName);
      });

      test('updates quantity when restocking', () {
        final lowStock = InventoryItem(
          id: 'inv-flour-001',
          productName: 'קמח לבן',
          category: 'אפייה',
          location: 'ארון',
          quantity: 1,
          unit: 'ק"ג',
        );

        // Bought 5 more kg
        final restocked = lowStock.copyWith(
          quantity: lowStock.quantity + 5,
        );

        expect(restocked.quantity, 6);
        expect(restocked.id, lowStock.id);
      });

      test('creates items with Hebrew units', () {
        final items = [
          InventoryItem(
            id: 'test-1',
            productName: 'מוצר 1',
            category: 'כללי',
            location: 'מקרר',
            quantity: 1,
            unit: 'יח\'',
          ),
          InventoryItem(
            id: 'test-2',
            productName: 'מוצר 2',
            category: 'כללי',
            location: 'מזווה',
            quantity: 2,
            unit: 'חבילות',
          ),
          InventoryItem(
            id: 'test-3',
            productName: 'מוצר 3',
            category: 'כללי',
            location: 'מקפיא',
            quantity: 500,
            unit: 'גרם',
          ),
        ];

        expect(items[0].unit, 'יח\'');
        expect(items[1].unit, 'חבילות');
        expect(items[2].unit, 'גרם');
      });
    });
  });
}
