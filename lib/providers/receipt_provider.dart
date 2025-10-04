// 📄 File: lib/providers/receipt_provider.dart
//
// 🇮🇱 מנהל את הקבלות (Receipts) של המשתמש:
//     - טוען קבלות ממקור נתונים (כרגע Mock, בעתיד Firebase/API).
//     - יוצר/מעדכן/מוחק קבלות.
//     - שומר מצב טעינה ושגיאות.
//     - מסתנכרן עם UserContext.
//
// 💡 רעיונות עתידיים:
//     - סנכרון בזמן אמת מול Firebase.
//     - שמירה לוקאלית ב-Hive/SQLite כדי לשחזר אחרי סגירה.
//     - חיפוש וסינון קבלות לפי חנות/תאריך.
//
// 🇬🇧 Manages user receipts:
//     - Loads receipts from repository (currently Mock, future Firebase/API).
//     - Creates/updates/deletes receipts.
//     - Tracks loading/error state.
//     - Observes UserContext.
//
// 💡 Future ideas:
//     - Real-time sync with Firebase.
//     - Local persistence (Hive/SQLite).
//     - Search & filter by store/date.
//

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
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

  static final Uuid _uuid = Uuid();

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

  void updateUserContext(UserContext newContext) {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    _initialize();
  }

  void _onUserChanged() => _loadReceipts();

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      _loadReceipts();
    } else {
      _receipts = [];
      notifyListeners();
    }
  }

  Future<void> _loadReceipts() async {
    if (_userContext?.isLoggedIn != true) {
      _receipts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final householdId = _userContext!.user!.householdId;
      _receipts = await _repository.fetchReceipts(householdId);
    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת קבלות: $e";
      debugPrintStack(label: 'ReceiptProvider._loadReceipts', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadReceipts() => _loadReceipts();

  Future<Receipt> createReceipt({
    required String storeName,
    required DateTime date,
    List<ReceiptItem> items = const [],
  }) async {
    final newReceipt = Receipt.newReceipt(
      storeName: storeName,
      date: date,
      items: items,
      totalAmount: items.fold(0, (sum, it) => sum + it.totalPrice),
    );

    final householdId = _userContext!.user!.householdId;
    final saved = await _repository.saveReceipt(newReceipt, householdId);

    _receipts.add(saved);
    notifyListeners();
    return saved;
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final householdId = _userContext!.user!.householdId;
    final updated = await _repository.saveReceipt(receipt, householdId);

    final index = _receipts.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _receipts[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    final householdId = _userContext!.user!.householdId;
    await _repository.deleteReceipt(receiptId, householdId);

    _receipts.removeWhere((r) => r.id == receiptId);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
