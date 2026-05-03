// Scrapes the Tavliney Pereg site (tavlineypereg.co.il) to build a
// product-name → SKU/image-URL map.
//
// Strategy: iterate through ProdId 1..MAX. For each, fetch
// ProductInfo.asp?ProdId=N and extract:
//   - product name (Hebrew, from <title> or h1)
//   - image SKU (from /ProductsImages/{SKU}.jpg in the HTML)
//
// Output: scripts/pereg_image_map.json
//
// Rate limit: 200ms between requests. Skip 404s. Save progress every 50
// successful scrapes so a crash doesn't lose everything.

const fs = require('fs');
const https = require('https');

const OUT_FILE = 'scripts/pereg_image_map.json';
const MAX_PROD_ID = parseInt(process.argv[2] || '700', 10);
const DELAY_MS = 200;
const SAVE_EVERY = 50;

function delay(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function fetchText(url) {
  return new Promise((resolve, reject) => {
    https
      .get(
        url,
        {
          headers: {
            'User-Agent':
              'Mozilla/5.0 (compatible; MemoZap-CatalogBot/1.0; +https://memozap.app)',
          },
          timeout: 15000,
        },
        (res) => {
          if (res.statusCode === 404) {
            res.resume();
            return resolve(null);
          }
          if (res.statusCode !== 200) {
            res.resume();
            return reject(new Error('HTTP ' + res.statusCode));
          }
          // The site is encoded in windows-1255 / utf-8. Try utf-8 first.
          const chunks = [];
          res.on('data', (c) => chunks.push(c));
          res.on('end', () => {
            const buf = Buffer.concat(chunks);
            // Try UTF-8 first
            let txt = buf.toString('utf8');
            // If we see lots of replacement chars or no Hebrew, try win-1255
            const hebrewCount = (txt.match(/[֐-׿]/g) || []).length;
            if (hebrewCount < 5) {
              try {
                const iconv = require('iconv-lite');
                txt = iconv.decode(buf, 'windows-1255');
              } catch (e) {
                /* iconv-lite not installed — fall back to utf8 */
              }
            }
            resolve(txt);
          });
        },
      )
      .on('error', reject)
      .on('timeout', () => reject(new Error('timeout')));
  });
}

function extractName(html) {
  // Try common patterns: <title>X | Pereg</title>, <h1>X</h1>, og:title
  const title = html.match(/<title>([^<]+)<\/title>/i);
  if (title) {
    let t = title[1]
      .replace(/&[^;]+;/g, ' ')
      .replace(/\s*[|·-].*$/, '') // drop site-name suffix
      .trim();
    if (t && /[֐-׿]/.test(t)) return t;
  }
  const h1 = html.match(/<h1[^>]*>([^<]+)<\/h1>/i);
  if (h1) return h1[1].trim();
  return null;
}

function extractImageSku(html) {
  // Look for /ProductsImages/{SKU}.jpg — first match (largest size, no s250 prefix preferred)
  const all = [...html.matchAll(/\/ProductsImages\/(?:s250\/)?([A-Z0-9_]+)\.jpe?g/gi)];
  if (all.length === 0) return null;
  // Prefer SKU that does NOT come from s250 thumbnail folder if both exist.
  for (const m of all) {
    if (!/\/s250\//.test(m[0])) return m[1];
  }
  return all[0][1];
}

function extractWeight(html) {
  // Common weights in Hebrew product pages
  const m = html.match(/(\d+(?:\.\d+)?)\s*(גרם|גר|ק״ג|קג|ק"ג|מ״ל|מ"ל|מל)\b/);
  if (m) return m[1] + ' ' + m[2];
  return null;
}

async function main() {
  // Resume from existing file if present
  let existing = {};
  if (fs.existsSync(OUT_FILE)) {
    try {
      existing = JSON.parse(fs.readFileSync(OUT_FILE, 'utf8'));
      console.log('Resuming from existing file with', Object.keys(existing).length, 'entries');
    } catch (e) {
      /* ignore */
    }
  }

  let found = Object.keys(existing).length;
  let attempts = 0;

  for (let id = 1; id <= MAX_PROD_ID; id++) {
    if (existing[String(id)]) continue; // already have
    attempts++;
    const url = 'https://www.tavlineypereg.co.il/ProductInfo.asp?ProdId=' + id;
    try {
      const html = await fetchText(url);
      if (!html) {
        process.stdout.write('-');
      } else {
        const name = extractName(html);
        const sku = extractImageSku(html);
        const weight = extractWeight(html);
        if (name && sku) {
          existing[String(id)] = {
            id,
            name,
            sku,
            weight,
            imageUrl: 'https://www.tavlineypereg.co.il/ProductsImages/' + sku + '.jpg',
            thumbUrl: 'https://www.tavlineypereg.co.il/ProductsImages/s250/' + sku + '.jpg',
          };
          found++;
          process.stdout.write('.');
        } else {
          process.stdout.write('?');
        }
      }
    } catch (e) {
      process.stdout.write('!');
    }

    if (attempts % SAVE_EVERY === 0) {
      fs.writeFileSync(OUT_FILE, JSON.stringify(existing, null, 2));
    }
    await delay(DELAY_MS);
  }

  fs.writeFileSync(OUT_FILE, JSON.stringify(existing, null, 2));
  console.log('\n\nDone. Total products mapped: ' + found);
  console.log('Output: ' + OUT_FILE);

  // Print quick sample
  const sample = Object.values(existing).slice(0, 10);
  console.log('\nSample:');
  sample.forEach((p) =>
    console.log('  • [' + p.id + '] ' + p.name + ' (' + (p.weight || '?') + ') → ' + p.sku),
  );
}

main().catch((e) => {
  console.error('FATAL:', e);
  process.exit(1);
});
