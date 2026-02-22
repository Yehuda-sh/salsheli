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
  // Manage Users
  // ========================================

  static const manageUsers = _ManageUsersStrings();

  // ========================================
  // Inventory (Pantry)
  // ========================================

  static const inventory = _InventoryStrings();

  // ========================================
  // Shopping List Details
  // ========================================

  static const listDetails = _ShoppingListDetailsStrings();

  // ========================================
  // Select List Dialog
  // ========================================

  static const selectList = _SelectListStrings();

  // ========================================
  // Recurring Product Dialog
  // ========================================

  static const recurring = _RecurringStrings();

  // ========================================
  // User Sharing System (Phase 3B)
  // ========================================

  static const sharing = _SharingStrings();

  // ========================================
  // Receipt Details Screen
  // ========================================

  static const receiptDetails = _ReceiptDetailsStrings();

  // ========================================
  // Shopping History
  // ========================================

  static const shoppingHistory = _ShoppingHistoryStrings();

  // ========================================
  // Active Shopper Banner
  // ========================================

  static const activeShopperBanner = _ActiveShopperBannerStrings();

  // ========================================
  // Suggestions Today Card (Dashboard)
  // ========================================

  static const suggestionsToday = _SuggestionsTodayCardStrings();

  // ========================================
  // Last Chance Banner
  // ========================================

  static const lastChanceBanner = _LastChanceBannerStrings();

  // ========================================
  // Pending Invite Banner
  // ========================================

  static const pendingInviteBanner = _PendingInviteBannerStrings();

  // ========================================
  // Pending Invites Screen
  // ========================================

  static const pendingInvitesScreen = _PendingInvitesScreenStrings();

  // ========================================
  // Home Dashboard Screen
  // ========================================

  static const homeDashboard = _HomeDashboardStrings();

  // ========================================
  // Notifications Center Screen
  // ========================================

  static const notificationsCenter = _NotificationsCenterStrings();

  // ========================================
  // Pantry Screen
  // ========================================

  static const pantry = _PantryStrings();

  // ========================================
  // Checklist Screen
  // ========================================

  static const checklist = _ChecklistStrings();

  // ========================================
  // Contact Selector Dialog
  // ========================================

  static const contactSelector = _ContactSelectorStrings();

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

  // Logout Error
  String get logoutError => 'שגיאה בהתנתקות, נסה שוב';

  // Pending Invites Menu
  String get pendingInvitesTitle => 'הזמנות ממתינות';
  String get groupInvites => 'הזמנות לקבוצות';
  String get groupInvitesSubtitle => 'הצטרפות למשפחה / Household';
  String get listInvites => 'הזמנות לרשימות';
  String get listInvitesSubtitle => 'שיתוף רשימות קניות';

  // Accessibility
  String navSemanticLabel(String selectedTab) => 'ניווט ראשי. טאב נבחר: $selectedTab';
  String get navSemanticHint => 'החלק ימינה או שמאלה לבחירת טאב אחר';
  String get longPressHint => 'לחיצה ארוכה לפעולות נוספות';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class _NavigationStrings {
  const _NavigationStrings();

  String get home => 'בית';
  String get family => 'משפחה';
  String get groups => 'קבוצות'; // 🗑️ Deprecated - keeping for backwards compatibility
  String get lists => 'רשימות';
  String get pantry => 'מזווה';
  String get receipts => 'קבלות';
  String get history => 'היסטוריה';
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
  String get categoryUnknown => 'לא ידוע';
  String get syncError => 'בעיית סנכרון - השינויים נשמרו מקומית';
  String get saveFailed => 'השמירה נכשלה, נסה שוב';

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
  String stepProgress(int current, int total) => 'שלב $current/$total';
  String stepAccessibilityLabel(int current, int total) => 'שלב $current מתוך $total';

  // Errors
  String savingError(String error) => 'שמירת ההגדרות נכשלה: $error';
  String get skipError => 'לא ניתן לדלג';

  // Welcome Step
  String get welcomeTitle => 'ברוכים הבאים ל־MemoZap 🎉';
  String get welcomeSubtitle =>
      'ניהול רשימות מעולם לא היה קל כל כך! 🎉\n🛒 קניות • 📝 מטלות • 🎁 אירועים - עם בת הזוג, המשפחה, החברים או כל קבוצה';

  // Family Size Step
  String get familySizeTitle => 'כמה אנשים במשפחה?';
  String get hasChildrenQuestion => 'יש לכם ילדים?';
  String get addChild => 'הוסף ילד נוסף';
  String childLabel(int index) => 'ילד $index';
  String get childNameLabel => 'שם';
  String get childAgeLabel => 'גיל';
  String get ageBaby => 'תינוק/ת (0-1)';
  String get ageToddler => 'גיל הרך (2-3)';
  String get agePreschool => 'גן (4-6)';
  String get ageSchool => 'בית ספר (7-12)';
  String get ageTeen => 'נוער (13-18)';

  // Stores Step
  String get storesTitle => 'בחר חנויות מועדפות:';

  // Budget Step
  String get budgetTitle => 'מה התקציב החודשי שלך?';
  String budgetAmount(double amount) => '${amount.toStringAsFixed(0)} ₪';

  // Categories Step
  String get categoriesTitle => 'אילו קטגוריות חשובות לכם במיוחד?';

  // Shopping Frequency Step
  String get frequencyTitle => 'תדירות קניות';
  String get frequencyQuestion => 'כמה פעמים בשבוע אתם קונים קניות?';
  String frequencyPerWeek(int count) => '$count פעמים בשבוע';
  String get fixedDaysQuestion => 'יש לכם ימים קבועים לקניות?';
  String get multiSelectHint => '(בחירה מרובה)';

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
  String frequencySummary(int count) => 'תדירות: $count פעמים בשבוע';
  String fixedDaysSummary(String days) => 'ימים קבועים: $days';
  String childrenSummary(String children) => 'ילדים: $children';
  String get childrenYes => 'כן';
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
  String get itemStatusPurchased => 'קנוי';
  String get itemStatusOutOfStock => 'אזל';
  String get itemStatusNotNeeded => 'לא צריך';

  // Unknown Items (server fallback)
  String get unknownItemsSection => 'פריטים לא נתמכים';
  String get unknownItemsHint => 'סוג הפריט לא מוכר - ייתכן שנדרש עדכון אפליקציה';
  String unknownItemsCount(int count) => count == 1 ? 'פריט לא נתמך' : '$count פריטים לא נתמכים';

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
  String get viewerCannotShop => 'צופים לא יכולים להשתתף בקנייה';
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

  // Limits
  String maxItemsReached(int max) => 'הגעת למקסימום $max פריטים ברשימה';
  String maxListsReached(int max) => 'הגעת למקסימום $max רשימות פעילות';

  // Limit Warnings (80%)
  String itemsNearLimit(int current, int max) =>
      'יש לך $current מתוך $max פריטים ברשימה';
  String listsNearLimit(int current, int max) =>
      'יש לך $current מתוך $max רשימות פעילות';

  // ========================================
  // Active Shopping - Sync & Messages
  // ========================================

  String get syncSuccess => 'הסנכרון הצליח!';
  String get syncErrorTooltip => 'לא מסונכרן - לחץ לנסות שוב';
  String get shoppingSaved => 'הקנייה נשמרה';
  String pendingItemsLeftWarning(int count) => '$count פריטים נשארו והרשימה פעילה';

  // ========================================
  // Active Shopping - Icon Legend
  // ========================================

  String get legendPurchased => 'קניתי';
  String get legendOutOfStock => 'אין במלאי';
  String get legendNotNeeded => 'לא צריך';

  // ========================================
  // Active Shopping - Semantics Labels
  // ========================================

  String get retryLoadSemantics => 'נסה לטעון שוב';
  String get backToListSemantics => 'חזור לרשימה';
  String get finishAndSaveSemantics => 'סיים קנייה ושמור';
  String purchasedToggleSemantics(String itemName, bool isPurchased) =>
      isPurchased ? 'בטל סימון קניתי עבור $itemName' : 'סמן $itemName כנקנה';
  String outOfStockToggleSemantics(String itemName, bool isOutOfStock) =>
      isOutOfStock ? 'בטל סימון אין במלאי עבור $itemName' : 'סמן $itemName כאין במלאי';
  String notNeededToggleSemantics(String itemName, bool isNotNeeded) =>
      isNotNeeded ? 'בטל סימון לא צריך עבור $itemName' : 'סמן $itemName כלא צריך';
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

  // UI - Loading
  String get loading => 'טוען...';

  // 🔧 Loading Messages (rotating)
  List<String> get loadingMessages => const [
        'בודק מצב...',
        'מתחבר...',
        'כמעט מוכן...',
      ];

  // 🔧 Error Screen
  String get errorTitle => 'אופס! משהו השתבש';
  String get errorMessage => 'לא הצלחנו לטעון את האפליקציה';
  String get retryButton => 'נסה שוב';
  String get retryLabel => 'נסה שוב לטעון את האפליקציה';
  String get retryHint => 'לחץ כדי לנסות שוב';
}

