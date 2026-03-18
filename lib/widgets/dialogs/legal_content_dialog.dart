// 📄 lib/widgets/dialogs/legal_content_dialog.dart
//
// דיאלוג להצגת תוכן משפטי (תנאי שימוש / מדיניות פרטיות)
//
// 🆕 נוצר: ינואר 2026
// 🔗 Related: welcome_screen.dart, settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';

/// סוג התוכן המשפטי
enum LegalContentType {
  termsOfService,
  privacyPolicy,
}

/// מציג דיאלוג תנאי שימוש
Future<void> showTermsOfServiceDialog(BuildContext context) {
  return showLegalContentDialog(
    context: context,
    type: LegalContentType.termsOfService,
  );
}

/// מציג דיאלוג מדיניות פרטיות
Future<void> showPrivacyPolicyDialog(BuildContext context) {
  return showLegalContentDialog(
    context: context,
    type: LegalContentType.privacyPolicy,
  );
}

/// מציג דיאלוג תוכן משפטי
Future<void> showLegalContentDialog({
  required BuildContext context,
  required LegalContentType type,
}) {
  return showDialog(
    context: context,
    builder: (context) => _LegalContentDialog(type: type),
  );
}

class _LegalContentDialog extends StatelessWidget {
  final LegalContentType type;

  const _LegalContentDialog({required this.type});

  String get _title {
    switch (type) {
      case LegalContentType.termsOfService:
        return AppStrings.welcome.termsOfService;
      case LegalContentType.privacyPolicy:
        return AppStrings.welcome.privacyPolicy;
    }
  }

