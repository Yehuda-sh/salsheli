// 📄 create_system_templates.js
//
// Purpose: יצירת תבניות מערכת (System Templates) ב-Firestore
// 
// תבניות מערכת זמינות לכל המשתמשים ומספקות נקודת התחלה לרשימות נפוצות.
// התבניות נוצרות עם is_system=true ו-default_format='shared'
//
// Run: npm run create-templates
//
// Version: 2.0 - מתוקן! (תואם ל-Template model)
// Last Updated: 11/10/2025
//

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// 📋 System Templates Data
const SYSTEM_TEMPLATES = [
  {
    id: 'system_weekly_super',
    name: 'סופרמרקט שבועי',
    description: 'קניות שבועיות בסיסיות למשפחה',
    icon: '🛒',
    type: 'super',
    default_format: 'shared',
    is_system: true,
    sort_order: 1,
    default_items: [
      { name: 'חלב 3% 1 ליטר', category: 'חלבי', quantity: 2, unit: 'יחידות' },
      { name: 'לחם פרוס', category: 'לחמים ומאפים', quantity: 2, unit: 'יחידות' },
      { name: 'ביצים', category: 'חלבי', quantity: 1, unit: 'מארז' },
      { name: 'גבינה צהובה', category: 'חלבי', quantity: 1, unit: 'אריזה' },
      { name: 'עגבניות', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'מלפפונים', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'תפוחים', category: 'פירות וירקות', quantity: 1, unit: 'ק"ג' },
      { name: 'בננות', category: 'פירות וירקות', quantity: 1, unit: 'קילו' },
      { name: 'שמן זית', category: 'שימורים', quantity: 1, unit: 'בקבוק' },
      { name: 'אורז', category: 'יבשים', quantity: 1, unit: 'קילו' },
      { name: 'פסטה', category: 'יבשים', quantity: 2, unit: 'אריזות' },
      { name: 'רוטב עגבניות', category: 'שימורים', quantity: 2, unit: 'יחידות' },
    ]
  },
  
  {
    id: 'system_pharmacy',
    name: 'בית מרקחת - ערכת עזרה ראשונה',
    description: 'פריטים בסיסיים לבית מרקחת',
    icon: '💊',
    type: 'pharmacy',
    default_format: 'shared',
    is_system: true,
    sort_order: 2,
    default_items: [
      { name: 'אקמול/אקמוליות', category: 'תרופות', quantity: 1, unit: 'אריזה' },
      { name: 'נורופן/אדוויל', category: 'תרופות', quantity: 1, unit: 'אריזה' },
      { name: 'פלסטרים', category: 'עזרה ראשונה', quantity: 1, unit: 'קופסה' },
      { name: 'גזה סטרילית', category: 'עזרה ראשונה', quantity: 1, unit: 'אריזה' },
      { name: 'תחבושת אלסטית', category: 'עזרה ראשונה', quantity: 1, unit: 'יחידה' },
      { name: 'מדחום', category: 'עזרה ראשונה', quantity: 1, unit: 'יחידה' },
      { name: 'משכך כאבים לילדים', category: 'תרופות', quantity: 1, unit: 'בקבוק' },
      { name: 'ויטמין C', category: 'תוספי תזונה', quantity: 1, unit: 'אריזה' },
      { name: 'טיפות אוזניים', category: 'תרופות', quantity: 1, unit: 'בקבוק' },
    ]
  },

  {
    id: 'system_birthday_party',
    name: 'יום הולדת - מסיבה ביתית',
    description: 'כל מה שצריך למסיבת יום הולדת מוצלחת',
    icon: '🎂',
    type: 'birthday',
    default_format: 'shared',
    is_system: true,
    sort_order: 3,
    default_items: [
      { name: 'עוגת יום הולדת', category: 'מאפים', quantity: 1, unit: 'יחידה' },
      { name: 'נרות יום הולדת', category: 'אירוח', quantity: 1, unit: 'חבילה' },
      { name: 'בלונים צבעוניים', category: 'קישוטים', quantity: 2, unit: 'חבילות' },
      { name: 'צלחות חד פעמי', category: 'אירוח', quantity: 1, unit: 'חבילה' },
      { name: 'כוסות חד פעמי', category: 'אירוח', quantity: 1, unit: 'חבילה' },
      { name: 'מפיות נייר', category: 'אירוח', quantity: 2, unit: 'חבילות' },
      { name: 'שתייה קלה 1.5 ליטר', category: 'משקאות', quantity: 3, unit: 'בקבוקים' },
      { name: 'מיץ טבעי', category: 'משקאות', quantity: 2, unit: 'בקבוקים' },
      { name: 'חטיפים מלוחים', category: 'חטיפים', quantity: 3, unit: 'שקיות' },
      { name: 'סוכריות וממתקים', category: 'חטיפים', quantity: 2, unit: 'שקיות' },
      { name: 'פיצה קפואה', category: 'מוקפא', quantity: 2, unit: 'יחידות' },
    ]
  },

  {
    id: 'system_weekend_hosting',
    name: 'אירוח סוף שבוע',
    description: 'רשימה לאירוח אורחים בסוף שבוע',
    icon: '🍷',
    type: 'hosting',
    default_format: 'shared',
    is_system: true,
    sort_order: 4,
    default_items: [
      { name: 'בשר/עוף טרי', category: 'בשר ועוף', quantity: 1.5, unit: 'ק"ג' },
      { name: 'ירקות לסלט', category: 'פירות וירקות', quantity: 1, unit: 'מארז' },
      { name: 'תפוחי אדמה', category: 'פירות וירקות', quantity: 2, unit: 'ק"ג' },
      { name: 'חלות', category: 'לחמים ומאפים', quantity: 2, unit: 'יחידות' },
      { name: 'יין אדום/לבן', category: 'אלכוהול', quantity: 2, unit: 'בקבוקים' },
      { name: 'מיצים ושתייה קלה', category: 'משקאות', quantity: 3, unit: 'בקבוקים' },
      { name: 'גבינות מגוונות', category: 'חלבי', quantity: 1, unit: 'מגש' },
      { name: 'קינוחים', category: 'מתוקים', quantity: 1, unit: 'מגש' },
      { name: 'פירות העונה', category: 'פירות וירקות', quantity: 2, unit: 'ק"ג' },
      { name: 'לחמניות/בגטים', category: 'לחמים ומאפים', quantity: 1, unit: 'שקית' },
      { name: 'חומוס', category: 'סלטים', quantity: 1, unit: 'קופסה' },
      { name: 'טחינה', category: 'סלטים', quantity: 1, unit: 'צנצנת' },
    ]
  },

  {
    id: 'system_game_night',
    name: 'ערב משחקים וצפייה',
    description: 'חטיפים ושתייה לערב משחקים או צפייה',
    icon: '🎮',
    type: 'party',
    default_format: 'shared',
    is_system: true,
    sort_order: 5,
    default_items: [
      { name: 'פופקורן', category: 'חטיפים', quantity: 2, unit: 'שקיות' },
      { name: 'צ\'יפס/במבה', category: 'חטיפים', quantity: 3, unit: 'שקיות' },
      { name: 'ביסלי', category: 'חטיפים', quantity: 2, unit: 'שקיות' },
      { name: 'בוטנים/קשיו', category: 'חטיפים', quantity: 1, unit: 'שקית' },
      { name: 'שוקולדים', category: 'מתוקים', quantity: 2, unit: 'חבילות' },
      { name: 'שתייה קלה 1.5 ליטר', category: 'משקאות', quantity: 3, unit: 'בקבוקים' },
      { name: 'בירה', category: 'אלכוהול', quantity: 6, unit: 'בקבוקים' },
      { name: 'מיץ טבעי', category: 'משקאות', quantity: 1, unit: 'בקבוק' },
      { name: 'מים מינרליים', category: 'משקאות', quantity: 2, unit: 'בקבוקים' },
      { name: 'פיצה קפואה', category: 'מוקפא', quantity: 2, unit: 'יחידות' },
    ]
  },

  {
    id: 'system_camping',
    name: 'קמפינג/טיול',
    description: 'פריטים לטיול או קמפינג משפחתי',
    icon: '🏕️',
    type: 'picnic',
    default_format: 'shared',
    is_system: true,
    sort_order: 6,
    default_items: [
      { name: 'מים בקבוקים', category: 'משקאות', quantity: 6, unit: 'בקבוקים' },
      { name: 'לחם פרוס/לחמניות', category: 'לחמים ומאפים', quantity: 2, unit: 'יחידות' },
      { name: 'גבינה צהובה פרוסה', category: 'חלבי', quantity: 1, unit: 'אריזה' },
      { name: 'נקניקיות', category: 'בשר ועוף', quantity: 1, unit: 'אריזה' },
      { name: 'חטיפים מלוחים', category: 'חטיפים', quantity: 3, unit: 'שקיות' },
      { name: 'פירות העונה', category: 'פירות וירקות', quantity: 2, unit: 'ק"ג' },
      { name: 'חטיפי אנרגיה', category: 'חטיפים', quantity: 1, unit: 'קופסה' },
      { name: 'קפה/תה נמס', category: 'משקאות', quantity: 1, unit: 'שקית' },
      { name: 'שוקולד מריר', category: 'מתוקים', quantity: 2, unit: 'לוחות' },
      { name: 'קרקרים', category: 'חטיפים', quantity: 2, unit: 'אריזות' },
      { name: 'חומוס', category: 'סלטים', quantity: 1, unit: 'קופסה' },
      { name: 'ירקות חתוכים', category: 'פירות וירקות', quantity: 1, unit: 'מארז' },
    ]
  }
];

