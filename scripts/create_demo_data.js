#!/usr/bin/env node

// 📄 File: scripts/create_demo_data.js
// תיאור: Script ליצירת נתוני דמו מלאים עבור משתמשי הדמו
//
// מה הסקריפט יוצר:
// ✅ 3 רשימות קניות (2 פעילות + 1 הושלמה)
// ✅ 15 פריטים במלאי (כמויות שונות)
// ✅ 2 קבלות נוספות (בנוסף ל-6 הקיימות)
//
// שימוש:
//   node scripts/create_demo_data.js

const admin = require('firebase-admin');
const path = require('path');

// ======== הגדרות ========

const serviceAccountPath = path.join(__dirname, 'firebase-service-account.json');
const HOUSEHOLD_ID = 'house_demo';
const USER_ID = 'yoni_demo_user';

// ======== אתחול Firebase Admin ========

try {
  const serviceAccount = require(serviceAccountPath);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  
  console.log('✅ Firebase Admin initialized successfully\n');
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin:');
  console.error('   Error:', error.message);
  process.exit(1);
}

const db = admin.firestore();

// ======== נתוני דמו ========

/**
 * רשימות קניות (3)
 */
const DEMO_LISTS = [
  {
    id: 'list_weekly_groceries',
    name: 'קניות שבועיות',
    type: 'super',
    status: 'active',
    items: [
      { name: 'חלב 3%', category: 'dairy', quantity: 2, unit: 'יח', status: 'pending', notes: '' },
      { name: 'לחם שיפון', category: 'bakery', quantity: 1, unit: 'יח', status: 'pending', notes: '' },
      { name: 'ביצים גדולות', category: 'dairy', quantity: 1, unit: 'יח', status: 'pending', notes: '' },
      { name: 'עגבניות', category: 'vegetables', quantity: 1, unit: 'ק"ג', status: 'pending', notes: '' },
      { name: 'מלפפונים', category: 'vegetables', quantity: 5, unit: 'יח', status: 'pending', notes: '' },
      { name: 'יוגורט תנובה', category: 'dairy', quantity: 8, unit: 'יח', status: 'pending', notes: '150 גרם' },
      { name: 'שמן זית', category: 'dry_goods', quantity: 1, unit: 'יח', status: 'pending', notes: '' },
      { name: 'אורז', category: 'dry_goods', quantity: 1, unit: 'ק"ג', status: 'pending', notes: '' },
    ],
  },
  {
    id: 'list_party_supplies',
    name: 'יום הולדת לילדים',
    type: 'event_birthday',
    status: 'active',
    items: [
      { name: 'בלונים צבעוניים', category: 'party_decoration', quantity: 2, unit: 'חבילות', status: 'pending', notes: '' },
      { name: 'צלחות חד פעמי', category: 'disposables', quantity: 50, unit: 'יח', status: 'taken', notes: '' },
      { name: 'כוסות חד פעמי', category: 'disposables', quantity: 50, unit: 'יח', status: 'pending', notes: '' },
      { name: 'עוגה', category: 'bakery', quantity: 1, unit: 'יח', status: 'pending', notes: 'להזמין מהקונדיטוריה' },
      { name: 'שתייה קרה', category: 'beverages', quantity: 6, unit: 'בקבוקים', status: 'pending', notes: 'קולה ספרייט' },
      { name: 'חטיפים', category: 'snacks', quantity: 5, unit: 'שקיות', status: 'taken', notes: 'במבה ביסלי' },
    ],
  },
  {
    id: 'list_pharmacy_completed',
    name: 'ביקור בסופר פארם',
    type: 'pharmacy',
    status: 'completed',
    items: [
      { name: 'שמפו', category: 'toiletries', quantity: 1, unit: 'יח', status: 'purchased', notes: 'הד אנד שולדרס' },
      { name: 'משחת שיניים', category: 'toiletries', quantity: 2, unit: 'יח', status: 'purchased', notes: 'קולגייט' },
      { name: 'סבון נוזלי', category: 'cleaning', quantity: 1, unit: 'יח', status: 'purchased', notes: '' },
      { name: 'ויטמין D', category: 'other', quantity: 1, unit: 'יח', status: 'purchased', notes: '' },
    ],
  },
];

/**
 * פריטי מלאי (15)
 */
