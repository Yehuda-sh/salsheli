#!/usr/bin/env python3
"""
Move alcoholic products from beverages.json to alcohol.json
"""

import json
from pathlib import Path

# Paths
CATEGORIES_DIR = Path(r"c:\projects\salsheli\assets\data\list_types\categories")
BEVERAGES_FILE = CATEGORIES_DIR / "beverages.json"
ALCOHOL_FILE = CATEGORIES_DIR / "alcohol.json"
REPORT_FILE = Path(r"c:\projects\salsheli\scripts\alcohol_move_report.txt")

# Keywords to identify alcoholic products (Hebrew)
ALCOHOL_KEYWORDS = [
    'בירה',      # beer
    'יין',       # wine
    'וודקה',     # vodka
    'וויסקי',    # whisky
    'ויסקי',     # whiskey variant
    "ג'ין ",     # gin (with space to avoid false matches)
    'טקילה',     # tequila
    'רום ',      # rum (with space)
    'ליקר',      # liqueur
    'קוניאק',    # cognac
    'ברנדי',     # brandy
    'לאגר',      # lager
    'אייל',      # ale
    'סטאוט',     # stout
    'פילזנר',    # pilsner
    'בלונד',     # blonde (beer style)
    'דונקל',     # dunkel
    'ויינשטפן',  # weihenstephan
    'ויינשטיין', # weinstein
    'באדוויזר',  # budweiser
    'הייניקן',   # heineken (will filter 0% later)
    'גולדסטאר',  # goldstar
    'מכבי',      # maccabee
    'גינס',      # guinness
    'סטלה',      # stella
    'קסטיל',     # kasteel
    'קרומבאכר',  # krombacher
    'פאולנר',    # paulaner
    'אלכסנדר',   # alexander (brewery)
    'נגב',       # negev (brewery) - will check context
    'לה שוף',    # la chouffe
    'באלטיק',    # baltic
    'בלנש',      # blanche
    'בקס',       # becks
    '1664',      # beer brand
    'מרלו',      # merlot
    'קברנה',     # cabernet
    'סוביניון',  # sauvignon
    'שרדונה',    # chardonnay
    'רוזה',      # rosé (wine)
    'חצי יבש',   # semi-dry (wine term)
    'יבש 750',   # dry 750ml (wine)
    'לקידוש',    # for kiddush (wine)
    'הר חרמון',  # har hermon (winery)
    'סגל',       # segal (winery)
    'גלבוע',     # gilboa (winery)
    'ארד',       # arad (winery)
    'ויזן',      # vizen (wine brand)
    'אימפרשן',   # impression (wine)
    'סבן הילס',  # seven hills (wine)
    'שאבלי',     # chablis
    'שפירא',     # shapira (brewery)
    'דרום',      # darom (wine)
    'מרום גליל', # merom galil (wine)
    'בילואו',    # beluga (vodka)
    'פינלנדיה',  # finlandia (vodka)
    'רוסקי',     # russian (vodka)
    'בומביי',    # bombay (gin)
    "ג'וני ווקר", # johnny walker
    'בלנטיין',   # ballantine's
    'לוך לומונד', # loch lomond
    'קוקטייל וודקה',  # vodka cocktail
    'קוקטייל בטעם רום', # rum cocktail
    'סמירנוף',   # smirnoff
]

# Products to EXCLUDE (non-alcoholic despite keywords)
EXCLUDE_PATTERNS = [
    '0% אלכוהול',  # 0% alcohol
    'ללא אלכוהול', # without alcohol
    'חומץ יין',    # wine vinegar (not alcohol)
]


def is_alcoholic(product: dict) -> bool:
    """Check if a product is alcoholic based on name"""
    name = product.get('name', '').lower()

    # Check exclusions first
    for exclude in EXCLUDE_PATTERNS:
        if exclude in name:
            return False

    # Check for alcohol keywords
    for keyword in ALCOHOL_KEYWORDS:
        if keyword in name:
            return True

    return False


