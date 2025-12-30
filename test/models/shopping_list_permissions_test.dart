// 📄 File: test/models/shopping_list_permissions_test.dart
//
// 🧪 בדיקות הרשאות מקיפות עבור רשימות קניות
//
// בודק את כל מטריצת ההרשאות:
// - Owner: כל ההרשאות
// - Admin: כמעט הכל (מלבד מחיקת רשימה והזמנת משתמשים)
// - Editor: עריכה עם בקשת אישור
// - Viewer: קריאה בלבד
//
// ✅ Last Updated: 29/12/2025

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shared_user.dart';
import 'package:memozap/models/shopping_list.dart';

void main() {
  group('🔐 Shopping List Permissions Tests', () {
    // =============================================
    // 📊 מטריצת הרשאות מלאה
    // =============================================

    group('📊 מטריצת הרשאות מלאה', () {
      late ShoppingList ownerList;
      late ShoppingList adminList;
      late ShoppingList editorList;
      late ShoppingList viewerList;

      setUp(() {
        final baseList = ShoppingList.newList(
          id: 'test-list-123',
          name: 'רשימת בדיקה',
          createdBy: 'owner-user-id',
        );

        ownerList = baseList.copyWith(currentUserRole: UserRole.owner);
        adminList = baseList.copyWith(currentUserRole: UserRole.admin);
        editorList = baseList.copyWith(currentUserRole: UserRole.editor);
        viewerList = baseList.copyWith(currentUserRole: UserRole.viewer);
      });

      // ========== בדיקת isCurrentUserOwner ==========
      group('isCurrentUserOwner', () {
        test('Owner - should be true', () {
          expect(ownerList.isCurrentUserOwner, true);
        });

        test('Admin - should be false', () {
          expect(adminList.isCurrentUserOwner, false);
        });

        test('Editor - should be false', () {
          expect(editorList.isCurrentUserOwner, false);
        });

        test('Viewer - should be false', () {
          expect(viewerList.isCurrentUserOwner, false);
        });
      });

      // ========== בדיקת canCurrentUserEdit ==========
      group('canCurrentUserEdit (הוספה/עריכה/סימון)', () {
        test('Owner - should be true', () {
          expect(ownerList.canCurrentUserEdit, true);
        });

        test('Admin - should be true', () {
          expect(adminList.canCurrentUserEdit, true);
        });

        test('Editor - should be true', () {
          expect(editorList.canCurrentUserEdit, true);
        });

        test('Viewer - should be FALSE', () {
          expect(viewerList.canCurrentUserEdit, false);
        });
      });

      // ========== בדיקת canCurrentUserApprove ==========
      group('canCurrentUserApprove (אישור/דחיית בקשות)', () {
        test('Owner - should be true', () {
          expect(ownerList.canCurrentUserApprove, true);
        });

        test('Admin - should be true', () {
          expect(adminList.canCurrentUserApprove, true);
        });

        test('Editor - should be FALSE', () {
          expect(editorList.canCurrentUserApprove, false);
        });

        test('Viewer - should be FALSE', () {
          expect(viewerList.canCurrentUserApprove, false);
        });
      });

      // ========== בדיקת canCurrentUserManage ==========
      group('canCurrentUserManage (ניהול משתמשים)', () {
        test('Owner - should be true', () {
          expect(ownerList.canCurrentUserManage, true);
        });

        test('Admin - should be true', () {
          expect(adminList.canCurrentUserManage, true);
        });

        test('Editor - should be FALSE', () {
          expect(editorList.canCurrentUserManage, false);
        });

        test('Viewer - should be FALSE', () {
          expect(viewerList.canCurrentUserManage, false);
        });
      });

      // ========== בדיקת canCurrentUserInvite ==========
      group('canCurrentUserInvite (הזמנת משתמשים)', () {
        test('Owner - should be true', () {
          expect(ownerList.canCurrentUserInvite, true);
        });

        test('Admin - should be FALSE', () {
          expect(adminList.canCurrentUserInvite, false);
        });

        test('Editor - should be FALSE', () {
          expect(editorList.canCurrentUserInvite, false);
        });

        test('Viewer - should be FALSE', () {
          expect(viewerList.canCurrentUserInvite, false);
        });
      });

      // ========== בדיקת canCurrentUserDelete ==========
      group('canCurrentUserDelete (מחיקת רשימה)', () {
        test('Owner - should be true', () {
          expect(ownerList.canCurrentUserDelete, true);
        });

        test('Admin - should be FALSE', () {
          expect(adminList.canCurrentUserDelete, false);
        });

        test('Editor - should be FALSE', () {
          expect(editorList.canCurrentUserDelete, false);
        });

        test('Viewer - should be FALSE', () {
          expect(viewerList.canCurrentUserDelete, false);
        });
      });

      // ========== בדיקת shouldCurrentUserRequest ==========
      group('shouldCurrentUserRequest (שליחת בקשות)', () {
        test('Owner - should be FALSE (מוסיף ישירות)', () {
          expect(ownerList.shouldCurrentUserRequest, false);
        });

        test('Admin - should be FALSE (מוסיף ישירות)', () {
          expect(adminList.shouldCurrentUserRequest, false);
        });

        test('Editor - should be TRUE (צריך לבקש אישור)', () {
          expect(editorList.shouldCurrentUserRequest, true);
        });

        test('Viewer - should be FALSE (אין הרשאה בכלל)', () {
          expect(viewerList.shouldCurrentUserRequest, false);
        });
      });
    });

    // =============================================
    // 🎭 UserRole Enum Tests
    // =============================================

    group('🎭 UserRole Enum Permissions', () {
      // ========== canAddDirectly ==========
      group('canAddDirectly', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canAddDirectly, true);
        });

        test('Admin - should be true', () {
          expect(UserRole.admin.canAddDirectly, true);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canAddDirectly, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canAddDirectly, false);
        });
      });

      // ========== canEditDirectly ==========
      group('canEditDirectly', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canEditDirectly, true);
        });

        test('Admin - should be true', () {
          expect(UserRole.admin.canEditDirectly, true);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canEditDirectly, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canEditDirectly, false);
        });
      });

      // ========== canDeleteDirectly ==========
      group('canDeleteDirectly', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canDeleteDirectly, true);
        });

        test('Admin - should be true', () {
          expect(UserRole.admin.canDeleteDirectly, true);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canDeleteDirectly, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canDeleteDirectly, false);
        });
      });

      // ========== canApproveRequests ==========
      group('canApproveRequests', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canApproveRequests, true);
        });

        test('Admin - should be true', () {
          expect(UserRole.admin.canApproveRequests, true);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canApproveRequests, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canApproveRequests, false);
        });
      });

      // ========== canManageUsers ==========
      group('canManageUsers', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canManageUsers, true);
        });

        test('Admin - should be FALSE', () {
          expect(UserRole.admin.canManageUsers, false);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canManageUsers, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canManageUsers, false);
        });
      });

      // ========== canDeleteList ==========
      group('canDeleteList', () {
        test('Owner - should be true', () {
          expect(UserRole.owner.canDeleteList, true);
        });

        test('Admin - should be FALSE', () {
          expect(UserRole.admin.canDeleteList, false);
        });

        test('Editor - should be FALSE', () {
          expect(UserRole.editor.canDeleteList, false);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canDeleteList, false);
        });
      });

      // ========== canRequest ==========
      group('canRequest (שליחת בקשות לאישור)', () {
        test('Owner - should be FALSE (מוסיף ישירות)', () {
          expect(UserRole.owner.canRequest, false);
        });

        test('Admin - should be FALSE (מוסיף ישירות)', () {
          expect(UserRole.admin.canRequest, false);
        });

        test('Editor - should be TRUE', () {
          expect(UserRole.editor.canRequest, true);
        });

        test('Viewer - should be FALSE', () {
          expect(UserRole.viewer.canRequest, false);
        });
      });

      // ========== canRead ==========
      group('canRead', () {
        test('All roles should be able to read', () {
          expect(UserRole.owner.canRead, true);
          expect(UserRole.admin.canRead, true);
          expect(UserRole.editor.canRead, true);
          expect(UserRole.viewer.canRead, true);
        });
      });
    });

    // =============================================
    // 👤 SharedUser & getUserRole Tests
    // =============================================

    group('👤 SharedUser & getUserRole', () {
      test('getUserRole should return owner for createdBy user', () {
        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה',
          createdBy: 'owner-123',
        );

        final role = list.getUserRole('owner-123');
        expect(role, UserRole.owner);
      });

      test('getUserRole should return role from sharedUsers map', () {
        final sharedUsers = {
          'admin-456': SharedUser(
            userId: 'admin-456',
            role: UserRole.admin,
            sharedAt: DateTime.now(),
          ),
          'editor-789': SharedUser(
            userId: 'editor-789',
            role: UserRole.editor,
            sharedAt: DateTime.now(),
          ),
        };

        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה',
          createdBy: 'owner-123',
        ).copyWith(sharedUsers: sharedUsers);

        expect(list.getUserRole('admin-456'), UserRole.admin);
        expect(list.getUserRole('editor-789'), UserRole.editor);
      });

      test('getUserRole should return null for unknown user', () {
        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה',
          createdBy: 'owner-123',
        );

        expect(list.getUserRole('unknown-user'), isNull);
      });

      test('getSharedUser should return SharedUser with owner role for creator', () {
        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה',
          createdBy: 'owner-123',
        );

        final sharedUser = list.getSharedUser('owner-123');
        expect(sharedUser, isNotNull);
        expect(sharedUser!.role, UserRole.owner);
        expect(sharedUser.userId, 'owner-123');
      });
    });

    // =============================================
    // 🎨 UI Display Tests
    // =============================================

    group('🎨 UserRole UI Display', () {
      test('hebrewName should return correct Hebrew names', () {
        expect(UserRole.owner.hebrewName, 'בעלים');
        expect(UserRole.admin.hebrewName, 'מנהל');
        expect(UserRole.editor.hebrewName, 'עורך');
        expect(UserRole.viewer.hebrewName, 'צופה');
      });

      test('emoji should return correct emojis', () {
        expect(UserRole.owner.emoji, '👑');
        expect(UserRole.admin.emoji, '🔧');
        expect(UserRole.editor.emoji, '✏️');
        expect(UserRole.viewer.emoji, '👀');
      });
    });

    // =============================================
    // 📋 סיכום מטריצת הרשאות (טבלה)
    // =============================================

    group('📋 סיכום מטריצת הרשאות', () {
      test('טבלת הרשאות מלאה', () {
        // הדפסת טבלה לצורך documentation
        print('\n');
        print('╔══════════════════════════════════════════════════════════════════╗');
        print('║                    📊 מטריצת הרשאות                              ║');
        print('╠══════════════════════════════════════════════════════════════════╣');
        print('║ פעולה                    │ Owner │ Admin │ Editor │ Viewer      ║');
        print('╠══════════════════════════════════════════════════════════════════╣');
        print('║ קריאה                    │   ✅  │   ✅  │   ✅   │   ✅        ║');
        print('║ הוספה ישירה             │   ✅  │   ✅  │   ❌   │   ❌        ║');
        print('║ עריכה ישירה             │   ✅  │   ✅  │   ❌   │   ❌        ║');
        print('║ מחיקה ישירה             │   ✅  │   ✅  │   ❌   │   ❌        ║');
        print('║ שליחת בקשות             │   ❌  │   ❌  │   ✅   │   ❌        ║');
        print('║ אישור בקשות             │   ✅  │   ✅  │   ❌   │   ❌        ║');
        print('║ ניהול משתמשים           │   ✅  │   ❌  │   ❌   │   ❌        ║');
        print('║ הזמנת משתמשים           │   ✅  │   ❌  │   ❌   │   ❌        ║');
        print('║ מחיקת רשימה             │   ✅  │   ❌  │   ❌   │   ❌        ║');
        print('╚══════════════════════════════════════════════════════════════════╝');
        print('\n');

        // בדיקות מסכמות
        // Owner - מלוא ההרשאות
        expect(UserRole.owner.canRead, true);
        expect(UserRole.owner.canAddDirectly, true);
        expect(UserRole.owner.canEditDirectly, true);
        expect(UserRole.owner.canDeleteDirectly, true);
        expect(UserRole.owner.canRequest, false); // לא צריך - מוסיף ישירות
        expect(UserRole.owner.canApproveRequests, true);
        expect(UserRole.owner.canManageUsers, true);
        expect(UserRole.owner.canDeleteList, true);

        // Admin - כמעט הכל
        expect(UserRole.admin.canRead, true);
        expect(UserRole.admin.canAddDirectly, true);
        expect(UserRole.admin.canEditDirectly, true);
        expect(UserRole.admin.canDeleteDirectly, true);
        expect(UserRole.admin.canRequest, false); // לא צריך - מוסיף ישירות
        expect(UserRole.admin.canApproveRequests, true);
        expect(UserRole.admin.canManageUsers, false); // ❌
        expect(UserRole.admin.canDeleteList, false); // ❌

        // Editor - עריכה עם בקשות
        expect(UserRole.editor.canRead, true);
        expect(UserRole.editor.canAddDirectly, false); // ❌
        expect(UserRole.editor.canEditDirectly, false); // ❌
        expect(UserRole.editor.canDeleteDirectly, false); // ❌
        expect(UserRole.editor.canRequest, true); // ✅
        expect(UserRole.editor.canApproveRequests, false); // ❌
        expect(UserRole.editor.canManageUsers, false); // ❌
        expect(UserRole.editor.canDeleteList, false); // ❌

        // Viewer - קריאה בלבד
        expect(UserRole.viewer.canRead, true);
        expect(UserRole.viewer.canAddDirectly, false); // ❌
        expect(UserRole.viewer.canEditDirectly, false); // ❌
        expect(UserRole.viewer.canDeleteDirectly, false); // ❌
        expect(UserRole.viewer.canRequest, false); // ❌
        expect(UserRole.viewer.canApproveRequests, false); // ❌
        expect(UserRole.viewer.canManageUsers, false); // ❌
        expect(UserRole.viewer.canDeleteList, false); // ❌
      });
    });

    // =============================================
    // 🧪 Edge Cases
    // =============================================

    group('🧪 Edge Cases', () {
      test('null currentUserRole should return false for all permissions', () {
        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה',
          createdBy: 'owner-123',
        );
        // currentUserRole is null by default

        expect(list.isCurrentUserOwner, false);
        expect(list.canCurrentUserEdit, false);
        expect(list.canCurrentUserApprove, false);
        expect(list.canCurrentUserManage, false);
        expect(list.canCurrentUserInvite, false);
        expect(list.canCurrentUserDelete, false);
        expect(list.shouldCurrentUserRequest, false);
      });

      test('multiple sharedUsers should have correct roles', () {
        final sharedUsers = {
          'user-admin': SharedUser(
            userId: 'user-admin',
            role: UserRole.admin,
            sharedAt: DateTime.now(),
          ),
          'user-editor': SharedUser(
            userId: 'user-editor',
            role: UserRole.editor,
            sharedAt: DateTime.now(),
          ),
          'user-viewer': SharedUser(
            userId: 'user-viewer',
            role: UserRole.viewer,
            sharedAt: DateTime.now(),
          ),
        };

        final list = ShoppingList.newList(
          id: 'test-list',
          name: 'רשימה משותפת',
          createdBy: 'owner-123',
        ).copyWith(sharedUsers: sharedUsers);

        // Owner (creator)
        expect(list.getUserRole('owner-123'), UserRole.owner);

        // Shared users
        expect(list.getUserRole('user-admin'), UserRole.admin);
        expect(list.getUserRole('user-editor'), UserRole.editor);
        expect(list.getUserRole('user-viewer'), UserRole.viewer);
      });
    });
  });
}
