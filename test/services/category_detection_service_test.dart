// test/services/category_detection_service_test.dart
//
// Regression guard for the substring/ordering traps fixed in the
// longest-match-first + flavor-signal redesign (#13). Each "trap" case used
// to be miscategorized because a short fruit/coffee keyword won via raw
// substring matching in category-insertion order.

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/services/category_detection_service.dart';

String cat(String name) =>
    CategoryDetectionService.detectFromProductJson({'name': name});

void main() {
  group('CategoryDetectionService — trap fixes (#13)', () {
    test('מנגולד is a vegetable, not "מנגו" fruit', () {
      expect(cat('מנגולד טרי'), 'ירקות');
    });

    test('עגבניה תמר is a vegetable, not "תמר" fruit', () {
      expect(cat('עגבניה תמר'), 'ירקות');
    });

    test('מיץ תפוז is a drink, not "תפוז" fruit', () {
      expect(cat('מיץ תפוז סחוט'), 'משקאות');
    });

    test('מעדן בננה is not fruit', () {
      expect(cat('מעדן סויה בננה'), isNot('פירות'));
    });

    test('chocolate "בטעם קפה" is a snack, not coffee', () {
      expect(cat('ביס שוקולד בטעם קפה'), 'חטיפים');
    });
  });

  group('CategoryDetectionService — real produce/items still detected', () {
    test('fresh fruit', () => expect(cat('תפוח עץ אדום'), 'פירות'));
    test('fresh vegetable', () => expect(cat('מלפפון חלק'), 'ירקות'));
    test('dairy', () => expect(cat('חלב טרי 3%'), 'מוצרי חלב'));
    test('real coffee', () => expect(cat('קפה שחור טורקי'), 'קפה ותה'));
    test('flavored coffee stays coffee',
        () => expect(cat('קפה בטעם וניל'), 'קפה ותה'));
    test('unknown → אחר', () => expect(cat('מוצר לא מוכר כלשהו'), 'אחר'));
  });
}
