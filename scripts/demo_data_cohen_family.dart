// File: scripts/demo_data_cohen_family.dart
//
// Purpose: Create demo data for Cohen family in Firebase Emulator
//
// Run with:
//   dart run scripts/demo_data_cohen_family.dart           # רק יוצר נתונים
//   dart run scripts/demo_data_cohen_family.dart --clean   # מוחק הכל ויוצר מחדש
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

// ═══════════════════════════════════════════════════════════════════
// BUILDING COMMITTEE - "ועד בית רחוב הדקל 15"
// ═══════════════════════════════════════════════════════════════════
const String mosheUserId = 'demo_moshe_vaad_040';
const String saraUserId = 'demo_sara_vaad_041';
const String davidUserId = 'demo_david_vaad_042';
const String michalUserId = 'demo_michal_vaad_043';

const String mosheHouseholdId = 'household_moshe_040';
const String saraHouseholdId = 'household_sara_041';
const String davidHouseholdId = 'household_david_042';
const String michalHouseholdId = 'household_michal_043';

const String buildingGroupId = 'group_dekel_15_building';

// ═══════════════════════════════════════════════════════════════════
// KINDERGARTEN COMMITTEE - "ועד הורים גן שושנים"
// ═══════════════════════════════════════════════════════════════════
const String yaelUserId = 'demo_yael_gan_050';
const String ornaUserId = 'demo_orna_gan_051';
const String ramiUserId = 'demo_rami_gan_052';

const String yaelHouseholdId = 'household_yael_050';
const String ornaHouseholdId = 'household_orna_051';
const String ramiHouseholdId = 'household_rami_052';

const String kindergartenGroupId = 'group_gan_shoshanim';

// ═══════════════════════════════════════════════════════════════════
// WEDDING EVENT - "חתונת ליאור ונועם"
// ═══════════════════════════════════════════════════════════════════
const String liorUserId = 'demo_lior_event_060';
const String noamUserId = 'demo_noam_event_061';
const String eyalUserId = 'demo_eyal_event_062';

const String liorHouseholdId = 'household_lior_060';
const String noamHouseholdId = 'household_noam_061';
const String eyalHouseholdId = 'household_eyal_062';

