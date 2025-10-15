// 🎬 Demo Data Generator - יוצר סביבת דמו מלאה עם נתונים אמיתיים
// 
// מה הוא עושה:
// - משפחה של 5 משתמשים באותו household
// - שולף מוצרים אמיתיים מ-Firestore (products collection)
// - שולף תבניות מערכת קיימות (templates collection)
// - יוצר רשימות קניות מגוונות עם המוצרים האמיתיים
// - יוצר קבלות היסטוריות
// - יוצר מלאי בבית
// - יוצר תבניות אישיות
//
// שימוש:
// 1. הרץ קודם find_demo_uids.js למצוא UIDs
// 2. עדכן את UIDs למטה
// 3. node scripts/generate_demo_data.js

const admin = require('firebase-admin');
const path = require('path');

// טעינת Service Account Key
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'salsheli',
});
const db = admin.firestore();

// ✅ משפחת לוי - UIDs מעודכנים מ-Firebase Auth!
const FAMILY_MEMBERS = [
  {
    uid: 'apLPgpAyt6Rt8YPK4fJclKzh5',
    email: 'avi.levi@demo.com',
    name: 'אבי לוי',
    role: 'אבא',
    age: 38,
    isAdmin: true,
  },
  {
    uid: 'TXYRsa1deTNze4iCWYfcvqJ6',
    email: 'michal.levi@demo.com',
    name: 'מיכל לוי',
    role: 'אמא',
    age: 36,
    isAdmin: true,
  },
  {
    uid: 'YeHdmVDVlPMoQsUnf4LUFyu',
    email: 'tomer.levi@demo.com',
    name: 'תומר לוי',
    role: 'בן',
    age: 14,
    isAdmin: false,
  },
  {
    uid: 'vszUQ7tfzbhJtCTtjfl2eevzwjj2',
    email: 'noam.levi@demo.com',
    name: 'נועם לוי',
    role: 'בן',
    age: 10,
    isAdmin: false,
  },
  {
    uid: 'iu0b4elMkyQGauksBJ5lp3c07',
    email: 'talia.levi@demo.com',
    name: 'טליה לוי',
    role: 'בת',
    age: 7,
    isAdmin: false,
  },
];

const HOUSEHOLD_ID = 'house_levi_demo';

// === משתנים גלובליים ===
let availableProducts = [];
let systemTemplates = [];

// === פונקציות עזר ===

function randomDate(daysAgo) {
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  date.setHours(Math.floor(Math.random() * 12) + 8);
  date.setMinutes(Math.floor(Math.random() * 60));
  return admin.firestore.Timestamp.fromDate(date);
}

function randomItem(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function randomItems(array, count) {
  const shuffled = [...array].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, Math.min(count, array.length));
}

function generateId(prefix) {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

// === טעינת מוצרים אמיתיים מ-Firestore ===
async function loadProducts() {
  console.log('📥 טוען מוצרים מ-Firestore...');
  
  try {
    const snapshot = await db.collection('products').limit(100).get();
    
    if (snapshot.empty) {
      console.log('   ⚠️  אין מוצרים ב-collection! משתמש במוצרי ברירת מחדל');
      availableProducts = getDefaultProducts();
    } else {
      availableProducts = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          barcode: data.barcode || doc.id,
          name: data.name,
          category: data.category || 'כללי',
          price: data.price || 5.0,
          brand: data.brand || 'מותג כללי',
          unit: data.unit || 'יח׳',
        };
      });
      console.log(`   ✅ נטענו ${availableProducts.length} מוצרים אמיתיים`);
    }
  } catch (error) {
    console.log(`   ⚠️  שגיאה בטעינת מוצרים: ${error.message}`);
    console.log('   → משתמש במוצרי ברירת מחדל');
    availableProducts = getDefaultProducts();
  }
  
  console.log('');
}

// === טעינת תבניות מערכת ===
async function loadSystemTemplates() {
  console.log('📥 טוען תבניות מערכת...');
  
  try {
    const snapshot = await db.collection('templates')
      .where('is_system', '==', true)
      .get();
    
    systemTemplates = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        name: data.name,
        type: data.type,
        items: data.items || [],
      };
    });
    
    console.log(`   ✅ נטענו ${systemTemplates.length} תבניות מערכת`);
  } catch (error) {
    console.log(`   ⚠️  שגיאה בטעינת תבניות: ${error.message}`);
    systemTemplates = [];
  }
  
  console.log('');
}

