// 📄 lib/l10n/app_strings.dart
//
// מחרוזות UI מקובצות לפי מסכים - עברית בלבד, מוכן ל-i18n.
// מבנה: AppStrings.layout, .common, .auth, .inventory, .shoppingList, וכו'.
//
// 🔗 Related: All screens and widgets, filters_config (for categories)



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

  // ========================================
  // Shopping List Details
  // ========================================

  static const listDetails = _ShoppingListDetailsStrings();

  // ========================================
  // User Sharing System (Phase 3B)
  // ========================================

  static const sharing = _SharingStrings();
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
  String get family => 'משפחה';
  String get groups => 'קבוצות';
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
  String get resetFilter => 'איפוס סינון';
  String get clearAll => 'נקה הכל';
  String get searchProductHint => 'חפש מוצר...';
  String get categories => 'קטגוריות';
  String get meatTypes => 'סוגי בשר';
  String get all => 'הכל';

  // Confirmations
  String get yes => 'כן';
  String get no => 'לא';
  String get ok => 'אישור';

  // Status
  String get loading => 'טוען...';
  String get error => 'שגיאה';
  String get success => 'הצלחה';
  String get noData => 'אין נתונים';
  String get syncError => 'בעיית סנכרון - השינויים נשמרו מקומית';

  // Unsaved Changes Dialog
  String get unsavedChangesTitle => 'שינויים לא נשמרו';
  String get unsavedChangesMessage => 'יש שינויים שלא נשמרו. האם לצאת בלי לשמור?';
  String get stayHere => 'הישאר';
  String get exitWithoutSaving => 'צא בלי לשמור';
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
  String get familySizeTitle => 'כמה אנשים במשפחה?';

  // Stores Step
  String get storesTitle => 'בחר חנויות מועדפות:';

  // Budget Step
  String get budgetTitle => 'מה התקציב החודשי שלך?';
  String budgetAmount(double amount) => '${amount.toStringAsFixed(0)} ₪';

  // Categories Step
  String get categoriesTitle => 'אילו קטגוריות חשובות לכם במיוחד?';

  // Sharing Step
  String get sharingTitle => 'האם תרצה לשתף רשימות עם המשפחה?';
  String get sharingOption => 'שיתוף רשימות עם המשפחה';

  // Reminder Step
  String get reminderTitle => 'באיזו שעה נוח לך לקבל תזכורות?';
  String get reminderChangeButton => 'שינוי שעה';

  // Summary Step
  String get summaryTitle => 'סיכום ההעדפות שלך';
  String get summaryFinishHint => 'לחץ על \'סיום\' כדי להמשיך להרשמה.';
  String familySizeSummary(int size) => 'משפחה: $size אנשים';
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

  // Shopping List Tile
  String get sharedLabel => 'משותפת';
  String get startShoppingButton => 'התחל קנייה';
  String get addProductsToStart => 'הוסף מוצרים כדי להתחיל';
  String listDeleted(String name) => 'הרשימה "$name" נמחקה';
  String get undoButton => 'בטל';
  String get restoreError => 'שגיאה בשחזור הרשימה';
  String get deleteError => 'שגיאה במחיקת הרשימה';

  // Shopping List Tile - Urgency
  String get urgencyPassed => 'עבר!';
  String get urgencyToday => 'היום!';
  String get urgencyTomorrow => 'מחר';
  String urgencyDaysLeft(int days) => 'עוד $days ימים';

  // Shopping List Tile - List Types
  String get typeSupermarket => 'סופרמרקט';
  String get typePharmacy => 'בית מרקחת';
  String get typeGreengrocer => 'ירקן';
  String get typeButcher => 'אטליז';
  String get typeBakery => 'מאפייה';
  String get typeMarket => 'שוק';
  String get typeHousehold => 'כלי בית';
  String get typeOther => 'אחר';

  // Shopping List Tile - Delete Dialog
  String get deleteListTitle => 'מחיקת רשימה';
  String deleteListMessage(String name) => 'האם למחוק את הרשימה "$name"?';
  String get deleteButton => 'מחק';

  // Shopping List Tile - Item Info
  String itemsAndDate(int count, String date) => 'פריטים: $count • עודכן: $date';
  String get editListButton => 'עריכת רשימה';
  String get deleteListButton => 'מחיקה';

  // Active Shopping - Summary Dialog
  String get summaryTitle => 'סיכום קנייה';
  String get summaryShoppingTime => 'זמן קנייה';
  String get summaryOutOfStock => 'אזלו בחנות';
  String get summaryDeferred => 'נדחו לפעם הבאה';
  String get summaryNotMarked => 'לא סומנו';
  String get summaryBack => 'חזור';
  String get summaryFinishShopping => 'סיים קנייה';
  String summaryPurchased(int purchased, int total) => '$purchased מתוך $total';

  // Pending Items Dialog
  String summaryPendingQuestion(int count) =>
      count == 1 ? 'יש פריט אחד שלא סומן.' : 'יש $count פריטים שלא סומנו.';
  String get summaryPendingSubtitle => 'מה לעשות איתם?';
  String get summaryPendingTransfer => 'העבר לרשימה הבאה';
  String get summaryPendingTransferSubtitle => 'הפריטים יועברו לקנייה הבאה';
  String get summaryPendingLeave => 'השאר ברשימה';
  String get summaryPendingLeaveSubtitle => 'הרשימה תישאר פעילה';
  String get summaryPendingDelete => 'מחק ולא צריך';
  String get summaryPendingDeleteSubtitle => 'הפריטים יוסרו לגמרי';

  // Price & Quantity
  String quantityMultiplier(int quantity) => '$quantity×';
  String priceFormat(double price) => '₪${price.toStringAsFixed(2)}';
  String get noPrice => 'אין מחיר';
  String get categoryGeneral => 'כללי';

  // Product Selection Bottom Sheet
  String addProductsTitle(String listName) => 'הוספת מוצרים: $listName';
  String productRemovedFromList(String name) => '$name הוסר מהרשימה';
  String productUpdatedQuantity(String name, int quantity) => '$name (עודכן ל-$quantity)';
  String productAddedToList(String name) => '$name נוסף לרשימה! ✓';
  String get loadingProducts => 'טוען מוצרים...';
  String noProductsMatchingSearch(String query) => 'לא נמצאו מוצרים התואמים "$query"';
  String get noProductsAvailable => 'אין מוצרים זמינים כרגע';
  String get tryDifferentSearch => 'נסה לחפש משהו אחר';
  String get loadProductsFromServer => 'טען מוצרים מהשרת';
  String get loadProductsButton => 'טען מוצרים';
  String get productNoName => 'ללא שם';
  String updateProductError(String error) => 'שגיאה בעדכון מוצר: $error';
  String addProductError(String error) => 'שגיאה בהוספת מוצר: $error';

  // ========================================
  // Shopping Lists Screen (Browse)
  // ========================================

  // Top Bar & Menu
  String get searchAndFilter => 'חיפוש וסינון';
  String get filterActive => 'סינון פעיל';
  String get searchMenuLabel => 'חיפוש';
  String get filterByTypeLabel => 'סינון לפי סוג';
  String get sortLabel => 'מיון';
  String get clearFilterLabel => 'נקה סינון';
  String get newListTooltip => 'רשימה חדשה';

  // Search Sheet
  String get searchListTitle => 'חיפוש רשימה';
  String get searchListHint => 'הקלד שם רשימה...';
  String get clearButton => 'נקה';
  String get searchButton => 'חפש';

  // Filter Sheet
  String get filterByTypeTitle => 'סינון לפי סוג';
  String get allTypesLabel => 'הכל';

  // Sort Sheet
  String get sortTitle => 'מיון';
  String get sortDateDesc => 'חדש → ישן';
  String get sortDateAsc => 'ישן → חדש';
  String get sortNameAZ => 'א-ת';
  String get sortBudgetDesc => 'תקציב גבוה → נמוך';
  String get sortBudgetAsc => 'תקציב נמוך → גבוה';
  String get sortLabelNew => 'חדש';
  String get sortLabelOld => 'ישן';
  String get sortLabelAZ => 'א-ת';

  // Section Headers
  String get activeLists => '🔵 רשימות פעילות';
  String get historyLists => '✅ היסטוריה';
  String get historyListsNote => '(לפי עדכון אחרון)';

  // Empty States
  String get noListsFoundTitle => 'לא נמצאו רשימות';
  String get noListsFoundSubtitle => 'נסה לשנות את החיפוש או הסינון';
  String get noListsTitle => 'אין רשימות קניות';
  String get noListsSubtitle => 'לחץ על הכפתור מטה ליצירת\nהרשימה הראשונה שלך!';
  String get createNewListButton => 'צור רשימה חדשה';
  String get orScanReceiptHint => 'או סרוק קבלה במסך הקבלות';

  // Error State
  String get loadingListsError => 'שגיאה בטעינת הרשימות';
  String get somethingWentWrong => 'משהו השתבש...';
  String get tryAgainButton => 'נסה שוב';

  // Pagination
  String loadMoreLists(int remaining) => 'טען עוד רשימות ($remaining נותרו)';

  // Tooltips & Actions
  String get moreOptionsTooltip => 'אפשרויות נוספות';

  // Default List Names
  String get defaultShoppingListName => 'קניות כלליות';
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
  String get title => 'MemoZap';
  String get subtitle => 'רשימות משותפות. מקום אחד.';

  // Group Cards - Updated Version (16/12/2025) - New Welcome Design
  // 🎯 Focus on group types with questions and features
  // 👨‍👩‍👧‍👦 Family, 🏠 Building Committee, 🎒 Kindergarten Committee

  // Family Card
  String get group1Emoji => '👨‍👩‍👧‍👦';
  String get group1Title => 'משפחה';
  String get group1Question => '"מה לקנות? מה יש?"';
  String get group1Feature1 => 'קניות 🛒';
  String get group1Feature2 => 'מזווה 📦';

  // Building Committee Card
  String get group2Emoji => '🏠';
  String get group2Title => 'ועד בית';
  String get group2Question => '"מה צריך? מי בעד?"';
  String get group2Feature1 => 'משימות ✅';
  String get group2Feature2 => 'הצבעות 🗳️';

  // Kindergarten Committee Card
  String get group3Emoji => '🎒';
  String get group3Title => 'ועד גן';
  String get group3Question => '"מי מביא מה?"';
  String get group3Feature1 => 'חלוקה 🙋';
  String get group3Feature2 => 'רשימה 📋';

  // More groups hint
  String get moreGroupsHint => '+ שותפים, אירועים...';

  // Legacy benefits (kept for backward compatibility)
  String get benefit1Title => 'שיתוף בזמן אמת';
  String get benefit1Subtitle => 'כולם רואים ומעדכנים - זוג, משפחה או עבודה';
  String get benefit2Title => 'מוצרים ומטלות ביחד';
  String get benefit2Subtitle => 'רשימה אחת לכל מה שצריך - מהסופר ועד המטלות';
  String get benefit3Title => 'מזווה חכם ומאורגן';
  String get benefit3Subtitle => 'המלצות אוטומטיות למה חסר + ארגון לפי מדפים';

  // Buttons
  String get startButton => 'הרשמה';
  String get loginButton => 'התחברות';
  String get loginLink => 'כבר יש לי חשבון — התחברות';
  String get authExplanation => 'כדי להשתמש באפליקציה צריך להתחבר או להירשם';
  String get registerButton => 'הרשמה';
  String get socialLoginLabel => 'או התחבר עם:';
  String get googleButton => 'Google';
  String get facebookButton => 'Facebook';

  // Legal links
  String get termsOfService => 'תנאי שימוש';
  String get privacyPolicy => 'מדיניות פרטיות';

  // Accessibility
  String get logoLabel => 'לוגו אפליקציית MemoZap';
  String socialLoginButtonLabel(String provider) => 'התחבר עם $provider';

  // ⚠️ DEPRECATED: Guest mode removed - auth is required
  @Deprecated('Guest mode removed - auth is required')
  String get guestButton => 'המשך כאורח';
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
  String get phoneLabel => 'טלפון';
  String get phoneHint => '050-1234567';

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
  String get phoneRequired => 'שדה חובה';
  String get phoneInvalid => 'מספר טלפון לא תקין (05X-XXXXXXX)';

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

  // ⚠️ DEPRECATED: Guest mode removed - auth is required
  @Deprecated('Guest mode removed - auth is required')
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
  String get addLocationButton => 'הוסף';
  String get addLocationTitle => 'הוספת מיקום חדש';
  String get locationNameLabel => 'שם המיקום';
  String get locationNameHint => 'לדוגמה: "מקרר קטן"';
  String get selectEmojiLabel => 'בחר אמוג\'י:';
  String get locationAdded => 'מיקום חדש נוסף בהצלחה! 📍';
  String get locationExists => 'מיקום זה כבר קיים';
  String get locationNameRequired => 'נא להזין שם מיקום';

  // ========================================
  // Filters (PantryFilters widget)
  // ========================================

  String get filterLabel => 'סינון מזווה';
  String get filterByCategory => 'סינון לפי קטגוריה';

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

  // ========================================
  // Storage Location Manager
  // ========================================

  // Note: StorageManager strings removed - not currently in use

  // ========================================
  // Pantry Product Selection (Catalog)
  // ========================================

  String get addFromCatalogTitle => 'הוספה מהקטלוג';
  String get searchProductsHint => 'חיפוש מוצר...';
  String get loadingProducts => 'טוען מוצרים...';
  String get noProductsFound => 'לא נמצאו מוצרים';
  String get noProductsAvailable => 'אין מוצרים זמינים';
  String productAddedSuccess(String name) => '$name נוסף למזווה!';

  // ========================================
  // Smart Suggestions (Stock Descriptions)
  // ========================================

  String get stockOutOfStock => 'נגמר! צריך לקנות';
  String stockOnlyOneLeft(String unit) => 'נשאר 1 $unit בלבד';
  String stockOnlyFewLeft(int count, String unit) => 'נשארו רק $count $unit';

  // ========================================
  // Expiry Alert Dialog
  // ========================================

  String get expiryAlertTitleExpired => 'פג תוקף!';
  String get expiryAlertTitleExpiringSoon => 'תפוגה קרובה';
  String expiryAlertSubtitle(int expiredCount, int expiringSoonCount) {
    final parts = <String>[];
    if (expiredCount > 0) parts.add('$expiredCount פג תוקף');
    if (expiringSoonCount > 0) parts.add('$expiringSoonCount קרוב לתפוגה');
    return parts.join(' | ');
  }
  String get expiryAlertGoToPantry => 'עבור למזווה';
  String get expiryAlertDismissToday => 'אל תציג שוב היום';
  String expiryAlertMoreItems(int count) => 'הצג עוד $count מוצרים...';

  // Expiry status text
  String get expiryExpiredToday => 'פג היום';
  String get expiryExpiredYesterday => 'פג אתמול';
  String expiryExpiredDaysAgo(int days) => 'פג לפני $days ימים';
  String get expiryExpiresToday => 'פג היום!';
  String get expiryExpiresTomorrow => 'פג מחר';
  String expiryExpiresInDays(int days) => 'פג בעוד $days ימים';

  // ========================================
  // Inventory Settings Dialog
  // ========================================

  String get settingsTitle => 'הגדרות מזווה';

  // Pantry Mode
  String get pantryModePersonal => 'מזווה אישי - רק שלך';
  String get pantryModeGroup => 'מחובר למזווה משותף של הקבוצה';

  // Alerts Section
  String get alertsSectionTitle => 'התראות';
  String get settingsLowStockAlertTitle => 'התראת מלאי נמוך';
  String get settingsLowStockAlertSubtitle => 'קבל התראה כשפריט מגיע למינימום';
  String get settingsExpiryAlertTitle => 'התראת תפוגה';
  String get settingsExpiryAlertSubtitle => 'קבל התראה על מוצרים שעומדים לפוג';
  String get settingsExpiryAlertDaysPrefix => 'התראה ';
  String get settingsExpiryAlertDaysSuffix => ' ימים לפני תפוגה';

  // Display Section
  String get displaySectionTitle => 'תצוגה';
  String get showExpiredFirstTitle => 'הצג פגי תוקף ראשונים';
  String get showExpiredFirstSubtitle => 'פריטים שפג תוקפם יופיעו בראש הרשימה';

  // ========================================
  // Inventory Transfer Dialog
  // ========================================

  String get transferDialogTitle => 'המזווה שלך';
  String transferDialogItemCount(int count) =>
      count == 1 ? 'פריט אחד' : '$count פריטים';
  String transferDialogDescription(String groupName, int count) =>
      'אתה מצטרף ל"$groupName" שיש לה מזווה משותף.\n'
      'מה ברצונך לעשות עם ${count == 1 ? "הפריט" : "$count הפריטים"} במזווה האישי שלך?';
  String get transferOptionTitle => 'העבר למזווה הקבוצה';
  String get transferOptionSubtitle => 'כל הפריטים יועברו למזווה המשותף';
  String get deleteOptionTitle => 'מחק את המזווה האישי';
  String get deleteOptionSubtitle => 'התחל מחדש עם המזווה המשותף';
  String get cancelJoinOption => 'ביטול - לא להצטרף';

  // Delete Confirmation Sub-dialog
  String get deleteConfirmTitle => 'אישור מחיקה';
  String deleteConfirmMessage(int count) =>
      'האם אתה בטוח שברצונך למחוק ${count == 1 ? "פריט אחד" : "$count פריטים"} מהמזווה האישי?\n\nפעולה זו לא ניתנת לביטול.';
  String get deleteConfirmButton => 'מחק הכל';

  // ========================================
  // Low Stock Alert Dialog
  // ========================================

  String get lowStockAlertTitle => 'מלאי נמוך';
  String lowStockAlertSubtitle(int count) => '$count מוצרים עומדים להיגמר';
  String get lowStockAlertAddToList => 'הוסף לרשימה';
  String get lowStockAlertGoToPantry => 'למזווה';
  String get lowStockAlertDismissToday => 'אל תציג שוב היום';
  String lowStockAlertMoreItems(int count) => 'ועוד $count מוצרים...';

  // ========================================
  // Storage Locations
  // ========================================

  String get locationMainPantry => 'מזווה';
  String get locationMainPantryDesc => 'מזווה ראשי - מוצרים יבשים';
  String get locationRefrigerator => 'מקרר';
  String get locationRefrigeratorDesc => 'מקרר - מוצרים טריים';
  String get locationFreezer => 'מקפיא';
  String get locationFreezerDesc => 'מקפיא - מוצרים קפואים';
  String get locationOther => 'אחר';
  String get locationOtherDesc => 'מיקום אחר';
  String get locationUnknown => 'לא ידוע';
  String get locationUnknownDesc => 'מיקום לא מוכר';
}

