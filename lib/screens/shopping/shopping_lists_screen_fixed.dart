// פח קובץ תיקונים זמני - יש למחוק אחרי תיקון הקובץ המקורי
// השינויים הנדרשים:

// 1. שורה 43: final במקום int
final int _historyPageSize = 10;

// 2. שורה 87: מרכאות יחידות
tooltip: 'רענן',

// 3-7. שורות 276-343: הסרת const מ-Icon עם color דינמי
// הסר const מפני שה-color תלוי ב-_sortBy (דינמי)

PopupMenuItem(
  value: 'date_desc',
  child: Row(
    children: [
      Icon(  // ללא const!
        Icons.arrow_downward,
        size: kIconSizeSmall,
        color: _sortBy == 'date_desc' ? Theme.of(context).colorScheme.primary : null,
      ),
      // ... שאר הקוד
    ],
  ),
)

// 8-11. שורות 490-563: Context safety
// שמירת messenger + mounted check
final navigator = Navigator.of(context);
final messenger = ScaffoldMessenger.of(context);

if (mounted) {
  Navigator.of(dialogContext, rootNavigator: true).pop();
}

// 12-13. שורות 536, 563: final לוקלי
final filtered = lists.where...

// 14-17. מרכאות יחידות בשורות 790, 856, 860, 930, 935, 942, 965
'אין רשימות קניות'
'לחץ על הכפתור מטה ליצירת'
// וכו'
