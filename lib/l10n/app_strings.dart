// 📄 File: lib/l10n/app_strings.dart
//
// 🌍 מטרה: מחרוזות UI לאפליקציה (Localization-ready)
//
// 📝 הערות:
// - נבנה להיות תואם למעבר ל-flutter_localizations בעתיד
// - כרגע עברית בלבד, אבל המבנה תומך בהוספת שפות
// - כל המחרוזות מקובצות לפי קטגוריות לוגיות
//
// 🎯 שימוש:
// ```dart
// import 'package:memozap/l10n/app_strings.dart';
//
// Text(AppStrings.layout.appTitle)  // "MemoZap"
// Text(AppStrings.common.logout)    // "התנתק"
// ```
//
// 🔮 עתיד: כשנוסיף flutter_localizations, נחליף את הקובץ הזה
//          ב-AppLocalizations generated class
//
// Version: 3.2 - הסרת list_type_mappings_strings שבור (session 42)
// Last Updated: 29/10/2025



/// מחרוזות UI - כרגע עברית בלבד
///
/// המבנה:
/// - `layout` - מחרוזות AppLayout (AppBar, Drawer, BottomNav)
/// - `common` - מחרוזות נפוצות (כפתורים, הודעות)
/// - `navigation` - שמות טאבים ומסכים
class AppStrings {
  // מניעת instances
  const AppStrings._();

  // ========================================
  // Layout & Navigation
  // ========================================

  static const layout = _LayoutStrings();
  static const navigation = _NavigationStrings();

  // ========================================
  // Common UI Elements
  // ========================================

  static const common = _CommonStrings();

  // ========================================
  // Onboarding
  // ========================================

  static const onboarding = _OnboardingStrings();

  // ========================================
  // Shopping
  // ========================================

  static const shopping = _ShoppingStrings();

  // ========================================
  // Filters
  // ========================================

  static const filters = _FiltersStrings();

  // ========================================
  // Index (Splash)
  // ========================================

  static const index = _IndexStrings();

  // ========================================
  // Welcome
  // ========================================

  static const welcome = _WelcomeStrings();

  // ========================================
  // Auth (Login/Register)
  // ========================================

  static const auth = _AuthStrings();

  // ========================================
  // Home Dashboard
  // ========================================

  static const home = _HomeStrings();

  // ========================================
  // Price Comparison
  // ========================================

  static const priceComparison = _PriceComparisonStrings();

  // ========================================
  // Settings
  // ========================================

  static const settings = _SettingsStrings();

  // ========================================
  // Household (Household Types)
  // ========================================

  static const household = _HouseholdStrings();

  // ========================================
  // List Type Groups
  // ========================================

  static const listTypeGroups = _ListTypeGroupsStrings();



  // ========================================
  // Templates
  // ========================================

  static const templates = _TemplatesStrings();

  // ========================================
  // Create List Dialog
  // ========================================

  static const createListDialog = _CreateListDialogStrings();

  // ========================================
  // Inventory (Pantry)
  // ========================================

  static const inventory = _InventoryStrings();
}

// ========================================
// Layout Strings (AppLayout)
// ========================================

class _LayoutStrings {
  const _LayoutStrings();

  // AppBar
  String get appTitle => 'MemoZap';

  // Notifications
  String get notifications => 'התראות';
  String get noNotifications => 'אין התראות חדשות';
  String notificationsCount(int count) => 'יש לך $count עדכונים חדשים';

  // User Menu
  String get hello => 'שלום 👋';
  String get welcome => 'ברוך הבא ל-MemoZap';
  String welcomeWithUpdates(int count) => 'יש לך $count עדכונים חדשים';

  // Offline
  String get offline => 'אין חיבור לרשת';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class _NavigationStrings {
  const _NavigationStrings();

  String get home => 'בית';
  String get lists => 'רשימות';
  String get pantry => 'מזווה';
  String get receipts => 'קבלות';
  String get settings => 'הגדרות';
}

// ========================================
// Common Strings (Buttons, Actions)
// ========================================

class _CommonStrings {
  const _CommonStrings();

  // Actions
  String get logout => 'התנתק';
  String get logoutAction => 'התנתקות';
  String get cancel => 'ביטול';
  String get save => 'שמור';
  String get delete => 'מחק';
  String get edit => 'ערוך';
  String get add => 'הוסף';
  String get search => 'חיפוש';
  String get retry => 'נסה שוב';

  // Confirmations
  String get yes => 'כן';
  String get no => 'לא';
  String get ok => 'אישור';

  // Status
  String get loading => 'טוען...';
  String get error => 'שגיאה';
  String get success => 'הצלחה';
  String get noData => 'אין נתונים';
}

// ========================================
// Onboarding Strings
// ========================================

class _OnboardingStrings {
  const _OnboardingStrings();

