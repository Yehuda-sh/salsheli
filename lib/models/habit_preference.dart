// 📄 File: lib/models/habit_preference.dart
//
// 🇮🇱 **מודל הרגל קנייה** - Shopping Habit Preference Model
//
// **מטרה:**
// - ייצוג העדפת קנייה חוזרת (מוצר מועדף + תדירות)
// - תמיכה ב-Firestore serialization
// - חישוב תחזית לקנייה הבאה
//
// **שדות:**
// - id: מזהה ייחודי (Firestore document ID)
// - preferredProduct: שם המוצר המועדף (ברקוד/שם מותג)
// - genericName: שם גנרי (לחם, חלב, וכו')
// - frequencyDays: תדירות קנייה בימים (7 = שבועי)
// - lastPurchased: תאריך הקנייה האחרונה
// - createdDate: תאריך יצירת ההרגל
// - updatedDate: תאריך עדכון אחרון
//
// **Firestore Collection:** `habit_preferences`
// **Document ID:** אוטומטי (Firestore auto-generated)
//
// **Version:** 1.0

import 'package:json_annotation/json_annotation.dart';
import 'timestamp_converter.dart';

part 'habit_preference.g.dart';

@JsonSerializable(explicitToJson: true)
class HabitPreference {
  /// מזהה ייחודי (Firestore document ID)
  final String id;

  /// שם המוצר המועדף (ברקוד/מותג ספציפי)
  @JsonKey(name: 'preferred_product')
  final String preferredProduct;

  /// שם גנרי (קטגוריה: "חלב", "לחם", וכו')
  @JsonKey(name: 'generic_name')
  final String genericName;

  /// תדירות קנייה בימים (7 = שבועי, 14 = דו-שבועי)
  @JsonKey(name: 'frequency_days')
  final int frequencyDays;

  /// תאריך הקנייה האחרונה
  @TimestampConverter()
  @JsonKey(name: 'last_purchased')
  final DateTime lastPurchased;

  /// תאריך יצירת ההרגל
  @TimestampConverter()
  @JsonKey(name: 'created_date')
  final DateTime createdDate;

  /// תאריך עדכון אחרון
  @TimestampConverter()
  @JsonKey(name: 'updated_date')
  final DateTime updatedDate;

  const HabitPreference({
    required this.id,
    required this.preferredProduct,
    required this.genericName,
    required this.frequencyDays,
    required this.lastPurchased,
    required this.createdDate,
    required this.updatedDate,
  });

  /// 🧠 חישוב תחזית לקנייה הבאה
  DateTime get predictedNextPurchase {
    return lastPurchased.add(Duration(days: frequencyDays));
  }

  /// 📅 כמה ימים נשארו עד הקנייה הצפויה הבאה
  /// ערך שלילי = כבר עבר המועד
  int get daysUntilNextPurchase {
    return predictedNextPurchase.difference(DateTime.now()).inDays;
  }

  /// 🚨 האם הגיע הזמן לקנות? (נשארו פחות מיום אחד)
  bool get isDueForPurchase {
    return daysUntilNextPurchase <= 1;
  }

  /// 📝 copyWith למצב חדש
  HabitPreference copyWith({
    String? id,
    String? preferredProduct,
    String? genericName,
    int? frequencyDays,
    DateTime? lastPurchased,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return HabitPreference(
      id: id ?? this.id,
      preferredProduct: preferredProduct ?? this.preferredProduct,
      genericName: genericName ?? this.genericName,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      lastPurchased: lastPurchased ?? this.lastPurchased,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  /// 🔄 JSON Serialization
  factory HabitPreference.fromJson(Map<String, dynamic> json) =>
      _$HabitPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$HabitPreferenceToJson(this);

  @override
  String toString() =>
      'HabitPreference(id: $id, product: $preferredProduct, freq: ${frequencyDays}d)';
}
