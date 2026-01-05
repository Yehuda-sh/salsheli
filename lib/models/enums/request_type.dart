import 'package:json_annotation/json_annotation.dart';

/// סוגי בקשות שמשתמש יכול לשלוח
@JsonEnum(valueField: 'value')
enum RequestType {
  /// בקשה להוסיף פריט חדש
  addItem('addItem'),

  /// בקשה לערוך פריט קיים
  editItem('editItem'),

  /// בקשה למחוק פריט
  deleteItem('deleteItem'),

  /// הזמנה להצטרף לרשימה/משפחה
  inviteToList('inviteToList');

  const RequestType(this.value);
  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized type names are needed.
}
