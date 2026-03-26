// rebuild_demo_data.js — Unified demo data for MemoZap
// Creates REALISTIC data matching exactly what the app GUI produces.
// Replaces: create_demo_production.js, enrich_demo_data.js, enrich_edge_cases.js
//
// Run: node scripts/rebuild_demo_data.js
// ⚠️ This REPLACES all demo data. Run once to set up fresh.

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
// CONSTANTS
// ═══════════════════════════════════════════════════════════════
const DEMO_PASSWORD = 'Demo123456!';
const now = new Date();
const DAY = 86400000;
const HOUR = 3600000;

function daysAgo(n) { return new Date(now.getTime() - n * DAY); }
function hoursAgo(n) { return new Date(now.getTime() - n * HOUR); }
function daysFromNow(n) { return new Date(now.getTime() + n * DAY); }
function pickRandom(arr, count) { return [...arr].sort(() => Math.random() - 0.5).slice(0, Math.min(count, arr.length)); }
function randomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

// ═══════════════════════════════════════════════════════════════
// USER & HOUSEHOLD CONFIG
// ═══════════════════════════════════════════════════════════════
const USERS = [
  // Cohen Family (4 + 1 viewer)
  { key: 'avi',    name: 'אבי כהן',     email: 'avi.cohen@demo.com',    phone: '0501234567', household: 'cohen',  role: 'admin',  isAdmin: true },
  { key: 'ronit',  name: 'רונית כהן',    email: 'ronit.cohen@demo.com',  phone: '0502345678', household: 'cohen',  role: 'admin',  isAdmin: true },
  { key: 'yuval',  name: 'יובל כהן',     email: 'yuval.cohen@demo.com',  phone: '0503456789', household: 'cohen',  role: 'member', isAdmin: false },
  { key: 'noa',    name: 'נועה כהן',     email: 'noa.cohen@demo.com',    phone: '0504567890', household: 'cohen',  role: 'member', isAdmin: false },
  { key: 'ori',    name: 'אורי שלום',    email: 'ori.shalom@demo.com',   phone: '0509012345', household: 'cohen',  role: 'member', isAdmin: false },
  // Levi Couple
  { key: 'dan',    name: 'דן לוי',       email: 'dan.levi@demo.com',     phone: '0505678901', household: 'levi',   role: 'admin',  isAdmin: true },
  { key: 'maya',   name: 'מאיה לוי',     email: 'maya.levi@demo.com',    phone: '0506789012', household: 'levi',   role: 'admin',  isAdmin: true },
  // Singles
  { key: 'tomer',  name: 'תומר בר',      email: 'tomer.bar@demo.com',    phone: '0507890123', household: 'tomer',  role: 'admin',  isAdmin: true },
  { key: 'shiran', name: 'שירן גל',      email: 'shiran.gal@demo.com',   phone: '0508901234', household: 'shiran', role: 'admin',  isAdmin: true },
  // Power user
  { key: 'naama',  name: 'נעמה רוזן',    email: 'naama.rozen@demo.com',  phone: '0511234567', household: 'naama',  role: 'admin',  isAdmin: true },
  // Inactive user
  { key: 'lior',   name: 'ליאור דהן',    email: 'lior.dahan@demo.com',   phone: '0512345678', household: 'lior',   role: 'admin',  isAdmin: true },
  // Fresh user
  { key: 'yael',   name: 'יעל חדשה',     email: 'yael.fresh@demo.com',   phone: '0513456789', household: 'yael',   role: 'admin',  isAdmin: true },
  // Google Sign-In user (no phone, has profile image)
  { key: 'google_user', name: 'גיל גוגל', email: 'gil.google@demo.com', phone: '', household: 'google_user', role: 'admin', isAdmin: true, provider: 'google', profileImageUrl: 'https://lh3.googleusercontent.com/a/default-user' },
  // Apple Sign-In user (no phone, no display name initially)
  { key: 'apple_user', name: 'apple_user@icloud.com', email: 'apple_user@icloud.com', phone: '', household: 'apple_user', role: 'admin', isAdmin: true, provider: 'apple' },
];

const HOUSEHOLDS = {
  cohen:  { name: 'משפחת כהן',     members: ['avi', 'ronit', 'yuval', 'noa', 'ori'] },
  levi:   { name: 'משפחת לוי',      members: ['dan', 'maya'] },
  tomer:  { name: 'הבית של תומר',   members: ['tomer'] },
  shiran: { name: 'הבית של שירן',   members: ['shiran'] },
  naama:  { name: 'הבית של נעמה',   members: ['naama'] },
  lior:   { name: 'הבית של ליאור',  members: ['lior'] },
  yael:        { name: 'הבית של יעל',    members: ['yael'] },
  google_user: { name: 'הבית של גיל',    members: ['google_user'] },
  apple_user:  { name: 'הבית שלי',       members: ['apple_user'] },
};

// ═══════════════════════════════════════════════════════════════
// LOAD PRODUCTS FROM JSON CATALOG
// ═══════════════════════════════════════════════════════════════
function loadProducts() {
  const products = [];
  for (const f of ['supermarket', 'bakery', 'butcher', 'greengrocer', 'pharmacy', 'market']) {
    const p = path.join(__dirname, '..', 'assets', 'data', 'list_types', `${f}.json`);
    if (fs.existsSync(p)) {
      const data = JSON.parse(fs.readFileSync(p, 'utf8'));
      products.push(...data.map(item => ({ ...item, sourceFile: f })));
    }
  }
  return products;
}

function byCategory(products, ...cats) {
  return products.filter(p => cats.includes(p.category));
}

function normalizeUnit(u) {
  if (!u) return "יח'";
  if (u === 'ק"ג' || u === 'קג') return 'ק"ג';
  if (u === 'ליטר' || u === 'ל') return 'ליטר';
  if (u === 'גרם' || u === 'גר') return 'גרם';
  return u;
}

