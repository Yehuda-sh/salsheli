// 📄 lib/l10n/app_strings_he.dart
//
// מחרוזות UI — עברית
// מבנה: AppStringsHe.layout, .common, .auth, .inventory, .shoppingList, וכו'.
//
// Version: 4.1 (13/03/2026)
// 🔗 Related: app_strings.dart (proxy), app_strings_en.dart (English)

/// מחרוזות UI — עברית
class AppStringsHe {
  // מניעת instances
  const AppStringsHe._();

  /// שם האפליקציה - מקום אחד לשינוי בכל ה-UI
  static const String appName = 'MemoZap';

  // ========================================
  // Layout & Navigation
  // ========================================
  static const layout = LayoutStrings();
  static const navigation = NavigationStrings();

  // ========================================
  // Common UI Elements
  // ========================================
  static const common = CommonStrings();

  // ========================================
  // Categories (Pantry & Filters)
  // ========================================
  static const categories = CategoryStrings();

  // ========================================
  // Onboarding
  // ========================================

  // ========================================
  // Shopping
  // ========================================
  static const shopping = ShoppingStrings();

  // ========================================
  // Index (Splash)
  // ========================================
  static const index = IndexStrings();

  // ========================================
  // Welcome
  // ========================================
  static const welcome = WelcomeStrings();

  // ========================================
  // Auth (Login/Register)
  // ========================================
  static const auth = AuthStrings();

  // ========================================
  // Home Dashboard
  // ========================================
  static const home = HomeStrings();

  // ========================================
  // Price Comparison
  // ========================================
  static const priceComparison = PriceComparisonStrings();

  // ========================================
  // Settings
  // ========================================
  static const settings = SettingsStrings();

  // ========================================
  // Household (Household Types)
  // ========================================
  static const household = HouseholdStrings();

  // ========================================
  // List Type Groups
  // ========================================
  static const listTypeGroups = ListTypeGroupsStrings();

  // ========================================
  // Templates
  // ========================================
  static const templates = TemplatesStrings();

  // ========================================
  // Create List Dialog
  // ========================================
  static const createListDialog = CreateListDialogStrings();

  // ========================================
  // Manage Users
  // ========================================
  static const manageUsers = ManageUsersStrings();

  // ========================================
  // Inventory (Pantry)
  // ========================================
  static const inventory = InventoryStrings();

  // ========================================
  // Shopping List Details
  // ========================================
  static const listDetails = ShoppingListDetailsStrings();

  // ========================================
  // Select List Dialog
  // ========================================
  static const selectList = SelectListStrings();

  // ========================================
  // Recurring Product Dialog
  // ========================================
  static const recurring = RecurringStrings();

  // ========================================
  // User Sharing System (Phase 3B)
  // ========================================
  static const sharing = SharingStrings();

  // ========================================
  // Receipt Details Screen
  // ========================================
  static const receiptDetails = ReceiptDetailsStrings();

  // ========================================
  // Shopping History
  // ========================================
  static const shoppingHistory = ShoppingHistoryStrings();

  // ========================================
  // Active Shopper Banner
  // ========================================
  static const activeShopperBanner = ActiveShopperBannerStrings();

  // ========================================
  // Suggestions Today Card (Dashboard)
  // ========================================
  static const suggestionsToday = SuggestionsTodayCardStrings();

  // ========================================
  // Last Chance Banner
  // ========================================
  static const lastChanceBanner = LastChanceBannerStrings();

  // ========================================
  // Pending Invite Banner
  // ========================================
  static const pendingInviteBanner = PendingInviteBannerStrings();

  // ========================================
  // Pending Invites Screen
  // ========================================
  static const pendingInvitesScreen = PendingInvitesScreenStrings();

  // ========================================
  // Home Dashboard Screen
  // ========================================
  static const homeDashboard = HomeDashboardStrings();

  // ========================================
  // Notifications Center Screen
  // ========================================
  static const notificationsCenter = NotificationsCenterStrings();

  // ========================================
  // Pantry Screen
  // ========================================
  static const pantry = PantryStrings();

  // ========================================
  // Checklist Screen
  // ========================================
  static const checklist = ChecklistStrings();

  // ========================================
  // Contact Selector Dialog
  // ========================================
  static const contactSelector = ContactSelectorStrings();
  static const shoppingSummary = ShoppingSummaryStrings();

  // ========================================
  // Legal Content
  // ========================================
  static const tutorial = TutorialStrings();
  static const legal = LegalStrings();
}

// ========================================
// _CategoryStrings
// ========================================

class CategoryStrings {
  const CategoryStrings();

  String get all => 'הכל';
  String get other => 'אחר';
  String get dairy => 'מוצרי חלב';
  String get vegetables => 'ירקות';
  String get fruits => 'פירות';
  String get meatFish => 'בשר ודגים';
  String get ricePasta => 'אורז ופסטה';
  String get spices => 'תבלינים';
  String get coffeeTea => 'קפה ותה';
  String get sweetsSnacks => 'ממתקים וחטיפים';
  String get beef => 'בקר';
  String get chicken => 'עוף';
  String get turkey => 'הודו';
  String get lamb => 'טלה וכבש';
  String get fish => 'דגים';
  String get meatSubstitutes => 'תחליפי בשר';
  String get breadBakery => 'לחם ומאפים';
  String get cookiesSweets => 'עוגיות ומתוקים';
  String get cakes => 'עוגות';
  String get canned => 'שימורים';
  String get legumesGrains => 'קטניות ודגנים';
  String get cereals => 'דגנים';
  String get driedFruits => 'פירות יבשים';
  String get nutsSeeds => 'אגוזים וגרעינים';
  String get beverages => 'משקאות';
  String get oilsSauces => 'שמנים ורטבים';
  String get sweetSpreads => 'ממרחים מתוקים';
  String get frozen => 'קפואים';
  String get readySalads => 'סלטים מוכנים';
  String get dairySubstitutes => 'תחליפי חלב';
  String get hygiene => 'היגיינה';
  String get oralCare => 'טיפוח הפה';
  String get cosmetics => 'קוסמטיקה וטיפוח';
  String get feminineHygiene => 'היגיינה נשית';
  String get cleaning => 'מוצרי ניקיון';
  String get homeProducts => 'מוצרי בית';
  String get disposable => 'חד פעמי';
  String get garden => 'מוצרי גינה';
  String get petFood => 'מזון לחיות מחמד';
  String get otcMedicine => 'תרופות ללא מרשם';
  String get vitamins => 'ויטמינים ותוספי תזונה';
  String get firstAid => 'עזרה ראשונה';
  String get babyProducts => 'מוצרי תינוקות';
  String get accessories => 'מוצרים נלווים';
}

// ========================================
// Layout Strings (AppLayout)
// ========================================

class LayoutStrings {
  const LayoutStrings();

  String get appTitle => AppStringsHe.appName;
  String get notifications => 'התראות';
  String get noNotifications => 'אין התראות חדשות';
  String notificationsCount(int count) => 'יש לך $count עדכונים חדשים';
  String get welcome => 'ברוך הבא ל-${AppStringsHe.appName}';
  String get offline => 'אין חיבור לרשת';
  String get logoutError => 'שגיאה בהתנתקות, נסה שוב';
  String get pendingInvitesTitle => 'התראות והזמנות';
  String get groupInvites => 'הזמנות לקבוצות';
  String get groupInvitesSubtitle => 'הצטרפות לבית';
  String get listInvites => 'הזמנות לרשימות';
  String get listInvitesSubtitle => 'שיתוף רשימות קניות';
  String get notificationsSubtitle => 'עדכונים ופעילות אחרונה';
  String get lowStockTitle => 'מלאי חסר';
  String lowStockSubtitle(int count) => '$count מוצרים במלאי נמוך';
  String navSemanticLabel(String selectedTab) => 'ניווט ראשי. טאב נבחר: $selectedTab';
  String get navSemanticHint => 'החלק ימינה או שמאלה לבחירת טאב אחר';
  String get longPressHint => 'לחיצה ארוכה לפעולות נוספות';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class NavigationStrings {
  const NavigationStrings();

  String get home => 'בית';
  String get family => 'בית';
  String get groups => 'קבוצות';
  String get lists => 'רשימות';
  String get pantry => 'מזווה';
  String get receipts => 'קבלות';
  String get history => 'היסטוריה';
  String get settings => 'הגדרות';
}

// ========================================
// Common Strings (Buttons, Actions)
// ========================================

class CommonStrings {
  const CommonStrings();

  String get logout => 'התנתק';
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
  String get yes => 'כן';
  String get no => 'לא';
  String get ok => 'אישור';
  String get loading => 'טוען...';
  String get error => 'שגיאה';
  String get success => 'הצלחה';
  String get categoryUnknown => 'לא ידוע';
  String get syncError => 'בעיית סנכרון - השינויים נשמרו מקומית';
  String get saveFailed => 'השמירה נכשלה, נסה שוב';
  String get unsavedChangesTitle => 'שינויים לא נשמרו';
  String get unsavedChangesMessage => 'יש שינויים שלא נשמרו. האם לצאת בלי לשמור?';
  String get stayHere => 'הישאר';
  String get exitWithoutSaving => 'צא בלי לשמור';

  // 📅 Days of week (0=Sunday ... 6=Saturday)
  String get daySunday => 'ראשון';
  String get dayMonday => 'שני';
  String get dayTuesday => 'שלישי';
  String get dayWednesday => 'רביעי';
  String get dayThursday => 'חמישי';
  String get dayFriday => 'שישי';
  String get daySaturday => 'שבת';
  String get dayUnknown => 'לא ידוע';

  /// Get day name by index (0=Sunday ... 6=Saturday)
  String dayByIndex(int index) => switch (index) {
    0 => daySunday,
    1 => dayMonday,
    2 => dayTuesday,
    3 => dayWednesday,
    4 => dayThursday,
    5 => dayFriday,
    6 => daySaturday,
    _ => dayUnknown,
  };

  // Shared UI
  String get understood => 'הבנתי';
  String get confirm => 'אישור';
  String get goBack => 'חזור';
  String get backToHome => 'חזרה לדף הבית';
  String get close => 'סגור';
  String unknownError(String error) => 'שגיאה: $error';
  String get unknownErrorGeneric => 'אירעה שגיאה, נסו שוב';
  String get permissionError => 'אין הרשאה לבצע פעולה זו';
  String get notFoundError => 'הפריט לא נמצא';
  String get networkError => 'בעיית חיבור לאינטרנט. נסו שוב';
  String get connected => 'מחובר';
  String get optional => '(אופציונלי)';
}

// ========================================
// Onboarding Strings
// ========================================


// ========================================
// Shopping Strings
// ========================================

class ShoppingStrings {
  const ShoppingStrings();