def get_icon_for_product(product: dict) -> str:
    """Determine appropriate icon for alcoholic product"""
    name = product.get('name', '').lower()

    # Beer
    if any(kw in name for kw in ['בירה', 'לאגר', 'אייל', 'סטאוט', 'פילזנר', 'בלונד', 'דונקל',
                                   'ויינשטפן', 'ויינשטיין', 'באדוויזר', 'הייניקן', 'גולדסטאר',
                                   'מכבי', 'גינס', 'סטלה', 'קסטיל', 'קרומבאכר', 'פאולנר',
                                   'אלכסנדר', 'נגב', 'לה שוף', 'באלטיק', 'בלנש', 'בקס', '1664', 'שפירא']):
        return '🍺'

    # Wine
    if any(kw in name for kw in ['יין', 'מרלו', 'קברנה', 'סוביניון', 'שרדונה', 'רוזה',
                                  'חצי יבש', 'לקידוש', 'הר חרמון', 'סגל', 'גלבוע', 'ארד',
                                  'ויזן', 'אימפרשן', 'סבן הילס', 'שאבלי', 'דרום', 'מרום גליל']):
        # Red vs white vs rosé
        if 'רוזה' in name or 'רוז' in name:
            return '🍷'  # rosé
        elif 'לבן' in name or 'שרדונה' in name:
            return '🍾'  # white wine / champagne style
        else:
            return '🍷'  # red wine

    # Whisky
    if any(kw in name for kw in ['וויסקי', 'ויסקי', "ג'וני ווקר", 'בלנטיין', 'לוך לומונד']):
        return '🥃'

    # Vodka
    if any(kw in name for kw in ['וודקה', 'בילואו', 'פינלנדיה', 'רוסקי', 'סמירנוף']):
        return '🍸'

    # Gin
    if any(kw in name for kw in ["ג'ין", 'בומביי']):
        return '🍸'

    # Cocktails
    if 'קוקטייל' in name:
        return '🍹'

    # Default
    return '🍺'


def main():
    # Load files
    with open(BEVERAGES_FILE, 'r', encoding='utf-8') as f:
        beverages = json.load(f)

    with open(ALCOHOL_FILE, 'r', encoding='utf-8') as f:
        alcohol = json.load(f)

    # Get existing barcodes in alcohol.json to avoid duplicates
    existing_barcodes = {p.get('barcode') for p in alcohol if p.get('barcode')}

    # Separate alcoholic from non-alcoholic
    alcoholic_products = []
    non_alcoholic = []

    for product in beverages:
        if is_alcoholic(product):
            alcoholic_products.append(product)
        else:
            non_alcoholic.append(product)

    # Process alcoholic products
    moved_products = []
    skipped_duplicates = []

    for product in alcoholic_products:
        barcode = product.get('barcode')

        # Skip if already in alcohol.json
        if barcode and barcode in existing_barcodes:
            skipped_duplicates.append(product['name'])
            continue

        # Update category and icon
        product['category'] = 'משקאות אלכוהוליים'
        product['icon'] = get_icon_for_product(product)

        # Add to alcohol list
        alcohol.append(product)
        moved_products.append(product['name'])

        if barcode:
            existing_barcodes.add(barcode)

    # Remove duplicates from alcohol.json (by barcode)
    seen_barcodes = set()
    unique_alcohol = []
    for product in alcohol:
        barcode = product.get('barcode')
        if barcode and barcode in seen_barcodes:
            continue
        if barcode:
            seen_barcodes.add(barcode)
        unique_alcohol.append(product)

    # Sort by name
    unique_alcohol.sort(key=lambda x: x.get('name', ''))
    non_alcoholic.sort(key=lambda x: x.get('name', ''))

    # Save files
    with open(ALCOHOL_FILE, 'w', encoding='utf-8') as f:
        json.dump(unique_alcohol, f, ensure_ascii=False, indent=2)

    with open(BEVERAGES_FILE, 'w', encoding='utf-8') as f:
        json.dump(non_alcoholic, f, ensure_ascii=False, indent=2)

    # Generate report
    report = []
    report.append("=== ALCOHOL MOVE REPORT ===\n")
    report.append(f"Beverages before: {len(beverages)}")
    report.append(f"Beverages after: {len(non_alcoholic)}")
    report.append(f"Alcohol before: {len(alcohol) - len(moved_products)}")
    report.append(f"Alcohol after: {len(unique_alcohol)}")
    report.append(f"\nMoved products: {len(moved_products)}")
    report.append(f"Skipped duplicates: {len(skipped_duplicates)}")

    report.append("\n\n=== MOVED PRODUCTS ===")
    for name in sorted(moved_products):
        report.append(f"  • {name}")

    if skipped_duplicates:
        report.append("\n\n=== SKIPPED (already in alcohol.json) ===")
        for name in sorted(skipped_duplicates):
            report.append(f"  • {name}")

    report_text = "\n".join(report)

    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write(report_text)

    print(f"Done! Report saved to {REPORT_FILE}")
    print(f"Moved {len(moved_products)} products")
    print(f"Beverages: {len(beverages)} -> {len(non_alcoholic)}")
    print(f"Alcohol: {len(alcohol) - len(moved_products)} -> {len(unique_alcohol)}")


if __name__ == '__main__':
    main()
