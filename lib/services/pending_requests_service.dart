// lib/services/pending_requests_service.dart — Pending requests service — editor approval workflow (add/edit/delete item requests)

import 'dart:developer';

import '../l10n/app_strings.dart';
import '../models/enums/request_status.dart';
import '../models/enums/request_type.dart';
import '../models/pending_request.dart';
import '../models/shopping_list.dart';
import '../models/unified_list_item.dart';
import '../providers/user_context.dart';
import '../repositories/shopping_lists_repository.dart';
import '../services/notifications_service.dart';
import '../services/share_list_service.dart';

/// 🇮🇱 שירות לניהול בקשות ממתינות
/// 🇬🇧 Service for managing pending requests
/// 
/// אחריות:
/// - יצירת בקשות חדשות (Editor מוסיף מוצר)
/// - אישור/דחיה (Owner/Admin)
/// - שליפת בקשות ממתינות
/// 
/// Permission Flow:
/// 1. Editor מוסיף מוצר → createRequest()
/// 2. Owner/Admin פותח בקשות → getPendingRequests()
/// 3. Owner/Admin מאשר → approveRequest() → מוצר נוסף לרשימה
/// 4. Owner/Admin דוחה → rejectRequest() → בקשה נמחקת
class PendingRequestsService {
  final ShoppingListsRepository _repository;
  final UserContext _userContext;

  PendingRequestsService(
    this._repository,
    this._userContext,
  );

  // ════════════════════════════════════════════
  // Create Request
  // ════════════════════════════════════════════

  /// 🇮🇱 יצירת בקשה חדשה להוספת מוצר
  /// 🇬🇧 Create new request to add item
  /// 
  /// Flow:
  /// 1. בדיקה שהמשתמש הוא Editor (לא Owner/Admin)
  /// 2. יצירת PendingRequest
  /// 3. הוספה ל-list.pendingRequests
  /// 4. עדכון Firebase
  /// 
  /// Throws:
  /// - Exception: אם המשתמש לא Editor
  /// - Exception: אם העדכון נכשל
  Future<void> createRequest({
    required ShoppingList list,
    required RequestType type,
    required Map<String, dynamic> requestData,
    NotificationsService? notificationsService,
  }) async {
    final currentUserId = _userContext.userId;
    if (currentUserId == null) {
      throw Exception('משתמש לא מחובר');
    }

    // Validation: רק Editor צריך לבקש אישור
    if (!ShareListService.shouldUserRequest(list, currentUserId)) {
      throw Exception(
        'אין צורך בבקשה - למשתמש יש הרשאה לערוך ישירות',
      );
    }

    // יצירת בקשה חדשה
    final request = PendingRequest.newRequest(
      listId: list.id,
      requesterId: currentUserId,
      type: type,
      requestData: requestData,
      requesterName: _userContext.displayName,
    );

    // הוספה לרשימת הבקשות
    final updatedRequests = [...list.pendingRequests, request];

    // עדכון Firebase
    try {
      final userId = _userContext.userId;
      final householdId = _userContext.householdId;
      if (householdId == null) {
        throw Exception('משתמש לא משויך למשק בית');
      }
      await _repository.saveList(
        list.copyWith(pendingRequests: updatedRequests),
        userId!,
        householdId,
      );
      log('✅ בקשה נוצרה בהצלחה [PendingRequestsService]');

      // Notify the list owner that a new request is waiting for approval.
      // Uses the approved-notification channel (closest match) with
      // a custom title/message that makes it clear this is a NEW request.
      if (notificationsService != null) {
        // createdBy is non-nullable but may be '' for malformed docs
        final ownerId = list.createdBy;
        if (ownerId.isNotEmpty && ownerId != currentUserId) {
          try {
            final requesterName = _userContext.displayName ?? '';
            final productName = requestData['name'] as String? ?? '';
            await notificationsService.createNewRequestNotification(
              userId: ownerId,
              householdId: householdId,
              listId: list.id,
              listName: list.name,
              requesterName: requesterName,
              itemName: productName,
            );
          } catch (_) {
            // Non-critical — request was created successfully
          }
        }
      }
    } catch (e) {
      log('❌ כשל ביצירת בקשה: $e [PendingRequestsService]');
      rethrow;
    }
  }

  // ════════════════════════════════════════════
  // Approve Request
  // ════════════════════════════════════════════

