// enrich_demo_data.js — Enrich existing demo data to simulate 6 months of real usage
// Adds: new users, rich receipts, notifications, varied list types, active shopping, edge cases
// Run: node scripts/enrich_demo_data.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const sa = require('./firebase-service-account.json');

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}
const db = admin.firestore();
const auth = admin.auth();

const DEMO_PASSWORD = 'Demo123456!';
const now = new Date();
const DAY = 86400000;

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
function daysAgo(n) { return new Date(now.getTime() - n * DAY); }
function hoursAgo(n) { return new Date(now.getTime() - n * 3600000); }
function pickRandom(arr, count) {
  return [...arr].sort(() => Math.random() - 0.5).slice(0, Math.min(count, arr.length));
}
function randomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

function loadProducts() {
  const products = [];
  for (const f of ['supermarket','bakery','butcher','greengrocer','pharmacy','market']) {
    const p = path.join(__dirname, '..', 'assets', 'data', 'list_types', `${f}.json`);
    if (fs.existsSync(p)) products.push(...JSON.parse(fs.readFileSync(p, 'utf8')));
  }
  return products;
}

function locationForCategory(cat) {
  const map = {
    'מוצרי חלב': 'מקרר', 'בשר ועוף': 'מקפיא', 'דגים': 'מקפיא',
    'פירות וירקות': 'מקרר', 'לחם ומאפים': 'מטבח',
    'מוצרי ניקיון': 'מחסן', 'היגיינה ויופי': 'אמבטיה',
    'משקאות': 'מזווה', 'שימורים': 'מזווה', 'אורז ופסטה': 'מזווה',
    'תבלינים ואפייה': 'מזווה', 'ממתקים וחטיפים': 'מזווה',
  };
  return map[cat] || 'מזווה';
}

// ═══════════════════════════════════════════════════════════════
// NEW USERS
// ═══════════════════════════════════════════════════════════════
const NEW_USERS = [
  // Grandpa — invited to Cohen household, viewer role
  { key: 'ori', name: 'אורי שלום', email: 'ori.shalom@demo.com', phone: '0509012345',
    household: 'cohen', role: 'member', isAdmin: false, familySize: 1 },
  // Inactive user — barely uses app
  { key: 'lior', name: 'ליאור דהן', email: 'lior.dahan@demo.com', phone: '0510123456',
    household: 'lior', role: 'admin', isAdmin: true, familySize: 1 },
  // Power user — lots of lists, events, receipts
  { key: 'naama', name: 'נעמה רוזן', email: 'naama.rozen@demo.com', phone: '0511234567',
    household: 'naama', role: 'admin', isAdmin: true, familySize: 1 },
];

