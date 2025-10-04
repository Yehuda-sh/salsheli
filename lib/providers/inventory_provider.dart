// 📄 File: lib/providers/inventory_provider.dart
//
// 🇮🇱 מנהל את פריטי המלאי (Inventory) עם טעינה בטוחה וסנכרון אוטומטי.
// 🇬🇧 Manages inventory items with safe loading and auto-sync.
//

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import 'user_context.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repository;
  UserContext? _userContext;
  bool _listening = false;

  bool _isLoading = false;
  String? _errorMessage;
  List<InventoryItem> _items = [];

  static final Uuid _uuid = Uuid();
  Future<void>? _loadingFuture; // מניעת טעינות כפולות

  InventoryProvider({
    required InventoryRepository repository,
    required UserContext userContext,
  }) : _repository = repository {
    updateUserContext(userContext);
  }

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  List<InventoryItem> get items => List.unmodifiable(_items);

  /// === חיבור UserContext ===
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

  void _onUserChanged() => _loadItems();

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      _loadItems();
    } else {
      _items = [];
      notifyListeners();
    }
  }

  /// === טעינת פריטים ===
  Future<void> _loadItems() {
    if (_loadingFuture != null) return _loadingFuture!;
    _loadingFuture = _doLoad().whenComplete(() => _loadingFuture = null);
    return _loadingFuture!;
  }

  Future<void> _doLoad() async {
    final householdId = _userContext?.user?.householdId;
    if (_userContext?.isLoggedIn != true || householdId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchItems(householdId);
    } catch (e, st) {
      _errorMessage = "שגיאה בטעינת מלאי: $e";
      debugPrintStack(label: 'InventoryProvider._doLoad', stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadItems() => _loadItems();

  /// === יצירה/עדכון/מחיקה ===
  Future<InventoryItem> createItem({
    required String productName,
    required String category,
    required String location,
    int quantity = 1,
    String unit = "יח'",
  }) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      throw Exception("❌ householdId לא נמצא");
    }

    final newItem = InventoryItem(
      id: _uuid.v4(),
      productName: productName,
      category: category,
      location: location,
      quantity: quantity,
      unit: unit,
    );

    await _repository.saveItem(newItem, householdId);
    await _loadItems(); // ריענון מלא
    return newItem;
  }

  Future<void> updateItem(InventoryItem item) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    await _repository.saveItem(item, householdId);
    await _loadItems(); // ריענון מלא
  }

  Future<void> deleteItem(String id) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return;

    await _repository.deleteItem(id, householdId);
    await _loadItems(); // ריענון מלא
  }

  /// === פילטרים נוחים ===
  List<InventoryItem> itemsByCategory(String category) =>
      _items.where((i) => i.category == category).toList();

  List<InventoryItem> itemsByLocation(String location) =>
      _items.where((i) => i.location == location).toList();

  @override
  void dispose() {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