// ========================================
// Welcome Strings
// ========================================

class _WelcomeStrings {
  const _WelcomeStrings();

  // Screen
  String get title => 'MemoZap';
  String get subtitle => 'רשימות משותפות. מקום אחד.';

  // Feature Cards - Updated Version (27/01/2026) - No Groups
  // 🎯 Focus on core features: shopping lists, pantry, family sharing
  // 🛒 Shopping Lists, 📦 Pantry, 👨‍👩‍👧‍👦 Family Sharing

  // Shopping Lists Card
  String get group1Emoji => '🛒';
  String get group1Title => 'רשימות קניות';
  String get group1Question => '"מה צריך לקנות?"';
  String get group1Feature1 => 'פריטים ✅';
  String get group1Feature2 => 'כמויות 🔢';

  // Pantry Card
  String get group2Emoji => '📦';
  String get group2Title => 'מזווה דיגיטלי';
  String get group2Question => '"מה חסר בבית?"';
  String get group2Feature1 => 'מלאי 📊';
  String get group2Feature2 => 'תזכורות ⏰';

  // Family Sharing Card
  String get group3Emoji => '👨‍👩‍👧‍👦';
  String get group3Title => 'שיתוף משפחתי';
  String get group3Question => '"מי בקבוצה?"';
  String get group3Feature1 => 'זמן אמת 🔄';
  String get group3Feature2 => 'סנכרון ☁️';

  // More features hint
  String get moreGroupsHint => 'פשוט ונוח - בלי סיבוכים';

  // Demo data for mini previews (Welcome screen)
  String get demoListHeader => '🛒 סופר';
  String get demoItem1 => 'חלב';
  String get demoItem2 => 'לחם';
  String get demoItem3 => 'ביצים';

  String get demoPantryHeader => '📦 מזווה';
  String get demoPantryItem1 => 'חלב';
  String get demoPantryItem2 => 'ביצים';
  String get demoPantryItem3 => 'לחם';

  String get demoFamilyHeader => '👨‍👩‍👧‍👦 משפחה';
  String get demoUser1 => 'אבא';
  String get demoUser2 => 'אמא';
  String get demoUser3 => 'דני';

