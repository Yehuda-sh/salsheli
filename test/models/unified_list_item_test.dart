import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/models/enums/item_type.dart';

void main() {
  group('UnifiedListItem', () {
    group('Product', () {
      test('factory constructor יוצר product נכון', () {
        final item = UnifiedListItem.product(
          id: '1',
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.90,
          barcode: '1234567890',
          unit: 'בקבוקים',
        );

        expect(item.type, ItemType.product);
        expect(item.name, 'חלב');
        expect(item.quantity, 2);
        expect(item.unitPrice, 6.90);
        expect(item.barcode, '1234567890');
        expect(item.unit, 'בקבוקים');
        expect(item.totalPrice, 13.80);
      });

      test('totalPrice מחושב נכון', () {
        final item = UnifiedListItem.product(
          id: '1',
          name: 'בננות',
          quantity: 5,
          unitPrice: 2.50,
        );

        expect(item.totalPrice, 12.50);
      });

      test('productData מוגדר נכון', () {
        final item = UnifiedListItem.product(
          id: '1',
          name: 'לחם',
          quantity: 3,
          unitPrice: 5.90,
        );

        expect(item.productData, isNotNull);
        expect(item.productData!['quantity'], 3);
        expect(item.productData!['unitPrice'], 5.90);
        expect(item.taskData, isNull);
      });
    });

    group('Task', () {
      test('factory constructor יוצר task נכון', () {
        final dueDate = DateTime(2025, 11, 15);
        final item = UnifiedListItem.task(
          id: '1',
          name: 'להזמין עוגה',
          dueDate: dueDate,
          assignedTo: 'דני',
          priority: 'high',
        );

        expect(item.type, ItemType.task);
        expect(item.name, 'להזמין עוגה');
        expect(item.dueDate, dueDate);
        expect(item.assignedTo, 'דני');
        expect(item.priority, 'high');
      });

      test('isUrgent מזהה משימה דחופה', () {
        // משימה בעוד יומיים - דחופה
        final urgentTask = UnifiedListItem.task(
          id: '1',
          name: 'דחוף',
          dueDate: DateTime.now().add(Duration(days: 2)),
        );

        expect(urgentTask.isUrgent, true);
      });

      test('isUrgent לא דחוף למשימה רחוקה', () {
        // משימה בעוד שבוע - לא דחופה
        final normalTask = UnifiedListItem.task(
          id: '1',
          name: 'רגיל',
          dueDate: DateTime.now().add(Duration(days: 7)),
        );

        expect(normalTask.isUrgent, false);
      });

      test('taskData מוגדר נכון', () {
        final dueDate = DateTime(2025, 11, 15);
        final item = UnifiedListItem.task(
          id: '1',
          name: 'משימה',
          dueDate: dueDate,
          priority: 'high',
        );

        expect(item.taskData, isNotNull);
        expect(item.taskData!['dueDate'], dueDate.toIso8601String());
        expect(item.taskData!['priority'], 'high');
        expect(item.productData, isNull);
      });
    });

    group('JSON Serialization', () {
      test('product → JSON → product', () {
        final original = UnifiedListItem.product(
          id: '1',
          name: 'מוצר',
          quantity: 5,
          unitPrice: 10.0,
        );

        final json = original.toJson();
        final restored = UnifiedListItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.quantity, original.quantity);
        expect(restored.unitPrice, original.unitPrice);
      });

      test('task → JSON → task', () {
        final dueDate = DateTime(2025, 11, 15);
        final original = UnifiedListItem.task(
          id: '1',
          name: 'משימה',
          dueDate: dueDate,
          priority: 'high',
        );

        final json = original.toJson();
        final restored = UnifiedListItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.dueDate, dueDate);
        expect(restored.priority, 'high');
      });
    });
  });
}
