#!/usr/bin/env python3
"""
🧹 ניקוי נתוני מוצרים — assets/data/list_types/
- הסרת כפולות
- חילוץ size מהשם
- הסרת שדה icon
- אחידות מבנה (brand, size)
- תיקון רווחים חסרים
"""

import json
import re
import os
import sys

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'list_types')

FILES = ['supermarket.json', 'market.json', 'bakery.json', 'butcher.json', 'greengrocer.json', 'pharmacy.json']

# Pattern to extract size from name
# Matches: number (with optional decimal) + unit
SIZE_UNITS = r"(?:גרם|גר\'?|ג\'?|מ\"ל|מ\"ג|מל|ליטר|ק\"ג|קג|ק\'ג|יחידות|יחידה|טבליות|שקיות|קפסולות|גלילים|מטר|מ׳|מ\"ר)"
SIZE_PATTERN = re.compile(
    r'(\d+(?:\.\d+)?)\s*[xX×]\s*(\d+(?:\.\d+)?)\s*' + SIZE_UNITS + r'|'  # 10X81.6 גרם
    r'(\d+(?:\.\d+)?)\s*' + SIZE_UNITS + r'\s*(\d+(?:\.\d+)?)\s*' + SIZE_UNITS + r'|'  # 500 מ"ג 20 טבליות
    r'(\d+(?:\.\d+)?)\s*' + SIZE_UNITS + r'|'  # 500 גרם
    r'(\d+(?:\.\d+)?)\s*(?:מ"ל|מל|ml|ML)'  # 500 מ"ל or 500ml
)

def extract_size(name):
    """Extract size info from product name, return (clean_name, size)"""
    # Try to find size pattern
    # More specific pattern that captures the full size string
    patterns = [
        # "10X81.6 גרם" or "4X37.5 גרם"  
        re.compile(r'\s*(\d+(?:\.\d+)?\s*[xX×]\s*\d+(?:\.\d+)?\s*' + SIZE_UNITS + r')\s*$'),
        # "500 מ"ג 20 טבליות" (compound size)
        re.compile(r'\s*(\d+(?:\.\d+)?\s*' + SIZE_UNITS + r'\s+\d+(?:\.\d+)?\s*' + SIZE_UNITS + r')\s*$'),
        # "1.56 ליטר" or "500 גרם" (simple size at end)
        re.compile(r'\s*(\d+(?:\.\d+)?\s*' + SIZE_UNITS + r')\s*$'),
        # Just a number at the end (like "12" for eggs)
        re.compile(r'\s+(\d+)\s*$'),
    ]
    
    for pattern in patterns:
        match = pattern.search(name)
        if match:
            size = match.group(1).strip()
            clean = name[:match.start()].strip()
            if clean:  # Don't return empty name
                return clean, size
    
    return name, None


def fix_spacing(name):
    """Fix missing spaces between Hebrew text and numbers"""
    # Hebrew char followed by digit without space
    name = re.sub(r'([א-ת])(\d)', r'\1 \2', name)
    # Digit followed by Hebrew char without space  
    name = re.sub(r'(\d)([א-ת])', r'\1 \2', name)
    # Fix "L" stuck to Hebrew (like "ביציםL")
    name = re.sub(r'([א-ת])([A-Za-z])', r'\1 \2', name)
    return name


def clean_name(name):
    """Clean product name after size extraction"""
    name = name.strip()
    # Remove trailing dots, commas, dashes
    name = re.sub(r'[.,\-–]+$', '', name)
    name = name.strip()
    return name


def process_file(filepath):
    """Process a single JSON file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        products = json.load(f)
    
    original_count = len(products)
    
    # Step 1: Remove duplicates by name
    seen_names = set()
    unique_products = []
    dupes_removed = 0
    for p in products:
        name_lower = (p.get('name', '') or '').lower().strip()
        if name_lower in seen_names:
            dupes_removed += 1
            continue
        seen_names.add(name_lower)
        unique_products.append(p)
    
    # Step 2: Process each product
    sizes_extracted = 0
    cleaned = []
    for p in unique_products:
        name = p.get('name', '')
        
        # Fix spacing first
        name = fix_spacing(name)
        
        # Extract size
        name, size = extract_size(name)
        if size:
            sizes_extracted += 1
        
        # Clean name
        name = clean_name(name)
        
        # Build clean product with uniform structure
        clean_p = {
            'name': name,
            'category': p.get('category', 'אחר'),
            'price': p.get('price', 0),
            'barcode': p.get('barcode', ''),
            'brand': p.get('brand', ''),
            'unit': p.get('unit', 'יחידה'),
            'size': size,
        }
        # Remove icon, description, imageUrl (not used)
        
        cleaned.append(clean_p)
    
    # Write back
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(cleaned, f, ensure_ascii=False, indent=2)
    
    return {
        'original': original_count,
        'dupes_removed': dupes_removed,
        'sizes_extracted': sizes_extracted,
        'final': len(cleaned),
    }


def main():
    print("🧹 מתחיל ניקוי נתוני מוצרים...\n")
    
    total_stats = {'original': 0, 'dupes_removed': 0, 'sizes_extracted': 0, 'final': 0}
    
    for filename in FILES:
        filepath = os.path.join(DATA_DIR, filename)
        if not os.path.exists(filepath):
            print(f"⚠️  {filename} — לא נמצא, מדלג")
            continue
        
        stats = process_file(filepath)
        print(f"✅ {filename}:")
        print(f"   מקור: {stats['original']} → סופי: {stats['final']}")
        print(f"   כפולות שהוסרו: {stats['dupes_removed']}")
        print(f"   גדלים שחולצו: {stats['sizes_extracted']}")
        print()
        
        for k in total_stats:
            total_stats[k] += stats[k]
    
    print("=" * 40)
    print(f"📊 סה\"כ:")
    print(f"   מוצרים: {total_stats['original']} → {total_stats['final']}")
    print(f"   כפולות שהוסרו: {total_stats['dupes_removed']}")
    print(f"   גדלים שחולצו: {total_stats['sizes_extracted']}")


if __name__ == '__main__':
    main()
