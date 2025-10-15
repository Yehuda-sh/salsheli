// 🔧 Script לתיקון מבנה משתמשי הדמו ב-Firestore
// 
// מה הוא עושה:
// 1. מוחק שדות camelCase מיותרים (householdId, lastLoginAt, createdAt)
// 2. מוודא ששדות snake_case קיימים (household_id, last_login_at, joined_at)
// 3. מתקן תאריכים
// 4. מוסיף שדות חסרים (profile_image_url)
//
// שימוש:
// node scripts/fix_demo_users.js

const admin = require('firebase-admin');

// אתחול Firebase Admin
admin.initializeApp();
const db = admin.firestore();

const demoUsers = [
  {
    id: 'danny_demo_user',
    name: 'דני',
    email: 'danny@demo.com',
  },
  {
    id: 'sarah_demo_user',
    name: 'שרה',
    email: 'sarah@demo.com',
  },
  {
    id: 'yoni_demo_user',
    name: 'יוני',
    email: 'yoni@demo.com',
  }
];

async function fixDemoUsers() {
  console.log('🔧 מתקן משתמשי דמו...');
  console.log('');
  
  try {
    for (const user of demoUsers) {
      console.log(`📝 מתקן: ${user.name} (${user.email})`);
      
      const userRef = db.collection('users').doc(user.id);
      const doc = await userRef.get();
      
      if (!doc.exists) {
        console.log(`   ⚠️  משתמש לא קיים - מדלג`);
        continue;
      }
      
      const now = admin.firestore.Timestamp.now();
      
      // המבנה הנכון עם snake_case בלבד
      const correctData = {
        id: user.id,
        name: user.name,
        email: user.email,
        household_id: 'house_demo', // כולם באותו משק בית
        joined_at: now,
        last_login_at: now,
        preferred_stores: [],
        favorite_products: [],
        weekly_budget: 0,
        is_admin: true,
        profile_image_url: null
      };
      
      // מעדכן את המסמך עם המבנה הנכון
      await userRef.set(correctData, { merge: false }); // merge: false = דורס הכל
      
      console.log(`   ✅ תוקן בהצלחה!`);
      
      // מחיקת שדות מיותרים אם נשארו (camelCase)
      const fieldsToDelete = ['householdId', 'lastLoginAt', 'createdAt', 'avatar'];
      const deleteUpdates = {};
      fieldsToDelete.forEach(field => {
        deleteUpdates[field] = admin.firestore.FieldValue.delete();
      });
      
      await userRef.update(deleteUpdates).catch(() => {
        // אם השדות לא קיימים - ignore
      });
      
      console.log(`   🧹 ניקוי שדות מיותרים הושלם`);
      console.log('');
    }
    
    console.log('✅ כל משתמשי הדמו תוקנו בהצלחה!');
    console.log('');
    console.log('🎯 המבנה הנכון עכשיו:');
    console.log('   - id, name, email');
    console.log('   - household_id (לא householdId)');
    console.log('   - joined_at, last_login_at (לא createdAt)');
    console.log('   - preferred_stores, favorite_products');
    console.log('   - weekly_budget, is_admin');
    console.log('   - profile_image_url (לא avatar)');
    console.log('');
    console.log('🚀 עכשיו אפשר להריץ את האפליקציה!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ שגיאה בתיקון:', error);
    process.exit(1);
  }
}

fixDemoUsers();
