// 📄 File: lib/providers/activity_log_provider.dart
//
// Provider ליומן פעילות הבית — טוען ומנהל אירועים.
// עוקב אחרי אותו pattern של ReceiptProvider:
//   - מאזין ל-UserContext
//   - טעינה אוטומטית בהתחברות
//   - dispose-safe
//
// Version: 1.0
// Last Updated: 07/04/2026

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/activity_event.dart';
import '../repositories/activity_log_repository.dart';
import 'user_context.dart';

class ActivityLogProvider with ChangeNotifier {
  final ActivityLogRepository _repository;
  UserContext? _userContext;
  bool _listening = false;
  bool _hasInitialized = false;
  bool _isDisposed = false;

  /// retention: אירועים ישנים מ-90 יום נמחקים בטעינה
  static const _retentionDays = 90;

  bool _isLoading = false;
  String? _errorMessage;
  List<ActivityEvent> _events = [];

  void _notifySafe() {
    if (!_isDisposed) notifyListeners();
  }

  ActivityLogProvider({
    required UserContext userContext,
    required ActivityLogRepository repository,
  }) : _repository = repository {
    updateUserContext(userContext);
  }

  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _events.isEmpty;
  List<ActivityEvent> get events => List.unmodifiable(_events);

  void updateUserContext(UserContext newContext) {
    if (_userContext == newContext) return;

    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    if (!_hasInitialized) {
      _hasInitialized = true;
      _initialize();
    }
  }

  void _onUserChanged() {
    _loadEvents();
  }

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      _loadEvents();
    } else {
      _events = [];
      _notifySafe();
    }
  }

  Future<void> _loadEvents() async {
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _events = [];
      _isLoading = false;
      _notifySafe();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      _events = await _repository.fetchEvents(householdId);

      // ניקוי אירועים ישנים ברקע
      unawaited(
        _repository.deleteOldEvents(householdId, days: _retentionDays),
      );
    } catch (e) {
      _errorMessage = 'load_activity_failed';
      if (kDebugMode) debugPrint('❌ ActivityLogProvider._loadEvents: $e');
    }

    _isLoading = false;
    _notifySafe();
  }

  /// רענון ידני
  Future<void> loadEvents() => _loadEvents();

  /// ניסיון חוזר
  Future<void> retry() {
    _errorMessage = null;
    return _loadEvents();
  }

  void clearAll() {
    _events = [];
    _errorMessage = null;
    _isLoading = false;
    _notifySafe();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
