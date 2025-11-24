// 📄 File: lib/tools/load_demo_data_screen.dart
//
// 🎯 Purpose: UI screen to load demo users data into Firebase
//
// Usage: Navigate to this screen from settings or debug menu

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_entity.dart';
import '../models/shopping_list.dart';
import '../models/inventory_item.dart';
import '../repositories/firebase_user_repository.dart';
import '../repositories/firebase_shopping_lists_repository.dart';
import '../repositories/firebase_inventory_repository.dart';

class LoadDemoDataScreen extends StatefulWidget {
  const LoadDemoDataScreen({super.key});

  @override
  State<LoadDemoDataScreen> createState() => _LoadDemoDataScreenState();
}

class _LoadDemoDataScreenState extends State<LoadDemoDataScreen> {
  bool _isLoading = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadDemoData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    _addLog('🚀 Starting demo users loader...\n');

    try {
      // 1. Read JSON file from assets
      _addLog('📖 Reading demo_users.json from assets...');
      final jsonString = await rootBundle.loadString('demo_users.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final demoUsers = jsonData['demo_users'] as List<dynamic>;
      _addLog('✅ Found ${demoUsers.length} demo users\n');

      // 2. Initialize repositories
      final userRepo = FirebaseUserRepository();
      final listsRepo = FirebaseShoppingListsRepository();
      final inventoryRepo = FirebaseInventoryRepository();

      // 3. Load each user
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

      _addLog('\n🎉 All demo users loaded successfully!');
      _addLog('✅ Demo users available:');
      for (var userData in demoUsers) {
        final user = userData['user'] as Map<String, dynamic>;
        _addLog('   - ${user['email']}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo data loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      _addLog('\n❌ Error loading demo users: $e');
      _addLog(stackTrace.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    _addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _addLog('📦 Loading user $current/$total');
    _addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // 1. Load User
    final userJson = userData['user'] as Map<String, dynamic>;
    final user = UserEntity.fromJson(userJson);
    _addLog('👤 User: ${user.name} (${user.email})');
    _addLog('   Household: ${user.householdId}');

    try {
      await userRepo.saveUser(user);
      _addLog('✅ User saved to Firebase\n');
    } catch (e) {
      _addLog('⚠️  User save error: $e\n');
    }

    // 2. Load Shopping Lists
    final shoppingListsData = userData['shopping_lists'] as List<dynamic>?;
    if (shoppingListsData != null && shoppingListsData.isNotEmpty) {
      _addLog('🛒 Shopping Lists: ${shoppingListsData.length}');
      for (var listJson in shoppingListsData) {
        final listData = listJson as Map<String, dynamic>;

        try {
          final list = ShoppingList.fromJson(listData);
          await listsRepo.saveList(list, user.householdId);
          _addLog('   ✅ "${list.name}" (${list.items.length} items, ${list.status})');
        } catch (e) {
          _addLog('   ⚠️  Error saving list: $e');
        }
      }
      _addLog('');
    } else {
      _addLog('🛒 Shopping Lists: None\n');
    }

    // 3. Load Inventory
    final inventoryData = userData['inventory'] as List<dynamic>?;
    if (inventoryData != null && inventoryData.isNotEmpty) {
      _addLog('📦 Inventory: ${inventoryData.length} items');
      for (var itemJson in inventoryData) {
        final itemData = itemJson as Map<String, dynamic>;

        try {
          final item = InventoryItem.fromJson(itemData);
          await inventoryRepo.saveItem(item, user.householdId);
          _addLog('   ✅ ${item.productName} (${item.quantity} ${item.unit})');
        } catch (e) {
          _addLog('   ⚠️  Error saving inventory item: $e');
        }
      }
      _addLog('');
    } else {
      _addLog('📦 Inventory: None\n');
    }

    // 4. Smart Suggestions info
    final suggestionsData = userData['smart_suggestions'] as List<dynamic>?;
    if (suggestionsData != null && suggestionsData.isNotEmpty) {
      _addLog('💡 Smart Suggestions: ${suggestionsData.length} (will be generated from inventory)');
      for (var suggestionJson in suggestionsData) {
        final suggestionData = suggestionJson as Map<String, dynamic>;
        _addLog('   ℹ️  ${suggestionData['product_name']} (${suggestionData['status']})');
      }
      _addLog('');
    } else {
      _addLog('💡 Smart Suggestions: None\n');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('טעינת נתוני דמו'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯 טעינת 5 משתמשי דמו',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'טוען נתונים מ-demo_users.json לתוך Firebase',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadDemoData,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isLoading ? 'טוען...' : 'טען נתוני דמו'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              color: Colors.black87,
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'לחץ על "טען נתוני דמו" כדי להתחיל',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SelectableText(
                            _logs[index],
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: _logs[index].startsWith('❌')
                                  ? Colors.red.shade300
                                  : _logs[index].startsWith('⚠️')
                                      ? Colors.orange.shade300
                                      : _logs[index].startsWith('✅')
                                          ? Colors.green.shade300
                                          : Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
