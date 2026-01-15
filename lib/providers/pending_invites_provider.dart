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
import '../services/notifications_service.dart';

/// Provider לניהול הזמנות ממתינות לקבוצות
class PendingInvitesProvider with ChangeNotifier {
  final GroupInviteRepository _repository;

  List<GroupInvite> _pendingInvites = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChecked = false;

  // 🔒 דגל לבדיקה אם ה-provider כבר disposed
  bool _isDisposed = false;

  // 🔒 מונה דור - מבטל תוצאות ישנות אחרי logout/clear
  int _checkGeneration = 0;

  // 🔒 שמירת inputs אחרונים - למניעת בדיקות כפולות עם אותם פרטים
  String? _lastCheckedPhone;
  String? _lastCheckedEmail;

  PendingInvitesProvider({GroupInviteRepository? repository})
      : _repository = repository ?? GroupInviteRepository();

  // === Safe Notification ===

  /// 🔒 קורא ל-notifyListeners() רק אם ה-provider לא disposed
  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

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
    // 🔧 נרמול: "" או " " → null
    final normalizedPhone = phone?.trim();
    final normalizedEmail = email?.trim().toLowerCase();
    final effectivePhone = (normalizedPhone?.isEmpty ?? true) ? null : normalizedPhone;
    final effectiveEmail = (normalizedEmail?.isEmpty ?? true) ? null : normalizedEmail;

    // אם אין phone וגם אין email - אין מה לחפש
    if (effectivePhone == null && effectiveEmail == null) {
      return;
    }

    // 🔒 מניעת טעינה כפולה
    if (_isLoading) return;

    // 🔒 מניעת בדיקות כפולות - רק אם אותם פרטים בדיוק
    if (_hasChecked &&
        effectivePhone == _lastCheckedPhone &&
        effectiveEmail == _lastCheckedEmail) {
      return;
    }

    final currentGeneration = ++_checkGeneration;

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      final invites = await _repository.findPendingInvites(
        phone: effectivePhone,
        email: effectiveEmail,
      );

      // 🔒 בדיקה: אם logout/clear קרה בזמן ה-await - מתעלמים מהתוצאות
      if (currentGeneration != _checkGeneration || _isDisposed) {
        return;
      }

      _pendingInvites = invites;
      _hasChecked = true;
      // 🔒 שמור את ה-inputs לבדיקה הבאה
      _lastCheckedPhone = effectivePhone;
      _lastCheckedEmail = effectiveEmail;

      if (kDebugMode) {
        debugPrint('✅ PendingInvitesProvider: Found ${_pendingInvites.length} pending invites');
      }
    } catch (e) {
      // 🔒 בדיקה גם ב-catch
      if (currentGeneration != _checkGeneration || _isDisposed) {
        return;
      }

      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.checkPendingInvites: $e');
      }
      _errorMessage = 'שגיאה בבדיקת הזמנות';
      _pendingInvites = [];
    }

    // 🔒 בדיקה לפני notify סופי
    if (currentGeneration != _checkGeneration || _isDisposed) {
      return;
    }

    _isLoading = false;
    _notifySafe();
  }

  /// אישור הזמנה והצטרפות לקבוצה
  Future<bool> acceptInvite({
    required GroupInvite invite,
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatar,
  }) async {
    final gen = _checkGeneration;

    try {
      await _repository.acceptInviteAndJoinGroup(
        invite: invite,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userAvatar: userAvatar,
      );

      // 🔒 בדיקה: אם logout/clear קרה בזמן ה-await - מתעלמים
      if (gen != _checkGeneration || _isDisposed) {
        return false;
      }

      // הסר מהרשימה המקומית
      _pendingInvites = _pendingInvites.where((i) => i.id != invite.id).toList();
      _notifySafe();

      return true;
    } catch (e) {
      // 🔒 בדיקה גם ב-catch
      if (gen != _checkGeneration || _isDisposed) {
        return false;
      }

      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.acceptInvite: $e');
      }
      _errorMessage = 'שגיאה באישור ההזמנה';
      _notifySafe();
      return false;
    }
  }

  /// דחיית הזמנה
  ///
  /// [rejectorName] - שם הדוחה (לשליחת התראה למזמין)
  /// [senderId] - מזהה הדוחה (נדרש ל-Firestore rules)
  /// [notificationsService] - שירות התראות לשליחת התראה למזמין
  /// [householdId] - מזהה משק בית (נדרש להתראה)
  Future<bool> rejectInvite(
    GroupInvite invite, {
    String? rejectorName,
    String? senderId,
    NotificationsService? notificationsService,
    String? householdId,
  }) async {
    final gen = _checkGeneration;

    try {
      await _repository.rejectInvite(invite.id);

      // 🔒 בדיקה: אם logout/clear קרה בזמן ה-await - מתעלמים
      if (gen != _checkGeneration || _isDisposed) {
        return false;
      }

      // הסר מהרשימה המקומית
      _pendingInvites = _pendingInvites.where((i) => i.id != invite.id).toList();
      _notifySafe();

      // 🆕 שליחת התראה למזמין (non-critical)
      if (notificationsService != null &&
          rejectorName != null &&
          senderId != null &&
          householdId != null) {
        try {
          await notificationsService.createGroupInviteRejectedNotification(
            userId: invite.invitedBy, // המזמין מקבל התראה
            householdId: householdId,
            groupId: invite.groupId,
            groupName: invite.groupName,
            rejectorName: rejectorName,
            senderId: senderId, // 🔒 נדרש ל-Firestore rules
          );
          if (kDebugMode) {
            debugPrint('📬 PendingInvitesProvider: Sent rejection notification to ${invite.invitedBy}');
          }
        } catch (e) {
          // Non-critical - continue anyway
          if (kDebugMode) {
            debugPrint('⚠️ PendingInvitesProvider: Failed to send rejection notification: $e');
          }
        }
      }

      return true;
    } catch (e) {
      // 🔒 בדיקה גם ב-catch
      if (gen != _checkGeneration || _isDisposed) {
        return false;
      }

      if (kDebugMode) {
        debugPrint('❌ PendingInvitesProvider.rejectInvite: $e');
      }
      _errorMessage = 'שגיאה בדחיית ההזמנה';
      _notifySafe();
      return false;
    }
  }

  /// ניקוי הרשימה (בהתנתקות)
  void clear() {
    _pendingInvites = [];
    _hasChecked = false;
    _errorMessage = null;
    _isLoading = false;
    // 🔒 איפוס inputs אחרונים
    _lastCheckedPhone = null;
    _lastCheckedEmail = null;
    // 🔒 ביטול קריאות תלויות
    _checkGeneration++;
    _notifySafe();
  }

  /// רענון הזמנות
  Future<void> refresh({String? phone, String? email}) async {
    _hasChecked = false;
    await checkPendingInvites(phone: phone, email: email);
  }

  // === Lifecycle ===

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
