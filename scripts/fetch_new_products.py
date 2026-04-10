#!/usr/bin/env python3
"""
fetch_new_products.py — Pull new products from Open Israeli Supermarkets
and save only products NOT in the existing catalog.

Output: assets/data/list_types/new_products.json
        (or merged directly into supermarket.json with --merge)

Usage:
  1. Install dependencies:
     pip install il-supermarket-scraper il-supermarket-parser pandas

  2. Run (from project root):
     # Safe mode — saves new products to a separate file for review:
     python scripts/fetch_new_products.py

     # Auto-merge mode — adds new products directly into supermarket.json
     # (creates a timestamped backup first, asks for confirmation):
     python scripts/fetch_new_products.py --merge

     # Skip the confirmation prompt (still creates backup):
     python scripts/fetch_new_products.py --merge --yes

  3. (Without --merge) Review new_products.json, then merge manually

Notes:
  - Downloads PricesFull XML files from ALL major Israeli chains
  - Supported chains: Shufersal, Rami Levy, Yochananof, Victory,
    Osher Ad, Yeinot Bitan, and more (all chains in il-supermarket-scraper)
  - Compares by barcode (with leading-zero normalization) AND name
  - --merge: applies smart auto-categorization, creates backup, asks before write
  - Some scraper sites are geo-blocked outside Israel
  - Use --chains flag to select specific chains
"""

import argparse
import datetime
import json
import os
import re
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

# ════════════════════════════════════════════
# CONFIGURATION
# ════════════════════════════════════════════

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LIST_TYPES_DIR = PROJECT_ROOT / 'assets' / 'data' / 'list_types'
OUTPUT_FILE = LIST_TYPES_DIR / 'new_products.json'
DUMPS_FOLDER = PROJECT_ROOT / 'scripts' / 'dumps'

# All catalog files to check against
CATALOG_FILES = [
    'supermarket.json',
    'market.json',
    'pharmacy.json',
    'butcher.json',
    'greengrocer.json',
    'bakery.json',
]

# Chains to scrape — None = ALL chains, or specify list
# Available (run `python -c "from il_supermarket_scarper import ScraperFactory; print(ScraperFactory.all_scrapers_name())"`)
# Common: SHUFERSAL, RAMI_LEVY, YOCHANANOF, VICTORY, OSHER_AD, YAYNO_BITAN, BAREKET, etc.
ENABLED_SCRAPERS = None  # None = all chains (maximum product coverage)

# ════════════════════════════════════════════
# STEP 1: Load existing catalog barcodes
# ════════════════════════════════════════════

