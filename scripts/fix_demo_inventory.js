#!/usr/bin/env node
/**
 * Fix demo inventory: move from /users/{userId}/inventory → /households/{householdId}/inventory
 * For users in shared households (Cohen, Levi), inventory should be at household level.
 * Personal users (Tomer, Shiran) keep their inventory under /users/{userId}/inventory.
 */

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// From create_demo_production.js
const uids = {
  avi: 'CkO3e7YZtBWulVIEy3uTzJIn0vI2',
  ronit: 'Rn2kF8YqPNXJ4mVLw9sTpKdE5hA3',
  yuval: 'Yv7nH3BxQcRe2jWfM8kLpDgS6tU1',
  noa: 'Na4pJ9CyTdSf3kXgN7mRqEvW8uI2',
  dan: 'Dn5qK0DzUeVg4lYhO8nSrFwX9vJ3',
  maya: 'Ma6rL1EaVfWh5mZiP9oTsGxY0wK4',
  tomer: 'Tm8tN3GcXhYj7oBkR1qVuIzA2xM5',
  shiran: 'Sh9uO4HdYiZk8pClS2rWvJaB3yN6',
  ori: 'Or0vP5IeZjAl9qDmT3sXwKbC4zO7',
  naama: 'Nm1wQ6JfAkBm0rEnU4tYxLcD5aP8',
  lior: 'Lr2xR7KgBlCn1sFoV5uZyMdE6bQ9',
};

const householdMapping = {
  // Cohen family → household_cohen
  [uids.avi]: 'household_cohen',
  // Levi family → household_levi  
  [uids.dan]: 'household_levi',
};

async function fixInventory() {
  for (const [userId, householdId] of Object.entries(householdMapping)) {
    console.log(`\n📦 Moving inventory: user ${userId} → household ${householdId}`);
    
    const userInvRef = db.collection('users').doc(userId).collection('inventory');
    const householdInvRef = db.collection('households').doc(householdId).collection('inventory');
    
    const snapshot = await userInvRef.get();
    
    if (snapshot.empty) {
      console.log(`   ⚠️ No inventory items found for user ${userId}`);
      continue;
    }
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      // Copy to household
      batch.set(householdInvRef.doc(doc.id), doc.data());
      // Delete from user
      batch.delete(userInvRef.doc(doc.id));
      count++;
    }
    
    await batch.commit();
    console.log(`   ✅ Moved ${count} items to ${householdId}`);
  }
  
  // Also handle enrich_demo_data items for Levi
  const enrichUsers = {
    [uids.dan]: 'household_levi',
    [uids.naama]: 'household_levi', // naama might be in levi household
  };
  
  for (const [userId, householdId] of Object.entries(enrichUsers)) {
    const userInvRef = db.collection('users').doc(userId).collection('inventory');
    const householdInvRef = db.collection('households').doc(householdId).collection('inventory');
    
    const snapshot = await userInvRef.get();
    if (snapshot.empty) continue;
    
    const batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
      batch.set(householdInvRef.doc(doc.id), doc.data());
      batch.delete(userInvRef.doc(doc.id));
      count++;
    }
    
    await batch.commit();
    if (count > 0) console.log(`   ✅ Also moved ${count} enriched items for ${userId}`);
  }
  
  console.log('\n🎉 Done! Inventory moved to household collections.');
  process.exit(0);
}

fixInventory().catch(e => {
  console.error('❌ Error:', e);
  process.exit(1);
});
