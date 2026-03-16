#!/usr/bin/env python3
"""
Fix supermarket.json:
1. Auto-categorize 5,043 uncategorized items by keyword matching
2. Merge duplicate category names
3. Remove duplicate items (same name + brand)
4. Clean brand placeholders ("---" → null)
5. Flag suspicious prices (>₪500)
"""

import json
import re
from collections import Counter

INPUT = 'assets/data/list_types/supermarket.json'
OUTPUT = INPUT  # overwrite
BACKUP = INPUT + '.bak'

# =============================================================================
# Category keyword mapping (Hebrew)
# =============================================================================
CATEGORY_KEYWORDS = {
    'מוצרי חלב': [
        'חלב', 'גבינה', 'יוגורט', 'שמנת', 'קוטג', 'לבן', 'קפיר',
        'מוצרלה', 'פרמזן', 'צהובה', 'בולגרית', 'עמק', 'גד',
        'דניאל', 'מילקי', 'פודינג', 'אשל', 'תנובה',
    ],
    'לחם ומאפים': [
        'לחם', 'פיתה', 'טורטיה', 'באגט', 'חלה', 'לחמניה', 'מאפה',
        'קרואסון', 'בייגל', 'פוקצ\'ה', 'לחמנייה', 'לפה', 'עוגיה',
        'עוגיות', 'ביסקוויט', 'וופל', 'קרקר',
    ],
    'פירות וירקות': [
        'תפוח', 'בננה', 'תפוז', 'לימון', 'אבוקדו', 'מנגו', 'ענב',
        'אפרסק', 'שזיף', 'אגס', 'רימון', 'קיווי', 'פומלה',
        'עגבני', 'מלפפון', 'גזר', 'בצל', 'שום', 'פלפל', 'חציל',
        'קישוא', 'ברוקולי', 'כרובית', 'חסה', 'סלרי', 'פטרוזיליה',
        'כוסברה', 'שמיר', 'נענע', 'בזיליקום', 'תרד', 'כרוב',
        'סלק', 'דלעת', 'בטטה', 'צנונית', 'ירקות', 'פירות',
        'אבטיח', 'מלון', 'תות', 'אוכמניות', 'פטל',
    ],
    'בשר ודגים': [
        'עוף', 'חזה', 'כרעיים', 'שניצל', 'בקר', 'טחון', 'סטייק',
        'נקניק', 'נקניקיות', 'קבב', 'המבורגר', 'כבד', 'אנטריקוט',
        'פילה', 'סלמון', 'טונה', 'דג', 'דגים', 'שרימפס', 'בורי',
        'אמנון', 'דניס', 'פורל', 'מוסר', 'טילפיה',
        'הודו', 'כבש', 'צלעות',
    ],
    'ממתקים וחטיפים': [
        'שוקולד', 'במבה', 'ביסלי', 'חטיף', 'סוכריה', 'גומי',
        'מסטיק', 'פופקורן', 'אגוז', 'גלידה', 'ופל', 'עוגה',
        'טופי', 'חלווה', 'מרשמלו', 'סנאק', 'דורי',
    ],
    'משקאות': [
        'מיץ', 'מים', 'קולה', 'ספרייט', 'פאנטה', 'סודה', 'טוניק',
        'לימונדה', 'אנרגיה', 'סירופ', 'נקטר', 'פריגת', 'משקה',
        'בירה', 'יין', 'וודקה', 'וויסקי', 'ג\'ין',
    ],
    'קפה ותה': [
        'קפה', 'נס קפה', 'אספרסו', 'קפסולה', 'תה', 'תה ירוק',
        'חליטה', 'קקאו', 'שוקו', 'נסקפה',
    ],
    'אורז ופסטה': [
        'אורז', 'פסטה', 'ספגטי', 'פנה', 'נודלס', 'קוסקוס',
        'בורגול', 'קינואה', 'אטריות', 'לזניה', 'רביולי', 'טורטליני',
    ],
    'שימורים': [
        'שימור', 'טונה בשמן', 'תירס', 'זיתים', 'מלפפון חמוץ',
        'רסק', 'רוטב עגבניות', 'שעועית', 'חומוס', 'טחינה',
        'פול', 'עדשים', 'אפונה', 'חמוצים',
    ],
    'תבלינים ואפייה': [
        'תבלין', 'מלח', 'פלפל שחור', 'פפריקה', 'כורכום', 'קינמון',
        'קמח', 'סוכר', 'שמרים', 'אבקת אפייה', 'וניל', 'קוקוס',
        'שקדים', 'אגוזי מלך', 'פיסטוק', 'שומשום', 'חרדל',
        'מיונז', 'קטשופ', 'סויה', 'חומץ', 'שמן זית', 'שמן',
    ],
    'מוצרי ניקיון': [
        'אקונומיקה', 'סבון כלים', 'אבקת כביסה', 'מרכך', 'מטלית',
        'ספוג', 'שקיות אשפה', 'נייר סופג', 'נייר טואלט', 'מגבון',
        'ניקוי', 'דטרגנט', 'אל כתמים', 'מפיות', 'חד פעמי',
        'כוסות', 'צלחות', 'סכום', 'מזלג', 'כף', 'סכין חד',
        'פולישר', 'לניקוי', 'מנקה', 'בלנק', 'סנו',
    ],
    'היגיינה אישית': [
        'שמפו', 'מרכך שיער', 'סבון', 'דאודורנט', 'משחת שיניים',
        'מברשת שיניים', 'קרם', 'תחבושת', 'טמפון', 'חיתול',
        'מגבונים', 'ג\'ל רחצה', 'קצף גילוח', 'סכין גילוח',
        'צמר גפן', 'קונדום', 'לק', 'איפור', 'מסקרה', 'שפתון',
        'בושם', 'קרם הגנה', 'קרם ידיים', 'קרם גוף', 'גילוח',
        'לשיער', 'לגוף', 'לפנים', 'רחצה',
    ],
    'מוצרי תינוקות': [
        'תינוק', 'חיתול', 'מטרנה', 'סימילאק', 'מגבון', 'מוצץ',
        'בקבוק תינוק', 'דייסה', 'מזון תינוקות',
    ],
    'קפואים': [
        'קפוא', 'פיצה קפואה', 'שניצל קפוא', 'ירקות קפואים',
        'בצק', 'בורקס', 'מאפה קפוא', 'גלידה', 'ארטיק',
    ],
    'מזון לחיות מחמד': [
        'כלב', 'חתול', 'מזון לחתולים', 'מזון לכלבים',
        'חיות מחמד', 'פט',
    ],
}