const DEMO_INVENTORY = [
  { name: 'קמח', category: 'dry_goods', quantity: 2, unit: 'ק"ג', location: 'מזווה', min_quantity: 1, expiry_date: null, notes: '' },
  { name: 'סוכר', category: 'dry_goods', quantity: 1, unit: 'ק"ג', location: 'מזווה', min_quantity: 1, expiry_date: null, notes: '' },
  { name: 'מלח', category: 'dry_goods', quantity: 1, unit: 'ק"ג', location: 'מזווה', min_quantity: 0.5, expiry_date: null, notes: '' },
  { name: 'פסטה', category: 'dry_goods', quantity: 3, unit: 'חבילות', location: 'מזווה', min_quantity: 2, expiry_date: null, notes: '' },
  { name: 'קטשופ', category: 'dry_goods', quantity: 1, unit: 'בקבוק', location: 'מקרר', min_quantity: 1, expiry_date: null, notes: '' },
  { name: 'מיונז', category: 'dry_goods', quantity: 0.5, unit: 'בקבוק', location: 'מקרר', min_quantity: 1, expiry_date: null, notes: 'נגמר בקרוב' },
  { name: 'שמן זית', category: 'dry_goods', quantity: 0.5, unit: 'בקבוק', location: 'מזווה', min_quantity: 1, expiry_date: null, notes: 'לקנות בקרוב' },
  { name: 'קפה', category: 'beverages', quantity: 1, unit: 'קופסה', location: 'מזווה', min_quantity: 1, expiry_date: null, notes: '' },
  { name: 'תה', category: 'beverages', quantity: 20, unit: 'שקיקים', location: 'מזווה', min_quantity: 10, expiry_date: null, notes: '' },
  { name: 'שמן קנולה', category: 'dry_goods', quantity: 0.8, unit: 'בקבוק', location: 'מזווה', min_quantity: 1, expiry_date: null, notes: '' },
  { name: 'אורז בסמטי', category: 'dry_goods', quantity: 5, unit: 'ק"ג', location: 'מזווה', min_quantity: 2, expiry_date: null, notes: '' },
  { name: 'חומוס משומר', category: 'dry_goods', quantity: 4, unit: 'קופסאות', location: 'מזווה', min_quantity: 2, expiry_date: null, notes: '' },
  { name: 'טונה', category: 'dry_goods', quantity: 6, unit: 'קופסאות', location: 'מזווה', min_quantity: 3, expiry_date: null, notes: '' },
  { name: 'נייר טואלט', category: 'cleaning', quantity: 12, unit: 'גלילים', location: 'שירותים', min_quantity: 8, expiry_date: null, notes: '' },
  { name: 'סבון כלים', category: 'cleaning', quantity: 1, unit: 'בקבוק', location: 'מטבח', min_quantity: 1, expiry_date: null, notes: '' },
];

/**
 * קבלות נוספות (2)
 */
const DEMO_RECEIPTS = [
  {
    id: 'receipt_shufersal_recent',
    store_name: 'שופרסל',
    date: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // לפני 3 יום
    total: 287.50,
    items: [
      { name: 'חלב 3%', price: 6.90, quantity: 2 },
      { name: 'לחם שיפון', price: 8.50, quantity: 1 },
      { name: 'גבינה צהובה', price: 35.90, quantity: 1 },
      { name: 'יוגורט', price: 5.50, quantity: 8 },
      { name: 'עגבניות', price: 6.90, quantity: 1 },
      { name: 'מלפפונים', price: 2.50, quantity: 5 },
      { name: 'בננות', price: 8.90, quantity: 1 },
      { name: 'תפוחים', price: 12.90, quantity: 1 },
      { name: 'פסטה', price: 7.90, quantity: 3 },
      { name: 'רוטב עגבניות', price: 8.50, quantity: 2 },
      { name: 'קפה', price: 32.90, quantity: 1 },
      { name: 'שמן זית', price: 29.90, quantity: 1 },
      { name: 'חומוס', price: 10.50, quantity: 4 },
      { name: 'טונה', price: 6.90, quantity: 6 },
      { name: 'נייר טואלט', price: 34.90, quantity: 1 },
    ],
    image_path: null,
  },
  {
    id: 'receipt_ramilevy_recent',
    store_name: 'רמי לוי',
    date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // לפני שבוע
    total: 195.80,
    items: [
      { name: 'חלב 3%', price: 6.50, quantity: 2 },
      { name: 'ביצים גדולות', price: 18.90, quantity: 1 },
      { name: 'לחם', price: 7.90, quantity: 1 },
      { name: 'גבינה לבנה', price: 7.90, quantity: 2 },
      { name: 'קוטג׳', price: 7.50, quantity: 2 },
      { name: 'עגבניות', price: 5.90, quantity: 2 },
      { name: 'מלפפונים', price: 2.20, quantity: 6 },
      { name: 'בצל', price: 4.90, quantity: 1 },
      { name: 'שום', price: 8.90, quantity: 1 },
      { name: 'אורז', price: 15.90, quantity: 2 },
      { name: 'שמן קנולה', price: 12.90, quantity: 1 },
      { name: 'סוכר', price: 9.90, quantity: 1 },
      { name: 'קמח', price: 8.90, quantity: 2 },
      { name: 'סבון כלים', price: 9.90, quantity: 1 },
    ],
    image_path: null,
  },
];

// ======== פונקציות יצירה ========

/**
 * יוצר UUID פשוט
 */
function generateId() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * יוצר רשימת קניות
 */