  /// 🇮🇱 אישור בקשה (Owner/Admin only)
  /// 🇬🇧 Approve request (Owner/Admin only)
  /// 
  /// Flow:
  /// 1. בדיקת הרשאה (Owner/Admin)
  /// 2. מציאת הבקשה ברשימה
  /// 3. עדכון סטטוס → approved
  /// 4. ביצוע הפעולה המבוקשת (הוספת מוצר וכו')
  /// 5. עדכון Firebase
  /// 6. שליחת התראה למבקש
  /// 
  /// Throws:
  /// - Exception: אם אין הרשאה
  /// - Exception: אם הבקשה לא נמצאה
  /// - Exception: אם העדכון נכשל
  Future<void> approveRequest({
    required ShoppingList list,
    required String requestId,
    required String approverName,
    required NotificationsService notificationsService,
  }) async {
    final currentUserId = _userContext.userId;
    if (currentUserId == null) {
      throw Exception('משתמש לא מחובר');
    }

    // Validation: רק Owner/Admin יכולים לאשר
    if (!ShareListService.canUserApprove(list, currentUserId)) {
      throw Exception('אין לך הרשאה לאשר בקשות');
    }

    // מציאת הבקשה
    final request = list.pendingRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => throw Exception('בקשה לא נמצאה'),
    );

    // בדיקה שהבקשה ממתינה
    if (!request.isPending) {
      throw Exception('הבקשה כבר טופלה');
    }

    // עדכון סטטוס הבקשה
    final approvedRequest = request.copyWith(
      status: RequestStatus.approved,
      reviewerId: currentUserId,
      reviewedAt: DateTime.now(),
      reviewerName: _userContext.displayName,
    );

    // ביצוע הפעולה המבוקשת
    final List<UnifiedListItem> updatedItems = [...list.items];

    switch (request.type) {
      case RequestType.addItem:
        // הוספת מוצר חדש לרשימה
        final newItem = UnifiedListItem.fromRequestData(request.requestData);
        updatedItems.add(newItem);
        break;

      case RequestType.editItem:
        // עריכת מוצר קיים — lookup by itemId first, fallback to name
        final itemId = request.requestData['itemId'] as String?;
        final itemName = request.requestData['name'] as String?;
        final index = itemId != null
            ? updatedItems.indexWhere((i) => i.id == itemId)
            : updatedItems.indexWhere((i) => i.name == itemName);
        if (index != -1) {
          updatedItems[index] = UnifiedListItem.fromRequestData(request.requestData);
        }
        break;

      case RequestType.deleteItem:
        // מחיקת מוצר
        final itemName = request.requestData['name'] as String?;
        if (itemName != null) {
          updatedItems.removeWhere((i) => i.name == itemName);
        }
        break;

      case RequestType.inviteToList:
      case RequestType.inviteToHousehold:
        // הזמנות מטופלות ב-PendingInvitesService
        log('⚠️ RequestType.inviteToList should be handled by PendingInvitesService');
        break;

      case RequestType.unknown:
        // סוג בקשה לא מוכר - לוג אזהרה ודלג
        log('⚠️ RequestType.unknown - skipping');
        break;
    }

    // עדכון הבקשות (להחליף את הבקשה המאושרת)
    final updatedRequests = list.pendingRequests
        .map((r) => r.id == requestId ? approvedRequest : r)
        .toList();

