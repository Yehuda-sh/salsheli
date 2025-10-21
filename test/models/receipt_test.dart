import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/receipt.dart';

void main() {
  group('Receipt', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    group('Factory Constructor', () {
      test('newReceipt creates receipt with correct defaults', () {
        final receipt = Receipt.newReceipt(
          storeName: 'רמי לוי',
          date: testDate,
          householdId: 'test_household',
          totalAmount: 250.50,
        );

        expect(receipt.id, isNotEmpty);
        expect(receipt.storeName, 'רמי לוי');
        expect(receipt.date, testDate);
        expect(receipt.totalAmount, 250.50);
        expect(receipt.items, isEmpty);
        expect(receipt.createdDate, isNotNull);
      });

      test('newReceipt with items', () {
        final items = [
          ReceiptItem(
            id: 'item-1',
            name: 'חלב',
            quantity: 2,
            unitPrice: 6.5,
          ),
          ReceiptItem(
            id: 'item-2',
            name: 'לחם',
            quantity: 1,
            unitPrice: 8.0,
          ),
        ];

        final receipt = Receipt.newReceipt(
          storeName: 'שופרסל',
          date: testDate,
          householdId: 'test_household',
          totalAmount: 21.0,
          items: items,
        );

        expect(receipt.items.length, 2);
        expect(receipt.items[0].name, 'חלב');
        expect(receipt.items[1].name, 'לחם');
        expect(receipt.totalAmount, 21.0);
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = Receipt(
          id: 'receipt-123',
          storeName: 'מגה בעיר',
          date: testDate,
          householdId: 'test_household',
          createdDate: testDate.add(Duration(hours: 1)),
          totalAmount: 342.75,
          items: [
            ReceiptItem(
              id: 'item-1',
              name: 'חלב',
              quantity: 2,
              unitPrice: 6.5,
              isChecked: true,
            ),
          ],
        );

        final json = original.toJson();
        final restored = Receipt.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.storeName, original.storeName);
        expect(restored.date, original.date);
        expect(restored.createdDate, original.createdDate);
        expect(restored.totalAmount, original.totalAmount);
        expect(restored.items.length, 1);
        expect(restored.items[0].name, 'חלב');
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 'receipt-minimal',
          'store_name': 'חנות',
          'date': testDate.toIso8601String(),
          'household_id': 'test_household',
          'total_amount': 100.0,
          'items': [],
        };

        final receipt = Receipt.fromJson(json);

        expect(receipt.id, 'receipt-minimal');
        expect(receipt.storeName, 'חנות');
        expect(receipt.createdDate, isNull);
        expect(receipt.items, isEmpty);
      });

      test('handles default values in JSON', () {
        final json = {
          'id': '',
          'store_name': null,
          'date': testDate.toIso8601String(),
          'household_id': 'test_household',
          'total_amount': 0,
          'items': [],
        };

        final receipt = Receipt.fromJson(json);

        expect(receipt.id, '');
        expect(receipt.storeName, 'חנות ללא שם');
        expect(receipt.totalAmount, 0.0);
      });
    });
  });

  group('ReceiptItem', () {
    test('creates with default values', () {
      final item = ReceiptItem();

      expect(item.id, '');
      expect(item.name, isNull);
      expect(item.quantity, 1);
      expect(item.unitPrice, 0.0);
      expect(item.isChecked, false);
      expect(item.barcode, isNull);
      expect(item.manufacturer, isNull);
      expect(item.category, isNull);
      expect(item.unit, isNull);
    });

    test('creates with all values', () {
      final item = ReceiptItem(
        id: 'item-123',
        name: 'חלב תנובה 3%',
        quantity: 2,
        unitPrice: 6.5,
        isChecked: true,
        barcode: '7290000000123',
        manufacturer: 'תנובה',
        category: 'מוצרי חלב',
        unit: 'ליטר',
      );

      expect(item.id, 'item-123');
      expect(item.name, 'חלב תנובה 3%');
      expect(item.quantity, 2);
      expect(item.unitPrice, 6.5);
      expect(item.isChecked, true);
      expect(item.barcode, '7290000000123');
      expect(item.manufacturer, 'תנובה');
      expect(item.category, 'מוצרי חלב');
      expect(item.unit, 'ליטר');
    });

    test('totalPrice calculates correctly', () {
      final item1 = ReceiptItem(
        quantity: 3,
        unitPrice: 5.5,
      );

      final item2 = ReceiptItem(
        quantity: 0,
        unitPrice: 10.0,
      );

      final item3 = ReceiptItem(
        quantity: 5,
        unitPrice: 0.0,
      );

      expect(item1.totalPrice, 16.5);
      expect(item2.totalPrice, 0.0);
      expect(item3.totalPrice, 0.0);
    });

    test('copyWith updates only specified fields', () {
      final original = ReceiptItem(
        id: 'item-123',
        name: 'מוצר מקורי',
        quantity: 1,
        unitPrice: 10.0,
        isChecked: false,
      );

      final updated = original.copyWith(
        name: 'מוצר מעודכן',
        quantity: 5,
        isChecked: true,
      );

      expect(updated.name, 'מוצר מעודכן');
      expect(updated.quantity, 5);
      expect(updated.isChecked, true);
      expect(updated.id, original.id);
      expect(updated.unitPrice, original.unitPrice);
    });

    test('JSON serialization works correctly', () {
      final original = ReceiptItem(
        id: 'item-test',
        name: 'מוצר בדיקה',
        quantity: 3,
        unitPrice: 12.5,
        isChecked: true,
        barcode: '1234567890',
        manufacturer: 'יצרן',
        category: 'קטגוריה',
        unit: 'ק"ג',
      );

      final json = original.toJson();
      final restored = ReceiptItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.quantity, original.quantity);
      expect(restored.unitPrice, original.unitPrice);
      expect(restored.isChecked, original.isChecked);
      expect(restored.barcode, original.barcode);
      expect(restored.manufacturer, original.manufacturer);
      expect(restored.category, original.category);
      expect(restored.unit, original.unit);
    });

    test('handles null name gracefully', () {
      final item = ReceiptItem(
        id: 'item-no-name',
        name: null,
        quantity: 1,
        unitPrice: 5.0,
      );

      expect(item.toString(), contains('ללא שם'));
    });

    test('assertions validate constraints', () {
      // Negative quantity should throw
      expect(
        () => ReceiptItem(quantity: -1, unitPrice: 5.0),
        throwsA(isA<AssertionError>()),
      );

      // Negative price should throw
      expect(
        () => ReceiptItem(quantity: 1, unitPrice: -5.0),
        throwsA(isA<AssertionError>()),
      );

      // Zero is valid
      final validItem = ReceiptItem(quantity: 0, unitPrice: 0.0);
      expect(validItem.quantity, 0);
      expect(validItem.unitPrice, 0.0);
    });
  });

  group('Converters', () {
    group('IsoDateTimeConverter', () {
      test('converts DateTime to ISO string and back', () {
        const converter = IsoDateTimeConverter();
        final date = DateTime(2025, 1, 15, 10, 30, 45);

        final json = converter.toJson(date);
        final restored = converter.fromJson(json);

        expect(json, isA<String>());
        expect(json, contains('2025-01-15'));
        expect(restored, date);
      });
    });

    group('IsoDateTimeNullableConverter', () {
      test('handles null values', () {
        const converter = IsoDateTimeNullableConverter();

        final nullJson = converter.toJson(null);
        final nullRestored = converter.fromJson(null);

        expect(nullJson, isNull);
        expect(nullRestored, isNull);
      });

      test('converts non-null DateTime', () {
        const converter = IsoDateTimeNullableConverter();
        final date = DateTime(2025, 1, 15, 10, 30);

        final json = converter.toJson(date);
        final restored = converter.fromJson(json);

        expect(json, isNotNull);
        expect(restored, date);
      });
    });

    group('FlexDoubleConverter', () {
      test('converts various number formats', () {
        const converter = FlexDoubleConverter();

        // Integer
        expect(converter.fromJson(42), 42.0);
        
        // Double
        expect(converter.fromJson(42.5), 42.5);
        
        // String with dot
        expect(converter.fromJson('123.45'), 123.45);
        
        // String with comma (European format)
        expect(converter.fromJson('123,45'), 123.45);
        
        // Null
        expect(converter.fromJson(null), 0.0);
        
        // Invalid string
        expect(converter.fromJson('not a number'), 0.0);
        
        // Empty string
        expect(converter.fromJson(''), 0.0);
      });

      test('toJson returns number as-is', () {
        const converter = FlexDoubleConverter();
        
        expect(converter.toJson(42.5), 42.5);
        expect(converter.toJson(0.0), 0.0);
        expect(converter.toJson(123.456), 123.456);
      });
    });
  });

  group('Common use cases', () {
    test('creates grocery store receipt', () {
      final groceryItems = [
        ReceiptItem(
          id: 'item-1',
          name: 'חלב תנובה 3%',
          quantity: 2,
          unitPrice: 6.50,
          barcode: '7290000042138',
          manufacturer: 'תנובה',
          category: 'מוצרי חלב',
          unit: 'ליטר',
        ),
        ReceiptItem(
          id: 'item-2',
          name: 'לחם אחיד',
          quantity: 1,
          unitPrice: 8.90,
          barcode: '7290000123456',
          manufacturer: 'אנג\'ל',
          category: 'מאפים',
          unit: 'יחידה',
        ),
        ReceiptItem(
          id: 'item-3',
          name: 'עגבניות',
          quantity: 1,
          unitPrice: 12.90,
          category: 'ירקות',
          unit: 'ק"ג',
        ),
      ];

      final receipt = Receipt.newReceipt(
        storeName: 'רמי לוי',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: groceryItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        items: groceryItems,
      );

      expect(receipt.storeName, 'רמי לוי');
      expect(receipt.items.length, 3);
      expect(receipt.totalAmount, closeTo(34.8, 0.01));
      
      // Verify items total matches receipt total
      final itemsTotal = receipt.items.fold(0.0, (sum, item) => sum + item.totalPrice);
      expect(itemsTotal, receipt.totalAmount);
    });

    test('creates receipt with discounted items', () {
      final items = [
        ReceiptItem(
          id: 'item-1',
          name: 'במבה אסם - מבצע',
          quantity: 3,
          unitPrice: 5.90,  // Discounted price
          barcode: '7290000000001',
          manufacturer: 'אסם',
        ),
      ];

      final receipt = Receipt(
        id: 'receipt-discount',
        storeName: 'שופרסל דיל',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 17.70,
        items: items,
      );

      expect(receipt.items[0].totalPrice, closeTo(17.70, 0.01));
      expect(receipt.totalAmount, closeTo(receipt.items[0].totalPrice, 0.01));
    });

    test('creates pharmacy receipt', () {
      final items = [
        ReceiptItem(
          id: 'med-1',
          name: 'אקמול',
          quantity: 2,
          unitPrice: 18.90,
          category: 'תרופות',
          unit: 'חבילה',
        ),
        ReceiptItem(
          id: 'med-2',
          name: 'משחת שיניים',
          quantity: 1,
          unitPrice: 15.90,
          category: 'היגיינה',
          unit: 'יחידה',
        ),
      ];

      final receipt = Receipt.newReceipt(
        storeName: 'סופר-פארם',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 53.70,
        items: items,
      );

      expect(receipt.storeName, 'סופר-פארם');
      expect(receipt.items.every((item) => 
        item.category == 'תרופות' || item.category == 'היגיינה'
      ), true);
    });

    test('creates empty receipt for manual entry', () {
      final emptyReceipt = Receipt.newReceipt(
        storeName: 'חנות לא ידועה',
        date: DateTime.now(),
        householdId: 'test_household',
      );

      expect(emptyReceipt.items, isEmpty);
      expect(emptyReceipt.totalAmount, 0.0);
      expect(emptyReceipt.id, isNotEmpty);
    });

    test('calculates receipt statistics', () {
      final items = [
        ReceiptItem(name: 'פריט זול', quantity: 1, unitPrice: 2.50),
        ReceiptItem(name: 'פריט רגיל', quantity: 2, unitPrice: 10.00),
        ReceiptItem(name: 'פריט יקר', quantity: 1, unitPrice: 50.00),
      ];

      final receipt = Receipt.newReceipt(
        storeName: 'חנות בדיקה',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 72.50,
        items: items,
      );

      // Calculate statistics
      final totalItems = receipt.items.fold<int>(0, (sum, item) => sum + item.quantity);
      final avgPrice = receipt.totalAmount / totalItems;
      final minPrice = receipt.items.map((i) => i.unitPrice).reduce((a, b) => a < b ? a : b);
      final maxPrice = receipt.items.map((i) => i.unitPrice).reduce((a, b) => a > b ? a : b);

      expect(totalItems, 4);
      expect(avgPrice, closeTo(18.125, 0.001));
      expect(minPrice, 2.50);
      expect(maxPrice, 50.00);
    });

    test('handles receipt with checked/unchecked items', () {
      final items = [
        ReceiptItem(id: '1', name: 'חלב', quantity: 1, unitPrice: 6.50, isChecked: true),
        ReceiptItem(id: '2', name: 'לחם', quantity: 1, unitPrice: 8.90, isChecked: true),
        ReceiptItem(id: '3', name: 'ביצים', quantity: 1, unitPrice: 15.90, isChecked: false),
        ReceiptItem(id: '4', name: 'גבינה', quantity: 1, unitPrice: 12.50, isChecked: true),
      ];

      final receipt = Receipt(
        id: 'receipt-checked',
        storeName: 'מגה',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 43.80,
        items: items,
      );

      // Count checked items
      final checkedItems = receipt.items.where((item) => item.isChecked).toList();
      final uncheckedItems = receipt.items.where((item) => !item.isChecked).toList();
      
      expect(checkedItems.length, 3);
      expect(uncheckedItems.length, 1);
      
      // Calculate checked total
      final checkedTotal = checkedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      expect(checkedTotal, closeTo(27.90, 0.01));
    });

    test('creates receipt from OCR with missing data', () {
      // Simulating OCR results with some missing fields
      final ocrItems = [
        ReceiptItem(
          id: '1',
          name: 'חלב',  // OCR recognized
          quantity: 2,
          unitPrice: 6.50,
        ),
        ReceiptItem(
          id: '2',
          name: null,  // OCR failed to recognize name
          quantity: 1,
          unitPrice: 8.90,
        ),
        ReceiptItem(
          id: '3',
          name: 'ביצים L',  // OCR recognized
          quantity: 1,
          unitPrice: 15.90,
        ),
      ];

      final receipt = Receipt(
        id: 'receipt-ocr',
        storeName: 'חנות',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 37.80,
        items: ocrItems,
      );

      // Check that some items have missing names
      final namedItems = receipt.items.where((item) => item.name != null).toList();
      final unnamedItems = receipt.items.where((item) => item.name == null).toList();
      
      expect(namedItems.length, 2);
      expect(unnamedItems.length, 1);
      
      // Verify total is still calculated correctly
      final calculatedTotal = receipt.items.fold(0.0, (sum, item) => sum + item.totalPrice);
      expect(calculatedTotal, receipt.totalAmount);
    });

    test('creates bulk purchase receipt', () {
      final bulkItems = [
        ReceiptItem(
          id: 'bulk-1',
          name: 'נייר טואלט - מארז 48',
          quantity: 1,
          unitPrice: 89.90,
          unit: 'מארז',
        ),
        ReceiptItem(
          id: 'bulk-2',
          name: 'מים מינרליים - קרטון',
          quantity: 2,
          unitPrice: 35.00,
          unit: 'קרטון',
        ),
        ReceiptItem(
          id: 'bulk-3',
          name: 'חיתולים - חבילת ענק',
          quantity: 1,
          unitPrice: 120.00,
          unit: 'חבילה',
        ),
      ];

      final receipt = Receipt.newReceipt(
        storeName: 'קוסטקו',
        date: DateTime.now(),
        householdId: 'test_household',
        totalAmount: 279.90,
        items: bulkItems,
      );

      expect(receipt.totalAmount, 279.90);
      expect(receipt.items.every((item) => item.unitPrice > 30), true);
    });
  });
}
