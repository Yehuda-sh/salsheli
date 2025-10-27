// 📄 File: scripts/migrate_list_types.dart
//
// 🔄 Migration Script: "super" → "supermarket"
//
// Purpose: Update all existing shopping lists in Firestore
//          from legacy "super" type to new "supermarket" type.
//
// Usage:
//   dart run scripts/migrate_list_types.dart
//
// Safety:
//   - Reads all lists
//   - Only updates "super" → "supermarket"
//   - Keeps other types unchanged
//   - Logs every update
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  print('🚀 Starting migration: "super" → "supermarket"');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  // Initialize Firebase
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  try {
    // Get all shopping lists with type "super"
    final snapshot = await firestore
        .collection('shopping_lists')
        .where('type', isEqualTo: 'super')
        .get();

    print('📊 Found ${snapshot.docs.length} lists with type "super"');
    print('');

    if (snapshot.docs.isEmpty) {
      print('✅ No lists to migrate. All done!');
      return;
    }

    // Update each list
    int successCount = 0;
    int errorCount = 0;

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final listName = data['name'] ?? 'Unknown';
        final listId = doc.id;

        print('🔄 Migrating: $listName (ID: $listId)');

        await doc.reference.update({
          'type': 'supermarket',
          'updated_date': FieldValue.serverTimestamp(),
        });

        successCount++;
        print('   ✅ Success');
      } catch (e) {
        errorCount++;
        print('   ❌ Error: $e');
      }
    }

    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 Migration Summary:');
    print('   ✅ Success: $successCount');
    print('   ❌ Errors: $errorCount');
    print('   📝 Total: ${snapshot.docs.length}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (errorCount == 0) {
      print('');
      print('🎉 Migration completed successfully!');
    } else {
      print('');
      print('⚠️ Migration completed with errors. Check logs above.');
    }
  } catch (e) {
    print('');
    print('❌ Migration failed: $e');
    rethrow;
  }
}