  // Screen
  String get title => 'בואו נכיר! 👋';
  String get skip => 'דלג';
  String get previous => 'הקודם';
  String get next => 'הבא';
  String get finish => 'סיום';
  String get progress => 'התקדמות';

  // Errors
  String savingError(String error) => 'שמירת ההגדרות נכשלה: $error';
  String get skipError => 'לא ניתן לדלג';

  // Welcome Step
  String get welcomeTitle => 'ברוכים הבאים ל־MemoZap 🎉';
  String get welcomeSubtitle =>
      'ניהול רשימות מעולם לא היה קל כל כך! 🎉\n🛒 קניות • 📝 מטלות • 🎁 אירועים - עם בת הזוג, המשפחה, החברים או כל קבוצה';

  // Family Size Step
  String get familySizeTitle => 'כמה אנשים בקבוצה?';

  // Stores Step
  String get storesTitle => 'בחר חנויות מועדפות:';

  // Budget Step
  String get budgetTitle => 'מה התקציב החודשי שלך?';
  String budgetAmount(double amount) => '${amount.toStringAsFixed(0)} ₪';

  // Categories Step
  String get categoriesTitle => 'אילו קטגוריות חשובות לכם במיוחד?';

  // Sharing Step
  String get sharingTitle => 'האם תרצה לשתף רשימות עם הקבוצה?';
  String get sharingOption => 'שיתוף רשימות עם הקבוצה';

  // Reminder Step
  String get reminderTitle => 'באיזו שעה נוח לך לקבל תזכורות?';
  String get reminderChangeButton => 'שינוי שעה';

  // Summary Step
  String get summaryTitle => 'סיכום ההעדפות שלך';
  String get summaryFinishHint => 'לחץ על \'סיום\' כדי להמשיך להרשמה.';
  String familySizeSummary(int size) => 'קבוצה: $size אנשים';
  String storesSummary(String stores) => 'חנויות: $stores';
  String get noStoresSelected => 'לא נבחר';
  String budgetSummary(double amount) => 'תקציב חודשי: ${amount.toStringAsFixed(0)} ₪';
  String categoriesSummary(String categories) => 'קטגוריות: $categories';
  String get noCategoriesSelected => 'לא נבחר';
  String sharingSummary(bool enabled) => 'שיתוף רשימות: ${enabled ? "כן" : "לא"}';
  String reminderTimeSummary(String time) => 'שעה מועדפת: $time';
}

// ========================================
// 💡 טיפים לשימוש
// ========================================
//
// 1. **Import פשוט:**
//    ```dart
//    import 'package:memozap/l10n/app_strings.dart';
//    ```
//
// 2. **שימוש ב-Widget:**
//    ```dart
//    Text(AppStrings.layout.appTitle)
//    Text(AppStrings.common.logout)
//    Text(AppStrings.navigation.home)
//    ```
//
// 3. **מחרוזות עם פרמטרים:**
//    ```dart
//    Text(AppStrings.layout.notificationsCount(5))
//    // "יש לך 5 עדכונים חדשים"
//    ```
//
// 4. **מעבר ל-flutter_localizations בעתיד:**
//    - נחליף את הקובץ הזה ב-ARB files
//    - נשנה רק את ה-import, הקוד יישאר זהה
//    - המבנה כבר תואם: AppStrings.category.key
//

// ========================================
// Shopping Strings
// ========================================

class _ShoppingStrings {
  const _ShoppingStrings();

  // Item Status
  String get itemStatusPending => 'ממתין';
  String get itemStatusPurchased => 'קנוי'; // שונה מ-"נקנה" ל"קנוי" - קצר וברור!
  String get itemStatusOutOfStock => 'אזל'; // שונה מ-"לא במלאי" ל"אזל" - קצר וברור!
  String get itemStatusDeferred => 'דחה לאחר כך'; // שונה מ-"דחוי" ל"דחה לאחר כך" - ברור יותר!
  String get itemStatusNotNeeded => 'לא צריך'; // חדש!

  // Active Shopping Screen
  String get activeSaving => 'שומר...';
  String get activeFinish => 'סיום';
  String get activePurchased => 'קנוי';
  String get activeNotNeeded => 'לא צריך';
  String get activeRemaining => 'נותרו';
  String get activeTotal => 'סה״כ';
  String get activeSavingData => 'שומר את הנתונים...';

  // Active Shopping - Messages
  String get loadingDataError => 'שגיאה בטעינת הנתונים';
  String get shoppingCompletedSuccess => 'הקנייה הושלמה בהצלחה! 🎉';
  String pantryUpdated(int count) => '📦 $count מוצרים עודכנו במזווה';
  String itemsMovedToNext(int count) => '🔄 $count פריטים הועברו לרשימה הבאה';
  String get saveError => 'שגיאה בשמירה';
  String get saveErrorMessage => 'לא הצלחנו לשמור את הנתונים.\nנסה שוב?';
  String get oopsError => 'אופס! משהו השתבש';
  String get listEmpty => 'הרשימה ריקה';
  String get noItemsToBuy => 'אין פריטים לקנייה';

