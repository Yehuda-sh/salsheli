// 🧪 Test: ShareListService
// Tests for user sharing functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/shared_user.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/services/share_list_service.dart';

void main() {
  group('ShareListService', () {
    // Test data
    late ShoppingList testList;
    const ownerId = 'owner-123';
    const userId1 = 'user-456';
    const userId2 = 'user-789';
    const householdId = 'household-001';

    setUp(() {
      // רשימה בסיסית עם Owner בלבד
      testList = ShoppingList.newList(
        id: 'list-001',
        name: 'רשימת קניות',
        createdBy: ownerId,
      );
    });

    // ════════════════════════════════════════════
    // inviteUser Tests
    // ════════════════════════════════════════════

    group('inviteUser()', () {
      test('Owner can invite user as Admin', () async {
        // Act
        final updatedList = await ShareListService.inviteUser(
          list: testList,
          currentUserId: ownerId,
          invitedUserId: userId1,
          role: UserRole.admin,
          userName: 'User 1',
          userEmail: 'user1@example.com',
          inviterName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 1);
        expect(updatedList.sharedUsers[0].userId, userId1);
        expect(updatedList.sharedUsers[0].role, UserRole.admin);
        expect(updatedList.sharedUsers[0].userName, 'User 1');
        expect(updatedList.isShared, true);
      });

      test('Owner can invite user as Editor', () async {
        // Act
        final updatedList = await ShareListService.inviteUser(
          list: testList,
          currentUserId: ownerId,
          invitedUserId: userId1,
          role: UserRole.editor,
          inviterName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 1);
        expect(updatedList.sharedUsers[0].role, UserRole.editor);
      });

      test('Owner can invite user as Viewer', () async {
        // Act
        final updatedList = await ShareListService.inviteUser(
          list: testList,
          currentUserId: ownerId,
          invitedUserId: userId1,
          role: UserRole.viewer,
          inviterName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 1);
        expect(updatedList.sharedUsers[0].role, UserRole.viewer);
      });

      test('Non-owner cannot invite users', () {
        // Act & Assert
        expect(
          () => ShareListService.inviteUser(
            list: testList,
            currentUserId: userId1, // Not owner!
            invitedUserId: userId2,
            role: UserRole.admin,
            inviterName: 'User 1',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('permission_denied'),
            ),
          ),
        );
      });

      test('Cannot invite same user twice', () async {
        // Arrange - invite user1 first
        final listWithUser = await ShareListService.inviteUser(
          list: testList,
          currentUserId: ownerId,
          invitedUserId: userId1,
          role: UserRole.admin,
          inviterName: 'Owner',
          householdId: householdId,
        );

        // Act & Assert - try to invite again
        expect(
          () => ShareListService.inviteUser(
            list: listWithUser,
            currentUserId: ownerId,
            invitedUserId: userId1, // Same user!
            role: UserRole.editor,
            inviterName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('user_already_shared'),
            ),
          ),
        );
      });

      test('Cannot invite owner as user', () {
        // Act & Assert
        expect(
          () => ShareListService.inviteUser(
            list: testList,
            currentUserId: ownerId,
            invitedUserId: ownerId, // Owner trying to invite himself!
            role: UserRole.admin,
            inviterName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('cannot_invite_owner'),
            ),
          ),
        );
      });

      test('Cannot create additional owner', () {
        // Act & Assert
        expect(
          () => ShareListService.inviteUser(
            list: testList,
            currentUserId: ownerId,
            invitedUserId: userId1,
            role: UserRole.owner, // Trying to create second owner!
            inviterName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('invalid_role'),
            ),
          ),
        );
      });

      test('Invite multiple users', () async {
        // Act - invite 2 users
        var updatedList = await ShareListService.inviteUser(
          list: testList,
          currentUserId: ownerId,
          invitedUserId: userId1,
          role: UserRole.admin,
          inviterName: 'Owner',
          householdId: householdId,
        );

        updatedList = await ShareListService.inviteUser(
          list: updatedList,
          currentUserId: ownerId,
          invitedUserId: userId2,
          role: UserRole.editor,
          inviterName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 2);
        expect(updatedList.sharedUsers[0].userId, userId1);
        expect(updatedList.sharedUsers[1].userId, userId2);
      });
    });

    // ════════════════════════════════════════════
    // removeUser Tests
    // ════════════════════════════════════════════

    group('removeUser()', () {
      late ShoppingList listWithUsers;

      setUp(() {
        // רשימה עם 2 משתמשים
        listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );
      });

      test('Owner can remove user', () async {
        // Act
        final updatedList = await ShareListService.removeUser(
          list: listWithUsers,
          currentUserId: ownerId,
          removedUserId: userId1,
          removerName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 1);
        expect(updatedList.sharedUsers[0].userId, userId2);
        expect(updatedList.isShared, true); // Still shared (1 user left)
      });

      test('Removing last user sets isShared to false', () async {
        // Arrange - list with only 1 shared user
        final listWithOneUser = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );

        // Act
        final updatedList = await ShareListService.removeUser(
          list: listWithOneUser,
          currentUserId: ownerId,
          removedUserId: userId1,
          removerName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 0);
        expect(updatedList.isShared, false); // No more shared users
      });

      test('Non-owner cannot remove users', () {
        // Act & Assert
        expect(
          () => ShareListService.removeUser(
            list: listWithUsers,
            currentUserId: userId1, // Not owner!
            removedUserId: userId2,
            removerName: 'User 1',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('permission_denied'),
            ),
          ),
        );
      });

      test('Cannot remove owner', () {
        // Act & Assert
        expect(
          () => ShareListService.removeUser(
            list: listWithUsers,
            currentUserId: ownerId,
            removedUserId: ownerId, // Trying to remove himself!
            removerName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('cannot_remove_owner'),
            ),
          ),
        );
      });

      test('Cannot remove non-existing user', () {
        // Act & Assert
        expect(
          () => ShareListService.removeUser(
            list: listWithUsers,
            currentUserId: ownerId,
            removedUserId: 'user-999', // Doesn't exist!
            removerName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('user_not_found'),
            ),
          ),
        );
      });
    });

    // ════════════════════════════════════════════
    // updateUserRole Tests
    // ════════════════════════════════════════════

    group('updateUserRole()', () {
      late ShoppingList listWithUsers;

      setUp(() {
        // רשימה עם 2 משתמשים
        listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );
      });

      test('Owner can update user role from Admin to Editor', () async {
        // Act
        final updatedList = await ShareListService.updateUserRole(
          list: listWithUsers,
          currentUserId: ownerId,
          targetUserId: userId1,
          newRole: UserRole.editor,
          changerName: 'Owner',
          householdId: householdId,
        );

        // Assert
        expect(updatedList.sharedUsers.length, 2);
        final updatedUser = updatedList.sharedUsers
            .firstWhere((u) => u.userId == userId1);
        expect(updatedUser.role, UserRole.editor); // Changed!
      });

      test('Owner can update user role from Editor to Viewer', () async {
        // Act
        final updatedList = await ShareListService.updateUserRole(
          list: listWithUsers,
          currentUserId: ownerId,
          targetUserId: userId2,
          newRole: UserRole.viewer,
          changerName: 'Owner',
          householdId: householdId,
        );

        // Assert
        final updatedUser = updatedList.sharedUsers
            .firstWhere((u) => u.userId == userId2);
        expect(updatedUser.role, UserRole.viewer); // Changed!
      });

      test('Non-owner cannot update roles', () {
        // Act & Assert
        expect(
          () => ShareListService.updateUserRole(
            list: listWithUsers,
            currentUserId: userId1, // Not owner!
            targetUserId: userId2,
            newRole: UserRole.viewer,
            changerName: 'User 1',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('permission_denied'),
            ),
          ),
        );
      });

      test('Cannot change owner role', () {
        // Act & Assert
        expect(
          () => ShareListService.updateUserRole(
            list: listWithUsers,
            currentUserId: ownerId,
            targetUserId: ownerId, // Trying to change owner!
            newRole: UserRole.admin,
            changerName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('cannot_change_owner_role'),
            ),
          ),
        );
      });

      test('Cannot promote user to owner', () {
        // Act & Assert
        expect(
          () => ShareListService.updateUserRole(
            list: listWithUsers,
            currentUserId: ownerId,
            targetUserId: userId1,
            newRole: UserRole.owner, // Trying to create second owner!
            changerName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('invalid_role'),
            ),
          ),
        );
      });

      test('Cannot update non-existing user', () {
        // Act & Assert
        expect(
          () => ShareListService.updateUserRole(
            list: listWithUsers,
            currentUserId: ownerId,
            targetUserId: 'user-999', // Doesn't exist!
            newRole: UserRole.viewer,
            changerName: 'Owner',
            householdId: householdId,
          ),
          throwsA(
            predicate(
              (e) => e.toString().contains('user_not_found'),
            ),
          ),
        );
      });
    });

    // ════════════════════════════════════════════
    // getUsersForList Tests
    // ════════════════════════════════════════════

    group('getUsersForList()', () {
      late ShoppingList listWithUsers;

      setUp(() {
        listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );
      });

      test('Returns all users including owner', () {
        // Act
        final users = ShareListService.getUsersForList(listWithUsers);

        // Assert
        expect(users.length, 3); // Owner + 2 shared users
        expect(users[0].userId, ownerId); // Owner is first
        expect(users[0].role, UserRole.owner);
        expect(users[1].userId, userId1);
        expect(users[2].userId, userId2);
      });

      test('Returns users without owner when includeOwner=false', () {
        // Act
        final users = ShareListService.getUsersForList(
          listWithUsers,
          includeOwner: false,
        );

        // Assert
        expect(users.length, 2); // Only shared users
        expect(users[0].userId, userId1);
        expect(users[1].userId, userId2);
      });

      test('Returns only owner for non-shared list', () {
        // Act
        final users = ShareListService.getUsersForList(testList);

        // Assert
        expect(users.length, 1); // Only owner
        expect(users[0].userId, ownerId);
        expect(users[0].role, UserRole.owner);
      });
    });

    // ════════════════════════════════════════════
    // Permission Helpers Tests
    // ════════════════════════════════════════════

    group('Permission Helpers', () {
      late ShoppingList listWithUsers;

      setUp(() {
        listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );
      });

      test('canUserEdit() - Owner and Admin can edit', () {
        expect(
          ShareListService.canUserEdit(listWithUsers, ownerId),
          true,
        ); // Owner
        expect(
          ShareListService.canUserEdit(listWithUsers, userId1),
          true,
        ); // Admin
        expect(
          ShareListService.canUserEdit(listWithUsers, userId2),
          false,
        ); // Editor
      });

      test('canUserApprove() - Owner and Admin can approve', () {
        expect(
          ShareListService.canUserApprove(listWithUsers, ownerId),
          true,
        ); // Owner
        expect(
          ShareListService.canUserApprove(listWithUsers, userId1),
          true,
        ); // Admin
        expect(
          ShareListService.canUserApprove(listWithUsers, userId2),
          false,
        ); // Editor
      });

      test('canUserManage() - Only Owner can manage', () {
        expect(
          ShareListService.canUserManage(listWithUsers, ownerId),
          true,
        ); // Owner
        expect(
          ShareListService.canUserManage(listWithUsers, userId1),
          false,
        ); // Admin
        expect(
          ShareListService.canUserManage(listWithUsers, userId2),
          false,
        ); // Editor
      });

      test('shouldUserRequest() - Only Editor needs approval', () {
        expect(
          ShareListService.shouldUserRequest(listWithUsers, ownerId),
          false,
        ); // Owner
        expect(
          ShareListService.shouldUserRequest(listWithUsers, userId1),
          false,
        ); // Admin
        expect(
          ShareListService.shouldUserRequest(listWithUsers, userId2),
          true,
        ); // Editor
      });
    });

    // ════════════════════════════════════════════
    // Statistics Tests
    // ════════════════════════════════════════════

    group('Statistics', () {
      test('getUsersStats() returns correct counts', () {
        // Arrange
        final listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: 'user-3',
              role: UserRole.viewer,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );

        // Act
        final stats = ShareListService.getUsersStats(listWithUsers);

        // Assert
        expect(stats['total'], 4); // 1 owner + 3 shared
        expect(stats['owner'], 1);
        expect(stats['admin'], 1);
        expect(stats['editor'], 1);
        expect(stats['viewer'], 1);
      });

      test('isListShared() returns true for shared list', () {
        // Arrange
        final sharedList = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );

        // Act & Assert
        expect(ShareListService.isListShared(sharedList), true);
      });

      test('isListShared() returns false for non-shared list', () {
        // Act & Assert
        expect(ShareListService.isListShared(testList), false);
      });

      test('getActiveUsersCount() includes owner + shared users', () {
        // Arrange
        final listWithUsers = testList.copyWith(
          sharedUsers: [
            SharedUser(
              userId: userId1,
              role: UserRole.admin,
              sharedAt: DateTime.now(),
            ),
            SharedUser(
              userId: userId2,
              role: UserRole.editor,
              sharedAt: DateTime.now(),
            ),
          ],
          isShared: true,
        );

        // Act
        final count = ShareListService.getActiveUsersCount(listWithUsers);

        // Assert
        expect(count, 3); // 1 owner + 2 shared users
      });
    });
  });
}
