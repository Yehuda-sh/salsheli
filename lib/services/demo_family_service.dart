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

    // 1️⃣ קודם - יוצר/מתחבר לכל משתמשי הדמו כדי לקבל את ה-UIDs שלהם
    final Map<String, String> demoUserUids = await _ensureAllDemoUsersExist();

    // 2️⃣ מתחבר לדוד (הבעלים) כדי ליצור את הנתונים המשותפים
    final ownerUid = demoUserUids['david.demo@memozap.app']!;
    final sharedHouseholdId = 'house_$ownerUid';

    await _auth.signInWithEmailAndPassword(
      email: 'david.demo@memozap.app',
      password: 'Demo123!',
    );
    debugPrint('🏠 DemoFamilyService: מחובר כדוד, יוצר נתונים ב-$sharedHouseholdId');

    // 3️⃣ צור נתוני דמו עם כל בני המשפחה (כדוד - הבעלים)
    await _createSharedDemoData(sharedHouseholdId, demoUserUids);

    // 4️⃣ עכשיו מתחבר למשתמש שנבחר
    if (user.email != 'david.demo@memozap.app') {
      await _auth.signOut();
      final credential = await _auth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      debugPrint('✅ DemoFamilyService: התחבר בהצלחה כ-${user.name}');
      return credential;
    }

    debugPrint('✅ DemoFamilyService: נשאר מחובר כ-${user.name}');
    // אם בחרו בדוד - כבר מחוברים
    return await _auth.signInWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
  }

  /// יוצר/מתחבר לכל משתמשי הדמו ומחזיר מפה של email -> uid
  Future<Map<String, String>> _ensureAllDemoUsersExist() async {
    final Map<String, String> uids = {};

    for (final demoUser in demoUsers) {
      try {
        // נסה להתחבר
        final credential = await _auth.signInWithEmailAndPassword(
          email: demoUser.email,
          password: demoUser.password,
        );
        uids[demoUser.email] = credential.user!.uid;
        debugPrint('✅ ${demoUser.name}: uid=${credential.user!.uid}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // צור משתמש חדש
          final credential = await _auth.createUserWithEmailAndPassword(
            email: demoUser.email,
            password: demoUser.password,
          );
          await credential.user?.updateDisplayName(demoUser.name);
          uids[demoUser.email] = credential.user!.uid;
          debugPrint('👤 ${demoUser.name} נוצר: uid=${credential.user!.uid}');
        } else {
          debugPrint('❌ שגיאה עם ${demoUser.name}: ${e.code}');
          rethrow;
        }
      }
    }

    // התנתק כדי שנוכל להתחבר למשתמש הנכון
    await _auth.signOut();

    return uids;
  }

  /// יוצר נתוני דמו משותפים לכל המשפחה
  Future<void> _createSharedDemoData(
    String householdId,
    Map<String, String> demoUserUids,
  ) async {
    debugPrint('🏗️ DemoFamilyService: יוצר נתוני דמו משותפים...');

    try {
      // בדוק אם הרשימה כבר קיימת
      final listDoc = await _firestore.collection('shopping_lists').doc('demo_list_shared').get();
      if (listDoc.exists) {
        debugPrint('✅ DemoFamilyService: נתוני דמו כבר קיימים');
        return;
      }

      // צור רשימת קניות משותפת עם כל בני המשפחה
      await _createSharedDemoShoppingList(householdId, demoUserUids);

      // צור פריטי מלאי דמו
      await _createDemoInventoryInHousehold(householdId);

      debugPrint('🎉 DemoFamilyService: נתוני דמו משותפים נוצרו בהצלחה!');
    } catch (e) {
      debugPrint('❌ DemoFamilyService: שגיאה ביצירת נתוני דמו: $e');
    }
  }

  /// יוצר רשימת קניות משותפת עם כל בני המשפחה
  Future<void> _createSharedDemoShoppingList(
    String householdId,
    Map<String, String> demoUserUids,
  ) async {
    final now = DateTime.now();
    final ownerUid = demoUserUids['david.demo@memozap.app']!;

    // בניית רשימת shared_users עם כל בני המשפחה
    final List<Map<String, dynamic>> sharedUsers = [];
    final List<String> sharedWith = [];

    for (final demoUser in demoUsers) {
      final uid = demoUserUids[demoUser.email]!;
      sharedWith.add(uid);
      sharedUsers.add({
        'user_id': uid,
        'role': demoUser.role.name,
        'shared_at': now.toIso8601String(),
        'user_name': demoUser.name,
      });
    }

    final listData = {
      'id': 'demo_list_shared',
      'name': 'קניות לשבת 🛒',
      'type': 'super',
      'status': 'active',
      'created_date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      'updated_date': Timestamp.fromDate(now),
      'created_by': ownerUid,
      'is_shared': true,
      'shared_with': sharedWith,
      'format': 'personal',
      'created_from_template': false,
      'household_id': householdId,
      'isDemo': true,
      'shared_users': sharedUsers,
      'items': _createDemoItemsJson(),
    };

    await _firestore.collection('shopping_lists').doc('demo_list_shared').set(listData);
    debugPrint('✅ DemoFamilyService: רשימת דמו משותפת נוצרה עם ${sharedUsers.length} משתמשים');
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
