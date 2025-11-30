// 📄 File: lib/services/demo_family_service.dart
// 🎯 שירות ליצירה והתחברות למשפחת דמו אמיתית ב-Firebase
//
// משפחת כהן - 4 משתמשים עם תפקידים שונים:
// - דוד (אבא) - Owner 👑
// - מיכל (אמא) - Admin 🔧
// - יונתן (בן) - Editor ✏️
// - נועה (בת) - Viewer 👀

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/request_type.dart';
import '../models/enums/user_role.dart';
import '../models/inventory_item.dart';
import '../models/pending_request.dart';
import '../models/shared_user.dart';
import '../models/shopping_list.dart';
import '../models/unified_list_item.dart';

/// מידע על משתמש דמו
class DemoUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String emoji;
  final String description;

  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.emoji,
    required this.description,
  });
}

/// שירות ליצירה והתחברות למשפחת דמו
class DemoFamilyService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // 🏠 מזהים קבועים למשפחת הדמו
  static const String demoHouseholdId = 'demo_household_cohen';
  static const String demoListId1 = 'demo_list_weekly';
  static const String demoListId2 = 'demo_list_completed';

  // 👨‍👩‍👧‍👦 משפחת כהן
  static const List<DemoUser> demoUsers = [
    DemoUser(
      id: 'demo_user_david',
      name: 'דוד כהן',
      email: 'david.demo@memozap.app',
      password: 'Demo123!',
      role: UserRole.owner,
      emoji: '👑',
      description: 'בעלים - רואה הכל, מנהל משתמשים',
    ),
    DemoUser(
      id: 'demo_user_michal',
      name: 'מיכל כהן',
      email: 'michal.demo@memozap.app',
      password: 'Demo123!',
      role: UserRole.admin,
      emoji: '🔧',
      description: 'מנהלת - מאשרת בקשות, עורכת הכל',
    ),
    DemoUser(
      id: 'demo_user_yonatan',
      name: 'יונתן כהן',
      email: 'yonatan.demo@memozap.app',
      password: 'Demo123!',
      role: UserRole.editor,
      emoji: '✏️',
      description: 'עורך - מוסיף דרך בקשות',
    ),
    DemoUser(
      id: 'demo_user_noa',
      name: 'נועה כהן',
      email: 'noa.demo@memozap.app',
      password: 'Demo123!',
      role: UserRole.viewer,
      emoji: '👀',
      description: 'צופה - רק רואה, בלי לשנות',
    ),
  ];

  DemoFamilyService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// בודק אם משפחת הדמו כבר קיימת
  Future<bool> isDemoFamilyExists() async {
    try {
      final doc = await _firestore
          .collection('households')
          .doc(demoHouseholdId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ DemoFamilyService: שגיאה בבדיקה: $e');
      return false;
    }
  }

  /// יוצר את משפחת הדמו אם לא קיימת
  Future<void> ensureDemoFamilyExists() async {
    if (await isDemoFamilyExists()) {
      debugPrint('✅ DemoFamilyService: משפחת דמו כבר קיימת');
      return;
    }

    debugPrint('🏗️ DemoFamilyService: יוצר משפחת דמו...');

    try {
      // 1️⃣ יצירת משק הבית
      await _createDemoHousehold();

      // 2️⃣ יצירת המשתמשים ב-Firestore
      await _createDemoUsers();

      // 3️⃣ יצירת רשימות קניות עם היסטוריה
      await _createDemoShoppingLists();

      // 4️⃣ יצירת פריטים במלאי
      await _createDemoInventory();

      debugPrint('🎉 DemoFamilyService: משפחת דמו נוצרה בהצלחה!');
    } catch (e) {
      debugPrint('❌ DemoFamilyService: שגיאה ביצירת משפחת דמו: $e');
      rethrow;
    }
  }

  /// התחברות כמשתמש דמו
  Future<UserCredential> signInAsDemoUser(DemoUser user) async {
    debugPrint('🔐 DemoFamilyService: מתחבר כ-${user.name}...');

    UserCredential credential;

    try {
      // 1️⃣ קודם - נסה להתחבר
      credential = await _auth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      debugPrint('✅ DemoFamilyService: התחבר בהצלחה');
    } on FirebaseAuthException catch (e) {
      // המשתמש לא קיים או credentials לא נכונים - צור אותו
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        debugPrint('👤 DemoFamilyService: יוצר משתמש ${user.name}... (${e.code})');
        try {
          credential = await _auth.createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
          await credential.user?.updateDisplayName(user.name);
          debugPrint('✅ DemoFamilyService: משתמש נוצר');
        } on FirebaseAuthException catch (createError) {
          if (createError.code == 'email-already-in-use') {
            // המשתמש קיים אבל הסיסמה לא נכונה - זו בעיה
            debugPrint('❌ DemoFamilyService: משתמש קיים עם סיסמה אחרת');
            throw Exception('משתמש דמו קיים עם סיסמה שונה. נסה למחוק את המשתמש מ-Firebase Console.');
          }
          rethrow;
        }
      } else {
        debugPrint('❌ DemoFamilyService: שגיאת התחברות: ${e.code}');
        rethrow;
      }
    }

    // 2️⃣ השתמש ב-household של המשתמש שנוצר (house_<uid>)
    final userHouseholdId = 'house_${credential.user!.uid}';
    debugPrint('🏠 DemoFamilyService: משתמש ב-household: $userHouseholdId');

    // 3️⃣ צור נתוני דמו ב-household של המשתמש
    await _createDemoDataInUserHousehold(userHouseholdId, user, credential.user!.uid);

    return credential;
  }

  /// יוצר נתוני דמו ב-household של המשתמש
  Future<void> _createDemoDataInUserHousehold(
    String householdId,
    DemoUser demoUser,
    String realUid,
  ) async {
    debugPrint('🏗️ DemoFamilyService: יוצר נתוני דמו ב-$householdId...');

    try {
      // צור רשימות קניות דמו (עם ID קבוע כדי למנוע כפילויות)
      await _createDemoShoppingListsInHousehold(householdId, realUid, demoUser);

      // צור פריטי מלאי דמו
      await _createDemoInventoryInHousehold(householdId);

      debugPrint('🎉 DemoFamilyService: נתוני דמו נוצרו בהצלחה!');
    } catch (e) {
      debugPrint('❌ DemoFamilyService: שגיאה ביצירת נתוני דמו: $e');
      // לא זורקים שגיאה - המשתמש יכול להמשיך גם בלי נתוני דמו
    }
  }

  /// יוצר רשימות דמו ב-collection הראשי (לפי Security Rules)
  Future<void> _createDemoShoppingListsInHousehold(
    String householdId,
    String realUid,
    DemoUser demoUser,
  ) async {
    final now = DateTime.now();

    // ID קבוע לרשימת הדמו (כדי למנוע כפילויות)
    final demoListId = 'demo_list_$realUid';

    // שמירה ב-Firestore - ישירות ל-shopping_lists collection (לפי ה-Rules)
    final listData = {
      'id': demoListId,
      'name': 'קניות לשבת 🛒',
      'type': 'super',
      'status': 'active',
      'created_date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      'updated_date': Timestamp.fromDate(now),
      'created_by': realUid,
      'is_shared': false,
      'shared_with': [realUid],
      'format': 'personal',
      'created_from_template': false,
      'household_id': householdId, // חובה לפי Security Rules!
      'isDemo': true,
      'shared_users': [
        {
          'user_id': realUid,
          'role': demoUser.role.name,
          'shared_at': now.toIso8601String(),
          'user_name': demoUser.name,
        }
      ],
      'items': _createDemoItemsJson(),
    };

    await _firestore.collection('shopping_lists').doc(demoListId).set(listData);
    debugPrint('✅ DemoFamilyService: רשימת דמו נוצרה');
  }

  /// יוצר פריטי מלאי דמו ב-collection הראשי
  Future<void> _createDemoInventoryInHousehold(String householdId) async {
    final items = [
      {
        'id': 'demo_inv_1',
        'product_name': 'חלב תנובה 3%',
        'category': '🥛 מוצרי חלב',
        'quantity': 2,
        'unit': "יח'",
        'location': 'מקרר',
        'household_id': householdId, // חובה לפי Security Rules!
        'isDemo': true,
      },
      {
        'id': 'demo_inv_2',
        'product_name': 'ביצים',
        'category': '🥚 ביצים',
        'quantity': 12,
        'unit': "יח'",
        'location': 'מקרר',
        'household_id': householdId,
        'isDemo': true,
      },
    ];

    for (final item in items) {
      await _firestore.collection('inventory').doc(item['id'] as String).set(item);
    }
    debugPrint('✅ DemoFamilyService: פריטי מלאי דמו נוצרו');
  }

  /// יוצר JSON של פריטי דמו לרשימה
  List<Map<String, dynamic>> _createDemoItemsJson() {
    return [
      {
        'id': const Uuid().v4(),
        'type': 'product',
        'name': 'חלב תנובה 3%',
        'quantity': 3,
        'unit_price': 0,
        'category': '🥛 מוצרי חלב',
        'is_checked': true,
      },
      {
        'id': const Uuid().v4(),
        'type': 'product',
        'name': 'לחם אחיד',
        'quantity': 2,
        'unit_price': 0,
        'category': '🥖 לחם ומאפים',
        'is_checked': true,
      },
      {
        'id': const Uuid().v4(),
        'type': 'product',
        'name': 'עוף שלם',
        'quantity': 1,
        'unit_price': 0,
        'category': '🍖 בשר ועוף',
        'is_checked': false,
      },
      {
        'id': const Uuid().v4(),
        'type': 'product',
        'name': 'עגבניות',
        'quantity': 6,
        'unit_price': 0,
        'category': '🥬 ירקות ופירות',
        'is_checked': false,
      },
      {
        'id': const Uuid().v4(),
        'type': 'task',
        'name': 'לבדוק מבצעים בירקות',
        'is_checked': true,
      },
      {
        'id': const Uuid().v4(),
        'type': 'task',
        'name': 'לקחת שקיות רב פעמיות',
        'is_checked': false,
      },
    ];
  }

  // === Private Methods ===

  Future<void> _createDemoHousehold() async {
    await _firestore.collection('households').doc(demoHouseholdId).set({
      'id': demoHouseholdId,
      'name': 'משפחת כהן',
      'createdAt': FieldValue.serverTimestamp(),
      'isDemo': true,
      'members': demoUsers.map((u) => u.id).toList(),
    });
  }

  Future<void> _createDemoUsers() async {
    for (final user in demoUsers) {
      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'householdId': demoHouseholdId,
        'createdAt': FieldValue.serverTimestamp(),
        'isDemo': true,
      });
    }
  }

  Future<void> _createDemoShoppingLists() async {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    // יצירת SharedUsers
    final sharedUsersList = demoUsers.map((u) => SharedUser(
      userId: u.id,
      role: u.role,
      sharedAt: twoWeeksAgo,
      userName: u.name,
    )).toList();

    // 📝 רשימה פעילה - קניות השבוע
    final activeList = ShoppingList(
      id: demoListId1,
      name: 'קניות לשבת',
      type: 'super',
      status: 'active',
      createdDate: now.subtract(const Duration(days: 2)),
      updatedDate: now,
      createdBy: demoUsers[0].id, // דוד
      isShared: true,
      sharedWith: demoUsers.map((u) => u.id).toList(),
      format: 'shared',
      createdFromTemplate: false,
      sharedUsers: sharedUsersList,
      items: _createDemoItems(),
      pendingRequests: _createDemoPendingRequests(),
    );

    // ✅ רשימה שהושלמה - מלפני שבוע
    final completedList = ShoppingList(
      id: demoListId2,
      name: 'קניות לאירוע',
      type: 'super',
      status: 'completed',
      createdDate: now.subtract(const Duration(days: 10)),
      updatedDate: now.subtract(const Duration(days: 7)),
      createdBy: demoUsers[0].id,
      isShared: true,
      sharedWith: demoUsers.map((u) => u.id).toList(),
      format: 'shared',
      createdFromTemplate: false,
      sharedUsers: sharedUsersList,
      items: _createCompletedDemoItems(),
    );

    // שמירה ב-Firestore
    final listsRef = _firestore
        .collection('households')
        .doc(demoHouseholdId)
        .collection('shopping_lists');

    await listsRef.doc(activeList.id).set(activeList.toJson());
    await listsRef.doc(completedList.id).set(completedList.toJson());
  }

  List<UnifiedListItem> _createDemoItems() {
    return [
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'חלב תנובה 3%',
        quantity: 3,
        unitPrice: 0,
        category: '🥛 מוצרי חלב',
        isChecked: true,
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'לחם אחיד',
        quantity: 2,
        unitPrice: 0,
        category: '🥖 לחם ומאפים',
        isChecked: true,
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'עוף שלם',
        quantity: 1,
        unitPrice: 0,
        category: '🍖 בשר ועוף',
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'עגבניות',
        quantity: 6,
        unitPrice: 0,
        category: '🥬 ירקות ופירות',
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'מלפפונים',
        quantity: 4,
        unitPrice: 0,
        category: '🥬 ירקות ופירות',
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'גבינה צהובה',
        quantity: 1,
        unitPrice: 0,
        category: '🥛 מוצרי חלב',
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'ביצים L',
        quantity: 2,
        unitPrice: 0,
        category: '🥚 ביצים',
        unit: 'תבניות',
      ),
      UnifiedListItem.task(
        id: const Uuid().v4(),
        name: 'לבדוק מבצעים בירקות',
        isChecked: true,
      ),
      UnifiedListItem.task(
        id: const Uuid().v4(),
        name: 'לקחת שקיות רב פעמיות',
      ),
    ];
  }

  List<UnifiedListItem> _createCompletedDemoItems() {
    return [
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'יין אדום',
        quantity: 2,
        unitPrice: 0,
        category: '🍷 משקאות',
        isChecked: true,
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'עוגת שוקולד',
        quantity: 1,
        unitPrice: 0,
        category: '🍰 קינוחים',
        isChecked: true,
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'גבינות לאירוח',
        quantity: 3,
        unitPrice: 0,
        category: '🥛 מוצרי חלב',
        isChecked: true,
      ),
      UnifiedListItem.product(
        id: const Uuid().v4(),
        name: 'קרקרים',
        quantity: 2,
        unitPrice: 0,
        category: '🍪 חטיפים',
        isChecked: true,
      ),
    ];
  }

  List<PendingRequest> _createDemoPendingRequests() {
    // בקשה ממתינה מיונתן (Editor)
    return [
      PendingRequest.newRequest(
        listId: demoListId1,
        requesterId: demoUsers[2].id, // יונתן
        type: RequestType.addItem,
        requestData: {
          'name': 'במבה',
          'quantity': 3,
          'category': '🍪 חטיפים',
        },
        requesterName: demoUsers[2].name,
      ),
    ];
  }

  Future<void> _createDemoInventory() async {
    final inventoryRef = _firestore
        .collection('households')
        .doc(demoHouseholdId)
        .collection('inventory');

    final items = [
      InventoryItem(
        id: const Uuid().v4(),
        productName: 'חלב תנובה 3%',
        category: '🥛 מוצרי חלב',
        quantity: 2,
        unit: "יח'",
        location: 'מקרר',
      ),
      InventoryItem(
        id: const Uuid().v4(),
        productName: 'ביצים',
        category: '🥚 ביצים',
        quantity: 12,
        unit: "יח'",
        location: 'מקרר',
      ),
      InventoryItem(
        id: const Uuid().v4(),
        productName: 'אורז',
        category: '🍚 דגנים וקטניות',
        quantity: 1,
        unit: 'ק"ג',
        location: 'מזווה',
      ),
      InventoryItem(
        id: const Uuid().v4(),
        productName: 'שמן זית',
        category: '🫒 שמנים',
        quantity: 1,
        unit: 'בקבוק',
        location: 'מזווה',
      ),
    ];

    for (final item in items) {
      await inventoryRef.doc(item.id).set(item.toJson());
    }
  }

  /// מחיקת משפחת הדמו (לניקוי)
  Future<void> deleteDemoFamily() async {
    debugPrint('🗑️ DemoFamilyService: מוחק משפחת דמו...');

    try {
      // מחק רשימות קניות
      final listsSnapshot = await _firestore
          .collection('households')
          .doc(demoHouseholdId)
          .collection('shopping_lists')
          .get();

      for (final doc in listsSnapshot.docs) {
        await doc.reference.delete();
      }

      // מחק מלאי
      final inventorySnapshot = await _firestore
          .collection('households')
          .doc(demoHouseholdId)
          .collection('inventory')
          .get();

      for (final doc in inventorySnapshot.docs) {
        await doc.reference.delete();
      }

      // מחק משק בית
      await _firestore.collection('households').doc(demoHouseholdId).delete();

      // מחק משתמשי דמו
      for (final user in demoUsers) {
        await _firestore.collection('users').doc(user.id).delete();
      }

      debugPrint('✅ DemoFamilyService: משפחת דמו נמחקה');
    } catch (e) {
      debugPrint('❌ DemoFamilyService: שגיאה במחיקה: $e');
    }
  }
}
