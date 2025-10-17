import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/receipt.dart';

void main() {
  group('ShoppingList', () {
    late DateTime testDate;
    
    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    group('Factory Constructors', () {
      test('newList creates shopping list with correct defaults', () {
        final list = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימת קניות שבועית',
          createdBy: 'user-456',
          type: ShoppingList.typeSuper,
          budget: 500.0,
          now: testDate,
        );

        expect(list.id, 'list-123');
        expect(list.name, 'רשימת קניות שבועית');
        expect(list.createdBy, 'user-456');
        expect(list.type, ShoppingList.typeSuper);
        expect(list.budget, 500.0);
        expect(list.status, ShoppingList.statusActive);
        expect(list.format, 'shared');
        expect(list.createdFromTemplate, false);
        expect(list.isShared, false);
        expect(list.items, isEmpty);
        expect(list.updatedDate, testDate);
        expect(list.createdDate, testDate);
      });

      test('fromTemplate creates list from template correctly', () {
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

        final list = ShoppingList.fromTemplate(
          id: 'list-789',
          templateId: 'template-001',
          name: 'רשימה מתבנית',
          createdBy: 'user-456',
          type: ShoppingList.typeSuper,
          format: 'shared',
          items: items,
          budget: 300.0,
          isShared: true,
          now: testDate,
        );

        expect(list.id, 'list-789');
        expect(list.templateId, 'template-001');
        expect(list.createdFromTemplate, true);
        expect(list.name, 'רשימה מתבנית');
        expect(list.items.length, 2);
        expect(list.items[0].name, 'חלב');
        expect(list.budget, 300.0);
        expect(list.isShared, true);
      });
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימה מקורית',
          createdBy: 'user-456',
          now: testDate,
        );

        final updated = original.copyWith(
          name: 'רשימה מעודכנת',
          budget: 750.0,
          status: ShoppingList.statusCompleted,
        );

        expect(updated.name, 'רשימה מעודכנת');
        expect(updated.budget, 750.0);
        expect(updated.status, ShoppingList.statusCompleted);
        
        // Fields not changed
        expect(updated.id, original.id);
        expect(updated.createdBy, original.createdBy);
        expect(updated.type, original.type);
        expect(updated.createdDate, original.createdDate);
      });

      test('can nullify nullable fields', () {
        final original = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימה',
          createdBy: 'user-456',
          budget: 500.0,
          eventDate: DateTime(2025, 2, 1),
          now: testDate,
        );

        final updated = original.copyWith(
          budget: null,
          eventDate: null,
        );

        expect(updated.budget, isNull);
        expect(updated.eventDate, isNull);
      });
    });

    group('Item Manipulation', () {
      test('withItemAdded adds item to list', () {
        final list = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימה',
          createdBy: 'user-456',
          now: testDate,
        );

        final newItem = ReceiptItem(
          id: 'item-1',
          name: 'חלב',
          quantity: 2,
          unitPrice: 6.5,
        );

        final updated = list.withItemAdded(newItem);

        expect(updated.items.length, 1);
        expect(updated.items[0].name, 'חלב');
        expect(updated.items[0].quantity, 2);
        expect(updated.updatedDate.isAfter(testDate), true);
      });

      test('withItemRemoved removes item at index', () {
        final items = [
          ReceiptItem(id: 'item-1', name: 'חלב', quantity: 2, unitPrice: 6.5),
          ReceiptItem(id: 'item-2', name: 'לחם', quantity: 1, unitPrice: 8.0),
          ReceiptItem(id: 'item-3', name: 'ביצים', quantity: 12, unitPrice: 15.0),
        ];

        final list = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימה',
          createdBy: 'user-456',
          items: items,
          now: testDate,
        );

        final updated = list.withItemRemoved(1);

        expect(updated.items.length, 2);
        expect(updated.items[0].name, 'חלב');
        expect(updated.items[1].name, 'ביצים');
      });

      test('withItemRemoved handles invalid index gracefully', () {
        final list = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימה',
          createdBy: 'user-456',
          items: [
            ReceiptItem(id: 'item-1', name: 'חלב', quantity: 2, unitPrice: 6.5),
          ],
          now: testDate,
        );

        final updated1 = list.withItemRemoved(-1);
        final updated2 = list.withItemRemoved(5);

        expect(updated1, same(list));
        expect(updated2, same(list));
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final original = ShoppingList.newList(
          id: 'list-123',
          name: 'רשימת בדיקה',
          createdBy: 'user-456',
          type: ShoppingList.typePharmacy,
          budget: 250.0,
          items: [
            ReceiptItem(id: 'item-1', name: 'אקמול', quantity: 1, unitPrice: 15.0),
          ],
          isShared: true,
          sharedWith: ['user-789', 'user-012'],
          eventDate: DateTime(2025, 2, 14),
          targetDate: DateTime(2025, 2, 13),
          now: testDate,
        );

        final json = original.toJson();
        final restored = ShoppingList.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.createdBy, original.createdBy);
        expect(restored.type, original.type);
        expect(restored.budget, original.budget);
        expect(restored.items.length, 1);
        expect(restored.items[0].name, 'אקמול');
        expect(restored.isShared, true);
        expect(restored.sharedWith, ['user-789', 'user-012']);
        expect(restored.eventDate?.day, 14);
        expect(restored.targetDate?.day, 13);
      });

      test('handles missing optional fields in JSON', () {
        final minimalJson = {
          'id': 'list-minimal',
          'name': 'רשימה מינימלית',
          'created_by': 'user-123',
          'updated_date': testDate.toIso8601String(),
          'created_date': testDate.toIso8601String(),
          'status': 'active',
          'type': 'super',
          'is_shared': false,
          'shared_with': [],
          'items': [],
          'format': 'shared',
          'created_from_template': false,
        };

        final list = ShoppingList.fromJson(minimalJson);

        expect(list.id, 'list-minimal');
        expect(list.budget, isNull);
        expect(list.eventDate, isNull);
        expect(list.targetDate, isNull);
        expect(list.templateId, isNull);
        expect(list.items, isEmpty);
      });
    });

    group('Constants', () {
      test('status constants are correct', () {
        expect(ShoppingList.statusActive, 'active');
        expect(ShoppingList.statusCompleted, 'completed');
        expect(ShoppingList.statusArchived, 'archived');
      });

      test('type constants are correct', () {
        expect(ShoppingList.typeSuper, 'super');
        expect(ShoppingList.typePharmacy, 'pharmacy');
        expect(ShoppingList.typeOther, 'other');
      });
    });

    group('Equality and HashCode', () {
      test('equality is based on id only', () {
        final list1 = ShoppingList.newList(
          id: 'same-id',
          name: 'רשימה 1',
          createdBy: 'user-456',
          now: testDate,
        );

        final list2 = ShoppingList.newList(
          id: 'same-id',
          name: 'רשימה 2',
          createdBy: 'user-789',
          now: DateTime.now(),
        );

        final list3 = ShoppingList.newList(
          id: 'different-id',
          name: 'רשימה 1',
          createdBy: 'user-456',
          now: testDate,
        );

        expect(list1 == list2, true);
        expect(list1 == list3, false);
        expect(list1.hashCode, list2.hashCode);
        expect(list1.hashCode, isNot(list3.hashCode));
      });
    });

    group('Common use cases', () {
      test('creates weekly grocery list', () {
        final weeklyItems = [
          ReceiptItem(id: 'item-1', name: 'חלב', quantity: 2, unitPrice: 6.5),
          ReceiptItem(id: 'item-2', name: 'לחם', quantity: 1, unitPrice: 8.0),
          ReceiptItem(id: 'item-3', name: 'ביצים', quantity: 12, unitPrice: 15.0),
          ReceiptItem(id: 'item-4', name: 'ירקות', quantity: 1, unitPrice: 30.0),
          ReceiptItem(id: 'item-5', name: 'עוף', quantity: 1, unitPrice: 40.0),
        ];

        final list = ShoppingList.newList(
          id: 'weekly-001',
          name: 'קניות שבועיות',
          createdBy: 'user-family',
          type: ShoppingList.typeSuper,
          budget: 500.0,
          isShared: true,
          sharedWith: ['spouse-id', 'roommate-id'],
          items: weeklyItems,
          now: DateTime.now(),
        );

        expect(list.type, ShoppingList.typeSuper);
        expect(list.items.length, 5);
        expect(list.isShared, true);
        expect(list.sharedWith.length, 2);

        // Calculate total
        final total = list.items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
        expect(total, closeTo(106.5, 0.01));
      });

      test('creates pharmacy shopping list', () {
        final pharmacyItems = [
          ReceiptItem(id: 'med-1', name: 'אקמול', quantity: 2, unitPrice: 15.0),
          ReceiptItem(id: 'med-2', name: 'נורופן', quantity: 1, unitPrice: 25.0),
          ReceiptItem(id: 'med-3', name: 'ויטמין C', quantity: 1, unitPrice: 30.0),
        ];

        final list = ShoppingList.newList(
          id: 'pharmacy-001',
          name: 'בית מרקחת',
          createdBy: 'user-123',
          type: ShoppingList.typePharmacy,
          budget: 100.0,
          items: pharmacyItems,
        );

        expect(list.type, ShoppingList.typePharmacy);
        expect(list.items.every((item) => item.name?.contains('מין') != true), true);  // Not groceries
      });

      test('creates list for special event', () {
        final eventDate = DateTime(2025, 2, 14);  // Valentine's Day
        final targetDate = DateTime(2025, 2, 13);  // Day before
        
        final eventItems = [
          ReceiptItem(id: 'event-1', name: 'שוקולד', quantity: 1, unitPrice: 25.0),
          ReceiptItem(id: 'event-2', name: 'שמפניה', quantity: 1, unitPrice: 120.0),
          ReceiptItem(id: 'event-3', name: 'ורדים', quantity: 1, unitPrice: 80.0),
        ];

        final list = ShoppingList.newList(
          id: 'valentine-001',
          name: 'קניות ליום האהבה',
          createdBy: 'user-romantic',
          type: ShoppingList.typeOther,
          budget: 250.0,
          eventDate: eventDate,
          targetDate: targetDate,
          items: eventItems,
        );

        expect(list.eventDate, eventDate);
        expect(list.targetDate, targetDate);
        expect(list.targetDate!.isBefore(list.eventDate!), true);
      });

      test('transitions list through lifecycle', () {
        // Create active list
        final activeList = ShoppingList.newList(
          id: 'lifecycle-001',
          name: 'רשימה בדיקה',
          createdBy: 'user-123',
          items: [
            ReceiptItem(id: '1', name: 'מוצר', quantity: 1, unitPrice: 10.0),
          ],
        );
        
        expect(activeList.status, ShoppingList.statusActive);

        // Complete the list
        final completedList = activeList.copyWith(
          status: ShoppingList.statusCompleted,
        );
        
        expect(completedList.status, ShoppingList.statusCompleted);

        // Archive the list
        final archivedList = completedList.copyWith(
          status: ShoppingList.statusArchived,
        );
        
        expect(archivedList.status, ShoppingList.statusArchived);
      });

      test('manages budget tracking', () {
        final items = [
          ReceiptItem(id: '1', name: 'מוצר 1', quantity: 1, unitPrice: 50.0),
          ReceiptItem(id: '2', name: 'מוצר 2', quantity: 2, unitPrice: 30.0),
          ReceiptItem(id: '3', name: 'מוצר 3', quantity: 1, unitPrice: 70.0),
        ];

        final list = ShoppingList.newList(
          id: 'budget-001',
          name: 'רשימה עם תקציב',
          createdBy: 'user-123',
          budget: 150.0,  // Budget limit
          items: items,
        );

        // Calculate total cost
        final totalCost = items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
        expect(totalCost, 180.0);  // 50 + 60 + 70
        
        // Check if over budget
        final isOverBudget = totalCost > (list.budget ?? 0.0);
        expect(isOverBudget, true);  // 180 > 150
        
        // Calculate overage
        final overage = totalCost - (list.budget ?? 0.0);
        expect(overage, 30.0);
      });

      test('shares list with household members', () {
        // רשימת חברי בית
        final creator = 'user-1';
        final otherMembers = ['user-2', 'user-3'];
        
        final sharedList = ShoppingList.newList(
          id: 'shared-001',
          name: 'רשימת בית משותפת',
          createdBy: creator,
          isShared: true,
          sharedWith: otherMembers,
        );

        expect(sharedList.isShared, true);
        expect(sharedList.sharedWith, containsAll(['user-2', 'user-3']));
        expect(sharedList.sharedWith, isNot(contains('user-1')));  // Creator not in sharedWith
      });

      test('creates list from template and modifies', () {
        // Start from template
        final templateItems = [
          ReceiptItem(id: 't-1', name: 'חלב', quantity: 1, unitPrice: 0),
          ReceiptItem(id: 't-2', name: 'לחם', quantity: 1, unitPrice: 0),
          ReceiptItem(id: 't-3', name: 'ביצים', quantity: 1, unitPrice: 0),
        ];

        final listFromTemplate = ShoppingList.fromTemplate(
          id: 'from-template-001',
          templateId: 'template-basic-groceries',
          name: 'מוצרי בסיס',
          createdBy: 'user-123',
          type: ShoppingList.typeSuper,
          format: 'shared',
          items: templateItems,
        );

        expect(listFromTemplate.createdFromTemplate, true);
        expect(listFromTemplate.templateId, 'template-basic-groceries');
        expect(listFromTemplate.items.length, 3);

        // Add custom item
        final customItem = ReceiptItem(id: 'c-1', name: 'גבינה', quantity: 1, unitPrice: 0);
        final modifiedList = listFromTemplate.withItemAdded(customItem);

        expect(modifiedList.items.length, 4);
        expect(modifiedList.items.last.name, 'גבינה');
        expect(modifiedList.createdFromTemplate, true);  // Still marked as from template
      });

      test('handles empty list', () {
        final emptyList = ShoppingList.newList(
          id: 'empty-001',
          name: 'רשימה ריקה',
          createdBy: 'user-123',
        );

        expect(emptyList.items, isEmpty);
        expect(emptyList.budget, isNull);
        expect(emptyList.isShared, false);
        expect(emptyList.status, ShoppingList.statusActive);
      });

      test('list with multiple formats', () {
        final personalList = ShoppingList.newList(
          id: 'personal-001',
          name: 'רשימה אישית',
          createdBy: 'user-123',
          format: 'personal',
          isShared: false,
        );

        final assignedList = ShoppingList.newList(
          id: 'assigned-001',
          name: 'רשימה מוקצית',
          createdBy: 'user-123',
          format: 'assigned',
          isShared: true,
          sharedWith: ['user-456'],
        );

        expect(personalList.format, 'personal');
        expect(personalList.isShared, false);
        expect(assignedList.format, 'assigned');
        expect(assignedList.isShared, true);
      });
    });
  });
}
