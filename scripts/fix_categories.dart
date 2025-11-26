// 📄 File: scripts/fix_categories.dart
//
// 🎯 Purpose: Fix product categories in supermarket.json
//
// Usage:
//   dart run scripts/fix_categories.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 מתחיל תיקון קטגוריות...\n');

  // Read the file
  final file = File('assets/data/list_types/supermarket.json');
  if (!file.existsSync()) {
    print('❌ קובץ לא נמצא: ${file.path}');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final List<dynamic> products = jsonDecode(jsonString);

  print('📦 נמצאו ${products.length} מוצרים\n');

  int fixedCount = 0;
  Map<String, int> categoryChanges = {};

  for (var product in products) {
    final name = (product['name'] as String).toLowerCase();
    final currentCategory = product['category'] as String;
    String? newCategory;
    String? newIcon;

    // === חוקי תיקון קטגוריות ===

    // 🔧 תיקון שגיאות ספציפיות קודם (לפני החוקים הכלליים)

    // ⚠️ מרלבורו/סיגריות - אחר (לא בשר!) - חייב להיות ראשון!
    if (name.contains('מרלבורו')) {
      newCategory = 'אחר';
      newIcon = '🚬';
    }
    // ארטישוק קפוא - תוקן בטעות להיגיינה אישית
    else if (name.contains('ארטישוק') && name.contains('קפוא')) {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // ארטישוק/תפוא ירושלמי - ירקות
    else if (name.contains('ארטישוק') || name.contains('תפו"א ירושלמי')) {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // נודלס/אטריות - אורז ופסטה (לא בשר!)
    else if (_matchesAny(name, ['נודלס', 'אטריות']) && currentCategory == 'בשר ודגים') {
      newCategory = 'אורז ופסטה';
      newIcon = '🍚';
    }
    // דאודורנט/ספריי גוף - היגיינה (לא פירות!)
    else if (_matchesAny(name, ['אקס ספריי', 'דאו ספריי', 'דאודורנט', 'אפטר שייב']) && currentCategory != 'היגיינה אישית') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // בונזו - מזון לכלבים (לא בשר!)
    else if (name.contains('בונזו') && currentCategory == 'בשר ודגים') {
      newCategory = 'מזון לחיות מחמד';
      newIcon = '🐾';
    }
    // בורקס - מאפים (לא מוצרי חלב!)
    else if (name.contains('בורקס') && currentCategory == 'מוצרי חלב') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // בייגלה - חטיפים (לא מוצרי חלב או ירקות!)
    else if (_matchesAny(name, ['בייגלה', 'בייגל']) && _matchesAny(currentCategory, ['מוצרי חלב', 'ירקות', 'אחר'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // בייבי ביס - חטיפי תינוקות (לא פירות או מאפים!)
    else if (name.contains('בייבי ביס')) {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // ביסקוויט/ביסקוטי - ממתקים
    else if (_matchesAny(name, ['ביסקוויט', 'ביסקוטי', 'בפלות']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // קינדר - ממתקים
    else if (name.contains('קינדר') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // בורגר טבעוני/צמחוני - תחליפי בשר
    else if (_matchesAny(name, ['בורגר', 'מן הצומח', 'טבעוני']) && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // יין - משקאות
    else if (_matchesAny(name, ['יין', 'ווין', 'wine']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // בריזר - משקאות אלכוהול
    else if (name.contains('בריזר') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍹';
    }
    // ג'אמפ/משקאות מוגזים - משקאות
    else if (_matchesAny(name, ["ג'אמפ", 'ג\'אמפ', 'משקה']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // ברף/מוצרי אסלה - ניקיון
    else if (_matchesAny(name, ['ברף', 'לאסלה', 'למיכל אסלה']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // בלינצס - קפואים
    else if (name.contains('בלינצס') && currentCategory != 'קפואים') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // ברוסקטות - מאפים/חטיפים (לא ירקות!)
    else if (name.contains('ברוסקטות') && currentCategory == 'ירקות') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // בסיס לפיצה/בצק - מאפים
    else if (_matchesAny(name, ['בסיס לפיצה', 'בצק לפיצה', 'בצק עלים', 'בצק פילאס']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // גבינות (ברי, פטה) - מוצרי חלב
    else if (_matchesAny(name, ['ברי צרפתי', 'ברי פקאן', 'פטה יוונית', 'פטינה']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // ביגלה - מאפים
    else if (name.contains('ביגלה') && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // בריסטה/חלב שיבולת שועל - תחליפי חלב
    else if (_matchesAny(name, ['בריסטה', 'נוט מילק', 'שועל']) && currentCategory == 'אחר') {
      newCategory = 'תחליפי חלב';
      newIcon = '🥛';
    }
    // קוויאר - דגים
    else if (name.contains('קוויאר') && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // ברנפלקס/קורנפלקס - דגנים
    else if (_matchesAny(name, ['ברנפלקס', 'קורנפלקס', 'דגני בוקר']) && currentCategory == 'אחר') {
      newCategory = 'דגנים';
      newIcon = '🥣';
    }
    // בלונס - מסיבות (לא קטגוריה רלוונטית)
    else if (name.contains('בלונס') && currentCategory == 'אחר') {
      newCategory = 'מוצרי בית';
      newIcon = '🎈';
    }
    // ג'אמפ - משקאות (לא פירות!)
    else if (name.contains("ג'אמפ") && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // ג'חנון/לחוח - מאפים
    else if (_matchesAny(name, ["ג'חנון", 'לחוח', 'מלאווח']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // ג'ין/ג'ינג'ר - משקאות אלכוהול
    else if (_matchesAny(name, ["ג'ין ", 'ג\'ין ', 'וודקה', 'ויסקי', 'רום', 'ברנדי', 'ליקר', 'טקילה']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍸';
    }
    // ג'ל גילוח/ג'ל פטרוליום - היגיינה
    else if (_matchesAny(name, ["ג'ל גילוח", "ג'ל פטרוליום", "ג'לט קצף"]) && currentCategory != 'היגיינה אישית') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // ג'ל כביסה - ניקיון
    else if (_matchesAny(name, ["ג'ל כביסה", "ג'ל כ.מרוכז", "ג'ל מסיר כתמים"]) && _matchesAny(currentCategory, ['אחר', 'בשר ודגים'])) {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // גאודה/גבינות - מוצרי חלב (לא אחר!)
    else if (_matchesAny(name, ['גאודה', 'גבינה', 'גבינת', 'גב.']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // גאטו נגרו - יין (לא בשר!)
    else if (name.contains('גאטו נגרו') && currentCategory == 'בשר ודגים') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // גוורצטרמינר - יין
    else if (name.contains('גוורצטרמינר') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // גויאבות - פירות
    else if (name.contains('גויאבות') && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🍎';
    }
    // ג'לטין - תבלינים ואפייה (לא מוצרי חלב!)
    else if (name.contains("ג'לטין") && currentCategory == 'מוצרי חלב') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // ג'לי - מוצרי חלב (קינוח)
    else if (name.contains("ג'לי") && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🍮';
    }
    // גבינה עיזים - מוצרי חלב (לא ירקות!)
    else if (_matchesAny(name, ['גב.עיזים', 'גבינת עיזים']) && currentCategory == 'ירקות') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // גולדסטאר/בירה - משקאות (לא אחר!)
    else if (_matchesAny(name, ['גולדסטאר', 'מכבי לאגר', 'באדווייזר', 'הייניקן', 'טובורג', 'קרלסברג']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍺';
    }
    // גים בים/ג'ים בים - ויסקי (לא בשר!)
    else if (_matchesAny(name, ['גים בים', "ג'ים בים", 'ג\'ים בים']) && currentCategory == 'בשר ודגים') {
      newCategory = 'משקאות';
      newIcon = '🥃';
    }
    // גל גילוח - היגיינה (לא בשר!)
    else if (_matchesAny(name, ['גל גילוח', 'גילוח']) && currentCategory == 'בשר ודגים') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // גל כביסה/פרסיל - ניקיון (לא אחר!)
    else if (_matchesAny(name, ['גל כביסה', 'פרסיל', 'כביסה']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // גלידה - קפואים (לא פירות/תבלינים!)
    else if (name.contains('גלידה') && _matchesAny(currentCategory, ['פירות', 'תבלינים ואפייה', 'אחר'])) {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // גליל מטליות - ניקיון (לא היגיינה!)
    else if (_matchesAny(name, ['גליל מטליות', 'מגבת נייר', 'נייר טואלט']) && currentCategory == 'היגיינה אישית') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧻';
    }
    // גרנולה - דגנים (לא אחר/תבלינים!)
    else if (name.contains('גרנולה') && _matchesAny(currentCategory, ['אחר', 'תבלינים ואפייה'])) {
      newCategory = 'דגנים';
      newIcon = '🥣';
    }
    // גרגירי חומוס - שימורים (לא שמנים/תבלינים!)
    else if (name.contains('גרגירי חומוס') && _matchesAny(currentCategory, ['שמנים ורטבים', 'תבלינים ואפייה'])) {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // גונסון בייבי - מוצרי תינוקות (לא שמנים!)
    else if (_matchesAny(name, ["ג'ונסון", 'גונסון', 'בייבי שמן', 'שמן לתינוק']) && currentCategory == 'שמנים ורטבים') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // גרניה ספריי - היגיינה (לא אחר!)
    else if (name.contains('גרניה') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // גריסים - אורז ופסטה (לא אחר!)
    else if (name.contains('גריסים') && currentCategory == 'אחר') {
      newCategory = 'אורז ופסטה';
      newIcon = '🍚';
    }
    // גריסיני - מאפים (לא אחר!)
    else if (name.contains('גריסיני') && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // גרעיני דלעת/חמנייה - אגוזים וגרעינים (לא ירקות/תבלינים!)
    else if (_matchesAny(name, ['גרעיני דלעת', 'גרעיני חמנייה', 'גרעינים']) && _matchesAny(currentCategory, ['ירקות', 'תבלינים ואפייה'])) {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // דאב מוצרי טיפוח - היגיינה (לא ניקיון/ירקות/פירות!)
    else if (name.contains('דאב') && _matchesAny(currentCategory, ['מוצרי ניקיון', 'ירקות', 'פירות'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // דאו/דאודורנט - היגיינה (לא אחר/משקאות!)
    else if (_matchesAny(name, ['דאו.', 'דאו ', 'רול און', 'רולאון']) && _matchesAny(currentCategory, ['אחר', 'משקאות'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // דבש - ממרחים מתוקים (לא אחר!)
    else if (name.contains('דבש') && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // דגני בוקר - דגנים (לא בשר!)
    else if (_matchesAny(name, ['דגני בוקר', 'דגני טבעות', 'דגני קוקו', 'הלו קיטי', 'קיטקט 330']) && currentCategory == 'בשר ודגים') {
      newCategory = 'דגנים';
      newIcon = '🥣';
    }
    // דגש אבקת מרק - תבלינים (לא בשר!)
    else if (name.contains('אבקת מרק') && currentCategory == 'בשר ודגים') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // דואט שמפניון/פטריות - ירקות (לא אחר!)
    else if (_matchesAny(name, ['שמפניון', 'פורטובלו', 'פטריות']) && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🍄';
    }
    // דוגלי - מזון לחיות מחמד (לא אחר!)
    else if (name.contains('דוגלי') && currentCategory == 'אחר') {
      newCategory = 'מזון לחיות מחמד';
      newIcon = '🐾';
    }
    // דון חוליו/יין - משקאות (לא אחר!)
    else if (_matchesAny(name, ['דון חוליו', 'קברנה', 'מרלו', 'שרדונה', 'סוביניון']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // דורגול - מוצרי ניקיון (לא אחר!)
    else if (name.contains('דורגול') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // דורות פסטו - שמנים ורטבים (לא אחר!)
    else if (name.contains('פסטו') && currentCategory == 'אחר') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // דזיטול/חיטוי - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['דזיטול', 'חיטוי', 'דטול']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // דייסת מטרנה - מוצרי תינוקות (לא תבלינים!)
    else if (_matchesAny(name, ['דייסת', 'מטרנה']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // דיסקריט תחבושות - היגיינה (לא תבלינים!)
    else if (_matchesAny(name, ['דיסקריט', 'תחבושות']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // דלי/כלי בית - מוצרי בית (לא אחר!)
    else if (_matchesAny(name, ['דלי ', 'דלי אוולי']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי בית';
      newIcon = '🪣';
    }
    // דלורית - ירקות (לא אחר!)
    else if (name.contains('דלורית') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // דלתון/יין - משקאות (לא אחר!)
    else if (_matchesAny(name, ['דלתון', 'מוסקאטו', 'רוזה אסטייט']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // דנונה - מוצרי חלב (לא אחר!)
    else if (name.contains('דנונה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🥛';
    }
    // דנטלייף - מזון לחיות מחמד (לא אחר!)
    else if (name.contains('דנטלייף') && currentCategory == 'אחר') {
      newCategory = 'מזון לחיות מחמד';
      newIcon = '🐾';
    }
    // דרום יין - משקאות (לא חלב!)
    else if (_matchesAny(name, ['דרום יין', 'יין לבן', 'יין אדום']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // האני באנצס - דגנים/חטיפים (לא אחר/פירות!)
    else if (_matchesAny(name, ['האני באנצס', 'האני בנצ']) && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'דגנים';
      newIcon = '🥣';
    }
    // הגן הקסום/חליטה - קפה ותה (לא אחר!)
    else if (_matchesAny(name, ['הגן הקסום', 'חליטת', 'חליטה']) && currentCategory == 'אחר') {
      newCategory = 'קפה ותה';
      newIcon = '🍵';
    }
    // הד&שולדרס/שמפו - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['הד&שולדרס', 'הד אנד שולדרס', 'שמפו']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // הוגארדן/בירה בלגית - משקאות (לא אחר!)
    else if (_matchesAny(name, ['הוגארדן', 'לפה', 'סטלה ארטואה', 'קורונה']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍺';
    }
    // הוואי שמפו/טיפוח שיער - היגיינה (לא אחר!)
    else if (_matchesAny(name, ['הוואי', 'קשקשים', 'שיער יבש', 'שיער רגיל']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // היט מיניס/שוקו - ממתקים (לא אחר!)
    else if (_matchesAny(name, ['היט מיניס', 'שוקו 130']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // המבורגר צמחוני - תחליפי בשר (לא בשר ודגים!)
    else if (_matchesAny(name, ['המבורגר צמחוני', 'שניצל צמחוני', 'נקניק צמחוני', 'קציצות צמחוניות']) && currentCategory == 'בשר ודגים') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // הרבל אסנס - היגיינה אישית (לא ניקיון!)
    else if (_matchesAny(name, ['הרבל אסנס', 'מרכך ניחוח', 'מרכך שיער']) && currentCategory == 'מוצרי ניקיון') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // הרינג/דג מלוח - בשר ודגים (לא תבלינים!)
    else if (_matchesAny(name, ['הרינג', 'דג מלוח', 'דג מעושן']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // וולה דלוקס/מוס שיער - היגיינה (לא אחר!)
    else if (_matchesAny(name, ['וולה', 'מוס לעיצוב', 'מוס שיער', 'ספריי שיער']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // וונדרס/תחליף בשר - תחליפי בשר (לא אחר!)
    else if (_matchesAny(name, ['וונדרס', 'ביונד מיט', 'אימפוסיבל']) && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // ווקס שיער - היגיינה (לא אחר!)
    else if (_matchesAny(name, ['ווקס', 'חימר לעיצוב', 'ג\'ל שיער']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // ויט רצועות שעווה - היגיינה (לא אחר!)
    else if (_matchesAny(name, ['ויט ', 'רצועות שעווה', 'שעווה להסרת']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // ויטמינצ'יק - משקאות (לא אחר!)
    else if (name.contains('ויטמינצ') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // וניש ג'ל לכביסה - ניקיון (לא פירות!)
    else if (_matchesAny(name, ['וניש', "ג'ל לכביסה"]) && currentCategory == 'פירות') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // ורדי רימונים - משקאות (לא אחר!)
    else if (_matchesAny(name, ['ורדי רימונים', 'רימונים 750']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // זוג רדידים/נייר אפייה - מוצרי בית (לא אחר!)
    else if (_matchesAny(name, ['רדידים', 'נייר אפייה', 'נייר פרגמנט']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי בית';
      newIcon = '🏠';
    }
    // זית/זיתים - שימורים (לא אחר!)
    else if (_matchesAny(name, ['זית ', 'זית.', 'זיתים']) && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🫒';
    }
    // זיתים עגבניות מיובשות - שימורים (לא פירות!)
    else if (_matchesAny(name, ['זיתים', 'עגבניות מיובשות']) && currentCategory == 'פירות') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // זעתר - תבלינים (לא ירקות!)
    else if (name.contains('זעתר') && currentCategory == 'ירקות') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // זרעי עגבניות/זרעים לגינה - מוצרי גינה (לא חלב!)
    else if (_matchesAny(name, ['זרעי עגבניות', 'זרעי מלפפון', 'זרעי פלפל']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'מוצרי גינה';
      newIcon = '🌱';
    }
    // זרעי פשתן/צ'יה - אגוזים וגרעינים (לא היגיינה!)
    else if (_matchesAny(name, ['זרעי פשתן', 'זרעי צ\'יה', 'זרעי חיה']) && currentCategory == 'היגיינה אישית') {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // חלווה - ממרחים מתוקים (לא אחר!)
    else if (name.contains('חלווה') && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // חוואיג'/תבלין תימני - תבלינים (לא אחר!)
    else if (_matchesAny(name, ['חוואיג', 'חוואג', 'שוג']) && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // חוט דנטלי - היגיינה (לא אחר!)
    else if (_matchesAny(name, ['חוט דנטלי', 'דנטלי', 'קיסמים']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🦷';
    }
    // חומוס לבנוני - שמנים ורטבים (לא פירות!)
    else if (name.contains('חומוס') && currentCategory == 'פירות') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫗';
    }
    // חומץ אורז - שמנים ורטבים (לא אורז ופסטה!)
    else if (name.contains('חומץ') && currentCategory == 'אורז ופסטה') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // חומץ בלסמי/תפוחי עץ - שמנים ורטבים (לא אחר/פירות!)
    else if (name.contains('חומץ') && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // חזה צמחוני - תחליפי בשר (לא אחר!)
    else if (_matchesAny(name, ['חזה צמחוני', 'חזה בגריל צמחוני']) && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // חזה עוף/הודו - בשר ודגים (לא אחר/חלב!)
    else if (_matchesAny(name, ['חזה עוף', 'חזה הודו', 'חזה דקדק']) && _matchesAny(currentCategory, ['אחר', 'מוצרי חלב'])) {
      newCategory = 'בשר ודגים';
      newIcon = '🍗';
    }
    // חטיף נייטשר וואלי - ממתקים וחטיפים (לא אחר!)
    else if (_matchesAny(name, ['נייטשר וואלי', 'nature valley']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // חטיף שוקולד חמאת בוטנים - ממתקים (לא חלב!)
    else if (_matchesAny(name, ['שוקו.חלב', 'חמאת בוטנ']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // חטיפטף/לפתן פירות - מוצרי תינוקות (לא אחר/פירות!)
    else if (_matchesAny(name, ['חטיפטף', 'לפתן', 'פרינוק']) && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // חטיפי FREE - ממתקים וחטיפים (לא אחר!)
    else if (name.contains('free') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // חטיפי פיצה/תירס טבעול - קפואים (לא שימורים!)
    else if (_matchesAny(name, ['חטיפי פיצה', 'חטיפי תירס']) && currentCategory == 'שימורים') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // חטיפי פריכונים - ממתקים וחטיפים (לא ממרחים מתוקים!)
    else if (name.contains('פריכונים') && currentCategory == 'ממרחים מתוקים') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // חיטה - קטניות ודגנים (לא אחר!)
    else if (name.contains('חיטה') && currentCategory == 'אחר') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🌾';
    }
    // חלבה/חלווה - ממרחים מתוקים (לא חלב/תבלינים!)
    else if (_matchesAny(name, ['חלבה', 'חלווה']) && _matchesAny(currentCategory, ['מוצרי חלב', 'תבלינים ואפייה'])) {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // חלומי - מוצרי חלב/גבינה (לא אחר!)
    else if (name.contains('חלומי') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // חליטת ג'ינג'ר/דבש - קפה ותה (לא ממרחים מתוקים!)
    else if (_matchesAny(name, ["חליטת ג'ינג'ר", 'חליטת גינג']) && currentCategory == 'ממרחים מתוקים') {
      newCategory = 'קפה ותה';
      newIcon = '🍵';
    }
    // חליטת קינמון - קפה ותה (לא תבלינים!)
    else if (_matchesAny(name, ['חליטת קינמון', 'חליטת קסם']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'קפה ותה';
      newIcon = '🍵';
    }
    // חלת/חלה - מאפים (לא אחר!)
    else if (_matchesAny(name, ['חלת ', 'חלת קונדיטוריה', 'חלת שבת', 'חלת שושנים']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🍞';
    }
    // חמאת בוטנים - ממרחים מתוקים (לא אחר!)
    else if (name.contains('חמאת בוטנים') && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🥜';
    }
    // חמוציות - פירות יבשים (לא אחר!)
    else if (name.contains('חמוציות') && currentCategory == 'אחר') {
      newCategory = 'פירות יבשים';
      newIcon = '🍇';
    }
    // חמישיה שלגון/גלידה - קפואים (לא תבלינים!)
    else if (_matchesAny(name, ['שלגון', 'גלידון', 'מגנום']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // חמצוצים - ממתקים וחטיפים (לא אחר!)
    else if (name.contains('חמצוצים') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // חציל - ירקות (לא אחר!)
    else if (name.contains('חציל') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🍆';
    }
    // חציל במיונז/סלט חציל - שמנים ורטבים (לא חלב!)
    else if (_matchesAny(name, ['חציל במיונז', 'סלט חציל']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫗';
    }
    // חריסה - שמנים ורטבים (לא אחר!)
    else if (name.contains('חריסה') && currentCategory == 'אחר') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🌶️';
    }
    // חתיכות הרינג - בשר ודגים (לא אחר!)
    else if (_matchesAny(name, ['חתיכות הרינג', 'הרינג מלוח']) && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // טבלת שוקולד - ממתקים (לא אחר!)
    else if (_matchesAny(name, ['טבלת טורינו', 'טבלת שוקולד', 'טבלת מריר']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // טבעול נקניקיות צמחוניות - תחליפי בשר (לא בשר!)
    else if (_matchesAny(name, ['טבעול נקניקיות', 'נקניקיות צמחוני', 'קוקטייל צ']) && currentCategory == 'בשר ודגים') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // טבעות בצל קפוא - קפואים (לא ירקות!)
    else if (name.contains('טבעות בצל') && currentCategory == 'ירקות') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // טבעות זיתים - שימורים (לא אחר!)
    else if (name.contains('טבעות זית') && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🫒';
    }
    // טבעות תירס ואורז - דגנים (לא אורז ופסטה!)
    else if (name.contains('טבעות תירס') && currentCategory == 'אורז ופסטה') {
      newCategory = 'דגנים';
      newIcon = '🥣';
    }
    // טוויקס/מארס/סניקרס - ממתקים (לא אחר!)
    else if (_matchesAny(name, ['טוויקס', 'מארס', 'סניקרס', 'מילקי ווי', 'באונטי']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // טונה - שימורים (לא ממתקים!)
    else if (name.contains('טונה') && currentCategory == 'ממתקים וחטיפים') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // טוסטעים/פת קלויה - מאפים (לא אחר!)
    else if (_matchesAny(name, ['טוסטעים', 'פת קלויה', 'קרקר']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // טופו - תחליפי בשר (לא אחר!)
    else if (name.contains('טופו') && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // טורטיה - מאפים (לא חלב/היגיינה/תבלינים!)
    else if (_matchesAny(name, ['טורטיה', 'טורטיות']) && _matchesAny(currentCategory, ['מוצרי חלב', 'היגיינה אישית', 'תבלינים ואפייה'])) {
      newCategory = 'מאפים';
      newIcon = '🌮';
    }
    // טורס דה אספניה/יין - משקאות (לא אחר!)
    else if (_matchesAny(name, ['טורס דה', 'בלאנקו750']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // טיק טק - ממתקים (לא אחר!)
    else if (name.contains('טיק טק') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // טמפקס - היגיינה אישית (לא אחר!)
    else if (name.contains('טמפקס') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // טרו ריבת - ממרחים מתוקים (לא אחר/פירות!)
    else if (_matchesAny(name, ['ריבת ', 'ריבה ']) && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍓';
    }
    // טריפל צ'דר/גבינה - מוצרי חלב (לא אחר!)
    else if (_matchesAny(name, ['טריפל צ', 'צדר', "צ'דר"]) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // ידית טלסקופית - מוצרי בית (לא אחר!)
    else if (_matchesAny(name, ['ידית טלסקופית', 'מקל סחבה']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי בית';
      newIcon = '🏠';
    }
    // יוגורט מולר - מוצרי חלב (לא אחר!)
    else if (_matchesAny(name, ['יוג.מולר', 'יוגורט מולר']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🥛';
    }
    // יוגורט יופלה/דנונה - מוצרי חלב (לא ממתקים!)
    else if (_matchesAny(name, ['יוגורט', 'יופלה']) && currentCategory == 'ממתקים וחטיפים') {
      newCategory = 'מוצרי חלב';
      newIcon = '🥛';
    }
    // טונה - שימורים (לא ממתקים!)
    else if (name.contains('טונה') && currentCategory == 'ממתקים וחטיפים') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // יין ויזן - משקאות (לא מוצרי חלב!)
    else if (_matchesAny(name, ['יין ויזן', 'יין לבן']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // כדורי בשר צמחוניים - תחליפי בשר (לא בשר!)
    else if (_matchesAny(name, ['כדורי בשר צמ', 'בשר צמחוני']) && currentCategory == 'בשר ודגים') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // כוס הפלא - מוצרי תינוקות (לא אחר!)
    else if (_matchesAny(name, ['כוס הפלא', 'כוס לתינוק']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // כוסות/כפות חד פעמי - מוצרי בית (לא אחר!)
    else if (_matchesAny(name, ['כוסות גדול', 'כף שקוף', 'כף חד פעמי', 'כפפות ניטריל']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי בית';
      newIcon = '🏠';
    }
    // כוסמין/כוסמת - קטניות ודגנים (לא אחר!)
    else if (_matchesAny(name, ['כוסמין', 'כוסמת']) && currentCategory == 'אחר') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🌾';
    }
    // כיס תפו"ע - ירקות (לא אחר!)
    else if (_matchesAny(name, ['כיס תפו', 'תפוח אדמה']) && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥔';
    }
    // כיף שמפו/מרכך/תחליב - היגיינה אישית (לא אחר/פירות/חלב!)
    else if (name.contains('כיף ') && _matchesAny(currentCategory, ['אחר', 'פירות', 'מוצרי חלב'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // כרוב לבן - ירקות (לא מוצרי חלב!)
    else if (name.contains('כרוב') && currentCategory == 'מוצרי חלב') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // כריות קרצוף - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['כריות קרצוף', 'קרצוף', 'ספוג']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // כרישה - ירקות (לא אחר!)
    else if (name.contains('כרישה') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // כתף עוף/בשר - בשר ודגים (לא אחר!)
    else if (_matchesAny(name, ['כתף ', 'צוואר', 'ירך ', 'שוק ']) && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🥩';
    }
    // לאבנה - מוצרי חלב (לא אחר!)
    else if (name.contains('לאבנה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🥛';
    }
    // לבבות דקל - שימורים (לא בשר!)
    else if (name.contains('לבבות דקל') && currentCategory == 'בשר ודגים') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // לביבות - קפואים (לא ירקות!)
    else if (name.contains('לביבות') && currentCategory == 'ירקות') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // לה קט - מזון לחיות מחמד (לא אחר!)
    else if (name.contains('לה קט') && currentCategory == 'אחר') {
      newCategory = 'מזון לחיות מחמד';
      newIcon = '🐱';
    }
    // לה קרמריה/גלידה - קפואים (לא ממתקים/פירות/חלב!)
    else if (_matchesAny(name, ['לה קרמריה', 'קרמריה']) && _matchesAny(currentCategory, ['ממתקים וחטיפים', 'פירות', 'מוצרי חלב'])) {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // לואקר - ממתקים וחטיפים (לא אחר!)
    else if (name.contains('לואקר') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // לחם - מאפים (לא מוצרי חלב!)
    else if (_matchesAny(name, ['לחם ', 'לחם לבן', 'לחם מוראטו', 'לחם קל']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'מאפים';
      newIcon = '🍞';
    }
    // לחמניות - מאפים (לא בשר/חלב!)
    else if (name.contains('לחמניות') && _matchesAny(currentCategory, ['בשר ודגים', 'מוצרי חלב'])) {
      newCategory = 'מאפים';
      newIcon = '🍞';
    }
    // לילי נייר טואלט - מוצרי ניקיון (לא בשר!)
    else if (_matchesAny(name, ['לילי ', 'נייר טואלט']) && currentCategory == 'בשר ודגים') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧻';
    }
    // ליידי ספיד סטיק - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['ליידי ספיד', 'ספיד סטיק']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // לימון - פירות (לא אחר!)
    else if (name.contains('לימון') && !name.contains("צ'לו") && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🍋';
    }
    // לימונצ'לו/למברוסקו - משקאות (לא אחר!)
    else if (_matchesAny(name, ["לימונצ'לו", 'למברוסקו']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // לינדט - ממתקים וחטיפים (לא אחר!)
    else if (name.contains('לינדט') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // ליסטרין - היגיינה אישית (לא אחר!)
    else if (name.contains('ליסטרין') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // לקריץ - ממתקים וחטיפים (לא תבלינים!)
    else if (name.contains('לקריץ') && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // מאגדת גלידה - קפואים (לא אחר/פירות/חלב!)
    else if (_matchesAny(name, ['מאגדת ', 'מאגדת גלידה', 'מאגדת מגנום', 'מאגדת מילקה']) && _matchesAny(currentCategory, ['אחר', 'פירות', 'מוצרי חלב'])) {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // משחת שיניים - היגיינה אישית (לא בשר/פירות!)
    else if (_matchesAny(name, ['משחת שיניים', 'פרודונטקס', 'קולגייט', 'סנסודיין']) && _matchesAny(currentCategory, ['בשר ודגים', 'פירות'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🪥';
    }
    // מאמאמיה פיצה - קפואים (לא אחר/שימורים!)
    else if (name.contains('מאמאמיה') && _matchesAny(currentCategory, ['אחר', 'שימורים'])) {
      newCategory = 'קפואים';
      newIcon = '🍕';
    }
    // מאפה דונאטס - מאפים (לא פירות!)
    else if (_matchesAny(name, ['מאפה דונאטס', 'דונאטס']) && currentCategory == 'פירות') {
      newCategory = 'מאפים';
      newIcon = '🍩';
    }
    // מארז אבוקדו/ליים - פירות (לא אחר!)
    else if (_matchesAny(name, ['אבוקדו', 'ליים']) && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🥑';
    }
    // מארז בייגלה - מאפים (לא ממתקים!)
    else if (name.contains('בייגלה') && currentCategory == 'ממתקים וחטיפים') {
      newCategory = 'מאפים';
      newIcon = '🥯';
    }
    // מברשת שיניים/קולגייט - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['מברשת', 'מברשתיעה']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🪥';
    }
    // מבשם בדים - מוצרי ניקיון (לא אחר!)
    else if (name.contains('מבשם') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧴';
    }
    // מג'יק ריטאצ' (צבע שיער) - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ["מג'יק", 'ריטאצ']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '💇';
    }
    // מגב - מוצרי ניקיון (לא אחר!)
    else if (name.contains('מגב ') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מגבונים מסירי איפור - היגיינה אישית (לא מוצרי חלב!)
    else if (_matchesAny(name, ['מסירי איפור', 'מגבונאף']) && _matchesAny(currentCategory, ['מוצרי חלב', 'אחר'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // מגבוני דיסני/תינוקות - מוצרי תינוקות (לא אחר!)
    else if (_matchesAny(name, ['מגבוני דיסני']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // מגבוני רצפה - מוצרי ניקיון (לא פירות!)
    else if (name.contains('מגבוני רצפה') && currentCategory == 'פירות') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מגורדת מוצרלה - מוצרי חלב (לא אחר!)
    else if (_matchesAny(name, ['מגורדת', 'מוצרלה']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // מגרדת לכף הרגל - היגיינה אישית (לא אחר!)
    else if (name.contains('מגרדת') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🦶';
    }
    // מגש/כוסות/מזלגות חד פעמי - חד פעמי (לא בשר/היגיינה!)
    else if (_matchesAny(name, ['מגש ', 'מזלג ', 'כוסות ', 'סכין חד', 'צלחות ']) && _matchesAny(currentCategory, ['בשר ודגים', 'היגיינה אישית'])) {
      newCategory = 'חד פעמי';
      newIcon = '🍽️';
    }
    // מולטי צ'ריוס - קטניות ודגנים (לא אחר!)
    else if (_matchesAny(name, ["צ'ריוס", 'צריוס', 'קורנפלקס']) && currentCategory == 'אחר') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🥣';
    }
    // מוסקטו/יין - משקאות (לא אחר/בשר!)
    else if (_matchesAny(name, ['מוסקטו', 'קברנה', 'סובניון', 'שרדונה', 'מרלו']) && _matchesAny(currentCategory, ['אחר', 'בשר ודגים'])) {
      newCategory = 'משקאות';
      newIcon = '🍷';
    }
    // מוש צמר גפן - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['צמר גפן', 'מוש ']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧶';
    }
    // מחית מרק ירקות - שימורים (לא אחר!)
    else if (_matchesAny(name, ['מחית מרק', 'מרק ירקות']) && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // מחית עגבניות - שימורים (לא פירות!)
    else if (name.contains('מחית עגבניות') && currentCategory == 'פירות') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // מחית קארי/סלסה - שמנים ורטבים (לא אחר!)
    else if (_matchesAny(name, ['מחית קארי', 'סלסה']) && currentCategory == 'אחר') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // מטבעות שוקולד חלב/לבן - ממתקים וחטיפים (לא מוצרי חלב/בשר!)
    else if (name.contains('מטבעות שוק') && _matchesAny(currentCategory, ['מוצרי חלב', 'בשר ודגים'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // מטחנת מלח/תבלין - תבלינים ואפייה (לא ירקות!)
    else if (_matchesAny(name, ['מטחנת מלח', 'מטחנת פלפל', 'מטחנת ']) && currentCategory == 'ירקות') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // מטליות לפרקט - מוצרי ניקיון (לא היגיינה!)
    else if (name.contains('לפרקט') && currentCategory == 'היגיינה אישית') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מי ורדים - תבלינים ואפייה (לא אחר!)
    else if (name.contains('מי ורדים') && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🌹';
    }
    // מי סאן בנדטו/מים מינרלים - משקאות (לא אחר!)
    else if (_matchesAny(name, ['מי סאן', 'בנדטו', 'מים מצוננים', 'מים טעם', 'מים בתוספת', 'עין גדי']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '💧';
    }
    // מי פה - היגיינה אישית (לא אחר!)
    else if (name.contains('מי פה') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🦷';
    }
    // מיכל פלסטיק - חד פעמי (לא אחר!)
    else if (_matchesAny(name, ['מיכל 1', 'מיכל 3', 'מיכל 5']) && currentCategory == 'אחר') {
      newCategory = 'חד פעמי';
      newIcon = '🫙';
    }
    // מילוי אירוויק - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['אירוויק', 'מבשם אוויר', 'מטהר']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🌸';
    }
    // מילקי קייק - ממתקים וחטיפים (לא אחר!)
    else if (_matchesAny(name, ['מילקי קייק']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // מיני דק שניצל - קפואים (לא מוצרי חלב!)
    else if (_matchesAny(name, ['מיני דק', 'שניצל']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'קפואים';
      newIcon = '🍗';
    }
    // מיני חלוה/פסק זמן - ממתקים וחטיפים (לא אחר!)
    else if (_matchesAny(name, ['מיני חלוה', 'פסק זמן', 'מיקס לילד']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // מיץ עגבניות/תפוגזר - משקאות (לא פירות/ירקות!)
    else if (_matchesAny(name, ['מיץ עגבניות', 'מיץ תפוגזר', 'תפוגזר']) && _matchesAny(currentCategory, ['פירות', 'ירקות'])) {
      newCategory = 'משקאות';
      newIcon = '🍹';
    }
    // מיץ תפוח/תפוז - משקאות (לא פירות!)
    else if (_matchesAny(name, ['מיץ תפוח', 'מיץ תפוז']) && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // מיקס עלי מיקרו - ירקות (לא אחר!)
    else if (_matchesAny(name, ['עלי מיקרו', 'עלי בייבי']) && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // מכבי שנדי - משקאות (לא פירות!)
    else if (_matchesAny(name, ['שנדי', 'מכבי ']) && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🍺';
    }
    // מלפפונים במלח - שימורים (לא תבלינים!)
    else if (name.contains('מלפפונים במלח') && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'שימורים';
      newIcon = '🥒';
    }
    // ממרח אגוזי לוז/צ'וקטה - ממרחים מתוקים (לא אחר!)
    else if (_matchesAny(name, ["צ'וקטה", 'נוטלה', 'ממרח אגוזי']) && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍫';
    }
    // ממרח קרמי/צזיקיני - שמנים ורטבים (לא אחר!)
    else if (_matchesAny(name, ['ממרח במרקם', 'צזיקיני', 'ממרח בסגנון']) && currentCategory == 'אחר') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // ממרח זיתים - שימורים (לא אחר!)
    else if (_matchesAny(name, ['ממרח זית', 'זיתי קלמטה']) && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🫒';
    }
    // ממרח עגבניות - שמנים ורטבים (לא פירות!)
    else if (name.contains('ממרח עגבניות') && currentCategory == 'פירות') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🍅';
    }
    // ממרח פלפלים/שום - שמנים ורטבים (לא ירקות!)
    else if (_matchesAny(name, ['ממרח פלפלים', 'ממרח שום']) && currentCategory == 'ירקות') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // מנטוס - ממתקים וחטיפים (לא משקאות/היגיינה/אחר!)
    else if (name.contains('מנטוס') && _matchesAny(currentCategory, ['משקאות', 'היגיינה אישית', 'אחר'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // מסיכה/מסכה לשיער - היגיינה אישית (לא אחר/בשר!)
    else if (_matchesAny(name, ['מסיכ', 'מסכה ', 'מסכת ']) && _matchesAny(currentCategory, ['אחר', 'בשר ודגים'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '💆';
    }
    // מסיר כתמים/שומנים - מוצרי ניקיון (לא אחר/פירות!)
    else if (_matchesAny(name, ['מסיר כתמ', 'מסיר שומנ']) && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מסקרפונה - מוצרי חלב (לא אחר!)
    else if (name.contains('מסקרפונה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // מעדן סויה - תחליפי חלב (לא תבלינים/שמנים!)
    else if (name.contains('מעדן סויה') && _matchesAny(currentCategory, ['תבלינים ואפייה', 'שמנים ורטבים'])) {
      newCategory = 'תחליפי חלב';
      newIcon = '🥛';
    }
    // מעטפות בצק פילופטה - קפואים (לא אחר!)
    else if (_matchesAny(name, ['מעטפות ', 'מעטפת ', 'פילופטה']) && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🥟';
    }
    // מפות שולחן/מפיות - חד פעמי (לא אחר!)
    else if (_matchesAny(name, ['מפות שולחן', 'מפיות ']) && currentCategory == 'אחר') {
      newCategory = 'חד פעמי';
      newIcon = '🧻';
    }
    // מקל מחוזק - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['מקל מחוזק', 'מטאטא', 'מקל למטאטא']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מקלוני ירקות - קפואים (לא ירקות!)
    else if (name.contains('מקלוני ירקות') && currentCategory == 'ירקות') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // מקרל - בשר ודגים (לא אחר!)
    else if (name.contains('מקרל') && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // מרכך לשיער - היגיינה אישית (לא מוצרי ניקיון!)
    else if (_matchesAny(name, ['מרכך לשיער', 'מרכך קרטין', 'מרכך לילדים', 'מרכך ניחוח']) && currentCategory == 'מוצרי ניקיון') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // מרלבורו/סיגריות - טבק (לא בשר ודגים!)
    else if (_matchesAny(name, ['מרלבורו', 'סיגריות', 'נובלס', 'ווינסטון']) && currentCategory == 'בשר ודגים') {
      newCategory = 'אחר';
      newIcon = '🚬';
    }
    // מרסי שוקולד - ממתקים וחטיפים (לא אחר!)
    else if (_matchesAny(name, ['מרסי ', 'שטורק']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // מרסס מסיר עובש - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['מרסס מסיר', 'מסיר עובש']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // מרציפן - תבלינים ואפייה (לא אחר!)
    else if (name.contains('מרציפן') && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🥜';
    }
    // מרק בטעם עוף/עוף אמיתי - שימורים (לא בשר ודגים!)
    else if (_matchesAny(name, ['מרק בטעם', 'מרק עוף']) && currentCategory == 'בשר ודגים') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // מרק בצל/פטריות - שימורים (לא ירקות!)
    else if (_matchesAny(name, ['מרק בצל', 'מרק פטריות', 'מרק ירקות']) && currentCategory == 'ירקות') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // מרק היום עגבניות - שימורים (לא פירות!)
    else if (name.contains('מרק היום') && currentCategory == 'פירות') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // משחת שיניים - היגיינה אישית (לא אחר/פירות/משקאות!)
    else if (_matchesAny(name, ['משחת ', 'מש.שיניים', 'מש.אופטיק']) && _matchesAny(currentCategory, ['אחר', 'פירות', 'משקאות'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🦷';
    }
    // משחת אסטוניש ניקוי - מוצרי ניקיון (לא אחר!)
    else if (name.contains('אסטוניש') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // משטחי החתלה - מוצרי תינוקות (לא אחר!)
    else if (name.contains('החתלה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // משקה אלוורה/סאפה/ליצי - משקאות (לא פירות/ניקיון!)
    else if (_matchesAny(name, ['משקה אלוורה', 'משקה סאפה', 'משקה בטעם']) && _matchesAny(currentCategory, ['פירות', 'מוצרי ניקיון'])) {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // משקה שיבולת שועל - תחליפי חלב (לא תבלינים!)
    else if (_matchesAny(name, ['משקה שיבול', 'שיבולת שועל']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'תחליפי חלב';
      newIcon = '🥛';
    }
    // מתוק וקל - תבלינים ואפייה (לא אחר!)
    else if (name.contains('מתוק וקל') && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🍬';
    }
    // נייר טואלט - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['נ.טואלט', 'נייר טואלט']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧻';
    }
    // נאגטס ירקות - תחליפי בשר (לא אחר!)
    else if (name.contains('נאגטס ירקות') && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // נאצ'וס - ממתקים וחטיפים (לא מוצרי חלב!)
    else if (_matchesAny(name, ["נאצ'וס", 'נאטשוס', 'טורטייה']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🌮';
    }
    // נוזל רצפה/רצפות - מוצרי ניקיון (לא אחר/פירות!)
    else if (_matchesAny(name, ['נוזל רצפה', 'נוזל רצפות']) && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // נורדיק משקאות - משקאות (לא אחר!)
    else if (name.contains('נורדיק') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // נטפליקס & צ'יל (גלידה) - קפואים (לא אחר!)
    else if (name.contains('נטפליקס') && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // ניוואה קרם הגנה/SPF - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['ניוואה פרוטקט', 'SPF']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // נייטשר וואלי - ממתקים וחטיפים (לא אחר/תבלינים!)
    else if (_matchesAny(name, ['נייטשר ', "נייטשר'ס"]) && _matchesAny(currentCategory, ['אחר', 'תבלינים ואפייה'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // נקטר - משקאות (לא פירות!)
    else if (name.contains('נקטר') && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // נקניקיות צמחונית - תחליפי בשר (לא בשר ודגים!)
    else if (_matchesAny(name, ['צמחונית', 'צמחוני']) && currentCategory == 'בשר ודגים') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // נקנקיות מרגז - בשר ודגים (לא אחר!) - לא מרלבורו!
    else if (_matchesAny(name, ['נקנקיות', 'מרגז']) && currentCategory == 'אחר' && !name.contains('מרלבורו')) {
      newCategory = 'בשר ודגים';
      newIcon = '🌭';
    }
    // נתחוני סויה - תחליפי בשר (לא שמנים ורטבים!)
    else if (name.contains('נתחוני סויה') && currentCategory == 'שמנים ורטבים') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // ס.דליס/שוקולד - ממתקים וחטיפים (לא מוצרי חלב!)
    else if (_matchesAny(name, ['ס.דליס', 'דליס שוק']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // סאפה אלוורה - משקאות (לא פירות!)
    else if (name.contains('סאפה') && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // סבון מוצק - היגיינה אישית (לא מוצרי חלב!)
    else if (name.contains('סבון מוצק') && currentCategory == 'מוצרי חלב') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧼';
    }
    // סבן אפ - משקאות (לא אחר!)
    else if (name.contains('סבן אפ') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // סדיניה - מוצרי ניקיון (לא אחר!)
    else if (name.contains('סדיניה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧻';
    }
    // סוויטאנגו - ממרחים מתוקים (לא אחר!)
    else if (name.contains('סוויטאנגו') && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // סוכריות וורטר - ממתקים וחטיפים (לא תבלינים!)
    else if (_matchesAny(name, ['סוכ.וורטר', 'וורטר']) && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // סולטיד/סורבה גלידה - קפואים (לא אחר!)
    else if (_matchesAny(name, ['סולטיד', 'סורבה']) && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // סולת - תבלינים ואפייה (לא אחר!)
    else if (name.contains('סולת') && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🌾';
    }
    // סופגניה - מאפים (לא אחר!)
    else if (name.contains('סופגני') && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🍩';
    }
    // סחוג - שמנים ורטבים (לא אחר!)
    else if (name.contains('סחוג') && currentCategory == 'אחר') {
      newCategory = 'שמנים ורטבים';
      newIcon = '🌶️';
    }
    // סט לשירותים - מוצרי ניקיון (לא אחר!)
    else if (name.contains('סט לשירותים') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🚽';
    }
    // סילאן - ממרחים מתוקים (לא אחר!)
    else if (name.contains('סילאן') && currentCategory == 'אחר') {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // סינטבון - מוצרי ניקיון (לא אחר!)
    else if (name.contains('סינטבון') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // סינר לתינוק - מוצרי תינוקות (לא אחר!)
    else if (name.contains('סינר') && currentCategory == 'אחר') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // סירופ - משקאות (לא אחר/פירות!)
    else if (name.contains('סירופ') && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'משקאות';
      newIcon = '🍹';
    }
    // סירופ מלבי - תבלינים ואפייה (לא בשר!)
    else if (name.contains('סירופ מלבי') && currentCategory == 'בשר ודגים') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🍬';
    }
    // סכיני ונוס/גילוח - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['סכיני ונוס', 'סכין גילוח']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🪒';
    }
    // סלט איקרה - בשר ודגים (לא פירות!)
    else if (name.contains('איקרה') && currentCategory == 'פירות') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // סלט ביצים - סלטים מוכנים (לא מוצרי חלב!)
    else if (name.contains('סלט ביצים') && currentCategory == 'מוצרי חלב') {
      newCategory = 'סלטים מוכנים';
      newIcon = '🥗';
    }
    // סלט חציל בטעם כבד - סלטים מוכנים (לא בשר ודגים!)
    else if (_matchesAny(name, ['סלט חציל', 'בטעם כבד']) && currentCategory == 'בשר ודגים') {
      newCategory = 'סלטים מוכנים';
      newIcon = '🥗';
    }
    // סלט טורקי/קולסלאו/תפוא - סלטים מוכנים (לא אחר!)
    else if (_matchesAny(name, ['סלט טורקי', 'סלט קולסלאו', 'סלט תפו']) && currentCategory == 'אחר') {
      newCategory = 'סלטים מוכנים';
      newIcon = '🥗';
    }
    // סלים דליס - ממתקים וחטיפים (לא אחר!)
    else if (name.contains('סלים דליס') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // סלמי - בשר ודגים (לא אחר!)
    else if (name.contains('סלמי') && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🥩';
    }
    // סלק - ירקות (לא אחר!)
    else if (name.contains('סלק') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // סלרי - ירקות (לא אחר!)
    else if (name.contains('סלרי') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // סן פלגרינו - משקאות (לא אחר!)
    else if (name.contains('סן פלגרינו') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '💧';
    }
    // סנו אינסטלטור/מבריק רהיטים - מוצרי ניקיון (לא אחר!)
    else if (_matchesAny(name, ['סנו אינסטלטור', 'סנורהיט', 'מבריק רהיטים']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // סנסשיונל טחון צמחוני - תחליפי בשר (לא אחר!)
    else if (name.contains('סנסשיונל') && currentCategory == 'אחר') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }
    // ספרי הגנה/SPF - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['ספרי הגנה', 'spf']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // ספרי מסיר ריחות - מוצרי ניקיון (לא אחר!)
    else if (name.contains('ספרי מ.ריחות') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🌸';
    }
    // ספריי לשיער - היגיינה אישית (לא אחר!)
    else if (_matchesAny(name, ['ספריי חזק', 'ספריי סאיוס', 'ספריי לשיער']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '💇';
    }
    // ספרינג קרטון - משקאות (לא פירות!)
    else if (name.contains('ספרינג') && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // סרדינים - בשר ודגים (לא שמנים!)
    else if (name.contains('סרדינים') && currentCategory == 'שמנים ורטבים') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // סרום לשיער - היגיינה אישית (לא משקאות!)
    else if (name.contains('סרום') && currentCategory == 'משקאות') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // עגבניה/עגבניות - ירקות (לא פירות!)
    else if (_matchesAny(name, ['עגבניה', 'עגבניות']) && currentCategory == 'פירות') {
      newCategory = 'ירקות';
      newIcon = '🍅';
    }
    // עוגיות - ממתקים וחטיפים (לא אחר!)
    else if (_matchesAny(name, ['עוג.', 'עוגיו']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍪';
    }

    // === חוקים כלליים ===

    // 1. מסטיקים וסוכריות → ממתקים וחטיפים (רק מאחר!)
    else if (_matchesAny(name, ['אורביט', 'מסטיק', 'סוכריה', 'סוכריות', 'ופל', 'ביסלי', 'במבה', 'עוגיות', 'בונבון', 'לינדור', 'טופיפי', 'אפרופו']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // 2. אטריות ופסטה → אורז ופסטה
    else if (_matchesAny(name, ['אטריות', 'פסטה', 'ספגטי', 'פנה', 'לזניה', 'נודלס', 'קוסקוס', 'בורגול', 'קינואה']) && currentCategory == 'אחר') {
      newCategory = 'אורז ופסטה';
      newIcon = '🍚';
    }
    // 3. תבלינים ועשבי תיבול → תבלינים ואפייה
    else if (_matchesAny(name, ['אורגנו', 'בזיליקום', 'כוסברה', 'פטרוזיליה', 'שמיר', 'כמון', 'פפריקה', 'קינמון', 'זנגביל', 'כורכום', 'תבלין', 'בהרט']) && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // 4. רטבים ומיונז → שמנים ורטבים
    else if (_matchesAny(name, ['איולי', 'מיונז', 'קטשופ', 'חרדל', 'רוטב', 'טחינה', 'חומוס', 'סויה', 'ויניגרט', 'דרסינג', 'אלף האיים', 'אריסה']) && (currentCategory == 'אחר' || currentCategory == 'ירקות')) {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫒';
    }
    // 5. חומרי ניקוי → מוצרי ניקיון
    else if (_matchesAny(name, ['אוקסיגן', 'אקונומיקה', 'סבון', 'נוזל כלים', 'אבקת כביסה', 'מרכך', 'מטליות', 'ספוג', 'מגבונים לחים', 'אל כתמים', 'אנטרטיק', 'אקווה בלו', 'ריח כביסה', 'אירויקמקל']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // 6. קפה ותה
    else if (_matchesAny(name, ['קפה', 'נס קפה', 'אספרסו', 'תה ', 'תה ירוק', 'קפוצינו', 'אייס קפה', 'אייס קפוצ']) && currentCategory == 'אחר') {
      newCategory = 'קפה ותה';
      newIcon = '☕';
    }
    // 7. משקאות (כולל אלכוהול)
    else if (_matchesAny(name, ['קולה', 'ספרייט', 'פאנטה', 'מיץ', 'סודה', 'מים מינרל', 'בירה', 'יין', 'אנרגיה', 'משקה', 'סמירנוף', 'באדוויזר', 'לאגר', 'ריוחה', 'וודקה', 'ויסקי']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // 8. מוצרי תינוקות
    else if (_matchesAny(name, ['חיתול', 'מטרנה', 'סימילאק', 'תינוק', 'מוצץ', 'בקבוק תינוק']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // 9. היגיינה אישית
    else if (_matchesAny(name, ['שמפו', 'מרכך שיער', 'סבון גוף', 'דאודורנט', 'משחת שיניים', 'מברשת שיניים', 'קרם', 'תחבושות', 'טמפונים', 'אפטר שייב', 'אציטון', 'אקווה פרש', 'אקוהפרש']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // 10. מאפים
    else if (_matchesAny(name, ['לחם', 'פיתה', 'לחמניה', 'באגט', 'חלה', 'עוגה', 'קרואסון', 'מאפה']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // 11. קפואים
    else if (_matchesAny(name, ['קפוא', 'גלידה', 'פיצה קפואה', 'שניצל קפוא', 'ירקות קפואים']) && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // 12. שימורים
    else if (_matchesAny(name, ['שימור', 'טונה', 'תירס', 'אפונה', 'זיתים', 'מלפפון חמוץ', 'רסק עגבניות']) && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }
    // 13. בשר ודגים
    else if (_matchesAny(name, ['אנטריקוט', 'סטייק', 'שניצל', 'כבד', 'לב', 'קציצות', 'המבורגר', 'נקניק', 'פרגית', 'חזה עוף', 'כנפיים', 'שוקיים']) && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🥩';
    }
    // 14. מזון לחיות מחמד
    else if (_matchesAny(name, ['בונזו', 'פדיגרי', 'וויסקס', 'פריסקיז', 'חתולים', 'כלבים']) && currentCategory == 'אחר') {
      newCategory = 'מזון לחיות מחמד';
      newIcon = '🐾';
    }

    // ======= תיקונים נוספים - סריקה 9700+ =======

    // עוגות - מאפים (לא פירות/אחר!)
    else if (_matchesAny(name, ['עוגת דבש', 'עוגת היער', 'עוגת פס', 'עוגת קראנץ', 'עוגת גזר']) && _matchesAny(currentCategory, ['פירות', 'אחר'])) {
      newCategory = 'מאפים';
      newIcon = '🥧';
    }
    // קממבר - גבינה (לא משקאות!)
    else if (name.contains('קממבר') && currentCategory == 'משקאות') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // עלים לקרמשניט/בצק - מאפים
    else if (_matchesAny(name, ['עלים לקרמשניט', 'בצק פילו']) && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // עלית טורקי - קפה
    else if (name.contains('עלית') && name.contains('טורקי') && currentCategory == 'אחר') {
      newCategory = 'קפה ותה';
      newIcon = '☕';
    }
    // ענבים - פירות (לא בשר/אחר!)
    else if (_matchesAny(name, ['ענב ', 'ענבים']) && _matchesAny(currentCategory, ['בשר ודגים', 'אחר'])) {
      newCategory = 'פירות';
      newIcon = '🍇';
    }
    // ערגליות - חטיפים (לא פירות!)
    else if (name.contains('ערגליות') && currentCategory == 'פירות') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // פאנטה - משקאות (לא פירות!)
    else if (name.contains('פאנטה') && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🥤';
    }
    // פאפיה - פרי
    else if (name.contains('פאפיה') && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🍈';
    }
    // פאקט/סיגריות - אחר (לא בשר!)
    else if (_matchesAny(name, ['פאקט נקסט', 'iqos', 'heets']) && currentCategory == 'בשר ודגים') {
      newCategory = 'אחר';
      newIcon = '🚬';
    }
    // פדיאשור - מזון תינוקות (לא תבלינים!)
    else if (name.contains('פדיאשור') && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'מוצרי תינוקות';
      newIcon = '👶';
    }
    // פדים להסרת איפור - היגיינה
    else if (_matchesAny(name, ['פדים להסרת', 'פדים קוסמטיים']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '💆';
    }
    // פול ירוק מוקפא - קפואים
    else if (name.contains('פול') && name.contains('מוקפא') && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // פולי סויה - קטניות (לא שמנים!)
    else if (name.contains('פולי סויה') && currentCategory == 'שמנים ורטבים') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🫘';
    }
    // פומלה - פרי
    else if (name.contains('פומלה') && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🍊';
    }
    // פומפדור/תה - קפה ותה
    else if (_matchesAny(name, ['פומפדור', 'צ\'אי']) && currentCategory == 'אחר') {
      newCategory = 'קפה ותה';
      newIcon = '🍵';
    }
    // פטה כבשים - גבינה
    else if (name.contains('פטה') && name.contains('כבשים') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // פטה שקדים/טופו - תחליפי חלב
    else if (_matchesAny(name, ['פטה שקדים', 'פטה טופו']) && currentCategory == 'אחר') {
      newCategory = 'תחליפי חלב';
      newIcon = '🌱';
    }
    // פטריות - ירקות (לא בשר!)
    else if (name.contains('פטריות') && currentCategory == 'בשר ודגים') {
      newCategory = 'ירקות';
      newIcon = '🍄';
    }
    // פיוז טי - משקאות (לא פירות!)
    else if (name.contains('פיוז טי') && currentCategory == 'פירות') {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // פיור אקטיב - היגיינה אישית
    else if (name.contains('פיור אקטיב') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // פיטנס חטיף דגנים - חטיפים (לא בשר!)
    else if (_matchesAny(name, ['פיטנס חט', 'פיטנס פריכיות']) && currentCategory == 'בשר ודגים') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🥣';
    }
    // פיינט (גלידה) - קפואים (לא תבלינים!)
    else if (name.contains('פיינט') && _matchesAny(currentCategory, ['תבלינים ואפייה', 'ממתקים וחטיפים'])) {
      newCategory = 'קפואים';
      newIcon = '🍨';
    }
    // פיירי - ניקיון (לא אחר/קפה!)
    else if (name.contains('פיירי') && _matchesAny(currentCategory, ['אחר', 'קפה ותה'])) {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // פילה דג - קפואים (לא חלב!)
    else if (_matchesAny(name, ['פילה דג', 'פילה זהבון']) && currentCategory == 'מוצרי חלב') {
      newCategory = 'קפואים';
      newIcon = '🐟';
    }
    // פילה סלמון רוטב עגבניות - בשר ודגים (לא ירקות!)
    else if (name.contains('פילה סלמון') && currentCategory == 'ירקות') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // פילה מקרל - בשר ודגים (לא תבלינים!)
    else if (name.contains('פילה מקרל') && currentCategory == 'תבלינים ואפייה') {
      newCategory = 'בשר ודגים';
      newIcon = '🐟';
    }
    // פינוק שמפו/מרכך - היגיינה (לא ניקיון/אחר!)
    else if (name.contains('פינוק') && _matchesAny(currentCategory, ['מוצרי ניקיון', 'אחר'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // פיניש - ניקיון
    else if (name.contains('פיניש') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🧹';
    }
    // פיסטוק - אגוזים וגרעינים
    else if (name.contains('פיסטוק') && currentCategory == 'אחר') {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // פיצה - קפואים
    else if (name.contains('פיצה') && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🍕';
    }
    // פירורית - מאפים
    else if (name.contains('פירורית') && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🍞';
    }
    // פיתות - מאפים (לא פירות!)
    else if (name.contains('פיתות') && currentCategory == 'פירות') {
      newCategory = 'מאפים';
      newIcon = '🥙';
    }

    // ======= תיקונים נוספים - סריקה 10700+ =======

    // פלאפל - קפואים
    else if (name.contains('פלאפל') && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🧆';
    }
    // פלמוליב - סבון (לא חלב!)
    else if (name.contains('פלמוליב') && currentCategory == 'מוצרי חלב') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧼';
    }
    // פלפל שחור תבלין - תבלינים (לא ירקות!)
    else if (_matchesAny(name, ['פלפל שחור', 'פלפל לבן']) && name.contains('גרוס') && currentCategory == 'ירקות') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }
    // פנטן מרכך - היגיינה (לא ניקיון!)
    else if (name.contains('פנטן') && name.contains('מרכך') && currentCategory == 'מוצרי ניקיון') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // פניני בישום לכביסה - ניקיון (לא ירקות!)
    else if (name.contains('פניני בישום') && currentCategory == 'ירקות') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🌸';
    }
    // פסט/פסטרמה - בשר ודגים (לא אחר/ממרחים!)
    else if (_matchesAny(name, ['פסט ', 'פסטרמה']) && _matchesAny(currentCategory, ['אחר', 'ממרחים מתוקים'])) {
      newCategory = 'בשר ודגים';
      newIcon = '🥩';
    }
    // פסטו - שמנים ורטבים (לא חלב!) - רק אם זה רוטב, לא גבינה עם פסטו
    else if (name.contains('פסטו') && currentCategory == 'מוצרי חלב' && !name.contains('גאודה')) {
      newCategory = 'שמנים ורטבים';
      newIcon = '🫗';
    }
    // פקאן - אגוזים
    else if (name.contains('פקאן') && currentCategory == 'אחר') {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // פקורינו/פרובנציאל - גבינה
    else if (_matchesAny(name, ['פקורינו', 'פרובנציאל']) && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // פרוט&ווג - משקאות (לא חלב!)
    else if (name.contains('פרוט') && name.contains('ווג') && currentCategory == 'מוצרי חלב') {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // פרוסות נקניק - בשר (לא חלב!)
    else if (name.contains('נקניק') && currentCategory == 'מוצרי חלב') {
      newCategory = 'בשר ודגים';
      newIcon = '🌭';
    }
    // פריגורט - יוגורט (לא פירות/אחר!)
    else if (name.contains('פריגורט') && _matchesAny(currentCategory, ['פירות', 'אחר'])) {
      newCategory = 'מוצרי חלב';
      newIcon = '🥛';
    }
    // פריגת - משקאות (לא פירות/אחר!)
    else if (name.contains('פריגת') && _matchesAny(currentCategory, ['פירות', 'אחר'])) {
      newCategory = 'משקאות';
      newIcon = '🧃';
    }
    // פריכ/פריכונים/פריכיות - חטיפים (לא בשר/ירקות/שמנים!)
    else if (_matchesAny(name, ['פריכ.', 'פריכונים', 'פריכיות']) && _matchesAny(currentCategory, ['בשר ודגים', 'ירקות', 'שמנים ורטבים'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍘';
    }
    // פרינגלס - חטיפים (לא אחר/חלב!)
    else if (name.contains('פרינגלס') && _matchesAny(currentCategory, ['אחר', 'מוצרי חלב'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🥔';
    }
    // פריניר עגבניות - שימורים (לא חלב!)
    else if (name.contains('פריניר') && name.contains('עגב') && currentCategory == 'מוצרי חלב') {
      newCategory = 'שימורים';
      newIcon = '🥫';
    }

    // ======= תיקונים נוספים - סריקה 11500+ =======

    // פריפלצת/פרי לחטוף - ממתקים (לא פירות!)
    else if (_matchesAny(name, ['פריפלצת', 'פרי לחטוף']) && currentCategory == 'פירות') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // פריקה/בורגול - דגנים
    else if (_matchesAny(name, ['פריקה', 'בורגול']) && currentCategory == 'אחר') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🌾';
    }
    // פרל אנימה/יין מבעבע - משקאות
    else if (_matchesAny(name, ['פרל אנימה', 'מבעבע']) && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍾';
    }
    // פררו/שוקולד יוקרה - ממתקים
    else if (_matchesAny(name, ['פררו', 'גודייבה', 'לינדט', 'טובלרון']) && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // פשתן טחון - דגנים (לא היגיינה!)
    else if (name.contains('פשתן') && currentCategory == 'היגיינה אישית') {
      newCategory = 'קטניות ודגנים';
      newIcon = '🌾';
    }
    // פתיבר - ממתקים (לא תבלינים/חלב/אחר!)
    else if (name.contains('פתיבר') && _matchesAny(currentCategory, ['תבלינים ואפייה', 'מוצרי חלב', 'אחר'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // צ'ונגו/צונגו - קפואים (לא ירקות/אחר!)
    else if (_matchesAny(name, ["צ'ונגו", 'צונגו']) && _matchesAny(currentCategory, ['ירקות', 'אחר'])) {
      newCategory = 'קפואים';
      newIcon = '🍗';
    }
    // צ'ופסטיקס/צופסטיקס - חד פעמי
    else if (_matchesAny(name, ["צ'ופ-סטיקס", 'צופסטיקס', 'צפצפה']) && currentCategory == 'אחר') {
      newCategory = 'חד פעמי';
      newIcon = '🥢';
    }
    // צ'יטוס/צ'יפס - חטיפים (לא אחר/ירקות!)
    else if (_matchesAny(name, ["צ'יטוס", "צ'יפס", 'ציפס']) && _matchesAny(currentCategory, ['אחר', 'ירקות', 'אורז ופסטה'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🥔';
    }
    // ציפס בטטה קפוא - קפואים (לא ירקות!)
    else if (name.contains('ציפס') && name.contains('קפוא') && currentCategory == 'ירקות') {
      newCategory = 'קפואים';
      newIcon = '🍟';
    }
    // צבע לשיער - היגיינה
    else if (_matchesAny(name, ['צבע לשיער', 'צבע שיער', 'צבע סמי', 'צבע אינטנסיב']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '💇';
    }
    // צהובה הולנדית - גבינה
    else if (name.contains('צהובה') && name.contains('הולנדית') && currentCategory == 'אחר') {
      newCategory = 'מוצרי חלב';
      newIcon = '🧀';
    }
    // צוקטה שוקולד - ממתקים
    else if (name.contains('צוקטה') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }
    // ציזיקי לשתיה - משקאות
    else if (name.contains('ציזיקי') && name.contains('לשתיה') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🥛';
    }
    // צילי/צ'ילי - תבלינים
    else if (_matchesAny(name, ['צילי', "צ'ילי"]) && currentCategory == 'אחר') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🌶️';
    }
    // צימרוני אוזניים - היגיינה
    else if (name.contains('צימרוני') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧹';
    }
    // צלחות חד פעמי
    else if (_matchesAny(name, ['צלחות', 'צלחת']) && _matchesAny(currentCategory, ['אחר', 'היגיינה אישית'])) {
      newCategory = 'חד פעמי';
      newIcon = '🍽️';
    }
    // צנובר - אגוזים
    else if (name.contains('צנובר') && currentCategory == 'אחר') {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // צנצנת ממתקים - ממתקים (לא פירות/חלב!)
    else if (name.contains('צנצנת') && _matchesAny(name, ['בזוקה', 'מסטיק', 'סוכרייה', 'קוביות']) && _matchesAny(currentCategory, ['פירות', 'מוצרי חלב'])) {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍬';
    }
    // קרם ידיים - היגיינה
    else if (_matchesAny(name, ['ק.ידיים', 'קרם ידיים', 'קרם לידיים']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // קארע - ירקות
    else if (name.contains('קארע') && currentCategory == 'אחר') {
      newCategory = 'ירקות';
      newIcon = '🥬';
    }
    // קבב טבעוני - תחליפי בשר (לא ירקות!)
    else if (name.contains('קבב') && name.contains('טבעוני') && currentCategory == 'ירקות') {
      newCategory = 'תחליפי בשר';
      newIcon = '🌱';
    }

    // ======= תיקונים נוספים - סריקה 12100+ =======

    // קובה - קפואים (לא אחר!)
    else if (_matchesAny(name, ['קובה חמוסטה', 'קובה למרק', 'קובה סלק']) && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // קוביות לקדירה - בשר
    else if (name.contains('קוביות לקדירה') && currentCategory == 'אחר') {
      newCategory = 'בשר ודגים';
      newIcon = '🥩';
    }
    // קוטקס מגן תחתון - היגיינה
    else if (name.contains('קוטקס') && name.contains('מגן') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // קולגייט/קולגיט - היגיינה
    else if (_matchesAny(name, ['קולגייט', 'קולגיט']) && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🪥';
    }
    // קונפיטורה - ממרחים מתוקים (לא אחר/פירות!)
    else if (name.contains('קונפיטור') && _matchesAny(currentCategory, ['אחר', 'פירות'])) {
      newCategory = 'ממרחים מתוקים';
      newIcon = '🍯';
    }
    // קוקוס לשתיה - פירות
    else if (name.contains('קוקוס') && name.contains('לשתיה') && currentCategory == 'אחר') {
      newCategory = 'פירות';
      newIcon = '🥥';
    }
    // קוקטייל - משקאות
    else if (name.contains('קוקטייל') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍸';
    }
    // קורנטו גלידה - קפואים (לא חלב!)
    else if (name.contains('קורנטו') && currentCategory == 'מוצרי חלב') {
      newCategory = 'קפואים';
      newIcon = '🍦';
    }
    // קורני חטיפי - ממתקים
    else if (name.contains('קורני') && name.contains('חטיפ') && currentCategory == 'אחר') {
      newCategory = 'ממתקים וחטיפים';
      newIcon = '🍫';
    }

    // ======= תיקונים נוספים - סריקה 14500+ =======

    // שעועית עדינה קפואה - קפואים
    else if (name.contains('שעועית') && name.contains('עדינה') && currentCategory == 'אחר') {
      newCategory = 'קפואים';
      newIcon = '🧊';
    }
    // שערות קדאיף - מאפים
    else if (name.contains('קדאיף') && currentCategory == 'אחר') {
      newCategory = 'מאפים';
      newIcon = '🥖';
    }
    // שפירא בירה - משקאות
    else if (name.contains('שפירא') && currentCategory == 'אחר') {
      newCategory = 'משקאות';
      newIcon = '🍺';
    }
    // שקד טחון - אגוזים
    else if (name.contains('שקד') && name.contains('טחון') && currentCategory == 'אחר') {
      newCategory = 'אגוזים וגרעינים';
      newIcon = '🥜';
    }
    // שקדי מרק - מרקים מיובשים
    else if (name.contains('שקדי מרק') && currentCategory == 'אחר') {
      newCategory = 'שימורים';
      newIcon = '🍜';
    }
    // שקיות אשפה - ניקיון
    else if (name.contains('שקיות אשפה') && currentCategory == 'אחר') {
      newCategory = 'מוצרי ניקיון';
      newIcon = '🗑️';
    }
    // תבניות אלומיניום - חד פעמי (לא בשר/פירות!)
    else if (_matchesAny(name, ['ת.אלומיניום', 'תבנית אלומ', 'תבניות אלומ']) && _matchesAny(currentCategory, ['בשר ודגים', 'פירות'])) {
      newCategory = 'חד פעמי';
      newIcon = '🍽️';
    }
    // תחליב הגנה - היגיינה
    else if (name.contains('ת.הגנה') && currentCategory == 'אחר') {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // תחליב רחצה - היגיינה (לא חלב/תבלינים/אחר!)
    else if (_matchesAny(name, ['ת.רחצ', 'ת.רחצה', 'תחליב רחצ']) && _matchesAny(currentCategory, ['מוצרי חלב', 'תבלינים ואפייה', 'אחר'])) {
      newCategory = 'היגיינה אישית';
      newIcon = '🧴';
    }
    // תבלין גריל - תבלינים (לא בשר!) - רק אם זה מתחיל בתבלין
    else if (name.startsWith('תבלין') && currentCategory == 'בשר ודגים') {
      newCategory = 'תבלינים ואפייה';
      newIcon = '🧂';
    }

    // Apply fix if needed
    if (newCategory != null && newCategory != currentCategory) {
      final oldCategory = product['category'];
      product['category'] = newCategory;
      if (newIcon != null) {
        product['icon'] = newIcon;
      }
      fixedCount++;

      // Track changes
      final changeKey = '$oldCategory → $newCategory';
      categoryChanges[changeKey] = (categoryChanges[changeKey] ?? 0) + 1;

      // Print first few fixes
      if (fixedCount <= 20) {
        print('✅ "${product['name']}"');
        print('   $oldCategory → $newCategory\n');
      }
    }
  }

  if (fixedCount > 20) {
    print('   ... ועוד ${fixedCount - 20} תיקונים\n');
  }

  // Save the fixed file
  final encoder = JsonEncoder.withIndent('  ');
  final fixedJson = encoder.convert(products);
  await file.writeAsString(fixedJson);

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 סיכום שינויים:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  categoryChanges.forEach((change, count) {
    print('   $change: $count מוצרים');
  });
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('\n🎉 תוקנו $fixedCount מוצרים!');
  print('💾 הקובץ נשמר: ${file.path}');
}

bool _matchesAny(String text, List<String> keywords) {
  for (final keyword in keywords) {
    if (text.contains(keyword)) {
      return true;
    }
  }
  return false;
}
