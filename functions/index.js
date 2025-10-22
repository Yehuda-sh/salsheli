const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ========================================
// הגדרת Templates
// ========================================

const SYSTEM_TEMPLATES = [
  {
    id: 'template_super',
    type: 'super_',
    name: 'סופרמרקט שבועי',
    description: 'רשימת קניות שבועית למשפחה',
    icon: '🛒',
    sortOrder: 1,
    defaultItems: [
      { name: 'חלב', category: 'מוצרי חלב', quantity: 2, unit: 'ליטר' },
      { name: 'לחם', category: 'מאפים', quantity: 1, unit: 'יח\'' },
      { name: 'ביצים', category: 'מוצרי חלב', quantity: 1, unit: 'קרטון' },
      { name: 'עגבניות', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'מלפפונים', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'בננות', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'עוף', category: 'בשר ודגים', quantity: 1, unit: 'ק"ג' },
      { name: 'אורז', category: 'אורז ופסטה', quantity: 1, unit: 'ק"ג' },
    ],
  },
  {
    id: 'template_pharmacy',
    type: 'pharmacy',
    name: 'בית מרקחת',
    description: 'תרופות ומוצרי טיפוח',
    icon: '💊',
    sortOrder: 2,
    defaultItems: [
      { name: 'תרופת כאב', category: 'תרופות', quantity: 1, unit: 'יח\'' },
      { name: 'ויטמין D', category: 'ויטמינים', quantity: 1, unit: 'יח\'' },
      { name: 'משחת שיניים', category: 'היגיינה אישית', quantity: 1, unit: 'יח\'' },
      { name: 'מברשת שיניים', category: 'היגיינה אישית', quantity: 2, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_hardware',
    type: 'hardware',
    name: 'חומרי בניין',
    description: 'כלים וחומרים לבית',
    icon: '🔨',
    sortOrder: 3,
    defaultItems: [
      { name: 'פטיש', category: 'כלים', quantity: 1, unit: 'יח\'' },
      { name: 'מברגים', category: 'כלים', quantity: 1, unit: 'סט' },
      { name: 'ברגים', category: 'חומרי בניין', quantity: 1, unit: 'קופסה' },
      { name: 'צבע לבן', category: 'צבעים', quantity: 1, unit: 'דלי' },
    ],
  },
  {
    id: 'template_clothing',
    type: 'clothing',
    name: 'ביגוד',
    description: 'בגדים והנעלה',
    icon: '👕',
    sortOrder: 4,
    defaultItems: [
      { name: 'חולצה', category: 'חולצות', quantity: 2, unit: 'יח\'' },
      { name: 'ג\'ינס', category: 'מכנסיים', quantity: 1, unit: 'יח\'' },
      { name: 'נעליים', category: 'הנעלה', quantity: 1, unit: 'זוג' },
      { name: 'גרביים', category: 'תחתונים וגרביים', quantity: 5, unit: 'זוג' },
    ],
  },
  {
    id: 'template_electronics',
    type: 'electronics',
    name: 'אלקטרוניקה',
    description: 'מוצרי חשמל וגאדג\'טים',
    icon: '💻',
    sortOrder: 5,
    defaultItems: [
      { name: 'אוזניות', category: 'אוזניות ורמקולים', quantity: 1, unit: 'יח\'' },
      { name: 'כבל USB', category: 'אביזרי אלקטרוניקה', quantity: 2, unit: 'יח\'' },
      { name: 'מטען', category: 'אביזרי אלקטרוניקה', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_pets',
    type: 'pets',
    name: 'חיות מחמד',
    description: 'מזון ואביזרים לחיות',
    icon: '🐕',
    sortOrder: 6,
    defaultItems: [
      { name: 'מזון לכלב', category: 'מזון לכלבים', quantity: 1, unit: 'שק' },
      { name: 'פינוקים', category: 'פינוקים לחיות', quantity: 1, unit: 'יח\'' },
      { name: 'צעצוע', category: 'צעצועים לחיות', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_cosmetics',
    type: 'cosmetics',
    name: 'קוסמטיקה',
    description: 'איפור וטיפוח',
    icon: '💄',
    sortOrder: 7,
    defaultItems: [
      { name: 'בסיס איפור', category: 'איפור פנים', quantity: 1, unit: 'יח\'' },
      { name: 'מסקרה', category: 'איפור פנים', quantity: 1, unit: 'יח\'' },
      { name: 'שפתון', category: 'איפור פנים', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_stationery',
    type: 'stationery',
    name: 'ציוד משרדי',
    description: 'מכתבים וציוד לימוד',
    icon: '📝',
    sortOrder: 8,
    defaultItems: [
      { name: 'עטים', category: 'כלי כתיבה', quantity: 10, unit: 'יח\'' },
      { name: 'מחברת', category: 'מחברות ודפי כתיבה', quantity: 3, unit: 'יח\'' },
      { name: 'מחק', category: 'כלי כתיבה', quantity: 2, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_toys',
    type: 'toys',
    name: 'צעצועים',
    description: 'משחקים וצעצועים לילדים',
    icon: '🧸',
    sortOrder: 9,
    defaultItems: [
      { name: 'פאזל', category: 'חידות ומשחקי חשיבה', quantity: 1, unit: 'יח\'' },
      { name: 'בובה', category: 'בובות ודמויות', quantity: 1, unit: 'יח\'' },
      { name: 'משחק קופסא', category: 'משחקי קופסה', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_books',
    type: 'books',
    name: 'ספרים',
    description: 'ספרות וחומרי קריאה',
    icon: '📚',
    sortOrder: 10,
    defaultItems: [
      { name: 'רומן', category: 'סיפורת', quantity: 1, unit: 'יח\'' },
      { name: 'ספר בישול', category: 'ספרי בישול', quantity: 1, unit: 'יח\'' },
      { name: 'ספר ילדים', category: 'ספרי ילדים', quantity: 2, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_sports',
    type: 'sports',
    name: 'ספורט',
    description: 'ציוד כושר ואימונים',
    icon: '⚽',
    sortOrder: 11,
    defaultItems: [
      { name: 'נעלי ריצה', category: 'נעלי ספורט', quantity: 1, unit: 'זוג' },
      { name: 'מזרן יוגה', category: 'מזרני יוגה', quantity: 1, unit: 'יח\'' },
      { name: 'בקבוק מים', category: 'אביזרי ריצה', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_home_decor',
    type: 'home_decor',
    name: 'עיצוב הבית',
    description: 'ריהוט ואביזרים לבית',
    icon: '🛋️',
    sortOrder: 12,
    defaultItems: [
      { name: 'כרית', category: 'כריות ושטיחים', quantity: 2, unit: 'יח\'' },
      { name: 'אגרטל', category: 'תמונות ומסגרות', quantity: 1, unit: 'יח\'' },
      { name: 'נר', category: 'נרות וריחות', quantity: 3, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_automotive',
    type: 'automotive',
    name: 'רכב',
    description: 'אביזרים ותחזוקה לרכב',
    icon: '🚗',
    sortOrder: 13,
    defaultItems: [
      { name: 'שמן מנוע', category: 'שמן מנוע', quantity: 1, unit: 'בקבוק' },
      { name: 'נוזל שמשות', category: 'נוזל שמשות', quantity: 1, unit: 'בקבוק' },
      { name: 'מטלית', category: 'ניקיון רכב', quantity: 2, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_baby',
    type: 'baby',
    name: 'תינוקות',
    description: 'מוצרים לתינוקות ופעוטות',
    icon: '👶',
    sortOrder: 14,
    defaultItems: [
      { name: 'חיתולים', category: 'חיתולים', quantity: 1, unit: 'חבילה' },
      { name: 'מגבונים', category: 'מגבונים', quantity: 2, unit: 'חבילה' },
      { name: 'בקבוק', category: 'בקבוקים ומוצצים', quantity: 2, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_gifts',
    type: 'gifts',
    name: 'מתנות',
    description: 'רעיונות למתנות',
    icon: '🎁',
    sortOrder: 15,
    defaultItems: [
      { name: 'שובר מתנה', category: 'שוברי מתנה', quantity: 1, unit: 'יח\'' },
      { name: 'נייר עטיפה', category: 'נייר עטיפה', quantity: 2, unit: 'גליון' },
      { name: 'כרטיס ברכה', category: 'כרטיסי ברכה', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_birthday',
    type: 'birthday',
    name: 'יום הולדת',
    description: 'הכנות לחגיגת יום הולדת',
    icon: '🎂',
    sortOrder: 16,
    defaultItems: [
      { name: 'עוגה', category: 'עוגת יום הולדת', quantity: 1, unit: 'יח\'' },
      { name: 'בלונים', category: 'בלונים', quantity: 20, unit: 'יח\'' },
      { name: 'נרות', category: 'נרות ליום הולדת', quantity: 1, unit: 'חבילה' },
      { name: 'כובעי מסיבה', category: 'כובעי מסיבה', quantity: 10, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_party',
    type: 'party',
    name: 'מסיבה',
    description: 'אירוח ובידור',
    icon: '🎉',
    sortOrder: 17,
    defaultItems: [
      { name: 'צ\'יפס', category: 'מזון למסיבה', quantity: 3, unit: 'שקית' },
      { name: 'שתייה קלה', category: 'שתייה קרה', quantity: 6, unit: 'בקבוק' },
      { name: 'כוסות חד-פעמיות', category: 'כוסות', quantity: 50, unit: 'יח\'' },
      { name: 'מפיות', category: 'מפיות', quantity: 2, unit: 'חבילה' },
    ],
  },
  {
    id: 'template_wedding',
    type: 'wedding',
    name: 'חתונה',
    description: 'תכנון אירוע חתונה',
    icon: '💒',
    sortOrder: 18,
    defaultItems: [
      { name: 'פרחים', category: 'פרחים', quantity: 1, unit: 'סידור' },
      { name: 'הזמנות', category: 'הזמנות', quantity: 100, unit: 'יח\'' },
      { name: 'מתנות לאורחים', category: 'מתנות לאורחים', quantity: 100, unit: 'יח\'' },
      { name: 'שמפניה', category: 'אלכוהול לחתונה', quantity: 10, unit: 'בקבוק' },
    ],
  },
  {
    id: 'template_picnic',
    type: 'picnic',
    name: 'פיקניק',
    description: 'טיול וארוחה בטבע',
    icon: '🧺',
    sortOrder: 19,
    defaultItems: [
      { name: 'כריכים', category: 'כריכים', quantity: 6, unit: 'יח\'' },
      { name: 'פירות', category: 'פירות', quantity: 1, unit: 'ק"ג' },
      { name: 'שמיכה', category: 'שמיכת פיקניק', quantity: 1, unit: 'יח\'' },
      { name: 'צידנית', category: 'צידנית', quantity: 1, unit: 'יח\'' },
    ],
  },
  {
    id: 'template_holiday',
    type: 'holiday',
    name: 'חג',
    description: 'הכנות לחג',
    icon: '🕎',
    sortOrder: 20,
    defaultItems: [
      { name: 'יין לקידוש', category: 'יין וקידוש', quantity: 1, unit: 'בקבוק' },
      { name: 'חלה', category: 'מזון לחג', quantity: 2, unit: 'יח\'' },
      { name: 'נרות', category: 'נרות', quantity: 2, unit: 'חבילה' },
    ],
  },
  {
    id: 'template_other',
    type: 'other',
    name: 'אחר',
    description: 'רשימה כללית',
    icon: '📋',
    sortOrder: 21,
    defaultItems: [],
  },
];

// ========================================
// Cloud Function - Initialize Templates
// ========================================

exports.initializeTemplates = functions.https.onRequest(async (req, res) => {
  try {
    console.log('🚀 Starting template initialization...');
    
    const db = admin.firestore();
    const batch = db.batch();
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    
    let count = 0;
    
    for (const template of SYSTEM_TEMPLATES) {
      const docRef = db.collection('templates').doc(template.id);
      
      batch.set(docRef, {
        id: template.id,
        type: template.type,
        name: template.name,
        description: template.description,
        icon: template.icon,
        default_format: 'shared',
        default_items: template.defaultItems,
        is_system: true,
        created_by: 'system',
        household_id: null,
        created_date: timestamp,
        updated_date: timestamp,
        sort_order: template.sortOrder,
      });
      
      count++;
      console.log(`✅ Added template: ${template.name} (${template.id})`);
    }
    
    await batch.commit();
    
    console.log(`🎉 Successfully created ${count} system templates!`);
    
    res.status(200).json({
      success: true,
      message: `Created ${count} system templates`,
      templates: SYSTEM_TEMPLATES.map(t => ({ id: t.id, name: t.name })),
    });
    
  } catch (error) {
    console.error('❌ Error initializing templates:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
