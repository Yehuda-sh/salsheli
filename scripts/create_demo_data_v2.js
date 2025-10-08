#!/usr/bin/env node

// 📄 File: scripts/create_demo_data_v2.js
// תיאור: Script ליצירת נתוני דמו מלאים עבור משתמשי הדמו
//         ⚡ משתמש במוצרים אמיתיים מ-Firestore (לא Mock Data!)
//
// מה הסקריפט יוצר:
// ✅ 3 רשימות קניות (2 פעילות + 1 הושלמה) - עם מוצרים אמיתיים
// ✅ 15 פריטים במלאי - עם מוצרים אמיתיים
// ✅ 2 קבלות - עם מוצרים אמיתיים ומחירים אמיתיים
//
// שימוש:
//   1. הרץ קודם: node scripts/upload_to_firebase.js (להעלות מוצרים)
//   2. הרץ: node scripts/create_demo_data_v2.js

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

// ======== מיפוי קטגוריות ========

/**
 * מיפוי מקטגוריות האפליקציה לקטגוריות Firestore (עברית)
 * 
 * הקטגוריות ב-Firestore מגיעות מ-Shufersal API ובעברית מלאה
 */
const CATEGORY_MAPPING = {
  // קטגוריות מזון
  'dairy': ['מוצרי חלב'],
  'meat': ['בשר ודגים'],
  'vegetables': ['ירקות'],
  'fruits': ['פירות'],
  'bakery': ['מאפים'],
  'dry_goods': ['אורז ופסטה', 'תבלינים ואפייה', 'שמנים ורטבים'],
  'beverages': ['משקאות', 'קפה ותה'],
  'snacks': ['ממתקים וחטיפים'],
  
  // קטגוריות לא-מזון
  'toiletries': ['היגיינה אישית'],
  'cleaning': ['מוצרי ניקיון'],
  'other': ['אחר', 'קפואים']
};

/**
 * מחזיר מוצרים מקטגוריה ספציפית
 */
function getProductsByAppCategory(products, appCategory, limit = 5) {
  // קבל את הקטגוריות המתאימות ב-Firestore
  const firestoreCategories = CATEGORY_MAPPING[appCategory] || [appCategory];
  
  // סנן מוצרים לפי הקטגוריות
  const filtered = products.filter(p => 
    firestoreCategories.includes(p.category) && 
    p.name && 
    p.price > 0
  );
  
  // ערבוב רנדומלי ובחירת limit ראשונים
  return filtered
    .sort(() => Math.random() - 0.5)
    .slice(0, limit);
}

// ======== פונקציות עזר ========

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
 * טוען מוצרים אמיתיים מ-Firestore
 */