  String get itemStatusOutOfStock => 'אזל';
  String get activeSaving => 'שומר...';
  String get activeFinish => 'סיום';
  String get activePurchased => 'קנוי';
  String get activeNotNeeded => 'לא צריך';
  String get activeRemaining => 'נותרו';
  String get activeTotal => 'סה״כ';
  String get activeSavingData => 'שומר את הנתונים...';
  String get loadingDataError => 'שגיאה בטעינת הנתונים';
  String get shoppingCompletedSuccess => 'סיימתם — קנייה מוצלחת! 🎉';
  String get viewerCannotShop => 'צופים לא יכולים להשתתף בקנייה';
  String pantryUpdated(int count) => '📦 $count מוצרים עודכנו במזווה';
  String itemsMovedToNext(int count) => '🔄 $count פריטים הועברו לרשימה הבאה';
  String get saveError => 'שגיאה בשמירה';
  String get saveErrorMessage => 'לא הצלחנו לשמור את הנתונים.\nנסה שוב?';
  String get oopsError => 'משהו לא עבד — ננסה שוב?';
  String get listEmpty => 'הרשימה ריקה';
  String get noItemsToBuy => 'אין פריטים לקנייה';
  String get sharedLabel => 'משותפת';
  String get privateLabel => 'אישית';
  String get startShoppingButton => 'התחל קנייה';
  String get addProductsToStart => 'הוסף מוצרים כדי להתחיל';
  String listDeleted(String name) => 'הרשימה "$name" נמחקה';
  String get undoButton => 'בטל';
  String get restoreError => 'שגיאה בשחזור הרשימה';
  String get deleteError => 'שגיאה במחיקת הרשימה';
  String get urgencyPassed => 'עבר!';
  String get urgencyToday => 'היום!';
  String get urgencyTomorrow => 'מחר';
  String urgencyDaysLeft(int days) => 'עוד $days ימים';
  String get typeSupermarket => 'סופרמרקט';
  String get typePharmacy => 'בית מרקחת';
  String get typeGreengrocer => 'ירקן';
  String get typeButcher => 'אטליז';
  String get typeBakery => 'מאפייה';
  String get typeMarket => 'שוק';
  String get typeHousehold => 'כלי בית';
  String get typeEvent => 'אירוע';
  String get typeOther => 'אחר';
  // Short names (for chips/tabs)
  String get typeSupermarketShort => 'סופר';
  String get typePharmacyShort => 'מרקחת';
  String get typeGreengrocerShort => 'ירקן';
  String get typeButcherShort => 'אטליז';
  String get typeBakeryShort => 'מאפייה';
  String get typeMarketShort => 'שוק';
  String get typeHouseholdShort => 'בית';
  String get typeEventShort => 'אירוע';
  String get typeOtherShort => 'אחר';
  String get deleteListTitle => 'מחיקת רשימה';
  String deleteListMessage(String name) => 'האם למחוק את הרשימה "$name"?';
  String get deleteButton => 'מחק';
  String itemsAndDate(int count, String date) => 'פריטים: $count • עודכן: $date';
  String get editListButton => 'עריכת רשימה';
  String get deleteListButton => 'מחיקה';
  String get summaryTitle => 'סיכום קנייה';
  String get summarySuccess => 'קנייה מוצלחת! ⚡';
  String get storeQuestion => 'מאיפה קנית?';
  String get whoBringsWhat => 'מי מביא מה';
  String get whoBringsTitle => 'מי מביא?';
  String get whoBringsHint => 'לחץ על "אני מביא" כדי להתנדב להביא פריט';
  String get whoBringsFullLabel => 'מלא! ✓';
  String whoBringsItemFull(String name) => '$name כבר מלא!';
  String get whoBringsEmptyTitle => 'אין פריטים ברשימה';
  String get whoBringsEmptySubtitle => 'הוסף פריטים כדי שחברי הקבוצה יוכלו להתנדב';
  String get anonymousUser => 'אנונימי';
  String get checklist => 'צ\'קליסט';
  String get defaultInviteLabel => 'הזמנה';
  String get leaveShoppingTitle => 'לצאת מהקנייה?';
  String get leaveShoppingMessage => 'הקנייה עדיין פעילה. אם תצא, תוכל לחזור אליה מאוחר יותר.';
  String get continueShoppingButton => 'להמשיך לקנות';
  String get leaveButton => 'לצאת';
  String get summaryOutOfStock => 'אזלו בחנות';
  String get summaryNotMarked => 'לא סומנו';
  String get summaryBack => 'חזור';
  String get summaryFinishShopping => 'סיים קנייה';
  String summaryPurchased(int purchased, int total) => '$purchased מתוך $total';
  String summaryPendingQuestion(int count) => count == 1 ? 'יש פריט אחד שלא סומן.' : 'יש $count פריטים שלא סומנו.';
  String get summaryPendingSubtitle => 'מה לעשות איתם?';
  String get summaryPendingTransfer => 'העבר לרשימה הבאה';
  String get summaryPendingTransferSubtitle => 'הפריטים יועברו לקנייה הבאה';
  String get summaryPendingLeave => 'השאר ברשימה';
  String get summaryPendingLeaveSubtitle => 'הרשימה תישאר פעילה';
  String get summaryPendingDelete => 'מחק ולא צריך';
  String get summaryPendingDeleteSubtitle => 'הפריטים יוסרו לגמרי';
  String priceFormat(double price) => '₪${price.toStringAsFixed(2)}';
  String get noPrice => 'אין מחיר';
  String get categoryGeneral => 'כללי';
  String addProductsTitle(String listName) => 'הוספת מוצרים: $listName';
  String productRemovedFromList(String name) => '$name הוסר מהרשימה';
  String productUpdatedQuantity(String name, int quantity) => '$name (עודכן ל-$quantity)';
  String productAddedToList(String name) => '$name נוסף לרשימה! ✓';
  String get loadingProducts => 'טוען מוצרים...';
  String noProductsMatchingSearch(String query) => 'לא נמצאו מוצרים התואמים "$query"';
  String get noProductsAvailable => 'אין מוצרים זמינים כרגע';
  String get loadProductsButton => 'טען מוצרים';
  String get productNoName => 'ללא שם';
  String updateProductError(String error) => 'שגיאה בעדכון מוצר: $error';
  String addProductError(String error) => 'שגיאה בהוספת מוצר: $error';
  String get searchAndFilter => 'חיפוש וסינון';
  String get filterActive => 'סינון פעיל';
  String get searchMenuLabel => 'חיפוש';
  String get filterByTypeLabel => 'סינון לפי סוג';
  String get sortLabel => 'מיון';
  String get clearFilterLabel => 'נקה סינון';
  String get newListTooltip => 'רשימה חדשה';
  String get searchListTitle => 'חיפוש רשימה';
  String get searchListHint => 'הקלד שם רשימה...';
  String get clearButton => 'נקה';
  String get searchButton => 'חפש';
  String get filterByTypeTitle => 'סינון לפי סוג';
  String get allTypesLabel => 'הכל';
  String get sortTitle => 'מיון';
  String get sortDateDesc => 'חדש → ישן';
  String get sortDateAsc => 'ישן → חדש';
  String get sortNameAZ => 'א-ת';
  String get sortBudgetDesc => 'תקציב גבוה → נמוך';
  String get sortBudgetAsc => 'תקציב נמוך → גבוה';
  String get sortLabelNew => 'חדש';
  String get sortLabelOld => 'ישן';
  String get sortLabelAZ => 'א-ת';
  String get activeLists => '🔵 רשימות פעילות';
  String get historyLists => '✅ היסטוריה';
  String get historyListsNote => '(לפי עדכון אחרון)';
  String get noListsFoundTitle => 'לא נמצאו רשימות';
  String get noListsFoundSubtitle => 'נסה לשנות את החיפוש או הסינון';
  String get noListsTitle => 'מוכנים לקנייה חכמה?';
  String get noListsSubtitle => 'צרו את הרשימה הראשונה\nולא תשכחו שוב אף מוצר!';
  String get createNewListButton => 'צור רשימה חדשה';
  String get orScanReceiptHint => 'או סרוק קבלה במסך הקבלות';
  String get loadingListsError => 'שגיאה בטעינת הרשימות';
  String get somethingWentWrong => 'הממ, זה לא עבד';
  String get tryAgainButton => 'נסה שוב';
  String loadMoreLists(int remaining) => 'טען עוד רשימות ($remaining נותרו)';
  String get moreOptionsTooltip => 'אפשרויות נוספות';
  String listTileSemantics(String name, int total, int checked) => '$name, $total פריטים, $checked סומנו';
  String get defaultShoppingListName => 'קניות כלליות';
  String maxItemsReached(int max) => 'הגעת למקסימום $max פריטים ברשימה';
  String maxListsReached(int max) => 'הגעת למקסימום $max רשימות פעילות';
  String get syncSuccess => 'הסנכרון הצליח!';
  String get syncErrorTooltip => 'לא מסונכרן - לחץ לנסות שוב';
  String get shoppingSaved => 'הקנייה נשמרה';
  String pendingItemsLeftWarning(int count) => '$count פריטים נשארו והרשימה פעילה';
  String get legendOutOfStock => 'אין במלאי';
  String get legendNotNeeded => 'לא צריך';
  String get legendPending => 'ממתין';
  String get editQuantity => 'ערוך כמות';
  String get scanBarcode => 'סרוק ברקוד';
  String get addNewProductTooltip => 'הוסף מוצר חדש';
  String get increaseQuantityTooltip => 'הוסף כמות';
  String get decreaseQuantityTooltip => 'הפחת כמות';
  String get productNoNameFallback => 'מוצר ללא שם';
  String get cameraError => 'לא ניתן לגשת למצלמה.\nבדוק הרשאות בהגדרות המכשיר.';
  String get toggleFlash => 'הדלק/כבה פנס';
  String get barcodeFoundAdd => 'המוצר לא ברשימה. להוסיף?';
  String get addToListButton => 'הוסף לרשימה';
  String barcodeNotFound(String code) => 'ברקוד $code לא נמצא';
  String get retryLoadSemantics => 'לחץ פעמיים כדי לנסות לטעון את הרשימה מחדש';
  String get backToListSemantics => 'לחץ פעמיים כדי לחזור לרשימת הקניות';
  String get finishAndSaveSemantics => 'לחץ פעמיים כדי לסיים את הקנייה ולשמור את הנתונים';
  String outOfStockToggleSemantics(String itemName, bool isOutOfStock) =>
      isOutOfStock ? 'לחץ פעמיים כדי לבטל סימון אין במלאי עבור $itemName' : 'לחץ פעמיים כדי לסמן ש-$itemName אזל מהמדף';

  // Who Brings
  String alreadyVolunteered(String name) => 'כבר התנדבת להביא את $name';
  String volunteerSuccess(String name) => 'נרשמת להביא: $name ✓';
  String get volunteerError => 'שגיאה בהרשמה';
  String cancelVolunteer(String name) => 'ביטלת את ההתנדבות ל$name';
  String get cancelVolunteerError => 'שגיאה בביטול';
  String get statsTotal => 'סה"כ';
  String get statsCompleted => 'הושלם';
  String get statsIBring => 'אני מביא';
  String get cancelVolunteerButton => 'בטל התנדבות';
  String get iBringButton => 'אני מביא! ✋';

  // Summary
  String get budgetTitle => 'תקציב';
  String get successRateTitle => 'אחוז הצלחה';
  String get purchasedLabel => 'נרכשו';
  String get missingLabel => 'חסרו';
  String get finishedButton => 'סיימתי';
  String get otherStoreHint => 'חנות אחרת...';
}

// ========================================
// Index (Splash) Strings
// ========================================

class IndexStrings {
  const IndexStrings();

  String get appName => AppStringsHe.appName;
  String get logoLabel => 'לוגו אפליקציית ${AppStringsHe.appName}';
  String get loadingLabel => 'טוען את האפליקציה';
  String get loading => 'טוען...';
  List<String> get loadingMessages => const ['בודק מצב...', 'מתחבר...', 'כמעט מוכן...'];
  String get errorTitle => 'אופס! משהו השתבש';
  String get errorMessage => 'לא הצלחנו לטעון את האפליקציה';
  String get retryButton => 'נסה שוב';
}

// ========================================
// Welcome Strings
// ========================================

class WelcomeStrings {
  const WelcomeStrings();

  String get title => AppStringsHe.appName;
  String get subtitle => 'קניות חכמות לכל המשפחה';
  String get group1Emoji => '🛒';
  String get group1Title => 'קנו ביחד';
  String get group1Question => 'רשימה אחת, כולם עורכים בזמן אמת';
  String get group1Feature1 => 'פריטים חכמים ✅';
  String get group1Feature2 => 'כמויות אוטומטיות 🔢';
  String get group2Emoji => '📦';
  String get group2Title => 'מזווה שלא נגמר';
  String get group2Question => 'המזווה הדיגיטלי שלך — מתריע לפני שנגמר';
  String get group2Feature1 => 'מלאי חי 📊';
  String get group2Feature2 => 'התראות חכמות ⏰';
  String get group3Emoji => '👨‍👩‍👧‍👦';
  String get group3Title => 'המשפחה מסונכרנת';
  String get group3Question => 'כולם רואים, כולם מעדכנים — בלי קניות כפולות';
  String get group3Feature1 => 'עדכונים חיים 🔄';
  String get group3Feature2 => 'סנכרון ענן ☁️';
  String get moreGroupsHint => 'פשוט ויפה — בלי עקומת למידה';
  String get demoItem1 => 'חלב';
  String get demoItem2 => 'לחם';
  String get demoItem3 => 'ביצים';
  String get demoPantryHeader => '📦 מזווה';
  String get demoPantryItem1 => 'חלב';
  String get demoPantryItem2 => 'ביצים';
  String get demoPantryItem3 => 'לחם';
  String get demoFamilyHeader => '👨‍👩‍👧‍👦 הבית';
  String get demoUser1 => 'אבא';
  String get demoUser2 => 'אמא';
  String get demoUser3 => 'דני';
  String get statusOnline => 'מחובר';
  String get statusOffline => 'לא מחובר';
  String get benefit1Title => 'שיתוף בזמן אמת';
  String get benefit1Subtitle => 'שינויים מופיעים מיד אצל כולם';
  String get benefit2Title => 'רשימות + מטלות במקום אחד';
  String get benefit2Subtitle => 'קניות, סידורים, אירועים — הכל מסודר';
  String get benefit3Title => 'מזווה חכם';
  String get benefit3Subtitle => 'יודע מה צריך — לפני שאתם יודעים';
  String get startButton => 'הרשמה';
  String get loginButton => 'התחברות';
  String get loginLink => 'כבר יש לי חשבון — התחברות';
  String get authExplanation => 'התחברו כדי לסנכרן את הרשימות בכל המכשירים';
  String get registerButton => 'הרשמה';
  String get termsOfService => 'תנאי שימוש';
  String get privacyPolicy => 'מדיניות פרטיות';
  String get logoLabel => 'לוגו אפליקציית ${AppStringsHe.appName}';
}

// ========================================
// Auth Strings (Login/Register)
// ========================================

class AuthStrings {
  const AuthStrings();

