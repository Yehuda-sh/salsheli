#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix all category JSON files - comprehensive cleanup
- Fix abbreviations
- Fix missing spaces
- Fix unit inconsistencies
- Fix generic icons
- Remove newlines from brand field
- Move misplaced products from other.json
"""

import json
import re
from pathlib import Path

CATEGORIES_DIR = Path(r"c:\projects\salsheli\assets\data\list_types\categories")

# === 1. ABBREVIATION FIXES ===
ABBREVIATION_FIXES = {
    # Common abbreviations
    'גב.': 'גבינת ',
    'יוג.': 'יוגורט ',
    'ח.': 'חומץ ',
    'מ.': 'מרכך ',
    'דאו.': 'דאודורנט ',
    'בק.': 'בקבוק ',
    'לחמנ.': 'לחמניות ',
    'תערוב.': 'תערובת ',
    'שומש.': 'שומשום ',
    'ש.שועל': 'שיבולת שועל ',
    'שיבול.': 'שיבולת ',
    'ל.גלוטן': 'ללא גלוטן',
    'לל״ג': 'ללא גלוטן ',
    'סובינ.': 'סוביניון ',
    'חריפ.': 'חריפות ',
    'פל.': 'פלפל ',
    'ע.תיבול': 'עם תיבול',
    'בונ.': 'בונבון ',
    'חט.': 'חטיף ',
    'מא.': 'מארז ',
    'קולקש.': 'קולקשן ',
    # Additional abbreviations found in data
    'מלפ.': 'מלפפון ',
    'רוט.': 'רוטב ',
    'עגב.': 'עגבניות ',
    'שוק.': 'שוקולד ',
    'אג.': 'אגוזי ',
    'פיר.': 'פירות ',
    'מס.': 'מסעדות ',
    # Note: 'ת.' is too ambiguous - can mean תחליב, תבנית, תמרים etc.
    # Don't include it in automatic fixes
}

# === 2. UNIT FIXES (at end of name) ===
UNIT_FIXES_END = [
    (r' גר$', ' גרם'),
    (r' ג$', ' גרם'),
    (r' מל$', ' מ״ל'),
    (r' מ$', ' מ״ל'),
    (r' ל$', ' ליטר'),
    (r' יח$', ' יחידות'),
    (r' י$', ' יחידות'),
    (r' שק$', ' שקיות'),
    (r' ש$', ' שקיות'),
]

# === 3. ICON MAPPINGS BY CATEGORY ===
CATEGORY_ICONS = {
    'beverages': {
        'default': '🥤',
        'keywords': {
            'בירה': '🍺', 'beer': '🍺', 'לאגר': '🍺', 'אייל': '🍺', 'סטאוט': '🍺',
            'יין': '🍷', 'wine': '🍷', 'קברנה': '🍷', 'מרלו': '🍷', 'שרדונה': '🍷',
            'וויסקי': '🥃', 'whisky': '🥃', 'וודקה': '🥃', 'רום': '🥃', 'ג\'ין': '🥃', 'קוניאק': '🥃',
            'מיץ': '🧃', 'juice': '🧃',
            'סודה': '🥤', 'קולה': '🥤', 'ספרייט': '🥤', 'פנטה': '🥤',
            'מים': '💧', 'water': '💧',
            'קפה': '☕', 'coffee': '☕', 'אספרסו': '☕',
            'תה': '🍵', 'tea': '🍵',
        }
    },
    'snacks': {
        'default': '🍬',
        'keywords': {
            'שוקולד': '🍫', 'chocolate': '🍫', 'מילקה': '🍫', 'קינדר': '🍫',
            'וופל': '🍫', 'wafer': '🍫', 'ופל': '🍫', 'גליליות': '🍫',
            'ביסקוויט': '🍪', 'עוגיות': '🍪', 'cookie': '🍪', 'קרקר': '🍪',
            'במבה': '🥜', 'ביסלי': '🥨', 'חטיף': '🍿',
            'מסטיק': '🍬', 'גומי': '🍬', 'סוכריות': '🍬', 'לקקן': '🍭',
            'גלידה': '🍦', 'ice cream': '🍦',
        }
    },
    'baby': {
        'default': '👶',
        'keywords': {
            'בקבוק': '🍼', 'bottle': '🍼',
            'חיתול': '👶', 'פמפרס': '👶', 'האגיס': '👶',
            'מגבונים': '🧻',
        }
    },
    'fruits': {
        'default': '🍎',
        'keywords': {
            'ענב': '🍇', 'grape': '🍇',
            'תפוז': '🍊', 'orange': '🍊', 'קלמנטינה': '🍊',
            'לימון': '🍋', 'lemon': '🍋', 'ליים': '🍋',
            'בננה': '🍌', 'banana': '🍌',
            'אבטיח': '🍉', 'watermelon': '🍉',
            'מלון': '🍈', 'melon': '🍈',
            'אפרסק': '🍑', 'peach': '🍑',
            'אגס': '🍐', 'pear': '🍐',
            'קוקוס': '🥥', 'coconut': '🥥',
            'אבוקדו': '🥑', 'avocado': '🥑',
            'פאפיה': '🍈',
        }
    },
    'vegetables': {
        'default': '🥬',
        'keywords': {
            'עגבני': '🍅', 'tomato': '🍅',
            'גזר': '🥕', 'carrot': '🥕',
            'בצל': '🧅', 'onion': '🧅',
            'שום': '🧄', 'garlic': '🧄',
            'תפוח אדמה': '🥔', 'potato': '🥔', 'תפו״א': '🥔',
            'מלפפון': '🥒', 'cucumber': '🥒',
            'פלפל': '🌶️', 'pepper': '🌶️',
            'חסה': '🥬', 'lettuce': '🥬',
            'כרוב': '🥬',
            'דלעת': '🎃',
            'חציל': '🍆', 'eggplant': '🍆',
            'תירס': '🌽', 'corn': '🌽',
            'פטריות': '🍄', 'mushroom': '🍄',
        }
    },
    'frozen': {
        'default': '❄️',
        'keywords': {
            'גלידה': '🍦', 'ice cream': '🍦', 'שלגון': '🍦',
            'פיצה': '🍕', 'pizza': '🍕',
        }
    },
    'meat_fish': {
        'default': '🥩',
        'keywords': {
            'עוף': '🍗', 'chicken': '🍗',
            'דג': '🐟', 'fish': '🐟', 'סלמון': '🐟', 'טונה': '🐟',
            'נקניק': '🌭', 'sausage': '🌭',
        }
    },
    'bakery': {
        'default': '🍞',
        'keywords': {
            'לחם': '🍞', 'bread': '🍞',
            'חלה': '🍞',
            'פיצה': '🍕',
            'עוגה': '🍰', 'cake': '🍰',
            'קרואסון': '🥐', 'croissant': '🥐',
            'בייגל': '🥯', 'bagel': '🥯',
        }
    },
    'tobacco': {
        'default': '🚬',
        'keywords': {}
    },
    'cleaning': {
        'default': '🧴',
        'keywords': {
            'כביסה': '🧺',
            'מנקה': '🧹',
        }
    },
    'hygiene': {
        'default': '🧴',
        'keywords': {
            'שמפו': '🧴',
            'סבון': '🧼', 'soap': '🧼',
            'משחת שיניים': '🪥',
            'מברשת': '🪥',
        }
    },
}

# === 4. MOVE RULES for other.json ===
MOVE_RULES = {
    'tobacco': [
        # Hebrew names
        'אל אם', 'אל די', 'וינסטון', 'נקסט', 'גולף', 'טיים רד', 'טיים בלו',
        'פרלמנט', 'קנט', 'קמל', 'לאקי סטרייק', 'נובלס', 'מרלבורו',
        # With "חפיסה" or "פאקט"
        'חפיסה', 'פאקט',
        # English names
        'marlboro', 'winston', 'L&M', 'next', 'parliament', 'kent', 'camel'
    ],
    'hygiene': [
        'דאודורנט', 'deodorant', 'שמפו', 'shampoo', 'סבון', 'soap',
        'משחת שיניים', 'מברשת שיניים', 'גילוח', 'אפטר שייב',
        'קרם פנים', 'קרם גוף', 'קרם ידיים', 'אל תוש', 'לילי לח'
    ],
    'cleaning': [
        'אירויק', 'airwick', 'פוליש', 'מנקה', 'אקונומיקה',
        'מרכך כביסה', 'נוזל כלים', 'מרכך לחות לרצפה'
    ],
    'alcohol': [
        # Whisky and wine products
        'גלנמורנג', 'גלנפידיך', 'וויסקי', 'סוביניון', 'מאד האוס'
    ],
}

def get_icon_for_product(name: str, category_file: str) -> str:
    """Get appropriate icon based on product name and category"""
    category = category_file.replace('.json', '')
    name_lower = name.lower()

    if category not in CATEGORY_ICONS:
        return None  # Keep existing icon

    cat_config = CATEGORY_ICONS[category]

    # Check keywords
    for keyword, icon in cat_config.get('keywords', {}).items():
        if keyword in name_lower:
            return icon

    return None  # Don't change if no specific match

def fix_name(name: str) -> str:
    """Fix product name - abbreviations, spaces, units"""
    result = name

    # 1. Fix abbreviations (only at start or after space)
    for abbr, full in ABBREVIATION_FIXES.items():
        # At start of string
        if result.startswith(abbr):
            result = full + result[len(abbr):]
        # After space
        result = result.replace(' ' + abbr, ' ' + full)

    # 2. Add space before numbers (but not in dates/versions)
    # Match: letter followed by digit (not after .)
    result = re.sub(r'([א-ת])(\d)', r'\1 \2', result)

    # 3. Add space after numbers before Hebrew text
    result = re.sub(r'(\d)([א-ת])', r'\1 \2', result)

    # 4. Fix unit abbreviations at end
    for pattern, replacement in UNIT_FIXES_END:
        result = re.sub(pattern, replacement, result)

    # 5. Fix double spaces
    result = re.sub(r'\s+', ' ', result)

    # 6. Fix space before %
    result = re.sub(r'(\d)\s*%', r'\1%', result)

    # 7. Strip
    result = result.strip()

    return result

def fix_brand(brand: str) -> str:
    """Remove newlines and clean brand field"""
    if not brand:
        return brand
    return brand.strip().replace('\n', '').replace('\r', '')

def should_move_product(name: str, target_category: str) -> bool:
    """Check if product should be moved to target category"""
    name_lower = name.lower()
    keywords = MOVE_RULES.get(target_category, [])
    for keyword in keywords:
        if keyword.lower() in name_lower:
            return True
    return False

def process_category_file(filepath: Path, stats: dict) -> list:
    """Process a single category file and return updated products"""
    with open(filepath, 'r', encoding='utf-8') as f:
        products = json.load(f)

    category = filepath.stem
    updated = []

    for product in products:
        original_name = product.get('name', '')
        original_brand = product.get('brand', '')
        original_icon = product.get('icon', '')

        # Fix name
        new_name = fix_name(original_name)
        if new_name != original_name:
            stats['name_fixes'].append(f"{category}: {original_name} → {new_name}")
            product['name'] = new_name

        # Fix brand
        new_brand = fix_brand(original_brand)
        if new_brand != original_brand:
            stats['brand_fixes'].append(f"{category}: {original_brand}")
            product['brand'] = new_brand

        # Fix icon if generic
        if original_icon == '🛒':
            new_icon = get_icon_for_product(new_name, filepath.name)
            if new_icon:
                stats['icon_fixes'].append(f"{category}: {new_name}: 🛒 → {new_icon}")
                product['icon'] = new_icon

        updated.append(product)

    return updated

def process_other_json(stats: dict) -> dict:
    """Process other.json and move products to correct categories"""
    other_path = CATEGORIES_DIR / 'other.json'

    with open(other_path, 'r', encoding='utf-8') as f:
        products = json.load(f)

    # Products to keep in other.json
    keep = []
    # Products to move
    to_move = {'tobacco': [], 'hygiene': [], 'cleaning': [], 'alcohol': []}

    for product in products:
        name = product.get('name', '')
        moved = False

        for target_cat in ['tobacco', 'hygiene', 'cleaning', 'alcohol']:
            if should_move_product(name, target_cat):
                # Update category field
                if target_cat == 'tobacco':
                    product['category'] = 'טבק'
                    product['icon'] = '🚬'
                elif target_cat == 'hygiene':
                    product['category'] = 'היגיינה אישית'
                    if product.get('icon') == '🛒':
                        product['icon'] = '🧴'
                elif target_cat == 'cleaning':
                    product['category'] = 'מוצרי ניקיון'
                    if product.get('icon') == '🛒':
                        product['icon'] = '🧴'
                elif target_cat == 'alcohol':
                    product['category'] = 'משקאות אלכוהוליים'
                    product['icon'] = '🥃'

                to_move[target_cat].append(product)
                stats['moved'].append(f"other → {target_cat}: {name}")
                moved = True
                break

        if not moved:
            keep.append(product)

    return {'keep': keep, 'to_move': to_move}

def main():
    stats = {
        'name_fixes': [],
        'brand_fixes': [],
        'icon_fixes': [],
        'moved': [],
    }

    # Get all category files
    category_files = list(CATEGORIES_DIR.glob('*.json'))

    # Count before
    total_before = 0
    for f in category_files:
        with open(f, 'r', encoding='utf-8') as file:
            total_before += len(json.load(file))

    # === Step 1: Process other.json first ===
    other_result = process_other_json(stats)

    # Save remaining other.json
    other_path = CATEGORIES_DIR / 'other.json'
    # Apply fixes to remaining products
    other_products = []
    for p in other_result['keep']:
        p['name'] = fix_name(p.get('name', ''))
        p['brand'] = fix_brand(p.get('brand', ''))
        other_products.append(p)

    with open(other_path, 'w', encoding='utf-8') as f:
        json.dump(other_products, f, ensure_ascii=False, indent=2)

    # === Step 2: Add moved products to target categories ===
    for target_cat, products in other_result['to_move'].items():
        if not products:
            continue

        target_path = CATEGORIES_DIR / f'{target_cat}.json'

        if target_path.exists():
            with open(target_path, 'r', encoding='utf-8') as f:
                existing = json.load(f)
        else:
            existing = []

        # Add moved products (avoid duplicates by name)
        existing_names = {p['name'].lower() for p in existing}
        for p in products:
            if p['name'].lower() not in existing_names:
                existing.append(p)
                existing_names.add(p['name'].lower())

        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(existing, f, ensure_ascii=False, indent=2)

    # === Step 3: Process all other category files ===
    for filepath in category_files:
        if filepath.name == 'other.json':
            continue  # Already processed
        if filepath.name == 'dairy.json':
            continue  # Already fixed previously

        updated = process_category_file(filepath, stats)

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(updated, f, ensure_ascii=False, indent=2)

    # Count after
    category_files = list(CATEGORIES_DIR.glob('*.json'))
    total_after = 0
    for f in category_files:
        with open(f, 'r', encoding='utf-8') as file:
            total_after += len(json.load(file))

    # === Write report ===
    report_path = Path(r"c:\projects\salsheli\scripts\fix_report.txt")
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("=== CATEGORY FIX REPORT ===\n\n")
        f.write(f"Total products before: {total_before}\n")
        f.write(f"Total products after: {total_after}\n\n")

        f.write(f"=== NAME FIXES ({len(stats['name_fixes'])}) ===\n")
        for fix in stats['name_fixes'][:50]:  # Limit output
            f.write(f"  {fix}\n")
        if len(stats['name_fixes']) > 50:
            f.write(f"  ... and {len(stats['name_fixes']) - 50} more\n")

        f.write(f"\n=== BRAND FIXES ({len(stats['brand_fixes'])}) ===\n")
        for fix in stats['brand_fixes']:
            f.write(f"  {fix}\n")

        f.write(f"\n=== ICON FIXES ({len(stats['icon_fixes'])}) ===\n")
        for fix in stats['icon_fixes']:
            f.write(f"  {fix}\n")

        f.write(f"\n=== MOVED PRODUCTS ({len(stats['moved'])}) ===\n")
        for move in stats['moved']:
            f.write(f"  {move}\n")

    # Console summary
    print(f"Total products before: {total_before}")
    print(f"Total products after: {total_after}")
    print(f"Name fixes: {len(stats['name_fixes'])}")
    print(f"Brand fixes: {len(stats['brand_fixes'])}")
    print(f"Icon fixes: {len(stats['icon_fixes'])}")
    print(f"Moved products: {len(stats['moved'])}")
    print(f"\nFull report: {report_path}")

if __name__ == "__main__":
    main()
