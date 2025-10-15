// 🗑️ מחיקת רשימות ישנות
// 
// שימוש: node scripts/delete_old_lists.js

const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'salsheli',
});

const db = admin.firestore();
const HOUSEHOLD_ID = 'house_apLPgpAyt6Rt8YPK4FJcIKzh5d72';

async function deleteOldLists() {
  console.log('🗑️ מוחק רשימות ישנות...');
  console.log(`   household_id: ${HOUSEHOLD_ID}`);
  console.log('');
  
  try {
    const snapshot = await db.collection('shopping_lists')
      .where('household_id', '==', HOUSEHOLD_ID)
      .get();
    
    console.log(`   📋 נמצאו ${snapshot.size} רשימות`);
    
    if (snapshot.size === 0) {
      console.log('   ℹ️  אין רשימות למחוק');
      process.exit(0);
    }
    
    const deletePromises = snapshot.docs.map(doc => {
      console.log(`   ❌ מוחק: ${doc.data().name} (${doc.id})`);
      return doc.ref.delete();
    });
    
    await Promise.all(deletePromises);
    
    console.log('');
    console.log(`✅ נמחקו ${snapshot.size} רשימות בהצלחה!`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ שגיאה:', error);
    process.exit(1);
  }
}

deleteOldLists();