// מיקומי אחסון — חייבים להתאים ל-StorageLocations IDs באפליקציה
// (lib/config/storage_locations.dart)
function locationForCategory(cat) {
  const map = {
    'מוצרי חלב': 'refrigerator',
    'פירות וירקות': 'refrigerator',
    'בשר ועוף': 'freezer',
    'דגים': 'freezer',
    'לחם ומאפים': 'kitchen',
    'תבלינים ואפייה': 'kitchen',
    'שמנים ורטבים': 'kitchen',
    'משקאות': 'main_pantry',
    'שימורים': 'main_pantry',
    'אורז ופסטה': 'main_pantry',
    'ממתקים וחטיפים': 'main_pantry',
    'מוצרי ניקיון': 'service_porch',
    'מוצרי בית': 'storage',
    'היגיינה ויופי': 'bathroom',
    'היגיינה אישית': 'bathroom',
  };
  return map[cat] || 'main_pantry';
}

// ═══════════════════════════════════════════════════════════════
// ITEM BUILDERS — Match exact app data structures
// ═══════════════════════════════════════════════════════════════

/**
 * Product item — nested productData (matches UnifiedListItem model)
 */
function makeProductItem(product, idx, opts = {}) {
  return {
    id: opts.id || `item_${idx}`,
    name: product.name,
    type: 'product',
    isChecked: opts.isChecked || false,
    category: product.category || null,
    notes: opts.notes || null,
    imageUrl: null,
    checkedBy: opts.checkedBy || null,
    checkedAt: opts.checkedAt || null,
    productData: {
      quantity: opts.quantity || product.defaultQty || randomInt(1, 3),
      unitPrice: product.price || 0,
      unit: normalizeUnit(product.defaultUnit || product.unit),
      ...(product.barcode ? { barcode: product.barcode } : {}),
      ...(product.brand ? { brand: product.brand } : {}),
    },
    taskData: null,
  };
}

/**
 * Task item — nested taskData (matches UnifiedListItem model)
 */
function makeTaskItem(id, name, opts = {}) {
  return {
    id,
    name,
    type: 'task',
    isChecked: opts.isChecked || false,
    category: null,
    notes: opts.notes || null,
    imageUrl: null,
    checkedBy: opts.checkedBy || null,
    checkedAt: opts.checkedAt || null,
    productData: null,
    taskData: {
      itemType: 'task',
      priority: opts.priority || 'medium',
    },
  };
}

/**
 * "Who Brings" item — special task with volunteers
 */
function makeWhoBringsItem(id, name, neededCount, volunteers = [], opts = {}) {
  return {
    id,
    name,
    type: 'task',
    isChecked: opts.isChecked || false,
    category: null,
    notes: opts.notes || null,
    imageUrl: null,
    checkedBy: null,
    checkedAt: null,
    productData: null,
    taskData: {
      itemType: 'whoBrings',
      neededCount,
      volunteers, // [{userId, displayName}]
    },
  };
}

/**
 * Receipt item — snake_case (matches Receipt model with FieldRename.snake)
 */
function makeReceiptItem(product, idx, shopperUid, date) {
  const qty = randomInt(1, 4);
  return {
    id: `rcpt_${idx}`,
    name: product.name,
    quantity: qty,
    unit_price: product.price || 0,
    unit: normalizeUnit(product.unit),
    is_checked: true,
    category: product.category || null,
    checked_by: shopperUid,
    checked_at: date.toISOString(),
  };
}

/**
 * Active shopper — matches ActiveShopper model
 */
function makeActiveShopper(uid, joinedAt, isStarter) {
  return {
    user_id: uid,
    joined_at: joinedAt.toISOString(),
    is_starter: isStarter,
    is_active: true,
  };
}

/**
 * Notification — matches AppNotification model
 * Valid types: invite, request_approved, request_rejected, role_changed,
 *   user_removed, who_brings_volunteer, new_vote, vote_tie, member_left, low_stock
 */