// ========================================
// Shopping List Details Strings
// ========================================

class _ShoppingListDetailsStrings {
  const _ShoppingListDetailsStrings();

  // ========================================
  // Dialogs - Product
  // ========================================

  String get addProductTitle => 'הוספת מוצר';
  String get editProductTitle => 'עריכת מוצר';
  String get productNameLabel => 'שם מוצר';
  String get brandLabel => 'חברה/מותג (אופציונלי)';
  String get categoryLabel => 'קטגוריה';
  String get selectCategory => 'בחר קטגוריה';
  String get quantityLabel => 'כמות';
  String get priceLabel => 'מחיר ליחידה';

  // ========================================
  // Dialogs - Task
  // ========================================

  String get addTaskTitle => 'הוספת משימה';
  String get editTaskTitle => 'עריכת משימה';
  String get taskNameLabel => 'שם משימה';
  String get notesLabel => 'הערות (אופציונלי)';
  String get dueDateLabel => 'בחר תאריך יעד (אופציונלי)';
  String dueDateSelected(String date) => 'תאריך יעד: $date';
  String get priorityLabel => 'עדיפות';
  String get priorityLow => '🟢 נמוכה';
  String get priorityMedium => '🟡 בינונית';
  String get priorityHigh => '🔴 גבוהה';

