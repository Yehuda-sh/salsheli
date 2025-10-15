// ✨ Script ליצירת משפחת דמו מלאה ב-Firebase Auth + Firestore
// 
// שימוש:
// node scripts/create_demo_family.js

const admin = require('firebase-admin');
const path = require('path');

// טעינת Service Account Key
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'salsheli',
});

const auth = admin.auth();
const db = admin.firestore();

const LEVI_FAMILY = [
  {
    email: 'avi.levi@demo.com',
    password: 'Demo2025!',
    name: 'אבי לוי',
    role: 'אבא',
    age: 38,
    isAdmin: true,
  },
  {
    email: 'michal.levi@demo.com',
    password: 'Demo2025!',
    name: 'מיכל לוי',
    role: 'אמא',
    age: 36,
    isAdmin: true,
  },
  {
    email: 'tomer.levi@demo.com',
    password: 'Demo2025!',
    name: 'תומר לוי',
    role: 'בן',
    age: 14,
    isAdmin: false,
  },
  {
    email: 'noam.levi@demo.com',
    password: 'Demo2025!',
    name: 'נועם לוי',
    role: 'בן',
    age: 10,
    isAdmin: false,
  },
  {
    email: 'talia.levi@demo.com',
    password: 'Demo2025!',
    name: 'טליה לוי',
    role: 'בת',
    age: 7,
    isAdmin: false,
  },
];

const HOUSEHOLD_ID = 'house_levi_demo';

async function createLeviFamily() {
  console.log('✨ יוצר את משפחת לוי...');
  console.log('');
  
  const createdUsers = [];
  
  for (const member of LEVI_FAMILY) {
    console.log(`👤 מטפל ב-${member.name} (${member.email})...`);
    
    try {
      let user;
      
      // בדוק אם המשתמש כבר קיים
      try {
        user = await auth.getUserByEmail(member.email);
        console.log(`   ℹ️  משתמש כבר קיים ב-Auth (UID: ${user.uid})`);
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // צור משתמש חדש
          user = await auth.createUser({
            email: member.email,
            password: member.password,
            displayName: member.name,
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
        name: member.name,
        email: member.email,
        household_id: HOUSEHOLD_ID,
        joined_at: now,
        last_login_at: now,
        preferred_stores: ['שופרסל סיטי', 'רמי לוי', 'ויקטורי'],
        favorite_products: [],
        weekly_budget: member.isAdmin ? 2000 : 0,
        is_admin: member.isAdmin,
        profile_image_url: null,
      };
      
      await db.collection('users').doc(user.uid).set(userData);
      console.log(`   ✅ רשומה נוצרה ב-Firestore`);
      
      createdUsers.push({
        name: member.name,
        email: member.email,
        uid: user.uid,
        password: member.password,
        role: member.role,
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
  console.log('🎉 ================================================');
  console.log('✅ משפחת לוי נוצרה בהצלחה!');
  console.log('🎉 ================================================');
  console.log('');
  console.log('👨‍👩‍👧‍👦 פרטי המשפחה:');
  console.log('');
  
  createdUsers.forEach((user, index) => {
    console.log(`${index + 1}. ${user.name} (${user.role})`);
    console.log(`   📧 Email: ${user.email}`);
    console.log(`   🔐 Password: ${user.password}`);
    console.log(`   🆔 UID: ${user.uid}`);
    console.log('');
  });
  
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log('📝 UIDs לעדכן ב-generate_demo_data.js:');
  console.log('');
  console.log('const FAMILY_MEMBERS = [');
  createdUsers.forEach(user => {
    console.log(`  {`);
    console.log(`    uid: '${user.uid}',`);
    console.log(`    email: '${user.email}',`);
    console.log(`    name: '${user.name}',`);
    console.log(`    role: '${user.role}',`);
    console.log(`    isAdmin: ${user.role === 'אבא' || user.role === 'אמא'},`);
    console.log(`  },`);
  });
  console.log('];');
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log('🚀 השלבים הבאים:');
  console.log('');
  console.log('1️⃣  פתח את scripts/generate_demo_data.js');
  console.log('2️⃣  החלף את FAMILY_MEMBERS בקוד שלמעלה ↑');
  console.log('3️⃣  הרץ: node scripts/generate_demo_data.js');
  console.log('4️⃣  פתח את האפליקציה והתחבר!');
  console.log('');
  console.log('💡 כניסה מהירה: avi.levi@demo.com / Demo2025!');
  
  process.exit(0);
}

createLeviFamily();