async function loadProducts() {
  console.log('📦 Loading real products from Firestore...\n');
  
  try {
    const snapshot = await db.collection('products').limit(1000).get();
    const products = [];
    
    snapshot.forEach(doc => {
      products.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    console.log(`   ✅ Loaded ${products.length} real products\n`);
    return products;
  } catch (error) {
    console.error(`   ❌ Failed to load products: ${error.message}`);
    console.log('\n💡 Make sure you ran: node scripts/upload_to_firebase.js first!\n');
    throw error;
  }
}

// ======== פונקציות יצירה ========

/**
 * יוצר רשימת קניות עם מוצרים אמיתיים
 */
async function createShoppingList(listData, realProducts) {
  const { id, name, type, status, categoryMap } = listData;
  
  console.log(`📋 Creating shopping list: ${name}`);
  
  try {
    const now = admin.firestore.Timestamp.now();
    const items = [];
    
    // יצירת פריטים מתוך מוצרים אמיתיים
    for (const [appCategory, count] of Object.entries(categoryMap)) {
      const categoryProducts = getProductsByAppCategory(realProducts, appCategory, count);
      
      for (const product of categoryProducts) {
        items.push({
          id: generateId(),
          name: product.name,
          category: product.category, // השתמש בקטגוריה המקורית מ-Firestore
          quantity: Math.floor(Math.random() * 3) + 1, // 1-3
          unit: product.unit || 'יח',
          status: Math.random() > 0.7 ? 'taken' : 'pending', // 30% סיכוי ש-taken
          notes: '',
          price: product.price,
          barcode: product.barcode || null,
          added_by: USER_ID,
          added_date: now,
          updated_date: now,
        });
      }
    }
    
    const listDoc = {
      id: id,
      name: name,
      type: type,
      status: status,
      household_id: HOUSEHOLD_ID,
      created_by: USER_ID,
      created_date: now,
      updated_date: now,
      items: items,
      tags: [],
    };
    
    await db.collection('shopping_lists').doc(id).set(listDoc);
    console.log(`   ✅ Created with ${items.length} real products`);
  } catch (error) {
    console.error(`   ❌ Failed: ${error.message}`);
    throw error;
  }
}

/**
 * יוצר פריט מלאי ממוצר אמיתי
 */
async function createInventoryItem(product, location, minQuantity) {
  const id = generateId();
  
  try {
    const now = admin.firestore.Timestamp.now();
    
    const itemDoc = {
      id: id,
      name: product.name,
      category: product.category, // השתמש בקטגוריה המקורית
      quantity: Math.floor(Math.random() * 5) + 1, // 1-5
      unit: product.unit || 'יח',
      location: location,
      min_quantity: minQuantity,
      expiry_date: null,
      notes: '',
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
 * יוצר קבלה עם מוצרים אמיתיים
 */
async function createReceipt(receiptData, realProducts) {
  const { id, store_name, daysAgo, categoryMap } = receiptData;
  
  console.log(`🧾 Creating receipt: ${store_name}`);
  
  try {
    const date = new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000);
    const timestamp = admin.firestore.Timestamp.fromDate(date);
    const items = [];
    let total = 0;
    
    // יצירת פריטים מתוך מוצרים אמיתיים
    for (const [appCategory, count] of Object.entries(categoryMap)) {
      const categoryProducts = getProductsByAppCategory(realProducts, appCategory, count);
      
      for (const product of categoryProducts) {
        const quantity = Math.floor(Math.random() * 3) + 1; // 1-3
        const itemTotal = product.price * quantity;
        
        items.push({
          name: product.name,
          price: product.price,
          quantity: quantity,
          total: itemTotal,
        });
        
        total += itemTotal;
      }
    }
    
    const receiptDoc = {
      id: id,
      store_name: store_name,
      date: timestamp,
      total: parseFloat(total.toFixed(2)),
      items: items,
      image_path: null,
      household_id: HOUSEHOLD_ID,
      uploaded_by: USER_ID,
      created_date: admin.firestore.Timestamp.now(),
    };
    
    await db.collection('receipts').doc(id).set(receiptDoc);
    console.log(`   ✅ Created with ${items.length} real products, total: ${total.toFixed(2)} ₪`);
  } catch (error) {
    console.error(`   ❌ Failed: ${error.message}`);
    throw error;
  }
}

// ======== נתוני דמו (מבנה בלבד, לא מוצרים!) ========

const DEMO_LISTS_STRUCTURE = [
  {
    id: 'list_weekly_groceries',
    name: 'קניות שבועיות',
    type: 'super',
    status: 'active',
    categoryMap: {
      'dairy': 3,
      'meat': 2,
      'vegetables': 3,
      'fruits': 2,
      'bakery': 2,
      'dry_goods': 2,
    },
  },
  {
    id: 'list_party_supplies',
    name: 'יום הולדת לילדים',
    type: 'event_birthday',
    status: 'active',
    categoryMap: {
      'snacks': 3,
      'beverages': 2,
      'bakery': 1,
    },
  },
  {
    id: 'list_pharmacy_completed',
    name: 'ביקור בסופר פארם',
    type: 'pharmacy',
    status: 'completed',
    categoryMap: {
      'toiletries': 2,
      'cleaning': 1,
    },
  },
];

const DEMO_RECEIPTS_STRUCTURE = [
  {
    id: 'receipt_shufersal_recent',
    store_name: 'שופרסל',
    daysAgo: 3,
    categoryMap: {
      'dairy': 4,
      'bakery': 2,
      'vegetables': 3,
      'dry_goods': 4,
      'beverages': 2,
    },
  },
  {
    id: 'receipt_ramilevy_recent',
    store_name: 'רמי לוי',
    daysAgo: 7,
    categoryMap: {
      'dairy': 3,
      'bakery': 1,
      'vegetables': 4,
      'dry_goods': 3,
    },
  },
];

const INVENTORY_LOCATIONS = [
  { location: 'מזווה', appCategory: 'dry_goods', count: 8, minQuantity: 2 },
  { location: 'מקרר', appCategory: 'dairy', count: 3, minQuantity: 1 },
  { location: 'מטבח', appCategory: 'cleaning', count: 2, minQuantity: 1 },
  { location: 'שירותים', appCategory: 'toiletries', count: 2, minQuantity: 1 },
];

// ======== Main ========

async function main() {
  console.log('🚀 Starting demo data creation with REAL products...\n');
  console.log('═══════════════════════════════════════════\n');
  
  let stats = {
    lists: 0,
    inventory: 0,
    receipts: 0,
    errors: 0,
  };
  
  // 1️⃣ טעינת מוצרים אמיתיים מ-Firestore
  let realProducts = [];
  try {
    realProducts = await loadProducts();
    
    if (realProducts.length === 0) {
      console.error('❌ No products found in Firestore!');
      console.log('\n💡 Run this first: node scripts/upload_to_firebase.js\n');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Failed to load products. Exiting...\n');
    process.exit(1);
  }
  
  // 2️⃣ יצירת רשימות קניות
  console.log('📋 Creating shopping lists...\n');
  for (const list of DEMO_LISTS_STRUCTURE) {
    try {
      await createShoppingList(list, realProducts);
      stats.lists++;
    } catch (error) {
      stats.errors++;
    }
  }
  console.log();
  
  // 3️⃣ יצירת פריטי מלאי
  console.log('📦 Creating inventory items...\n');
  for (const locationConfig of INVENTORY_LOCATIONS) {
    const { location, appCategory, count, minQuantity } = locationConfig;
    const products = getProductsByAppCategory(realProducts, appCategory, count);
    
    for (const product of products) {
      try {
        await createInventoryItem(product, location, minQuantity);
        stats.inventory++;
      } catch (error) {
        stats.errors++;
      }
    }
    
    console.log(`   📦 Created ${products.length} items for ${location}`);
  }
  console.log(`   ✅ All ${stats.inventory} inventory items created\n`);
  
  // 4️⃣ יצירת קבלות
  console.log('🧾 Creating receipts...\n');
  for (const receipt of DEMO_RECEIPTS_STRUCTURE) {
    try {
      await createReceipt(receipt, realProducts);
      stats.receipts++;
    } catch (error) {
      stats.errors++;
    }
  }
  console.log();
  
  // סיכום
  console.log('═══════════════════════════════════════════\n');
  console.log('📊 Summary:');
  console.log(`   📋 Shopping Lists: ${stats.lists}/${DEMO_LISTS_STRUCTURE.length}`);
  console.log(`   📦 Inventory Items: ${stats.inventory}`);
  console.log(`   🧾 Receipts: ${stats.receipts}/${DEMO_RECEIPTS_STRUCTURE.length}`);
  console.log(`   ❌ Errors: ${stats.errors}\n`);
  
  if (stats.errors === 0) {
    console.log('🎉 All demo data created successfully with REAL products!\n');
    console.log('📱 Now you can login and see:');
    console.log('   • 3 shopping lists with real products');
    console.log('   • ~15 inventory items with real products');
    console.log('   • 2 receipts with real products & prices');
    console.log('   • Realistic statistics in Settings\n');
    console.log('💡 All products are loaded from Firestore - NO MOCK DATA!\n');
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
