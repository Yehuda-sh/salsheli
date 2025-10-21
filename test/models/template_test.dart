import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/template.dart';

void main() {
  group('Template', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
    });

    group('Factory Constructor', () {
      test('newTemplate creates template with correct defaults', () {
        final template = Template.newTemplate(
          id: 'template_super',
          type: 'super',
          name: 'סופרמרקט שבועי',
          description: 'קניות שבועיות למשפחה',
          icon: '🛒',
          createdBy: 'system',
          isSystem: true,
          sortOrder: 1,
          now: testDate,
        );

        expect(template.id, 'template_super');
        expect(template.type, 'super');
        expect(template.name, 'סופרמרקט שבועי');
        expect(template.description, 'קניות שבועיות למשפחה');
        expect(template.icon, '🛒');
        expect(template.createdBy, 'system');
        expect(template.isSystem, true);
        expect(template.defaultFormat, Template.formatShared);
        expect(template.defaultItems, isEmpty);
        expect(template.householdId, isNull);
        expect(template.sortOrder, 1);
        expect(template.createdDate, testDate);
        expect(template.updatedDate, testDate);
      });

      test('newTemplate with defaultItems', () {
        final items = [
          TemplateItem(name: 'חלב', category: 'מוצרי חלב', quantity: 2),
          TemplateItem(name: 'לחם', category: 'מאפים', quantity: 1),
        ];

        final template = Template.newTemplate(
          id: 'template_custom',
          type: 'super',
          name: 'רשימה מותאמת',
          description: 'הרשימה שלי',
          icon: '📝',
          createdBy: 'user-123',
          defaultItems: items,
          householdId: 'house-456',
          defaultFormat: Template.formatAssigned,
          now: testDate,
        );

        expect(template.defaultItems.length, 2);
        expect(template.defaultItems[0].name, 'חלב');
        expect(template.defaultItems[1].name, 'לחם');
        expect(template.householdId, 'house-456');
        expect(template.defaultFormat, Template.formatAssigned);
      });
    });

    group('copyWith', () {
      test('updates only specified fields', () {
        final original = Template.newTemplate(
          id: 'template_test',
          type: 'super',
          name: 'תבנית מקורית',
          description: 'תיאור מקורי',
          icon: '🛒',
          createdBy: 'user-123',
          now: testDate,
        );

        final updated = original.copyWith(
          name: 'תבנית מעודכנת',
          description: 'תיאור חדש',
          icon: '🛍️',
          sortOrder: 5,
        );

        expect(updated.name, 'תבנית מעודכנת');
        expect(updated.description, 'תיאור חדש');
        expect(updated.icon, '🛍️');
        expect(updated.sortOrder, 5);
        
        // Unchanged fields
        expect(updated.id, original.id);
        expect(updated.type, original.type);
        expect(updated.createdBy, original.createdBy);
        expect(updated.createdDate, original.createdDate);
      });
    });

    group('Items Manipulation', () {
      test('withItemAdded adds item to template', () {
        final template = Template.newTemplate(
          id: 'template_test',
          type: 'super',
          name: 'תבנית',
          description: 'תיאור',
          icon: '🛒',
          createdBy: 'user-123',
          now: testDate,
        );

        final newItem = TemplateItem(
          name: 'סוכר',
          category: 'יבשים',
          quantity: 1,
        );

        final updated = template.withItemAdded(newItem);

        expect(updated.defaultItems.length, 1);
        expect(updated.defaultItems[0].name, 'סוכר');
        expect(updated.updatedDate.isAfter(testDate), true);
      });

      test('withItemRemoved removes item at index', () {
        final items = [
          TemplateItem(name: 'חלב', quantity: 2),
          TemplateItem(name: 'לחם', quantity: 1),
          TemplateItem(name: 'ביצים', quantity: 12),
        ];

        final template = Template.newTemplate(
          id: 'template_test',
          type: 'super',
          name: 'תבנית',
          description: 'תיאור',
          icon: '🛒',
          createdBy: 'user-123',
          defaultItems: items,
          now: testDate,
        );

        final updated = template.withItemRemoved(1);

        expect(updated.defaultItems.length, 2);
        expect(updated.defaultItems[0].name, 'חלב');
        expect(updated.defaultItems[1].name, 'ביצים');
      });

      test('withItemUpdated updates item at index', () {
        final items = [
          TemplateItem(name: 'חלב', quantity: 2),
          TemplateItem(name: 'לחם', quantity: 1),
        ];

        final template = Template.newTemplate(
          id: 'template_test',
          type: 'super',
          name: 'תבנית',
          description: 'תיאור',
          icon: '🛒',
          createdBy: 'user-123',
          defaultItems: items,
          now: testDate,
        );

        final updatedItem = TemplateItem(
          name: 'חלב 3%',
          category: 'מוצרי חלב',
          quantity: 3,
        );

        final updated = template.withItemUpdated(0, updatedItem);

        expect(updated.defaultItems[0].name, 'חלב 3%');
        expect(updated.defaultItems[0].category, 'מוצרי חלב');
        expect(updated.defaultItems[0].quantity, 3);
        expect(updated.defaultItems[1].name, 'לחם');
      });

      test('item manipulation handles invalid indices gracefully', () {
        final template = Template.newTemplate(
          id: 'template_test',
          type: 'super',
          name: 'תבנית',
          description: 'תיאור',
          icon: '🛒',
          createdBy: 'user-123',
          defaultItems: [
            TemplateItem(name: 'חלב', quantity: 2),
          ],
          now: testDate,
        );

        final removed1 = template.withItemRemoved(-1);
        final removed2 = template.withItemRemoved(5);
        final updated1 = template.withItemUpdated(-1, TemplateItem(name: 'test'));
        final updated2 = template.withItemUpdated(5, TemplateItem(name: 'test'));

        expect(removed1, same(template));
        expect(removed2, same(template));
        expect(updated1, same(template));
        expect(updated2, same(template));
      });
    });

    group('Helper Methods', () {
      test('isAvailableFor checks household correctly', () {
        final systemTemplate = Template.newTemplate(
          id: 'template_system',
          type: 'super',
          name: 'תבנית מערכת',
          description: 'זמינה לכולם',
          icon: '🛒',
          createdBy: 'system',
          isSystem: true,
          householdId: null,
          now: testDate,
        );

        final householdTemplate = Template.newTemplate(
          id: 'template_house',
          type: 'super',
          name: 'תבנית משק בית',
          description: 'רק למשק בית ספציפי',
          icon: '🏠',
          createdBy: 'user-123',
          householdId: 'house-456',
          now: testDate,
        );

        // System template available for all
        expect(systemTemplate.isAvailableFor('house-456'), true);
        expect(systemTemplate.isAvailableFor('house-789'), true);
        expect(systemTemplate.isAvailableFor('any-house'), true);

        // Household template only for specific household
        expect(householdTemplate.isAvailableFor('house-456'), true);
        expect(householdTemplate.isAvailableFor('house-789'), false);
        expect(householdTemplate.isAvailableFor('other-house'), false);
      });

      test('isDeletable and isEditable respect isSystem flag', () {
        final systemTemplate = Template.newTemplate(
          id: 'template_system',
          type: 'super',
          name: 'תבנית מערכת',
          description: 'לא ניתן למחוק או לערוך',
          icon: '🛒',
          createdBy: 'system',
          isSystem: true,
          now: testDate,
        );

        final userTemplate = Template.newTemplate(
          id: 'template_user',
          type: 'super',
          name: 'תבנית משתמש',
          description: 'ניתן למחוק ולערוך',
          icon: '📝',
          createdBy: 'user-123',
          isSystem: false,
          now: testDate,
        );

        expect(systemTemplate.isDeletable, false);
        expect(systemTemplate.isEditable, false);
        expect(userTemplate.isDeletable, true);
        expect(userTemplate.isEditable, true);
      });

      test('isValidFormat validates format strings', () {
        expect(Template.isValidFormat('shared'), true);
        expect(Template.isValidFormat('assigned'), true);
        expect(Template.isValidFormat('personal'), true);
        expect(Template.isValidFormat('invalid'), false);
        expect(Template.isValidFormat(''), false);
        expect(Template.isValidFormat('SHARED'), false); // case sensitive
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson work correctly', () {
        final items = [
          TemplateItem(
            name: 'חלב',
            category: 'מוצרי חלב',
            quantity: 2,
            unit: 'ליטר',
            note: 'רצוי 3%',
          ),
        ];

        final original = Template.newTemplate(
          id: 'template_test',
          type: 'pharmacy',
          name: 'תבנית בית מרקחת',
          description: 'תרופות ומוצרי טיפוח',
          icon: '💊',
          createdBy: 'user-123',
          defaultFormat: Template.formatPersonal,
          defaultItems: items,
          householdId: 'house-456',
          isSystem: false,
          sortOrder: 3,
          now: testDate,
        );

        final json = original.toJson();
        final restored = Template.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
        expect(restored.icon, original.icon);
        expect(restored.defaultFormat, original.defaultFormat);
        expect(restored.defaultItems.length, 1);
        expect(restored.defaultItems[0].name, 'חלב');
        expect(restored.householdId, 'house-456');
        expect(restored.isSystem, false);
        expect(restored.sortOrder, 3);
      });
    });

    group('Constants', () {
      test('format constants are correct', () {
        expect(Template.formatShared, 'shared');
        expect(Template.formatAssigned, 'assigned');
        expect(Template.formatPersonal, 'personal');
        expect(Template.allFormats, ['shared', 'assigned', 'personal']);
      });
    });
  });

  group('TemplateItem', () {
    test('creates with default values', () {
      final item = TemplateItem(name: 'מוצר בדיקה');

      expect(item.name, 'מוצר בדיקה');
      expect(item.category, isNull);
      expect(item.quantity, 1);
      expect(item.unit, 'יח׳');
      expect(item.note, isNull);
    });

    test('creates with all values', () {
      final item = TemplateItem(
        name: 'חלב',
        category: 'מוצרי חלב',
        quantity: 2,
        unit: 'ליטר',
        note: 'רצוי 3%',
      );

      expect(item.name, 'חלב');
      expect(item.category, 'מוצרי חלב');
      expect(item.quantity, 2);
      expect(item.unit, 'ליטר');
      expect(item.note, 'רצוי 3%');
    });

    test('copyWith updates only specified fields', () {
      final original = TemplateItem(
        name: 'מוצר מקורי',
        category: 'קטגוריה',
        quantity: 1,
      );

      final updated = original.copyWith(
        name: 'מוצר מעודכן',
        quantity: 5,
      );

      expect(updated.name, 'מוצר מעודכן');
      expect(updated.quantity, 5);
      expect(updated.category, original.category);
      expect(updated.unit, original.unit);
    });

    test('JSON serialization works correctly', () {
      final original = TemplateItem(
        name: 'מוצר בדיקה',
        category: 'קטגוריה',
        quantity: 3,
        unit: 'ק"ג',
        note: 'הערה',
      );

      final json = original.toJson();
      final restored = TemplateItem.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.quantity, original.quantity);
      expect(restored.unit, original.unit);
      expect(restored.note, original.note);
    });

    test('equality and hashCode work correctly', () {
      final item1 = TemplateItem(
        name: 'מוצר',
        category: 'קטגוריה',
        quantity: 2,
        unit: 'יח׳',
      );

      final item2 = TemplateItem(
        name: 'מוצר',
        category: 'קטגוריה',
        quantity: 2,
        unit: 'יח׳',
      );

      final item3 = TemplateItem(
        name: 'מוצר אחר',
        category: 'קטגוריה',
        quantity: 2,
        unit: 'יח׳',
      );

      expect(item1 == item2, true);
      expect(item1 == item3, false);
      expect(item1.hashCode, item2.hashCode);
      expect(item1.hashCode, isNot(item3.hashCode));
    });
  });

  group('Common use cases', () {
    test('creates system supermarket template', () {
      final items = [
        TemplateItem(name: 'חלב', category: 'מוצרי חלב', quantity: 2, unit: 'ליטר'),
        TemplateItem(name: 'לחם', category: 'מאפים', quantity: 1, unit: 'יחידה'),
        TemplateItem(name: 'ביצים', category: 'חלבון', quantity: 12, unit: 'יח\''),
        TemplateItem(name: 'ירקות', category: 'ירקות', quantity: 1, unit: 'ק"ג'),
        TemplateItem(name: 'עוף', category: 'בשר ודגים', quantity: 1, unit: 'ק"ג'),
      ];

      final template = Template.newTemplate(
        id: 'template_super',
        type: 'super',
        name: 'סופרמרקט שבועי',
        description: 'קניות שבועיות למשפחה',
        icon: '🛒',
        createdBy: 'system',
        isSystem: true,
        defaultItems: items,
        sortOrder: 1,
      );

      expect(template.isSystem, true);
      expect(template.isDeletable, false);
      expect(template.isEditable, false);
      expect(template.isAvailableFor('any-household'), true);
      expect(template.defaultItems.length, 5);
      expect(template.defaultFormat, Template.formatShared);
    });

    test('creates pharmacy template', () {
      final items = [
        TemplateItem(name: 'אקמול', category: 'תרופות', quantity: 1, unit: 'חבילה'),
        TemplateItem(name: 'נורופן', category: 'תרופות', quantity: 1, unit: 'חבילה'),
        TemplateItem(name: 'משחת שיניים', category: 'היגיינה', quantity: 1, unit: 'יחידה'),
      ];

      final template = Template.newTemplate(
        id: 'template_pharmacy',
        type: 'pharmacy',
        name: 'בית מרקחת',
        description: 'תרופות ומוצרי טיפוח',
        icon: '💊',
        createdBy: 'system',
        isSystem: true,
        defaultItems: items,
        sortOrder: 2,
      );

      expect(template.type, 'pharmacy');
      expect(template.defaultItems.every((item) => 
        item.category == 'תרופות' || item.category == 'היגיינה'
      ), true);
    });

    test('creates birthday party template', () {
      final items = [
        TemplateItem(name: 'עוגת יום הולדת', category: 'מאפים', quantity: 1),
        TemplateItem(name: 'בלונים', category: 'קישוטים', quantity: 20),
        TemplateItem(name: 'נרות', category: 'קישוטים', quantity: 10),
        TemplateItem(name: 'שתייה קלה', category: 'משקאות', quantity: 10, unit: 'ליטר'),
      ];

      final template = Template.newTemplate(
        id: 'template_birthday',
        type: 'birthday',
        name: 'מסיבת יום הולדת',
        description: 'כל מה שצריך למסיבה',
        icon: '🎉',
        createdBy: 'system',
        isSystem: true,
        defaultItems: items,
        defaultFormat: Template.formatAssigned,
        sortOrder: 3,
      );

      expect(template.type, 'birthday');
      expect(template.defaultFormat, Template.formatAssigned);
      expect(template.defaultItems.any((item) => item.name.contains('עוג')), true);  // 'עוגת' contains 'עוג'
    });

    test('creates household custom template', () {
      final items = [
        TemplateItem(name: 'מוצר מיוחד 1', category: 'מותאם אישית'),
        TemplateItem(name: 'מוצר מיוחד 2', category: 'מותאם אישית'),
      ];

      final template = Template.newTemplate(
        id: 'template_custom_123',
        type: 'other',
        name: 'הרשימה שלנו',
        description: 'רשימה מותאמת אישית למשק הבית',
        icon: '🏠',
        createdBy: 'user-456',
        householdId: 'house-789',
        isSystem: false,
        defaultItems: items,
        defaultFormat: Template.formatPersonal,
      );

      expect(template.isSystem, false);
      expect(template.isDeletable, true);
      expect(template.isEditable, true);
      expect(template.isAvailableFor('house-789'), true);
      expect(template.isAvailableFor('house-000'), false);
      expect(template.defaultFormat, Template.formatPersonal);
      expect(template.householdId, 'house-789');
    });

    test('modifies template items dynamically', () {
      final template = Template.newTemplate(
        id: 'template_dynamic',
        type: 'super',
        name: 'רשימה דינמית',
        description: 'תבנית שמשתנה',
        icon: '🔄',
        createdBy: 'user-123',
        defaultItems: [
          TemplateItem(name: 'פריט 1'),
        ],
      );

      // Add items
      var modified = template
          .withItemAdded(TemplateItem(name: 'פריט 2'))
          .withItemAdded(TemplateItem(name: 'פריט 3'));

      expect(modified.defaultItems.length, 3);

      // Update item
      modified = modified.withItemUpdated(
        1,
        TemplateItem(name: 'פריט 2 מעודכן', quantity: 5),
      );

      expect(modified.defaultItems[1].name, 'פריט 2 מעודכן');
      expect(modified.defaultItems[1].quantity, 5);

      // Remove item
      modified = modified.withItemRemoved(0);

      expect(modified.defaultItems.length, 2);
      expect(modified.defaultItems[0].name, 'פריט 2 מעודכן');
    });

    test('creates template for different formats', () {
      final sharedTemplate = Template.newTemplate(
        id: 'template_shared',
        type: 'super',
        name: 'רשימה משותפת',
        description: 'כולם יכולים לערוך',
        icon: '🤝',
        createdBy: 'user-123',
        defaultFormat: Template.formatShared,
      );

      final assignedTemplate = Template.newTemplate(
        id: 'template_assigned',
        type: 'super',
        name: 'רשימה עם הקצאות',
        description: 'כל פריט מוקצה למשתמש',
        icon: '📋',
        createdBy: 'user-123',
        defaultFormat: Template.formatAssigned,
      );

      final personalTemplate = Template.newTemplate(
        id: 'template_personal',
        type: 'super',
        name: 'רשימה פרטית',
        description: 'רק אני רואה',
        icon: '🔒',
        createdBy: 'user-123',
        defaultFormat: Template.formatPersonal,
      );

      expect(sharedTemplate.defaultFormat, Template.formatShared);
      expect(assignedTemplate.defaultFormat, Template.formatAssigned);
      expect(personalTemplate.defaultFormat, Template.formatPersonal);
    });

    test('sorts templates by sortOrder', () {
      final templates = [
        Template.newTemplate(
          id: 'template_3',
          type: 'super',
          name: 'תבנית 3',
          description: '',
          icon: '3️⃣',
          createdBy: 'system',
          sortOrder: 3,
        ),
        Template.newTemplate(
          id: 'template_1',
          type: 'super',
          name: 'תבנית 1',
          description: '',
          icon: '1️⃣',
          createdBy: 'system',
          sortOrder: 1,
        ),
        Template.newTemplate(
          id: 'template_2',
          type: 'super',
          name: 'תבנית 2',
          description: '',
          icon: '2️⃣',
          createdBy: 'system',
          sortOrder: 2,
        ),
      ];

      templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      expect(templates[0].id, 'template_1');
      expect(templates[1].id, 'template_2');
      expect(templates[2].id, 'template_3');
    });
  });
}
