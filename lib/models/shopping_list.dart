// 📄 File: lib/models/shopping_list.dart
//
// 🇮🇱 מודל רשימת קניות:
//     - מייצג רשימת קניות עם פריטים, תקציב, וסטטוס.
//     - תומך בשיתוף בין משתמשים במשק בית.
//     - כולל סוגי רשימות: סופרמרקט, בית מרקחת, אחר.
//     - מחשב אוטומטית התקדמות, סכומים, וחריגה מתקציב.
//     - נתמך ע"י JSON לצורך סנכרון עם Firebase Firestore.
//
// 🔥 Firebase Integration:
//     - household_id מנוהל ע"י Repository (לא חלק מהמודל)
//     - כל רשימה שייכת למשק בית אחד
//     - Repository מוסיף את household_id בזמן שמירה
//     - Repository מסנן לפי household_id בזמן טעינה
//

//
// 🇬🇧 Shopping list model:
//     - Represents a shopping list with items, budget, and status.
//     - Supports sharing between household members.
//     - Includes list types: supermarket, pharmacy, other.
//     - Auto-calculates progress, totals, and budget overruns.
//     - Supports JSON for server sync and local storage.
//

//

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'receipt.dart';
import 'unified_list_item.dart';
import 'enums/item_type.dart';
import 'timestamp_converter.dart';
import 'active_shopper.dart';

part 'shopping_list.g.dart';

// Sentinel value for detecting when nullable fields should be explicitly set to null
const _sentinel = Object();

/// 🇮🇱 מודל רשימת קניות
/// 🇬🇧 Shopping list model
@immutable
@JsonSerializable(explicitToJson: true)
class ShoppingList {
  /// 🇮🇱 מזהה ייחודי לרשימה
  /// 🇬🇧 Unique list identifier
  final String id;

  /// 🇮🇱 שם הרשימה (למשל "סופר יומי")
  /// 🇬🇧 List name (e.g., "Daily Supermarket")
  final String name;

  /// 🇮🇱 מתי עודכנה הרשימה לאחרונה
  /// 🇬🇧 Last update date
  @TimestampConverter()
  @JsonKey(name: 'updated_date')
  final DateTime updatedDate;

  /// 🇮🇱 מתי נוצרה הרשימה
  /// 🇬🇧 Creation date
  @TimestampConverter()
  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  /// 🇮🇱 סטטוס הרשימה: "active" | "completed" | "archived"
  /// 🇬🇧 List status: "active" | "completed" | "archived"
  @JsonKey(defaultValue: 'active')
  final String status;

  /// 🇮🇱 סוג הרשימה: "super" | "pharmacy" | "other"
  /// 🇬🇧 List type: "super" | "pharmacy" | "other"
  @JsonKey(defaultValue: 'super')
  final String type;

  /// 🇮🇱 תקציב משוער (אופציונלי, ₪)
  /// 🇬🇧 Estimated budget (optional, ₪)
  final double? budget;

  /// 🇮🇱 האם הרשימה משותפת עם משתמשים נוספים
  /// 🇬🇧 Is the list shared with other users
  @JsonKey(name: 'is_shared', defaultValue: false)
  final bool isShared;

  /// 🇮🇱 מזהה המשתמש שיצר את הרשימה
  /// 🇬🇧 User ID who created the list
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 🇮🇱 מזהי משתמשים איתם הרשימה שותפה
  /// 🇬🇧 User IDs with whom the list is shared
  @JsonKey(name: 'shared_with', defaultValue: [])
  final List<String> sharedWith;

  /// 🇮🇱 תאריך אירוע מתוכנן (אופציונלי) - למשל יום הולדת, אירוח
  /// 🇬🇧 Planned event date (optional) - e.g., birthday, hosting
  @TimestampConverter()
  @JsonKey(name: 'event_date')
  final DateTime? eventDate;

  /// 🇮🇱 תאריך יעד לסיום הקניות (אופציונלי) - דד-ליין
  /// 🇬🇧 Target date for completing the shopping (optional) - deadline
  @TimestampConverter()
  @JsonKey(name: 'target_date')
  final DateTime? targetDate;

  /// 🇮🇱 פריטי הקניות ברשימה (מוצרים + משימות)
  /// 🇬🇧 Shopping items in the list (products + tasks)
  final List<UnifiedListItem> items;

  /// 🆕 מזהה התבנית ממנה נוצרה הרשימה (null אם ידנית)
  /// 🇬🇧 Template ID from which the list was created (null if manual)
  @JsonKey(name: 'template_id')
  final String? templateId;

  /// 🆕 פורמט הרשימה: "shared" | "assigned" | "personal"
  /// 🇬🇧 List format: "shared" | "assigned" | "personal"
  @JsonKey(defaultValue: 'shared')
  final String format;

