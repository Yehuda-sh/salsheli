// 📄 File: lib/services/contact_picker_service.dart
// 🎯 Purpose: שירות לבחירת אנשי קשר מהטלפון
//
// 📋 Features:
// - בקשת הרשאות גישה לאנשי קשר
// - טעינת אנשי קשר עם טלפון/אימייל
// - חיפוש אנשי קשר
// - בחירת אנשי קשר מרובים
//
// ✅ תיקונים:
//    - ContactPickerResult typed result במקום null
//    - Platform check למניעת crash ב-Web/Desktop
//
// 📝 Version: 1.1
// 📅 Created: 14/12/2025

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/enums/user_role.dart';

// ========================================
// 🆕 Typed Result for Contact Picker
// ========================================

/// סוגי תוצאות מבורר אנשי קשר
///
/// מאפשר ל-UI להבחין בין מצבים שונים:
/// ```dart
/// final result = await contactService.getContacts();
/// switch (result.type) {
///   case ContactPickerResultType.success:
///     // הצג את result.contacts
///     break;
///   case ContactPickerResultType.permissionDenied:
///     // הצג הסבר + כפתור להגדרות
///     break;
///   case ContactPickerResultType.platformNotSupported:
///     // הצג הודעה שהפיצ'ר לא נתמך
///     break;
///   // ...
/// }
/// ```
enum ContactPickerResultType {
  /// הצלחה - יש אנשי קשר
  success,

  /// המשתמש דחה הרשאה
  permissionDenied,

  /// המשתמש ביטל את הבחירה
  cancelled,

  /// אין אנשי קשר עם טלפון/אימייל
  empty,

  /// הפלטפורמה לא נתמכת (Web/Desktop)
  platformNotSupported,

  /// שגיאה כללית
  error,
}

/// תוצאת בורר אנשי קשר - Type-Safe!
///
/// כוללת:
/// - [type] - סוג התוצאה (enum)
/// - [contacts] - רשימת אנשי קשר (אם יש)
/// - [contact] - איש קשר בודד (לבחירה בודדת)
/// - [errorMessage] - הודעת שגיאה (לדיבוג)
class ContactPickerResult {
  final ContactPickerResultType type;
  final List<SelectedContact>? contacts;
  final SelectedContact? contact;
  final String? errorMessage;

  const ContactPickerResult._({
    required this.type,
    this.contacts,
    this.contact,
    this.errorMessage,
  });

  /// הצלחה עם רשימת אנשי קשר
  factory ContactPickerResult.success(List<SelectedContact> contacts) {
    return ContactPickerResult._(
      type: contacts.isEmpty
          ? ContactPickerResultType.empty
          : ContactPickerResultType.success,
      contacts: contacts,
    );
  }

  /// הצלחה עם איש קשר בודד
  factory ContactPickerResult.singleContact(SelectedContact contact) {
    return ContactPickerResult._(
      type: ContactPickerResultType.success,
      contact: contact,
    );
  }

  /// המשתמש דחה הרשאה
  factory ContactPickerResult.permissionDenied() {
    return const ContactPickerResult._(
      type: ContactPickerResultType.permissionDenied,
    );
  }

  /// המשתמש ביטל
  factory ContactPickerResult.cancelled() {
    return const ContactPickerResult._(
      type: ContactPickerResultType.cancelled,
    );
  }

  /// פלטפורמה לא נתמכת
  factory ContactPickerResult.platformNotSupported() {
    return const ContactPickerResult._(
      type: ContactPickerResultType.platformNotSupported,
      errorMessage: 'Contact picker is only supported on Android and iOS',
    );
  }

  /// שגיאה
  factory ContactPickerResult.error(String message) {
    return ContactPickerResult._(
      type: ContactPickerResultType.error,
      errorMessage: message,
    );
  }

  /// האם הצליח
  bool get isSuccess => type == ContactPickerResultType.success;

  /// האם יש אנשי קשר
  bool get hasContacts => contacts != null && contacts!.isNotEmpty;

  /// האם יש איש קשר בודד
  bool get hasContact => contact != null;
}

/// מודל פשוט לאיש קשר נבחר
class SelectedContact {
  final String id;
  final String displayName;
  final String? phone;
  final String? email;
  final Uint8List? photo;

  /// תפקיד להזמנה (ברירת מחדל: editor)
  final UserRole role;

  SelectedContact({
    required this.id,
    required this.displayName,
    this.phone,
    this.email,
    this.photo,
    this.role = UserRole.editor,
  });

  /// העתקה עם שינוי תפקיד
  SelectedContact copyWith({UserRole? role}) {
    return SelectedContact(
      id: id,
      displayName: displayName,
      phone: phone,
      email: email,
      photo: photo,
      role: role ?? this.role,
    );
  }

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

  // ========================================
  // 🆕 Platform Check
  // ========================================

