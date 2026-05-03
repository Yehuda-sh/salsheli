// Diagnostic scan for assets/data/list_types/greengrocer.json
// Read-only — does not modify the file.

const fs = require('fs');
const data = JSON.parse(
  fs.readFileSync('assets/data/list_types/greengrocer.json', 'utf8'),
);

console.log('=== Overview ===');
console.log('Total products:', data.length);

// Check structure of first item
console.log('\nSample shape:');
console.log(JSON.stringify(data[0], null, 2));

// Top categories
console.log('\n=== A. Categories ===');
const cats = {};
data.forEach((p) => (cats[p.category || '<none>'] = (cats[p.category || '<none>'] || 0) + 1));
Object.entries(cats)
  .sort((a, b) => b[1] - a[1])
  .forEach(([c, n]) => console.log('  ' + c + ': ' + n));

// Generic / off-domain categories (greengrocer should be vegetables/fruits)
const offDomain = data.filter((p) => {
  const c = p.category || '';
  return /כללי|אחר|other/i.test(c);
});
console.log('\nOff-domain categories ("כללי"/"אחר"):', offDomain.length);
offDomain.slice(0, 5).forEach((p) =>
  console.log('  • [' + p.category + '] ' + JSON.stringify(p.name)),
);

// Items in non-veg/fruit categories
const nonProduce = data.filter((p) => {
  const c = p.category || '';
  return !/ירק|פר[יו]|תבלינ|spice|veg|fruit|פרישות|עלי/i.test(c);
});
console.log('\nNon-produce categories (suspicious for a greengrocer):', nonProduce.length);
const nonProduceCatCount = {};
nonProduce.forEach((p) => (nonProduceCatCount[p.category || '<none>'] = (nonProduceCatCount[p.category || '<none>'] || 0) + 1));
Object.entries(nonProduceCatCount)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 8)
  .forEach(([c, n]) => console.log('  ' + c + ': ' + n));

console.log('\n=== B. Naming hygiene ===');

// Backticks (should be 0 after the supermarket round)
const bt = data.filter((p) => p.name && /`/.test(p.name));
console.log('Backticks: ' + bt.length);
bt.slice(0, 3).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Leading punctuation
const leadingJunk = data.filter(
  (p) => p.name && /^[\s'"`*\-.,_/\\]/.test(p.name),
);
console.log('Leading junk char: ' + leadingJunk.length);
leadingJunk.slice(0, 5).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Trailing punctuation (excluding gershayim units)
const trailingJunk = data.filter(
  (p) => p.name && /[\s,;:.\-]+$/.test(p.name) && !/['"]$/.test(p.name),
);
console.log('Trailing punct: ' + trailingJunk.length);
trailingJunk.slice(0, 5).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Multiple consecutive spaces
const ms = data.filter((p) => p.name && /  +/.test(p.name));
console.log('Multiple spaces: ' + ms.length);
ms.slice(0, 3).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Names with brackets / weird chars
const brackets = data.filter((p) => p.name && /[\(\)\[\]{}<>|]/.test(p.name));
console.log('Names with brackets/pipes: ' + brackets.length);
brackets.slice(0, 5).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Unmatched parens
const unmatched = data.filter((p) => {
  if (!p.name) return false;
  const o = (p.name.match(/\(/g) || []).length;
  const c = (p.name.match(/\)/g) || []).length;
  return o !== c;
});
console.log('Unmatched parens: ' + unmatched.length);
unmatched.slice(0, 5).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Trailing asterisks / starts with *
const asterisk = data.filter((p) => p.name && /\*/.test(p.name));
console.log('Names with asterisk: ' + asterisk.length);
asterisk.slice(0, 5).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Zero-width / bidi chars
const zw = data.filter((p) => p.name && /[​-‏‪-‮⁠﻿]/.test(p.name));
console.log('Zero-width / bidi chars: ' + zw.length);
zw.slice(0, 3).forEach((p) => console.log('  •', JSON.stringify(p.name)));

console.log('\n=== C. Length distribution ===');
const lens = {};
data.forEach((p) => {
  const l = (p.name || '').length;
  const bucket = l < 5 ? '<5' : l < 10 ? '5-9' : l < 20 ? '10-19' : l < 30 ? '20-29' : l < 40 ? '30-39' : '40+';
  lens[bucket] = (lens[bucket] || 0) + 1;
});
Object.entries(lens).forEach(([k, v]) => console.log('  ' + k + ': ' + v));

const tooShort = data.filter((p) => p.name && p.name.trim().length < 3);
console.log('\nName ≤ 2 chars: ' + tooShort.length);
tooShort.forEach((p) => console.log('  •', JSON.stringify(p.name)));

console.log('\n=== D. Brand & price ===');

const brandSet = new Set();
data.forEach((p) => p.brand && brandSet.add(p.brand));
console.log('Distinct brands:', brandSet.size);
console.log('Top 10 brands:');
const brandCount = {};
data.forEach((p) => {
  const b = p.brand || '<null>';
  brandCount[b] = (brandCount[b] || 0) + 1;
});
Object.entries(brandCount)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 10)
  .forEach(([b, n]) => console.log('  ' + b + ': ' + n));

