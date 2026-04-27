// scripts/debug_cohen.js — Diagnose why the Cohen household pantry isn't showing.
//
// Read-only: prints user docs, household doc, and inventory contents.
// Compares Cohen with Levi side-by-side to spot differences.
//
// Run: node scripts/debug_cohen.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

if (!admin.apps.length) {
  const localSa = path.join(__dirname, 'firebase-service-account.json');
  if (fs.existsSync(localSa)) {
    admin.initializeApp({ credential: admin.credential.cert(require(localSa)) });
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
  } else {
    throw new Error(
      'No credentials found. Place firebase-service-account.json in scripts/ ' +
      'or set GOOGLE_APPLICATION_CREDENTIALS.'
    );
  }
}
const db = admin.firestore();
const auth = admin.auth();

async function userDocByEmail(email) {
  const q = await db.collection('users').where('email', '==', email).limit(1).get();
  if (q.empty) return null;
  return q.docs[0];
}

async function inventoryRows(householdId) {
  const snap = await db.collection('households').doc(householdId).collection('inventory').get();
  return snap.docs.map(d => ({ id: d.id, ...d.data() }));
}

async function dumpFamily(label, email, expectedHouseholdId) {
  console.log(`\n${'='.repeat(70)}`);
  console.log(`👨‍👩‍👧 ${label}`);
  console.log('='.repeat(70));

  // 1. user doc
  const userDoc = await userDocByEmail(email);
  if (!userDoc) {
    console.log(`❌ user(${email}) — NOT FOUND in /users`);
    return;
  }
  const user = userDoc.data();
  console.log(`👤 /users/${userDoc.id}`);
  console.log(`   email          = ${user.email}`);
  console.log(`   name           = ${user.name}`);
  console.log(`   household_id   = ${user.household_id ?? '<missing>'}`);
  console.log(`   household_name = ${user.household_name ?? '<missing>'}`);

  // 2. Try to also read from Auth (uid match)
  try {
    const authUser = await auth.getUserByEmail(email).catch(() => null);
    if (authUser) {
      console.log(`   (Auth uid       = ${authUser.uid})`);
      if (authUser.uid !== userDoc.id) {
        console.log(`   ⚠️ Auth uid !== users-doc id (${authUser.uid} vs ${userDoc.id})`);
      }
    } else {
      console.log(`   ⚠️ no Firebase Auth account for ${email}`);
    }
  } catch (_) {}

  const hId = user.household_id;
  if (!hId) {
    console.log(`❌ household_id missing on user doc — that's why pantry won't show.`);
    return;
  }
  if (expectedHouseholdId && hId !== expectedHouseholdId) {
    console.log(`⚠️ household_id mismatch: got '${hId}', script expects '${expectedHouseholdId}'`);
  }

  // 3. household doc
  const hDoc = await db.collection('households').doc(hId).get();
  if (!hDoc.exists) {
    console.log(`❌ /households/${hId} — DOES NOT EXIST`);
    return;
  }
  const h = hDoc.data();
  console.log(`🏠 /households/${hId}`);
  console.log(`   name       = ${h.name}`);
  console.log(`   created_by = ${h.created_by}`);
  console.log(`   is_solo    = ${h.is_solo}`);

  // 4. members
  const members = await db.collection('households').doc(hId).collection('members').get();
  console.log(`👥 members (${members.size}):`);
  members.forEach(m => {
    const md = m.data();
    console.log(`   - ${md.name} (${md.role}) → ${m.id}`);
  });

  // 5. inventory
  const inv = await inventoryRows(hId);
  console.log(`📦 inventory (${inv.length} docs):`);
  if (inv.length === 0) {
    console.log(`   — collection EMPTY. App will show empty-state if Avi truly has 0 items.`);
  } else {
    const missingName = inv.filter(it => !it.product_name);
    if (missingName.length) {
      console.log(`   ⚠️ ${missingName.length} docs missing 'product_name' — orderBy('product_name') will EXCLUDE them.`);
    }
    inv.slice(0, 5).forEach(it => {
      console.log(`   - ${it.id} → product_name='${it.product_name ?? '<missing>'}', qty=${it.quantity}, category='${it.category}'`);
    });
    if (inv.length > 5) console.log(`   ... and ${inv.length - 5} more`);
  }
}

async function main() {
  await dumpFamily('Cohen — אבי כהן', 'avi.cohen@demo.com', 'household_cohen');
  await dumpFamily('Levi — דן לוי (control group, working)', 'dan.levi@demo.com', 'household_levi');

  console.log(`\n${'='.repeat(70)}`);
  console.log('Done. If Cohen has docs but Levi doesn\'t (or vice-versa), or if');
  console.log('user.household_id doesn\'t match the document path, that\'s your bug.');
  console.log('='.repeat(70));

  process.exit(0);
}

main().catch(e => {
  console.error('💥 debug_cohen failed:', e);
  process.exit(1);
});
