// 🗑️ Script למחיקת משתמשי דמו מ-Firestore
// 
// שימוש:
// node scripts/cleanup_demo_users.js

const admin = require('firebase-admin');

// אתחול Firebase Admin (ישתמש בפרויקט הפעיל)
admin.initializeApp();
const db = admin.firestore();

const demoUserIds = [
  'danny_demo_user',
  'sarah_demo_user',
  'yoni_demo_user'
];

async function cleanupDemoUsers() {
  console.log('🗑️ מוחק משתמשי דמו...');
  
  try {
    const batch = db.batch();
    
    for (const userId of demoUserIds) {
      const userRef = db.collection('users').doc(userId);
      batch.delete(userRef);
      console.log(`   ❌ מסמן למחיקה: ${userId}`);
    }
    
    await batch.commit();
    console.log('✅ כל משתמשי הדמו נמחקו בהצלחה!');
    console.log('');
    console.log('🔄 עכשיו הרץ את האפליקציה והתחבר עם משתמש דמו - הוא ייווצר מחדש נכון!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ שגיאה במחיקה:', error);
    process.exit(1);
  }
}

cleanupDemoUsers();