  // Active Shopping - Summary Dialog
  String get summaryTitle => 'סיכום קנייה';
  String get summaryShoppingTime => 'זמן קנייה';
  String get summaryOutOfStock => 'אזלו בחנות';
  String get summaryDeferred => 'נדחו לפעם הבאה';
  String get summaryNotMarked => 'לא סומנו';
  String get summaryBack => 'חזור';
  String get summaryFinishShopping => 'סיים קנייה';
  String summaryPurchased(int purchased, int total) => '$purchased מתוך $total';

  // Price & Quantity
  String quantityMultiplier(int quantity) => '${quantity}×';
  String priceFormat(double price) => '₪${price.toStringAsFixed(2)}';
  String get noPrice => 'אין מחיר';
  String get categoryGeneral => 'כללי';
}

// ========================================
// Filters Strings
// ========================================

class _FiltersStrings {
  const _FiltersStrings();

  // Categories
  String get allCategories => 'כל הקטגוריות';
  String get categoryDairy => 'חלב וביצים';
  String get categoryMeat => 'בשר ודגים';
  String get categoryVegetables => 'ירקות';
  String get categoryFruits => 'פירות';
  String get categoryBakery => 'לחם ומאפים';
  String get categoryDryGoods => 'מוצרים יבשים';
  String get categoryCleaning => 'חומרי ניקיון';
  String get categoryToiletries => 'טואלטיקה';
  String get categoryFrozen => 'קפואים';
  String get categoryBeverages => 'משקאות';

  // Statuses
  String get allStatuses => 'כל הסטטוסים';
  String get statusPending => 'ממתין';
  String get statusTaken => 'נלקח';
  String get statusMissing => 'חסר';
  String get statusReplaced => 'הוחלף';
}

// ========================================
// Index (Splash) Strings
// ========================================

class _IndexStrings {
  const _IndexStrings();

  // Screen
  String get appName => 'MemoZap';

  // Accessibility
  String get logoLabel => 'לוגו אפליקציית MemoZap';
  String get loadingLabel => 'טוען את האפליקציה';

  // UI
  String get loading => 'טוען...';
}

// ========================================
// Welcome Strings
// ========================================

class _WelcomeStrings {
  const _WelcomeStrings();

  // Screen
  String get title => 'MemoZap - קניות ומטלות חכמות 🛒✅';
  String get subtitle => 'מה שקונים מתווסף אוטומטית למזווה';

  // Benefits - Updated Version (25/10/2025)
  // 📏 Shorter texts for single-screen layout (4 benefits + no scroll)
  // 🎯 Focus on core features: sharing, unified lists, smart suggestions, organized pantry
  String get benefit1Title => 'שיתוף חכם';
  String get benefit1Subtitle => 'זוג, משפחה, ועד, עבודה';
  String get benefit2Title => 'מוצרים + מטלות';
  String get benefit2Subtitle => 'ברשימה אחת';
  String get benefit3Title => 'המלצות חכמות';
  String get benefit3Subtitle => 'המזווה יודע מה חסר';
  String get benefit4Title => 'מזווה מאורגן';
  String get benefit4Subtitle => 'לפי ארון, מדף, חדר';

  // Buttons
  String get loginButton => 'התחברות';
  String get registerButton => 'הרשמה';
  String get guestButton => 'המשך כאורח';
  String get socialLoginLabel => 'או התחבר עם:';
  String get googleButton => 'Google';
  String get facebookButton => 'Facebook';

  // Accessibility
  String get logoLabel => 'לוגו אפליקציית MemoZap';
  String socialLoginButtonLabel(String provider) => 'התחבר עם $provider';
}

// ========================================
// Auth Strings (Login/Register)
// ========================================

class _AuthStrings {
  const _AuthStrings();

  // ========================================
  // Login Screen
  // ========================================

  String get loginTitle => 'התחברות';
  String get loginSubtitle => 'ברוך שובך!';
  String get loginButton => 'התחבר';

  // ========================================
  // Register Screen
  // ========================================

  String get registerTitle => 'הרשמה';
  String get registerSubtitle => 'צור חשבון חדש';
  String get registerButton => 'הירשם';

  // ========================================
  // Password Reset
  // ========================================

  String get forgotPassword => 'שכחת סיסמה?';
  String get resetPasswordTitle => 'איפוס סיסמה';
  String get resetPasswordSubtitle => 'נשלח לך קישור לאיפוס הסיסמה למייל';
  String get sendResetEmailButton => 'שלח קישור';
  String get backToLogin => 'חזרה להתחברות';
  String get resetEmailSent => 'מייל לאיפוס סיסמה נשלח בהצלחה!';

