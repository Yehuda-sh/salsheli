#!/usr/bin/env python3
"""
Brand-field cleanup for the catalog files.

Issues handled:
- supermarket: 7,053 items with brand='לא ידוע' (literal "unknown" string)
  and 979 with brand=',' — both pure data pollution. Set to null.
- Case-mismatch pairs (JTI/jti, BAT/bat, FRANZELUTA/Franzeluta) — pick the
  uppercase form (more consistent with how foreign brands are usually
  rendered) so all rows agree.
"""
import json
from collections import Counter
from pathlib import Path

ROOT = Path('assets/data/list_types')

JUNK_BRANDS = {'לא ידוע', ',', '-', '---', 'None', 'null', 'unknown', 'UNKNOWN'}

# Pick canonical case for known mismatches
BRAND_CANONICAL = {
    'jti': 'JTI',
    'bat': 'BAT',
    'franzeluta': 'FRANZELUTA',
}


def clean(name):
    path = ROOT / f'{name}.json'
    with open(path, encoding='utf-8') as f:
        data = json.load(f)

    nulled = 0
    cased = 0
    for it in data:
        b = it.get('brand')
        if not b:
            continue
        s = b.strip()
        if s in JUNK_BRANDS or len(s) <= 1:
            it['brand'] = None
            nulled += 1
            continue
        canonical = BRAND_CANONICAL.get(s.lower())
        if canonical and s != canonical:
            it['brand'] = canonical
            cased += 1

    if nulled or cased:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    return nulled, cased


def main():
    for name in ['bakery', 'butcher', 'greengrocer', 'market', 'pharmacy',
                 'supermarket']:
        nulled, cased = clean(name)
        if nulled or cased:
            print(f"✅ {name}: nulled junk={nulled}, case-fixed={cased}")
        else:
            print(f"   {name}: clean")


if __name__ == '__main__':
    main()
