// 📄 File: lib/services/pending_requests_service.dart
//
// 🎯 מטרה: ניהול בקשות ממתינות לשינויים ברשימות קניות משותפות
//
// 📋 Features:
// - יצירת בקשות (Editor מבקש הוספת מוצר)
// - אישור/דחיית בקשות (Owner/Admin בלבד)
// - שליפת בקשות ממתינות (לבאדג' ולממשק)
// - ניקוי אוטומטי של בקשות ישנות (מעל 7 ימים)
// - שליחת התראות למבקש על אישור/דחייה
//
// 🔐 Permission Model:
// - Editor: יכול רק לבקש (createRequest)
// - Admin/Owner: יכול לאשר/לדחות (approve/reject)
//
// 🔗 Related:
// - PendingRequest (models/pending_request.dart)
// - ShoppingList (models/shopping_list.dart)
// - ShareListService (services/share_list_service.dart)
// - NotificationsService (services/notifications_service.dart)
//
// Version: 1.0
// Last Updated: 13/01/2026

import 'dart:developer';

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
/// 2. Owner/Admin רואה badge → getPendingRequestsCount()
/// 3. Owner/Admin פותח בקשות → getPendingRequests()
/// 4. Owner/Admin מאשר → approveRequest() → מוצר נוסף לרשימה
/// 5. Owner/Admin דוחה → rejectRequest() → בקשה נמחקת
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
    } catch (e) {
      log('❌ כשל ביצירת בקשה: $e [PendingRequestsService]');
      rethrow;
    }
  }

  /// 🇮🇱 יצירת בקשה להוספת מוצר (wrapper מפשט)
  /// 🇬🇧 Create request to add item (simplified wrapper)
  Future<void> createAddItemRequest({
    required ShoppingList list,
    required UnifiedListItem item,
  }) async {
    await createRequest(
      list: list,
      type: RequestType.addItem,
      requestData: {
        'name': item.name,
        'quantity': item.quantity ?? 1,
        'unitPrice': item.unitPrice ?? 0.0,
        'barcode': item.barcode,
        'unit': item.unit,
        'category': item.category,
        'notes': item.notes,
      },
    );
  }

  /// יצירת בקשה לעריכת מוצר (Editor)
  Future<void> createEditItemRequest({
    required ShoppingList list,
    required UnifiedListItem item,
  }) async {
    await createRequest(
      list: list,
      type: RequestType.editItem,
      requestData: {
        'name': item.name,
        'quantity': item.quantity ?? 1,
        'unitPrice': item.unitPrice ?? 0.0,
        'barcode': item.barcode,
        'unit': item.unit,
        'category': item.category,
        'notes': item.notes,
      },
    );
  }

  /// יצירת בקשה למחיקת מוצר (Editor)
  Future<void> createDeleteItemRequest({
    required ShoppingList list,
    required String itemName,
  }) async {
    await createRequest(
      list: list,
      type: RequestType.deleteItem,
      requestData: {
        'name': itemName,
      },
    );
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
        // עריכת מוצר קיים
        final itemName = request.requestData['name'] as String?;
        if (itemName != null) {
          final index = updatedItems.indexWhere((i) => i.name == itemName);
          if (index != -1) {
            updatedItems[index] = UnifiedListItem.fromRequestData(request.requestData);
          }
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
          itemName: request.requestData['name'] as String? ?? 'מוצר',
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
          itemName: request.requestData['name'] as String? ?? 'מוצר',
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
  // Cleanup Rejected Requests (Helper)
  // ════════════════════════════════════════════

  /// 🇮🇱 מחיקת בקשות שנדחו לפני יותר מ-7 ימים
  /// 🇬🇧 Delete rejected requests older than 7 days
  /// 
  /// אפשר לקרוא אחת לשבוע או אוטומטית ב-background
  Future<void> cleanupOldRejectedRequests(ShoppingList list) async {
    final now = DateTime.now();
    const maxAge = Duration(days: 7);

    // סינון: השאר רק בקשות חדשות או ממתינות/אושרות
    final updatedRequests = list.pendingRequests.where((request) {
      if (request.isRejected) {
        final age = now.difference(request.reviewedAt ?? request.createdAt);
        return age < maxAge; // השאר רק אם < 7 ימים
      }
      return true; // השאר בקשות אחרות
    }).toList();

    // אם יש שינוי - עדכון Firebase
    if (updatedRequests.length != list.pendingRequests.length) {
      try {
        final userId = _userContext.userId;
        final householdId = _userContext.householdId;
        if (userId == null || householdId == null) {
          throw Exception('משתמש לא מחובר או לא משויך למשק בית');
        }
        await _repository.saveList(
          list.copyWith(pendingRequests: updatedRequests),
          userId,
          householdId,
        );
        final removed = list.pendingRequests.length - updatedRequests.length;
        log('✅ נמחקו $removed בקשות ישנות [PendingRequestsService]');
      } catch (e) {
        log('❌ כשל במחיקת בקשות: $e [PendingRequestsService]');
      }
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

  /// 🇮🇱 ספירת בקשות ממתינות (לבאדג')
  /// 🇬🇧 Count pending requests (for badge)
  int getPendingRequestsCount(ShoppingList list) {
    return list.pendingRequests.where((r) => r.isPending).length;
  }

  /// 🇮🇱 קבלת כל הבקשות (כולל מאושרות/נדחות)
  /// 🇬🇧 Get all requests (including approved/rejected)
  List<PendingRequest> getAllRequests(ShoppingList list) {
    return list.pendingRequests;
  }

  /// 🇮🇱 קבלת בקשות לפי סטטוס
  /// 🇬🇧 Get requests by status
  List<PendingRequest> getRequestsByStatus(
    ShoppingList list,
    RequestStatus status,
  ) {
    return list.pendingRequests.where((r) => r.status == status).toList();
  }

  /// 🇮🇱 קבלת בקשות של משתמש מסוים
  /// 🇬🇧 Get requests by specific user
  List<PendingRequest> getRequestsByUser(
    ShoppingList list,
    String userId,
  ) {
    return list.pendingRequests.where((r) => r.requesterId == userId).toList();
  }

  // ════════════════════════════════════════════
  // Statistics
  // ════════════════════════════════════════════

  /// 🇮🇱 סטטיסטיקה של בקשות
  /// 🇬🇧 Requests statistics
  Map<String, int> getRequestsStats(ShoppingList list) {
    final all = list.pendingRequests;
    return {
      'total': all.length,
      'pending': all.where((r) => r.isPending).length,
      'approved': all.where((r) => r.isApproved).length,
      'rejected': all.where((r) => r.isRejected).length,
    };
  }

  /// 🇮🇱 האם יש בקשות ממתינות
  /// 🇬🇧 Has pending requests
  bool hasPendingRequests(ShoppingList list) {
    return getPendingRequestsCount(list) > 0;
  }
}
