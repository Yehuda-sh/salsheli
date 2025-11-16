// 🧪 Test: PendingRequestsService
// Tests for pending requests functionality

// ignore_for_file: directives_ordering, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:memozap/models/enums/request_status.dart';
import 'package:memozap/models/enums/request_type.dart';
import 'package:memozap/models/enums/user_role.dart';
import 'package:memozap/models/pending_request.dart';
import 'package:memozap/models/shared_user.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/models/unified_list_item.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/services/notifications_service.dart';
import 'package:memozap/services/pending_requests_service.dart';

// Generate mocks
@GenerateMocks([ShoppingListsRepository, UserContext, NotificationsService])
import 'pending_requests_service_test.mocks.dart';

void main() {
  group('PendingRequestsService', () {
    // Test data
    late MockShoppingListsRepository mockRepository;
    late MockUserContext mockUserContext;
    late MockNotificationsService mockNotificationsService;
    late PendingRequestsService service;
    late ShoppingList testList;

    const ownerId = 'owner-123';
    const editorId = 'editor-789';

    setUp(() {
      // Setup mocks
      mockRepository = MockShoppingListsRepository();
      mockUserContext = MockUserContext();
      mockNotificationsService = MockNotificationsService();

      // Mock UserContext
      when(mockUserContext.userId).thenReturn(editorId);
      when(mockUserContext.displayName).thenReturn('Editor User');
      when(mockUserContext.householdId).thenReturn('household-001');

      // Create service
      service = PendingRequestsService(mockRepository, mockUserContext);

      // Create test list with Editor
      testList = ShoppingList.newList(name: 'רשימת קניות', createdBy: ownerId).copyWith(
        id: 'list-001',
        sharedUsers: [SharedUser(userId: editorId, role: UserRole.editor, sharedAt: DateTime.now())],
        pendingRequests: const [],
        isShared: true,
      );
    });

    // ════════════════════════════════════════════
    // createRequest Tests
    // ════════════════════════════════════════════

    group('createRequest()', () {
      test('Editor can create request to add item', () async {
        // Arrange
        when(mockRepository.saveList(any, any)).thenAnswer((_) async => testList);

        // Act
        await service.createRequest(
          list: testList,
          type: RequestType.addItem,
          requestData: {'name': 'חלב', 'quantity': 2, 'unitPrice': 5.0},
        );

        // Assert
        final captured = verify(mockRepository.saveList(captureAny, any)).captured.single as ShoppingList;
        expect(captured.pendingRequests.length, 1);
        expect(captured.pendingRequests[0].type, RequestType.addItem);
        expect(captured.pendingRequests[0].requestData['name'], 'חלב');
      });

      test('Non-editor cannot create request', () async {
        // Arrange - Mock Owner
        when(mockUserContext.userId).thenReturn(ownerId);

        // Act & Assert
        expect(
          () => service.createRequest(list: testList, type: RequestType.addItem, requestData: {'name': 'חלב'}),
          throwsA(predicate((e) => e.toString().contains('אין צורך בבקשה'))),
        );

        verifyNever(mockRepository.saveList(any, any));
      });

      test('createAddItemRequest() creates full request', () async {
        // Arrange
        when(mockRepository.saveList(any, any)).thenAnswer((_) async => testList);

        final item = UnifiedListItem.product(name: 'לחם', quantity: 1, unitPrice: 8.0, unit: 'יח\'');

        // Act
        await service.createAddItemRequest(list: testList, item: item);

        // Assert
        final captured = verify(mockRepository.saveList(captureAny, any)).captured.single as ShoppingList;
        expect(captured.pendingRequests.length, 1);
        expect(captured.pendingRequests[0].requestData['name'], 'לחם');
        expect(captured.pendingRequests[0].requestData['quantity'], 1);
        expect(captured.pendingRequests[0].requestData['unitPrice'], 8.0);
      });
    });

    // ════════════════════════════════════════════
    // approveRequest Tests
    // ════════════════════════════════════════════

    group('approveRequest()', () {
      late ShoppingList listWithPendingRequest;

      setUp(() {
        // List with 1 pending request
        listWithPendingRequest = testList.copyWith(
          pendingRequests: [
            PendingRequest.newRequest(
              id: 'req-001',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'חלב', 'quantity': 2, 'unitPrice': 5.0},
              requesterName: 'Editor User',
            ),
          ],
        );

        // Mock Owner
        when(mockUserContext.userId).thenReturn(ownerId);
        when(mockUserContext.displayName).thenReturn('Owner User');
      });

      test('Owner can approve request and add item', () async {
        // Arrange
        when(mockRepository.saveList(any, any)).thenAnswer((_) async => listWithPendingRequest);
        when(mockNotificationsService.createRequestApprovedNotification(
          userId: anyNamed('userId'),
          householdId: anyNamed('householdId'),
          listId: anyNamed('listId'),
          listName: anyNamed('listName'),
          itemName: anyNamed('itemName'),
          approverName: anyNamed('approverName'),
        )).thenAnswer((_) async => {});

        final requestId = listWithPendingRequest.pendingRequests[0].id;

        // Act
        await service.approveRequest(
          list: listWithPendingRequest,
          requestId: requestId,
          approverName: 'Owner User',
          notificationsService: mockNotificationsService,
        );

        // Assert
        final captured = verify(mockRepository.saveList(captureAny, any)).captured.single as ShoppingList;

        // Check item added
        expect(captured.items.length, 1);
        expect(captured.items[0].name, 'חלב');

        // Check request status
        expect(captured.pendingRequests.length, 1);
        expect(captured.pendingRequests[0].isApproved, true);
        expect(captured.pendingRequests[0].reviewerId, ownerId);
      });

      test('Non-approver cannot approve request', () async {
        // Arrange - Mock Editor (not Owner/Admin)
        when(mockUserContext.userId).thenReturn(editorId);

        final requestId = listWithPendingRequest.pendingRequests[0].id;

        // Act & Assert
        expect(
          () => service.approveRequest(
            list: listWithPendingRequest,
            requestId: requestId,
            approverName: 'Editor User',
            notificationsService: mockNotificationsService,
          ),
          throwsA(predicate((e) => e.toString().contains('אין לך הרשאה לאשר בקשות'))),
        );

        verifyNever(mockRepository.saveList(any, any));
      });

      test('Cannot approve non-existing request', () async {
        // Act & Assert
        expect(
          () => service.approveRequest(
            list: listWithPendingRequest,
            requestId: 'non-existing-id',
            approverName: 'Owner User',
            notificationsService: mockNotificationsService,
          ),
          throwsA(predicate((e) => e.toString().contains('בקשה לא נמצאה'))),
        );
      });

      test('Cannot approve already-approved request', () async {
        // Arrange - Mark request as approved
        final approvedRequest = listWithPendingRequest.pendingRequests[0].copyWith(
          status: RequestStatus.approved,
          reviewerId: ownerId,
          reviewedAt: DateTime.now(),
        );

        final listWithApprovedRequest = listWithPendingRequest.copyWith(pendingRequests: [approvedRequest]);

        // Act & Assert
        expect(
          () => service.approveRequest(
            list: listWithApprovedRequest,
            requestId: approvedRequest.id,
            approverName: 'Owner User',
            notificationsService: mockNotificationsService,
          ),
          throwsA(predicate((e) => e.toString().contains('הבקשה כבר טופלה'))),
        );
      });
    });

    // ════════════════════════════════════════════
    // rejectRequest Tests
    // ════════════════════════════════════════════

    group('rejectRequest()', () {
      late ShoppingList listWithPendingRequest;

      setUp(() {
        // List with 1 pending request
        listWithPendingRequest = testList.copyWith(
          pendingRequests: [
            PendingRequest.newRequest(
              id: 'req-002',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'חלב'},
              requesterName: 'Editor User',
            ),
          ],
        );

        // Mock Owner
        when(mockUserContext.userId).thenReturn(ownerId);
        when(mockUserContext.displayName).thenReturn('Owner User');
      });

      test('Owner can reject request', () async {
        // Arrange
        when(mockRepository.saveList(any, any)).thenAnswer((_) async => listWithPendingRequest);
        when(mockNotificationsService.createRequestRejectedNotification(
          userId: anyNamed('userId'),
          householdId: anyNamed('householdId'),
          listId: anyNamed('listId'),
          listName: anyNamed('listName'),
          itemName: anyNamed('itemName'),
          reviewerName: anyNamed('reviewerName'),
          reason: anyNamed('reason'),
        )).thenAnswer((_) async => {});

        final requestId = listWithPendingRequest.pendingRequests[0].id;

        // Act
        await service.rejectRequest(
          list: listWithPendingRequest,
          requestId: requestId,
          reason: 'לא רלוונטי',
          rejecterName: 'Owner User',
          notificationsService: mockNotificationsService,
        );

        // Assert
        final captured = verify(mockRepository.saveList(captureAny, any)).captured.single as ShoppingList;

        // Check request status
        expect(captured.pendingRequests.length, 1);
        expect(captured.pendingRequests[0].isRejected, true);
        expect(captured.pendingRequests[0].rejectionReason, 'לא רלוונטי');
        expect(captured.pendingRequests[0].reviewerId, ownerId);

        // Check item NOT added
        expect(captured.items.length, 0);
      });

      test('Non-approver cannot reject request', () async {
        // Arrange - Mock Editor
        when(mockUserContext.userId).thenReturn(editorId);

        final requestId = listWithPendingRequest.pendingRequests[0].id;

        // Act & Assert
        expect(
          () => service.rejectRequest(
            list: listWithPendingRequest,
            requestId: requestId,
            rejecterName: 'Editor User',
            notificationsService: mockNotificationsService,
          ),
          throwsA(predicate((e) => e.toString().contains('אין לך הרשאה לדחות בקשות'))),
        );

        verifyNever(mockRepository.saveList(any, any));
      });
    });

    // ════════════════════════════════════════════
    // cleanupOldRejectedRequests Tests
    // ════════════════════════════════════════════

    group('cleanupOldRejectedRequests()', () {
      test('Removes rejected requests older than 7 days', () async {
        // Arrange
        final oldRejectedRequest =
            PendingRequest.newRequest(
              id: 'req-old',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'חלב'},
              requesterName: 'Editor',
            ).copyWith(
              status: RequestStatus.rejected,
              reviewedAt: DateTime.now().subtract(const Duration(days: 8)), // 8 days ago
            );

        final recentRejectedRequest =
            PendingRequest.newRequest(
              id: 'req-recent',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'לחם'},
              requesterName: 'Editor',
            ).copyWith(
              status: RequestStatus.rejected,
              reviewedAt: DateTime.now().subtract(const Duration(days: 3)), // 3 days ago
            );

        final listWithOldRequests = testList.copyWith(pendingRequests: [oldRejectedRequest, recentRejectedRequest]);

        when(mockRepository.saveList(any, any)).thenAnswer((_) async => listWithOldRequests);

        // Act
        await service.cleanupOldRejectedRequests(listWithOldRequests);

        // Assert
        final captured = verify(mockRepository.saveList(captureAny, any)).captured.single as ShoppingList;

        // Only recent request remains
        expect(captured.pendingRequests.length, 1);
        expect(captured.pendingRequests[0].requestData['name'], 'לחם'); // Recent one
      });

      test('Does not remove pending or approved requests', () async {
        // Arrange
        final pendingRequest = PendingRequest.newRequest(
          id: 'req-pending',
          listId: testList.id,
          requesterId: editorId,
          type: RequestType.addItem,
          requestData: {'name': 'חלב'},
          requesterName: 'Editor',
        );

        final approvedRequest = PendingRequest.newRequest(
          id: 'req-approved',
          listId: testList.id,
          requesterId: editorId,
          type: RequestType.addItem,
          requestData: {'name': 'לחם'},
          requesterName: 'Editor',
        ).copyWith(status: RequestStatus.approved, reviewedAt: DateTime.now().subtract(const Duration(days: 10)));

        final listWithRequests = testList.copyWith(pendingRequests: [pendingRequest, approvedRequest]);

        // Act
        await service.cleanupOldRejectedRequests(listWithRequests);

        // Assert - No cleanup needed
        verifyNever(mockRepository.saveList(any, any));
      });
    });

    // ════════════════════════════════════════════
    // Query Methods Tests
    // ════════════════════════════════════════════

    group('Query Methods', () {
      late ShoppingList listWithVariousRequests;

      setUp(() {
        listWithVariousRequests = testList.copyWith(
          pendingRequests: [
            PendingRequest.newRequest(
              id: 'req-1',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'חלב'},
              requesterName: 'Editor',
            ), // Pending
            PendingRequest.newRequest(
              id: 'req-2',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'לחם'},
              requesterName: 'Editor',
            ).copyWith(status: RequestStatus.approved, reviewerId: ownerId), // Approved
            PendingRequest.newRequest(
              id: 'req-3',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'גבינה'},
              requesterName: 'Editor',
            ).copyWith(status: RequestStatus.rejected, reviewerId: ownerId), // Rejected
          ],
        );
      });

      test('getPendingRequests() returns only pending', () {
        // Act
        final pending = service.getPendingRequests(listWithVariousRequests);

        // Assert
        expect(pending.length, 1);
        expect(pending[0].requestData['name'], 'חלב');
        expect(pending[0].isPending, true);
      });

      test('getPendingRequestsCount() counts only pending', () {
        // Act
        final count = service.getPendingRequestsCount(listWithVariousRequests);

        // Assert
        expect(count, 1);
      });

      test('getAllRequests() returns all requests', () {
        // Act
        final all = service.getAllRequests(listWithVariousRequests);

        // Assert
        expect(all.length, 3);
      });

      test('getRequestsByStatus() filters by status', () {
        // Act - Get approved
        final approved = service.getRequestsByStatus(listWithVariousRequests, RequestStatus.approved);

        // Assert
        expect(approved.length, 1);
        expect(approved[0].requestData['name'], 'לחם');

        // Act - Get rejected
        final rejected = service.getRequestsByStatus(listWithVariousRequests, RequestStatus.rejected);

        // Assert
        expect(rejected.length, 1);
        expect(rejected[0].requestData['name'], 'גבינה');
      });

      test('getRequestsByUser() filters by user', () {
        // Act
        final byEditor = service.getRequestsByUser(listWithVariousRequests, editorId);

        // Assert
        expect(byEditor.length, 3); // All from same editor
      });
    });

    // ════════════════════════════════════════════
    // Statistics Tests
    // ════════════════════════════════════════════

    group('Statistics', () {
      test('getRequestsStats() returns correct counts', () {
        // Arrange
        final listWithRequests = testList.copyWith(
          pendingRequests: [
            PendingRequest.newRequest(
              id: 'req-stat-1',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': '1'},
              requesterName: 'Editor',
            ), // Pending
            PendingRequest.newRequest(
              id: 'req-stat-2',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': '2'},
              requesterName: 'Editor',
            ).copyWith(status: RequestStatus.approved), // Approved
            PendingRequest.newRequest(
              id: 'req-stat-3',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': '3'},
              requesterName: 'Editor',
            ).copyWith(status: RequestStatus.rejected), // Rejected
          ],
        );

        // Act
        final stats = service.getRequestsStats(listWithRequests);

        // Assert
        expect(stats['total'], 3);
        expect(stats['pending'], 1);
        expect(stats['approved'], 1);
        expect(stats['rejected'], 1);
      });

      test('hasPendingRequests() returns true when has pending', () {
        // Arrange
        final listWithPending = testList.copyWith(
          pendingRequests: [
            PendingRequest.newRequest(
              id: 'req-has-pending',
              listId: testList.id,
              requesterId: editorId,
              type: RequestType.addItem,
              requestData: {'name': 'חלב'},
              requesterName: 'Editor',
            ),
          ],
        );

        // Act & Assert
        expect(service.hasPendingRequests(listWithPending), true);
      });

      test('hasPendingRequests() returns false when no pending', () {
        // Act & Assert
        expect(service.hasPendingRequests(testList), false);
      });
    });
  });
}