  String get statusOnline => 'מחובר';
  String get statusOffline => 'לא מחובר';

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
  String get loginSubtitle => 'נעים לראות אותך שוב 👋';
  String get loginButton => 'התחבר';

  // ========================================
  // Register Screen
  // ========================================

  String get registerTitle => 'הרשמה';
  String get registerSubtitle => 'צור חשבון חדש ותוכל לשתף ולנהל רשימות יחד עם אחרים ✨';
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
  String get orContinueWith => 'או הירשם במהירות עם';

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
  String get errorTimeout => 'הפעולה נכשלה - נסה שוב';
  String get errorNoUserLoggedIn => 'אין משתמש מחובר';

  // Social Login Errors
  String get socialLoginCancelled => 'ההתחברות בוטלה';
  String get socialLoginError => 'שגיאה בהתחברות';

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

  // ========================================
  // Login Screen - Additional
  // ========================================

  String get loginSuccessRedirect => 'התחברת בהצלחה! מעביר לדף הבית...';
  String get googleLoginSuccess => 'התחברת בהצלחה עם Google!';
  String get appleLoginSuccess => 'התחברת בהצלחה עם Apple!';
  String get orLoginWith => 'או התחבר עם';
  String get showPassword => 'הצג סיסמה';
  String get hidePassword => 'הסתר סיסמה';
  String get enterEmailFirst => 'אנא הזן את כתובת האימייל שלך בשדה למעלה';
  String resetEmailSentTo(String email) => 'נשלח מייל לאיפוס סיסמה ל-$email';
  String get resetEmailSendError => 'שגיאה בשליחת מייל איפוס';

  // ========================================
  // Accessibility Labels
  // ========================================

  String get forgotPasswordSemanticLabel => 'שכחת סיסמה? לחץ לקבלת מייל איפוס';
  String get forgotPasswordSemanticHint => 'שולח קישור לאיפוס סיסמה לאימייל שהוזן';
  String socialLoginSemanticLabel(String provider) => 'התחבר באמצעות $provider';

  // ========================================
  // Register Screen - Additional
  // ========================================

  String get registerSuccessRedirect => 'הרשמת בהצלחה! מעביר לדף הבית...';
  String get pendingInvitesDialogTitle => 'הזמנות ממתינות!';
  String pendingInvitesDialogContent(int count) =>
      'יש לך $count הזמנות לקבוצות ממתינות לאישור.\n\nהאם לעבור למסך ההזמנות?';
  String get pendingInvitesLater => 'אחר כך';
  String get pendingInvitesView => 'צפה בהזמנות';
  String get phoneHelperText => 'מספר נייד ישראלי - לקבלת עדכונים מהקבוצות';

  // ========================================
  // Register Screen - Accessibility Labels
  // ========================================

  String get nameFieldSemanticLabel => 'שדה שם מלא, חובה';
  String get emailFieldSemanticLabel => 'שדה כתובת אימייל, חובה';
  String get passwordFieldSemanticLabel => 'שדה סיסמה, לפחות 6 תווים';
  String get confirmPasswordFieldSemanticLabel => 'שדה אימות סיסמה, חייב להתאים לסיסמה';
  String get phoneFieldSemanticLabel => 'שדה טלפון נייד ישראלי, חובה';
  String get loginLinkSemanticLabel => 'יש לך חשבון? לחץ לעבור למסך התחברות';
  String socialRegisterSemanticLabel(String provider) => 'הירשם או התחבר באמצעות $provider';
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

  // Notifications Section
  String get notificationsSectionTitle => 'התראות';
  String get notifyShoppingTitle => 'התראות קנייה';
  String get notifyShoppingSubtitle => 'כשמישהו מסיים קנייה';
  String get notifyInventoryTitle => 'התראות מלאי';
  String get notifyInventorySubtitle => 'כשמוצר במזווה אוזל';
  String get notifyGroupTitle => 'התראות קבוצה';
  String get notifyGroupSubtitle => 'הזמנות וחברים חדשים';

  // General Settings Section
  String get generalSettingsSectionTitle => 'הגדרות כלליות';
  String get themeLabel => 'ערכת נושא';
  String get themeLight => 'בהיר';
  String get themeDark => 'כהה';
  String get themeSystem => 'מערכת';

  // Household Management Section (ניהול משפחה)
  String get householdManagementTitle => 'ניהול משפחה';
  String get householdMembersTitle => 'חברי המשפחה';
  String get householdMembersSubtitle => 'הוסף והסר חברים';
  String get householdInviteTitle => 'הזמן חברים';
  String get householdInviteSubtitle => 'שלח הזמנה להצטרף';
  String get householdComingSoon => 'ניהול מלא - בקרוב!';

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

  // Delete Account (GDPR)
  String get deleteAccountTitle => 'מחיקת חשבון';
  String get deleteAccountSubtitle => 'מחיקת כל הנתונים לצמיתות';
  String get deleteAccountWarning => 'פעולה זו תמחק לצמיתות את:\n• כל הרשימות שיצרת\n• היסטוריית הקניות\n• המזווה שלך\n• כל הנתונים האישיים\n\nלא ניתן לשחזר את הנתונים!';
  String get deleteAccountConfirmLabel => 'הקלד "מחק את החשבון" לאישור:';
  String get deleteAccountConfirmText => 'מחק את החשבון';
  String get deleteAccountButton => 'מחק חשבון לצמיתות';
  String get deleteAccountSuccess => 'החשבון נמחק בהצלחה';
  String deleteAccountError(String error) => 'שגיאה במחיקת החשבון: $error';
  String get deleteAccountRequiresReauth => 'נדרשת התחברות מחדש לפני מחיקת החשבון';

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

