# 🔧 תיקוני UserEntity - 16/10/2025

## בעיות שתוקנו:

### 1. ✅ תמיכה בניקוי שדות Nullable ב-copyWith
**הבעיה:** לא היה אפשר לנקות שדות nullable (להפוך אותם ל-null) דרך copyWith
**הפתרון:** הוספת flags מיוחדים:
- `clearProfileImageUrl` - לניקוי תמונת פרופיל
- `clearLastLoginAt` - לניקוי זמן התחברות אחרון

**דוגמת שימוש:**
```dart
// ניקוי שדות
final cleared = user.copyWith(
  clearProfileImageUrl: true,
  clearLastLoginAt: true,
);

// הגדרת ערכים חדשים
final updated = user.copyWith(
  profileImageUrl: 'https://example.com/new.jpg',
  lastLoginAt: DateTime.now(),
);
```

### 2. ✅ תיקון שמות שדות ל-snake_case ב-JSON
**הבעיה:** חלק מהשדות לא היו ב-snake_case בפורמט JSON
**הפתרון:** הוספת @JsonKey annotations:
- `profileImageUrl` → `profile_image_url`
- `preferredStores` → `preferred_stores`
- `favoriteProducts` → `favorite_products`
- `weeklyBudget` → `weekly_budget`
- `isAdmin` → `is_admin`

## 📋 צעדים להרצה:

1. **יצירת קוד נגזר מחדש:**
   ```powershell
   # PowerShell
   .\regenerate_models.ps1
   
   # או CMD
   regenerate_models.bat
   ```

2. **הרצת בדיקות:**
   ```bash
   flutter test test/models/user_entity_test.dart
   ```

## ✅ בדיקות שאמורות לעבור:
- ✅ UserEntity copyWith can set and clear nullable fields
- ✅ UserEntity JSON Serialization JSON structure uses snake_case

## 🎯 לפי ה-Best Practices:
- ✅ **withValues** - אין withOpacity בקובץ זה
- ✅ **const constructors** - יש const constructor
- ✅ **immutable** - המחלקה מסומנת כ-@immutable
- ✅ **JSON snake_case** - כל השדות עכשיו ב-snake_case
- ✅ **copyWith pattern** - תומך גם בניקוי וגם בעדכון

---
Made with ❤️ by AI Assistant | 16/10/2025
