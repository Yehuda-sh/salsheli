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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'active_shopper.dart';
import 'enums/item_type.dart';
import 'enums/user_role.dart';
import 'pending_request.dart';
import 'shared_user.dart';
import 'timestamp_converter.dart';
import 'unified_list_item.dart';

part 'shopping_list.g.dart';

/// Converter for `Map<String, SharedUser>` to/from Firestore
///
/// Converts between:
/// - Dart: `Map<String, SharedUser>` (userId as key)
/// - Firestore: `Map<String, Map<String, dynamic>>`
///
/// Example Firestore structure:
/// ```json
/// "shared_users": {
///   "user123": { "role": "admin", "shared_at": "2024-01-01T00:00:00Z" },
///   "user456": { "role": "viewer", "shared_at": "2024-01-02T00:00:00Z" }
/// }
/// ```
class SharedUsersMapConverter
    implements JsonConverter<Map<String, SharedUser>, dynamic> {
  const SharedUsersMapConverter();

  @override
  Map<String, SharedUser> fromJson(dynamic json) {
    if (json == null) {
      return {};
    }

    // Handle old List format (backward compatibility)
    if (json is List) {
      debugPrint('⚠️ SharedUsersMapConverter: Converting old List format to Map');
      final result = <String, SharedUser>{};
      for (final item in json) {
        try {
          if (item is Map) {
            final userData = Map<String, dynamic>.from(item);
            // Old format had userId inside the object
            final userId = userData['user_id'] as String? ?? userData['userId'] as String?;
            if (userId != null && userId.isNotEmpty) {
              final user = SharedUser.fromJson(userData);
              result[userId] = user.copyWith(userId: userId);
            }
          }
        } catch (e) {
          debugPrint('⚠️ SharedUsersMapConverter: Failed to parse user from list: $e');
        }
      }
      return result;
    }

    // Handle new Map format
    if (json is Map) {
      final result = <String, SharedUser>{};
      for (final entry in json.entries) {
        try {
          final key = entry.key as String;
          final userData = Map<String, dynamic>.from(entry.value as Map);
          final user = SharedUser.fromJson(userData);
          // Set the userId from the map key
          result[key] = user.copyWith(userId: key);
        } catch (e) {
          debugPrint('⚠️ SharedUsersMapConverter: Failed to parse user ${entry.key}: $e');
        }
      }
      return result;
    }

    debugPrint('⚠️ SharedUsersMapConverter: Unexpected type ${json.runtimeType}');
    return {};
  }

  @override
  Map<String, dynamic> toJson(Map<String, SharedUser> users) {
    final result = <String, dynamic>{};
    for (final entry in users.entries) {
      result[entry.key] = entry.value.toJson();
    }
    return result;
  }
}

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

  // ==== 🆕 שיתוף משתמשים (Map Structure for Scalability) ====

  /// 🆕 מפת משתמשים משותפים (מלבד ה-owner)
  /// 🇬🇧 Map of shared users (besides the owner)
  ///
  /// מבנה: userId -> SharedUser data
  /// יתרונות:
  /// - O(1) lookup by userId
  /// - No limit on number of users
  /// - Simple Security Rules (uid in sharedUsers)
  @SharedUsersMapConverter()
  @JsonKey(name: 'shared_users', defaultValue: {})
  final Map<String, SharedUser> sharedUsers;

  /// 🆕 בקשות ממתינות לאישור (רק עבור Editors)
  /// 🇬🇧 Pending requests for approval (only for Editors)
  @JsonKey(name: 'pending_requests', defaultValue: [])
  final List<PendingRequest> pendingRequests;

  /// 🆕 האם הרשימה פרטית (לא משותפת עם ה-household)
  /// 🇬🇧 Is the list private (not shared with the household)
  /// ברירת מחדל: false - רשימות משותפות עם כל ה-household
  @JsonKey(name: 'is_private', defaultValue: false)
  final bool isPrivate;

  /// 🆕 הרשאה של המשתמש הנוכחי (מחושב, לא נשמר)
  /// 🇬🇧 Current user's role (computed, not saved)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserRole? currentUserRole;

  // ---- Shopping timeout ----
  static const Duration shoppingTimeout = Duration(hours: 6);

  // ---- Status constants ----
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';
  static const String statusCompleted = 'completed';

  // ---- Type constants (Extended List Types) ----
  static const String typeSupermarket = 'supermarket';  // 🛒 סופרמרקט - כל המוצרים
  static const String typePharmacy = 'pharmacy';        // 💊 בית מרקחת - היגיינה וניקיון
  static const String typeGreengrocer = 'greengrocer'; // 🥬 ירקן - פירות וירקות
  static const String typeButcher = 'butcher';         // 🥩 אטליז - בשר ועוף
  static const String typeBakery = 'bakery';           // 🍞 מאפייה - לחם ומאפים
  static const String typeMarket = 'market';           // 🏪 שוק - מעורב
  static const String typeHousehold = 'household';     // 🏠 כלי בית - מוצרים מותאמים
  static const String typeOther = 'other';             // ➕ אחר
  

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

  // ==== 🆕 Sharing & Permissions Helpers ====

  /// 🇮🇱 האם המשתמש הנוכחי הוא ה-owner
  /// 🇬🇧 Is the current user the owner
  bool get isCurrentUserOwner => currentUserRole == UserRole.owner;

  /// 🇮🇱 האם המשתמש הנוכחי יכול לערוך (owner/admin/editor)
  /// 🇬🇧 Can the current user edit (owner/admin/editor)
  bool get canCurrentUserEdit =>
      currentUserRole == UserRole.owner ||
      currentUserRole == UserRole.admin ||
      currentUserRole == UserRole.editor;

  /// 🇮🇱 האם המשתמש הנוכחי יכול לאשר בקשות (owner/admin)
  /// 🇬🇧 Can the current user approve requests (owner/admin)
  bool get canCurrentUserApprove =>
      currentUserRole == UserRole.owner || currentUserRole == UserRole.admin;

  /// 🇮🇱 האם המשתמש הנוכחי יכול לנהל משתמשים (owner/admin)
  /// 🇬🇧 Can the current user manage users (owner/admin)
  bool get canCurrentUserManage =>
      currentUserRole == UserRole.owner || currentUserRole == UserRole.admin;

  /// 🇮🇱 האם המשתמש הנוכחי צריך לבקש אישור (editor)
  /// 🇬🇧 Should the current user request approval (editor)
  bool get shouldCurrentUserRequest => currentUserRole == UserRole.editor;

  /// 🇮🇱 האם המשתמש הנוכחי יכול להזמין משתמשים (owner בלבד!)
  /// 🇬🇧 Can the current user invite users (owner only!)
  bool get canCurrentUserInvite => currentUserRole == UserRole.owner;

  /// 🇮🇱 האם המשתמש הנוכחי יכול למחוק את הרשימה (owner בלבד!)
  /// 🇬🇧 Can the current user delete the list (owner only!)
  bool get canCurrentUserDelete => currentUserRole == UserRole.owner;

  /// 🇮🇱 בקשות ממתינות של המשתמש הנוכחי
  /// 🇬🇧 Pending requests by the current user
  List<PendingRequest> pendingRequestsByCurrentUser(String userId) {
    return pendingRequests
        .where((r) => r.requesterId == userId && r.isPending)
        .toList();
  }

  /// 🇮🇱 בקשות ממתינות לאישור (רק ל-Admin/Owner)
  /// 🇬🇧 Pending requests for review (only for Admin/Owner)
  List<PendingRequest> get pendingRequestsForReview {
    return pendingRequests.where((r) => r.isPending).toList();
  }

  /// 🇮🇱 כמה בקשות ממתינות יש
  /// 🇬🇧 How many pending requests exist
  int get pendingRequestsCount =>
      pendingRequests.where((r) => r.isPending).length;

  /// 🇮🇱 מצא משתמש משותף לפי userId
  /// 🇬🇧 Find shared user by userId
  SharedUser? getSharedUser(String userId) {
    if (createdBy == userId) {
      return SharedUser(
        userId: userId,
        role: UserRole.owner,
        sharedAt: createdDate,
      );
    }

    // Map lookup - O(1)
    return sharedUsers[userId];
  }

  /// 🇮🇱 קבל את התפקיד של משתמש
  /// 🇬🇧 Get the role of a user
  UserRole? getUserRole(String userId) {
    return getSharedUser(userId)?.role;
  }

  // ==== 🎨 UI Helpers - Type-based styling ====

  /// 🇮🇱 צבע פתק לפי סוג הרשימה
  /// 🇬🇧 Sticky note color by list type
  Color get stickyColor {
    switch (type) {
      case typeSupermarket:
        return const Color(0xFFFFF59D); // kStickyYellow
      case typePharmacy:
        return const Color(0xFF80DEEA); // kStickyCyan
      case typeGreengrocer:
        return const Color(0xFFA5D6A7); // kStickyGreen
      case typeButcher:
        return const Color(0xFFF48FB1); // kStickyPink
      case typeBakery:
        return const Color(0xFFFFCC80); // kStickyOrange
      case typeMarket:
        return const Color(0xFFCE93D8); // kStickyPurple
      case typeHousehold:
        return const Color(0xFF80DEEA); // kStickyCyan
      default:
        return const Color(0xFFFFF59D); // kStickyYellow (default)
    }
  }

  /// 🇮🇱 אימוג'י לפי סוג הרשימה
  /// 🇬🇧 Emoji by list type
  String get typeEmoji {
    switch (type) {
      case typeSupermarket:
        return '🛒';
      case typePharmacy:
        return '💊';
      case typeGreengrocer:
        return '🥦';
      case typeButcher:
        return '🥩';
      case typeBakery:
        return '🥖';
      case typeMarket:
        return '🏪';
      case typeHousehold:
        return '🏠';
      default:
        return '📝';
    }
  }

  /// 🇮🇱 אייקון Material לפי סוג הרשימה
  /// 🇬🇧 Material icon by list type
  IconData get typeIcon {
    switch (type) {
      case typeSupermarket:
        return Icons.shopping_cart;
      case typePharmacy:
        return Icons.medication;
      case typeGreengrocer:
        return Icons.local_florist;
      case typeButcher:
        return Icons.set_meal;
      case typeBakery:
        return Icons.bakery_dining;
      case typeMarket:
        return Icons.store;
      case typeHousehold:
        return Icons.home;
      default:
        return Icons.shopping_bag;
    }
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
    Map<String, SharedUser> sharedUsers = const {},
    List<PendingRequest> pendingRequests = const [],
    this.isPrivate = false,
    this.currentUserRole,
  })  : createdDate = createdDate ?? updatedDate,
        sharedWith = List<String>.unmodifiable(sharedWith),
        items = List<UnifiedListItem>.unmodifiable(items),
        activeShoppers = List<ActiveShopper>.unmodifiable(activeShoppers),
        sharedUsers = Map<String, SharedUser>.unmodifiable(sharedUsers),
        pendingRequests = List<PendingRequest>.unmodifiable(pendingRequests);

  // ---- Factory Constructors ----

  /// 🇮🇱 יצירת רשימה חדשה בקלות
  /// 🇬🇧 Easily create a new list
  factory ShoppingList.newList({
    String? id,
    required String name,
    required String createdBy,
    String type = typeSupermarket,
    double? budget,
    DateTime? eventDate,
    DateTime? targetDate,
    bool isShared = false,
    bool isPrivate = false,
    List<String> sharedWith = const [],
    List<UnifiedListItem> items = const [],
    String? templateId,
    String format = 'shared',
    bool createdFromTemplate = false,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ShoppingList(
      id: id ?? const Uuid().v4(),
      name: name,
      createdBy: createdBy,
      type: type,
      budget: budget,
      eventDate: eventDate,
      targetDate: targetDate,
      isShared: isShared,
      isPrivate: isPrivate,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<UnifiedListItem>.unmodifiable(items),
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
    String? id,
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
    bool isPrivate = false,
    List<String> sharedWith = const [],
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ShoppingList(
      id: id ?? const Uuid().v4(),
      name: name,
      createdBy: createdBy,
      type: type,
      format: format,
      budget: budget,
      eventDate: eventDate,
      targetDate: targetDate,
      isShared: isShared,
      isPrivate: isPrivate,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<UnifiedListItem>.unmodifiable(items),
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
    bool? isPrivate,
    String? createdBy,
    List<String>? sharedWith,
    List<UnifiedListItem>? items,
    Object? templateId = _sentinel,  // Using Object? to allow explicit null
    String? format,
    bool? createdFromTemplate,
    List<ActiveShopper>? activeShoppers,
    Map<String, SharedUser>? sharedUsers,
    List<PendingRequest>? pendingRequests,
    UserRole? currentUserRole,
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
      isPrivate: isPrivate ?? this.isPrivate,
      createdBy: createdBy ?? this.createdBy,
      sharedWith: sharedWith ?? this.sharedWith,
      items: items ?? this.items,
      templateId: identical(templateId, _sentinel)
          ? this.templateId
          : templateId as String?,  // Allow explicit null
      format: format ?? this.format,
      createdFromTemplate: createdFromTemplate ?? this.createdFromTemplate,
      activeShoppers: activeShoppers ?? this.activeShoppers,
      sharedUsers: sharedUsers ?? this.sharedUsers,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      currentUserRole: currentUserRole ?? this.currentUserRole,
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
    return _$ShoppingListFromJson(json);
  }

  /// 🇮🇱 המרה ל-JSON
  /// 🇬🇧 Convert to JSON
  Map<String, dynamic> toJson() {
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