const priceNull = data.filter((p) => p.price == null).length;
const priceZero = data.filter((p) => p.price === 0).length;
const priceLow = data.filter((p) => typeof p.price === 'number' && p.price > 0 && p.price < 0.5).length;
const priceHigh = data.filter((p) => typeof p.price === 'number' && p.price > 200).length;
console.log('\nprice = null: ' + priceNull);
console.log('price = 0: ' + priceZero);
console.log('price 0 < x < 0.5 (placeholder): ' + priceLow);
console.log('price > 200 (greengrocer ceiling check): ' + priceHigh);
data
  .filter((p) => typeof p.price === 'number' && p.price > 200)
  .slice(0, 5)
  .forEach((p) => console.log('  • ₪' + p.price + ' — ' + JSON.stringify(p.name)));

console.log('\n=== E. Barcode anomalies ===');
const noBarcode = data.filter((p) => !p.barcode);
console.log('barcode missing/null: ' + noBarcode.length);
const badLen = data.filter(
  (p) => p.barcode && ![8, 12, 13, 14].includes(p.barcode.length),
);
console.log('Barcode wrong length: ' + badLen.length);
badLen.slice(0, 8).forEach((p) =>
  console.log('  • bc="' + p.barcode + '" (len ' + p.barcode.length + ') — ' + JSON.stringify(p.name)),
);
const repeat = data.filter((p) => p.barcode && /^(\d)\1{6,}$/.test(p.barcode));
console.log('All-same-digit barcode: ' + repeat.length);
const nonNumeric = data.filter((p) => p.barcode && !/^\d+$/.test(p.barcode));
console.log('Non-numeric barcode: ' + nonNumeric.length);
nonNumeric.slice(0, 5).forEach((p) =>
  console.log('  • bc="' + p.barcode + '" — ' + JSON.stringify(p.name)),
);

console.log('\n=== F. Duplicates ===');
const byName = {};
data.forEach((p) => {
  const n = (p.name || '').trim();
  byName[n] = (byName[n] || []);
  byName[n].push(p);
});
const dupNames = Object.entries(byName).filter(([n, arr]) => arr.length > 1);
console.log('Duplicate names:', dupNames.length, '(total dup records:', dupNames.reduce((a, [_, arr]) => a + arr.length - 1, 0), ')');
dupNames.slice(0, 5).forEach(([n, arr]) =>
  console.log('  • "' + n + '" × ' + arr.length + ' (barcodes: ' + arr.map((p) => p.barcode).join(', ') + ')'),
);

const byBarcode = {};
data.forEach((p) => {
  if (!p.barcode) return;
  byBarcode[p.barcode] = (byBarcode[p.barcode] || []);
  byBarcode[p.barcode].push(p);
});
const dupBc = Object.entries(byBarcode).filter(([bc, arr]) => arr.length > 1);
console.log('\nDuplicate barcodes:', dupBc.length);
dupBc.slice(0, 5).forEach(([bc, arr]) =>
  console.log('  • bc=' + bc + ' × ' + arr.length + ' — names: ' + arr.map((p) => '"' + p.name + '"').join(', ')),
);

console.log('\n=== G. Greengrocer-specific sanity ===');

// Items that look like they don't belong in a greengrocer (cleaning, sodas, snacks)
const nonProduceKeywords = /נקיון|חיתול|דאודורנט|שמפו|סבון|מסטיק|ויטמין|תרופ|בירה|וודקה|ויסקי|כריך|פיצה|המבורגר|נקני|טוסטר|מטעי|מצופה שוקול/;
const offTopic = data.filter((p) => p.name && nonProduceKeywords.test(p.name));
console.log('Off-topic items (cleaning/alcohol/snacks):', offTopic.length);
offTopic.slice(0, 10).forEach((p) =>
  console.log('  • [' + (p.category || '?') + '] ' + JSON.stringify(p.name)),
);

// Items with English-only names
const engOnly = data.filter((p) => p.name && !/[֐-׿]/.test(p.name));
console.log('\nNames with NO Hebrew (English-only):', engOnly.length);
engOnly.slice(0, 8).forEach((p) => console.log('  •', JSON.stringify(p.name)));

// Items where unit doesn't fit produce (should be 'ק"ג' / 'גרם' / 'יחידה')
const unitsCount = {};
data.forEach((p) => (unitsCount[p.unit || '<null>'] = (unitsCount[p.unit || '<null>'] || 0) + 1));
console.log('\nUnits used:');
Object.entries(unitsCount)
  .sort((a, b) => b[1] - a[1])
  .forEach(([u, n]) => console.log('  ' + u + ': ' + n));

// Items with isWeighted true vs false — meaningful for produce
const weighted = data.filter((p) => p.isWeighted === true).length;
const notWeighted = data.filter((p) => p.isWeighted === false).length;
const undefWeighted = data.filter((p) => p.isWeighted == null).length;
console.log('\nisWeighted=true: ' + weighted + ', =false: ' + notWeighted + ', undefined/null: ' + undefWeighted);
