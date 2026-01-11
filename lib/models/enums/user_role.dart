import 'package:json_annotation/json_annotation.dart';

/// 4 רמות הרשאות למשתמשים משותפים
@JsonEnum(valueField: 'value')
enum UserRole {
  /// בעלים - מלוא ההרשאות
  owner('owner'),

  /// מנהל - יכול הכל מלבד מחיקת רשימה ושינוי הרשאות
  admin('admin'),

  /// עורך - יכול לבקש הוספה/עריכה/מחיקה (עם אישור)
  editor('editor'),

  /// צופה - רק קריאה
  viewer('viewer');

  const UserRole(this.value);
  final String value;

  /// שם בעברית
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
    }
  }

  /// אימוג'י לתפקיד
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
    }
  }

  // === הרשאות לפי תפקיד ===

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
  bool get canRead => true; // כולם יכולים לקרוא

  /// 🆕 יכול להשתתף בקנייה פעילה (לסמן פריטים)
  /// צופה לא יכול - רק לראות!
  bool get canShop => this != UserRole.viewer;

  /// 🆕 יכול להתחיל קנייה חדשה
  /// רק בעלים ומנהלים
  bool get canStartShopping => this == UserRole.owner || this == UserRole.admin;

  /// 🆕 יכול לסיים קנייה (רק מי שהתחיל)
  /// רק בעלים ומנהלים - בפועל נבדק גם אם הוא ה-starter
  bool get canFinishShopping => this == UserRole.owner || this == UserRole.admin;
}