// 🚀 Main Function
async function createSystemTemplates() {
  console.log('🚀 מתחיל יצירת תבניות מערכת...\n');

  try {
    const batch = db.batch();
    const timestamp = admin.firestore.Timestamp.now();

    for (const template of SYSTEM_TEMPLATES) {
      const templateRef = db.collection('templates').doc(template.id);
      
      // ✅ מבנה מתוקן - תואם ל-Template model!
      const templateData = {
        ...template,
        created_by: 'system',        // ✅ חדש!
        household_id: null,          // ✅ חדש! (null = זמין לכולם)
        created_date: timestamp,
        updated_date: timestamp,
      };

      batch.set(templateRef, templateData);
      console.log(`✅ נוספה תבנית: ${template.name} (${template.default_items.length} פריטים)`);
    }

    await batch.commit();
    
    console.log(`\n🎉 הושלם בהצלחה!`);
    console.log(`📊 סה"כ ${SYSTEM_TEMPLATES.length} תבניות מערכת נוצרו`);
    console.log(`\n📋 תבניות שנוצרו:`);
    SYSTEM_TEMPLATES.forEach(t => {
      console.log(`   ${t.sort_order}. ${t.icon} ${t.name} - ${t.default_items.length} פריטים`);
    });
    
    console.log(`\n✨ כל התבניות תואמות ל-Template model ומוכנות לשימוש!`);

  } catch (error) {
    console.error('❌ שגיאה ביצירת תבניות:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run
createSystemTemplates();
