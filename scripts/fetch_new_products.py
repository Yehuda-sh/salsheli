#!/usr/bin/env python3
"""
fetch_new_products.py — Pull new products from Open Israeli Supermarkets
and save only products NOT in the existing catalog.

Output: assets/data/list_types/new_products.json

Usage:
  1. Install dependencies:
     pip install il-supermarket-scraper il-supermarket-parser pandas

  2. Run (from project root):
     python scripts/fetch_new_products.py

  3. Review new_products.json, then merge what you want into supermarket.json

Notes:
  - Downloads PricesFull XML files from ALL major Israeli chains
  - Supported chains: Shufersal, Rami Levy, Yochananof, Victory,
    Osher Ad, Yeinot Bitan, and more (all chains in il-supermarket-scraper)
  - Compares by barcode against existing supermarket.json
  - Only saves products with NEW barcodes
  - Does NOT modify supermarket.json
  - Some scraper sites are geo-blocked outside Israel
  - Use --chains flag to select specific chains
"""

import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

# ════════════════════════════════════════════
# CONFIGURATION
# ════════════════════════════════════════════

PROJECT_ROOT = Path(__file__).resolve().parent.parent
EXISTING_CATALOG = PROJECT_ROOT / 'assets' / 'data' / 'list_types' / 'supermarket.json'
OUTPUT_FILE = PROJECT_ROOT / 'assets' / 'data' / 'list_types' / 'new_products.json'
DUMPS_FOLDER = PROJECT_ROOT / 'scripts' / 'dumps'

# Chains to scrape — None = ALL chains, or specify list
# Available (run `python -c "from il_supermarket_scarper import ScraperFactory; print(ScraperFactory.all_scrapers_name())"`)
# Common: SHUFERSAL, RAMI_LEVY, YOCHANANOF, VICTORY, OSHER_AD, YAYNO_BITAN, BAREKET, etc.
ENABLED_SCRAPERS = None  # None = all chains (maximum product coverage)

# ════════════════════════════════════════════
# STEP 1: Load existing catalog barcodes
# ════════════════════════════════════════════

def load_existing_barcodes():
    """Load all barcodes from the existing catalog."""
    if not EXISTING_CATALOG.exists():
        print(f'❌ Catalog not found: {EXISTING_CATALOG}')
        sys.exit(1)

    with open(EXISTING_CATALOG, 'r', encoding='utf-8') as f:
        data = json.load(f)

    barcodes = set()
    for item in data:
        bc = item.get('barcode')
        if bc:
            barcodes.add(str(bc).strip())

    print(f'📦 Existing catalog: {len(data)} products, {len(barcodes)} unique barcodes')
    return barcodes


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
        scraper = ScarpingTask(
            dump_folder_name=str(DUMPS_FOLDER),
            enabled_scrapers=selected,
            files_types=['PriceFull'],  # Full product catalog with barcodes
            limit=limit,
        )
        scraper.start()
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

def find_new_products(all_products, existing_barcodes):
    """Filter out products that already exist in the catalog."""
    new_products = []
    for barcode, product in all_products.items():
        if barcode not in existing_barcodes:
            new_products.append(product)

    # Sort by name
    new_products.sort(key=lambda p: p.get('name', ''))
    return new_products


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

    # Load existing barcodes
    existing_barcodes = load_existing_barcodes()

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

    # Find new products
    new_products = find_new_products(all_products, existing_barcodes)

    print(f'\n📊 Results:')
    print(f'   API products:      {len(all_products)}')
    print(f'   Already in catalog: {len(all_products) - len(new_products)}')
    print(f'   NEW products:      {len(new_products)}')

    if new_products:
        save_new_products(new_products)

        # Show sample
        print(f'\n📋 Sample new products:')
        for p in new_products[:10]:
            print(f'   {p["barcode"]} — {p["name"]}')
        if len(new_products) > 10:
            print(f'   ... +{len(new_products) - 10} more')
    else:
        print('\n✅ No new products found — catalog is up to date!')


if __name__ == '__main__':
    main()
