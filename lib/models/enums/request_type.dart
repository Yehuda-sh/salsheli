/// סוגי בקשות שמשתמש יכול לשלוח
enum RequestType {
  /// בקשה להוסיף פריט חדש
  addItem,

  /// בקשה לערוך פריט קיים
  editItem,

  /// בקשה למחוק פריט
  deleteItem,

  /// הזמנה להצטרף לרשימה/משפחה
  inviteToList;

  /// שם בעברית
  String get hebrewName {
    switch (this) {
      case RequestType.addItem:
        return 'הוספת פריט';
      case RequestType.editItem:
        return 'עריכת פריט';
      case RequestType.deleteItem:
        return 'מחיקת פריט';
      case RequestType.inviteToList:
        return 'הזמנה לרשימה';
    }
  }

  /// אימוג'י לסוג הבקשה
  String get emoji {
    switch (this) {
      case RequestType.addItem:
        return '➕';
      case RequestType.editItem:
        return '✏️';
      case RequestType.deleteItem:
        return '🗑️';
      case RequestType.inviteToList:
        return '👥';
    }
  }
}