  // ========================================
  // Template Section
  // ========================================

  String get removeTemplateTooltip => 'הסר תבנית';

  // ========================================
  // Visibility Section
  // ========================================

  String get visibilityLabel => 'מי יראה את הרשימה?';
  String get visibilityPrivate => '🔒 אישית';
  String get visibilityHousehold => '👨‍👩‍👧 משפחתית';
  String get visibilityShared => '👥 שיתוף';
  String get visibilityPrivateDesc => 'רק אתה תראה את הרשימה הזו';
  String get visibilityHouseholdDesc => 'כל המשפחה תוכל לראות ולערוך';
  String get visibilitySharedDesc => 'שתף עם אנשים ספציפיים (ללא גישה למזווה שלך)';

  // ========================================
  // Event Mode Section
  // ========================================

  String get eventModeLabel => 'איך תנהלו את הרשימה?';
  String get eventModeWhoBrings => 'מי מביא מה';
  String get eventModeWhoBringsDesc => 'כל משתתף מתנדב להביא פריטים';
  String get eventModeShopping => 'קנייה רגילה';
  String get eventModeShoppingDesc => 'אדם אחד קונה את כל הרשימה';
  String get eventModeTasks => 'משימות אישיות';
  String get eventModeTasksDesc => 'צ\'קליסט פשוט רק לי';
  String get recommended => 'מומלץ';

  // ========================================
  // Contact Picker Section
  // ========================================

  String get selectContactsButton => 'בחר אנשים לשיתוף';
  String get addMoreContactsButton => 'הוסף עוד אנשים';
  String get pendingInviteNote => 'משתמשים שאינם רשומים יקבלו הזמנה ממתינה';
}

// ========================================
// Manage Users Strings
// ========================================

class _ManageUsersStrings {
  const _ManageUsersStrings();

  // ========================================
  // Screen Title
  // ========================================

  String get title => 'ניהול משתמשים';

  // ========================================
  // User Display
  // ========================================

  String get me => 'אני';
  String get you => 'אתה';
  String userShortId(String shortId) => 'משתמש #$shortId';
  String get defaultUserName => 'משתמש';

  // ========================================
  // Error Messages
  // ========================================

  String get errorUserNotLoggedIn => 'שגיאה: משתמש לא מחובר';
  String get errorNoPermissionRemove => 'אין לך הרשאה להסיר משתמשים';
  String get errorNoPermissionEditRole => 'אין לך הרשאה לשנות תפקידים';
  String get errorNoHousehold => 'שגיאה: משתמש לא משויך למשק בית';
  String errorRemovingUser(String error) => 'שגיאה בהסרת משתמש: $error';
  String errorUpdatingRole(String error) => 'שגיאה בעדכון תפקיד: $error';

  // ========================================
  // Remove User Dialog
  // ========================================

  String get removeUserTitle => 'הסרת משתמש';
  String removeUserConfirmation(String name) => 'האם אתה בטוח שברצונך להסיר את $name?';
  String get removeButton => 'הסר';
  String get userRemovedSuccess => 'משתמש הוסר בהצלחה';

  // ========================================
  // Edit Role Dialog
  // ========================================

  String get editRoleTitle => 'עריכת תפקיד';
  String selectNewRole(String name) => 'בחר תפקיד חדש עבור $name:';
  String roleUpdatedSuccess(String roleName) => 'התפקיד עודכן ל-$roleName';

  // ========================================
  // Common Actions
  // ========================================

  String get cancel => 'ביטול';
  String get inviteUser => 'הזמן משתמש';
  String get editRole => 'ערוך תפקיד';
  String get removeUser => 'הסר משתמש';

  // ========================================
  // Loading & Empty States
  // ========================================

  String get loadingUsers => 'טוען משתמשים...';
  String get retryButton => 'נסה שוב 🔄';
  String get noSharedUsers => 'אין משתמשים משותפים';
  String get inviteUsersHint => 'לחץ על + להזמנת משתמשים';
  String get onlyOwnerCanInvite => 'רק בעל הרשימה יכול להזמין משתמשים';
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

  // Unknown Suggestion Status
  String get unknownSuggestionWarning => 'סוג המלצה לא מוכר - נדרש עדכון אפליקציה';
  String get unknownSuggestionCannotDelete => 'לא ניתן למחוק המלצה לא מוכרת';
  String get unknownSuggestionUpdateApp => 'עדכן אפליקציה';

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

  // Expiry Alert Tooltips & Accessibility
  String expiryAlertSemanticLabel(int expiredCount, int expiringSoonCount, bool isExpiredMode) =>
      isExpiredMode
          ? 'התראת תפוגה: $expiredCount פריטים פגי תוקף, $expiringSoonCount עומדים לפוג'
          : 'התראת תפוגה: $expiringSoonCount פריטים עומדים לפוג בקרוב';
  String get expiryAlertCloseTooltip => 'סגור';
  String get expiryAlertGoToPantryTooltip => 'עבור למזווה לצפייה בכל הפריטים';
  String get expiryAlertDismissTodayTooltip => 'התראה זו לא תוצג שוב היום';

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
  String get settingsSemanticLabel => 'דיאלוג הגדרות מזווה';

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

  // Accessibility
  String transferSemanticLabel(int count, String groupName) =>
      'העברת מזווה: $count פריטים לקבוצה $groupName';

  // ========================================
  // Low Stock Alert Dialog
  // ========================================

