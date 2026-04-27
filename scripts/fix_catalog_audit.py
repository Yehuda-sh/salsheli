#!/usr/bin/env python3
"""
One-shot audit pipeline for the small catalog files (butcher / bakery /
pharmacy). Already ran once in session 7 — re-running is safe but only
useful if the catalog is restored from a fresh scrape.

butcher.json:
- Introduce 'נקניקים ובשרים מעובדים' for sausages/salami/pastrami/kebab
  currently dumped in 'אחר'.
- Sort remaining 'אחר' candidates by species when the name implies it
  (chicken / beef / turkey).

bakery.json:
- 'מאפים' is a kitchen-sink. Redistribute by item type:
    cake/cookies                  -> 'עוגות'
    challah/bread/baguette/bun    -> 'לחמים ולחמניות'
    burekas/sambousek             -> 'מאפים מזרחיים'
    danish/croissant/donut        -> 'מאפים מתוקים'
    pizza/cracker/savory          -> 'מאפים מלוחים'
  Anything left in 'מאפים' becomes the genuine fallback.

pharmacy.json:
- Items in 'מוצרי ניקיון' / 'מזון בריאות' don't belong in a pharmacy file.
- 'אביזרי שיער' merged into 'טיפוח שיער'.

Backups: each catalog gets a `<name>.json.bak` next to it before
mutation. Existing .bak files are NOT overwritten — this preserves the
true pre-fix state across re-runs.
"""
import json
from collections import Counter
from pathlib import Path

ROOT = Path('assets/data/list_types')


def load(name):
    with open(ROOT / f'{name}.json', encoding='utf-8') as f:
        return json.load(f)


def save(name, data):
    out = ROOT / f'{name}.json'
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"   ✅ saved {out}")


def backup(name, data):
    """Write `<name>.json.bak` once. Subsequent runs leave it alone so
    the very first pre-fix snapshot stays recoverable."""
    bak = ROOT / f'{name}.json.bak'
    if bak.exists():
        return
    with open(bak, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)


def has_any(s, words):
    return any(w in s for w in words)


# =============================================================================
# butcher
# =============================================================================
def fix_butcher():
    print("\n🥩 butcher.json")
    data = load('butcher')
    print(f"   before: אחר={Counter(it.get('category') for it in data)['אחר']}")
    backup('butcher', data)

    PROCESSED = ['נקניק', 'נקניקיות', 'נקניקייה', 'סלמי', 'פסטרמה',
                 "צ'וריסו", 'צוריסוס', 'מורטדלה', 'מרטדלה', 'קבב',
                 'מרגז', 'וינר', 'ווינר']

    moved_processed = 0
    moved_chicken = 0
    moved_beef = 0
    moved_turkey = 0

    for it in data:
        if it.get('category') != 'אחר':
            continue
        name = it.get('name', '')

        if has_any(name, PROCESSED):
            it['category'] = 'נקניקים ובשרים מעובדים'
            moved_processed += 1
            continue

        # Species-based reclassification for ambiguous cuts
        if has_any(name, ['פרגית', 'פרגיות', 'כרעיים', 'שניצל עוף',
                          'חזה עוף', 'אגרופים', 'כנפיים', 'שוק עוף',
                          'כבד עוף']):
            it['category'] = 'עוף'
            moved_chicken += 1
        elif has_any(name, ['המבורגר', 'סטייק אנטרקוט', 'סטייק סינטה',
                            'בשר טחון', 'אנטרקוט', 'סינטה', 'אסאדו',
                            'מוח עגל', 'לשון']):
            it['category'] = 'בקר'
            moved_beef += 1
        elif has_any(name, ['חזה הודו', 'שניצל הודו', 'הודו טחון',
                            'כבד הודו']):
            it['category'] = 'הודו'
            moved_turkey += 1

    print(f"   → נקניקים ובשרים מעובדים: {moved_processed}")
    print(f"   → עוף: {moved_chicken}")
    print(f"   → בקר: {moved_beef}")
    print(f"   → הודו: {moved_turkey}")

    after = Counter(it.get('category') for it in data)
    print(f"   after: אחר={after['אחר']} (irreducible)")

    save('butcher', data)


