// 📄 download_products.js
// הורדת מוצרים מה-API לקובץ JSON

const https = require('https');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'https://url.publishedprices.co.il';
const USERNAME = 'RamiLevi';
const PASSWORD = '';

// מוצרים דמה - 100 מוצרים בקטגוריות שונות
const DEMO_PRODUCTS = [
  // מוצרי חלב
  { barcode: '7290000000001', name: 'חלב 3%', category: 'מוצרי חלב', brand: 'תנובה', unit: 'ליטר', icon: '🥛', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000002', name: 'חלב 1%', category: 'מוצרי חלב', brand: 'תנובה', unit: 'ליטר', icon: '🥛', price: 7.5, store: 'רמי לוי' },
  { barcode: '7290000000003', name: 'חלב ללא לקטוז', category: 'מוצרי חלב', brand: 'יוטבתה', unit: 'ליטר', icon: '🥛', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000020', name: 'גבינה צהובה', category: 'מוצרי חלב', brand: 'תנובה', unit: '200 גרם', icon: '🧀', price: 15.2, store: 'רמי לוי' },
  { barcode: '7290000000021', name: 'גבינה לבנה 5%', category: 'מוצרי חלב', brand: 'תנובה', unit: '250 גרם', icon: '🧀', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000022', name: 'גבינת קוטג\'', category: 'מוצרי חלב', brand: 'תנובה', unit: '250 גרם', icon: '🧀', price: 8.5, store: 'רמי לוי' },
  { barcode: '7290000000023', name: 'יוגורט טבעי', category: 'מוצרי חלב', brand: 'דנונה', unit: '500 גרם', icon: '🥛', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000024', name: 'שמנת מתוקה', category: 'מוצרי חלב', brand: 'תנובה', unit: '250 מ"ל', icon: '🥛', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000025', name: 'חמאה', category: 'מוצרי חלב', brand: 'תנובה', unit: '200 גרם', icon: '🧈', price: 10.9, store: 'רמי לוי' },
  { barcode: '7290000000100', name: 'ביצים', category: 'מוצרי חלב', brand: 'גל', unit: '12 יחידות', icon: '🥚', price: 16.9, store: 'רמי לוי' },
  
  // מאפים
  { barcode: '7290000000010', name: 'לחם שחור', category: 'מאפים', brand: 'אנג\'ל', unit: 'יחידה', icon: '🍞', price: 8.5, store: 'רמי לוי' },
  { barcode: '7290000000011', name: 'לחם לבן', category: 'מאפים', brand: 'אנג\'ל', unit: 'יחידה', icon: '🍞', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000012', name: 'חלה', category: 'מאפים', brand: 'אנג\'ל', unit: 'יחידה', icon: '🍞', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000013', name: 'בורקס גבינה', category: 'מאפים', brand: 'אנג\'ל', unit: '4 יחידות', icon: '🥐', price: 18.9, store: 'רמי לוי' },
  { barcode: '7290000000014', name: 'רוגלך', category: 'מאפים', brand: 'אנג\'ל', unit: '6 יחידות', icon: '🥐', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000015', name: 'לחמניות המבורגר', category: 'מאפים', brand: 'אנג\'ל', unit: '8 יחידות', icon: '🍔', price: 10.9, store: 'רמי לוי' },
  
  // ירקות
  { barcode: '7290000000030', name: 'עגבניות', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🍅', price: 5.4, store: 'רמי לוי' },
  { barcode: '7290000000040', name: 'מלפפון', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🥒', price: 4.2, store: 'רמי לוי' },
  { barcode: '7290000000041', name: 'פלפל אדום', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🫑', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000042', name: 'חסה', category: 'ירקות', brand: 'מקומי', unit: 'יחידה', icon: '🥬', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000043', name: 'גזר', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🥕', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000044', name: 'בצל', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🧅', price: 2.9, store: 'רמי לוי' },
  { barcode: '7290000000045', name: 'שום', category: 'ירקות', brand: 'מקומי', unit: '200 גרם', icon: '🧄', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000046', name: 'תפוח אדמה', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🥔', price: 3.5, store: 'רמי לוי' },
  { barcode: '7290000000047', name: 'בטטה', category: 'ירקות', brand: 'מקומי', unit: 'ק"ג', icon: '🍠', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000048', name: 'ברוקולי', category: 'ירקות', brand: 'מקומי', unit: 'יחידה', icon: '🥦', price: 7.9, store: 'רמי לוי' },
  
  // פירות
  { barcode: '7290000000051', name: 'בננה', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍌', price: 6.5, store: 'רמי לוי' },
  { barcode: '7290000000060', name: 'תפוח עץ', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍎', price: 7.8, store: 'רמי לוי' },
  { barcode: '7290000000061', name: 'תפוז', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍊', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000062', name: 'אגס', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍐', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000063', name: 'ענבים', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍇', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000064', name: 'אבטיח', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍉', price: 2.9, store: 'רמי לוי' },
  { barcode: '7290000000065', name: 'מלון', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍈', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000066', name: 'תותים', category: 'פירות', brand: 'מקומי', unit: '250 גרם', icon: '🍓', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000067', name: 'אננס', category: 'פירות', brand: 'מקומי', unit: 'יחידה', icon: '🍍', price: 15.9, store: 'רמי לוי' },
  { barcode: '7290000000068', name: 'קלמנטינות', category: 'פירות', brand: 'מקומי', unit: 'ק"ג', icon: '🍊', price: 5.9, store: 'רמי לוי' },
  
  // בשר ודגים
  { barcode: '7290000000110', name: 'עוף שלם', category: 'בשר ודגים', brand: 'אוף טוב', unit: 'ק"ג', icon: '🍗', price: 24.9, store: 'רמי לוי' },
  { barcode: '7290000000111', name: 'חזה עוף', category: 'בשר ודגים', brand: 'אוף טוב', unit: 'ק"ג', icon: '🍗', price: 32.9, store: 'רמי לוי' },
  { barcode: '7290000000112', name: 'שניצל עוף', category: 'בשר ודגים', brand: 'אוף טוב', unit: 'ק"ג', icon: '🍗', price: 38.9, store: 'רמי לוי' },
  { barcode: '7290000000113', name: 'כרעיים עוף', category: 'בשר ודגים', brand: 'אוף טוב', unit: 'ק"ג', icon: '🍗', price: 18.9, store: 'רמי לוי' },
  { barcode: '7290000000114', name: 'בשר טחון', category: 'בשר ודגים', brand: 'טיב טעם', unit: 'ק"ג', icon: '🥩', price: 42.9, store: 'רמי לוי' },
  { barcode: '7290000000115', name: 'נקניקיות', category: 'בשר ודגים', brand: 'טיב טעם', unit: '400 גרם', icon: '🌭', price: 16.9, store: 'רמי לוי' },
  { barcode: '7290000000116', name: 'פילה סלמון', category: 'בשר ודגים', brand: 'דגי הים', unit: 'ק"ג', icon: '🐟', price: 89.9, store: 'רמי לוי' },
  { barcode: '7290000000117', name: 'טונה בשמן', category: 'בשר ודגים', brand: 'סטארקיסט', unit: '160 גרם', icon: '🐟', price: 8.9, store: 'רמי לוי' },
  
  // אורז ופסטה
  { barcode: '7290000000080', name: 'אורז לבן', category: 'אורז ופסטה', brand: 'סוגת', unit: '1 ק"ג', icon: '🍚', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000081', name: 'אורז מלא', category: 'אורז ופסטה', brand: 'סוגת', unit: '1 ק"ג', icon: '🍚', price: 10.9, store: 'רמי לוי' },
  { barcode: '7290000000082', name: 'אורז בסמטי', category: 'אורז ופסטה', brand: 'סוגת', unit: '1 ק"ג', icon: '🍚', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000090', name: 'פסטה ספגטי', category: 'אורז ופסטה', brand: 'אוסם', unit: '500 גרם', icon: '🍝', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000091', name: 'פסטה פנה', category: 'אורז ופסטה', brand: 'אוסם', unit: '500 גרם', icon: '🍝', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000092', name: 'קוסקוס', category: 'אורז ופסטה', brand: 'אוסם', unit: '500 גרם', icon: '🍚', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000093', name: 'נודלס', category: 'אורז ופסטה', brand: 'אוסם', unit: '400 גרם', icon: '🍜', price: 4.9, store: 'רמי לוי' },
  
  // שמנים ורטבים
  { barcode: '7290000000070', name: 'שמן זית', category: 'שמנים ורטבים', brand: 'עין זית', unit: '1 ליטר', icon: '🫗', price: 32.9, store: 'רמי לוי' },
  { barcode: '7290000000071', name: 'שמן קנולה', category: 'שמנים ורטבים', brand: 'עין זית', unit: '1 ליטר', icon: '🫗', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000120', name: 'קטשופ', category: 'שמנים ורטבים', brand: 'היינץ', unit: '570 גרם', icon: '🍅', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000130', name: 'מיונז', category: 'שמנים ורטבים', brand: 'הלמן\'ס', unit: '460 גרם', icon: '🥚', price: 11.9, store: 'רמי לוי' },
  { barcode: '7290000000131', name: 'חומוס', category: 'שמנים ורטבים', brand: 'אחלה', unit: '400 גרם', icon: '🧆', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000132', name: 'טחינה', category: 'שמנים ורטבים', brand: 'אל ארז', unit: '500 גרם', icon: '🥜', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000133', name: 'חרדל', category: 'שמנים ורטבים', brand: 'היינץ', unit: '225 גרם', icon: '🌭', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000134', name: 'רוטב עגבניות', category: 'שמנים ורטבים', brand: 'פריגו', unit: '400 גרם', icon: '🍅', price: 5.9, store: 'רמי לוי' },
  
  // תבלינים ואפייה
  { barcode: '7290000000170', name: 'קמח לבן', category: 'תבלינים ואפייה', brand: 'שופרסל', unit: '1 ק"ג', icon: '🌾', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000171', name: 'קמח מלא', category: 'תבלינים ואפייה', brand: 'שופרסל', unit: '1 ק"ג', icon: '🌾', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000180', name: 'סוכר לבן', category: 'תבלינים ואפייה', brand: 'סוכרזית', unit: '1 ק"ג', icon: '🧂', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000181', name: 'סוכר חום', category: 'תבלינים ואפייה', brand: 'סוכרזית', unit: '500 גרם', icon: '🧂', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000190', name: 'מלח ים', category: 'תבלינים ואפייה', brand: 'ים המלח', unit: '500 גרם', icon: '🧂', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000191', name: 'פלפל שחור', category: 'תבלינים ואפייה', brand: 'פרישמן', unit: '50 גרם', icon: '🧂', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000192', name: 'פפריקה', category: 'תבלינים ואפייה', brand: 'פרישמן', unit: '50 גרם', icon: '🧂', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000193', name: 'כורכום', category: 'תבלינים ואפייה', brand: 'פרישמן', unit: '50 גרם', icon: '🧂', price: 7.9, store: 'רמי לוי' },
  { barcode: '7290000000194', name: 'שמרים', category: 'תבלינים ואפייה', brand: 'פאף', unit: '100 גרם', icon: '🍞', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000195', name: 'אבקת אפייה', category: 'תבלינים ואפייה', brand: 'שופרסל', unit: '100 גרם', icon: '🍰', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000196', name: 'וניל', category: 'תבלינים ואפייה', brand: 'פרישמן', unit: '10 גרם', icon: '🌿', price: 5.9, store: 'רמי לוי' },
  
  // ממתקים וחטיפים
  { barcode: '7290000000140', name: 'שוקולד מריר', category: 'ממתקים וחטיפים', brand: 'פרה', unit: '100 גרם', icon: '🍫', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000141', name: 'שוקולד חלב', category: 'ממתקים וחטיפים', brand: 'פרה', unit: '100 גרם', icon: '🍫', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000142', name: 'קליק', category: 'ממתקים וחטיפים', brand: 'עלית', unit: '40 גרם', icon: '🍫', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000143', name: 'ביסלי גריל', category: 'ממתקים וחטיפים', brand: 'אוסם', unit: '70 גרם', icon: '🥨', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000144', name: 'במבה', category: 'ממתקים וחטיפים', brand: 'אוסם', unit: '80 גרם', icon: '🥜', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000145', name: 'צ\'יפס טבעי', category: 'ממתקים וחטיפים', brand: 'לייז', unit: '170 גרם', icon: '🥔', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000146', name: 'עוגיות אוראו', category: 'ממתקים וחטיפים', brand: 'אוראו', unit: '176 גרם', icon: '🍪', price: 10.9, store: 'רמי לוי' },
  { barcode: '7290000000147', name: 'וופלים', category: 'ממתקים וחטיפים', brand: 'לוקר', unit: '250 גרם', icon: '🍪', price: 12.9, store: 'רמי לוי' },
  
  // משקאות
  { barcode: '7290000000150', name: 'קוקה קולה', category: 'משקאות', brand: 'קוקה קולה', unit: '1.5 ליטר', icon: '🥤', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000151', name: 'קוקה זירו', category: 'משקאות', brand: 'קוקה קולה', unit: '1.5 ליטר', icon: '🥤', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000152', name: 'ספרייט', category: 'משקאות', brand: 'קוקה קולה', unit: '1.5 ליטר', icon: '🥤', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000160', name: 'מיץ תפוזים', category: 'משקאות', brand: 'פריגת', unit: '1 ליטר', icon: '🍊', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000161', name: 'מיץ תפוחים', category: 'משקאות', brand: 'פריגת', unit: '1 ליטר', icon: '🍎', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000162', name: 'מים מינרלים', category: 'משקאות', brand: 'נביעות', unit: '1.5 ליטר', icon: '💧', price: 3.9, store: 'רמי לוי' },
  { barcode: '7290000000163', name: 'מים מוגזים', category: 'משקאות', brand: 'נביעות', unit: '1.5 ליטר', icon: '💧', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000164', name: 'בירה גולדסטאר', category: 'משקאות', brand: 'טמפו', unit: '330 מ"ל', icon: '🍺', price: 4.9, store: 'רמי לוי' },
  { barcode: '7290000000165', name: 'קפה נמס', category: 'משקאות', brand: 'עלית', unit: '200 גרם', icon: '☕', price: 22.9, store: 'רמי לוי' },
  { barcode: '7290000000166', name: 'תה שחור', category: 'משקאות', brand: 'ויסוצקי', unit: '100 שקיות', icon: '🍵', price: 15.9, store: 'רמי לוי' },
  
  // מוצרי ניקיון
  { barcode: '7290000000200', name: 'סבון כלים', category: 'מוצרי ניקיון', brand: 'פיירי', unit: '750 מ"ל', icon: '🧼', price: 8.9, store: 'רמי לוי' },
  { barcode: '7290000000201', name: 'נוזל כביסה', category: 'מוצרי ניקיון', brand: 'אריאל', unit: '2 ליטר', icon: '🧴', price: 34.9, store: 'רמי לוי' },
  { barcode: '7290000000202', name: 'מרכך כביסה', category: 'מוצרי ניקיון', brand: 'לנור', unit: '2 ליטר', icon: '🧴', price: 19.9, store: 'רמי לוי' },
  { barcode: '7290000000203', name: 'אקונומיקה', category: 'מוצרי ניקיון', brand: 'סנו', unit: '1 ליטר', icon: '🧴', price: 5.9, store: 'רמי לוי' },
  { barcode: '7290000000204', name: 'אסלטון', category: 'מוצרי ניקיון', brand: 'סנו', unit: '750 מ"ל', icon: '🧴', price: 6.9, store: 'רמי לוי' },
  { barcode: '7290000000205', name: 'ניר טואלט', category: 'מוצרי ניקיון', brand: 'סופט', unit: '24 גלילים', icon: '🧻', price: 39.9, store: 'רמי לוי' },
  { barcode: '7290000000206', name: 'מגבות נייר', category: 'מוצרי ניקיון', brand: 'סופט', unit: '8 גלילים', icon: '🧻', price: 24.9, store: 'רמי לוי' },
  { barcode: '7290000000207', name: 'שקיות אשפה', category: 'מוצרי ניקיון', brand: 'סופר בלו', unit: '50 יחידות', icon: '🗑️', price: 12.9, store: 'רמי לוי' },
  
  // היגיינה אישית
  { barcode: '7290000000210', name: 'סבון רחצה', category: 'היגיינה אישית', brand: 'דאב', unit: '4 יחידות', icon: '🧼', price: 16.9, store: 'רמי לוי' },
  { barcode: '7290000000211', name: 'שמפו', category: 'היגיינה אישית', brand: 'הד אנד שולדרס', unit: '400 מ"ל', icon: '🧴', price: 18.9, store: 'רמי לוי' },
  { barcode: '7290000000212', name: 'מרכך שיער', category: 'היגיינה אישית', brand: 'הד אנד שולדרס', unit: '400 מ"ל', icon: '🧴', price: 18.9, store: 'רמי לוי' },
  { barcode: '7290000000213', name: 'משחת שיניים', category: 'היגיינה אישית', brand: 'קולגייט', unit: '100 מ"ל', icon: '🦷', price: 9.9, store: 'רמי לוי' },
  { barcode: '7290000000214', name: 'מברשת שיניים', category: 'היגיינה אישית', brand: 'קולגייט', unit: '2 יחידות', icon: '🪥', price: 12.9, store: 'רמי לוי' },
  { barcode: '7290000000215', name: 'דאודורנט', category: 'היגיינה אישית', brand: 'אקס', unit: '150 מ"ל', icon: '🧴', price: 14.9, store: 'רמי לוי' },
];

console.log('🚀 מתחיל הורדת מוצרים...\n');
console.log('⚠️  זה יכול לקחת מספר דקות\n');

// משתמש במוצרים דמה (API לא זמין מחוץ לישראל)
console.log(`📦 משתמש במוצרים דמה (${DEMO_PRODUCTS.length} מוצרים)\n`);

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
console.log('🔥 עכשיו העלה את הקובץ ל-Firestore:');
console.log('   cd C:\\projects\\salsheli\\scripts');
console.log('   npm run upload');