  String get lowStockAlertTitle => 'מלאי נמוך';
  String lowStockAlertSubtitle(int count) => '$count מוצרים עומדים להיגמר';
  String get lowStockAlertAddToList => 'הוסף לרשימה';
  String get lowStockAlertGoToPantry => 'למזווה';
  String get lowStockAlertDismissToday => 'אל תציג שוב היום';
  String lowStockAlertMoreItems(int count) => 'ועוד $count מוצרים...';

  // Low Stock Alert Tooltips & Accessibility
  String lowStockAlertSemanticLabel(int count) =>
      'התראת מלאי נמוך: $count מוצרים עומדים להיגמר';
  String get lowStockAlertCloseTooltip => 'סגור';
  String get lowStockAlertAddToListTooltip => 'הוסף את כל המוצרים לרשימת הקניות';
  String get lowStockAlertGoToPantryTooltip => 'עבור למזווה לצפייה בכל הפריטים';
  String get lowStockAlertDismissTodayTooltip => 'התראה זו לא תוצג שוב היום';

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

  // Limits
  String maxItemsReached(int max) => 'הגעת למקסימום $max פריטים במזווה';

  // Limit Warnings (80%)
  String itemsNearLimit(int current, int max) =>
      'יש לך $current מתוך $max פריטים במזווה';
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

  // Saved Contacts
  String get savedContactsTitle => 'אנשי קשר שמורים';
  String get savedContactsSubtitle => 'בחר מאנשי קשר שהזמנת בעבר';
  String showMoreContacts(int count) => 'הצג עוד $count אנשי קשר';
  String get orEnterNewEmail => '── או הזן אימייל חדש ──';
  String get contactSelectedEmailDisabled => 'איש קשר נבחר - האימייל לא ישמש';
  String get alreadySharedBadge => 'כבר שותף';

  // Confirmation
  String inviteConfirmation(String recipient, String role, String listName) =>
      'הזמנה תישלח ל-$recipient כ$role ברשימה "$listName"';
  String inviteSentPending(String name) => 'הזמנה נשלחה ל$name - ממתינה לאישור';
  String inviteSentUnregistered(String name) => 'הזמנה נשלחה ל$name - יראה אותה כשיירשם לאפליקציה';

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
  String get requestTypeInvite => 'הזמנה';
  String get requestTypeUnknown => 'לא מוכר';

  // Unknown Request Warning
  String get unknownRequestWarning => 'סוג בקשה לא מוכר - נדרש עדכון אפליקציה';
  String get unknownRequestCannotProcess => 'לא ניתן לעבד בקשה זו';

  // Request Card
  String requestedBy(String userName) => 'נתבקש על ידי $userName';
  String requestedAt(String time) => 'לפני $time';
  String get viewDetailsButton => 'פרטים';
  String get approveButton => 'אשר ✅';
  String get rejectButton => 'דחה ❌';

  // Fallbacks (pending requests)
  String get backButton => 'חזור';
  String get unknownUserFallback => 'משתמש לא ידוע';
  String get unknownItemFallback => 'פריט לא ידוע';
  String get editItemFallback => 'עריכת פריט';
  String get deleteItemFallback => 'מחיקת פריט';
  String get unknownRequestFallback => 'בקשה לא מוכרת';

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

  // Limits
  String maxMembersReached(int max) => 'הגעת למקסימום $max חברים בקבוצה';
  String maxGroupsReached(int max) => 'הגעת למקסימום $max קבוצות';

  // Limit Warnings (80%)
  String membersNearLimit(int current, int max) =>
      'יש לך $current מתוך $max חברים בקבוצה';
  String groupsNearLimit(int current, int max) =>
      'יש לך $current מתוך $max קבוצות';
}

// ========================================
// Select List Dialog Strings
// ========================================

class _SelectListStrings {
  const _SelectListStrings();

  // ========================================
  // Dialog Title & Defaults
  // ========================================

  String get defaultTitle => 'בחר רשימה';
  String addingItem(String itemName) => 'מוסיף: $itemName';

  // ========================================
  // Empty State
  // ========================================

  String get noActiveLists => 'אין רשימות פעילות';
  String get createNewToAddItems => 'צור רשימה חדשה כדי להוסיף פריטים';

  // ========================================
  // Buttons
  // ========================================

  String get createNewButton => 'צור רשימה חדשה';
  String get cancelButton => 'ביטול';

  // ========================================
  // Tooltips
  // ========================================

  String get closeTooltip => 'סגור';
  String get createNewTooltip => 'צור רשימת קניות חדשה';
  String get cancelTooltip => 'ביטול בחירת רשימה';

  // ========================================
  // List Tile
  // ========================================

  String itemsCount(int count) => '$count פריטים';

  // ========================================
  // Accessibility
  // ========================================

  String get semanticLabel => 'בחירת רשימה';
  String semanticLabelWithItem(String itemName) =>
      'בחירת רשימה להוספת $itemName';
  String listTileSemanticLabel(String listName, int itemCount, int checkedCount) =>
      '$listName, $itemCount פריטים${checkedCount > 0 ? ', $checkedCount סומנו' : ''}';
}

// ========================================
// Recurring Product Dialog Strings
// ========================================

class _RecurringStrings {
  const _RecurringStrings();

  // ========================================
  // Dialog Title & Subtitle
  // ========================================

  String get title => 'מוצר פופולרי!';
  String get subtitle => 'נראה שאתה קונה את זה לעתים קרובות';

  // ========================================
  // Stat Badges
  // ========================================

  String get statPurchases => 'קניות';
  String get statLastPurchase => 'קנייה אחרונה';

  // ========================================
  // Last Purchase Formatting
  // ========================================