  // ========================================
  // Validation Messages
  // ========================================

  String get productNameEmpty => 'שם המוצר לא יכול להיות ריק';
  String get quantityInvalid => 'כמות לא תקינה (1-9999)';
  String get priceInvalid => 'מחיר לא תקין (חייב להיות מספר חיובי)';
  String get taskNameEmpty => 'שם המשימה לא יכול להיות ריק';

  // ========================================
  // Search & Filters
  // ========================================

  String get searchHint => 'חפש פריט...';
  String get sortButton => 'מיין';
  String get sortNone => 'ללא מיון';
  String get sortPriceDesc => 'מחיר (יקר→זול)';
  String get sortStatus => 'סטטוס (לא נסומן קודם)';
  String itemsCount(int count) => '$count פריטים';

  // ========================================
  // Categories with Emoji
  // ========================================

  String get categoryAll => 'הכל';
  String get categoryVegetables => 'ירקות ופירות';
  String get categoryMeat => 'בשר ודגים';
  String get categoryDairy => 'חלב וביצים';
  String get categoryBakery => 'לחם ומאפים';
  String get categoryCanned => 'שימורים';
  String get categoryFrozen => 'קפואים';
  String get categoryCleaning => 'ניקיון';
  String get categoryHygiene => 'היגיינה';
  String get categoryOther => 'אחר';

