import 'package:flutter/foundation.dart';
import '../models/pending_request.dart';
import '../models/enums/request_type.dart';
import '../models/enums/request_status.dart';
import '../repositories/shopping_lists_repository.dart';

/// Provider לניהול בקשות ממתינות
class PendingRequestsProvider extends ChangeNotifier {
  final ShoppingListsRepository _repository;

  PendingRequestsProvider(this._repository);

  // === State ===

  List<PendingRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  // === Getters ===

  List<PendingRequest> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// בקשות ממתינות בלבד
  List<PendingRequest> get pendingRequests =>
      _requests.where((r) => r.isPending).toList();

  /// מספר בקשות ממתינות
  int get pendingCount => pendingRequests.length;

  /// בקשות לפי סוג
  List<PendingRequest> getRequestsByType(RequestType type) {
    return _requests.where((r) => r.type == type && r.isPending).toList();
  }

  // === Methods ===

  /// טוען את רשימת הבקשות
  void loadRequests(List<PendingRequest> requests) {
    _requests = requests;
    _error = null;
    notifyListeners();
  }

  /// טוען בקשות ממתינות לרשימה ספציפית
  Future<void> fetchPendingRequests(String listId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _repository.getPendingRequests(listId);
      debugPrint('✅ [PendingRequestsProvider] נטענו ${_requests.length} בקשות');
    } catch (e) {
      _error = 'שגיאה בטעינת בקשות: $e';
      debugPrint('❌ [PendingRequestsProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// יוצר בקשה חדשה
  Future<void> createRequest({
    required String listId,
    required String requesterId,
    required RequestType type,
    required Map<String, dynamic> requestData,
    String? requesterName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createRequest(
        listId,
        requesterId,
        type.name,
        requestData,
        requesterName,
      );

      // הוסף לרשימה המקומית
      final newRequest = PendingRequest.newRequest(
        listId: listId,
        requesterId: requesterId,
        type: type,
        requestData: requestData,
        requesterName: requesterName,
      );

      _requests.add(newRequest);
      debugPrint('✅ [PendingRequestsProvider] נוצרה בקשה: ${type.hebrewName}');
    } catch (e) {
      _error = 'שגיאה ביצירת בקשה: $e';
      debugPrint('❌ [PendingRequestsProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// מאשר בקשה
  Future<void> approveRequest({
    required String listId,
    required String requestId,
    required String reviewerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.approveRequest(listId, requestId, reviewerId);

      // עדכן ברשימה המקומית
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: RequestStatus.approved,
          reviewerId: reviewerId,
          reviewedAt: DateTime.now(),
        );
      }

      debugPrint('✅ [PendingRequestsProvider] בקשה אושרה: $requestId');
    } catch (e) {
      _error = 'שגיאה באישור בקשה: $e';
      debugPrint('❌ [PendingRequestsProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// דוחה בקשה
  Future<void> rejectRequest({
    required String listId,
    required String requestId,
    required String reviewerId,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.rejectRequest(listId, requestId, reviewerId, reason);

      // עדכן ברשימה המקומית
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: RequestStatus.rejected,
          reviewerId: reviewerId,
          reviewedAt: DateTime.now(),
          rejectionReason: reason,
        );
      }

      debugPrint('✅ [PendingRequestsProvider] בקשה נדחתה: $requestId');
    } catch (e) {
      _error = 'שגיאה בדחיית בקשה: $e';
      debugPrint('❌ [PendingRequestsProvider] שגיאה: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// מחזיר בקשה לפי ID
  PendingRequest? getRequestById(String requestId) {
    try {
      return _requests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }

  /// מסנן בקשות ישנות (יותר מ-7 ימים)
  void removeOldRequests() {
    final now = DateTime.now();
    _requests.removeWhere((r) {
      final daysSince = now.difference(r.createdAt).inDays;
      return daysSince > 7 && !r.isPending;
    });
    notifyListeners();
  }

  /// ניקוי state
  void clear() {
    _requests = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