  String formatLastPurchase(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'היום';
    if (diff == 1) return 'אתמול';
    if (diff < 7) return 'לפני $diff ימים';
    if (diff < 30) return 'לפני ${(diff / 7).floor()} שבועות';
    return 'לפני ${(diff / 30).floor()} חודשים';
  }

  // ========================================
  // Explanation
  // ========================================

  String get explanation => 'מוצר קבוע יתווסף אוטומטית לרשימות קניות חדשות';

  // ========================================
  // Buttons
  // ========================================

  String get confirmButton => 'הפוך לקבוע';
  String get dismissButton => 'לא, תודה';
  String get askLaterButton => 'שאל אותי אחר כך';

  // ========================================
  // Tooltips
  // ========================================

  String get closeTooltip => 'סגור';
  String get confirmTooltip => 'הפוך למוצר קבוע';
  String get dismissTooltip => 'לא להציע מוצר זה כמוצר קבוע';
  String get askLaterTooltip => 'תזכיר לי בפעם הבאה';

  // ========================================
  // Accessibility
  // ========================================

  String semanticLabel(String productName) =>
      'הצעה להפוך את $productName למוצר קבוע';
}

// ========================================
// Receipt Details Screen
// ========================================

class _ReceiptDetailsStrings {
  const _ReceiptDetailsStrings();

  // ========================================
  // Summary Section
  // ========================================

  String get itemsLabel => 'פריטים';
  String get totalLabel => 'סה"כ';

  // ========================================
  // Tags
  // ========================================

  String get virtualTag => 'וירטואלי';
  String get linkedToListTag => 'מקושר לרשימה';

  // ========================================
  // Items Section
  // ========================================

  String get itemsSectionTitle => 'פריטים';
  String get noItemsMessage => 'אין פריטים בקבלה';
  String get unknownItemName => 'פריט ללא שם';
}

// ========================================
// Shopping History Screen
// ========================================

class _ShoppingHistoryStrings {
  const _ShoppingHistoryStrings();

  // ========================================
  // AppBar & Navigation
  // ========================================

  String get title => 'היסטוריית קניות';
  String get sortTooltip => 'מיון';

  // ========================================
  // Sort Options
  // ========================================

  String get sortByDate => 'לפי תאריך';
  String get sortByList => 'לפי סוג רשימה';
  String get sortByAmount => 'לפי סכום';

  // ========================================
  // Filter Period
  // ========================================

  String get filterThisMonth => 'החודש';
  String get filterThreeMonths => '3 חודשים';
  String get filterAll => 'הכל';

  // ========================================
  // Statistics
  // ========================================

  String get shoppingsLabel => 'קניות';
  String get totalLabel => 'סה"כ';
  String get averageLabel => 'ממוצע';

  // ========================================
  // List Items
  // ========================================

  String itemsCount(int count) => '$count פריטים';
  String get virtualTag => 'וירטואלי';
  String get noResults => 'אין קניות בתקופה זו';

  // ========================================
  // Empty State
  // ========================================

  String get emptyTitle => 'אין היסטוריית קניות';
  String get emptySubtitle => 'כאן יופיעו הקניות שביצעת.\nסיים קנייה כדי לראות אותה כאן.';

  // ========================================
  // Error State
  // ========================================

  String get defaultError => 'שגיאה בטעינה';
  String get retryButton => 'נסה שוב';
}

// ========================================
// Active Shopper Banner (Dashboard Widget)
// ========================================

class _ActiveShopperBannerStrings {
  const _ActiveShopperBannerStrings();

  // ========================================
  // My Active Shopping Banner
  // ========================================

  String get myActiveTitle => 'יש לך קנייה פעילה';
  String myActiveSubtitle(String listName, int remaining) =>
      '"$listName" - נותרו $remaining פריטים';
  String get continueButton => 'המשך';

  // ========================================
  // Others Shopping Banner
  // ========================================

  String othersActiveTitle(String shopperName) => '$shopperName קונה עכשיו';
  String othersActiveTitleMultiple(int count) => '$count קונים עכשיו';
  String othersActiveSingle(String listName) => 'קונה מ"$listName"';
  String othersActiveMultiple(int count, String listName) =>
      '$count אנשים קונים מ"$listName"';
  String get joinButton => 'להצטרף';
  String get viewListTooltip => 'צפייה חיה';
}

// ========================================
// Suggestions Today Card (Dashboard Widget)
// ========================================

class _SuggestionsTodayCardStrings {
  const _SuggestionsTodayCardStrings();

  // Header
  String get title => 'הצעות מהמזווה';
  String get loading => 'טוען הצעות...';
  String itemCount(int count) => '$count פריטים';

  // Urgency levels
  String get urgencyCritical => 'נגמר!';
  String get urgencyHigh => 'כמעט נגמר';
  String get urgencyMedium => 'מתמעט';
  String get urgencyLow => 'מומלץ';

  // Stock display
  String inStock(int stock, String unit) => 'במלאי: $stock $unit';

  // Action buttons
  String get addButton => 'הוסף';

  // Snackbar messages
  String get noActiveLists => 'אין רשימות פעילות - צור רשימה חדשה';
  String addedToList(String productName) => 'נוסף "$productName" לרשימה';
  String dismissedForWeek(String productName) => 'דחיתי "$productName" לשבוע';
}

// ========================================
// Last Chance Banner (Dashboard Widget)
// ========================================

class _LastChanceBannerStrings {
  const _LastChanceBannerStrings();

  // ========================================
  // Banner Content
  // ========================================

  String get title => 'רגע! שכחת משהו?';

  String semanticsLabel(String productName, int stock) =>
      'המוצר $productName עומד להיגמר. נותרו $stock יחידות במלאי.';

