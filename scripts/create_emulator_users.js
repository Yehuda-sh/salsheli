// Creates demo users in the local Firebase Auth Emulator
// Run: node scripts/create_emulator_users.js

const http = require('http');

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

async function createUser(u) {
  const data = JSON.stringify({
    email: u.email,
    password: 'Demo123456!',
    localId: u.uid,
    displayName: u.name,
  });

  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: '127.0.0.1',
      port: 9099,
      path: '/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    }, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`✅ ${u.email} (${u.uid})`);
        } else {
          console.log(`⚠️ ${u.email}: ${body.slice(0, 80)}`);
        }
        resolve();
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function main() {
  console.log('Creating 8 demo users in Auth Emulator...\n');
  for (const u of users) await createUser(u);
  console.log('\n✅ Done! Users ready for login.');
}

main();