  // ========================================
  // Email Verification
  // ========================================

  String get emailNotVerified => 'האימייל לא אומת';
  String get verifyEmailMessage => 'נא לאמת את כתובת האימייל שלך';
  String get sendVerificationEmailButton => 'שלח מייל אימות';
  String get verificationEmailSent => 'מייל אימות נשלח!';
  String get checkYourEmail => 'בדוק את תיבת הדואר שלך';

  // ========================================
  // Profile Updates
  // ========================================

  String get updateProfile => 'עדכון פרופיל';
  String get updateDisplayName => 'עדכון שם תצוגה';
  String get displayNameUpdated => 'שם התצוגה עודכן בהצלחה!';
  String get updateEmail => 'עדכון אימייל';
  String get emailUpdated => 'האימייל עודכן בהצלחה!';
  String get updatePassword => 'עדכון סיסמה';
  String get passwordUpdated => 'הסיסמה עודכנה בהצלחה!';
  String get newPasswordLabel => 'סיסמה חדשה';
  String get currentPasswordLabel => 'סיסמה נוכחית';

  // ========================================
  // Account Deletion
  // ========================================

  String get deleteAccount => 'מחיקת חשבון';
  String get deleteAccountWarning => 'פעולה זו בלתי הפיכה!';
  String get deleteAccountConfirm => 'האם אתה בטוח שברצונך למחוק את החשבון?';
  String get accountDeleted => 'החשבון נמחק בהצלחה';

  // ========================================
  // Fields
  // ========================================

  String get emailLabel => 'אימייל';
  String get emailHint => 'example@email.com';
  String get passwordLabel => 'סיסמה';
  String get passwordHint => '••••••••';
  String get confirmPasswordLabel => 'אימות סיסמה';
  String get confirmPasswordHint => '••••••••';
  String get nameLabel => 'שם מלא';
  String get nameHint => 'יוסי כהן';

  // ========================================
  // Links
  // ========================================

  String get noAccount => 'אין לך חשבון?';
  String get registerNow => 'הירשם עכשיו';
  String get haveAccount => 'יש לך חשבון?';
  String get loginNow => 'התחבר עכשיו';

  // ========================================
  // Divider
  // ========================================

  String get or => 'או';

  // ========================================
  // Validation Errors
  // ========================================

  String get emailRequired => 'שדה חובה';
  String get emailInvalid => 'אימייל לא תקין';
  String get passwordRequired => 'שדה חובה';
  String get passwordTooShort => 'סיסמה חייבת להכיל לפחות 6 תווים';
  String get confirmPasswordRequired => 'שדה חובה';
  String get passwordsDoNotMatch => 'הסיסמאות לא תואמות';
  String get nameRequired => 'שדה חובה';
  String get nameTooShort => 'שם חייב להכיל לפחות 2 תווים';

  // ========================================
  // Firebase Error Messages
  // ========================================

  // Sign Up Errors
  String get errorWeakPassword => 'הסיסמה חלשה מדי';
  String get errorEmailInUse => 'האימייל כבר בשימוש';
  String get errorInvalidEmail => 'פורמט אימייל לא תקין';
  String get errorOperationNotAllowed => 'פעולה לא מורשית';

  // Sign In Errors
  String get errorUserNotFound => 'משתמש לא נמצא';
  String get errorWrongPassword => 'סיסמה שגויה';
  String get errorUserDisabled => 'המשתמש חסום';
  String get errorInvalidCredential => 'פרטי התחברות שגויים';
  String get errorTooManyRequests => 'יותר מדי ניסיונות. נסה שוב מאוחר יותר';

  // Other Errors
  String get errorRequiresRecentLogin => 'נדרשת התחברות מחדש לביצוע פעולה זו';
  String get errorNetworkRequestFailed => 'בעיית רשת. בדוק את החיבור לאינטרנט';
  String get errorNoUserLoggedIn => 'אין משתמש מחובר';

  // Generic Errors with Parameters
  String signUpError(String? message) => 'שגיאה ברישום${message != null ? ": $message" : ""}';
  String signInError(String? message) => 'שגיאה בהתחברות${message != null ? ": $message" : ""}';
  String signOutError(String? message) => 'שגיאה בהתנתקות${message != null ? ": $message" : ""}';
  String resetEmailError(String? message) => 'שגיאה בשליחת מייל${message != null ? ": $message" : ""}';
  String verificationEmailError(String? message) => 'שגיאה בשליחת מייל אימות${message != null ? ": $message" : ""}';
  String updateDisplayNameError(String? message) => 'שגיאה בעדכון שם${message != null ? ": $message" : ""}';
  String updateEmailError(String? message) => 'שגיאה בעדכון אימייל${message != null ? ": $message" : ""}';
  String updatePasswordError(String? message) => 'שגיאה בעדכון סיסמה${message != null ? ": $message" : ""}';
  String deleteAccountError(String? message) => 'שגיאה במחיקת חשבון${message != null ? ": $message" : ""}';
  String reloadUserError(String? message) => 'שגיאה בטעינה מחדש${message != null ? ": $message" : ""}';

