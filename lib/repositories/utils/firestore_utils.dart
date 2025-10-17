// 📄 File: lib/repositories/utils/firestore_utils.dart
//
// 🎯 Purpose: Utility functions for Firestore operations
//
// Version: 1.0
// Created: 17/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for Firestore operations
class FirestoreUtils {
  /// המרת Timestamp fields ל-ISO 8601 strings
  /// 
  /// Firestore מחזיר Timestamp objects, אבל המודלים שלנו מצפים ל-DateTime strings.
  /// פונקציה זו ממירה אוטומטית את כל השדות המוכרים.
  /// 
  /// Parameters:
  /// - data: המפה להמרה
  /// - timestampFields: רשימת שדות להמרה (אופציונלי)
  /// 
  /// Returns: המפה עם שדות מומרים
  static Map<String, dynamic> convertTimestamps(
    Map<String, dynamic> data, {
    List<String>? timestampFields,
  }) {
    // שדות ברירת מחדל נפוצים
    final defaultFields = [
      'created_date',
      'updated_date',
      'last_login_at',
      'joined_at',
      'date',
      'last_purchased',
      'created_at',
      'updated_at',
    ];
    
    final fieldsToConvert = timestampFields ?? defaultFields;
    
    // ✅ יצירת עותק של הדאטה כדי לא לשנות את המקור
    final result = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToConvert) {
      if (result.containsKey(field) && result[field] is Timestamp) {
        result[field] = (result[field] as Timestamp).toDate().toIso8601String();
      }
    }
    
    return result;
  }

  /// המרת DateTime ל-Timestamp לשמירה ב-Firestore
  /// 
  /// Parameters:
  /// - data: המפה להמרה
  /// - dateFields: רשימת שדות להמרה
  /// 
  /// Returns: המפה עם Timestamp objects
  static Map<String, dynamic> convertToTimestamps(
    Map<String, dynamic> data, {
    List<String>? dateFields,
  }) {
    final defaultFields = [
      'created_date',
      'updated_date',
      'date',
      'last_purchased',
    ];
    
    final fieldsToConvert = dateFields ?? defaultFields;
    
    for (final field in fieldsToConvert) {
      if (data.containsKey(field)) {
        final value = data[field];
        if (value is DateTime) {
          data[field] = Timestamp.fromDate(value);
        } else if (value is String) {
          try {
            final date = DateTime.parse(value);
            data[field] = Timestamp.fromDate(date);
          } catch (_) {
            // Skip invalid dates
          }
        }
      }
    }
    
    return data;
  }

  /// בדיקת בעלות על מסמך
  /// 
  /// מוודא שמסמך שייך ל-household מסוים לפני ביצוע פעולה
  /// 
  /// Parameters:
  /// - firestore: instance של Firestore
  /// - collection: שם ה-collection
  /// - documentId: מזהה המסמך
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: true אם המסמך שייך ל-household
  static Future<bool> verifyOwnership({
    required FirebaseFirestore firestore,
    required String collection,
    required String documentId,
    required String householdId,
  }) async {
    try {
      final doc = await firestore
          .collection(collection)
          .doc(documentId)
          .get();
      
      if (!doc.exists) {
        return false;
      }
      
      final data = doc.data();
      return data?['household_id'] == householdId;
    } catch (_) {
      return false;
    }
  }

  /// יצירת batch מ-items רבים
  /// 
  /// מחלק רשימה גדולה ל-batches קטנים יותר (מקסימום 500 לבאץ')
  /// 
  /// Parameters:
  /// - items: רשימת הפריטים
  /// - batchSize: גודל כל batch (ברירת מחדל: 500)
  /// 
  /// Returns: רשימת batches
  static List<List<T>> createBatches<T>(
    List<T> items, {
    int batchSize = 500,
  }) {
    final batches = <List<T>>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) 
          ? i + batchSize 
          : items.length;
      batches.add(items.sublist(i, end));
    }
    
    return batches;
  }

  /// הוספת household_id לנתונים
  /// 
  /// מוסיף או מעדכן household_id במפה
  /// 
  /// Parameters:
  /// - data: המפה לעדכון
  /// - householdId: מזהה משק הבית
  /// 
  /// Returns: המפה עם household_id
  static Map<String, dynamic> addHouseholdId(
    Map<String, dynamic> data,
    String householdId,
  ) {
    data['household_id'] = householdId;
    return data;
  }

  /// יצירת document ID ייחודי לפי household
  /// 
  /// יוצר ID בפורמט: {householdId}_{key}
  /// 
  /// Parameters:
  /// - householdId: מזהה משק הבית
  /// - key: מפתח ייחודי
  /// 
  /// Returns: document ID
  static String createHouseholdDocId(String householdId, String key) {
    return '${householdId}_$key';
  }
  
  /// בדיקה אם שדה קיים וחוקי
  /// 
  /// בודק אם שדה קיים במפה ולא null או ריק
  /// 
  /// Parameters:
  /// - data: המפה לבדיקה
  /// - field: שם השדה
  /// 
  /// Returns: true אם השדה קיים וחוקי
  static bool hasValidField(Map<String, dynamic> data, String field) {
    final value = data[field];
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  /// ניקוי שדות ריקים ממפה
  /// 
  /// מסיר שדות עם ערכים null, "" (strings ריקים), או רשימות ריקות
  /// 
  /// Parameters:
  /// - data: המפה לניקוי
  /// 
  /// Returns: המפה המנוקה
  static Map<String, dynamic> cleanEmptyFields(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      if (value is List && value.isEmpty) return;
      if (value is Map && value.isEmpty) return;
      cleaned[key] = value;
    });
    
    return cleaned;
  }

  /// בדיקת תקינות של household_id
  /// 
  /// מוודא שה-household_id קיים וחוקי
  /// 
  /// Parameters:
  /// - data: המפה לבדיקה
  /// - expectedHouseholdId: ה-household_id הצפוי
  /// 
  /// Returns: true אם ה-household_id תואם
  static bool validateHouseholdId(
    Map<String, dynamic> data,
    String expectedHouseholdId,
  ) {
    final householdId = data['household_id'];
    return householdId != null && householdId == expectedHouseholdId;
  }

  /// יצירת query בסיסי עם household_id
  /// 
  /// יוצר query עם סינון לפי household_id ומיון default
  /// 
  /// Parameters:
  /// - collection: ה-collection reference
  /// - householdId: מזהה משק הבית
  /// - orderByField: שדה למיון (אופציונלי)
  /// - descending: כיוון המיון (ברירת מחדל: false)
  /// 
  /// Returns: Query מוכן לביצוע
  static Query<Map<String, dynamic>> createHouseholdQuery({
    required CollectionReference<Map<String, dynamic>> collection,
    required String householdId,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = collection
        .where('household_id', isEqualTo: householdId);
    
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    
    return query;
  }
  
  // Prevent instantiation
  const FirestoreUtils._();
}
