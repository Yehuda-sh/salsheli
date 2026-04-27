#!/usr/bin/env python3
"""
Name cleanup for the catalog files.

Issues handled in supermarket.json:
- 4 names that are pure digits/dots ('19.9', '23.90', '23035', '5000')
  — drop the rows entirely (OCR/scrape garbage with no real product).
- 41 names prefixed with '*מבצע*' (literal "*sale*" promo marker) — strip
  the marker so search/sort works on the actual product name.
- 8 names starting with bare '*' or '****' — strip the leading asterisks.
- ~1,120 names with mid-string '*' (e.g. 'אגוז *קשיו', 'גרעיני * חמנייה')
  where the asterisk is a stray OCR / scraper artefact between two words.
  Replace ' * '/' *'/'* ' with a single space, then ' *X' → ' X'.
"""
import json
import re
from pathlib import Path

ROOT = Path('assets/data/list_types')


def clean_name(s):
    if not s:
        return s
    s = s.strip()

    # Strip leading promo marker
    s = re.sub(r'^\*+\s*מבצע\s*\*+\s*', '', s)
    # Strip leading bare asterisks
    s = re.sub(r'^\*+\s*', '', s)
    # Mid-string asterisks: '* X' or 'X *Y' or ' * '
    s = re.sub(r'\s*\*\s*', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s


def main():
    path = ROOT / 'supermarket.json'
    with open(path, encoding='utf-8') as f:
        data = json.load(f)

    before = len(data)

    # Drop pure-numeric rows
    NUM_RE = re.compile(r'^[\d.\-,\s]+$')
    new_data = [it for it in data
                if not NUM_RE.match((it.get('name') or '').strip())]
    dropped = before - len(new_data)

    # Clean asterisks
    cleaned = 0
    for it in new_data:
        original = it.get('name') or ''
        cleaned_name = clean_name(original)
        if cleaned_name != original:
            it['name'] = cleaned_name
            cleaned += 1

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)

    print(f"✅ supermarket.json:")
    print(f"   הוסרו (pure-numeric): {dropped}")
    print(f"   שמות נוקו (asterisks): {cleaned}")
    print(f"   {before} → {len(new_data)} פריטים")


if __name__ == '__main__':
    main()
