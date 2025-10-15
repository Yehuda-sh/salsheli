// 🔍 Script למציאת UIDs האמיתיים של משתמשי הדמו
// 
// שימוש:
// node scripts/find_demo_uids.js

const admin = require('firebase-admin');
const path = require('path');

// טעינת Service Account Key
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'salsheli',
});

const auth = admin.auth();

const demoEmails = [
  'avi.levi@demo.com',
  'michal.levi@demo.com',
  'tomer.levi@demo.com',
  'noam.levi@demo.com',
  'talia.levi@demo.com',
];

async function findDemoUIDs() {
  console.log('🔍 מחפש UIDs של משתמשי דמו...');
  console.log('');
  
  const results = [];
  
  for (const email of demoEmails) {
    try {
      const user = await auth.getUserByEmail(email);
      
      console.log(`✅ ${email}`);
      console.log(`   UID: ${user.uid}`);
      console.log(`   Display Name: ${user.displayName || '(ריק)'}`);
      console.log('');
      
      results.push({
        email: email,
        uid: user.uid,
        displayName: user.displayName
      });
    } catch (error) {
      console.log(`❌ ${email} - לא נמצא!`);
      console.log('');
    }
  }
  
  console.log('📋 סיכום:');
  console.log(JSON.stringify(results, null, 2));
  console.log('');
  console.log('📝 העתק את ה-UIDs האלה ל-Script הבא!');
  
  process.exit(0);
}

findDemoUIDs();
