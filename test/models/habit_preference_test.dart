import 'package:flutter_test/flutter_test.dart';
import 'package:salsheli/models/habit_preference.dart';

void main() {
  group('HabitPreference', () {
    late DateTime testDate;
    late DateTime pastDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
      pastDate = DateTime(2025, 1, 8, 10, 30);  // 7 days ago
    });

    test('creates with all required fields', () {
      final habit = HabitPreference(
        id: 'habit-123',
        preferredProduct: '7290000000123',
        genericName: 'חלב',
        frequencyDays: 7,
        lastPurchased: pastDate,
        createdDate: pastDate,
        updatedDate: testDate,
      );

      expect(habit.id, 'habit-123');
      expect(habit.preferredProduct, '7290000000123');
      expect(habit.genericName, 'חלב');
      expect(habit.frequencyDays, 7);
      expect(habit.lastPurchased, pastDate);
      expect(habit.createdDate, pastDate);
      expect(habit.updatedDate, testDate);
    });

    group('Computed Properties', () {
      test('predictedNextPurchase calculates correctly', () {
        final habit = HabitPreference(
          id: 'habit-1',
          preferredProduct: 'product-123',
          genericName: 'מוצר',
          frequencyDays: 7,
          lastPurchased: DateTime(2025, 1, 10),
          createdDate: DateTime(2025, 1, 1),
          updatedDate: DateTime(2025, 1, 10),
        );

        final expected = DateTime(2025, 1, 17);  // 10 + 7 days
        expect(habit.predictedNextPurchase, expected);
      });

      test('daysUntilNextPurchase calculates correctly', () {
        final now = DateTime.now();
        
        // Purchase that should happen in 3 days
        final futurePurchase = HabitPreference(
          id: 'habit-1',
          preferredProduct: 'product-123',
          genericName: 'מוצר',
          frequencyDays: 10,
          lastPurchased: now.subtract(Duration(days: 7)),  // 7 days ago
          createdDate: now,
          updatedDate: now,
        );

        // Purchase that's overdue by 2 days
        final overduePurchase = HabitPreference(
          id: 'habit-2',
          preferredProduct: 'product-456',
          genericName: 'מוצר אחר',
          frequencyDays: 5,
          lastPurchased: now.subtract(Duration(days: 7)),  // 7 days ago
          createdDate: now,
          updatedDate: now,
        );

        expect(futurePurchase.daysUntilNextPurchase, closeTo(3, 1));
        expect(overduePurchase.daysUntilNextPurchase, closeTo(-2, 1));
      });

      test('isDueForPurchase identifies due items', () {
        final now = DateTime.now();

        // Due today
        final dueToday = HabitPreference(
          id: 'habit-1',
          preferredProduct: 'product-123',
          genericName: 'מוצר',
          frequencyDays: 7,
          lastPurchased: now.subtract(Duration(days: 7)),
          createdDate: now,
          updatedDate: now,
        );

        // Due tomorrow
        final dueTomorrow = HabitPreference(
          id: 'habit-2',
          preferredProduct: 'product-456',
          genericName: 'מוצר',
          frequencyDays: 7,
          lastPurchased: now.subtract(Duration(days: 6)),
          createdDate: now,
          updatedDate: now,
        );

        // Due in 3 days (not yet)
        final dueInThreeDays = HabitPreference(
          id: 'habit-3',
          preferredProduct: 'product-789',
          genericName: 'מוצר',
          frequencyDays: 7,
          lastPurchased: now.subtract(Duration(days: 4)),
          createdDate: now,
          updatedDate: now,
        );

        // Overdue
        final overdue = HabitPreference(
          id: 'habit-4',
          preferredProduct: 'product-000',
          genericName: 'מוצר',
          frequencyDays: 7,
          lastPurchased: now.subtract(Duration(days: 10)),
          createdDate: now,
          updatedDate: now,
        );

        expect(dueToday.isDueForPurchase, true);
        expect(dueTomorrow.isDueForPurchase, true);  // Due within 1 day
        expect(dueInThreeDays.isDueForPurchase, false);
        expect(overdue.isDueForPurchase, true);
      });
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = HabitPreference(
          id: 'habit-123',
          preferredProduct: '7290000000123',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: pastDate,
          createdDate: pastDate,
          updatedDate: testDate,
        );

        final updated = original.copyWith(
          frequencyDays: 14,
          lastPurchased: testDate,
          updatedDate: DateTime.now(),
        );

        expect(updated.frequencyDays, 14);
        expect(updated.lastPurchased, testDate);
        expect(updated.updatedDate, isNot(testDate));
        
        // Unchanged fields
        expect(updated.id, original.id);
        expect(updated.preferredProduct, original.preferredProduct);
        expect(updated.genericName, original.genericName);
        expect(updated.createdDate, original.createdDate);
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = HabitPreference(
          id: 'habit-456',
          preferredProduct: 'barcode-123456',
          genericName: 'לחם',
          frequencyDays: 3,
          lastPurchased: pastDate,
          createdDate: pastDate.subtract(Duration(days: 30)),
          updatedDate: testDate,
        );

        final json = original.toJson();
        final restored = HabitPreference.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.preferredProduct, original.preferredProduct);
        expect(restored.genericName, original.genericName);
        expect(restored.frequencyDays, original.frequencyDays);
        expect(restored.lastPurchased, original.lastPurchased);
        expect(restored.createdDate, original.createdDate);
        expect(restored.updatedDate, original.updatedDate);
      });

      test('JSON structure uses snake_case', () {
        final habit = HabitPreference(
          id: 'habit-789',
          preferredProduct: 'product-test',
          genericName: 'מוצר בדיקה',
          frequencyDays: 10,
          lastPurchased: testDate,
          createdDate: pastDate,
          updatedDate: testDate,
        );

        final json = habit.toJson();

        expect(json.containsKey('preferred_product'), true);
        expect(json.containsKey('generic_name'), true);
        expect(json.containsKey('frequency_days'), true);
        expect(json.containsKey('last_purchased'), true);
        expect(json.containsKey('created_date'), true);
        expect(json.containsKey('updated_date'), true);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final habit = HabitPreference(
          id: 'habit-123',
          preferredProduct: 'תנובה חלב 3%',
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: testDate,
          createdDate: testDate,
          updatedDate: testDate,
        );

        final str = habit.toString();

        expect(str, contains('habit-123'));
        expect(str, contains('תנובה חלב 3%'));
        expect(str, contains('7d'));
      });
    });

    group('Common use cases', () {
      test('creates weekly purchase habit', () {
        final weeklyMilk = HabitPreference(
          id: 'habit-milk',
          preferredProduct: '7290000042138',  // Tnuva milk barcode
          genericName: 'חלב',
          frequencyDays: 7,
          lastPurchased: DateTime.now().subtract(Duration(days: 5)),
          createdDate: DateTime.now().subtract(Duration(days: 60)),
          updatedDate: DateTime.now(),
        );

        expect(weeklyMilk.frequencyDays, 7);
        expect(weeklyMilk.daysUntilNextPurchase, closeTo(2, 1));
        expect(weeklyMilk.isDueForPurchase, false);
      });

      test('creates bi-weekly purchase habit', () {
        final biWeeklyDetergent = HabitPreference(
          id: 'habit-detergent',
          preferredProduct: 'sano-max-barcode',
          genericName: 'אבקת כביסה',
          frequencyDays: 14,
          lastPurchased: DateTime.now().subtract(Duration(days: 13)),
          createdDate: DateTime.now().subtract(Duration(days: 90)),
          updatedDate: DateTime.now(),
        );

        expect(biWeeklyDetergent.frequencyDays, 14);
        expect(biWeeklyDetergent.daysUntilNextPurchase, closeTo(1, 1));
        expect(biWeeklyDetergent.isDueForPurchase, true);  // Due within 1 day
      });

      test('creates daily purchase habit', () {
        final dailyBread = HabitPreference(
          id: 'habit-bread',
          preferredProduct: 'angel-bread-barcode',
          genericName: 'לחם',
          frequencyDays: 1,
          lastPurchased: DateTime.now().subtract(Duration(days: 1)),
          createdDate: DateTime.now().subtract(Duration(days: 30)),
          updatedDate: DateTime.now(),
        );

        expect(dailyBread.frequencyDays, 1);
        expect(dailyBread.daysUntilNextPurchase, closeTo(0, 1));
        expect(dailyBread.isDueForPurchase, true);
      });

      test('creates monthly purchase habit', () {
        final monthlyToiletPaper = HabitPreference(
          id: 'habit-tp',
          preferredProduct: 'lily-tp-barcode',
          genericName: 'נייר טואלט',
          frequencyDays: 30,
          lastPurchased: DateTime.now().subtract(Duration(days: 25)),
          createdDate: DateTime.now().subtract(Duration(days: 180)),
          updatedDate: DateTime.now(),
        );

        expect(monthlyToiletPaper.frequencyDays, 30);
        expect(monthlyToiletPaper.daysUntilNextPurchase, closeTo(5, 1));
        expect(monthlyToiletPaper.isDueForPurchase, false);
      });
    });
  });
}
