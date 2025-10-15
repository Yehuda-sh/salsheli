// ✨ Script ליצירת משתמשי דמו ב-Firebase Auth + Firestore
// 
// מה הוא עושה:
// 1. בודק אם המשתמש קיים ב-Auth
// 2. אם לא - יוצר אותו עם אימייל וסיסמה
// 3. יוצר רשומה ב-Firestore עם UID נכון
// 4. מוחק רשומות ישנות (danny_demo_user וכו')
//
// שימוש:
// node scripts/create_demo_users_complete.js

const admin = require('firebase-admin');

admin.initializeApp();
const auth = admin.auth();
const db = admin.firestore();

const DEMO_USERS = [
  {
    email: 'danny@demo.com',
    password: 'Demo123!',
    name: 'דני כהן',
    role: 'אבא',
  },
  {
    email: 'sarah@demo.com',
    password: 'Demo123!',
    name: 'שרה כהן',
    role: 'אמא',
  },
  {
    email: 'yoni@demo.com',
    password: 'Demo123!',
    name: 'יוני כהן',
    role: 'בן',
  },
];

const HOUSEHOLD_ID = 'house_demo';

async function createDemoUsers() {
  console.log('✨ יוצר משתמשי דמו מלאים...');
  console.log('');
  
  const createdUsers = [];
  
  for (const demoUser of DEMO_USERS) {
    console.log(`👤 מטפל ב-${demoUser.name} (${demoUser.email})...`);
    
    try {
      let user;
      
      // בדוק אם המשתמש כבר קיים
      try {
        user = await auth.getUserByEmail(demoUser.email);
        console.log(`   ℹ️  משתמש כבר קיים ב-Auth (UID: ${user.uid})`);
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // צור משתמש חדש
          user = await auth.createUser({
            email: demoUser.email,
            password: demoUser.password,
            displayName: demoUser.name,
            emailVerified: true,
          });
          console.log(`   ✅ משתמש נוצר ב-Auth (UID: ${user.uid})`);
        } else {
          throw error;
        }
      }
      
      // צור/עדכן רשומה ב-Firestore
      const now = admin.firestore.Timestamp.now();
      
      const userData = {
        id: user.uid,
        name: demoUser.name,
        email: demoUser.email,
        household_id: HOUSEHOLD_ID,
        joined_at: now,
        last_login_at: now,
        preferred_stores: ['שופרסל', 'רמי לוי', 'פארם'],
        favorite_products: [],
        weekly_budget: demoUser.role === 'אבא' || demoUser.role === 'אמא' ? 1500 : 0,
        is_admin: demoUser.role === 'אבא' || demoUser.role === 'אמא',
        profile_image_url: null,
      };
      
      await db.collection('users').doc(user.uid).set(userData);
      console.log(`   ✅ רשומה נוצרה/עודכנה ב-Firestore`);
      
      createdUsers.push({
        name: demoUser.name,
        email: demoUser.email,
        uid: user.uid,
        password: demoUser.password,
      });
      
      console.log('');
      
    } catch (error) {
      console.log(`   ❌ שגיאה: ${error.message}`);
      console.log('');
    }
  }
  
  // מחיקת רשומות ישנות (אם קיימות)
  console.log('🧹 מנקה רשומות ישנות...');
  const oldIds = ['danny_demo_user', 'sarah_demo_user', 'yoni_demo_user'];
  
  for (const oldId of oldIds) {
    try {
      await db.collection('users').doc(oldId).delete();
      console.log(`   ❌ נמחק: ${oldId}`);
    } catch (e) {
      // לא נורא אם לא קיים
    }
  }
  
  console.log('');
  console.log('🎉 ========================================');
  console.log('✅ משתמשי דמו נוצרו בהצלחה!');
  console.log('🎉 ========================================');
  console.log('');
  console.log('📋 פרטי התחברות:');
  console.log('');
  
  createdUsers.forEach((user, index) => {
    console.log(`${index + 1}. ${user.name}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Password: ${user.password}`);
    console.log(`   UID: ${user.uid}`);
    console.log('');
  });
  
  console.log('🚀 עכשיו אפשר להריץ:');
  console.log('   node scripts/generate_demo_data.js');
  console.log('');
  console.log('   (אל תשכח לעדכן את ה-UIDs בקובץ generate_demo_data.js!)');
  console.log('');
  console.log('📝 UIDs לעדכן ב-generate_demo_data.js:');
  console.log('');
  createdUsers.forEach(user => {
    const varName = user.email.split('@')[0].toUpperCase();
    console.log(`uid: '${user.uid}', // ${user.email}`);
  });
  
  process.exit(0);
}

createDemoUsers();