    // עדכון Firebase
    try {
      final householdId = _userContext.householdId;
      if (householdId == null) {
        throw Exception('משתמש לא משויך למשק בית');
      }
      await _repository.saveList(
        list.copyWith(
          items: updatedItems,
          pendingRequests: updatedRequests,
        ),
        currentUserId,
        householdId,
      );
      log('✅ בקשה אושרה בהצלחה [PendingRequestsService]');

      // שליחת התראה למבקש (non-critical)
      try {
        await notificationsService.createRequestApprovedNotification(
          userId: request.requesterId,
          householdId: householdId,
          listId: list.id,
          listName: list.name,
          itemName: request.requestData['name'] as String? ?? AppStrings.common.defaultProductName,
          approverName: approverName,
        );
        log('📬 התראת אישור נשלחה למבקש [PendingRequestsService]');
      } catch (e) {
        log('⚠️ כשל בשליחת התראת אישור: $e [PendingRequestsService]');
        // Don't throw - notification is not critical
      }
    } catch (e) {
      log('❌ כשל באישור בקשה: $e [PendingRequestsService]');
      rethrow;
    }
  }

  // ════════════════════════════════════════════
  // Reject Request
  // ════════════════════════════════════════════

  /// 🇮🇱 דחיית בקשה (Owner/Admin only)
  /// 🇬🇧 Reject request (Owner/Admin only)
  /// 
  /// Flow:
  /// 1. בדיקת הרשאה (Owner/Admin)
  /// 2. מציאת הבקשה ברשימה
  /// 3. עדכון סטטוס → rejected
  /// 4. הסרת הבקשה מהרשימה (מחיקה אחרי 7 ימים)
  /// 5. עדכון Firebase
  /// 6. שליחת התראה למבקש
  /// 
  /// Throws:
  /// - Exception: אם אין הרשאה
  /// - Exception: אם הבקשה לא נמצאה
  /// - Exception: אם העדכון נכשל
  Future<void> rejectRequest({
    required ShoppingList list,
    required String requestId,
    String? reason,
    required String rejecterName,
    required NotificationsService notificationsService,
  }) async {
    final currentUserId = _userContext.userId;
    if (currentUserId == null) {
      throw Exception('משתמש לא מחובר');
    }

    // Validation: רק Owner/Admin יכולים לדחות
    if (!ShareListService.canUserApprove(list, currentUserId)) {
      throw Exception('אין לך הרשאה לדחות בקשות');
    }

    // מציאת הבקשה
    final request = list.pendingRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => throw Exception('בקשה לא נמצאה'),
    );

    // בדיקה שהבקשה ממתינה
    if (!request.isPending) {
      throw Exception('הבקשה כבר טופלה');
    }

    // עדכון סטטוס הבקשה
    final rejectedRequest = request.copyWith(
      status: RequestStatus.rejected,
      reviewerId: currentUserId,
      reviewedAt: DateTime.now(),
      reviewerName: _userContext.displayName,
      rejectionReason: reason,
    );

    // עדכון הבקשות (להחליף את הבקשה הנדחית)
    final updatedRequests = list.pendingRequests
        .map((r) => r.id == requestId ? rejectedRequest : r)
        .toList();

    // עדכון Firebase
    try {
      final householdId = _userContext.householdId;
      if (householdId == null) {
        throw Exception('משתמש לא משויך למשק בית');
      }
      await _repository.saveList(
        list.copyWith(pendingRequests: updatedRequests),
        currentUserId,
        householdId,
      );
      log('✅ בקשה נדחתה [PendingRequestsService]');

      // שליחת התראה למבקש (non-critical)
      try {
        await notificationsService.createRequestRejectedNotification(
          userId: request.requesterId,
          householdId: householdId,
          listId: list.id,
          listName: list.name,
          itemName: request.requestData['name'] as String? ?? AppStrings.common.defaultProductName,
          reviewerName: rejecterName,
          reason: reason,
        );
        log('📬 התראת דחייה נשלחה למבקש [PendingRequestsService]');
      } catch (e) {
        log('⚠️ כשל בשליחת התראת דחייה: $e [PendingRequestsService]');
        // Don't throw - notification is not critical
      }
    } catch (e) {
      log('❌ כשל בדחיית בקשה: $e [PendingRequestsService]');
      rethrow;
    }
  }

  // ════════════════════════════════════════════
  // Query Methods
  // ════════════════════════════════════════════

  /// 🇮🇱 קבלת כל הבקשות הממתינות
  /// 🇬🇧 Get all pending requests
  ///
  /// מסנן רק בקשות עם status=pending (כולל unknown)
  List<PendingRequest> getPendingRequests(ShoppingList list) {
    final requests = list.pendingRequests.where((r) => r.isPending).toList();

    // 🆕 לוג אזהרה אם יש בקשות עם type/status לא מוכרים
    _logUnknownRequests(requests);

    return requests;
  }

  /// 🆕 לוג אזהרה כשמגיעות בקשות עם ערכים לא מוכרים
  /// זה עוזר לזהות שהשרת התחיל לשלוח ערכים חדשים
  void _logUnknownRequests(List<PendingRequest> requests) {
    for (final request in requests) {
      if (!request.type.isKnown) {
        log(
          '⚠️ בקשה עם type לא מוכר! id=${request.id}, '
          'requestData=${request.requestData} [PendingRequestsService]',
        );
      }
      if (!request.status.isKnown) {
        log(
          '⚠️ בקשה עם status לא מוכר! id=${request.id}, '
          'type=${request.type} [PendingRequestsService]',
        );
      }
    }
  }

  /// 🇮🇱 קבלת בקשות של משתמש מסוים
  /// 🇬🇧 Get requests by specific user
  List<PendingRequest> getRequestsByUser(
    ShoppingList list,
    String userId,
  ) {
    return list.pendingRequests.where((r) => r.requesterId == userId).toList();
  }
}
