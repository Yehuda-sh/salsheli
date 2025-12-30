// 📄 File: lib/repositories/utils/firestore_utils.dart
//
// 🎯 Purpose: Firestore utility functions
// - Convert Firestore Timestamps to DateTime
// - Handle null values safely

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  /// Convert Firestore Timestamps to DateTime in a Map
  static Map<String, dynamic> convertTimestamps(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);
    
    converted.forEach((key, value) {
      if (value is Timestamp) {
        converted[key] = value.toDate();
      } else if (value is Map) {
        converted[key] = convertTimestamps(Map<String, dynamic>.from(value));
      } else if (value is List) {
        converted[key] = value.map((item) {
          if (item is Timestamp) {
            // 🔧 תמיכה ברשימת תאריכים: [Timestamp, Timestamp, ...]
            return item.toDate();
          } else if (item is Map) {
            return convertTimestamps(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      }
    });
    
    return converted;
  }
}
