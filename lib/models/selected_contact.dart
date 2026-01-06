// 📄 File: lib/models/selected_contact.dart
//
// 🎯 Purpose: מודל לאיש קשר שנבחר לשיתוף רשימה
//
// 📋 Features:
// - תפקיד לכל איש קשר (Admin/Editor/Viewer)
// - תמיכה במשתמשים רשומים ולא רשומים (pending)
// - שימושי למסך יצירת רשימה עם שיתוף ספציפי
//
// 🔗 Related:
// - saved_contact.dart - איש קשר שמור
// - shared_user.dart - משתמש משותף ברשימה
// - create_list_screen.dart - מסך יצירת רשימה
//
// Version: 1.0
// Created: 06/01/2026

import 'enums/user_role.dart';
import 'saved_contact.dart';

/// איש קשר שנבחר לשיתוף רשימה חדשה
///
/// משמש במסך יצירת רשימה כאשר בוחרים "שיתוף ספציפי".
/// כולל תפקיד (role) ומידע אם המשתמש רשום או לא.
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
  });

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
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final cleaned = name!.trim().replaceAll(RegExp(r'\s+'), ' ');
      final parts =
          cleaned.split(RegExp(r'[\s\-]+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    if (phone != null && phone!.isNotEmpty) {
      return phone![phone!.length - 1]; // ספרה אחרונה
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
    // השווה לפי אימייל או טלפון
    if (email.isNotEmpty && other.email.isNotEmpty) {
      return other.email == email;
    }
    if (phone != null && other.phone != null) {
      return other.phone == phone;
    }
    return other.email == email && other.phone == phone;
  }

  @override
  int get hashCode => email.isNotEmpty ? email.hashCode : (phone?.hashCode ?? 0);

  @override
  String toString() {
    return 'SelectedContact(email: $email, phone: $phone, name: $name, role: ${role.name}, isPending: $isPending)';
  }
}
