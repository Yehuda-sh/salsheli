// File: scripts/demo_data_cohen_family.dart
//
// Purpose: Create demo data for Cohen family in Firebase Emulator
//
// Run with:
//   dart run scripts/demo_data_cohen_family.dart
//
// Environment Variables (optional):
//   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
//   FIRESTORE_EMULATOR_HOST=localhost:8080
//
// Note: This script creates data for testing purposes only.
//       Prices shown are for illustration purposes only.
//
// Database Structure:
//   /users/{userId}                    - User profiles
//   /users/{userId}/private_lists/     - Private shopping lists
//   /households/{householdId}/         - Household data
//     ├── shared_lists/{listId}        - Shared shopping lists
//     ├── inventory/{itemId}           - Pantry items
//     └── receipts/{receiptId}         - Virtual receipts
//   /groups/{groupId}                  - Family group
//   /group_invites/{inviteId}          - Pending invites
//   /custom_locations/{docId}          - Custom storage locations
//
// Created: 30/12/2025

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════════

// Firebase Emulator endpoints
const String firestoreHost = 'localhost:8080';
const String authHost = 'localhost:9099';
const String projectId = 'memozap-5ad30'; // From firebase.json

// ═══════════════════════════════════════════════════════════════════
// PRODUCTS FROM JSON FILES
// ═══════════════════════════════════════════════════════════════════

/// כל המוצרים מקבצי ה-JSON
late List<Map<String, dynamic>> allProducts;

/// מוצרים לפי קטגוריה
late Map<String, List<Map<String, dynamic>>> productsByCategory;

/// טוען מוצרים מקבצי ה-JSON
Future<void> loadProductsFromJson() async {
  allProducts = [];
  productsByCategory = {};

  final jsonFiles = [
    'assets/data/list_types/supermarket.json',
    'assets/data/list_types/bakery.json',
    'assets/data/list_types/butcher.json',
    'assets/data/list_types/greengrocer.json',
    'assets/data/list_types/pharmacy.json',
    'assets/data/list_types/market.json',
  ];

  for (final filePath in jsonFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final products = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
      allProducts.addAll(products);

      // קיבוץ לפי קטגוריה
      for (final product in products) {
        final category = product['category'] as String? ?? 'אחר';
        productsByCategory.putIfAbsent(category, () => []).add(product);
      }
    }
  }

  print('📦 נטענו ${allProducts.length} מוצרים מ-${productsByCategory.length} קטגוריות');
}

/// בוחר מוצרים אקראיים מקטגוריה
List<Map<String, dynamic>> getRandomProducts(String category, int count) {
  final categoryProducts = productsByCategory[category] ?? allProducts;
  if (categoryProducts.isEmpty) return [];

  final random = Random();
  final shuffled = List<Map<String, dynamic>>.from(categoryProducts)..shuffle(random);
  return shuffled.take(count.clamp(0, shuffled.length)).toList();
}

/// בוחר מוצרים אקראיים מכל הקטגוריות
List<Map<String, dynamic>> getRandomProductsFromAll(int count) {
  if (allProducts.isEmpty) return [];

  final random = Random();
  final shuffled = List<Map<String, dynamic>>.from(allProducts)..shuffle(random);
  return shuffled.take(count.clamp(0, shuffled.length)).toList();
}

/// מיקומי אחסון לפי קטגוריה
String getLocationForCategory(String category) {
  final categoryLower = category.toLowerCase();
  if (categoryLower.contains('חלב') || categoryLower.contains('גבינ') || categoryLower.contains('יוגורט')) {
    return 'מקרר';
  }
  if (categoryLower.contains('בשר') || categoryLower.contains('עוף') || categoryLower.contains('דג')) {
    return 'מקפיא';
  }
  if (categoryLower.contains('ירק') || categoryLower.contains('פיר')) {
    return 'מקרר';
  }
  if (categoryLower.contains('ניקיון') || categoryLower.contains('כביסה')) {
    return 'ארון שירות';
  }
  if (categoryLower.contains('היגיינ') || categoryLower.contains('טיפוח')) {
    return 'ארון אמבטיה';
  }
  return 'ארון יבש';
}

// Cohen Family - User IDs (stable UUIDs for reproducibility)
const String aviUserId = 'demo_avi_cohen_001';
const String ronitUserId = 'demo_ronit_cohen_002';
const String yuvalUserId = 'demo_yuval_cohen_003';
const String noaUserId = 'demo_noa_cohen_004';
const String eladUserId = 'demo_elad_cohen_005';

// Young Couple - Levi Family
const String danUserId = 'demo_dan_levi_010';
const String mayaUserId = 'demo_maya_levi_011';

// Single Person - Lives alone
const String tomerId = 'demo_tomer_bar_020';

// New User - Rich pantry, no history
const String shiranId = 'demo_shiran_gal_030';

// Household & Group IDs
const String householdId = 'household_cohen_001';
const String groupId = 'group_cohen_baam_001';

// Levi household
const String leviHouseholdId = 'household_levi_010';
const String leviGroupId = 'group_levi_family_010';

// Single person household
const String tomerHouseholdId = 'household_tomer_020';

// New user household
const String shiranHouseholdId = 'household_shiran_030';

// Password for all demo users
const String demoPassword = 'Demo123!';

// ═══════════════════════════════════════════════════════════════════
// USER DATA
// ═══════════════════════════════════════════════════════════════════