// === מוצרי ברירת מחדל (אם אין ב-DB) ===
function getDefaultProducts() {
  return [
    { barcode: '7290000000001', name: 'חלב 3%', category: 'חלב', price: 6.5, brand: 'תנובה', unit: 'יח׳' },
    { barcode: '7290000000002', name: 'לחם פרוס', category: 'לחם', price: 8.9, brand: 'אנג\'ל', unit: 'יח׳' },
    { barcode: '7290000000003', name: 'ביצים גדולות', category: 'ביצים', price: 12.9, brand: 'מעוף', unit: 'יח׳' },
    { barcode: '7290000000004', name: 'גבינה צהובה', category: 'חלב', price: 24.9, brand: 'תנובה', unit: 'יח׳' },
    { barcode: '7290000000005', name: 'עגבניות', category: 'ירקות', price: 5.9, brand: 'טרי', unit: 'ק"ג' },
    { barcode: '7290000000006', name: 'מלפפון', category: 'ירקות', price: 4.5, brand: 'טרי', unit: 'ק"ג' },
    { barcode: '7290000000007', name: 'בננות', category: 'פירות', price: 6.9, brand: 'טרי', unit: 'ק"ג' },
    { barcode: '7290000000008', name: 'חזה עוף', category: 'בשר', price: 39.9, brand: 'עוף טוב', unit: 'ק"ג' },
    { barcode: '7290000000009', name: 'אורז לבן', category: 'יבש', price: 12.9, brand: 'סוגת', unit: 'יח׳' },
    { barcode: '7290000000010', name: 'פסטה', category: 'יבש', price: 7.5, brand: 'אסם', unit: 'יח׳' },
    { barcode: '7290000000011', name: 'קוקה קולה 1.5L', category: 'שתייה', price: 5.9, brand: 'קוקה קולה', unit: 'יח׳' },
    { barcode: '7290000000012', name: 'יוגורט', category: 'חלב', price: 4.9, brand: 'יופלה', unit: 'יח׳' },
    { barcode: '7290000000013', name: 'שמן זית', category: 'שמנים', price: 24.9, brand: 'עין זית', unit: 'יח׳' },
    { barcode: '7290000000014', name: 'קמח לבן', category: 'אפייה', price: 8.9, brand: 'רקיק', unit: 'יח׳' },
    { barcode: '7290000000015', name: 'סוכר לבן', category: 'אפייה', price: 6.5, brand: 'סוכרזית', unit: 'יח׳' },
    { barcode: '7290000000016', name: 'קוטג\' 5%', category: 'חלב', price: 6.2, brand: 'תנובה', unit: 'יח׳' },
    { barcode: '7290000000017', name: 'חמאה', category: 'חלב', price: 12.9, brand: 'תנובה', unit: 'יח׳' },
    { barcode: '7290000000018', name: 'מיץ תפוזים', category: 'שתייה', price: 8.9, brand: 'פריגת', unit: 'יח׳' },
    { barcode: '7290000000019', name: 'תפוזים', category: 'פירות', price: 5.5, brand: 'טרי', unit: 'ק"ג' },
    { barcode: '7290000000020', name: 'תפוחים', category: 'פירות', price: 7.9, brand: 'טרי', unit: 'ק"ג' },
  ];
}

// === יצירת משתמשים ===
async function createUsers() {
  console.log('👥 יוצר משתמשים...');
  
  for (const member of FAMILY_MEMBERS) {
    if (member.uid.startsWith('PASTE_')) {
      console.log(`   ⏭️  מדלג על ${member.name} - עדכן UID קודם`);
      continue;
    }
    
    const userData = {
      id: member.uid,
      name: member.name,
      email: member.email,
      household_id: HOUSEHOLD_ID,
      joined_at: randomDate(30),
      last_login_at: randomDate(1),
      preferred_stores: ['שופרסל', 'רמי לוי', 'פארם'],
      favorite_products: randomItems(availableProducts, 5).map(p => p.barcode),
      weekly_budget: member.isAdmin ? 1500 : 0,
      is_admin: member.isAdmin,
      profile_image_url: null,
    };
    
    await db.collection('users').doc(member.uid).set(userData);
    
    // עדכון displayName ב-Firebase Auth
    try {
      await admin.auth().updateUser(member.uid, {
        displayName: member.name
      });
    } catch (e) {
      console.log(`   ⚠️  לא ניתן לעדכן Auth displayName`);
    }
    
    console.log(`   ✅ ${member.name} (${member.role})`);
  }
  
  console.log('');
}

