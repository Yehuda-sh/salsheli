#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix bugs from the previous script:
1. "מעודןנת" -> "מעודנת"
2. "3. 5%" -> "3.5%" (remove space before decimal)
"""

import json
import re
from pathlib import Path

DAIRY_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\categories\dairy.json")

def fix_bugs(name: str) -> str:
    result = name

    # Fix the מעודןנת bug
    result = result.replace('מעודןנת', 'מעודנת')

    # Fix space before decimal point in percentages (e.g., "3. 5%" -> "3.5%")
    result = re.sub(r'(\d+)\. (\d+%)', r'\1.\2', result)

    return result

def main():
    with open(DAIRY_FILE, 'r', encoding='utf-8') as f:
        products = json.load(f)

    fixes = []
    for product in products:
        old_name = product.get('name', '')
        new_name = fix_bugs(old_name)
        if new_name != old_name:
            fixes.append(f"{old_name} -> {new_name}")
            product['name'] = new_name

    with open(DAIRY_FILE, 'w', encoding='utf-8') as f:
        json.dump(products, f, ensure_ascii=False, indent=2)

    print(f"Fixed {len(fixes)} bugs")
    for fix in fixes:
        print(f"  - {fix}")

if __name__ == "__main__":
    main()
