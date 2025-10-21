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

    group('Serialization Round-Trip', () {
      test('Item should maintain all data through JSON conversion', () {
        // Arrange
        final item = InventoryItem(
          id: 'test_123',
          productName: 'חלב 3%',
          category: 'מוצרי חלב',
          location: 'refrigerator',
          quantity: 2,
          unit: 'ליטר',
        );
        
        // Act
        final json = item.toJson();
        final deserializedItem = InventoryItem.fromJson(json);
        
        // Assert - All fields preserved
        expect(deserializedItem.id, item.id);
        expect(deserializedItem.productName, item.productName);
        expect(deserializedItem.category, item.category);
        expect(deserializedItem.location, item.location);
        expect(deserializedItem.quantity, item.quantity);
        expect(deserializedItem.unit, item.unit);
      });

      test('copyWith should create new instance with updated fields', () {
        // Arrange
        final item = InventoryItem(
          id: 'test_123',
          productName: 'קמח',
          category: 'מאפים',
          location: 'pantry',
          quantity: 1,
          unit: 'ק"ג',
        );
        
        // Act
        final updated = item.copyWith(
          quantity: 2,
          location: 'kitchen',
        );
        
        // Assert - Updated fields changed
        expect(updated.quantity, 2);
        expect(updated.location, 'kitchen');
        
        // Assert - Other fields unchanged
        expect(updated.id, item.id);
        expect(updated.productName, item.productName);
        expect(updated.category, item.category);
        expect(updated.unit, item.unit);
      });

      test('copyWith should NOT allow id modification', () {
        // Arrange
        final item = InventoryItem(
          id: 'original_id',
          productName: 'סוכר',
          category: 'מאפים',
          location: 'pantry',
          quantity: 1,
          unit: 'ק"ג',
        );
        
        // Act
        final updated = item.copyWith(productName: 'מלח');
        
        // Assert - ID never changes
        expect(updated.id, 'original_id');
      });
    });

    group('Edge Cases', () {
      test('Item with zero quantity should be valid', () {
        // Arrange
        final item = InventoryItem(
          id: 'test_123',
          productName: 'סוכר',
          category: 'מאפים',
          location: 'pantry',
          quantity: 0,
          unit: 'ק"ג',
        );
        
        // Act
        final json = item.toJson();
        final deserializedItem = InventoryItem.fromJson(json);
        
        // Assert
        expect(deserializedItem.quantity, 0);
      });

      test('Item with Hebrew text should preserve encoding', () {
        // Arrange
        final item = InventoryItem(
          id: 'test_123',
          productName: 'גבינה צהובה',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 1,
          unit: 'ק"ג',
        );
        
        // Act
        final json = item.toJson();
        final deserializedItem = InventoryItem.fromJson(json);
        
        // Assert - Hebrew text preserved correctly
        expect(deserializedItem.productName, 'גבינה צהובה');
        expect(deserializedItem.category, 'מוצרי חלב');
        expect(deserializedItem.location, 'מקרר');
      });

      test('Multiple items with different units should maintain uniqueness', () {
        // Arrange
        final item1 = InventoryItem(
          id: 'milk_1',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 2,
          unit: 'ליטר',
        );
        
        final item2 = InventoryItem(
          id: 'milk_2',
          productName: 'חלב',
          category: 'מוצרי חלב',
          location: 'מקרר',
          quantity: 1,
          unit: 'יח\'',
        );
        
        // Act & Assert - Same product, different ID and unit
        expect(item1.productName, item2.productName);
        expect(item1.id, isNot(item2.id));
        expect(item1.unit, isNot(item2.unit));
      });

      test('Item equality should consider all fields', () {
        // Arrange
        final item1 = InventoryItem(
          id: 'test_123',
          productName: 'מלח',
          category: 'תבלינים',
          location: 'ארון',
          quantity: 1,
          unit: 'יח\'',
        );
        
        final item2 = InventoryItem(
          id: 'test_123',
          productName: 'מלח',
          category: 'תבלינים',
          location: 'ארון',
          quantity: 1,
          unit: 'יח\'',
        );
        
        final item3 = item1.copyWith(quantity: 2);
        
        // Assert
        expect(item1, equals(item2));  // Same data = equal
        expect(item1, isNot(equals(item3)));  // Different quantity = not equal
        expect(item1.hashCode, equals(item2.hashCode));  // Same hash
        expect(item1.hashCode, isNot(equals(item3.hashCode)));  // Different hash
      });
    });

    // Integration tests should be in a separate file
    // and run against a test Firestore instance or emulator
  });
}
