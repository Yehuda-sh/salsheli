// 📄 File: scripts/clean_corrupted_inventory.dart
// 
// Purpose: נקה פריטי מלאי פגומים מ-Firestore
//
// Usage:
//   dart run scripts/clean_corrupted_inventory.dart
//
// Note: דורש הרצה עם Flutter SDK בגלל cloud_firestore

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// מחלקת עזר לניקוי
class InventoryCleanup {
  final FirebaseFirestore firestore;
  final String householdId;
  
  InventoryCleanup({
    required this.firestore,
    required this.householdId,
  });

  /// שלב 1: סריקה וזיהוי פריטים פגומים
  Future<List<String>> scanCorruptedItems() async {
    print('\n🔍 סורק פריטים במלאי עבור household: $householdId...\n');
    
    try {
      final snapshot = await firestore
          .collection('inventory')
          .where('household_id', isEqualTo: householdId)
          .get();

      print('📊 נמצאו ${snapshot.docs.length} פריטים במלאי');
      
      final corruptedIds = <String>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // בדיקה: האם productName הוא null או חסר?
        final productName = data['productName'];
        
        if (productName == null) {
          corruptedIds.add(doc.id);
          print('❌ פריט פגום: ${doc.id}');
          print('   Data: $data');
        }
      }
      
      return corruptedIds;
    } catch (e) {
      print('❌ שגיאה בסריקה: $e');
      rethrow;
    }
  }

  /// שלב 2: מחיקת פריטים פגומים
  Future<int> deleteCorruptedItems(List<String> ids) async {
    if (ids.isEmpty) {
      print('\n✅ אין פריטים פגומים למחיקה!');
      return 0;
    }
    
    print('\n🗑️ מוחק ${ids.length} פריטים פגומים...\n');
    
    int deleted = 0;
    
    for (final id in ids) {
      try {
        await firestore.collection('inventory').doc(id).delete();
        deleted++;
        
        // התקדמות כל 10 פריטים
        if (deleted % 10 == 0) {
          print('   ✓ נמחקו $deleted/${ids.length} פריטים...');
        }
      } catch (e) {
        print('   ❌ שגיאה במחיקת $id: $e');
      }
    }
    
    return deleted;
  }
}

/// פונקציה ראשית
Future<void> main() async {
  print('═══════════════════════════════════════════');
  print('🧹 סקריפט ניקוי מלאי פגום');
  print('═══════════════════════════════════════════\n');

  try {
    // אתחול Firebase
    print('🔥 מאתחל Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase אותחל\n');

    // הגדרת household ID
    const householdId = 'house_apLPgpAyt6Rt8YPK4FJcIKzh5d72';
    
    final cleanup = InventoryCleanup(
      firestore: FirebaseFirestore.instance,
      householdId: householdId,
    );

    // שלב 1: סריקה
    final corruptedIds = await cleanup.scanCorruptedItems();
    
    if (corruptedIds.isEmpty) {
      print('\n🎉 הכל נקי! לא נמצאו פריטים פגומים.');
      exit(0);
    }

    print('\n═══════════════════════════════════════════');
    print('📊 סיכום:');
    print('   • פריטים פגומים שנמצאו: ${corruptedIds.length}');
    print('   • household: $householdId');
    print('═══════════════════════════════════════════\n');

    // בקשת אישור
    print('⚠️  האם למחוק את כל ${corruptedIds.length} הפריטים הפגומים?');
    print('   (הקלד "yes" לאישור או Enter לביטול)');
    
    final input = stdin.readLineSync();
    
    if (input?.toLowerCase() != 'yes') {
      print('\n❌ הפעולה בוטלה על ידי המשתמש');
      exit(0);
    }

    // שלב 2: מחיקה
    final deleted = await cleanup.deleteCorruptedItems(corruptedIds);
    
    print('\n═══════════════════════════════════════════');
    print('✅ הסתיים!');
    print('   • נמחקו: $deleted פריטים');
    print('   • נכשלו: ${corruptedIds.length - deleted} פריטים');
    print('═══════════════════════════════════════════\n');

  } catch (e, stackTrace) {
    print('\n❌ שגיאה קריטית: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