  // ========================================
  // Success Messages
  // ========================================

  String get mustCompleteLogin => 'יש להשלים את תהליך ההתחברות';
  String get mustCompleteRegister => 'יש להשלים את תהליך ההרשמה';
  String get loginSuccess => 'התחברת בהצלחה!';
  String get registerSuccess => 'נרשמת בהצלחה!';
  String get signOutSuccess => 'התנתקת בהצלחה';
}

// ========================================
// Home Dashboard Strings
// ========================================

class _HomeStrings {
  const _HomeStrings();

  // Welcome Header
  String welcomeUser(String userName) => 'שלום $userName! 👋';
  String get guestUser => 'אורח';

  // Sort
  String get sortLabel => 'מיון:';
  String get sortByDate => 'תאריך עדכון';
  String get sortByName => 'שם';
  String get sortByStatus => 'סטטוס';

  // Empty State
  String get noActiveLists => 'אין רשימות פעילות כרגע';
  String get emptyStateMessage => 'צור את הרשימה הראשונה שלך\nקניות, מטלות, אירועים - הכל מתחיל פה! ✨';
  String get createFirstList => 'צור רשימה ראשונה';

  // Receipts Card
  String get myReceipts => 'הקבלות שלי';
  String get noReceipts => 'אין קבלות עדיין. התחל להוסיף!';
  String receiptsCount(int count) => '$count קבלות';

  // Active Lists Card
  String get otherActiveLists => 'רשימות פעילות נוספות';
  String get noOtherActiveLists => 'אין רשימות נוספות כרגע';
  String get allLists => 'כל הרשימות';
  String itemsCount(int count) => '$count פריטים';

  // List Actions
  String listDeleted(String listName) => 'הרשימה "$listName" נמחקה';
  String get undo => 'בטל';

  // Errors
  String createListError(String error) => 'שגיאה ביצירת רשימה: $error';
  String deleteListError(String error) => 'שגיאה במחיקה: $error';

  // Navigation
  String get doubleTapToExit => 'לחץ שוב לסגירת האפליקציה';
}

// ========================================
// Price Comparison Strings
// ========================================

class _PriceComparisonStrings {
  const _PriceComparisonStrings();

  // Screen
  String get title => 'השוואת מחירים';
  String get searchHint => 'חפש מוצר...';
  String get searchButton => 'חפש';
  String get clearButton => 'נקה';
  String get clearTooltip => 'נקה';

  // Results
  String searchResults(String term) => 'תוצאות עבור "$term"';
  String resultsCount(int count) => '$count תוצאות';

  // Empty States
  String get noResultsTitle => 'לא נמצאו תוצאות';
  String noResultsMessage(String term) => 'לא נמצאו תוצאות עבור "$term"';
  String get noResultsHint => 'נסו מונח אחר או שם מוצר מדויק יותר';
  String get emptyStateTitle => 'חפש מוצרים';
  String get emptyStateMessage => 'הזן שם מוצר כדי להשוות מחירים בין חנויות שונות';

  // Store Info
  String get cheapestLabel => 'הכי זול';
  String get savingsLabel => 'חיסכון פוטנציאלי';
  String get storeIcon => '🏪';
  String get savingsIcon => '💰';

  // Loading
  String get searching => 'מחפש מוצרים...';

  // Errors
  String get errorTitle => 'שגיאה בחיפוש';
  String searchError(String error) => 'שגיאה בחיפוש: $error';
  String get retry => 'נסה שוב';
}

// ========================================
// Settings Strings
// ========================================

class _SettingsStrings {
  const _SettingsStrings();

  // Screen
  String get title => 'הגדרות ופרופיל';

  // Profile Section
  String get profileTitle => 'פרופיל אישי';
  String get editProfile => 'עריכה';
  String get editProfileButton => 'עריכת פרופיל - בקרוב!';

  // Stats Card
  String get statsActiveLists => 'רשימות פעילות';
  String get statsReceipts => 'קבלות';
  String get statsPantryItems => 'פריטים במזווה';

  // Household Section
  String get householdTitle => 'ניהול קבוצה';
  String get householdName => 'שם הקבוצה';
  String get householdType => 'סוג הקבוצה:';
  String get householdNameHint => 'שם הקבוצה';
  String get editHouseholdNameSave => 'שמור';
  String get editHouseholdNameEdit => 'ערוך שם';

  // Members
  String membersCount(int count) => 'חברי הקבוצה ($count)';
  String get manageMembersButton => 'ניהול חברים - בקרוב!';
  String get manageMembersComingSoon => 'ניהול חברים מלא - בקרוב! 🚧';
  String get roleOwner => 'בעלים';
  String get roleEditor => 'עורך';
  String get roleViewer => 'צופה';

