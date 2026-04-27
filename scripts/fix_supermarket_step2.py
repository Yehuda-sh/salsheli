#!/usr/bin/env python3
"""
Step 2 — categorization expansion:
1. Remove non-product entries (transit passes: 'חופשי שנתי/יומי/סמסטר', מנויי תקופתי)
2. Add NEW categories: אלכוהול, סיגריות וטבק, תוספי תזונה
3. Expand keywords so remaining 'כללי' items route to existing categories
4. Tightened rules with explicit exclusions for common false positives
"""
import json
import re
from collections import Counter

PATH = 'assets/data/list_types/supermarket.json'
BACKUP = PATH + '.bak2'


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
    print(f"📂 נטען: {len(data)} פריטים")

    # Backup
    with open(BACKUP, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
    print(f"💾 גיבוי: {BACKUP}")

    # ======== STEP A: Remove non-product entries ========
    before = len(data)
    def is_transit(name):
        return ('חופשי' in name and has_any(name, ['שנתי', 'שבועי', 'יומי', 'חודשי', 'סמסטר'])) \
            or ('מנויי' in name and 'תקופתי' in name)
    data = [it for it in data if not is_transit(it.get('name', ''))]
    removed_transit = before - len(data)
    print(f"🚫 הוסרו מנויי תחבורה: {removed_transit}")

    before = len(data)
    def is_noise(name):
        n = name.strip()
        return len(n) < 3 or re.match(r'^\d{3,}\s', n) is not None
    data = [it for it in data if not is_noise(it.get('name', ''))]
    removed_noise = before - len(data)
    print(f"🚫 הוסרו רשומות רעש: {removed_noise}")

    # ======== STEP B: Ordered re-categorization rules ========
    # Each rule only applies to items currently 'כללי'.
    # Order matters: more specific rules first.
    rules = [
        # NEW CATEGORY: אלכוהול (exclude glasses/accessories)
        # NOTE on substring traps:
        #   'מרלו' alone matches 'מרלוזה' (fish) / 'מרלוג' (logistics) — use ' מרלו'/'מרלו ' anchored variants
        #   'רוזה ' alone matches 'ארוזה ' (packaged) — require leading space
        #   'ליקר' alone matches 'בליקר' (chocolate) / 'סליקר' (mascara brush) — anchor it
        ('אלכוהול',
         lambda n: has_any(n, [
             'וודקה', 'ויסקי', 'וויסקי', 'קוניאק', 'ברנדי', 'טקילה',
             ' ליקר', 'ליקר ', 'ליקר,', 'אראק', 'ערק ', "ג'ין ", "ג'ין,",
             'VSOP', 'XO ', 'ABSOLUT', 'JACK DANIEL', 'CHIVAS',
             'SMIRNOFF', 'JOHNNIE WALKER', 'GLENFIDDICH', 'BACARDI',
             'ג&#039;יימסון',
             'שמפניה', 'פרוסקו', ' מרלו', 'מרלו ', 'מרלו,',
             'סוביניון', 'שרדונה',
             'קברנה', 'מוסקטו', ' רוזה ', ' רוזה,',
             "סאווין'", 'ערקים',
         ]) and not has_any(n, ['כוס ', 'כוסיות', 'כוסות', 'ספל ', 'כד ', 'קנקן', 'מגש',
                                 'בקבוק ריק', 'פקק', 'מברשת', 'בליקר', 'סליקר',
                                 'מרלוז', 'מרלוג', 'ארוזה']),
         'NEW אלכוהול'),

        # NEW CATEGORY: סיגריות וטבק
        ('סיגריות וטבק',
         lambda n: has_any(n, [
             'סיגריה', 'סיגרי', 'סיגר ', 'סיגר,',
             'טבק', 'מקטרת', 'נרגילה', 'נארגיל',
             'MARLBORO', 'WINSTON', 'DUNHILL', 'PARLIAMENT',
             'LUCKY STRIKE', 'CAMEL', 'KENT ', 'KENT,',
             'L&M', 'LD CLUB', 'BLACK DEVIL',
             "אלקטרונית",  # סיגריה אלקטרונית
         ]),
         'NEW סיגריות וטבק'),

        # NEW CATEGORY: תוספי תזונה (conservative — require dosage form)
        ('תוספי תזונה',
         lambda n: (has_any(n, ['ויטמין', 'מולטי-ויטמין', 'מולטי ויטמין', 'אומגה 3', 'אומגה-3',
                                 'קולגן ', 'קולגן,', 'פרוביוטיק', 'מגנזיום', 'סידן ו',
                                 'אבץ ', 'אבץ,', 'B12', 'D3 ', "ג'לי רויאל", 'משמרת',
                                 'ליפוזומלי', 'פיטוסטרולים'])
                   and has_any(n, ['כמוסות', 'טבליות', 'כדורי', 'תרסיס', 'מ"ג', 'מ״ג',
                                    'טיפות', 'אמפולות', 'סירופ', 'אבקת פרוטאין', 'שייק חלבון']))
                   or has_any(n, ['מולטי ויטמין', 'מולטי-ויטמין', 'פרוביוטיק']),
         'NEW תוספי תזונה'),

        # Route to existing: שמנים ורטבים
        ('שמנים ורטבים',
         lambda n: 'רוטב' in n,
         '→ שמנים ורטבים: רוטב'),

        # Route to existing: מוצרי חלב (construct state "גבינת")
        ('מוצרי חלב',
         lambda n: 'גבינת' in n,
         '→ מוצרי חלב: גבינת'),

        # Route to existing: לחם ומאפים (cakes, but NOT cheesecake)
        ('לחם ומאפים',
         lambda n: 'עוגת' in n and 'גבינה' not in n,
         '→ לחם ומאפים: עוגת (not גבינה)'),

        # Route to existing: ממרחים מתוקים — ממרח (most are sweet)
        ('ממרחים מתוקים',
         lambda n: 'ממרח' in n,
         '→ ממרחים מתוקים: ממרח'),

        # Route to existing: ממרחים מתוקים — דבש (exclude sauce/cereal contexts)
        ('ממרחים מתוקים',
         lambda n: 'דבש' in n
                   and not has_any(n, ['רוטב', 'פרינגלס', "צ'קס", 'קורן פלקס',
                                        'דגני', 'חטיף', 'קינמון וד', 'מיץ ',
                                        'גרנולה', "מנגו'", 'פצפוצי', 'ברנדי',
                                        'בירה', 'יין ', 'כוס']),
         '→ ממרחים מתוקים: דבש'),

        # Route to existing: מוצרי בית — kitchen goods
        # NOTE on substring traps:
        #   'מגש ' alone matches food-trays like 'מגש פירות יבשים' (the food itself)
        ('מוצרי בית',
         lambda n: has_any(n, ['נירוסטה', 'פיירקס', 'טפלון', 'כלי אפייה',
                                'מחבת ', 'סיר ', 'מגש ', 'קערה ', 'קערת ',
                                'מסננת', 'מטרפה', 'מצקת', 'מיחם ', 'מיחם,',
                                'סוטאז', 'סוטז', 'סירים', 'מחבתות',
                                'בקבוק טריטן', 'בקבוק ילדים',
                                'סכום חד פעמי', 'סכו״ם', 'סכום ', 'סכום,'])
                   and not has_any(n, ['רוטב', 'ממרח', 'קפה', 'שוקולד',
                                        'מגש פירות', 'מגש ירק', 'מגש בשר',
                                        'מגש גבינות', 'מגש סלט', 'מגש דגים',
                                        'מגש עוף', 'מגש ביצ']),
         '→ מוצרי בית: כלי מטבח'),

        # Route to existing: מוצרי בית — disposables (food-shape exclusion)
        ('מוצרי בית',
         lambda n: has_any(n, ['כוס חד', 'צלחת חד', 'כפפות ניטרו', 'כפפות לטקס',
                                'כפפות ויניל', 'שקיות זיפר', 'שקיות אשפה',
                                'שקיות להקפאה', 'נייר סופג', 'מפיות', 'שקיות שרוך',
                                'מגבוני בד', 'מגבונים לתינוק'])
                   and not has_any(n, ['שקד', 'אגוז', 'בוטן']),
         '→ מוצרי בית: חד פעמי'),

        # Route to existing: מוצרי בית — candles (explicit patterns only)
        ('מוצרי בית',
         lambda n: 'נרות' in n or 'נר הבדלה' in n or 'נר נשמה' in n
                   or re.search(r'(^|\s)נר\s', n) is not None,
         '→ מוצרי בית: נרות'),

        # Route to existing: היגיינה אישית — spray products (cosmetics only)
        ('היגיינה אישית',
         lambda n: 'ספריי' in n
                   and has_any(n, ['גילוח', 'אפטר', 'דאודורנט', 'בושם', 'איפור',
                                    'שיער', 'לשיער', 'לגוף', 'לפנים', 'הגנה',
                                    'שמש', 'חיטוי', 'מסקרה', 'אקס ', 'דאב',
                                    'האן ', 'רקסונה', 'אולטרסול', 'לוריאל'])
                   and not has_any(n, ['אבק', 'ניקוי', 'תיקון פנצ']),
         '→ היגיינה אישית: ספריי קוסמטי'),

        # Route to existing: מוצרי ניקיון — cleaning sprays
        ('מוצרי ניקיון',
         lambda n: 'ספריי' in n and has_any(n, ['אבק', 'ניקוי', 'עמילן', 'מסיר', 'דוחה']),
         '→ מוצרי ניקיון: ספריי ניקוי'),

        # Route to existing: ממתקים וחטיפים — specific candy brands (bring a few more in)
        ('ממתקים וחטיפים',
         lambda n: has_any(n, ['מלטיזרס', 'סניקרס', 'קיט קט', 'קיטקט', 'מארס ',
                                'מילקיבר', 'טוויקס', 'קרקר סוכר', 'הייבי',
                                'קינדר ', 'כיף כף', 'במבה אישית']),
         '→ ממתקים וחטיפים: מותגים'),

        # Route to existing: משקאות — additional drink keywords
        # NOTE on substring traps:
        #   'פיוז' alone matches 'פיוז\'ן/פיוזן' (Gillette razors) — use 'פיוז ' / 'פיוז-' anchored
        #   'נקטר' alone matches 'נקטרינה' (nectarine fruit) — use 'נקטר ' anchored
        #   'תפוגן' is a CHIPS brand, NOT a drink — keyword removed entirely
        ('משקאות',
         lambda n: has_any(n, ['סבן אפ', 'סבנ אפ', 'סבנ-אפ',
                                'פריגת', 'סן פלגרינו', 'סן-פלגרינו',
                                'שוקו ', 'שוקו,', 'שטראוס שוקו', 'אייס קפה',
                                'נקטר ', 'נקטר,', 'פיוז ', 'פיוז-', 'פיוזטי',
                                'RED BULL', 'רד בול'])
                   and not has_any(n, ['ממרח', 'גלידה', 'פיוזן', "פיוז'ן",
                                        'פיוז\'ן', 'פיוז`ן', 'נקטרינ', 'תפוגן',
                                        'סכין', 'סכיני', 'גילט', "ג'ילט",
                                        'דיפיוז', 'דפיוז']),
         '→ משקאות: מותגים'),

        # Route to existing: מזון לחיות מחמד
        ('מזון לחיות מחמד',
         lambda n: has_any(n, ['אוכל לחתול', 'אוכל לכלב', 'מזון חתול',
                                'מזון כלב', 'מזון לחתולים', 'מזון לכלבים',
                                'פדיגרי', 'וויסקאס', 'פרופלן', 'רויאל קנין',
                                'פריסקיז', 'פטרומיה', 'קיטי קט']),
         '→ מזון לחיות מחמד: מותגים'),
    ]

    # Apply rules
    report = []
    for target_cat, cond, label in rules:
        moved = 0
        for it in data:
            if it.get('category') == 'כללי' and cond(it.get('name', '')):
                it['category'] = target_cat
                moved += 1
        if moved:
            report.append((label, moved))
            print(f"   {moved:5d}  {label}")

    total_moved = sum(m for _, m in report)
    print(f"\n🏷️  סה\"כ סווגו מחדש: {total_moved}")

    # ======== Final stats ========
    cats = Counter(it.get('category', 'כללי') for it in data)
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
