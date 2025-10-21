// 📄 File: test/repositories/firestore_utils_test.dart
//
// 🧪 Unit tests for FirestoreUtils
//
// Version: 1.0
// Created: 17/10/2025

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memozap/repositories/utils/firestore_utils.dart';

void main() {
  group('FirestoreUtils', () {
    group('convertTimestamps', () {
      test('should convert Timestamp fields to ISO 8601 strings', () {
        // Arrange
        final now = DateTime.now();
        final timestamp = Timestamp.fromDate(now);
        final data = {
          'created_date': timestamp,
          'updated_date': timestamp,
          'regular_field': 'test',
          'number_field': 123,
        };

        // Act
        final result = FirestoreUtils.convertTimestamps(data);

        // Assert
        expect(result['created_date'], isA<String>());
        expect(result['created_date'], now.toIso8601String());
        expect(result['updated_date'], isA<String>());
        expect(result['regular_field'], 'test');
        expect(result['number_field'], 123);
      });

      test('should handle null timestamp fields', () {
        // Arrange
        final data = {
          'created_date': null,
          'updated_date': null,
          'regular_field': 'test',
        };

        // Act
        final result = FirestoreUtils.convertTimestamps(data);

        // Assert
        expect(result['created_date'], null);
        expect(result['updated_date'], null);
        expect(result['regular_field'], 'test');
      });

      test('should use custom timestamp fields list', () {
        // Arrange
        final timestamp = Timestamp.fromDate(DateTime.now());
        final data = {
          'custom_date': timestamp,
          'created_date': timestamp, // Should not be converted
        };

        // Act
        final result = FirestoreUtils.convertTimestamps(
          data,
          timestampFields: ['custom_date'],
        );

        // Assert
        expect(result['custom_date'], isA<String>());
        expect(result['created_date'], isA<Timestamp>());
      });
    });

    group('cleanEmptyFields', () {
      test('should remove null fields', () {
        // Arrange
        final data = {
          'field1': 'value',
          'field2': null,
          'field3': 123,
          'field4': null,
        };

        // Act
        final result = FirestoreUtils.cleanEmptyFields(data);

        // Assert
        expect(result.containsKey('field1'), true);
        expect(result.containsKey('field2'), false);
        expect(result.containsKey('field3'), true);
        expect(result.containsKey('field4'), false);
      });

      test('should remove empty strings', () {
        // Arrange
        final data = {
          'field1': 'value',
          'field2': '',
          'field3': '   ', // Not empty, just whitespace
        };

        // Act
        final result = FirestoreUtils.cleanEmptyFields(data);

        // Assert
        expect(result.containsKey('field1'), true);
        expect(result.containsKey('field2'), false);
        expect(result.containsKey('field3'), true); // Whitespace is not empty
      });

      test('should remove empty lists', () {
        // Arrange
        final data = {
          'field1': ['item'],
          'field2': [],
          'field3': <String>[],
        };

        // Act
        final result = FirestoreUtils.cleanEmptyFields(data);

        // Assert
        expect(result.containsKey('field1'), true);
        expect(result.containsKey('field2'), false);
        expect(result.containsKey('field3'), false);
      });

      test('should remove empty maps', () {
        // Arrange
        final data = {
          'field1': {'key': 'value'},
          'field2': {},
          'field3': <String, dynamic>{},
        };

        // Act
        final result = FirestoreUtils.cleanEmptyFields(data);

        // Assert
        expect(result.containsKey('field1'), true);
        expect(result.containsKey('field2'), false);
        expect(result.containsKey('field3'), false);
      });
    });

    group('hasValidField', () {
      test('should return true for valid string field', () {
        // Arrange
        final data = {'name': 'John Doe'};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'name'), true);
      });

      test('should return false for empty string field', () {
        // Arrange
        final data = {'name': ''};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'name'), false);
      });

      test('should return false for null field', () {
        // Arrange
        final data = {'name': null};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'name'), false);
      });

      test('should return false for missing field', () {
        // Arrange
        final data = <String, dynamic>{};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'name'), false);
      });

      test('should return true for valid list field', () {
        // Arrange
        final data = {'items': ['item1', 'item2']};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'items'), true);
      });

      test('should return false for empty list field', () {
        // Arrange
        final data = {'items': []};

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'items'), false);
      });

      test('should return true for non-string non-list field', () {
        // Arrange
        final data = {
          'number': 42,
          'boolean': true,
          'map': {'key': 'value'},
        };

        // Act & Assert
        expect(FirestoreUtils.hasValidField(data, 'number'), true);
        expect(FirestoreUtils.hasValidField(data, 'boolean'), true);
        expect(FirestoreUtils.hasValidField(data, 'map'), true);
      });
    });

    group('validateHouseholdId', () {
      test('should return true when household_id matches', () {
        // Arrange
        final data = {'household_id': 'house_123'};
        const expectedId = 'house_123';

        // Act & Assert
        expect(
          FirestoreUtils.validateHouseholdId(data, expectedId),
          true,
        );
      });

      test('should return false when household_id does not match', () {
        // Arrange
        final data = {'household_id': 'house_123'};
        const expectedId = 'house_456';

        // Act & Assert
        expect(
          FirestoreUtils.validateHouseholdId(data, expectedId),
          false,
        );
      });

      test('should return false when household_id is null', () {
        // Arrange
        final data = {'household_id': null};
        const expectedId = 'house_123';

        // Act & Assert
        expect(
          FirestoreUtils.validateHouseholdId(data, expectedId),
          false,
        );
      });

      test('should return false when household_id is missing', () {
        // Arrange
        final data = <String, dynamic>{};
        const expectedId = 'house_123';

        // Act & Assert
        expect(
          FirestoreUtils.validateHouseholdId(data, expectedId),
          false,
        );
      });
    });

    group('addHouseholdId', () {
      test('should add household_id to data', () {
        // Arrange
        final data = {'name': 'Test Item'};
        const householdId = 'house_123';

        // Act
        final result = FirestoreUtils.addHouseholdId(data, householdId);

        // Assert
        expect(result['household_id'], householdId);
        expect(result['name'], 'Test Item');
      });

      test('should overwrite existing household_id', () {
        // Arrange
        final data = {
          'name': 'Test Item',
          'household_id': 'old_house',
        };
        const householdId = 'new_house';

        // Act
        final result = FirestoreUtils.addHouseholdId(data, householdId);

        // Assert
        expect(result['household_id'], householdId);
      });
    });

    group('createHouseholdDocId', () {
      test('should create correct document ID format', () {
        // Arrange
        const householdId = 'house_123';
        const key = 'item_456';

        // Act
        final result = FirestoreUtils.createHouseholdDocId(householdId, key);

        // Assert
        expect(result, 'house_123_item_456');
      });

      test('should handle special characters', () {
        // Arrange
        const householdId = 'house-abc';
        const key = 'item.xyz';

        // Act
        final result = FirestoreUtils.createHouseholdDocId(householdId, key);

        // Assert
        expect(result, 'house-abc_item.xyz');
      });
    });

    group('createBatches', () {
      test('should create single batch for small list', () {
        // Arrange
        final items = List.generate(50, (i) => 'item_$i');

        // Act
        final batches = FirestoreUtils.createBatches(items);

        // Assert
        expect(batches.length, 1);
        expect(batches[0].length, 50);
      });

      test('should create multiple batches for large list', () {
        // Arrange
        final items = List.generate(1200, (i) => 'item_$i');

        // Act
        final batches = FirestoreUtils.createBatches(items);

        // Assert
        expect(batches.length, 3);
        expect(batches[0].length, 500);
        expect(batches[1].length, 500);
        expect(batches[2].length, 200);
      });

      test('should respect custom batch size', () {
        // Arrange
        final items = List.generate(250, (i) => 'item_$i');

        // Act
        final batches = FirestoreUtils.createBatches(items, batchSize: 100);

        // Assert
        expect(batches.length, 3);
        expect(batches[0].length, 100);
        expect(batches[1].length, 100);
        expect(batches[2].length, 50);
      });

      test('should handle empty list', () {
        // Arrange
        final items = <String>[];

        // Act
        final batches = FirestoreUtils.createBatches(items);

        // Assert
        expect(batches.length, 0);
      });

      test('should handle exact batch size', () {
        // Arrange
        final items = List.generate(500, (i) => 'item_$i');

        // Act
        final batches = FirestoreUtils.createBatches(items);

        // Assert
        expect(batches.length, 1);
        expect(batches[0].length, 500);
      });
    });
  });
}
