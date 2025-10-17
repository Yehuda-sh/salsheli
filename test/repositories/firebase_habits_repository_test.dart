// 📄 File: test/repositories/firebase_habits_repository_test.dart
//
// 🧪 Unit tests for FirebaseHabitsRepository
//
// Version: 1.0
// Created: 17/10/2025

import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/repositories/firebase_habits_repository.dart';
import 'package:salsheli/models/habit_preference.dart';

void main() {
  group('FirebaseHabitsRepository', () {
    group('Exception Handling', () {
      test('HabitsRepositoryException should format correctly', () {
        // Arrange
        const message = 'Failed to fetch habits';
        const cause = 'Network error';
        
        // Act
        final exception = HabitsRepositoryException(message, cause);
        
        // Assert
        expect(
          exception.toString(),
          'HabitsRepositoryException: Failed to fetch habits (Cause: Network error)',
        );
      });

      test('HabitsRepositoryException without cause should format correctly', () {
        // Arrange
        const message = 'Failed to fetch habits';
        
        // Act
        final exception = HabitsRepositoryException(message, null);
        
        // Assert
        expect(
          exception.toString(),
          'HabitsRepositoryException: Failed to fetch habits',
        );
      });
    });

    group('Data Validation', () {
      test('HabitPreference should have required fields', () {
        // Arrange
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב תנובה 3%',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: DateTime(2025, 1, 15),
          createdDate: DateTime(2025, 1, 1),
          updatedDate: DateTime(2025, 1, 15),
        );
        
        // Act
        final json = habit.toJson();
        
        // Assert
        expect(json['id'], 'habit_123');
        expect(json['preferred_product'], 'חלב תנובה 3%');
        expect(json['generic_name'], 'חלב');
        expect(json['frequency_days'], 7);
        expect(json['last_purchased'], isNotNull);
        expect(json['created_date'], isNotNull);
        expect(json['updated_date'], isNotNull);
      });

      test('HabitPreference from JSON should parse correctly', () {
        // Arrange
        final json = {
          'id': 'habit_123',
          'preferred_product': 'חלב תנובה 3%',
          'generic_name': 'חלב',
          'frequency_days': 7,
          'last_purchased': DateTime(2025, 1, 15).toIso8601String(),
          'created_date': DateTime(2025, 1, 1).toIso8601String(),
          'updated_date': DateTime(2025, 1, 15).toIso8601String(),
        };
        
        // Act
        final habit = HabitPreference.fromJson(json);
        
        // Assert
        expect(habit.id, 'habit_123');
        expect(habit.preferredProduct, 'חלב תנובה 3%');
        expect(habit.genericName, 'חלב');
        expect(habit.frequencyDays, 7);
        expect(habit.lastPurchased, isA<DateTime>());
      });

      test('HabitPreference copyWith should preserve unchanged fields', () {
        // Arrange
        final original = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב תנובה 3%',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: DateTime(2025, 1, 15),
          createdDate: DateTime(2025, 1, 1),
          updatedDate: DateTime(2025, 1, 15),
        );
        
        // Act
        final updated = original.copyWith(
          frequencyDays: 14,
        );
        
        // Assert
        expect(updated.id, original.id);
        expect(updated.preferredProduct, original.preferredProduct);
        expect(updated.genericName, original.genericName);
        expect(updated.frequencyDays, 14);
        expect(updated.lastPurchased, original.lastPurchased);
      });

      test('HabitPreference should calculate days since last purchase', () {
        // Arrange
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 5)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 5)),
        );
        
        // Act
        final daysSince = now.difference(habit.lastPurchased!).inDays;
        
        // Assert
        expect(daysSince, 5);
      });

      test('HabitPreference should indicate when reorder is needed', () {
        // Arrange
        final now = DateTime.now();
        final habitNeedsReorder = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 8)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 8)),
        );
        
        final habitDoesNotNeedReorder = HabitPreference(
          id: 'habit_456',
          preferredProduct: 'לחם',
          genericName: 'לחם',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 3)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 3)),
        );
        
        // Act
        final daysSinceReorder = now.difference(habitNeedsReorder.lastPurchased!).inDays;
        final daysSinceNoReorder = now.difference(habitDoesNotNeedReorder.lastPurchased!).inDays;
        
        // Assert
        expect(daysSinceReorder > habitNeedsReorder.frequencyDays, true);
        expect(daysSinceNoReorder > habitDoesNotNeedReorder.frequencyDays, false);
      });
    });

    group('Business Logic', () {
      test('Should handle various frequency patterns', () {
        // Arrange
        final now = DateTime.now();
        final dailyHabit = HabitPreference(
          id: 'habit_1',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 1, // Daily
          lastPurchased: now,
          createdDate: now,
          updatedDate: now,
        );
        
        final weeklyHabit = HabitPreference(
          id: 'habit_2',
          preferredProduct: 'לחם',
          genericName: 'לחם',
          frequencyDays: 7, // Weekly
          lastPurchased: now,
          createdDate: now,
          updatedDate: now,
        );
        
        final monthlyHabit = HabitPreference(
          id: 'habit_3',
          preferredProduct: 'שמפו',
          genericName: 'שמפו',
          frequencyDays: 30, // Monthly
          lastPurchased: now,
          createdDate: now,
          updatedDate: now,
        );
        
        // Assert
        expect(dailyHabit.frequencyDays, 1);
        expect(weeklyHabit.frequencyDays, 7);
        expect(monthlyHabit.frequencyDays, 30);
      });
    });

    group('Smart Getters', () {
      test('predictedNextPurchase should calculate correct date', () {
        // Arrange
        final lastPurchased = DateTime(2025, 1, 1);
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: lastPurchased,
          createdDate: DateTime(2024, 12, 1),
          updatedDate: lastPurchased,
        );
        
        // Act
        final predicted = habit.predictedNextPurchase;
        
        // Assert
        expect(predicted, DateTime(2025, 1, 8)); // 7 days later
      });

      test('daysUntilNextPurchase should calculate remaining days', () {
        // Arrange - purchased 5 days ago, frequency is 7 days
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 5)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 5)),
        );
        
        // Act
        final daysUntil = habit.daysUntilNextPurchase;
        
        // Assert - should be around 2 days (7 - 5 = 2)
        expect(daysUntil, closeTo(2, 1)); // Allow 1 day tolerance for timing
      });

      test('daysUntilNextPurchase should be negative when overdue', () {
        // Arrange - purchased 10 days ago, frequency is 7 days
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 10)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 10)),
        );
        
        // Act
        final daysUntil = habit.daysUntilNextPurchase;
        
        // Assert - should be negative (overdue by ~3 days)
        expect(daysUntil, lessThan(0));
      });

      test('isDueForPurchase should be true when overdue', () {
        // Arrange - purchased 10 days ago, frequency is 7 days
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 10)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 10)),
        );
        
        // Act & Assert
        expect(habit.isDueForPurchase, isTrue);
      });

      test('isDueForPurchase should be true when due tomorrow', () {
        // Arrange - purchased 6 days ago, frequency is 7 days (due tomorrow)
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 6)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 6)),
        );
        
        // Act & Assert
        expect(habit.isDueForPurchase, isTrue); // <= 1 day
      });

      test('isDueForPurchase should be false when still has time', () {
        // Arrange - purchased 3 days ago, frequency is 7 days (4 days left)
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now.subtract(const Duration(days: 3)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 3)),
        );
        
        // Act & Assert
        expect(habit.isDueForPurchase, isFalse);
      });
    });

    group('Edge Cases', () {
      test('Should handle same-day purchase (new habit)', () {
        // Arrange
        final now = DateTime.now();
        final habit = HabitPreference(
          id: 'habit_123',
          preferredProduct: 'חלב',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: now,
          createdDate: now,
          updatedDate: now,
        );
        
        // Act
        final isNewHabit = habit.lastPurchased == habit.createdDate;
        
        // Assert
        expect(isNewHabit, isTrue);
        expect(habit.isDueForPurchase, isFalse); // Just bought, not due yet
      });

      test('Should handle extreme frequencies', () {
        // Arrange
        final now = DateTime.now();
        
        // Very frequent (daily)
        final dailyHabit = HabitPreference(
          id: 'habit_1',
          preferredProduct: 'לחם',
          genericName: 'לחם',
          frequencyDays: 1,
          lastPurchased: now.subtract(const Duration(days: 1)),
          createdDate: now.subtract(const Duration(days: 30)),
          updatedDate: now.subtract(const Duration(days: 1)),
        );
        
        // Very rare (quarterly)
        final quarterlyHabit = HabitPreference(
          id: 'habit_2',
          preferredProduct: 'שמפו',
          genericName: 'שמפו',
          frequencyDays: 90,
          lastPurchased: now.subtract(const Duration(days: 30)),
          createdDate: now.subtract(const Duration(days: 120)),
          updatedDate: now.subtract(const Duration(days: 30)),
        );
        
        // Assert
        expect(dailyHabit.isDueForPurchase, isTrue);  // 1 day passed
        expect(quarterlyHabit.isDueForPurchase, isFalse);  // Only 30/90 days passed
      });
    });

    // Note: Integration tests with Firestore should be in a separate file
    // and run against a test Firestore instance or emulator
  });
}
