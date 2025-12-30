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

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized type names are needed.
}
