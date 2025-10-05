// 📄 File: lib/data/demo_welcome_slides.dart
//
// 🇮🇱 קובץ זה מגדיר את שקופיות ה־Welcome של מסך הפתיחה:
//     - מודל טיפוסי WelcomeSlide (כולל fromMap/toJson).
//     - נתוני דמו גם בגרסה מוקלדת (typed) וגם כ-Map<String,String> לתאימות.
//
// 🇬🇧 This file defines the Welcome slides for the app's intro screen:
//     - Strongly-typed WelcomeSlide model (with fromMap/toJson).
//     - Demo data both typed and as Map<String,String> for compatibility.
//

/// 🇮🇱 מודל שקופית Welcome.
/// 🇬🇧 Welcome slide model.
class WelcomeSlide {
  final String title;
  final String description;
  final String icon;

  /// 🇮🇱 שדות אופציונליים לעיצוב עתידי (כגון צבע דגש או תגית פילוח).
  /// 🇬🇧 Optional fields for future design (e.g. accent color, segmentation tag).
  final String? accentHex; // e.g. "#FBBF24"
  final String? tag; // e.g. "SAVINGS" / "FAMILY"

  const WelcomeSlide({
    required this.title,
    required this.description,
    required this.icon,
    this.accentHex,
    this.tag,
  });

  /// 🇮🇱 המרה ל־Map לתאימות עם מסכים ישנים שעובדים עם `Map<String,String>`.
  /// 🇬🇧 Converts to Map for compatibility with legacy screens using `Map<String,String>`.
  Map<String, String> toMap() => {
    "title": title,
    "description": description,
    "icon": icon,
    if (accentHex != null) "accent": accentHex!,
    if (tag != null) "tag": tag!,
  };

  /// 🇮🇱 המרה מ־Map (ל־typed).
  /// 🇬🇧 Constructs from a Map (for typed usage).
  factory WelcomeSlide.fromMap(Map<String, String> map) => WelcomeSlide(
    title: map["title"] ?? "",
    description: map["description"] ?? "",
    icon: map["icon"] ?? "✨",
    accentHex: map["accent"],
    tag: map["tag"],
  );

  /// 🇮🇱 לוגיקה זהה ל־toMap—שימושית כשמערכת מצפה ל־toJson.
  /// 🇬🇧 Same as toMap—handy if a system expects toJson.
  Map<String, String> toJson() => toMap();
}

/// 🇮🇱 נתוני דמו למסך Welcome.
/// 🇬🇧 Demo slides data for the Welcome screen.
class DemoWelcomeSlides {
  DemoWelcomeSlides._();

  /// 🇮🇱 גרסה מוקלדת (מומלץ לשימוש פנימי).
  /// 🇬🇧 Typed version (recommended for internal use).
  static const List<WelcomeSlide> slidesTyped = [
    WelcomeSlide(
      title: "קניות חכמות בלי לשכוח",
      description: "נהל רשימות מסודרות כדי לא לשכוח מוצרים חשובים.",
      icon: "🛒",
      accentHex: "#F59E0B", // amber-500
      tag: "LISTS",
    ),
    WelcomeSlide(
      title: "ניהול משק בית משפחתי",
      description: "שתף את הרשימות עם בני המשפחה ונהל קניות יחד.",
      icon: "🏠",
      accentHex: "#10B981", // emerald-500
      tag: "FAMILY",
    ),
    WelcomeSlide(
      title: "חיסכון בזמן וכסף",
      description: "AI עוזר לך לקנות חכם יותר ולהימנע מקניות מיותרות.",
      icon: "🤖",
      accentHex: "#3B82F6", // blue-500
      tag: "SAVINGS",
    ),
  ];

  /// 🇮🇱 גרסת `Map<String,String>` עבור תאימות למסכים קיימים.
  /// 🇬🇧 `Map<String,String>` version for backward compatibility with existing screens.
  static const List<Map<String, String>> slides = [
    {
      "title": "קניות חכמות בלי לשכוח",
      "description": "נהל רשימות מסודרות כדי לא לשכוח מוצרים חשובים.",
      "icon": "🛒",
      "accent": "#F59E0B",
      "tag": "LISTS",
    },
    {
      "title": "ניהול משק בית משפחתי",
      "description": "שתף את הרשימות עם בני המשפחה ונהל קניות יחד.",
      "icon": "🏠",
      "accent": "#10B981",
      "tag": "FAMILY",
    },
    {
      "title": "חיסכון בזמן וכסף",
      "description": "AI עוזר לך לקנות חכם יותר ולהימנע מקניות מיותרות.",
      "icon": "🤖",
      "accent": "#3B82F6",
      "tag": "SAVINGS",
    },
  ];

  /// 🇮🇱 אם תרצה לייצר את ה־maps מהמודלים typed:
  /// 🇬🇧 If you prefer to generate maps from typed models:
  /// slidesTyped.map((s) => s.toMap()).toList(growable: false)
}
