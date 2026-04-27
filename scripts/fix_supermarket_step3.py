#!/usr/bin/env python3
"""
Step 3 — final categorization pass:
1. NEW categories: צעצועים ומתנות, אלקטרוניקה
2. Expanded keyword coverage for existing categories
3. Tightened rules with word-boundary checks to avoid false positives
"""
import json
import re
from collections import Counter

PATH = 'assets/data/list_types/supermarket.json'
BACKUP = PATH + '.bak3'


def has_any(name, words):
    return any(w in name for w in words)


def word_in(pattern, name):
    """Check if pattern appears as whole word (start, after space, or at end)."""
    return re.search(r'(^|\s)' + re.escape(pattern) + r'(\s|$|[,.])', name) is not None


def load():
    with open(PATH, encoding='utf-8') as f:
        return json.load(f)


def save(data):
    with open(PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    data = load()
    print(f"📂 נטען: {len(data)} פריטים\n")

    with open(BACKUP, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
    print(f"💾 גיבוי: {BACKUP}\n")

    # Each rule: (target_cat, condition, description)
    rules = [
        # NEW CATEGORY: צעצועים ומתנות (toys & gifts)
        ('צעצועים ומתנות',
         lambda n: has_any(n, ['צעצוע', 'פלסטלין', 'יום הולדת', 'שנה טובה',
                                'פוקימון', 'טרנספורמ', 'בארבי', 'לגו ',
                                'פזל ', 'פאזל', 'קלפי משחק', 'דומינו',
                                'בובת ', 'בובות ', 'מרוול ', 'דיסני ',
                                'ספיידרמן', 'ספיידר מן', 'סופרמן',
                                'פו הדב', 'הרפתקאות', 'רובוט ',
                                'שרביט פיות', 'שרשרת קסמים'])
                   or word_in('בלון', n) or word_in('בלונים', n)
                   or word_in('משחק', n) or word_in('משחקים', n)
                   or word_in('בובה', n) or word_in('ליצן', n)
                   or ('זיקוק' in n and 'נר זיקוק' not in n),
         'NEW צעצועים ומתנות'),

        # NEW CATEGORY: אלקטרוניקה
        ('אלקטרוניקה',
         lambda n: has_any(n, ['כבל USB', 'כבל HDMI', 'כבל טעינה',
                                'כבל מטען', 'כבל איפון', 'כבל אייפון',
                                'מטען טייפ', 'מטען קיר', 'מטען אייפון',
                                'מטען סלולרי', 'מטען ביתי', 'מטען אוטו',
                                'אוזניות ', 'רב שקע', 'חוט מאריך',
                                'סוללות ', 'סוללה ', 'סוללות,',
                                'נורת LED', 'נורה LED', 'נורת לד',
                                'פנס ', 'פנסי ', 'פנסים',
                                'רמקול ', 'רמקול,', 'בלוטוט', 'בלוטות',
                                'שקע חשמל', 'מאריך חשמל', 'שלט רחוק']),
         'NEW אלקטרוניקה'),

        # Expand: בשר ודגים
        ('בשר ודגים',
         lambda n: (has_any(n, ['פסטרמה', 'פסטראמה', 'סלמי ', 'סלמי,',
                                'צלי עגל', 'צלי כתף', 'בשר עגל',
                                'לשון עגל', 'שוק עגל', 'קבב',
                                'חזה עוף', 'שוקי עוף', 'ירך עוף',
                                'כרעי עוף', 'כבד עוף', 'עוף טחון',
                                'מושט ', 'דניס ', 'בורי ', 'אמנון ',
                                'פילה דג', 'פילה סלמון', 'פילה טונה',
                                'שוקיים ', 'נקניקיות', 'נתחי עגל',
                                'בקר טחון', 'בקר טרי'])
                   or word_in('פסטרמה', n))
                   and not has_any(n, ['גיבורי', 'גבורי', 'קדבורי',
                                        'קטבורי', 'פינסבורי',
                                        'אמנון ותמר']),
         '→ בשר ודגים: meat/fish keywords'),

        # Expand: אגוזים וגרעינים (standalone nuts, not butters)
        ('אגוזים וגרעינים',
         lambda n: (has_any(n, ['קשיו', 'פיסטוק', 'פקאן', 'אגוזי מלך',
                                 'אגוזי ברזיל', 'אגוזי לוז',
                                 'גרעיני חמנ', 'גרעיני דלעת', 'גרעינים שחור',
                                 'גרעינים מלוחים', 'שקדים קלוי', 'שקדים טבעי',
                                 'בוטנים קלוי', 'בוטנים מלוח', 'בוטנים אמריק'])
                   or word_in('בוטנים', n))
                   and not has_any(n, ['חמאת', 'ממרח', 'שוקולד', 'חטיף', 'במבה', 'דבש ']),
         '→ אגוזים וגרעינים'),

        # Expand: דגנים (oats and cereals)
        ('דגנים',
         lambda n: has_any(n, ['שיבולת שועל', 'קווקר', 'ברנפלקס', 'קורנפלקס',
                                'גרנולה', 'מוזלי', 'דייסת',
                                'חטיף גרנול', 'חטיף דגנים', 'דגני בוקר',
                                'צ'+"'"+'קס', 'צקס']),
         '→ דגנים'),

        # Expand: מוצרי חלב (more dairy keywords)
        ('מוצרי חלב',
         lambda n: (has_any(n, ['קוטג', 'מעדן ', 'מעדן,',
                                'שמנת חמוצה', 'שמנת מתוקה', 'שמנת להקצפה',
                                'מילקי ', 'מילקי,', 'דנונה ',
                                'גאודה ', 'גאודה,', 'עמק דק', 'עמק חצי',
                                'תנובה חלב', 'תנובה קוטג'])
                   or (word_in('גביע', n) and not has_any(n, ['נייר', 'פלסטיק',
                                                                'שקוף', 'חד פעמי',
                                                                'קידוש', 'הפתעה'])))
                   and not has_any(n, ['לכלב', 'לחתול', 'לחיה']),
         '→ מוצרי חלב: more dairy'),

        # Expand: לחם ומאפים (baked goods, excluding non-food items)
        ('לחם ומאפים',
         lambda n: has_any(n, ['לחמניות', 'לחמנייה', 'לחמנייות',
                                'מארז חלות', 'חלה ',
                                'פיתות', 'בייגל ', 'בייגלה', 'רוגלך', 'רוגעלך',
                                'קרקרים', 'עוגיות מרוקאיות',
                                'מאפה ', 'מאפה,', 'שטרודל', 'פשטידה'])
                   and not has_any(n, ['מפה', 'כיסוי', 'מגש', 'סכין',
                                        'צנצנת לעוגה', 'אחלה']),
         '→ לחם ומאפים: more bakery'),

        # Expand: מוצרי ניקיון (cleaning products)
        ('מוצרי ניקיון',
         lambda n: has_any(n, ['נוזל כלים', 'FIT נוזל',
                                'אבקת כביסה', 'ג"ל כביסה', 'ג\'ל כביסה',
                                'מרכך כביסה', 'מלבין ', 'אקונום',
                                'נוזל לאסלה', 'מסיר אבנית', 'פוליש',
                                'מבשם לבית', 'מבשם כביסה', 'מבשם אוויר',
                                'מבשם אויר', 'מטליות ', 'מטליות,',
                                'סבון כלים', 'אקונומיקה', 'חומר ניקוי']),
         '→ מוצרי ניקיון: cleaning'),

        # Expand: היגיינה אישית (personal care)
        ('היגיינה אישית',
         lambda n: has_any(n, ['תחבושות', 'טמפונים', 'משחת שיניים',
                                'מי פה ', 'מי פה,', 'שטיפת פה', 'חוט דנטלי',
                                'דיאודורנט', 'אפטר שייב', 'סכין גילוח',
                                'קונדומים', 'גרב ברכיים', 'ניילון רגליים',
                                'מבשם גוף', 'מבשם אישי']),
         '→ היגיינה אישית: body care'),

        # Expand: מוצרי בית (kitchen storage, foil, etc.)
        ('מוצרי בית',
         lambda n: has_any(n, ['רדידי אלומיניום', 'נייר כסף', 'נייר אפייה',
                                'ניילון נצמד', 'שקיות זיפ', 'שקיות זיפר',
                                'קופסאות אחסון', 'קופסאות אח',
                                'קופסת אחסון', 'מכסה לקופסא',
                                'מפה לכיסוי', 'מפה ', 'מפות',
                                'אלומיניום'])
                   and not has_any(n, ['רוטב', 'שוקולד', 'ממתק', 'גלידה']),
         '→ מוצרי בית: kitchen storage'),

        # Expand: קוסמטיקה וטיפוח (makeup + specific tools)
        ('קוסמטיקה וטיפוח',
         lambda n: has_any(n, ['שפתון', 'ליפ גלוס', 'ליפ בולם',
                                'מסקרה', 'צלליות', 'אייליינר', 'קו עיניים',
                                'פודרה', 'בלאש ', 'קונסילר', 'פאונדיישן',
                                'לק ', 'לק,', 'מסיר לק', 'הסרת לק',
                                'מסיכת פנים', 'קרם יום', 'קרם לילה',
                                'קרם עיניים', 'אודם ', 'אודם,',
                                'מסכת הזנה', 'מסכת פנים'])
                   and not has_any(n, ['רוטב', 'חלב ', 'גבינה',
                                        'חלק', 'סלק', 'מילק', 'טלק',
                                        'סילק', 'איטלק', 'מחלק', 'דולק',
                                        'הר אודם', 'סוביניון בלאש',
                                        'סוביניון בלאן בלאש']),
         '→ קוסמטיקה וטיפוח'),

        # Expand: תבלינים ואפייה (baking powders, sweeteners)
        ('תבלינים ואפייה',
         lambda n: has_any(n, ['אבקת אפייה', 'אבקת מרק', 'אבקת מאפה',
                                'שמרים יב', 'שמרים טריים', 'ממתיק ספלנדה',
                                'ממתיק נטו', 'ממתיק סוכרזית', 'ממתיק סטיויה',
                                'סוכר חום', 'סוכר כהה', 'סוכר לבן',
                                'שוקולד מריר', 'שוקולד מע'])
                   and not has_any(n, ['כביסה', 'כלים', 'שטיפה']),
         '→ תבלינים ואפייה'),

        # Expand: שימורים (canned goods)
        ('שימורים',
         lambda n: has_any(n, ['זיתים שחורים', 'זיתים ירוקים', 'זיתים קלמטה',
                                'זיתי טעם', 'מלפפון חמוץ', 'מלפפונים חמוצ',
                                'תירס מתוק', 'תירס בקופ', 'אפונה בקופסא',
                                'חמוצים מוכנים', 'חלבית מאיה', 'טונה בשמן',
                                'ארטישוקים', 'חומוס מוכן בקופ'])
                   and not has_any(n, ['צנצנת ריקה']),
         '→ שימורים'),

        # Expand: קפואים
        ('קפואים',
         lambda n: has_any(n, ['שניצל קפוא', 'פיצה קפואה', 'ירקות קפואים',
                                'בצק עלים', 'בצק פילו',
                                'אוכל מוכן קפוא', 'ארוחה קפואה',
                                'בורקס קפוא', 'מלווה קפוא']),
         '→ קפואים'),
    ]

    # Apply
    report = []
    for target, cond, label in rules:
        moved = 0
        for it in data:
            if it.get('category') == 'כללי' and cond(it.get('name', '')):
                it['category'] = target
                moved += 1
        if moved:
            report.append((label, moved))
            print(f"   {moved:5d}  {label}")

    total = sum(m for _, m in report)
    print(f"\n🏷️  סה\"כ סווגו מחדש: {total}")

    cats = Counter(it.get('category') for it in data)
    print(f"\n📊 תוצאות סופיות:")
    print(f"  פריטים: {len(data)}")
    print(f"  קטגוריות: {len(cats)}")
    for cat, cnt in cats.most_common():
        print(f"    {cat}: {cnt}")

    save(data)
    size_mb = len(json.dumps(data, ensure_ascii=False)) / 1024 / 1024
    print(f"\n✅ נשמר: {PATH} ({size_mb:.2f} MB)")


if __name__ == '__main__':
    main()
