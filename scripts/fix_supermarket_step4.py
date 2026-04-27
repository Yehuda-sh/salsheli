#!/usr/bin/env python3
"""
Step 4 — bigram-driven categorization:
Based on bigram analysis of remaining 24,864 generic items.
- Remove Rav-Kav value-reload entries (ערך צבור) — not products
- Expand coverage via multi-word patterns (deodorant brands, cleaning tabs,
  seasonal items, toys, pastries, meat cuts, seeds, etc.)
"""
import json
from collections import Counter

PATH = 'assets/data/list_types/supermarket.json'
BACKUP = PATH + '.bak4'


def has_any(name, words):
    return any(w in name for w in words)


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

    # Step A: Remove Rav-Kav value-reloads
    before = len(data)
    data = [it for it in data if 'ערך צבור' not in it.get('name', '')]
    removed = before - len(data)
    print(f"🚫 הוסרו 'ערך צבור' (טעינת רב-קו): {removed}\n")

    # Step B: re-categorize rules (applied only to 'כללי')
    rules = [
        # בשר ודגים — veal cuts with "עצם"/"טרי"
        ('בשר ודגים',
         lambda n: ('עגל טרי' in n or 'טרי-ישראל' in n or
                    (('עצם' in n) and has_any(n, ['עגל', 'בקר', 'כבש', 'עוף', 'גדי']))
                    or 'מרעה גולן' in n),
         '→ בשר ודגים: עגל/עצם/מרעה'),

        # לחם ומאפים — seasonal pastries
        ('לחם ומאפים',
         lambda n: has_any(n, ['אוזני המן', 'אזני המן', 'סופגניה', 'סופגניות',
                                'עוגיות פורים', 'ביסקוויטים', 'קישלעך']),
         '→ לחם ומאפים: מאפים עונתיים'),

        # תבלינים ואפייה — spice mixes
        ('תבלינים ואפייה',
         lambda n: has_any(n, ['תערובת תיבול', 'תערובת תבלינים', 'עשבי תיבול',
                                'תבלין ', 'תבלין,', 'בהרט', 'זעתר',
                                'תערובת להכנת', 'פפריקה']),
         '→ תבלינים ואפייה: תערובות'),

        # פירות יבשים
        ('פירות יבשים',
         lambda n: has_any(n, ['תמר מגהול', 'תמר מג', 'תמרים', 'פירות יבש',
                                'חמוציות יבש', 'צימוקים', 'משמשים יבש',
                                'אננס יבש', 'תאנים יבש', 'אפרסקים יבש',
                                'תות יבש', 'בננה יבש']),
         '→ פירות יבשים'),

        # אגוזים וגרעינים — chia, flax, etc.
        ('אגוזים וגרעינים',
         lambda n: has_any(n, ['זרעי ציה', 'זרעי פשתן', 'זרעי דלעת',
                                'זרעי חמנ', 'זרעי חמניה', 'זרעי שומשום']),
         '→ אגוזים וגרעינים: זרעים'),

        # היגיינה אישית — deodorants (big hit) + shampoos + hygiene
        ('היגיינה אישית',
         lambda n: has_any(n, ['ספיד סטיק', 'ליידי ספיד', 'רול און', 'רול-און',
                                'האן ', 'אקס ', 'דאב ', 'רקסונה',
                                'אנד שולדרס', 'הד אנד', 'האד אנד',
                                'אורל בי', 'אורל-בי', 'קולגייט', 'סנסודיין',
                                'מגן תחתון', 'מגני תחתון', 'אלוויז',
                                'טמפקס', 'קוטקס', 'קרלין',
                                'ממחטות אף', 'ממחטות בד',
                                'חוטי ציפורן', 'גוזז ציפורניים',
                                'סכין גילוח', 'מחסנית גילוח',
                                'ג\'ילט', 'ונוס'])
                   and not has_any(n, ['גלידה', 'שוקולד', 'ממרח',
                                       'אג\'אקס', 'אזאקס']),
         '→ היגיינה אישית: דיאודורנט/שמפו/היגיינה'),

        # קוסמטיקה וטיפוח — sunscreens
        ('קוסמטיקה וטיפוח',
         lambda n: has_any(n, ['תחליב הגנה', 'תכשיר הגנה', 'קרם הגנה',
                                'ספריי הגנה לש', 'SPF',
                                'מסיכת פנים', 'מסכת לחות', 'סרום פנים',
                                'קרם עיניים', 'קרם עיני', 'טונר ',
                                'מי פנים', 'ניקוי פנים']),
         '→ קוסמטיקה וטיפוח: הגנה/פנים'),

        # סיגריות וטבק — Pall Mall (missed before)
        ('סיגריות וטבק',
         lambda n: has_any(n, ['פאל מאל', 'PALL MALL', 'רוטמנס',
                                'נובלס', 'ROTHMANS', 'SALEM']),
         '→ סיגריות וטבק: מותגים נוספים'),

        # מוצרי ניקיון — laundry clips, dishwasher tabs, steel wool, floor
        ('מוצרי ניקיון',
         lambda n: has_any(n, ['אטבי כביסה', 'אטבים', 'טבליות למדיח',
                                'טבליות מדיח', 'נוזל רצפות', 'נוזל לרצפה',
                                'נוזל לפרקט', 'נוזל לחלונות',
                                'צמר פלדה', 'ספוג ברזל', 'ספוגי מטבח',
                                'מפיץ ריח', 'מפיצי ריח',
                                'שקיות הקפאה', 'שקיות להקפ',
                                'מגבות נייר', 'מגבת נייר',
                                'רב תכליתי נוזל', 'חומר לניקוי',
                                'נוזל לכלים', 'סבון כלים',
                                'אבקת כלים'])
                   and not has_any(n, ['שוקולד', 'ממרח', 'סכין']),
         '→ מוצרי ניקיון'),

        # צעצועים ומתנות — characters, swim toys, purim gifts
        ('צעצועים ומתנות',
         lambda n: has_any(n, ['משלוח מנות', 'ביצת הפתעה', 'הלו קיטי',
                                'מיקי מאוס', 'מיני מאוס', 'חד קרן',
                                'גלגל ים', 'כדור ים', 'מזרון ים', 'מזרן ים',
                                'סביבון', 'רעשן', 'מסיכת פורים',
                                'מסיכה ל', 'כתר ', 'כתר,',
                                'LOL', 'טרול ', 'אולאף',
                                'פרזנט', 'מתנת ', 'שק מתנ',
                                'באלון', 'בלוני'])
                   and not has_any(n, ['קפה', 'שוקולד', 'רוטב', 'חלב', 'גבינה',
                                       'סט סכו"ם', 'פמוט כתר', 'חלת בריוש',
                                       'קינוחית כתר', 'מסיכה ללא']),
         '→ צעצועים ומתנות: דמויות/ים/פורים'),

        # מוצרי בית — cutting boards, tablecloths, candles, storage
        ('מוצרי בית',
         lambda n: has_any(n, ['קרש חיתוך', 'מפת שולחן', 'מפות שולחן',
                                'מיכל אחסון', 'מיכלי אחסון',
                                'סט קופסאות', 'קופסאות אחסון',
                                'סט כפיות', 'סט כפות', 'סט סכינים',
                                'סט מגשים', 'סט קערות',
                                'סט כלי', 'מחזיק', 'מחזיקי',
                                'צלחת במבוק', 'קעריות', 'קעריה',
                                'ויליג קאנדל', 'יאנקי קאנדל',
                                'כלי פלסטיק', 'כלים חד',
                                'נרות שב', 'נר שב',
                                'תיבת אחסון', 'פינג אן'])
                   and not has_any(n, ['גבינה', 'חלב ', 'בשר ', 'שוקולד', 'רוטב']),
         '→ מוצרי בית: כלים/אחסון'),

        # ממתקים וחטיפים — chips, soft candies
        ('ממתקים וחטיפים',
         lambda n: has_any(n, ['ממתק מוקצף', 'פתי בר', 'מרשמלו',
                                'סלילים טופי', 'ציפס קלאסי', 'ציפס בטעם',
                                'קרמל מלוח', 'כדורי שוקולד',
                                'כדורי אנרגיה', 'חלבה', 'חלווה',
                                'דברים קטנים', 'קראנץ'])
                   and not has_any(n, ['גלידה', 'עוגה']),
         '→ ממתקים וחטיפים: סוגים נוספים'),

        # שימורים — seaweed, bamboo shoots, pickles
        ('שימורים',
         lambda n: has_any(n, ['אצות ים', 'אצות נורי', 'חלזונות',
                                'נבטי במבוק', 'ערמונים בקופסא',
                                'תבלינים חמוצים',
                                'זית ממולא', 'זיתים ממולא',
                                'עלי גפן ממולא', 'ארטישוק ממולא']),
         '→ שימורים: אצות/חמוצים'),

        # דגנים — crispies, oat products
        ('דגנים',
         lambda n: has_any(n, ['פריכיות כוסמת', 'פריכיות אורז',
                                'שיבולת שוע', 'קוואקר', 'דייסת שיבול',
                                'דייסה לתינוק', 'פצפוצי אורז',
                                'פצפוצי שוקולד', 'גריסי פנינה']),
         '→ דגנים'),
    ]

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