  String get loginTitle => 'התחברות';
  String get loginSubtitle => 'נעים לראות אותך שוב 👋';
  String get loginButton => 'התחבר';
  String get loggingIn => 'מתחבר...';
  String get registerTitle => 'הרשמה';
  String get registerSubtitle => 'הדרך החכמה לקניות משפחתיות ✨';
  String get registerButton => 'הירשם';
  String get registering => 'נרשם...';
  String get forgotPassword => 'שכחת סיסמה?';
  String get sendResetEmailButton => 'שלח קישור';
  String get resetEmailSent => 'מייל לאיפוס סיסמה נשלח בהצלחה!';
  String get emailNotVerified => 'האימייל לא אומת';
  String get verifyEmailMessage => 'נא לאמת את כתובת האימייל שלך';
  String get sendVerificationEmailButton => 'שלח מייל אימות';
  String get verificationEmailSent => 'מייל אימות נשלח!';
  String get checkYourEmail => 'בדוק את תיבת הדואר שלך';
  String get updateProfile => 'עדכון פרופיל';
  String get updateDisplayName => 'עדכון שם תצוגה';
  String get displayNameUpdated => 'שם התצוגה עודכן בהצלחה!';
  String get updateEmail => 'עדכון אימייל';
  String get emailUpdated => 'האימייל עודכן בהצלחה!';
  String get updatePassword => 'עדכון סיסמה';
  String get passwordUpdated => 'הסיסמה עודכנה בהצלחה!';
  String get deleteAccount => 'מחיקת חשבון';
  String get deleteAccountWarning => 'פעולה זו בלתי הפיכה!';
  String get deleteAccountConfirm => 'האם אתה בטוח שברצונך למחוק את החשבון?';
  String get accountDeleted => 'החשבון נמחק בהצלחה';
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
  String get noAccount => 'אין לך חשבון?';
  String get registerNow => 'הירשם עכשיו';
  String get haveAccount => 'יש לך חשבון?';
  String get or => 'או';
  String get orContinueWith => 'או הירשם במהירות עם';
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
  String get errorWeakPassword => 'הסיסמה חלשה מדי';
  String get errorEmailInUse => 'האימייל כבר בשימוש';
  String get errorInvalidEmail => 'פורמט אימייל לא תקין';
  String get errorOperationNotAllowed => 'פעולה לא מורשית';
  String get errorUserNotFound => 'משתמש לא נמצא';
  String get errorWrongPassword => 'סיסמה שגויה';
  String get errorUserDisabled => 'המשתמש חסום';
  String get errorInvalidCredential => 'פרטי התחברות שגויים';
  String get errorTooManyRequests => 'יותר מדי ניסיונות. נסה שוב מאוחר יותר';
  String get errorRequiresRecentLogin => 'נדרשת התחברות מחדש לביצוע פעולה זו';
  String get errorNetworkRequestFailed => 'בעיית רשת. בדוק את החיבור לאינטרנט';
  String get errorTimeout => 'הפעולה נכשלה - נסה שוב';
  String get errorNoUserLoggedIn => 'אין משתמש מחובר';
  String get socialLoginCancelled => 'ההתחברות בוטלה';
  String get socialLoginError => 'שגיאה בהתחברות';
  String signUpError(String? message) => 'שגיאה ברישום${message != null ? ": $message" : ""}';
  String signInError(String? message) => 'שגיאה בהתחברות${message != null ? ": $message" : ""}';
  String resetEmailError(String? message) => 'שגיאה בשליחת מייל${message != null ? ": $message" : ""}';
  String verificationEmailError(String? message) => 'שגיאה בשליחת מייל אימות${message != null ? ": $message" : ""}';
  String updateDisplayNameError(String? message) => 'שגיאה בעדכון שם${message != null ? ": $message" : ""}';
  String updateEmailError(String? message) => 'שגיאה בעדכון אימייל${message != null ? ": $message" : ""}';
  String updatePasswordError(String? message) => 'שגיאה בעדכון סיסמה${message != null ? ": $message" : ""}';
  String deleteAccountError(String? message) => 'שגיאה במחיקת חשבון${message != null ? ": $message" : ""}';
  String reloadUserError(String? message) => 'שגיאה בטעינה מחדש${message != null ? ": $message" : ""}';
  String get mustCompleteLogin => 'יש להשלים את תהליך ההתחברות';
  String get loginSuccess => 'התחברת בהצלחה!';
  String get registerSuccess => 'נרשמת בהצלחה!';
  String get loginSuccessRedirect => 'התחברת בהצלחה! מעביר לדף הבית...';
  String get orLoginWith => 'או התחבר עם';
  String get orWithEmail => 'או עם אימייל';
  String get showPassword => 'הצג סיסמה';
  String get hidePassword => 'הסתר סיסמה';
  String get enterEmailFirst => 'אנא הזן את כתובת האימייל שלך בשדה למעלה';
  String resetEmailSentTo(String email) => 'נשלח מייל לאיפוס סיסמה ל-$email';
  String get resetEmailSendError => 'שגיאה בשליחת מייל איפוס';
  String get forgotPasswordSemanticLabel => 'שכחת סיסמה? לחץ לקבלת מייל איפוס';
  String get forgotPasswordSemanticHint => 'שולח קישור לאיפוס סיסמה לאימייל שהוזן';
  String socialLoginSemanticLabel(String provider) => 'התחבר באמצעות $provider';
  String get registerSuccessRedirect => 'הרשמת בהצלחה! מעביר לדף הבית...';
  String get pendingInvitesDialogTitle => 'הזמנות ממתינות!';
  String pendingInvitesDialogContent(int count) =>
      'יש לך $count הזמנות לקבוצות ממתינות לאישור.\n\nהאם לעבור למסך ההזמנות?';
  String get pendingInvitesLater => 'אחר כך';
  String get pendingInvitesView => 'צפה בהזמנות';
  String get phoneHelperText => 'מספר נייד ישראלי - לקבלת עדכונים מהקבוצות';
  String get nameFieldSemanticLabel => 'שדה שם מלא, חובה';
  String get emailFieldSemanticLabel => 'שדה כתובת אימייל, חובה';
  String get passwordFieldSemanticLabel => 'שדה סיסמה, לפחות 6 תווים';
  String get confirmPasswordFieldSemanticLabel => 'שדה אימות סיסמה, חייב להתאים לסיסמה';
  String get phoneFieldSemanticLabel => 'שדה טלפון נייד ישראלי, חובה';
  String get loginLinkSemanticLabel => 'יש לך חשבון? לחץ לעבור למסך התחברות';
  String socialRegisterSemanticLabel(String provider) => 'הירשם או התחבר באמצעות $provider';

  // Loading overlay messages
  String get loadingCheckingDetails => 'בודק פרטים...';
  String get loadingConnecting => 'מתחבר לשרת...';
  String get loadingAlmostThere => 'כמעט שם...';
}

// ========================================
// Home Dashboard Strings
// ========================================

class HomeStrings {
  const HomeStrings();

  String timeBasedGreeting(String userName, int hour) {
    final String greeting;
    if (hour >= 5 && hour < 12)
      greeting = 'בוקר טוב';
    else if (hour >= 12 && hour < 17)
      greeting = 'צהריים טובים';
    else if (hour >= 17 && hour < 21)
      greeting = 'ערב טוב';
    else
      greeting = 'לילה טוב';
    return '$greeting, $userName! 👋';
  }

  String get sortLabel => 'מיון:';
  String get sortByDate => 'תאריך עדכון';
  String get noActiveLists => 'אין רשימות פעילות כרגע';
  String get otherActiveLists => 'רשימות פעילות נוספות';
  String get noOtherActiveLists => 'אין רשימות נוספות כרגע';
  String get allLists => 'כל הרשימות';
  String itemsCount(int count) => '$count פריטים';
  String listDeleted(String listName) => 'הרשימה "$listName" נמחקה';
  String get undo => 'בטל';
  String createListError(String error) => 'שגיאה ביצירת רשימה: $error';
  String get doubleTapToExit => 'לחץ שוב לסגירת האפליקציה';
}

// ========================================
// Price Comparison Strings
// ========================================

class PriceComparisonStrings {
  const PriceComparisonStrings();

  String get title => 'השוואת מחירים';
  String get searchHint => 'חפש מוצר...';
  String get searchButton => 'חפש';
  String get clearButton => 'נקה';
  String get storeIcon => '🏪';
  String get errorTitle => 'שגיאה בחיפוש';
  String get retry => 'נסה שוב';
}

// ========================================
// Settings Strings
// ========================================

class SettingsStrings {
  const SettingsStrings();

  String get title => 'הגדרות ופרופיל';
  String get editProfile => 'עריכה';
  String get statsActiveLists => 'רשימות פעילות';
  String get statsPantryItems => 'פריטים במזווה';
  String get householdName => 'שם הקבוצה';
  String get householdNameHint => 'שם הקבוצה';
  String get editHouseholdNameSave => 'שמור';
  String get editHouseholdNameEdit => 'ערוך שם';
  String get roleOwner => 'בעלים';
  String get roleAdmin => 'מנהל';
  String get roleEditor => 'עורך';
  String get roleViewer => 'צופה';
  String get storesTitle => 'חנויות מועדפות';
  String get addStoreHint => 'הוסף חנות...';
  String get addStoreTooltip => 'הוסף חנות';
  String get familySizeLabel => 'גודל הקבוצה (מספר אנשים)';
  String get weeklyRemindersLabel => 'תזכורות שבועיות';
  String get weeklyRemindersSubtitle => 'קבל תזכורת לתכנן קניות';
  String get notificationsSectionTitle => 'התראות';
  String get notifyShoppingTitle => 'פעילות קנייה';
  String get notifyShoppingSubtitle => 'כשמישהו התחיל או סיים לקנות';
  String get notifyGroupTitle => 'שינויים בקבוצה';
  String get notifyGroupSubtitle => 'חבר חדש, הזמנה או יציאה';
  String get notifyRemindersTitle => 'תזכורות';
  String get notifyRemindersSubtitle => 'רשימה פתוחה מעל 24 שעות, תזכורת שבועית';
  String get notifyListUpdatesTitle => 'עדכוני רשימה';
  String get notifyListUpdatesSubtitle => 'כשמישהו הוסיף או מחק פריטים מרשימה משותפת';
  String get generalSettingsSectionTitle => 'הגדרות כלליות';
  String get themeLabel => 'ערכת נושא';
  String get themeLight => 'בהיר';
  String get themeDark => 'כהה';
  String get themeSystem => 'מערכת';
  String get householdManagementTitle => 'ניהול הבית';
  String get householdMembersTitle => 'חברי הבית';
  String get householdMembersSubtitle => 'הוסף והסר חברים';
  String get householdInviteTitle => 'הזמן חברים';
  String get householdInviteSubtitle => 'שלח הזמנה להצטרף';
  String get householdComingSoon => 'ניהול מלא - בקרוב!';
  String get inviteToHouseholdTitle => 'הזמן לבית';
  String get inviteToHouseholdSubtitle => 'שלח הזמנה להצטרף לבית שלך';
  String get inviteToHouseholdHint => 'הזן אימייל של המוזמן';
  String get inviteToHouseholdSuccess => '✅ הזמנה נשלחה!';
  String get inviteToHouseholdAlreadyMember => 'המשתמש כבר חבר בבית';
  String get inviteToHouseholdAlreadyPending => 'כבר יש הזמנה ממתינה';
  String get inviteToHouseholdButton => 'שלח הזמנה';
  String get householdJoinedSuccess => '🏠 הצטרפת לבית בהצלחה!';
  String get myPantry => 'המזווה שלי';
  String get priceComparison => 'השוואת מחירים';
  String get updatePricesTitle => 'עדכן מחירים מ-API';
  String get updatePricesSubtitle => 'טעינת מחירים עדכניים מהרשת';
  String get updatingPrices => '💰 מעדכן מחירים מ-API...';
  String pricesUpdated(int withPrice, int total) => '✅ התעדכנו $withPrice מחירים מתוך $total מוצרים!';
  String pricesUpdateError(String error) => '❌ שגיאה בעדכון מחירים: $error';
  String get logoutTitle => 'התנתקות';
  String get logoutMessage => 'האם אתה בטוח שברצונך להתנתק?';
  String get logoutCancel => 'ביטול';
  String get logoutConfirm => 'התנתק';
  String get logoutSubtitle => 'יציאה מהחשבון';
  String get deleteAccountTitle => 'מחיקת חשבון';
  String get deleteAccountSubtitle => 'מחיקת כל הנתונים לצמיתות';
  String get deleteAccountWarning =>
      'פעולה זו תמחק לצמיתות את:\n• כל הרשימות שיצרת\n• היסטוריית הקניות\n• המזווה שלך\n• כל הנתונים האישיים\n\nלא ניתן לשחזר את הנתונים!';
  String get deleteAccountConfirmLabel => 'הקלד "מחק את החשבון" לאישור:';
  String get deleteAccountConfirmText => 'מחק את החשבון';
  String get deleteAccountButton => 'מחק חשבון לצמיתות';
  String get deleteAccountSuccess => 'החשבון נמחק בהצלחה';
  String deleteAccountError(String error) => 'שגיאה במחיקת החשבון: $error';
  String get deleteAccountRequiresReauth => 'נדרשת התחברות מחדש לפני מחיקת החשבון';
  String get loading => 'טוען...';
  String loadError(String error) => 'Error loading settings: $error';
  String saveError(String error) => 'Error saving settings: $error';

