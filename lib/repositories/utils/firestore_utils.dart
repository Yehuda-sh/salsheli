// 📄 File: lib/repositories/utils/firestore_utils.dart
//
// 🎯 Purpose: Firestore utility functions
// - Convert Firestore Timestamps to DateTime
// - Handle null values safely

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  /// Convert Firestore Timestamps to DateTime in a Map (fully recursive)
  static Map<String, dynamic> convertTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _convertValue(value)));
  }

  /// 🔄 המרת ערך בודד - רקורסיבית לכל עומק
  static dynamic _convertValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is Map) {
      return value.cast<String, dynamic>()
          .map((key, v) => MapEntry(key, _convertValue(v)));
    }
    if (value is List) {
      return value.map(_convertValue).toList();
    }
    return value;
  }
}

/// Extension נוח להמרת Firestore data ישירות על Map
extension FirestoreMapExtension on Map<String, dynamic> {
  /// ממיר Timestamps ל-DateTime בכל עומק
  ///
  /// ```dart
  /// final data = doc.data()!.toDartTypes();
  /// ```
  Map<String, dynamic> toDartTypes() => FirestoreUtils.convertTimestamps(this);
}

/// Extension על DocumentSnapshot - המרה ישירה ללא .data() ידני
extension FirestoreDocExtension on DocumentSnapshot<Map<String, dynamic>> {
  /// מחזיר data ממומר (Timestamps → DateTime) או null אם אין data
  ///
  /// ```dart
  /// final map = doc.toDartMap()!;
  /// final item = InventoryItem.fromJson(map);
  /// ```
  Map<String, dynamic>? toDartMap() => data()?.toDartTypes();
}

/// Extension על QuerySnapshot - המרת כל ה-documents בבת אחת
extension FirestoreQueryExtension on QuerySnapshot<Map<String, dynamic>> {
  /// ממיר את כל ה-documents לרשימת Map עם DateTime במקום Timestamp
  ///
  /// ```dart
  /// final items = snapshot.toDartList().map(Item.fromJson).toList();
  /// ```
  List<Map<String, dynamic>> toDartList() =>
      docs.map((doc) => doc.data().toDartTypes()).toList();
}
