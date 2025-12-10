const admin = require("firebase-admin");
const path = require("path");

// 1. הגדרות ושירותים
// וודא ששם הקובץ תואם לקובץ שהורדת מ-Firebase Console
const SERVICE_ACCOUNT_FILENAME = "firebase-service-account.json";

try {
  const serviceAccount = require(path.join(
    __dirname,
    SERVICE_ACCOUNT_FILENAME
  ));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (error) {
  console.error("Error loading service account:", error.message);
  console.error(
    "Please make sure variable SERVICE_ACCOUNT_FILENAME matches your file name and the file exists in the scripts folder."
  );
  process.exit(1);
}

const db = admin.firestore();
const auth = admin.auth();

// פונקציה ליצירת תאריך לפני X ימים
const daysAgo = (days) => {
  const date = new Date();
  date.setDate(date.getDate() - days);
  return date;
};

// 2. רשימת המשתמשים לדוגמה
const USERS = [
  {
    uid: "demo_user_1",
    email: "dani@example.com",
    password: "password123",
    displayName: "דני ישראל",
    role: "admin",
    createdAt: daysAgo(10),
  },
  {
    uid: "demo_user_2",
    email: "shira@example.com",
    password: "password123",
    displayName: "שירה כהן",
    role: "user",
    createdAt: daysAgo(5),
  },
  {
    uid: "demo_user_3",
    email: "yossi@example.com",
    password: "password123",
    displayName: "יוסי לוי",
    role: "user",
    createdAt: daysAgo(1),
  },
];

// 3. הפונקציה הראשית
async function createDemoUsers() {
  console.log("🚀 מתחיל ביצירת משתמשים לדוגמה...");

  for (const user of USERS) {
    try {
      // א. יצירת המשתמש ב-Authentication
      try {
        await auth.createUser({
          uid: user.uid,
          email: user.email,
          password: user.password,
          displayName: user.displayName,
        });
        console.log(`✅ Auth: נוצר משתמש ${user.email}`);
      } catch (error) {
        if (error.code === "auth/uid-already-exists") {
          console.log(`ℹ️ Auth: משתמש ${user.email} כבר קיים, מדלג...`);
          // אופציונלי: עדכון משתמש קיים
          await auth.updateUser(user.uid, {
            email: user.email,
            displayName: user.displayName,
            // סיסמה לא מעדכנים בדרך כלל אלא אם רוצים לאפס
          });
        } else {
          throw error;
        }
      }

      // ב. יצירת מסמך המשתמש ב-Firestore (באוסף 'users')
      await db.collection("users").doc(user.uid).set(
        {
          email: user.email,
          displayName: user.displayName,
          role: user.role,
          createdAt: user.createdAt,
          isActive: true,
        },
        { merge: true }
      ); // merge מבטיח שלא נדרוס שדות אחרים אם קיימים

      console.log(`✅ Firestore: נוצר מסמך עבור ${user.displayName}`);
    } catch (error) {
      console.error(`❌ שגיאה ביצירת משתמש ${user.email}:`, error);
    }
  }

  console.log("✨ סיימנו! כל המשתמשים נוצרו בהצלחה.");
}

// הרצת הפונקציה
createDemoUsers();