def load_existing_barcodes():
    """Load all barcodes from all catalog files."""
    barcodes = set()
    names = set()
    total_products = 0

    for fname in CATALOG_FILES:
        fpath = LIST_TYPES_DIR / fname
        if not fpath.exists():
            print(f'  ⚠️ Not found: {fname}')
            continue

        with open(fpath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        count = 0
        for item in data:
            bc = item.get('barcode')
            if bc:
                barcodes.add(str(bc).strip())
                count += 1
            name = item.get('name', '').strip().lower()
            if name:
                names.add(name)

        total_products += len(data)
        print(f'  📄 {fname}: {len(data)} products, {count} barcodes')

    print(f'📦 Total across all catalogs: {total_products} products, {len(barcodes)} unique barcodes, {len(names)} unique names')
    return barcodes, names


# ════════════════════════════════════════════
# STEP 2: Download Shufersal data
# ════════════════════════════════════════════

def download_supermarket_data(chains=None, limit=3):
    """Download PricesFull XML files from Israeli supermarkets using il-supermarket-scraper."""
    try:
        from il_supermarket_scarper import ScarpingTask
        from il_supermarket_scarper.scrappers_factory import ScraperFactory
    except ImportError:
        print('❌ il-supermarket-scraper not installed.')
        print('   Run: pip install il-supermarket-scraper')
        sys.exit(1)

    os.makedirs(DUMPS_FOLDER, exist_ok=True)

    # Show available chains
    all_chains = ScraperFactory.all_scrapers_name()
    if chains:
        selected = chains
        print(f'\n🔄 Downloading from {len(selected)} chains: {", ".join(selected)}')
    else:
        selected = None  # All chains
        print(f'\n🔄 Downloading from ALL {len(all_chains)} chains:')
        for c in all_chains:
            print(f'   • {c}')

    print(f'\n   Limit: {limit} files per chain')
    print(f'   Output: {DUMPS_FOLDER}')
    print('   (This may take several minutes...)')

    try:
        # il-supermarket-scraper >= 1.0.0 API:
        #  - dump_folder_name was removed; use output_configuration / status_configuration
        #  - limit moved from __init__ to start(limit=...)
        #  - must call .join() to wait for the background thread
        scraper = ScarpingTask(
            enabled_scrapers=selected,
            files_types=['PRICE_FULL_FILE'],  # Full product catalog with barcodes
            output_configuration={
                'output_mode': 'disk',
                'base_storage_path': str(DUMPS_FOLDER),
            },
            status_configuration={
                'database_type': 'json',
                'base_path': str(DUMPS_FOLDER / 'status'),
            },
        )
        scraper.start(limit=limit)
        scraper.join()
        print('✅ Download complete')
    except Exception as e:
        print(f'⚠️ Download error: {e}')
        print('   Note: Some sites are geo-blocked outside Israel')
        print('   Trying to parse any existing dumps...')


# ════════════════════════════════════════════
# STEP 3: Parse XML files to extract products
# ════════════════════════════════════════════

def parse_shufersal_xml(dumps_folder):
    """Parse PricesFull XML files to extract products."""
    products = {}  # barcode → product dict

    xml_files = list(Path(dumps_folder).rglob('*.xml')) + \
                list(Path(dumps_folder).rglob('*.gz'))

    if not xml_files:
        print(f'⚠️ No XML files found in {dumps_folder}')
        return products

    print(f'\n📄 Parsing {len(xml_files)} XML files...')

    for xml_file in xml_files:
        try:
            # Handle gzipped files
            if str(xml_file).endswith('.gz'):
                import gzip
                with gzip.open(xml_file, 'rb') as f:
                    content = f.read()
                root = ET.fromstring(content)
            else:
                tree = ET.parse(xml_file)
                root = tree.getroot()

            # Find all Item/Product elements
            for item in root.iter():
                if item.tag in ('Item', 'Product'):
                    barcode = None
                    name = None
                    price = None
                    unit = None
                    manufacturer = None

                    for child in item:
                        tag = child.tag.lower().replace('_', '')
                        text = (child.text or '').strip()

                        if tag in ('itemcode', 'barcode', 'code'):
                            barcode = text
                        elif tag in ('itemname', 'name', 'productname'):
                            name = text
                        elif tag in ('itemprice', 'price', 'unitprice'):
                            try:
                                price = float(text)
                            except (ValueError, TypeError):
                                pass
                        elif tag in ('unitofmeasure', 'unit', 'unitqty'):
                            unit = text
                        elif tag in ('manufacturername', 'manufacturer', 'brand'):
                            manufacturer = text

                    if barcode and name and len(barcode) >= 7:
                        if barcode not in products:
                            products[barcode] = {
                                'name': name,
                                'barcode': barcode,
                                'price': price,
                                'unit': unit or "יח'",
                                'brand': manufacturer,
                                'category': None,  # Will need manual categorization
                                'source': 'open-israeli-supermarkets'
                            }

        except Exception as e:
            print(f'  ⚠️ Error parsing {xml_file.name}: {e}')
            continue

    print(f'  Found {len(products)} unique products')
    return products


# ════════════════════════════════════════════
# STEP 4: Alternative — Parse from CSV (Kaggle)
# ════════════════════════════════════════════

def parse_kaggle_csv(csv_folder):
    """Parse CSV files from Kaggle dataset (alternative to scraping)."""
    try:
        import pandas as pd
    except ImportError:
        print('❌ pandas not installed. Run: pip install pandas')
        return {}

    products = {}
    csv_files = list(Path(csv_folder).rglob('*.csv'))

    if not csv_files:
        print(f'⚠️ No CSV files found in {csv_folder}')
        return products

    print(f'\n📄 Parsing {len(csv_files)} CSV files...')

    for csv_file in csv_files:
        try:
            df = pd.read_csv(csv_file, encoding='utf-8', low_memory=False)

            # Try to find relevant columns
            barcode_col = None
            name_col = None
            price_col = None
            brand_col = None

            for col in df.columns:
                col_lower = col.lower()
                if 'barcode' in col_lower or 'itemcode' in col_lower or 'code' in col_lower:
                    barcode_col = col
                elif 'name' in col_lower or 'itemname' in col_lower:
                    name_col = col
                elif 'price' in col_lower:
                    price_col = col
                elif 'manufacturer' in col_lower or 'brand' in col_lower:
                    brand_col = col

            if not barcode_col or not name_col:
                continue

            for _, row in df.iterrows():
                barcode = str(row.get(barcode_col, '')).strip()
                name = str(row.get(name_col, '')).strip()

                if barcode and name and len(barcode) >= 7 and barcode != 'nan':
                    if barcode not in products:
                        price = None
                        if price_col:
                            try:
                                price = float(row[price_col])
                            except (ValueError, TypeError):
                                pass

                        products[barcode] = {
                            'name': name,
                            'barcode': barcode,
                            'price': price,
                            'unit': "יח'",
                            'brand': str(row.get(brand_col, '')) if brand_col else None,
                            'category': None,
                            'source': 'kaggle-dataset'
                        }

        except Exception as e:
            print(f'  ⚠️ Error parsing {csv_file.name}: {e}')

    print(f'  Found {len(products)} unique products')
    return products


# ════════════════════════════════════════════
# STEP 5: Compare and save new products
# ════════════════════════════════════════════

def normalize_barcode(barcode):
    """Normalize a barcode for duplicate comparison.

    Strips whitespace and leading zeros so '07290016' and '7290016' compare equal.
    Empty/None becomes empty string.
    """
    if not barcode:
        return ''
    s = str(barcode).strip().lstrip('0')
    return s


def find_new_products(all_products, existing_barcodes, existing_names=None):
    """Filter out products that already exist in any catalog file.

    Comparison is barcode-normalized (leading zeros stripped) AND name-based.
    """
    existing_names = existing_names or set()
    existing_norm_barcodes = {normalize_barcode(b) for b in existing_barcodes}

    new_products = []
    for barcode, product in all_products.items():
        norm = normalize_barcode(barcode)
        if norm and norm in existing_norm_barcodes:
            continue
        name = product.get('name', '').strip().lower()
        if name and name in existing_names:
            continue
        new_products.append(product)

    # Sort by name
    new_products.sort(key=lambda p: p.get('name', ''))
    return new_products


# ════════════════════════════════════════════
# AUTO-CATEGORIZATION (used by --merge)
# ════════════════════════════════════════════
#
# Same high-confidence rules used to fix the existing catalog.
# Format: (regex, exclude_regex_or_None, target_category, description)
# First matching rule wins. Products that match nothing get DEFAULT_CATEGORY.

DEFAULT_CATEGORY = 'כללי'

CATEGORIZATION_RULES = [
    # ===== Personal Hygiene (היגיינה אישית) =====
    (r'משחת שיניים', None, 'היגיינה אישית', 'toothpaste'),
    (r'מברשת שיניים|מברשות שיניים', None, 'היגיינה אישית', 'toothbrush'),
    (r'מי\s*פה(?!\s*ל)', None, 'היגיינה אישית', 'mouthwash'),
    (r'שטיפת פה', None, 'היגיינה אישית', 'mouthwash'),
    (r'חוט דנטלי', None, 'היגיינה אישית', 'dental floss'),
    (r'דאודורנט|דיאודורנט|דאו רול|דיאו רול', None, 'היגיינה אישית', 'deodorant'),
    (r'תחבושות? היגיינ|טמפון', None, 'היגיינה אישית', 'feminine hygiene'),
    (r'נייר טואלט', None, 'היגיינה אישית', 'toilet paper'),
    (r"קצף גילוח|ג'ל גילוח|מכונת גילוח|סכיני גילוח|סכין גילוח|להבי גילוח", None, 'היגיינה אישית', 'shaving'),
    (r'שמפו', r'לרכב|לכלב|לחתול|לחיות|רכב|שמפו קוקוס', 'היגיינה אישית', 'shampoo'),
    (r'מרכך שיער', None, 'היגיינה אישית', 'hair conditioner'),
    (r'אל[\s־-]?סבון', None, 'היגיינה אישית', 'liquid hand soap'),
    (r"ג'ל רחצה|תחפיף|תחליב רחצה", None, 'היגיינה אישית', 'shower gel'),

    # ===== Cosmetics (קוסמטיקה וטיפוח) =====
    (r'צבע שיער|צבע לשיער|אקסלנס.*צבע', None, 'קוסמטיקה וטיפוח', 'hair dye'),
    (r'שפתון', None, 'קוסמטיקה וטיפוח', 'lipstick'),
    (r'גלוס לשפתיים', None, 'קוסמטיקה וטיפוח', 'lip gloss'),
    (r'מסקרה|אייליינר|איילינר', None, 'קוסמטיקה וטיפוח', 'eye makeup'),
    (r'(?<!\S)פנקייק(?!\S)', r'תערובת|להכנת|פנקייקים|קפוא|כשל', 'קוסמטיקה וטיפוח', 'pancake makeup'),
    (r'(?<!\S)בלאש(?!\S)', r'תערובת|להכנת', 'קוסמטיקה וטיפוח', 'blush'),
    (r'לק לציפורניים|לק ציפורניים|מסיר לק', None, 'קוסמטיקה וטיפוח', 'nail polish'),
    (r'(?<!\S)בושם(?!\S)|(?<!\S)בשמים(?!\S)|או דה טואלט|או דה פרפיום', None, 'קוסמטיקה וטיפוח', 'perfume'),

    # ===== Cleaning (מוצרי ניקיון) =====
    (r'אקונומיקה|אקונומיק', None, 'מוצרי ניקיון', 'bleach'),
    (r'מרכך כביסה', None, 'מוצרי ניקיון', 'fabric softener'),
    (r"אבקת כביסה|ג'ל כביסה|קפסולות כביסה|טבליות כביסה", None, 'מוצרי ניקיון', 'laundry detergent'),
    (r'מטהר אוויר|מטהר אויר', None, 'מוצרי ניקיון', 'air freshener'),
    (r'שקיות זבל|שקית זבל', None, 'מוצרי ניקיון', 'trash bags'),
    (r'מגבוני רצפה|מגבונים? לרצפה', None, 'מוצרי ניקיון', 'floor wipes'),

    # ===== Household items (מוצרי בית) =====
    (r'נייר אפייה', None, 'מוצרי בית', 'parchment paper'),
    (r'נייר כסף|נייר אלומיניום', None, 'מוצרי בית', 'foil'),
    (r'ניילון נצמד', None, 'מוצרי בית', 'plastic wrap'),
    (r'נרות שבת', None, 'מוצרי בית', 'shabbat candles'),
    (r'צלחות.*קנה סוכר|כוסות.*קנה סוכר|סכ.*קנה סוכר', None, 'מוצרי בית', 'sugar cane disposables'),
    (r'^צלחות (חד|ענקיות|פלסטיק|נייר|גדול)|^כוסות (חד|פלסטיק|נייר|חמות)|^סכו"ם חד', None, 'מוצרי בית', 'disposables'),
    (r'כוסות נייר', None, 'מוצרי בית', 'paper cups'),

    # ===== Baby (מוצרי תינוקות) =====
    (r'^חיתולים|^חיתולי|חיתולי האגיס|חיתולי בייביסיטר|חיתולי הגיס|פרמיום חיתולים', None, 'מוצרי תינוקות', 'diapers'),
    (r'^טיטולים|טיטולי האגיס', None, 'מוצרי תינוקות', 'diapers'),
    (r'מטרנה|סימילק|תחליף חלב אם|תרכובת מזון לתינוק', None, 'מוצרי תינוקות', 'baby formula'),

    # ===== Pet food (מזון לחיות מחמד) =====
    (r'מזון לכלב|מזון לחתול|מזון לכלבים|מזון לחתולים|אוכל לכלב|אוכל לחתול', None, 'מזון לחיות מחמד', 'pet food'),
    (r'חטיף לכלב|חטיפים לכלב|חטיף לחתול|חטיפים לחתול', None, 'מזון לחיות מחמד', 'pet treats'),
    (r'חול לחתול|חול חתולים', None, 'מזון לחיות מחמד', 'cat litter'),
]

_compiled_rules = None


def _get_compiled_rules():
    global _compiled_rules
    if _compiled_rules is None:
        _compiled_rules = [
            (re.compile(p), re.compile(e) if e else None, c, d)
            for p, e, c, d in CATEGORIZATION_RULES
        ]
    return _compiled_rules


def categorize_product(name):
    """Apply categorization rules to a product name.

    Returns the matched category, or DEFAULT_CATEGORY if no rule matches.
    """
    if not name:
        return DEFAULT_CATEGORY
    for pattern, exclude, target_cat, _desc in _get_compiled_rules():
        if pattern.search(name):
            if exclude and exclude.search(name):
                continue
            return target_cat
    return DEFAULT_CATEGORY


# ════════════════════════════════════════════
# BACKUP & MERGE (used by --merge)
# ════════════════════════════════════════════

def backup_catalog(catalog_path):
    """Create a timestamped backup of a catalog file.

    Returns the backup file path.
    """
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d-%H%M')
    backup_path = catalog_path.with_name(
        f'{catalog_path.stem}.backup-{timestamp}{catalog_path.suffix}'
    )
    shutil.copy2(catalog_path, backup_path)
    return backup_path


def merge_into_catalog(new_products, catalog_path, assume_yes=False):
    """Merge new_products into supermarket.json with safety checks.

    Steps:
      1. Auto-categorize each new product
      2. Print categorization breakdown
      3. Create timestamped backup
      4. Confirm with user (unless assume_yes)
      5. Append products and write
    """
    if not catalog_path.exists():
        print(f'❌ Catalog file not found: {catalog_path}')
        return False

    # Load existing catalog
    with open(catalog_path, 'r', encoding='utf-8') as f:
        catalog = json.load(f)
    before_count = len(catalog)

    # Auto-categorize
    print('\n🤖 מסווג אוטומטית לפי כללים:')
    cat_counts = {}
    enriched = []
    for product in new_products:
        # Make a shallow copy so we don't mutate the new_products list
        item = dict(product)
        # Only override category if it's None/missing/empty
        if not item.get('category'):
            item['category'] = categorize_product(item.get('name', ''))
        cat = item['category']
        cat_counts[cat] = cat_counts.get(cat, 0) + 1
        enriched.append(item)

    # Sort categories: known categories first by count, default last
    sorted_cats = sorted(
        cat_counts.items(),
        key=lambda kv: (kv[0] == DEFAULT_CATEGORY, -kv[1])
    )
    for cat, n in sorted_cats:
        marker = '  ⚠️ ' if cat == DEFAULT_CATEGORY else '   • '
        label = f'{cat} (ללא סיווג)' if cat == DEFAULT_CATEGORY else cat
        print(f'{marker}{label}: {n}')

    auto_cnt = sum(n for c, n in cat_counts.items() if c != DEFAULT_CATEGORY)
    default_cnt = cat_counts.get(DEFAULT_CATEGORY, 0)
    print(f'\n   סווגו אוטומטית: {auto_cnt} | נשארו "כללי": {default_cnt}')

    # Backup
    backup_path = backup_catalog(catalog_path)
    print(f'\n💾 גיבוי נשמר: {backup_path.name}')

    # Confirmation
    after_count = before_count + len(enriched)
    print(f'\n🚨 עומד להוסיף {len(enriched)} מוצרים ל-{catalog_path.name}')
    print(f'   לפני: {before_count} → אחרי: {after_count}')

    if not assume_yes:
        try:
            answer = input('   להמשיך? [y/N]: ').strip().lower()
        except EOFError:
            answer = ''
        if answer not in ('y', 'yes'):
            print('\n❌ בוטל. לא בוצעו שינויים בקטלוג.')
            print(f'   הגיבוי נשאר ב: {backup_path}')
            return False

    # Append and write
    catalog.extend(enriched)
    with open(catalog_path, 'w', encoding='utf-8') as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)

    print(f'\n✅ נכנסו {len(enriched)} מוצרים')
    print(f'📦 {catalog_path.name}: {before_count} → {after_count}')
    print(f'💾 גיבוי: {backup_path.name}')
    return True


