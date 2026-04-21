// lib/models/selected_contact.dart — Selected contact — transient model for contact picker (name, email, phone)

import 'package:flutter/foundation.dart' show immutable;

import 'enums/user_role.dart';
import 'saved_contact.dart';

/// איש קשר שנבחר לשיתוף רשימה חדשה
///
/// משמש במסך יצירת רשימה כאשר בוחרים "שיתוף ספציפי".
/// כולל תפקיד (role) ומידע אם המשתמש רשום או לא.
@immutable
class SelectedContact {
  /// מזהה המשתמש (null אם לא רשום באפליקציה)
  final String? userId;

  /// אימייל המשתמש
  final String email;

  /// טלפון המשתמש (אם ידוע)
  final String? phone;

  /// שם המשתמש (אם ידוע)
  final String? name;

  /// אווטאר המשתמש (אם ידוע)
  final String? avatar;

  /// התפקיד שניתן למשתמש
  final UserRole role;

  /// האם המשתמש לא רשום ודורש הזמנה ממתינה
  final bool isPending;

  const SelectedContact({
    this.userId,
    required this.email,
    this.phone,
    this.name,
    this.avatar,
    required this.role,
    this.isPending = false,
  }) : assert(
          userId != null || email.length > 0 || (phone != null && phone!.length > 0),
          'SelectedContact must have userId, email, or phone',
        );

  // ---- Normalization Helpers ----

  /// 🔧 נרמול אימייל: trim + lowercase
  /// 🇬🇧 Normalize email: trim + lowercase
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  /// 🔧 נרמול טלפון: רק ספרות (ו-+ בהתחלה אם יש)
  /// 🇬🇧 Normalize phone: digits only (keeps leading +)
  static String normalizePhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';

    final hasPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    return hasPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// 🔧 מפתח זהות אחיד: userId > email מנורמל > phone מנורמל
  /// 🇬🇧 Unified identity key: userId > normalized email > normalized phone
  ///
  /// משמש ל-== ו-hashCode למניעת כפילויות
  String get identityKey {
    if (userId != null && userId!.isNotEmpty) return 'uid:$userId';
    if (email.isNotEmpty) return 'email:${normalizeEmail(email)}';
    if (phone != null && phone!.isNotEmpty) return 'phone:${normalizePhone(phone!)}';
    // 🔧 לא אמור להגיע לפה בגלל ה-assert בקונסטרקטור
    assert(false, 'SelectedContact must have userId, email, or phone');
    return 'unknown';
  }

  /// 🔧 מחלץ תו ראשון בצורה בטוחה (תומך באמוג׳י)
  static String _firstChar(String s) {
    if (s.isEmpty) return '';
    return String.fromCharCode(s.runes.first);
  }

  /// יצירה מ-SavedContact קיים
  factory SelectedContact.fromSavedContact(
    SavedContact contact, {
    required UserRole role,
  }) {
    return SelectedContact(
      userId: contact.userId,
      email: contact.userEmail,
      phone: contact.userPhone,
      name: contact.userName,
      avatar: contact.userAvatar,
      role: role,
    );
  }

  /// יצירה מאימייל חדש (משתמש לא רשום)
  factory SelectedContact.fromEmail(
    String email, {
    required UserRole role,
  }) {
    return SelectedContact(
      email: email,
      role: role,
      isPending: true,
    );
  }

  /// יצירה מטלפון חדש (משתמש לא רשום)
  factory SelectedContact.fromPhone(
    String phone, {
    required UserRole role,
  }) {
    return SelectedContact(
      email: '', // אין אימייל - רק טלפון
      phone: phone,
      role: role,
      isPending: true,
    );
  }

  /// יצירה מפרטי משתמש רשום
  factory SelectedContact.fromRegisteredUser({
    required String userId,
    required String email,
    String? phone,
    String? name,
    String? avatar,
    required UserRole role,
  }) {
    return SelectedContact(
      userId: userId,
      email: email,
      phone: phone,
      name: name,
      avatar: avatar,
      role: role,
    );
  }

  /// שם לתצוגה - שם, אימייל או טלפון
  String get displayName => name ?? (email.isNotEmpty ? email : phone ?? '?');

  /// ראשי תיבות לאווטאר
  ///
  /// 🔧 תומך בשמות עבריים, מקפים, רווחים כפולים ואמוג׳י
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final cleaned = name!.trim().replaceAll(RegExp(r'\s+'), ' ');
      final parts =
          cleaned.split(RegExp(r'[\s\-]+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${_firstChar(parts[0])}${_firstChar(parts[1])}'.toUpperCase();
      }
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return _firstChar(parts[0]).toUpperCase();
      }
    }
    if (email.isNotEmpty) {
      return _firstChar(email).toUpperCase();
    }
    if (phone != null && phone!.isNotEmpty) {
      // 🔧 2 ספרות אחרונות - יותר "טביעת אצבע" מספרה אחת
      final normalized = normalizePhone(phone!);
      if (normalized.length >= 2) {
        return normalized.substring(normalized.length - 2);
      }
      if (normalized.isNotEmpty) {
        return normalized; // ספרה בודדת
      }
      // normalized ריק (למשל phone היה רק "+") - ניפול ל-'?'
    }
    return '?';
  }

  /// העתקה עם שינויים
  SelectedContact copyWith({
    String? userId,
    String? email,
    String? phone,
    String? name,
    String? avatar,
    UserRole? role,
    bool? isPending,
  }) {
    return SelectedContact(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectedContact) return false;
    // 🔧 השוואה לפי identityKey (userId > email מנורמל > phone מנורמל)
    return identityKey == other.identityKey;
  }

  @override
  int get hashCode => identityKey.hashCode;

  @override
  String toString() {
    return 'SelectedContact(email: $email, phone: $phone, name: $name, role: ${role.name}, isPending: $isPending)';
  }
}
