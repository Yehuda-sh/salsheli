#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix dairy product names:
1. Expand abbreviations (גב. -> גבינה, יוג. -> יוגורט)
2. Fix missing spaces before percentages
3. Fix truncated names
4. Fix icons where wrong
"""

import json
import re
from pathlib import Path

DAIRY_FILE = Path(r"c:\projects\salsheli\assets\data\list_types\categories\dairy.json")

# Abbreviation expansions
ABBREVIATIONS = {
    'גב.': 'גבינת',
    'יוג.': 'יוגורט',
    'פ.': 'פירות',
    'ט.': 'טעם',
    'ע.': 'עם',
    'מעוד': 'מעודן',
    ' ג\'': ' גרם',
    ' ג"': ' גרם',
    ' מ"ל': ' מ״ל',
}

# Specific name fixes (old -> new)
NAME_FIXES = {
    # Missing spaces before percentages
    "בולגרית מעודנת5% במשקל": "גבינה בולגרית מעודנת 5% במשקל",
    "בסגנון פטה פטינא21%משקל": "גבינה בסגנון פטה פטינה 21% במשקל",
    "גאודה עיזים 30.60% משקל": "גבינת גאודה עיזים 30% במשקל",
    "גאודה פסטו אדום32% משקל": "גבינת גאודה פסטו אדום 32% במשקל",
    "גאודה בקר כמהין במשקל32%": "גבינת גאודה בקר כמהין 32% במשקל",

    # Truncated/incomplete names
    "יוג.מולר נטורל1.7% 1508": "יוגורט מולר טבעי 1.7% 1.5 ק״ג",
    "יופלה אפרסקתות3% 1508 ג": "יוגורט יופלה אפרסק ותות 3% 1.5 ק״ג",
    "יופלה לבן מעוד1.5% 1508": "יוגורט יופלה לבן מעודן 1.5% 1.5 ק״ג",
    "מאגדתRUD גלידת שמנת וניל": "מארז RUD גלידת שמנת וניל",
    "גלידת RUD שמנת פיסטוק275": "גלידת RUD שמנת פיסטוק 275 גרם",

    # Missing spaces
    "גבינה לבנהזיתים 5% 250 ג": "גבינה לבנה עם זיתים 5% 250 גרם",

    # Generic names - add details
    "ציזיקי לשתיה": "ציזיקי לשתיה 250 מ״ל",
    "קוטג' שום שמיר": "קוטג' שום ושמיר 5% 250 גרם",

    # Abbreviation fixes
    "גב.בולגרית למריחה5% 250 ג": "גבינה בולגרית למריחה 5% 250 גרם",
    "גב.עיזים שום ע.תיבול140 ג": "גבינת עיזים שום עם תיבול 140 גרם",
    "גב.צהובה נעם 9% 360 גרם": "גבינה צהובה נעם 9% 360 גרם",
    "גב.שמנת זיתים 5%גד 200 ג": "גבינת שמנת זיתים 5% גד 200 גרם",
    "ארלה גב.שמנת טעם טבעי200": "ארלה גבינת שמנת טעם טבעי 200 גרם",

    # Weird characters/formatting
    "צהובה הולנדית מחיר לפי מ": "גבינה צהובה הולנדית במשקל",
    "פודינג ט.פאי גב.לימון75 ג": "פודינג טעם פאי גבינה לימון 75 גרם",
    "עוגת גב.פירורים לייט78 גר": "עוגת גבינה פירורים לייט 78 גרם",
    "מעדןחלבוןGO שקד קרמל מלו": "מעדן חלבון GO שקד קרמל מלוח 150 גרם",
    "משקה חלב צמר גפן מתוק 1 ל": "משקה חלב צמר גפן מתוק 1 ליטר",
    "מסקרפונה עם קרמל מלוח1.2": "מסקרפונה עם קרמל מלוח 1.2 ק״ג",
    "פס גבינה מעודןאוכמנ650 ג": "פס גבינה מעודן אוכמניות 650 גרם",
    "שמנת מתוקה להקצפה32% 250": "שמנת מתוקה להקצפה 32% 250 מ״ל",
    "משולש גבינת קשקבל27%משקל": "משולש גבינת קשקבל 27% במשקל",
    "טריפל צ'דר מגורדת משקל": "גבינת צ'דר משולשת מגורדת במשקל",
    "מגורדת בסגנון מוצרלה200": "גבינה מגורדת בסגנון מוצרלה 200 גרם",
    "תבור גבינה לאפיה5% 500 ג": "גבינת תבור לאפיה 5% 500 גרם",
    "לאבנה גלילית 11% 750 גרם": "לבנה גלילית 11% 750 גרם",
    "קוביות בולגרית מעודנת16%": "קוביות בולגרית מעודנת 16% 200 גרם",
    "פריגורט עיזים פ.יער 500 ג": "פריגורט עיזים פירות יער 500 גרם",
    "יוגורט עיזים פ.יער 500 מל": "יוגורט עיזים פירות יער 500 מ״ל",
    "שלישיה גלית תות חלבי 99 ק": "שלישיית גלית תות חלבי 99 גרם",
}

# Icon fixes (product name -> correct icon)
ICON_FIXES = {
    "סקי מעדן גבינה וניל 125 גרם": "🍮",  # dessert, not cheese
    "סימפוניה 16% שום קונפי 200 גרם": "🧈",  # cream cheese, not milk
    "קרם פטיסייר 250 גרם": "🍮",  # pastry cream = dessert
    "גב.עיזים שום ע.תיבול140 ג": "🧀",  # cheese, not milk
}

def fix_name(name: str) -> str:
    """Apply all name fixes"""
    # First check for exact match
    if name in NAME_FIXES:
        return NAME_FIXES[name]

    result = name

    # Apply abbreviation expansions
    for abbr, full in ABBREVIATIONS.items():
        result = result.replace(abbr, full)

    # Fix missing space before percentage (e.g., "5%" -> " 5%")
    result = re.sub(r'(\D)(\d+%)', r'\1 \2', result)

    # Fix double spaces
    result = re.sub(r'  +', ' ', result)

    return result.strip()

def fix_icon(product: dict) -> str:
    """Fix icon if needed"""
    name = product.get('name', '')
    if name in ICON_FIXES:
        return ICON_FIXES[name]
    return product.get('icon', '📦')

def main():
    # Load
    with open(DAIRY_FILE, 'r', encoding='utf-8') as f:
        products = json.load(f)

    changes = []

    for product in products:
        old_name = product.get('name', '')
        new_name = fix_name(old_name)

        old_icon = product.get('icon', '')
        new_icon = fix_icon(product)

        if new_name != old_name:
            changes.append(f"NAME: {old_name} -> {new_name}")
            product['name'] = new_name

        if new_icon != old_icon:
            changes.append(f"ICON: {old_name}: {old_icon} -> {new_icon}")
            product['icon'] = new_icon

    # Save
    with open(DAIRY_FILE, 'w', encoding='utf-8') as f:
        json.dump(products, f, ensure_ascii=False, indent=2)

    # Report to file (avoid console encoding issues)
    report_file = Path(r"c:\projects\salsheli\scripts\name_fixes_report.txt")
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(f"Total products: {len(products)}\n")
        f.write(f"Changes made: {len(changes)}\n\n")
        for change in changes:
            f.write(f"{change}\n")

    print(f"Total products: {len(products)}")
    print(f"Changes made: {len(changes)}")
    print(f"Details saved to: {report_file}")

if __name__ == "__main__":
    main()