  // Profile editing
  String get editProfileTitle => 'עריכת פרופיל';
  String get chooseAvatar => 'בחר אווטאר:';
  String get displayNameLabel => 'שם תצוגה:';
  String get displayNameHint => 'הכנס את שמך';
  String get enterNameError => 'נא להזין שם';
  String get profileUpdated => 'הפרופיל עודכן בהצלחה';
  String profileUpdateError(String error) => 'שגיאה בעדכון: $error';

  // Debug/Misc
  String get loggingOut => 'מתנתק...';
  String logoutError(String error) => 'שגיאה בהתנתקות: $error';
  String get debugDeleteTitle => 'פעולה זו תמחק הכל כולל seenOnboarding.\nתחזור למסך Welcome.';
  String get debugOnlyLabel => 'זמין רק ב-Debug Mode';
  String get debugDeleteAll => 'מחק הכל';
  String get deletingData => 'מוחק נתונים...';
  String deleteDataError(String error) => 'שגיאה במחיקה: $error';

  // Invite
  String get invalidEmail => 'אימייל לא תקין';
  String get defaultUserName => 'משתמש';
  String get defaultHouseholdName => 'הבית שלי';
  String inviteError(String error) => 'שגיאה בשליחת ההזמנה';

  // Quick links
  String get pendingInvitesTitle => 'הזמנות ממתינות';
  String get pendingInvitesSubtitle => 'הזמנות שקיבלת לרשימות';
  String get showOnboardingAgain => 'הצג הדרכה מחדש';
  String get languageHebrew => 'עברית';
  String get showOnboardingSubtitle => 'צפה שוב בהדרכת האפליקציה';
  String get about => 'אודות';
  String get aboutDescription => 'אפליקציה חכמה לניהול קניות ומזווה ביתי';
  String versionLabel(String version) => 'גרסה $version';
  String get quickLinksTitle => 'קישורים מהירים';
  String get infoTitle => 'מידע';
  String get termsOfService => 'תנאי שימוש';
  String get privacyPolicy => 'מדיניות פרטיות';
  String get debugResetOnboarding => 'מוחק seenOnboarding - חוזר ל-Welcome';
}

// ========================================
// Household Strings
// ========================================

class HouseholdStrings {
  const HouseholdStrings();

  String get typeFamily => 'בית';
  String get typeOther => 'אחר';
  String get typeExtendedFamily => 'משפחה מורחבת';
  String get descFamily => 'ניהול קניות וצרכים משותפים לבית';
  String get descExtendedFamily => 'תכנון קניות ואירועים גדולים למשפחה המורחבת';

  // Members management
  String get removeMemberTitle => 'הסרת חבר';
  String removeMemberConfirm(String name) => 'להסיר את $name מהבית?';
  String get removeMemberButton => 'הסר';
  String removeMemberError(String error) => 'שגיאה בהסרה: $error';
  String genericError(String error) => 'שגיאה: $error';
  String get leaveHouseholdTitle => 'עזיבת הבית';
  String get leaveHouseholdButton => 'עזוב';
  String get leftHousehold => 'עזבת את הבית';
  String get makeAdmin => 'הפוך למנהל';
  String get makeMember => 'הפוך לחבר';
  String get removeFromHousehold => 'הסר מהבית';
  String roleChangeError(String error) => 'שגיאה בשינוי תפקיד: $error';
  String get ownerCannotLeave => 'בעלים לא יכול לעזוב את הבית. ניתן למחוק את הבית או להעביר בעלות';
  String get householdNotFound => 'לא נמצא בית';
  String get loadMembersError => 'שגיאה בטעינת חברי הבית';
  String get leaveHouseholdConfirm => 'בטוח שאתה רוצה לעזוב? תועבר לבית אישי חדש.';
  String memberRemoved(String name) => '$name הוסר מהבית';
  String memberRoleChanged(String name, String role) => '$name הפך ל$role';
  String get membersCount => 'חברים';
  String get roleOwner => 'בעלים';
  String get roleAdmin => 'מנהל';
  String get roleMember => 'חבר';
  String get myHome => 'הבית שלי';
  String get leaveHouseholdTooltip => 'עזוב את הבית';
  String get userFallback => 'משתמש';
  String get meLabel => 'אני';
  String get roleOwnerLabel => '👑 בעלים';
  String get roleAdminLabel => '⭐ מנהל';
  String get roleMemberLabel => '👤 חבר';
}

// ========================================
// List Type Groups Strings
// ========================================

class ListTypeGroupsStrings {
  const ListTypeGroupsStrings();
}

// ========================================
// Templates Strings
// ========================================

class TemplatesStrings {
  const TemplatesStrings();

  String get title => 'תבניות רשימות';
  String get subtitle => 'צור תבניות מוכנות לשימוש חוזר';
  String get filterAll => 'הכל';
  String get filterShared => 'משותפות';
  String get emptyMyTemplatesTitle => 'אין לך תבניות אישיות';
  String get emptyMyTemplatesMessage => 'צור תבנית כדי לחסוך זמן ביצירת רשימות חוזרות';
  String get emptySharedTemplatesTitle => 'אין תבניות משותפות';
  String get emptySharedTemplatesMessage => 'חברי הקבוצה יכולים ליצור תבניות משותפות';
  String itemsCount(int count) => '$count פריטים';
  String get formatShared => 'משותף';
  String get createButton => 'תבנית חדשה';
  String get deleteButton => 'מחק';
  String get useTemplateButton => 'השתמש בתבנית';
  String get nameLabel => 'שם התבנית';
  String get nameHint => 'למשל: קניות שבועיות';
  String get nameRequired => 'נא להזין שם תבנית';
  String get formatSharedDesc => 'כל הקבוצה רואה';
  String get saveButton => 'שמור תבנית';
  String get cancelButton => 'בטל';
  String templateNameExists(String name) => 'תבנית בשם "$name" כבר קיימת';
  String templateCreated(String name) => 'התבנית "$name" נוצרה בהצלחה!';
  String templateUpdated(String name) => 'התבנית "$name" עודכנה!';
  String templateDeleted(String name) => 'התבנית "$name" נמחקה';
  String get undo => 'בטל';
  String updateError(String error) => 'שגיאה בעדכון: $error';
  String deleteError(String error) => 'שגיאה במחיקה: $error';
  String get useTemplateTitle => 'בחר תבנית';
  String get useTemplateHint => 'בחר תבנית כדי למלא את הרשימה אוטומטית';
  String get useTemplateEmpty => 'אין תבניות זמינות';
  String get useTemplateSelect => 'בחר';
}

// ========================================
// Create List Dialog Strings
// ========================================

class CreateListDialogStrings {
  const CreateListDialogStrings();

  String get title => 'יצירת רשימה חדשה';
  String get useTemplateButton => '📋 שימוש בתבנית';
  String get useTemplateTooltip => 'בחר תבנית מוכנה';
  String get selectTemplateTitle => 'בחר תבנית';
  String get selectTemplateHint => 'בחר תבנית כדי למלא את הרשימה אוטומטית';
  String get noTemplatesAvailable => 'אין תבניות זמינות';
  String get noTemplatesMessage => 'צור תבנית ראשונה במסך התבניות';
  String templateSelected(String name) => 'תבנית "$name" נבחרה';
  String templateApplied(String name, int itemsCount) => '✨ התבנית "$name" הוחלה בהצלחה! נוספו $itemsCount פריטים';
  String get nameLabel => 'שם הרשימה';
  String get nameHint => 'למשל: קניות השבוע';
  String get nameRequired => 'נא להזין שם רשימה';
  String nameAlreadyExists(String name) => 'רשימה בשם "$name" כבר קיימת';
  String get typeLabel => 'סוג הרשימה';
  String get budgetLabel => 'תקציב (אופציונלי)';
  String get budgetHint => '₪500';
  String get budgetInvalid => 'נא להזין מספר תקין';
  String get budgetMustBePositive => 'תקציב חייב להיות גדול מ-0';
  String get clearBudgetTooltip => 'נקה תקציב';
  String get eventDateLabel => 'תאריך אירוע (אופציונלי)';
  String get eventDateHint => 'למשל: יום הולדת, אירוח';
  String get noDate => 'אין תאריך';
  String get selectDate => 'בחר תאריך אירוע';
  String get clearDateTooltip => 'נקה תאריך';
  String get cancelButton => 'בטל';
  String get cancelTooltip => 'ביטול יצירת הרשימה';
  String get createButton => 'צור רשימה';
  String get creating => 'יוצר...';
  String get loadingTemplates => 'טוען תבניות...';
  String get loadingTemplatesError => 'שגיאה בטעינת תבניות';
  String listCreated(String name) => 'הרשימה "$name" נוצרה בהצלחה! 🎉';
  String listCreatedWithBudget(String name, double budget) =>
      'הרשימה "$name" נוצרה עם תקציב ₪${budget.toStringAsFixed(0)}';
  String get validationFailed => 'אנא תקן את השגיאות בטופס';
  String get userNotLoggedIn => 'משתמש לא מחובר';
  String createListError(String error) => 'שגיאה ביצירת הרשימה';
  String get createListErrorGeneric => 'אירעה שגיאה ביצירת הרשימה. נסה שוב.';
  String get networkError => 'בעיית רשת. בדוק את החיבור לאינטרנט';
  String get removeTemplateTooltip => 'הסר תבנית';
  String get visibilityLabel => 'מי יראה את הרשימה?';
  String get visibilityPrivate => '🔒 אישית';
  String get visibilityHousehold => '👨‍👩‍👧 משותף לבית';
  String get visibilityShared => '👥 שיתוף';
  String get visibilityPrivateDesc => 'רק אתה תראה את הרשימה הזו';
  String get visibilityHouseholdDesc => 'כל חברי הבית יוכלו לראות ולערוך';
  String get visibilitySharedDesc => 'שתף עם אנשים ספציפיים (ללא גישה למזווה שלך)';
  String get eventModeLabel => 'איך תנהלו את הרשימה?';
  String get eventModeWhoBrings => 'מי מביא מה';
  String get eventModeWhoBringsDesc => 'כל משתתף מתנדב להביא פריטים';
  String get eventModeShopping => 'קנייה רגילה';
  String get eventModeShoppingDesc => 'אדם אחד קונה את כל הרשימה';
  String get eventModeTasks => 'משימות אישיות';
  String get eventModeTasksDesc => 'צ\'קליסט פשוט רק לי';
  String get recommended => 'מומלץ';
  String get selectContactsButton => 'בחר אנשים לשיתוף';
  String get addMoreContactsButton => 'הוסף עוד אנשים';
  String get pendingInviteNote => 'משתמשים שאינם רשומים יקבלו הזמנה ממתינה';
}

// ========================================
// Manage Users Strings
// ========================================

class ManageUsersStrings {
  const ManageUsersStrings();

