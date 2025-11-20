// 📄 lib/config/filters_config.dart
//
// 🎯 הגדרות סינון קטגוריות למזווה
// 📦 11 קטגוריות + תרגום לעברית
// 🔗 משמש ב: my_pantry_screen.dart → PantryFilters widget (Dropdown סינון)
//
// 💡 איך לראות בממשק:
//    1. פתח את מסך "המזווה שלי" (My Pantry)
//    2. בראש המסך יש Dropdown עם רשימת קטגוריות
//    3. בחר קטגוריה → מסנן את הפריטים לפי הקטגוריה הנבחרת

/// 11 קטגוריות זמינות לסינון פריטי מזווה
const List<String> kCategories = [
  'all',
  'coffee_tea',
  'dairy',
  'fruits',
  'meat_fish',
  'other',
  'personal_hygiene',
  'rice_pasta',
  'spices_baking',
  'sweets_snacks',
  'vegetables',
];

/// תרגום קטגוריות לעברית (להצגה ב-UI)
const Map<String, String> kCategoryLabels = {
  'all': 'הכל',
  'coffee_tea': 'קפה ותה',
  'dairy': 'מוצרי חלב',
  'fruits': 'פירות',
  'meat_fish': 'בשר ודגים',
  'other': 'אחר',
  'personal_hygiene': 'טיפוח אישי',
  'rice_pasta': 'אורז ופסטה',
  'spices_baking': 'תבלינים ואפייה',
  'sweets_snacks': 'ממתקים וחטיפים',
  'vegetables': 'ירקות',
};

/// מחזיר שם בעברית לקטגוריה | ברירת מחדל: 'לא ידוע'
String getCategoryLabel(String categoryId) {
  return kCategoryLabels[categoryId] ?? 'לא ידוע';
}
