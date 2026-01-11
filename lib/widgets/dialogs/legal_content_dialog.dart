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
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
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
                    child: const Text('הבנתי'),
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
// תוכן משפטי (placeholder - יש להחליף בתוכן אמיתי)
// ============================================================

const String _termsOfServiceContent = '''
תנאי שימוש - MemoZap

עודכן לאחרונה: ינואר 2026

1. קבלת התנאים
בשימוש באפליקציה זו, אתה מסכים לתנאי שימוש אלה.

2. תיאור השירות
MemoZap היא אפליקציה לניהול רשימות קניות משפחתיות.

3. חשבון משתמש
- אתה אחראי לשמירה על סודיות פרטי הכניסה שלך
- אתה אחראי לכל הפעילות בחשבונך

4. שימוש מותר
- השימוש באפליקציה הוא אישי ולא מסחרי
- אסור להשתמש באפליקציה לפעילות בלתי חוקית

5. קניין רוחני
כל הזכויות באפליקציה שמורות.

6. הגבלת אחריות
האפליקציה מסופקת "כמות שהיא" ללא אחריות מכל סוג.

7. שינויים בתנאים
אנו שומרים את הזכות לעדכן תנאים אלה בכל עת.

8. יצירת קשר
לשאלות ניתן לפנות אלינו דרך האפליקציה.
''';

const String _privacyPolicyContent = '''
מדיניות פרטיות - MemoZap

עודכן לאחרונה: ינואר 2026

1. מידע שאנו אוספים
- פרטי חשבון: שם, אימייל, מספר טלפון
- נתוני שימוש: רשימות קניות, מזווה, קבוצות
- מידע טכני: גרסת האפליקציה, סוג המכשיר

2. שימוש במידע
המידע משמש ל:
- הפעלת השירות
- שיפור חוויית המשתמש
- שליחת התראות רלוונטיות

3. שיתוף מידע
- לא נמכור את המידע שלך
- נשתף מידע רק עם שותפים הכרחיים להפעלת השירות
- נשתף מידע אם נדרש על פי חוק

4. אבטחת מידע
אנו משתמשים באמצעי אבטחה מתקדמים להגנה על המידע שלך.

5. זכויותיך
על פי חוק הגנת הפרטיות, יש לך זכות ל:
- גישה למידע שלך
- תיקון מידע שגוי
- מחיקת המידע שלך
- ייצוא המידע שלך

6. מחיקת חשבון
ניתן למחוק את החשבון בכל עת דרך ההגדרות.
המחיקה היא לצמיתות ובלתי הפיכה.

7. Cookies
האפליקציה לא משתמשת ב-cookies.

8. שינויים במדיניות
נעדכן אותך על שינויים מהותיים במדיניות.

9. יצירת קשר
לשאלות בנושא פרטיות, ניתן לפנות אלינו דרך האפליקציה.
''';