// === יצירת רשימות קניות ===
async function createShoppingLists() {
  console.log('🛒 יוצר רשימות קניות...');
  
  const activeMembers = FAMILY_MEMBERS.filter(m => !m.uid.startsWith('PASTE_'));
  if (activeMembers.length === 0) {
    console.log('   ⚠️  אין משתמשים פעילים - עדכן UIDs');
    return;
  }
  
  let listsCreated = 0;
  
  // אם יש תבניות מערכת - השתמש בהן
  if (systemTemplates.length > 0) {
    console.log(`   📋 משתמש ב-${systemTemplates.length} תבניות מערכת`);
    
    // יצירת רשימה לכל תבנית מערכת
    for (const template of systemTemplates.slice(0, 3)) {
      const listId = generateId('list');
      const creator = randomItem(activeMembers);
      const daysAgo = Math.floor(Math.random() * 20) + 5;
      
      // המרת פריטי התבנית לפריטי רשימה
      const items = template.items.map((item, index) => {
        // מצא מוצר תואם או השתמש במידע מהתבנית
        const matchingProduct = availableProducts.find(p => 
          p.name === item.name || p.name.includes(item.name) || item.name.includes(p.name)
        );
        
        return {
          id: `item_${index}`,
          name: item.name,
          quantity: item.quantity || 1,
          unit: item.unit || 'יח׳',
          category: item.category || matchingProduct?.category || 'כללי',
          price: matchingProduct?.price || 5.0,
          is_checked: Math.random() > 0.3, // 70% סיכוי שנסמן
          barcode: matchingProduct?.barcode || `temp_${index}`,
        };
      });
      
      const listData = {
        id: listId,
        name: template.name,
        household_id: HOUSEHOLD_ID,
        creator_id: creator.uid,
        creator_name: creator.name,
        items: items,
        created_date: randomDate(daysAgo + 1),
        updated_date: randomDate(daysAgo),
        status: Math.random() > 0.2 ? 'completed' : 'active',
        total_price: items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
        format: 'shared',
      };
      
      await db.collection('shopping_lists').doc(listId).set(listData);
      listsCreated++;
    }
  }
  
  // רשימות שבועיות נוספות (4 שבועות)
  for (let week = 0; week < 4; week++) {
    const listId = generateId('list');
    const creator = randomItem(activeMembers);
    const daysAgo = week * 7 + Math.floor(Math.random() * 3);
    
    // בחר 8-15 מוצרים אקראיים
    const selectedProducts = randomItems(availableProducts, Math.floor(Math.random() * 8) + 8);
    
    const items = selectedProducts.map((product, index) => ({
      id: `item_${index}`,
      name: product.name,
      quantity: Math.floor(Math.random() * 3) + 1,
      unit: product.unit,
      category: product.category,
      price: product.price,
      is_checked: true,
      barcode: product.barcode,
    }));
    
    const listData = {
      id: listId,
      name: `קניות שבועיות - שבוע ${4 - week}`,
      household_id: HOUSEHOLD_ID,
      creator_id: creator.uid,
      creator_name: creator.name,
      items: items,
      created_date: randomDate(daysAgo + 1),
      updated_date: randomDate(daysAgo),
      status: 'completed',
      total_price: items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
      format: 'shared',
    };
    
    await db.collection('shopping_lists').doc(listId).set(listData);
    listsCreated++;
  }
  
  // רשימה פעילה נוכחית
  const activeListId = generateId('list');
  const urgentProducts = randomItems(availableProducts, 5);
  
  const activeItems = urgentProducts.map((product, index) => ({
    id: `item_${index}`,
    name: product.name,
    quantity: 1,
    unit: product.unit,
    category: product.category,
    price: product.price,
    is_checked: false,
    barcode: product.barcode,
  }));
  
  await db.collection('shopping_lists').doc(activeListId).set({
    id: activeListId,
    name: 'קניות דחופות 🔥',
    household_id: HOUSEHOLD_ID,
    creator_id: activeMembers[0].uid,
    creator_name: activeMembers[0].name,
    items: activeItems,
    created_date: randomDate(1),
    updated_date: admin.firestore.Timestamp.now(),
    status: 'active',
    total_price: activeItems.reduce((sum, item) => sum + (item.price * item.quantity), 0),
    format: 'shared',
  });
  listsCreated++;
  
  console.log(`   ✅ ${listsCreated} רשימות נוצרו`);
  console.log('');
}

