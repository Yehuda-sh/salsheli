// 📄 upload_to_firebase.js
// העלאת הקובץ products.json ל-Firestore

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// אתחול Firebase Admin
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadProducts() {
  try {
    console.log('🚀 מתחיל העלאה ל-Firestore...\n');

    // קריאת הקובץ
    const filePath = path.join(__dirname, 'products.json');
    if (!fs.existsSync(filePath)) {
      console.error('❌ הקובץ products.json לא נמצא!');
      console.log('הרץ קודם: node download_products.js');
      process.exit(1);
    }

    const rawData = fs.readFileSync(filePath, 'utf8');
    const data = JSON.parse(rawData);
    
    console.log(`📦 נמצאו ${data.count} מוצרים`);
    console.log(`📅 תאריך יצירה: ${data.generated}\n`);

    // העלאה בבאצ'ים (500 בכל פעם)
    const products = data.products;
    const batchSize = 500;
    let uploaded = 0;

    for (let i = 0; i < products.length; i += batchSize) {
      const batch = db.batch();
      const chunk = products.slice(i, Math.min(i + batchSize, products.length));

      for (const product of chunk) {
        const docRef = db.collection('products').doc(product.barcode);
        batch.set(docRef, {
          ...product,
          lastUpdate: admin.firestore.FieldValue.serverTimestamp()
        });
        uploaded++;
      }

      await batch.commit();
      console.log(`   📤 הועלו ${uploaded} / ${products.length} מוצרים...`);
    }

    console.log(`\n✅ הצלחה! הועלו ${uploaded} מוצרים ל-Firestore`);
    process.exit(0);

  } catch (error) {
    console.error('\n❌ שגיאה:', error.message);
    process.exit(1);
  }
}

uploadProducts();
