#!/usr/bin/env python3
"""
Sort all catalog files by (category, name) for deterministic order and
easier maintenance / cleaner diffs. Also drops stripped-barcode
duplicates in supermarket — pairs where one row has the canonical
7290-prefixed 13-digit barcode and another the 8-digit suffix with no
brand (a known scrape artefact).

Idempotent: re-running on a clean catalog finds zero dupes and
preserves the same sort order.
"""
import json
from collections import defaultdict
from pathlib import Path

ROOT = Path('assets/data/list_types')
FILES = ['bakery', 'butcher', 'greengrocer', 'market', 'pharmacy', 'supermarket']


def load(name):
    with open(ROOT / f'{name}.json', encoding='utf-8') as f:
        return json.load(f)


def save(name, data):
    out = ROOT / f'{name}.json'
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def sort_data(data):
    """Sort by (category, name). Hebrew strings collate by Unicode
    codepoint which is good enough for our purposes."""
    return sorted(
        data,
        key=lambda it: (it.get('category') or 'אחר', it.get('name') or '')
    )


def drop_stripped_dupes(data):
    """If two items share a name and one has barcode=7290XXXXXXXXX
    while the other has just XXXXXXXXX (the 8-digit suffix) and no
    brand, drop the short-barcode/no-brand row.

    Returns (new_list, dropped_count).
    """
    by_name = defaultdict(list)
    for i, it in enumerate(data):
        n = (it.get('name') or '').strip()
        if n:
            by_name[n].append((i, it))

    to_drop = set()
    for lst in by_name.values():
        if len(lst) != 2:
            continue
        (i_a, a), (i_b, b) = lst
        ba, bb = (a.get('barcode') or ''), (b.get('barcode') or '')
        if (len(ba) == 13 and ba.startswith('7290') and len(bb) == 8
                and ba.endswith(bb) and not b.get('brand')):
            to_drop.add(i_b)
        elif (len(bb) == 13 and bb.startswith('7290') and len(ba) == 8
                and bb.endswith(ba) and not a.get('brand')):
            to_drop.add(i_a)

    if not to_drop:
        return data, 0
    return [it for i, it in enumerate(data) if i not in to_drop], len(to_drop)


def main():
    for name in FILES:
        data = load(name)
        before_n = len(data)
        cats_before = len(set(it.get('category') for it in data))

        # supermarket-only: drop stripped barcode dupes
        if name == 'supermarket':
            data, dropped = drop_stripped_dupes(data)
            if dropped:
                print(f"🧹 {name}: dropped {dropped} stripped-barcode dupes")

        data = sort_data(data)
        save(name, data)

        after_n = len(data)
        cats_after = len(set(it.get('category') for it in data))
        print(f"✅ {name}: {before_n} → {after_n} פריטים, "
              f"{cats_before}→{cats_after} קטגוריות")


if __name__ == '__main__':
    main()