const NEW_HOUSEHOLDS = {
  lior:  { name: 'הבית של ליאור', members: ['lior'] },
  naama: { name: 'הבית של נעמה', members: ['naama'] },
};

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════
async function main() {
  const products = loadProducts();
  console.log(`📦 ${products.length} מוצרים נטענו\n`);

  // Get existing UIDs
  const existingUids = {};
  for (const email of ['avi.cohen@demo.com','ronit.cohen@demo.com','yuval.cohen@demo.com',
    'noa.cohen@demo.com','dan.levi@demo.com','maya.levi@demo.com',
    'tomer.bar@demo.com','shiran.gal@demo.com']) {
    try {
      const u = await auth.getUserByEmail(email);
      const key = email.split('@')[0].split('.')[0];
      existingUids[key] = u.uid;
    } catch(e) { /* skip */ }
  }
  console.log(`♻️ ${Object.keys(existingUids).length} existing users found\n`);

  const uids = { ...existingUids };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. CREATE NEW AUTH USERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👥 יוצר משתמשים חדשים...');
  for (const u of NEW_USERS) {
    try {
      const record = await auth.createUser({ email: u.email, password: DEMO_PASSWORD, displayName: u.name });
      uids[u.key] = record.uid;
      console.log(`   ✅ ${u.name} (${record.uid})`);
    } catch (e) {
      if (e.code === 'auth/email-already-exists') {
        const existing = await auth.getUserByEmail(u.email);
        uids[u.key] = existing.uid;
        console.log(`   ♻️ ${u.name} (exists: ${existing.uid})`);
      } else throw e;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. CREATE NEW HOUSEHOLDS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🏠 יוצר households חדשים...');
  for (const [hKey, hData] of Object.entries(NEW_HOUSEHOLDS)) {
    const hId = `household_${hKey}`;
    const creatorUid = uids[hData.members[0]];
    await db.collection('households').doc(hId).set({
      id: hId, name: hData.name, created_by: creatorUid,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    for (const mKey of hData.members) {
      const mUser = NEW_USERS.find(u => u.key === mKey);
      await db.collection('households').doc(hId).collection('members').doc(uids[mKey]).set({
        name: mUser.name, role: mUser.role, joined_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    console.log(`   🏠 ${hData.name}`);
  }

  // Add אורי to Cohen household
  console.log('   🏠 מוסיף אורי שלום לבית כהן...');
  await db.collection('households').doc('household_cohen').collection('members').doc(uids.ori).set({
    name: 'אורי שלום', role: 'member', joined_at: daysAgo(60).toISOString(),
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. CREATE USER DOCUMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📝 יוצר user documents...');
  const userDocs = [
    { key: 'ori', hId: 'household_cohen', stores: ['שופרסל'], freq: 0, budget: 0,
      joinedDaysAgo: 60, lastLoginDaysAgo: 3, seenTutorial: true, seenOnboarding: true },
    { key: 'lior', hId: 'household_lior', stores: [], freq: 0, budget: 0,
      joinedDaysAgo: 120, lastLoginDaysAgo: 45, seenTutorial: true, seenOnboarding: true },
    { key: 'naama', hId: 'household_naama', stores: ['רמי לוי','שופרסל','AM:PM','מחסני השוק'], freq: 4, budget: 1500,
      joinedDaysAgo: 180, lastLoginDaysAgo: 0, seenTutorial: true, seenOnboarding: true },
  ];
  for (const ud of userDocs) {
    const u = NEW_USERS.find(x => x.key === ud.key);
    await db.collection('users').doc(uids[u.key]).set({
      id: uids[u.key], name: u.name, email: u.email, phone: u.phone,
      household_id: ud.hId, household_name: ud.key === 'ori' ? 'הבית של כהן' : NEW_HOUSEHOLDS[ud.key]?.name || '',
      joined_at: daysAgo(ud.joinedDaysAgo).toISOString(),
      last_login_at: daysAgo(ud.lastLoginDaysAgo).toISOString(),
      preferred_stores: ud.stores, favorite_products: [],
      weekly_budget: ud.budget, is_admin: u.isAdmin, family_size: u.familySize,
      shopping_frequency: ud.freq, shopping_days: [],
      has_children: false, share_lists: true, reminder_time: null,
      seen_onboarding: ud.seenOnboarding, seen_tutorial: ud.seenTutorial,
    });
    console.log(`   📝 ${u.name}`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. RICH RECEIPTS — 6 months of shopping history
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🧾 יוצר קבלות (6 חודשים)...');
  let receiptCount = 0;

  const stores = ['שופרסל דיל', 'רמי לוי', 'יוחננוף', 'מחסני השוק', 'AM:PM', 'ויקטורי'];

  // Cohen: ~2 shops/week × 26 weeks = ~52 receipts → generate 25
  const cohenShoppers = [uids.avi, uids.ronit, uids.yuval, uids.ronit, uids.avi];
  for (let w = 1; w <= 25; w++) {
    const dayOffset = w * randomInt(2, 5);
    const date = daysAgo(dayOffset);
    const shopperUid = cohenShoppers[w % cohenShoppers.length];
    const numItems = randomInt(5, 18);
    const items = pickRandom(products, numItems).map((p, i) => ({
      id: `rcpt_c${w}_${i}`, name: p.name, quantity: randomInt(1, 4), unit_price: p.price || 0,
      is_checked: true, category: p.category,
      checked_by: shopperUid, checked_at: date.toISOString(),
    }));

    await db.collection('households').doc('household_cohen').collection('receipts').doc(`receipt_cohen_${w}`).set({
      id: `receipt_cohen_${w}`,
      store_name: stores[w % stores.length],
      date: date.toISOString(),
      household_id: 'household_cohen',
      items, total_amount: items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0),
      is_virtual: true, created_by: shopperUid,
      created_at: date.toISOString(),
    });
    receiptCount++;
  }
  console.log(`   🧾 כהן: 25 קבלות`);

  // Levi: ~2 shops/week × 26 weeks → generate 15
  for (let w = 1; w <= 15; w++) {
    const dayOffset = w * randomInt(3, 6);
    const date = daysAgo(dayOffset);
    const shopperUid = w % 2 === 0 ? uids.dan : uids.maya;
    const numItems = randomInt(4, 12);
    const items = pickRandom(products, numItems).map((p, i) => ({
      id: `rcpt_l${w}_${i}`, name: p.name, quantity: randomInt(1, 3), unit_price: p.price || 0,
      is_checked: true, category: p.category,
      checked_by: shopperUid, checked_at: date.toISOString(),
    }));

    await db.collection('households').doc('household_levi').collection('receipts').doc(`receipt_levi_${w}`).set({
      id: `receipt_levi_${w}`,
      store_name: w % 3 === 0 ? 'שופרסל' : 'רמי לוי',
      date: date.toISOString(),
      household_id: 'household_levi',
      items, total_amount: items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0),
      is_virtual: true, created_by: shopperUid,
      created_at: date.toISOString(),
    });
    receiptCount++;
  }
  console.log(`   🧾 לוי: 15 קבלות`);

  // Naama (power user): ~4 shops/week → generate 30
  for (let w = 1; w <= 30; w++) {
    const dayOffset = w * randomInt(1, 4);
    const date = daysAgo(dayOffset);
    const numItems = randomInt(3, 25);
    const items = pickRandom(products, numItems).map((p, i) => ({
      id: `rcpt_n${w}_${i}`, name: p.name, quantity: randomInt(1, 5), unit_price: p.price || 0,
      is_checked: true, category: p.category,
      checked_by: uids.naama, checked_at: date.toISOString(),
    }));

    await db.collection('households').doc('household_naama').collection('receipts').doc(`receipt_naama_${w}`).set({
      id: `receipt_naama_${w}`,
      store_name: stores[w % stores.length],
      date: date.toISOString(),
      household_id: 'household_naama',
      items, total_amount: items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0),
      is_virtual: true, created_by: uids.naama,
      created_at: date.toISOString(),
    });
    receiptCount++;
  }
  console.log(`   🧾 נעמה: 30 קבלות`);

  // Tomer: ~1 shop/week → 10
  for (let w = 1; w <= 10; w++) {
    const dayOffset = w * randomInt(5, 9);
    const date = daysAgo(dayOffset);
    const numItems = randomInt(3, 8);
    const items = pickRandom(products, numItems).map((p, i) => ({
      id: `rcpt_t${w}_${i}`, name: p.name, quantity: randomInt(1, 2), unit_price: p.price || 0,
      is_checked: true, category: p.category,
      checked_by: uids.tomer, checked_at: date.toISOString(),
    }));

    await db.collection('households').doc('household_tomer').collection('receipts').doc(`receipt_tomer_${w}`).set({
      id: `receipt_tomer_${w}`,
      store_name: w % 2 === 0 ? 'AM:PM' : 'שופרסל דיל',
      date: date.toISOString(),
      household_id: 'household_tomer',
      items, total_amount: items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0),
      is_virtual: true, created_by: uids.tomer,
      created_at: date.toISOString(),
    });
    receiptCount++;
  }
  console.log(`   🧾 תומר: 10 קבלות`);

  console.log(`   📊 סה"כ: ${receiptCount} קבלות`);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. VARIED LIST TYPES — bakery, butcher, event, etc.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📋 יוצר רשימות מגוונות...');

  // Cohen: Bakery list (active)
  const bakeryProducts = pickRandom(products.filter(p => p.category === 'לחם ומאפים'), 4);
  await db.collection('households').doc('household_cohen').collection('shared_lists').doc('list_cohen_bakery').set({
    id: 'list_cohen_bakery', name: 'מאפייה לשבת', status: 'active', type: 'bakery',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    shared_with: [uids.avi, uids.noa],
    shared_users: {
      [uids.noa]: { role: 'editor', shared_at: daysAgo(7).toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: true },
    },
    pending_requests: [
      // נועה (editor) מבקשת להוסיף חלה לשבת
      {
        id: 'req_noa_bk1',
        list_id: 'list_cohen_bakery',
        requester_id: uids.noa,
        type: 'addItem',
        status: 'pending',
        created_at: hoursAgo(1).toISOString(),
        request_data: { name: 'מיץ תפוזים סחוט שמוטי1ל', quantity: 2, unit: "יח'", category: 'משקאות', type: 'product' },
        reviewer_id: null, reviewed_at: null,
        requester_name: 'נועה כהן', reviewer_name: null,
      },
    ],
    active_shoppers: [],
    items: bakeryProducts.map((p, i) => ({
      id: `item_bk_${i}`, name: p.name, quantity: randomInt(1, 3), unit: p.unit || "יח'",
      unit_price: p.price || 0, category: p.category, type: 'product',
      is_checked: i === 0, // first item checked
      emoji: p.icon || null, notes: i === 0 ? 'הגדול, לא הקטן' : null,
    })),
  });
  console.log('   📝 מאפייה לשבת (כהן) — bakery + 1 בקשה ממתינה, active');

  // Cohen: Butcher list (active, partially checked)
  const butcherProducts = pickRandom(products.filter(p => p.category === 'בשר ועוף' || p.category === 'דגים'), 6);
  await db.collection('households').doc('household_cohen').collection('shared_lists').doc('list_cohen_butcher').set({
    id: 'list_cohen_butcher', name: 'קצביה ליום שישי', status: 'active', type: 'butcher',
    budget: null, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.ronit], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: butcherProducts.map((p, i) => ({
      id: `item_bt_${i}`, name: p.name, quantity: randomInt(1, 2), unit: 'ק"ג',
      unit_price: p.price || 0, category: p.category, type: 'product',
      is_checked: i < 2, // 2 out of 6 checked
      emoji: p.icon || null, notes: null,
    })),
  });
  console.log('   📝 קצביה ליום שישי (כהן) — butcher, 2/6 checked');

  // Cohen: Event list — Birthday party (completed)
  await db.collection('households').doc('household_cohen').collection('shared_lists').doc('list_cohen_birthday').set({
    id: 'list_cohen_birthday', name: 'יום הולדת נועה 🎂', status: 'completed', type: 'event',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(30).toISOString(), updated_date: daysAgo(28).toISOString(),
    shared_with: [uids.avi, uids.yuval], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      { id: 'item_bd_0', name: 'עוגת שוקולד', quantity: 1, unit: "יח'", unit_price: 0, category: 'לחם ומאפים', type: 'product', is_checked: true, emoji: '🎂', notes: '3 קומות!' },
      { id: 'item_bd_1', name: 'נרות יום הולדת', quantity: 1, unit: "חבילה", unit_price: 0, category: null, type: 'custom', is_checked: true, emoji: '🕯️', notes: null },
      { id: 'item_bd_2', name: 'בלונים', quantity: 20, unit: "יח'", unit_price: 0, category: null, type: 'custom', is_checked: true, emoji: '🎈', notes: 'ורוד וזהב' },
      { id: 'item_bd_3', name: 'צלחות חד פעמיות', quantity: 30, unit: "יח'", unit_price: 0, category: null, type: 'custom', is_checked: true, emoji: '🍽️', notes: null },
      { id: 'item_bd_4', name: 'מיץ ענבים', quantity: 3, unit: 'בקבוק', unit_price: 0, category: 'משקאות', type: 'product', is_checked: true, emoji: '🍇', notes: null },
      { id: 'item_bd_5', name: 'חטיפים', quantity: 5, unit: 'שקית', unit_price: 0, category: 'ממתקים וחטיפים', type: 'product', is_checked: true, emoji: '🍿', notes: null },
      { id: 'item_bd_6', name: 'פיצה', quantity: 4, unit: 'מגש', unit_price: 0, category: null, type: 'custom', is_checked: true, emoji: '🍕', notes: 'להזמין מדומינוס' },
    ],
  });
  console.log('   📝 יום הולדת נועה 🎂 (כהן) — event, completed');

  // Cohen: Greengrocer (active, with active shopper!)
  const greengrocerProducts = pickRandom(products.filter(p => p.category === 'פירות וירקות'), 8);
  await db.collection('households').doc('household_cohen').collection('shared_lists').doc('list_cohen_greengrocer').set({
    id: 'list_cohen_greengrocer', name: 'ירקות ופירות', status: 'active', type: 'greengrocer',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(5).toISOString(), updated_date: hoursAgo(0.5).toISOString(),
    shared_with: [uids.avi], shared_users: {},
    pending_requests: [],
    // ACTIVE SHOPPING — רונית קונה עכשיו!
    active_shoppers: [{
      user_id: uids.ronit,
      user_name: 'רונית כהן',
      started_at: hoursAgo(0.5).toISOString(),
      is_active: true,
    }],
    items: greengrocerProducts.map((p, i) => ({
      id: `item_gg_${i}`, name: p.name, quantity: randomInt(1, 3), unit: p.unit || 'ק"ג',
      unit_price: p.price || 0, category: p.category, type: 'product',
      is_checked: i < 3, // 3/8 already checked (in progress)
      emoji: p.icon || null, notes: null,
      checked_by: i < 3 ? uids.ronit : null,
      checked_at: i < 3 ? hoursAgo(0.3).toISOString() : null,
    })),
  });
  console.log('   📝 ירקות ופירות (כהן) — greengrocer, ACTIVE SHOPPING by רונית!');

  // Naama: Big supermarket list (50+ items — performance edge case)
  const bigListProducts = pickRandom(products, 55);
  await db.collection('households').doc('household_naama').collection('shared_lists').doc('list_naama_big').set({
    id: 'list_naama_big', name: 'קניות חודשיות 🛒', status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(3).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: bigListProducts.map((p, i) => ({
      id: `item_nb_${i}`, name: p.name, quantity: randomInt(1, 5), unit: p.unit || "יח'",
      unit_price: p.price || 0, category: p.category, type: 'product',
      is_checked: i < 20, // 20/55 checked
      emoji: p.icon || null, notes: i === 0 ? 'בדוק תאריך תפוגה!!' : null,
    })),
  });
  console.log('   📝 קניות חודשיות (נעמה) — 55 פריטים! (performance test)');

  // Naama: Market list (שוק)
  const marketProducts = pickRandom(products.filter(p =>
    ['פירות וירקות','תבלינים ואפייה','בשר ועוף'].includes(p.category)), 10);
  await db.collection('households').doc('household_naama').collection('shared_lists').doc('list_naama_market').set({
    id: 'list_naama_market', name: 'שוק מחנה יהודה 🏪', status: 'active', type: 'market',
    budget: null, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(6).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: marketProducts.map((p, i) => ({
      id: `item_nm_${i}`, name: p.name, quantity: randomInt(1, 3), unit: p.unit || 'ק"ג',
      unit_price: p.price || 0, category: p.category, type: 'product',
      is_checked: false, emoji: p.icon || null, notes: null,
    })),
  });
  console.log('   📝 שוק מחנה יהודה (נעמה) — market, 10 items');

  // Naama: BBQ event (upcoming)
  await db.collection('households').doc('household_naama').collection('shared_lists').doc('list_naama_bbq').set({
    id: 'list_naama_bbq', name: 'על האש 🔥 שישי', status: 'active', type: 'event',
    budget: null, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(12).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      { id: 'item_bbq_0', name: 'סטייק אנטריקוט', quantity: 2, unit: 'ק"ג', unit_price: 0, category: 'בשר ועוף', type: 'product', is_checked: false, emoji: '🥩', notes: null },
      { id: 'item_bbq_1', name: 'כנפיים', quantity: 2, unit: 'ק"ג', unit_price: 0, category: 'בשר ועוף', type: 'product', is_checked: false, emoji: '🍗', notes: 'מתובלות' },
      { id: 'item_bbq_2', name: 'קבב', quantity: 1, unit: 'ק"ג', unit_price: 0, category: 'בשר ועוף', type: 'product', is_checked: false, emoji: '🥩', notes: null },
      { id: 'item_bbq_3', name: 'פחם', quantity: 1, unit: 'שק', unit_price: 0, category: null, type: 'custom', is_checked: false, emoji: '🔥', notes: null },
      { id: 'item_bbq_4', name: 'פיתות', quantity: 2, unit: 'חבילה', unit_price: 0, category: 'לחם ומאפים', type: 'product', is_checked: false, emoji: '🫓', notes: null },
      { id: 'item_bbq_5', name: 'סלטים', quantity: 3, unit: "יח'", unit_price: 0, category: 'פירות וירקות', type: 'product', is_checked: false, emoji: '🥗', notes: 'חומוס + טחינה + מטבוחה' },
      { id: 'item_bbq_6', name: 'בירה', quantity: 12, unit: 'בקבוק', unit_price: 0, category: 'משקאות', type: 'product', is_checked: false, emoji: '🍺', notes: 'גולדסטאר' },
      { id: 'item_bbq_7', name: 'קולה', quantity: 2, unit: 'בקבוק 1.5L', unit_price: 0, category: 'משקאות', type: 'product', is_checked: false, emoji: '🥤', notes: null },
    ],
  });
  console.log('   📝 על האש 🔥 שישי (נעמה) — event, 8 items');

  // Naama: completed lists from past months
  for (let m = 1; m <= 8; m++) {
    const completedItems = pickRandom(products, randomInt(6, 15));
    await db.collection('households').doc('household_naama').collection('shared_lists').doc(`list_naama_past_${m}`).set({
      id: `list_naama_past_${m}`, name: `קניות ${m === 1 ? 'שבוע שעבר' : `לפני ${m} שבועות`}`,
      status: 'completed', type: 'supermarket',
      budget: null, is_shared: false, is_private: false, created_by: uids.naama,
      format: 'shared', created_from_template: false,
      created_date: daysAgo(m * 7 + randomInt(0, 3)).toISOString(),
      updated_date: daysAgo(m * 7 - 1).toISOString(),
      shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
      items: completedItems.map((p, i) => ({
        id: `item_np${m}_${i}`, name: p.name, quantity: randomInt(1, 4), unit: p.unit || "יח'",
        unit_price: p.price || 0, category: p.category, type: 'product', is_checked: true,
        emoji: p.icon || null, notes: null,
      })),
    });
  }
  console.log('   📝 נעמה: 8 רשימות מושלמות (היסטוריה עשירה)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. PANTRY — Levi + Naama + edge cases
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📦 מעדכן מזווה...');

  // Levi: 12 items (was missing pantry)
  const leviPantry = pickRandom(products.filter(p =>
    ['מוצרי חלב','אורז ופסטה','שימורים','משקאות','תבלינים ואפייה'].includes(p.category)), 12);
  for (let i = 0; i < leviPantry.length; i++) {
    const p = leviPantry[i];
    await db.collection('users').doc(uids.dan).collection('inventory').doc(`inv_levi_${i}`).set({
      id: `inv_levi_${i}`, product_name: p.name, category: p.category,
      location: locationForCategory(p.category),
      quantity: i < 2 ? 0 : randomInt(1, 5), // 2 items at 0 (out of stock!)
      unit: p.unit || "יח'", min_quantity: i < 4 ? 3 : 1,
      expiry_date: null, notes: null, is_recurring: true,
      emoji: p.icon || null,
      last_updated_by: i % 2 === 0 ? uids.dan : uids.maya,
      updated_at: daysAgo(randomInt(1, 14)).toISOString(),
    });
  }
  console.log('   📦 לוי: 12 פריטים (2 כמות 0)');

  // Naama: 35 items (power user — BIG pantry)
  const naamaPantry = pickRandom(products, 35);
  for (let i = 0; i < naamaPantry.length; i++) {
    const p = naamaPantry[i];
    await db.collection('users').doc(uids.naama).collection('inventory').doc(`inv_naama_${i}`).set({
      id: `inv_naama_${i}`, product_name: p.name, category: p.category,
      location: locationForCategory(p.category),
      quantity: i < 5 ? randomInt(0, 1) : randomInt(1, 8), // 5 items low/empty
      unit: p.unit || "יח'", min_quantity: randomInt(1, 3),
      expiry_date: p.category === 'מוצרי חלב' ? daysAgo(-randomInt(1, 30)).toISOString() : null,
      notes: i === 0 ? 'מהמבצע בשופרסל' : null,
      is_recurring: Math.random() > 0.3,
      emoji: p.icon || null,
      last_updated_by: uids.naama,
      updated_at: daysAgo(randomInt(0, 20)).toISOString(),
    });
  }
  console.log('   📦 נעמה: 35 פריטים (5 מלאי נמוך)');

  // Lior: 2 items only (inactive user)
  const liorPantry = pickRandom(products.filter(p => p.category === 'שימורים'), 2);
  for (let i = 0; i < liorPantry.length; i++) {
    const p = liorPantry[i];
    await db.collection('users').doc(uids.lior).collection('inventory').doc(`inv_lior_${i}`).set({
      id: `inv_lior_${i}`, product_name: p.name, category: p.category,
      location: 'מזווה', quantity: randomInt(1, 3), unit: p.unit || "יח'",
      min_quantity: 1, expiry_date: null, notes: null, is_recurring: false,
      emoji: p.icon || null,
      last_updated_by: uids.lior,
      updated_at: daysAgo(90).toISOString(), // last update 3 months ago!
    });
  }
  console.log('   📦 ליאור: 2 פריטים (עדכון אחרון לפני 3 חודשים)');

  // Ori (grandpa): 0 items (viewer only, uses Cohen's shared pantry)
  console.log('   📦 אורי: 0 פריטים (צופה בלבד)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. NOTIFICATIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🔔 יוצר התראות...');

  const notifTypes = [
    { type: 'list_shared', title: 'רשימה חדשה שותפה איתך', body: 'רונית שיתפה את הרשימה "קניות שבועיות"' },
    { type: 'item_added', title: 'פריט חדש ברשימה', body: 'יובל הוסיף "חלב" לרשימה' },
    { type: 'shopping_started', title: 'קנייה התחילה!', body: 'רונית התחילה לקנות מ"ירקות ופירות"' },
    { type: 'shopping_completed', title: 'קנייה הסתיימה', body: 'אבי סיים את הקנייה ב"שופרסל"' },
    { type: 'low_stock', title: 'מלאי נמוך', body: 'חלב, קפה — נגמרים! הוסף לרשימה' },
    { type: 'invite_received', title: 'הזמנה חדשה', body: 'דן לוי הזמין אותך להצטרף לבית' },
    { type: 'member_joined', title: 'חבר חדש בבית', body: 'אורי שלום הצטרף לבית שלכם' },
    { type: 'reminder', title: 'תזכורת קניות', body: 'לא קנית כבר 5 ימים — הגיע הזמן?' },
  ];

  // Cohen notifications (for avi)
  for (let i = 0; i < 12; i++) {
    const notif = notifTypes[i % notifTypes.length];
    const d = daysAgo(randomInt(0, 30));
    await db.collection('users').doc(uids.avi).collection('notifications').doc(`notif_avi_${i}`).set({
      id: `notif_avi_${i}`, type: notif.type, title: notif.title, body: notif.body,
      created_at: d.toISOString(), read: i > 4, // first 5 unread
      data: {}, user_id: uids.avi,
    });
  }
  console.log('   🔔 אבי: 12 התראות (5 לא נקראו)');

  // Naama — lots of notifications
  for (let i = 0; i < 20; i++) {
    const notif = notifTypes[i % notifTypes.length];
    const d = daysAgo(randomInt(0, 60));
    await db.collection('users').doc(uids.naama).collection('notifications').doc(`notif_naama_${i}`).set({
      id: `notif_naama_${i}`, type: notif.type, title: notif.title, body: notif.body,
      created_at: d.toISOString(), read: i > 7, // first 8 unread
      data: {}, user_id: uids.naama,
    });
  }
  console.log('   🔔 נעמה: 20 התראות (8 לא נקראו)');

  // Lior — 1 old notification
  await db.collection('users').doc(uids.lior).collection('notifications').doc('notif_lior_0').set({
    id: 'notif_lior_0', type: 'reminder', title: 'חזרת?', body: 'לא השתמשת באפליקציה כבר חודשיים',
    created_at: daysAgo(45).toISOString(), read: false,
    data: {}, user_id: uids.lior,
  });
  console.log('   🔔 ליאור: 1 התראה ישנה (לא נקראה)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 8. PENDING INVITES — edge cases
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📩 יוצר הזמנות ממתינות...');

  // Naama invited to join Levi household
  await db.collection('pending_invites').doc('invite_naama_to_levi').set({
    id: 'invite_naama_to_levi',
    type: 'inviteToHousehold',
    requester_id: uids.dan,
    requester_name: 'דן לוי',
    requester_email: 'dan.levi@demo.com',
    target_user_id: uids.naama,
    target_email: 'naama.rozen@demo.com',
    status: 'pending',
    created_at: daysAgo(2).toISOString(),
    request_data: {
      household_id: 'household_levi',
      household_name: 'הבית של לוי',
    },
  });
  console.log('   📩 דן → נעמה: הזמנה לבית לוי');

  // Tomer invited to a list (not household)
  await db.collection('pending_invites').doc('invite_tomer_list').set({
    id: 'invite_tomer_list',
    type: 'joinRequest',
    requester_id: uids.naama,
    requester_name: 'נעמה רוזן',
    requester_email: 'naama.rozen@demo.com',
    target_user_id: uids.tomer,
    target_email: 'tomer.bar@demo.com',
    status: 'pending',
    created_at: daysAgo(1).toISOString(),
    request_data: {
      list_name: 'על האש 🔥 שישי',
    },
  });
  console.log('   📩 נעמה → תומר: הזמנה לרשימת BBQ');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 9. UPDATE EXISTING USERS — enrich
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📝 מעדכן משתמשים קיימים...');

  // Update Cohen household name
  await db.collection('households').doc('household_cohen').update({
    name: 'הבית של כהן',
  });
  console.log('   📝 שם household כהן: "הבית של כהן"');

  // Update Levi household name
  await db.collection('households').doc('household_levi').update({
    name: 'הבית של לוי',
  });
  console.log('   📝 שם household לוי: "הבית של לוי"');

  // Update last_login for active users
  if (uids.avi) await db.collection('users').doc(uids.avi).update({ last_login_at: hoursAgo(2).toISOString() });
  if (uids.ronit) await db.collection('users').doc(uids.ronit).update({ last_login_at: hoursAgo(0.5).toISOString() });
  if (uids.dan) await db.collection('users').doc(uids.dan).update({ last_login_at: daysAgo(1).toISOString() });
  if (uids.naama) await db.collection('users').doc(uids.naama).update({ last_login_at: hoursAgo(1).toISOString() });
  console.log('   📝 last_login עודכן');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n' + '═'.repeat(60));
  console.log('✅ Demo data enriched successfully!');
  console.log('═'.repeat(60));
  console.log(`
👥 3 משתמשים חדשים (סה"כ 11)
🏠 2 households חדשים + אורי הצטרף לכהן (סה"כ 6)
📋 ~18 רשימות (כולל event, bakery, butcher, market, 55-item list)
📦 ~49 פריטי מזווה חדשים
🧾 ${receiptCount} קבלות (6 חודשי היסטוריה)
🔔 33 התראות
📩 2 הזמנות ממתינות חדשות

📊 מקרי קצה מכוסים:
  ✅ קנייה פעילה (רונית → ירקות ופירות)
  ✅ רשימה עם 55 פריטים (ביצועים)
  ✅ רשימת אירוע מושלמת (יום הולדת)
  ✅ רשימת BBQ (אירוע עתידי)
  ✅ משתמש לא פעיל (ליאור — login לפני 45 ימים)
  ✅ סבא/צופה (אורי — בבית כהן, 0 מזווה)
  ✅ Power user (נעמה — 35 מזווה, 30 קבלות, 11+ רשימות)
  ✅ פריטי מזווה בכמות 0 (לוי)
  ✅ הזמנה לבית (דן → נעמה)
  ✅ הזמנה לרשימה (נעמה → תומר)
  ✅ התראות לא נקראו (אבי:5, נעמה:8, ליאור:1)
  ✅ 4 סוגי רשימות (supermarket, bakery, butcher, greengrocer, market, event, pharmacy)

🔑 סיסמה: ${DEMO_PASSWORD}
📧 משתמשים חדשים:
   ori.shalom@demo.com — אורי שלום (סבא, צופה בכהן)
   lior.dahan@demo.com — ליאור דהן (רווק, לא פעיל)
   naama.rozen@demo.com — נעמה רוזן (power user)
`);
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
