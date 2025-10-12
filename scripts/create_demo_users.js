#!/usr/bin/env node

// 📄 File: scripts/create_demo_users.js
// תיאור: Script ליצירת 3 משתמשי דמו ב-Firebase Authentication + Firestore
//
// מה הסקריפט יוצר:
// ✅ 3 משתמשים ב-Firebase Auth (yoni, sarah, danny)
// ✅ 3 רשומות משתמש ב-Firestore (collection: users)
// ✅ כולם משוייכים ל-household_id: 'house_demo'
//
// שימוש:
//   1. ודא ש-firebase-service-account.json קיים ב-scripts/
//   2. הרץ: node scripts/create_demo_users.js
//   או:  npm run create-users

const admin = require('firebase-admin');
const path = require('path');

// ======== הגדרות ========

const serviceAccountPath = path.join(__dirname, 'firebase-service-account.json');

const DEMO_USERS = [
  {
    email: 'yoni@demo.com',
    password: 'Demo123!',
    displayName: 'יוני',
    uid: 'yoni_demo_user',
  },
  {
    email: 'sarah@demo.com',
    password: 'Demo123!',
    displayName: 'שרה',
    uid: 'sarah_demo_user',
  },
  {
    email: 'danny@demo.com',
    password: 'Demo123!',
    displayName: 'דני',
    uid: 'danny_demo_user',
  },
];

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
  console.error('\n📝 Instructions:');
  console.error('   1. Go to Firebase Console');
  console.error('   2. Project Settings → Service Accounts');
  console.error('   3. Generate new private key');
  console.error('   4. Save as: scripts/firebase-service-account.json');
  console.error('   5. Run: npm run create-users\n');
  process.exit(1);
}

// ======== פונקציות עזר ========

/**
 * יוצר משתמש ב-Firebase Auth
 */
async function createUser(userData) {
  const { email, password, displayName, uid } = userData;
  
  console.log(`📝 Creating user: ${displayName} (${email})`);
  
  try {
    // בדיקה אם המשתמש כבר קיים
    try {
      const existingUser = await admin.auth().getUserByEmail(email);
      console.log(`   ⚠️  User already exists with UID: ${existingUser.uid}`);
      
      // עדכון המשתמש הקיים
      await admin.auth().updateUser(existingUser.uid, {
        password: password,
        displayName: displayName,
      });
      
      console.log(`   ✅ Updated existing user`);
      return existingUser;
    } catch (error) {
      if (error.code !== 'auth/user-not-found') {
        throw error;
      }
    }
    
    // יצירת משתמש חדש
    const newUser = await admin.auth().createUser({
      uid: uid,
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: true, // אימות אוטומטי לדמו
    });
    
    console.log(`   ✅ Created new user with UID: ${newUser.uid}`);
    return newUser;
  } catch (error) {
    console.error(`   ❌ Failed to create user: ${error.message}`);
    throw error;
  }
}

/**
 * יוצר רשומת משתמש ב-Firestore
 * 
 * ⚠️ חשוב: המבנה חייב לתאום ל-UserEntity model!
 * ראה: lib/models/user_entity.dart
 */
async function createFirestoreUser(authUser, displayName) {
  const userId = authUser.uid;
  
  console.log(`💾 Creating Firestore document for: ${displayName}`);
  
  try {
    // ✅ מבנה תואם ל-UserEntity
    const userDoc = {
      id: userId,
      email: authUser.email,
      name: displayName,
      household_id: 'house_demo',  // ✅ snake_case
      profile_image_url: null,     // ✅ תואם למודל
      joined_at: admin.firestore.FieldValue.serverTimestamp(),
      last_login_at: admin.firestore.FieldValue.serverTimestamp(),
      preferred_stores: [],        // ✅ default value
      favorite_products: [],       // ✅ default value
      weekly_budget: 0.0,          // ✅ default value
      is_admin: true,              // ✅ משתמש ראשון = admin
    };
    
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .set(userDoc, { merge: true });
    
    console.log(`   ✅ Firestore document created`);
  } catch (error) {
    console.error(`   ❌ Failed to create Firestore document: ${error.message}`);
    throw error;
  }
}

// ======== Main ========

async function main() {
  console.log('🚀 Starting demo users creation...\n');
  console.log('═══════════════════════════════════════════\n');
  
  let successCount = 0;
  let failCount = 0;
  
  for (const userData of DEMO_USERS) {
    try {
      // יצירת משתמש ב-Auth
      const authUser = await createUser(userData);
      
      // יצירת רשומה ב-Firestore
      await createFirestoreUser(authUser, userData.displayName);
      
      console.log(`✅ Successfully created: ${userData.displayName}\n`);
      successCount++;
    } catch (error) {
      console.error(`❌ Failed to create: ${userData.displayName}\n`);
      failCount++;
    }
  }
  
  console.log('═══════════════════════════════════════════\n');
  console.log('📊 Summary:');
  console.log(`   ✅ Success: ${successCount}`);
  console.log(`   ❌ Failed: ${failCount}`);
  console.log(`   📝 Total: ${DEMO_USERS.length}\n`);
  
  if (successCount === DEMO_USERS.length) {
    console.log('🎉 All demo users created successfully!\n');
    console.log('You can now login with:');
    DEMO_USERS.forEach(user => {
      console.log(`   • ${user.displayName}: ${user.email} / ${user.password}`);
    });
    console.log();
  } else {
    console.log('⚠️  Some users failed to create. Check the logs above.\n');
  }
  
  process.exit(successCount === DEMO_USERS.length ? 0 : 1);
}

// הרצה
main().catch(error => {
  console.error('\n❌ Fatal error:', error);
  process.exit(1);
});
