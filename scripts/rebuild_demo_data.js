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
  { key: 'yael',   name: 'יעל מזרחי',    email: 'yael.fresh@demo.com',   phone: '0513456789', household: 'yael',   role: 'admin',  isAdmin: true },
  // Google Sign-In user (no phone, has profile image)
  { key: 'google_user', name: 'גיל גוגל', email: 'gil.google@demo.com', phone: '', household: 'google_user', role: 'admin', isAdmin: true, provider: 'google', profileImageUrl: 'https://lh3.googleusercontent.com/a/default-user' },
  // Apple Sign-In user (Apple hides real name — display name is email until user updates profile)
  { key: 'apple_user', name: 'apple_user@icloud.com', email: 'apple_user@icloud.com', phone: '', household: 'apple_user', role: 'admin', isAdmin: true, provider: 'apple', applePrivateRelay: true },
  // English-speaking user (English name, English locale preference)
  { key: 'mike', name: 'Mike Johnson', email: 'mike.johnson@demo.com', phone: '+972541234567', household: 'mike', role: 'admin', isAdmin: true, locale: 'en' },
  // Special characters in name (Hebrew with geresh/gershayim)
  { key: 'george', name: "ג'ורג' חביב", email: 'george.haviv@demo.com', phone: '0521234567', household: 'george', role: 'admin', isAdmin: true },
  // ── Roommates (3 girls sharing apartment — not family) ──
  { key: 'keren', name: 'קרן אביב',  email: 'keren.aviv@demo.com',  phone: '0531234567', household: 'roommates', role: 'admin',  isAdmin: true },
  { key: 'hila',  name: 'הילה מורג',  email: 'hila.morag@demo.com',  phone: '0532345678', household: 'roommates', role: 'admin',  isAdmin: true },
  { key: 'sapir', name: 'ספיר דוד',   email: 'sapir.david@demo.com', phone: '0533456789', household: 'roommates', role: 'member', isAdmin: false },
  // Elderly user — minimal data, simple usage
  { key: 'shlomo', name: 'שלמה ברקוביץ', email: 'shlomo.berk@demo.com', phone: '0541234567', household: 'shlomo', role: 'admin', isAdmin: true },
  // Removed user — was in Cohen household, got removed, now has personal household
  { key: 'removed_user', name: 'אילן פרץ', email: 'ilan.peretz@demo.com', phone: '0551234567', household: 'removed_user', role: 'admin', isAdmin: true },
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
  mike:        { name: "Mike's Home",    members: ['mike'] },
  george:      { name: "הבית של ג'ורג'", members: ['george'] },
  roommates:   { name: 'הדירה ברוטשילד',  members: ['keren', 'hila', 'sapir'] },
  shlomo:      { name: 'הבית של שלמה',    members: ['shlomo'] },
  removed_user: { name: 'הבית של אילן',   members: ['removed_user'] },
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
    image_url: null,
    checked_by: opts.checkedBy || null,
    checked_at: opts.checkedAt || null,
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
    image_url: null,
    checked_by: opts.checkedBy || null,
    checked_at: opts.checkedAt || null,
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
    image_url: null,
    checked_by: null,
    checked_at: null,
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 0. CLEANUP — delete pending_invites and custom_locations (top-level)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('🧹 Cleaning up old top-level data...');
  const pendingSnap = await db.collection('pending_invites').get();
  const customLocSnap = await db.collection('custom_locations').get();
  const batch0 = db.batch();
  for (const doc of pendingSnap.docs) batch0.delete(doc.ref);
  for (const doc of customLocSnap.docs) batch0.delete(doc.ref);
  await batch0.commit();
  console.log(`   🧹 Deleted ${pendingSnap.size} pending_invites + ${customLocSnap.size} custom_locations`);

  const uids = {}; // key → firebase UID

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. AUTH USERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👥 Creating Auth users...');
  for (const u of USERS) {
    try {
      const createParams = {
        email: u.email,
        password: DEMO_PASSWORD,
        displayName: u.name,
        ...(u.profileImageUrl ? { photoURL: u.profileImageUrl } : {}),
      };
      const record = await auth.createUser(createParams);
      uids[u.key] = record.uid;
      console.log(`   ✅ ${u.name} (${record.uid})${u.provider ? ` [${u.provider}]` : ''}`);
    } catch (e) {
      if (e.code === 'auth/email-already-exists') {
        const existing = await auth.getUserByEmail(u.email);
        uids[u.key] = existing.uid;
        // Update photoURL if it exists (in case user was created before)
        if (u.profileImageUrl) {
          await auth.updateUser(existing.uid, { photoURL: u.profileImageUrl, displayName: u.name });
        }
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
        user_id: uids[memberKey],
        name: memberUser.name,
        email: memberUser.email,
        role: memberUser.role,
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
      ...(u.locale ? { app_locale: u.locale } : {}),
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
      // editItem request (pending) — tests pending_requests_section fix
      // request_data matches what PendingRequestsService.createEditItemRequest produces (flat, not nested)
      { id: 'req_yuval_edit', list_id: 'list_cohen_weekly', requester_id: uids.yuval, type: 'editItem', status: 'pending',
        created_at: hoursAgo(1).toISOString(),
        request_data: { name: 'חלב תנובה 3%', quantity: 5, unitPrice: 6.9, unit: 'ליטר', category: 'מוצרי חלב', barcode: null, notes: null },
        reviewer_id: null, reviewed_at: null, requester_name: 'יובל כהן', reviewer_name: null },
      // deleteItem request (pending) — tests pending_requests_section fix
      { id: 'req_noa_delete', list_id: 'list_cohen_weekly', requester_id: uids.noa, type: 'deleteItem', status: 'pending',
        created_at: hoursAgo(0.5).toISOString(),
        request_data: { name: 'סוכר לבן 1 ק"ג', item_id: 'item_cw_3' },
        reviewer_id: null, reviewed_at: null, requester_name: 'נועה כהן', reviewer_name: null },
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

  // ── SHIRAN: Empty list (0 items — tests empty state) ──
  await db.collection('users').doc(uids.shiran).collection('private_lists').doc('list_shiran_empty').set({
    id: 'list_shiran_empty', name: 'רשימה חדשה', status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: true, created_by: uids.shiran,
    format: 'personal', created_from_template: false,
    created_date: hoursAgo(1).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [],
  });
  console.log('   📋 שירן: רשימה חדשה (EMPTY — 0 items, tests empty state)');

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
        expiry_date: p.category === 'מוצרי חלב'
          ? (i === 0 ? daysAgo(2).toISOString()     // expired 2 days ago!
            : i === 1 ? daysFromNow(1).toISOString() // expires tomorrow
            : daysFromNow(14).toISOString())          // expires in 2 weeks
          : null,
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

  // Mike: 8 items (English product names test in pantry)
  const mikePantry = pickRandom(byCategory(products, 'מוצרי חלב', 'אורז ופסטה', 'משקאות'), 5);
  await createInventory(hIds.mike, mikePantry, uids.mike);
  // Add English-named items manually to inventory
  for (const [i, item] of [
    { name: 'Organic Almond Milk', category: 'מוצרי חלב', unit: 'ליטר' },
    { name: 'Quinoa (Red)', category: 'אורז ופסטה', unit: "יח'" },
    { name: 'Extra Virgin Olive Oil 750ml', category: 'שמנים ורטבים', unit: "יח'" },
  ].entries()) {
    await db.collection('households').doc(hIds.mike).collection('inventory').doc(`inv_mike_en_${i}`).set({
      id: `inv_mike_en_${i}`,
      product_name: item.name,
      category: item.category,
      location: locationForCategory(item.category),
      quantity: randomInt(1, 4),
      unit: item.unit,
      min_quantity: 2,
      expiry_date: null,
      notes: null,
      is_recurring: false,
      emoji: null,
      last_updated_by: uids.mike,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
      last_purchased: daysAgo(randomInt(1, 7)).toISOString(),
      purchase_count: randomInt(1, 10),
    });
  }
  console.log('   📦 Mike: 8 items (5 Hebrew catalog + 3 English custom)');

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

  await createReceipts(hIds.mike, [uids.mike], 5, ['Rami Levy Shoresh', 'Shufersal Deal']);
  console.log('   🧾 Mike: 5 receipts (English store names)');

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
    makeNotification('notif_avi_3', uids.avi, hIds.cohen, 'request_rejected', 'בקשה נדחתה', 'הבקשה של נועה להוסיף "שוקולד פרה" נדחתה', { createdAt: daysAgo(3), isRead: true, readAt: daysAgo(3), senderId: uids.ronit, senderName: 'רונית כהן', actionData: { listId: 'list_cohen_weekly' } }),
    makeNotification('notif_avi_4', uids.avi, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'יובל כהן התנדב להביא "סלט ירקות"', { createdAt: hoursAgo(5), senderId: uids.yuval, senderName: 'יובל כהן', actionData: { listId: 'list_cohen_shabbat', volunteerName: 'יובל כהן' } }),
    makeNotification('notif_avi_5', uids.avi, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'נועה כהן התנדבה להביא "קינוח"', { createdAt: hoursAgo(3), senderId: uids.noa, senderName: 'נועה כהן', actionData: { listId: 'list_cohen_shabbat', volunteerName: 'נועה כהן' } }),
    makeNotification('notif_avi_6', uids.avi, hIds.cohen, 'low_stock', 'מלאי נמוך', 'המלאי של "חלב תנובה 3%" נגמר', { createdAt: hoursAgo(8), actionData: { productName: 'חלב תנובה 3%' } }),
    makeNotification('notif_avi_7', uids.avi, hIds.cohen, 'low_stock', 'מלאי נמוך', 'נשארה יחידה אחרונה של "ביצים L', { createdAt: hoursAgo(6), actionData: { productName: 'ביצים L' } }),
    makeNotification('notif_avi_8', uids.avi, hIds.cohen, 'role_changed', 'שינוי תפקיד', 'אורי שלום קיבל תפקיד צפייה ברשימת "קניות שבועיות"', { createdAt: daysAgo(60), isRead: true, readAt: daysAgo(60), actionData: { listId: 'list_cohen_weekly', newRole: 'viewer' } }),
    makeNotification('notif_avi_9', uids.avi, hIds.cohen, 'member_left', 'חבר עזב', 'אורי שלום עזב את הבית (וחזר מאוחר יותר כצופה)', { createdAt: daysAgo(90), isRead: true, readAt: daysAgo(89), senderId: uids.ori, senderName: 'אורי שלום', actionData: {} }),
    makeNotification('notif_avi_10', uids.avi, hIds.cohen, 'invite', 'הזמנה לבית', 'נעמה רוזן הזמינה אותך להצטרף לבית שלה', { createdAt: hoursAgo(3), senderId: uids.naama, senderName: 'נעמה רוזן', actionData: { householdId: hIds.naama } }),
    // Edge case: user_removed notification
    makeNotification('notif_avi_11', uids.avi, hIds.cohen, 'user_removed', 'הוסרת מרשימה', 'הוסרת מרשימת "קניות ישנה"', { createdAt: daysAgo(90), isRead: true, readAt: daysAgo(89), actionData: { listId: 'old_list_123' } }),
    // Edge case: unknown notification type — app should not crash
    makeNotification('notif_avi_12', uids.avi, hIds.cohen, 'future_feature_xyz', 'עדכון מערכת', 'סוג התראה ממאפיין עתידי שטרם קיים באפליקציה', { createdAt: hoursAgo(1), actionData: {} }),
  ]);
  console.log('   🔔 אבי: 12 notifications (6 unread, includes unknown type edge case)');

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

  // Yuval notifications (editor — sees his request outcomes)
  await createNotifications(uids.yuval, [
    makeNotification('notif_yuval_1', uids.yuval, hIds.cohen, 'request_approved', 'בקשה אושרה', 'הבקשה שלך להוסיף "קולה זירו" אושרה ע"י רונית', { createdAt: daysAgo(3), isRead: true, readAt: daysAgo(3), senderId: uids.ronit, senderName: 'רונית כהן', actionData: { listId: 'list_cohen_weekly' } }),
    makeNotification('notif_yuval_2', uids.yuval, hIds.cohen, 'who_brings_volunteer', 'מתנדב חדש', 'נועה כהן התנדבה להביא "קינוח"', { createdAt: hoursAgo(3), senderId: uids.noa, senderName: 'נועה כהן', actionData: { listId: 'list_cohen_shabbat' } }),
  ]);
  console.log('   🔔 יובל: 2 notifications (1 unread)');

  // Noa notifications (editor — sees rejection)
  await createNotifications(uids.noa, [
    makeNotification('notif_noa_1', uids.noa, hIds.cohen, 'request_rejected', 'בקשה נדחתה', 'הבקשה שלך להוסיף "שוקולד פרה" נדחתה ע"י אבי', { createdAt: daysAgo(2), senderId: uids.avi, senderName: 'אבי כהן', actionData: { listId: 'list_cohen_weekly' } }),
    makeNotification('notif_noa_2', uids.noa, hIds.cohen, 'request_approved', 'בקשה אושרה', 'הבקשה שלך להוסיף "נייר טואלט" אושרה', { createdAt: hoursAgo(1), senderId: uids.ronit, senderName: 'רונית כהן', actionData: { listId: 'list_cohen_weekly' } }),
  ]);
  console.log('   🔔 נועה: 2 notifications (1 unread)');

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
  // 9. SAVED CONTACTS — users/{uid}/saved_contacts
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n👤 Creating saved contacts...');

  // Ronit saved her family
  for (const [i, contact] of [
    { userId: uids.yuval, name: 'יובל כהן', email: 'yuval.cohen@demo.com', phone: '0503456789' },
    { userId: uids.noa, name: 'נועה כהן', email: 'noa.cohen@demo.com', phone: '0504567890' },
    { userId: uids.ori, name: 'אורי שלום', email: 'ori.shalom@demo.com', phone: '0509012345' },
  ].entries()) {
    await db.collection('users').doc(uids.ronit).collection('saved_contacts').doc(`contact_ronit_${i}`).set({
      id: `contact_ronit_${i}`,
      user_id: contact.userId,
      user_name: contact.name,
      user_email: contact.email,
      user_phone: contact.phone,
      user_avatar: null,
      last_invited_at: daysAgo(30).toISOString(),
      created_at: daysAgo(180).toISOString(),
    });
  }
  console.log('   👤 רונית: 3 saved contacts');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 10. CUSTOM LOCATIONS — custom_locations collection
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n📍 Creating custom locations...');

  await db.collection('custom_locations').doc('loc_cohen_wine').set({
    id: 'loc_cohen_wine',
    key: 'wine_fridge',
    name: 'מקרר יין',
    emoji: '🍷',
    household_id: hIds.cohen,
    created_by: uids.avi,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection('custom_locations').doc('loc_cohen_garage').set({
    id: 'loc_cohen_garage',
    key: 'garage_storage',
    name: 'מחסן בגראז\'',
    emoji: '🚗',
    household_id: hIds.cohen,
    created_by: uids.ronit,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log('   📍 כהן: 2 custom locations (מקרר יין, מחסן בגראז\')');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 11. LISTS WITH TARGET DATE — urgency testing
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n⏰ Adding target dates to lists...');

  // Update existing lists with target_date for urgency tags
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_weekly').update({
    target_date: daysFromNow(1).toISOString(), // מחר — urgency "מחר"
  });
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_butcher').update({
    target_date: daysFromNow(0).toISOString(), // היום — urgency "היום!"
  });
  await db.collection('households').doc(hIds.levi).collection('shared_lists').doc('list_levi_market').update({
    target_date: daysFromNow(5).toISOString(), // 5 ימים — urgency "עוד 5 ימים"
  });
  console.log('   ⏰ Cohen weekly: target=tomorrow, butcher: target=today, Levi market: target=5 days');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 12. GOOGLE/APPLE USER DATA — basic list + pantry
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🔵 Creating Google/Apple user data...');

  // Google user — one basic list
  const googleProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 5);
  await db.collection('users').doc(uids.google_user).collection('private_lists').doc('list_google_basic').set({
    id: 'list_google_basic', name: 'רשימה ראשונה', status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: true, created_by: uids.google_user,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: googleProducts.map((p, i) => makeProductItem(p, i, { id: `item_gu_${i}` })),
  });
  console.log('   🔵 Google user: 1 basic list (5 items)');

  // Apple user — empty (just registered, tests empty states)
  console.log('   🍎 Apple user: 0 lists (empty states test)');

  // ── MIKE: English-speaking user — English list names + items ──
  const mikeProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 6);
  await db.collection('users').doc(uids.mike).collection('private_lists').doc('list_mike_weekly').set({
    id: 'list_mike_weekly', name: 'Weekly Groceries 🛒', status: 'active', type: 'supermarket',
    budget: 500, is_shared: false, is_private: true, created_by: uids.mike,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    target_date: daysFromNow(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      ...mikeProducts.map((p, i) => makeProductItem(p, i, { id: `item_mike_${i}`, isChecked: i < 2 })),
      // English-named custom items (user typed in English)
      makeProductItem({ name: 'Organic Milk 1L', category: 'מוצרי חלב', price: 12.9, defaultUnit: 'ליטר' }, 10, { id: 'item_mike_custom1' }),
      makeProductItem({ name: 'Peanut Butter (crunchy)', category: 'ממתקים וחטיפים', price: 24.9 }, 11, { id: 'item_mike_custom2' }),
      makeTaskItem('item_mike_task1', 'Pick up dry cleaning', { priority: 'high' }),
    ],
  });
  console.log('   🌍 Mike: Weekly Groceries (English name, mixed Hebrew/English items)');

  // Mike's English pharmacy list
  await db.collection('users').doc(uids.mike).collection('private_lists').doc('list_mike_pharm').set({
    id: 'list_mike_pharm', name: 'Pharmacy & Personal Care', status: 'active', type: 'pharmacy',
    budget: null, is_shared: false, is_private: true, created_by: uids.mike,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(3).toISOString(), updated_date: daysAgo(1).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      makeProductItem({ name: 'Sunscreen SPF 50', category: 'היגיינה ויופי', price: 49.9 }, 0, { id: 'item_mike_ph1' }),
      makeProductItem({ name: 'Vitamin D3 1000IU', category: 'היגיינה ויופי', price: 35 }, 1, { id: 'item_mike_ph2' }),
      makeTaskItem('item_mike_ph3', 'Ask about allergy medicine', { priority: 'medium' }),
    ],
  });
  console.log('   🌍 Mike: Pharmacy (English, 3 items)');

  // ── GEORGE: Special characters in names (geresh/gershayim) ──
  const georgeProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 4);
  await db.collection('users').doc(uids.george).collection('private_lists').doc('list_george_1').set({
    id: 'list_george_1', name: "קניות של ג'ורג'", status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: true, created_by: uids.george,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(2).toISOString(), updated_date: hoursAgo(4).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      ...georgeProducts.map((p, i) => makeProductItem(p, i, { id: `item_geo_${i}` })),
      // Item with very long name (overflow test)
      makeProductItem({ name: 'שמנת מתוקה תנובה 38% שומן למטבח - מארז חיסכון משפחתי 3 יחידות במחיר מיוחד', category: 'מוצרי חלב', price: 15.9 }, 10, { id: 'item_geo_long' }),
      // Item with price 0 (free/unknown price)
      makeProductItem({ name: 'דוגמיות חינם מהפארם', category: 'היגיינה ויופי', price: 0 }, 11, { id: 'item_geo_free' }),
    ],
  });
  console.log("   🔤 George: קניות של ג'ורג' (special chars + long item name + free item)");

  // ── ROOMMATES: 3 girls sharing apartment — different last names, shared household ──
  const roommatesClean = pickRandom(byCategory(products, 'מוצרי ניקיון', 'מוצרי בית').filter(p => p.sourceFile === 'supermarket'), 8);
  await db.collection('households').doc(hIds.roommates).collection('shared_lists').doc('list_room_clean').set({
    id: 'list_room_clean', name: 'ניקיון שבועי לדירה 🧹', status: 'active', type: 'household',
    budget: 200, is_shared: true, is_private: false, created_by: uids.keren,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [uids.hila, uids.sapir],
    shared_users: {
      [uids.hila]:  { role: 'editor', shared_at: daysAgo(30).toISOString(), user_name: 'הילה מורג', user_email: 'hila.morag@demo.com', can_start_shopping: true },
      [uids.sapir]: { role: 'editor', shared_at: daysAgo(30).toISOString(), user_name: 'ספיר דוד', user_email: 'sapir.david@demo.com', can_start_shopping: true },
    },
    pending_requests: [], active_shoppers: [],
    items: [
      ...roommatesClean.map((p, i) => makeProductItem(p, i, { id: `item_rc_${i}`, isChecked: i < 3 })),
      makeTaskItem('item_rc_t0', 'לנקות מקלחת (תור של ספיר)', { priority: 'high' }),
      makeTaskItem('item_rc_t1', 'לקנות נורה למסדרון', { priority: 'medium' }),
    ],
  });
  console.log('   🏠 Roommates: ניקיון שבועי (household, 8 products + 2 tasks, 3 members)');

  const roommatesGrocery = pickRandom(byCategory(products, 'מוצרי חלב', 'לחם ומאפים', 'פירות וירקות', 'משקאות').filter(p => p.sourceFile === 'supermarket'), 12);
  await db.collection('households').doc(hIds.roommates).collection('shared_lists').doc('list_room_grocery').set({
    id: 'list_room_grocery', name: 'סופר לשבוע 🛒', status: 'active', type: 'supermarket',
    budget: 400, is_shared: true, is_private: false, created_by: uids.hila,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(6).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.keren, uids.sapir],
    shared_users: {
      [uids.keren]: { role: 'admin', shared_at: daysAgo(30).toISOString(), user_name: 'קרן אביב', user_email: 'keren.aviv@demo.com', can_start_shopping: true },
      [uids.sapir]: { role: 'editor', shared_at: daysAgo(30).toISOString(), user_name: 'ספיר דוד', user_email: 'sapir.david@demo.com', can_start_shopping: false },
    },
    pending_requests: [
      { id: 'req_sapir_1', list_id: 'list_room_grocery', requester_id: uids.sapir, type: 'addItem', status: 'pending',
        created_at: hoursAgo(1).toISOString(),
        request_data: { name: 'חומוס אבו גוש 400 גרם', quantity: 2, unit: "יח'", category: 'שימורים', type: 'product' },
        reviewer_id: null, reviewed_at: null, requester_name: 'ספיר דוד', reviewer_name: null },
    ],
    active_shoppers: [], items: roommatesGrocery.map((p, i) => makeProductItem(p, i, { id: `item_rg_${i}`, isChecked: i < 4 })),
  });
  console.log('   🛒 Roommates: סופר לשבוע (supermarket, 12 items, 1 pending request from sapir)');

  // Roommates inventory (shared pantry)
  const roommatesPantry = pickRandom(byCategory(products, 'מוצרי ניקיון', 'משקאות', 'מוצרי חלב', 'אורז ופסטה'), 10);
  await createInventory(hIds.roommates, roommatesPantry, uids.keren, { forceQty: (i) => i < 2 ? 0 : randomInt(1, 4) });
  console.log('   📦 Roommates: 10 pantry items (2 out-of-stock)');

  // Roommates receipts
  await createReceipts(hIds.roommates, [uids.keren, uids.hila, uids.sapir], 6, ['שופרסל דיזנגוף', 'AM:PM רוטשילד']);
  console.log('   🧾 Roommates: 6 receipts');

  // Roommates notifications
  await createNotifications(uids.keren, [
    makeNotification('notif_keren_1', uids.keren, hIds.roommates, 'low_stock', 'מלאי נמוך', 'נגמר נייר טואלט בדירה', { createdAt: hoursAgo(5), actionData: { productName: 'נייר טואלט' } }),
    makeNotification('notif_keren_2', uids.keren, hIds.roommates, 'invite', 'בקשה חדשה', 'ספיר ביקשה להוסיף "חומוס" לרשימת הסופר', { createdAt: hoursAgo(1), senderId: uids.sapir, senderName: 'ספיר דוד', actionData: { listId: 'list_room_grocery', requestId: 'req_sapir_1' } }),
  ]);
  console.log('   🔔 קרן: 2 notifications');

  // ── SHLOMO: Elderly user — simple, minimal data ──
  const shlomoProducts = pickRandom(byCategory(products, 'מוצרי חלב', 'לחם ומאפים', 'פירות וירקות').filter(p => p.sourceFile === 'supermarket'), 5);
  await db.collection('users').doc(uids.shlomo).collection('private_lists').doc('list_shlomo_1').set({
    id: 'list_shlomo_1', name: 'קניות', status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: true, created_by: uids.shlomo,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(3).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: shlomoProducts.map((p, i) => makeProductItem(p, i, { id: `item_shl_${i}` })),
  });
  console.log('   👴 שלמה: רשימה אחת פשוטה (5 items, no sharing, no budget)');

  // Shlomo pantry — just basics
  const shlomoPantry = pickRandom(byCategory(products, 'מוצרי חלב', 'לחם ומאפים'), 4);
  await createInventory(hIds.shlomo, shlomoPantry, uids.shlomo);
  console.log('   📦 שלמה: 4 pantry items');

  // ── REMOVED USER: Was in Cohen, got removed, now has personal household ──
  // Private list from before removal (still works in personal household)
  await db.collection('users').doc(uids.removed_user).collection('private_lists').doc('list_ilan_1').set({
    id: 'list_ilan_1', name: 'הרשימה שלי', status: 'active', type: 'supermarket',
    budget: null, is_shared: false, is_private: true, created_by: uids.removed_user,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(20).toISOString(), updated_date: daysAgo(3).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 4)
      .map((p, i) => makeProductItem(p, i, { id: `item_ilan_${i}` })),
  });
  console.log('   🚪 אילן (removed): רשימה אישית אחרי הסרה מכהן (4 items)');

  // Ilan notification about being removed
  await createNotifications(uids.removed_user, [
    makeNotification('notif_ilan_1', uids.removed_user, hIds.removed_user, 'user_removed', 'הוסרת מהבית', 'הוסרת ממשפחת כהן ע"י אבי כהן', { createdAt: daysAgo(10), isRead: true, readAt: daysAgo(10), senderId: uids.avi, senderName: 'אבי כהן', actionData: { householdId: hIds.cohen } }),
  ]);
  console.log('   🔔 אילן: 1 notification (user_removed)');

  // ── PRE-SIGNUP INVITE: Invite to email that has no account yet ──
  await db.collection('pending_invites').doc('invite_ronit_friend').set({
    id: 'invite_ronit_friend',
    list_id: hIds.cohen,
    requester_id: uids.ronit,
    type: 'inviteToHousehold',
    status: 'pending',
    created_at: daysAgo(2).toISOString(),
    requester_name: 'רונית כהן',
    reviewer_id: null, reviewed_at: null, rejection_reason: null, reviewer_name: null, list_name: null,
    request_data: {
      invited_user_id: null, // no account yet!
      invited_user_email: 'michal.new@gmail.com',
      invited_user_name: null,
      household_id: hIds.cohen,
      household_name: 'משפחת כהן',
      role: 'editor',
    },
  });
  console.log('   ✉️ רונית → michal.new@gmail.com: הזמנה למשתמשת שטרם נרשמה (pre-signup)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 14. EDGE CASE PATCHES — fix missing scenarios found in audit
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n🔬 Applying edge case patches...');

  // PATCH 1: Add overdue target_date to an existing list (urgency "עבר!")
  await db.collection('households').doc(hIds.levi).collection('shared_lists').doc('list_levi_weekly').update({
    target_date: daysAgo(2).toISOString(), // 2 days overdue!
  });
  console.log('   ⏰ Levi weekly: target_date set to 2 days AGO (tests urgency "עבר!")');

  // PATCH 2: Who Brings item that is FULL (neededCount == volunteers)
  await db.collection('households').doc(hIds.cohen).collection('shared_lists').doc('list_cohen_shabbat').update({
    'items.3': makeWhoBringsItem('wb_4', 'לחם', 2, [
      { userId: uids.avi, displayName: 'אבי כהן', volunteeredAt: hoursAgo(4).toISOString() },
      { userId: uids.ronit, displayName: 'רונית כהן', volunteeredAt: hoursAgo(3).toISOString() },
    ]),
  });
  console.log('   ✅ Shabbat wb_4 "לחם": now FULL (2/2 volunteers)');

  // PATCH 3: Inventory items with notes
  await db.collection('households').doc(hIds.cohen).collection('inventory').doc('inv_household_cohen_0').update({
    notes: 'לקנות רק תנובה, לא של שטראוס',
  });
  await db.collection('households').doc(hIds.cohen).collection('inventory').doc('inv_household_cohen_1').update({
    notes: 'לבדוק תאריך תפוגה לפני שקונים',
  });
  console.log('   📝 Cohen inventory: 2 items now have notes');

  // PATCH 4: Shiran gets a list with ALL items checked (100% active)
  const allCheckedProducts = pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 5);
  await db.collection('users').doc(uids.shiran).collection('private_lists').doc('list_shiran_done').set({
    id: 'list_shiran_done', name: 'הכל נקנה! ✅', status: 'active', type: 'supermarket',
    budget: 200, is_shared: false, is_private: true, created_by: uids.shiran,
    format: 'personal', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(0.5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: allCheckedProducts.map((p, i) => makeProductItem(p, i, {
      id: `item_sh_done_${i}`, isChecked: true,
      checked_by: uids.shiran, checked_at: hoursAgo(1).toISOString(),
    })),
  });
  console.log('   ✅ Shiran: "הכל נקנה!" (active, 100% checked — tests green progress bar)');

  // PATCH 5: Product with very large quantity
  await db.collection('users').doc(uids.naama).collection('private_lists').doc('list_naama_budget').update({
    'items.0': makeProductItem(
      { name: 'מים מינרליים 1.5 ליטר', category: 'משקאות', price: 3.5, defaultUnit: 'ליטר' },
      0, { id: 'item_bgt_0', quantity: 24, isChecked: false }
    ),
  });
  console.log('   🔢 Naama budget list: item 0 quantity = 24 (large quantity display test)');

  // PATCH 6: Active checklist (event_mode: 'tasks') — Tomer's chores
  await db.collection('users').doc(uids.tomer).collection('private_lists').doc('list_tomer_chores').set({
    id: 'list_tomer_chores', name: 'משימות לסוף שבוע', status: 'active', type: 'event',
    budget: 0, is_shared: false, is_private: true, created_by: uids.tomer,
    format: 'personal', created_from_template: false, event_mode: 'tasks',
    event_date: daysFromNow(2).toISOString(),
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(2).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      makeTaskItem('item_chore_0', 'לנקות את הדירה 🧹', { priority: 'high' }),
      makeTaskItem('item_chore_1', 'כביסה + גיהוץ', { isChecked: true, priority: 'medium' }),
      makeTaskItem('item_chore_2', 'לארגן את הארון', { priority: 'low', notes: 'לתרום בגדים ישנים' }),
      makeTaskItem('item_chore_3', 'לתקן את הברז במטבח 🔧', { priority: 'high' }),
      // Item with emoji in name
      makeProductItem({ name: '🧴 סבון כלים אקולוגי', category: 'מוצרי ניקיון', price: 18.9 }, 4, { id: 'item_chore_4' }),
    ],
  });
  console.log('   ✅ Tomer: Active checklist (event/tasks, budget: 0, emoji in item name)');

  // PATCH 7: Template-based list — Dan created from template
  await db.collection('households').doc(hIds.levi).collection('shared_lists').doc('list_levi_template').set({
    id: 'list_levi_template', name: 'קניות שבועיות (תבנית)', status: 'active', type: 'supermarket',
    budget: null, is_shared: true, is_private: false, created_by: uids.dan,
    format: 'shared', created_from_template: true, template_id: 'tmpl_shopping_weekly',
    created_date: hoursAgo(6).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.maya], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: pickRandom(products.filter(p => p.sourceFile === 'supermarket'), 8)
      .map((p, i) => makeProductItem(p, i, { id: `item_lt_${i}`, isChecked: i < 3 })),
  });
  console.log('   📋 Levi: Template-based list (created_from_template: true)');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('\n' + '═'.repeat(55));
  console.log('✅ Demo data created successfully!');
  console.log('═'.repeat(55));
  console.log(`\n👥 ${USERS.length} users`);
  console.log(`🏠 ${Object.keys(HOUSEHOLDS).length} households`);
  console.log(`📋 ~32 shopping lists (all 9 types + active/completed/archived)`);
  console.log(`📦 ~110 inventory items`);
  console.log(`🧾 ~76 receipts`);
  console.log(`🔔 ~30 notifications`);
  console.log(`✉️ 4 pending invites (3 pending + 1 rejected)`);
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
  console.log('   gil.google@demo.com — Google Sign-In (no phone, has profile image)');
  console.log('   apple_user@icloud.com — Apple Sign-In (email as name, no phone)');
  console.log('   mike.johnson@demo.com — English speaker (EN locale, English list names)');
  console.log("   george.haviv@demo.com — Special chars (ג'ורג', long item names, free items)");
  console.log('   keren.aviv@demo.com — Roommates (3 girls, shared apartment, not family)');
  console.log('   shlomo.berk@demo.com — Elderly user (minimal, simple usage)');
  console.log('   ilan.peretz@demo.com — Removed user (was in Cohen, now personal household)');
  console.log('   michal.new@gmail.com — Pre-signup invite (no account yet)');
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
