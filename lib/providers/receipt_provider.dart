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
// Version: 2.0 (עם logging מלא + תיעוד מקיף)
// Last Updated: 06/10/2025
//

import 'package:flutter/foundation.dart';
import '../models/receipt.dart';
import '../repositories/receipt_repository.dart';
import 'user_context.dart';

class ReceiptProvider with ChangeNotifier {
  final ReceiptRepository _repository;
  UserContext? _userContext;
  bool _listening = false;

  bool _isLoading = false;
  String? _errorMessage;
  List<Receipt> _receipts = [];

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
    debugPrint('🔄 ReceiptProvider.updateUserContext');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
      debugPrint('   ✅ Listener הוסר מ-UserContext הקודם');
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    debugPrint('   ✅ Listener הוסף, מתחיל initialization');
    _initialize();
  }

  void _onUserChanged() {
    debugPrint('👤 ReceiptProvider._onUserChanged: משתמש השתנה');
    _loadReceipts();
  }

  void _initialize() {
    debugPrint('🔧 ReceiptProvider._initialize');
    
    if (_userContext?.isLoggedIn == true) {
      debugPrint('   ✅ משתמש מחובר, טוען קבלות');
      _loadReceipts();
    } else {
      debugPrint('   ⚠️ משתמש לא מחובר, מנקה רשימה');
      _receipts = [];
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (user not logged in)');
    }
  }

  Future<void> _loadReceipts() async {
    debugPrint('📥 ReceiptProvider._loadReceipts: מתחיל טעינה');
    
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      debugPrint('   ⚠️ אין household_id, מנקה רשימה');
      _receipts = [];
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (no household_id)');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('   🔔 ReceiptProvider: notifyListeners() (isLoading=true)');

    try {
      _receipts = await _repository.fetchReceipts(householdId);
      debugPrint('✅ ReceiptProvider._loadReceipts: נטענו ${_receipts.length} קבלות');
    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת קבלות: $e";
      debugPrint('❌ ReceiptProvider._loadReceipts: שגיאה - $e');
      debugPrintStack(label: 'ReceiptProvider._loadReceipts', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('   🔔 ReceiptProvider: notifyListeners() (isLoading=false, receipts=${_receipts.length})');
  }

  /// טוען את כל הקבלות מחדש מה-Repository
  /// 
  /// Example:
  /// ```dart
  /// await receiptProvider.loadReceipts();
  /// ```
  Future<void> loadReceipts() {
    debugPrint('🔄 ReceiptProvider.loadReceipts: רענון ידני');
    return _loadReceipts();
  }

  /// יוצר קבלה חדשה ומוסיף לרשימה
  /// 
  /// Example:
  /// ```dart
  /// final receipt = await receiptProvider.createReceipt(
  ///   storeName: 'שופרסל',
  ///   date: DateTime.now(),
  ///   items: [item1, item2],
  /// );
  /// ```
  Future<Receipt> createReceipt({
    required String storeName,
    required DateTime date,
    List<ReceiptItem> items = const [],
  }) async {
    debugPrint('➕ ReceiptProvider.createReceipt');
    debugPrint('   חנות: $storeName, תאריך: $date, פריטים: ${items.length}');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('❌ householdId לא נמצא');
      throw Exception("❌ householdId לא נמצא");
    }

    try {
      final totalAmount = items.fold(0.0, (sum, it) => sum + it.totalPrice);
      debugPrint('   💰 סכום כולל: ₪${totalAmount.toStringAsFixed(2)}');
      
      final newReceipt = Receipt.newReceipt(
        storeName: storeName,
        date: date,
        items: items,
        totalAmount: totalAmount,
      );

      final saved = await _repository.saveReceipt(newReceipt, householdId);
      debugPrint('✅ קבלה נשמרה ב-Repository: ${saved.id}');
      
      // אופטימיזציה: הוספה local במקום ריענון מלא
      _receipts.add(saved);
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (receipt created: ${saved.id})');
      
      return saved;
    } catch (e) {
      debugPrint('❌ ReceiptProvider.createReceipt: שגיאה - $e');
      _errorMessage = 'שגיאה ביצירת קבלה';
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (error)');
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
    debugPrint('✏️ ReceiptProvider.updateReceipt: ${receipt.id}');
    debugPrint('   חנות: ${receipt.storeName}, פריטים: ${receipt.items.length}');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ householdId לא נמצא, מדלג');
      return;
    }

    try {
      final updated = await _repository.saveReceipt(receipt, householdId);
      debugPrint('✅ קבלה עודכנה ב-Repository');
      
      // אופטימיזציה: עדכון local במקום ריענון מלא
      final index = _receipts.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _receipts[index] = updated;
        notifyListeners();
        debugPrint('   🔔 ReceiptProvider: notifyListeners() (receipt updated: ${updated.id})');
      } else {
        debugPrint('⚠️ קבלה לא נמצאה ברשימה, מבצע ריענון מלא');
        await _loadReceipts();
      }
    } catch (e) {
      debugPrint('❌ ReceiptProvider.updateReceipt: שגיאה - $e');
      _errorMessage = 'שגיאה בעדכון קבלה';
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (error)');
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
    debugPrint('🗑️ ReceiptProvider.deleteReceipt: $receiptId');
    
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ householdId לא נמצא, מדלג');
      return;
    }

    try {
      await _repository.deleteReceipt(receiptId, householdId);
      debugPrint('✅ קבלה נמחקה מ-Repository');
      
      // אופטימיזציה: מחיקה local במקום ריענון מלא
      _receipts.removeWhere((r) => r.id == receiptId);
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (receipt deleted: $receiptId)');
    } catch (e) {
      debugPrint('❌ ReceiptProvider.deleteReceipt: שגיאה - $e');
      _errorMessage = 'שגיאה במחיקת קבלה';
      notifyListeners();
      debugPrint('   🔔 ReceiptProvider: notifyListeners() (error)');
      rethrow;
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 ReceiptProvider.dispose');
    
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      debugPrint('   ✅ Listener הוסר');
    }
    
    super.dispose();
  }
}