  String get title => 'ניהול משתמשים';
  String get me => 'אני';
  String get you => 'אתה';
  String userShortId(String shortId) => 'משתמש #$shortId';
  String get defaultUserName => 'משתמש';
  String get errorUserNotLoggedIn => 'שגיאה: משתמש לא מחובר';
  String get errorNoPermissionRemove => 'אין לך הרשאה להסיר משתמשים';
  String get errorNoPermissionEditRole => 'אין לך הרשאה לשנות תפקידים';
  String get errorNoHousehold => 'שגיאה: משתמש לא משויך למשק בית';
  String errorRemovingUser(String error) => 'שגיאה בהסרת משתמש: $error';
  String errorUpdatingRole(String error) => 'שגיאה בעדכון תפקיד: $error';
  String get removeUserTitle => 'הסרת משתמש';
  String removeUserConfirmation(String name) => 'האם אתה בטוח שברצונך להסיר את $name?';
  String get removeButton => 'הסר';
  String get userRemovedSuccess => 'משתמש הוסר בהצלחה';
  String get editRoleTitle => 'עריכת תפקיד';
  String selectNewRole(String name) => 'בחר תפקיד חדש עבור $name:';
  String roleUpdatedSuccess(String roleName) => 'התפקיד עודכן ל-$roleName';
  String get cancel => 'ביטול';
  String get inviteUser => 'הזמן משתמש';
  String get editRole => 'ערוך תפקיד';
  String get removeUser => 'הסר משתמש';
  String get loadingUsers => 'טוען משתמשים...';
  String get retryButton => 'נסה שוב 🔄';
  String get noSharedUsers => 'אין משתמשים משותפים';
  String get inviteUsersHint => 'לחץ על + להזמנת משתמשים';
  String get onlyOwnerCanInvite => 'רק בעל הרשימה יכול להזמין משתמשים';
}

// ========================================
// Inventory Strings
// ========================================

class InventoryStrings {
  const InventoryStrings();

  String get addDialogTitle => 'הוספת פריט';
  String get editDialogTitle => 'עריכת פריט';
  String get addButton => 'הוסף';
  String get saveButton => 'שמור';
  String get productNameLabel => 'שם הפריט';
  String get productNameHint => 'לדוגמה: חלב';
  String get productNameRequired => 'נא להזין שם פריט';
  String get categoryLabel => 'קטגוריה';
  String get quantityLabel => 'כמות';
  String get unitLabel => 'יחידה';
  String get unitHint => 'יח\', ק"ג, ליטר';
  String get locationLabel => 'מיקום';
  String get addLocationButton => 'הוסף';
  String get addLocationTitle => 'הוספת מיקום חדש';
  String get locationNameLabel => 'שם המיקום';
  String get locationNameHint => 'לדוגמה: "מקרר קטן"';
  String get selectEmojiLabel => 'בחר אמוג\'י:';
  String get locationAdded => 'מיקום נוסף! 📍';
  String get locationExists => 'מיקום זה כבר קיים';
  String get locationNameRequired => 'נא להזין שם מיקום';
  String get filterLabel => 'סינון מזווה';
  String get filterByCategory => 'סינון לפי קטגוריה';
  String get itemAdded => 'הפריט נוסף בהצלחה';
  String get itemUpdated => 'הפריט עודכן בהצלחה';
  String get addError => 'שגיאה בהוספת פריט';
  String get updateError => 'שגיאה בעדכון פריט';
  String get addFromCatalogTitle => 'הוספה מהקטלוג';
  String get searchProductsHint => 'חיפוש מוצר...';
  String get loadingProducts => 'טוען מוצרים...';
  String get noProductsFound => 'לא נמצאו מוצרים';
  String get noProductsAvailable => 'אין מוצרים זמינים';
  String productAddedSuccess(String name) => '$name נוסף למזווה!';
  String get stockOutOfStock => 'נגמר! צריך לקנות';
  String stockOnlyOneLeft(String unit) => 'נשאר 1 $unit בלבד';
  String stockOnlyFewLeft(int count, String unit) => 'נשארו רק $count $unit';
  String get unknownSuggestionWarning => 'סוג המלצה לא מוכר - נדרש עדכון אפליקציה';
  String get unknownSuggestionCannotDelete => 'לא ניתן למחוק המלצה לא מוכרת';
  String get unknownSuggestionUpdateApp => 'עדכן אפליקציה';
  // Pantry item dialog
  String get defaultUnit => 'יח\'';
  String get statisticsLabel => 'סטטיסטיקות';
  String get popularLabel => 'פופולרי';
  String get selectExpiryDate => 'בחר תאריך תפוגה';
  String get cancelLabel => 'ביטול';
  String get confirmLabel => 'אישור';
  String get quantityLabelShort => 'כמות';
  String get minimumLabel => 'מינימום';
  String get advancedSettings => 'הגדרות נוספות';
  String get expiryDateLabel => 'תאריך תפוגה';
  String get clearDateTooltip => 'נקה תאריך';
  String get notSetLabel => 'לא הוגדר';
  String get notesLabel => 'הערות';
  String get autoAddToLists => 'יתווסף אוטומטית לרשימות חדשות';
  String get defaultCategory => 'כללי';

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
  String expiryAlertSemanticLabel(int expiredCount, int expiringSoonCount, bool isExpiredMode) => isExpiredMode
      ? 'התראת תפוגה: $expiredCount פריטים פגי תוקף, $expiringSoonCount עומדים לפוג'
      : 'התראת תפוגה: $expiringSoonCount פריטים עומדים לפוג בקרוב';
  String get expiryAlertCloseTooltip => 'סגור';
  String get expiryAlertGoToPantryTooltip => 'עבור למזווה לצפייה בכל הפריטים';
  String get expiryAlertDismissTodayTooltip => 'התראה זו לא תוצג שוב היום';
  String get expiryExpiredToday => 'פג היום';
  String get expiryExpiredYesterday => 'פג אתמול';
  String expiryExpiredDaysAgo(int days) => 'פג לפני $days ימים';
  String get expiryExpiresToday => 'פג היום!';
  String get expiryExpiresTomorrow => 'פג מחר';
  String expiryExpiresInDays(int days) => 'פג בעוד $days ימים';
  String get settingsTitle => 'הגדרות מזווה';
  String get settingsSemanticLabel => 'דיאלוג הגדרות מזווה';
  String get pantryModePersonal => 'מזווה אישי - רק שלך';
  String get pantryModeGroup => 'מחובר למזווה משותף של הקבוצה';
  String get alertsSectionTitle => 'התראות';
  String get settingsLowStockAlertTitle => 'התראת מלאי נמוך';
  String get settingsLowStockAlertSubtitle => 'קבל התראה כשפריט מגיע למינימום';
  String get settingsExpiryAlertTitle => 'התראת תפוגה';
  String get settingsExpiryAlertSubtitle => 'קבל התראה על מוצרים שעומדים לפוג';
  String get settingsExpiryAlertDaysPrefix => 'התראה ';
  String get settingsExpiryAlertDaysSuffix => ' ימים לפני תפוגה';
  String get displaySectionTitle => 'תצוגה';
  String get showExpiredFirstTitle => 'הצג פגי תוקף ראשונים';
  String get showExpiredFirstSubtitle => 'פריטים שפג תוקפם יופיעו בראש הרשימה';
  String get lowStockAlertTitle => 'מלאי נמוך';
  String lowStockAlertSubtitle(int count) => '$count מוצרים עומדים להיגמר';
  String get lowStockAlertAddToList => 'הוסף לרשימה';
  String get lowStockAlertGoToPantry => 'למזווה';
  String get lowStockAlertDismissToday => 'אל תציג שוב היום';
  String lowStockAlertMoreItems(int count) => 'ועוד $count מוצרים...';
  String lowStockAlertSemanticLabel(int count) => 'התראת מלאי נמוך: $count מוצרים עומדים להיגמר';
  String get lowStockAlertCloseTooltip => 'סגור';
  String get lowStockAlertAddToListTooltip => 'הוסף את כל המוצרים לרשימת הקניות';
  String get lowStockAlertGoToPantryTooltip => 'עבור למזווה לצפייה בכל הפריטים';
  String get lowStockAlertDismissTodayTooltip => 'התראה זו לא תוצג שוב היום';
  String get locationMainPantry => 'מזווה';
  String get locationMainPantryDesc => 'מזווה ראשי - מוצרים יבשים';
  String get locationRefrigerator => 'מקרר';
  String get locationRefrigeratorDesc => 'מקרר - מוצרים טריים';
  String get locationFreezer => 'מקפיא';
  String get locationFreezerDesc => 'מקפיא - מוצרים קפואים';
  String get locationKitchen => 'מטבח';
  String get locationKitchenDesc => 'ארונות מטבח - כלים ומוצרי בישול';
  String get locationBathroom => 'אמבטיה';
  String get locationBathroomDesc => 'אמבטיה - מוצרי טיפוח וניקיון';
  String get locationStorage => 'מחסן';
  String get locationStorageDesc => 'מחסן - מארזים גדולים ומלאי';
  String get locationServicePorch => 'מרפסת שירות';
  String get locationServicePorchDesc => 'מרפסת שירות - כביסה וניקיון';
  String get locationOther => 'אחר';
  String get locationOtherDesc => 'מיקום אחר';
  String get locationUnknown => 'לא ידוע';
  String get locationUnknownDesc => 'מיקום לא מוכר';
  String maxItemsReached(int max) => 'הגעת למקסימום $max פריטים במזווה';
  String pantryHealthStatus(double healthPercent) {
    if (healthPercent >= 80) return 'המזווה מלא ומוכן! 💚';
    if (healthPercent >= 50) return 'המזווה במצב סביר, כדאי להשלים כמה דברים';
    if (healthPercent >= 25) return 'המלאי יורד — כדאי לצאת לסופר 🛒';
    return 'המזווה כמעט ריק — דורש תשומת לב! 🚨';
  }

  String get pantryHealthLabel => 'בריאות המזווה';
  String pantryHealthPercent(int percent) => '$percent% מלאי תקין';
  String get pantryFullyStocked => 'הכל במלאי — אין מה לדאוג!';
  String pantryLowItems(int count) => count == 1 ? 'מוצר אחד עומד להיגמר' : '$count מוצרים עומדים להיגמר';

  // Pantry item dialog
  String get quantityMustBePositive => 'כמות חייבת להיות גדולה מאפס';
  String get notesHint => 'הערות נוספות (אופציונלי)';
  String get permanentProduct => 'מוצר קבוע';
  String addCustomProduct(String query) => 'הוסף "$query"';

  // Product selection sheet
  String get inPantryBadge => 'במזווה';
  String get customProductNotFound => 'לא מצאת? הוסף מוצר חדש';
  String get allCategoriesFilter => 'הכל';
  String get tapToAddToPantry => 'לחץ להוספה למזווה';
  String get productFallbackName => 'מוצר';
  String get categoryFallbackName => 'אחר';
  String loadProductsError(String error) => 'שגיאה בטעינת מוצרים: $error';

  // Pantry merge dialog
  String get pantryMergeTitle => 'יש לך מזווה אישי!';
  String pantryMergeContent(int count) =>
      'יש לך $count מוצרים במזווה האישי.\n\nתרצה להעביר אותם למזווה של הבית החדש?';
  String get pantryMergeButton => 'העבר למזווה הבית';
}

// ========================================
// Shopping List Details
// ========================================

class ShoppingListDetailsStrings {
  const ShoppingListDetailsStrings();

  String get addProductTitle => 'הוספת מוצר';
  String get editProductTitle => 'עריכת מוצר';
  String get productNameLabel => 'שם מוצר';
  String get brandLabel => 'חברה/מותג (אופציונלי)';
  String get categoryLabel => 'קטגוריה';
  String get selectCategory => 'בחר קטגוריה';
  String get quantityLabel => 'כמות';
  String get priceLabel => 'מחיר ליחידה';
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
  String get productNameEmpty => 'שם המוצר לא יכול להיות ריק';
  String get quantityInvalid => 'כמות לא תקינה (1-9999)';
  String get priceInvalid => 'מחיר לא תקין (חייב להיות מספר חיובי)';
  String get taskNameEmpty => 'שם המשימה לא יכול להיות ריק';
  String get searchHint => 'חפש פריט...';
  String get sortPriceDesc => 'מחיר (יקר→זול)';
  String itemsCount(int count) => '$count פריטים';
  String get categoryAll => 'הכל';
  String get categoryDairy => 'חלב וביצים';
  String get categoryOther => 'אחר';
  String get addProductButton => 'הוסף מוצר';
  String get addTaskButton => 'הוסף משימה';
  String get shareListTooltip => 'שתף רשימה';
  String get pendingRequestsTooltip => 'בקשות ממתינות';
  String get addFromCatalogTooltip => 'הוסף מהקטלוג';
  String get deleteTitle => 'מחיקת מוצר';
  String deleteMessage(String name) => 'האם למחוק את "$name"?';
  String itemDeleted(String name) => 'המוצר "$name" נמחק';
  String get totalLabel => 'סה״כ:';
  String get emptyListTitle => 'הרשימה ריקה';
  String get emptyListSubtitle => 'חפש מוצרים למעלה או הוסף מהקטלוג';
  String get populateFromCatalog => 'אכלס מהקטלוג';
  String get quickSearchHint => 'חפש מוצר להוספה...';
  String get addFreeText => 'הוסף כטקסט חופשי';
  String categoriesCount(int count) => '$count קטגוריות';
  String get noSearchResultsTitle => 'לא נמצאו פריטים';
  String get clearSearchButton => 'נקה חיפוש';
  String get loadingError => 'שגיאה בטעינת הנתונים';
  String get errorTitle => 'אופס! משהו השתבש';
  String errorMessage(String? error) => error ?? 'אירעה שגיאה בטעינת הנתונים';
}

// ========================================
// User Sharing System
// ========================================

class SharingStrings {
  const SharingStrings();