  /// האם הפלטפורמה נתמכת (Android/iOS בלבד)
  ///
  /// flutter_contacts לא תומך ב-Web/Desktop
  static bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      // Platform לא זמין (Web)
      return false;
    }
  }

  /// בדיקת הרשאות
  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// בקשת הרשאות
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// טעינת כל אנשי הקשר
  ///
  /// ✅ מחזיר [ContactPickerResult] עם סוג תוצאה ברור
  ///
  /// Example:
  /// ```dart
  /// final result = await contactService.getContacts();
  /// if (result.isSuccess) {
  ///   // השתמש ב-result.contacts
  /// } else if (result.type == ContactPickerResultType.permissionDenied) {
  ///   // הצג הסבר למשתמש
  /// }
  /// ```
  Future<ContactPickerResult> getContactsResult({bool forceRefresh = false}) async {
    // ✅ בדיקת פלטפורמה
    if (!isSupported) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService: Platform not supported');
      }
      return ContactPickerResult.platformNotSupported();
    }

    try {
      // בדיקת הרשאות
      final hasAccess = await requestPermission();
      if (!hasAccess) {
        if (kDebugMode) {
          debugPrint('❌ ContactPickerService: Permission denied');
        }
        return ContactPickerResult.permissionDenied();
      }

      // בדיקת cache
      if (!forceRefresh &&
          _cachedContacts != null &&
          _cacheTime != null &&
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        if (kDebugMode) {
          debugPrint('📦 ContactPickerService: Using cached contacts');
        }
        return ContactPickerResult.success(_convertContacts(_cachedContacts!));
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

      return ContactPickerResult.success(_convertContacts(_cachedContacts!));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService.getContacts failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      return ContactPickerResult.error(e.toString());
    }
  }

  /// @deprecated השתמש ב-getContactsResult() במקום
  ///
  /// טעינת כל אנשי הקשר (Legacy API)
  Future<List<SelectedContact>> getContacts({bool forceRefresh = false}) async {
    final result = await getContactsResult(forceRefresh: forceRefresh);
    return result.contacts ?? [];
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
  ///
  /// ✅ מחזיר [ContactPickerResult] עם סוג תוצאה ברור
  Future<ContactPickerResult> searchContactsResult(String query) async {
    if (query.isEmpty) return getContactsResult();

    final result = await getContactsResult();
    if (!result.isSuccess) return result;

    final lowerQuery = query.toLowerCase();
    final filtered = result.contacts!.where((contact) {
      return contact.displayName.toLowerCase().contains(lowerQuery) ||
          (contact.phone?.contains(query) ?? false) ||
          (contact.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    return ContactPickerResult.success(filtered);
  }

  /// @deprecated השתמש ב-searchContactsResult() במקום
  Future<List<SelectedContact>> searchContacts(String query) async {
    final result = await searchContactsResult(query);
    return result.contacts ?? [];
  }

  /// פתיחת בורר אנשי קשר של המערכת (בחירה בודדת)
  ///
  /// ✅ מחזיר [ContactPickerResult] עם סוג תוצאה ברור
  ///
  /// Example:
  /// ```dart
  /// final result = await contactService.pickContactResult();
  /// switch (result.type) {
  ///   case ContactPickerResultType.success:
  ///     final contact = result.contact!;
  ///     // השתמש באיש הקשר
  ///     break;
  ///   case ContactPickerResultType.cancelled:
  ///     // המשתמש ביטל - חזור בשקט
  ///     break;
  ///   case ContactPickerResultType.permissionDenied:
  ///     // הצג הסבר
  ///     break;
  /// }
  /// ```
  Future<ContactPickerResult> pickContactResult() async {
    // ✅ בדיקת פלטפורמה
    if (!isSupported) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService: Platform not supported');
      }
      return ContactPickerResult.platformNotSupported();
    }

    try {
      final hasAccess = await requestPermission();
      if (!hasAccess) {
        return ContactPickerResult.permissionDenied();
      }

      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) {
        return ContactPickerResult.cancelled();
      }

      // טען פרטים מלאים
      final fullContact = await FlutterContacts.getContact(contact.id);

      if (fullContact == null) {
        return ContactPickerResult.error('Failed to load contact details');
      }

      String? phone;
      if (fullContact.phones.isNotEmpty) {
        phone = fullContact.phones.first.number;
      }

      String? email;
      if (fullContact.emails.isNotEmpty) {
        email = fullContact.emails.first.address;
      }

      return ContactPickerResult.singleContact(SelectedContact(
        id: fullContact.id,
        displayName: fullContact.displayName,
        phone: phone,
        email: email,
        photo: fullContact.photo,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ContactPickerService.pickContact failed: $e');
      }
      return ContactPickerResult.error(e.toString());
    }
  }

  /// @deprecated השתמש ב-pickContactResult() במקום
  Future<SelectedContact?> pickContact() async {
    final result = await pickContactResult();
    return result.contact;
  }

  /// ניקוי cache
  void clearCache() {
    _cachedContacts = null;
    _cacheTime = null;
  }
}
