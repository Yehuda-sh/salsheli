// 📄 File: lib/providers/receipt_provider.dart
//
// 🎯 Purpose: Provider לניהול קבלות - ניהול state מרכזי של כל הקבלות באפליקציה
//
// 📦 Dependencies:
// - ReceiptRepository: ממשק לטעינת/שמירת קבלות
// - UserContext: household_id + auth state
//
// ✨ Features:
// - 📥 טעינה אוטומטית: מאזין ל-UserContext ומריענן כשמשתמש משתנה
// - ✏️ CRUD מלא: יצירה, עדכון, מחיקה של קבלות
// - 📊 State management: isLoading, hasError, isEmpty
// - 🔄 Auto-sync: רענון אוטומטי כשמשתמש מתחבר/מתנתק
// - 🛡️ Dispose-safe: _isDisposed guard + _notifySafe() prevents post-dispose crash
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<ReceiptProvider>();
// final receipts = provider.receipts;
//
// // ביצירת קבלה:
// final receipt = await context.read<ReceiptProvider>().createReceipt(
//   storeName: 'שופרסל',
//   date: DateTime.now(),
//   items: [item1, item2],
// );
//
// // בעדכון:
// await context.read<ReceiptProvider>().updateReceipt(updatedReceipt);
//
// // במחיקה:
// await context.read<ReceiptProvider>().deleteReceipt(receiptId);
// ```
//
// 🔄 State Flow:
// 1. Constructor → updateUserContext() → _initialize()
// 2. UserContext changes → _onUserChanged() → _loadReceipts()
// 3. CRUD operations → Repository → Update local state → notifyListeners()
//
// Version: 3.3 (_isDisposed guard + _notifySafe)
// Last Updated: 24/03/2026
//

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/receipt.dart';
import '../repositories/receipt_repository.dart';
import 'user_context.dart';

class ReceiptProvider with ChangeNotifier {
  final ReceiptRepository _repository;
  UserContext? _userContext;
  bool _listening = false;
  bool _hasInitialized = false; // מניעת אתחול כפול
  bool _isDisposed = false; // v4.3: מניעת notifyListeners אחרי dispose

  /// מדיניות שמירה: קבלות ישנות מ-365 ימים נמחקות בטעינה
  static const _retentionDays = 365;

  bool _isLoading = false;
  String? _errorMessage;
  List<Receipt> _receipts = [];

  /// v4.3: שליחת notifyListeners בטוחה — לא קורסת אחרי dispose
  void _notifySafe() {
    if (!_isDisposed) notifyListeners();
  }

  ReceiptProvider({
    required UserContext userContext,
    required ReceiptRepository repository,
  }) : _repository = repository {
    updateUserContext(userContext);
  }

  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _receipts.isEmpty;
  List<Receipt> get receipts => List.unmodifiable(_receipts);

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    if (kDebugMode) debugPrint('🔄 ReceiptProvider.updateUserContext');

    // מניעת update כפול של אותו context
    if (_userContext == newContext) {
      if (kDebugMode) debugPrint('   ⏭️ אותו UserContext, מדלג');
      return;
    }

    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;

