#!/usr/bin/env python3
"""
Auto-repair short Israeli (7290-prefixed) barcodes by inserting the
zeros that were stripped during scrape, validated against the EAN-13
check digit.

EAN-13 check digit:
    sum = d0 + 3*d1 + d2 + 3*d3 + ... + 3*d11
    check = (10 - (sum % 10)) % 10

Strategy per row:
1. Filter: must start with '7290' and be < 13 digits.
2. Insert (13 - len) zeros immediately after the '7290' prefix.
3. Compute the EAN-13 check digit of the first 12 digits and compare
   to digit 13 of the candidate.
4. Only commit candidates where the check digit matches.
5. By default DRY-RUN — pass --apply to actually save the file.

We split the report by length: 12-digit candidates (1 missing zero,
high confidence) are listed separately from 9-11 digit candidates
(several missing — present but skipped from auto-fix unless --aggressive).
"""
import argparse
import json
import sys
from collections import Counter
from pathlib import Path

PATH = Path('assets/data/list_types/supermarket.json')


def ean13_check_digit(twelve_digits: str) -> int:
    """Return the EAN-13 check digit for a 12-digit prefix."""
    s = 0
    for i, ch in enumerate(twelve_digits):
        d = int(ch)
        s += d if i % 2 == 0 else 3 * d
    return (10 - (s % 10)) % 10


def candidate_for(barcode: str) -> str | None:
    """Return the auto-padded EAN-13 if the math validates, else None."""
    if not barcode.startswith('7290'):
        return None
    if len(barcode) >= 13 or len(barcode) < 8:
        return None
    pad = 13 - len(barcode)
    candidate = '7290' + ('0' * pad) + barcode[4:]
    if len(candidate) != 13 or not candidate.isdigit():
        return None
    if ean13_check_digit(candidate[:12]) != int(candidate[12]):
        return None
    return candidate


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true',
                        help='Actually save changes (default: dry-run)')
    parser.add_argument('--aggressive', action='store_true',
                        help='Also fix barcodes shorter than 12 digits')
    args = parser.parse_args()

    with open(PATH, encoding='utf-8') as f:
        data = json.load(f)

    fixes = []  # (idx, name, before, after, length_class)
    for idx, it in enumerate(data):
        bc = str(it.get('barcode') or '')
        cand = candidate_for(bc)
        if cand is None:
            continue
        # Always fix 12-digit; only fix shorter when --aggressive
        if len(bc) < 12 and not args.aggressive:
            fixes.append((idx, it.get('name', '')[:60], bc, cand, 'skipped'))
            continue
        fixes.append((idx, it.get('name', '')[:60], bc, cand, 'fix'))

    by_class = Counter(f[4] for f in fixes)
    print(f"📊 Total candidates: {len(fixes)}")
    print(f"   • will fix: {by_class.get('fix', 0)}")
    print(f"   • skipped (short, need --aggressive): {by_class.get('skipped', 0)}")

    print("\n=== TO FIX ===")
    for idx, name, before, after, kind in fixes:
        if kind == 'fix':
            print(f"  {before} ({len(before)}d) → {after}  | {name}")

    if by_class.get('skipped'):
        print("\n=== SKIPPED (would need --aggressive, validation passed) ===")
        for idx, name, before, after, kind in fixes:
            if kind == 'skipped':
                print(f"  {before} ({len(before)}d) → {after}  | {name}")

    if not args.apply:
        print(f"\n💡 dry-run only. Re-run with --apply to write the file.")
        return

    # Apply
    applied = 0
    for idx, name, before, after, kind in fixes:
        if kind == 'fix':
            data[idx]['barcode'] = after
            applied += 1

    if applied:
        with open(PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"\n✅ saved — {applied} barcodes fixed")
    else:
        print("\n   nothing to apply")


if __name__ == '__main__':
    main()
