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
        .collection('users')
        .doc(userId)
        .collection(_collectionName);
  }

  /// טעינת כל אנשי הקשר השמורים של המשתמש
  ///
  /// ממוין לפי זמן הזמנה אחרונה (החדש ביותר קודם)
  Future<List<SavedContact>> getContacts(String userId) async {
    if (kDebugMode) {
      debugPrint('📇 SavedContactsService.getContacts():');
      debugPrint('   User: $userId');
    }

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

      if (kDebugMode) {
        debugPrint('   ✅ Found ${contacts.length} contacts');
      }

      return contacts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Error loading contacts: $e');
      }
      return [];
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
    if (kDebugMode) {
      debugPrint('💾 SavedContactsService.saveContact():');
      debugPrint('   CurrentUser: $currentUserId');
      debugPrint('   Contact: $contactUserId ($contactUserEmail)');
    }

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
        if (kDebugMode) {
          debugPrint('   ✅ Contact updated (last_invited_at)');
        }
      } else {
        // איש קשר חדש - יצירה
        final contact = SavedContact.fromUserDetails(
          userId: contactUserId,
          userName: contactUserName,
          userEmail: contactUserEmail,
          userAvatar: contactUserAvatar,
        );
        await docRef.set(contact.toJson());
        if (kDebugMode) {
          debugPrint('   ✅ New contact saved');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Error saving contact: $e');
      }
      rethrow;
    }
  }

  /// מחיקת איש קשר
  Future<void> deleteContact({
    required String currentUserId,
    required String contactUserId,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ SavedContactsService.deleteContact():');
      debugPrint('   CurrentUser: $currentUserId');
      debugPrint('   Contact: $contactUserId');
    }

    try {
      await _getUserContactsRef(currentUserId).doc(contactUserId).delete();
      if (kDebugMode) {
        debugPrint('   ✅ Contact deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Error deleting contact: $e');
      }
      rethrow;
    }
  }

  /// בדיקה אם איש קשר קיים
  Future<bool> contactExists({
    required String currentUserId,
    required String contactUserId,
  }) async {
    try {
      final doc = await _getUserContactsRef(currentUserId)
          .doc(contactUserId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// חיפוש אנשי קשר לפי שם או אימייל
  Future<List<SavedContact>> searchContacts({
    required String userId,
    required String query,
  }) async {
    if (query.isEmpty) {
      return getContacts(userId);
    }

    final allContacts = await getContacts(userId);
    final lowerQuery = query.toLowerCase();

    return allContacts.where((contact) {
      final nameMatch = contact.userName?.toLowerCase().contains(lowerQuery) ?? false;
      final emailMatch = contact.userEmail.toLowerCase().contains(lowerQuery);
      return nameMatch || emailMatch;
    }).toList();
  }

  /// עדכון זמן הזמנה אחרונה
  Future<void> updateLastInvited({
    required String currentUserId,
    required String contactUserId,
  }) async {
    try {
      await _getUserContactsRef(currentUserId).doc(contactUserId).update({
        'last_invited_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error updating last_invited_at: $e');
      }
    }
  }
}
