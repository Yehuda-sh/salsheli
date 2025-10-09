// 📄 File: lib/repositories/firebase_habits_repository.dart
//
// 🇮🇱 **Firebase Habits Repository** - ניהול הרגלי קנייה ב-Firestore
//
// **Collection:** `habit_preferences`
// **Document Structure:**
// ```
// {
//   "preferred_product": "חלב תנובה 3%",
//   "generic_name": "חלב",
//   "frequency_days": 7,
//   "last_purchased": Timestamp,
//   "created_date": Timestamp,
//   "updated_date": Timestamp,
//   "household_id": "xyz123"  ← הוסף ב-Repository
// }
// ```
//
// **Security Rules:**
// ```
// match /habit_preferences/{habitId} {
//   allow read, write: if request.auth != null
//     && resource.data.household_id == request.auth.token.household_id;
// }
// ```
//
// **Version:** 1.0

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/habit_preference.dart';

class FirebaseHabitsRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'habit_preferences';

  /// יוצר instance חדש של FirebaseHabitsRepository
  /// 
  /// Parameters:
  ///   - [firestore]: instance של FirebaseFirestore (אופציונלי, ברירת מחדל: instance ראשי)
  /// 
  /// Example:
  /// ```dart
  /// // שימוש רגיל
  /// final repo = FirebaseHabitsRepository();
  /// 
  /// // עם FirebaseFirestore מותאם
  /// final repo = FirebaseHabitsRepository(
  ///   firestore: FirebaseFirestore.instanceFor(app: myApp),
  /// );
  /// ```
  FirebaseHabitsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// קבלת collection reference
  CollectionReference get _collection =>
      _firestore.collection(_collectionName);

  /// טוען את כל הרגלי הקנייה של משק בית
  /// 
  /// מבצע query ב-Firestore עם household_id וממיין לפי תאריך קנייה אחרון (מהחדש לישן).
  /// השימוש הוא דרך HabitsProvider שמנהל את ההרגלים.
  /// 
  /// Parameters:
  ///   - [householdId]: מזהה המשק בית (למשל: 'house_demo')
  /// 
  /// Returns:
  ///   - List של HabitPreference ממוין לפי last_purchased (יורד)
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] במקרה של שגיאת Firestore
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final habits = await repo.fetchHabits('house_demo');
  ///   print('נטענו ${habits.length} הרגלים');
  /// } catch (e) {
  ///   print('שגיאה בטעינת הרגלים: $e');
  /// }
  /// ```
  Future<List<HabitPreference>> fetchHabits(String householdId) async {
    debugPrint('🔥 FirebaseHabitsRepo.fetchHabits: household=$householdId');

    try {
      final snapshot = await _collection
          .where('household_id', isEqualTo: householdId)
          .orderBy('last_purchased', descending: true)
          .get();

      final habits = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // הוספת document ID
            return HabitPreference.fromJson(data);
          })
          .toList();

      debugPrint('   ✅ ${habits.length} הרגלים נטענו');
      return habits;
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה בטעינת הרגלים: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to fetch habits for $householdId', e);
    }
  }

  /// יוצר הרגל קנייה חדש
  /// 
  /// מוסיף timestamps אוטומטית (createdDate, updatedDate) ו-household_id.
  /// מחזיר את ההרגל עם ה-ID שנוצר ב-Firestore.
  /// 
  /// Parameters:
  ///   - [habit]: ההרגל ליצירה (ללא ID)
  ///   - [householdId]: מזהה המשק בית שההרגל שייך אליו
  /// 
  /// Returns:
  ///   - HabitPreference עם ID, createdDate, updatedDate
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] במקרה של שגיאת שמירה
  /// 
  /// Example:
  /// ```dart
  /// final habit = HabitPreference(
  ///   preferredProduct: 'חלב תנובה 3%',
  ///   genericName: 'חלב',
  ///   frequencyDays: 7,
  /// );
  /// 
  /// final created = await repo.createHabit(habit, 'house_demo');
  /// print('נוצר הרגל: ${created.id}');
  /// ```
  Future<HabitPreference> createHabit(
    HabitPreference habit,
    String householdId,
  ) async {
    debugPrint('🔥 FirebaseHabitsRepo.createHabit: ${habit.preferredProduct}');

    try {
      final now = DateTime.now();
      final data = habit
          .copyWith(
            createdDate: now,
            updatedDate: now,
          )
          .toJson();

      // הוספת household_id
      data['household_id'] = householdId;

      final docRef = await _collection.add(data);
      debugPrint('   ✅ הרגל נוצר: ${docRef.id}');

      return habit.copyWith(
        id: docRef.id,
        createdDate: now,
        updatedDate: now,
      );
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה ביצירת הרגל: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to create habit', e);
    }
  }

  /// מעדכן הרגל קנייה קיים
  /// 
  /// מעדכן את updatedDate אוטומטית ומוודא שהשדה household_id נשמר.
  /// 
  /// Parameters:
  ///   - [habit]: ההרגל המעודכן (חייב לכלול ID)
  ///   - [householdId]: מזהה המשק בית (לאימות)
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] במקרה של שגיאת עדכון
  /// 
  /// Example:
  /// ```dart
  /// final updated = habit.copyWith(frequencyDays: 10);
  /// await repo.updateHabit(updated, 'house_demo');
  /// print('הרגל עודכן');
  /// ```
  Future<void> updateHabit(
    HabitPreference habit,
    String householdId,
  ) async {
    debugPrint('🔥 FirebaseHabitsRepo.updateHabit: ${habit.id}');

    try {
      final data = habit
          .copyWith(updatedDate: DateTime.now())
          .toJson();

      // וידוא household_id
      data['household_id'] = householdId;

      await _collection.doc(habit.id).update(data);
      debugPrint('   ✅ הרגל עודכן');
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה בעדכון הרגל: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to update habit ${habit.id}', e);
    }
  }

  /// מוחק הרגל קנייה
  /// 
  /// 🔒 בדיקת אבטחה: מוודא שההרגל שייך ל-household לפני מחיקה.
  /// אם ההרגל לא קיים או לא שייך ל-household, לא מבצע מחיקה.
  /// 
  /// Parameters:
  ///   - [habitId]: מזהה ההרגל למחיקה
  ///   - [householdId]: מזהה המשק בית (לאימות בעלות)
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] אם ההרגל לא שייך ל-household או שגיאה במחיקה
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await repo.deleteHabit('habit_123', 'house_demo');
  ///   print('הרגל נמחק בהצלחה');
  /// } catch (e) {
  ///   print('שגיאה במחיקה: $e');
  /// }
  /// ```
  Future<void> deleteHabit(String habitId, String householdId) async {
    debugPrint('🔥 FirebaseHabitsRepo.deleteHabit: $habitId');

    try {
      // 🔒 בדיקת אבטחה - וידוא שההרגל שייך ל-household
      final doc = await _collection.doc(habitId).get();
      
      if (!doc.exists) {
        debugPrint('   ⚠️ הרגל לא קיים');
        return;
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data?['household_id'] != householdId) {
        debugPrint('   ⚠️ הרגל לא שייך ל-household זה');
        throw HabitsRepositoryException('Habit does not belong to household', null);
      }

      await _collection.doc(habitId).delete();
      debugPrint('   ✅ הרגל נמחק');
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה במחיקת הרגל: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to delete habit $habitId', e);
    }
  }

  /// ספירת כמות ההרגלים של משק בית
  /// 
  /// שימושי לסטטיסטיקות ו-dashboard.
  /// 
  /// Parameters:
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - מספר ההרגלים (0 אם אין)
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] במקרה של שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final count = await repo.countHabits('house_demo');
  /// print('יש $count הרגלי קנייה');
  /// ```
  Future<int> countHabits(String householdId) async {
    debugPrint('🔥 FirebaseHabitsRepo.countHabits: household=$householdId');

    try {
      final snapshot = await _collection
          .where('household_id', isEqualTo: householdId)
          .count()
          .get();

      final count = snapshot.count ?? 0;
      debugPrint('   ✅ נמצאו $count הרגלים');
      return count;
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה בספירת הרגלים: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to count habits for $householdId', e);
    }
  }

  /// חיפוש הרגל לפי שם המוצר המועדף
  /// 
  /// מחזיר את ההרגל הראשון שמתאים (limit 1).
  /// 
  /// Parameters:
  ///   - [productName]: שם המוצר המדויק (case-sensitive)
  ///   - [householdId]: מזהה המשק בית
  /// 
  /// Returns:
  ///   - HabitPreference אם נמצא, null אם לא
  /// 
  /// Throws:
  ///   - [HabitsRepositoryException] במקרה של שגיאה
  /// 
  /// Example:
  /// ```dart
  /// final habit = await repo.findByProduct('חלב תנובה 3%', 'house_demo');
  /// if (habit != null) {
  ///   print('נמצא הרגל: קונים כל ${habit.frequencyDays} ימים');
  /// }
  /// ```
  Future<HabitPreference?> findByProduct(
    String productName,
    String householdId,
  ) async {
    debugPrint(
      '🔥 FirebaseHabitsRepo.findByProduct: "$productName", household=$householdId',
    );

    try {
      final snapshot = await _collection
          .where('household_id', isEqualTo: householdId)
          .where('preferred_product', isEqualTo: productName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('   ⚠️ לא נמצא הרגל');
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      final habit = HabitPreference.fromJson(data);
      debugPrint('   ✅ נמצא: ${habit.id}');
      return habit;
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה בחיפוש הרגל: $e');
      debugPrint('   📍 Stack: $stack');
      throw HabitsRepositoryException('Failed to find habit by product', e);
    }
  }
}

/// Exception class for habits repository errors
/// 
/// משמש לטיפול בשגיאות ספציפיות של ה-repository.
/// 
/// Example:
/// ```dart
/// try {
///   await repo.fetchHabits('house_demo');
/// } catch (e) {
///   if (e is HabitsRepositoryException) {
///     print('שגיאת Repository: ${e.message}');
///     print('סיבה: ${e.cause}');
///   }
/// }
/// ```
class HabitsRepositoryException implements Exception {
  final String message;
  final Object? cause;

  HabitsRepositoryException(this.message, this.cause);

  @override
  String toString() => 'HabitsRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