  // ========================================
  // Actions
  // ========================================

  String get addProductButton => 'הוסף מוצר';
  String get addTaskButton => 'הוסף משימה';
  String get shareListTooltip => 'שתף רשימה';
  String get addFromCatalogTooltip => 'הוסף מהקטלוג';
  String get searchTooltip => 'חיפוש';
  String get editTooltip => 'ערוך';
  String get deleteTooltip => 'מחק';

  // ========================================
  // Delete Confirmation
  // ========================================

  String get deleteTitle => 'מחיקת מוצר';
  String deleteMessage(String name) => 'האם למחוק את "$name"?';
  String itemDeleted(String name) => 'המוצר "$name" נמחק';

  // ========================================
  // Item Display
  // ========================================

  String quantityDisplay(int quantity) => 'כמות: $quantity';
  String get taskLabel => 'משימה';
  String get totalLabel => 'סה״כ:';

  // ========================================
  // Empty States
  // ========================================

  String get emptyListTitle => 'הרשימה ריקה';
  String get emptyListMessage => 'לחץ על "הוסף מוצר" להתחלה';
  String get emptyListSubMessage => 'או אכלס מהקטלוג:';
  String get populateFromCatalog => 'אכלס מהקטלוג';

  String get noSearchResultsTitle => 'לא נמצאו פריטים';
  String get noSearchResultsMessage => 'נסה לשנות את החיפוש';
  String get clearSearchButton => 'נקה חיפוש';

