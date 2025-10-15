import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/product_entity.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:math';

void main() {
  group('ProductEntity', () {
    late DateTime testDate;
    late Directory tempDir;

    setUpAll(() async {
      // Create a temporary directory for Hive in tests
      final random = Random().nextInt(100000);
      tempDir = Directory('test_hive_$random');
      
      // Initialize Hive with the temp directory
      Hive.init(tempDir.path);
      
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductEntityAdapter());
      }
    });

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    tearDown(() async {
      // Clean up any open boxes
      await Hive.deleteFromDisk();
    });
    
    tearDownAll(() async {
      // Clean up Hive and temp directory
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('creates with required fields', () {
      final product = ProductEntity(
        barcode: '7290000000123',
        name: 'חלב תנובה 3%',
        category: 'מוצרי חלב',
        brand: 'תנובה',
        unit: 'ליטר',
        icon: '🥛',
      );

      expect(product.barcode, '7290000000123');
      expect(product.name, 'חלב תנובה 3%');
      expect(product.category, 'מוצרי חלב');
      expect(product.brand, 'תנובה');
      expect(product.unit, 'ליטר');
      expect(product.icon, '🥛');
      expect(product.currentPrice, isNull);
      expect(product.lastPriceStore, isNull);
      expect(product.lastPriceUpdate, isNull);
    });

    test('creates with price information', () {
      final product = ProductEntity(
        barcode: '7290000000123',
        name: 'חלב תנובה 3%',
        category: 'מוצרי חלב',
        brand: 'תנובה',
        unit: 'ליטר',
        icon: '🥛',
        currentPrice: 6.50,
        lastPriceStore: 'רמי לוי',
        lastPriceUpdate: testDate,
      );

      expect(product.currentPrice, 6.50);
      expect(product.lastPriceStore, 'רמי לוי');
      expect(product.lastPriceUpdate, testDate);
    });

    group('isPriceValid', () {
      test('returns false when no price update', () {
        final product = ProductEntity(
          barcode: '123',
          name: 'מוצר',
          category: 'כללי',
          brand: 'מותג',
          unit: 'יח\'',
          icon: '🛒',
        );

        expect(product.isPriceValid, false);
      });

      test('returns true for recent price (less than 24 hours)', () {
        final product = ProductEntity(
          barcode: '123',
          name: 'מוצר',
          category: 'כללי',
          brand: 'מותג',
          unit: 'יח\'',
          icon: '🛒',
          currentPrice: 10.0,
          lastPriceStore: 'חנות',
          lastPriceUpdate: DateTime.now().subtract(Duration(hours: 12)),
        );

        expect(product.isPriceValid, true);
      });

      test('returns false for old price (more than 24 hours)', () {
        final product = ProductEntity(
          barcode: '123',
          name: 'מוצר',
          category: 'כללי',
          brand: 'מותג',
          unit: 'יח\'',
          icon: '🛒',
          currentPrice: 10.0,
          lastPriceStore: 'חנות',
          lastPriceUpdate: DateTime.now().subtract(Duration(hours: 25)),
        );

        expect(product.isPriceValid, false);
      });
    });

    group('fromPublishedProduct', () {
      test('creates from valid API response', () {
        final json = {
          'barcode': '7290000042138',
          'name': 'במבה אסם',
          'category': 'חטיפים',
          'brand': 'אסם',
          'unit': 'גרם',
          'icon': '🥜',
          'price': 7.90,
          'store': 'שופרסל',
        };

        final product = ProductEntity.fromPublishedProduct(json);

        expect(product.barcode, '7290000042138');
        expect(product.name, 'במבה אסם');
        expect(product.category, 'חטיפים');
        expect(product.brand, 'אסם');
        expect(product.unit, 'גרם');
        expect(product.icon, '🥜');
        expect(product.currentPrice, 7.90);
        expect(product.lastPriceStore, 'שופרסל');
        expect(product.lastPriceUpdate, isNotNull);
      });

      test('handles missing optional fields', () {
        final json = {
          'barcode': '123456789',
          'name': 'מוצר בסיסי',
          // Missing all optional fields
        };

        final product = ProductEntity.fromPublishedProduct(json);

        expect(product.barcode, '123456789');
        expect(product.name, 'מוצר בסיסי');
        expect(product.category, 'אחר');
        expect(product.brand, '');
        expect(product.unit, '');
        expect(product.icon, '🛒');
        expect(product.currentPrice, isNull);
        expect(product.lastPriceStore, isNull);
        expect(product.lastPriceUpdate, isNull);
      });

      test('handles price as integer', () {
        final json = {
          'barcode': '123',
          'name': 'מוצר',
          'price': 10,  // Integer instead of double
        };

        final product = ProductEntity.fromPublishedProduct(json);

        expect(product.currentPrice, 10.0);
      });

      test('throws on empty JSON', () {
        expect(
          () => ProductEntity.fromPublishedProduct({}),
          throwsArgumentError,
        );
      });

      test('throws on missing barcode', () {
        final json = {
          'name': 'מוצר ללא ברקוד',
        };

        expect(
          () => ProductEntity.fromPublishedProduct(json),
          throwsArgumentError,
        );
      });

      test('throws on missing name', () {
        final json = {
          'barcode': '123456789',
        };

        expect(
          () => ProductEntity.fromPublishedProduct(json),
          throwsArgumentError,
        );
      });
    });

    group('updatePrice', () {
      test('updates price information correctly', () async {
        // Create a test box
        final box = await Hive.openBox<ProductEntity>('test_products');
        
        final product = ProductEntity(
          barcode: '123',
          name: 'מוצר בדיקה',
          category: 'כללי',
          brand: 'מותג',
          unit: 'יח\'',
          icon: '🛒',
        );

        // Add to box first
        await box.put('123', product);
        
        // Update price
        product.updatePrice(price: 25.90, store: 'מגה');

        expect(product.currentPrice, 25.90);
        expect(product.lastPriceStore, 'מגה');
        expect(product.lastPriceUpdate, isNotNull);
        expect(product.lastPriceUpdate!.difference(DateTime.now()).inSeconds.abs(), lessThan(2));

        // Clean up
        await box.close();
      });
    });

    group('toMap', () {
      test('converts to Map correctly', () {
        final product = ProductEntity(
          barcode: '7290000000456',
          name: 'קוטג\' תנובה',
          category: 'מוצרי חלב',
          brand: 'תנובה',
          unit: 'גרם',
          icon: '🧀',
          currentPrice: 12.90,
          lastPriceStore: 'יינות ביתן',
          lastPriceUpdate: testDate,
        );

        final map = product.toMap();

        expect(map['barcode'], '7290000000456');
        expect(map['name'], 'קוטג\' תנובה');
        expect(map['category'], 'מוצרי חלב');
        expect(map['brand'], 'תנובה');
        expect(map['unit'], 'גרם');
        expect(map['icon'], '🧀');
        expect(map['price'], 12.90);
        expect(map['store'], 'יינות ביתן');
        expect(map['lastUpdate'], testDate.toIso8601String());
      });

      test('handles null price fields in toMap', () {
        final product = ProductEntity(
          barcode: '789',
          name: 'מוצר',
          category: 'כללי',
          brand: 'מותג',
          unit: 'יח\'',
          icon: '🛒',
        );

        final map = product.toMap();

        expect(map['price'], isNull);
        expect(map['store'], isNull);
        expect(map['lastUpdate'], isNull);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final product = ProductEntity(
          barcode: '123456789',
          name: 'חלב טרי',
          category: 'מוצרי חלב',
          brand: 'טרה',
          unit: 'ליטר',
          icon: '🥛',
          currentPrice: 6.90,
        );

        final str = product.toString();

        expect(str, contains('123456789'));
        expect(str, contains('חלב טרי'));
        expect(str, contains('6.9'));
      });
    });

    group('Common use cases', () {
      test('creates dairy product', () {
        final milk = ProductEntity(
          barcode: '7290000042138',
          name: 'חלב תנובה 3% 1 ליטר',
          category: 'מוצרי חלב',
          brand: 'תנובה',
          unit: 'ליטר',
          icon: '🥛',
          currentPrice: 6.50,
          lastPriceStore: 'רמי לוי',
          lastPriceUpdate: DateTime.now(),
        );

        expect(milk.category, 'מוצרי חלב');
        expect(milk.icon, '🥛');
        expect(milk.isPriceValid, true);
      });

      test('creates bakery product', () {
        final bread = ProductEntity(
          barcode: '7290000123456',
          name: 'לחם אנג\'ל אחיד',
          category: 'מאפים',
          brand: 'אנג\'ל',
          unit: 'יחידה',
          icon: '🍞',
        );

        expect(bread.category, 'מאפים');
        expect(bread.icon, '🍞');
        expect(bread.isPriceValid, false);  // No price yet
      });

      test('creates produce item', () {
        final tomatoes = ProductEntity(
          barcode: 'PLU-4664',  // Produce lookup code
          name: 'עגבניות',
          category: 'ירקות',
          brand: '',
          unit: 'ק"ג',
          icon: '🍅',
          currentPrice: 4.90,
          lastPriceStore: 'שוק',
          lastPriceUpdate: DateTime.now().subtract(Duration(hours: 2)),
        );

        expect(tomatoes.category, 'ירקות');
        expect(tomatoes.icon, '🍅');
        expect(tomatoes.isPriceValid, true);
      });
    });
  });
}
