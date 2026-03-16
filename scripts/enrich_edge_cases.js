// enrich_edge_cases.js — Add missing edge case scenarios to demo data
// Adds: fresh user, mixed products+tasks list, budget list, incoming group invite
// Run: node scripts/enrich_edge_cases.js

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

function daysAgo(n) { return new Date(now.getTime() - n * DAY); }
function hoursAgo(n) { return new Date(now.getTime() - n * 3600000); }

function loadProducts() {
  const products = [];
  for (const f of ['supermarket','bakery','butcher','greengrocer','pharmacy','market']) {
    const p = path.join(__dirname, '..', 'assets', 'data', 'list_types', `${f}.json`);
    if (fs.existsSync(p)) products.push(...JSON.parse(fs.readFileSync(p, 'utf8')));
  }
  return products;
}
function pickRandom(arr, count) {
  return [...arr].sort(() => Math.random() - 0.5).slice(0, Math.min(count, arr.length));
}
function randomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════
async function main() {
  const products = loadProducts();
  console.log(`📦 ${products.length} מוצרים נטענו\n`);

  // Get existing UIDs
  const uids = {};
  const emails = {
    avi: 'avi.cohen@demo.com', ronit: 'ronit.cohen@demo.com',
    yuval: 'yuval.cohen@demo.com', noa: 'noa.cohen@demo.com',
    dan: 'dan.levi@demo.com', maya: 'maya.levi@demo.com',
    tomer: 'tomer.bar@demo.com', shiran: 'shiran.gal@demo.com',
    ori: 'ori.shalom@demo.com', lior: 'lior.dahan@demo.com',
    naama: 'naama.rozen@demo.com',
  };

  for (const [key, email] of Object.entries(emails)) {
    try {
      const u = await auth.getUserByEmail(email);
      uids[key] = u.uid;
    } catch (e) { /* skip */ }
  }
  console.log(`♻️ ${Object.keys(uids).length} existing users found\n`);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. FRESH USER — 0 lists, 0 pantry, 0 history (empty states)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('👶 יוצר משתמש חדש (Empty State)...');
  let freshUid;
  try {
    const record = await auth.createUser({
      email: 'yael.fresh@demo.com',
      password: DEMO_PASSWORD,
      displayName: 'יעל חדשה',
    });
    freshUid = record.uid;
    console.log(`   ✅ יעל חדשה (${freshUid})`);
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      const existing = await auth.getUserByEmail('yael.fresh@demo.com');
      freshUid = existing.uid;
      console.log(`   ♻️ יעל חדשה (exists: ${freshUid})`);
    } else throw e;
  }
  uids.yael = freshUid;

  // Create household for fresh user
  await db.collection('households').doc('household_yael').set({
    id: 'household_yael', name: 'הבית של יעל',
    created_by: freshUid,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  await db.collection('households').doc('household_yael').collection('members').doc(freshUid).set({
    name: 'יעל חדשה', role: 'admin', joined_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  // User document — just registered, nothing set up
  await db.collection('users').doc(freshUid).set({
    id: freshUid, name: 'יעל חדשה', email: 'yael.fresh@demo.com', phone: '0512345678',
    household_id: 'household_yael', household_name: 'הבית של יעל',
    joined_at: hoursAgo(0.5).toISOString(), // just signed up 30 min ago
    last_login_at: hoursAgo(0.5).toISOString(),
    seen_onboarding: true, seen_tutorial: false, // hasn't seen tutorial yet!
    is_admin: true,
  });
  console.log('   📝 User doc created — 0 lists, 0 pantry, 0 receipts, 0 notifications');
  console.log('   💡 This user tests ALL empty states in every screen\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. MIXED PRODUCTS + TASKS LIST (for Cohen)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('📋 יוצר רשימה מעורבת (מוצרים + משימות)...');

  const supermarketProducts = pickRandom(
    products.filter(p => p.category && p.category !== 'כללי'), 6
  );

  await db.collection('households').doc('household_cohen').collection('shared_lists').doc('list_cohen_mixed').set({
    id: 'list_cohen_mixed', name: 'קניות + משימות לשבת', status: 'active', type: 'supermarket',
    budget: null, is_shared: true, is_private: false, created_by: uids.avi,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(8).toISOString(), updated_date: hoursAgo(1).toISOString(),
    shared_with: [uids.ronit, uids.yuval],
    shared_users: {
      [uids.yuval]: {
        role: 'editor', shared_at: daysAgo(7).toISOString(),
        user_name: 'יובל כהן', user_email: 'yuval.cohen@demo.com', can_start_shopping: true,
      },
    },
    pending_requests: [], active_shoppers: [],
    items: [
      // 6 products from catalog
      ...supermarketProducts.map((p, i) => ({
        id: `item_mix_p${i}`, name: p.name, quantity: randomInt(1, 3), unit: p.unit || "יח'",
        unit_price: p.price || 0, category: p.category, type: 'product',
        is_checked: i < 2, emoji: p.icon || null, notes: null,
      })),
      // 4 tasks
      {
        id: 'item_mix_t0', name: 'לנקות את המקרר', quantity: 1, unit: "יח'",
        unit_price: 0, category: null, type: 'task',
        is_checked: false, emoji: '🧹', notes: 'לפני שמכניסים קניות',
      },
      {
        id: 'item_mix_t1', name: 'להוציא בשר מהמקפיא', quantity: 1, unit: "יח'",
        unit_price: 0, category: null, type: 'task',
        is_checked: true, emoji: '🥩', notes: 'לארוחת שבת',
      },
      {
        id: 'item_mix_t2', name: 'לבדוק תאריכי תפוגה במזווה', quantity: 1, unit: "יח'",
        unit_price: 0, category: null, type: 'task',
        is_checked: false, emoji: '📋', notes: null,
      },
      {
        id: 'item_mix_t3', name: 'להזמין גז', quantity: 1, unit: "יח'",
        unit_price: 0, category: null, type: 'task',
        is_checked: false, emoji: '🔥', notes: 'אמישראגז 1-800-225-225',
      },
    ],
  });
  console.log('   ✅ "קניות + משימות לשבת" — 6 מוצרים + 4 משימות\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. BUDGET LIST with unit_price (for Naama)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('💰 יוצר רשימה עם תקציב...');

  const budgetProducts = pickRandom(
    products.filter(p => p.price && p.price > 0), 10
  );

  await db.collection('households').doc('household_naama').collection('shared_lists').doc('list_naama_budget').set({
    id: 'list_naama_budget', name: 'קניות בתקציב 💰', status: 'active', type: 'supermarket',
    budget: 300, // 300₪ budget!
    is_shared: false, is_private: false, created_by: uids.naama,
    format: 'shared', created_from_template: false,
    created_date: hoursAgo(4).toISOString(), updated_date: hoursAgo(0.5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: budgetProducts.map((p, i) => ({
      id: `item_bgt_${i}`, name: p.name,
      quantity: randomInt(1, 3),
      unit: p.unit || "יח'",
      unit_price: p.price, // actual prices!
      category: p.category, type: 'product',
      is_checked: i < 3, // 3/10 bought
      emoji: p.icon || null,
      notes: i === 0 ? 'לבדוק מבצע ברמי לוי' : null,
    })),
  });
  console.log('   ✅ "קניות בתקציב 💰" — 10 פריטים עם מחירים, budget=300₪\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. INCOMING GROUP INVITE to אבי (pending)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('📩 יוצר הזמנה נכנסת לאבי...');

  await db.collection('pending_invites').doc('invite_avi_from_naama').set({
    id: 'invite_avi_from_naama',
    type: 'inviteToHousehold',
    requester_id: uids.naama,
    requester_name: 'נעמה רוזן',
    requester_email: 'naama.rozen@demo.com',
    target_user_id: uids.avi,
    target_email: 'avi.cohen@demo.com',
    status: 'pending',
    created_at: hoursAgo(3).toISOString(),
    request_data: {
      household_id: 'household_naama',
      household_name: 'הבית של נעמה',
    },
  });
  console.log('   ✅ נעמה → אבי: הזמנה לבית נעמה\n');

  // Also add a notification for this invite
  await db.collection('users').doc(uids.avi).collection('notifications').doc('notif_avi_invite_naama').set({
    id: 'notif_avi_invite_naama', type: 'invite_received',
    title: 'הזמנה חדשה!', body: 'נעמה רוזן הזמינה אותך להצטרף לבית שלה',
    created_at: hoursAgo(3).toISOString(), read: false,
    data: { invite_id: 'invite_avi_from_naama' }, user_id: uids.avi,
  });
  console.log('   🔔 התראה נוספה לאבי (הזמנה נכנסת)\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. PHARMACY LIST for Tomer (solo user edge case)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('💊 יוצר רשימת בית מרקחת לתומר...');

  const pharmaProducts = pickRandom(
    products.filter(p => p.category === 'פארם'), 5
  );

  await db.collection('households').doc('household_tomer').collection('shared_lists').doc('list_tomer_pharmacy').set({
    id: 'list_tomer_pharmacy', name: 'בית מרקחת', status: 'active', type: 'pharmacy',
    budget: null, is_shared: false, is_private: true, // private list!
    created_by: uids.tomer,
    format: 'shared', created_from_template: false,
    created_date: daysAgo(1).toISOString(), updated_date: hoursAgo(5).toISOString(),
    shared_with: [], shared_users: {}, pending_requests: [], active_shoppers: [],
    items: [
      ...pharmaProducts.map((p, i) => ({
        id: `item_ph_${i}`, name: p.name, quantity: 1, unit: "יח'",
        unit_price: p.price || 0, category: p.category, type: 'product',
        is_checked: false, emoji: '💊', notes: null,
      })),
      // A task too
      {
        id: 'item_ph_task', name: 'לשאול על מרשם חדש', quantity: 1, unit: "יח'",
        unit_price: 0, category: null, type: 'task',
        is_checked: false, emoji: '📝', notes: 'ד"ר כהן',
      },
    ],
  });
  console.log('   ✅ "בית מרקחת" — private, 5 מוצרים + 1 משימה\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUMMARY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  console.log('═'.repeat(60));
  console.log('✅ Edge cases enriched successfully!');
  console.log('═'.repeat(60));
  console.log(`
👶 1 משתמש חדש: יעל חדשה (yael.fresh@demo.com) — סה"כ 12
📋 3 רשימות חדשות:
   • "קניות + משימות לשבת" — 6 מוצרים + 4 משימות (mixed!)
   • "קניות בתקציב 💰" — 10 פריטים עם מחירים, budget=300₪
   • "בית מרקחת" — private, 5 פארם + 1 משימה
📩 1 הזמנה נכנסת: נעמה → אבי (הצטרפות לבית)
🔔 1 התראה חדשה לאבי

📊 תרחישי קצה חדשים:
  ✅ משתמש חדש לחלוטין (0 הכל — כל empty states)
  ✅ רשימה מעורבת מוצרים + משימות
  ✅ רשימה עם תקציב מוגדר + מחירים בפריטים
  ✅ הזמנת group נכנסת (לא רק יוצאת)
  ✅ רשימה פרטית (is_private=true)
  ✅ רשימת בית מרקחת (סוג נדיר)
  ✅ משתמש שלא ראה tutorial (seen_tutorial=false)

🔑 סיסמה: ${DEMO_PASSWORD}
`);
}

main().then(() => process.exit(0)).catch(e => { console.error('❌', e); process.exit(1); });