  // Stores Section
  String get storesTitle => 'חנויות מועדפות';
  String get addStoreHint => 'הוסף חנות...';
  String get addStoreTooltip => 'הוסף חנות';

  // Personal Settings
  String get personalSettingsTitle => 'הגדרות אישיות';
  String get familySizeLabel => 'גודל הקבוצה (מספר אנשים)';
  String get weeklyRemindersLabel => 'תזכורות שבועיות';
  String get weeklyRemindersSubtitle => 'קבל תזכורת לתכנן קניות';
  String get habitsAnalysisLabel => 'ניתוח הרגלי קנייה';
  String get habitsAnalysisSubtitle => 'קבל המלצות מבוססות נתונים';

  // Quick Links
  String get quickLinksTitle => 'קישורים מהירים';
  String get myReceipts => 'הקבלות שלי';
  String get myPantry => 'המזווה שלי';
  String get priceComparison => 'השוואת מחירים';
  String get updatePricesTitle => 'עדכן מחירים מ-API';
  String get updatePricesSubtitle => 'טעינת מחירים עדכניים מהרשת';

  // Update Prices Flow
  String get updatingPrices => '💰 מעדכן מחירים מ-API...';
  String pricesUpdated(int withPrice, int total) => '✅ התעדכנו $withPrice מחירים מתוך $total מוצרים!';
  String pricesUpdateError(String error) => '❌ שגיאה בעדכון מחירים: $error';

  // Logout
  String get logoutTitle => 'התנתקות';
  String get logoutMessage => 'האם אתה בטוח שברצונך להתנתק?';
  String get logoutCancel => 'ביטול';
  String get logoutConfirm => 'התנתק';
  String get logoutSubtitle => 'יציאה מהחשבון';

  // Loading
  String get loading => 'טוען...';

  // Errors
  String loadError(String error) => 'Error loading settings: $error';
  String saveError(String error) => 'Error saving settings: $error';
}

// ========================================
// Household Strings (Types & Descriptions)
// ========================================

class _HouseholdStrings {
  const _HouseholdStrings();

  // ========================================
  // Type Labels (11 types)
  // ========================================

  // Original 5
  String get typeFamily => 'משפחה';
  String get typeBuildingCommittee => 'ועד בית';
  String get typeKindergartenCommittee => 'ועד גן';
  String get typeRoommates => 'שותפים לדירה';
  String get typeOther => 'אחר';

  // New 6
  String get typeFriends => 'חברים';
  String get typeColleagues => 'עמיתים לעבודה';
  String get typeNeighbors => 'שכנים';
  String get typeClassCommittee => 'ועד כיתה';
  String get typeClub => 'מועדון/קהילה';
  String get typeExtendedFamily => 'משפחה מורחבת';

  // ========================================
  // Type Descriptions (11 types)
  // ========================================

  // Original 5
  String get descFamily => 'ניהול קניות וצרכים משותפים למשפחה';
  String get descBuildingCommittee => 'רכישות משותפות וניהול אירועי ועד בית';
  String get descKindergartenCommittee => 'ניהול קניות ואירועים לועד גן הילדים';
  String get descRoommates => 'חלוקת עלויות וקניות לשותפים בדירה';
  String get descOther => 'קבוצה מותאמת אישית - הגדר בעצמך';

  // New 6
  String get descFriends => 'תכנון קניות וארגון אירועים עם חברים קרובים';
  String get descColleagues => 'רכישות משותפות וארגון ארוחות לצוות העבודה';
  String get descNeighbors => 'קניות משותפות ושיתוף פעולה בין שכנים בקרבת מקום';
  String get descClassCommittee => 'ניהול קניות ואירועים להורי תלמידי הכיתה';
  String get descClub => 'ארגון אירועים ורכישות לקבוצת תחביב או קהילה';
  String get descExtendedFamily => 'תכנון קניות ואירועים גדולים למשפחה המורחבת';
}

// ========================================
// List Type Groups Strings
// ========================================

class _ListTypeGroupsStrings {
  const _ListTypeGroupsStrings();

  // ========================================
  // Group Names
  // ========================================

  String get nameShopping => 'קניות יומיומיות';
  String get nameSpecialty => 'קניות מיוחדות';
  String get nameEvents => 'אירועים';

  // ========================================
  // Group Descriptions
  // ========================================

  String get descShopping => 'קניות שוטפות ויומיומיות';
  String get descSpecialty => 'קניות בחנויות מיוחדות';
  String get descEvents => 'אירועים, מסיבות ומטלות מיוחדות';
}

// ========================================
// Templates Strings
// ========================================

class _TemplatesStrings {
  const _TemplatesStrings();

