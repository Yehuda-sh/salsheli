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

  FirebaseHabitsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// קבלת collection reference
  CollectionReference get _collection =>
      _firestore.collection('habit_preferences');

  /// 📥 טעינת כל ההרגלים למשק בית
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
      rethrow;
    }
  }

  /// ➕ יצירת הרגל חדש
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
      rethrow;
    }
  }

  /// ✏️ עדכון הרגל קיים
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
      rethrow;
    }
  }

  /// 🗑️ מחיקת הרגל
  Future<void> deleteHabit(String habitId) async {
    debugPrint('🔥 FirebaseHabitsRepo.deleteHabit: $habitId');

    try {
      await _collection.doc(habitId).delete();
      debugPrint('   ✅ הרגל נמחק');
    } catch (e, stack) {
      debugPrint('   ❌ שגיאה במחיקת הרגל: $e');
      debugPrint('   📍 Stack: $stack');
      rethrow;
    }
  }

  /// 📊 ספירת הרגלים למשק בית
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
      rethrow;
    }
  }

  /// 🔍 חיפוש הרגל לפי מוצר
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
      rethrow;
    }
  }
}