  // ========================================
  // Loading & Error States
  // ========================================

  String get loadingError => 'שגיאה בטעינת הנתונים';
  String get errorTitle => 'אופס! משהו השתבש';
  String errorMessage(String? error) => error ?? 'אירעה שגיאה בטעינת הנתונים';
}



// ========================================
// User Sharing System Strings (Phase 3B)
// ========================================

class _SharingStrings {
  const _SharingStrings();

  // ========================================
  // User Roles - Labels
  // ========================================

  String get roleOwner => 'בעלים';
  String get roleAdmin => 'מנהל';
  String get roleEditor => 'עורך';
  String get roleViewer => 'צופה';

  // ========================================
  // User Roles - Descriptions
  // ========================================

  String get roleOwnerDesc => 'גישה מלאה + מחיקת רשימה + ניהול משתמשים';
  String get roleAdminDesc => 'גישה מלאה + ניהול משתמשים (ללא מחיקה)';
  String get roleEditorDesc => 'קריאה + הוספת פריטים דרך בקשות (צריך אישור)';
  String get roleViewerDesc => 'קריאה בלבד (לא יכול לערוך כלום)';

  // ========================================
  // Invite Users Screen
  // ========================================

  String get inviteTitle => 'הזמנת משתמשים';
  String get inviteSubtitle => 'הזמן אנשים לשתף את הרשימה';
  String get emailLabel => 'אימייל';
  String get emailHint => 'example@email.com';
  String get emailRequired => 'נא להזין כתובת אימייל';
  String get emailInvalid => 'אימייל לא תקין';
  String get selectRoleLabel => 'בחר תפקיד';
  String get inviteButton => 'שלח הזמנה';
  String get inviting => 'שולח...';
  String get cancelButton => 'ביטול';

