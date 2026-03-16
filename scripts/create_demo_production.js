// create_demo_production.js — Create demo data in PRODUCTION Firebase
// Uses Admin SDK (bypasses security rules)
// Run: node scripts/create_demo_production.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const sa = require('./firebase-service-account.json');

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}
const db = admin.firestore();
const auth = admin.auth();

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════
const DEMO_PASSWORD = 'Demo123456!';

const USERS = [
  // Cohen Family
  { key: 'avi',    name: 'אבי כהן',    email: 'avi.cohen@demo.com',    phone: '0501234567', household: 'cohen', role: 'admin',  isAdmin: true,  familySize: 4, stores: ['שופרסל', 'רמי לוי'],  days: [4,5], freq: 2, budget: 2000 },
  { key: 'ronit',  name: 'רונית כהן',   email: 'ronit.cohen@demo.com',  phone: '0502345678', household: 'cohen', role: 'admin',  isAdmin: true,  familySize: 4, stores: ['שופרסל', 'יוחננוף'], days: [0,3,5], freq: 3, budget: 2000 },
  { key: 'yuval',  name: 'יובל כהן',    email: 'yuval.cohen@demo.com',  phone: '0503456789', household: 'cohen', role: 'member', isAdmin: false, familySize: 4, stores: ['AM:PM', 'שופרסל'],   days: [5], freq: 1, budget: 200 },
  { key: 'noa',    name: 'נועה כהן',    email: 'noa.cohen@demo.com',    phone: '0504567890', household: 'cohen', role: 'member', isAdmin: false, familySize: 4, stores: ['שופרסל'],            days: [5], freq: 1, budget: 150 },
  // Levi Couple
  { key: 'dan',    name: 'דן לוי',      email: 'dan.levi@demo.com',     phone: '0505678901', household: 'levi',  role: 'admin',  isAdmin: true,  familySize: 2, stores: ['רמי לוי'],           days: [4], freq: 2, budget: 1200 },
  { key: 'maya',   name: 'מאיה לוי',    email: 'maya.levi@demo.com',    phone: '0506789012', household: 'levi',  role: 'admin',  isAdmin: true,  familySize: 2, stores: ['רמי לוי', 'שופרסל'], days: [0,4], freq: 2, budget: 1200 },
  // Single
  { key: 'tomer',  name: 'תומר בר',     email: 'tomer.bar@demo.com',    phone: '0507890123', household: 'tomer', role: 'admin',  isAdmin: true,  familySize: 1, stores: ['AM:PM'],             days: [5], freq: 1, budget: 600 },
  // New user
  { key: 'shiran', name: 'שירן גל',     email: 'shiran.gal@demo.com',   phone: '0508901234', household: 'shiran',role: 'admin',  isAdmin: true,  familySize: 1, stores: ['שופרסל'],            days: [], freq: 1, budget: 500 },
];

const HOUSEHOLDS = {
  cohen:  { name: 'משפחת כהן',  members: ['avi','ronit','yuval','noa'] },
  levi:   { name: 'משפחת לוי',   members: ['dan','maya'] },
  tomer:  { name: 'הבית של תומר', members: ['tomer'] },
  shiran: { name: 'הבית של שירן', members: ['shiran'] },
};

// ═══════════════════════════════════════════════════════════════
// LOAD PRODUCTS FROM JSON
// ═══════════════════════════════════════════════════════════════
function loadProducts() {
  const products = [];
  const files = ['supermarket','bakery','butcher','greengrocer','pharmacy','market'];
  for (const f of files) {
    const p = path.join(__dirname, '..', 'assets', 'data', 'list_types', `${f}.json`);
    if (fs.existsSync(p)) {
      const data = JSON.parse(fs.readFileSync(p, 'utf8'));
      products.push(...data);
    }
  }
  return products;
}

