#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Add missing dairy products and organize the file
"""

import json
from pathlib import Path

DAIRY_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\categories\dairy.json")

# New products to add (if missing)
NEW_PRODUCTS = [
    # === תנובה - שמנת/חמאה/קוטג' ===
    {"name": "שמנת מתוקה להקצפה 38% תנובה 250 מ״ל", "category": "מוצרי חלב", "icon": "🧈", "price": 9.9, "barcode": "7290000040202", "brand": "תנובה", "unit": "100 מ״ל"},
    {"name": "שמנת חמוצה 15% תנובה 250 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 6.9, "barcode": "7290000040158", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "קוטג' 5% תנובה 250 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 7.0, "barcode": "7290004127077", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "אשל 3% תנובה 200 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 4.5, "barcode": "7290000040257", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "גיל 3% תנובה 200 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 4.5, "barcode": "7290000040264", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "חמאה מתוקה תנובה 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 12.9, "barcode": "7290000040165", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "גבינת ריקוטה תנובה 250 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 13.9, "barcode": "7290000040172", "brand": "תנובה", "unit": "100 גרם"},

    # === שטראוס - שמנת/חמאה/קוטג' ===
    {"name": "שמנת מתוקה להקצפה שטראוס 38% 250 מ״ל", "category": "מוצרי חלב", "icon": "🧈", "price": 10.5, "barcode": "7290110563097", "brand": "שטראוס", "unit": "100 מ״ל"},
    {"name": "שמנת חמוצה 15% שטראוס 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 6.9, "barcode": "7290110563127", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "קוטג' שטראוס 5% 250 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 7.0, "barcode": "7290110563011", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "אשל שטראוס 3% 200 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 4.3, "barcode": "7290110563134", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "לבן שטראוס 4.5% 500 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 8.9, "barcode": "7290110563172", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "חמאת שטראוס 82% 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 12.5, "barcode": "7290110563165", "brand": "שטראוס", "unit": "100 גרם"},

    # === טרה - שמנת/חמאה/קוטג' ===
    {"name": "שמנת מתוקה להקצפה טרה 32% 250 מ״ל", "category": "מוצרי חלב", "icon": "🧈", "price": 9.0, "barcode": "7290002868910", "brand": "טרה", "unit": "100 מ״ל"},
    {"name": "שמנת חמוצה טרה 15% 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 6.9, "barcode": "7290002868927", "brand": "טרה", "unit": "100 גרם"},
    {"name": "חמאה טרה 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 12.0, "barcode": "7290002868972", "brand": "טרה", "unit": "100 גרם"},
    {"name": "לבן טרה 3% 500 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 8.5, "barcode": "7290002868934", "brand": "טרה", "unit": "100 גרם"},

    # === משק צוריאל / מחלבות גד ===
    {"name": "שמנת חמוצה מחלבות גד 15% 250 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 8.5, "barcode": "7290019635338", "brand": "מחלבות גד", "unit": "100 גרם"},
    {"name": "שמנת עיזים מתוקה משק צוריאל 32% 250 מ״ל", "category": "מוצרי חלב", "icon": "🧈", "price": 12.5, "barcode": "7290005416552", "brand": "משק צוריאל", "unit": "100 מ״ל"},
    {"name": "קוטג' עיזים 5% מחלבות גד 250 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 9.9, "barcode": "7290019635352", "brand": "מחלבות גד", "unit": "100 גרם"},
    {"name": "חמאה עיזים משק צוריאל 82% 100 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 14.5, "barcode": "7290005416453", "brand": "משק צוריאל", "unit": "100 גרם"},
    {"name": "לבן עיזים משק צוריאל 3% 500 גרם", "category": "מוצרי חלב", "icon": "🥛", "price": 11.0, "barcode": "7290005416460", "brand": "משק צוריאל", "unit": "100 גרם"},

    # === תנובה - גבינות צהובות ===
    {"name": "גבינה צהובה עמק 22% פרוסות 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 22.9, "barcode": "7290004120832", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "גבינת עמק 28% 250 גרם גוש", "category": "מוצרי חלב", "icon": "🧀", "price": 25.9, "barcode": "7290004120870", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "עמק מגורדת 22% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 19.9, "barcode": "7290004120894", "brand": "תנובה", "unit": "100 גרם"},

    # === טרה - גבינות צהובות ===
    {"name": "גבינה צהובה טרה 22% פרוסות 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 23.5, "barcode": "7290002868729", "brand": "טרה", "unit": "100 גרם"},
    {"name": "גבינה צהובה טרה 15% דלת שומן 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 24.9, "barcode": "7290002868736", "brand": "טרה", "unit": "100 גרם"},
    {"name": "גבינה צהובה מגורדת טרה 22% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 20.9, "barcode": "7290002868743", "brand": "טרה", "unit": "100 גרם"},

    # === שטראוס - גבינות צהובות ===
    {"name": "גבינה צהובה שטראוס 22% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 22.0, "barcode": "7290110563998", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "צהובה שטראוס 28% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 25.0, "barcode": "7290110563981", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "צהובה מגורדת שטראוס 22% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 21.5, "barcode": "7290110564001", "brand": "שטראוס", "unit": "100 גרם"},

    # === מחלבות גד / משק צוריאל - גבינות צהובות ===
    {"name": "גבינה צהובה מחלבות גד 28% גוש 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 24.9, "barcode": "7290019635406", "brand": "מחלבות גד", "unit": "100 גרם"},
    {"name": "גבינה צהובה עיזים 28% משק צוריאל 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 26.9, "barcode": "7290005416308", "brand": "משק צוריאל", "unit": "100 גרם"},
    {"name": "קשקבל מחלבות גד 28% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 25.9, "barcode": "7290019635413", "brand": "מחלבות גד", "unit": "100 גרם"},

    # === ויליפוד / יבואנים ===
    {"name": "גאודה ויליפוד 30% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 28.5, "barcode": "7290014083783", "brand": "ויליפוד", "unit": "100 גרם"},
    {"name": "צ'דר אדומה ויליפוד 33% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 30.9, "barcode": "7290014083790", "brand": "ויליפוד", "unit": "100 גרם"},
    {"name": "גבינה פרובולונה 28% 200 גרם", "category": "מוצרי חלב", "icon": "🧀", "price": 29.9, "barcode": "7290014083820", "brand": "גלבוע", "unit": "100 גרם"},
]

# Brand order for sorting
BRAND_ORDER = {
    'תנובה': 1,
    'עמק (תנובה)': 1,
    'פיראוס (תנובה)': 1,
    'GO (תנובה)': 1,
    'נפוליאון (תנובה)': 1,
    'יולו (תנובה)': 1,
    'שטראוס': 2,
    'טרה': 3,
    'יטבתה': 4,
    'מחלבות גד': 5,
    'מחלבות גד בעמ': 5,
    'מחלבות גד בע"מ': 5,
    'משק צוריאל': 6,
}

# Category order for sorting
CATEGORY_ORDER = {
    'חלב': 1,
    'יוגורט': 2,
    'לבן': 3,
    'קוטג': 4,
    'שמנת': 5,
    'חמאה': 6,
    'גבינה צהובה': 7,
    'גבינה לבנה': 8,
    'גבינה': 9,
    'גלידה': 10,
    'קינוח': 11,
}

def get_sort_key(product):
    """Generate sort key: brand order, then category, then name"""
    brand = product.get('brand', '') or ''
    name = product.get('name', '')

    # Brand priority
    brand_priority = BRAND_ORDER.get(brand, 99)

    # Category priority based on name prefix
    cat_priority = 99
    name_lower = name.lower()
    for cat, order in CATEGORY_ORDER.items():
        if cat in name_lower:
            cat_priority = order
            break

    return (brand_priority, cat_priority, name)

def main():
    # Load existing
    with open(DAIRY_FILE, 'r', encoding='utf-8') as f:
        existing = json.load(f)

    # Get existing names (normalized)
    existing_names = {p['name'].lower().strip() for p in existing}
    existing_barcodes = {p.get('barcode', '') for p in existing if p.get('barcode')}

    # Add missing products
    added = []
    skipped = []

    for product in NEW_PRODUCTS:
        name_lower = product['name'].lower().strip()
        barcode = product.get('barcode', '')

        # Skip if name or barcode already exists
        if name_lower in existing_names:
            skipped.append(product['name'])
        elif barcode and barcode in existing_barcodes:
            skipped.append(f"{product['name']} (barcode exists)")
        else:
            existing.append(product)
            existing_names.add(name_lower)
            if barcode:
                existing_barcodes.add(barcode)
            added.append(product['name'])

    # Sort by brand, then category, then name
    existing.sort(key=get_sort_key)

    # Save
    with open(DAIRY_FILE, 'w', encoding='utf-8') as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)

    # Report
    print(f"Before: {len(existing) - len(added)}")
    print(f"Added: {len(added)}")
    print(f"Skipped: {len(skipped)}")
    print(f"Total: {len(existing)}")

if __name__ == "__main__":
    main()