const String weddingGroupId = 'group_lior_noam_wedding';

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
    'household_id': householdId,
    'household_name': 'משפחת כהן',
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
    'household_id': householdId,
    'household_name': 'משפחת כהן',
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
    'household_id': householdId,
    'household_name': 'משפחת כהן',
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
    'household_id': householdId,
    'household_name': 'משפחת כהן',
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
    'household_id': leviHouseholdId,
    'household_name': 'דן ומאיה',
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
    'household_id': leviHouseholdId,
    'household_name': 'דן ומאיה',
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
    'household_id': tomerHouseholdId,
    'household_name': null,
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
    'household_id': shiranHouseholdId,
    'household_name': null,
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

  // ═══════════════════════════════════════════════════════════════════
  // BUILDING COMMITTEE USERS - ועד בית רחוב הדקל 15
  // ═══════════════════════════════════════════════════════════════════

  // משה גולן - יו"ר ועד הבית (owner)
  mosheUserId: {
    'id': mosheUserId,
    'household_id': mosheHouseholdId,
    'household_name': 'משפחת גולן',
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל'],
    'favorite_products': [],
    'weekly_budget': 1500.0,
    'is_admin': true,
    'family_size': 3,
    'shopping_frequency': 2,
    'shopping_days': [4, 5], // Thursday, Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': '09:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // שרה לוי - גזברית הוועד (admin)
  saraUserId: {
    'id': saraUserId,
    'household_id': saraHouseholdId,
    'household_name': 'משפחת לוי',
    'last_login_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    'preferred_stores': ['רמי לוי', 'יוחננוף'],
    'favorite_products': [],
    'weekly_budget': 1200.0,
    'is_admin': true,
    'family_size': 2,
    'shopping_frequency': 3,
    'shopping_days': [0, 3, 5], // Sunday, Wednesday, Friday
    'has_children': false,
    'share_lists': true,
    'reminder_time': '10:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // דוד כהן - חבר ועד (editor)
  davidUserId: {
    'id': davidUserId,
    'household_id': davidHouseholdId,
    'household_name': 'משפחת כהן',
    'last_login_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'preferred_stores': ['שופרסל'],
    'favorite_products': [],
    'weekly_budget': 1800.0,
    'is_admin': true,
    'family_size': 4,
    'shopping_frequency': 2,
    'shopping_days': [5], // Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // מיכל אברהם - דיירת חדשה (viewer)
  michalUserId: {
    'id': michalUserId,
    'household_id': michalHouseholdId,
    'household_name': 'משפחת פרידמן',
    'last_login_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'preferred_stores': ['AM:PM'],
    'favorite_products': [],
    'weekly_budget': 600.0,
    'is_admin': true,
    'family_size': 1,
    'shopping_frequency': 1,
    'shopping_days': [5], // Friday
    'has_children': false,
    'share_lists': false,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': false,
  },

  // ═══════════════════════════════════════════════════════════════════
  // KINDERGARTEN COMMITTEE USERS - ועד הורים גן שושנים
  // ═══════════════════════════════════════════════════════════════════

  // יעל ברק - יו"ר ועד ההורים (owner)
  yaelUserId: {
    'id': yaelUserId,
    'household_id': yaelHouseholdId,
    'household_name': 'משפחת שמעון',
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל', 'רמי לוי'],
    'favorite_products': [],
    'weekly_budget': 1400.0,
    'is_admin': true,
    'family_size': 4,
    'shopping_frequency': 2,
    'shopping_days': [3, 5], // Wednesday, Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': '08:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // אורנה שלום - גזברית ועד הורים (admin)
  ornaUserId: {
    'id': ornaUserId,
    'household_id': ornaHouseholdId,
    'household_name': 'משפחת רוס',
    'last_login_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    'preferred_stores': ['יוחננוף'],
    'favorite_products': [],
    'weekly_budget': 1600.0,
    'is_admin': true,
    'family_size': 3,
    'shopping_frequency': 3,
    'shopping_days': [0, 3, 5], // Sunday, Wednesday, Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': '09:30',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // רמי דור - חבר ועד הורים (editor)
  ramiUserId: {
    'id': ramiUserId,
    'household_id': ramiHouseholdId,
    'household_name': 'משפחת אברמוביץ',
    'last_login_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'preferred_stores': ['שופרסל'],
    'favorite_products': [],
    'weekly_budget': 1300.0,
    'is_admin': true,
    'family_size': 4,
    'shopping_frequency': 2,
    'shopping_days': [5], // Friday
    'has_children': true,
    'share_lists': true,
    'reminder_time': null,
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // ═══════════════════════════════════════════════════════════════════
  // WEDDING EVENT USERS - חתונת ליאור ונועם
  // ═══════════════════════════════════════════════════════════════════

  // ליאור כץ - החתן (owner)
  liorUserId: {
    'id': liorUserId,
    'household_id': liorHouseholdId,
    'household_name': 'ליאור ונועם',
    'last_login_at': DateTime.now().toIso8601String(),
    'preferred_stores': ['שופרסל', 'רמי לוי'],
    'favorite_products': [],
    'weekly_budget': 1000.0,
    'is_admin': true,
    'family_size': 2,
    'shopping_frequency': 2,
    'shopping_days': [4, 5], // Thursday, Friday
    'has_children': false,
    'share_lists': true,
    'reminder_time': '10:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // נועם שפירא - הכלה (admin)
  noamUserId: {
    'id': noamUserId,
    'household_id': noamHouseholdId,
    'household_name': null,
    'last_login_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    'preferred_stores': ['יוחננוף', 'שופרסל'],
    'favorite_products': [],
    'weekly_budget': 1200.0,
    'is_admin': true,
    'family_size': 2,
    'shopping_frequency': 2,
    'shopping_days': [3, 5], // Wednesday, Friday
    'has_children': false,
    'share_lists': true,
    'reminder_time': '11:00',
    'seen_onboarding': true,
    'seen_tutorial': true,
  },

  // אייל כץ - אח החתן (editor)
  eyalUserId: {
    'id': eyalUserId,
    'household_id': eyalHouseholdId,
    'household_name': 'משפחת גרין',
    'last_login_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'preferred_stores': ['רמי לוי'],
    'favorite_products': [],
    'weekly_budget': 800.0,
    'is_admin': true,
    'family_size': 1,
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
      'voting_alerts': false,
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

/// 📧 הזמנות ממתינות לשירן גל
///
/// שירן קיבלה הזמנות לקבוצות שעדיין לא קיבלה/דחתה
List<Map<String, dynamic>> generateShiranPendingInvites(Map<String, String> uids) {
  final ronitUid = uids[ronitUserId]!;
  final yuvalUid = uids[yuvalUserId]!;

  return [
    // הזמנה למשפחת כהן מרונית
    {
      'id': 'invite_shiran_to_cohen',
      'group_id': groupId,
      'group_name': 'כהן בע"מ',
      'invited_phone': '0504445555',
      'invited_email': 'shiran.gal@demo.com',
      'invited_name': 'שירן גל',
      'role': 'viewer',
      'invited_by': ronitUid,
      'invited_by_name': 'רונית כהן',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'status': 'pending',
      'responded_at': null,
      'accepted_by_user_id': null,
    },
    // הזמנה לקבוצת ספורט מיובל
    {
      'id': 'invite_shiran_to_workout',
      'group_id': 'group_workout_buddies',
      'group_name': 'חברות לספורט',
      'invited_phone': '0504445555',
      'invited_email': 'shiran.gal@demo.com',
      'invited_name': 'שירן גל',
      'role': 'editor',
      'invited_by': yuvalUid,
      'invited_by_name': 'יובל כהן',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'status': 'pending',
      'responded_at': null,
      'accepted_by_user_id': null,
    },
  ];
}

/// 👥 קבוצת החברות של שירן
///
/// קבוצה שבה שירן היא הבעלים עם רונית ונועה כחברות
const String shiranFriendsGroupId = 'group_shiran_friends';

/// 🏋️ קבוצת חברים לספורט
///
/// קבוצה שיובל יצר עם תומר, ויש לה הזמנה ממתינה לשירן
const String workoutBuddiesGroupId = 'group_workout_buddies';

Map<String, dynamic> generateShiranFriendsGroup(Map<String, String> uids) {
  final shiranUid = uids[shiranId]!;
  final ronitUid = uids[ronitUserId]!;
  final noaUid = uids[noaUserId]!;
  final now = DateTime.now();

  return {
    'id': shiranFriendsGroupId,
    'name': 'החברות של שירן',
    'type': 'friends', // GroupType enum value
    'description': 'קבוצה לתכנון פעילויות משותפות',
    'created_at': now.subtract(const Duration(days: 14)).toIso8601String(),
    'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
    'created_by': shiranUid,
    'members': {
      shiranUid: {
        'user_id': shiranUid,
        'name': 'שירן גל',
        'email': 'shiran.gal@demo.com',
        'role': 'owner',
        'joined_at': now.subtract(const Duration(days: 14)).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      ronitUid: {
        'user_id': ronitUid,
        'name': 'רונית כהן',
        'email': 'ronit.cohen@demo.com',
        'role': 'admin',
        'joined_at': now.subtract(const Duration(days: 12)).toIso8601String(),
        'invited_by': shiranUid,
        'can_start_shopping': true,
      },
      noaUid: {
        'user_id': noaUid,
        'name': 'נועה כהן',
        'email': 'noa.cohen@demo.com',
        'role': 'editor',
        'joined_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'invited_by': shiranUid,
        'can_start_shopping': true,
      },
    },
    // GroupSettings - matching the actual model
    'settings': {
      'notifications': true,
      'low_stock_alerts': true,
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
  };
}

/// 🏋️ קבוצת חברים לספורט
///
/// קבוצה שיובל יצר לתכנון אימונים משותפים.
/// יובל הוא הבעלים, תומר חבר, ולשירן יש הזמנה ממתינה.
Map<String, dynamic> generateWorkoutBuddiesGroup(Map<String, String> uids) {
  final yuvalUid = uids[yuvalUserId]!;
  final tomerUid = uids[tomerId]!;
  final now = DateTime.now();

  return {
    'id': workoutBuddiesGroupId,
    'name': 'חברות לספורט',
    'type': 'friends', // GroupType enum value
    'description': 'קבוצה לתיאום אימונים משותפים',
    'created_at': now.subtract(const Duration(days: 21)).toIso8601String(),
    'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
    'created_by': yuvalUid,
    'members': {
      yuvalUid: {
        'user_id': yuvalUid,
        'name': 'יובל כהן',
        'email': 'yuval.cohen@demo.com',
        'role': 'owner',
        'joined_at': now.subtract(const Duration(days: 21)).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      tomerUid: {
        'user_id': tomerUid,
        'name': 'תומר בר',
        'email': 'tomer.bar@demo.com',
        'role': 'editor',
        'joined_at': now.subtract(const Duration(days: 18)).toIso8601String(),
        'invited_by': yuvalUid,
        'can_start_shopping': true,
      },
    },
    // GroupSettings - matching the actual model
    'settings': {
      'notifications': true,
      'low_stock_alerts': true,
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
  };
}

// ═══════════════════════════════════════════════════════════════════
// NEW GROUP TYPES - Building, Kindergarten, Wedding
// ═══════════════════════════════════════════════════════════════════

/// 🏢 קבוצת ועד בית - רחוב הדקל 15
///
/// קבוצה מסוג `building` עם 4 דיירים.
/// כוללת הצבעות על שיפוצים ותקציבים.
Map<String, dynamic> generateBuildingGroup(Map<String, String> uids) {
  final mosheUid = uids[mosheUserId]!;
  final saraUid = uids[saraUserId]!;
  final davidUid = uids[davidUserId]!;
  final michalUid = uids[michalUserId]!;
  final now = DateTime.now();

  return {
    'id': buildingGroupId,
    'name': 'ועד בית רחוב הדקל 15',
    'type': 'building', // GroupType enum value
    'description': 'ניהול הבניין המשותף - 8 דירות',
    'created_at': now.subtract(const Duration(days: 90)).toIso8601String(),
    'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
    'created_by': mosheUid,
    'members': {
      mosheUid: {
        'user_id': mosheUid,
        'name': 'משה גולן',
        'email': 'moshe.golan@demo.com',
        'role': 'owner',
        'joined_at': now.subtract(const Duration(days: 90)).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true, // לא רלוונטי לועד בית
      },
      saraUid: {
        'user_id': saraUid,
        'name': 'שרה לוי',
        'email': 'sara.levi@demo.com',
        'role': 'admin',
        'joined_at': now.subtract(const Duration(days: 88)).toIso8601String(),
        'invited_by': mosheUid,
        'can_start_shopping': true,
      },
      davidUid: {
        'user_id': davidUid,
        'name': 'דוד כהן',
        'email': 'david.cohen.vaad@demo.com',
        'role': 'editor',
        'joined_at': now.subtract(const Duration(days: 60)).toIso8601String(),
        'invited_by': mosheUid,
        'can_start_shopping': false,
      },
      michalUid: {
        'user_id': michalUid,
        'name': 'מיכל אברהם',
        'email': 'michal.avraham@demo.com',
        'role': 'viewer',
        'joined_at': now.subtract(const Duration(days: 30)).toIso8601String(),
        'invited_by': saraUid,
        'can_start_shopping': false,
      },
    },
    // GroupSettings - building type
    'settings': {
      'notifications': true,
      'low_stock_alerts': false, // לא רלוונטי לועד בית
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
    'extra_fields': {
      'address': 'רחוב הדקל 15, תל אביב',
      'apartments_count': 8,
    },
  };
}

/// 🧒 קבוצת ועד הורים - גן שושנים
///
/// קבוצה מסוג `kindergarten` עם 3 הורים.
/// כוללת רשימות "מי מביא" לאירועים.
Map<String, dynamic> generateKindergartenGroup(Map<String, String> uids) {
  final yaelUid = uids[yaelUserId]!;
  final ornaUid = uids[ornaUserId]!;
  final ramiUid = uids[ramiUserId]!;
  final now = DateTime.now();

  return {
    'id': kindergartenGroupId,
    'name': 'ועד הורים גן שושנים',
    'type': 'kindergarten', // GroupType enum value
    'description': 'תיאום אירועים והורים - כיתת הפרפרים',
    'created_at': now.subtract(const Duration(days: 60)).toIso8601String(),
    'updated_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
    'created_by': yaelUid,
    'members': {
      yaelUid: {
        'user_id': yaelUid,
        'name': 'יעל ברק',
        'email': 'yael.barak@demo.com',
        'role': 'owner',
        'joined_at': now.subtract(const Duration(days: 60)).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      ornaUid: {
        'user_id': ornaUid,
        'name': 'אורנה שלום',
        'email': 'orna.shalom@demo.com',
        'role': 'admin',
        'joined_at': now.subtract(const Duration(days: 55)).toIso8601String(),
        'invited_by': yaelUid,
        'can_start_shopping': true,
      },
      ramiUid: {
        'user_id': ramiUid,
        'name': 'רמי דור',
        'email': 'rami.dor@demo.com',
        'role': 'editor',
        'joined_at': now.subtract(const Duration(days: 50)).toIso8601String(),
        'invited_by': yaelUid,
        'can_start_shopping': false,
      },
    },
    // GroupSettings - kindergarten type
    'settings': {
      'notifications': true,
      'low_stock_alerts': false,
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
    'extra_fields': {
      'kindergarten_name': 'גן שושנים',
      'class_name': 'כיתת הפרפרים',
      'teacher_name': 'גננת שרית',
    },
  };
}

/// 🎉 קבוצת אירוע - חתונת ליאור ונועם
///
/// קבוצה מסוג `event` עם 3 מארגנים.
/// כוללת רשימת מתנות והצבעות.
Map<String, dynamic> generateWeddingGroup(Map<String, String> uids) {
  final liorUid = uids[liorUserId]!;
  final noamUid = uids[noamUserId]!;
  final eyalUid = uids[eyalUserId]!;
  final now = DateTime.now();

  return {
    'id': weddingGroupId,
    'name': 'חתונת ליאור ונועם',
    'type': 'event', // GroupType enum value
    'description': 'תכנון החתונה - 15.03.2026',
    'created_at': now.subtract(const Duration(days: 120)).toIso8601String(),
    'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
    'created_by': liorUid,
    'members': {
      liorUid: {
        'user_id': liorUid,
        'name': 'ליאור כץ',
        'email': 'lior.katz@demo.com',
        'role': 'owner',
        'joined_at': now.subtract(const Duration(days: 120)).toIso8601String(),
        'invited_by': null,
        'can_start_shopping': true,
      },
      noamUid: {
        'user_id': noamUid,
        'name': 'נועם שפירא',
        'email': 'noam.shapira@demo.com',
        'role': 'admin',
        'joined_at': now.subtract(const Duration(days: 120)).toIso8601String(),
        'invited_by': liorUid,
        'can_start_shopping': true,
      },
      eyalUid: {
        'user_id': eyalUid,
        'name': 'אייל כץ',
        'email': 'eyal.katz@demo.com',
        'role': 'editor',
        'joined_at': now.subtract(const Duration(days: 90)).toIso8601String(),
        'invited_by': liorUid,
        'can_start_shopping': false,
      },
    },
    // GroupSettings - event type
    'settings': {
      'notifications': true,
      'low_stock_alerts': false,
      'voting_alerts': false,
      'whos_bringing_alerts': true,
    },
    'extra_fields': {
      'event_date': '2026-03-15',
      'venue': 'אולמי הגן, רמת גן',
      'guests_count': 250,
    },
  };
}

/// 🗳️ רשימת הצבעות של ועד הבית
///
/// רשימה עם פריטי הצבעה (voting items) - שיפוץ חדר מדרגות
List<Map<String, dynamic>> generateBuildingVotingList(Map<String, String> uids) {
  final mosheUid = uids[mosheUserId]!;
  final saraUid = uids[saraUserId]!;
  final davidUid = uids[davidUserId]!;
  final michalUid = uids[michalUserId]!;
  final now = DateTime.now();

  return [
    {
      'id': 'building_renovation_vote',
      'name': 'הצבעה: שיפוץ חדר מדרגות',
      'type': 'other',
      'status': 'active',
      'budget': 0.0,
      'is_shared': true,
      'is_private': false,
      'created_by': mosheUid,
      'created_date': now.subtract(const Duration(days: 7)).toIso8601String(),
      'updated_date': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'shared_users': {
        mosheUid: {
          'role': 'owner',
          'user_name': 'משה גולן',
          'user_email': 'moshe.golan@demo.com',
          'shared_at': now.subtract(const Duration(days: 7)).toIso8601String(),
          'can_start_shopping': true,
        },
        saraUid: {
          'role': 'admin',
          'user_name': 'שרה לוי',
          'user_email': 'sara.levi@demo.com',
          'shared_at': now.subtract(const Duration(days: 7)).toIso8601String(),
          'can_start_shopping': true,
        },
        davidUid: {
          'role': 'editor',
          'user_name': 'דוד כהן',
          'user_email': 'david.cohen.vaad@demo.com',
          'shared_at': now.subtract(const Duration(days: 7)).toIso8601String(),
          'can_start_shopping': false,
        },
        michalUid: {
          'role': 'viewer',
          'user_name': 'מיכל אברהם',
          'user_email': 'michal.avraham@demo.com',
          'shared_at': now.subtract(const Duration(days: 7)).toIso8601String(),
          'can_start_shopping': false,
        },
      },
      'items': [
        // פריט הצבעה 1 - אישור תקציב
        {
          'id': 'vote_renovation_budget',
          'name': 'אישור תקציב 50,000₪ לשיפוץ חדר מדרגות',
          'type': 'task',
          'is_checked': false,
          'category': 'הצבעות',
          'notes': 'הצבעה על אישור התקציב לשיפוץ כללי של חדר המדרגות',
          'task_data': {
            'itemType': 'voting',
            'votesFor': [
              {'userId': mosheUid, 'displayName': 'משה גולן'},
              {'userId': saraUid, 'displayName': 'שרה לוי'},
            ],
            'votesAgainst': [
              {'userId': davidUid, 'displayName': 'דוד כהן'},
            ],
            'votesAbstain': [],
            'isAnonymous': false,
            'votingEndDate': now.add(const Duration(days: 7)).toIso8601String(),
          },
          'added_by': mosheUid,
          'added_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        },
        // פריט הצבעה 2 - בחירת צבע (תיקו!)
        {
          'id': 'vote_color_choice',
          'name': 'בחירת צבע לקירות: לבן או בז\'',
          'type': 'task',
          'is_checked': false,
          'category': 'הצבעות',
          'notes': 'הצבעה על צבע הקירות החדש',
          'task_data': {
            'itemType': 'voting',
            'votesFor': [
              {'userId': mosheUid, 'displayName': 'משה גולן'},
            ],
            'votesAgainst': [
              {'userId': saraUid, 'displayName': 'שרה לוי'},
            ],
            'votesAbstain': [
              {'userId': davidUid, 'displayName': 'דוד כהן'},
            ],
            'isAnonymous': false,
            'votingEndDate': now.add(const Duration(days: 3)).toIso8601String(),
          },
          'added_by': saraUid,
          'added_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        },
        // פריט הצבעה 3 - הצבעה אנונימית
        {
          'id': 'vote_cleaning_company',
          'name': 'החלפת חברת הניקיון',
          'type': 'task',
          'is_checked': false,
          'category': 'הצבעות',
          'notes': 'הצבעה אנונימית על החלפת חברת הניקיון',
          'task_data': {
            'itemType': 'voting',
            'votesFor': [
              {'userId': mosheUid},
              {'userId': saraUid},
              {'userId': davidUid},
            ],
            'votesAgainst': [],
            'votesAbstain': [
              {'userId': michalUid},
            ],
            'isAnonymous': true, // הצבעה אנונימית!
            'votingEndDate': now.add(const Duration(days: 14)).toIso8601String(),
          },
          'added_by': davidUid,
          'added_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
      ],
      'pending_requests': [],
    },
  ];
}

/// 🙋 רשימת "מי מביא" של ועד הגן
///
/// רשימה עם פריטי whoBrings - מסיבת פורים
List<Map<String, dynamic>> generateKindergartenPartyList(Map<String, String> uids) {
  final yaelUid = uids[yaelUserId]!;
  final ornaUid = uids[ornaUserId]!;
  final ramiUid = uids[ramiUserId]!;
  final now = DateTime.now();

  return [
    {
      'id': 'gan_purim_party',
      'name': 'מסיבת פורים - מי מביא מה?',
      'type': 'other',
      'status': 'active',
      'budget': 0.0,
      'is_shared': true,
      'is_private': false,
      'created_by': yaelUid,
      'created_date': now.subtract(const Duration(days: 14)).toIso8601String(),
      'updated_date': now.subtract(const Duration(hours: 5)).toIso8601String(),
      'shared_users': {
        yaelUid: {
          'role': 'owner',
          'user_name': 'יעל ברק',
          'user_email': 'yael.barak@demo.com',
          'shared_at': now.subtract(const Duration(days: 14)).toIso8601String(),
          'can_start_shopping': true,
        },
        ornaUid: {
          'role': 'admin',
          'user_name': 'אורנה שלום',
          'user_email': 'orna.shalom@demo.com',
          'shared_at': now.subtract(const Duration(days: 14)).toIso8601String(),
          'can_start_shopping': true,
        },
        ramiUid: {
          'role': 'editor',
          'user_name': 'רמי דור',
          'user_email': 'rami.dor@demo.com',
          'shared_at': now.subtract(const Duration(days: 14)).toIso8601String(),
          'can_start_shopping': false,
        },
      },
      'items': [
        // פריט "מי מביא" 1 - צריך 2 הורים, יש 1
        {
          'id': 'bring_hamantashen',
          'name': 'אוזני המן (30 יח\')',
          'type': 'task',
          'is_checked': false,
          'category': 'מאכלים',
          'notes': 'צריך 2 הורים שיביאו אוזני המן',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 2,
            'volunteers': [
              {'userId': yaelUid, 'displayName': 'יעל ברק'},
            ],
          },
          'added_by': yaelUid,
          'added_at': now.subtract(const Duration(days: 14)).toIso8601String(),
        },
        // פריט "מי מביא" 2 - מלא!
        {
          'id': 'bring_drinks',
          'name': 'שתייה (מיצים, מים)',
          'type': 'task',
          'is_checked': true, // סומן כמלא!
          'category': 'משקאות',
          'notes': 'מישהו כבר התנדב',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 1,
            'volunteers': [
              {'userId': ornaUid, 'displayName': 'אורנה שלום'},
            ],
          },
          'added_by': yaelUid,
          'added_at': now.subtract(const Duration(days: 14)).toIso8601String(),
          'checked_by': ornaUid,
          'checked_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        },
        // פריט "מי מביא" 3 - ריק!
        {
          'id': 'bring_decorations',
          'type': 'task',
          'is_checked': false,
          'category': 'קישוטים',
          'notes': 'מחפשים מתנדב!',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 1,
            'volunteers': [], // אף אחד עדיין!
          },
          'added_by': ornaUid,
          'added_at': now.subtract(const Duration(days: 12)).toIso8601String(),
        },
        // פריט "מי מביא" 4 - צריך 3 הורים
        {
          'id': 'bring_snacks',
          'name': 'חטיפים מלוחים (שקיות גדולות)',
          'type': 'task',
          'is_checked': false,
          'category': 'מאכלים',
          'notes': 'כל הורה מביא שקית אחת גדולה',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 3,
            'volunteers': [
              {'userId': ramiUid, 'displayName': 'רמי דור'},
              {'userId': yaelUid, 'displayName': 'יעל ברק'},
            ],
          },
          'added_by': ramiUid,
          'added_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        },
        // פריט רגיל (לא מי מביא)
        {
          'id': 'party_setup',
          'name': 'להכין את החדר בשעה 9:00',
          'type': 'task',
          'is_checked': false,
          'category': 'משימות',
          'task_data': {
            'itemType': 'task',
            'dueDate': now.add(const Duration(days: 7)).toIso8601String(),
            'assignedTo': yaelUid,
            'priority': 'high',
          },
          'added_by': yaelUid,
          'added_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        },
      ],
      'pending_requests': [],
    },
  ];
}

/// 🎁 רשימת החתונה - מתנות והצבעות
///
/// רשימה משולבת עם מתנות והצבעות
List<Map<String, dynamic>> generateWeddingGiftList(Map<String, String> uids) {
  final liorUid = uids[liorUserId]!;
  final noamUid = uids[noamUserId]!;
  final eyalUid = uids[eyalUserId]!;
  final now = DateTime.now();

  return [
    {
      'id': 'wedding_gift_registry',
      'name': 'רשימת מתנות לחתונה',
      'type': 'event',
      'status': 'active',
      'budget': 0.0,
      'is_shared': true,
      'is_private': false,
      'created_by': liorUid,
      'created_date': now.subtract(const Duration(days: 60)).toIso8601String(),
      'updated_date': now.subtract(const Duration(days: 1)).toIso8601String(),
      'event_date': '2026-03-15',
      'shared_users': {
        liorUid: {
          'role': 'owner',
          'user_name': 'ליאור כץ',
          'user_email': 'lior.katz@demo.com',
          'shared_at': now.subtract(const Duration(days: 60)).toIso8601String(),
          'can_start_shopping': true,
        },
        noamUid: {
          'role': 'admin',
          'user_name': 'נועם שפירא',
          'user_email': 'noam.shapira@demo.com',
          'shared_at': now.subtract(const Duration(days: 60)).toIso8601String(),
          'can_start_shopping': true,
        },
        eyalUid: {
          'role': 'editor',
          'user_name': 'אייל כץ',
          'user_email': 'eyal.katz@demo.com',
          'shared_at': now.subtract(const Duration(days: 55)).toIso8601String(),
          'can_start_shopping': false,
        },
      },
      'items': [
        // מתנה 1 - מישהו לוקח
        {
          'id': 'gift_mixer',
          'name': 'מיקסר מקצועי KitchenAid',
          'type': 'task',
          'is_checked': false,
          'category': 'מטבח',
          'notes': 'צבע: אדום',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 1,
            'volunteers': [
              {'userId': eyalUid, 'displayName': 'אייל כץ'},
            ],
          },
          'added_by': noamUid,
          'added_at': now.subtract(const Duration(days: 55)).toIso8601String(),
        },
        // מתנה 2 - פנוי
        {
          'id': 'gift_vacuum',
          'name': 'שואב אבק רובוטי',
          'type': 'task',
          'is_checked': false,
          'category': 'בית',
          'notes': 'Roomba או דומה',
          'task_data': {
            'itemType': 'whoBrings',
            'neededCount': 1,
            'volunteers': [],
          },
          'added_by': liorUid,
          'added_at': now.subtract(const Duration(days: 50)).toIso8601String(),
        },
        // הצבעה - זמר לחתונה
        {
          'id': 'vote_wedding_singer',
          'name': 'בחירת זמר לחתונה: עומר אדם או שטרוק',
          'type': 'task',
          'is_checked': false,
          'category': 'הצבעות',
          'notes': 'הצבעה על הזמר לאירוע',
          'task_data': {
            'itemType': 'voting',
            'votesFor': [
              {'userId': liorUid, 'displayName': 'ליאור כץ'},
              {'userId': eyalUid, 'displayName': 'אייל כץ'},
            ],
            'votesAgainst': [
              {'userId': noamUid, 'displayName': 'נועם שפירא'},
            ],
            'votesAbstain': [],
            'isAnonymous': false,
            'votingEndDate': now.add(const Duration(days: 30)).toIso8601String(),
          },
          'added_by': liorUid,
          'added_at': now.subtract(const Duration(days: 14)).toIso8601String(),
        },
      ],
      'pending_requests': [],
    },
  ];
}

/// 🔔 התראות למשתמשים קיימים
///
/// יוצר התראות ב-Firestore עם היסטוריה (נקראו/לא נקראו)
Map<String, List<Map<String, dynamic>>> generateNotifications(Map<String, String> uids) {
  final result = <String, List<Map<String, dynamic>>>{};
  final now = DateTime.now();

  // UIDs
  final aviUid = uids[aviUserId];
  final ronitUid = uids[ronitUserId];
  final yuvalUid = uids[yuvalUserId];
  final mosheUid = uids[mosheUserId];
  final yaelUid = uids[yaelUserId];
  final liorUid = uids[liorUserId];

  // התראות לרונית כהן
  if (ronitUid != null && yuvalUid != null) {
    final shiranUid = uids[shiranId];
    result[ronitUid] = [
      // התראה על מלאי נמוך (לא נקראה) - התראת מערכת
      {
        'id': 'notif_ronit_001',
        'user_id': ronitUid,
        'household_id': householdId,
        'type': 'low_stock',
        'title': 'מלאי נמוך',
        'message': 'נגמר הלחם במזווה',
        'action_data': {'itemId': 'inv_bread'},
        'is_read': false,
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'sender_id': null, // System notification
        'sender_name': 'המערכת',
      },
      // התראה על מתנדב חדש (נקראה)
      {
        'id': 'notif_ronit_002',
        'user_id': ronitUid,
        'household_id': householdId,
        'type': 'who_brings_volunteer',
        'title': 'מישהו התנדב!',
        'message': 'שירן התנדבה להביא קינוחים למסיבה',
        'action_data': {'listId': 'friends_party_planning'},
        'is_read': true,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'read_at': now.subtract(const Duration(hours: 20)).toIso8601String(),
        'sender_id': shiranUid,
        'sender_name': 'שירן גל',
      },
    ];
  }

  // התראות לאבי כהן
  if (aviUid != null) {
    result[aviUid] = [
      // מלאי נמוך (לא נקראה) - התראת מערכת
      {
        'id': 'notif_avi_001',
        'user_id': aviUid,
        'household_id': householdId,
        'type': 'low_stock',
        'title': 'מלאי נמוך',
        'message': 'חלב 3% נגמר במזווה',
        'action_data': {'itemId': 'inv_milk_3'},
        'is_read': false,
        'created_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'sender_id': null, // System notification
        'sender_name': 'המערכת',
      },
      // שינוי תפקיד (נקראה)
      {
        'id': 'notif_avi_002',
        'user_id': aviUid,
        'household_id': householdId,
        'type': 'role_changed',
        'title': 'שינוי תפקיד',
        'message': 'התפקיד שלך ברשימה "ציוד למנגל" שונה ל-admin',
        'action_data': {'listId': 'avi_bbq_list'},
        'is_read': true,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'read_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'sender_id': ronitUid,
        'sender_name': 'רונית כהן',
      },
    ];
  }

  // התראות למשה גולן (ועד בית)
  if (mosheUid != null) {
    final davidUid = uids[davidUserId];
    result[mosheUid] = [
      // תיקו בהצבעה! (לא נקראה) - התראת מערכת
      {
        'id': 'notif_moshe_001',
        'user_id': mosheUid,
        'household_id': mosheHouseholdId,
        'type': 'vote_tie',
        'title': 'תיקו בהצבעה',
        'message': 'ההצבעה על "בחירת צבע לקירות" הסתיימה בתיקו',
        'action_data': {
          'listId': 'building_renovation_vote',
          'itemId': 'vote_color_choice',
        },
        'is_read': false,
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'sender_id': null, // System notification
        'sender_name': 'המערכת',
      },
      // הצבעה חדשה (נקראה)
      {
        'id': 'notif_moshe_002',
        'user_id': mosheUid,
        'household_id': mosheHouseholdId,
        'type': 'new_vote',
        'title': 'הצבעה חדשה',
        'message': 'דוד הצביע נגד בנושא אישור התקציב',
        'action_data': {
          'listId': 'building_renovation_vote',
          'itemId': 'vote_renovation_budget',
        },
        'is_read': true,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'read_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'sender_id': davidUid,
        'sender_name': 'דוד כהן',
      },
    ];
  }

  // התראות ליעל ברק (ועד גן)
  if (yaelUid != null && uids[ornaUserId] != null) {
    final ornaUid = uids[ornaUserId];
    result[yaelUid] = [
      // מתנדב חדש (לא נקראה)
      {
        'id': 'notif_yael_001',
        'user_id': yaelUid,
        'household_id': yaelHouseholdId,
        'type': 'who_brings_volunteer',
        'title': 'מתנדב חדש!',
        'message': 'אורנה התנדבה להביא שתייה למסיבת פורים',
        'action_data': {
          'listId': 'gan_purim_party',
          'itemId': 'bring_drinks',
        },
        'is_read': false,
        'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'sender_id': ornaUid,
        'sender_name': 'אורנה שלום',
      },
    ];
  }

  // התראות לליאור כץ (חתונה)
  if (liorUid != null && uids[noamUserId] != null) {
    final noamUid = uids[noamUserId];
    final eyalUid = uids[eyalUserId];
    result[liorUid] = [
      // הצבעה חדשה (לא נקראה)
      {
        'id': 'notif_lior_001',
        'user_id': liorUid,
        'household_id': liorHouseholdId,
        'type': 'new_vote',
        'title': 'הצבעה חדשה',
        'message': 'נועם הצביעה נגד בבחירת הזמר',
        'action_data': {
          'listId': 'wedding_gift_registry',
          'itemId': 'vote_wedding_singer',
        },
        'is_read': false,
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'sender_id': noamUid,
        'sender_name': 'נועם רוזן',
      },
      // מתנדב למתנה (נקראה)
      {
        'id': 'notif_lior_002',
        'user_id': liorUid,
        'household_id': liorHouseholdId,
        'type': 'who_brings_volunteer',
        'title': 'מישהו לוקח מתנה!',
        'message': 'אייל לוקח את המיקסר מרשימת המתנות',
        'action_data': {
          'listId': 'wedding_gift_registry',
          'itemId': 'gift_mixer',
        },
        'is_read': true,
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'read_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'sender_id': eyalUid,
        'sender_name': 'אייל דוד',
      },
    ];
  }

  return result;
}

/// 📋 רשימות משותפות של קבוצת החברות
///
/// רשימות שהחברות משתפות ביניהן
List<Map<String, dynamic>> generateFriendsGroupLists(Map<String, String> uids) {
  final shiranUid = uids[shiranId]!;
  final ronitUid = uids[ronitUserId]!;
  final noaUid = uids[noaUserId]!;
  final now = DateTime.now();

  return [
    // רשימה של שירן - יום כיף בנות
    {
      'id': 'friends_spa_day',
      'name': 'יום כיף בנות',
      'type': 'other',
      'status': 'active',
      'budget': 300.0,
      'is_shared': true,
      'is_private': false,
      'created_by': shiranUid,
      'created_date': now.subtract(const Duration(days: 7)).toIso8601String(),
      'updated_date': now.subtract(const Duration(days: 1)).toIso8601String(),
      'shared_users': {
        shiranUid: {
          'role': 'owner',
          'user_name': 'שירן גל',
          'user_email': 'shiran.gal@demo.com',
          'shared_at': now.subtract(const Duration(days: 7)).toIso8601String(),
          'can_start_shopping': true,
        },
        ronitUid: {
          'role': 'admin',
          'user_name': 'רונית כהן',
          'user_email': 'ronit.cohen@demo.com',
          'shared_at': now.subtract(const Duration(days: 6)).toIso8601String(),
          'can_start_shopping': true,
        },
        noaUid: {
          'role': 'editor',
          'user_name': 'נועה כהן',
          'user_email': 'noa.cohen@demo.com',
          'shared_at': now.subtract(const Duration(days: 5)).toIso8601String(),
          'can_start_shopping': true,
        },
      },
      'items': [
        {
          'id': 'spa_item_1',
          'name': 'קרם שיזוף',
          'quantity': 1,
          'unit': 'יח\'',
          'is_checked': false,
          'added_by': shiranUid,
        },
        {
          'id': 'spa_item_2',
          'name': 'חטיפים בריאים',
          'quantity': 2,
          'unit': 'שקיות',
          'is_checked': true,
          'added_by': ronitUid,
        },
        {
          'id': 'spa_item_3',
          'name': 'מים בתוספת מינרלים 600 מל',
          'quantity': 6,
          'unit': 'בקבוקים',
          'is_checked': false,
          'added_by': noaUid,
        },
        {
          'id': 'spa_item_4',
          'name': 'מגב פטנט 40 ס"מ יחידה',
          'quantity': 3,
          'unit': 'יח\'',
          'is_checked': false,
          'added_by': shiranUid,
        },
      ],
      'pending_requests': [],
    },
    // רשימה של רונית - מתכננות מסיבה
    {
      'id': 'friends_party_planning',
      'name': 'מתכננות מסיבה',
      'type': 'party',
      'status': 'active',
      'budget': 500.0,
      'is_shared': true,
      'is_private': false,
      'created_by': ronitUid,
      'created_date': now.subtract(const Duration(days: 3)).toIso8601String(),
      'updated_date': now.subtract(const Duration(hours: 5)).toIso8601String(),
      'shared_users': {
        ronitUid: {
          'role': 'owner',
          'user_name': 'רונית כהן',
          'user_email': 'ronit.cohen@demo.com',
          'shared_at': now.subtract(const Duration(days: 3)).toIso8601String(),
          'can_start_shopping': true,
        },
        shiranUid: {
          'role': 'admin',
          'user_name': 'שירן גל',
          'user_email': 'shiran.gal@demo.com',
          'shared_at': now.subtract(const Duration(days: 2)).toIso8601String(),
          'can_start_shopping': true,
        },
        noaUid: {
          'role': 'editor',
          'user_name': 'נועה כהן',
          'user_email': 'noa.cohen@demo.com',
          'shared_at': now.subtract(const Duration(days: 2)).toIso8601String(),
          'can_start_shopping': true,
        },
      },
      'items': [
        {
          'id': 'party_item_1',
          'quantity': 20,
          'unit': 'יח\'',
          'is_checked': true,
          'added_by': ronitUid,
        },
        {
          'id': 'party_item_2',
          'quantity': 5,
          'unit': 'יח\'',
          'is_checked': false,
          'added_by': shiranUid,
        },
        {
          'id': 'party_item_3',
          'name': 'כוסות חד פעמיות',
          'quantity': 30,
          'unit': 'יח\'',
          'is_checked': true,
          'added_by': noaUid,
        },
        {
          'id': 'party_item_4',
          'name': 'צלחות חד פעמיות',
          'quantity': 30,
          'unit': 'יח\'',
          'is_checked': false,
          'added_by': ronitUid,
        },
        {
          'id': 'party_item_5',
          'name': 'עוגה',
          'quantity': 1,
          'unit': 'יח\'',
          'is_checked': false,
          'added_by': shiranUid,
        },
        // 🎂 פריט "מי מביא" - קינוחים למסיבה
        {
          'id': 'party_item_6',
          'name': 'קינוחים',
          'quantity': 1,
          'unit': 'מגש',
          'is_checked': false,
          'added_by': ronitUid,
          'item_data': {
            'itemType': 'whoBrings',
            'neededCount': 1,
            'volunteers': [
              {'userId': shiranUid, 'displayName': 'שירן גל'},
            ],
          },
          'added_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
      ],
      'pending_requests': [],
    },
  ];
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM LOCATIONS
// ═══════════════════════════════════════════════════════════════════

final List<Map<String, dynamic>> customLocations = [
  {
    'key': 'service_cabinet',
    'name': 'ארון שירות',
    'emoji': '🧹',
  },
  {
    'key': 'bathroom_cabinet',
    'name': 'ארון אמבטיה',
    'emoji': '🛁',
  },
  {
    'key': 'storage_room',
    'name': 'מחסן',
    'emoji': '📦',
  },
  {
    'key': 'medicine_cabinet',
    'name': 'ארון תרופות',
    'emoji': '💊',
  },
];

// ═══════════════════════════════════════════════════════════════════
// SAMPLE PRODUCTS (from catalog with realistic prices)
// ═══════════════════════════════════════════════════════════════════

// Note: Prices are for illustration only
final List<Map<String, dynamic>> sampleProducts = [
  // Dairy
  {'name': 'חלב מועשר1% בקבוק 1 ליטר', 'category': 'מוצרי חלב', 'price': 6.90, 'barcode': '7290000000001'},
  {'name': 'גבינה צהובה נעם 22% 200 ג', 'category': 'מוצרי חלב', 'price': 12.90, 'barcode': '7290000000002'},
  {'name': 'יוגורט דנונה בננה', 'category': 'מוצרי חלב', 'price': 4.50, 'barcode': '7290000000003'},
  {'name': 'קוטג\' תנובה 5% 250 גרם', 'category': 'מוצרי חלב', 'price': 8.90, 'barcode': '7290000000004'},
  {'name': 'שמנת מתוקה להקצפה32% 250', 'category': 'מוצרי חלב', 'price': 9.90, 'barcode': '7290000000005'},

  // Bread & Bakery
  {'name': 'חלה פרוסה 500 גר ארוז231', 'category': 'לחם ומאפים', 'price': 7.90, 'barcode': '7290000000010'},
  {'name': 'חלה מתוקה', 'category': 'לחם ומאפים', 'price': 12.90, 'barcode': '7290000000011'},
  {'name': 'פיתה דרוזית גדולה', 'category': 'לחם ומאפים', 'price': 8.90, 'barcode': '7290000000012'},
  {'name': 'לחמניות המבורגר 4 יח\'', 'category': 'לחם ומאפים', 'price': 11.90, 'barcode': '7290000000013'},

  // Meat & Poultry
  {'name': 'חזה דקדק טרי ארוז שלי', 'category': 'בשר ועוף', 'price': 34.90, 'barcode': '7290000000020'},
  {'name': 'שניצל גונגל 700 גרם', 'category': 'בשר ועוף', 'price': 39.90, 'barcode': '7290000000021'},
  {'name': 'כרעיים עוף', 'category': 'בשר ועוף', 'price': 24.90, 'barcode': '7290000000022'},
  {'name': 'בשר בקר טחון חלק', 'category': 'בשר ועוף', 'price': 49.90, 'barcode': '7290000000023'},

  // Fruits & Vegetables
  {'name': 'תפוח עץ', 'category': 'פירות וירקות', 'price': 8.90, 'barcode': '7290000000030'},
  {'name': 'בננה', 'category': 'פירות וירקות', 'price': 7.90, 'barcode': '7290000000031'},
  {'name': 'עגבניה שרי', 'category': 'פירות וירקות', 'price': 12.90, 'barcode': '7290000000032'},
  {'name': 'מלפפון', 'category': 'פירות וירקות', 'price': 4.90, 'barcode': '7290000000033'},
  {'name': 'בצל יבש', 'category': 'פירות וירקות', 'price': 3.90, 'barcode': '7290000000034'},
  {'name': 'גזר', 'category': 'פירות וירקות', 'price': 4.90, 'barcode': '7290000000035'},
  {'name': 'תפוחי אדמה', 'category': 'פירות וירקות', 'price': 5.90, 'barcode': '7290000000036'},
  {'name': 'אבוקדו', 'category': 'פירות וירקות', 'price': 6.90, 'barcode': '7290000000037'},

  // Snacks & Sweets
  {'name': 'ביסלי פלאפל 200 גרם', 'category': 'חטיפים וממתקים', 'price': 8.90, 'barcode': '7290000000040'},
  {'name': 'במבה 2510 גרם', 'category': 'חטיפים וממתקים', 'price': 6.90, 'barcode': '7290000000041'},
  {'name': 'שוקולד פרה מילקה', 'category': 'חטיפים וממתקים', 'price': 12.90, 'barcode': '7290000000042'},
  {'name': 'עוגיות אוראו', 'category': 'חטיפים וממתקים', 'price': 14.90, 'barcode': '7290000000043'},

  // Drinks
  {'name': 'מיץ אשכוליות אדומות 1 ל'', 'category': 'משקאות', 'price': 9.90, 'barcode': '7290000000050'},
  {'name': 'קוקה קולה בקבוק 1.5 ליטר', 'category': 'משקאות', 'price': 8.90, 'barcode': '7290000000051'},
  {'name': 'מים בתוספת מינרלים 600 מל', 'category': 'משקאות', 'price': 3.90, 'barcode': '7290000000052'},

  // Cleaning
  {'name': 'נוזל כלים פיירי', 'category': 'מוצרי ניקיון', 'price': 12.90, 'barcode': '7290000000060'},
  {'name': 'סיליט ספרי אקונומיקה750 מ', 'category': 'מוצרי ניקיון', 'price': 19.90, 'barcode': '7290000000061'},
  {'name': 'נייר טואלט דו שכבתי48XPO', 'category': 'מוצרי ניקיון', 'price': 39.90, 'barcode': '7290000000062'},

  // Hygiene
  {'name': 'הד&שולדרס שמפו קלאסי625 מ', 'category': 'היגיינה וטיפוח', 'price': 24.90, 'barcode': '7290000000070'},
  {'name': 'משחת שיניים דואלקר 275', 'category': 'היגיינה וטיפוח', 'price': 12.90, 'barcode': '7290000000071'},
  {'name': 'אל סבון לפני השינה1 ליטר', 'category': 'היגיינה וטיפוח', 'price': 9.90, 'barcode': '7290000000072'},

  // Rice & Pasta
  {'name': 'אורז בסמטי טילדה 1 ק"ג', 'category': 'אורז ופסטה', 'price': 15.90, 'barcode': '7290000000080'},
  {'name': 'ספגטי מס 5 מוריני 500 ג', 'category': 'אורז ופסטה', 'price': 8.90, 'barcode': '7290000000081'},
  {'name': 'פתיתים טבעות 500 גרם', 'category': 'אורז ופסטה', 'price': 9.90, 'barcode': '7290000000082'},

  // Canned goods
  {'name': 'טונה בשמן 4 יח\'', 'category': 'שימורים', 'price': 29.90, 'barcode': '7290000000090'},
  {'name': 'גרעיני תירס מתוק 320 גרם', 'category': 'שימורים', 'price': 7.90, 'barcode': '7290000000091'},
  {'name': 'רסק עגבניות', 'category': 'שימורים', 'price': 6.90, 'barcode': '7290000000092'},

  // Frozen
  {'name': 'שניצל ברוקולי טבעול 564', 'category': 'מוקפאים', 'price': 29.90, 'barcode': '7290000000100'},
  {'name': 'שניצל תירס 1.25 קג', 'category': 'מוקפאים', 'price': 34.90, 'barcode': '7290000000101'},
  {'name': 'גלידה קרמיסימו ריבת חלב 1.33 ליטר', 'category': 'מוקפאים', 'price': 39.90, 'barcode': '7290000000102'},

  // Eggs
  {'name': 'ביציםL שופרסל 12'', 'category': 'ביצים', 'price': 19.90, 'barcode': '7290000000110'},

  // Coffee & Tea
  {'name': 'קפה נמס עלית 50 גרם', 'category': 'קפה ותה', 'price': 34.90, 'barcode': '7290000000120'},
  {'name': 'חליטת תה סאמר בוקט 25 שק', 'category': 'קפה ותה', 'price': 19.90, 'barcode': '7290000000121'},

  // Pharmacy/Medicine
  {'name': 'אקמול 500 מ"ג 20 טבליות', 'category': 'תרופות', 'price': 14.90, 'barcode': '7290000000130'},
  {'name': 'נורופן 400 מ"ג 20 טבליות', 'category': 'תרופות', 'price': 24.90, 'barcode': '7290000000131'},
  {'name': 'ויטמין C 1000 מ"ג 100 טבליות', 'category': 'תרופות', 'price': 39.90, 'barcode': '7290000000132'},
  {'name': 'תחבושות פלסטר 20 יח'', 'category': 'תרופות', 'price': 12.90, 'barcode': '7290000000133'},
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
    'is_checked': isChecked,
    'category': category,
    'notes': null,
    'image_url': null,
    'product_data': {
      'quantity': quantity,
      'unit_price': unitPrice,
      'barcode': barcode,
      'unit': 'יח\'',
    },
    'task_data': null,
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
      createListItem(id: 'item_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 3, unitPrice: 6.90, category: 'מוצרי חלב'),
      createListItem(id: 'item_002', name: 'גבינה צהובה נעם 22% 200 ג', quantity: 2, unitPrice: 10.0, category: 'מוצרי חלב'),
      createListItem(id: 'item_003', name: 'לחם כפרי ללת"ס700 גרם', quantity: 2, unitPrice: 22.9, category: 'לחם ומאפים'),
      createListItem(id: 'item_004', name: 'ביציםL שופרסל 12', quantity: 1, unitPrice: 22.9, category: 'ביצים'),
      createListItem(id: 'item_005', name: 'חזה דקדק טרי ארוז שלי', quantity: 2, unitPrice: 22.9, category: 'בשר ועוף'),
      createListItem(id: 'item_006', name: 'תפוח עץ', quantity: 1, unitPrice: 44.9, category: 'פירות וירקות'),
      createListItem(id: 'item_007', name: 'בננה', quantity: 1, unitPrice: 44.9, category: 'פירות וירקות'),
      createListItem(id: 'item_008', name: 'עגבניה שרי', quantity: 2, unitPrice: 44.9, category: 'פירות וירקות'),
      createListItem(id: 'item_009', name: 'מלפפון', quantity: 1, unitPrice: 4.90, category: 'פירות וירקות'),
    ],
    'template_id': null,
    'format': 'shared',
    'created_from_template': false,
    // 🛒 Active shopping session - Yuval is shopping now!
    'active_shoppers': [
      {
        'user_id': yuvalUid,
        'joined_at': now.subtract(const Duration(minutes: 15)).toIso8601String(),
        'is_starter': true,
        'is_active': true,
      },
    ],
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
    'type': 'event',
    'budget': 3000.0,
    'is_shared': true,
    'created_by': ronitUid,
    'shared_with': [],
    'event_date': pesach2026.toIso8601String(),
    'target_date': pesach2026.subtract(const Duration(days: 7)).toIso8601String(),
    'items': [
      createListItem(id: 'pesach_001', name: 'קמח מצה', quantity: 5, unitPrice: 45.0, category: 'כשרות לפסח'),
      createListItem(id: 'pesach_002', name: 'דרום יין לבן יבש 750 מל', quantity: 4, unitPrice: 35.0, category: 'כשרות לפסח'),
      createListItem(id: 'pesach_004', name: 'קמח מצה', quantity: 2, unitPrice: 18.0, category: 'כשרות לפסח'),
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
  for (var weekAgo = 1; weekAgo <= 13; weekAgo++) {
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
    // מוצרים אמיתיים מהקטלוג:
    createListItem(id: 'w${weekNumber}_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 2 + (weekNumber % 2), unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_002', name: 'לחם כפרי ללת"ס700 גרם', quantity: 2, unitPrice: 10.0, category: 'לחם ומאפים', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_003', name: 'ביציםL שופרסל 12', quantity: 1, unitPrice: 10.0, category: 'ביצים', isChecked: true, checkedBy: aviUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_004', name: 'בננה', quantity: 1, unitPrice: 14.09, category: 'פירות וירקות', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt),
    createListItem(id: 'w${weekNumber}_005', name: 'עגבניה שרי', quantity: 1 + weekNumber, unitPrice: 14.09, category: 'פירות וירקות', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt),
  ];

  // Add week-specific items (מוצרים מהקטלוג)
  if (weekNumber == 1) {
    baseItems.add(createListItem(id: 'w1_006', name: 'שניצל תירס 1.25 קג', quantity: 2, unitPrice: 39.90, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
  } else if (weekNumber == 2) {
    baseItems.add(createListItem(id: 'w2_006', name: 'חזה דקדק טרי ארוז שלי', quantity: 3, unitPrice: 51.9, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
    baseItems.add(createListItem(id: 'w2_007', name: 'נייר טואלט דו שכבתי48XPO', quantity: 1, unitPrice: 51.9, category: 'מוצרי ניקיון', isChecked: true, checkedBy: ronitUid, checkedAt: completedAt));
  } else if (weekNumber == 3) {
    baseItems.add(createListItem(id: 'w3_006', name: 'טונה בשמן ויליגר1404 גרם', quantity: 2, unitPrice: 45.9, category: 'שימורים', isChecked: true, checkedBy: yuvalUid, checkedAt: completedAt));
  } else {
    baseItems.add(createListItem(id: 'w4_006', name: 'בשר בקר טחון חלק', quantity: 1, unitPrice: 49.90, category: 'בשר ועוף', isChecked: true, checkedBy: aviUid, checkedAt: completedAt));
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
          createListItem(id: 'avi_bbq_001', name: 'סטייק אנטריקוט', quantity: 2, unitPrice: 120.0, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_002', name: 'כנפיים עוף', quantity: 2, unitPrice: 29.90, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_003', name: 'קבב', quantity: 1, unitPrice: 45.0, category: 'בשר ועוף'),
          createListItem(id: 'avi_bbq_004', name: 'פחמים לגריל', quantity: 2, unitPrice: 35.0, category: 'ציוד מנגל'),
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
          createListItem(id: 'avi_car_002', name: 'מגב פטנט 40 ס"מ יחידה', quantity: 1, unitPrice: 65.0, category: 'רכב', isChecked: true, checkedBy: aviUserId),
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
          createListItem(id: 'ronit_pharm_002', name: 'ויטמין C 1000 מ"ג 100 טבליות', quantity: 1, unitPrice: 39.90, category: 'תרופות'),
          createListItem(id: 'ronit_pharm_003', name: 'תחבושות פלסטר 20 יח'', quantity: 1, unitPrice: 12.90, category: 'תרופות'),
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
          createListItem(id: 'yuval_snack_001', name: 'ביסלי פלאפל 200 גרם', quantity: 3, unitPrice: 8.90, category: 'חטיפים וממתקים'),
          createListItem(id: 'yuval_snack_002', name: 'במבה 2510 גרם', quantity: 3, unitPrice: 6.90, category: 'חטיפים וממתקים'),
          createListItem(id: 'yuval_snack_003', name: 'קוקה קולה בקבוק 1.5 ליטר', quantity: 4, unitPrice: 21.5, category: 'משקאות'),
          createListItem(id: 'yuval_snack_004', name: 'שניצל תירס 1.25 קג', quantity: 2, unitPrice: 21.5, category: 'מוקפאים'),
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
    // הוסרו: barcode, price, brand - לא קיימים במודל InventoryItem
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
    final expiryDays = config['expiryDays'];
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
  for (var weekAgo = 1; weekAgo <= 13; weekAgo++) {
    final date = now.subtract(Duration(days: weekAgo * 7 - 1));
    final items = _generateReceiptItems(weekAgo, date);
    final total = items.fold<double>(0, (sum, item) => sum + (item['quantity'] as int) * (item['unit_price'] as double));

    receipts.add({
      'id': 'receipt_week_$weekAgo',
      'store_name': weekAgo <= 3 ? 'שופרסל דיל' :
                  weekAgo <= 7 ? 'רמי לוי' :
                  weekAgo <= 10 ? 'יוחננוף' : 'שופרסל דיל',
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
    {'id': 'ri_${weekNumber}_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2 + (weekNumber % 2), 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_002', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'לחם ומאפים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_003', 'name': 'ביציםL שופרסל 12'', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'ביצים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_004', 'name': 'בננה', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'פירות וירקות', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()},
    {'id': 'ri_${weekNumber}_005', 'name': 'עגבניה שרי', 'quantity': 1 + weekNumber, 'unit_price': 12.9, 'is_checked': true, 'category': 'פירות וירקות', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()},
  ];

  final mod = ((weekNumber - 1) % 4) + 1;
  if (mod == 1) {
    items.add({'id': 'ri_\${weekNumber}_006', 'name': 'חזה דקדק טרי ארוז שלי', 'quantity': 2, 'unit_price': 44.9, 'is_checked': true, 'category': 'בשר ודגים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
    items.add({'id': 'ri_\${weekNumber}_007', 'name': 'ספגטי מס 5 מוריני 500 ג', 'quantity': 2, 'unit_price': 8.9, 'is_checked': true, 'category': 'אורז ופסטה', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()});
  } else if (mod == 2) {
    items.add({'id': 'ri_\${weekNumber}_006', 'name': 'בשר בקר טחון חלק', 'quantity': 1, 'unit_price': 39.9, 'is_checked': true, 'category': 'בשר ודגים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
    items.add({'id': 'ri_\${weekNumber}_007', 'name': 'נייר טואלט דו שכבתי48XPO', 'quantity': 1, 'unit_price': 45.9, 'is_checked': true, 'category': 'מוצרי ניקיון', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()});
  } else if (mod == 3) {
    items.add({'id': 'ri_\${weekNumber}_006', 'name': 'טונה בשמן ויליגר1404 גרם', 'quantity': 2, 'unit_price': 25.9, 'is_checked': true, 'category': 'בשר ודגים', 'checked_by': yuvalUserId, 'checked_at': date.toIso8601String()});
    items.add({'id': 'ri_\${weekNumber}_007', 'name': 'אורז בסמטי טילדה 1 ק"ג', 'quantity': 2, 'unit_price': 24.0, 'is_checked': true, 'category': 'אורז ופסטה', 'checked_by': ronitUserId, 'checked_at': date.toIso8601String()});
  } else {
    items.add({'id': 'ri_\${weekNumber}_006', 'name': 'שניצל גונגל 700 גרם', 'quantity': 2, 'unit_price': 46.9, 'is_checked': true, 'category': 'בשר ודגים', 'checked_by': aviUserId, 'checked_at': date.toIso8601String()});
    items.add({'id': 'ri_\${weekNumber}_007', 'name': 'גרעיני תירס מתוק 320 גרם', 'quantity': 2, 'unit_price': 6.9, 'is_checked': true, 'category': 'שימורים', 'checked_by': noaUserId, 'checked_at': date.toIso8601String()});
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
      createListItem(id: 'levi_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב'),
      createListItem(id: 'levi_002', name: 'לחם כפרי ללת"ס700 גרם', quantity: 1, unitPrice: 10.0, category: 'לחם ומאפים'),
      createListItem(id: 'levi_003', name: 'גבינה צהובה נעם 22% 200 ג', quantity: 1, unitPrice: 10.0, category: 'מוצרי חלב'),
      createListItem(id: 'levi_004', name: 'עגבניה שרי', quantity: 1, unitPrice: 22.9, category: 'פירות וירקות'),
      createListItem(id: 'levi_005', name: 'אבוקדו', quantity: 3, unitPrice: 22.9, category: 'פירות וירקות'),
      createListItem(id: 'levi_006', name: 'קפה נמס עלית 50 גרם', quantity: 1, unitPrice: 22.9, category: 'קפה ותה'),
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
      // מוצרים אמיתיים מהקטלוג:
      createListItem(id: 'levi_party_001', name: 'נגיסי עוף ישרלה מחבת600', quantity: 2, unitPrice: 39.90, category: 'בשר ועוף'),
      createListItem(id: 'levi_party_002', name: 'אורז בסמטי טילדה 1 ק"ג', quantity: 1, unitPrice: 15.90, category: 'אורז ופסטה'),
      createListItem(id: 'levi_party_003', name: 'דרום יין לבן יבש 750 מל', quantity: 2, unitPrice: 24.0, category: 'משקאות'),
      createListItem(id: 'levi_party_004', name: 'שמנת מתוקה להקצפה32% 250', quantity: 2, unitPrice: 24.0, category: 'מוצרי חלב'),
      createListItem(id: 'levi_party_005', name: 'מאגדת מיני מילקה קרמל 6 י', quantity: 3, unitPrice: 9.7, category: 'חטיפים וממתקים'),
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
      createListItem(id: 'levi_c1_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: danUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_002', name: 'לחם כפרי ללת"ס700 גרם', quantity: 1, unitPrice: 10.0, category: 'לחם ומאפים', isChecked: true, checkedBy: danUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_003', name: 'ביציםL שופרסל 12', quantity: 1, unitPrice: 10.0, category: 'ביצים', isChecked: true, checkedBy: mayaUserId, checkedAt: lastWeek),
      createListItem(id: 'levi_c1_004', name: 'חזה דקדק טרי ארוז שלי', quantity: 1, unitPrice: 14.09, category: 'בשר ועוף', isChecked: true, checkedBy: mayaUserId, checkedAt: lastWeek),
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
        {'id': 'lr1_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr1_002', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'לחם ומאפים'},
        {'id': 'lr1_003', 'name': 'ביציםL שופרסל 12'', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'ביצים'},
        {'id': 'lr1_004', 'name': 'חזה דקדק טרי ארוז שלי', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'בשר ועוף'},
      ],
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'levi_completed_1',
      'is_virtual': true,
      'created_by': danUserId,
      'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_2',
      'store_name': 'ויקטורי',
      'date': now.subtract(const Duration(days: 13)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 13)).toIso8601String(),
      'total_amount': 213.2,
      'items': [
        {'id': 'lr2_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr2_002', 'name': 'ביציםL שופרסל 12', 'quantity': 1, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr2_003', 'name': 'חזה דקדק טרי ארוז שלי', 'quantity': 2, 'unit_price': 44.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'lr2_004', 'name': 'אורז בסמטי טילדה 1 ק"ג', 'quantity': 1, 'unit_price': 24.0, 'is_checked': true, 'category': 'אורז ופסטה'},
        {'id': 'lr2_005', 'name': 'קפה נמס עלית 50 גרם', 'quantity': 1, 'unit_price': 13.9, 'is_checked': true, 'category': 'קפה ותה'},
        {'id': 'lr2_006', 'name': 'עגבניה שרי', 'quantity': 2, 'unit_price': 9.9, 'is_checked': true, 'category': 'ירקות'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': danUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_3',
      'store_name': 'יוחננוף',
      'date': now.subtract(const Duration(days: 20)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 20)).toIso8601String(),
      'total_amount': 176.4,
      'items': [
        {'id': 'lr3_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr3_002', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'מאפים'},
        {'id': 'lr3_003', 'name': 'גבינה צהובה נעם 22% 200 ג', 'quantity': 2, 'unit_price': 22.9, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr3_004', 'name': 'עגבניה שרי', 'quantity': 2, 'unit_price': 9.9, 'is_checked': true, 'category': 'ירקות'},
        {'id': 'lr3_005', 'name': 'שמן קנולה מזוכך 1 ליטר', 'quantity': 1, 'unit_price': 10.9, 'is_checked': true, 'category': 'שמנים ורטבים'},
        {'id': 'lr3_006', 'name': 'ספגטי מס 5 מוריני 500 ג', 'quantity': 2, 'unit_price': 8.9, 'is_checked': true, 'category': 'אורז ופסטה'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': mayaUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_4',
      'store_name': 'ויקטורי',
      'date': now.subtract(const Duration(days: 27)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 27)).toIso8601String(),
      'total_amount': 289.5,
      'items': [
        {'id': 'lr4_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 3, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr4_002', 'name': 'ביציםL שופרסל 12', 'quantity': 1, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr4_003', 'name': 'פתיתים טבעות 500 גרם', 'quantity': 2, 'unit_price': 8.9, 'is_checked': true, 'category': 'אורז ופסטה'},
        {'id': 'lr4_004', 'name': 'פריניר רוטב עגב קלאסי240', 'quantity': 3, 'unit_price': 6.6, 'is_checked': true, 'category': 'שמנים ורטבים'},
        {'id': 'lr4_005', 'name': 'דרום יין לבן יבש 750 מל', 'quantity': 2, 'unit_price': 89.9, 'is_checked': true, 'category': 'משקאות'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': danUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_5',
      'store_name': 'שופרסל',
      'date': now.subtract(const Duration(days: 34)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 34)).toIso8601String(),
      'total_amount': 194.7,
      'items': [
        {'id': 'lr5_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr5_002', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 2, 'unit_price': 12.9, 'is_checked': true, 'category': 'מאפים'},
        {'id': 'lr5_003', 'name': 'שניצל גונגל 700 גרם', 'quantity': 2, 'unit_price': 46.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'lr5_004', 'name': 'קפה נמס עלית 50 גרם', 'quantity': 1, 'unit_price': 13.9, 'is_checked': true, 'category': 'קפה ותה'},
        {'id': 'lr5_005', 'name': 'בננה', 'quantity': 1, 'unit_price': 7.9, 'is_checked': true, 'category': 'פירות'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': mayaUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_6',
      'store_name': 'ויקטורי',
      'date': now.subtract(const Duration(days: 48)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 48)).toIso8601String(),
      'total_amount': 258.4,
      'items': [
        {'id': 'lr6_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr6_002', 'name': 'ביציםL שופרסל 12', 'quantity': 2, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr6_003', 'name': 'אבוקדו', 'quantity': 4, 'unit_price': 29.9, 'is_checked': true, 'category': 'פירות'},
        {'id': 'lr6_004', 'name': 'חזה דקדק טרי ארוז שלי', 'quantity': 2, 'unit_price': 44.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'lr6_005', 'name': 'נייר טואלט דו שכבתי48XPO', 'quantity': 1, 'unit_price': 45.9, 'is_checked': true, 'category': 'מוצרי ניקיון'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': danUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_7',
      'store_name': 'יוחננוף',
      'date': now.subtract(const Duration(days: 62)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 62)).toIso8601String(),
      'total_amount': 276.8,
      'items': [
        {'id': 'lr7_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 3, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr7_002', 'name': 'בולגרית מסורתית 16% 250', 'quantity': 1, 'unit_price': 26.9, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr7_003', 'name': 'עגבניה שרי', 'quantity': 2, 'unit_price': 9.9, 'is_checked': true, 'category': 'ירקות'},
        {'id': 'lr7_004', 'name': 'בשר בקר טחון חלק', 'quantity': 1, 'unit_price': 39.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'lr7_005', 'name': 'שמן קנולה מזוכך 1 ליטר', 'quantity': 1, 'unit_price': 10.9, 'is_checked': true, 'category': 'שמנים ורטבים'},
        {'id': 'lr7_006', 'name': 'אורז בסמטי טילדה 1 ק"ג', 'quantity': 1, 'unit_price': 24.0, 'is_checked': true, 'category': 'אורז ופסטה'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': mayaUserId, 'household_id': leviHouseholdId,
    },
    {
      'id': 'levi_receipt_8',
      'store_name': 'ויקטורי',
      'date': now.subtract(const Duration(days: 76)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 76)).toIso8601String(),
      'total_amount': 321.6,
      'items': [
        {'id': 'lr8_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr8_002', 'name': 'ביציםL שופרסל 12', 'quantity': 1, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'lr8_003', 'name': 'שניצל גונגל 700 גרם', 'quantity': 3, 'unit_price': 46.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'lr8_004', 'name': 'אורז בסמטי טילדה 1 ק"ג', 'quantity': 2, 'unit_price': 24.0, 'is_checked': true, 'category': 'אורז ופסטה'},
        {'id': 'lr8_005', 'name': 'קפה נמס עלית 50 גרם', 'quantity': 1, 'unit_price': 13.9, 'is_checked': true, 'category': 'קפה ותה'},
        {'id': 'lr8_006', 'name': 'נוזל כלים פיירי לימון 500 מ"ל', 'quantity': 1, 'unit_price': 16.9, 'is_checked': true, 'category': 'מוצרי ניקיון'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': danUserId, 'household_id': leviHouseholdId,
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
          createListItem(id: 'tomer_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 1, unitPrice: 6.90, category: 'מוצרי חלב'),
          createListItem(id: 'tomer_002', name: 'לחם כפרי ללת"ס700 גרם', quantity: 1, unitPrice: 10.0, category: 'לחם ומאפים'),
          createListItem(id: 'tomer_003', name: 'יוגורט יופלה מנגו בננ3%', quantity: 4, unitPrice: 10.0, category: 'מוצרי חלב'),
          createListItem(id: 'tomer_004', name: 'בננה', quantity: 1, unitPrice: 10.0, category: 'פירות וירקות'),
          createListItem(id: 'tomer_005', name: 'טונה בשמן ויליגר1404 גרם', quantity: 1, unitPrice: 29.90, category: 'שימורים'),
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
          createListItem(id: 'tomer_c1_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 1, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_002', name: 'ביציםL שופרסל 12', quantity: 1, unitPrice: 10.0, category: 'ביצים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_003', name: 'שניצל תירס 1.25 קג', quantity: 2, unitPrice: 14.09, category: 'מוקפאים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c1_004', name: 'קוקה קולה בקבוק 1.5 ליטר', quantity: 2, unitPrice: 51.9, category: 'משקאות', isChecked: true, checkedBy: tomerId),
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
          createListItem(id: 'tomer_c2_001', name: 'חלב מועשר1% בקבוק 1 ליטר', quantity: 2, unitPrice: 6.90, category: 'מוצרי חלב', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c2_002', name: 'לחם כפרי ללת"ס700 גרם', quantity: 1, unitPrice: 10.0, category: 'לחם ומאפים', isChecked: true, checkedBy: tomerId),
          createListItem(id: 'tomer_c2_003', name: 'במבה 2510 גרם', quantity: 3, unitPrice: 10.0, category: 'חטיפים וממתקים', isChecked: true, checkedBy: tomerId),
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
        {'id': 'tr1_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 1, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr1_002', 'name': 'ביציםL שופרסל 12'', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'ביצים'},
        {'id': 'tr1_003', 'name': 'שניצל תירס 1.25 קג', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוקפאים'},
        {'id': 'tr1_004', 'name': 'קוקה קולה בקבוק 1.5 ליטר', 'quantity': 2, 'unit_price': 51.9, 'is_checked': true, 'category': 'משקאות'},
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
        {'id': 'tr2_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 6.90, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr2_002', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'לחם ומאפים'},
        {'id': 'tr2_003', 'name': 'במבה 2510 גרם', 'quantity': 3, 'unit_price': 12.9, 'is_checked': true, 'category': 'חטיפים וממתקים'},
      ],
      'original_url': null,
      'file_url': null,
      'linked_shopping_list_id': 'tomer_completed_2',
      'is_virtual': true,
      'created_by': tomerId,
      'household_id': tomerHouseholdId,
    },
    {
      'id': 'tomer_receipt_3',
      'store_name': 'שופרסל אקספרס',
      'date': now.subtract(const Duration(days: 20)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 20)).toIso8601String(),
      'total_amount': 87.4,
      'items': [
        {'id': 'tr3_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr3_002', 'name': 'ביציםL שופרסל 12', 'quantity': 1, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr3_003', 'name': 'קוקה קולה בקבוק 1.5 ליטר', 'quantity': 2, 'unit_price': 9.5, 'is_checked': true, 'category': 'משקאות'},
        {'id': 'tr3_004', 'name': 'במבה 2510 גרם', 'quantity': 2, 'unit_price': 21.5, 'is_checked': true, 'category': 'ממתקים וחטיפים'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': tomerId, 'household_id': tomerHouseholdId,
    },
    {
      'id': 'tomer_receipt_4',
      'store_name': 'AM:PM',
      'date': now.subtract(const Duration(days: 34)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 34)).toIso8601String(),
      'total_amount': 149.7,
      'items': [
        {'id': 'tr4_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr4_002', 'name': 'שניצל תירס 1.25 קג', 'quantity': 2, 'unit_price': 51.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'tr4_003', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'מאפים'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': tomerId, 'household_id': tomerHouseholdId,
    },
    {
      'id': 'tomer_receipt_5',
      'store_name': 'שופרסל אקספרס',
      'date': now.subtract(const Duration(days: 48)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 48)).toIso8601String(),
      'total_amount': 69.3,
      'items': [
        {'id': 'tr5_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 2, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr5_002', 'name': 'טונה בשמן ויליגר1404 גרם', 'quantity': 1, 'unit_price': 25.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'tr5_003', 'name': 'חלה פרוסה 500 גר ארוז231', 'quantity': 1, 'unit_price': 12.9, 'is_checked': true, 'category': 'מאפים'},
        {'id': 'tr5_004', 'name': 'קוקה קולה בקבוק 1.5 ליטר', 'quantity': 2, 'unit_price': 9.5, 'is_checked': true, 'category': 'משקאות'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': tomerId, 'household_id': tomerHouseholdId,
    },
    {
      'id': 'tomer_receipt_6',
      'store_name': 'AM:PM',
      'date': now.subtract(const Duration(days: 69)).toIso8601String(),
      'created_date': now.subtract(const Duration(days: 69)).toIso8601String(),
      'total_amount': 122.3,
      'items': [
        {'id': 'tr6_001', 'name': 'חלב מועשר1% בקבוק 1 ליטר', 'quantity': 1, 'unit_price': 10.0, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr6_002', 'name': 'ביציםL שופרסל 12', 'quantity': 1, 'unit_price': 14.09, 'is_checked': true, 'category': 'מוצרי חלב'},
        {'id': 'tr6_003', 'name': 'שניצל תירס 1.25 קג', 'quantity': 1, 'unit_price': 51.9, 'is_checked': true, 'category': 'בשר ודגים'},
        {'id': 'tr6_004', 'name': 'במבה 2510 גרם', 'quantity': 2, 'unit_price': 21.5, 'is_checked': true, 'category': 'ממתקים וחטיפים'},
      ],
      'original_url': null, 'file_url': null,
      'linked_shopping_list_id': null, 'is_virtual': true,
      'created_by': tomerId, 'household_id': tomerHouseholdId,
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
      'product_name': 'בשר בקר טחון חלק',
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
          createListItem(id: 'shiran_001', name: 'לחם כפרי ללת"ס700 גרם', quantity: 2, unitPrice: 7.90, category: 'לחם ומאפים'),
          createListItem(id: 'shiran_002', name: 'עגבניה שרי', quantity: 1, unitPrice: 12.90, category: 'פירות וירקות'),
          createListItem(id: 'shiran_003', name: 'מלפפון', quantity: 1, unitPrice: 4.90, category: 'פירות וירקות'),
          createListItem(id: 'shiran_004', name: 'בננה', quantity: 1, unitPrice: 7.90, category: 'פירות וירקות'),
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
        'name': 'מיץ אשכוליות אדומות 1 ל'',
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
// EXTERNAL SHARED LISTS (שיתוף עם אנשים מחוץ למשפחה)
// ═══════════════════════════════════════════════════════════════════

/// 🔗 רשימות משותפות עם אנשים מחוץ ל-household
///
/// אלו רשימות עם `is_private: true` + `shared_users` - כך שהמזווה
/// של הבעלים לא יופיע למשתף.
Map<String, List<Map<String, dynamic>>> generateExternalSharedLists(
  Map<String, String> allUids,
) {
  final now = DateTime.now();
  final result = <String, List<Map<String, dynamic>>>{};

  // קבלת ה-UIDs האמיתיים
  final yuvalUid = allUids[yuvalUserId];
  final tomerUid = allUids[tomerId];
  final ronitUid = allUids[ronitUserId];
  final shiranUid = allUids[shiranId];
  final danUid = allUids[danUserId];
  final aviUid = allUids[aviUserId];

  // 1. יובל משתף רשימה עם תומר (חבר מחוץ למשפחה)
  if (yuvalUid != null && tomerUid != null) {
    final yuvalExternalList = {
      'id': 'yuval_external_friends_party',
      'name': 'מסיבה אצל תומר',
      'updated_date': now.toIso8601String(),
      'created_date': now.subtract(const Duration(days: 2)).toIso8601String(),
      'status': 'active',
      'type': 'event',
      'budget': 300.0,
      'is_shared': true,
      'is_private': true,  // ⚠️ לא משותף עם household!
      'created_by': yuvalUid,
      'shared_with': [tomerUid],
      'event_date': now.add(const Duration(days: 5)).toIso8601String(),
      'target_date': now.add(const Duration(days: 4)).toIso8601String(),
      'items': _generateItemsForExternalList('event', 8),
      'format': 'shared',
      'created_from_template': false,
      'active_shoppers': [],
      'shared_users': {
        tomerUid: {
          'role': 'editor',
          'shared_at': now.subtract(const Duration(days: 2)).toIso8601String(),
          'user_name': 'תומר בר',
          'user_email': 'tomer.bar@demo.com',
          'can_start_shopping': true,
        },
      },
      'pending_requests': [],
    };

    result[yuvalUid] = [yuvalExternalList];
  }

  // 2. רונית משתפת רשימה עם שירן (חברה)
  if (ronitUid != null && shiranUid != null) {
    final ronitExternalList = {
      'id': 'ronit_external_gifts',
      'name': 'מתנות לחג',
      'updated_date': now.toIso8601String(),
      'created_date': now.subtract(const Duration(days: 1)).toIso8601String(),
      'status': 'active',
      'type': 'other',
      'budget': 500.0,
      'is_shared': true,
      'is_private': true,  // ⚠️ לא משותף עם household!
      'created_by': ronitUid,
      'shared_with': [shiranUid],
      'event_date': null,
      'target_date': now.add(const Duration(days: 10)).toIso8601String(),
      'items': _generateItemsForExternalList('other', 6),
      'format': 'shared',
      'created_from_template': false,
      'active_shoppers': [],
      'shared_users': {
        shiranUid: {
          'role': 'editor',
          'shared_at': now.subtract(const Duration(days: 1)).toIso8601String(),
          'user_name': 'שירן גל',
          'user_email': 'shiran.gal@demo.com',
          'can_start_shopping': true,
        },
      },
      'pending_requests': [],
    };

    result[ronitUid] = [ronitExternalList];
  }

  // 3. דן (לוי) משתף רשימה עם אבי (כהן) - פיקניק בין משפחות
  if (danUid != null && aviUid != null) {
    final danExternalList = {
      'id': 'dan_external_picnic',
      'name': 'פיקניק משפחות בפארק',
      'updated_date': now.toIso8601String(),
      'created_date': now.subtract(const Duration(days: 3)).toIso8601String(),
      'status': 'active',
      'type': 'event',
      'budget': 400.0,
      'is_shared': true,
      'is_private': true,  // ⚠️ לא משותף עם household של לוי!
      'created_by': danUid,
      'shared_with': [aviUid],
      'event_date': now.add(const Duration(days: 7)).toIso8601String(),
      'target_date': now.add(const Duration(days: 6)).toIso8601String(),
      'items': _generateItemsForExternalList('event', 10),
      'format': 'shared',
      'created_from_template': false,
      'active_shoppers': [],
      'shared_users': {
        aviUid: {
          'role': 'editor',
          'shared_at': now.subtract(const Duration(days: 3)).toIso8601String(),
          'user_name': 'אבי כהן',
          'user_email': 'avi.cohen@demo.com',
          'can_start_shopping': true,
        },
      },
      'pending_requests': [],
    };

    result[danUid] = [danExternalList];
  }

  return result;
}

/// יצירת פריטים לרשימה חיצונית (משתמש במוצרים מ-JSON)
List<Map<String, dynamic>> _generateItemsForExternalList(String type, int count) {
  final now = DateTime.now();
  final items = <Map<String, dynamic>>[];

  // בחר מוצרים אקראיים מהמאגר
  final products = getRandomProductsFromAll(count);

  for (var i = 0; i < products.length; i++) {
    final product = products[i];
    items.add({
      'id': 'ext_item_${now.millisecondsSinceEpoch}_$i',
      'type': 'product',
      'name': product['name'] ?? 'מוצר',
      'quantity': (i % 3) + 1,  // 1-3
      'unit_price': (product['price'] as num?)?.toDouble() ?? 10.0,
      'is_checked': i < 2,  // 2 פריטים ראשונים מסומנים
      'checked_at': i < 2 ? now.subtract(const Duration(hours: 1)).toIso8601String() : null,
      'checked_by': null,
      'added_at': now.subtract(Duration(days: i)).toIso8601String(),
      'category': product['category'] ?? 'כללי',
      'barcode': product['barcode'],
      'brand': product['brand'],
      'unit': product['unit'] ?? 'יחידה',
      'icon': product['icon'] ?? '📦',
      'notes': null,
      'priority': 'normal',
      'added_by': null,
    });
  }

  return items;
}

// ═══════════════════════════════════════════════════════════════════
// SAVED CONTACTS (אנשי קשר שמורים)
// ═══════════════════════════════════════════════════════════════════

/// 📇 אנשי קשר שמורים לכל משתמש
///
/// מאפשר הזמנה מהירה לרשימות בעתיד
Map<String, List<Map<String, dynamic>>> generateSavedContacts(
  Map<String, String> allUids,
) {
  final now = DateTime.now();
  final result = <String, List<Map<String, dynamic>>>{};

  // הגדרת כל המשתמשים עם הפרטים שלהם
  final userDetails = <String, Map<String, String>>{
    aviUserId: {'name': 'אבי כהן', 'email': 'avi.cohen@demo.com'},
    ronitUserId: {'name': 'רונית כהן', 'email': 'ronit.cohen@demo.com'},
    yuvalUserId: {'name': 'יובל כהן', 'email': 'yuval.cohen@demo.com'},
    noaUserId: {'name': 'נועה כהן', 'email': 'noa.cohen@demo.com'},
    danUserId: {'name': 'דן לוי', 'email': 'dan.levi@demo.com'},
    mayaUserId: {'name': 'מאיה לוי', 'email': 'maya.levi@demo.com'},
    tomerId: {'name': 'תומר בר', 'email': 'tomer.bar@demo.com'},
    shiranId: {'name': 'שירן גל', 'email': 'shiran.gal@demo.com'},
  };

  // Helper function ליצירת איש קשר
  Map<String, dynamic> createContact(String contactUserId, int daysAgo) {
    final uid = allUids[contactUserId];
    final details = userDetails[contactUserId]!;
    return {
      'user_id': uid ?? contactUserId,
      'user_name': details['name'],
      'user_email': details['email'],
      'user_avatar': null,
      'added_at': now.subtract(Duration(days: daysAgo + 10)).toIso8601String(),
      'last_invited_at': now.subtract(Duration(days: daysAgo)).toIso8601String(),
    };
  }

  // אבי - אנשי קשר: רונית, יובל, נועה, דן
  final aviUid = allUids[aviUserId];
  if (aviUid != null) {
    result[aviUid] = [
      createContact(ronitUserId, 1),
      createContact(yuvalUserId, 3),
      createContact(noaUserId, 5),
      createContact(danUserId, 7),
    ];
  }

  // רונית - אנשי קשר: אבי, יובל, נועה, שירן
  final ronitUid = allUids[ronitUserId];
  if (ronitUid != null) {
    result[ronitUid] = [
      createContact(aviUserId, 1),
      createContact(yuvalUserId, 2),
      createContact(noaUserId, 4),
      createContact(shiranId, 1),
    ];
  }

  // יובל - אנשי קשר: אבי, רונית, נועה, תומר
  final yuvalUid = allUids[yuvalUserId];
  if (yuvalUid != null) {
    result[yuvalUid] = [
      createContact(aviUserId, 5),
      createContact(ronitUserId, 3),
      createContact(noaUserId, 2),
      createContact(tomerId, 2),
    ];
  }

  // נועה - אנשי קשר: אבי, רונית, יובל
  final noaUid = allUids[noaUserId];
  if (noaUid != null) {
    result[noaUid] = [
      createContact(aviUserId, 4),
      createContact(ronitUserId, 3),
      createContact(yuvalUserId, 1),
    ];
  }

  // דן - אנשי קשר: מאיה, אבי
  final danUid = allUids[danUserId];
  if (danUid != null) {
    result[danUid] = [
      createContact(mayaUserId, 1),
      createContact(aviUserId, 3),
    ];
  }

  // מאיה - אנשי קשר: דן
  final mayaUid = allUids[mayaUserId];
  if (mayaUid != null) {
    result[mayaUid] = [
      createContact(danUserId, 1),
    ];
  }

  // תומר - אנשי קשר: יובל
  final tomerUid = allUids[tomerId];
  if (tomerUid != null) {
    result[tomerUid] = [
      createContact(yuvalUserId, 2),
    ];
  }

  // שירן - אנשי קשר: רונית, נועה, יובל
  final shiranUid = allUids[shiranId];
  if (shiranUid != null) {
    result[shiranUid] = [
      createContact(ronitUserId, 1), // חברה קרובה
      createContact(noaUserId, 3), // חברה מהקבוצה
      createContact(yuvalUserId, 5), // שלחה לה הזמנה לספורט
    ];
  }

  return result;
}

// ═══════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

/// Helper להשגת שם משתמש לפי UID
String _getUserNameByUid(String uid, Map<String, String> allUids) {
  // מיפוי הפוך: UID -> User ID -> Name
  final userIdToName = <String, String>{
    aviUserId: 'אבי כהן',
    ronitUserId: 'רונית כהן',
    yuvalUserId: 'יובל כהן',
    noaUserId: 'נועה כהן',
    danUserId: 'דן לוי',
    mayaUserId: 'מאיה לוי',
    tomerId: 'תומר בר',
    shiranId: 'שירן גל',
  };

  for (final entry in allUids.entries) {
    if (entry.value == uid) {
      return userIdToName[entry.key] ?? entry.key;
    }
  }
  return uid;
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
// CLEANUP FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

/// 🧹 מוחק את כל הנתונים מ-Firestore Emulator
/// משתמש ב-endpoint המיוחד של האמולטור
Future<void> cleanAllFirestoreData() async {
  print('🧹 מוחק את כל הנתונים מ-Firestore...');

  final url = Uri.parse(
    'http://$firestoreHost/emulator/v1/projects/$projectId/databases/(default)/documents',
  );

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('   ✅ כל הנתונים נמחקו בהצלחה');
  } else {
    print('   ⚠️ שגיאה במחיקה: ${response.statusCode} - ${response.body}');
  }
}

/// 🧹 מוחק את כל המשתמשים מ-Auth Emulator
Future<void> cleanAllAuthUsers() async {
  print('🧹 מוחק את כל המשתמשים מ-Auth...');

  final url = Uri.parse(
    'http://$authHost/emulator/v1/projects/$projectId/accounts',
  );

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('   ✅ כל המשתמשים נמחקו בהצלחה');
  } else {
    print('   ⚠️ שגיאה במחיקה: ${response.statusCode} - ${response.body}');
  }
}

// ═══════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════

void main(List<String> args) async {
  // 🆕 בדיקת flags
  final shouldClean = args.contains('--clean');

  print('═' * 60);
  print('🏠 יוצר דאטה דמו - כל המשתמשים');
  if (shouldClean) {
    print('🧹 מצב ניקוי: מוחק נתונים קיימים לפני יצירה');
  }
  print('═' * 60);
  print('');

  // 🧹 ניקוי נתונים קיימים אם התבקש
  if (shouldClean) {
    print('━' * 60);
    print('🧹 מנקה נתונים קיימים...');
    print('━' * 60);
    await cleanAllAuthUsers();
    await cleanAllFirestoreData();
    print('');
  }

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
  print('🏢 ועד בית - הדקל 15:');
  print('   👤 משה גולן - Owner (יו"ר)');
  print('   👤 שרה לוי - Admin (גזברית)');
  print('   👤 דוד כהן - Editor');
  print('   👤 מיכל אברהם - Viewer');
  print('');
  print('🎒 ועד גן - שושנים:');
  print('   👤 יעל ברק - Owner (יו"ר)');
  print('   👤 אורנה שלום - Admin');
  print('   👤 רמי דור - Editor');
  print('');
  print('💒 אירוע - חתונת ליאור ונועם:');
  print('   👤 ליאור כץ - Owner (חתן)');
  print('   👤 נועם שפירא - Admin (כלה)');
  print('   👤 אייל כץ - Editor (אח)');
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
      final userData = Map<String, dynamic>.from(entry.value);
      userData['id'] = uid;
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
      final userData = Map<String, dynamic>.from(entry.value);
      userData['id'] = uid;
      await writeDocument('users', uid, userData);
    }
    print('   ✅ מסמכי משתמשים נוספים נוצרו');
    print('');

    // 3. Create Custom Locations
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

    // 8. Create Inventory - מזווה אישי של אבי
    print('━' * 60);
    print('🏪 יוצר פריטי מזווה...');
    print('━' * 60);

    final inventory = generateInventoryItems();
    final aviUid = cohenUids[aviUserId]!;
    for (final item in inventory) {
      print('   ${item['emoji'] ?? '📦'} ${item['product_name']} (${item['location']})');
      await writeSubDocument(
        'households/$householdId/inventory',  // 🔧 מזווה משפחתי משותף
        item['id'] as String,
        item,
      );
      // 🔧 גם תחת users - כדי ש-InventoryProvider.fetchUserItems() ימצא
      await writeSubDocument(
        'users/$aviUid/inventory',
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${inventory.length} פריטי מזווה נוצרו (households + users/$aviUid)');
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

    // Levi Inventory - מזווה משפחתי משותף
    final leviInventory = generateLeviInventory();
    for (final item in leviInventory) {
      await writeSubDocument(
        'households/$leviHouseholdId/inventory',  // 🔧 מזווה משפחתי משותף
        item['id'] as String,
        item,
      );
    }
    print('   ✅ ${leviInventory.length} פריטי מזווה משפחתי לוי נוצרו');

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

    // ═══════════════════════════════════════════════════════════════
    // EXTERNAL SHARED LISTS (שיתוף עם אנשים מחוץ למשפחה)
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('🔗 יוצר רשימות משותפות חיצוניות...');
    print('━' * 60);

    // איחוד כל ה-UIDs
    final allUids = <String, String>{
      ...cohenUids,
      ...additionalUids,
    };

    // ═══════════════════════════════════════════════════════════════
    // EXTERNAL SHARED LISTS (שיתוף עם אנשים מחוץ למשפחה)
    // ═══════════════════════════════════════════════════════════════

    final externalLists = generateExternalSharedLists(allUids);
    var externalCount = 0;
    for (final entry in externalLists.entries) {
      final userId = entry.key;
      for (final list in entry.value) {
        print('   📝 ${list['name']} (בעלים: ${_getUserNameByUid(userId, allUids)})');
        await writeSubDocument(
          'users/$userId/private_lists',
          list['id'] as String,
          list,
        );
        externalCount++;
      }
    }
    print('   ✅ $externalCount רשימות משותפות חיצוניות נוצרו');
    print('');

    // ═══════════════════════════════════════════════════════════════
    // SAVED CONTACTS (אנשי קשר שמורים)
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('📇 יוצר אנשי קשר שמורים...');
    print('━' * 60);

    final savedContacts = generateSavedContacts(allUids);
    var contactsCount = 0;
    for (final entry in savedContacts.entries) {
      final userId = entry.key;
      final contacts = entry.value;
      print('   👤 ${_getUserNameByUid(userId, allUids)}: ${contacts.length} אנשי קשר');
      for (final contact in contacts) {
        await writeSubDocument(
          'users/$userId/saved_contacts',
          contact['user_id'] as String,
          contact,
        );
        contactsCount++;
      }
    }
    print('   ✅ $contactsCount אנשי קשר שמורים נוצרו');
    print('');

    // ═══════════════════════════════════════════════════════════════
    // NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════════

    print('━' * 60);
    print('🔔 יוצר התראות...');
    print('━' * 60);

    final notifications = generateNotifications(allUids);
    var notifCount = 0;
    for (final entry in notifications.entries) {
      final userId = entry.key;
      final userNotifs = entry.value;
      print('   👤 ${_getUserNameByUid(userId, allUids)}: ${userNotifs.length} התראות');
      for (final notif in userNotifs) {
        await writeSubDocument(
          'users/$userId/notifications',
          notif['id'] as String,
          notif,
        );
        notifCount++;
      }
    }
    print('   ✅ $notifCount התראות נוצרו');
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
    print('   🏢 ועד בית (הדקל 15):');
    print('      moshe.golan@demo.com (יו"ר)');
    print('      sara.levi@demo.com (גזברית)');
    print('      david.cohen@demo.com');
    print('      michal.avraham@demo.com');
    print('');
    print('   🎒 ועד גן (שושנים):');
    print('      yael.barak@demo.com (יו"ר)');
    print('      orna.shalom@demo.com');
    print('      rami.dor@demo.com');
    print('');
    print('   💒 חתונת ליאור ונועם:');
    print('      lior.katz@demo.com (חתן)');
    print('      noam.shapira@demo.com (כלה)');
    print('      eyal.katz@demo.com (אח)');
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