  String stockText(int stock) => 'נותרו: $stock יחידות במלאי';

  // ========================================
  // Buttons & Tooltips
  // ========================================

  String addTooltip(String productName) =>
      'הוסף "$productName" לרשימת הקניות';
  String get addButton => 'הוסף לרשימה';

  String get nextTooltip => 'עבור להמלצה הבאה (יחזור בסוף הסבב)';
  String get nextButton => 'הבא';

  String get skipSessionTooltip => 'לא יופיע בקנייה הזו, כן בקנייה הבאה';
  String get skipSessionButton => 'לא עכשיו';

  // ========================================
  // Feedback Messages
  // ========================================

  String addedSuccess(String productName) => 'נוסף "$productName" לרשימה';
  String get addError => 'שגיאה בהוספת פריט';
  String get genericError => 'אירעה שגיאה, נסה שוב';
  String get skippedForSession => 'לא יופיע בקנייה הזו';
}

// ========================================
// Pending Invite Banner (Dashboard Widget)
// ========================================

// ========================================
// Pending Invites Screen Strings
// ========================================

class _PendingInvitesScreenStrings {
  const _PendingInvitesScreenStrings();

  // Title
  String get title => 'הזמנות ממתינות';

  // Loading
  String get loading => 'טוען הזמנות...';
  String get loadError => 'שגיאה בטעינת הזמנות';
  String get retryButton => 'נסה שוב';

  // Empty State
  String get emptyTitle => 'אין הזמנות ממתינות';
  String get emptySubtitle => 'כאשר מישהו יזמין אותך לרשימה,\nההזמנה תופיע כאן';
  String get pullToRefresh => '↓ משוך לרענון';

  // Invite Card
  String get listFallback => 'רשימה';
  String get userFallback => 'משתמש';
  String inviteToList(String listName) => 'הזמנה לרשימה "$listName"';
  String inviterMessage(String inviterName) => '$inviterName מזמין אותך להצטרף';
  String get roleLabel => 'תפקיד: ';

  // Action Buttons
  String get acceptButton => 'הצטרף';
  String get declineButton => 'דחה';

  // Accept
  String acceptSuccess(String listName) => 'הצטרפת לרשימה "$listName"';
  String acceptError(String error) => 'שגיאה באישור ההזמנה: $error';

  // Decline Dialog
  String get declineDialogTitle => 'דחיית הזמנה';
  String declineDialogMessage(String listName) => 'לדחות את ההזמנה לרשימה "$listName"?';
  String get cancelButton => 'ביטול';
  String get declineConfirmButton => 'דחה';
  String get declineSuccess => 'ההזמנה נדחתה';
  String declineError(String error) => 'שגיאה בדחיית ההזמנה: $error';
}

class _PendingInviteBannerStrings {
  const _PendingInviteBannerStrings();

  // ========================================
  // Banner Content
  // ========================================

  String get title => 'הזמנה לקבוצה';
  String moreCount(int count) => '+$count';
  String inviteMessage(String inviterName, String groupName) =>
      '$inviterName הזמין אותך ל"$groupName"';

  // ========================================
  // Buttons & Tooltips
  // ========================================

  String get acceptButton => 'קבל';
  String get rejectButton => 'דחה';
  String get rejectTooltip => 'דחה הזמנה';

  // ========================================
  // Dialog
  // ========================================

  String get rejectDialogTitle => 'דחיית הזמנה';
  String get rejectDialogContent => 'האם אתה בטוח שברצונך לדחות את ההזמנה?';
  String get cancelButton => 'ביטול';

  // ========================================
  // Feedback Messages
  // ========================================

  String acceptSuccess(String groupName) => 'הצטרפת לקבוצה "$groupName"';
  String get acceptError => 'שגיאה בקבלת ההזמנה';
  String get rejectSuccess => 'ההזמנה נדחתה';
  String get rejectError => 'שגיאה בדחיית ההזמנה';
  String get notLoggedIn => 'לא מחובר';
}

// ========================================
// Home Dashboard Screen Strings
// ========================================

class _HomeDashboardStrings {
  const _HomeDashboardStrings();

  // ========================================
  // FAB
  // ========================================

  String get newListButton => 'רשימה חדשה';

  // ========================================
  // Error Banner
  // ========================================

  String get errorTitle => 'שגיאה בטעינת נתונים';
  String get retryButton => 'נסה שוב';

  // ========================================
  // Header
  // ========================================

  String greeting(String? userName) {
    final hasName = userName?.trim().isNotEmpty ?? false;
    return hasName ? 'שלום, $userName!' : 'שלום!';
  }

  String get personalFamily => 'משפחה אישית';
  String get sharedFamily => 'משפחה משותפת';

  // ========================================
  // Active Lists Section
  // ========================================

  String get activeListsTitle => 'רשימות פעילות';
  String get noActiveLists => 'אין רשימות פעילות';
  String get createListHint => 'לחץ כאן ליצירת רשימה חדשה';
  String get emptyList => 'רשימה ריקה';
  String get completed => 'הושלם! ✓';
  String remainingItems(int count) => 'נותרו $count פריטים';
  String itemsCount(int count) => '$count פריטים';

  // ========================================
  // History Section
  // ========================================

  String get historyTitle => 'היסטוריה';
  String get seeAll => 'ראה הכל';

  // ========================================
  // Date Formatting
  // ========================================

  String get today => 'היום';
  String get yesterday => 'אתמול';
  String daysAgo(int days) => 'לפני $days ימים';
  String dateFormat(int day, int month, int year) => '$day/$month/$year';
}

// ========================================
// Notifications Center Screen Strings
// ========================================

