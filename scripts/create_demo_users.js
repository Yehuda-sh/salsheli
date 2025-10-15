// ✨ Script ליצירת משתמשי דמו נכונים ב-Firestore
// 
// שימוש:
// 1. הרץ קודם: node scripts/find_demo_uids.js
// 2. העתק את ה-UIDs שמצאת למטה
// 3. הרץ: node scripts/create_demo_users.js

const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

// 🔴 חשוב! תעדכן את ה-UIDs האמיתיים כאן אחרי שתריץ את find_demo_uids.js
const demoUsers = [
  {
    // 👇 עדכן את ה-UID האמיתי כאן!
    uid: 'PASTE_DANNY_UID_HERE',
    name: 'דני',
    email: 'danny@demo.com',
  },
  {
    // 👇 עדכן את ה-UID האמיתי כאן!
    uid: 'PASTE_SARAH_UID_HERE',
    name: 'שרה',
    email: 'sarah@demo.com',
  },
  {
    // 👇 עדכן את ה-UID האמיתי כאן!
    uid: 'PASTE_YONI_UID_HERE',
    name: 'יוני',
    email: 'yoni@demo.com',
  }
];

async function createDemoUsers() {
  console.log('✨ יוצר משתמשי דמו נכונים...');
  console.log('');
  
  try {
    // שלב 1: מחיקת משתמשים ישנים
    console.log('🧹 מוחק משתמשים ישנים...');
    const oldIds = ['danny_demo_user', 'sarah_demo_user', 'yoni_demo_user'];
    
    for (const oldId of oldIds) {
      try {
        await db.collection('users').doc(oldId).delete();
        console.log(`   ❌ נמחק: ${oldId}`);
      } catch (e) {
        console.log(`   ⚠️  לא נמצא: ${oldId}`);
      }
    }
    console.log('');
    
    // שלב 2: יצירת משתמשים חדשים עם UIDs נכונים
    console.log('✨ יוצר משתמשים חדשים...');
    const now = admin.firestore.Timestamp.now();
    
    for (const user of demoUsers) {
      if (user.uid.startsWith('PASTE_')) {
        console.log(`❌ ${user.name}: עדכן את ה-UID קודם!`);
        continue;
      }
      
      // עדכון displayName ב-Firebase Auth
      try {
        await auth.updateUser(user.uid, {
          displayName: user.name
        });
        console.log(`   🏷️  ${user.name}: עדכנתי displayName ב-Auth`);
      } catch (e) {
        console.log(`   ⚠️  ${user.name}: לא יכול לעדכן Auth - ${e.message}`);
      }
      
      // יצירת המסמך ב-Firestore עם UID נכון
      const userData = {
        id: user.uid, // ← UID אמיתי!
        name: user.name,
        email: user.email,
        household_id: 'house_demo',
        joined_at: now,
        last_login_at: now,
        preferred_stores: [],
        favorite_products: [],
        weekly_budget: 0,
        is_admin: true,
        profile_image_url: null
      };
      
      await db.collection('users').doc(user.uid).set(userData);
      console.log(`   ✅ ${user.name}: נוצר עם UID נכון (${user.uid})`);
    }
    
    console.log('');
    console.log('🎉 הכל מוכן!');
    console.log('');
    console.log('🚀 עכשיו כשתתחבר עם משתמש דמו:');
    console.log('   1. Firebase Auth יחזיר את ה-UID הנכון');
    console.log('   2. הקוד ימצא את המשתמש ב-Firestore');
    console.log('   3. הכל יעבוד מושלם! 🎯');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ שגיאה:', error);
    process.exit(1);
  }
}

createDemoUsers();