  /// 🆕 האם נוצרה מתבנית
  /// 🇬🇧 Whether the list was created from a template
  @JsonKey(name: 'created_from_template', defaultValue: false)
  final bool createdFromTemplate;

  /// 🆕 רשימת קונים פעילים (תמיכה בקנייה משותפת)
  /// 🇬🇧 List of active shoppers (collaborative shopping support)
  @JsonKey(name: 'active_shoppers', defaultValue: [])
  final List<ActiveShopper> activeShoppers;

  // ---- Shopping timeout ----
  static const Duration shoppingTimeout = Duration(hours: 6);

  // ---- Status constants ----
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';
  static const String statusCompleted = 'completed';

  // ---- Type constants ----
  static const String typeSuper = 'super';
  static const String typePharmacy = 'pharmacy';
  static const String typeOther = 'other';

  // ---- Active Shopping Getters ----

  /// 🇮🇱 האם יש קנייה פעילה
  /// 🇬🇧 Is there an active shopping session
  bool get isBeingShopped => activeShoppers.any((s) => s.isActive);

  /// 🇮🇱 האם יש קונים פעילים
  /// 🇬🇧 Are there active shoppers
  bool get hasActiveShoppers => activeShoppers.isNotEmpty;

  /// 🇮🇱 מי התחיל את הקנייה (ה-Starter)
  /// 🇬🇧 Who started the shopping (the Starter)
  ActiveShopper? get starter {
    try {
      return activeShoppers.firstWhere((s) => s.isStarter);
    } catch (_) {
      return null;
    }
  }

  /// 🇮🇱 רשימת קונים פעילים כרגע
  /// 🇬🇧 List of currently active shoppers
  List<ActiveShopper> get currentShoppers =>
      activeShoppers.where((s) => s.isActive).toList();

  /// 🇮🇱 כמות קונים פעילים
  /// 🇬🇧 Number of active shoppers
  int get activeShopperCount => currentShoppers.length;

  /// 🇮🇱 האם המשתמש הזה קונה כרגע
  /// 🇬🇧 Is this user currently shopping
  bool isUserShopping(String userId) =>
      currentShoppers.any((s) => s.userId == userId);

  /// 🇮🇱 האם המשתמש יכול לסיים קנייה (רק ה-Starter)
  /// 🇬🇧 Can this user finish shopping (only the Starter)
  bool canUserFinish(String userId) {
    final s = starter;
    return s != null && s.userId == userId && s.isActive;
  }