def save_new_products(new_products):
    """Save new products to output file."""
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(new_products, f, ensure_ascii=False, indent=2)

    print(f'\n✅ Saved {len(new_products)} new products to:')
    print(f'   {OUTPUT_FILE}')
    print(f'\n📝 Next steps:')
    print(f'   1. Review new_products.json')
    print(f'   2. Add categories manually or with categorization script')
    print(f'   3. Merge into supermarket.json when ready')


# ════════════════════════════════════════════
# MAIN
# ════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(description='Fetch new products from Israeli supermarkets')
    parser.add_argument('--chains', nargs='+', help='Specific chains (e.g., SHUFERSAL RAMI_LEVY). Default: all')
    parser.add_argument('--limit', type=int, default=3, help='Max files per chain (default: 3)')
    parser.add_argument('--skip-download', action='store_true', help='Skip download, parse existing dumps')
    parser.add_argument('--kaggle', type=str, help='Path to Kaggle CSV folder (alternative to scraping)')
    parser.add_argument('--list-chains', action='store_true', help='List available chain names and exit')
    parser.add_argument('--merge', action='store_true', help='Auto-merge new products into supermarket.json (creates backup)')
    parser.add_argument('--yes', '-y', action='store_true', help='Skip confirmation prompt when using --merge')
    args = parser.parse_args()

    print('═' * 55)
    print('🛒 Fetch New Products — Open Israeli Supermarkets')
    print('═' * 55)

    # List chains mode
    if args.list_chains:
        try:
            from il_supermarket_scarper.scrappers_factory import ScraperFactory
            print('\nAvailable chains:')
            for c in ScraperFactory.all_scrapers_name():
                print(f'  • {c}')
        except ImportError:
            print('❌ Install first: pip install il-supermarket-scraper')
        sys.exit(0)

    # Load existing barcodes and names from all catalog files
    existing_barcodes, existing_names = load_existing_barcodes()

    # Try to download and parse
    all_products = {}

    # Option 1: Kaggle CSV
    if args.kaggle:
        print(f'\n📦 Using Kaggle CSV data from {args.kaggle}...')
        all_products = parse_kaggle_csv(Path(args.kaggle))

    # Option 2: Scraper
    if not all_products:
        try:
            if not args.skip_download:
                download_supermarket_data(chains=args.chains, limit=args.limit)
            all_products = parse_shufersal_xml(DUMPS_FOLDER)
        except Exception as e:
            print(f'⚠️ Scraper failed: {e}')

    # Option 2: Try Kaggle CSV (if available)
    kaggle_folder = PROJECT_ROOT / 'scripts' / 'kaggle_data'
    if not all_products and kaggle_folder.exists():
        print('\n📦 Trying Kaggle CSV data...')
        all_products = parse_kaggle_csv(kaggle_folder)

    if not all_products:
        print('\n❌ No product data found.')
        print('\nOptions:')
        print('  1. Run from Israel (scraper sites are geo-blocked)')
        print('  2. Download Kaggle dataset manually:')
        print('     kaggle datasets download -d erlichsefi/israeli-supermarkets-2024')
        print(f'     Extract to: {kaggle_folder}/')
        print('  3. Place PricesFull XML files in:')
        print(f'     {DUMPS_FOLDER}/')
        sys.exit(1)

    # Find new products (check against all catalog files)
    new_products = find_new_products(all_products, existing_barcodes, existing_names)

    print(f'\n📊 Results:')
    print(f'   API products:      {len(all_products)}')
    print(f'   Already in catalog: {len(all_products) - len(new_products)}')
    print(f'   NEW products:      {len(new_products)}')

    if new_products:
        # Show sample
        print(f'\n📋 Sample new products:')
        for p in new_products[:10]:
            print(f'   {p["barcode"]} — {p["name"]}')
        if len(new_products) > 10:
            print(f'   ... +{len(new_products) - 10} more')

        if args.merge:
            # Auto-merge directly into supermarket.json
            catalog_path = LIST_TYPES_DIR / 'supermarket.json'
            merge_into_catalog(new_products, catalog_path, assume_yes=args.yes)
        else:
            # Safe mode — write to a separate review file
            save_new_products(new_products)
    else:
        print('\n✅ No new products found — catalog is up to date!')


if __name__ == '__main__':
    main()