function pickRandom(arr, count) {
  const shuffled = [...arr].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
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
// MAIN
// ═══════════════════════════════════════════════════════════════
async function main() {
  const products = loadProducts();
  console.log(`📦 נטענו ${products.length} מוצרים מ-JSON\n`);

  const uids = {}; // key → firebase UID
  const now = new Date();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. CREATE AUTH USERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👥 יוצר משתמשי Auth...');
  for (const u of USERS) {
    try {
      const record = await auth.createUser({
        email: u.email,
        password: DEMO_PASSWORD,
        displayName: u.name,
      });
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
  // 2. CREATE HOUSEHOLDS + MEMBERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🏠 יוצר households...');
  const householdIds = {};
  for (const [hKey, hData] of Object.entries(HOUSEHOLDS)) {
    const hId = `household_${hKey}`;
    householdIds[hKey] = hId;
    const creatorUid = uids[hData.members[0]];

    await db.collection('households').doc(hId).set({
      id: hId,
      name: hData.name,
      created_by: creatorUid,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const memberKey of hData.members) {
      const memberUser = USERS.find(u => u.key === memberKey);
      await db.collection('households').doc(hId).collection('members').doc(uids[memberKey]).set({
        name: memberUser.name,
        role: memberUser.role,
        joined_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    console.log(`   🏠 ${hData.name} (${hData.members.length} members)`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. CREATE USER DOCUMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📝 יוצר user documents...');
  for (const u of USERS) {
    const uid = uids[u.key];
    const hId = householdIds[u.household];
    await db.collection('users').doc(uid).set({
      id: uid,
      name: u.name,
      email: u.email,
      phone: u.phone,
      household_id: hId,
      household_name: HOUSEHOLDS[u.household].name,
      joined_at: admin.firestore.FieldValue.serverTimestamp(),
      last_login_at: admin.firestore.FieldValue.serverTimestamp(),
      preferred_stores: u.stores,
      favorite_products: [],
      weekly_budget: u.budget,
      is_admin: u.isAdmin,
      family_size: u.familySize,
      shopping_frequency: u.freq,
      shopping_days: u.days,
      has_children: u.familySize > 2,
      share_lists: true,
      reminder_time: u.isAdmin ? '09:00' : null,
      seen_onboarding: true,
      seen_tutorial: u.key !== 'shiran', // שירן = משתמשת חדשה
    });
    console.log(`   📝 ${u.name}`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. CREATE SHARED SHOPPING LISTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📋 יוצר רשימות קניות...');

  // Cohen: Weekly active list
  const cohenWeeklyItems = pickRandom(products.filter(p => ['מוצרי חלב','לחם ומאפים','פירות וירקות','ביצים','בשר ועוף'].includes(p.category)), 9);
  const cohenWeeklyList = {
    id: 'list_cohen_weekly',
    name: 'קניות שבועיות',
    status: 'active',
    type: 'supermarket',
    budget: 800,
    is_shared: true,
    is_private: false,
    created_by: uids.ronit,
    format: 'shared',
    created_from_template: false,
    created_date: admin.firestore.FieldValue.serverTimestamp(),
    updated_date: admin.firestore.FieldValue.serverTimestamp(),
    shared_with: [uids.avi, uids.yuval, uids.noa],
    shared_users: {
      [uids.yuval]: { role: 'editor', shared_at: now.toISOString(), user_name: 'יובל כהן', user_email: 'yuval.cohen@demo.com', can_start_shopping: true },
      [uids.noa]: { role: 'editor', shared_at: now.toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: false },
    },
    pending_requests: [
      // יובל (editor) מבקש להוסיף 3 מוצרים — ממתין לאישור
      {
        id: 'req_yuval_1',
        list_id: 'list_cohen_weekly',
        requester_id: uids.yuval,
        type: 'addItem',
        status: 'pending',
        created_at: new Date(now - 2*3600000).toISOString(),
        request_data: { name: 'במבה', quantity: 3, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: null, reviewed_at: null,
        requester_name: 'יובל כהן', reviewer_name: null,
      },
      {
        id: 'req_yuval_2',
        list_id: 'list_cohen_weekly',
        requester_id: uids.yuval,
        type: 'addItem',
        status: 'pending',
        created_at: new Date(now - 1*3600000).toISOString(),
        request_data: { name: 'שוקולד פרה חלב 100ג עלית', quantity: 2, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: null, reviewed_at: null,
        requester_name: 'יובל כהן', reviewer_name: null,
      },
      // נועה (editor) מבקשת להוסיף מוצר — ממתין לאישור
      {
        id: 'req_noa_1',
        list_id: 'list_cohen_weekly',
        requester_id: uids.noa,
        type: 'addItem',
        status: 'pending',
        created_at: new Date(now - 30*60000).toISOString(),
        request_data: { name: 'נייר טואלט 3שכבות32גTNX', quantity: 1, unit: "יח'", category: 'מוצרי ניקיון', type: 'product' },
        reviewer_id: null, reviewed_at: null,
        requester_name: 'נועה כהן', reviewer_name: null,
      },
      // בקשה שכבר אושרה (לדוגמה — יובל ביקש לפני יומיים, רונית אישרה)
      {
        id: 'req_yuval_old',
        list_id: 'list_cohen_weekly',
        requester_id: uids.yuval,
        type: 'addItem',
        status: 'approved',
        created_at: new Date(now - 48*3600000).toISOString(),
        request_data: { name: 'לחם 9 דגנים קל 500 גרם', quantity: 1, unit: "יח'", category: 'לחם ומאפים', type: 'product' },
        reviewer_id: uids.ronit, reviewed_at: new Date(now - 47*3600000).toISOString(),
        requester_name: 'יובל כהן', reviewer_name: 'רונית כהן',
      },
      // בקשה שנדחתה (נועה ביקשה, אבי דחה)
      {
        id: 'req_noa_old',
        list_id: 'list_cohen_weekly',
        requester_id: uids.noa,
        type: 'addItem',
        status: 'rejected',
        created_at: new Date(now - 24*3600000).toISOString(),
        request_data: { name: 'אל סבון לידיים מארז3*500', quantity: 1, unit: "יח'", category: 'היגיינה אישית', type: 'product' },
        reviewer_id: uids.avi, reviewed_at: new Date(now - 23*3600000).toISOString(),
        requester_name: 'נועה כהן', reviewer_name: 'אבי כהן',
      },
    ],
    active_shoppers: [],
    items: cohenWeeklyItems.map((p, i) => ({
      id: `item_cw_${i}`,
      name: p.name,
      quantity: Math.floor(Math.random() * 3) + 1,
      unit: p.unit || "יח'",
      unit_price: p.price || 0,
      category: p.category,
      type: 'product',
      is_checked: false,
      emoji: p.icon || null,
      notes: null,
    })),
  };
  await db.collection('households').doc(householdIds.cohen).collection('shared_lists').doc(cohenWeeklyList.id).set(cohenWeeklyList);
  console.log('   📝 קניות שבועיות (כהן) — 9 פריטים + 5 בקשות (3 ממתינות), active');

  // Cohen: Completed list from last week
  const cohenLastWeekItems = pickRandom(products.filter(p => p.category !== 'תרופות'), 12);
  const cohenCompletedList = {
    id: 'list_cohen_lastweek',
    name: 'קניות שבוע שעבר',
    status: 'completed',
    type: 'supermarket',
    budget: 750,
    is_shared: true,
    is_private: false,
    created_by: uids.avi,
    format: 'shared',
    created_from_template: false,
    created_date: new Date(now - 7*86400000).toISOString(),
    updated_date: new Date(now - 5*86400000).toISOString(),
    shared_with: [uids.ronit],
    shared_users: {},
    pending_requests: [],
    active_shoppers: [],
    items: cohenLastWeekItems.map((p, i) => ({
      id: `item_clw_${i}`,
      name: p.name,
      quantity: Math.floor(Math.random() * 3) + 1,
      unit: p.unit || "יח'",
      unit_price: p.price || 0,
      category: p.category,
      type: 'product',
      is_checked: true,
      emoji: p.icon || null,
      notes: null,
    })),
  };
  await db.collection('households').doc(householdIds.cohen).collection('shared_lists').doc(cohenCompletedList.id).set(cohenCompletedList);
  console.log('   📝 קניות שבוע שעבר (כהן) — 12 פריטים, completed');

  // Levi: Active list
  const leviItems = pickRandom(products.filter(p => ['מוצרי חלב','פירות וירקות','משקאות','אורז ופסטה'].includes(p.category)), 7);
  const leviList = {
    id: 'list_levi_weekly',
    name: 'רשימה לסופר',
    status: 'active',
    type: 'supermarket',
    budget: 500,
    is_shared: true,
    is_private: false,
    created_by: uids.maya,
    format: 'shared',
    created_from_template: false,
    created_date: admin.firestore.FieldValue.serverTimestamp(),
    updated_date: admin.firestore.FieldValue.serverTimestamp(),
    shared_with: [uids.dan],
    shared_users: {},
    pending_requests: [],
    active_shoppers: [],
    items: leviItems.map((p, i) => ({
      id: `item_lv_${i}`,
      name: p.name,
      quantity: Math.floor(Math.random() * 2) + 1,
      unit: p.unit || "יח'",
      unit_price: p.price || 0,
      category: p.category,
      type: 'product',
      is_checked: false,
      emoji: p.icon || null,
      notes: null,
    })),
  };
  await db.collection('households').doc(householdIds.levi).collection('shared_lists').doc(leviList.id).set(leviList);
  console.log('   📝 רשימה לסופר (לוי) — 7 פריטים, active');

  // Tomer: Private list (pharmacy)
  const tomerPharmItems = pickRandom(products.filter(p => p.category === 'היגיינה ויופי' || p.category === 'מוצרי ניקיון'), 5);
  const tomerList = {
    id: 'list_tomer_pharm',
    name: 'סופרפארם',
    status: 'active',
    type: 'pharmacy',
    budget: null,
    is_shared: false,
    is_private: true,
    created_by: uids.tomer,
    format: 'shared',
    created_from_template: false,
    created_date: admin.firestore.FieldValue.serverTimestamp(),
    updated_date: admin.firestore.FieldValue.serverTimestamp(),
    shared_with: [],
    shared_users: {},
    pending_requests: [],
    active_shoppers: [],
    items: tomerPharmItems.map((p, i) => ({
      id: `item_tp_${i}`,
      name: p.name,
      quantity: 1,
      unit: p.unit || "יח'",
      unit_price: p.price || 0,
      category: p.category,
      type: 'product',
      is_checked: false,
      emoji: p.icon || null,
      notes: null,
    })),
  };
  await db.collection('users').doc(uids.tomer).collection('private_lists').doc(tomerList.id).set(tomerList);
  console.log('   📝 סופרפארם (תומר) — 5 פריטים, private');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. CREATE INVENTORY (PANTRY)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📦 יוצר מזווה...');

  // Cohen pantry — rich inventory
  const cohenPantryProducts = pickRandom(products.filter(p =>
    ['מוצרי חלב','אורז ופסטה','שימורים','מוצרי ניקיון','משקאות','תבלינים ואפייה','לחם ומאפים','ממתקים וחטיפים'].includes(p.category)
  ), 20);

  for (let i = 0; i < cohenPantryProducts.length; i++) {
    const p = cohenPantryProducts[i];
    const qty = i === 0 ? 0 : i === 1 ? 1 : Math.floor(Math.random() * 5) + 1; // first 2 = low stock
    const minQty = i < 3 ? 3 : Math.floor(Math.random() * 2) + 1;
    const item = {
      id: `inv_cohen_${i}`,
      product_name: p.name,
      category: p.category,
      location: locationForCategory(p.category),
      quantity: qty,
      unit: p.unit || "יח'",
      min_quantity: minQty,
      expiry_date: p.category === 'מוצרי חלב' ? new Date(now.getTime() + (i < 3 ? 2 : 14) * 86400000).toISOString() : null,
      notes: null,
      is_recurring: Math.random() > 0.3,
      emoji: p.icon || null,
      last_updated_by: uids.avi,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('users').doc(uids.avi).collection('inventory').doc(item.id).set(item);
  }
  console.log(`   📦 מזווה כהן — ${cohenPantryProducts.length} פריטים (2 מלאי נמוך)`);

  // Tomer pantry — small
  const tomerPantryProducts = pickRandom(products.filter(p =>
    ['אורז ופסטה','שימורים','משקאות'].includes(p.category)
  ), 8);
  for (let i = 0; i < tomerPantryProducts.length; i++) {
    const p = tomerPantryProducts[i];
    const item = {
      id: `inv_tomer_${i}`,
      product_name: p.name,
      category: p.category,
      location: locationForCategory(p.category),
      quantity: Math.floor(Math.random() * 3) + 1,
      unit: p.unit || "יח'",
      min_quantity: 1,
      expiry_date: null,
      notes: null,
      is_recurring: false,
      emoji: p.icon || null,
      last_updated_by: uids.tomer,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('users').doc(uids.tomer).collection('inventory').doc(item.id).set(item);
  }
  console.log(`   📦 מזווה תומר — ${tomerPantryProducts.length} פריטים`);

  // Shiran pantry — rich but no lists (new user)
  const shiranPantryProducts = pickRandom(products.filter(p =>
    ['מוצרי חלב','פירות וירקות','אורז ופסטה','תבלינים ואפייה','לחם ומאפים'].includes(p.category)
  ), 15);
  for (let i = 0; i < shiranPantryProducts.length; i++) {
    const p = shiranPantryProducts[i];
    const item = {
      id: `inv_shiran_${i}`,
      product_name: p.name,
      category: p.category,
      location: locationForCategory(p.category),
      quantity: Math.floor(Math.random() * 4) + 2,
      unit: p.unit || "יח'",
      min_quantity: 2,
      expiry_date: null,
      notes: null,
      is_recurring: true,
      emoji: p.icon || null,
      last_updated_by: uids.shiran,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('users').doc(uids.shiran).collection('inventory').doc(item.id).set(item);
  }
  console.log(`   📦 מזווה שירן — ${shiranPantryProducts.length} פריטים (ללא רשימות)`);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. CREATE RECEIPTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🧾 יוצר קבלות...');
  const receiptItems = cohenLastWeekItems.slice(0, 8).map((p, i) => ({
    id: `rcpt_item_${i}`,
    name: p.name,
    quantity: Math.floor(Math.random() * 3) + 1,
    is_checked: true,
    category: p.category,
    checked_by: uids.avi,
    checked_at: new Date(now - 5*86400000).toISOString(),
  }));

  await db.collection('households').doc(householdIds.cohen).collection('receipts').doc('receipt_lastweek').set({
    id: 'receipt_lastweek',
    store_name: 'שופרסל דיל ירושלים',
    date: new Date(now - 5*86400000).toISOString(),
    household_id: householdIds.cohen,
    items: receiptItems,
    total_amount: receiptItems.reduce((s, it) => s + it.quantity * 15, 0), // approximate
    is_virtual: true,
    created_by: uids.avi,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log('   🧾 קבלה — שופרסל (שבוע שעבר)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n' + '═'.repeat(50));
  console.log('✅ Demo data נוצר בהצלחה!');
  console.log('═'.repeat(50));
  console.log(`\n👥 ${USERS.length} משתמשים`);
  console.log(`🏠 ${Object.keys(HOUSEHOLDS).length} households`);
  console.log(`📋 4 רשימות (3 shared + 1 private)`);
  console.log(`📦 ${20 + 8 + 15} פריטי מזווה`);
  console.log(`🧾 1 קבלה`);
  console.log(`\n🔑 סיסמה לכל המשתמשים: ${DEMO_PASSWORD}`);
  console.log('\n📧 משתמשים:');
  for (const u of USERS) {
    console.log(`   ${u.email} — ${u.name}`);
  }
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
