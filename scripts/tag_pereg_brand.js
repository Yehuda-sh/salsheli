// Tags `brand: "פרג"` on supermarket.json items that are clearly Pereg-brand
// products (the spice company), distinguishing them from products that just
// contain poppy seeds (פרג in Hebrew is also "poppy seed").

const fs = require('fs');
const path = 'assets/data/list_types/supermarket.json';
const data = JSON.parse(fs.readFileSync(path, 'utf8'));

// Spice/condiment "head" keywords. When a name starts with (or prominently
// contains) one of these AND has "פרג" as a token → it's Pereg-brand.
const SPICE_HEADS = new Set([
  // Common spice names
  'אורגנו', 'זנגוויל', 'זנגביל', 'חוואיג', 'חרוסת', 'טימין', 'כמון',
  'סחוג', 'עמבה', 'רוזמרין', 'צילי', 'כורכום', 'כרכום', 'פפריקה',
  'זעתר', 'פטרוזיליה', 'פלפל', 'מלח', 'קינמון', 'ציפורן', 'קימל',
  'בזיליקום', 'כוסברה', 'שמיר', 'עלי', 'אנים', 'הל', 'נענע',
  // Seasoning categories
  'תבלין', 'תיבול', 'גריל', 'מקלות',
]);

// Hard NON-Pereg patterns — bakery / pastry / dairy items that contain
// poppy seeds as ingredient. The presence of any of these in the name
// disqualifies it from being tagged Pereg-brand.
const NON_PEREG_PATTERNS = [
  /כעכים/, /סושקה/, /ערגליות/, /פרסבורגר/, /אוזני המן/, /אזני המן/,
  /בייגל/, /בייגלה/, /גריסיני/, /עוגיות/, /עוגת/, /מאפה/, /שטרודל/,
  /קרקר/, /יוגורט/, /גרנולה/, /קרנולה/, /ריבועי/, /מלית פרג/,
  /פח דוושה/, /אבקה להכנת/, /לחמי/, /חמאה/, /קונדיטור/,
];

// Explicit Pereg-only product line / phrase patterns.
const PEREG_EXPLICIT = [
  /פרג טופ/, /פרג-תיבול/, /פרג-פנקו/, /פרג טחון/,
  /שמן זית פרג/, /רוטב פרג קרמי/, /צנימים פרג לוקס/,
];

function isPeregBrand(name) {
  if (!name) return false;
  // Hard exclusions first
  for (const re of NON_PEREG_PATTERNS) {
    if (re.test(name)) return false;
  }
  // Explicit Pereg patterns — match anywhere
  for (const re of PEREG_EXPLICIT) {
    if (re.test(name)) return true;
  }
  // Otherwise: spice head + standalone "פרג" token
  const tokens = name.split(/[\s,.\-\/()\[\]"']+/);
  const hasSpiceHead = tokens.some((t) => SPICE_HEADS.has(t));
  const hasPeregToken = tokens.some((t) => t === 'פרג');
  return hasSpiceHead && hasPeregToken;
}

let tagged = 0;
const samples = [];
for (const p of data) {
  if (p.brand) continue; // don't overwrite existing brand
  if (isPeregBrand(p.name)) {
    p.brand = 'פרג';
    tagged++;
    if (samples.length < 25) samples.push(p.name);
  }
}

fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n', 'utf8');

console.log('Tagged ' + tagged + ' products with brand="פרג"');
console.log('\nFirst 25 tagged:');
samples.forEach((n) => console.log('  • ' + n));

// Double-check: any remaining brand=null name with פרג token that we MIGHT
// have missed? Print so user can review.
const stillUntagged = data.filter((p) => {
  if (p.brand) return false;
  if (!p.name) return false;
  const tokens = p.name.split(/[\s,.\-\/()\[\]"']+/);
  return tokens.some((t) => t === 'פרג');
});
console.log('\n--- Remaining "פרג"-token items left untagged (review) ---');
console.log('Count:', stillUntagged.length);
stillUntagged.forEach((p) => console.log('  • ' + JSON.stringify(p.name)));
