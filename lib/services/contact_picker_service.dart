// 📄 File: lib/services/contact_picker_service.dart
// 🎯 Purpose: שירות לבחירת אנשי קשר מהטלפון
//
// 📋 Features:
// - בקשת הרשאות גישה לאנשי קשר
// - טעינת אנשי קשר עם טלפון/אימייל
// - חיפוש אנשי קשר
// - בחירת אנשי קשר מרובים
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// מודל פשוט לאיש קשר נבחר
class SelectedContact {
  final String id;
  final String displayName;
  final String? phone;
  final String? email;
  final Uint8List? photo;

  SelectedContact({
    required this.id,
    required this.displayName,
    this.phone,
    this.email,
    this.photo,
  });

  /// האם יש מידע ליצירת קשר
  bool get hasContactInfo => phone != null || email != null;

  /// הטלפון המנורמל (ללא מקפים ורווחים)
  String? get normalizedPhone {
    if (phone == null) return null;
    return phone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  @override
  String toString() => 'SelectedContact($displayName, $phone, $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedContact &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// שירות לניהול אנשי קשר
class ContactPickerService {
  // Singleton
  static final ContactPickerService _instance = ContactPickerService._();
  factory ContactPickerService() => _instance;
  ContactPickerService._();

  // Cache של אנשי קשר
  List<Contact>? _cachedContacts;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// בדיקת הרשאות
  Future<bool> hasPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// בקשת הרשאות
  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// טעינת כל אנשי הקשר
  Future<List<SelectedContact>> getContacts({bool forceRefresh = false}) async {
    try {
      // בדיקת הרשאות
      final hasAccess = await requestPermission();
      if (!hasAccess) {
        if (kDebugMode) {
          debugPrint('❌ ContactPickerService: No permission');
        }
        return [];
      }

      // בדיקת cache
      if (!forceRefresh &&
          _cachedContacts != null &&
          _cacheTime != null &&
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        if (kDebugMode) {
          debugPrint('📦 ContactPickerService: Using cached contacts');
        }
        return _convertContacts(_cachedContacts!);
      }

      // טעינת אנשי קשר
      if (kDebugMode) {
        debugPrint('📱 ContactPickerService: Loading contacts...');
      }

      _cachedContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      _cacheTime = DateTime.now();

      if (kDebugMode) {
        debugPrint(
            '✅ ContactPickerService: Loaded ${_cachedContacts!.length} contacts');
      }

      return _convertContacts(_cachedContacts!);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService.getContacts failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return [];
    }
  }

  /// המרת אנשי קשר למודל פשוט
  List<SelectedContact> _convertContacts(List<Contact> contacts) {
    final result = <SelectedContact>[];

    for (final contact in contacts) {
      // דלג על אנשי קשר ללא שם
      if (contact.displayName.isEmpty) continue;

      // קח את הטלפון הראשון
      String? phone;
      if (contact.phones.isNotEmpty) {
        phone = contact.phones.first.number;
      }

      // קח את האימייל הראשון
      String? email;
      if (contact.emails.isNotEmpty) {
        email = contact.emails.first.address;
      }

      // דלג על אנשי קשר ללא טלפון ואימייל
      if (phone == null && email == null) continue;

      result.add(SelectedContact(
        id: contact.id,
        displayName: contact.displayName,
        phone: phone,
        email: email,
        photo: contact.photo,
      ));
    }

    // מיון אלפביתי
    result.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

    return result;
  }

  /// חיפוש אנשי קשר
  Future<List<SelectedContact>> searchContacts(String query) async {
    if (query.isEmpty) return getContacts();

    final contacts = await getContacts();
    final lowerQuery = query.toLowerCase();

    return contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(lowerQuery) ||
          (contact.phone?.contains(query) ?? false) ||
          (contact.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// פתיחת בורר אנשי קשר של המערכת (בחירה בודדת)
  Future<SelectedContact?> pickContact() async {
    try {
      final hasAccess = await requestPermission();
      if (!hasAccess) return null;

      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) return null;

      // טען פרטים מלאים
      final fullContact = await FlutterContacts.getContact(contact.id);

      if (fullContact == null) return null;

      String? phone;
      if (fullContact.phones.isNotEmpty) {
        phone = fullContact.phones.first.number;
      }

      String? email;
      if (fullContact.emails.isNotEmpty) {
        email = fullContact.emails.first.address;
      }

      return SelectedContact(
        id: fullContact.id,
        displayName: fullContact.displayName,
        phone: phone,
        email: email,
        photo: fullContact.photo,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService.pickContact failed: $e');
      }
      return null;
    }
  }

  /// ניקוי cache
  void clearCache() {
    _cachedContacts = null;
    _cacheTime = null;
  }
}