    // אתחול רק בפעם הראשונה
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initialize();
    }
  }

  void _onUserChanged() {
    if (kDebugMode) debugPrint('👤 ReceiptProvider._onUserChanged');
    _loadReceipts();
  }

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      _loadReceipts();
    } else {
      _receipts = [];
      _notifySafe();
    }
  }

  Future<void> _loadReceipts() async {
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _receipts = [];
      _isLoading = false;
      _notifySafe();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notifySafe();

    try {
      final allReceipts = await _repository.fetchReceipts(householdId);

      // 🗓️ מדיניות שמירה: מחיקת קבלות ישנות מעל שנה
      final cutoff = DateTime.now().subtract(const Duration(days: _retentionDays));
      final old = allReceipts.where((r) => r.date.isBefore(cutoff)).toList();

      if (old.isNotEmpty) {
        _receipts = allReceipts.where((r) => !r.date.isBefore(cutoff)).toList();
        if (kDebugMode) debugPrint('🗑️ ReceiptProvider: מוחק ${old.length} קבלות ישנות (מעל שנה)');
        // מחיקה מ-Firebase ברקע — לא חוסם את ה-UI
        for (final r in old) {
          unawaited(
            _repository.deleteReceipt(id: r.id, householdId: householdId).catchError((e) {
              if (kDebugMode) debugPrint('⚠️ ReceiptProvider: שגיאה במחיקת קבלה ישנה ${r.id}: $e');
            }),
          );
        }
      } else {
        _receipts = allReceipts;
      }

      if (kDebugMode) debugPrint('📥 ReceiptProvider: ${_receipts.length} קבלות (${old.length} ישנות נמחקו)');

    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת קבלות: $e";
      _isLoading = false;
      if (kDebugMode) {
        debugPrintStack(label: 'ReceiptProvider._loadReceipts', stackTrace: st);
      }
      _notifySafe();
      return;
    }

    _isLoading = false;
    _notifySafe();
  }

  /// טוען את כל הקבלות מחדש מה-Repository
  /// 
  /// Example:
  /// ```dart
  /// await receiptProvider.loadReceipts();
  /// ```
  Future<void> loadReceipts() {
    if (kDebugMode) debugPrint('🔄 ReceiptProvider.loadReceipts: רענון ידני');
    return _loadReceipts();
  }

  /// מנסה לטעון שוב אחרי שגיאה
  /// 
  /// Example:
  /// ```dart
  /// // ב-UI:
  /// if (provider.hasError) {
  ///   ElevatedButton(
  ///     onPressed: () => provider.retry(),
  ///     child: Text('נסה שוב'),
  ///   );
  /// }
  /// ```
  Future<void> retry() async {
    if (kDebugMode) debugPrint('🔄 ReceiptProvider.retry');
    _errorMessage = null;
    await _loadReceipts();
  }

  /// מנקה את כל ה-state (שימושי בהתנתקות)
  /// 
  /// Example:
  /// ```dart
  /// await authService.logout();
  /// receiptProvider.clearAll();
  /// ```
  void clearAll() {
    if (kDebugMode) debugPrint('🧹 ReceiptProvider.clearAll');
    _receipts = [];
    _errorMessage = null;
    _isLoading = false;
    _notifySafe();
  }

  /// בודק אם קבלה עם אותו קישור כבר קיימת
  /// 
  /// מחזיר true אם נמצאה קבלה עם אותו originalUrl.
  /// 
  /// Example:
  /// ```dart
  /// final isDuplicate = await receiptProvider.checkDuplicateByUrl(url);
  /// if (isDuplicate) {
  ///   print('קבלה זו כבר קיימת!');
  /// }
  /// ```
  Future<bool> checkDuplicateByUrl(String originalUrl) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return false;

    try {
      // בדיקה local קודם (מהיר)
      final localMatch = _receipts.any((r) => r.originalUrl == originalUrl);
      if (localMatch) return true;

      // אם לא נמצא local - בודק ב-Repository (לבטח)
      final allReceipts = await _repository.fetchReceipts(householdId);
      return allReceipts.any((r) => r.originalUrl == originalUrl);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ReceiptProvider.checkDuplicateByUrl: $e');
      return false; // במקרה של שגיאה - ממשיכים
    }
  }

  /// יוצר קבלה חדשה ומוסיף לרשימה
  /// 
  /// Example:
  /// ```dart
  /// final receipt = await receiptProvider.createReceipt(
  ///   storeName: 'שופרסל',
  ///   date: DateTime.now(),
  ///   items: [item1, item2],
  ///   originalUrl: 'https://...',  // אופציונלי
  ///   fileUrl: 'https://...',      // אופציונלי
  /// );
  /// ```
  Future<Receipt> createReceipt({
    required String storeName,
    required DateTime date,
    List<ReceiptItem> items = const [],
    String? originalUrl,
    String? fileUrl,
  }) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception("❌ householdId לא נמצא");
    }

    try {
      // בדיקת כפילות לפי URL
      if (originalUrl != null && originalUrl.isNotEmpty) {
        final isDuplicate = await checkDuplicateByUrl(originalUrl);
        if (isDuplicate) {
          throw Exception('קבלה זו כבר קיימת במערכת');
        }
      }

      final totalAmount = items.fold(0.0, (sum, it) => sum + it.totalPrice);

      final newReceipt = Receipt.newReceipt(
        storeName: storeName,
        date: date,
        householdId: householdId,
        items: items,
        totalAmount: totalAmount,
        originalUrl: originalUrl,
        fileUrl: fileUrl,
      );

      final saved = await _repository.saveReceipt(receipt: newReceipt, householdId: householdId);
      if (kDebugMode) debugPrint('✅ ReceiptProvider.createReceipt: ${saved.id}');

      // אופטימיזציה: הוספה local במקום ריענון מלא
      _receipts.add(saved);
      _notifySafe();

      return saved;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ReceiptProvider.createReceipt: $e');
      _errorMessage = 'שגיאה ביצירת קבלה';
      _notifySafe();
      rethrow;
    }
  }

  /// מעדכן קבלה קיימת
  /// 
  /// Example:
  /// ```dart
  /// final updatedReceipt = receipt.copyWith(storeName: 'חנות חדשה');
  /// await receiptProvider.updateReceipt(updatedReceipt);
  /// ```
  Future<void> updateReceipt(Receipt receipt) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    try {
      final updated = await _repository.saveReceipt(receipt: receipt, householdId: householdId);

      // אופטימיזציה: עדכון local במקום ריענון מלא
      final index = _receipts.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _receipts[index] = updated;
        _notifySafe();
      } else {
        await _loadReceipts();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ReceiptProvider.updateReceipt: $e');
      _errorMessage = 'שגיאה בעדכון קבלה';
      _notifySafe();
      rethrow;
    }
  }

  /// מחיק קבלה
  /// 
  /// Example:
  /// ```dart
  /// await receiptProvider.deleteReceipt(receipt.id);
  /// ```
  Future<void> deleteReceipt(String receiptId) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    try {
      await _repository.deleteReceipt(id: receiptId, householdId: householdId);

      // אופטימיזציה: מחיקה local במקום ריענון מלא
      _receipts.removeWhere((r) => r.id == receiptId);
      _notifySafe();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ReceiptProvider.deleteReceipt: $e');
      _errorMessage = 'שגיאה במחיקת קבלה';
      _notifySafe();
      rethrow;
    }
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
