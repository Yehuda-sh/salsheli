// Round C cleanup of supermarket.json — applies 8 approved fixes from the
// scan. Single pass; writes back in place.

const fs = require('fs');
const path = 'assets/data/list_types/supermarket.json';
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
const before = data.length;

const stats = {
  zeroWidthStripped: 0,
  garbageDeleted: 0,
  leadingDigitsStripped: 0,
  fakeBarcodeNulled: 0,
  trailingUnmatchedParenStripped: 0,
  leadingBracketPrefixStripped: 0,
  fakePriceNulled: 0,
};

const garbageNames = new Set([
  'באד אפל0.--7',
  'שמן סויה+--+-+-+',
]);

// Zero-width / bidi formatting chars to strip.
// U+200B-U+200F (ZWSP/ZWNJ/ZWJ/LRM/RLM)
// U+202A-U+202E (LRE/RLE/PDF/LRO/RLO)
// U+2060 (WJ), U+FEFF (BOM/ZWNBSP)
const zeroWidthRegex = /[​-‏‪-‮⁠﻿]/g;

// Fake / placeholder barcodes — runs of all the same digit (≥ 7 long).
const fakeBarcodeRegex = /^(\d)\1{6,}$/;

const filtered = [];

for (const p of data) {
  // 1. Hard-deletes — known garbage records.
  if (p.name && garbageNames.has(p.name)) {
    stats.garbageDeleted++;
    continue;
  }

  if (p.name) {
    // 2. Strip zero-width / bidi chars.
    if (zeroWidthRegex.test(p.name)) {
      p.name = p.name.replace(zeroWidthRegex, '');
      stats.zeroWidthStripped++;
    }

    // 3. Strip leading 5+ digit prefix glued to Hebrew (e.g. "42000שאיפות").
    const leadingDigits = p.name.match(/^(\d{5,})([֐-׿])/);
    if (leadingDigits) {
      p.name = p.name.slice(leadingDigits[1].length);
      stats.leadingDigitsStripped++;
    }

    // 4. Strip leading stray "(" or "[" — and a "(NN)" prefix when present.
    //    "(60)BASIC ..."  → "BASIC ..."
    //    "[מייבש כלים"     → "מייבש כלים"
    const leadingNumberedParen = p.name.match(/^\(\s*\d+\s*\)\s*/);
    if (leadingNumberedParen) {
      p.name = p.name.slice(leadingNumberedParen[0].length);
      stats.leadingBracketPrefixStripped++;
    } else if (/^\s*[\[\(]\s*(?![\d֐-׿A-Za-z])/.test(p.name)) {
      // leading "(" or "[" not followed by alphanumeric (so it is just stray)
      // — kept conservative; only strips truly orphan leading brackets
      p.name = p.name.replace(/^\s*[\[\(]\s*/, '');
      stats.leadingBracketPrefixStripped++;
    } else if (/^[\[]/.test(p.name)) {
      // leading "[" with content following (no closing) — stray
      const openCount = (p.name.match(/\[/g) || []).length;
      const closeCount = (p.name.match(/\]/g) || []).length;
      if (openCount > closeCount) {
        p.name = p.name.replace(/^\[\s*/, '');
        stats.leadingBracketPrefixStripped++;
      }
    }

    // 5. Strip trailing unmatched "(" — truncation pattern.
    //    "אובלי בלה קטן (10 יח" → "אובלי בלה קטן"
    {
      const opens = (p.name.match(/\(/g) || []).length;
      const closes = (p.name.match(/\)/g) || []).length;
      if (opens > closes) {
        // Strip from the last unmatched " (" onwards.
        const lastOpenIdx = p.name.lastIndexOf('(');
        if (lastOpenIdx > 0) {
          // Trim trailing whitespace before the (
          let cut = lastOpenIdx;
          while (cut > 0 && /\s/.test(p.name[cut - 1])) cut--;
          if (cut > 0) {
            p.name = p.name.slice(0, cut);
            stats.trailingUnmatchedParenStripped++;
          }
        }
      }
    }

    // Final trim — earlier strips may have left edge whitespace.
    p.name = p.name.trim();
  }

  // 6. Fake barcode → null (run of 7+ identical digits).
  if (p.barcode && fakeBarcodeRegex.test(p.barcode)) {
    p.barcode = null;
    stats.fakeBarcodeNulled++;
  }

  // 7. Fake / placeholder price < 0.5 ILS → null. Real consumer items don't
  //    cost less than half a shekel; values like ₪0.01 are import artifacts.
  if (typeof p.price === 'number' && p.price > 0 && p.price < 0.5) {
    p.price = null;
    stats.fakePriceNulled++;
  }

  filtered.push(p);
}

fs.writeFileSync(path, JSON.stringify(filtered, null, 2) + '\n', 'utf8');

console.log('Records before: ' + before);
console.log('Records after:  ' + filtered.length + ' (deleted: ' + (before - filtered.length) + ')');
console.log('');
console.log('| Operation | Count |');
console.log('|-----------|-------|');
console.log('| Zero-width / bidi chars stripped | ' + stats.zeroWidthStripped + ' |');
console.log('| Garbage records deleted | ' + stats.garbageDeleted + ' |');
console.log('| Leading digit prefix stripped | ' + stats.leadingDigitsStripped + ' |');
console.log('| Leading bracket prefix stripped | ' + stats.leadingBracketPrefixStripped + ' |');
console.log('| Trailing unmatched "(...$" stripped | ' + stats.trailingUnmatchedParenStripped + ' |');
console.log('| Fake barcode → null | ' + stats.fakeBarcodeNulled + ' |');
console.log('| Fake price < 0.5 → null | ' + stats.fakePriceNulled + ' |');
const total = Object.values(stats).reduce((a, b) => a + b, 0);
console.log('\nTotal record-modifications: ' + total);
