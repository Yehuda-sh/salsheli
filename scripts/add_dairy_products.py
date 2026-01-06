#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Add new dairy products to dairy.json, skipping existing ones."""

import json

# Read existing dairy products
with open('c:/projects/salsheli/assets/data/list_types/categories/dairy.json', 'r', encoding='utf-8') as f:
    existing = json.load(f)

# Get existing product names (lowercase for comparison)
existing_names = {p['name'].lower().strip() for p in existing}

# New products to add (from user's template)
new_products = [
    # ====================== תנובה (Tnuva) ======================
    {'name': 'חלב טרי 3% תנובה 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 9.5, 'barcode': '', 'brand': 'תנובה', 'unit': 'ליטר'},
    {'name': 'חלב דל לקטוז 2% תנובה 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 10.9, 'barcode': '', 'brand': 'תנובה', 'unit': 'ליטר'},
    {'name': "קוטג' GO חלבון 5% 250 גרם", 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 8.9, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'גבינת עמק פרוסות 200 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 18.5, 'barcode': '', 'brand': 'עמק (תנובה)', 'unit': '100 גרם'},
    {'name': 'יוגורט פיראוס תות 3% 170 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.0, 'barcode': '', 'brand': 'פיראוס (תנובה)', 'unit': '100 גרם'},
    {'name': 'יוגורט טבעי GO 3% 500 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 11.9, 'barcode': '', 'brand': 'GO (תנובה)', 'unit': '100 גרם'},
    {'name': 'שמנת מתוקה 38% תנובה 250 מ"ל', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 12.9, 'barcode': '', 'brand': 'תנובה', 'unit': 'מ"ל'},
    {'name': 'גבינת נפוליאון שמנת 200 גרם', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 20.0, 'barcode': '', 'brand': 'נפוליאון (תנובה)', 'unit': '100 גרם'},
    {'name': 'גבינה צהובה חריפה תנובה 26% 300 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 25.0, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'יוגורט יולו פירות יער 170 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.5, 'barcode': '', 'brand': 'יולו (תנובה)', 'unit': '100 גרם'},
    {'name': 'חלב תנובה 1% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 8.5, 'barcode': '', 'brand': 'תנובה', 'unit': 'ליטר'},
    {'name': 'חלב מועשר A+ 3.5% תנובה 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 11.5, 'barcode': '', 'brand': 'תנובה', 'unit': 'ליטר'},
    {'name': 'שמנת חמוצה 15% תנובה 250 גרם', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 9.9, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'גבינת מוצרלה פרוסות תנובה 200 ג', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 18.9, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'יוגורט תות GO תנובה 150 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.9, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'יוגורט אפונה GO תנובה 150 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.9, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'גבינת ריקוטה תנובה 250 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 22.0, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': "גבינת קוטג' 3% תנובה 500 גרם", 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 12.0, 'barcode': '', 'brand': 'תנובה', 'unit': '100 גרם'},
    {'name': 'שמנת לבישול 15% תנובה 250 מ"ל', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 8.5, 'barcode': '', 'brand': 'תנובה', 'unit': 'מ"ל'},

    # ====================== טרה (Tara) ======================
    {'name': 'חלב טרה 3% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 9.5, 'barcode': '', 'brand': 'טרה', 'unit': 'ליטר'},
    {'name': 'חלב בטעם שוקו טרה 250 מ"ל', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.5, 'barcode': '', 'brand': 'טרה', 'unit': 'מ"ל'},
    {'name': 'גבינת צהובה נעם 28% 300 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 22.0, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'גבינת מוצרלה נעם 23% 250 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 18.9, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': "קוטג' טרה 5% 250 גרם", 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.5, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'גבינה לבנה טרה 5% 500 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 8.9, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'גבינת קרם שמנת טרה 150 גרם', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 12.0, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'יוגורט טרה טבעי 3% 500 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 11.0, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'חלב טרה 1.5% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 9.0, 'barcode': '', 'brand': 'טרה', 'unit': 'ליטר'},
    {'name': 'חלב שוקו טרה 500 מ"ל', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.0, 'barcode': '', 'brand': 'טרה', 'unit': 'מ"ל'},
    {'name': 'גבינה צהובה טרה 24% 300 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 23.0, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'גבינת קממבר טרה 125 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 18.9, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'יוגורט טרה לימון 170 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.5, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'שמנת מתוקה טרה 33% 500 מ"ל', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 18.9, 'barcode': '', 'brand': 'טרה', 'unit': 'מ"ל'},
    {'name': "קוטג' טרה 3% 500 גרם", 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 10.5, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},
    {'name': 'יוגורט טרה בננה 170 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.5, 'barcode': '', 'brand': 'טרה', 'unit': '100 גרם'},

    # ====================== יטבתה (Yotvata) ======================
    {'name': 'חלב יטבתה 3% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 9.9, 'barcode': '', 'brand': 'יטבתה', 'unit': 'ליטר'},
    {'name': 'שוקו יטבתה 1 ליטר', 'category': 'משקאות חלב', 'icon': '🥛', 'price': 9.9, 'barcode': '', 'brand': 'יטבתה', 'unit': 'ליטר'},
    {'name': 'חלב בטעם מוקה יטבתה 1 ליטר', 'category': 'משקאות חלב', 'icon': '🥛', 'price': 10.5, 'barcode': '', 'brand': 'יטבתה', 'unit': 'ליטר'},
    {'name': 'משקה יוגורט יטבתה אננס 250 מ"ל', 'category': 'משקאות חלב', 'icon': '🥛', 'price': 7.9, 'barcode': '', 'brand': 'יטבתה', 'unit': 'מ"ל'},
    {'name': 'יוגורט יטבתה תות 170 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.0, 'barcode': '', 'brand': 'יטבתה', 'unit': '100 גרם'},
    {'name': 'שוקו יטבתה 500 מ"ל', 'category': 'משקאות חלב', 'icon': '🥛', 'price': 6.9, 'barcode': '', 'brand': 'יטבתה', 'unit': 'מ"ל'},
    {'name': 'יוגורט יטבתה תות רביעייה (4x100)', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 19.0, 'barcode': '', 'brand': 'יטבתה', 'unit': '100 גרם'},
    {'name': 'חלב יטבתה דל שומן 1% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 8.5, 'barcode': '', 'brand': 'יטבתה', 'unit': 'ליטר'},
    {'name': 'חלב יטבתה 3.5% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 10.0, 'barcode': '', 'brand': 'יטבתה', 'unit': 'ליטר'},

    # ====================== שטראוס (Strauss) ======================
    {'name': 'יוגורט מילקי ווניל 120 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 4.3, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'דני דנונה שוקולד 175 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 5.5, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'יופלה בטעם וניל 150 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.2, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'דניאלה טבעי 100 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 4.0, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'מעדן חלב טעם קרמל שטראוס 120 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 6.8, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'יופלה טבעי 3% 150 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 6.2, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'דנונה GO פירות יער 150 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 6.5, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'דני שוקולד 175 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 5.9, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'יוגורט GO פירות כתומים 200 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 7.5, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},
    {'name': 'דניאלה תות 100 גרם', 'category': 'מוצרי חלב', 'icon': '🍮', 'price': 4.4, 'barcode': '', 'brand': 'שטראוס', 'unit': '100 גרם'},

    # ====================== משק צוריאל / מחלבות גד ======================
    {'name': 'חלב עיזים מלא 3.9% 1 ליטר', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 19.9, 'barcode': '', 'brand': 'משק צוריאל', 'unit': 'ליטר'},
    {'name': 'איירן 3% מחלבות גד 500 מ"ל', 'category': 'משקאות חלב', 'icon': '🥛', 'price': 8.5, 'barcode': '', 'brand': 'מחלבות גד', 'unit': 'מ"ל'},
    {'name': "צזיקי 5% מחלבות גד 250 גרם", 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 9.5, 'barcode': '', 'brand': 'מחלבות גד', 'unit': '100 גרם'},
    {'name': 'גבינה צאן רכה 5% 200 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 24.0, 'barcode': '', 'brand': 'משק צוריאל', 'unit': '100 גרם'},
    {'name': 'גבינת בולגרית משק צוריאל 5% 250 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 24.9, 'barcode': '', 'brand': 'משק צוריאל', 'unit': '100 גרם'},
    {'name': 'גבינת צאן רכה משק צוריאל 10% 200 גרם', 'category': 'מוצרי חלב', 'icon': '🧀', 'price': 26.0, 'barcode': '', 'brand': 'משק צוריאל', 'unit': '100 גרם'},
    {'name': 'יוגורט לבן מחלבות גד 3% 500 גרם', 'category': 'מוצרי חלב', 'icon': '🥛', 'price': 10.5, 'barcode': '', 'brand': 'מחלבות גד', 'unit': '100 גרם'},
    {'name': 'שמנת חמוצה מחלבות גד 18% 250 גרם', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 11.9, 'barcode': '', 'brand': 'מחלבות גד', 'unit': '100 גרם'},
    {'name': 'חמאה 82% מחלבות גד 100 גרם', 'category': 'מוצרי חלב', 'icon': '🧈', 'price': 15.0, 'barcode': '', 'brand': 'מחלבות גד', 'unit': '100 גרם'},
]

# Filter out existing products
added = []
skipped = []
for p in new_products:
    if p['name'].lower().strip() in existing_names:
        skipped.append(p['name'])
    else:
        existing.append(p)
        added.append(p['name'])

# Save updated file
with open('c:/projects/salsheli/assets/data/list_types/categories/dairy.json', 'w', encoding='utf-8') as f:
    json.dump(existing, f, ensure_ascii=False, indent=2)

print(f'Added: {len(added)} new products')
print(f'Skipped: {len(skipped)} existing products')
print(f'Total now: {len(existing)} products')
print()
if skipped:
    print('Skipped products:')
    for s in skipped[:10]:
        print(f'  - {s}')
    if len(skipped) > 10:
        print(f'  ... and {len(skipped) - 10} more')
