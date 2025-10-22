// 🔄 Migration: ReceiptItem → UnifiedListItem
// 
// שימוש: node scripts/migrate_to_unified_list_item.js
// 
// מה הסקריפט עושה:
// 1. קורא את כל רשימות הקניות מ-Firestore
// 2. ממיר כל item מ-ReceiptItem ל-UnifiedListItem (type: product)
// 3. שומר בחזרה ב-Firestore
// 
// ⚠️ הערה: הסקריפט מזהה אוטומטית אם כבר בוצעה המרה (בודק אם יש שדה 'type')

const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.join(__dirname, 'firebase-service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'memozap-5ad30',
});

const db = admin.firestore();

// ====================================
// פונקציות עזר
// ====================================

/**
 * בדיקה אם item כבר הומר (יש לו שדה type)
 */
function isAlreadyMigrated(item) {
  return item.hasOwnProperty('type');
}

/**
 * המרת ReceiptItem ל-UnifiedListItem
 */
function convertToUnifiedListItem(receiptItem) {
  // אם כבר הומר - החזר כמו שהוא
  if (isAlreadyMigrated(receiptItem)) {
    console.log(`      ℹ️  "${receiptItem.name}" כבר הומר - מדלג`);
    return receiptItem;
  }
  
  // המרה חדשה
  const unified = {
    id: receiptItem.id || '',
    name: receiptItem.name || 'מוצר ללא שם',
    type: 'product',
    isChecked: receiptItem.isChecked || false,
    category: receiptItem.category || null,
    notes: null,
    
    // נתונים ספציפיים למוצר
    productData: {
      quantity: receiptItem.quantity || 1,
      unitPrice: receiptItem.unitPrice || 0.0,
      barcode: receiptItem.barcode || null,
      unit: receiptItem.unit || "יח'",
    },
    
    // משימות - null
    taskData: null,
  };
  
  console.log(`      ✅ "${unified.name}" הומר בהצלחה`);
  return unified;
}

/**
 * המרת רשימה שלמה
 */
function migrateList(list) {
  const items = list.items || [];
  
  // ספירת items שכבר הומרו
  const alreadyMigratedCount = items.filter(isAlreadyMigrated).length;
  const needsMigration = items.length - alreadyMigratedCount;
  
  if (needsMigration === 0) {
    return {
      needsUpdate: false,
      migratedItems: items,
      stats: {
        total: items.length,
        migrated: 0,
        skipped: alreadyMigratedCount,
      },
    };
  }
  
  // המר את כל ה-items
  const migratedItems = items.map(convertToUnifiedListItem);
  
  return {
    needsUpdate: true,
    migratedItems: migratedItems,
    stats: {
      total: items.length,
      migrated: needsMigration,
      skipped: alreadyMigratedCount,
    },
  };
}

// ====================================
// Main Function
// ====================================

async function runMigration() {
  console.log('');
  console.log('═══════════════════════════════════════════════════════');
  console.log('🔄 Migration: ReceiptItem → UnifiedListItem');
  console.log('═══════════════════════════════════════════════════════');
  console.log('');
  
  try {
    // קריאת כל הרשימות
    console.log('📥 טוען רשימות מ-Firestore...');
    const snapshot = await db.collection('shopping_lists').get();
    
    console.log(`   ✅ נטענו ${snapshot.size} רשימות`);
    console.log('');
    
    if (snapshot.size === 0) {
      console.log('   ℹ️  אין רשימות להמיר');
      process.exit(0);
    }
    
    // סטטיסטיקות גלובליות
    let totalLists = 0;
    let totalUpdated = 0;
    let totalSkipped = 0;
    let totalItems = 0;
    let totalItemsMigrated = 0;
    let totalItemsSkipped = 0;
    
    // עיבוד כל רשימה
    for (const doc of snapshot.docs) {
      totalLists++;
      const listData = doc.data();
      const listName = listData.name || 'רשימה ללא שם';
      const listId = doc.id;
      
      console.log(`📋 [${totalLists}/${snapshot.size}] עובד על: "${listName}"`);
      console.log(`   🆔 ID: ${listId}`);
      
      // המר רשימה
      const result = migrateList(listData);
      
      totalItems += result.stats.total;
      totalItemsMigrated += result.stats.migrated;
      totalItemsSkipped += result.stats.skipped;
      
      // הדפס סטטיסטיקות
      console.log(`   📊 סטטיסטיקות:`);
      console.log(`      • סה"כ items: ${result.stats.total}`);
      console.log(`      • הומרו: ${result.stats.migrated}`);
      console.log(`      • כבר היו מומרים: ${result.stats.skipped}`);
      
      // שמור רק אם צריך
      if (result.needsUpdate) {
        console.log(`   💾 שומר שינויים...`);
        
        await doc.ref.update({
          items: result.migratedItems,
          updated_date: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        totalUpdated++;
        console.log(`   ✅ נשמר בהצלחה`);
      } else {
        totalSkipped++;
        console.log(`   ⏭️  לא נדרש עדכון (כל ה-items כבר הומרו)`);
      }
      
      console.log('');
    }
    
    // דוח סיכום
    console.log('═══════════════════════════════════════════════════════');
    console.log('📊 דוח סיכום:');
    console.log('═══════════════════════════════════════════════════════');
    console.log('');
    console.log('📋 רשימות:');
    console.log(`   • סה"כ: ${totalLists}`);
    console.log(`   • עודכנו: ${totalUpdated}`);
    console.log(`   • דולגו (כבר מומרים): ${totalSkipped}`);
    console.log('');
    console.log('🛒 Items:');
    console.log(`   • סה"כ: ${totalItems}`);
    console.log(`   • הומרו: ${totalItemsMigrated}`);
    console.log(`   • כבר היו מומרים: ${totalItemsSkipped}`);
    console.log('');
    
    if (totalItemsMigrated > 0) {
      console.log('✅ ההמרה הושלמה בהצלחה!');
      console.log(`   🎉 ${totalItemsMigrated} items הומרו מ-ReceiptItem ל-UnifiedListItem`);
    } else {
      console.log('ℹ️  כל ה-items כבר היו מומרים - לא בוצעו שינויים');
    }
    
    console.log('');
    console.log('═══════════════════════════════════════════════════════');
    
    process.exit(0);
  } catch (error) {
    console.error('');
    console.error('❌ שגיאה בהרצת ההמרה:', error);
    console.error('');
    process.exit(1);
  }
}

// הרצת ההמרה
runMigration();