// === יצירת קבלות ===
async function createReceipts() {
  console.log('🧾 יוצר קבלות...');
  
  const stores = ['שופרסל', 'רמי לוי', 'פארם', 'סופר פארם', 'יינות ביתן'];
  const activeMembers = FAMILY_MEMBERS.filter(m => !m.uid.startsWith('PASTE_'));
  
  if (activeMembers.length === 0) {
    console.log('   ⚠️  אין משתמשים פעילים');
    return;
  }
  
  let receiptsCreated = 0;
  
  // 20 קבלות מהחודש האחרון
  for (let i = 0; i < 20; i++) {
    const receiptId = generateId('receipt');
    const store = randomItem(stores);
    const buyer = randomItem(activeMembers);
    const daysAgo = Math.floor(Math.random() * 30);
    
    // בחר 5-12 מוצרים אקראיים
    const selectedProducts = randomItems(availableProducts, Math.floor(Math.random() * 8) + 5);
    
    const items = selectedProducts.map(product => {
      const quantity = Math.floor(Math.random() * 3) + 1;
      const price = product.price * (0.9 + Math.random() * 0.2); // וריאציה קטנה במחיר
      
      return {
        name: product.name,
        quantity: quantity,
        price: Math.round(price * 100) / 100,
        total: Math.round(price * quantity * 100) / 100,
        barcode: product.barcode,
        category: product.category,
      };
    });
    
    const totalAmount = items.reduce((sum, item) => sum + item.total, 0);
    
    const receiptData = {
      id: receiptId,
      household_id: HOUSEHOLD_ID,
      store_name: store,
      store_address: `${store} - סניף מרכז, רחוב הדוגמה 123`,
      date: randomDate(daysAgo),
      total_amount: Math.round(totalAmount * 100) / 100,
      items: items,
      uploaded_by: buyer.uid,
      uploaded_at: randomDate(daysAgo),
      image_url: null,
    };
    
    await db.collection('receipts').doc(receiptId).set(receiptData);
    receiptsCreated++;
  }
  
  console.log(`   ✅ ${receiptsCreated} קבלות נוצרו`);
  console.log('');
}

// === יצירת מלאי ===
async function createInventory() {
  console.log('📦 יוצר מלאי...');
  
  // בחר 20-30 מוצרים למלאי
  const inventoryProducts = randomItems(availableProducts, Math.min(30, availableProducts.length));
  let inventoryCreated = 0;
  
  for (const product of inventoryProducts) {
    const inventoryId = generateId('inv');
    const quantity = Math.floor(Math.random() * 5) + 1;
    const daysUntilExpiry = Math.floor(Math.random() * 60) + 5;
    
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + daysUntilExpiry);
    
    const inventoryData = {
      id: inventoryId,
      household_id: HOUSEHOLD_ID,
      product_name: product.name,
      barcode: product.barcode,
      category: product.category,
      quantity: quantity,
      unit: product.unit,
      location: randomItem(['מקרר', 'מזווה', 'מקפיא', 'ארון']),
      expiry_date: admin.firestore.Timestamp.fromDate(expiryDate),
      added_date: randomDate(Math.floor(Math.random() * 10)),
      notes: daysUntilExpiry < 14 ? 'עומד להיגמר' : null,
    };
    
    await db.collection('inventory').doc(inventoryId).set(inventoryData);
    inventoryCreated++;
  }
  
  console.log(`   ✅ ${inventoryCreated} פריטי מלאי נוצרו`);
  console.log('');
}

// === Main ===
async function main() {
  console.log('🎬 מתחיל יצירת נתוני דמו...');
  console.log('');
  
  try {
    // טעינת נתונים קיימים
    await loadProducts();
    await loadSystemTemplates();
    
    // יצירת נתונים חדשים
    await createUsers();
    await createShoppingLists();
    await createReceipts();
    await createInventory();
    
    console.log('');
    console.log('🎉 ========================================');
    console.log('✅ סביבת הדמו נוצרה בהצלחה!');
    console.log('🎉 ========================================');
    console.log('');
    console.log('📊 נתונים שנוצרו:');
    console.log(`   👥 ${FAMILY_MEMBERS.filter(m => !m.uid.startsWith('PASTE_')).length} משתמשים`);
    console.log(`   📦 ${availableProducts.length} מוצרים זמינים`);
    console.log(`   🛒 ~10-15 רשימות קניות`);
    console.log(`   🧾 20 קבלות`);
    console.log(`   📦 ~30 פריטי מלאי`);
    console.log('');
    console.log('🚀 עכשיו הרץ את האפליקציה והתחבר עם אחד ממשתמשי הדמו!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ שגיאה:', error);
    process.exit(1);
  }
}

main();
