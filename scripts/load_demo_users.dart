// 📄 File: scripts/load_demo_users.dart
//
// 🎯 Purpose: Load demo users from demo_users.json to Firebase
//
// Usage:
//   dart run scripts/load_demo_users.dart
//
// Prerequisites:
//   - Firebase project configured
//   - demo_users.json exists in project root
//   - firebase_core and cloud_firestore dependencies

import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

// Import Firebase options
import '../lib/firebase_options.dart';

// Import models
import '../lib/models/user_entity.dart';
import '../lib/models/shopping_list.dart';
import '../lib/models/inventory_item.dart';

// Import repositories
import '../lib/repositories/firebase_user_repository.dart';
import '../lib/repositories/firebase_shopping_lists_repository.dart';
import '../lib/repositories/firebase_inventory_repository.dart';

void main() async {
  print('🚀 Starting demo users loader...\n');

  try {
    // 1. Initialize Firebase
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');

    // 2. Read JSON file
    print('📖 Reading demo_users.json...');
    final file = File('demo_users.json');
    if (!file.existsSync()) {
      print('❌ Error: demo_users.json not found!');
      exit(1);
    }
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final demoUsers = jsonData['demo_users'] as List<dynamic>;
    print('✅ Found ${demoUsers.length} demo users\n');

    // 3. Initialize repositories
    final userRepo = FirebaseUserRepository();
    final listsRepo = FirebaseShoppingListsRepository();
    final inventoryRepo = FirebaseInventoryRepository();

    // 4. Load each user
    for (var i = 0; i < demoUsers.length; i++) {
      final userData = demoUsers[i] as Map<String, dynamic>;
      await _loadDemoUser(
        userData,
        i + 1,
        demoUsers.length,
        userRepo,
        listsRepo,
        inventoryRepo,
      );
    }

    print('\n🎉 All demo users loaded successfully!');
    print('✅ You can now log in with any of these emails:');
    for (var userData in demoUsers) {
      final user = userData['user'] as Map<String, dynamic>;
      print('   - ${user['email']}');
    }

    exit(0);
  } catch (e, stackTrace) {
    print('\n❌ Error loading demo users: $e');
    print(stackTrace);
    exit(1);
  }
}

Future<void> _loadDemoUser(
  Map<String, dynamic> userData,
  int current,
  int total,
  FirebaseUserRepository userRepo,
  FirebaseShoppingListsRepository listsRepo,
  FirebaseInventoryRepository inventoryRepo,
) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📦 Loading user $current/$total');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 1. Load User
  final userJson = userData['user'] as Map<String, dynamic>;
  final user = UserEntity.fromJson(userJson);
  print('👤 User: ${user.name} (${user.email})');
  print('   Household: ${user.householdId}');

  try {
    await userRepo.saveUser(user);
    print('✅ User saved to Firebase\n');
  } catch (e) {
    print('⚠️  User save error: $e\n');
  }

  // 2. Load Shopping Lists
  final shoppingListsData = userData['shopping_lists'] as List<dynamic>?;
  if (shoppingListsData != null && shoppingListsData.isNotEmpty) {
    print('🛒 Shopping Lists: ${shoppingListsData.length}');
    for (var listJson in shoppingListsData) {
      final listData = listJson as Map<String, dynamic>;

      try {
        final list = ShoppingList.fromJson(listData);
        await listsRepo.saveList(list, user.householdId);
        print('   ✅ "${list.name}" (${list.items.length} items, ${list.status})');
      } catch (e) {
        print('   ⚠️  Error saving list: $e');
      }
    }
    print('');
  } else {
    print('🛒 Shopping Lists: None\n');
  }

  // 3. Load Inventory
  final inventoryData = userData['inventory'] as List<dynamic>?;
  if (inventoryData != null && inventoryData.isNotEmpty) {
    print('📦 Inventory: ${inventoryData.length} items');
    for (var itemJson in inventoryData) {
      final itemData = itemJson as Map<String, dynamic>;

      try {
        final item = InventoryItem.fromJson(itemData);
        await inventoryRepo.saveItem(item, user.householdId);
        print('   ✅ ${item.productName} (${item.quantity} ${item.unit})');
      } catch (e) {
        print('   ⚠️  Error saving inventory item: $e');
      }
    }
    print('');
  } else {
    print('📦 Inventory: None\n');
  }

  // 4. Smart Suggestions info (not saved - generated dynamically from inventory)
  final suggestionsData = userData['smart_suggestions'] as List<dynamic>?;
  if (suggestionsData != null && suggestionsData.isNotEmpty) {
    print('💡 Smart Suggestions: ${suggestionsData.length} (will be generated from inventory)');
    for (var suggestionJson in suggestionsData) {
      final suggestionData = suggestionJson as Map<String, dynamic>;
      print('   ℹ️  ${suggestionData['product_name']} (${suggestionData['status']})');
    }
    print('');
  } else {
    print('💡 Smart Suggestions: None\n');
  }
}
