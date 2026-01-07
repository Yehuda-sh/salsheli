#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Add more dairy products - cream cheese, kids desserts, vegan alternatives
"""

import json
from pathlib import Path

DAIRY_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\categories\dairy.json")

# New products to add
NEW_PRODUCTS = [
    # === גבינות שמנת ===
    {"name": "גבינת שמנת תנובה 30% 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 12.9, "barcode": "7290000040226", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "גבינת שמנת שום שמיר 5% גד 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 15.9, "barcode": "7290019635109", "brand": "מחלבות גד", "unit": "100 גרם"},
    {"name": "גבינת שמנת פילדלפיה 25% 150 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 17.9, "barcode": "7622300840027", "brand": "פילדלפיה", "unit": "100 גרם"},
    {"name": "גבינת שמנת טבעית 25% טרה 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 13.9, "barcode": "7290002868804", "brand": "טרה", "unit": "100 גרם"},
    {"name": "גבינת שמנת שום שמיר 25% טרה 200 גרם", "category": "מוצרי חלב", "icon": "🧈", "price": 14.9, "barcode": "7290002868811", "brand": "טרה", "unit": "100 גרם"},

    # === ממרחי גבינה ===
    {"name": "ממרח גבינת שמנת שום שמיר תנובה 250 גרם", "category": "מוצרי חלב", "icon": "🥯", "price": 15.9, "barcode": "7290000040288", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "ממרח גבינה בטעם טבעי 200 גרם גד", "category": "מוצרי חלב", "icon": "🥯", "price": 14.9, "barcode": "7290019635307", "brand": "מחלבות גד", "unit": "100 גרם"},
    {"name": "ממרח גבינה בטעם זיתים 200 גרם טרה", "category": "מוצרי חלב", "icon": "🥯", "price": 13.9, "barcode": "7290002868835", "brand": "טרה", "unit": "100 גרם"},
    {"name": "ממרח גבינה מתוקה מסקרפונה 38% 250 גרם", "category": "מוצרי חלב", "icon": "🍰", "price": 28.9, "barcode": "7290114312189", "brand": "טרה", "unit": "100 גרם"},

    # === מעדנים לילדים ===
    {"name": "מילקי שוקולד 130 גרם", "category": "מוצרי חלב", "icon": "🍮", "price": 4.5, "barcode": "7290110563035", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "מילקי שכבות שוקולד וניל 130 גרם", "category": "מוצרי חלב", "icon": "🍮", "price": 4.5, "barcode": "7290110563042", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "מעדן יולו שוקולד חלב 110 גרם", "category": "מוצרי חלב", "icon": "🍫", "price": 5.9, "barcode": "7290110563097", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "מעדן יולו קרמל מלוח 110 גרם", "category": "מוצרי חלב", "icon": "🍫", "price": 5.9, "barcode": "7290110563080", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "מעדן דנונה תות 150 גרם", "category": "מוצרי חלב", "icon": "🍓", "price": 5.5, "barcode": "7290112339355", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "גמדים תות 100 גרם", "category": "מוצרי חלב", "icon": "🍓", "price": 6.0, "barcode": "7290112339874", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "גמדים בננה 100 גרם", "category": "מוצרי חלב", "icon": "🍌", "price": 6.0, "barcode": "7290112339881", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "דניאלה שוקולד 88 גרם", "category": "מוצרי חלב", "icon": "🍮", "price": 4.3, "barcode": "7290011194208", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "אקטימל ילדים תות בננה 93 מ״ל", "category": "מוצרי חלב", "icon": "🥤", "price": 3.5, "barcode": "7290119380916", "brand": "שטראוס", "unit": "100 מ״ל"},

    # === יוגורטים לילדים ===
    {"name": "יופלה ילדים תות בננה 3% 115 גרם", "category": "מוצרי חלב", "icon": "🧁", "price": 5.5, "barcode": "7290000040639", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "יופלה ילדים אפרסק 3% 115 גרם", "category": "מוצרי חלב", "icon": "🧁", "price": 5.5, "barcode": "7290000040646", "brand": "תנובה", "unit": "100 גרם"},
    {"name": "דנונה קידס שוקו וניל 150 גרם", "category": "מוצרי חלב", "icon": "🍫", "price": 5.9, "barcode": "7290112339126", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "דנונה קידס תות בננה 150 גרם", "category": "מוצרי חלב", "icon": "🍓", "price": 5.9, "barcode": "7290112339133", "brand": "שטראוס", "unit": "100 גרם"},
    {"name": "YOLO קידס שוקולד 100 גרם", "category": "מוצרי חלב", "icon": "🍮", "price": 4.9, "barcode": "7290110564506", "brand": "טרה", "unit": "100 גרם"},
    {"name": "YOLO קידס וניל 100 גרם", "category": "מוצרי חלב", "icon": "🍮", "price": 4.9, "barcode": "7290110564513", "brand": "טרה", "unit": "100 גרם"},
    {"name": "מעדן YOLO קידס תות 100 גרם", "category": "מוצרי חלב", "icon": "🍓", "price": 4.9, "barcode": "7290110564520", "brand": "טרה", "unit": "100 גרם"},
    {"name": "גמדים לדרך וניל תות 100 גרם", "category": "מוצרי חלב", "icon": "🍓", "price": 6.0, "barcode": "7290112339867", "brand": "שטראוס", "unit": "100 גרם"},

    # === תחליפי חלב - תנובה אלטרנטיב ===
    {"name": "משקה סויה אלטרנטיב 1 ליטר", "category": "תחליפי חלב", "icon": "🥛", "price": 13.9, "barcode": "7290114312107", "brand": "תנובה אלטרנטיב", "unit": "ליטר"},
    {"name": "משקה שקדים אלטרנטיב 1 ליטר", "category": "תחליפי חלב", "icon": "🌰", "price": 14.9, "barcode": "7290114312114", "brand": "תנובה אלטרנטיב", "unit": "ליטר"},
    {"name": "משקה שיבולת שועל אלטרנטיב 1 ליטר", "category": "תחליפי חלב", "icon": "🌾", "price": 14.9, "barcode": "7290114312121", "brand": "תנובה אלטרנטיב", "unit": "ליטר"},
    {"name": "משקה קוקוס אלטרנטיב 1 ליטר", "category": "תחליפי חלב", "icon": "🥥", "price": 15.9, "barcode": "7290114312138", "brand": "תנובה אלטרנטיב", "unit": "ליטר"},

    # === תחליפי חלב - אלפרו ===
    {"name": "משקה סויה אלפרו 1 ליטר", "category": "תחליפי חלב", "icon": "🥛", "price": 15.9, "barcode": "5411188115472", "brand": "אלפרו", "unit": "ליטר"},
    {"name": "משקה שקדים אלפרו 1 ליטר", "category": "תחליפי חלב", "icon": "🌰", "price": 16.5, "barcode": "5411188123347", "brand": "אלפרו", "unit": "ליטר"},
    {"name": "משקה שיבולת שועל אלפרו 1 ליטר", "category": "תחליפי חלב", "icon": "🌾", "price": 16.5, "barcode": "5411188123378", "brand": "אלפרו", "unit": "ליטר"},
    {"name": "משקה קוקוס אלפרו 1 ליטר", "category": "תחליפי חלב", "icon": "🥥", "price": 17.5, "barcode": "5411188123354", "brand": "אלפרו", "unit": "ליטר"},

    # === תחליפי חלב - Oatly ===
    {"name": "משקה שיבולת שועל Oatly Barista 1 ליטר", "category": "תחליפי חלב", "icon": "🌾", "price": 17.9, "barcode": "7394376616371", "brand": "Oatly", "unit": "ליטר"},
    {"name": "משקה שיבולת שועל Oatly רגיל 1 ליטר", "category": "תחליפי חלב", "icon": "🌾", "price": 15.9, "barcode": "7394376616234", "brand": "Oatly", "unit": "ליטר"},
    {"name": "משקה שיבולת שועל בטעם שוקולד Oatly 1 ליטר", "category": "תחליפי חלב", "icon": "🍫", "price": 16.9, "barcode": "7394376616296", "brand": "Oatly", "unit": "ליטר"},

    # === תחליפי חלב - Free / Vemondo ===
    {"name": "משקה שקדים Free 1 ליטר", "category": "תחליפי חלב", "icon": "🌰", "price": 12.9, "barcode": "7290110573034", "brand": "טרה Free", "unit": "ליטר"},
    {"name": "משקה שיבולת שועל Free 1 ליטר", "category": "תחליפי חלב", "icon": "🌾", "price": 12.9, "barcode": "7290110573041", "brand": "טרה Free", "unit": "ליטר"},
    {"name": "משקה שקדים Vemondo 1 ליטר", "category": "תחליפי חלב", "icon": "🌰", "price": 9.9, "barcode": "20414197", "brand": "Vemondo (Lidl)", "unit": "ליטר"},
    {"name": "משקה סויה Vemondo 1 ליטר", "category": "תחליפי חלב", "icon": "🥛", "price": 9.9, "barcode": "20414210", "brand": "Vemondo (Lidl)", "unit": "ליטר"},

    # === מעדנים טבעוניים ===
    {"name": "מעדן אלטרנטיב וניל 150 גרם", "category": "תחליפי חלב", "icon": "🌱", "price": 6.9, "barcode": "7290114312769", "brand": "תנובה אלטרנטיב", "unit": "100 גרם"},
    {"name": "מעדן אלטרנטיב שוקולד 150 גרם", "category": "תחליפי חלב", "icon": "🍫", "price": 6.9, "barcode": "7290114312776", "brand": "תנובה אלטרנטיב", "unit": "100 גרם"},
    {"name": "מעדן אלטרנטיב קרמל מלוח 150 גרם", "category": "תחליפי חלב", "icon": "🍮", "price": 6.9, "barcode": "7290114312783", "brand": "תנובה אלטרנטיב", "unit": "100 גרם"},
    {"name": "מעדן אלפרו שוקולד טבעוני 125 גרם", "category": "תחליפי חלב", "icon": "🌱", "price": 7.2, "barcode": "5411188116936", "brand": "אלפרו", "unit": "100 גרם"},
    {"name": "מעדן אלפרו וניל טבעוני 125 גרם", "category": "תחליפי חלב", "icon": "🌱", "price": 7.2, "barcode": "5411188116929", "brand": "אלפרו", "unit": "100 גרם"},
    {"name": "מעדן Free בטעם קקאו 150 גרם", "category": "תחליפי חלב", "icon": "🍫", "price": 6.5, "barcode": "7290110573003", "brand": "תנובה Free", "unit": "100 גרם"},
    {"name": "מעדן Free בטעם וניל 150 גרם", "category": "תחליפי חלב", "icon": "🌱", "price": 6.5, "barcode": "7290110573010", "brand": "תנובה Free", "unit": "100 גרם"},
    {"name": "מעדן Free קוקוס 150 גרם", "category": "תחליפי חלב", "icon": "🥥", "price": 6.9, "barcode": "7290110573027", "brand": "תנובה Free", "unit": "100 גרם"},
    {"name": "ממרח גבינת שמנת טבעונית ALTERNATIVE 150 גרם", "category": "תחליפי חלב", "icon": "🌱", "price": 15.9, "barcode": "7290114312639", "brand": "תנובה אלטרנטיב", "unit": "100 גרם"},
]

def main():
    # Load existing
    with open(DAIRY_FILE, 'r', encoding='utf-8') as f:
        existing = json.load(f)

    # Get existing names and barcodes (normalized)
    existing_names = {p['name'].lower().strip() for p in existing}
    existing_barcodes = {p.get('barcode', '') for p in existing if p.get('barcode')}

    # Add missing products
    added = []
    skipped = []

    for product in NEW_PRODUCTS:
        name_lower = product['name'].lower().strip()
        barcode = product.get('barcode', '')

        if name_lower in existing_names:
            skipped.append(product['name'])
        elif barcode and barcode in existing_barcodes:
            skipped.append(f"{product['name']} (barcode)")
        else:
            existing.append(product)
            existing_names.add(name_lower)
            if barcode:
                existing_barcodes.add(barcode)
            added.append(product['name'])

    # Save
    with open(DAIRY_FILE, 'w', encoding='utf-8') as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)

    print(f"Before: {len(existing) - len(added)}")
    print(f"Added: {len(added)}")
    print(f"Skipped: {len(skipped)}")
    print(f"Total: {len(existing)}")

if __name__ == "__main__":
    main()
