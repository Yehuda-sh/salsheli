// Creates demo users in the local Firebase Auth Emulator with matching UIDs
// Run: node scripts/create_emulator_users.js
// Requires: firebase Auth Emulator running on port 9099

process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

const admin = require('firebase-admin');
const sa = require('./firebase-service-account.json');

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}

const users = [
  { email: 'avi.cohen@demo.com', uid: 'CkO3e7YZtBWulVIEy3uTzJIn0vI2', name: 'אבי כהן' },
  { email: 'ronit.cohen@demo.com', uid: 'NsMtEn8CIaVLCxUukhj3eyzq0bE2', name: 'רונית כהן' },
  { email: 'yuval.cohen@demo.com', uid: 'pcwcVmjrjGcV6HLnfxpQiV7owIG3', name: 'יובל כהן' },
  { email: 'noa.cohen@demo.com', uid: 'WD6hvQUoOcMeX6XMIKOJeV7e5W13', name: 'נועה כהן' },
  { email: 'dan.levi@demo.com', uid: 'CJWc4vDZDEekNoZLkk7Zj22VTcM2', name: 'דן לוי' },
  { email: 'maya.levi@demo.com', uid: 'FB7UcpdC84WZCTRTyFeKTvn5miE3', name: 'מאיה לוי' },
  { email: 'tomer.bar@demo.com', uid: '5rVMvHeRXjMUkCWLEMiP8VCmDq53', name: 'תומר בר' },
  { email: 'shiran.gal@demo.com', uid: 'azvmDVSSbqds2NU37NrKG3IyiU52', name: 'שירן גל' },
];

async function main() {
  console.log('Creating 8 demo users in Auth Emulator...\n');

  for (const u of users) {
    try {
      await admin.auth().createUser({
        uid: u.uid,
        email: u.email,
        password: 'Demo123456!',
        displayName: u.name,
      });
      console.log(`✅ ${u.email} (${u.uid})`);
    } catch (e) {
      if (e.code === 'auth/uid-already-exists') {
        console.log(`⏭️  ${u.email} already exists`);
      } else {
        console.log(`❌ ${u.email}: ${e.message}`);
      }
    }
  }

  console.log('\n✅ Done!');
  process.exit(0);
}

main();
