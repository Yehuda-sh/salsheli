// 🔍 Script למציאת כל המשתמשים ב-Firebase Auth
// 
// שימוש:
// node scripts/list_all_users.js

const admin = require('firebase-admin');
const path = require('path');

// טעינת Service Account Key
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'salsheli',
});

async function listAllUsers() {
  console.log('🔍 מחפש את כל המשתמשים ב-Firebase Auth...');
  console.log('');
  
  try {
    const listUsersResult = await admin.auth().listUsers(100);
    
    if (listUsersResult.users.length === 0) {
      console.log('❌ אין משתמשים ב-Firebase Authentication!');
      console.log('');
      console.log('💡 פתרון: צור משתמשים חדשים עם Firebase Console או Script');
      return;
    }
    
    console.log(`✅ נמצאו ${listUsersResult.users.length} משתמשים:`);
    console.log('');
    
    const users = [];
    
    listUsersResult.users.forEach((user, index) => {
      console.log(`${index + 1}. ${user.email || '(אין אימייל)'}`);
      console.log(`   UID: ${user.uid}`);
      console.log(`   Display Name: ${user.displayName || '(ריק)'}`);
      console.log(`   Created: ${user.metadata.creationTime}`);
      console.log(`   Last Sign In: ${user.metadata.lastSignInTime || '(מעולם לא התחבר)'}`);
      console.log('');
      
      users.push({
        email: user.email,
        uid: user.uid,
        displayName: user.displayName,
      });
    });
    
    console.log('📋 JSON לשימוש ב-Script:');
    console.log(JSON.stringify(users, null, 2));
    
  } catch (error) {
    console.error('❌ שגיאה:', error.message);
  }
  
  process.exit(0);
}

listAllUsers();