  String get roleOwner => 'בעלים';
  String get roleAdmin => 'מנהל';
  String get roleEditor => 'עורך';
  String get roleViewer => 'צופה';
  String get roleOwnerDesc => 'גישה מלאה + מחיקת רשימה + ניהול משתמשים';
  String get roleAdminDesc => 'גישה מלאה + ניהול משתמשים (ללא מחיקה)';
  String get roleEditorDesc => 'קריאה + הוספת פריטים דרך בקשות (צריך אישור)';
  String get roleViewerDesc => 'קריאה בלבד (לא יכול לערוך כלום)';
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
  String inviteSent(String email) => 'ההזמנה נשלחה ל-$email 📧';
  String inviteResent(String email) => 'ההזמנה נשלחה שוב ל-$email';
  String get userNotFound => 'משתמש לא נמצא במערכת';
  String get cannotInviteSelf => 'לא ניתן להזמין את עצמך';
  String inviteError(String error) => 'שגיאה בשליחת הזמנה: $error';
  String get inviteUserButton => 'הזמן משתמש';
  String get changeRoleTooltip => 'שנה תפקיד';
  String get resendInviteTooltip => 'שלח הזמנה שוב';
  String get changeRoleTitle => 'שינוי תפקיד';
  String changeRoleMessage(String userName) => 'בחר תפקיד חדש עבור $userName:';
  String get changeRoleButton => 'שנה';
  String roleChanged(String userName, String newRole) => '$userName עודכן ל-$newRole';
  String changeRoleError(String error) => 'שגיאה בשינוי תפקיד: $error';
  String get removeUserTitle => 'הסרת משתמש';
  String get removeButton => 'הסר';
  String userRemoved(String userName) => '$userName הוסר מהרשימה';
  String get savedContactsTitle => 'אנשי קשר שמורים';
  String get savedContactsSubtitle => 'בחר מאנשי קשר שהזמנת בעבר';
  String showMoreContacts(int count) => 'הצג עוד $count אנשי קשר';
  String get orEnterNewEmail => '── או הזן אימייל חדש ──';
  String get contactSelectedEmailDisabled => 'איש קשר נבחר - האימייל לא ישמש';
  String get alreadySharedBadge => 'כבר שותף';
  String inviteConfirmation(String recipient, String role, String listName) =>
      'הזמנה תישלח ל-$recipient כ$role ברשימה "$listName"';
  String inviteSentPending(String name) => 'הזמנה נשלחה ל$name - ממתינה לאישור';
  String inviteSentUnregistered(String name) => 'הזמנה נשלחה ל$name - יראה אותה כשיירשם לאפליקציה';
  String get householdNameDialogTitle => 'איך לקרוא לקבוצה שלכם?';
  String get householdNameDialogHint => 'לדוגמה: הבית של כהן';
  String get householdNameDialogSkip => 'דלג';
  String get cannotChangeOwnRole => 'לא ניתן לשנות את התפקיד שלך';
  String get noPermissionInvite => 'רק הבעלים יכול להזמין משתמשים';
  String get pendingRequestsTitle => 'בקשות ממתינות';
  String get noPermissionViewRequests => 'רק בעלים/מנהלים יכולים לראות בקשות';
  String get noPendingRequests => 'אין בקשות ממתינות';
  String get noPendingRequestsSubtitle => 'בקשות מעורכים יופיעו כאן לאישור';
  String get requestTypeAdd => 'הוספה';
  String get requestTypeEdit => 'עריכה';
  String get requestTypeDelete => 'מחיקה';
  String get requestTypeInvite => 'הזמנה';
  String get requestTypeUnknown => 'לא מוכר';
  String get unknownRequestWarning => 'סוג בקשה לא מוכר - נדרש עדכון אפליקציה';
  String get viewDetailsButton => 'פרטים';
  String get approveButton => 'אשר ✅';
  String get rejectButton => 'דחה ❌';
  String get backButton => 'חזור';
  String get unknownUserFallback => 'משתמש לא ידוע';
  String get unknownItemFallback => 'פריט לא ידוע';
  String get editItemFallback => 'עריכת פריט';
  String get deleteItemFallback => 'מחיקת פריט';
  String get unknownRequestFallback => 'בקשה לא מוכרת';
  String get requestDetailsTitle => 'פרטי בקשה';
  String get quantityLabel => 'כמות';
  String get categoryLabel => 'קטגוריה';
  String get priceLabel => 'מחיר';
  String get notesLabel => 'הערות';
  String requestApproved(String itemName) => '✅ הבקשה להוספת "$itemName" אושרה';
  String get requestApprovedSuccess => 'הבקשה אושרה בהצלחה';
  String get requestApprovedError => 'שגיאה באישור הבקשה';
  String requestRejected(String itemName) => '❌ הבקשה להוספת "$itemName" נדחתה';
  String get requestRejectedSuccess => 'הבקשה נדחתה';
  String get requestRejectedError => 'שגיאה בדחיית הבקשה';
  String get rejectDialogTitle => 'דחיית בקשה';
  String get rejectDialogMessage => 'למה לדחות את הבקשה? (אופציונלי)';
  String get rejectReasonHint => 'סיבת הדחייה...';
  String get noPermissionTitle => 'אין הרשאה';
  String get onlyOwnerCanChangePermissions => 'רק הבעלים יכול לשנות הרשאות';
  String get mustBeOwnerOrAdmin => 'חייבים להיות בעלים או מנהל לביצוע פעולה זו';
  String get requestCreated => 'הבקשה נשלחה לאישור הבעלים/מנהלים';
  String editorRequestsMixed(int approved, int rejected) => '✅ $approved בקשות אושרו | ❌ $rejected נדחו';
  String editorRequestsApproved(int count) => '✅ $count מהבקשות שלך אושרו!';
  String editorRequestsRejected(int count) => '❌ $count מהבקשות שלך נדחו';
  String get requestWaitingApproval => 'הפריט ימתין לאישור לפני שיופיע ברשימה';
  String get notificationInviteTitle => 'הזמנה לרשימה משותפת';
  String notificationInviteBody(String listName, String inviterName) => '$inviterName הזמין אותך לרשימה "$listName"';
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
  String notificationRoleChangedBody(String newRole, String listName) => 'התפקיד שלך ב"$listName" שונה ל-$newRole';
  String get notificationRemovedTitle => 'הוסרת מרשימה';
  String notificationRemovedBody(String listName) => 'הוסרת מהרשימה "$listName"';
  String get sharedListBadge => 'משותפת';
  String sharedWith(int count) => 'משותפת עם $count אנשים';
  String get youAreAdmin => 'אתה מנהל';
  String get loadingUsers => 'טוען משתמשים...';
  String get loadingError => 'שגיאה בטעינת נתונים';
  String get retryButton => 'נסה שוב';
  String maxGroupsReached(int max) => 'הגעת למקסימום $max קבוצות';
  String groupsNearLimit(int current, int max) => 'יש לך $current מתוך $max קבוצות';
  String get rejectRequestTitle => 'דחיית בקשה';
  String get rejectRequestConfirm => 'בטוח שברצונך לדחות את הבקשה?';
  String get rejectRequestButton => 'דחה';
}

// ========================================
// Select List Dialog
// ========================================

class SelectListStrings {
  const SelectListStrings();

  String get defaultTitle => 'בחר רשימה';
  String addingItem(String itemName) => 'מוסיף: $itemName';
  String get noActiveLists => 'אין רשימות פעילות';
  String get createNewToAddItems => 'צור רשימה חדשה כדי להוסיף פריטים';
  String get createNewButton => 'צור רשימה חדשה';
  String get cancelButton => 'ביטול';
  String get closeTooltip => 'סגור';
  String get createNewTooltip => 'צור רשימת קניות חדשה';
  String get cancelTooltip => 'ביטול בחירת רשימה';
  String itemsCount(int count) => '$count פריטים';
  String get semanticLabel => 'בחירת רשימה';
  String semanticLabelWithItem(String itemName) => 'בחירת רשימה להוספת $itemName';
  String listTileSemanticLabel(String listName, int itemCount, int checkedCount) =>
      '$listName, $itemCount פריטים${checkedCount > 0 ? ', $checkedCount סומנו' : ''}';
}

// ========================================
// Recurring Product Dialog
// ========================================

class RecurringStrings {
  const RecurringStrings();

  String get title => 'מוצר פופולרי!';
  String get subtitle => 'נראה שאתה קונה את זה לעתים קרובות';
  String get statPurchases => 'קניות';
  String get statLastPurchase => 'קנייה אחרונה';
  String formatLastPurchase(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'היום';
    if (diff == 1) return 'אתמול';
    if (diff < 7) return 'לפני $diff ימים';
    if (diff < 30) return 'לפני ${(diff / 7).floor()} שבועות';
    return 'לפני ${(diff / 30).floor()} חודשים';
  }

  String get explanation => 'מוצר קבוע יתווסף אוטומטית לרשימות קניות חדשות';
  String get confirmButton => 'הפוך לקבוע';
  String get dismissButton => 'לא, תודה';
  String get askLaterButton => 'שאל אותי אחר כך';
  String get closeTooltip => 'סגור';
  String get confirmTooltip => 'הפוך למוצר קבוע';
  String get dismissTooltip => 'לא להציע מוצר זה כמוצר קבוע';
  String get askLaterTooltip => 'תזכיר לי בפעם הבאה';
  String semanticLabel(String productName) => 'הצעה להפוך את $productName למוצר קבוע';
}

// ========================================
// Receipt Details
// ========================================

class ReceiptDetailsStrings {
  const ReceiptDetailsStrings();

  String get totalLabel => 'סה"כ';
  String get virtualTag => 'וירטואלי';
  String get noItemsMessage => 'אין פריטים בקבלה';
}

// ========================================
// Shopping History
// ========================================

class ShoppingHistoryStrings {
  const ShoppingHistoryStrings();

  String get title => 'היסטוריית קניות';
  String get sortTooltip => 'מיון';
  String get sortByDate => 'לפי תאריך';
  String get sortByList => 'לפי סוג רשימה';
  String get sortByAmount => 'לפי סכום';
  String get filterThisMonth => 'החודש';
  String get filterThreeMonths => '3 חודשים';
  String get filterAll => 'הכל';
  String get shoppingsLabel => 'קניות';
  String get totalLabel => 'סה"כ';
  String get averageLabel => 'ממוצע';
  String get totalItemsLabel => 'פריטים';
  String itemsCount(int count) => '$count פריטים';
  String get virtualTag => 'וירטואלי';
  String get noResults => 'אין קניות בתקופה זו';
  String get noResultsSubtitle => 'נסה לסנן לפי תקופה אחרת';
  String get emptyTitle => 'עוד לא סיימת קניות';
  String get emptySubtitle => 'רשימות שתסיים יופיעו כאן כדי שתוכל\nלעקוב אחרי הקניות שלך! 🛒';
  String get defaultError => 'שגיאה בטעינה';
  String get retryButton => 'נסה שוב';
}

// ========================================
// Active Shopper Banner
// ========================================

class ActiveShopperBannerStrings {
  const ActiveShopperBannerStrings();

  String get myActiveTitle => 'יש לך קנייה פעילה';
  String myActiveSubtitle(String listName, int remaining) => '"$listName" - נותרו $remaining פריטים';
  String get continueButton => 'המשך';
  String othersActiveTitle(String shopperName) => '$shopperName קונה עכשיו';
  String othersActiveTitleMultiple(int count) => '$count קונים עכשיו';
  String othersActiveSingle(String listName) => 'קונה מ"$listName"';
  String othersActiveMultiple(int count, String listName) => '$count אנשים קונים מ"$listName"';
  String get joinButton => 'להצטרף';
  String get viewListTooltip => 'צפייה חיה';
  String shopperJoined(String name) => '$name הצטרף/ה לקנייה';
  String shopperLeft(String name) => '$name עזב/ה את הקנייה';
  String shopperUpdatingPantry(String name) => '$name מעדכן/ת את המזווה כרגע';
  String shopperCheckedItem(String name, String item) => '$name סימן/ה "$item" כנקנה';
  String activeShoppersCount(int count) => '$count קונים פעילים כרגע';
  String shopperAvatarLabel(String name, bool isStarter) =>
      isStarter ? '$name (התחיל/ה את הקנייה)' : '$name קונה עכשיו';
  String get moreShoppersLabel => 'עוד קונים פעילים';
}

// ========================================
// Suggestions Today Card
// ========================================

class SuggestionsTodayCardStrings {
  const SuggestionsTodayCardStrings();

