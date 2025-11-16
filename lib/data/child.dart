// 📄 File: lib/data/child.dart
// 🎯 Purpose: מודל Child - ייצוג ילד במשפחה
//
// Version: 1.0 - Initial implementation (16/11/2025)

import '../core/constants.dart';

/// מודל ייצוג ילד
///
/// מכיל שם וקטגוריית גיל לשם פרסונליזציה והמלצות מוצרים.
///
/// **דוגמה:**
/// ```dart
/// final child = Child(name: 'נועה', ageCategory: '0-1'); // תינוקת
/// final child2 = Child(name: 'שי', ageCategory: '7-12'); // גיל בית ספר
/// ```
class Child {
  /// שם הילד/ה
  final String name;

  /// קטגוריית גיל (מתוך kValidChildrenAges)
  ///
  /// אפשרויות:
  /// - '0-1': תינוקות
  /// - '2-3': גיל הרך
  /// - '4-6': גן
  /// - '7-12': בית ספר
  /// - '13-18': נוער
  final String ageCategory;

  const Child({
    required this.name,
    required this.ageCategory,
  });

  /// בדיקה אם הגיל תקין
  bool get isValidAge => kValidChildrenAges.contains(ageCategory);

  /// תיאור טקסטואלי של הגיל
  String get ageDescription {
    switch (ageCategory) {
      case '0-1':
        return 'תינוק/ת';
      case '2-3':
        return 'גיל הרך';
      case '4-6':
        return 'גן';
      case '7-12':
        return 'בית ספר';
      case '13-18':
        return 'נוער';
      default:
        return ageCategory;
    }
  }

  /// המרה ל-JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ageCategory': ageCategory,
    };
  }

  /// טעינה מ-JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      name: json['name'] as String? ?? '',
      ageCategory: json['ageCategory'] as String? ?? '0-1',
    );
  }

  /// יצירת עותק מעודכן
  Child copyWith({
    String? name,
    String? ageCategory,
  }) {
    return Child(
      name: name ?? this.name,
      ageCategory: ageCategory ?? this.ageCategory,
    );
  }

  @override
  String toString() => 'Child(name: $name, age: $ageCategory)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Child &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          ageCategory == other.ageCategory;

  @override
  int get hashCode => name.hashCode ^ ageCategory.hashCode;
}
