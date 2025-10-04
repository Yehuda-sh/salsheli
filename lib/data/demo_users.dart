// 📄 File: lib/data/demo_users.dart
// תיאור: נתוני דמו של משתמשים (לשימוש בזמן פיתוח/מסכים ראשונים) - מעודכן עם היסטוריה

import '../models/user_entity.dart';

/// JSON התואם ל־UserEntity.fromJson (כולל מפתחות עם @JsonKey)
///
/// עדכון: יוני הוא עכשיו משתמש "עשיר" עם היסטוריה אמיתית:
/// - חנויות מועדפות
/// - מוצרים מועדפים
/// - תקציב שבועי
/// - תאריכי כניסה אחרונים
const List<Map<String, dynamic>> kDemoUsersJson = [
  {
    "id": "yoni_123",
    "name": "יוני כהן",
    "email": "yoni@example.com",
    "household_id": "house_demo",
    "joined_at": "2024-01-15T10:00:00Z",
    "last_login_at": "2025-01-02T08:00:00Z",
    "profileImageUrl": null,
    "preferredStores": ["שופרסל", "רמי לוי", "יינות ביתן"],
    "favoriteProducts": [
      "חלב 3%",
      "פסטה",
      "אורז בסמטי",
      "גבינה צהובה",
      "שמן זית כתית",
      "לחם פרוס",
      "ביצים",
      "טונה",
    ],
    "weeklyBudget": 450.0,
    "isAdmin": true,
  },
  {
    "id": "dana_456",
    "name": "דנה לוי",
    "email": "dana@example.com",
    "household_id": "house_demo",
    "joined_at": "2024-03-10T12:00:00Z",
    "last_login_at": "2025-01-05T19:30:00Z",
    "profileImageUrl": null,
    "preferredStores": ["יינות ביתן", "שופרסל"],
    "favoriteProducts": ["שמן זית כתית", "אורז בסמטי", "גבינה צהובה"],
    "weeklyBudget": 420.0,
    "isAdmin": false,
  },
];

/// המרה נוחה ל־List<UserEntity>
final List<UserEntity> kDemoUsers = kDemoUsersJson
    .map(UserEntity.fromJson)
    .toList();

/// החזרת משתמש דמו ראשון (סימולציה של "מחובר")
/// זהו יוני - משתמש עשיר עם היסטוריה
Future<UserEntity?> getDemoUser() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return kDemoUsers.first;
}

/// שליפת משתמש דמו לפי מזהה (נוח ל־login_screen)
Future<UserEntity?> getDemoUserById(String userId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  try {
    return kDemoUsers.firstWhere((u) => u.id == userId);
  } catch (_) {
    return null;
  }
}
