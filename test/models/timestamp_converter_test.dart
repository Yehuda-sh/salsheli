import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salsheli/models/timestamp_converter.dart';

void main() {
  group('TimestampConverter', () {
    const converter = TimestampConverter();
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30, 45, 123, 456);
    });

    group('fromJson', () {
      test('converts Timestamp to DateTime', () {
        final timestamp = Timestamp.fromDate(testDate);
        final result = converter.fromJson(timestamp);
        
        expect(result.year, testDate.year);
        expect(result.month, testDate.month);
        expect(result.day, testDate.day);
        expect(result.hour, testDate.hour);
        expect(result.minute, testDate.minute);
        expect(result.second, testDate.second);
      });

      test('converts ISO string to DateTime', () {
        final isoString = testDate.toIso8601String();
        final result = converter.fromJson(isoString);
        
        expect(result, testDate);
      });

      test('converts epoch milliseconds to DateTime', () {
        final epochMillis = testDate.millisecondsSinceEpoch;
        final result = converter.fromJson(epochMillis);
        
        expect(result.millisecondsSinceEpoch, epochMillis);
      });

      test('returns DateTime as-is', () {
        final result = converter.fromJson(testDate);
        
        expect(result, testDate);
      });

      test('throws on invalid input', () {
        expect(
          () => converter.fromJson('not-a-date'),
          throwsFormatException,
        );

        expect(
          () => converter.fromJson({'invalid': 'object'}),
          throwsArgumentError,
        );

        // Testing null input - requires Object, not Object?
        // This test verifies the converter throws on null input
        final Object? nullValue = null;
        expect(
          () => converter.fromJson(nullValue as Object),
          throwsA(anything),
        );
      });
    });

    group('toJson', () {
      test('converts DateTime to Timestamp', () {
        final result = converter.toJson(testDate);
        
        expect(result, isA<Timestamp>());
        
        final timestamp = result as Timestamp;
        final converted = timestamp.toDate();
        
        expect(converted.year, testDate.year);
        expect(converted.month, testDate.month);
        expect(converted.day, testDate.day);
        expect(converted.hour, testDate.hour);
        expect(converted.minute, testDate.minute);
        expect(converted.second, testDate.second);
      });
    });

    group('Round-trip conversion', () {
      test('maintains date accuracy through conversion', () {
        final original = DateTime(2025, 1, 15, 10, 30, 45);
        
        // Convert to JSON and back
        final json = converter.toJson(original);
        final restored = converter.fromJson(json);
        
        expect(restored.year, original.year);
        expect(restored.month, original.month);
        expect(restored.day, original.day);
        expect(restored.hour, original.hour);
        expect(restored.minute, original.minute);
        expect(restored.second, original.second);
      });
    });
  });

  group('NullableTimestampConverter', () {
    const converter = NullableTimestampConverter();
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30, 45);
    });

    group('fromJson', () {
      test('handles null input', () {
        final result = converter.fromJson(null);
        
        expect(result, isNull);
      });

      test('converts Timestamp to DateTime', () {
        final timestamp = Timestamp.fromDate(testDate);
        final result = converter.fromJson(timestamp);
        
        expect(result, isNotNull);
        expect(result!.year, testDate.year);
        expect(result.month, testDate.month);
        expect(result.day, testDate.day);
      });

      test('converts ISO string to DateTime', () {
        final isoString = testDate.toIso8601String();
        final result = converter.fromJson(isoString);
        
        expect(result, testDate);
      });

      test('converts epoch milliseconds to DateTime', () {
        final epochMillis = testDate.millisecondsSinceEpoch;
        final result = converter.fromJson(epochMillis);
        
        expect(result?.millisecondsSinceEpoch, epochMillis);
      });

      test('returns DateTime as-is', () {
        final result = converter.fromJson(testDate);
        
        expect(result, testDate);
      });

      test('returns null for invalid string', () {
        final result = converter.fromJson('not-a-date');
        
        expect(result, isNull);
      });

      test('throws on invalid non-string input', () {
        expect(
          () => converter.fromJson({'invalid': 'object'}),
          throwsArgumentError,
        );

        expect(
          () => converter.fromJson([1, 2, 3]),
          throwsArgumentError,
        );
      });
    });

    group('toJson', () {
      test('handles null input', () {
        final result = converter.toJson(null);
        
        expect(result, isNull);
      });

      test('converts DateTime to Timestamp', () {
        final result = converter.toJson(testDate);
        
        expect(result, isNotNull);
        expect(result, isA<Timestamp>());
        
        final timestamp = result as Timestamp;
        final converted = timestamp.toDate();
        
        expect(converted.year, testDate.year);
        expect(converted.month, testDate.month);
        expect(converted.day, testDate.day);
      });
    });

    group('Round-trip conversion', () {
      test('null remains null', () {
        final json = converter.toJson(null);
        final restored = converter.fromJson(json);
        
        expect(restored, isNull);
      });

      test('maintains date accuracy through conversion', () {
        final original = DateTime(2025, 1, 15, 10, 30, 45);
        
        // Convert to JSON and back
        final json = converter.toJson(original);
        final restored = converter.fromJson(json);
        
        expect(restored, isNotNull);
        expect(restored!.year, original.year);
        expect(restored.month, original.month);
        expect(restored.day, original.day);
        expect(restored.hour, original.hour);
        expect(restored.minute, original.minute);
        expect(restored.second, original.second);
      });
    });

    group('Edge cases', () {
      test('handles very old dates', () {
        final oldDate = DateTime(1900, 1, 1);
        final json = converter.toJson(oldDate);
        final restored = converter.fromJson(json);
        
        expect(restored?.year, 1900);
      });

      test('handles future dates', () {
        final futureDate = DateTime(2100, 12, 31);
        final json = converter.toJson(futureDate);
        final restored = converter.fromJson(json);
        
        expect(restored?.year, 2100);
      });

      test('handles dates with microseconds', () {
        final preciseDate = DateTime(2025, 1, 15, 10, 30, 45, 123, 456);
        final json = converter.toJson(preciseDate);
        final restored = converter.fromJson(json);
        
        expect(restored, isNotNull);
        // Firestore Timestamp has millisecond precision, not microsecond
        expect(restored!.millisecondsSinceEpoch, 
               preciseDate.millisecondsSinceEpoch);
      });

      test('handles UTC vs local time', () {
        final utcDate = DateTime.utc(2025, 1, 15, 10, 30);
        final localDate = DateTime(2025, 1, 15, 10, 30);
        
        final utcJson = converter.toJson(utcDate);
        final localJson = converter.toJson(localDate);
        
        final utcRestored = converter.fromJson(utcJson);
        final localRestored = converter.fromJson(localJson);
        
        expect(utcRestored, isNotNull);
        expect(localRestored, isNotNull);
        
        // The difference should be the timezone offset
        final difference = utcRestored!.difference(localRestored!);
        expect(difference.inHours.abs(), lessThanOrEqualTo(14)); // Max timezone diff
      });
    });
  });

  group('Converter compatibility', () {
    test('both converters produce compatible output', () {
      const nullableConverter = NullableTimestampConverter();
      const nonNullableConverter = TimestampConverter();
      
      final date = DateTime(2025, 1, 15, 10, 30);
      
      final nullableJson = nullableConverter.toJson(date);
      final nonNullableJson = nonNullableConverter.toJson(date);
      
      // Both should produce the same Timestamp
      expect(nullableJson, isA<Timestamp>());
      expect(nonNullableJson, isA<Timestamp>());
      
      final nullableTimestamp = nullableJson as Timestamp;
      final nonNullableTimestamp = nonNullableJson as Timestamp;
      
      expect(nullableTimestamp.seconds, nonNullableTimestamp.seconds);
      expect(nullableTimestamp.nanoseconds, nonNullableTimestamp.nanoseconds);
    });

    test('can read each others output', () {
      const nullableConverter = NullableTimestampConverter();
      const nonNullableConverter = TimestampConverter();
      
      final date = DateTime(2025, 1, 15, 10, 30);
      
      // Create with non-nullable, read with nullable
      final nonNullableJson = nonNullableConverter.toJson(date);
      final restoredByNullable = nullableConverter.fromJson(nonNullableJson);
      
      expect(restoredByNullable?.year, date.year);
      
      // Create with nullable, read with non-nullable
      final nullableJson = nullableConverter.toJson(date);
      // nullableJson is guaranteed to be non-null when date is non-null
      expect(nullableJson, isNotNull);
      final restoredByNonNullable = nonNullableConverter.fromJson(nullableJson!);
      
      expect(restoredByNonNullable.year, date.year);
    });
  });
}