  // ========================================
  // Screen
  // ========================================

  String get title => 'תבניות רשימות';
  String get subtitle => 'צור תבניות מוכנות לשימוש חוזר';

  // ========================================
  // Tabs/Filters
  // ========================================

  String get filterAll => 'הכל';
  String get filterMine => 'שלי';
  String get filterShared => 'משותפות';
  String get filterSystem => 'מערכת';

  // ========================================
  // Empty States
  // ========================================

  String get emptyStateTitle => 'אין תבניות עדיין';
  String get emptyStateMessage => 'צור תבנית ראשונה כדי להקל על יצירת רשימות בעתיד';
  String get emptyStateButton => 'צור תבנית ראשונה';

  String get emptyMyTemplatesTitle => 'אין לך תבניות אישיות';
  String get emptyMyTemplatesMessage => 'צור תבנית כדי לחסוך זמן ביצירת רשימות חוזרות';

  String get emptySharedTemplatesTitle => 'אין תבניות משותפות';
  String get emptySharedTemplatesMessage => 'חברי הקבוצה יכולים ליצור תבניות משותפות';

  // ========================================
  // Card/List Item
  // ========================================

  String itemsCount(int count) => '$count פריטים';
  String get formatPersonal => 'אישי';
  String get formatShared => 'משותף';
  String get formatAssigned => 'מוקצה';
  String get formatSystem => 'מערכת';

  // ========================================
  // Actions
  // ========================================

  String get createButton => 'תבנית חדשה';
  String get editButton => 'ערוך';
  String get deleteButton => 'מחק';
  String get useTemplateButton => 'השתמש בתבנית';
  String get duplicateButton => 'שכפל';

  // ========================================
  // Form Screen
  // ========================================

  String get formTitleCreate => 'תבנית חדשה';
  String get formTitleEdit => 'עריכת תבנית';

  // Fields
  String get nameLabel => 'שם התבנית';
  String get nameHint => 'למשל: קניות שבועיות';
  String get nameRequired => 'נא להזין שם תבנית';

  String get descriptionLabel => 'תיאור (אופציונלי)';
  String get descriptionHint => 'תאר למה התבנית מיועדת...';

  String get iconLabel => 'אייקון';
  String get iconHint => 'בחר סוג רשימה';

  String get formatLabel => 'פורמט';
  String get formatPersonalDesc => 'רק אני רואה';
  String get formatSharedDesc => 'כל הקבוצה רואה';
  String get formatAssignedDesc => 'הוקצה לאנשים ספציפיים';

  String get itemsLabel => 'פריטים בתבנית';
  String get addItemButton => 'הוסף פריט';
  String get noItemsYet => 'עדיין אין פריטים. הוסף לפחות פריט אחד.';

  // Item Form
  String get itemNameLabel => 'שם הפריט';
  String get itemNameHint => 'למשל: חלב';
  String get itemNameRequired => 'נא להזין שם פריט';

  String get itemCategoryLabel => 'קטגוריה';
  String get itemCategoryHint => 'בחר קטגוריה';

  String get itemQuantityLabel => 'כמות';
  String get itemQuantityHint => '1';

  String get itemUnitLabel => 'יחידה';
  String get itemUnitHint => 'ליטר, ק"ג, יחידות...';

  // Save
  String get saveButton => 'שמור תבנית';
  String get savingButton => 'שומר...';
  String get cancelButton => 'בטל';

  // Validation
  String get atLeastOneItem => 'יש להוסיף לפחות פריט אחד';
  String templateNameExists(String name) => 'תבנית בשם "$name" כבר קיימת';

  // ========================================
  // Messages
  // ========================================

  String templateCreated(String name) => 'התבנית "$name" נוצרה בהצלחה!';
  String templateUpdated(String name) => 'התבנית "$name" עודכנה!';
  String templateDeleted(String name) => 'התבנית "$name" נמחקה';
  String get undo => 'בטל';

  String createError(String error) => 'שגיאה ביצירת תבנית: $error';
  String updateError(String error) => 'שגיאה בעדכון: $error';
  String deleteError(String error) => 'שגיאה במחיקה: $error';

  // ========================================
  // Delete Confirmation
  // ========================================

  String get deleteConfirmTitle => 'מחיקת תבנית';
  String deleteConfirmMessage(String name) => 'האם אתה בטוח שברצונך למחוק את התבנית "$name"?';
  String get deleteCancel => 'ביטול';
  String get deleteConfirm => 'מחק';

  // ========================================
  // Use Template Dialog
  // ========================================

  String get useTemplateTitle => 'בחר תבנית';
  String get useTemplateHint => 'בחר תבנית כדי למלא את הרשימה אוטומטית';
  String get useTemplateEmpty => 'אין תבניות זמינות';
  String get useTemplateSelect => 'בחר';
}

// ========================================
// Create List Dialog Strings
// ========================================

class _CreateListDialogStrings {
  const _CreateListDialogStrings();