function makeNotification(id, uid, householdId, type, title, message, opts = {}) {
  return {
    id,
    user_id: uid,
    household_id: householdId,
    type,
    title,
    message,
    action_data: opts.actionData || {},
    is_read: opts.isRead || false,
    created_at: (opts.createdAt || now).toISOString(),
    read_at: opts.readAt ? opts.readAt.toISOString() : null,
    sender_id: opts.senderId || null,
    sender_name: opts.senderName || null,
  };
}

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════
async function main() {
  const products = loadProducts();
  console.log(`📦 Loaded ${products.length} products from catalog\n`);

  const uids = {}; // key → firebase UID

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. AUTH USERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👥 Creating Auth users...');
  for (const u of USERS) {
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. HOUSEHOLDS + MEMBERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🏠 Creating households...');
  const hIds = {};
  for (const [hKey, hData] of Object.entries(HOUSEHOLDS)) {
    const hId = `household_${hKey}`;
    hIds[hKey] = hId;
    const creatorUid = uids[hData.members[0]];

    await db.collection('households').doc(hId).set({
      id: hId, name: hData.name,
      created_by: creatorUid,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const memberKey of hData.members) {
      const memberUser = USERS.find(u => u.key === memberKey);
      await db.collection('households').doc(hId).collection('members').doc(uids[memberKey]).set({
        name: memberUser.name, role: memberUser.role,
        joined_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    console.log(`   🏠 ${hData.name} (${hData.members.length} members)`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. USER DOCUMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📝 Creating user documents...');
  for (const u of USERS) {
    const uid = uids[u.key];
    const hId = hIds[u.household];
    const isInactive = u.key === 'lior';
    const isFresh = u.key === 'yael';
    const isSocial = u.provider === 'google' || u.provider === 'apple';
    await db.collection('users').doc(uid).set({
      id: uid, name: u.name, email: u.email, phone: u.phone || '',
      household_id: hId,
      household_name: HOUSEHOLDS[u.household].name,
      joined_at: isFresh ? hoursAgo(0.5).toISOString() : isSocial ? daysAgo(7).toISOString() : daysAgo(180).toISOString(),
      last_login_at: isInactive ? daysAgo(45).toISOString() : isFresh ? hoursAgo(0.5).toISOString() : hoursAgo(randomInt(1, 12)).toISOString(),
      favorite_products: [],
      weekly_budget: u.key === 'naama' ? 3000 : u.key === 'tomer' ? 600 : isSocial ? 0 : u.isAdmin ? 2000 : 0,
      is_admin: u.isAdmin,
      seen_onboarding: true,
      seen_tutorial: u.key !== 'yael',
      ...(u.profileImageUrl ? { profile_image_url: u.profileImageUrl } : {}),
      ...(u.provider ? { auth_provider: u.provider } : { auth_provider: 'email' }),
    });
    console.log(`   📝 ${u.name}`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. SHOPPING LISTS — All 9 types, all statuses
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📋 Creating shopping lists...');

  // Helper: find a product by name substring
  function findProd(nameSubstr) { return products.find(p => p.name.includes(nameSubstr)); }

  // ── COHEN: Weekly supermarket (active, shared, editors + viewer + pending requests) ──
  const weeklyProducts = pickRandom(byCategory(products, 'מוצרי חלב', 'לחם ומאפים', 'פירות וירקות', 'משקאות', 'אורז ופסטה', 'שימורים').filter(p => p.sourceFile === 'supermarket'), 14);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_weekly').set({
    id: 'list_cohen_weekly', name: 'קניות שבועיות', status: 'active', type: 'supermarket',
    budget: 800, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.avi, uids.yuval, uids.noa, uids.ori],
    shared_users: {
      [uids.yuval]: { role: 'editor', shared_at: daysAgo(150).toISOString(), user_name: 'יובל כהן', user_email: 'yuval.cohen@demo.com', can_start_shopping: true },
      [uids.noa]:   { role: 'editor', shared_at: daysAgo(120).toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: false },
      [uids.ori]:   { role: 'viewer', shared_at: daysAgo(60).toISOString(), user_name: 'אורי שלום', user_email: 'ori.shalom@demo.com', can_start_shopping: false },
    },
    pending_requests: [
      { id: 'req_yuval_1', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'addItem', status: 'pending',
        created_at: hoursAgo(2).toISOString(),
        request_data: { name: 'במבה 80 גרם', quantity: 3, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'יובל כהן', reviewer_name: null },
      { id: 'req_noa_1', list_id: 'list_cohen_weekly', requester_id: uids.noa, type: 'addItem', status: 'pending',
        created_at: hoursAgo(0.5).toISOString(),
        request_data: { name: 'נייר טואלט 32 גלילים', quantity: 1, unit: "יח'", category: 'מוצרי בית', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'נועה כהן', reviewer_name: null },
      // Previously approved
      { id: 'req_yuval_old', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'addItem', status: 'approved',
        created_at: daysAgo(3).toISOString(),
        request_data: { name: 'קולה זירו 1.5 ליטר', quantity: 2, unit: "יח'", category: 'משקאות', type: 'product' },
        reviewer_id: uids.ronit, reviewed_at: daysAgo(3).toISOString(), requester_name: 'יובל כהן', reviewer_name: 'רונית כהן' },
      // Previously rejected
      { id: 'req_noa_old', list_id: 'list_cohen_weekly', requester_id: uids.noa, type: 'addItem', status: 'rejected',
        created_at: daysAgo(2).toISOString(),
        request_data: { name: 'שוקולד פרה 100 גרם', quantity: 5, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: uids.avi, reviewed_at: daysAgo(2).toISOString(), requester_name: 'נועה כהן', reviewer_name: 'אבי כהן',
        rejection_reason: 'יש כבר במזווה' },
    ],
    active_shoppers: [],
    items: weeklyProducts.map((p, i) => makeProductItem(p, i, { id: `item_cw_${i}`, isChecked: i < 4 })),
  });
  console.log('   📋 כהן: קניות שבועיות (supermarket, 14 items, 2 pending + 1 approved + 1 rejected)');

  // ── COHEN: Greengrocer — ACTIVE SHOPPING by רונית + אבי (2 shoppers!) ──
  const greenProducts = pickRandom(products.filter(p => p.sourceFile === 'greengrocer' && !p.name.includes('יוגורט') && !p.name.includes('מיץ')), 10);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_green').set({
    id: 'list_cohen_green', name: 'ירקות ופירות לשבוע', status: 'active', type: 'greengrocer',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(5).toISOString(), updated_date: hoursAgo(0.3).toISOString(),
    shared_with: [uids.avi], shared_users: {}, pending_requests: [],
    active_shoppers: [
      makeActiveShopper(uids.ronit, hoursAgo(0.5), true),
      makeActiveShopper(uids.avi, hoursAgo(0.3), false),
    ],
    items: greenProducts.map((p, i) => makeProductItem(p, i, {
      id: `item_cg_${i}`, isChecked: i < 4,
      checkedBy: i < 4 ? (i < 2 ? uids.ronit : uids.avi) : null,
      checkedAt: i < 4 ? hoursAgo(0.3).toISOString() : null,
    })),
  });
  console.log('   📋 כהן: ירקות ופירות (greengrocer, 2 ACTIVE SHOPPERS, 4/10 checked)');

  // ── COHEN: Bakery for shabbat ──
  const bakeryProducts = pickRandom(products.filter(p => p.sourceFile === 'bakery'), 5);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_bakery').set({
    id: 'list_cohen_bakery', name: 'מאפייה לשבת 🥖', status: 'active', type: 'bakery',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    shared_with: [uids.avi, uids.noa],
    shared_users: {
      [uids.noa]: { role: 'editor', shared_at: daysAgo(7).toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: true },
    },
    pending_requests: [], active_shoppers: [],
    items: bakeryProducts.map((p, i) => makeProductItem(p, i, { id: `item_bk_${i}`, isChecked: i === 0, notes: i === 0 ? 'הגדולה, לא הקטנה' : null })),
  });
  console.log('   📋 כהן: מאפייה לשבת (bakery, 5 items)');

  // ── COHEN: Butcher for friday ──
  const butcherProducts = pickRandom(products.filter(p => p.sourceFile === 'butcher'), 6);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_butcher').set({
    id: 'list_cohen_butcher', name: 'קצביה ליום שישי 🥩', status: 'active', type: 'butcher',
    budget: null, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.ronit], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: butcherProducts.map((p, i) => makeProductItem(p, i, { id: `item_bt_${i}`, isChecked: i < 2 })),
  });
  console.log('   📋 כהן: קצביה (butcher, 6 items, 2/6 checked)');

  // ── COHEN: Mixed products + tasks ──
  const mixedProducts = pickRandom(byCategory(products, 'מוצרי חלב', 'שימורים', 'מוצרי ניקיון', 'ממתקים וחטיפים').filter(p => p.sourceFile === 'supermarket'), 6);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_mixed').set({
    id: 'list_cohen_mixed', name: 'קניות + משימות לשבת', status: 'active', type: 'supermarket',
    budget: null, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(8).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.ronit, uids.yuval],
    shared_users: {
      [uids.yuval]: { role: 'editor', shared_at: daysAgo(7).toISOString(), user_name: 'יובל כהן', user_email: 'yuval.cohen@demo.com', can_start_shopping: true },
    },
    pending_requests: [], active_shoppers: [],
    items: [
      ...mixedProducts.map((p, i) => makeProductItem(p, i, { id: `item_mix_p${i}`, isChecked: i < 2 })),
      makeTaskItem('item_mix_t0', 'לנקות את המקרר', { notes: 'לפני שמכניסים קניות', priority: 'high' }),
      makeTaskItem('item_mix_t1', 'להוציא בשר מהמקפיא', { isChecked: true, notes: 'לארוחת שבת' }),
      makeTaskItem('item_mix_t2', 'לבדוק תאריכי תפוגה במזווה', {}),
      makeTaskItem('item_mix_t3', 'להזמין גז', { notes: 'אמישראגז 1-800-225-225', priority: 'high' }),
    ],
  });
  console.log('   📋 כהן: קניות + משימות (supermarket, 6 products + 4 tasks)');

  // ── COHEN: Household supplies ──
  const houseProducts = pickRandom(byCategory(products, 'מוצרי בית', 'מוצרי ניקיון').filter(p => p.sourceFile === 'supermarket'), 8);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_household').set({
    id: 'list_cohen_household', name: 'צרכי בית 🏠', status: 'active', type: 'household',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(5).toISOString(), updated_date: daysAgo(1).toISOString(),
    shared_with: [uids.avi], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: houseProducts.map((p, i) => makeProductItem(p, i, { id: `item_ch_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 כהן: צרכי בית (household, 8 items)');

  // ── COHEN: Who Brings event — שבת משפחתית 🎉 ──
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_shabbat').set({
    id: 'list_cohen_shabbat', name: 'ארוחת שבת משפחתית 🎉', status: 'active', type: 'event',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false, event_mode: 'who_brings',
    event_date: daysFromNow(3).toISOString(),
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [uids.avi, uids.yuval, uids.noa],
    shared_users: {
      [uids.yuval]: { role: 'editor', shared_at: daysAgo(1).toISOString(), user_name: 'יובל כהן', user_email: 'yuval.cohen@demo.com', can_start_shopping: false },
      [uids.noa]:   { role: 'editor', shared_at: daysAgo(1).toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: false },
    },
    pending_requests: [], active_shoppers: [],
    items: [
      makeWhoBringsItem('wb_1', 'סלט ירקות', 2, [{ userId: uids.yuval, displayName: 'יובל כהן' }]),
      makeWhoBringsItem('wb_2', 'חומוס', 1, []),
      makeWhoBringsItem('wb_3', 'קינוח', 1, [{ userId: uids.noa, displayName: 'נועה כהן' }]),
      makeWhoBringsItem('wb_4', 'לחם', 2, [
        { userId: uids.avi, displayName: 'אבי כהן' },
        { userId: uids.ronit, displayName: 'רונית כהן' },
      ]),
      makeWhoBringsItem('wb_5', 'שתייה', 3, [{ userId: uids.yuval, displayName: 'יובל כהן' }]),
      makeTaskItem('wb_t1', 'לסדר את השולחן', { priority: 'low' }),
    ],
  });
  console.log('   📋 כהן: ארוחת שבת (event, who_brings, 5 who-brings + 1 task)');

  // ── COHEN: Birthday completed ──
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_birthday').set({
    id: 'list_cohen_birthday', name: 'יום הולדת נועה 🎂', status: 'completed', type: 'event',
    budget: 500, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false, event_mode: 'tasks',
    created_date: daysAgo(30).toISOString(), updated_date: daysAgo(28).toISOString(),
    shared_with: [uids.avi, uids.yuval], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      makeTaskItem('item_bd_0', 'עוגת שוקולד 3 קומות', { isChecked: true, notes: 'מהקונדיטוריה ברחוב הרצל' }),
      makeTaskItem('item_bd_1', 'נרות יום הולדת', { isChecked: true }),
      makeTaskItem('item_bd_2', 'בלונים ורוד וזהב (20)', { isChecked: true }),
      makeTaskItem('item_bd_3', 'להזמין פיצה מדומינוס', { isChecked: true, notes: '4 מגשים' }),
      makeProductItem(findProd('במבה') || { name: 'במבה 80 גרם', category: 'ממתקים וחטיפים', price: 5.9 }, 4, { id: 'item_bd_4', isChecked: true, quantity: 5 }),
      makeProductItem(findProd('ביסלי') || { name: 'ביסלי גריל 200 גרם', category: 'ממתקים וחטיפים', price: 8.9 }, 5, { id: 'item_bd_5', isChecked: true, quantity: 3 }),
    ],
  });
  console.log('   📋 כהן: יום הולדת נועה (event/tasks, completed)');

  // ── COHEN: Last week completed ──
  const lastWeekProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket' && p.price), 15);
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_lastweek').set({
    id: 'list_cohen_lastweek', name: 'קניות שבוע שעבר', status: 'completed', type: 'supermarket',
    budget: 750, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(10).toISOString(), updated_date: daysAgo(7).toISOString(),
    shared_with: [uids.ronit], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: lastWeekProducts.map((p, i) => makeProductItem(p, i, { id: `item_clw_${i}`, isChecked: true, checkedBy: uids.avi, checkedAt: daysAgo(7).toISOString() })),
  });
  console.log('   📋 כהן: קניות שבוע שעבר (completed, 15 items all checked)');

  // ── COHEN: Archived list ──
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_archived').set({
    id: 'list_cohen_archived', name: 'חג פסח 2025', status: 'archived', type: 'supermarket',
    budget: 1500, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(365).toISOString(), updated_date: daysAgo(358).toISOString(),
    shared_with: [uids.avi], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 20).map((p, i) =>
      makeProductItem(p, i, { id: `item_arch_${i}`, isChecked: true })),
  });
  console.log('   📋 כהן: חג פסח 2025 (ARCHIVED, 20 items)');

  // ── LEVI: Active supermarket ──
  const leviProducts = pickRandom(byCategory(products, 'מוצרי חלב', 'פירות וירקות', 'משקאות', 'אורז ופסטה'), 7);
  await db.collection('households').doc(hIds.levi).collection('shared_lists').doc('list_levi_weekly').set({
    id: 'list_levi_weekly', name: 'רשימה לסופר', status: 'active', type: 'supermarket',
    budget: 500, is_shared: true, is_private: false, created_by: uids.maya,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    shared_with: [uids.dan], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: leviProducts.map((p, i) => makeProductItem(p, i, { id: `item_lv_${i}`, isChecked: i < 2 })),
  });
  console.log('   📋 לוי: רשימה לסופר (supermarket, 7 items)');

  // ── LEVI: Market ──
  const marketProducts = pickRandom(products.filter(p => p.sourceFile === 'market'), 8);
  await db.collection('households').doc(hIds.levi).collection('shared_lists').doc('list_levi_market').set({
    id: 'list_levi_market', name: 'שוק מחנה יהודה 🏪', status: 'active', type: 'market',
    budget: null, is_shared: true, is_private: false, created_by: uids.dan,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(3).toISOString(), updated_date: daysAgo(1).toISOString(),
    shared_with: [uids.maya], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: marketProducts.map((p, i) => makeProductItem(p, i, { id: `item_mk_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 לוי: שוק מחנה יהודה (market, 8 items)');

  // ── TOMER: Pharmacy (private) ──
  const pharmProducts = pickRandom(products.filter(p => p.sourceFile === 'pharmacy'), 5);
  await db.collection('users').doc(uids.tomer).collection('private_lists').doc('list_tomer_pharm').set({
    id: 'list_tomer_pharm', name: 'סופרפארם 💊', status: 'active', type: 'pharmacy',
    budget: null, is_shared: false, is_private: true, created_by: uids.tomer,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(3).toISOString(), updated_date: hoursAgo(5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      ...pharmProducts.map((p, i) => makeProductItem(p, i, { id: `item_tp_${i}` })),
      makeTaskItem('item_tp_task', 'לשאול על ויטמין D', { priority: 'low' }),
    ],
  });
  console.log('   📋 תומר: סופרפארם (pharmacy, private, 5 products + 1 task)');

  // ── TOMER: "Other" type list ──
  await db.collection('users').doc(uids.tomer).collection('private_lists').doc('list_tomer_misc').set({
    id: 'list_tomer_misc', name: 'דברים לקנות 📝', status: 'active', type: 'other',
    budget: null, is_shared: false, is_private: true, created_by: uids.tomer,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(7).toISOString(), updated_date: daysAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      makeTaskItem('item_misc_0', 'סוללות AA', { priority: 'medium' }),
      makeTaskItem('item_misc_1', 'מטען לאייפון', { isChecked: true }),
      makeTaskItem('item_misc_2', 'מפתח חלופי לבית', { priority: 'high' }),
    ],
  });
  console.log('   📋 תומר: דברים לקנות (OTHER type, 3 tasks)');

  // ── NAAMA: Large supermarket list (performance test) ──
  const naamaProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket' && p.price), 50);
  await db.collection('users').doc(uids.naama).collection('private_lists').doc('list_naama_big').set({
    id: 'list_naama_big', name: 'קניות חודשיות 🛒', status: 'active', type: 'supermarket',
    budget: 2000, is_shared: false, is_private: true, created_by: uids.naama,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(5).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: naamaProducts.map((p, i) => makeProductItem(p, i, { id: `item_nb_${i}`, isChecked: i < 20 })),
  });
  console.log('   📋 נעמה: קניות חודשיות (50 items! performance test, 20/50 checked)');

  // ── NAAMA: 8 completed past lists (history) ──
  for (let w = 1; w <= 8; w++) {
    const pastProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket' && p.price), randomInt(8, 15));
    await db.collection('users').doc(uids.naama).collection('private_lists').doc(`list_naama_past_${w}`).set({
      id: `list_naama_past_${w}`, name: `קניות שבוע ${w}`, status: 'completed', type: 'supermarket',
      budget: null, is_shared: false, is_private: true, created_by: uids.naama,
      format: 'personal', created_from_template: false,
      created_date: daysAgo(w * 7 + 5).toISOString(), updated_date: daysAgo(w * 7).toISOString(),
      shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
      items: pastProducts.map((p, i) => makeProductItem(p, i, { id: `item_np${w}_${i}`, isChecked: true })),
    });
  }
  console.log('   📋 נעמה: 8 completed past lists (history)');

  // ── NAAMA: Budget list ──
  const budgetProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket' && p.price && p.price < 30), 10);
  await db.collection('users').doc(uids.naama).collection('private_lists').doc('list_naama_budget').set({
    id: 'list_naama_budget', name: 'קניות בתקציב 💰', status: 'active', type: 'supermarket',
    budget: 300, is_shared: false, is_private: true, created_by: uids.naama,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(4).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: budgetProducts.map((p, i) => makeProductItem(p, i, { id: `item_bgt_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 נעמה: קניות בתקציב (budget: 300₪, 10 items)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. INVENTORY (PANTRY) — under households/{hId}/inventory
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📦 Creating inventory...');

  async function createInventory(hId, inventoryProducts, ownerUid, opts = {}) {
    for (let i = 0; i < inventoryProducts.length; i++) {
      const p = inventoryProducts[i];
      const qty = opts.forceQty !== undefined ? opts.forceQty(i) : randomInt(1, 6);
      const minQty = i < 3 ? 3 : randomInt(1, 2);
      await db.collection('households').doc(hId).collection('inventory').doc(`inv_${hId}_${i}`).set({
        id: `inv_${hId}_${i}`,
        product_name: p.name,
        category: p.category || 'כללי',
        location: locationForCategory(p.category),
        quantity: qty,
        unit: normalizeUnit(p.unit),
        min_quantity: minQty,
        expiry_date: p.category === 'מוצרי חלב' ? daysFromNow(i < 2 ? 2 : 14).toISOString() : null,
        notes: null,
        is_recurring: Math.random() > 0.3,
        emoji: p.icon || null,
        last_updated_by: ownerUid,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
        last_purchased: daysAgo(randomInt(1, 14)).toISOString(),
        purchase_count: randomInt(0, 20),
      });
    }
  }

  // Cohen: 20 items (2 low stock, 1 out of stock)
  const cohenPantry = pickRandom(byCategory(products, 'מוצרי חלב', 'אורז ופסטה', 'שימורים', 'מוצרי ניקיון', 'משקאות', 'תבלינים ואפייה', 'ממתקים וחטיפים'), 20);
  await createInventory(hIds.cohen, cohenPantry, uids.avi, { forceQty: (i) => i === 0 ? 0 : i === 1 ? 1 : randomInt(2, 6) });
  console.log('   📦 כהן: 20 items (1 out-of-stock, 1 low)');

  // Levi: 12 items
  const leviPantry = pickRandom(byCategory(products, 'מוצרי חלב', 'פירות וירקות', 'משקאות', 'אורז ופסטה'), 12);
  await createInventory(hIds.levi, leviPantry, uids.dan, { forceQty: (i) => i < 2 ? 0 : randomInt(1, 5) });
  console.log('   📦 לוי: 12 items (2 out-of-stock)');

  // Tomer: 8 items
  const tomerPantry = pickRandom(byCategory(products, 'אורז ופסטה', 'שימורים', 'משקאות'), 8);
  await createInventory(hIds.tomer, tomerPantry, uids.tomer);
  console.log('   📦 תומר: 8 items');

  // Shiran: 15 items (user with pantry but no lists)
  const shiranPantry = pickRandom(byCategory(products, 'מוצרי חלב', 'פירות וירקות', 'אורז ופסטה', 'תבלינים ואפייה', 'לחם ומאפים'), 15);
  await createInventory(hIds.shiran, shiranPantry, uids.shiran);
  console.log('   📦 שירן: 15 items (no lists — tests pantry-only view)');

  // Naama: 35 items (power user, 5 with expiry soon)
  const naamaPantry = pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 35);
  await createInventory(hIds.naama, naamaPantry, uids.naama, { forceQty: (i) => i < 5 ? randomInt(0, 1) : randomInt(2, 8) });
  console.log('   📦 נעמה: 35 items (5 low stock — power user)');

  // Lior: 2 items (inactive)
  const liorPantry = pickRandom(byCategory(products, 'שימורים'), 2);
  await createInventory(hIds.lior, liorPantry, uids.lior);
  console.log('   📦 ליאור: 2 items (inactive user)');

  // Yael: 0 items (fresh user — empty state)
  console.log('   📦 יעל: 0 items (fresh user — tests empty state)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. RECEIPTS — under households/{hId}/receipts
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🧾 Creating receipts...');
  const storeNames = ['שופרסל דיל ירושלים', 'רמי לוי שורש', 'יוחננוף נוה יעקב', 'AM:PM בן יהודה', 'מחסני השוק תלפיות'];

  async function createReceipts(hId, shopperUids, count, storePool, linkedListId) {
    for (let w = 1; w <= count; w++) {
      const date = daysAgo(w * randomInt(2, 5));
      const shopperUid = shopperUids[w % shopperUids.length];
      const numItems = randomInt(5, 18);
      const items = pickRandom(products.filter(p => p.price && p.sourceFile === 'supermarket'), numItems)
        .map((p, i) => makeReceiptItem(p, i, shopperUid, date));
      const totalAmount = items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0);

      await db.collection('households').doc(hId).collection('receipts').doc(`receipt_${hId}_${w}`).set({
        id: `receipt_${hId}_${w}`,
        store_name: storePool[w % storePool.length],
        date: date.toISOString(),
        created_date: date.toISOString(),
        household_id: hId,
        items,
        total_amount: Math.round(totalAmount * 100) / 100,
        is_virtual: true,
        created_by: shopperUid,
        linked_shopping_list_id: linkedListId || null,
      });
    }
  }

  await createReceipts(hIds.cohen, [uids.avi, uids.ronit, uids.ronit, uids.avi, uids.yuval], 20, storeNames.slice(0, 3), 'list_cohen_lastweek');
  console.log('   🧾 כהן: 20 receipts');

  await createReceipts(hIds.levi, [uids.dan, uids.maya], 12, ['רמי לוי שורש', 'שופרסל']);
  console.log('   🧾 לוי: 12 receipts');

  await createReceipts(hIds.tomer, [uids.tomer], 8, ['AM:PM בן יהודה', 'שופרסל דיל']);
  console.log('   🧾 תומר: 8 receipts');

  await createReceipts(hIds.naama, [uids.naama], 25, storeNames);
  console.log('   🧾 נעמה: 25 receipts');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. NOTIFICATIONS — under users/{uid}/notifications
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🔔 Creating notifications...');

  async function createNotifications(uid, notifs) {
    for (const n of notifs) {
      await db.collection('users').doc(uid).collection('notifications').doc(n.id).set(n);
    }
  }

  // Avi notifications (10)
  await createNotifications(uids.avi, [
    makeNotification('notif_avi_1', uids.avi, hIds.cohen, 'invite', 'הזמנה לרשימה', 'רונית הזמינה אותך לרשימת "קניות שבועיות"', { createdAt: daysAgo(7), isRead: true, readAt: daysAgo(7), senderId: uids.ronit, senderName: 'רונית כהן', actionData: { listId: 'list_cohen_weekly' } }),
    makeNotification('notif_avi_2', uids.avi, hIds.cohen, 'request_approved', 'בקשה אושרה', 'הבקשה שלך להוסיף "קולה זירו" אושרה', { createdAt: daysAgo(5), isRead: true, readAt: daysAgo(5), senderId: uids.ronit, senderName: 'רונית כהן', actionData: { listId: 'list_cohen_weekly', requestId: 'req_yuval_old' } }),
    makeNotification('notif_avi_3', uids.avi, hIds.cohen, 'request_rejected', 'בקשה נדחתה', 'הבקשה של נועה להוסיף "שוקולד פרה" נדחתה', { createdAt: daysAgo(3), isRead: true, readAt: daysAgo(3), senderId: uids.avi, senderName: 'אבי כהן', actionData: { listId: 'list_cohen_weekly' } }),
    makeNotification('notif_avi_4', uids.avi, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'יובל כהן התנדב להביא "סלט ירקות"', { createdAt: hoursAgo(5), senderId: uids.yuval, senderName: 'יובל כהן', actionData: { listId: 'list_cohen_shabbat', volunteerName: 'יובל כהן' } }),
    makeNotification('notif_avi_5', uids.avi, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'נועה כהן התנדבה להביא "קינוח"', { createdAt: hoursAgo(3), senderId: uids.noa, senderName: 'נועה כהן', actionData: { listId: 'list_cohen_shabbat', volunteerName: 'נועה כהן' } }),
    makeNotification('notif_avi_6', uids.avi, hIds.cohen, 'low_stock', 'מלאי נמוך', 'המלאי של "חלב תנובה 3%" נגמר', { createdAt: hoursAgo(8), actionData: { productName: 'חלב תנובה 3%' } }),
    makeNotification('notif_avi_7', uids.avi, hIds.cohen, 'low_stock', 'מלאי נמוך', 'נשארה יחידה אחרונה של "ביצים L', { createdAt: hoursAgo(6), actionData: { productName: 'ביצים L' } }),
    makeNotification('notif_avi_8', uids.avi, hIds.cohen, 'role_changed', 'שינוי תפקיד', 'אורי שלום קיבל תפקיד צפייה ברשימת "קניות שבועיות"', { createdAt: daysAgo(60), isRead: true, readAt: daysAgo(60), actionData: { listId: 'list_cohen_weekly', newRole: 'viewer' } }),
    makeNotification('notif_avi_9', uids.avi, hIds.cohen, 'member_left', 'חבר עזב', 'ליאור דהן עזב את הבית', { createdAt: daysAgo(45), isRead: true, readAt: daysAgo(44), actionData: {} }),
    makeNotification('notif_avi_10', uids.avi, hIds.cohen, 'invite', 'הזמנה לבית', 'נעמה רוזן הזמינה אותך להצטרף לבית שלה', { createdAt: hoursAgo(3), senderId: uids.naama, senderName: 'נעמה רוזן', actionData: { householdId: hIds.naama } }),
  ]);
  console.log('   🔔 אבי: 10 notifications (4 unread)');

  // Ronit notifications (5)
  await createNotifications(uids.ronit, [
    makeNotification('notif_ronit_1', uids.ronit, hIds.cohen, 'invite', 'הזמנה לרשימה', 'יובל ביקש להוסיף "במבה 80 גרם" לקניות שבועיות', { createdAt: hoursAgo(2), senderId: uids.yuval, senderName: 'יובל כהן', actionData: { listId: 'list_cohen_weekly', requestId: 'req_yuval_1' } }),
    makeNotification('notif_ronit_2', uids.ronit, hIds.cohen, 'invite', 'בקשה חדשה', 'נועה ביקשה להוסיף "נייר טואלט" לקניות שבועיות', { createdAt: hoursAgo(0.5), senderId: uids.noa, senderName: 'נועה כהן', actionData: { listId: 'list_cohen_weekly', requestId: 'req_noa_1' } }),
    makeNotification('notif_ronit_3', uids.ronit, hIds.cohen, 'low_stock', 'מלאי נמוך', 'המלאי של "חלב תנובה 3%" נגמר', { createdAt: hoursAgo(8), actionData: { productName: 'חלב תנובה 3%' } }),
    makeNotification('notif_ronit_4', uids.ronit, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'יובל כהן התנדב להביא "סלט ירקות"', { createdAt: hoursAgo(5), senderId: uids.yuval, senderName: 'יובל כהן', actionData: { listId: 'list_cohen_shabbat' } }),
    makeNotification('notif_ronit_5', uids.ronit, hIds.cohen, 'request_approved', 'בקשה אושרה', 'אישרת את הבקשה של יובל להוסיף "קולה זירו"', { createdAt: daysAgo(3), isRead: true, readAt: daysAgo(3), actionData: { listId: 'list_cohen_weekly' } }),
  ]);
  console.log('   🔔 רונית: 5 notifications (4 unread)');

  // Naama notifications (8)
  await createNotifications(uids.naama, [
    makeNotification('notif_naama_1', uids.naama, hIds.naama, 'low_stock', 'מלאי נמוך', 'נשארה יחידה אחרונה של "אורז בסמטי"', { createdAt: hoursAgo(4), actionData: { productName: 'אורז בסמטי' } }),
    makeNotification('notif_naama_2', uids.naama, hIds.naama, 'low_stock', 'מלאי נמוך', 'המלאי של "שמן זית" נגמר', { createdAt: hoursAgo(3), actionData: { productName: 'שמן זית' } }),
    makeNotification('notif_naama_3', uids.naama, hIds.naama, 'low_stock', 'מלאי נמוך', 'נשאר מעט "סוכר"', { createdAt: hoursAgo(2), actionData: { productName: 'סוכר' } }),
    makeNotification('notif_naama_4', uids.naama, hIds.naama, 'low_stock', 'מלאי נמוך', 'המלאי של "קמח" נגמר', { createdAt: hoursAgo(1), actionData: { productName: 'קמח' } }),
    makeNotification('notif_naama_5', uids.naama, hIds.naama, 'low_stock', 'מלאי נמוך', 'נשאר מעט "חלב"', { createdAt: hoursAgo(0.5), actionData: { productName: 'חלב' } }),
    makeNotification('notif_naama_6', uids.naama, hIds.naama, 'invite', 'הזמנה', 'דן לוי הזמין אותך להצטרף למשפחת לוי', { createdAt: daysAgo(5), senderId: uids.dan, senderName: 'דן לוי', actionData: { householdId: hIds.levi } }),
    makeNotification('notif_naama_7', uids.naama, hIds.naama, 'request_approved', 'בקשה אושרה', 'הבקשה שלך אושרה', { createdAt: daysAgo(10), isRead: true, readAt: daysAgo(10), actionData: {} }),
    makeNotification('notif_naama_8', uids.naama, hIds.naama, 'request_rejected', 'בקשה נדחתה', 'הבקשה שלך נדחתה', { createdAt: daysAgo(12), isRead: true, readAt: daysAgo(11), actionData: {} }),
  ]);
  console.log('   🔔 נעמה: 8 notifications (6 unread)');

  // Lior: 1 old notification (inactive user)
  await createNotifications(uids.lior, [
    makeNotification('notif_lior_1', uids.lior, hIds.lior, 'low_stock', 'מלאי נמוך', 'נשאר מעט "שימורי טונה"', { createdAt: daysAgo(45), actionData: { productName: 'שימורי טונה' } }),
  ]);
  console.log('   🔔 ליאור: 1 notification (45 days old, unread)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 8. PENDING INVITES — top-level pending_invites collection (PendingRequest schema)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n✉️ Creating pending invites...');

  // Dan invites Naama to Levi household (pending)
  await db.collection('pending_invites').doc('invite_dan_naama').set({
    id: 'invite_dan_naama',
    list_id: hIds.levi, // reused for householdId in household invites
    requester_id: uids.dan,
    type: 'inviteToHousehold',
    status: 'pending',
    created_at: daysAgo(5).toISOString(),
    requester_name: 'דן לוי',
    reviewer_id: null, reviewed_at: null, rejection_reason: null, reviewer_name: null, list_name: null,
    request_data: {
      invited_user_id: uids.naama,
      invited_user_email: 'naama.rozen@demo.com',
      invited_user_name: 'נעמה רוזן',
      household_id: hIds.levi,
      household_name: 'משפחת לוי',
      role: 'editor',
    },
  });
  console.log('   ✉️ דן → נעמה: הצטרפי ללוי (pending)');

  // Naama invites Avi to her household (pending)
  await db.collection('pending_invites').doc('invite_naama_avi').set({
    id: 'invite_naama_avi',
    list_id: hIds.naama,
    requester_id: uids.naama,
    type: 'inviteToHousehold',
    status: 'pending',
    created_at: hoursAgo(3).toISOString(),
    requester_name: 'נעמה רוזן',
    reviewer_id: null, reviewed_at: null, rejection_reason: null, reviewer_name: null, list_name: null,
    request_data: {
      invited_user_id: uids.avi,
      invited_user_email: 'avi.cohen@demo.com',
      invited_user_name: 'אבי כהן',
      household_id: hIds.naama,
      household_name: 'הבית של נעמה',
      role: 'editor',
    },
  });
  console.log('   ✉️ נעמה → אבי: הצטרף לבית שלי (pending)');

  // Old rejected invite
  await db.collection('pending_invites').doc('invite_old_rejected').set({
    id: 'invite_old_rejected',
    list_id: hIds.lior,
    requester_id: uids.lior,
    type: 'inviteToHousehold',
    status: 'rejected',
    created_at: daysAgo(60).toISOString(),
    requester_name: 'ליאור דהן',
    reviewer_id: uids.tomer, reviewed_at: daysAgo(59).toISOString(),
    rejection_reason: null, reviewer_name: 'תומר בר', list_name: null,
    request_data: {
      invited_user_id: uids.tomer,
      invited_user_email: 'tomer.bar@demo.com',
      invited_user_name: 'תומר בר',
      household_id: hIds.lior,
      household_name: 'הבית של ליאור',
      role: 'editor',
    },
  });
  console.log('   ✉️ ליאור → תומר: הזמנה ישנה (rejected)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n' + '═'.repeat(55));
  console.log('✅ Demo data created successfully!');
  console.log('═'.repeat(55));
  console.log(`\n👥 ${USERS.length} users`);
  console.log(`🏠 ${Object.keys(HOUSEHOLDS).length} households`);
  console.log(`📋 ~27 shopping lists (all 9 types + active/completed/archived)`);
  console.log(`📦 ~92 inventory items`);
  console.log(`🧾 65 receipts`);
  console.log(`🔔 ~24 notifications`);
  console.log(`✉️ 3 pending invites (2 pending + 1 rejected)`);
  console.log(`\n🔑 Password: ${DEMO_PASSWORD}`);
  console.log('\n📧 Users:');
  for (const u of USERS) {
    console.log(`   ${u.email} — ${u.name}`);
  }
  console.log('\n🎯 Special test users:');
  console.log('   yael.fresh@demo.com — Empty states (0 everything)');
  console.log('   lior.dahan@demo.com — Inactive (45+ days)');
  console.log('   naama.rozen@demo.com — Power user (50-item list, 35 pantry, 25 receipts)');
  console.log('   shiran.gal@demo.com — Pantry only (no lists)');
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