# =============================================================================
# bakery
# =============================================================================
def fix_bakery():
    print("\n🥐 bakery.json")
    data = load('bakery')
    print(f"   before: מאפים={Counter(it.get('category') for it in data)['מאפים']}")
    backup('bakery', data)

    BREAD = ['חלה', 'לחם', 'בגט', 'באן ', 'באגט', 'כעך', 'לחמניה',
             'לחמניית', 'לחמניות', 'פיתה', 'פיתות', 'פוקאצ',
             'ג\'בטה', 'גבטה', 'מצה', 'מצות']
    EASTERN = ['בורקס', 'סמבוסק', 'בורקסים']
    SWEET = ['דניש', 'קרואסון', 'קרואסן', 'מאפין', 'אקלר',
             'סופגניה', 'סופגניות', 'דונאט', 'דונאטס', 'מילופיי',
             'טארט', 'בייגלה מתוק', 'מאפה דונאטס', 'כדורי שוקולד']
    SAVORY = ['פיצה', 'פיצוצים מלוחים', 'בייגלה מלוח', 'גריסיני',
              'קרקר', 'מלוח']

    moved_bread = 0
    moved_eastern = 0
    moved_sweet = 0
    moved_savory = 0
    moved_cake = 0

    for it in data:
        if it.get('category') != 'מאפים':
            continue
        name = it.get('name', '')

        # Cakes that ended up in מאפים
        if has_any(name, ['עוגת', 'עוגה ', 'עוגיות', 'עוגייה',
                          'מאפה עוגת']):
            it['category'] = 'עוגות'
            moved_cake += 1
            continue

        if has_any(name, BREAD):
            it['category'] = 'לחמים ולחמניות'
            moved_bread += 1
        elif has_any(name, EASTERN):
            it['category'] = 'מאפים מזרחיים'
            moved_eastern += 1
        elif has_any(name, SWEET):
            it['category'] = 'מאפים מתוקים'
            moved_sweet += 1
        elif has_any(name, SAVORY):
            it['category'] = 'מאפים מלוחים'
            moved_savory += 1

    print(f"   → לחמים ולחמניות: {moved_bread}")
    print(f"   → מאפים מזרחיים: {moved_eastern}")
    print(f"   → מאפים מתוקים: {moved_sweet}")
    print(f"   → מאפים מלוחים: {moved_savory}")
    print(f"   → עוגות: {moved_cake}")

    after = Counter(it.get('category') for it in data)
    print(f"   after: מאפים={after['מאפים']} (genuine fallback)")

    save('bakery', data)


# =============================================================================
# pharmacy
# =============================================================================
def fix_pharmacy():
    print("\n💊 pharmacy.json")
    data = load('pharmacy')
    before = Counter(it.get('category') for it in data)
    print(f"   before: מוצרי ניקיון={before['מוצרי ניקיון']}, "
          f"מזון בריאות={before['מזון בריאות']}, "
          f"אביזרי שיער={before['אביזרי שיער']}")
    backup('pharmacy', data)

    moved_hair = 0
    removed = 0

    # Drop items that don't belong in a pharmacy file
    new_data = []
    for it in data:
        cat = it.get('category')
        if cat == 'מוצרי ניקיון':
            removed += 1
            continue
        if cat == 'מזון בריאות':
            removed += 1
            continue
        # Merge accessories into hair care
        if cat == 'אביזרי שיער':
            it['category'] = 'טיפוח שיער'
            moved_hair += 1
        new_data.append(it)

    print(f"   ✂️ הוסרו (לא שייכים לבית מרקחת): {removed}")
    print(f"   → טיפוח שיער (מ-אביזרי שיער): {moved_hair}")

    after = Counter(it.get('category') for it in new_data)
    print(f"   after: {len(after)} קטגוריות")

    save('pharmacy', new_data)


# =============================================================================
def main():
    fix_butcher()
    fix_bakery()
    fix_pharmacy()
    print("\n🎉 done")


if __name__ == '__main__':
    main()