  String get title => 'הצעות מהמזווה';
  String get loading => 'טוען הצעות...';
  String itemCount(int count) => '$count פריטים';
  String get urgencyCritical => 'נגמר!';
  String get urgencyHigh => 'כמעט נגמר';
  String get urgencyMedium => 'מתמעט';
  String get urgencyLow => 'מומלץ';
  String inStock(int stock, String unit) => 'במלאי: $stock $unit';
  String get addButton => 'הוסף';
  String get noActiveLists => 'אין רשימות פעילות - צור רשימה חדשה';
  String get addedToList => 'נוסף לרשימה';
  String addedToListName(String productName) => 'נוסף "$productName" לרשימה';
  String dismissedForWeek(String productName) => 'דחיתי "$productName" לשבוע';
  String suggestionError(String error) => 'שגיאה: $error';
  String get addAll => 'הוסף הכל';
  String addedAll(int count, String listName) => '$count פריטים נוספו ל"$listName"';
}

// ========================================
// Last Chance Banner
// ========================================

class LastChanceBannerStrings {
  const LastChanceBannerStrings();

  String get title => 'רגע, הנה משהו שבדרך כלל חסר לך...';
  String semanticsLabel(String productName, int stock) =>
      'המלצה חכמה: $productName עומד להיגמר במזווה שלך. נותרו $stock יחידות. לחץ פעמיים להוספה לרשימה.';
  String stockText(int stock) => 'נשארו רק $stock במזווה';
  String addTooltip(String productName) => 'הוסף "$productName" לרשימת הקניות';
  String get addButton => 'הוסף לרשימה';
  String get nextTooltip => 'עבור להמלצה הבאה';
  String get nextButton => 'הבא';
  String get skipSessionTooltip => 'דלג — נזכיר לך בפעם הבאה';
  String get skipSessionButton => 'לא הפעם';
  String addedSuccess(String productName) => 'נוסף "$productName" לרשימה';
  String get addError => 'שגיאה בהוספת פריט';
  String get genericError => 'אירעה שגיאה, נסה שוב';
  String get skippedForSession => 'נדלג הפעם — נזכיר בקנייה הבאה';
}

// ========================================
// Pending Invites Screen
// ========================================

class PendingInvitesScreenStrings {
  const PendingInvitesScreenStrings();

  String get title => 'הזמנות ממתינות';
  String get loading => 'טוען הזמנות...';
  String get loadError => 'שגיאה בטעינת הזמנות';
  String get retryButton => 'נסה שוב';
  String get emptyTitle => 'אין הזמנות ממתינות';
  String get emptySubtitle => 'כאשר מישהו יזמין אותך לרשימה,\nההזמנה תופיע כאן';
  String get pullToRefresh => '↓ משוך לרענון';
  String get listFallback => 'רשימה';
  String get userFallback => 'משתמש';
  String inviteToList(String listName) => 'הזמנה לרשימה "$listName"';
  String inviterMessage(String inviterName) => '$inviterName מזמין אותך להצטרף';
  String get roleLabel => 'תפקיד: ';
  String get acceptButton => 'הצטרף';
  String get declineButton => 'דחה';
  String acceptSuccess(String listName) => 'הצטרפת לרשימה "$listName"';
  String acceptError(String error) => 'שגיאה באישור ההזמנה: $error';
  String get declineDialogTitle => 'דחיית הזמנה';
  String declineDialogMessage(String listName) => 'לדחות את ההזמנה לרשימה "$listName"?';
  String get cancelButton => 'ביטול';
  String get declineConfirmButton => 'דחה';
  String get declineSuccess => 'ההזמנה נדחתה';
  String declineError(String error) => 'שגיאה בדחיית ההזמנה: $error';

  // Pending requests
  String pendingRequestsLabel(int count) => 'בקשות ממתינות לאישור, $count בקשות';
  String get rejectRequest => 'דחה את הבקשה';
  String get rejectButton => 'דחה';
  String get approveRequest => 'אשר את הבקשה';
  String get approveButton => 'אשר';
  String approveError(String error) => 'שגיאה באישור הבקשה: $error';
  String rejectError(String error) => 'שגיאה בדחיית הבקשה: $error';
}

// ========================================
// Pending Invite Banner
// ========================================

class PendingInviteBannerStrings {
  const PendingInviteBannerStrings();

  String get title => 'הזמנה לקבוצה';
  String moreCount(int count) => '+$count';
  String inviteMessage(String inviterName, String groupName) => '$inviterName הזמין אותך ל"$groupName"';
  String get acceptButton => 'קבל';
  String get rejectButton => 'דחה';
  String get rejectDialogTitle => 'דחיית הזמנה';
  String get cancelButton => 'ביטול';
  String acceptSuccess(String groupName) => 'הצטרפת לקבוצה "$groupName"';
  String get acceptError => 'שגיאה בקבלת ההזמנה';
}

// ========================================
// Home Dashboard Screen
// ========================================

class HomeDashboardStrings {
  const HomeDashboardStrings();

  String get newListButton => 'רשימה חדשה';
  String get errorTitle => 'שגיאה בטעינת נתונים';
  String get retryButton => 'נסה שוב';
  String greeting(String? userName) => (userName?.trim().isNotEmpty ?? false) ? 'שלום, $userName!' : 'שלום!';
  String timeBasedGreeting(String? userName, int hour) {
    final String greet;
    if (hour >= 5 && hour < 12)
      greet = 'בוקר טוב';
    else if (hour >= 12 && hour < 17)
      greet = 'צהריים טובים';
    else if (hour >= 17 && hour < 21)
      greet = 'ערב טוב';
    else
      greet = 'לילה טוב';
    return (userName?.trim().isNotEmpty ?? false) ? '$greet, $userName!' : '$greet!';
  }

  String get personalFamily => 'הבית שלי';
  String get sharedFamily => 'בית משותף';
  String get familyOf => 'הבית של ';
  String get activeListsTitle => 'רשימות פעילות';
  String get noActiveLists => 'אין רשימות פעילות';
  String get createListHint => 'המחברת שלך מוכנה... מה קונים היום?';
  String get createFirstList => 'צור רשימה ראשונה';
  String get emptyList => 'רשימה ריקה';
  String get completed => 'הושלם! ✓';
  String remainingItems(int count) => 'נותרו $count פריטים';
  String itemsCount(int count) => '$count פריטים';
  String get historyTitle => 'היסטוריה';
  String get seeAll => 'ראה הכל';
  String get today => 'היום';
  String get yesterday => 'אתמול';
  String daysAgo(int days) => 'לפני $days ימים';
  String dateFormat(int day, int month, int year) => '$day/$month/$year';

  // Activity feed
  String get activityFeedTitle => 'מה חדש בבית';
  String get youLabel => 'את/ה';
  String get householdMember => 'חבר/ת בית';
  String completedShoppingAt(String store) => '✅ סיים/ה קנייה ב$store';
  String plusItems(int count) => '+$count פריטים';
  String minutesAgo(int minutes) => 'לפני $minutes דק\'';
  String hoursAgo(int hours) => 'לפני $hours שע\'';

  // Active lists subtitle
  String activeListsSubtitle(int count) => '$count רשימות פעילות';

  // User info fallback
  String get userFallback => 'משתמש';
}

// ========================================
// Notifications Center Screen
// ========================================

class NotificationsCenterStrings {
  const NotificationsCenterStrings();

  String get title => 'התראות';
  String get markAllAsRead => 'סמן הכל כנקרא';
  String get userNotLoggedIn => 'משתמש לא מחובר';
  String get loadingError => 'שגיאה בטעינת ההתראות';
  String get retryButton => 'נסה שוב';
  String get emptyTitle => 'אין התראות';
  String get emptySubtitle => 'כשתקבל התראות חדשות, הן יופיעו כאן';
  String get allMarkedAsRead => 'כל ההתראות סומנו כנקראו';
}

// ========================================
// Pantry Screen
// ========================================

class PantryStrings {
  const PantryStrings();

  String get screenLabel => 'מסך המזווה שלי';
  String get addItemLabel => 'הוסף מוצר למזווה';
  String quantityLabel(int quantity, bool isLowStock) =>
      '$quantity יחידות${isLowStock ? ', מלאי נמוך' : ''}, לחץ לעדכון';
  String get pantryPrefix => 'מזווה ';
  String get addItemTooltip => 'הוסף מוצר';
  String get loadingText => 'טוען...';
  String get loadingErrorTitle => 'שגיאה בטעינת המזווה';
  String get loadingErrorDefault => 'נסה שוב מאוחר יותר';
  String get retryButton => 'נסה שוב';
  String get noItemsFound => 'לא נמצאו פריטים';
  String get clearFilters => 'נקה סינון';
  String get noStarterItemsFound => 'לא נמצאו מוצרי יסוד';
  String starterItemsAdded(int count) => 'נוספו $count מוצרי יסוד למזווה';
  String get starterItemsError => 'שגיאה בהוספת מוצרי יסוד';
  String get suggestionsTitle => 'כדאי שיהיה בבית';
  String get hideSuggestions => 'הסתר';
  String itemDeleted(String name) => '$name נמחק';
  String get deleteItemError => 'שגיאה במחיקת פריט';
  String get updateQuantityError => 'שגיאה בעדכון כמות';
  String get searchHint => 'חיפוש במזווה...';
  String get clearSearchTooltip => 'נקה חיפוש';
  String get allLocations => 'הכל';
  String get swipeDelete => 'מחיקה';
  String get deleteDialogTitle => 'מחיקת פריט';
  String deleteDialogContent(String name) => 'האם למחוק את "$name"?';
  String get updateQuantityTitle => 'עדכון כמות:';
  String lowStockWarning(int minQuantity) => 'מלאי נמוך (מינימום: $minQuantity)';
  String get cancelButton => 'ביטול';
  String get saveButton => 'שמור';
  String get unitAbbreviation => 'יח׳';

  // Tabs
  String get tabItems => 'פריטים';
  String get tabMissing => 'חסרים';
  String get tabLocations => 'מיקומים';
  // Empty state
  String get addBasicsButton => 'כן, הוסף!';
  String get emptyLabel => 'מזווה ריק';
  String get addFirstProduct => 'הוסף מוצר ראשון';
  String get emptyMainTitle => 'בואו נמלא את המזווה! 🎉';
  String get emptySubtitlePersonal => 'הוסף מוצרים כדי לדעת תמיד מה יש ומה חסר';
  String get emptySubtitleGroup => 'הוסיפו מוצרים למזווה המשותף כדי לעקוב אחרי מה שיש בבית';
  String get howToStartTitle => 'איך להתחיל?';
  String get howToStartStep1 => 'לחץ על ״הוסף מוצר״ למטה';
  String get howToStartStep2 => 'חפש מוצר מתוך 9,000+ מוצרים';
  String get howToStartStep3 => 'הגדר כמות — וזהו! 🎯';
  String get howToStartHint => '✨ כשמוצר ייגמר, תקבל התראה ברשימת הקניות';
  String get starterItemsTitle => 'רוצה להתחיל עם מוצרי יסוד?';
  String get starterItemsSubtitle => 'קמח, סוכר, שמן, אורז ועוד - נוסיף אותם אוטומטית';
  String pantryBadgeGroup(String name) => 'מזווה הבית — $name';
  String get pantryBadgePersonal => 'המזווה שלך ✨';

  // Duplicate detection
  String get similarProductFound => 'נמצא מוצר דומה במזווה';
  String get existingInPantry => 'קיים במזווה';
  String get scannedProduct => 'מוצר שנסרק';
  String get updateQuantity => 'עדכן כמות';
  String get replaceProduct => 'החלף מוצר';
  String get addSeparately => 'הוסף בנפרד';
}

// ========================================
// Checklist Screen
// ========================================

class ChecklistStrings {
  const ChecklistStrings();

