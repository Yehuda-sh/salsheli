// rebuild_demo_data.js — Complete demo data rebuild with realistic activities
// Properly follows app code: correct Firestore paths, role-based behavior, real product names
// Run: node scripts/rebuild_demo_data.js
//
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

const DEMO_PASSWORD = 'Demo123456!';
const now = new Date();
const DAY = 86400000;
const HOUR = 3600000;

function daysAgo(n) { return new Date(now.getTime() - n * DAY); }
function hoursAgo(n) { return new Date(now.getTime() - n * HOUR); }
function pickRandom(arr, count) { return [...arr].sort(() => Math.random() - 0.5).slice(0, Math.min(count, arr.length)); }
function randomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

// ═══════════════════════════════════════════════════════════════
// LOAD REAL PRODUCTS FROM JSON
// ═══════════════════════════════════════════════════════════════
function loadProducts() {
  const products = [];
  for (const f of ['supermarket','bakery','butcher','greengrocer','pharmacy','market']) {
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

function locationForCategory(cat) {
  const map = {
    'מוצרי חלב': 'מקרר', 'בשר ודגים': 'מקפיא',
    'פירות וירקות': 'מקרר', 'לחם ומאפים': 'מטבח',
    'מוצרי ניקיון': 'מחסן', 'היגיינה אישית': 'אמבטיה',
    'משקאות': 'מזווה', 'שימורים': 'מזווה', 'אורז ופסטה': 'מזווה',
    'תבלינים ואפייה': 'מזווה', 'ממתקים וחטיפים': 'מזווה',
    'קפה ותה': 'מזווה', 'קפואים': 'מקפיא',
    'מוצרי בית': 'מחסן', 'שמנים ורטבים': 'מזווה',
  };
  return map[cat] || 'מזווה';
}

// ═══════════════════════════════════════════════════════════════
// ALL 12 USERS
// ═══════════════════════════════════════════════════════════════
const USERS = [
  // ═══ Cohen Family (4 members, multi-role household) ═══
  { key: 'avi',    name: 'אבי כהן',    email: 'avi.cohen@demo.com',    phone: '0501234567', household: 'cohen', householdRole: 'admin',  familySize: 4, stores: ['שופרסל', 'רמי לוי'],  budget: 2000 },
  { key: 'ronit',  name: 'רונית כהן',   email: 'ronit.cohen@demo.com',  phone: '0502345678', household: 'cohen', householdRole: 'admin',  familySize: 4, stores: ['שופרסל', 'יוחננוף'], budget: 2000 },
  { key: 'yuval',  name: 'יובל כהן',    email: 'yuval.cohen@demo.com',  phone: '0503456789', household: 'cohen', householdRole: 'member', familySize: 4, stores: ['AM:PM', 'שופרסל'],   budget: 200 },
  { key: 'noa',    name: 'נועה כהן',    email: 'noa.cohen@demo.com',    phone: '0504567890', household: 'cohen', householdRole: 'member', familySize: 4, stores: ['שופרסל'],            budget: 150 },
  // ═══ Levi Couple (2 members, both admin) ═══
  { key: 'dan',    name: 'דן לוי',      email: 'dan.levi@demo.com',     phone: '0505678901', household: 'levi',  householdRole: 'admin',  familySize: 2, stores: ['רמי לוי'],           budget: 1200 },
  { key: 'maya',   name: 'מאיה לוי',    email: 'maya.levi@demo.com',    phone: '0506789012', household: 'levi',  householdRole: 'admin',  familySize: 2, stores: ['רמי לוי', 'שופרסל'], budget: 1200 },
  // ═══ Solo users ═══
  { key: 'tomer',  name: 'תומר בר',     email: 'tomer.bar@demo.com',    phone: '0507890123', household: 'tomer', householdRole: 'admin',  familySize: 1, stores: ['AM:PM'],             budget: 600 },
  { key: 'shiran', name: 'שירן גל',     email: 'shiran.gal@demo.com',   phone: '0508901234', household: 'shiran',householdRole: 'admin',  familySize: 1, stores: ['שופרסל'],            budget: 500 },
  // ═══ Grandpa viewer ═══
  { key: 'ori',    name: 'אורי שלום',   email: 'ori.shalom@demo.com',   phone: '0509012345', household: 'cohen', householdRole: 'member', familySize: 1, stores: ['שופרסל'],            budget: 0 },
  // ═══ Inactive user ═══
  { key: 'lior',   name: 'ליאור דהן',   email: 'lior.dahan@demo.com',   phone: '0510123456', household: 'lior',  householdRole: 'admin',  familySize: 1, stores: [],                    budget: 0 },
  // ═══ Power user ═══
  { key: 'naama',  name: 'נעמה רוזן',   email: 'naama.rozen@demo.com',  phone: '0511234567', household: 'naama', householdRole: 'admin',  familySize: 1, stores: ['רמי לוי','שופרסל','AM:PM','מחסני השוק'], budget: 1500 },
  // ═══ Fresh user (empty states) ═══
  { key: 'yael',   name: 'יעל חדשה',    email: 'yael.fresh@demo.com',   phone: '0512345678', household: 'yael',  householdRole: 'admin',  familySize: 1, stores: [],                    budget: 0 },
];

const HOUSEHOLDS = {
  cohen:  { name: 'משפחת כהן',    members: ['avi','ronit','yuval','noa','ori'] },
  levi:   { name: 'הזוג לוי',      members: ['dan','maya'] },
  tomer:  { name: 'הבית של תומר',  members: ['tomer'] },
  shiran: { name: 'הבית של שירן',  members: ['shiran'] },
  lior:   { name: 'הבית של ליאור', members: ['lior'] },
  naama:  { name: 'הבית של נעמה',  members: ['naama'] },
  yael:   { name: 'הבית של יעל',   members: ['yael'] },
};

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════
async function main() {
  const products = loadProducts();
  console.log(`📦 ${products.length} מוצרים נטענו\n`);

  const uids = {};

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. CREATE/GET AUTH USERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👥 Auth users...');
  for (const u of USERS) {
    try {
      const record = await auth.createUser({ email: u.email, password: DEMO_PASSWORD, displayName: u.name });
      uids[u.key] = record.uid;
      console.log(`   ✅ ${u.name}`);
    } catch (e) {
      if (e.code === 'auth/email-already-exists') {
        const existing = await auth.getUserByEmail(u.email);
        uids[u.key] = existing.uid;
        console.log(`   ♻️ ${u.name} (exists)`);
      } else throw e;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. CREATE HOUSEHOLDS + MEMBERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🏠 Households...');
  for (const [hKey, hData] of Object.entries(HOUSEHOLDS)) {
    const hId = `household_${hKey}`;
    const creatorKey = hData.members[0];
    await db.collection('households').doc(hId).set({
      id: hId, name: hData.name, created_by: uids[creatorKey],
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    for (const mKey of hData.members) {
      const mUser = USERS.find(u => u.key === mKey);
      await db.collection('households').doc(hId).collection('members').doc(uids[mKey]).set({
        name: mUser.name, role: mUser.householdRole,
        joined_at: mKey === 'ori' ? daysAgo(60).toISOString() : admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    console.log(`   🏠 ${hData.name} (${hData.members.length})`);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. CREATE USER DOCUMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📝 User documents...');
  const userMeta = {
    avi:    { joinedDays: 180, lastLoginHours: 2,   seenTutorial: true },
    ronit:  { joinedDays: 180, lastLoginHours: 0.5, seenTutorial: true },
    yuval:  { joinedDays: 150, lastLoginHours: 6,   seenTutorial: true },
    noa:    { joinedDays: 120, lastLoginHours: 12,  seenTutorial: true },
    dan:    { joinedDays: 90,  lastLoginHours: 24,  seenTutorial: true },
    maya:   { joinedDays: 90,  lastLoginHours: 3,   seenTutorial: true },
    tomer:  { joinedDays: 60,  lastLoginHours: 48,  seenTutorial: true },
    shiran: { joinedDays: 30,  lastLoginHours: 72,  seenTutorial: true },
    ori:    { joinedDays: 60,  lastLoginHours: 72,  seenTutorial: true },
    lior:   { joinedDays: 120, lastLoginHours: 1080, seenTutorial: true }, // 45 days ago
    naama:  { joinedDays: 180, lastLoginHours: 1,   seenTutorial: true },
    yael:   { joinedDays: 0,   lastLoginHours: 0.5, seenTutorial: false }, // just signed up
  };

  for (const u of USERS) {
    const meta = userMeta[u.key];
    const hId = `household_${u.household}`;
    await db.collection('users').doc(uids[u.key]).set({
      id: uids[u.key], name: u.name, email: u.email, phone: u.phone,
      household_id: hId, household_name: HOUSEHOLDS[u.household].name,
      joined_at: daysAgo(meta.joinedDays).toISOString(),
      last_login_at: hoursAgo(meta.lastLoginHours).toISOString(),
      preferred_stores: u.stores, favorite_products: [],
      weekly_budget: u.budget, is_admin: u.householdRole === 'admin',
      family_size: u.familySize, shopping_frequency: u.familySize > 2 ? 3 : 1,
      shopping_days: [], has_children: u.familySize > 2, share_lists: true,
      reminder_time: u.householdRole === 'admin' ? '09:00' : null,
      seen_onboarding: true, seen_tutorial: meta.seenTutorial,
    });
  }
  console.log('   📝 12 users created');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. SHOPPING LISTS — realistic, role-aware
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📋 Shopping lists...');

  // Helper to create a list item from a product
  function makeItem(p, idx, opts = {}) {
    return {
      id: opts.id || `item_${idx}`,
      name: p.name,
      quantity: opts.quantity || randomInt(1, 3),
      unit: p.unit || "יח'",
      unit_price: p.price || 0,
      category: p.category,
      type: opts.type || 'product',
      is_checked: opts.isChecked || false,
      emoji: p.icon || opts.emoji || null,
      notes: opts.notes || null,
      ...(opts.checkedBy ? { checked_by: opts.checkedBy, checked_at: opts.checkedAt } : {}),
    };
  }

  function makeTask(id, name, emoji, opts = {}) {
    return {
      id, name, quantity: 1, unit: "יח'", unit_price: 0,
      category: null, type: 'task', is_checked: opts.isChecked || false,
      emoji, notes: opts.notes || null,
    };
  }

  const hCohen = 'household_cohen';
  const hLevi = 'household_levi';
  const hTomer = 'household_tomer';
  const hNaama = 'household_naama';

  // ──── COHEN: Weekly supermarket (active, shared) ────
  // Owner: רונית | Admin: אבי (household) | Editors: יובל, נועה | Viewer: אורי
  const weeklyProducts = pickRandom(byCategory(products, 'מוצרי חלב','לחם ומאפים','פירות וירקות','ביצים','משקאות','שמנים ורטבים'), 14);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_weekly').set({
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
      // יובל (editor) requests — needs approval from owner/admin
      { id: 'req_yuval_1', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'addItem', status: 'pending',
        created_at: hoursAgo(2).toISOString(),
        request_data: { name: 'במבה 80 גרם', quantity: 3, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'יובל כהן', reviewer_name: null },
      { id: 'req_yuval_2', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'addItem', status: 'pending',
        created_at: hoursAgo(1.5).toISOString(),
        request_data: { name: 'ביסלי גריל 200 גרם', quantity: 2, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'יובל כהן', reviewer_name: null },
      // נועה (editor) request
      { id: 'req_noa_1', list_id: 'list_cohen_weekly', requester_id: uids.noa, type: 'addItem', status: 'pending',
        created_at: hoursAgo(0.5).toISOString(),
        request_data: { name: 'נייר טואלט טאצ\' 32 גלילים', quantity: 1, unit: "יח'", category: 'מוצרי בית', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'נועה כהן', reviewer_name: null },
      // Previously approved by רונית (owner)
      { id: 'req_yuval_old', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'addItem', status: 'approved',
        created_at: daysAgo(3).toISOString(),
        request_data: { name: 'קולה זירו 1.5 ליטר', quantity: 2, unit: "יח'", category: 'משקאות', type: 'product' },
        reviewer_id: uids.ronit, reviewed_at: daysAgo(3).toISOString(), requester_name: 'יובל כהן', reviewer_name: 'רונית כהן' },
      // Previously rejected by אבי (admin)
      { id: 'req_noa_old', list_id: 'list_cohen_weekly', requester_id: uids.noa, type: 'addItem', status: 'rejected',
        created_at: daysAgo(2).toISOString(),
        request_data: { name: 'שוקולד פרה אדום 100 גרם', quantity: 5, unit: "יח'", category: 'ממתקים וחטיפים', type: 'product' },
        reviewer_id: uids.avi, reviewed_at: daysAgo(2).toISOString(), requester_name: 'נועה כהן', reviewer_name: 'אבי כהן' },
    ],
    active_shoppers: [],
    items: weeklyProducts.map((p, i) => makeItem(p, i, { id: `item_cw_${i}`, isChecked: i < 4 })),
  });
  console.log('   📋 כהן: קניות שבועיות (14 items, 3 pending requests, editors+viewer)');

  // ──── COHEN: Greengrocer (ACTIVE SHOPPING by רונית!) ────
  const greenProducts = pickRandom(byCategory(products, 'פירות וירקות'), 10);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_green').set({
    id: 'list_cohen_green', name: 'ירקות ופירות לשבוע', status: 'active', type: 'greengrocer',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(5).toISOString(), updated_date: hoursAgo(0.3).toISOString(),
    shared_with: [uids.avi], shared_users: {}, pending_requests: [],
    active_shoppers: [{
      user_id: uids.ronit, user_name: 'רונית כהן',
      started_at: hoursAgo(0.5).toISOString(), is_active: true, is_starter: true,
    }],
    items: greenProducts.map((p, i) => makeItem(p, i, {
      id: `item_cg_${i}`, isChecked: i < 4,
      checkedBy: i < 4 ? uids.ronit : null,
      checkedAt: i < 4 ? hoursAgo(0.3).toISOString() : null,
    })),
  });
  console.log('   📋 כהן: ירקות ופירות (10, ACTIVE SHOPPING by רונית, 4/10 checked)');

  // ──── COHEN: Bakery for shabbat ────
  const bakeryProducts = pickRandom(products.filter(p => p.sourceFile === 'bakery'), 5);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_bakery').set({
    id: 'list_cohen_bakery', name: 'מאפייה לשבת 🥖', status: 'active', type: 'bakery',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    shared_with: [uids.avi, uids.noa],
    shared_users: {
      [uids.noa]: { role: 'editor', shared_at: daysAgo(7).toISOString(), user_name: 'נועה כהן', user_email: 'noa.cohen@demo.com', can_start_shopping: true },
    },
    pending_requests: [
      { id: 'req_noa_bk1', list_id: 'list_cohen_bakery', requester_id: uids.noa, type: 'addItem', status: 'pending',
        created_at: hoursAgo(1).toISOString(),
        request_data: { name: 'עוגת שוקולד', quantity: 1, unit: "יח'", category: 'עוגות', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'נועה כהן', reviewer_name: null },
    ],
    active_shoppers: [],
    items: [
      ...bakeryProducts.map((p, i) => makeItem(p, i, { id: `item_bk_${i}`, isChecked: i === 0, notes: i === 0 ? 'הגדולה, לא הקטנה' : null })),
    ],
  });
  console.log('   📋 כהן: מאפייה לשבת (5, editor נועה + 1 pending)');

  // ──── COHEN: Butcher for friday ────
  const butcherProducts = pickRandom(products.filter(p => p.sourceFile === 'butcher'), 6);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_butcher').set({
    id: 'list_cohen_butcher', name: 'קצביה ליום שישי 🥩', status: 'active', type: 'butcher',
    budget: null, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.ronit], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: butcherProducts.map((p, i) => makeItem(p, i, { id: `item_bt_${i}`, isChecked: i < 2 })),
  });
  console.log('   📋 כהן: קצביה ליום שישי (6, 2/6 checked)');

  // ──── COHEN: Mixed products + tasks ────
  const mixedProducts = pickRandom(byCategory(products, 'מוצרי חלב','שימורים','מוצרי ניקיון','ממתקים וחטיפים'), 6);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_mixed').set({
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
      ...mixedProducts.map((p, i) => makeItem(p, i, { id: `item_mix_p${i}`, isChecked: i < 2 })),
      makeTask('item_mix_t0', 'לנקות את המקרר', '🧹', { notes: 'לפני שמכניסים קניות' }),
      makeTask('item_mix_t1', 'להוציא בשר מהמקפיא', '🥩', { isChecked: true, notes: 'לארוחת שבת' }),
      makeTask('item_mix_t2', 'לבדוק תאריכי תפוגה במזווה', '📋'),
      makeTask('item_mix_t3', 'להזמין גז', '🔥', { notes: 'אמישראגז 1-800-225-225' }),
    ],
  });
  console.log('   📋 כהן: קניות + משימות (6 products + 4 tasks, editor יובל)');

  // ──── COHEN: Household supplies ────
  const houseProducts = pickRandom(byCategory(products, 'מוצרי בית','מוצרי ניקיון'), 8);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_household').set({
    id: 'list_cohen_household', name: 'צרכי בית 🏠', status: 'active', type: 'household',
    budget: null, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(5).toISOString(), updated_date: daysAgo(1).toISOString(),
    shared_with: [uids.avi], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: houseProducts.map((p, i) => makeItem(p, i, { id: `item_ch_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 כהן: צרכי בית (8, 3/8 checked)');

  // ──── COHEN: Birthday party (completed event) ────
  // catalogItem helper defined later — move birthday after BBQ? No, just use inline search
  function findProd(nameSubstr) { return products.find(p => p.name.includes(nameSubstr)); }
  function catItem(id, nameSubstr, quantity, unit, opts = {}) {
    const p = findProd(nameSubstr);
    if (!p) return { id, name: nameSubstr, quantity, unit, unit_price: 0, category: opts.category || null, type: 'product', is_checked: opts.isChecked || false, emoji: opts.emoji || null, notes: opts.notes || null };
    return { id, name: p.name, quantity, unit: unit || p.unit || "יח'", unit_price: p.price || 0, category: p.category, type: 'product', is_checked: opts.isChecked || false, emoji: p.icon || opts.emoji || null, notes: opts.notes || null };
  }

  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_birthday').set({
    id: 'list_cohen_birthday', name: 'יום הולדת נועה 🎂', status: 'completed', type: 'event',
    budget: 500, is_shared: true, is_private: false, created_by: uids.ronit,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(30).toISOString(), updated_date: daysAgo(28).toISOString(),
    shared_with: [uids.avi, uids.yuval], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      catItem('item_bd_0', 'עוגת שוקולד', 1, "יח'", { isChecked: true, notes: '3 קומות!' }),
      makeTask('item_bd_1', 'נרות יום הולדת', '🕯️', { isChecked: true }),
      makeTask('item_bd_2', 'בלונים ורוד וזהב', '🎈', { isChecked: true, notes: '20 יח\'' }),
      catItem('item_bd_3', '100 כוסות פלסטיק', 1, "יח'", { isChecked: true }),
      catItem('item_bd_4', 'במבה 80 גרם', 5, "יח'", { isChecked: true }),
      catItem('item_bd_5', 'ביסלי גריל 200', 3, "יח'", { isChecked: true }),
      catItem('item_bd_6', 'פריגת תפוזים', 3, "יח'", { isChecked: true }),
      makeTask('item_bd_7', 'להזמין פיצה מדומינוס', '🍕', { isChecked: true, notes: '4 מגשים' }),
    ],
  });
  console.log('   📋 כהן: יום הולדת נועה (completed event, 8 items)');

  // ──── COHEN: Last week completed ────
  const lastWeekProducts = pickRandom(products.filter(p => p.category !== 'אחר'), 15);
  await db.collection('households').doc(hCohen).collection('shared_lists').doc('list_cohen_lastweek').set({
    id: 'list_cohen_lastweek', name: 'קניות שבוע שעבר', status: 'completed', type: 'supermarket',
    budget: 750, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(8).toISOString(), updated_date: daysAgo(6).toISOString(),
    shared_with: [uids.ronit], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: lastWeekProducts.map((p, i) => makeItem(p, i, { id: `item_clw_${i}`, isChecked: true,
      checkedBy: i % 2 === 0 ? uids.avi : uids.ronit,
      checkedAt: daysAgo(6).toISOString(),
    })),
  });
  console.log('   📋 כהן: קניות שבוע שעבר (15, completed)');

  // ──── LEVI: Supermarket ────
  const leviProducts = pickRandom(byCategory(products, 'מוצרי חלב','פירות וירקות','משקאות','אורז ופסטה','קפה ותה'), 9);
  await db.collection('households').doc(hLevi).collection('shared_lists').doc('list_levi_weekly').set({
    id: 'list_levi_weekly', name: 'רשימה לסופר 🛒', status: 'active', type: 'supermarket',
    budget: 500, is_shared: true, is_private: false, created_by: uids.maya,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(5).toISOString(),
    shared_with: [uids.dan], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: leviProducts.map((p, i) => makeItem(p, i, { id: `item_lv_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 לוי: רשימה לסופר (9, 3/9 checked)');

  // ──── LEVI: Completed ────
  const leviCompletedProducts = pickRandom(products, 10);
  await db.collection('households').doc(hLevi).collection('shared_lists').doc('list_levi_done').set({
    id: 'list_levi_done', name: 'קניות שבוע שעבר', status: 'completed', type: 'supermarket',
    budget: 400, is_shared: true, is_private: false, created_by: uids.dan,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(9).toISOString(), updated_date: daysAgo(7).toISOString(),
    shared_with: [uids.maya], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: leviCompletedProducts.map((p, i) => makeItem(p, i, { id: `item_ld_${i}`, isChecked: true })),
  });
  console.log('   📋 לוי: קניות שבוע שעבר (10, completed)');

  // ──── TOMER: Private pharmacy ────
  const pharmProducts = pickRandom(products.filter(p => p.sourceFile === 'pharmacy'), 6);
  await db.collection('households').doc(hTomer).collection('shared_lists').doc('list_tomer_pharm').set({
    id: 'list_tomer_pharm', name: 'סופרפארם 💊', status: 'active', type: 'pharmacy',
    budget: null, is_shared: false, is_private: true, created_by: uids.tomer,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      ...pharmProducts.map((p, i) => makeItem(p, i, { id: `item_tp_${i}` })),
      makeTask('item_tp_task', 'לשאול על מרשם חדש', '📝', { notes: "ד\"ר כהן" }),
    ],
  });
  console.log('   📋 תומר: סופרפארם (private, 6 + 1 task)');

  // ──── TOMER: Small supermarket ────
  const tomerSuperProducts = pickRandom(byCategory(products, 'מוצרי חלב','לחם ומאפים','משקאות'), 5);
  await db.collection('households').doc(hTomer).collection('shared_lists').doc('list_tomer_super').set({
    id: 'list_tomer_super', name: 'AM:PM', status: 'active', type: 'supermarket',
    budget: 100, is_shared: false, is_private: false, created_by: uids.tomer,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(3).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: tomerSuperProducts.map((p, i) => makeItem(p, i, { id: `item_ts_${i}` })),
  });
  console.log('   📋 תומר: AM:PM (5 items, budget 100₪)');

  // ──── NAAMA: Big monthly list (performance test) ────
  const bigProducts = pickRandom(products.filter(p => p.category !== 'אחר' && p.category !== 'כללי'), 50);
  await db.collection('households').doc(hNaama).collection('shared_lists').doc('list_naama_big').set({
    id: 'list_naama_big', name: 'קניות חודשיות 🛒', status: 'active', type: 'supermarket',
    budget: 1500, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(3).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: bigProducts.map((p, i) => makeItem(p, i, { id: `item_nb_${i}`, isChecked: i < 20, quantity: randomInt(1, 5) })),
  });
  console.log('   📋 נעמה: קניות חודשיות (50 items! 20 checked)');

  // ──── NAAMA: Market ────
  const marketProducts = pickRandom(products.filter(p => p.sourceFile === 'market'), 8);
  await db.collection('households').doc(hNaama).collection('shared_lists').doc('list_naama_market').set({
    id: 'list_naama_market', name: 'שוק מחנה יהודה 🏪', status: 'active', type: 'market',
    budget: null, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(6).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: marketProducts.map((p, i) => makeItem(p, i, { id: `item_nm_${i}` })),
  });
  console.log('   📋 נעמה: שוק מחנה יהודה (8)');

  // ──── NAAMA: BBQ event ────
  // All items from REAL catalog! lookup by name substring
  function findProduct(nameSubstr) {
    return products.find(p => p.name.includes(nameSubstr));
  }
  function catalogItem(id, nameSubstr, quantity, unit, opts = {}) {
    const p = findProduct(nameSubstr);
    if (!p) {
      console.warn(`   ⚠️ Product not found: "${nameSubstr}"`);
      return { id, name: nameSubstr, quantity, unit, unit_price: 0, category: opts.category || null, type: 'product', is_checked: opts.isChecked || false, emoji: opts.emoji || null, notes: opts.notes || null };
    }
    return { id, name: p.name, quantity, unit: unit || p.unit || "יח'", unit_price: p.price || 0, category: p.category, type: 'product', is_checked: opts.isChecked || false, emoji: p.icon || opts.emoji || null, notes: opts.notes || null };
  }

  await db.collection('households').doc(hNaama).collection('shared_lists').doc('list_naama_bbq').set({
    id: 'list_naama_bbq', name: 'על האש 🔥 שישי', status: 'active', type: 'event',
    budget: 400, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(12).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      catalogItem('item_bbq_0', 'סטייק אנטריקוט', 2, 'ק"ג'),
      catalogItem('item_bbq_1', 'כנפיים עוף', 2, 'ק"ג', { notes: 'מתובלות' }),
      catalogItem('item_bbq_2', 'קבב אמיתי', 2, "יח'"),
      catalogItem('item_bbq_3', 'שיפוד פרגית', 1, 'ק"ג'),
      catalogItem('item_bbq_4', 'פיתה פיתה 8', 2, "יח'"),
      catalogItem('item_bbq_5', 'חומוס עשיר ב40% טחינה', 1, "יח'"),
      catalogItem('item_bbq_6', 'טחינה בלאדי רפי כהן', 1, "יח'"),
      catalogItem('item_bbq_7', 'סלט מטבוחה 300', 2, "יח'"),
      catalogItem('item_bbq_8', 'בירה גולדסטאר 6 יח', 2, "יח'"),
      catalogItem('item_bbq_9', 'קוקה קולה 1.5 ליטר', 2, "יח'"),
      catalogItem('item_bbq_10', 'מים מינרלים נביעות 1.5', 3, "יח'"),
      makeTask('item_bbq_t0', 'לנקות את המנגל', '🧹'),
      makeTask('item_bbq_t1', 'להביא כסאות מהמחסן', '🪑'),
      makeTask('item_bbq_t2', 'לקנות פחם', '🔥', { notes: 'שק 4 ק"ג' }),
    ],
  });
  console.log('   📋 נעמה: על האש (11 products + 3 tasks, budget 400₪)');

  // ──── NAAMA: Budget list ────
  const budgetProducts = pickRandom(products.filter(p => p.price && p.price > 0 && p.category !== 'אחר'), 12);
  await db.collection('households').doc(hNaama).collection('shared_lists').doc('list_naama_budget').set({
    id: 'list_naama_budget', name: 'קניות בתקציב 💰', status: 'active', type: 'supermarket',
    budget: 300, is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(4).toISOString(), updated_date: hoursAgo(0.5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: budgetProducts.map((p, i) => makeItem(p, i, { id: `item_bgt_${i}`, isChecked: i < 4,
      notes: i === 0 ? 'לבדוק מבצע ברמי לוי' : null })),
  });
  console.log('   📋 נעמה: קניות בתקציב (12, budget=300₪)');

  // ──── NAAMA: Past completed lists (history) ────
  for (let m = 1; m <= 6; m++) {
    const pastProducts = pickRandom(products.filter(p => p.category !== 'אחר'), randomInt(8, 18));
    await db.collection('households').doc(hNaama).collection('shared_lists').doc(`list_naama_past_${m}`).set({
      id: `list_naama_past_${m}`, name: `קניות ${m === 1 ? 'שבוע שעבר' : `לפני ${m} שבועות`}`,
      status: 'completed', type: 'supermarket',
      budget: null, is_shared: false, is_private: false, created_by: uids.naama,
      format: 'shared', created_from_template: false,
      created_date: daysAgo(m * 7 + randomInt(0, 3)).toISOString(),
      updated_date: daysAgo(m * 7 - 1).toISOString(),
      shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
      items: pastProducts.map((p, i) => makeItem(p, i, { id: `item_np${m}_${i}`, isChecked: true })),
    });
  }
  console.log('   📋 נעמה: 6 completed lists (history)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. INVENTORY — in HOUSEHOLD subcollection (correct path!)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📦 Inventory (household-level)...');

  async function createInventory(hId, items, updatedByUid) {
    for (let i = 0; i < items.length; i++) {
      const p = items[i];
      await db.collection('households').doc(hId).collection('inventory').doc(`inv_${hId}_${i}`).set({
        id: `inv_${hId}_${i}`, product_name: p.name, category: p.category,
        location: locationForCategory(p.category),
        quantity: p._qty !== undefined ? p._qty : randomInt(1, 6),
        unit: p.unit || "יח'", min_quantity: p._minQty || 2,
        expiry_date: p.category === 'מוצרי חלב' ? daysAgo(-randomInt(2, 20)).toISOString() : null,
        notes: p._notes || null, is_recurring: Math.random() > 0.3,
        emoji: p.icon || null, purchase_count: randomInt(0, 15), last_purchased: daysAgo(randomInt(1, 30)).toISOString(),
        last_updated_by: updatedByUid, updated_at: daysAgo(randomInt(0, 7)).toISOString(),
      });
    }
  }

  // Cohen: 25 items, some low stock, some expired
  const cohenInventory = pickRandom(byCategory(products,
    'מוצרי חלב','אורז ופסטה','שימורים','מוצרי ניקיון','משקאות','תבלינים ואפייה','קפה ותה','ממתקים וחטיפים','שמנים ורטבים','מוצרי בית'), 25);
  cohenInventory[0]._qty = 0; cohenInventory[0]._minQty = 3; cohenInventory[0]._notes = 'נגמר!';
  cohenInventory[1]._qty = 1; cohenInventory[1]._minQty = 3;
  cohenInventory[2]._qty = 0; cohenInventory[2]._minQty = 2;
  await createInventory(hCohen, cohenInventory, uids.ronit);
  console.log('   📦 כהן: 25 items (3 low/empty)');

  // Levi: 15 items
  const leviInventory = pickRandom(byCategory(products,
    'מוצרי חלב','אורז ופסטה','שימורים','משקאות','תבלינים ואפייה','קפה ותה'), 15);
  leviInventory[0]._qty = 0; leviInventory[0]._minQty = 2;
  leviInventory[1]._qty = 1; leviInventory[1]._minQty = 3;
  await createInventory(hLevi, leviInventory, uids.maya);
  console.log('   📦 לוי: 15 items (2 low)');

  // Tomer: 10 items (solo)
  const tomerInventory = pickRandom(byCategory(products, 'אורז ופסטה','שימורים','משקאות','קפה ותה','ממתקים וחטיפים'), 10);
  await createInventory(hTomer, tomerInventory, uids.tomer);
  console.log('   📦 תומר: 10 items');

  // Naama: 35 items (power user)
  const naamaInventory = pickRandom(products.filter(p => p.category !== 'אחר' && p.category !== 'כללי'), 35);
  for (let i = 0; i < 5; i++) { naamaInventory[i]._qty = randomInt(0, 1); naamaInventory[i]._minQty = 3; }
  await createInventory(hNaama, naamaInventory, uids.naama);
  console.log('   📦 נעמה: 35 items (5 low)');

  // Shiran: 8 items
  const shiranInventory = pickRandom(byCategory(products, 'מוצרי חלב','אורז ופסטה','תבלינים ואפייה','לחם ומאפים'), 8);
  await createInventory('household_shiran', shiranInventory, uids.shiran);
  console.log('   📦 שירן: 8 items');

  // Lior: 2 items (inactive)
  const liorInventory = pickRandom(byCategory(products, 'שימורים'), 2);
  await createInventory('household_lior', liorInventory, uids.lior);
  console.log('   📦 ליאור: 2 items (inactive)');

  // Yael: 0 items (fresh user) — nothing to create
  console.log('   📦 יעל: 0 items (fresh user)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. RECEIPTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🧾 Receipts...');
  const storeNames = ['שופרסל דיל ירושלים', 'רמי לוי שורש', 'יוחננוף נוה יעקב', 'AM:PM בן יהודה', 'מחסני השוק תלפיות'];

  async function createReceipts(hId, shopperUids, count, storePool) {
    for (let w = 1; w <= count; w++) {
      const date = daysAgo(w * randomInt(2, 5));
      const shopperUid = shopperUids[w % shopperUids.length];
      const numItems = randomInt(5, 18);
      const items = pickRandom(products.filter(p => p.price), numItems).map((p, i) => ({
        id: `rcpt_${i}`, name: p.name, quantity: randomInt(1, 4), unit_price: p.price || 0,
        is_checked: true, category: p.category,
        checked_by: shopperUid, checked_at: date.toISOString(),
      }));
      await db.collection('households').doc(hId).collection('receipts').doc(`receipt_${hId}_${w}`).set({
        id: `receipt_${hId}_${w}`, store_name: storePool[w % storePool.length],
        date: date.toISOString(), household_id: hId,
        items, total_amount: items.reduce((s, it) => s + (it.quantity || 1) * (it.unit_price || 0), 0),
        is_virtual: true, created_by: shopperUid, created_at: date.toISOString(),
      });
    }
  }

  await createReceipts(hCohen, [uids.avi, uids.ronit, uids.ronit, uids.avi, uids.yuval], 20, storeNames.slice(0, 3));
  console.log('   🧾 כהן: 20 receipts (אבי, רונית, יובל)');

  await createReceipts(hLevi, [uids.dan, uids.maya], 12, ['רמי לוי שורש', 'שופרסל']);
  console.log('   🧾 לוי: 12 receipts');

  await createReceipts(hTomer, [uids.tomer], 8, ['AM:PM בן יהודה', 'שופרסל דיל']);
  console.log('   🧾 תומר: 8 receipts');

  await createReceipts(hNaama, [uids.naama], 25, storeNames);
  console.log('   🧾 נעמה: 25 receipts');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. NOTIFICATIONS — in users/{uid}/notifications
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🔔 Notifications...');

  async function createNotifications(uid, notifs) {
    for (const n of notifs) {
      await db.collection('users').doc(uid).collection('notifications').doc(n.id).set({
        ...n, user_id: uid,
      });
    }
  }

  // אבי — 10 notifications (4 unread)
  await createNotifications(uids.avi, [
    { id: 'n_avi_1', type: 'shopping_started', title: 'קנייה התחילה!', body: 'רונית התחילה לקנות מ"ירקות ופירות"', created_at: hoursAgo(0.5).toISOString(), read: false, data: {} },
    { id: 'n_avi_2', type: 'item_added', title: 'בקשה חדשה', body: 'יובל מבקש להוסיף "במבה 80 גרם" לרשימה', created_at: hoursAgo(2).toISOString(), read: false, data: {} },
    { id: 'n_avi_3', type: 'item_added', title: 'בקשה חדשה', body: 'נועה מבקשת להוסיף "נייר טואלט" לרשימה', created_at: hoursAgo(0.5).toISOString(), read: false, data: {} },
    { id: 'n_avi_4', type: 'invite_received', title: 'הזמנה חדשה!', body: 'נעמה רוזן הזמינה אותך להצטרף לבית שלה', created_at: hoursAgo(3).toISOString(), read: false, data: { invite_id: 'invite_avi_from_naama' } },
    { id: 'n_avi_5', type: 'shopping_completed', title: 'קנייה הסתיימה', body: 'אבי סיים את הקנייה ב"שופרסל"', created_at: daysAgo(6).toISOString(), read: true, data: {} },
    { id: 'n_avi_6', type: 'low_stock', title: 'מלאי נמוך', body: 'חלב, קפה — נגמרים! הוסף לרשימה', created_at: daysAgo(1).toISOString(), read: true, data: {} },
    { id: 'n_avi_7', type: 'member_joined', title: 'חבר חדש', body: 'אורי שלום הצטרף לבית שלכם', created_at: daysAgo(60).toISOString(), read: true, data: {} },
    { id: 'n_avi_8', type: 'list_shared', title: 'רשימה חדשה', body: 'רונית שיתפה את "מאפייה לשבת"', created_at: daysAgo(1).toISOString(), read: true, data: {} },
    { id: 'n_avi_9', type: 'shopping_completed', title: 'קנייה הסתיימה', body: 'רונית סיימה את הקנייה ב"יוחננוף"', created_at: daysAgo(10).toISOString(), read: true, data: {} },
    { id: 'n_avi_10', type: 'reminder', title: 'תזכורת', body: 'יש 3 בקשות ממתינות לאישור!', created_at: hoursAgo(6).toISOString(), read: true, data: {} },
  ]);
  console.log('   🔔 אבי: 10 (4 unread)');

  // רונית — 6 notifications
  await createNotifications(uids.ronit, [
    { id: 'n_ronit_1', type: 'item_added', title: 'בקשה חדשה', body: 'יובל מבקש להוסיף "ביסלי" לרשימה', created_at: hoursAgo(1.5).toISOString(), read: false, data: {} },
    { id: 'n_ronit_2', type: 'item_added', title: 'בקשה חדשה', body: 'נועה מבקשת להוסיף "עוגת שוקולד" למאפייה', created_at: hoursAgo(1).toISOString(), read: false, data: {} },
    { id: 'n_ronit_3', type: 'low_stock', title: 'מלאי נמוך', body: '3 פריטים במלאי נמוך', created_at: daysAgo(1).toISOString(), read: true, data: {} },
    { id: 'n_ronit_4', type: 'shopping_completed', title: 'קנייה הסתיימה', body: 'אבי סיים את הקנייה השבועית', created_at: daysAgo(6).toISOString(), read: true, data: {} },
    { id: 'n_ronit_5', type: 'member_joined', title: 'חבר חדש', body: 'אורי שלום הצטרף לבית', created_at: daysAgo(60).toISOString(), read: true, data: {} },
    { id: 'n_ronit_6', type: 'reminder', title: 'תזכורת', body: 'מחר יום שישי — לא לשכוח את רשימת הקצביה!', created_at: daysAgo(2).toISOString(), read: true, data: {} },
  ]);
  console.log('   🔔 רונית: 6 (2 unread)');

  // נעמה — 15 notifications (power user)
  const naamaNotifs = [];
  const nTypes = ['shopping_completed','item_added','low_stock','reminder','list_shared'];
  for (let i = 0; i < 15; i++) {
    naamaNotifs.push({
      id: `n_naama_${i}`, type: nTypes[i % nTypes.length],
      title: ['קנייה הסתיימה','פריט חדש','מלאי נמוך','תזכורת','רשימה חדשה'][i % 5],
      body: ['סיימת קנייה ב"רמי לוי"','נוסף פריט לרשימה','5 פריטים במלאי נמוך','שבוע חדש — הגיע הזמן לקניות','רשימה חדשה נוצרה'][i % 5],
      created_at: daysAgo(i * 3).toISOString(), read: i > 5, data: {},
    });
  }
  await createNotifications(uids.naama, naamaNotifs);
  console.log('   🔔 נעמה: 15 (6 unread)');

  // ליאור — 1 old notification
  await createNotifications(uids.lior, [
    { id: 'n_lior_1', type: 'reminder', title: 'חזרת?', body: 'לא השתמשת באפליקציה כבר חודשיים', created_at: daysAgo(45).toISOString(), read: false, data: {} },
  ]);
  console.log('   🔔 ליאור: 1 (unread)');

  // תומר — 3 notifications
  await createNotifications(uids.tomer, [
    { id: 'n_tomer_1', type: 'invite_received', title: 'הזמנה!', body: 'נעמה רוזן הזמינה אותך לרשימת BBQ', created_at: daysAgo(1).toISOString(), read: false, data: {} },
    { id: 'n_tomer_2', type: 'low_stock', title: 'מלאי נמוך', body: 'קפה ושימורים — עומדים להיגמר', created_at: daysAgo(3).toISOString(), read: true, data: {} },
    { id: 'n_tomer_3', type: 'reminder', title: 'תזכורת', body: 'יש לך רשימת בית מרקחת פתוחה', created_at: daysAgo(1).toISOString(), read: true, data: {} },
  ]);
  console.log('   🔔 תומר: 3 (1 unread)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 8. PENDING INVITES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📩 Pending invites...');

  // נעמה → אבי: join household
  await db.collection('pending_invites').doc('invite_avi_from_naama').set({
    id: 'invite_avi_from_naama', type: 'inviteToHousehold',
    requester_id: uids.naama, requester_name: 'נעמה רוזן', requester_email: 'naama.rozen@demo.com',
    target_user_id: uids.avi, target_email: 'avi.cohen@demo.com',
    status: 'pending', created_at: hoursAgo(3).toISOString(),
    request_data: { household_id: hNaama, household_name: 'הבית של נעמה' },
  });
  console.log('   📩 נעמה → אבי (household invite)');

  // נעמה → תומר: join BBQ list
  await db.collection('pending_invites').doc('invite_tomer_bbq').set({
    id: 'invite_tomer_bbq', type: 'joinRequest',
    requester_id: uids.naama, requester_name: 'נעמה רוזן', requester_email: 'naama.rozen@demo.com',
    target_user_id: uids.tomer, target_email: 'tomer.bar@demo.com',
    status: 'pending', created_at: daysAgo(1).toISOString(),
    request_data: { list_name: 'על האש 🔥 שישי' },
  });
  console.log('   📩 נעמה → תומר (list invite)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n' + '═'.repeat(60));
  console.log('✅ DEMO DATA REBUILT SUCCESSFULLY!');
  console.log('═'.repeat(60));
  console.log(`
👥 12 Users:
   Cohen Family: אבי (owner/admin), רונית (admin), יובל (editor), נועה (editor), אורי (viewer)
   Levi Couple: דן (admin), מאיה (admin)
   Solo: תומר (private lists), שירן (casual), ליאור (inactive)
   Power: נעמה (35 pantry, 50-item list, 25 receipts)
   Fresh: יעל (0 everything — empty states)

🏠 7 Households

📋 ~25 Shopping Lists:
   • 7 active lists in Cohen (supermarket, greengrocer, bakery, butcher, mixed, household, + 1 completed, 1 completed event)
   • 2 lists in Levi (1 active, 1 completed)
   • 2 lists for Tomer (pharmacy private + AM:PM)
   • 10+ lists for Naama (big 50-item, market, BBQ, budget, 6 completed history)
   • 0 for Yael (fresh) / 0 for Lior (inactive)

📦 Inventory: 25+15+10+35+8+2 = 95 items (household-level, correct path!)

🧾 65 Receipts (20 Cohen + 12 Levi + 8 Tomer + 25 Naama)

🔔 35 Notifications (distributed across users)

📩 2 Pending Invites

🎭 Role-based scenarios:
   ✅ Owner (רונית) — creates lists, approves/rejects requests
   ✅ Admin (אבי) — household admin, approves requests too
   ✅ Editor (יובל/נועה) — adds via pending_requests, needs approval
   ✅ Viewer (אורי) — read-only, can see but not edit
   ✅ Active Shopping — רונית actively shopping greengrocer (4/10 checked)
   ✅ Private list — תומר's pharmacy list
   ✅ Mixed list — products + tasks
   ✅ Budget tracking — נעמה's 300₪ list with prices
   ✅ All 7 list types: supermarket, pharmacy, greengrocer, butcher, bakery, market, household, event
   ✅ Low/empty stock — multiple households
   ✅ Fresh user — יעל, 0 everything

🔑 Password: ${DEMO_PASSWORD}
`);
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
