// 📄 File: test/models/shopping_list_test.dart
//
// Unit tests for ShoppingList model
// Tests: creation, copyWith, items manipulation, permissions, UI helpers

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/active_shopper.dart';
import 'package:memozap/models/enums/item_type.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';

void main() {
  group('ShoppingList', () {
    // ===== Factory Constructor Tests =====
    group('newList', () {
      test('should create new list with required fields', () {
        final list = ShoppingList.newList(
          name: 'קניות שבועיות',
          createdBy: 'user-123',
        );

        expect(list.name, 'קניות שבועיות');
        expect(list.createdBy, 'user-123');
        expect(list.status, ShoppingList.statusActive);
        expect(list.type, ShoppingList.typeSupermarket);
        expect(list.items, isEmpty);
        expect(list.isShared, false);
        expect(list.id, isNotEmpty);
      });

      test('should create new list with optional fields', () {
        final eventDate = DateTime(2025, 12, 25);
        final list = ShoppingList.newList(
          name: 'קניות לחג',
          createdBy: 'user-123',
          type: ShoppingList.typeBakery,
          budget: 500.0,
          eventDate: eventDate,
          isShared: true,
        );

        expect(list.type, ShoppingList.typeBakery);
        expect(list.budget, 500.0);
        expect(list.eventDate, eventDate);
        expect(list.isShared, true);
      });

      test('should use provided id when given', () {
        final list = ShoppingList.newList(
          id: 'custom-id-123',
          name: 'רשימה',
          createdBy: 'user-123',
        );

        expect(list.id, 'custom-id-123');
      });

      test('should set createdDate and updatedDate', () {
        final now = DateTime(2025, 1, 15, 10, 30);
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
          now: now,
        );

        expect(list.createdDate, now);
        expect(list.updatedDate, now);
      });
    });

    // ===== fromTemplate Tests =====
    group('fromTemplate', () {
      test('should create list from template', () {
        final items = [
          UnifiedListItem.product(
            id: 'item-1',
            name: 'חלב',
            quantity: 2,
            unitPrice: 6.90,
            unit: 'יח\'',
          ),
        ];

        final list = ShoppingList.fromTemplate(
          templateId: 'template-123',
          name: 'מתבנית',
          createdBy: 'user-123',
          type: ShoppingList.typeSupermarket,
          format: 'shared',
          items: items,
        );

        expect(list.templateId, 'template-123');
        expect(list.createdFromTemplate, true);
        expect(list.items.length, 1);
      });
    });

    // ===== copyWith Tests =====
    group('copyWith', () {
      late ShoppingList originalList;

      setUp(() {
        originalList = ShoppingList.newList(
          id: 'original-id',
          name: 'רשימה מקורית',
          createdBy: 'user-123',
          budget: 200.0,
        );
      });

      test('should create copy with updated name', () {
        final copy = originalList.copyWith(name: 'שם חדש');

        expect(copy.name, 'שם חדש');
        expect(copy.id, originalList.id);
        expect(copy.budget, originalList.budget);
      });

      test('should allow nullifying budget with explicit null', () {
        final copy = originalList.copyWith(budget: null);

        expect(copy.budget, isNull);
      });

      test('should preserve budget when not specified', () {
        final copy = originalList.copyWith(name: 'שם אחר');

        expect(copy.budget, 200.0);
      });

      test('should update status', () {
        final copy = originalList.copyWith(
          status: ShoppingList.statusCompleted,
        );

        expect(copy.status, ShoppingList.statusCompleted);
      });
    });

    // ===== Items Manipulation Tests =====
    group('Items Manipulation', () {
      test('withItemAdded should add item to list', () {
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        );

        final item = UnifiedListItem.product(
          id: 'item-1',
          name: 'חלב',
          quantity: 1,
          unitPrice: 6.90,
          unit: 'יח\'',
        );

        final updated = list.withItemAdded(item);

        expect(updated.items.length, 1);
        expect(updated.items.first.name, 'חלב');
        // updatedDate should be same or after (could be same millisecond)
        expect(
          updated.updatedDate.isAfter(list.updatedDate) ||
              updated.updatedDate.isAtSameMomentAs(list.updatedDate),
          true,
        );
      });

      test('withItemRemoved should remove item at index', () {
        final items = [
          UnifiedListItem.product(
            id: 'item-1',
            name: 'חלב',
            quantity: 1,
            unitPrice: 6.90,
            unit: 'יח\'',
          ),
          UnifiedListItem.product(
            id: 'item-2',
            name: 'לחם',
            quantity: 1,
            unitPrice: 8.0,
            unit: 'יח\'',
          ),
        ];

        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
          items: items,
        );

        final updated = list.withItemRemoved(0);

        expect(updated.items.length, 1);
        expect(updated.items.first.name, 'לחם');
      });

      test('withItemRemoved should return same list for invalid index', () {
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        );

        final updated = list.withItemRemoved(5); // Invalid index

        expect(updated, list);
      });
    });

    // ===== Products & Tasks Getters Tests =====
    group('Products & Tasks Getters', () {
      late ShoppingList listWithItems;

      setUp(() {
        final items = [
          UnifiedListItem.product(
            id: 'prod-1',
            name: 'חלב',
            quantity: 2,
            unitPrice: 6.90,
            unit: 'יח\'',
          ),
          UnifiedListItem.product(
            id: 'prod-2',
            name: 'לחם',
            quantity: 1,
            unitPrice: 8.0,
            unit: 'יח\'',
          ),
          UnifiedListItem.task(
            id: 'task-1',
            name: 'להזמין עוגה',
          ),
        ];

        listWithItems = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
          items: items,
        );
      });

      test('products should return only products', () {
        expect(listWithItems.products.length, 2);
        expect(
          listWithItems.products.every((p) => p.type == ItemType.product),
          true,
        );
      });

      test('tasks should return only tasks', () {
        expect(listWithItems.tasks.length, 1);
        expect(
          listWithItems.tasks.every((t) => t.type == ItemType.task),
          true,
        );
      });

      test('productCount should return correct count', () {
        expect(listWithItems.productCount, 2);
      });

      test('taskCount should return correct count', () {
        expect(listWithItems.taskCount, 1);
      });

      test('totalAmount should calculate sum of products', () {
        // חלב: 2 * 6.90 = 13.80
        // לחם: 1 * 8.0 = 8.0
        // Total: 21.80
        expect(listWithItems.totalAmount, closeTo(21.80, 0.01));
      });
    });

    // ===== Active Shopping Tests =====
    group('Active Shopping', () {
      test('isBeingShopped should return false when no shoppers', () {
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        );

        expect(list.isBeingShopped, false);
        expect(list.hasActiveShoppers, false);
      });

      test('isBeingShopped should return true when has active shoppers', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(activeShoppers: [shopper]);

        expect(list.isBeingShopped, true);
        expect(list.hasActiveShoppers, true);
      });

      test('starter should return the starter shopper', () {
        final starter = ActiveShopper.starter(userId: 'user-123');
        final helper = ActiveShopper.helper(userId: 'user-456');
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(activeShoppers: [starter, helper]);

        expect(list.starter, isNotNull);
        expect(list.starter!.userId, 'user-123');
        expect(list.starter!.isStarter, true);
      });

      test('isUserShopping should check if user is shopping', () {
        final shopper = ActiveShopper.starter(userId: 'user-123');
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(activeShoppers: [shopper]);

        expect(list.isUserShopping('user-123'), true);
        expect(list.isUserShopping('user-999'), false);
      });

      test('canUserFinish should return true only for starter', () {
        final starter = ActiveShopper.starter(userId: 'user-123');
        final helper = ActiveShopper.helper(userId: 'user-456');
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(activeShoppers: [starter, helper]);

        expect(list.canUserFinish('user-123'), true);
        expect(list.canUserFinish('user-456'), false);
      });

      test('activeShopperCount should return correct count', () {
        final starter = ActiveShopper.starter(userId: 'user-123');
        final helper = ActiveShopper.helper(userId: 'user-456');
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(activeShoppers: [starter, helper]);

        expect(list.activeShopperCount, 2);
      });
    });

    // ===== Permissions Tests =====
    group('Permissions', () {
      test('isCurrentUserOwner should check owner role', () {
        final list = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(currentUserRole: UserRole.owner);

        expect(list.isCurrentUserOwner, true);
      });

      test('canCurrentUserEdit should allow owner/admin/editor', () {
        final ownerList = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(currentUserRole: UserRole.owner);

        final adminList = ownerList.copyWith(currentUserRole: UserRole.admin);
        final editorList = ownerList.copyWith(currentUserRole: UserRole.editor);
        final viewerList = ownerList.copyWith(currentUserRole: UserRole.viewer);

        expect(ownerList.canCurrentUserEdit, true);
        expect(adminList.canCurrentUserEdit, true);
        expect(editorList.canCurrentUserEdit, true);
        expect(viewerList.canCurrentUserEdit, false);
      });

      test('canCurrentUserApprove should allow only owner/admin', () {
        final ownerList = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(currentUserRole: UserRole.owner);

        final adminList = ownerList.copyWith(currentUserRole: UserRole.admin);
        final editorList = ownerList.copyWith(currentUserRole: UserRole.editor);

        expect(ownerList.canCurrentUserApprove, true);
        expect(adminList.canCurrentUserApprove, true);
        expect(editorList.canCurrentUserApprove, false);
      });

      test('canCurrentUserInvite should allow only owner', () {
        final ownerList = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(currentUserRole: UserRole.owner);

        final adminList = ownerList.copyWith(currentUserRole: UserRole.admin);

        expect(ownerList.canCurrentUserInvite, true);
        expect(adminList.canCurrentUserInvite, false);
      });

      test('canCurrentUserDelete should allow only owner', () {
        final ownerList = ShoppingList.newList(
          name: 'רשימה',
          createdBy: 'user-123',
        ).copyWith(currentUserRole: UserRole.owner);

        final adminList = ownerList.copyWith(currentUserRole: UserRole.admin);

        expect(ownerList.canCurrentUserDelete, true);
        expect(adminList.canCurrentUserDelete, false);
      });
    });

    // ===== UI Helpers Tests =====
    group('UI Helpers', () {
      test('stickyColor should return correct color for each type', () {
        final supermarketList = ShoppingList.newList(
          name: 'סופר',
          createdBy: 'user-123',
          type: ShoppingList.typeSupermarket,
        );

        final pharmacyList = ShoppingList.newList(
          name: 'בית מרקחת',
          createdBy: 'user-123',
          type: ShoppingList.typePharmacy,
        );

        expect(supermarketList.stickyColor, const Color(0xFFFFF59D));
        expect(pharmacyList.stickyColor, const Color(0xFF80DEEA));
      });

      test('typeEmoji should return correct emoji for each type', () {
        expect(
          ShoppingList.newList(
            name: 'סופר',
            createdBy: 'user-123',
            type: ShoppingList.typeSupermarket,
          ).typeEmoji,
          '🛒',
        );

        expect(
          ShoppingList.newList(
            name: 'אטליז',
            createdBy: 'user-123',
            type: ShoppingList.typeButcher,
          ).typeEmoji,
          '🥩',
        );

        expect(
          ShoppingList.newList(
            name: 'מאפייה',
            createdBy: 'user-123',
            type: ShoppingList.typeBakery,
          ).typeEmoji,
          '🥖',
        );
      });

      test('typeIcon should return correct icon for each type', () {
        expect(
          ShoppingList.newList(
            name: 'סופר',
            createdBy: 'user-123',
            type: ShoppingList.typeSupermarket,
          ).typeIcon,
          Icons.shopping_cart,
        );

        expect(
          ShoppingList.newList(
            name: 'בית מרקחת',
            createdBy: 'user-123',
            type: ShoppingList.typePharmacy,
          ).typeIcon,
          Icons.medication,
        );
      });
    });

    // ===== Equality Tests =====
    group('Equality', () {
      test('should be equal when ids match', () {
        final list1 = ShoppingList.newList(
          id: 'same-id',
          name: 'רשימה 1',
          createdBy: 'user-123',
        );

        final list2 = ShoppingList.newList(
          id: 'same-id',
          name: 'רשימה 2', // Different name but same id
          createdBy: 'user-456',
        );

        expect(list1, list2);
        expect(list1.hashCode, list2.hashCode);
      });

      test('should not be equal when ids differ', () {
        final list1 = ShoppingList.newList(
          id: 'id-1',
          name: 'רשימה',
          createdBy: 'user-123',
        );

        final list2 = ShoppingList.newList(
          id: 'id-2',
          name: 'רשימה',
          createdBy: 'user-123',
        );

        expect(list1, isNot(list2));
      });
    });

    // ===== Constants Tests =====
    group('Constants', () {
      test('should have correct status constants', () {
        expect(ShoppingList.statusActive, 'active');
        expect(ShoppingList.statusCompleted, 'completed');
        expect(ShoppingList.statusArchived, 'archived');
      });

      test('should have correct type constants', () {
        expect(ShoppingList.typeSupermarket, 'supermarket');
        expect(ShoppingList.typePharmacy, 'pharmacy');
        expect(ShoppingList.typeGreengrocer, 'greengrocer');
        expect(ShoppingList.typeButcher, 'butcher');
        expect(ShoppingList.typeBakery, 'bakery');
        expect(ShoppingList.typeMarket, 'market');
        expect(ShoppingList.typeHousehold, 'household');
        expect(ShoppingList.typeOther, 'other');
      });

      test('should have shopping timeout of 6 hours', () {
        expect(ShoppingList.shoppingTimeout, const Duration(hours: 6));
      });
    });
  });
}