  String get subtitle => 'צ\'קליסט ✓';
  String get gotItButton => 'הבנתי';
  String get checkAll => 'סמן הכל';
  String get uncheckAll => 'בטל הכל';
  String percentComplete(int percent) => '$percent% הושלם';
  String get emptyTitle => 'הרשימה ריקה';
  String get emptySubtitle => 'הוסף פריטים לצ\'קליסט';
}

// ========================================
// Contact Selector Dialog
// ========================================

class ContactSelectorStrings {
  const ContactSelectorStrings();

  String get title => 'בחירת אנשים לשיתוף';
  String get searchHint => 'חיפוש לפי שם או אימייל...';
  String get addNewContact => 'הוסף איש קשר חדש';
  String get emailLabel => 'אימייל';
  String get phoneLabel => 'טלפון';
  String get emailHint => 'הזן אימייל...';
  String get phoneHint => '05X-XXXXXXX';
  String get invalidEmail => 'נא להזין אימייל תקין';
  String get invalidPhone => 'נא להזין מספר טלפון תקין (05X-XXXXXXX)';
  String get contactAlreadySelected => 'איש קשר זה כבר נבחר';
  String genericError(String error) => 'שגיאה: $error';
  String get noSavedContacts => 'אין אנשי קשר שמורים';
  String get noSearchResults => 'לא נמצאו תוצאות';
  String get cancelButton => 'ביטול';
  String confirmButton(int count) => 'אישור ($count)';
  String selectRoleFor(String name) => 'בחר תפקיד עבור $name';
  String get roleOwnerShortDesc => 'בעלים - מלוא ההרשאות';
  String get roleAdminShortDesc => 'יכול לערוך ישירות ולהזמין אחרים';
  String get roleEditorShortDesc => 'יכול לערוך דרך אישור';
  String get roleViewerShortDesc => 'יכול לצפות בלבד';
  String get roleUnknownShortDesc => 'תפקיד לא מוכר';
}

// ========================================
// Shopping Summary
// ========================================

class ShoppingSummaryStrings {
  const ShoppingSummaryStrings();
  String get title => 'קנייה הושלמה בהצלחה!';
  String get successRate => 'הצלחה';
  String get purchasedLabel => 'נרכשו';
  String get missingLabel => 'חסרו';
  String get totalLabel => 'סה"כ';
  String get budgetTitle => 'תקציב';
  String budgetRemaining(String amount) => 'נשאר $amount';
  String budgetOver(String amount) => 'חריגה $amount';
  String get backToHome => 'חזרה לדף הבית';
  String get loadError => 'שגיאה בטעינת הסיכום';
  String get notFound => 'הרשימה לא נמצאה';
  String get notFoundSubtitle => 'ייתכן שהרשימה נמחקה';
}

// ========================================
// Legal Content Strings
// ========================================

// ========================================
// Tutorial
// ========================================

class TutorialStrings {
  const TutorialStrings();

  String get skip => 'דלג';
  String get next => 'הבא';
  String get letsStart => 'בואו נתחיל! 🚀';

  // Step titles
  String get welcomeTitle => 'ברוכים הבאים ל-MemoZap! 🎉';
  String get shoppingTitle => 'יצירת רשימת קניות 🛒';
  String get activeShoppingTitle => 'מצב קנייה פעיל 🏃';
  String get pantryTitle => 'המזווה הביתי 📦';
  String get householdTitle => 'ניהול הבית 🏠';
  String get historyTitle => 'היסטוריה וסטטיסטיקות 📊';
  String get navigationTitle => 'הניווט שלכם 🧭';
  String get readyTitle => 'מוכנים! 🚀';

  // Step descriptions
  String get welcomeDesc =>
      'האפליקציה שתנהל לכם את הקניות, המזווה והבית — במקום אחד.\n\nבואו נכיר בקצרה!';
  String get shoppingDesc =>
      'לחצו על כפתור ➕ רשימה חדשה בדף הבית.\n\nבחרו סוג חנות (סופר, ירקן, מאפייה...) והוסיפו מוצרים מהקטלוג או ידנית.\n\nאפשר לבחור כמות, קטגוריה ועדיפות לכל פריט.';
  String get activeShoppingDesc =>
      'כשמגיעים לחנות — לחצו "התחל קנייה".\n\nהמסך עובר למצב קנייה: סמנו פריטים ✓ תוך כדי הליכה, ראו את ההתקדמות, והוסיפו מוצרים שמצאתם בדרך.\n\nבסיום — תקבלו סיכום עם סכום כולל.';
  String get pantryDesc =>
      'המזווה עוקב אחרי מה שיש בבית.\n\n🔄 אוטומטי: כשמסיימים קנייה — המוצרים עולים למזווה.\n✏️ ידני: לחצו ➕ במזווה להוסיף מוצרים בעצמכם.\n\nכשמשהו אוזל — תופיע הצעה חכמה בדף הבית להוסיף אותו לרשימה הבאה.';
  String get householdDesc =>
      'כך מצרפים חברי בית:\n\n1️⃣ הגדרות → ניהול הבית → הזמן לבית\n2️⃣ שלחו הזמנה באימייל\n3️⃣ המוזמן מאשר ומצטרף\n\nמרגע ההצטרפות — כולם רואים את אותן רשימות ומזווה בזמן אמת. בלי להתקשר לשאול "מה לקנות?" 😄';
  String get historyDesc =>
      'כל קנייה נשמרת כקבלה עם תאריך, חנות וסכום.\n\nבטאב 📜 היסטוריה תראו:\n• כמה הוצאתם החודש\n• ממוצע לקנייה\n• פירוט לפי חנות\n\nאפשר לסנן לפי תקופה ולמיין לפי תאריך, חנות או סכום.';
  String get navigationDesc =>
      '🏠 בית — סיכום יומי, הצעות חכמות ורשימות פעילות\n\n📦 מזווה — כל המוצרים בבית + הוספה ידנית\n\n📜 היסטוריה — קבלות, הוצאות וסטטיסטיקות\n\n⚙️ הגדרות — פרופיל, הבית, התראות, ערכת נושא';
  String get readyDesc =>
      'התחילו ביצירת רשימת הקניות הראשונה שלכם.\n\n💡 טיפ: הוסיפו מוצרים מהקטלוג — הם יזכרו אותם לפעם הבאה!\n\nאפשר תמיד לחזור להדרכה דרך ⚙️ הגדרות → הצג הדרכה מחדש.';
}

class LegalStrings {
  const LegalStrings();

  String get termsOfServiceContent => '''תנאי שימוש — MemoZap

תאריך עדכון אחרון: מרץ 2026

ברוכים הבאים ל-MemoZap! השימוש באפליקציה מותנה בהסכמה לתנאים המפורטים להלן. אנא קראו אותם בעיון.

1. הגדרות
"האפליקציה" — אפליקציית MemoZap לניהול רשימות קניות ומזווה ביתי.
"המשתמש" — כל מי שמשתמש באפליקציה.
"תוכן משתמש" — רשימות קניות, פריטי מזווה, קבלות, ומידע אחר שהמשתמש מזין.

2. תיאור השירות
MemoZap מאפשרת ניהול רשימות קניות משותפות, מעקב אחר מלאי מזווה ביתי, שיתוף רשימות בין חברי הבית, שמירת היסטוריית קניות, וקבלת הצעות חכמות לקניות על בסיס צריכה.

3. חשבון משתמש
• יצירת חשבון מחייבת מסירת שם, כתובת אימייל תקינה ומספר טלפון.
• המשתמש/ת אחראי/ת לשמירת סודיות פרטי ההתחברות.
• יש לדווח מיידית על כל שימוש לא מורשה בחשבון.
• ניתן למחוק את החשבון בכל עת דרך מסך ההגדרות.

4. שימוש מותר ואסור
מותר: שימוש אישי וביתי לניהול קניות ומזווה.
אסור: שימוש מסחרי, העתקה או הפצה של האפליקציה, ניסיון לפרוץ או לשבש את השירות, העלאת תוכן פוגעני או בלתי חוקי.

5. תוכן משתמש
• התוכן שלך שייך לך. אנו לא תובעים בעלות על תוכן משתמש.
• אנו שומרים את התוכן שלך בשרתי Firebase מאובטחים.
• בעת מחיקת חשבון, כל התוכן נמחק לצמיתות.

6. קניין רוחני
כל הזכויות באפליקציה, בעיצוב, בקוד ובתוכן שאינו תוכן משתמש שמורות למפתחי MemoZap.

7. הגבלת אחריות
האפליקציה מסופקת "כמות שהיא" (AS IS). איננו אחראים לנזקים ישירים או עקיפים הנובעים מהשימוש באפליקציה, לאובדן נתונים כתוצאה מתקלות טכניות, או לדיוק המחירים או המידע המוצג.

8. זמינות השירות
אנו שואפים לזמינות מלאה אך לא מתחייבים לכך. ייתכנו הפסקות לתחזוקה או שדרוגים.

9. שינויים בתנאים
אנו רשאים לעדכן תנאים אלה מעת לעת. שינויים מהותיים יפורסמו באפליקציה. המשך השימוש לאחר שינוי מהווה הסכמה לתנאים המעודכנים.

10. דין חל וסמכות שיפוט
על תנאים אלה יחול הדין הישראלי. סמכות השיפוט הבלעדית נתונה לבתי המשפט בירושלים.

11. יצירת קשר
לשאלות או בירורים: memozap.app@gmail.com''';

  String get privacyPolicyContent => '''מדיניות פרטיות — MemoZap

תאריך עדכון אחרון: מרץ 2026

פרטיותך חשובה לנו. מדיניות זו מסבירה אילו נתונים אנו אוספים, כיצד אנו משתמשים בהם, וכיצד אנו מגינים עליהם.

1. מידע שאנו אוספים

א. מידע שנמסר על ידך:
• פרטי חשבון — שם, כתובת אימייל, מספר טלפון
• תוכן משתמש — רשימות קניות, פריטי מזווה, קבלות
• הגדרות — העדפות התראות, ערכת נושא, שם קבוצה

ב. מידע שנאסף אוטומטית:
• מזהה מכשיר ומערכת הפעלה (לצורך Crashlytics)
• נתוני שימוש אנונימיים (Analytics) — מסכים שנצפו, פעולות שבוצעו
• מידע על קריסות ושגיאות (Crashlytics)

ג. מידע שאיננו אוספים:
• מיקום גיאוגרפי
• אנשי קשר מהמכשיר
• תמונות או קבצים מהמכשיר
• מידע פיננסי או אמצעי תשלום

2. כיצד אנו משתמשים במידע
• הפעלת השירות — סנכרון רשימות, מזווה והתראות
• שיפור האפליקציה — ניתוח דפוסי שימוש אנונימיים
• תמיכה טכנית — אבחון ותיקון באגים
• תקשורת — הודעות מערכת חיוניות בלבד

3. שיתוף מידע
• לא נמכור ולא נשכיר את המידע שלך לצדדים שלישיים.
• מידע משותף עם חברי הבית — רק תוכן שבחרת לשתף (רשימות, מזווה).
• ספקי שירות — Firebase (Google) לאחסון ואימות. ראה מדיניות הפרטיות של Google.
• דרישה חוקית — נשתף מידע אם נדרש על פי צו בית משפט או חוק.

4. אחסון ואבטחה
• הנתונים מאוחסנים בשרתי Firebase (Google Cloud) באירופה.
• תעבורת נתונים מוצפנת ב-TLS/SSL.
• גישה למסד הנתונים מוגנת בכללי אבטחה (Firestore Security Rules).
• סיסמאות מוצפנות באמצעות Firebase Authentication — איננו מאחסנים סיסמאות בטקסט גלוי.

5. שמירת מידע
• נתוני החשבון נשמרים כל עוד החשבון פעיל.
• בעת מחיקת חשבון — כל הנתונים נמחקים תוך 30 יום.
• נתוני Analytics אנונימיים נשמרים עד 14 חודשים.

6. זכויותיך (בהתאם לחוק הגנת הפרטיות, התשמ"א-1981)
• זכות עיון — לצפות במידע שנאסף עליך
• זכות תיקון — לתקן מידע שגוי
• זכות מחיקה — למחוק את חשבונך וכל המידע הנלווה
• זכות ניוד — לייצא את הנתונים שלך (פנו אלינו)
• זכות התנגדות — להפסיק שימוש ב-Analytics (פנו אלינו)

למימוש זכויותיך, פנו אלינו בכתובת: memozap.app@gmail.com

7. גיל מינימלי
האפליקציה מיועדת לגילאי 13 ומעלה. איננו אוספים ביודעין מידע על ילדים מתחת לגיל 13.

8. שינויים במדיניות
שינויים מהותיים יפורסמו באפליקציה לפחות 7 ימים לפני כניסתם לתוקף.

9. יצירת קשר
לשאלות בנושא פרטיות: memozap.app@gmail.com''';
}