  String get _content {
    switch (type) {
      case LegalContentType.termsOfService:
        return _termsOfServiceContent;
      case LegalContentType.privacyPolicy:
        return _privacyPolicyContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === כותרת ===
              Container(
                padding: const EdgeInsets.all(kSpacingMedium),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kBorderRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      type == LegalContentType.termsOfService
                          ? Icons.description_outlined
                          : Icons.privacy_tip_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        _title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: scheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),

              // === תוכן ===
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Text(
                    _content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // === כפתור סגירה ===
              Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppStrings.common.understood),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// תוכן משפטי
// TODO(i18n): להעביר ל-AppStrings כשמוסיפים תרגום לאנגלית
// ============================================================

const String _termsOfServiceContent = '''
תנאי שימוש — MemoZap

תאריך עדכון אחרון: מרץ 2026

ברוכים הבאים ל-MemoZap! השימוש באפליקציה מותנה בהסכמתך לתנאים המפורטים להלן. אנא קרא/י אותם בעיון.

1. הגדרות
"האפליקציה" — אפליקציית MemoZap לניהול רשימות קניות ומזווה ביתי.
"המשתמש/ת" — כל מי שמתקין/ה או משתמש/ת באפליקציה.
"תוכן משתמש" — רשימות קניות, פריטי מזווה, קבלות, ומידע אחר שהמשתמש/ת מזין/ה.

2. תיאור השירות
MemoZap מאפשרת ניהול רשימות קניות משותפות, מעקב אחר מלאי מזווה ביתי, שיתוף רשימות בין חברי הבית, שמירת היסטוריית קניות, וקבלת הצעות חכמות לקניות על בסיס צריכה.

3. חשבון משתמש
• יצירת חשבון מחייבת מסירת שם, כתובת אימייל תקינה ומספר טלפון.
• המשתמש/ת אחראי/ת לשמירת סודיות פרטי ההתחברות.
• יש לדווח מיידית על כל שימוש לא מורשה בחשבון.
• ניתן למחוק את החשבון בכל עת דרך מסך ההגדרות.

4. שימוש מותר ואסור
מותר: שימוש אישי וביתי לניהול קניות ומזווה.
אסור: שימוש מסחרי, העתקה או הפצה של האפליקציה, ניסיון לפרוץ או לשבש את השירות, העלאת תוכן פוגעני או בלתי חוקי.

5. תוכן משתמש
• התוכן שלך שייך לך. אנו לא תובעים בעלות על תוכן משתמש.
• אנו שומרים את התוכן שלך בשרתי Firebase מאובטחים.
• בעת מחיקת חשבון, כל התוכן נמחק לצמיתות.

6. קניין רוחני
כל הזכויות באפליקציה, בעיצוב, בקוד ובתוכן שאינו תוכן משתמש שמורות למפתחי MemoZap.

7. הגבלת אחריות
האפליקציה מסופקת "כמות שהיא" (AS IS). איננו אחראים לנזקים ישירים או עקיפים הנובעים מהשימוש באפליקציה, לאובדן נתונים כתוצאה מתקלות טכניות, או לדיוק המחירים או המידע המוצג.

8. זמינות השירות
אנו שואפים לזמינות מלאה אך לא מתחייבים לכך. ייתכנו הפסקות לתחזוקה או שדרוגים.

9. שינויים בתנאים
אנו רשאים לעדכן תנאים אלה מעת לעת. שינויים מהותיים יפורסמו באפליקציה. המשך השימוש לאחר שינוי מהווה הסכמה לתנאים המעודכנים.

10. דין חל וסמכות שיפוט
על תנאים אלה יחול הדין הישראלי. סמכות השיפוט הבלעדית נתונה לבתי המשפט בירושלים.

11. יצירת קשר
לשאלות או בירורים: memozap.app@gmail.com
''';

const String _privacyPolicyContent = '''
מדיניות פרטיות — MemoZap

תאריך עדכון אחרון: מרץ 2026

פרטיותך חשובה לנו. מדיניות זו מסבירה אילו נתונים אנו אוספים, כיצד אנו משתמשים בהם, וכיצד אנו מגינים עליהם.

1. מידע שאנו אוספים

א. מידע שאת/ה מוסר/ת:
• פרטי חשבון — שם, כתובת אימייל, מספר טלפון
• תוכן משתמש — רשימות קניות, פריטי מזווה, קבלות
• הגדרות — העדפות התראות, ערכת נושא, שם קבוצה

ב. מידע שנאסף אוטומטית:
• מזהה מכשיר ומערכת הפעלה (לצורך Crashlytics)
• נתוני שימוש אנונימיים (Analytics) — מסכים שנצפו, פעולות שבוצעו
• מידע על קריסות ושגיאות (Crashlytics)

ג. מידע שאיננו אוספים:
• מיקום גיאוגרפי
• אנשי קשר מהמכשיר
• תמונות או קבצים מהמכשיר
• מידע פיננסי או אמצעי תשלום

2. כיצד אנו משתמשים במידע
• הפעלת השירות — סנכרון רשימות, מזווה והתראות
• שיפור האפליקציה — ניתוח דפוסי שימוש אנונימיים
• תמיכה טכנית — אבחון ותיקון באגים
• תקשורת — הודעות מערכת חיוניות בלבד

3. שיתוף מידע
• לא נמכור ולא נשכיר את המידע שלך לצדדים שלישיים.
• מידע משותף עם חברי הבית — רק תוכן שבחרת לשתף (רשימות, מזווה).
• ספקי שירות — Firebase (Google) לאחסון ואימות. ראה מדיניות הפרטיות של Google.
• דרישה חוקית — נשתף מידע אם נדרש על פי צו בית משפט או חוק.

4. אחסון ואבטחה
• הנתונים מאוחסנים בשרתי Firebase (Google Cloud) באירופה.
• תעבורת נתונים מוצפנת ב-TLS/SSL.
• גישה למסד הנתונים מוגנת בכללי אבטחה (Firestore Security Rules).
• סיסמאות מוצפנות באמצעות Firebase Authentication — איננו מאחסנים סיסמאות בטקסט גלוי.

5. שמירת מידע
• נתוני החשבון נשמרים כל עוד החשבון פעיל.
• בעת מחיקת חשבון — כל הנתונים נמחקים תוך 30 יום.
• נתוני Analytics אנונימיים נשמרים עד 14 חודשים.

6. זכויותיך (בהתאם לחוק הגנת הפרטיות, התשמ"א-1981)
• זכות עיון — לצפות במידע שנאסף עליך
• זכות תיקון — לתקן מידע שגוי
• זכות מחיקה — למחוק את חשבונך וכל המידע הנלווה
• זכות ניוד — לייצא את הנתונים שלך (פנה/י אלינו)
• זכות התנגדות — להפסיק שימוש ב-Analytics (פנה/י אלינו)

למימוש זכויותיך, פנה/י אלינו בכתובת: memozap.app@gmail.com

7. גיל מינימלי
האפליקציה מיועדת לגילאי 13 ומעלה. איננו אוספים ביודעין מידע על ילדים מתחת לגיל 13.

8. שינויים במדיניות
שינויים מהותיים יפורסמו באפליקציה לפחות 7 ימים לפני כניסתם לתוקף.

9. יצירת קשר
לשאלות בנושא פרטיות: memozap.app@gmail.com
''';
