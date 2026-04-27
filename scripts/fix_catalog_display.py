#!/usr/bin/env python3
"""
Catalog cleanup driven by user-reported display issues from the pantry
screen screenshots.

Issues found in supermarket.json:

NAME POLLUTION
- 769 names ending with stray '"' / '""' (truncated `ק"ג` etc.).
- 78 names with sticky-number patterns like '46%פירות' (missing space
  between digit-percent and the next Hebrew letter).
- 9 names starting with 'מבצע ' (no asterisks) — promo prefix that the
  earlier `*מבצע*` cleanup missed.
- 4 of those 9 are pure promo metadata with no product info ('מבצע 13 שח'
  etc.) — drop the row entirely.

CATEGORY ERRORS (substring traps in the upstream classifier)
- 'קוואס' (Russian fermented BEVERAGE): 19 rows scattered across כללי /
  שימורים / לחם ומאפים / מוצרי חלב / ממרחים מתוקים. All should sit in
  משקאות.
- 'סוכריות' / 'סוכרייה' (CANDIES): 464 rows ended up in 'תבלינים ואפייה'
  because the matcher's 'סוכר' (sugar) keyword is a substring of
  'סוכריות'. Move to 'ממתקים וחטיפים'.
"""
import json
import re
from collections import Counter
from pathlib import Path

PATH = Path('assets/data/list_types/supermarket.json')

# Promo-only rows (no real product info) → delete
PROMO_ONLY = re.compile(r'^מבצע\s+(\d|ב-?\d|שח|₪)')


def clean_name(s):
    if not s:
        return s
    out = s.strip()

    # Strip leading 'מבצע ' (no asterisks)
    out = re.sub(r'^מבצע\s+', '', out)

    # Drop trailing junk quotes ('"', '""', '"', etc.)
    out = re.sub(r'["“”\'\s]+$', '', out)

    # Sticky-number: '46%פירות' → '46% פירות' (insert space between
    # digit-percent and Hebrew letter)
    out = re.sub(r'(\d)%([א-ת])', r'\1% \2', out)
    # Sticky-number: '300גר' / '500ג' → '300 גר' (digit immediately followed
    # by Hebrew unit-prefix). Limit to 1-3 letter Hebrew suffixes to avoid
    # over-correction.
    out = re.sub(r'(\d)([א-ת]{1,3})\b', r'\1 \2', out)

    out = re.sub(r'\s+', ' ', out).strip()
    return out


def main():
    with open(PATH, encoding='utf-8') as f:
        data = json.load(f)
    before = len(data)

    # 1) Drop promo-only rows
    data = [it for it in data if not PROMO_ONLY.match(it.get('name', ''))]
    dropped_promo = before - len(data)

    # 2) Clean names
    name_changes = 0
    for it in data:
        original = it.get('name') or ''
        cleaned = clean_name(original)
        if cleaned and cleaned != original:
            it['name'] = cleaned
            name_changes += 1

    # 3) Move kvas → משקאות
    kvas_moved = 0
    for it in data:
        if 'קוואס' in it.get('name', '') and it.get('category') != 'משקאות':
            it['category'] = 'משקאות'
            kvas_moved += 1

    # 4) Move misplaced candies (in baking) → ממתקים וחטיפים
    candy_moved = 0
    for it in data:
        n = it.get('name', '')
        if it.get('category') == 'תבלינים ואפייה' and (
                'סוכריות' in n or 'סוכרייה' in n):
            it['category'] = 'ממתקים וחטיפים'
            candy_moved += 1

    with open(PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ supermarket.json:")
    print(f"   הוסרו (promo-only): {dropped_promo}")
    print(f"   שמות נוקו (trailing junk + sticky %): {name_changes}")
    print(f"   קוואס → משקאות: {kvas_moved}")
    print(f"   סוכריות/סוכרייה תבלינים → ממתקים: {candy_moved}")
    print(f"   {before} → {len(data)} פריטים")


if __name__ == '__main__':
    main()
