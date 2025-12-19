// File: lib/providers/pending_invites_provider.dart
// Purpose: Provider לניהול הזמנות ממתינות לקבוצות
//
// Features:
// - בדיקת הזמנות ממתינות בהתחברות/הרשמה
// - אישור/דחיית הזמנות
// - הצגת badge בתפריט
//
// Version: 1.0
// Created: 16/12/2025

import 'package:flutter/foundation.dart';

import '../models/group_invite.dart';
import '../repositories/group_invite_repository.dart';

/// Provider לניהול הזמנות ממתינות לקבוצות
class PendingInvitesProvider with ChangeNotifier {
  final GroupInviteRepository _repository;

  List<GroupInvite> _pendingInvites = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChecked = false;

  PendingInvitesProvider({GroupInviteRepository? repository})
      : _repository = repository ?? GroupInviteRepository();

  // === Getters ===

  /// גישה ל-repository (לשימוש על ידי providers אחרים)
  GroupInviteRepository get repository => _repository;

  /// רשימת הזמנות ממתינות
  List<GroupInvite> get pendingInvites => List.unmodifiable(_pendingInvites);

  /// מספר הזמנות ממתינות (ל-badge)
  int get pendingCount => _pendingInvites.length;

  /// האם יש הזמנות ממתינות
  bool get hasPendingInvites => _pendingInvites.isNotEmpty;

  /// האם בטעינה
  bool get isLoading => _isLoading;

  /// הודעת שגיאה
  String? get errorMessage => _errorMessage;

  /// האם כבר בדקנו הזמנות (למניעת בדיקות כפולות)
  bool get hasChecked => _hasChecked;

  // === Actions ===

  /// בדיקת הזמנות ממתינות למשתמש
  /// נקרא אחרי התחברות/הרשמה
  Future<void> checkPendingInvites({
    String? phone,
    String? email,
  }) async {
    if (phone == null && email == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingInvites = await _repository.findPendingInvites(
        phone: phone,
        email: email,
      );

      _hasChecked = true;

      if (kDebugMode) {
        debugPrint('✅ PendingInvitesProvider: Found ${_pendingInvites.length} pending invites');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.checkPendingInvites: $e');
      }
      _errorMessage = 'שגיאה בבדיקת הזמנות';
      _pendingInvites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// אישור הזמנה והצטרפות לקבוצה
  Future<bool> acceptInvite({
    required GroupInvite invite,
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatar,
  }) async {
    try {
      await _repository.acceptInviteAndJoinGroup(
        invite: invite,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userAvatar: userAvatar,
      );

      // הסר מהרשימה המקומית
      _pendingInvites = _pendingInvites.where((i) => i.id != invite.id).toList();
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.acceptInvite: $e');
      }
      _errorMessage = 'שגיאה באישור ההזמנה';
      notifyListeners();
      return false;
    }
  }

  /// דחיית הזמנה
  Future<bool> rejectInvite(GroupInvite invite) async {
    try {
      await _repository.rejectInvite(invite.id);

      // הסר מהרשימה המקומית
      _pendingInvites = _pendingInvites.where((i) => i.id != invite.id).toList();
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.rejectInvite: $e');
      }
      _errorMessage = 'שגיאה בדחיית ההזמנה';
      notifyListeners();
      return false;
    }
  }

  /// ניקוי הרשימה (בהתנתקות)
  void clear() {
    _pendingInvites = [];
    _hasChecked = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// רענון הזמנות
  Future<void> refresh({String? phone, String? email}) async {
    _hasChecked = false;
    await checkPendingInvites(phone: phone, email: email);
  }
}
