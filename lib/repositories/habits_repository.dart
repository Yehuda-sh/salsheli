// 📄 File: lib/repositories/habits_repository.dart
//
// 🎯 Purpose: Interface למאגר הרגלי קנייה - מגדיר חוזה לגישת נתונים
//
// 🏗️ Architecture: Repository Pattern
//     - Interface מופשט
//     - מאפשר החלפת מימוש (Firebase / Local / Mock)
//     - הפרדה בין Provider ל-Data Source
//
// 📦 Usage:
//     class FirebaseHabitsRepository implements HabitsRepository { ... }
//     class MockHabitsRepository implements HabitsRepository { ... }
//
// Version: 1.0
// Created: 17/10/2025

import '../models/habit_preference.dart';

/// Interface למאגר הרגלי קנייה
abstract class HabitsRepository {
  /// טוען את כל הרגלי הקנייה של household
  /// 
  /// Parameters:
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: רשימת הרגלי קנייה ממוינים לפי last_purchased
  /// 
  /// Throws: Exception אם הטעינה נכשלה
  Future<List<HabitPreference>> fetchHabits(String householdId);

  /// יוצר הרגל קנייה חדש
  /// 
  /// Parameters:
  /// - habit: ההרגל ליצירה (ללא ID)
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: ההרגל שנוצר עם ID
  /// 
  /// Throws: Exception אם היצירה נכשלה
  Future<HabitPreference> createHabit(
    HabitPreference habit,
    String householdId,
  );

  /// מעדכן הרגל קנייה קיים
  /// 
  /// Parameters:
  /// - habit: ההרגל המעודכן (חייב לכלול ID)
  /// - householdId: מזהה משק הבית
  /// 
  /// Throws: Exception אם העדכון נכשל
  Future<void> updateHabit(
    HabitPreference habit,
    String householdId,
  );

  /// מוחק הרגל קנייה
  /// 
  /// Parameters:
  /// - habitId: מזהה ההרגל למחיקה
  /// - householdId: מזהה משק הבית
  /// 
  /// Throws: Exception אם המחיקה נכשלה
  Future<void> deleteHabit(String habitId, String householdId);

  /// ספירת כמות ההרגלים של משק בית
  /// 
  /// Parameters:
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: מספר ההרגלים
  /// 
  /// Throws: Exception אם הספירה נכשלה
  Future<int> countHabits(String householdId);

  /// חיפוש הרגל לפי שם המוצר המועדף
  /// 
  /// Parameters:
  /// - productName: שם המוצר המדויק
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: ההרגל אם נמצא, null אם לא
  /// 
  /// Throws: Exception אם החיפוש נכשל
  Future<HabitPreference?> findByProduct(
    String productName,
    String householdId,
  );
}