  // Success Messages
  String inviteSent(String email) => 'ההזמנה נשלחה ל-$email 📧';
  String inviteResent(String email) => 'ההזמנה נשלחה שוב ל-$email';

  // Error Messages
  String get userNotFound => 'משתמש לא נמצא במערכת';
  String get userAlreadyInList => 'המשתמש כבר ברשימה';
  String get cannotInviteSelf => 'לא ניתן להזמין את עצמך';
  String inviteError(String error) => 'שגיאה בשליחת הזמנה: $error';

  // ========================================
  // Manage Users Screen
  // ========================================

  String get manageUsersTitle => 'ניהול משתמשים';
  String usersCount(int count) => '$count משתמשים';
  String get inviteUserButton => 'הזמן משתמש';
  String get searchUserHint => 'חפש משתמש...';
  String get noUsers => 'אין משתמשים ברשימה';
  String get ownerLabel => '(אתה)';

  // User Actions
  String get changeRoleTooltip => 'שנה תפקיד';
  String get removeUserTooltip => 'הסר משתמש';
  String get resendInviteTooltip => 'שלח הזמנה שוב';

  // Change Role Dialog
  String get changeRoleTitle => 'שינוי תפקיד';
  String changeRoleMessage(String userName) => 'בחר תפקיד חדש עבור $userName:';
  String get changeRoleButton => 'שנה';
  String roleChanged(String userName, String newRole) => '$userName עודכן ל-$newRole';
  String changeRoleError(String error) => 'שגיאה בשינוי תפקיד: $error';