  /// 🇮🇱 האם הקנייה הקפיאה (timeout)
  /// 🇬🇧 Is the shopping session timed out
  bool get isShoppingTimedOut {
    if (!isBeingShopped) return false;

    try {
      final oldest = currentShoppers
          .map((s) => s.joinedAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      return DateTime.now().difference(oldest) > shoppingTimeout;
    } catch (_) {
      return false;
    }
  }

  // ---- Unified Items Helpers ----

  /// 🇮🇱 רק מוצרים (ללא משימות)
  /// 🇬🇧 Only products (no tasks)
  List<UnifiedListItem> get products =>
      items.where((item) => item.type == ItemType.product).toList();

  /// 🇮🇱 רק משימות (ללא מוצרים)
  /// 🇬🇧 Only tasks (no products)
  List<UnifiedListItem> get tasks =>
      items.where((item) => item.type == ItemType.task).toList();

  /// 🇮🇱 כמות מוצרים
  /// 🇬🇧 Product count
  int get productCount => products.length;

  /// 🇮🇱 כמות משימות
  /// 🇬🇧 Task count
  int get taskCount => tasks.length;

  /// 🇮🇱 סכום מחיר כולל של מוצרים
  /// 🇬🇧 Total price of all products
  double get totalAmount {
    return products.fold(
      0.0,
      (sum, item) => sum + (item.totalPrice ?? 0.0),
    );
  }

  /// Constructor
  ShoppingList({
    required this.id,
    required this.name,
    required this.updatedDate,
    DateTime? createdDate,
    required this.status,
    required this.type,
    this.budget,
    this.eventDate,
    this.targetDate,
    required this.isShared,
    required this.createdBy,
    required List<String> sharedWith,
    required List<UnifiedListItem> items,
    this.templateId,
    required this.format,
    required this.createdFromTemplate,
    List<ActiveShopper> activeShoppers = const [],
  })  : createdDate = createdDate ?? updatedDate,
        sharedWith = List<String>.unmodifiable(sharedWith),
        items = List<ReceiptItem>.unmodifiable(items),
        activeShoppers = List<ActiveShopper>.unmodifiable(activeShoppers);

  // ---- Factory Constructors ----

  /// 🇮🇱 יצירת רשימה חדשה בקלות
  /// 🇬🇧 Easily create a new list
  factory ShoppingList.newList({
    required String id,
    required String name,
    required String createdBy,
    String type = typeSuper,
    double? budget,
    DateTime? eventDate,
    DateTime? targetDate,
    bool isShared = false,
    List<String> sharedWith = const [],
    List<UnifiedListItem> items = const [],
    String? templateId,
    String format = 'shared',
    bool createdFromTemplate = false,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ShoppingList(
      id: id,
      name: name,
      createdBy: createdBy,
      type: type,
      budget: budget,
      eventDate: eventDate,
      targetDate: targetDate,
      isShared: isShared,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<ReceiptItem>.unmodifiable(items),
      templateId: templateId,
      format: format,
      createdFromTemplate: createdFromTemplate,
      updatedDate: timestamp,
      createdDate: timestamp,
      status: statusActive,
    );
  }

  /// 🇮🇱 יצירת רשימה מתבנית
  /// 🇬🇧 Create a list from a template
  factory ShoppingList.fromTemplate({
    required String id,
    required String templateId,
    required String name,
    required String createdBy,
    required String type,
    required String format,
    required List<UnifiedListItem> items,
    double? budget,
    DateTime? eventDate,
    DateTime? targetDate,
    bool isShared = false,
    List<String> sharedWith = const [],
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ShoppingList(
      id: id,
      name: name,
      createdBy: createdBy,
      type: type,
      format: format,
      budget: budget,
      eventDate: eventDate,
      targetDate: targetDate,
      isShared: isShared,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<ReceiptItem>.unmodifiable(items),
      templateId: templateId,
      createdFromTemplate: true,
      updatedDate: timestamp,
      createdDate: timestamp,
      status: statusActive,
    );
  }

  // ---- Copy & Update ----

  /// 🇮🇱 יצירת עותק עם שינויים
  /// 🇬🇧 Create a copy with updates
  /// 
  /// Note: To nullify optional fields, use Object as the parameter type.
  /// Example: copyWith(budget: null) will clear the budget field.
  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? updatedDate,
    DateTime? createdDate,
    String? status,
    String? type,
    Object? budget = _sentinel,  // Using Object? to allow explicit null
    Object? eventDate = _sentinel,  // Using Object? to allow explicit null
    Object? targetDate = _sentinel,  // Using Object? to allow explicit null
    bool? isShared,
    String? createdBy,
    List<String>? sharedWith,
    List<UnifiedListItem>? items,
    Object? templateId = _sentinel,  // Using Object? to allow explicit null
    String? format,
    bool? createdFromTemplate,
    List<ActiveShopper>? activeShoppers,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedDate: updatedDate ?? this.updatedDate,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      type: type ?? this.type,
      budget: identical(budget, _sentinel) 
          ? this.budget 
          : budget as double?,  // Allow explicit null
      eventDate: identical(eventDate, _sentinel) 
          ? this.eventDate 
          : eventDate as DateTime?,  // Allow explicit null
      targetDate: identical(targetDate, _sentinel) 
          ? this.targetDate 
          : targetDate as DateTime?,  // Allow explicit null
      isShared: isShared ?? this.isShared,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? this.sharedWith,
      items: items ?? this.items,
      templateId: identical(templateId, _sentinel) 
          ? this.templateId 
          : templateId as String?,  // Allow explicit null
      format: format ?? this.format,
      createdFromTemplate: createdFromTemplate ?? this.createdFromTemplate,
      activeShoppers: activeShoppers ?? this.activeShoppers,
    );
  }

  // ---- Items Manipulation ----

  /// 🇮🇱 הוספת פריט לרשימה
  /// 🇬🇧 Add item to list
  ShoppingList withItemAdded(UnifiedListItem item) {
    return copyWith(items: [...items, item], updatedDate: DateTime.now());
  }

  /// 🇮🇱 הסרת פריט לפי אינדקס
  /// 🇬🇧 Remove item by index
  ShoppingList withItemRemoved(int index) {
    if (index < 0 || index >= items.length) return this;
    final updated = [...items]..removeAt(index);
    return copyWith(items: updated, updatedDate: DateTime.now());
  }

  // ---- JSON Serialization ----

  /// 🇮🇱 יצירה מ-JSON
  /// 🇬🇧 Create from JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('📥 ShoppingList.fromJson:');
      debugPrint('   id: ${json['id']}');
      debugPrint('   name: ${json['name']}');
      debugPrint('   type: ${json['type']}');
      debugPrint('   status: ${json['status']}');
      debugPrint('   items: ${(json['items'] as List?)?.length ?? 0}');
    }
    return _$ShoppingListFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
    if (kDebugMode) {
      debugPrint('📤 ShoppingList.toJson:');
      debugPrint('   id: $id');
      debugPrint('   name: $name');
      debugPrint('   type: $type');
      debugPrint('   status: $status');
      debugPrint('   items: ${items.length}');
    }
    return _$ShoppingListToJson(this);
  }

  @override
  String toString() =>
      'ShoppingList(id: $id, name: $name, type: $type, status: $status, items: ${items.length}, budget: $budget)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
