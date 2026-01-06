#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Remove non-dairy products from dairy.json
- Eggs (ביצים)
- Soy products (סויה)
- Vegan products (טבעוני)
- Chocolate wafers (גליליות רושן)
- Dulce de leche jar (ריבת חלב הוואנה)
"""

import json
from pathlib import Path

DAIRY_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\categories\dairy.json")

# Products to remove (by name patterns)
REMOVE_PATTERNS = [
    "ביצים",
    "ביציים",  # typo variant
    "סויה",
    "טבעוני",
    "גליליות רושן",
    "ריבת חלב הוואנה",
]

def should_remove(product_name: str) -> bool:
    """Check if product should be removed based on name patterns"""
    name_lower = product_name.lower()
    for pattern in REMOVE_PATTERNS:
        if pattern in name_lower:
            return True
    return False

def main():
    # Load current data
    with open(DAIRY_FILE, 'r', encoding='utf-8') as f:
        products = json.load(f)

    original_count = len(products)

    # Filter products
    removed = []
    kept = []

    for product in products:
        name = product.get('name', '')
        if should_remove(name):
            removed.append(name)
        else:
            kept.append(product)

    # Save
    with open(DAIRY_FILE, 'w', encoding='utf-8') as f:
        json.dump(kept, f, ensure_ascii=False, indent=2)

    # Report
    print(f"Original: {original_count}")
    print(f"Removed: {len(removed)}")
    print(f"Final: {len(kept)}")
    print()
    print("Removed products:")
    for name in removed:
        print(f"  - {name}")

if __name__ == "__main__":
    main()
