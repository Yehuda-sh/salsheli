// Migration: "super" → "supermarket"
// Run: node migrate_types.js

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrate() {
  console.log('🚀 Starting migration: "super" → "supermarket"');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    // Get all lists with type "super"
    const snapshot = await db.collection('shopping_lists')
      .where('type', '==', 'super')
      .get();

    console.log(`📊 Found ${snapshot.size} lists with type "super"`);
    console.log('');

    if (snapshot.empty) {
      console.log('✅ No lists to migrate. All done!');
      return;
    }

    // Update each list
    let successCount = 0;
    let errorCount = 0;
    const batch = db.batch();

    snapshot.forEach((doc) => {
      const data = doc.data();
      console.log(`🔄 Migrating: ${data.name || 'Unknown'} (ID: ${doc.id})`);
      
      batch.update(doc.ref, {
        type: 'supermarket',
        updated_date: admin.firestore.FieldValue.serverTimestamp()
      });
      
      successCount++;
    });

    // Commit batch
    await batch.commit();

    console.log('');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 Migration Summary:');
    console.log(`   ✅ Success: ${successCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📝 Total: ${snapshot.size}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('');
    console.log('🎉 Migration completed successfully!');

  } catch (error) {
    console.error('');
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

migrate();