final Map<String, Map<String, dynamic>> users = {
  aviUserId: {
    'id': aviUserId,
    'name': 'אבי כהן',
    'email': 'avi.cohen@demo.com',
    'phone': '0501234567',
    'household_id': householdId,
    'joined_at': DateTime(2024, 6, 1).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל', 'רמי לוי'],
    'favorite_products': [],
    'weekly_budget': 2000.0,
    'is_admin': true,
    'family_size': 4,
    'shopping_frequency': 2,
    'shopping_days': [4, 5], // Thursday, Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': '10:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
  ronitUserId: {
    'id': ronitUserId,
    'name': 'רונית כהן',
    'email': 'ronit.cohen@demo.com',
    'phone': '0521234567',
    'household_id': householdId,
    'joined_at': DateTime(2024, 6, 1).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל', 'יוחננוף'],
    'favorite_products': [],
    'weekly_budget': 2000.0,
    'is_admin': true,
    'family_size': 4,
    'shopping_frequency': 3,
    'shopping_days': [0, 3, 5], // Sunday, Wednesday, Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': '09:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
  yuvalUserId: {
    'id': yuvalUserId,
    'name': 'יובל כהן',
    'email': 'yuval.cohen@demo.com',
    'phone': '0531234567',
    'household_id': householdId,
    'joined_at': DateTime(2024, 7, 15).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['AM:PM', 'שופרסל'],
    'favorite_products': [],
    'weekly_budget': 200.0,
    'is_admin': false,
    'family_size': 4,
    'shopping_frequency': 1,
    'shopping_days': [5], // Friday
    'has_children': false,
    'share_lists': true,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
  noaUserId: {
    'id': noaUserId,
    'name': 'נועה כהן',
    'email': 'noa.cohen@demo.com',
    'phone': '0541234567',
    'household_id': householdId,
    'joined_at': DateTime(2024, 8, 1).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל'],
    'favorite_products': [],
    'weekly_budget': 150.0,
    'is_admin': false,
    'family_size': 4,
    'shopping_frequency': 1,
    'shopping_days': [5], // Friday
    'has_children': false,
    'share_lists': true,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
};

// ═══════════════════════════════════════════════════════════════════
// ADDITIONAL USERS - Young couple (Levi), Single (Tomer), New user (Shiran)
// ═══════════════════════════════════════════════════════════════════

final Map<String, Map<String, dynamic>> additionalUsers = {
  // Young Couple - Dan & Maya Levi
  danUserId: {
    'id': danUserId,
    'name': 'דן לוי',
    'email': 'dan.levi@demo.com',
    'phone': '0501112222',
    'household_id': leviHouseholdId,
    'joined_at': DateTime(2024, 9, 1).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['ויקטורי', 'שופרסל'],
    'favorite_products': [],
    'weekly_budget': 1200.0,
    'is_admin': true,
    'family_size': 2,
    'shopping_frequency': 2,
    'shopping_days': [4, 6], // Thursday, Saturday
    'has_children': false,
    'share_lists': true,
    'reminder_time': '18:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
  mayaUserId: {
    'id': mayaUserId,
    'name': 'מאיה לוי',
    'email': 'maya.levi@demo.com',
    'phone': '0502223333',
    'household_id': leviHouseholdId,
    'joined_at': DateTime(2024, 9, 1).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['ויקטורי', 'יוחננוף'],
    'favorite_products': [],
    'weekly_budget': 1200.0,
    'is_admin': true,
    'family_size': 2,
    'shopping_frequency': 2,
    'shopping_days': [0, 4], // Sunday, Thursday
    'has_children': false,
    'share_lists': true,
    'reminder_time': '19:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // Single Person - Tomer Bar (lives alone, active shopper)
  tomerId: {
    'id': tomerId,
    'name': 'תומר בר',
    'email': 'tomer.bar@demo.com',
    'phone': '0503334444',
    'household_id': tomerHouseholdId,
    'joined_at': DateTime(2024, 10, 15).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['AM:PM', 'שופרסל אקספרס'],
    'favorite_products': [],
    'weekly_budget': 600.0,
    'is_admin': true,
    'family_size': 1,
    'shopping_frequency': 3,
    'shopping_days': [1, 3, 5], // Monday, Wednesday, Friday
    'has_children': false,
    'share_lists': false,
    'reminder_time': '20:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // New User - Shiran Gal (just joined, has rich pantry but no shopping history)
  shiranId: {
    'id': shiranId,
    'name': 'שירן גל',
    'email': 'shiran.gal@demo.com',
    'phone': '0504445555',
    'household_id': shiranHouseholdId,
    'joined_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['רמי לוי'],
    'favorite_products': [],
    'weekly_budget': 800.0,
    'is_admin': true,
    'family_size': 1,
    'shopping_frequency': 2,
    'shopping_days': [5], // Friday
    'has_children': false,
    'share_lists': false,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': true,
  },
};

// ═══════════════════════════════════════════════════════════════════
// GROUP DATA - "כהן בע"מ"
// ═══════════════════════════════════════════════════════════════════

/// Generate Cohen group data with real Firebase UIDs
Map<String, dynamic> generateCohenGroupData(Map<String, String> uids) {
  final aviUid = uids[aviUserId]!;
  final ronitUid = uids[ronitUserId]!;
  final yuvalUid = uids[yuvalUserId]!;
  final noaUid = uids[noaUserId]!;

  return {
    'id': groupId,
    'name': 'כהן בע"מ',
    'type': 'family',
    'description': 'קבוצת משפחת כהן - לניהול קניות ומזווה משותף',
    'image_url': null,
    'created_by': aviUid,
    'created_at': DateTime(2024, 6, 1).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'members': {
      aviUid: {
        'user_id': aviUid,
        'name': 'אבי כהן',
        'email': 'avi.cohen@demo.com',
        'avatar_url': null,
        'role': 'owner',
        'joined_at': DateTime(2024, 6, 1).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      ronitUid: {
        'user_id': ronitUid,
        'name': 'רונית כהן',
        'email': 'ronit.cohen@demo.com',
        'avatar_url': null,
        'role': 'admin',
        'joined_at': DateTime(2024, 6, 1).toIso8601String(),
        'invited_by': aviUid,
        'can_start_shopping': true,
      },
      yuvalUid: {
        'user_id': yuvalUid,
        'name': 'יובל כהן',
        'email': 'yuval.cohen@demo.com',
        'avatar_url': null,
        'role': 'editor',
        'joined_at': DateTime(2024, 7, 15).toIso8601String(),
        'invited_by': aviUid,
        'can_start_shopping': true, // Yuval has permission
      },
      noaUid: {
        'user_id': noaUid,
        'name': 'נועה כהן',
        'email': 'noa.cohen@demo.com',
        'avatar_url': null,
        'role': 'editor',
        'joined_at': DateTime(2024, 8, 1).toIso8601String(),
        'invited_by': ronitUid,
        'can_start_shopping': false, // Noa doesn't have permission yet
      },
    },
    'settings': {
      'notifications': true,
      'low_stock_alerts': true,
      'voting_alerts': true,
      'whos_bringing_alerts': true,
    },
    'extra_fields': null,
  };
}

// ═══════════════════════════════════════════════════════════════════
// GROUP INVITE - אלעד (Pending)
// ═══════════════════════════════════════════════════════════════════

/// Generate Elad invite with real Firebase UIDs
Map<String, dynamic> generateEladInvite(Map<String, String> uids) {
  final ronitUid = uids[ronitUserId]!;

  return {
    'id': 'invite_elad_001',
    'group_id': groupId,
    'group_name': 'כהן בע"מ',
    'invited_phone': '0551234567',
    'invited_email': 'elad.cohen@demo.com',
    'invited_name': 'אלעד כהן',
    'role': 'viewer',
    'invited_by': ronitUid,
    'invited_by_name': 'רונית כהן',
    'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'status': 'pending',
    'responded_at': null,
    'accepted_by_user_id': null,
  };
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM LOCATIONS
// ═══════════════════════════════════════════════════════════════════

final List<Map<String, dynamic>> customLocations = [
  {
    'key': 'service_cabinet',
    'name': 'ארון שירות',
    'emoji': '🧹',
    'household_id': householdId,
  },
  {
    'key': 'bathroom_cabinet',
    'name': 'ארון אמבטיה',
    'emoji': '🛁',
    'household_id': householdId,
  },
  {
    'key': 'storage_room',
    'name': 'מחסן',
    'emoji': '📦',
    'household_id': householdId,
  },
  {
    'key': 'medicine_cabinet',
    'name': 'ארון תרופות',
    'emoji': '💊',
    'household_id': householdId,
  },
];

// ═══════════════════════════════════════════════════════════════════
// SAMPLE PRODUCTS (from catalog with realistic prices)
// ═══════════════════════════════════════════════════════════════════

// Note: Prices are for illustration only
final List<Map<String, dynamic>> sampleProducts = [
  // Dairy
  {'name': 'חלב תנובה 3% 1 ליטר', 'category': 'מוצרי חלב', 'price': 6.90, 'barcode': '7290000000001'},
  {'name': 'גבינה צהובה 28% עמק 200 גרם', 'category': 'מוצרי חלב', 'price': 12.90, 'barcode': '7290000000002'},
  {'name': 'יוגורט דנונה בננה', 'category': 'מוצרי חלב', 'price': 4.50, 'barcode': '7290000000003'},
  {'name': 'קוטג\' תנובה 5% 250 גרם', 'category': 'מוצרי חלב', 'price': 8.90, 'barcode': '7290000000004'},
  {'name': 'שמנת מתוקה 38%', 'category': 'מוצרי חלב', 'price': 9.90, 'barcode': '7290000000005'},

  // Bread & Bakery
  {'name': 'לחם אחיד פרוס', 'category': 'לחם ומאפים', 'price': 7.90, 'barcode': '7290000000010'},
  {'name': 'חלה מתוקה', 'category': 'לחם ומאפים', 'price': 12.90, 'barcode': '7290000000011'},
  {'name': 'פיתות רגילות', 'category': 'לחם ומאפים', 'price': 8.90, 'barcode': '7290000000012'},
  {'name': 'לחמניות המבורגר 4 יח\'', 'category': 'לחם ומאפים', 'price': 11.90, 'barcode': '7290000000013'},

  // Meat & Poultry
  {'name': 'חזה עוף טרי', 'category': 'בשר ועוף', 'price': 34.90, 'barcode': '7290000000020'},
  {'name': 'שניצל עוף טבעי', 'category': 'בשר ועוף', 'price': 39.90, 'barcode': '7290000000021'},
  {'name': 'כרעיים עוף', 'category': 'בשר ועוף', 'price': 24.90, 'barcode': '7290000000022'},
  {'name': 'בשר טחון', 'category': 'בשר ועוף', 'price': 49.90, 'barcode': '7290000000023'},

  // Fruits & Vegetables
  {'name': 'תפוחי עץ גולדן', 'category': 'פירות וירקות', 'price': 8.90, 'barcode': '7290000000030'},
  {'name': 'בננות', 'category': 'פירות וירקות', 'price': 7.90, 'barcode': '7290000000031'},
  {'name': 'עגבניות שרי', 'category': 'פירות וירקות', 'price': 12.90, 'barcode': '7290000000032'},
  {'name': 'מלפפונים', 'category': 'פירות וירקות', 'price': 4.90, 'barcode': '7290000000033'},
  {'name': 'בצל יבש', 'category': 'פירות וירקות', 'price': 3.90, 'barcode': '7290000000034'},
  {'name': 'גזר', 'category': 'פירות וירקות', 'price': 4.90, 'barcode': '7290000000035'},
  {'name': 'תפוחי אדמה', 'category': 'פירות וירקות', 'price': 5.90, 'barcode': '7290000000036'},
  {'name': 'אבוקדו', 'category': 'פירות וירקות', 'price': 6.90, 'barcode': '7290000000037'},

  // Snacks & Sweets
  {'name': 'ביסלי גריל', 'category': 'חטיפים וממתקים', 'price': 8.90, 'barcode': '7290000000040'},
  {'name': 'במבה אסם', 'category': 'חטיפים וממתקים', 'price': 6.90, 'barcode': '7290000000041'},
  {'name': 'שוקולד פרה מילקה', 'category': 'חטיפים וממתקים', 'price': 12.90, 'barcode': '7290000000042'},
  {'name': 'עוגיות אוראו', 'category': 'חטיפים וממתקים', 'price': 14.90, 'barcode': '7290000000043'},

  // Drinks
  {'name': 'מיץ תפוזים פריגת 1 ליטר', 'category': 'משקאות', 'price': 9.90, 'barcode': '7290000000050'},
  {'name': 'קולה 1.5 ליטר', 'category': 'משקאות', 'price': 8.90, 'barcode': '7290000000051'},
  {'name': 'מים מינרלים 1.5 ליטר', 'category': 'משקאות', 'price': 3.90, 'barcode': '7290000000052'},

  // Cleaning
  {'name': 'נוזל כלים פיירי', 'category': 'מוצרי ניקיון', 'price': 12.90, 'barcode': '7290000000060'},
  {'name': 'אקונומיקה 4 ליטר', 'category': 'מוצרי ניקיון', 'price': 19.90, 'barcode': '7290000000061'},
  {'name': 'נייר טואלט 32 גלילים', 'category': 'מוצרי ניקיון', 'price': 39.90, 'barcode': '7290000000062'},

  // Hygiene
  {'name': 'שמפו הד אנד שולדרס', 'category': 'היגיינה וטיפוח', 'price': 24.90, 'barcode': '7290000000070'},
  {'name': 'משחת שיניים קולגייט', 'category': 'היגיינה וטיפוח', 'price': 12.90, 'barcode': '7290000000071'},
  {'name': 'סבון נוזלי', 'category': 'היגיינה וטיפוח', 'price': 9.90, 'barcode': '7290000000072'},

  // Rice & Pasta
  {'name': 'אורז בסמטי 1 ק"ג', 'category': 'אורז ופסטה', 'price': 15.90, 'barcode': '7290000000080'},
  {'name': 'ספגטי ברילה 500 גרם', 'category': 'אורז ופסטה', 'price': 8.90, 'barcode': '7290000000081'},
  {'name': 'פתיתים אסם 500 גרם', 'category': 'אורז ופסטה', 'price': 9.90, 'barcode': '7290000000082'},

  // Canned goods
  {'name': 'טונה בשמן 4 יח\'', 'category': 'שימורים', 'price': 29.90, 'barcode': '7290000000090'},
  {'name': 'תירס מתוק שימורים', 'category': 'שימורים', 'price': 7.90, 'barcode': '7290000000091'},
  {'name': 'רסק עגבניות', 'category': 'שימורים', 'price': 6.90, 'barcode': '7290000000092'},

  // Frozen
  {'name': 'שניצלי סויה', 'category': 'מוקפאים', 'price': 29.90, 'barcode': '7290000000100'},
  {'name': 'פיצה משפחתית', 'category': 'מוקפאים', 'price': 34.90, 'barcode': '7290000000101'},
  {'name': 'גלידה שטראוס 1.4 ליטר', 'category': 'מוקפאים', 'price': 39.90, 'barcode': '7290000000102'},

  // Eggs
  {'name': 'ביצים חופש L 12 יח\'', 'category': 'ביצים', 'price': 19.90, 'barcode': '7290000000110'},

  // Coffee & Tea
  {'name': 'קפה עלית נמס 200 גרם', 'category': 'קפה ותה', 'price': 34.90, 'barcode': '7290000000120'},
  {'name': 'תה ויסוצקי 100 שקיקים', 'category': 'קפה ותה', 'price': 19.90, 'barcode': '7290000000121'},

  // Pharmacy/Medicine
  {'name': 'אקמול 500 מ"ג 20 טבליות', 'category': 'תרופות', 'price': 14.90, 'barcode': '7290000000130'},
  {'name': 'נורופן 200 מ"ג', 'category': 'תרופות', 'price': 24.90, 'barcode': '7290000000131'},
  {'name': 'ויטמין C 1000 מ"ג', 'category': 'תרופות', 'price': 39.90, 'barcode': '7290000000132'},
  {'name': 'פלסטרים מגוון', 'category': 'תרופות', 'price': 12.90, 'barcode': '7290000000133'},
];

// Helper to get product by name
Map<String, dynamic>? getProduct(String name) {
  try {
    return sampleProducts.firstWhere((p) => p['name'] == name);
  } catch (_) {
    return null;
  }
}

// Create list item from product
Map<String, dynamic> createListItem({
  required String id,
  required String name,
  required int quantity,
  required double unitPrice,
  String? barcode,
  String? category,
  bool isChecked = false,
  String? checkedBy,
  DateTime? checkedAt,
}) {
  return {
    'id': id,
    'name': name,
    'type': 'product',
    'isChecked': isChecked,
    'category': category,
    'notes': null,
    'image_url': null,
    'productData': {
      'quantity': quantity,
      'unitPrice': unitPrice,
      'barcode': barcode,
      'unit': 'יח\'',
    },
    'taskData': null,
    'checked_by': checkedBy,
    'checked_at': checkedAt?.toIso8601String(),
  };
}

// ═══════════════════════════════════════════════════════════════════
// SHARED LISTS (Household)
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateSharedLists(Map<String, String> uids) {
  final now = DateTime.now();
  final lists = <Map<String, dynamic>>[];

  final aviUid = uids[aviUserId]!;
  final ronitUid = uids[ronitUserId]!;
  final yuvalUid = uids[yuvalUserId]!;
  final noaUid = uids[noaUserId]!;

  // 1. Weekly Shopping - Active (current week)
  lists.add({
    'id': 'list_weekly_current',
    'name': 'קניות שבועיות',
    'updated_date': now.toIso8601String(),
    'created_date': now.subtract(const Duration(days: 2)).toIso8601String(),
    'status': 'active',
    'type': 'supermarket',
    'budget': 800.0,
    'is_shared': true,
    'created_by': ronitUid,
    'shared_with': [],
    'event_date': null,
    'target_date': now.add(const Duration(days: 2)).toIso8601String(),
    'items': [
      createListItem(id: 'item_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 3, unitPrice: 6.90, category: 'מוצרי חלב'),
      createListItem(id: 'item_002', name: 'גבינה צהובה 28% עמק 200 גרם', quantity: 2, unitPrice: 12.90, category: 'מוצרי חלב'),
      createListItem(id: 'item_003', name: 'לחם אחיד פרוס', quantity: 2, unitPrice: 7.90, category: 'לחם ומאפים'),
      createListItem(id: 'item_004', name: 'ביצים חופש L 12 יח\'', quantity: 1, unitPrice: 19.90, category: 'ביצים'),
      createListItem(id: 'item_005', name: 'חזה עוף טרי', quantity: 2, unitPrice: 34.90, category: 'בשר ועוף'),
      createListItem(id: 'item_006', name: 'תפוחי עץ גולדן', quantity: 1, unitPrice: 8.90, category: 'פירות וירקות'),
      createListItem(id: 'item_007', name: 'בננות', quantity: 1, unitPrice: 7.90, category: 'פירות וירקות'),
      createListItem(id: 'item_008', name: 'עגבניות שרי', quantity: 2, unitPrice: 12.90, category: 'פירות וירקות'),
      createListItem(id: 'item_009', name: 'מלפפונים', quantity: 1, unitPrice: 4.90, category: 'פירות וירקות'),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    'active_shoppers': [],
    'shared_users': {
      yuvalUid: {
        'role': 'editor',
        'shared_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'user_name': 'יובל כהן',
        'user_email': 'yuval.cohen@demo.com',
        'can_start_shopping': true,
      },
      noaUid: {
        'role': 'editor',
        'shared_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'user_name': 'נועה כהן',
        'user_email': 'noa.cohen@demo.com',
        'can_start_shopping': false,
      },
    },
    'pending_requests': [],
    'is_private': false,
  });

  // 2. Passover 2026 - Future list (shared only with Avi)
  final pesach2026 = DateTime(2026, 4, 1);
  lists.add({
    'id': 'list_pesach_2026',
    'name': 'פסח 2026',
    'updated_date': now.toIso8601String(),
    'created_date': now.toIso8601String(),
    'status': 'active',
    'type': 'supermarket',
    'budget': 3000.0,
    'is_shared': true,
    'created_by': ronitUid,
    'shared_with': [],
    'event_date': pesach2026.toIso8601String(),
    'target_date': pesach2026.subtract(const Duration(days: 7)).toIso8601String(),
    'items': [
      createListItem(id: 'pesach_001', name: 'מצות יד שמורה', quantity: 5, unitPrice: 45.0, category: 'כשרות לפסח'),
      createListItem(id: 'pesach_002', name: 'יין לקידוש 4 בקבוקים', quantity: 4, unitPrice: 35.0, category: 'כשרות לפסח'),
      createListItem(id: 'pesach_003', name: 'מרור טחון', quantity: 2, unitPrice: 15.0, category: 'כשרות לפסח'),
      createListItem(id: 'pesach_004', name: 'חרוסת מוכנה', quantity: 2, unitPrice: 18.0, category: 'כשרות לפסח'),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    'active_shoppers': [],
    'shared_users': {
      aviUid: {
        'role': 'admin',
        'shared_at': now.toIso8601String(),
        'user_name': 'אבי כהן',
        'user_email': 'avi.cohen@demo.com',
        'can_start_shopping': true,
      },
    },
    'pending_requests': [],
    'is_private': false,
  });

  // 3-6. Completed lists from the past month
  for (var weekAgo = 1; weekAgo <= 4; weekAgo++) {
    final date = now.subtract(Duration(days: weekAgo * 7));
    final completedDate = date.add(const Duration(days: 1));

    lists.add({
      'id': 'list_weekly_week_$weekAgo',
      'name': 'קניות שבועיות',
      'updated_date': completedDate.toIso8601String(),
      'created_date': date.toIso8601String(),
      'status': 'completed',
      'type': 'supermarket',
      'budget': 750.0 + (weekAgo * 50),
      'is_shared': true,
      'created_by': weekAgo.isOdd ? aviUid : ronitUid,
      'shared_with': [],
      'event_date': null,
      'target_date': date.add(const Duration(days: 2)).toIso8601String(),
      'items': _generateCompletedWeeklyItems(weekAgo, completedDate, uids),
      'template_id': null,
      'format': 'shared',
      'created_from_template': false,
      'active_shoppers': [],
      'shared_users': {
        yuvalUid: {
          'role': 'editor',
          'shared_at': date.toIso8601String(),
          'user_name': 'יובל כהן',
          'can_start_shopping': true,
        },
      },
      'pending_requests': [],
      'is_private': false,
    });
  }

  return lists;
}

List<Map<String, dynamic>> _generateCompletedWeeklyItems(int weekNumber, DateTime completedAt, Map<String, String> uids) {
  final aviUid = uids[aviUserId]!;
  final ronitUid = uids[ronitUserId]!;
  final yuvalUid = uids[yuvalUserId]!;

  // Vary the items slightly per week
  final baseItems = [
    createListItem(id: 'w${weekNumber}_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 2 + (weekNumber % 2), unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_002', name: 'לחם אחיד פרוס', quantity: 2, unitPrice: 7.90, category: 'לחם ומאפים', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_003', name: 'ביצים חופש L 12 יח\'', quantity: 1, unitPrice: 19.90, category: 'ביצים', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_004', name: 'בננות', quantity: 1, unitPrice: 7.90, category: 'פירות וירקות', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_005', name: 'עגבניות שרי', quantity: 1 + weekNumber, unitPrice: 12.90, category: 'פירות וירקות', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt),
  ];

  // Add week-specific items
  if (weekNumber == 1) {
    baseItems.add(createListItem(id: 'w1_006', name: 'שניצל עוף טבעי', quantity: 2, unitPrice: 39.90, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
  } else if (weekNumber == 2) {
    baseItems.add(createListItem(id: 'w2_006', name: 'חזה עוף טרי', quantity: 3, unitPrice: 34.90, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
    baseItems.add(createListItem(id: 'w2_007', name: 'נייר טואלט 32 גלילים', quantity: 1, unitPrice: 39.90, category: 'מוצרי ניקיון', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt));
  } else if (weekNumber == 3) {
    baseItems.add(createListItem(id: 'w3_006', name: 'טונה בשמן 4 יח\'', quantity: 2, unitPrice: 29.90, category: 'שימורים', isChecked: true, checkedBy: yuvalUid, checkedAt: completedAt));
  } else {
    baseItems.add(createListItem(id: 'w4_006', name: 'בשר טחון', quantity: 1, unitPrice: 49.90, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
  }

  return baseItems;
}

// ═══════════════════════════════════════════════════════════════════
// PRIVATE LISTS (per user)
// ═══════════════════════════════════════════════════════════════════

Map<String, List<Map<String, dynamic>>> generatePrivateLists() {
  final now = DateTime.now();

  return {
    // Avi's private lists
    aviUserId: [
      // Active: BBQ supplies
      {
        'id': 'avi_bbq_list',
        'name': 'ציוד למנגל',
        'updated_date': now.toIso8601String(),
        'created_date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'active',
        'type': 'butcher',
        'budget': 400.0,
        'is_shared': false,
        'created_by': aviUserId,
        'shared_with': [],
        'event_date': now.add(const Duration(days: 7)).toIso8601String(),
        'target_date': now.add(const Duration(days: 6)).toIso8601String(),
        'items': [
          createListItem(id: 'avi_bbq_001', name: 'אנטריקוט 1 ק"ג', quantity: 2, unitPrice: 120.0, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_002', name: 'כנפיים עוף', quantity: 2, unitPrice: 29.90, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_003', name: 'קבב טחון', quantity: 1, unitPrice: 45.0, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_004', name: 'פחמים 5 ק"ג', quantity: 2, unitPrice: 35.0, category: 'ציוד מנגל'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Completed: Car supplies
      {
        'id': 'avi_car_list',
        'name': 'ציוד לרכב',
        'updated_date': now.subtract(const Duration(days: 10)).toIso8601String(),
        'created_date': now.subtract(const Duration(days: 14)).toIso8601String(),
        'status': 'completed',
        'type': 'other',
        'budget': 200.0,
        'is_shared': false,
        'created_by': aviUserId,
        'shared_with': [],
        'items': [
          createListItem(id: 'avi_car_001', name: 'שמן מנוע', quantity: 1, unitPrice: 89.0, category: 'רכב', isChecked: true, checkedBy: aviUserId),
          createListItem(id: 'avi_car_002', name: 'מגבים חדשים', quantity: 1, unitPrice: 65.0, category: 'רכב', isChecked: true, checkedBy: aviUserId),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],

    // Ronit's private lists
    ronitUserId: [
      // Active: Pharmacy list
      {
        'id': 'ronit_pharmacy_list',
        'name': 'בית מרקחת',
        'updated_date': now.toIso8601String(),
        'created_date': now.subtract(const Duration(days: 3)).toIso8601String(),
        'status': 'active',
        'type': 'pharmacy',
        'budget': 150.0,
        'is_shared': false,
        'created_by': ronitUserId,
        'shared_with': [],
        'items': [
          createListItem(id: 'ronit_pharm_001', name: 'אקמול 500 מ"ג 20 טבליות', quantity: 2, unitPrice: 14.90, category: 'תרופות'),
          createListItem(id: 'ronit_pharm_002', name: 'ויטמין C 1000 מ"ג', quantity: 1, unitPrice: 39.90, category: 'תרופות'),
          createListItem(id: 'ronit_pharm_003', name: 'פלסטרים מגוון', quantity: 1, unitPrice: 12.90, category: 'תרופות'),
          createListItem(id: 'ronit_pharm_004', name: 'קרם ידיים', quantity: 1, unitPrice: 24.90, category: 'היגיינה וטיפוח'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Active: Birthday party supplies
      {
        'id': 'ronit_birthday_list',
        'name': 'יום הולדת נועה',
        'updated_date': now.toIso8601String(),
        'created_date': now.toIso8601String(),
        'status': 'active',
        'type': 'supermarket',
        'budget': 500.0,
        'is_shared': false,
        'created_by': ronitUserId,
        'shared_with': [],
        'event_date': now.add(const Duration(days: 30)).toIso8601String(),
        'items': [
          createListItem(id: 'ronit_bday_001', name: 'עוגה מיוחדת', quantity: 1, unitPrice: 150.0, category: 'מאפים'),
          createListItem(id: 'ronit_bday_002', name: 'בלונים', quantity: 20, unitPrice: 2.0, category: 'קישוטים'),
          createListItem(id: 'ronit_bday_003', name: 'כוסות וצלחות חד פעמי', quantity: 2, unitPrice: 25.0, category: 'חד פעמי'),
          createListItem(id: 'ronit_bday_004', name: 'מפיות מעוצבות', quantity: 3, unitPrice: 12.0, category: 'חד פעמי'),
          createListItem(id: 'ronit_bday_005', name: 'משקאות קלים', quantity: 6, unitPrice: 8.90, category: 'משקאות'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],

    // Yuval's private lists
    yuvalUserId: [
      // Active: Gaming supplies
      {
        'id': 'yuval_gaming_list',
        'name': 'ציוד גיימינג',
        'updated_date': now.toIso8601String(),
        'created_date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'status': 'active',
        'type': 'other',
        'budget': 300.0,
        'is_shared': false,
        'created_by': yuvalUserId,
        'shared_with': [],
        'items': [
          createListItem(id: 'yuval_game_001', name: 'אוזניות גיימינג', quantity: 1, unitPrice: 199.0, category: 'אלקטרוניקה'),
          createListItem(id: 'yuval_game_002', name: 'משטח עכבר XL', quantity: 1, unitPrice: 49.0, category: 'אלקטרוניקה'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Active: Snacks for party
      {
        'id': 'yuval_snacks_list',
        'name': 'חטיפים למסיבה',
        'updated_date': now.toIso8601String(),
        'created_date': now.toIso8601String(),
        'status': 'active',
        'type': 'supermarket',
        'budget': 100.0,
        'is_shared': false,
        'created_by': yuvalUserId,
        'shared_with': [],
        'event_date': now.add(const Duration(days: 3)).toIso8601String(),
        'items': [
          createListItem(id: 'yuval_snack_001', name: 'ביסלי גריל', quantity: 3, unitPrice: 8.90, category: 'חטיפים וממתקים'),
          createListItem(id: 'yuval_snack_002', name: 'במבה אסם', quantity: 3, unitPrice: 6.90, category: 'חטיפים וממתקים'),
          createListItem(id: 'yuval_snack_003', name: 'קולה 1.5 ליטר', quantity: 4, unitPrice: 8.90, category: 'משקאות'),
          createListItem(id: 'yuval_snack_004', name: 'פיצה משפחתית', quantity: 2, unitPrice: 34.90, category: 'מוקפאים'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],

    // Noa's private lists
    noaUserId: [
      // Active: School supplies
      {
        'id': 'noa_school_list',
        'name': 'ציוד לבית ספר',
        'updated_date': now.toIso8601String(),
        'created_date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'active',
        'type': 'other',
        'budget': 200.0,
        'is_shared': false,
        'created_by': noaUserId,
        'shared_with': [],
        'items': [
          createListItem(id: 'noa_school_001', name: 'מחברות A4 5 יח\'', quantity: 2, unitPrice: 25.0, category: 'ציוד משרדי'),
          createListItem(id: 'noa_school_002', name: 'עטים כחולים', quantity: 1, unitPrice: 15.0, category: 'ציוד משרדי'),
          createListItem(id: 'noa_school_003', name: 'מחק ומחדד', quantity: 1, unitPrice: 8.0, category: 'ציוד משרדי'),
          createListItem(id: 'noa_school_004', name: 'תיק גב חדש', quantity: 1, unitPrice: 150.0, category: 'ציוד משרדי'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Active: Skincare products
      {
        'id': 'noa_skincare_list',
        'name': 'מוצרי טיפוח',
        'updated_date': now.toIso8601String(),
        'created_date': now.toIso8601String(),
        'status': 'active',
        'type': 'pharmacy',
        'budget': 120.0,
        'is_shared': false,
        'created_by': noaUserId,
        'shared_with': [],
        'items': [
          createListItem(id: 'noa_skin_001', name: 'קרם פנים', quantity: 1, unitPrice: 45.0, category: 'היגיינה וטיפוח'),
          createListItem(id: 'noa_skin_002', name: 'מסיר איפור', quantity: 1, unitPrice: 29.0, category: 'היגיינה וטיפוח'),
          createListItem(id: 'noa_skin_003', name: 'מסכת פנים', quantity: 3, unitPrice: 12.0, category: 'היגיינה וטיפוח'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],
  };
}

// ═══════════════════════════════════════════════════════════════════
// INVENTORY ITEMS - FROM JSON PRODUCTS
// ═══════════════════════════════════════════════════════════════════

/// יוצר פריט מזווה ממוצר JSON
Map<String, dynamic> createInventoryItemFromProduct(
  Map<String, dynamic> product,
  String id, {
  int quantity = 1,
  int minQuantity = 1,
  int? expiryDays,
  String? notes,
  bool isRecurring = true,
  int purchaseCount = 1,
}) {
  final now = DateTime.now();
  final category = product['category'] as String? ?? 'אחר';
  final location = getLocationForCategory(category);

  return {
    'id': id,
    'product_name': product['name'] as String,
    'category': category,
    'location': location,
    'quantity': quantity,
    'unit': product['unit'] as String? ?? 'יח\'',
    'min_quantity': minQuantity,
    'expiry_date': expiryDays != null
        ? now.add(Duration(days: expiryDays)).toIso8601String()
        : null,
    'notes': notes,
    'is_recurring': isRecurring,
    'last_purchased': now.subtract(Duration(days: Random().nextInt(30) + 1)).toIso8601String(),
    'purchase_count': purchaseCount,
    'emoji': product['icon'] as String?,
    'barcode': product['barcode'] as String?,
    'price': product['price'] as double?,
    'brand': product['brand'] as String?,
  };
}

List<Map<String, dynamic>> generateInventoryItems() {
  final items = <Map<String, dynamic>>[];
  final random = Random();

  // קטגוריות למזווה עם כמויות
  final categoryConfig = {
    'מוצרי חלב': {'count': 4, 'expiryDays': 7, 'minQty': 2},
    'אורז ופסטה': {'count': 3, 'expiryDays': 365, 'minQty': 1},
    'שימורים': {'count': 3, 'expiryDays': 730, 'minQty': 2},
    'מוצרי ניקיון': {'count': 3, 'expiryDays': null, 'minQty': 1},
    'ממתקים וחטיפים': {'count': 2, 'expiryDays': 180, 'minQty': 1},
    'משקאות': {'count': 2, 'expiryDays': 180, 'minQty': 2},
    'תבלינים ואפייה': {'count': 2, 'expiryDays': 365, 'minQty': 1},
    'לחם ומאפים': {'count': 2, 'expiryDays': 5, 'minQty': 1},
  };

  int itemIndex = 0;
  for (final entry in categoryConfig.entries) {
    final category = entry.key;
    final config = entry.value;
    final count = config['count'] as int;
    final expiryDays = config['expiryDays'] as int?;
    final minQty = config['minQty'] as int;

    final categoryProducts = productsByCategory[category] ?? [];
    if (categoryProducts.isEmpty) continue;

    final shuffled = List<Map<String, dynamic>>.from(categoryProducts)..shuffle(random);
    final selected = shuffled.take(count);

    for (final product in selected) {
      items.add(createInventoryItemFromProduct(
        product,
        'inv_${itemIndex++}',
        quantity: random.nextInt(3) + 1,
        minQuantity: minQty,
        expiryDays: expiryDays,
        isRecurring: random.nextBool(),
        purchaseCount: random.nextInt(10) + 1,
      ));
    }
  }

  // הוסף כמה פריטים עם מלאי נמוך (לדמו)
  if (items.length > 3) {
    items[0]['quantity'] = 0; // אזל מהמלאי
    items[1]['quantity'] = 1; // מלאי נמוך
    items[1]['min_quantity'] = 3;
  }

  // הוסף כמה פריטים שפג תוקפם בקרוב (לדמו)
  if (items.length > 5) {
    final now = DateTime.now();
    items[2]['expiry_date'] = now.add(const Duration(days: 2)).toIso8601String();
    items[3]['expiry_date'] = now.add(const Duration(days: 1)).toIso8601String();
  }

  print('   📦 נוצרו ${items.length} פריטי מזווה ממוצרים אמיתיים');
  return items;
}

// ═══════════════════════════════════════════════════════════════════
// RECEIPTS (Virtual - from completed shopping)
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateReceipts() {
  final now = DateTime.now();
  final receipts = <Map<String, dynamic>>[];

  // Create receipts for each completed weekly list
  for (var weekAgo = 1; weekAgo <= 4; weekAgo++) {
    final date = now.subtract(Duration(days: weekAgo * 7 - 1));
    final items = _generateReceiptItems(weekAgo, date);
    final total = items.fold<double>(0, (sum, item) => sum + (item['quantity'] as int) * (item['unit_price'] as double));

    receipts.add({
      'id': 'receipt_week_$weekAgo',
      'store_name': 'קניות שבועיות',
      'date': date.toIso8601String(),
      'created_date': date.toIso8601String(),
      'total_amount': total,
      'items': items,
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'list_weekly_week_$weekAgo',
      'is_virtual': true,
      'created_by': weekAgo.isOdd ? aviUserId : ronitUserId,
      'household_id': householdId,
    });
  }

  return receipts;
}

List<Map<String, dynamic>> _generateReceiptItems(int weekNumber, DateTime date) {
  final items = <Map<String, dynamic>>[
    {'id': 'ri_${weekNumber}_001', 'name': 'חלב תנובה 3% 1 ליטר', 'quantity': 2 + (weekNumber % 2), 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_002', 'name': 'לחם אחיד פרוס', 'quantity': 2, 'unit_price': 7.90, 'is_checked': true, 'category': 'לחם ומאפים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_003', 'name': 'ביצים חופש L 12 יח\'', 'quantity': 1, 'unit_price': 19.90, 'is_checked': true, 'category': 'ביצים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_004', 'name': 'בננות', 'quantity': 1, 'unit_price': 7.90, 'is_checked': true, 'category': 'פירות וירקות', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_005', 'name': 'עגבניות שרי', 'quantity': 1 + weekNumber, 'unit_price': 12.90, 'is_checked': true, 'category': 'פירות וירקות', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()},
  ];

  if (weekNumber == 1) {
    items.add({'id': 'ri_1_006', 'name': 'שניצל עוף טבעי', 'quantity': 2, 'unit_price': 39.90, 'is_checked': true, 'category': 'בשר ועוף', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
  } else if (weekNumber == 2) {
    items.add({'id': 'ri_2_006', 'name': 'חזה עוף טרי', 'quantity': 3, 'unit_price': 34.90, 'is_checked': true, 'category': 'בשר ועוף', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
    items.add({'id': 'ri_2_007', 'name': 'נייר טואלט 32 גלילים', 'quantity': 1, 'unit_price': 39.90, 'is_checked': true, 'category': 'מוצרי ניקיון', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()});
  } else if (weekNumber == 3) {
    items.add({'id': 'ri_3_006', 'name': 'טונה בשמן 4 יח\'', 'quantity': 2, 'unit_price': 29.90, 'is_checked': true, 'category': 'שימורים', 'checked_by': yuvalUserId, 'checked_at': date.toIso8601String()});
  } else {
    items.add({'id': 'ri_4_006', 'name': 'בשר טחון', 'quantity': 1, 'unit_price': 49.90, 'is_checked': true, 'category': 'בשר ועוף', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
  }

  return items;
}

// ═══════════════════════════════════════════════════════════════════
// LEVI GROUP DATA - Young couple
// ═══════════════════════════════════════════════════════════════════

/// Generate Levi group data with real Firebase UIDs
Map<String, dynamic> generateLeviGroupData(Map<String, String> uids) {
  final danUid = uids[danUserId]!;
  final mayaUid = uids[mayaUserId]!;

  return {
    'id': leviGroupId,
    'name': 'דן ומאיה',
    'type': 'family',
    'description': 'הבית שלנו',
    'image_url': null,
    'created_by': danUid,
    'created_at': DateTime(2024, 9, 1).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'members': {
      danUid: {
        'user_id': danUid,
        'name': 'דן לוי',
        'email': 'dan.levi@demo.com',
        'avatar_url': null,
        'role': 'owner',
        'joined_at': DateTime(2024, 9, 1).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      mayaUid: {
        'user_id': mayaUid,
        'name': 'מאיה לוי',
        'email': 'maya.levi@demo.com',
        'avatar_url': null,
        'role': 'admin',
        'joined_at': DateTime(2024, 9, 1).toIso8601String(),
        'invited_by': danUid,
        'can_start_shopping': true,
      },
    },
    'settings': {
      'notifications': true,
      'low_stock_alerts': true,
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
    'extra_fields': null,
  };
}

// ═══════════════════════════════════════════════════════════════════
// LEVI HOUSEHOLD - Shared lists
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateLeviSharedLists() {
  final now = DateTime.now();
  final lists = <Map<String, dynamic>>[];

  // Active weekly shopping
  lists.add({
    'id': 'levi_weekly_current',
    'name': 'קניות השבוע',
    'updated_date': now.toIso8601String(),
    'created_date': now.subtract(const Duration(days: 1)).toIso8601String(),
    'status': 'active',
    'type': 'supermarket',
    'budget': 600.0,
    'is_shared': true,
    'created_by': mayaUserId,
    'shared_with': [],
    'event_date': null,
    'target_date': now.add(const Duration(days: 3)).toIso8601String(),
    'items': [
      createListItem(id: 'levi_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב'),
      createListItem(id: 'levi_002', name: 'לחם אחיד פרוס', quantity: 1, unitPrice: 7.90, category: 'לחם ומאפים'),
      createListItem(id: 'levi_003', name: 'גבינה צהובה 28% עמק 200 גרם', quantity: 1, unitPrice: 12.90, category: 'מוצרי חלב'),
      createListItem(id: 'levi_004', name: 'עגבניות שרי', quantity: 1, unitPrice: 12.90, category: 'פירות וירקות'),
      createListItem(id: 'levi_005', name: 'אבוקדו', quantity: 3, unitPrice: 6.90, category: 'פירות וירקות'),
      createListItem(id: 'levi_006', name: 'קפה עלית נמס 200 גרם', quantity: 1, unitPrice: 34.90, category: 'קפה ותה'),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    'active_shoppers': [],
    'shared_users': {
      danUserId: {
        'role': 'owner',
        'shared_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'user_name': 'דן לוי',
        'user_email': 'dan.levi@demo.com',
        'can_start_shopping': true,
      },
    },
    'pending_requests': [],
    'is_private': false,
  });

  // Dinner party list
  lists.add({
    'id': 'levi_dinner_party',
    'name': 'ארוחת ערב עם חברים',
    'updated_date': now.toIso8601String(),
    'created_date': now.toIso8601String(),
    'status': 'active',
    'type': 'supermarket',
    'budget': 350.0,
    'is_shared': true,
    'created_by': danUserId,
    'shared_with': [],
    'event_date': now.add(const Duration(days: 5)).toIso8601String(),
    'target_date': now.add(const Duration(days: 4)).toIso8601String(),
    'items': [
      createListItem(id: 'levi_party_001', name: 'שניצל עוף טבעי', quantity: 2, unitPrice: 39.90, category: 'בשר ועוף'),
      createListItem(id: 'levi_party_002', name: 'אורז בסמטי 1 ק"ג', quantity: 1, unitPrice: 15.90, category: 'אורז ופסטה'),
      createListItem(id: 'levi_party_003', name: 'יין אדום', quantity: 2, unitPrice: 45.0, category: 'משקאות'),
      createListItem(id: 'levi_party_004', name: 'שמנת מתוקה 38%', quantity: 2, unitPrice: 9.90, category: 'מוצרי חלב'),
      createListItem(id: 'levi_party_005', name: 'שוקולד פרה מילקה', quantity: 3, unitPrice: 12.90, category: 'חטיפים וממתקים'),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    'active_shoppers': [],
    'shared_users': {
      mayaUserId: {
        'role': 'admin',
        'shared_at': now.toIso8601String(),
        'user_name': 'מאיה לוי',
        'user_email': 'maya.levi@demo.com',
        'can_start_shopping': true,
      },
    },
    'pending_requests': [],
    'is_private': false,
  });

  // One completed list from last week
  final lastWeek = now.subtract(const Duration(days: 7));
  lists.add({
    'id': 'levi_completed_1',
    'name': 'קניות שבועיות',
    'updated_date': lastWeek.add(const Duration(days: 1)).toIso8601String(),
    'created_date': lastWeek.toIso8601String(),
    'status': 'completed',
    'type': 'supermarket',
    'budget': 500.0,
    'is_shared': true,
    'created_by': danUserId,
    'shared_with': [],
    'event_date': null,
    'target_date': lastWeek.add(const Duration(days: 2)).toIso8601String(),
    'items': [
      createListItem(id: 'levi_c1_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: danUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_002', name: 'לחם אחיד פרוס', quantity: 1, unitPrice: 7.90, category: 'לחם ומאפים', isChecked: true, checkedBy: danUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_003', name: 'ביצים חופש L 12 יח\'', quantity: 1, unitPrice: 19.90, category: 'ביצים', isChecked: true, checkedBy: mayaUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_004', name: 'חזה עוף טרי', quantity: 1, unitPrice: 34.90, category: 'בשר ועוף', isChecked: true, checkedBy: mayaUserId, checkedAt: lastWeek),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    'active_shoppers': [],
    'shared_users': {},
    'pending_requests': [],
    'is_private': false,
  });

  return lists;
}

// ═══════════════════════════════════════════════════════════════════
// LEVI HOUSEHOLD - Inventory
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateLeviInventory() {
  final now = DateTime.now();

  return [
    // Basic items for young couple
    {
      'id': 'levi_inv_milk',
      'product_name': 'חלב',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 1,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 4)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 3)).toIso8601String(),
      'purchase_count': 5,
      'emoji': '🥛',
    },
    {
      'id': 'levi_inv_eggs',
      'product_name': 'ביצים',
      'category': 'ביצים',
      'location': 'מקרר',
      'quantity': 6,
      'unit': 'יח\'',
      'min_quantity': 6,
      'expiry_date': now.add(const Duration(days: 14)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 5)).toIso8601String(),
      'purchase_count': 4,
      'emoji': '🥚',
    },
    {
      'id': 'levi_inv_coffee',
      'product_name': 'קפה נמס',
      'category': 'קפה ותה',
      'location': 'ארון יבש',
      'quantity': 1,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 180)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 14)).toIso8601String(),
      'purchase_count': 3,
      'emoji': '☕',
    },
    {
      'id': 'levi_inv_pasta',
      'product_name': 'ספגטי',
      'category': 'אורז ופסטה',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 21)).toIso8601String(),
      'purchase_count': 2,
      'emoji': '🍝',
    },
    {
      'id': 'levi_inv_wine',
      'product_name': 'יין אדום',
      'category': 'משקאות',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'בקבוקים',
      'min_quantity': 1,
      'expiry_date': null,
      'notes': 'לאירועים',
      'is_recurring': false,
      'last_purchased': now.subtract(const Duration(days: 30)).toIso8601String(),
      'purchase_count': 2,
      'emoji': '🍷',
    },
  ];
}

// ═══════════════════════════════════════════════════════════════════
// LEVI HOUSEHOLD - Receipts
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateLeviReceipts() {
  final now = DateTime.now();
  final lastWeek = now.subtract(const Duration(days: 6));

  return [
    {
      'id': 'levi_receipt_1',
      'store_name': 'קניות שבועיות',
      'date': lastWeek.toIso8601String(),
      'created_date': lastWeek.toIso8601String(),
      'total_amount': 89.60,
      'items': [
        {'id': 'lr1_001', 'name': 'חלב תנובה 3% 1 ליטר', 'quantity': 2, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr1_002', 'name': 'לחם אחיד פרוס', 'quantity': 1, 'unit_price': 7.90, 'is_checked': true, 'category': 'לחם ומאפים'},
        {'id': 'lr1_003', 'name': 'ביצים חופש L 12 יח\'', 'quantity': 1, 'unit_price': 19.90, 'is_checked': true, 'category': 'ביצים'},
        {'id': 'lr1_004', 'name': 'חזה עוף טרי', 'quantity': 1, 'unit_price': 34.90, 'is_checked': true, 'category': 'בשר ועוף'},
      ],
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'levi_completed_1',
      'is_virtual': true,
      'created_by': danUserId,
      'household_id': leviHouseholdId,
    },
  ];
}

// ═══════════════════════════════════════════════════════════════════
// TOMER - Single person, active shopper
// ═══════════════════════════════════════════════════════════════════

Map<String, List<Map<String, dynamic>>> generateTomerPrivateLists() {
  final now = DateTime.now();

  return {
    tomerId: [
      // Active: Weekly groceries
      {
        'id': 'tomer_weekly',
        'name': 'קניות שבועיות',
        'updated_date': now.toIso8601String(),
        'created_date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'active',
        'type': 'supermarket',
        'budget': 300.0,
        'is_shared': false,
        'created_by': tomerId,
        'shared_with': [],
        'event_date': null,
        'target_date': now.add(const Duration(days: 2)).toIso8601String(),
        'items': [
          createListItem(id: 'tomer_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 1, unitPrice: 6.90, category: 'מוצרי חלב'),
          createListItem(id: 'tomer_002', name: 'לחם אחיד פרוס', quantity: 1, unitPrice: 7.90, category: 'לחם ומאפים'),
          createListItem(id: 'tomer_003', name: 'יוגורט דנונה בננה', quantity: 4, unitPrice: 4.50, category: 'מוצרי חלב'),
          createListItem(id: 'tomer_004', name: 'בננות', quantity: 1, unitPrice: 7.90, category: 'פירות וירקות'),
          createListItem(id: 'tomer_005', name: 'טונה בשמן 4 יח\'', quantity: 1, unitPrice: 29.90, category: 'שימורים'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Completed: Last week
      {
        'id': 'tomer_completed_1',
        'name': 'קניות שבועיות',
        'updated_date': now.subtract(const Duration(days: 6)).toIso8601String(),
        'created_date': now.subtract(const Duration(days: 8)).toIso8601String(),
        'status': 'completed',
        'type': 'supermarket',
        'budget': 250.0,
        'is_shared': false,
        'created_by': tomerId,
        'shared_with': [],
        'items': [
          createListItem(id: 'tomer_c1_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 1, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_002', name: 'ביצים חופש L 12 יח\'', quantity: 1, unitPrice: 19.90, category: 'ביצים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_003', name: 'פיצה משפחתית', quantity: 2, unitPrice: 34.90, category: 'מוקפאים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_004', name: 'קולה 1.5 ליטר', quantity: 2, unitPrice: 8.90, category: 'משקאות', isChecked: true, checkedBy: tomerId),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
      // Completed: 2 weeks ago
      {
        'id': 'tomer_completed_2',
        'name': 'מכולת קטנה',
        'updated_date': now.subtract(const Duration(days: 13)).toIso8601String(),
        'created_date': now.subtract(const Duration(days: 14)).toIso8601String(),
        'status': 'completed',
        'type': 'supermarket',
        'budget': 150.0,
        'is_shared': false,
        'created_by': tomerId,
        'shared_with': [],
        'items': [
          createListItem(id: 'tomer_c2_001', name: 'חלב תנובה 3% 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c2_002', name: 'לחם אחיד פרוס', quantity: 1, unitPrice: 7.90, category: 'לחם ומאפים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c2_003', name: 'במבה אסם', quantity: 3, unitPrice: 6.90, category: 'חטיפים וממתקים', isChecked: true, checkedBy: tomerId),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],
  };
}

List<Map<String, dynamic>> generateTomerInventory() {
  final now = DateTime.now();

  return [
    // Basic single-person inventory
    {
      'id': 'tomer_inv_milk',
      'product_name': 'חלב',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 1,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 5)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 3)).toIso8601String(),
      'purchase_count': 8,
      'emoji': '🥛',
    },
    {
      'id': 'tomer_inv_eggs',
      'product_name': 'ביצים',
      'category': 'ביצים',
      'location': 'מקרר',
      'quantity': 4,
      'unit': 'יח\'',
      'min_quantity': 4,
      'expiry_date': now.add(const Duration(days: 10)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 6)).toIso8601String(),
      'purchase_count': 6,
      'emoji': '🥚',
    },
    {
      'id': 'tomer_inv_pizza',
      'product_name': 'פיצה מוקפאת',
      'category': 'מוקפאים',
      'location': 'מקפיא',
      'quantity': 3,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 90)).toIso8601String(),
      'notes': 'לארוחות מהירות',
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 6)).toIso8601String(),
      'purchase_count': 5,
      'emoji': '🍕',
    },
    {
      'id': 'tomer_inv_tuna',
      'product_name': 'טונה בשמן',
      'category': 'שימורים',
      'location': 'ארון יבש',
      'quantity': 6,
      'unit': 'יח\'',
      'min_quantity': 4,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 14)).toIso8601String(),
      'purchase_count': 4,
      'emoji': '🐟',
    },
    {
      'id': 'tomer_inv_cola',
      'product_name': 'קולה',
      'category': 'משקאות',
      'location': 'מקרר',
      'quantity': 2,
      'unit': 'בקבוקים',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 180)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 6)).toIso8601String(),
      'purchase_count': 7,
      'emoji': '🥤',
    },
    {
      'id': 'tomer_inv_snacks',
      'product_name': 'במבה',
      'category': 'חטיפים וממתקים',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 90)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 13)).toIso8601String(),
      'purchase_count': 6,
      'emoji': '🥜',
    },
  ];
}

List<Map<String, dynamic>> generateTomerReceipts() {
  final now = DateTime.now();

  return [
    {
      'id': 'tomer_receipt_1',
      'store_name': 'AM:PM',
      'date': now.subtract(const Duration(days: 6)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 6)).toIso8601String(),
      'total_amount': 114.50,
      'items': [
        {'id': 'tr1_001', 'name': 'חלב תנובה 3% 1 ליטר', 'quantity': 1, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr1_002', 'name': 'ביצים חופש L 12 יח\'', 'quantity': 1, 'unit_price': 19.90, 'is_checked': true, 'category': 'ביצים'},
        {'id': 'tr1_003', 'name': 'פיצה משפחתית', 'quantity': 2, 'unit_price': 34.90, 'is_checked': true, 'category': 'מוקפאים'},
        {'id': 'tr1_004', 'name': 'קולה 1.5 ליטר', 'quantity': 2, 'unit_price': 8.90, 'is_checked': true, 'category': 'משקאות'},
      ],
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'tomer_completed_1',
      'is_virtual': true,
      'created_by': tomerId,
      'household_id': tomerHouseholdId,
    },
    {
      'id': 'tomer_receipt_2',
      'store_name': 'שופרסל אקספרס',
      'date': now.subtract(const Duration(days: 13)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 13)).toIso8601String(),
      'total_amount': 42.50,
      'items': [
        {'id': 'tr2_001', 'name': 'חלב תנובה 3% 1 ליטר', 'quantity': 2, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr2_002', 'name': 'לחם אחיד פרוס', 'quantity': 1, 'unit_price': 7.90, 'is_checked': true, 'category': 'לחם ומאפים'},
        {'id': 'tr2_003', 'name': 'במבה אסם', 'quantity': 3, 'unit_price': 6.90, 'is_checked': true, 'category': 'חטיפים וממתקים'},
      ],
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'tomer_completed_2',
      'is_virtual': true,
      'created_by': tomerId,
      'household_id': tomerHouseholdId,
    },
  ];
}

// ═══════════════════════════════════════════════════════════════════
// SHIRAN - New user, rich pantry, no shopping history
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generateShiranInventory() {
  final now = DateTime.now();

  // Rich pantry - just moved in with lots of supplies
  return [
    // Refrigerator - well stocked
    {
      'id': 'shiran_inv_milk',
      'product_name': 'חלב',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 3,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 7)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 1)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🥛',
    },
    {
      'id': 'shiran_inv_cheese',
      'product_name': 'גבינה צהובה',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 21)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 1)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🧀',
    },
    {
      'id': 'shiran_inv_eggs',
      'product_name': 'ביצים',
      'category': 'ביצים',
      'location': 'מקרר',
      'quantity': 12,
      'unit': 'יח\'',
      'min_quantity': 6,
      'expiry_date': now.add(const Duration(days: 21)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 1)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🥚',
    },
    {
      'id': 'shiran_inv_yogurt',
      'product_name': 'יוגורט',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 8,
      'unit': 'יח\'',
      'min_quantity': 4,
      'expiry_date': now.add(const Duration(days: 14)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 1)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
    {
      'id': 'shiran_inv_cottage',
      'product_name': 'קוטג\'',
      'category': 'מוצרי חלב',
      'location': 'מקרר',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 10)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 1)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },

    // Freezer - stocked up
    {
      'id': 'shiran_inv_chicken',
      'product_name': 'חזה עוף',
      'category': 'בשר ועוף',
      'location': 'מקפיא',
      'quantity': 4,
      'unit': 'ק"ג',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 90)).toIso8601String(),
      'notes': 'מחולק לשקיות',
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🍗',
    },
    {
      'id': 'shiran_inv_schnitzel',
      'product_name': 'שניצל עוף',
      'category': 'בשר ועוף',
      'location': 'מקפיא',
      'quantity': 2,
      'unit': 'ק"ג',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 90)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
    {
      'id': 'shiran_inv_ground_beef',
      'product_name': 'בשר טחון',
      'category': 'בשר ועוף',
      'location': 'מקפיא',
      'quantity': 2,
      'unit': 'ק"ג',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 90)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🥩',
    },
    {
      'id': 'shiran_inv_frozen_veggies',
      'product_name': 'ירקות מוקפאים',
      'category': 'מוקפאים',
      'location': 'מקפיא',
      'quantity': 3,
      'unit': 'שקיות',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 180)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🥦',
    },

    // Pantry - very well stocked (just moved in)
    {
      'id': 'shiran_inv_rice',
      'product_name': 'אורז בסמטי',
      'category': 'אורז ופסטה',
      'location': 'ארון יבש',
      'quantity': 4,
      'unit': 'ק"ג',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🍚',
    },
    {
      'id': 'shiran_inv_pasta',
      'product_name': 'ספגטי',
      'category': 'אורז ופסטה',
      'location': 'ארון יבש',
      'quantity': 5,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 730)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🍝',
    },
    {
      'id': 'shiran_inv_ptitim',
      'product_name': 'פתיתים',
      'category': 'אורז ופסטה',
      'location': 'ארון יבש',
      'quantity': 3,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
    {
      'id': 'shiran_inv_tuna',
      'product_name': 'טונה בשמן',
      'category': 'שימורים',
      'location': 'ארון יבש',
      'quantity': 12,
      'unit': 'יח\'',
      'min_quantity': 4,
      'expiry_date': now.add(const Duration(days: 730)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🐟',
    },
    {
      'id': 'shiran_inv_corn',
      'product_name': 'תירס מתוק',
      'category': 'שימורים',
      'location': 'ארון יבש',
      'quantity': 6,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 730)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🌽',
    },
    {
      'id': 'shiran_inv_tomato_paste',
      'product_name': 'רסק עגבניות',
      'category': 'שימורים',
      'location': 'ארון יבש',
      'quantity': 4,
      'unit': 'יח\'',
      'min_quantity': 2,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🍅',
    },
    {
      'id': 'shiran_inv_coffee',
      'product_name': 'קפה נמס',
      'category': 'קפה ותה',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': 'עלית 200 גרם',
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '☕',
    },
    {
      'id': 'shiran_inv_tea',
      'product_name': 'תה ויסוצקי',
      'category': 'קפה ותה',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'קופסאות',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 730)).toIso8601String(),
      'notes': '100 שקיקים',
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🍵',
    },
    {
      'id': 'shiran_inv_sugar',
      'product_name': 'סוכר',
      'category': 'אחר',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'ק"ג',
      'min_quantity': 1,
      'expiry_date': null,
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
    {
      'id': 'shiran_inv_oil',
      'product_name': 'שמן קנולה',
      'category': 'אחר',
      'location': 'ארון יבש',
      'quantity': 2,
      'unit': 'ליטר',
      'min_quantity': 1,
      'expiry_date': now.add(const Duration(days: 365)).toIso8601String(),
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },

    // Cleaning supplies
    {
      'id': 'shiran_inv_toilet_paper',
      'product_name': 'נייר טואלט',
      'category': 'מוצרי ניקיון',
      'location': 'ארון שירות',
      'quantity': 32,
      'unit': 'גלילים',
      'min_quantity': 12,
      'expiry_date': null,
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': '🧻',
    },
    {
      'id': 'shiran_inv_dish_soap',
      'product_name': 'נוזל כלים',
      'category': 'מוצרי ניקיון',
      'location': 'ארון שירות',
      'quantity': 3,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': null,
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
    {
      'id': 'shiran_inv_laundry',
      'product_name': 'אבקת כביסה',
      'category': 'מוצרי ניקיון',
      'location': 'ארון שירות',
      'quantity': 2,
      'unit': 'יח\'',
      'min_quantity': 1,
      'expiry_date': null,
      'notes': null,
      'is_recurring': true,
      'last_purchased': now.subtract(const Duration(days: 2)).toIso8601String(),
      'purchase_count': 1,
      'emoji': null,
    },
  ];
}

// Shiran has one active list (just started using the app)
Map<String, List<Map<String, dynamic>>> generateShiranPrivateLists() {
  final now = DateTime.now();

  return {
    shiranId: [
      // First shopping list ever - just basics
      {
        'id': 'shiran_first_list',
        'name': 'קניות ראשונות',
        'updated_date': now.toIso8601String(),
        'created_date': now.toIso8601String(),
        'status': 'active',
        'type': 'supermarket',
        'budget': 200.0,
        'is_shared': false,
        'created_by': shiranId,
        'shared_with': [],
        'event_date': null,
        'target_date': now.add(const Duration(days: 4)).toIso8601String(),
        'items': [
          createListItem(id: 'shiran_001', name: 'לחם אחיד פרוס', quantity: 2, unitPrice: 7.90, category: 'לחם ומאפים'),
          createListItem(id: 'shiran_002', name: 'עגבניות שרי', quantity: 1, unitPrice: 12.90, category: 'פירות וירקות'),
          createListItem(id: 'shiran_003', name: 'מלפפונים', quantity: 1, unitPrice: 4.90, category: 'פירות וירקות'),
          createListItem(id: 'shiran_004', name: 'בננות', quantity: 1, unitPrice: 7.90, category: 'פירות וירקות'),
        ],
        'template_id': null,
        'format': 'personal',
        'created_from_template': false,
        'active_shoppers': [],
        'shared_users': {},
        'pending_requests': [],
        'is_private': true,
      },
    ],
  };
}

// ═══════════════════════════════════════════════════════════════════
// PENDING REQUESTS (from Noa - Editor)
// ═══════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> generatePendingRequests() {
  final now = DateTime.now();

  return [
    // Pending - waiting for approval
    {
      'id': 'req_pending_001',
      'list_id': 'list_weekly_current',
      'requester_id': noaUserId,
      'type': 'addItem',
      'status': 'pending',
      'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'request_data': {
        'name': 'שוקולד מריר',
        'quantity': 2,
        'unitPrice': 15.90,
        'category': 'חטיפים וממתקים',
      },
      'reviewer_id': null,
      'reviewed_at': null,
      'rejection_reason': null,
      'requester_name': 'נועה כהן',
      'reviewer_name': null,
      'list_name': 'קניות שבועיות',
    },
    // Approved - for history
    {
      'id': 'req_approved_001',
      'list_id': 'list_weekly_current',
      'requester_id': noaUserId,
      'type': 'addItem',
      'status': 'approved',
      'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      'request_data': {
        'name': 'מיץ תפוזים',
        'quantity': 2,
        'unitPrice': 9.90,
        'category': 'משקאות',
      },
      'reviewer_id': ronitUserId,
      'reviewed_at': now.subtract(const Duration(hours: 20)).toIso8601String(),
      'rejection_reason': null,
      'requester_name': 'נועה כהן',
      'reviewer_name': 'רונית כהן',
      'list_name': 'קניות שבועיות',
    },
    // Rejected - for history
    {
      'id': 'req_rejected_001',
      'list_id': 'list_weekly_current',
      'requester_id': noaUserId,
      'type': 'addItem',
      'status': 'rejected',
      'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      'request_data': {
        'name': 'צ\'יפס ענק',
        'quantity': 5,
        'unitPrice': 12.90,
        'category': 'חטיפים וממתקים',
      },
      'reviewer_id': aviUserId,
      'reviewed_at': now.subtract(const Duration(days: 1, hours: 12)).toIso8601String(),
      'rejection_reason': 'יותר מדי חטיפים השבוע',
      'requester_name': 'נועה כהן',
      'reviewer_name': 'אבי כהן',
      'list_name': 'קניות שבועיות',
    },
  ];
}

// ═══════════════════════════════════════════════════════════════════
// FIREBASE EMULATOR API HELPERS
// ═══════════════════════════════════════════════════════════════════

/// Mapping of email -> generated Firebase UID
final Map<String, String> emailToUid = {};

/// Create user in Firebase Auth Emulator and return the generated UID
Future<String?> createAuthUser(String preferredId, String email, String password, String displayName) async {
  // Standard Firebase Auth REST API endpoint
  final url = Uri.parse('http://$authHost/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'displayName': displayName,
      'returnSecureToken': true,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final uid = data['localId'] as String;
    emailToUid[email] = uid;
    print('   ✅ Auth user created: $email (UID: $uid)');
    return uid;
  } else {
    final body = response.body;
    if (body.contains('EMAIL_EXISTS')) {
      print('   ⚠️ Email exists, looking up UID...');
      // Try to get existing user's UID
      final uid = await _getUidByEmail(email);
      if (uid != null) {
        emailToUid[email] = uid;
        return uid;
      }
    } else {
      print('   ❌ Failed to create auth user: ${response.statusCode}');
      print('      Response: $body');
    }
  }
  return null;
}

/// Get UID by email (sign in to get it)
Future<String?> _getUidByEmail(String email) async {
  final url = Uri.parse('http://$authHost/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': demoPassword,
      'returnSecureToken': true,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['localId'] as String?;
  }
  return null;
}

/// Write document to Firestore Emulator
/// Uses Bearer owner token to bypass security rules in emulator
Future<void> writeDocument(String collection, String docId, Map<String, dynamic> data) async {
  final url = Uri.parse(
    'http://$firestoreHost/v1/projects/$projectId/databases/(default)/documents/$collection/$docId',
  );

  final fields = _convertToFirestoreFormat(data);

  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner', // Bypass security rules in emulator
    },
    body: jsonEncode({'fields': fields}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to write $collection/$docId: ${response.body}');
  }
}

/// Write subcollection document
/// Uses Bearer owner token to bypass security rules in emulator
Future<void> writeSubDocument(String parentPath, String docId, Map<String, dynamic> data) async {
  final url = Uri.parse(
    'http://$firestoreHost/v1/projects/$projectId/databases/(default)/documents/$parentPath/$docId',
  );

  final fields = _convertToFirestoreFormat(data);

  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner', // Bypass security rules in emulator
    },
    body: jsonEncode({'fields': fields}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to write $parentPath/$docId: ${response.body}');
  }
}

/// Convert Dart Map to Firestore REST format
Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
  final fields = <String, dynamic>{};

  for (final entry in data.entries) {
    fields[entry.key] = _convertValue(entry.value);
  }

  return fields;
}

dynamic _convertValue(dynamic value) {
  if (value == null) {
    return {'nullValue': null};
  } else if (value is bool) {
    return {'booleanValue': value};
  } else if (value is int) {
    return {'integerValue': value.toString()};
  } else if (value is double) {
    return {'doubleValue': value};
  } else if (value is String) {
    return {'stringValue': value};
  } else if (value is List) {
    return {
      'arrayValue': {
        'values': value.map(_convertValue).toList(),
      },
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': _convertToFirestoreFormat(Map<String, dynamic>.from(value)),
      },
    };
  }
  return {'stringValue': value.toString()};
}

// ═══════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════

void main() async {
  print('═' * 60);
  print('🏠 יוצר דאטה דמו - כל המשתמשים');
  print('═' * 60);
  print('');

  // 📦 טעינת מוצרים מקבצי JSON
  print('━' * 60);
  print('📦 טוען מוצרים מקבצי JSON...');
  print('━' * 60);
  await loadProductsFromJson();
  print('');

  print('📋 משפחת כהן:');
  print('   👨 אבי כהן (אבא) - Owner');
  print('   👩 רונית כהן (אמא) - Admin');
  print('   👦 יובל כהן (בן 18) - Editor + canStartShopping');
  print('   👧 נועה כהן (בת 15) - Editor');
  print('   👤 אלעד כהן (סבא) - Pending invite as Viewer');
  print('');
  print('💑 זוג צעיר - לוי:');
  print('   👨 דן לוי - Owner');
  print('   👩 מאיה לוי - Admin');
  print('');
  print('🧑 בודד - תומר בר:');
  print('   👤 תומר בר - גר לבד, קניות ומזווה פעילים');
  print('');
  print('🆕 משתמש חדש - שירן גל:');
  print('   👤 שירן גל - מזווה עשיר, בלי היסטוריה');
  print('');
  print('📍 Firebase Emulator:');
  print('   Auth: http://$authHost');
  print('   Firestore: http://$firestoreHost');
  print('');

  // Maps to store email -> actual Firebase UID
  final Map<String, String> cohenUids = {};
  final Map<String, String> additionalUids = {};

  try {
    // 1. Create Auth Users - Cohen Family
    print('━' * 60);
    print('👥 יוצר משתמשי Auth - משפחת כהן...');
    print('━' * 60);

    for (final entry in users.entries) {
      final user = entry.value;
      final email = user['email'] as String;
      print('   📧 $email');
      final uid = await createAuthUser(
        entry.key,
        email,
        demoPassword,
        user['name'] as String,
      );
      if (uid != null) {
        cohenUids[entry.key] = uid;
      }
    }
    print('   ✅ משתמשי Auth כהן נוצרו');
    print('');

    // 1b. Create Auth Users - Additional Users
    print('━' * 60);
    print('👥 יוצר משתמשי Auth - משתמשים נוספים...');
    print('━' * 60);

    for (final entry in additionalUsers.entries) {
      final user = entry.value;
      final email = user['email'] as String;
      print('   📧 $email');
      final uid = await createAuthUser(
        entry.key,
        email,
        demoPassword,
        user['name'] as String,
      );
      if (uid != null) {
        additionalUids[entry.key] = uid;
      }
    }
    print('   ✅ משתמשי Auth נוספים נוצרו');
    print('');

    // 2. Create User Documents - Cohen Family (using real UIDs)
    // 🔧 הוספת group_ids כדי שהאפליקציה תמצא את הקבוצות
    print('━' * 60);
    print('📄 יוצר מסמכי משתמשים - משפחת כהן...');
    print('━' * 60);

    for (final entry in users.entries) {
      final uid = cohenUids[entry.key];
      if (uid == null) {
        print('   ⚠️ Skipping ${entry.value['name']} - no UID');
        continue;
      }
      print('   👤 ${entry.value['name']}');
      // Update user data with real UID and group_ids
      final userData = Map<String, dynamic>.from(entry.value);
      userData['id'] = uid;
      // 🔧 הוספת group_ids - משפחת כהן שייכים לקבוצת כהן
      userData['group_ids'] = [groupId];
      await writeDocument('users', uid, userData);
    }
    print('   ✅ מסמכי משתמשים כהן נוצרו');
    print('');

    // 2b. Create User Documents - Additional Users (using real UIDs)
    print('━' * 60);
    print('📄 יוצר מסמכי משתמשים - משתמשים נוספים...');
    print('━' * 60);

    for (final entry in additionalUsers.entries) {
      final uid = additionalUids[entry.key];
      if (uid == null) {
        print('   ⚠️ Skipping ${entry.value['name']} - no UID');
        continue;
      }
      print('   👤 ${entry.value['name']}');
      // Update user data with real UID
      final userData = Map<String, dynamic>.from(entry.value);
      userData['id'] = uid;
      // 🔧 הוספת group_ids - לוי שייכים לקבוצת לוי, תומר ושירן בלי קבוצה
      if (entry.key == danUserId || entry.key == mayaUserId) {
        userData['group_ids'] = [leviGroupId];
      } else {
        userData['group_ids'] = <String>[]; // תומר ושירן - בלי קבוצות
      }
      await writeDocument('users', uid, userData);
    }
    print('   ✅ מסמכי משתמשים נוספים נוצרו');
    print('');

    // 3. Create Cohen Group (with real UIDs)
    print('━' * 60);
    print('👪 יוצר קבוצת משפחת כהן...');
    print('━' * 60);

    final cohenGroupData = generateCohenGroupData(cohenUids);
    print('   📝 ${cohenGroupData['name']}');
    await writeDocument('groups', groupId, cohenGroupData);
    print('   ✅ קבוצת כהן נוצרה');
    print('');

    // 3b. Create Levi Group (with real UIDs)
    print('━' * 60);
    print('💑 יוצר קבוצת לוי...');
    print('━' * 60);

    final leviGroupData = generateLeviGroupData(additionalUids);
    print('   📝 ${leviGroupData['name']}');
    await writeDocument('groups', leviGroupId, leviGroupData);
    print('   ✅ קבוצת לוי נוצרה');
    print('');

    // 4. Create Group Invite (Elad) - with real UIDs
    print('━' * 60);
    print('📨 יוצר הזמנה לאלעד...');
    print('━' * 60);

    final eladInvite = generateEladInvite(cohenUids);
    print('   📧 ${eladInvite['invited_email']}');
    await writeDocument('group_invites', eladInvite['id'] as String, eladInvite);
    print('   ✅ הזמנה נוצרה');
    print('');

    // 5. Create Custom Locations
    print('━' * 60);
    print('📍 יוצר מיקומי אחסון מותאמים...');
    print('━' * 60);

    for (final location in customLocations) {
      print('   ${location['emoji']} ${location['name']}');
      await writeDocument('custom_locations', location['key'] as String, location);
    }
    print('   ✅ מיקומים נוצרו');
    print('');

    // 6. Create Shared Lists (Household) - with real UIDs
    print('━' * 60);
    print('📋 יוצר רשימות משותפות...');
    print('━' * 60);

    final sharedLists = generateSharedLists(cohenUids);
    for (final list in sharedLists) {
      print('   📝 ${list['name']} (${list['status']})');
      await writeSubDocument(
        'households/$householdId/shared_lists',
        list['id'] as String,
        list,
      );
    }
    print('   ✅ ${sharedLists.length} רשימות משותפות נוצרו');
    print('');

    // 7. Create Private Lists
    print('━' * 60);
    print('🔒 יוצר רשימות פרטיות...');
    print('━' * 60);

    final privateLists = generatePrivateLists();
    for (final entry in privateLists.entries) {
      final userId = entry.key;
      final userName = users[userId]?['name'] ?? userId;
      print('   👤 $userName:');

      for (final list in entry.value) {
        print('      📝 ${list['name']}');
        await writeSubDocument(
          'users/$userId/private_lists',
          list['id'] as String,
          list,
        );
      }
    }
    print('   ✅ רשימות פרטיות נוצרו');
    print('');

    // 8. Create Inventory
    print('━' * 60);
    print('🏪 יוצר פריטי מזווה...');
    print('━' * 60);

    final inventory = generateInventoryItems();
    for (final item in inventory) {
      print('   ${item['emoji'] ?? '📦'} ${item['product_name']} (${item['location']})');
      await writeSubDocument(
        'groups/$groupId/inventory',  // 🔧 תיקון: מזווה קבוצתי תחת groups
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${inventory.length} פריטי מזווה נוצרו');
    print('');

    // 9. Create Receipts
    print('━' * 60);
    print('🧾 יוצר קבלות וירטואליות...');
    print('━' * 60);

    final receipts = generateReceipts();
    for (final receipt in receipts) {
      print('   📄 ${receipt['store_name']} - ₪${(receipt['total_amount'] as double).toStringAsFixed(2)}');
      await writeSubDocument(
        'households/$householdId/receipts',
        receipt['id'] as String,
        receipt,
      );
    }
    print('   ✅ ${receipts.length} קבלות נוצרו');
    print('');

    // 10. Add Pending Requests to current list
    print('━' * 60);
    print('📩 יוצר בקשות ממתינות...');
    print('━' * 60);

    final requests = generatePendingRequests();
    // Update the current weekly list with pending requests
    final currentList = sharedLists.firstWhere((l) => l['id'] == 'list_weekly_current');
    currentList['pending_requests'] = requests;
    await writeSubDocument(
      'households/$householdId/shared_lists',
      'list_weekly_current',
      currentList,
    );
    print('   ✅ ${requests.length} בקשות נוספו (pending: 1, approved: 1, rejected: 1)');
    print('');

    // ═══════════════════════════════════════════════════════════════
    // LEVI HOUSEHOLD DATA (Young Couple)
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('💑 יוצר נתוני משפחת לוי...');
    print('━' * 60);

    // Levi Shared Lists
    final leviLists = generateLeviSharedLists();
    for (final list in leviLists) {
      print('   📝 ${list['name']} (${list['status']})');
      await writeSubDocument(
        'households/$leviHouseholdId/shared_lists',
        list['id'] as String,
        list,
      );
    }
    print('   ✅ ${leviLists.length} רשימות משותפות לוי נוצרו');

    // Levi Inventory
    final leviInventory = generateLeviInventory();
    for (final item in leviInventory) {
      await writeSubDocument(
        'groups/$leviGroupId/inventory',  // 🔧 תיקון: מזווה קבוצתי תחת groups
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${leviInventory.length} פריטי מזווה לוי נוצרו');

    // Levi Receipts
    final leviReceipts = generateLeviReceipts();
    for (final receipt in leviReceipts) {
      await writeSubDocument(
        'households/$leviHouseholdId/receipts',
        receipt['id'] as String,
        receipt,
      );
    }
    print('   ✅ ${leviReceipts.length} קבלות לוי נוצרו');
    print('');

    // ═══════════════════════════════════════════════════════════════
    // TOMER DATA (Single Person)
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('🧑 יוצר נתוני תומר בר...');
    print('━' * 60);

    // 🔧 קבלת UID האמיתי של תומר
    final tomerUid = additionalUids[tomerId]!;

    // Tomer Private Lists
    final tomerLists = generateTomerPrivateLists();
    for (final list in tomerLists[tomerId]!) {
      print('   📝 ${list['name']} (${list['status']})');
      await writeSubDocument(
        'users/$tomerUid/private_lists',  // 🔧 שימוש ב-UID אמיתי
        list['id'] as String,
        list,
      );
    }
    print('   ✅ ${tomerLists[tomerId]!.length} רשימות פרטיות תומר נוצרו');

    // Tomer Inventory - מזווה אישי תחת users (אין לו קבוצת משפחה)
    final tomerInventory = generateTomerInventory();
    for (final item in tomerInventory) {
      await writeSubDocument(
        'users/$tomerUid/inventory',  // 🔧 מזווה אישי תחת users
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${tomerInventory.length} פריטי מזווה תומר נוצרו');

    // Tomer Receipts
    final tomerReceipts = generateTomerReceipts();
    for (final receipt in tomerReceipts) {
      await writeSubDocument(
        'users/$tomerUid/receipts',  // 🔧 קבלות תחת users
        receipt['id'] as String,
        receipt,
      );
    }
    print('   ✅ ${tomerReceipts.length} קבלות תומר נוצרו');
    print('');

    // ═══════════════════════════════════════════════════════════════
    // SHIRAN DATA (New User - Rich Pantry, No History)
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('🆕 יוצר נתוני שירן גל...');
    print('━' * 60);

    // 🔧 קבלת UID האמיתי של שירן
    final shiranUid = additionalUids[shiranId]!;

    // Shiran Private Lists (only one active list)
    final shiranLists = generateShiranPrivateLists();
    for (final list in shiranLists[shiranId]!) {
      print('   📝 ${list['name']} (${list['status']})');
      await writeSubDocument(
        'users/$shiranUid/private_lists',  // 🔧 שימוש ב-UID אמיתי
        list['id'] as String,
        list,
      );
    }
    print('   ✅ ${shiranLists[shiranId]!.length} רשימות פרטיות שירן נוצרו');

    // Shiran Inventory (rich pantry!) - מזווה אישי תחת users (אין לה קבוצת משפחה)
    final shiranInventory = generateShiranInventory();
    for (final item in shiranInventory) {
      await writeSubDocument(
        'users/$shiranUid/inventory',  // 🔧 מזווה אישי תחת users
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${shiranInventory.length} פריטי מזווה שירן נוצרו (מזווה עשיר!)');
    print('   📊 אין קבלות - משתמש חדש');
    print('');

    // Summary
    print('═' * 60);
    print('✅ הדאטה נוצר בהצלחה!');
    print('═' * 60);
    print('');
    print('🔐 פרטי התחברות (כל המשתמשים):');
    print('   Password: $demoPassword');
    print('');
    print('   📋 משפחת כהן:');
    print('      avi.cohen@demo.com');
    print('      ronit.cohen@demo.com');
    print('      yuval.cohen@demo.com');
    print('      noa.cohen@demo.com');
    print('');
    print('   💑 זוג לוי:');
    print('      dan.levi@demo.com');
    print('      maya.levi@demo.com');
    print('');
    print('   🧑 תומר בר:');
    print('      tomer.bar@demo.com');
    print('');
    print('   🆕 שירן גל:');
    print('      shiran.gal@demo.com');
    print('');
    print('⚠️ הערה: המחירים הם להמחשה בלבד');
    print('');

  } catch (e, stack) {
    print('');
    print('❌ שגיאה: $e');
    print('');
    print('Stack trace:');
    print(stack);
    exit(1);
  }
}
