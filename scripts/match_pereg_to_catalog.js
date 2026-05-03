// Matches our 56 Pereg-tagged catalog items to Pereg's official image URLs
// (from scripts/pereg_image_map.json) using fuzzy name comparison.
//
// Output: scripts/pereg_catalog_matches.json — { barcode → imageUrl } map.
// (Or { name → imageUrl } when barcode is missing.)
// We DON'T modify supermarket.json directly here — that's a separate step
// once the matches look good.

const fs = require('fs');

const peregMap = JSON.parse(fs.readFileSync('scripts/pereg_image_map.json', 'utf8'));
const supermarket = JSON.parse(
  fs.readFileSync('assets/data/list_types/supermarket.json', 'utf8'),
);

const peregItems = supermarket.filter((p) => p.brand === 'פרג');
const peregEntries = Object.values(peregMap);

console.log('Catalog items branded "פרג":', peregItems.length);
console.log('Pereg site products mapped:', peregEntries.length);

// Normalize a Hebrew name for fuzzy comparison:
//  - lowercase Latin
//  - strip weight/size like "120 גרם", "1 ק״ג", "100 מ״ל"
//  - tokenize, then drop noise tokens ("פרג", "תבליני", etc.) explicitly.
//    Word-boundary regex with `\b` won't fire on Hebrew (JS treats non-ASCII
//    as non-word), so we tokenize+filter instead.
//  - normalize a few well-known spelling variants
const NOISE_TOKENS = new Set([
  'פרג', 'תבליני', 'תבלין', 'בשמן', 'של', 'את', 'עם', 'או',
  'pereg', 'tavlineypereg',
]);
const SPELLING_VARIANTS = {
  // Yemenite "חוויג'" ↔ "חוואיג"
  'חוואיג': 'חוויג',
  "חוויג'": 'חוויג',
  // Ginger "זנגוויל" / "זנגביל" / "ג'ינג'ר"
  'זנגוויל': 'זנגביל',
  'גינגר': 'זנגביל',
  "ג'ינג'ר": 'זנגביל',
  // Coriander
  'כוסבר': 'כוסברה',
  'כוסברה': 'כוסברה',
  // common stem fix
  'פלפלים': 'פלפל',
};

function normalize(s) {
  if (!s) return '';
  return s
    .toLowerCase()
    .replace(/\d+\s*(גרם|גר|ק[״"]ג|קג|מ[״"]ל|מל|יחידות|יח'?)/g, ' ')
    .split(/[\s,.\-\/()\[\]"']+/)
    .map((t) => SPELLING_VARIANTS[t] || t)
    .filter((t) => t && !NOISE_TOKENS.has(t))
    .join(' ')
    .replace(/[^֐-׿a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// Generic descriptive tokens — they don't, on their own, prove that two
// products are the same. "פרג טחון" matching "כמון טחון" purely on the
// shared "טחון" (ground) is a false match: every ground spice has it.
const GENERIC_TOKENS = new Set([
  'טחון', 'שלם', 'גס', 'דק', 'גדול', 'קטן', 'משומר',
  'שקית', 'מתוק', 'מתוקה', 'חריף', 'חריפה', 'אדום', 'שחור',
  'בשמן', 'יפני', 'תימני', 'בלאדי', 'מקסי', 'אמר', 'קלאסי',
  'אסלית', 'בכפר',
]);

// Token-overlap score (Jaccard-ish): |intersection| / max(|a|,|b|).
// Requires at least one substantive (non-generic) token to match — otherwise
// returns 0. This prevents matches based purely on generic descriptors.
function score(a, b) {
  const A = new Set(normalize(a).split(' ').filter((t) => t.length >= 2));
  const B = new Set(normalize(b).split(' ').filter((t) => t.length >= 2));
  if (A.size === 0 || B.size === 0) return 0;
  let common = 0;
  let substantiveCommon = 0;
  for (const t of A) {
    if (B.has(t)) {
      common++;
      if (!GENERIC_TOKENS.has(t)) substantiveCommon++;
    }
  }
  if (substantiveCommon === 0) return 0;
  return common / Math.max(A.size, B.size);
}

// For each catalog item, find the highest-scoring Pereg site product.
const results = [];
for (const item of peregItems) {
  let best = null;
  let bestScore = 0;
  for (const p of peregEntries) {
    const s = score(item.name, p.name);
    if (s > bestScore) {
      bestScore = s;
      best = p;
    }
  }
  results.push({
    catalogName: item.name,
    catalogBarcode: item.barcode,
    matchName: best && best.name,
    matchSku: best && best.sku,
    matchUrl: best && best.imageUrl,
    matchThumb: best && best.thumbUrl,
    score: bestScore,
  });
}

// Sort by score, descending
results.sort((a, b) => b.score - a.score);

// Print all results split into tiers so user can inspect
const STRONG = 0.5; // very confident match
const WEAK = 0.25; // possible match — review

console.log('\n=== STRONG matches (score ≥ ' + STRONG + ') ===');
results
  .filter((r) => r.score >= STRONG)
  .forEach((r) =>
    console.log(
      '  [' + r.score.toFixed(2) + '] "' + r.catalogName + '" → "' + r.matchName + '" (' + r.matchSku + ')',
    ),
  );

console.log('\n=== WEAK matches (' + WEAK + ' ≤ score < ' + STRONG + ') ===');
results
  .filter((r) => r.score >= WEAK && r.score < STRONG)
  .forEach((r) =>
    console.log(
      '  [' + r.score.toFixed(2) + '] "' + r.catalogName + '" → "' + r.matchName + '" (' + r.matchSku + ')',
    ),
  );

console.log('\n=== NO matches (score < ' + WEAK + ') ===');
results
  .filter((r) => r.score < WEAK)
  .forEach((r) =>
    console.log(
      '  [' + r.score.toFixed(2) + '] "' + r.catalogName + '" — best was "' + r.matchName + '"',
    ),
  );

// Write only strong matches to the output file
const strongOnly = results.filter((r) => r.score >= STRONG);
const out = {};
for (const r of strongOnly) {
  if (r.catalogBarcode) {
    out[r.catalogBarcode] = {
      sku: r.matchSku,
      imageUrl: r.matchUrl,
      thumbUrl: r.matchThumb,
      catalogName: r.catalogName,
      peregName: r.matchName,
    };
  }
}
fs.writeFileSync('scripts/pereg_catalog_matches.json', JSON.stringify(out, null, 2));

console.log(
  '\nWritten ' + Object.keys(out).length + ' strong barcode→imageUrl matches to scripts/pereg_catalog_matches.json',
);
console.log(
  'Total: ' +
    results.filter((r) => r.score >= STRONG).length +
    ' strong, ' +
    results.filter((r) => r.score >= WEAK && r.score < STRONG).length +
    ' weak, ' +
    results.filter((r) => r.score < WEAK).length +
    ' none',
);