  // Remove User Dialog
  String get removeUserTitle => 'הסרת משתמש';
  String removeUserMessage(String userName) => 'האם להסיר את $userName מהרשימה?';
  String get removeButton => 'הסר';
  String userRemoved(String userName) => '$userName הוסר מהרשימה';
  String removeUserError(String error) => 'שגיאה בהסרת משתמש: $error';

  // Restrictions
  String get cannotChangeOwnRole => 'לא ניתן לשנות את התפקיד שלך';
  String get cannotRemoveSelf => 'לא ניתן להסיר את עצמך';
  String get cannotRemoveOwner => 'לא ניתן להסיר את הבעלים';
  String get noPermissionInvite => 'רק הבעלים יכול להזמין משתמשים';
  String get onlyOwnerCanDelete => 'רק הבעלים יכול למחוק את הרשימה';

  // ========================================
  // Pending Requests Screen
  // ========================================

  String get pendingRequestsTitle => 'בקשות ממתינות';
  String get noPermissionViewRequests => 'רק בעלים/מנהלים יכולים לראות בקשות';
  String pendingCount(int count) => '$count בקשות';
  String get noPendingRequests => 'אין בקשות ממתינות';
  String get noPendingMessage => 'כשעורכים יוסיפו פריטים, הם יופיעו כאן לאישור';
  String get noPendingRequestsSubtitle => 'בקשות מעורכים יופיעו כאן לאישור';

  // Request Types
  String get requestTypeAdd => 'הוספה';
  String get requestTypeEdit => 'עריכה';
  String get requestTypeDelete => 'מחיקה';

  // Request Card
  String requestedBy(String userName) => 'נתבקש על ידי $userName';
  String requestedAt(String time) => 'לפני $time';
  String get viewDetailsButton => 'פרטים';
  String get approveButton => 'אשר ✅';
  String get rejectButton => 'דחה ❌';

  // Request Details Dialog
  String get requestDetailsTitle => 'פרטי בקשה';
  String get itemNameLabel => 'שם פריט';
  String get quantityLabel => 'כמות';
  String get categoryLabel => 'קטגוריה';
  String get priceLabel => 'מחיר';
  String get notesLabel => 'הערות';
  String get closeButton => 'סגור';

  // Approve/Reject
  String requestApproved(String itemName) => '✅ הבקשה להוספת "$itemName" אושרה';
  String get requestApprovedSuccess => 'הבקשה אושרה בהצלחה';
  String get requestApprovedError => 'שגיאה באישור הבקשה';
  String requestRejected(String itemName) => '❌ הבקשה להוספת "$itemName" נדחתה';
  String get requestRejectedSuccess => 'הבקשה נדחתה';
  String get requestRejectedError => 'שגיאה בדחיית הבקשה';
  String approveError(String error) => 'שגיאה באישור: $error';
  String rejectError(String error) => 'שגיאה בדחייה: $error';