async function createShoppingList(listData) {
  const { id, name, type, status, items } = listData;
  
  console.log(`📋 Creating shopping list: ${name}`);
  
  try {
    const now = admin.firestore.Timestamp.now();
    
    // המרת items לפורמט נכון
    const formattedItems = items.map(item => ({
      id: generateId(),
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      status: item.status,
      notes: item.notes,
      price: null,
      barcode: null,
      added_by: USER_ID,
      added_date: now,
      updated_date: now,
    }));
    
    const listDoc = {
      id: id,
      name: name,
      type: type,
      status: status,
      household_id: HOUSEHOLD_ID,
      created_by: USER_ID,
      created_date: now,
      updated_date: now,
      items: formattedItems,
      tags: [],
    };
    
    await db.collection('shopping_lists').doc(id).set(listDoc);
    console.log(`   ✅ Created with ${items.length} items`);
  } catch (error) {
    console.error(`   ❌ Failed: ${error.message}`);
    throw error;
  }
}

/**
 * יוצר פריט מלאי
 */
async function createInventoryItem(itemData) {
  const id = generateId();
  
  try {
    const now = admin.firestore.Timestamp.now();
    
    const itemDoc = {
      id: id,
      name: itemData.name,
      category: itemData.category,
      quantity: itemData.quantity,
      unit: itemData.unit,
      location: itemData.location,
      min_quantity: itemData.min_quantity,
      expiry_date: itemData.expiry_date,
      notes: itemData.notes,
      household_id: HOUSEHOLD_ID,
      added_by: USER_ID,
      added_date: now,
      updated_date: now,
    };
    
    await db.collection('inventory').doc(id).set(itemDoc);
  } catch (error) {
    console.error(`   ❌ Failed to create inventory item: ${error.message}`);
    throw error;
  }
}

/**
 * יוצר קבלה
 */
async function createReceipt(receiptData) {
  const { id, store_name, date, total, items, image_path } = receiptData;
  
  console.log(`🧾 Creating receipt: ${store_name} - ${total} ₪`);
  
  try {
    const timestamp = admin.firestore.Timestamp.fromDate(date);
    
    // המרת items לפורמט נכון
    const formattedItems = items.map(item => ({
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      total: item.price * item.quantity,
    }));
    
    const receiptDoc = {
      id: id,
      store_name: store_name,
      date: timestamp,
      total: total,
      items: formattedItems,
      image_path: image_path,
      household_id: HOUSEHOLD_ID,
      uploaded_by: USER_ID,
      created_date: admin.firestore.Timestamp.now(),
    };
    
    await db.collection('receipts').doc(id).set(receiptDoc);
    console.log(`   ✅ Created with ${items.length} items`);
  } catch (error) {
    console.error(`   ❌ Failed: ${error.message}`);
    throw error;
  }
}

// ======== Main ========

async function main() {
  console.log('🚀 Starting demo data creation...\n');
  console.log('═══════════════════════════════════════════\n');
  
  let stats = {
    lists: 0,
    inventory: 0,
    receipts: 0,
    errors: 0,
  };
  
  // יצירת רשימות קניות
  console.log('📋 Creating shopping lists...\n');
  for (const list of DEMO_LISTS) {
    try {
      await createShoppingList(list);
      stats.lists++;
    } catch (error) {
      stats.errors++;
    }
  }
  console.log();
  
  // יצירת פריטי מלאי
  console.log('📦 Creating inventory items...\n');
  for (const item of DEMO_INVENTORY) {
    try {
      await createInventoryItem(item);
      stats.inventory++;
      if (stats.inventory % 5 === 0) {
        console.log(`   📦 Created ${stats.inventory}/${DEMO_INVENTORY.length} items...`);
      }
    } catch (error) {
      stats.errors++;
    }
  }
  console.log(`   ✅ All ${stats.inventory} inventory items created\n`);
  
  // יצירת קבלות
  console.log('🧾 Creating receipts...\n');
  for (const receipt of DEMO_RECEIPTS) {
    try {
      await createReceipt(receipt);
      stats.receipts++;
    } catch (error) {
      stats.errors++;
    }
  }
  console.log();
  
  // סיכום
  console.log('═══════════════════════════════════════════\n');
  console.log('📊 Summary:');
  console.log(`   📋 Shopping Lists: ${stats.lists}/${DEMO_LISTS.length}`);
  console.log(`   📦 Inventory Items: ${stats.inventory}/${DEMO_INVENTORY.length}`);
  console.log(`   🧾 Receipts: ${stats.receipts}/${DEMO_RECEIPTS.length}`);
  console.log(`   ❌ Errors: ${stats.errors}\n`);
  
  if (stats.errors === 0) {
    console.log('🎉 All demo data created successfully!\n');
    console.log('📱 Now you can login and see:');
    console.log('   • 3 shopping lists (2 active + 1 completed)');
    console.log('   • 15 inventory items (with low stock warnings)');
    console.log('   • 8 receipts total (6 existing + 2 new)');
    console.log('   • Realistic statistics in Settings\n');
  } else {
    console.log('⚠️  Some data failed to create. Check the logs above.\n');
  }
  
  process.exit(stats.errors === 0 ? 0 : 1);
}

// הרצה
main().catch(error => {
  console.error('\n❌ Fatal error:', error);
  process.exit(1);
});