# Category merges (old → new)
CATEGORY_MERGES = {
    'ניקיון': 'מוצרי ניקיון',
    'לחם ומאפים': 'מאפים',  # keep 'מאפים' (33 items) as the main
    'חד פעמי': 'מוצרי ניקיון',
    'פיצוחים וקטניות': 'אגוזים וגרעינים',
    'משקאות אלכוהוליים': 'משקאות',
}
# Actually let's keep 'לחם ומאפים' as the canonical name
CATEGORY_MERGES = {
    'ניקיון': 'מוצרי ניקיון',
    'מאפים': 'לחם ומאפים',
    'חד פעמי': 'מוצרי ניקיון',
    'פיצוחים וקטניות': 'אגוזים וגרעינים',
    'משקאות אלכוהוליים': 'משקאות',
}


def categorize_item(item):
    """Try to assign a category based on item name keywords."""
    name = item.get('name', '').lower()
    
    for category, keywords in CATEGORY_KEYWORDS.items():
        for keyword in keywords:
            if keyword in name:
                return category
    return None


def main():
    with open(INPUT, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f"📂 נטען: {len(data)} פריטים")

    # === Step 0: Backup ===
    with open(BACKUP, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
    print(f"💾 גיבוי: {BACKUP}")

    # === Step 1: Merge categories ===
    merge_count = 0
    for item in data:
        cat = item.get('category')
        if cat in CATEGORY_MERGES:
            item['category'] = CATEGORY_MERGES[cat]
            merge_count += 1
    print(f"🔀 מיזוג קטגוריות: {merge_count} פריטים")

    # === Step 2: Auto-categorize uncategorized items ===
    uncategorized_before = sum(1 for item in data if not item.get('category'))
    categorized = 0
    for item in data:
        if not item.get('category') or item['category'] == 'כללי':
            new_cat = categorize_item(item)
            if new_cat:
                item['category'] = new_cat
                categorized += 1
    uncategorized_after = sum(1 for item in data if not item.get('category'))
    print(f"🏷️ קטגוריזציה: {categorized} פריטים ({uncategorized_before} → {uncategorized_after} ללא קטגוריה)")

    # === Step 3: Assign 'כללי' to remaining uncategorized ===
    remaining = 0
    for item in data:
        if not item.get('category'):
            item['category'] = 'כללי'
            remaining += 1
    print(f"📦 'כללי' לשאר: {remaining} פריטים")

    # === Step 4: Clean brand placeholders ===
    brand_cleaned = 0
    for item in data:
        if item.get('brand') in ('---', '', None):
            item['brand'] = None
            brand_cleaned += 1
    print(f"🏭 ניקוי מותגים: {brand_cleaned} (--- → null)")

    # === Step 5: Remove exact duplicates (same name + brand) ===
    seen = set()
    unique = []
    dupes_removed = 0
    for item in data:
        key = (item['name'], item.get('brand'))
        if key in seen:
            dupes_removed += 1
        else:
            seen.add(key)
            unique.append(item)
    data = unique
    print(f"🗑️ כפילויות שהוסרו: {dupes_removed}")

    # === Step 6: Flag suspicious prices ===
    suspicious = [(item['name'], item['price']) for item in data if item.get('price', 0) > 500]
    if suspicious:
        print(f"⚠️ מחירים חשודים (>₪500): {len(suspicious)}")
        for name, price in suspicious[:5]:
            print(f"  ₪{price:.2f} — {name}")

    # === Summary ===
    cats = Counter(item.get('category', 'כללי') for item in data)
    print(f"\n📊 תוצאות סופיות:")
    print(f"  פריטים: {len(data)}")
    print(f"  קטגוריות: {len(cats)}")
    for cat, count in cats.most_common():
        print(f"    {cat}: {count}")

    # === Save ===
    with open(OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    size_mb = len(json.dumps(data, ensure_ascii=False)) / 1024 / 1024
    print(f"\n✅ נשמר: {OUTPUT} ({size_mb:.2f} MB)")


if __name__ == '__main__':
    main()
