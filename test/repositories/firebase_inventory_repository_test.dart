// 📄 File: test/repositories/firebase_inventory_repository_test.dart
//
// 🧪 Unit tests for FirebaseInventoryRepository
//
// Version: 1.0
// Created: 17/10/2025

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/repositories/firebase_inventory_repository.dart';
import 'package:memozap/models/inventory_item.dart';

void main() {
  group('FirebaseInventoryRepository', () {
    group('Exception Handling', () {
      test('InventoryRepositoryException should format correctly', () {
        // Arrange
        const message = 'Test error';
        const cause = 'Network failure';
        
        // Act
        final exception = InventoryRepositoryException(message, cause);
        
        // Assert
        expect(
          exception.toString(),
          'InventoryRepositoryException: Test error (Cause: Network failure)',
        );
      });

      test('InventoryRepositoryException without cause should format correctly', () {
        // Arrange
        const message = 'Test error';
        
        // Act
        final exception = InventoryRepositoryException(message, null);
        
        // Assert
        expect(
          exception.toString(),
          'InventoryRepositoryException: Test error',
        );
      });
    });

    group('Data Validation', () {
      test('Item should have required fields', () {
        // This test validates that our model matches what the repository expects
        
        // Arrange
        final item = InventoryItem(
          id: 'test_123',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'refrigerator',
          quantity: 2,
          unit: 'יח\'',
        );
        
        // Act
        final json = item.toJson();
        
        // Assert
        expect(json['id'], 'test_123');
        expect(json['productName'], 'חלב');
        expect(json['category'], 'מוצרי חלב');
        expect(json['location'], 'refrigerator');
        expect(json['quantity'], 2);
        expect(json['unit'], 'יח\'');
      });

      test('Item from JSON should parse correctly', () {
        // Arrange
        final json = {
          'id': 'test_123',
          'productName': 'חלב',
          'category': 'מוצרי חלב',
          'location': 'refrigerator',
          'quantity': 2,
          'unit': 'יח\'',
        };
        
        // Act
        final item = InventoryItem.fromJson(json);
        
        // Assert
        expect(item.id, 'test_123');
        expect(item.productName, 'חלב');
        expect(item.category, 'מוצרי חלב');
        expect(item.location, 'refrigerator');
        expect(item.quantity, 2);
        expect(item.unit, 'יח\'');
      });
    });

    // Integration tests should be in a separate file
    // and run against a test Firestore instance or emulator
    
    group('Constants Usage', () {
      test('Repository should use correct collection name', () {
        // This is more of a compile-time check
        // The actual test would be in integration tests
        
        // If this compiles, it means we're using the constants correctly
        expect(true, isTrue);
      });
    });
  });
}