  // ========================================
  // Dialog Title
  // ========================================

  String get title => 'יצירת רשימה חדשה';

  // ========================================
  // Use Template Section
  // ========================================

  String get useTemplateButton => '📋 שימוש בתבנית';
  String get useTemplateTooltip => 'בחר תבנית מוכנה';
  String get selectTemplateTitle => 'בחר תבנית';
  String get selectTemplateHint => 'בחר תבנית כדי למלא את הרשימה אוטומטית';
  String get noTemplatesAvailable => 'אין תבניות זמינות';
  String get noTemplatesMessage => 'צור תבנית ראשונה במסך התבניות';
  String templateSelected(String name) => 'תבנית "$name" נבחרה';
  String templateApplied(String name, int itemsCount) => '✨ התבנית "$name" הוחלה בהצלחה! נוספו $itemsCount פריטים';

  // ========================================
  // Form Fields
  // ========================================

  // Name Field
  String get nameLabel => 'שם הרשימה';
  String get nameHint => 'למשל: קניות השבוע';
  String get nameRequired => 'נא להזין שם רשימה';
  String nameAlreadyExists(String name) => 'רשימה בשם "$name" כבר קיימת';

  // Type Field
  String get typeLabel => 'סוג הרשימה';
  String get typeSelected => 'נבחר';

  // Budget Field
  String get budgetLabel => 'תקציב (אופציונלי)';
  String get budgetHint => '₪500';
  String get budgetInvalid => 'נא להזין מספר תקין';
  String get budgetMustBePositive => 'תקציב חייב להיות גדול מ-0';
  String get clearBudgetTooltip => 'נקה תקציב';

  // Event Date Field
  String get eventDateLabel => 'תאריך אירוע (אופציונלי)';
  String get eventDateHint => 'למשל: יום הולדת, אירוח';
  String get noDate => 'אין תאריך';
  String get selectDate => 'בחר תאריך אירוע';
  String get clearDateTooltip => 'נקה תאריך';

  // ========================================
  // Action Buttons
  // ========================================

  String get cancelButton => 'בטל';
  String get cancelTooltip => 'ביטול יצירת הרשימה';
  String get createButton => 'צור רשימה';
  String get createTooltip => 'יצירת הרשימה החדשה';
  String get creating => 'יוצר...';

  // ========================================
  // Loading State
  // ========================================

  String get loadingTemplates => 'טוען תבניות...';
  String get loadingTemplatesError => 'שגיאה בטעינת תבניות';

  // ========================================
  // Success Messages
  // ========================================

  String listCreated(String name) => 'הרשימה "$name" נוצרה בהצלחה! 🎉';
  String listCreatedWithBudget(String name, double budget) =>
      'הרשימה "$name" נוצרה עם תקציב ₪${budget.toStringAsFixed(0)}';

  // ========================================
  // Error Messages
  // ========================================

  String get validationFailed => 'אנא תקן את השגיאות בטופס';
  String get userNotLoggedIn => 'משתמש לא מחובר';
  String createListError(String error) => 'שגיאה ביצירת הרשימה';
  String get createListErrorGeneric => 'אירעה שגיאה ביצירת הרשימה. נסה שוב.';
  String get networkError => 'בעיית רשת. בדוק את החיבור לאינטרנט';
}

// ========================================
// Inventory Strings (Pantry)
// ========================================

class _InventoryStrings {
  const _InventoryStrings();

  // ========================================
  // Dialog Titles
  // ========================================

  String get addDialogTitle => 'הוספת פריט';
  String get editDialogTitle => 'עריכת פריט';

  // ========================================
  // Action Buttons
  // ========================================

  String get addButton => 'הוסף';
  String get saveButton => 'שמור';

  // ========================================
  // Form Fields
  // ========================================

  // Product Name Field
  String get productNameLabel => 'שם הפריט';
  String get productNameHint => 'לדוגמה: חלב';
  String get productNameRequired => 'נא להזין שם פריט';

  // Category Field
  String get categoryLabel => 'קטגוריה';
  String get categoryHint => 'לדוגמה: חלבי';
  String get categoryRequired => 'נא להזין קטגוריה';

  // Quantity Field
  String get quantityLabel => 'כמות';

  // Unit Field
  String get unitLabel => 'יחידה';
  String get unitHint => 'יח\', ק"ג, ליטר';

  // Location Field
  String get locationLabel => 'מיקום';

  // ========================================
  // Success Messages
  // ========================================

  String get itemAdded => 'הפריט נוסף בהצלחה';
  String get itemUpdated => 'הפריט עודכן בהצלחה';

  // ========================================
  // Error Messages
  // ========================================

  String get addError => 'שגיאה בהוספת פריט';
  String get updateError => 'שגיאה בעדכון פריט';
}