  // Bulk Actions
  String get approveAllButton => 'אשר הכל';
  String get rejectAllButton => 'דחה הכל';
  String get approveAllConfirm => 'לאשר את כל הבקשות?';
  String get rejectAllConfirm => 'לדחות את כל הבקשות?';
  String get rejectDialogTitle => 'דחיית בקשה';
  String get rejectDialogMessage => 'למה לדחות את הבקשה? (אופציונלי)';
  String get rejectReasonHint => 'סיבת הדחייה...';
  String allApproved(int count) => '✅ $count בקשות אושרו';
  String allRejected(int count) => '❌ $count בקשות נדחו';

  // ========================================
  // Permission Validation Messages
  // ========================================

  String get noPermissionTitle => 'אין הרשאה';
  String get editorCannotAddDirectly => 'עורכים יכולים להוסיף פריטים רק דרך בקשות שדורשות אישור';
  String get viewerCannotEdit => 'צופים יכולים לראות את הרשימה בלבד, ללא אפשרות עריכה';
  String get editorCannotEditExisting => 'עורכים לא יכולים לערוך פריטים קיימים';
  String get editorCannotDelete => 'עורכים לא יכולים למחוק פריטים';
  String get viewerCannotDelete => 'צופים לא יכולים למחוק פריטים';
  String get onlyOwnerCanChangePermissions => 'רק הבעלים יכול לשנות הרשאות';
  String get mustBeOwnerOrAdmin => 'חייבים להיות בעלים או מנהל לביצוע פעולה זו';

  // Request Creation
  String get requestCreated => 'הבקשה נשלחה לאישור הבעלים/מנהלים';
  String get requestWaitingApproval => 'הפריט ימתין לאישור לפני שיופיע ברשימה';
  String requestCreationError(String error) => 'שגיאה ביצירת בקשה: $error';

  // ========================================
  // Sharing Notifications
  // ========================================

  String get notificationInviteTitle => 'הזמנה לרשימה משותפת';
  String notificationInviteBody(String listName, String inviterName) =>
      '$inviterName הזמין אותך לרשימה "$listName"';

  String get notificationRequestApprovedTitle => 'בקשה אושרה';
  String notificationRequestApprovedBody(String itemName, String listName) =>
      'הבקשה שלך להוסיף "$itemName" ל"$listName" אושרה ✅';

  String get notificationRequestRejectedTitle => 'בקשה נדחתה';
  String notificationRequestRejectedBody(String itemName, String listName) =>
      'הבקשה שלך להוסיף "$itemName" ל"$listName" נדחתה ❌';

  String get notificationNewRequestTitle => 'בקשה חדשה';
  String notificationNewRequestBody(String requesterName, String itemName) =>
      '$requesterName ביקש להוסיף "$itemName" לרשימה';

  String get notificationRoleChangedTitle => 'התפקיד שלך שונה';
  String notificationRoleChangedBody(String newRole, String listName) =>
      'התפקיד שלך ב"$listName" שונה ל-$newRole';

  String get notificationRemovedTitle => 'הוסרת מרשימה';
  String notificationRemovedBody(String listName) =>
      'הוסרת מהרשימה "$listName"';

  // ========================================
  // Shared List Indicators
  // ========================================

  String get sharedListBadge => 'משותפת';
  String sharedWith(int count) => 'משותפת עם $count אנשים';
  String get youAreOwner => 'אתה הבעלים';
  String get youAreAdmin => 'אתה מנהל';
  String get youAreEditor => 'אתה עורך';
  String get youAreViewer => 'אתה צופה';

  // ========================================
  // Loading & Error States
  // ========================================

  String get loadingUsers => 'טוען משתמשים...';
  String get loadingRequests => 'טוען בקשות...';
  String get loadingError => 'שגיאה בטעינת נתונים';
  String get retryButton => 'נסה שוב';
}
