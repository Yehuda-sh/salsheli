// 📄 File: lib/models/enums/user_role.dart
//
// 🇮🇱 תפקידי משתמשים ברשימות משותפות:
//     - owner: בעלים - מלוא ההרשאות (מחיקת רשימה, ניהול משתמשים)
//     - admin: מנהל - הכל מלבד מחיקת רשימה ושינוי הרשאות
//     - editor: עורך - יכול לבקש הוספה/עריכה/מחיקה (עם אישור)
//     - viewer: צופה - רק קריאה
//     - unknown: fallback לערכים לא מוכרים מהשרת
//
// 🇬🇧 User roles in shared lists:
//     - owner: Full permissions (delete list, manage users)
//     - admin: All except delete list and manage permissions
//     - editor: Can request add/edit/delete (requires approval)
//     - viewer: Read-only access
//     - unknown: fallback for unknown server values
//
// 🔗 Related:
//     - SharedUser (models/shared_user.dart)
//     - ShoppingList (models/shopping_list.dart)
//     - ShareListDialog (screens/sharing/share_list_dialog.dart)
//

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 תפקידי משתמשים ברשימות משותפות
/// 🇬🇧 User roles in shared lists
@JsonEnum(valueField: 'value')
enum UserRole {
  /// 👑 בעלים - מלוא ההרשאות
  owner('owner'),

  /// 🔧 מנהל - יכול הכל מלבד מחיקת רשימה ושינוי הרשאות
  admin('admin'),

  /// ✏️ עורך - יכול לבקש הוספה/עריכה/מחיקה (עם אישור)
  editor('editor'),

  /// 👀 צופה - רק קריאה
  viewer('viewer'),

  /// ❓ תפקיד לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown role value
  unknown('unknown');

  const UserRole(this.value);
  final String value;

  /// האם זה תפקיד תקין (לא unknown)
  bool get isKnown => this != UserRole.unknown;

  /// 🔒 האם זה תפקיד לקריאה בלבד (viewer או unknown)
  /// 🇬🇧 Is this a read-only role (viewer or unknown)
  ///
  /// שימושי לבדיקות UI כדי לא לשכוח את unknown
  bool get isReadOnly => this == UserRole.viewer || this == UserRole.unknown;

  /// שם בעברית
  /// ⚠️ Note: Consider using AppStrings in UI layer for localization
  String get hebrewName {
    switch (this) {
      case UserRole.owner:
        return 'בעלים';
      case UserRole.admin:
        return 'מנהל';
      case UserRole.editor:
        return 'עורך';
      case UserRole.viewer:
        return 'צופה';
      case UserRole.unknown:
        return 'לא ידוע';
    }
  }

  /// אימוג'י לתפקיד
  /// ⚠️ Note: Consider using AppStrings in UI layer for localization
  String get emoji {
    switch (this) {
      case UserRole.owner:
        return '👑';
      case UserRole.admin:
        return '🔧';
      case UserRole.editor:
        return '✏️';
      case UserRole.viewer:
        return '👀';
      case UserRole.unknown:
        return '❓';
    }
  }

  // === הרשאות לפי תפקיד ===
  // ⚠️ unknown מקבל הרשאות מינימליות (כמו viewer) מטעמי אבטחה

  /// יכול להוסיף פריטים ישירות (ללא אישור)
  bool get canAddDirectly => this == UserRole.owner || this == UserRole.admin;

  /// יכול לערוך פריטים ישירות (ללא אישור)
  bool get canEditDirectly => this == UserRole.owner || this == UserRole.admin;

  /// יכול למחוק פריטים ישירות (ללא אישור)
  bool get canDeleteDirectly => this == UserRole.owner || this == UserRole.admin;

  /// יכול לאשר/לדחות בקשות
  bool get canApproveRequests => this == UserRole.owner || this == UserRole.admin;

  /// יכול לנהל משתמשים (הוספה/הסרה/שינוי תפקיד)
  bool get canManageUsers => this == UserRole.owner;

  /// יכול למחוק את הרשימה
  bool get canDeleteList => this == UserRole.owner;

  /// יכול לשלוח בקשות (Editor בלבד)
  bool get canRequest => this == UserRole.editor;

  /// יש גישה לקריאה
  bool get canRead => true; // כולם יכולים לקרוא (כולל unknown)

  /// 🆕 יכול להשתתף בקנייה פעילה (לסמן פריטים)
  /// ✅ Allowlist pattern - בטוח יותר מ-denylist אם יתווסף role חדש
  bool get canShop =>
      this == UserRole.owner ||
      this == UserRole.admin ||
      this == UserRole.editor;

  /// 🆕 יכול להתחיל קנייה חדשה
  /// רק בעלים ומנהלים
  bool get canStartShopping => this == UserRole.owner || this == UserRole.admin;

  /// 🆕 יכול לסיים קנייה (רק מי שהתחיל)
  /// רק בעלים ומנהלים - בפועל נבדק גם אם הוא ה-starter
  bool get canFinishShopping => this == UserRole.owner || this == UserRole.admin;
}