class _NotificationsCenterStrings {
  const _NotificationsCenterStrings();

  // ========================================
  // AppBar
  // ========================================

  String get title => 'התראות';
  String get markAllAsRead => 'סמן הכל כנקרא';

  // ========================================
  // Loading / Error States
  // ========================================

  String get userNotLoggedIn => 'משתמש לא מחובר';
  String get loadingError => 'שגיאה בטעינת ההתראות';
  String get retryButton => 'נסה שוב';

  // ========================================
  // Empty State
  // ========================================

  String get emptyTitle => 'אין התראות';
  String get emptySubtitle => 'כשתקבל התראות חדשות, הן יופיעו כאן';

  // ========================================
  // Success Messages
  // ========================================

  String get allMarkedAsRead => 'כל ההתראות סומנו כנקראו';
}

// ========================================
// Pantry Screen Strings
// ========================================

class _PantryStrings {
  const _PantryStrings();

  // ========================================
  // Semantics / Accessibility
  // ========================================

  String get screenLabel => 'מסך המזווה שלי';
  String get addItemLabel => 'הוסף מוצר למזווה';
  String itemEditLabel(String name) => '$name, לחץ לעריכה';
  String quantityLabel(int quantity, bool isLowStock) =>
      '$quantity יחידות${isLowStock ? ', מלאי נמוך' : ''}, לחץ לעדכון';

  // ========================================
  // AppBar / Title
  // ========================================

  String get pantryPrefix => 'מזווה ';
  String get addItemTooltip => 'הוסף מוצר';

  // ========================================
  // Loading / Error States
  // ========================================

  String get loadingText => 'טוען...';
  String get loadingErrorTitle => 'שגיאה בטעינת המזווה';
  String get loadingErrorDefault => 'נסה שוב מאוחר יותר';
  String get retryButton => 'נסה שוב';

  // ========================================
  // Empty / Filtered States
  // ========================================

  String get noItemsFound => 'לא נמצאו פריטים';
  String get clearFilters => 'נקה סינון';

  // ========================================
  // Starter Items
  // ========================================

  String get noStarterItemsFound => 'לא נמצאו מוצרי יסוד';
  String starterItemsAdded(int count) => 'נוספו $count מוצרי יסוד למזווה';
  String get starterItemsError => 'שגיאה בהוספת מוצרי יסוד';

  // ========================================
  // Item Actions
  // ========================================

  String itemDeleted(String name) => '$name נמחק';
  String get deleteItemError => 'שגיאה במחיקת פריט';
  String get updateQuantityError => 'שגיאה בעדכון כמות';

  // ========================================
  // Search / Filter
  // ========================================

  String get searchHint => 'חיפוש במזווה...';
  String get clearSearchTooltip => 'נקה חיפוש';
  String get allLocations => 'הכל';

  // ========================================
  // Swipe Actions
  // ========================================

  String get swipeDelete => 'מחיקה';

  // ========================================
  // Delete Dialog
  // ========================================

  String get deleteDialogTitle => 'מחיקת פריט';
  String deleteDialogContent(String name) => 'האם למחוק את "$name"?';

  // ========================================
  // Quantity Dialog
  // ========================================

  String get updateQuantityTitle => 'עדכון כמות:';
  String lowStockWarning(int minQuantity) => 'מלאי נמוך (מינימום: $minQuantity)';
  String get cancelButton => 'ביטול';
  String get saveButton => 'שמור';

  // ========================================
  // Units
  // ========================================

  String get unitAbbreviation => 'יח׳';
}

// ========================================
// Checklist Screen Strings
// ========================================

class _ChecklistStrings {
  const _ChecklistStrings();

  String get subtitle => 'צ\'קליסט ✓';
  String get gotItButton => 'הבנתי';
  String get checkAll => 'סמן הכל';
  String get uncheckAll => 'בטל הכל';
  String percentComplete(int percent) => '$percent% הושלם';
  String get emptyTitle => 'הרשימה ריקה';
  String get emptySubtitle => 'הוסף פריטים לצ\'קליסט';
}

// ========================================
// Contact Selector Dialog Strings
// ========================================

class _ContactSelectorStrings {
  const _ContactSelectorStrings();

  // Header
  String get title => 'בחירת אנשים לשיתוף';
  String get searchHint => 'חיפוש לפי שם או אימייל...';

  // Add new contact
  String get addNewContact => 'הוסף איש קשר חדש';
  String get emailLabel => 'אימייל';
  String get phoneLabel => 'טלפון';
  String get emailHint => 'הזן אימייל...';

  // Validation
  String get invalidEmail => 'נא להזין אימייל תקין';
  String get invalidPhone => 'נא להזין מספר טלפון תקין (05X-XXXXXXX)';
  String get contactAlreadySelected => 'איש קשר זה כבר נבחר';
  String genericError(String error) => 'שגיאה: $error';

  // Empty states
  String get noSavedContacts => 'אין אנשי קשר שמורים';
  String get noSearchResults => 'לא נמצאו תוצאות';

  // Actions
  String get cancelButton => 'ביטול';
  String confirmButton(int count) => 'אישור ($count)';

  // Role picker
  String selectRoleFor(String name) => 'בחר תפקיד עבור $name';

  // Role short descriptions (for bottom sheet)
  String get roleOwnerShortDesc => 'בעלים - מלוא ההרשאות';
  String get roleAdminShortDesc => 'יכול לערוך ישירות ולהזמין אחרים';
  String get roleEditorShortDesc => 'יכול לערוך דרך אישור';
  String get roleViewerShortDesc => 'יכול לצפות בלבד';
  String get roleUnknownShortDesc => 'תפקיד לא מוכר';
}

