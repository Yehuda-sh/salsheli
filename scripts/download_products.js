// 📄 download_products.js
// הורדת מוצרים מה-API לקובץ JSON

const https = require('https');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'https://url.publishedprices.co.il';
const USERNAME = 'RamiLevi';
const PASSWORD = '';

// מוצרים דמה לבדיקה (במקרה שה-API לא עובד)
const DEMO_PRODUCTS = [
  { barcode: '7290000000001', name: 'חלב 3%', category: 'מוצרי חלב', brand: 'תנובה', unit: 'ליטר', icon: '🥛', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000010', name: 'לחם שחור', category: 'מאפים', brand: 'אנג\'ל', unit: 'יחידה', icon: '🍞', price: 8.5, store: 'רמי לוי' },
  { barcode: '7290000000020', name: 'גבינה צהובה', category: 'מוצרי חלב', brand: 'תנובה', unit: '200 גרם', icon: '🧀', price: 15.2, store: 'רמי לוי' },
  { barcode: '7290000000030', name: 'עגבניות', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🍅', price: 5.4, store: 'רמי לוי' },
  { barcode: '7290000000040', name: 'מלפפון', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🥒', price: 4.2, store: 'רמי לוי' },
  { barcode: '7290000000051', name: 'בננה', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍌', price: 6.5, store: 'רמי לוי' },
  { barcode: '7290000000060', name: 'תפוח עץ', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍎', price: 7.8, store: 'רמי לוי' },
  { barcode: '7290000000070', name: 'שמן זית', category: 'שמנים ורטבים', brand: 'עין זית', unit: '1 ליטר', icon: '🫗', price: 32.9, store: 'רמי לוי' },
  { barcode: '7290000000080', name: 'אורז לבן', category: 'אורז ופסטה', brand: 'סוגת', unit: '1 ק"ג', icon: '🍚', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000090', name: 'פסטה ספגטי', category: 'אורז ופסטה', brand: 'אוסם', unit: '500 גרם', icon: '🍝', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000100', name: 'בيצים', category: 'מוצרי חלב', brand: 'גל', unit: '12 יחידות', icon: '🥚', price: 16.9, store: 'רמי לוי' },
  { barcode: '7290000000110', name: 'עוף שלם', category: 'בשר ודגים', brand: 'אוף טוב', unit: 'ק"ג', icon: '🍗', price: 24.9, store: 'רמי לוי' },
  { barcode: '7290000000120', name: 'קטשופ', category: 'שמנים ורטבים', brand: 'היינץ', unit: '570 גרם', icon: '🍅', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000130', name: 'מיונז', category: 'שמנים ורטבים', brand: 'הלמן\'ס', unit: '460 גרם', icon: '🥚', price: 11.9, store: 'רמי לוי' },
  { barcode: '7290000000140', name: 'שוקולד מריר', category: 'ממתקים וחטיפים', brand: 'פרה', unit: '100 גרם', icon: '🍫', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000150', name: 'קוקה קולה', category: 'משקאות', brand: 'קוקה קולה', unit: '1.5 ליטר', icon: '🥤', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000160', name: 'מיץ תפוזים', category: 'משקאות', brand: 'פריגת', unit: '1 ליטר', icon: '🍊', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000170', name: 'קמח לבן', category: 'תבלינים ואפייה', brand: 'שופרסל', unit: '1 ק"ג', icon: '🌾', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000180', name: 'סוכר לבן', category: 'תבלינים ואפייה', brand: 'סוכרזית', unit: '1 ק"ג', icon: '🧂', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000190', name: 'מלח ים', category: 'תבלינים ואפייה', brand: 'ים המלח', unit: '500 גרם', icon: '🧂', price: 3.9, store: 'רמי לוי' },
];

console.log('🚀 מתחיל הורדת מוצרים...\n');
console.log('⚠️  זה יכול לקחת מספר דקות\n');

// משתמש במוצרים דמה (API לא זמין מחוץ לישראל)
console.log('📦 משתמש במוצרים דמה (20 מוצרים)\n');

const outputPath = path.join(__dirname, 'products.json');
const outputData = {
  generated: new Date().toISOString(),
  count: DEMO_PRODUCTS.length,
  products: DEMO_PRODUCTS
};

fs.writeFileSync(outputPath, JSON.stringify(outputData, null, 2), 'utf8');

console.log('✅ הצלחה!');
console.log(`📁 הקובץ נשמר ב: ${outputPath}`);
console.log(`📊 סה"כ מוצרים: ${DEMO_PRODUCTS.length}\n`);
console.log('🔥 עכשיו העלה את הקובץ ל-Firestore דרך Firebase Console');
