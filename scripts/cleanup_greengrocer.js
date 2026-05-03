// Cleanup pass for assets/data/list_types/greengrocer.json
//   1. Strip trailing unmatched "(...$" (truncations)
//   2. Delete the misplaced "בשר בננה מס'8 חלק" beef record
//   3. Normalize size = "" → null (98 records, for consistency with the
//      342 that already use null)

const fs = require('fs');
const path = 'assets/data/list_types/greengrocer.json';
const data = JSON.parse(fs.readFileSync(path, 'utf8'));

const stats = { trailingParen: 0, sizeNormalized: 0, beefDeleted: 0 };
const filtered = [];

for (const p of data) {
  // 2. Drop the misplaced beef record
  if (p.name === "בשר בננה מס'8 חלק") {
    stats.beefDeleted++;
    continue;
  }

  if (p.name) {
    // 1. Strip trailing unmatched "(..."
    const opens = (p.name.match(/\(/g) || []).length;
    const closes = (p.name.match(/\)/g) || []).length;
    if (opens > closes) {
      const lastOpen = p.name.lastIndexOf('(');
      if (lastOpen > 0) {
        let cut = lastOpen;
        while (cut > 0 && /\s/.test(p.name[cut - 1])) cut--;
        if (cut > 0) {
          p.name = p.name.slice(0, cut).trim();
          stats.trailingParen++;
        }
      }
    }
  }

  // 3. Normalize size = "" → null
  if (p.size === '') {
    p.size = null;
    stats.sizeNormalized++;
  }

  filtered.push(p);
}

fs.writeFileSync(path, JSON.stringify(filtered, null, 2) + '\n', 'utf8');

console.log('Records before: ' + data.length);
console.log('Records after:  ' + filtered.length);
console.log('');
console.log('| Operation | Count |');
console.log('|-----------|-------|');
console.log('| Trailing unmatched "(...$" stripped | ' + stats.trailingParen + ' |');
console.log('| size = "" → null | ' + stats.sizeNormalized + ' |');
console.log('| Misplaced beef record deleted | ' + stats.beefDeleted + ' |');
