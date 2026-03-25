// 📄 File: lib/services/saved_contacts_service.dart
//
// 🎯 Purpose: שירות לניהול אנשי קשר שמורים
//
// 📋 Features:
// - שמירת אנשי קשר לאחר הזמנה מוצלחת
// - טעינת אנשי קשר שמורים
// - עדכון זמן הזמנה אחרונה
// - מחיקת איש קשר
//
// 🔗 Related:
// - saved_contact.dart - מודל איש קשר
// - share_list_service.dart - שירות שיתוף
// - invite_users_screen.dart - מסך הזמנה
//
// Version: 1.0
// Created: 30/11/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/saved_contact.dart';
import '../repositories/constants/repository_constants.dart';

/// שירות לניהול אנשי קשר שמורים
///
/// מאפשר למשתמשים לשמור אנשי קשר לאחר הזמנה ראשונה
/// ולהזמין אותם בקלות לרשימות נוספות בעתיד.
class SavedContactsService {
  final FirebaseFirestore _firestore;

  /// Collection name for saved contacts
  static const String _collectionName = 'saved_contacts';

  SavedContactsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// קבלת reference לאוסף אנשי הקשר של משתמש
  CollectionReference<Map<String, dynamic>> _getUserContactsRef(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(_collectionName);
  }

  /// טעינת כל אנשי הקשר השמורים של המשתמש
  ///
  /// ממוין לפי זמן הזמנה אחרונה (החדש ביותר קודם)
  Future<List<SavedContact>> getContacts(String userId) async {

    try {
      final snapshot = await _getUserContactsRef(userId)
          .orderBy('last_invited_at', descending: true)
          .get();

      final contacts = snapshot.docs
          .map((doc) => SavedContact.fromJson(doc.data()))
          .toList();

      // 🔧 Fallback sort: רשומות ישנות ללא last_invited_at מגיעות בסוף מ-Firestore
      // effectiveLastInvitedAt משתמש ב-addedAt כ-fallback לרשומות כאלה
      contacts.sort((a, b) =>
          b.effectiveLastInvitedAt.compareTo(a.effectiveLastInvitedAt));


      return contacts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ SavedContactsService.getContacts failed: $e');
      }
      // rethrow כדי שה-UI יוכל להציג שגיאה למשתמש
      rethrow;
    }
  }

  /// שמירת איש קשר חדש
  ///
  /// אם איש הקשר כבר קיים, מעדכן את זמן ההזמנה האחרונה
  Future<void> saveContact({
    required String currentUserId,
    required String contactUserId,
    String? contactUserName,
    required String contactUserEmail,
    String? contactUserAvatar,
  }) async {
    try {
      final docRef = _getUserContactsRef(currentUserId).doc(contactUserId);
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        // איש קשר קיים - עדכון זמן הזמנה אחרונה
        await docRef.update({
          'last_invited_at': FieldValue.serverTimestamp(),
          // עדכון פרטים אם השתנו
          'user_name': contactUserName,
          'user_avatar': contactUserAvatar,
        });
      } else {
        // איש קשר חדש - יצירה
        final contact = SavedContact.fromUserDetails(
          userId: contactUserId,
          userName: contactUserName,
          userEmail: contactUserEmail,
          userAvatar: contactUserAvatar,
        );
        await docRef.set(contact.toJson());
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ SavedContactsService.saveContact: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  /// מחיקת איש קשר
  Future<void> deleteContact({
    required String currentUserId,
    required String contactUserId,
  }) async {
    try {
      await _getUserContactsRef(currentUserId).doc(contactUserId).delete();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ SavedContactsService.deleteContact: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      rethrow;
    }
  }

}
