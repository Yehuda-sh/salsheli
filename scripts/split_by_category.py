#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Split supermarket.json into separate category files
"""

import json
from pathlib import Path

SOURCE_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\supermarket.json")
OUTPUT_DIR = Path(r"c:\projects\salsheli\assets\data\list_types\categories")

# Hebrew category to English filename mapping
CATEGORY_MAP = {
    'ממתקים וחטיפים': 'snacks',
    'היגיינה אישית': 'hygiene',
    'משקאות': 'beverages',
    'מוצרי חלב': 'dairy',  # SKIP - already enhanced
    'שמנים ורטבים': 'oils_sauces',
    'מוצרי ניקיון': 'cleaning',
    'אחר': 'other',
    'קפואים': 'frozen',
    'בשר ודגים': 'meat_fish',
    'תבלינים ואפייה': 'spices_baking',
    'ירקות': 'vegetables',
    'מאפים': 'bakery',
    'אורז ופסטה': 'rice_pasta',
    'שימורים': 'canned',
    'קפה ותה': 'coffee_tea',
    'פירות': 'fruits',
    'תחליפי בשר': 'meat_alternatives',
    'מוצרי תינוקות': 'baby',
    'ממרחים מתוקים': 'sweet_spreads',
    'דגנים': 'cereals',
    'חד פעמי': 'disposable',
    'קטניות ודגנים': 'legumes_grains',
    'אגוזים וגרעינים': 'nuts_seeds',
    'מזון לחיות מחמד': 'pet_food',
    'מוצרי בית': 'household',
    'תחליפי חלב': 'dairy_alternatives',
    'פירות יבשים': 'dried_fruits',
    'סלטים מוכנים': 'prepared_salads',
    'משקאות אלכוהוליים': 'alcohol',
    'פיצוחים וקטניות': 'nuts_seeds',  # Merge with nuts_seeds
    'מוצרי גינה': 'garden',
    'לחם ומאפים': 'bakery',  # Merge with bakery
    'ניקיון': 'cleaning',  # Merge with cleaning
    'משקאות קלים': 'beverages',  # Merge with beverages
}

# Categories to skip (already have enhanced files)
SKIP_CATEGORIES = {'מוצרי חלב'}

def main():
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Load source data
    with open(SOURCE_FILE, 'r', encoding='utf-8') as f:
        products = json.load(f)

    # Group products by category
    by_category = {}
    for product in products:
        cat = product.get('category', 'אחר')
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(product)

    # Create output files
    created_files = {}
    skipped = []

    for hebrew_cat, products_list in by_category.items():
        # Skip enhanced categories
        if hebrew_cat in SKIP_CATEGORIES:
            skipped.append(f"{hebrew_cat}: {len(products_list)} (already enhanced)")
            continue

        # Get English filename
        english_name = CATEGORY_MAP.get(hebrew_cat, 'other')
        filename = f"{english_name}.json"
        filepath = OUTPUT_DIR / filename

        # If file exists, merge (don't overwrite)
        if filepath.exists():
            with open(filepath, 'r', encoding='utf-8') as f:
                existing = json.load(f)
            # Merge - avoid duplicates by name
            existing_names = {p['name'].lower() for p in existing}
            for p in products_list:
                if p['name'].lower() not in existing_names:
                    existing.append(p)
                    existing_names.add(p['name'].lower())
            products_list = existing

        # Save
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(products_list, f, ensure_ascii=False, indent=2)

        # Track
        if filename not in created_files:
            created_files[filename] = 0
        created_files[filename] += len(products_list)

    # Report
    print(f"Created {len(created_files)} category files:")
    print()
    for filename, count in sorted(created_files.items(), key=lambda x: -x[1]):
        print(f"  {filename}: {count} products")

    if skipped:
        print()
        print("Skipped:")
        for s in skipped:
            print(f"  {s}")

if __name__ == "__main__":
    main()
