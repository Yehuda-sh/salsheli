// lib/l10n/app_strings_en.dart — English strings — all UI text, extends Hebrew base classes with English overrides

import 'app_strings_he.dart';

/// UI Strings - English
class AppStringsEn {
  // Prevent instantiation
  const AppStringsEn._();

  /// App name - single place to change across all UI
  static const String appName = 'MemoZap';

  // ========================================
  // Layout & Navigation
  // ========================================
  static const layout = LayoutStringsEn();
  static const navigation = NavigationStringsEn();

  // ========================================
  // Common UI Elements
  // ========================================
  static const common = CommonStringsEn();

  // ========================================
  // Categories (Pantry & Filters)
  // ========================================
  static const categories = CategoryStringsEn();

  // ========================================
  // Onboarding
  // ========================================

  // ========================================
  // Shopping
  // ========================================
  static const shopping = ShoppingStringsEn();

  // ========================================
  // Index (Splash)
  // ========================================
  static const index = IndexStringsEn();

  // ========================================
  // Welcome
  // ========================================
  static const welcome = WelcomeStringsEn();

  // ========================================
  // Auth (Login/Register)
  // ========================================
  static const auth = AuthStringsEn();

  // ========================================
  // Home Dashboard
  // ========================================
  static const home = HomeStringsEn();

  // ========================================
  // Price Comparison
  // ========================================
  static const priceComparison = PriceComparisonStringsEn();

  // ========================================
  // Settings
  // ========================================
  static const settings = SettingsStringsEn();

  // ========================================
  // Household (Household Types)
  // ========================================
  static const household = HouseholdStringsEn();

  // ========================================
  // List Type Groups
  // ========================================
  static const listTypeGroups = ListTypeGroupsStringsEn();

  // ========================================
  // Templates
  // ========================================
  static const templates = TemplatesStringsEn();

  // ========================================
  // Create List Dialog
  // ========================================
  static const createListDialog = CreateListDialogStringsEn();

  // ========================================
  // Manage Users
  // ========================================
  static const manageUsers = ManageUsersStringsEn();

  // ========================================
  // Inventory (Pantry)
  // ========================================
  static const inventory = InventoryStringsEn();

  // ========================================
  // Shopping List Details
  // ========================================
  static const listDetails = ShoppingListDetailsStringsEn();

  // ========================================
  // Select List Dialog
  // ========================================
  static const selectList = SelectListStringsEn();

  // ========================================
  // Recurring Product Dialog
  // ========================================
  static const recurring = RecurringStringsEn();

  // ========================================
  // User Sharing System
  // ========================================
  static const sharing = SharingStringsEn();

  // ========================================
  // Receipt Details Screen
  // ========================================
  static const receiptDetails = ReceiptDetailsStringsEn();

  // ========================================
  // Shopping History
  // ========================================
  static const shoppingHistory = ShoppingHistoryStringsEn();

  // ========================================
  // Activity Log
  // ========================================
  static const activityLog = ActivityLogStringsEn();

  // ========================================
  // Active Shopper Banner
  // ========================================
  static const activeShopperBanner = ActiveShopperBannerStringsEn();

  // ========================================
  // Suggestions Today Card (Dashboard)
  // ========================================
  static const suggestionsToday = SuggestionsTodayCardStringsEn();

  // ========================================
  // Last Chance Banner
  // ========================================
  static const lastChanceBanner = LastChanceBannerStringsEn();

  // ========================================
  // Pending Invite Banner
  // ========================================
  static const pendingInviteBanner = PendingInviteBannerStringsEn();

  // ========================================
  // Pending Invites Screen
  // ========================================
  static const pendingInvitesScreen = PendingInvitesScreenStringsEn();

  // ========================================
  // Home Dashboard Screen
  // ========================================
  static const homeDashboard = HomeDashboardStringsEn();

  // ========================================
  // Notifications Center Screen
  // ========================================
  static const notificationsCenter = NotificationsCenterStringsEn();

  // ========================================
  // Pantry Screen
  // ========================================
  static const pantry = PantryStringsEn();

  // ========================================
  // Checklist Screen
  // ========================================
  static const checklist = ChecklistStringsEn();

  // ========================================
  // Contact Selector Dialog
  // ========================================
  static const contactSelector = ContactSelectorStringsEn();
  static const shoppingSummary = ShoppingSummaryStringsEn();
  // Tutorial — uses Hebrew base (tutorial content stays in Hebrew for now)
  static const tutorial = TutorialStrings();
  // Legal — uses Hebrew base (legal content stays in Hebrew for now)
  static const legal = LegalStrings();
  static const actionCenter = ActionCenterStringsEn();
  static const onboardingTips = OnboardingTipsStringsEn();
}

// ========================================
// _CategoryStrings
// ========================================

class CategoryStringsEn extends CategoryStrings {
  const CategoryStringsEn();

  @override String get all => 'All';
  @override String get other => 'Other';
  @override String get dairy => 'Dairy';
  @override String get vegetables => 'Vegetables';
  @override String get fruits => 'Fruits';
  @override String get meatFish => 'Meat & Fish';
  @override String get ricePasta => 'Rice & Pasta';
  @override String get spices => 'Spices';
  @override String get coffeeTea => 'Coffee & Tea';
  @override String get sweetsSnacks => 'Sweets & Snacks';
  @override String get beef => 'Beef';
  @override String get chicken => 'Chicken';
  @override String get turkey => 'Turkey';
  @override String get lamb => 'Lamb';
  @override String get fish => 'Fish';
  @override String get meatSubstitutes => 'Meat Substitutes';
  @override String get breadBakery => 'Bread & Bakery';
  @override String get cookiesSweets => 'Cookies & Sweets';
  @override String get cakes => 'Cakes';
  @override String get canned => 'Canned Goods';
  @override String get legumesGrains => 'Legumes & Grains';
  @override String get cereals => 'Cereals';
  @override String get driedFruits => 'Dried Fruits';
  @override String get nutsSeeds => 'Nuts & Seeds';
  @override String get beverages => 'Beverages';
  @override String get oilsSauces => 'Oils & Sauces';
  @override String get sweetSpreads => 'Sweet Spreads';
  @override String get frozen => 'Frozen';
  @override String get readySalads => 'Ready Salads';
  @override String get dairySubstitutes => 'Dairy Substitutes';
  @override String get hygiene => 'Hygiene';
  @override String get cosmetics => 'Cosmetics & Care';
  @override String get cleaning => 'Cleaning Products';
  @override String get petFood => 'Pet Food';
  @override String get otcMedicine => 'OTC Medicine';
  @override String get vitamins => 'Vitamins & Supplements';
  @override String get firstAid => 'First Aid';
  @override String get babyProducts => 'Baby Products';
}

// ========================================
// Layout Strings
// ========================================

class LayoutStringsEn extends LayoutStrings {
  const LayoutStringsEn();

  @override String get appTitle => AppStringsEn.appName;
  @override String get notifications => 'Notifications';
  @override String get noNotifications => 'No new notifications';
  @override String notificationsCount(int count) => 'You have $count new updates';
  @override String get welcome => 'Welcome to ${AppStringsEn.appName}';
  @override String get offline => 'No internet connection';
  @override String get logoutError => 'Error logging out, try again';
  @override String get pendingInvitesTitle => 'Notifications & Invites';
  @override String get groupInvites => 'Group Invitations';
  @override String get groupInvitesSubtitle => 'Join a household';
  @override String get listInvites => 'List Invitations';
  @override String get listInvitesSubtitle => 'Share shopping lists';
  @override String get notificationsSubtitle => 'Recent updates & activity';
  @override String get lowStockTitle => 'Low Stock';
  @override String lowStockSubtitle(int count) => '$count items running low';
  @override String navSemanticLabel(String selectedTab) => 'Main navigation. Selected tab: $selectedTab';
  @override String get navSemanticHint => 'Swipe left or right to select another tab';
  @override String get longPressHint => 'Long press for more options';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class NavigationStringsEn extends NavigationStrings {
  const NavigationStringsEn();

  @override String get home => 'Home';
  @override String get family => 'Home';
  @override String get groups => 'Groups';
  @override String get lists => 'Lists';
  @override String get pantry => 'Pantry';
  @override String get receipts => 'Receipts';
  @override String get history => 'History';
  @override String get settings => 'Settings';
}

// ========================================
// Common Strings (Buttons, Actions)
// ========================================

class CommonStringsEn extends CommonStrings {
  const CommonStringsEn();

  @override String get logout => 'Log Out';
  @override String get cancel => 'Cancel';
  @override String get moreOptions => 'More options';
  @override String get save => 'Save';
  @override String durationText(int hours, int minutes) =>
      hours > 0 ? '$hours hours and $minutes minutes' : '$minutes minutes';
  @override String get defaultUserName => 'User';
  @override String get newUserName => 'New User';
  @override String get defaultProductName => 'Product';
  @override String get delete => 'Delete';
  @override String get edit => 'Edit';
  @override String get add => 'Add';
  @override String get search => 'Search';
  @override String get retry => 'Try Again';
  @override String get resetFilter => 'Reset Filter';
  @override String get clearAll => 'Clear All';
  @override String get deleted => 'Deleted';
  @override String get searchProductHint => 'Search product...';
  @override String get categories => 'Categories';
  @override String get meatTypes => 'Meat Types';
  @override String get all => 'All';
  @override String get yes => 'Yes';
  @override String get no => 'No';
  @override String get ok => 'OK';
  @override String get loading => 'Loading...';
  @override String get error => 'Error';
  @override String get success => 'Success';
  @override String get categoryUnknown => 'Unknown';
  @override String get syncError => 'Sync issue - changes saved locally';
  @override String get saveFailed => 'Save failed, try again';
  @override String get unsavedChangesTitle => 'Unsaved Changes';
  @override String get unsavedChangesMessage => 'You have unsaved changes. Exit without saving?';
  @override String get stayHere => 'Stay';
  @override String get exitWithoutSaving => 'Exit Without Saving';

  // 📅 Days of week
  @override String get daySunday => 'Sunday';
  @override String get dayMonday => 'Monday';
  @override String get dayTuesday => 'Tuesday';
  @override String get dayWednesday => 'Wednesday';
  @override String get dayThursday => 'Thursday';
  @override String get dayFriday => 'Friday';
  @override String get daySaturday => 'Saturday';
  @override String get dayUnknown => 'Unknown';

  @override String get understood => 'Understood';
  @override String get confirm => 'Confirm';
  @override String get goBack => 'Go Back';
  @override String get backToHome => 'Back to Home';
  @override String get close => 'Close';
  @override String unknownError(String error) => 'Error: $error';
  @override String get unknownErrorGeneric => 'Something went wrong. Please try again';
  @override String get permissionError => 'You don\'t have permission for this action';
  @override String get notFoundError => 'Item not found';
  @override String get networkError => 'Connection issue. Please try again';
  @override String get connected => 'Connected';
  @override String get optional => '(Optional)';
}

// ========================================
// Onboarding Strings
// ========================================


// ========================================
// Shopping Strings
// ========================================

class ShoppingStringsEn extends ShoppingStrings {
  const ShoppingStringsEn();

  @override String get itemStatusOutOfStock => 'Out of stock';
  @override String get activeSaving => 'Saving...';
  @override String get activeFinish => 'Finish';
  @override String get activePurchased => 'Purchased';
  @override String get activeNotNeeded => 'Not needed';
  @override String get activeRemaining => 'Remaining';
  @override String get activeTotal => 'Total';
  @override String get activeSavingData => 'Saving data...';
  @override String get loadingDataError => 'Error loading data';
  @override String get shoppingCompletedSuccess => 'All done — great shopping! 🎉';
  @override String get viewerCannotShop => 'Viewers cannot participate in shopping';
  @override String pantryUpdated(int count) => '📦 $count products updated in pantry';
  @override String itemsMovedToNext(int count) => '🔄 $count items moved to next list';
  @override String get saveError => 'Save error';
  @override String get saveErrorMessage => 'We couldn\'t save the data.\nTry again?';
  @override String get oopsError => 'Something went wrong — let\'s try again';
  @override String get listEmpty => 'List is empty';
  @override String get noItemsToBuy => 'No items to buy';
  @override String get sharedLabel => 'Shared';
  @override String get privateLabel => 'Personal';
  @override String get startShoppingButton => 'Start Shopping';
  @override String get addProductsToStart => 'Add products to get started';
  @override String listDeleted(String name) => 'List "$name" deleted';
  @override String get undoButton => 'Undo';
  @override String get restoreError => 'Error restoring list';
  @override String get deleteError => 'Error deleting list';
  @override String get urgencyPassed => 'Overdue!';
  @override String get urgencyToday => 'Today!';
  @override String get urgencyTomorrow => 'Tomorrow';
  @override String urgencyDaysLeft(int days) => '$days days left';
  @override String get typeSupermarket => 'Supermarket';
  @override String get typePharmacy => 'Pharmacy';
  @override String get typeGreengrocer => 'Greengrocer';
  @override String get typeButcher => 'Butcher';
  @override String get typeBakery => 'Bakery';
  @override String get typeMarket => 'Market';
  @override String get typeHousehold => 'Household';
  @override String get typeEvent => 'Event';
  @override String get typeOther => 'Other';
  // Short names (for chips/tabs)
  @override String get typeSupermarketShort => 'Super';
  @override String get typePharmacyShort => 'Pharmacy';
  @override String get typeGreengrocerShort => 'Greens';
  @override String get typeButcherShort => 'Butcher';
  @override String get typeBakeryShort => 'Bakery';
  @override String get typeMarketShort => 'Market';
  @override String get typeHouseholdShort => 'Home';
  @override String get typeEventShort => 'Event';
  @override String get typeOtherShort => 'Other';
  @override String get deleteListTitle => 'Delete List';
  @override String deleteListMessage(String name) => 'Delete list "$name"?';
  @override String get deleteButton => 'Delete';
  @override String itemsAndDate(int count, String date) => 'Items: $count • Updated: $date';
  @override String get editListButton => 'Edit List';
  @override String get deleteListButton => 'Delete';
  @override String get summaryTitle => 'Shopping Summary';
  @override String get summarySuccess => 'Nailed it! ⚡';
  @override String get storeQuestion => 'Where did you shop?';
  @override String get whoBringsWhat => 'Who brings what';
  @override String get whoBringsTitle => 'Who brings?';
  @override String get whoBringsHint => 'Tap "I\'ll bring" to volunteer for an item';
  @override String get whoBringsFullLabel => 'Full! ✓';
  @override String whoBringsItemFull(String name) => '$name is already full!';
  @override String get whoBringsEmptyTitle => 'No items in list';
  @override String get whoBringsEmptySubtitle => 'Add items so group members can volunteer';
  @override String get anonymousUser => 'Anonymous';
  @override String get checklist => 'Checklist';
  @override String get defaultInviteLabel => 'Invitation';
  @override String get leaveShoppingTitle => 'Leave shopping?';
  @override String get leaveShoppingMessage => 'Shopping is still active. You can come back later.';
  @override String get continueShoppingButton => 'Keep shopping';
  @override String get leaveButton => 'Leave';
  @override String get summaryOutOfStock => 'Out of stock';
  @override String get summaryNotMarked => 'Not marked';
  @override String get summaryBack => 'Back';
  @override String get summaryFinishShopping => 'Finish Shopping';
  @override String summaryPurchased(int purchased, int total) => '$purchased of $total';
  @override String summaryPendingQuestion(int count) => count == 1 ? 'There is 1 unmarked item.' : 'There are $count unmarked items.';
  @override String get summaryPendingSubtitle => 'What would you like to do with them?';
  @override String get summaryPendingTransfer => 'Move to next list';
  @override String get summaryPendingTransferSubtitle => 'Items will be moved to the next shopping';
  @override String get summaryPendingLeave => 'Keep in list';
  @override String get summaryPendingLeaveSubtitle => 'The list will remain active';
  @override String get summaryPendingDelete => 'Delete, not needed';
  @override String get summaryPendingDeleteSubtitle => 'Items will be removed completely';
  @override String priceFormat(double price) => '₪${price.toStringAsFixed(2)}';
  @override String get noPrice => 'No price';
  @override String get categoryGeneral => 'General';
  @override String addProductsTitle(String listName) => 'Add Products: $listName';
  @override String productRemovedFromList(String name) => '$name removed from list';
  @override String productUpdatedQuantity(String name, int quantity) => '$name (updated to $quantity)';
  @override String productAddedToList(String name) => '$name added to list! ✓';
  @override String get loadingProducts => 'Loading products...';
  @override String noProductsMatchingSearch(String query) => 'No products matching "$query"';
  @override String get noProductsAvailable => 'No products available';
  @override String get loadProductsButton => 'Load Products';
  @override String get productNoName => 'No name';
  @override String updateProductError(String error) => 'Error updating product: $error';
  @override String addProductError(String error) => 'Error adding product: $error';
  @override String get searchAndFilter => 'Search & Filter';
  @override String get filterActive => 'Filter active';
  @override String get searchMenuLabel => 'Search';
  @override String get filterByTypeLabel => 'Filter by type';
  @override String get sortLabel => 'Sort';
  @override String get clearFilterLabel => 'Clear filter';
  @override String get newListTooltip => 'New list';
  @override String get searchListTitle => 'Search List';
  @override String get searchListHint => 'Type a list name...';
  @override String get clearButton => 'Clear';
  @override String get searchButton => 'Search';
  @override String get filterByTypeTitle => 'Filter by Type';
  @override String get allTypesLabel => 'All';
  @override String get sortTitle => 'Sort';
  @override String get sortDateDesc => 'Newest first';
  @override String get sortDateAsc => 'Oldest first';
  @override String get sortNameAZ => 'A-Z';
  @override String get sortBudgetDesc => 'Budget high → low';
  @override String get sortBudgetAsc => 'Budget low → high';
  @override String get sortLabelNew => 'New';
  @override String get sortLabelOld => 'Old';
  @override String get sortLabelAZ => 'A-Z';
  @override String get activeLists => '🔵 Active Lists';
  @override String get historyLists => '✅ History';
  @override String get historyListsNote => '(by last update)';
  @override String get noListsFoundTitle => 'No lists found';
  @override String get noListsFoundSubtitle => 'Try changing the search or filter';
  @override String get noListsTitle => 'Ready to shop smarter?';
  @override String get noListsSubtitle => 'Create your first list and\nnever forget an item again!';
  @override String get createNewListButton => 'Create New List';
  @override String get orScanReceiptHint => 'Or scan a receipt in the receipts screen';
  @override String get loadingListsError => 'Error loading lists';
  @override String get somethingWentWrong => 'Hmm, that didn\'t work';
  @override String get tryAgainButton => 'Try Again';
  @override String loadMoreLists(int remaining) => 'Load more lists ($remaining remaining)';
  @override String get moreOptionsTooltip => 'More options';
  @override String listTileSemantics(String name, int total, int checked) => '$name, $total items, $checked checked';
  @override String get defaultShoppingListName => 'General Shopping';
  @override String maxItemsReached(int max) => 'You\'ve reached the maximum of $max items per list';
  @override String maxListsReached(int max) => 'You\'ve reached the maximum of $max active lists';
  @override String get syncSuccess => 'Sync successful!';
  @override String get syncErrorTooltip => 'Not synced - tap to retry';
  @override String get shoppingSaved => 'Shopping saved';
  @override String pendingItemsLeftWarning(int count) => '$count items remaining, list stays active';
  @override String get legendOutOfStock => 'Out of stock';
  @override String get legendNotNeeded => 'Not needed';
  @override String get legendPending => 'Pending';
  @override String get editQuantity => 'Edit quantity';
  @override String get scanBarcode => 'Scan barcode';
  @override String get scanHint => 'Point the barcode at the center of the frame';
  @override String get addNewProductTooltip => 'Add new product';
  @override String get increaseQuantityTooltip => 'Increase quantity';
  @override String get decreaseQuantityTooltip => 'Decrease quantity';
  @override String get productNoNameFallback => 'Unnamed product';
  // Product selection - Grid/List toggle & sections
  @override String get gridViewTooltip => 'Grid view';
  @override String get listViewTooltip => 'List view';
  @override String get recentlyAdded => 'Recently added';
  @override String get cameraError => 'Cannot access the camera.\nCheck permissions in device settings.';
  @override String get toggleFlash => 'Toggle flash';
  @override String get barcodeFoundAdd => 'Product not in list. Add it?';
  @override String get addToListButton => 'Add to list';
  @override String barcodeNotFound(String code) => 'Barcode $code not found';
  @override String get retryLoadSemantics => 'Double tap to try loading the list again';
  @override String get backToListSemantics => 'Double tap to return to the shopping list';
  @override String get finishAndSaveSemantics => 'Double tap to finish shopping and save data';
  @override String outOfStockToggleSemantics(String itemName, bool isOutOfStock) =>
      isOutOfStock ? 'Double tap to unmark out of stock for $itemName' : 'Double tap to mark $itemName as out of stock';

  @override String alreadyVolunteered(String name) => 'You already volunteered to bring $name';
  @override String volunteerSuccess(String name) => 'Signed up to bring: $name ✓';
  @override String get volunteerError => 'Error signing up';
  @override String cancelVolunteer(String name) => 'Cancelled volunteering for $name';
  @override String get cancelVolunteerError => 'Error cancelling';
  @override String get statsTotal => 'Total';
  @override String get statsCompleted => 'Done';
  @override String get statsIBring => 'I Bring';
  @override String get cancelVolunteerButton => 'Cancel';
  @override String get iBringButton => "I'll bring it! ✋";
  @override String get budgetTitle => 'Budget';
  @override String get successRateTitle => 'Success Rate';
  @override String get purchasedLabel => 'Purchased';
  @override String get missingLabel => 'Missing';
  @override String get finishedButton => 'Done';
  @override String get activeFinishHint => 'Mark at least one item to finish';
  @override String get otherStoreHint => 'Other store...';
}

// ========================================
// Index (Splash) Strings
// ========================================

class IndexStringsEn extends IndexStrings {
  const IndexStringsEn();

  @override String get appName => AppStringsEn.appName;
  @override String get logoLabel => '${AppStringsEn.appName} app logo';
  @override String get loadingLabel => 'Loading the app';
  @override String get loading => 'Loading...';
  @override List<String> get loadingMessages => const ['Getting things ready...', 'Syncing your data...', 'Almost there...'];
  @override String get errorTitle => 'Something\'s not right';
  @override String get errorMessage => 'We hit a bump — let\'s try again';
  @override String get retryButton => 'Try Again';
}

// ========================================
// Welcome Strings
// ========================================

class WelcomeStringsEn extends WelcomeStrings {
  const WelcomeStringsEn();

  @override String get title => AppStringsEn.appName;
  @override String get subtitle => 'Smart shopping for the whole family';
  @override String get group1Emoji => '🛒';
  @override String get group1Title => 'Shop together';
  @override String get group1Question => 'One list, everyone edits in real time';
  @override String get group1Feature1 => 'Smart items ✅';
  @override String get group1Feature2 => 'Auto quantities 🔢';
  @override String get group2Emoji => '📦';
  @override String get group2Title => 'A pantry that never runs out';
  @override String get group2Question => 'Your digital pantry — alerts you before you run low';
  @override String get group2Feature1 => 'Live stock 📊';
  @override String get group2Feature2 => 'Smart alerts ⏰';
  @override String get group3Emoji => '👨‍👩‍👧‍👦';
  @override String get group3Title => 'Family in sync';
  @override String get group3Question => 'Everyone sees, everyone updates — no more duplicate buys';
  @override String get group3Feature1 => 'Live updates 🔄';
  @override String get group3Feature2 => 'Cloud sync ☁️';
  @override String get moreGroupsHint => 'Beautifully simple — zero learning curve';
  @override String get demoItem1 => 'Milk';
  @override String get demoItem2 => 'Bread';
  @override String get demoItem3 => 'Eggs';
  @override String get demoPantryHeader => '📦 Pantry';
  @override String get demoPantryItem1 => 'Milk';
  @override String get demoPantryItem2 => 'Eggs';
  @override String get demoPantryItem3 => 'Bread';
  @override String get demoFamilyHeader => '👨‍👩‍👧‍👦 Household';
  @override String get demoUser1 => 'Dad';
  @override String get demoUser2 => 'Mom';
  @override String get demoUser3 => 'Danny';
  @override String get statusOnline => 'Online';
  @override String get statusOffline => 'Offline';
  @override String get benefit1Title => 'Real-time sharing';
  @override String get benefit1Subtitle => 'Changes appear instantly for everyone';
  @override String get benefit2Title => 'Lists + tasks in one place';
  @override String get benefit2Subtitle => 'Groceries, errands, events — all organized';
  @override String get benefit3Title => 'Smart pantry';
  @override String get benefit3Subtitle => 'Knows what you need before you do';
  @override String get startButton => 'Sign Up';
  @override String get loginButton => 'Log In';
  @override String get loginLink => 'Already have an account — Log In';
  @override String get authExplanation => 'Sign in to sync your lists across all devices';
  @override String get registerButton => 'Sign Up';
  @override String get termsOfService => 'Terms of Service';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get logoLabel => '${AppStringsEn.appName} app logo';
  @override String get carouselLabel => 'Swipe between feature screens';
}

// ========================================
// Auth Strings (Login/Register)
// ========================================

class AuthStringsEn extends AuthStrings {
  const AuthStringsEn();

  @override String get loginTitle => 'Log In';
  @override String get loginSubtitle => 'Welcome back 👋';
  @override String get loginButton => 'Log In';
  @override String get loggingIn => 'Logging in...';
  @override String get registerTitle => 'Sign Up';
  @override String get registerSubtitle => 'Join the smarter way to shop ✨';
  @override String get registerButton => 'Sign Up';
  @override String get registering => 'Signing up...';
  @override String get forgotPassword => 'Forgot password?';
  @override String get sendResetEmailButton => 'Send Link';
  @override String get resetEmailSent => 'Password reset email sent successfully!';
  @override String get emailNotVerified => 'Email not verified';
  @override String get verifyEmailMessage => 'Please verify your email address';
  @override String get sendVerificationEmailButton => 'Send Verification Email';
  @override String get verificationEmailSent => 'Verification email sent!';
  @override String get checkYourEmail => 'Check your inbox';
  @override String get updateProfile => 'Update Profile';
  @override String get updateDisplayName => 'Update Display Name';
  @override String get displayNameUpdated => 'Display name updated successfully!';
  @override String get updateEmail => 'Update Email';
  @override String get emailUpdated => 'Email updated successfully!';
  @override String get updatePassword => 'Update Password';
  @override String get passwordUpdated => 'Password updated successfully!';
  @override String get deleteAccount => 'Delete Account';
  @override String get deleteAccountWarning => 'This action is irreversible!';
  @override String get deleteAccountConfirm => 'Are you sure you want to delete your account?';
  @override String get accountDeleted => 'Account deleted successfully';
  @override String get emailLabel => 'Email';
  @override String get emailHint => 'example@email.com';
  @override String get passwordLabel => 'Password';
  @override String get passwordHint => '••••••••';
  @override String get confirmPasswordLabel => 'Confirm Password';
  @override String get confirmPasswordHint => '••••••••';
  @override String get nameLabel => 'Full Name';
  @override String get nameHint => 'John Doe';
  @override String get phoneLabel => 'Phone';
  @override String get phoneHint => '050-1234567';
  @override String get noAccount => 'Don\'t have an account?';
  @override String get registerNow => 'Sign up now';
  @override String get haveAccount => 'Already have an account?';
  @override String get or => 'or';
  @override String get orContinueWith => 'Or sign up quickly with';
  @override String get emailRequired => 'Required field';
  @override String get emailInvalid => 'Invalid email';
  @override String get passwordRequired => 'Required field';
  @override String get passwordTooShort => 'Password must be at least 6 characters';
  @override String get confirmPasswordRequired => 'Required field';
  @override String get passwordsDoNotMatch => 'Passwords don\'t match';
  @override String get nameRequired => 'Required field';
  @override String get nameTooShort => 'Name must be at least 2 characters';
  @override String get phoneRequired => 'Required field';
  @override String get phoneInvalid => 'Invalid phone number (05X-XXXXXXX)';
  @override String get errorWeakPassword => 'Password is too weak';
  @override String get errorEmailInUse => 'Email is already in use';
  @override String get errorInvalidEmail => 'Invalid email format';
  @override String get errorOperationNotAllowed => 'Operation not allowed';
  @override String get errorUserNotFound => 'User not found';
  @override String get errorWrongPassword => 'Wrong password';
  @override String get errorUserDisabled => 'User is disabled';
  @override String get errorInvalidCredential => 'Invalid credentials';
  @override String get errorTooManyRequests => 'Too many attempts. Try again later';
  @override String get errorRequiresRecentLogin => 'Re-login required to perform this action';
  @override String get errorNetworkRequestFailed => 'Network error. Check your internet connection';
  @override String get errorTimeout => 'Operation failed - try again';
  @override String get errorNoUserLoggedIn => 'No user logged in';
  @override String get socialLoginCancelled => 'Login cancelled';
  @override String get socialLoginError => 'Login error';
  @override String signUpError(String? message) => 'Registration error${message != null ? ": $message" : ""}';
  @override String signInError(String? message) => 'Login error${message != null ? ": $message" : ""}';
  @override String resetEmailError(String? message) => 'Error sending email${message != null ? ": $message" : ""}';
  @override String verificationEmailError(String? message) => 'Error sending verification email${message != null ? ": $message" : ""}';
  @override String updateDisplayNameError(String? message) => 'Error updating name${message != null ? ": $message" : ""}';
  @override String updateEmailError(String? message) => 'Error updating email${message != null ? ": $message" : ""}';
  @override String updatePasswordError(String? message) => 'Error updating password${message != null ? ": $message" : ""}';
  @override String deleteAccountError(String? message) => 'Error deleting account${message != null ? ": $message" : ""}';
  @override String reloadUserError(String? message) => 'Error reloading${message != null ? ": $message" : ""}';
  @override String get mustCompleteLogin => 'Please complete the login process';
  @override String get loginSuccess => 'Logged in successfully!';
  @override String get registerSuccess => 'Registered successfully!';
  @override String get loginSuccessRedirect => 'Logged in successfully! Redirecting...';
  @override String get orLoginWith => 'Or log in with';
  @override String get orWithEmail => 'or with email';
  @override String get showPassword => 'Show password';
  @override String get hidePassword => 'Hide password';
  @override String get enterEmailFirst => 'Please enter your email address in the field above';
  @override String resetEmailSentTo(String email) => 'Password reset email sent to $email';
  @override String get resetEmailSendError => 'Error sending reset email';
  @override String get forgotPasswordSemanticLabel => 'Forgot password? Tap to receive a reset email';
  @override String get forgotPasswordSemanticHint => 'Sends a password reset link to the entered email';
  @override String socialLoginSemanticLabel(String provider) => 'Log in with $provider';
  @override String get registerSuccessRedirect => 'Registered successfully! Redirecting...';
  @override String get pendingInvitesDialogTitle => 'Pending Invitations!';
  @override String pendingInvitesDialogContent(int count) =>
      'You have $count pending group invitations.\n\nWould you like to go to the invitations screen?';
  @override String get pendingInvitesLater => 'Later';
  @override String get pendingInvitesView => 'View Invitations';
  @override String get phoneHelperText => 'Israeli mobile number - for group updates';
  @override String get nameFieldSemanticLabel => 'Full name field, required';
  @override String get emailFieldSemanticLabel => 'Email address field, required';
  @override String get passwordFieldSemanticLabel => 'Password field, at least 6 characters';
  @override String get confirmPasswordFieldSemanticLabel => 'Confirm password field, must match password';
  @override String get phoneFieldSemanticLabel => 'Israeli mobile phone field, required';
  @override String get loginLinkSemanticLabel => 'Have an account? Tap to go to login screen';
  @override String socialRegisterSemanticLabel(String provider) => 'Sign up or log in with $provider';

  // Loading overlay messages
  @override String get loadingCheckingDetails => 'Checking details...';
  @override String get loadingConnecting => 'Connecting to server...';
  @override String get loadingAlmostThere => 'Almost there...';
}

// ========================================
// Home Dashboard Strings
// ========================================

class HomeStringsEn extends HomeStrings {
  const HomeStringsEn();

  @override String timeBasedGreeting(String userName, int hour) {
    final String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Good night';
    }
    return '$greeting, $userName! 👋';
  }

  @override String get sortLabel => 'Sort:';
  @override String get sortByDate => 'Date updated';
  @override String get noActiveLists => 'Nothing on the list — enjoy the break!';
  @override String get otherActiveLists => 'Other active lists';
  @override String get noOtherActiveLists => 'No other lists right now';
  @override String get allLists => 'All lists';
  @override String itemsCount(int count) => '$count items';
  @override String listDeleted(String listName) => 'List "$listName" deleted';
  @override String get undo => 'Undo';
  @override String createListError(String error) => 'Error creating list: $error';
  @override String get doubleTapToExit => 'Tap again to close the app';
}

// ========================================
// Price Comparison Strings
// ========================================

class PriceComparisonStringsEn extends PriceComparisonStrings {
  const PriceComparisonStringsEn();

  @override String get title => 'Price Comparison';
  @override String get searchHint => 'Search product...';
  @override String get searchButton => 'Search';
  @override String get clearButton => 'Clear';
  @override String get storeIcon => '🏪';
  @override String get errorTitle => 'Search error';
  @override String get retry => 'Try Again';
}

// ========================================
// Settings Strings
// ========================================

class SettingsStringsEn extends SettingsStrings {
  const SettingsStringsEn();

  @override String get title => 'Settings & Profile';
  @override String get editProfile => 'Edit';
  @override String get statsActiveLists => 'Active Lists';
  @override String get statsPantryItems => 'Pantry Items';
  @override String get householdName => 'Group Name';
  @override String get householdNameHint => 'Group Name';
  @override String get householdNameEmpty => 'Group name cannot be empty';
  @override String get editHouseholdNameSave => 'Save';
  @override String get editHouseholdNameEdit => 'Edit Name';
  @override String get roleOwner => 'Owner';
  @override String get roleAdmin => 'Admin';
  @override String get roleEditor => 'Editor';
  @override String get roleViewer => 'Viewer';
  @override String get storesTitle => 'Favorite Stores';
  @override String get addStoreHint => 'Add store...';
  @override String get addStoreTooltip => 'Add Store';
  @override String get familySizeLabel => 'Group size (number of people)';
  @override String get weeklyRemindersLabel => 'Weekly Reminders';
  @override String get weeklyRemindersSubtitle => 'Get a reminder to plan shopping';
  @override String get notificationsSectionTitle => 'Notifications';
  @override String get notifyShoppingTitle => 'Shopping Activity';
  @override String get notifyShoppingSubtitle => 'When someone starts or finishes shopping';
  @override String get notifyGroupTitle => 'Group Changes';
  @override String get notifyGroupSubtitle => 'New member, invitation or departure';
  @override String get notifyRemindersTitle => 'Reminders';
  @override String get notifyRemindersSubtitle => 'Open list over 24 hours, weekly reminder';
  @override String get notifyListUpdatesTitle => 'List Updates';
  @override String get notifyListUpdatesSubtitle => 'When someone adds or removes items from a shared list';
  @override String get generalSettingsSectionTitle => 'General Settings';
  @override String get themeLabel => 'Theme';
  @override String get themeLight => 'Light';
  @override String get themeDark => 'Dark';
  @override String get themeSystem => 'System';
  @override String get householdManagementTitle => 'Household Management';
  @override String get householdMembersTitle => 'Household Members';
  @override String get householdMembersSubtitle => 'Add and remove members';
  @override String get householdInviteTitle => 'Invite Friends';
  @override String get householdInviteSubtitle => 'Send an invitation to join';
  @override String get householdComingSoon => 'Full management - coming soon!';
  @override String get inviteToHouseholdTitle => 'Invite to Household';
  @override String get inviteToHouseholdSubtitle => 'Send an invitation to join your household';
  @override String get inviteToHouseholdHint => 'Enter invitee\'s email';
  @override String get inviteToHouseholdSuccess => '✅ Invitation sent!';
  @override String get inviteToHouseholdAlreadyMember => 'User is already a member';
  @override String get inviteToHouseholdAlreadyPending => 'There\'s already a pending invitation';
  @override String get inviteToHouseholdButton => 'Send Invitation';
  @override String get inviteToHouseholdNeedName => 'First set a name for your household in Settings';
  @override String get householdJoinedSuccess => '🏠 Successfully joined the household!';
  @override String get myPantry => 'My Pantry';
  @override String get priceComparison => 'Price Comparison';
  @override String get updatePricesTitle => 'Update Prices from API';
  @override String get updatePricesSubtitle => 'Load updated prices from the network';
  @override String get updatingPrices => '💰 Updating prices from API...';
  @override String pricesUpdated(int withPrice, int total) => '✅ Updated $withPrice prices out of $total products!';
  @override String pricesUpdateError(String error) => '❌ Error updating prices: $error';
  @override String get logoutTitle => 'Log Out';
  @override String get logoutMessage => 'Are you sure you want to log out?';
  @override String get logoutCancel => 'Cancel';
  @override String get logoutConfirm => 'Log Out';
  @override String get logoutSubtitle => 'Sign out of account';
  @override String get deleteAccountTitle => 'Delete Account';
  @override String get deleteAccountSubtitle => 'Permanently delete all data';
  @override String get deleteAccountWarning =>
      'This action will permanently delete:\n• All lists you created\n• Shopping history\n• Your pantry\n• All personal data\n\nData cannot be recovered!';
  @override String get deleteAccountConfirmLabel => 'Type "delete my account" to confirm:';
  @override String get deleteAccountConfirmText => 'delete my account';
  @override String get deleteAccountButton => 'Delete Account Permanently';
  @override String get deleteAccountSuccess => 'Account deleted successfully';
  @override String deleteAccountError(String error) => 'Error deleting account: $error';
  @override String get deleteAccountRequiresReauth => 'Re-login required before deleting account';
  @override String get loading => 'Loading...';
  @override String loadError(String error) => 'Error loading settings: $error';
  @override String saveError(String error) => 'Error saving settings: $error';

  @override String get editProfileTitle => 'Edit Profile';
  @override String get chooseAvatar => 'Choose Avatar:';
  @override String get displayNameLabel => 'Display Name:';
  @override String get displayNameHint => 'Enter your name';
  @override String get enterNameError => 'Please enter a name';
  @override String get profileUpdated => 'Profile updated successfully';
  @override String profileUpdateError(String error) => 'Error updating: $error';
  @override String imageUploadCooldown(String timeRemaining) => 'You can change your photo again in $timeRemaining';

  @override String get loggingOut => 'Logging out...';
  @override String logoutError(String error) => 'Logout error: $error';
  @override String get debugDeleteTitle => 'This will delete everything including seenOnboarding.\nYou\'ll return to the Welcome screen.';
  @override String get debugOnlyLabel => 'Available in Debug Mode only';
  @override String get debugDeleteAll => 'Delete All';
  @override String get deletingData => 'Deleting data...';
  @override String deleteDataError(String error) => 'Error deleting: $error';

  @override String get invalidEmail => 'Invalid email';
  @override String get defaultUserName => 'User';
  @override String get defaultHouseholdName => 'My Home';
  @override String inviteError(String error) => 'Error sending invitation';

  @override String get pendingInvitesTitle => 'Pending Invitations';
  @override String get pendingInvitesSubtitle => 'Invitations you received for lists';
  @override String get showOnboardingAgain => 'Show Tutorial Again';
  @override String get languageHebrew => 'עברית';
  @override String get languageEnglish => 'English';
  @override String get showOnboardingSubtitle => 'View the app tutorial again';
  @override String get about => 'About';
  @override String get aboutDescription => 'Smart grocery & pantry management for families';
  @override String versionLabel(String version) => 'Version $version';
  @override String get quickLinksTitle => 'Quick Links';
  @override String get infoTitle => 'Info';
  @override String get termsOfService => 'Terms of Service';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get debugResetOnboarding => 'Deletes seenOnboarding - returns to Welcome';
}

// ========================================
// Household Strings
// ========================================

class HouseholdStringsEn extends HouseholdStrings {
  const HouseholdStringsEn();

  @override String get typeFamily => 'Home';
  @override String get typeOther => 'Other';
  @override String get typeExtendedFamily => 'Extended Family';
  @override String get descFamily => 'Manage shared shopping and needs for the household';
  @override String get descExtendedFamily => 'Plan shopping and events for the extended family';

  @override String get removeMemberTitle => 'Remove Member';
  @override String removeMemberConfirm(String name) => 'Remove $name from the household?';
  @override String get removeMemberButton => 'Remove';
  @override String removeMemberError(String error) => 'Error removing: $error';
  @override String genericError(String error) => 'Error: $error';
  @override String get leaveHouseholdTitle => 'Leave Household';
  @override String get leaveHouseholdButton => 'Leave';
  @override String get leftHousehold => 'You left the household';
  @override String get makeAdmin => 'Make Admin';
  @override String get makeMember => 'Make Member';
  @override String get removeFromHousehold => 'Remove from Household';
  @override String roleChangeError(String error) => 'Error changing role: $error';
  @override String get ownerCannotLeave => 'Owner cannot leave the household. You can delete or transfer ownership';
  @override String get householdNotFound => 'Household not found';
  @override String get loadMembersError => 'Error loading household members';
  @override String get leaveHouseholdConfirm => 'Are you sure you want to leave? You\'ll be moved to a new personal home.';
  @override String memberRemoved(String name) => '$name was removed from the household';
  @override String memberRoleChanged(String name, String role) => '$name is now $role';
  @override String get membersCount => 'members';
  @override String get roleOwner => 'Owner';
  @override String get roleAdmin => 'Admin';
  @override String get roleMember => 'Member';
  @override String get myHome => 'My Home';
  @override String get leaveHouseholdTooltip => 'Leave household';
  @override String get userFallback => 'User';
  @override String get meLabel => 'Me';
  @override String get roleOwnerLabel => '👑 Owner';
  @override String get roleAdminLabel => '⭐ Admin';
  @override String get roleMemberLabel => '👤 Member';
}

// ========================================
// List Type Groups Strings
// ========================================

class ListTypeGroupsStringsEn extends ListTypeGroupsStrings {
  const ListTypeGroupsStringsEn();
}

// ========================================
// Templates Strings
// ========================================

class TemplatesStringsEn extends TemplatesStrings {
  const TemplatesStringsEn();

  @override String get title => 'List Templates';
  @override String get subtitle => 'Save time with ready-made lists';
  @override String get filterAll => 'All';
  @override String get filterShared => 'Shared';
  @override String get emptyMyTemplatesTitle => 'No templates yet';
  @override String get emptyMyTemplatesMessage => 'Create one and skip the setup next time';
  @override String get emptySharedTemplatesTitle => 'No shared templates';
  @override String get emptySharedTemplatesMessage => 'Group members can create shared templates';
  @override String itemsCount(int count) => '$count items';
  @override String get formatShared => 'Shared';
  @override String get createButton => 'New Template';
  @override String get deleteButton => 'Delete';
  @override String get useTemplateButton => 'Use Template';
  @override String get nameLabel => 'Template Name';
  @override String get nameHint => 'e.g., Weekly Shopping';
  @override String get nameRequired => 'Please enter a template name';
  @override String get formatSharedDesc => 'Visible to the whole group';
  @override String get saveButton => 'Save Template';
  @override String get cancelButton => 'Cancel';
  @override String templateNameExists(String name) => 'A template named "$name" already exists';
  @override String templateCreated(String name) => 'Template "$name" created successfully!';
  @override String templateUpdated(String name) => 'Template "$name" updated!';
  @override String templateDeleted(String name) => 'Template "$name" deleted';
  @override String get undo => 'Undo';
  @override String updateError(String error) => 'Error updating: $error';
  @override String deleteError(String error) => 'Error deleting: $error';
  @override String get useTemplateTitle => 'Choose Template';
  @override String get useTemplateHint => 'Choose a template to auto-fill the list';
  @override String get useTemplateEmpty => 'No templates available';
  @override String get useTemplateSelect => 'Select';
}

// ========================================
// Create List Dialog Strings
// ========================================

class CreateListDialogStringsEn extends CreateListDialogStrings {
  const CreateListDialogStringsEn();

  @override String get title => 'Create New List';
  @override String get useTemplateButton => '📋 Use Template';
  @override String get useTemplateTooltip => 'Choose a ready template';
  @override String get selectTemplateTitle => 'Choose Template';
  @override String get selectTemplateHint => 'Choose a template to auto-fill the list';
  @override String get noTemplatesAvailable => 'No templates available';
  @override String get noTemplatesMessage => 'Create your first template in the templates screen';
  @override String templateSelected(String name) => 'Template "$name" selected';
  @override String templateApplied(String name, int itemsCount) => '✨ Template "$name" applied! Added $itemsCount items';
  @override String get nameLabel => 'List Name';
  @override String get nameHint => 'e.g., Weekly Shopping';
  @override String get nameRequired => 'Please enter a list name';
  @override String nameAlreadyExists(String name) => 'A list named "$name" already exists';
  @override String get typeLabel => 'List Type';
  @override String get budgetLabel => 'Budget (optional)';
  @override String get budgetHint => '₪500';
  @override String get budgetInvalid => 'Please enter a valid number';
  @override String get budgetMustBePositive => 'Budget must be greater than 0';
  @override String get clearBudgetTooltip => 'Clear budget';
  @override String get eventDateLabel => 'Event Date (optional)';
  @override String get eventDateHint => 'e.g., Birthday, Gathering';
  @override String get noDate => 'No date';
  @override String get selectDate => 'Select event date';
  @override String get clearDateTooltip => 'Clear date';
  @override String get cancelButton => 'Cancel';
  @override String get cancelTooltip => 'Cancel list creation';
  @override String get createButton => 'Create List';
  @override String get creating => 'Creating...';
  @override String get loadingTemplates => 'Loading templates...';
  @override String get loadingTemplatesError => 'Error loading templates';
  @override String listCreated(String name) => 'List "$name" created successfully! 🎉';
  @override String listCreatedWithBudget(String name, double budget) =>
      'List "$name" created with budget ₪${budget.toStringAsFixed(0)}';
  @override String get validationFailed => 'Please fix the errors in the form';
  @override String get userNotLoggedIn => 'User not logged in';
  @override String createListError(String error) => 'Error creating list';
  @override String get createListErrorGeneric => 'An error occurred creating the list. Try again.';
  @override String get networkError => 'Network error. Check your internet connection';
  @override String get removeTemplateTooltip => 'Remove template';
  @override String get previewSelectAll => 'Select all';
  @override String get previewDeselectAll => 'Deselect all';
  @override String previewItemsSelected(int selected, int total) => '$selected/$total';
  @override String previewConfirmButton(int count) => 'Add $count items';
  @override String get visibilityLabel => 'Who will see the list?';
  @override String get visibilityPrivate => '🔒 Private';
  @override String get visibilityHousehold => '👨‍👩‍👧 Shared with household';
  @override String get visibilityShared => '👥 Share';
  @override String get visibilityPrivateDesc => 'Only you will see this list';
  @override String get visibilityHouseholdDesc => 'All household members can view and edit';
  @override String get visibilitySharedDesc => 'Share with specific people (no access to your pantry)';
  @override String get eventModeLabel => 'How will you manage the list?';
  @override String get eventModeWhoBrings => 'Who Brings What';
  @override String get eventModeWhoBringsDesc => 'Each participant volunteers to bring items';
  @override String get eventModeShopping => 'Regular Shopping';
  @override String get eventModeShoppingDesc => 'One person buys everything on the list';
  @override String get eventModeTasks => 'Personal Tasks';
  @override String get eventModeTasksDesc => 'Simple checklist just for me';
  @override String get recommended => 'Recommended';
  @override String get selectContactsButton => 'Select people to share with';
  @override String get addMoreContactsButton => 'Add more people';
  @override String get pendingInviteNote => 'Unregistered users will receive a pending invitation';
}

// ========================================
// Manage Users Strings
// ========================================

class ManageUsersStringsEn extends ManageUsersStrings {
  const ManageUsersStringsEn();

  @override String get title => 'Manage Users';
  @override String get me => 'Me';
  @override String get you => 'You';
  @override String userShortId(String shortId) => 'User #$shortId';
  @override String get defaultUserName => 'User';
  @override String get errorUserNotLoggedIn => 'Error: User not logged in';
  @override String get errorNoPermissionRemove => 'You don\'t have permission to remove users';
  @override String get errorNoPermissionEditRole => 'You don\'t have permission to change roles';
  @override String get errorNoHousehold => 'Error: User not assigned to a household';
  @override String errorRemovingUser(String error) => 'Error removing user: $error';
  @override String errorUpdatingRole(String error) => 'Error updating role: $error';
  @override String get removeUserTitle => 'Remove User';
  @override String removeUserConfirmation(String name) => 'Are you sure you want to remove $name?';
  @override String get removeButton => 'Remove';
  @override String get userRemovedSuccess => 'User removed successfully';
  @override String get editRoleTitle => 'Edit Role';
  @override String selectNewRole(String name) => 'Select a new role for $name:';
  @override String roleUpdatedSuccess(String roleName) => 'Role updated to $roleName';
  @override String get cancel => 'Cancel';
  @override String get inviteUser => 'Invite User';
  @override String get editRole => 'Edit Role';
  @override String get removeUser => 'Remove User';
  @override String get loadingUsers => 'Loading users...';
  @override String get retryButton => 'Try Again 🔄';
  @override String get noSharedUsers => 'No shared users';
  @override String get inviteUsersHint => 'Tap + to invite users';
  @override String get onlyOwnerCanInvite => 'Only the list owner can invite users';
}

// ========================================
// Inventory Strings
// ========================================

class InventoryStringsEn extends InventoryStrings {
  const InventoryStringsEn();

  @override String get addDialogTitle => 'Add Item';
  @override String get editDialogTitle => 'Edit Item';
  @override String get addButton => 'Add';
  @override String get saveButton => 'Save';
  @override String get productNameLabel => 'Item Name';
  @override String get productNameHint => 'e.g., Milk';
  @override String get productNameRequired => 'Please enter an item name';
  @override String get categoryLabel => 'Category';
  @override String get quantityLabel => 'Quantity';
  @override String get unitLabel => 'Unit';
  @override String get unitHint => 'pcs, kg, liters';
  @override String get locationLabel => 'Location';
  @override String get addLocationButton => 'Add';
  @override String get addLocationTitle => 'Add New Location';
  @override String get locationNameLabel => 'Location Name';
  @override String get locationNameHint => 'e.g., "Small Fridge"';
  @override String get selectEmojiLabel => 'Choose an emoji:';
  @override String get locationAdded => 'Location added! 📍';
  @override String get locationExists => 'This location already exists';
  @override String get locationNameRequired => 'Please enter a location name';
  @override String get filterLabel => 'Filter Pantry';
  @override String get filterByCategory => 'Filter by Category';
  @override String get itemAdded => 'Item added successfully';
  @override String get itemUpdated => 'Item updated successfully';
  @override String get addError => 'Error adding item';
  @override String get updateError => 'Error updating item';
  @override String get addFromCatalogTitle => 'Add from Catalog';
  @override String get searchProductsHint => 'Search product...';
  @override String get loadingProducts => 'Loading products...';
  @override String get noProductsFound => 'No products found';
  @override String get noProductsAvailable => 'No products available';
  @override String productAddedSuccess(String name) => '$name added to pantry!';
  @override String get stockOutOfStock => 'Out of stock! Need to buy';
  @override String stockOnlyOneLeft(String unit) => 'Only 1 $unit left';
  @override String stockOnlyFewLeft(int count, String unit) => 'Only $count $unit left';
  @override String get unknownSuggestionWarning => 'Unknown suggestion type - app update required';
  @override String get unknownSuggestionCannotDelete => 'Cannot delete unknown suggestion';
  @override String get unknownSuggestionUpdateApp => 'Update App';
  @override String get defaultUnit => 'pcs';
  @override String get statisticsLabel => 'Statistics';
  @override String get popularLabel => 'Popular';
  @override String purchaseCountLabel(int count) =>
      count == 1 ? 'Bought once' : 'Bought $count times';
  @override String get lastPurchaseLabel => 'Last bought';
  @override String relativePurchaseLabel(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Bought today';
    if (diff == 1) return 'Bought yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    if (diff < 365) return '${(diff / 30).floor()} months ago';
    return 'over a year ago';
  }
  @override String get expiryNotSetCta => 'Add expiry date';
  @override String get selectExpiryDate => 'Select expiry date';
  @override String get cancelLabel => 'Cancel';
  @override String get confirmLabel => 'Confirm';
  @override String get quantityLabelShort => 'Quantity';
  @override String get minimumLabel => 'Minimum';
  @override String get advancedSettings => 'Advanced settings';
  @override String get expiryDateLabel => 'Expiry date';
  @override String get clearDateTooltip => 'Clear date';
  @override String get notSetLabel => 'Not set';
  @override String get notesLabel => 'Notes';
  @override String get autoAddToLists => 'Auto-add to new lists';
  @override String get defaultCategory => 'General';

  @override String get expiryAlertTitleExpired => 'Expired!';
  @override String get expiryAlertTitleExpiringSoon => 'Expiring Soon';
  @override String expiryAlertSubtitle(int expiredCount, int expiringSoonCount) {
    final parts = <String>[];
    if (expiredCount > 0) parts.add('$expiredCount expired');
    if (expiringSoonCount > 0) parts.add('$expiringSoonCount expiring soon');
    return parts.join(' | ');
  }

  @override String get expiryAlertGoToPantry => 'Go to Pantry';
  @override String get expiryAlertDismissToday => 'Don\'t show again today';
  @override String expiryAlertMoreItems(int count) => 'Show $count more items...';
  @override String expiryAlertSemanticLabel(int expiredCount, int expiringSoonCount, bool isExpiredMode) => isExpiredMode
      ? 'Expiry alert: $expiredCount expired items, $expiringSoonCount about to expire'
      : 'Expiry alert: $expiringSoonCount items about to expire soon';
  @override String get expiryAlertCloseTooltip => 'Close';
  @override String get expiryAlertGoToPantryTooltip => 'Go to pantry to view all items';
  @override String get expiryAlertDismissTodayTooltip => 'This alert won\'t show again today';
  @override String get expiryExpiredToday => 'Expired today';
  @override String get expiryExpiredYesterday => 'Expired yesterday';
  @override String expiryExpiredDaysAgo(int days) => 'Expired $days days ago';
  @override String get expiryExpiresToday => 'Expires today!';
  @override String get expiryExpiresTomorrow => 'Expires tomorrow';
  @override String expiryExpiresInDays(int days) => 'Expires in $days days';
  @override String get settingsTitle => 'Pantry Settings';
  @override String get settingsSemanticLabel => 'Pantry settings dialog';
  @override String get pantryModePersonal => 'Personal pantry - yours only';
  @override String get pantryModeGroup => 'Connected to shared group pantry';
  @override String get alertsSectionTitle => 'Alerts';
  @override String get settingsLowStockAlertTitle => 'Low Stock Alert';
  @override String get settingsLowStockAlertSubtitle => 'Get alerted when an item reaches minimum';
  @override String get settingsExpiryAlertTitle => 'Expiry Alert';
  @override String get settingsExpiryAlertSubtitle => 'Get alerted about items about to expire';
  @override String get settingsExpiryAlertDaysPrefix => 'Alert ';
  @override String get settingsExpiryAlertDaysSuffix => ' days before expiry';
  @override String get displaySectionTitle => 'Display';
  @override String get showExpiredFirstTitle => 'Show expired first';
  @override String get showExpiredFirstSubtitle => 'Expired items will appear at the top of the list';
  @override String get lowStockAlertTitle => 'Low Stock';
  @override String lowStockAlertSubtitle(int count) => '$count products are running low';
  @override String get lowStockAlertAddToList => 'Add to List';
  @override String get lowStockAlertGoToPantry => 'Go to Pantry';
  @override String get lowStockAlertDismissToday => 'Don\'t show again today';
  @override String lowStockAlertMoreItems(int count) => 'and $count more items...';
  @override String lowStockAlertSemanticLabel(int count) => 'Low stock alert: $count products are running low';
  @override String get lowStockAlertCloseTooltip => 'Close';
  @override String get lowStockAlertAddToListTooltip => 'Add all products to shopping list';
  @override String get lowStockAlertGoToPantryTooltip => 'Go to pantry to view all items';
  @override String get lowStockAlertDismissTodayTooltip => 'This alert won\'t show again today';
  @override String get locationMainPantry => 'Pantry';
  @override String get locationRefrigerator => 'Refrigerator';
  @override String get locationFreezer => 'Freezer';
  @override String get locationKitchen => 'Kitchen';
  @override String get locationBathroom => 'Bathroom';
  @override String get locationStorage => 'Storage';
  @override String get locationServicePorch => 'Service Porch';
  @override String get locationOther => 'Other';
  @override String get locationUnknown => 'Unknown';
  @override String maxItemsReached(int max) => 'You\'ve reached the maximum of $max pantry items';
  @override String pantryHealthStatus(double healthPercent) {
    if (healthPercent >= 80) return 'Pantry is fully stocked! 💚';
    if (healthPercent >= 50) return 'Looking good — a few things to restock 🛒';
    if (healthPercent >= 25) return 'Running low — time for a shopping trip 🛒';
    return 'Almost empty — your pantry needs attention! 🚨';
  }

  @override String get pantryHealthLabel => 'Pantry Health';
  @override String pantryHealthPercent(int percent) => '$percent% properly stocked';
  @override String get pantryFullyStocked => 'Everything in stock — no worries!';
  @override String pantryLowItems(int count) => count == 1 ? '1 product is running low' : '$count products are running low';

  @override String get quantityMustBePositive => 'Quantity must be greater than zero';
  @override String get notesHint => 'Additional notes (optional)';
  @override String get permanentProduct => 'Permanent product';
  @override String addCustomProduct(String query) => 'Add "$query"';

  // Product selection sheet
  @override String get inPantryBadge => 'In pantry';
  @override String get customProductNotFound => 'Not found? Add a custom product';
  @override String get allCategoriesFilter => 'All';
  @override String get basicsCategoryFilter => 'Basics';
  @override String get tapToAddToPantry => 'Tap to add to pantry';
  @override String get productFallbackName => 'Product';
  @override String get categoryFallbackName => 'Other';
  @override String loadProductsError(String error) => 'Error loading products: $error';

  // Pantry merge dialog
  @override String get pantryMergeTitle => 'You have a personal pantry!';
  @override String pantryMergeContent(int count) =>
      'You have $count items in your personal pantry.\n\nWould you like to transfer them to your new household pantry?';
  @override String get pantryMergeButton => 'Transfer to household pantry';

  // Quick Scan to decrement stock
  @override String get quickScanTooltip => 'Scan to use item';
  @override String get quickScanTitle => 'Quick Scan';
  @override String quickScanDecremented(String name, int remaining) =>
      '$name — $remaining left';
  @override String quickScanOutOfStock(String name) =>
      '$name is out! Add to shopping list?';
  @override String get quickScanNotInPantry => 'Product not found in pantry';
  @override String get quickScanAddToList => 'Add to list';
  @override String get quickScanUndo => 'Undo';
}

// ========================================
// Shopping List Details
// ========================================

class ShoppingListDetailsStringsEn extends ShoppingListDetailsStrings {
  const ShoppingListDetailsStringsEn();

  @override String get addProductTitle => 'Add Product';
  @override String get editProductTitle => 'Edit Product';
  @override String get productNameLabel => 'Product Name';
  @override String get brandLabel => 'Brand (optional)';
  @override String get categoryLabel => 'Category';
  @override String get selectCategory => 'Select Category';
  @override String get quantityLabel => 'Quantity';
  @override String get priceLabel => 'Price per unit';
  @override String get addTaskTitle => 'Add Task';
  @override String get editTaskTitle => 'Edit Task';
  @override String get taskNameLabel => 'Task Name';
  @override String get notesLabel => 'Notes (optional)';
  @override String get dueDateLabel => 'Select due date (optional)';
  @override String dueDateSelected(String date) => 'Due date: $date';
  @override String get priorityLabel => 'Priority';
  @override String get priorityLow => '🟢 Low';
  @override String get priorityMedium => '🟡 Medium';
  @override String get priorityHigh => '🔴 High';
  @override String get productNameEmpty => 'Product name cannot be empty';
  @override String get quantityInvalid => 'Invalid quantity (1-9999)';
  @override String get priceInvalid => 'Invalid price (must be a positive number)';
  @override String get taskNameEmpty => 'Task name cannot be empty';
  @override String get searchHint => 'Search item...';
  @override String get sortPriceDesc => 'Price (high→low)';
  @override String itemsCount(int count) => '$count items';
  @override String get categoryAll => 'All';
  @override String get categoryDairy => 'Dairy & Eggs';
  @override String get categoryOther => 'Other';
  @override String get addProductButton => 'Add Product';
  @override String get addTaskButton => 'Add Task';
  @override String get shareListTooltip => 'Share list';
  @override String get pendingRequestsTooltip => 'Pending requests';
  @override String get addFromCatalogTooltip => 'Add from catalog';
  @override String get deleteTitle => 'Delete Product';
  @override String deleteMessage(String name) => 'Delete "$name"?';
  @override String itemDeleted(String name) => 'Product "$name" deleted';
  @override String get totalLabel => 'Total:';
  @override String get emptyListTitle => 'List is empty';
  @override String get emptyListSubtitle => 'Search for products above or add from catalog';
  @override String get populateFromCatalog => 'Populate from catalog';
  @override String get quickSearchHint => 'Search product to add...';
  @override String get addFreeText => 'Add as free text';
  @override String categoriesCount(int count) => '$count categories';
  @override String get noSearchResultsTitle => 'No items found';
  @override String get clearSearchButton => 'Clear search';
  @override String get loadingError => 'Error loading data';
  @override String get errorTitle => 'Oops! Something went wrong';
  @override String errorMessage(String? error) => error ?? 'An error occurred loading data';
}

// ========================================
// Select List Dialog
// ========================================

class SelectListStringsEn extends SelectListStrings {
  const SelectListStringsEn();

  @override String get defaultTitle => 'Select List';
  @override String addingItem(String itemName) => 'Adding: $itemName';
  @override String get noActiveLists => 'No active lists';
  @override String get createNewToAddItems => 'Create a new list to add items';
  @override String get createNewButton => 'Create New List';
  @override String get cancelButton => 'Cancel';
  @override String get closeTooltip => 'Close';
  @override String get createNewTooltip => 'Create a new shopping list';
  @override String get cancelTooltip => 'Cancel list selection';
  @override String itemsCount(int count) => '$count items';
  @override String get semanticLabel => 'List selection';
  @override String semanticLabelWithItem(String itemName) => 'Select list to add $itemName';
  @override String listTileSemanticLabel(String listName, int itemCount, int checkedCount) =>
      '$listName, $itemCount items${checkedCount > 0 ? ', $checkedCount checked' : ''}';
}

// ========================================
// Recurring Product Dialog
// ========================================

class RecurringStringsEn extends RecurringStrings {
  const RecurringStringsEn();

  @override String get title => 'You buy this a lot!';
  @override String get subtitle => 'Want us to add it automatically next time?';
  @override String get statPurchases => 'Purchases';
  @override String get statLastPurchase => 'Last purchase';
  @override String formatLastPurchase(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    return '${(diff / 30).floor()} months ago';
  }

  @override String get explanation => 'Recurring products are automatically added to every new list — one less thing to remember';
  @override String get confirmButton => 'Yes, auto-add it!';
  @override String get dismissButton => 'No thanks';
  @override String get askLaterButton => 'Remind me later';
  @override String get closeTooltip => 'Close';
  @override String get confirmTooltip => 'Make this a recurring product';
  @override String get dismissTooltip => 'Don\'t suggest this product as recurring';
  @override String get askLaterTooltip => 'Remind me next time';
  @override String semanticLabel(String productName) => 'Suggestion to make $productName a recurring product';
}

// ========================================
// Receipt Details
// ========================================

class ReceiptDetailsStringsEn extends ReceiptDetailsStrings {
  const ReceiptDetailsStringsEn();

  @override String get totalLabel => 'Total';
  @override String get virtualTag => 'Virtual';
  @override String get noItemsMessage => 'No items in receipt';
}

// ========================================
// Shopping History
// ========================================

class ShoppingHistoryStringsEn extends ShoppingHistoryStrings {
  const ShoppingHistoryStringsEn();

  @override String get title => 'Shopping History';
  @override String get filterThisMonth => 'This Month';
  @override String get filterThreeMonths => '3 Months';
  @override String get filterAll => 'All';
  @override String get shoppingsLabel => 'Shopping trips';
  @override String get totalLabel => 'Total';
  @override String get averageLabel => 'Average';
  @override String get totalItemsLabel => 'Items';
  @override String itemsCount(int count) => '$count items';
  @override String get noResults => 'No shopping in this period';
  @override String get noResultsSubtitle => 'Try filtering by a different period';
  @override String get emptyTitle => 'No shopping history yet';
  @override String get emptySubtitle => 'Finish your first shopping and it\'ll\nshow up right here 🛒';
  @override String get defaultError => 'Error loading';
  @override String get retryButton => 'Try Again';
}

// ========================================
// Activity Log
// ========================================

class ActivityLogStringsEn extends ActivityLogStrings {
  const ActivityLogStringsEn();
  @override String get tabTitle => 'Activity Log';
  @override String get receiptsTab => 'Receipts';
  @override String get emptyTitle => 'No activity yet';
  @override String get emptySubtitle => 'Household activity will appear here';
  @override String get defaultError => 'Error loading activity';
  @override String get retryButton => 'Try Again';
  @override String shoppingCompleted(String actor, String listName) =>
      '$actor completed shopping from "$listName"';
  @override String shoppingStarted(String actor, String listName) =>
      '$actor started shopping from "$listName"';
  @override String shoppingJoined(String actor, String listName) =>
      '$actor joined shopping from "$listName"';
  @override String listCreated(String actor, String listName) =>
      '$actor created list "$listName"';
  @override String itemAdded(String actor, String itemName, String listName) =>
      '$actor added "$itemName" to "$listName"';
  @override String stockUpdated(String actor, String productName) =>
      '$actor updated stock for "$productName"';
  @override String memberLeft(String actor) =>
      '$actor left the household';
  @override String roleChanged(String actor, String targetName, String newRole) =>
      '$actor changed $targetName\'s role to $newRole';
  @override String unknownActivity(String actor) =>
      '$actor performed an action';
}

// ========================================
// Active Shopper Banner
// ========================================

class ActiveShopperBannerStringsEn extends ActiveShopperBannerStrings {
  const ActiveShopperBannerStringsEn();

  @override String get myActiveTitle => 'You have active shopping';
  @override String myActiveSubtitle(String listName, int remaining) => '"$listName" - $remaining items remaining';
  // Compact single-line variant used in the home banner.
  @override String myActiveCompact(String listName, int remaining) => '$listName · $remaining items';
  @override String get continueButton => 'Continue';
  @override String othersActiveTitle(String shopperName) => '$shopperName is shopping now';
  @override String othersActiveTitleMultiple(int count) => '$count shoppers active now';
  @override String othersActiveSingle(String listName) => 'Shopping from "$listName"';
  @override String othersActiveMultiple(int count, String listName) => '$count people shopping from "$listName"';
  @override String get joinButton => 'Join';
  @override String get viewListTooltip => 'Live view';
  @override String shopperJoined(String name) => '$name joined the shopping';
  @override String shopperLeft(String name) => '$name left the shopping';
  @override String shopperUpdatingPantry(String name) => '$name is updating the pantry';
  @override String shopperCheckedItem(String name, String item) => '$name checked "$item" as bought';
  @override String activeShoppersCount(int count) => '$count active shoppers now';
  @override String shopperAvatarLabel(String name, bool isStarter) =>
      isStarter ? '$name (started the shopping)' : '$name is shopping now';
  @override String get moreShoppersLabel => 'More active shoppers';
}

// ========================================
// Suggestions Today Card
// ========================================

class SuggestionsTodayCardStringsEn extends SuggestionsTodayCardStrings {
  const SuggestionsTodayCardStringsEn();

  @override String get title => 'Smart suggestions';
  @override String get loading => 'Loading suggestions...';
  @override String itemCount(int count) => '$count items';
  @override String get urgencyCritical => 'Out of stock!';
  @override String get urgencyHigh => 'Almost out';
  @override String get urgencyMedium => 'Running low';
  @override String get urgencyLow => 'Recommended';
  @override String inStock(int stock, String unit) => 'In stock: $stock $unit';
  @override String get addButton => 'Add';
  @override String get noActiveLists => 'No active lists - create a new list';
  @override String get chooseListTitle => 'Add to which list?';
  @override String get addedToList => 'Added to list';
  @override String addedToListName(String productName) => 'Added "$productName" to list';
  @override String dismissedForWeek(String productName) => 'Dismissed "$productName" for a week';
  @override String suggestionError(String error) => 'Error: $error';
  @override String get addAll => 'Add All';
  @override String addedAll(int count, String listName) => '$count items added to "$listName"';
}

// ========================================
// Last Chance Banner
// ========================================

class LastChanceBannerStringsEn extends LastChanceBannerStrings {
  const LastChanceBannerStringsEn();

  @override String get title => 'Don\'t forget — you usually grab this too';
  @override String semanticsLabel(String productName, int stock) =>
      'Smart suggestion: $productName is running low in your pantry. $stock units remaining. Double tap to add to list.';
  @override String stockText(int stock) => 'Only $stock left in pantry';
  @override String addTooltip(String productName) => 'Add "$productName" to shopping list';
  @override String get addButton => 'Add to list';
  @override String get nextTooltip => 'Go to next suggestion';
  @override String get nextButton => 'Next';
  @override String get skipSessionTooltip => 'Skip — we\'ll remind you next time';
  @override String get skipSessionButton => 'Not this time';
  @override String addedSuccess(String productName) => 'Added "$productName" to list';
  @override String get addError => 'Error adding item';
  @override String get genericError => 'An error occurred, try again';
  @override String get skippedForSession => 'Skipped for now — we\'ll remind you next time';
}

// ========================================
// Pending Invites Screen
// ========================================

class PendingInvitesScreenStringsEn extends PendingInvitesScreenStrings {
  const PendingInvitesScreenStringsEn();

  @override String get title => 'Pending Invitations';
  @override String get loading => 'Loading invitations...';
  @override String get loadError => 'Error loading invitations';
  @override String get retryButton => 'Try Again';
  @override String get emptyTitle => 'All clear!';
  @override String get emptySubtitle => 'When someone invites you to a list,\nit\'ll show up right here';
  @override String get pullToRefresh => '↓ Pull to refresh';
  @override String get listFallback => 'List';
  @override String get userFallback => 'User';
  @override String inviteToList(String listName) => 'Invitation to list "$listName"';
  @override String inviterMessage(String inviterName) => '$inviterName invites you to join';
  @override String get roleLabel => 'Role: ';
  @override String get acceptButton => 'Join';
  @override String get declineButton => 'Decline';
  @override String acceptSuccess(String listName) => 'Joined list "$listName"';
  @override String acceptError(String error) => 'Error accepting invitation: $error';
  @override String get declineDialogTitle => 'Decline Invitation';
  @override String declineDialogMessage(String listName) => 'Decline invitation to list "$listName"?';
  @override String get cancelButton => 'Cancel';
  @override String get declineConfirmButton => 'Decline';
  @override String get declineSuccess => 'Invitation declined';
  @override String declineError(String error) => 'Error declining invitation: $error';

  @override String pendingRequestsLabel(int count) => '$count pending requests';
  @override String get rejectRequest => 'Reject request';
  @override String get rejectButton => 'Reject';
  @override String get approveRequest => 'Approve request';
  @override String get approveButton => 'Approve';
  @override String approveError(String error) => 'Error approving request: $error';
  @override String rejectError(String error) => 'Error rejecting request: $error';
}

// ========================================
// Pending Invite Banner
// ========================================

class PendingInviteBannerStringsEn extends PendingInviteBannerStrings {
  const PendingInviteBannerStringsEn();

  @override String get title => 'Group Invitation';
  @override String moreCount(int count) => '+$count';
  @override String inviteMessage(String inviterName, String groupName) => '$inviterName invited you to "$groupName"';
  @override String get acceptButton => 'Accept';
  @override String get rejectButton => 'Decline';
  @override String get rejectDialogTitle => 'Decline Invitation';
  @override String get cancelButton => 'Cancel';
  @override String acceptSuccess(String groupName) => 'Joined group "$groupName"';
  @override String get acceptError => 'Error accepting invitation';
}

// ========================================
// User Sharing System
// ========================================

class SharingStringsEn extends SharingStrings {
  const SharingStringsEn();

  @override String get roleOwner => 'Owner';
  @override String get roleAdmin => 'Admin';
  @override String get roleEditor => 'Editor';
  @override String get roleViewer => 'Viewer';
  @override String get roleOwnerDesc => 'Full access + delete list + manage users';
  @override String get roleAdminDesc => 'Full access + manage users (no delete)';
  @override String get roleEditorDesc => 'Read + add items via requests (requires approval)';
  @override String get roleViewerDesc => 'Read only (cannot edit anything)';
  @override String get inviteTitle => 'Invite Users';
  @override String get inviteSubtitle => 'Invite people to share the list';
  @override String get emailLabel => 'Email';
  @override String get emailHint => 'example@email.com';
  @override String get emailRequired => 'Please enter an email address';
  @override String get emailInvalid => 'Invalid email';
  @override String get selectRoleLabel => 'Select Role';
  @override String get inviteButton => 'Send Invitation';
  @override String get inviting => 'Sending...';
  @override String get cancelButton => 'Cancel';
  @override String inviteSent(String email) => 'Invitation sent to $email 📧';
  @override String inviteResent(String email) => 'Invitation resent to $email';
  @override String get userNotFound => 'User not found in the system';
  @override String get cannotInviteSelf => 'You cannot invite yourself';
  @override String inviteError(String error) => 'Error sending invitation: $error';
  @override String get inviteUserButton => 'Invite User';
  @override String get changeRoleTooltip => 'Change role';
  @override String get resendInviteTooltip => 'Resend invitation';
  @override String get changeRoleTitle => 'Change Role';
  @override String changeRoleMessage(String userName) => 'Select a new role for $userName:';
  @override String get changeRoleButton => 'Change';
  @override String roleChanged(String userName, String newRole) => '$userName updated to $newRole';
  @override String changeRoleError(String error) => 'Error changing role: $error';
  @override String get removeUserTitle => 'Remove User';
  @override String get removeButton => 'Remove';
  @override String userRemoved(String userName) => '$userName removed from list';
  @override String get savedContactsTitle => 'Saved Contacts';
  @override String get savedContactsSubtitle => 'Choose from contacts you\'ve invited before';
  @override String showMoreContacts(int count) => 'Show $count more contacts';
  @override String get orEnterNewEmail => '── or enter a new email ──';
  @override String get contactSelectedEmailDisabled => 'Contact selected - email won\'t be used';
  @override String get alreadySharedBadge => 'Already shared';
  @override String inviteConfirmation(String recipient, String role, String listName) =>
      'Invitation will be sent to $recipient as $role in list "$listName"';
  @override String inviteSentPending(String name) => 'Invitation sent to $name - pending approval';
  @override String inviteSentUnregistered(String name) => 'Invitation sent to $name - they\'ll see it when they register';
  @override String get householdNameDialogTitle => 'What should we call your group?';
  @override String get householdNameDialogHint => 'e.g., The Smith House';
  @override String get householdNameDialogSkip => 'Skip';
  @override String get cannotChangeOwnRole => 'You cannot change your own role';
  @override String get noPermissionInvite => 'Only the owner can invite users';
  @override String get pendingRequestsTitle => 'Pending Requests';
  @override String get noPermissionViewRequests => 'Only owners/admins can view requests';
  @override String get noPendingRequests => 'No pending requests';
  @override String get noPendingRequestsSubtitle => 'Requests from editors will appear here for approval';
  @override String get requestTypeAdd => 'Add';
  @override String get requestTypeEdit => 'Edit';
  @override String get requestTypeDelete => 'Delete';
  @override String get requestTypeInvite => 'Invite';
  @override String get requestTypeUnknown => 'Unknown';
  @override String get unknownRequestWarning => 'Unknown request type - app update required';
  @override String get viewDetailsButton => 'Details';
  @override String get approveButton => 'Approve ✅';
  @override String get rejectButton => 'Reject ❌';
  @override String get backButton => 'Back';
  @override String get unknownUserFallback => 'Unknown user';
  @override String get unknownItemFallback => 'Unknown item';
  @override String get editItemFallback => 'Edit item';
  @override String get deleteItemFallback => 'Delete item';
  @override String get unknownRequestFallback => 'Unknown request';
  @override String get requestDetailsTitle => 'Request Details';
  @override String get quantityLabel => 'Quantity';
  @override String get categoryLabel => 'Category';
  @override String get priceLabel => 'Price';
  @override String get notesLabel => 'Notes';
  @override String requestApproved(String itemName) => '✅ Request to add "$itemName" approved';
  @override String get requestApprovedSuccess => 'Request approved successfully';
  @override String get requestApprovedError => 'Error approving request';
  @override String requestRejected(String itemName) => '❌ Request to add "$itemName" rejected';
  @override String get requestRejectedSuccess => 'Request rejected';
  @override String get requestRejectedError => 'Error rejecting request';
  @override String get rejectDialogTitle => 'Reject Request';
  @override String get rejectDialogMessage => 'Why reject the request? (optional)';
  @override String get rejectReasonHint => 'Rejection reason...';
  @override String get noPermissionTitle => 'No Permission';
  @override String get onlyOwnerCanChangePermissions => 'Only the owner can change permissions';
  @override String get mustBeOwnerOrAdmin => 'Must be an owner or admin to perform this action';
  @override String get requestCreated => 'Request sent for owner/admin approval';
  @override String editorRequestsMixed(int approved, int rejected) => '✅ $approved requests approved | ❌ $rejected rejected';
  @override String editorRequestsApproved(int count) => '✅ $count of your requests were approved!';
  @override String editorRequestsRejected(int count) => '❌ $count of your requests were rejected';
  @override String get requestWaitingApproval => 'Item will wait for approval before appearing in the list';
  @override String get notificationInviteTitle => 'Shared list invitation';
  @override String notificationInviteBody(String listName, String inviterName) => '$inviterName invited you to list "$listName"';
  @override String get notificationRequestApprovedTitle => 'Request approved';
  @override String notificationRequestApprovedBody(String itemName, String listName) =>
      'Your request to add "$itemName" to "$listName" was approved ✅';
  @override String get notificationRequestRejectedTitle => 'Request rejected';
  @override String notificationRequestRejectedBody(String itemName, String listName) =>
      'Your request to add "$itemName" to "$listName" was rejected ❌';
  @override String get notificationNewRequestTitle => 'New request';
  @override String notificationNewRequestBody(String requesterName, String itemName) =>
      '$requesterName requested to add "$itemName" to the list';
  @override String get notificationRoleChangedTitle => 'Your role was changed';
  @override String notificationRoleChangedBody(String newRole, String listName) => 'Your role in "$listName" changed to $newRole';
  @override String get notificationRemovedTitle => 'Removed from list';
  @override String notificationRemovedBody(String listName) => 'You were removed from list "$listName"';
  @override String get sharedListBadge => 'Shared';
  @override String sharedWith(int count) => 'Shared with $count people';
  @override String get youAreAdmin => 'You\'re an admin';
  @override String get loadingUsers => 'Loading users...';
  @override String get loadingError => 'Error loading data';
  @override String get retryButton => 'Try Again';
  @override String maxGroupsReached(int max) => 'You\'ve reached the maximum of $max groups';
  @override String groupsNearLimit(int current, int max) => 'You have $current of $max groups';
  @override String get rejectRequestTitle => 'Reject Request';
  @override String get rejectRequestConfirm => 'Are you sure you want to reject this request?';
  @override String get rejectRequestButton => 'Reject';
}

// ========================================
// Home Dashboard Screen
// ========================================

class HomeDashboardStringsEn extends HomeDashboardStrings {
  const HomeDashboardStringsEn();

  @override String get newListButton => 'New List';
  @override String get inviteFamilyTitle => 'Invite your family to shop together';
  @override String get inviteFamilySubtitle => 'Share lists, pantry, and notifications';
  @override String get inviteFamilyAction => 'Invite';
  @override String get errorTitle => 'Error loading data';
  @override String get retryButton => 'Try Again';
  @override String get refreshOfflineMessage => 'Offline — showing cached data';
  @override String greeting(String? userName) => (userName?.trim().isNotEmpty ?? false) ? 'Hello, $userName!' : 'Hello!';
  @override String timeBasedGreeting(String? userName, int hour) {
    final String greet;
    if (hour >= 5 && hour < 12) {
      greet = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greet = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greet = 'Good evening';
    } else {
      greet = 'Good night';
    }
    return (userName?.trim().isNotEmpty ?? false) ? '$greet, $userName!' : '$greet!';
  }

  @override String get personalFamily => 'My Home';
  @override String get sharedFamily => 'Shared Home';
  @override String get familyOf => 'Home of ';
  @override String get activeListsTitle => 'Active Lists';
  @override String get noActiveLists => 'No active lists';
  @override String get createListHint => 'Tap here to create a new list';
  @override String get createFirstList => 'Create your first list';
  @override String get emptyList => 'Empty list';
  @override String get emptyListCta => 'Tap to add items';
  @override String get completed => 'Completed! ✓';
  @override String remainingItems(int count) => '$count items remaining';
  @override String itemsCount(int count) => '$count items';
  @override String get historyTitle => 'History';
  @override String get seeAll => 'See all';
  @override String get today => 'Today';
  @override String get yesterday => 'Yesterday';
  @override String daysAgo(int days) => '$days days ago';
  @override String dateFormat(int day, int month, int year) => '$month/$day/$year';

  // Activity feed
  @override String get activityFeedTitle => 'What\'s new at home';
  @override String get youLabel => 'You';
  @override String get householdMember => 'Household member';
  @override String completedShoppingAt(String store) => '✅ Completed shopping at $store';
  @override String plusItems(int count) => '+$count items';
  @override String minutesAgo(int minutes) => '$minutes min ago';
  @override String hoursAgo(int hours) => '$hours hr ago';

  // Active lists subtitle
  @override String activeListsSubtitle(int count) => '$count active lists';

  // User info fallback
  @override String get userFallback => 'User';
}

// ========================================
// Notifications Center Screen
// ========================================

class NotificationsCenterStringsEn extends NotificationsCenterStrings {
  const NotificationsCenterStringsEn();

  @override String get title => 'Notifications';
  @override String get markAllAsRead => 'Mark all as read';
  @override String get userNotLoggedIn => 'User not logged in';
  @override String get loadingError => 'Error loading notifications';
  @override String get retryButton => 'Try Again';
  @override String get emptyTitle => 'You\'re all caught up!';
  @override String get emptySubtitle => 'New updates and activity will show up here';
  @override String get allMarkedAsRead => 'All notifications marked as read';
}

// ========================================
// Pantry Screen
// ========================================

class PantryStringsEn extends PantryStrings {
  const PantryStringsEn();

  @override String get screenLabel => 'My Pantry screen';
  @override String get addItemLabel => 'Add product to pantry';
  @override String quantityLabel(int quantity, bool isLowStock) =>
      '$quantity units${isLowStock ? ', low stock' : ''}, tap to update';
  @override String get pantryPrefix => 'Pantry ';
  @override String get addItemTooltip => 'Add product';
  @override String get loadingText => 'Loading...';
  @override String get loadingErrorTitle => 'Error loading pantry';
  @override String get loadingErrorDefault => 'Try again later';
  @override String get retryButton => 'Try Again';
  @override String get noItemsFound => 'No items found';
  @override String get clearFilters => 'Clear filters';
  @override String get filterOutOfStockLabel => 'Showing: out-of-stock';
  @override String get filterLowStockLabel => 'Showing: low stock';
  @override String get noStarterItemsFound => 'No starter items found';
  @override String starterItemsAdded(int count) => 'Added $count starter items to pantry';
  @override String get starterItemsError => 'Error adding starter items';
  @override String get starterPreviewTitle => 'Pantry Essentials';
  @override String get starterPreviewSubtitle => 'Check the products you usually have at home';
  @override String get starterSearchQuery => 'milk eggs bread oil sugar flour rice';
  @override String get suggestionsTitle => 'Essentials for your pantry';
  @override String get hideSuggestions => 'Hide';
  @override String itemDeleted(String name) => '$name deleted';
  @override String get deleteItemError => 'Error deleting item';
  @override String get updateQuantityError => 'Error updating quantity';
  @override String get searchHint => 'Search pantry...';
  @override String get clearSearchTooltip => 'Clear search';
  @override String get allLocations => 'All';
  @override String get swipeDelete => 'Delete';
  @override String get deleteDialogTitle => 'Delete Item';
  @override String deleteDialogContent(String name) => 'Delete "$name"?';
  @override String get updateQuantityTitle => 'Update quantity:';
  @override String lowStockWarning(int minQuantity) => 'Low stock (minimum: $minQuantity)';
  @override String get cancelButton => 'Cancel';
  @override String get saveButton => 'Save';
  @override String get unitAbbreviation => 'pcs';

  @override String get tabItems => 'Items';
  @override String get tabMissing => 'Missing';
  @override String get tabLocations => 'Locations';
  @override String get addBasicsButton => 'Yes, add!';
  @override String get emptyLabel => 'Pantry empty';
  @override String get addFirstProduct => 'Add first product';
  @override String get emptyMainTitle => "Let's fill the pantry! 🎉";
  @override String get emptySubtitlePersonal => "Add products so you always know what you have and what's missing";
  @override String get emptySubtitleGroup => "Add products to the shared pantry to keep track of what's at home";
  @override String get howToStartTitle => 'How to get started?';
  @override String get howToStartStep1 => 'Tap "Add Product" below';
  @override String get howToStartStep2 => 'Search from 30,000+ products';
  @override String get howToStartStep3 => "Set the quantity — that's it! 🎯";
  @override String get howToStartHint => "✨ When a product runs out, you'll get an alert in your shopping list";
  @override String get starterItemsTitle => 'Want to start with basic items?';
  @override String get starterItemsSubtitle => 'Flour, sugar, oil, rice and more — mark what you need';
  @override String pantryBadgeGroup(String name) => 'Home Pantry — $name';
  @override String get pantryBadgePersonal => 'Your Pantry ✨';

  @override String get similarProductFound => 'Similar product found in pantry';
  @override String get existingInPantry => 'Existing in pantry';
  @override String get scannedProduct => 'Scanned product';
  @override String get updateQuantity => 'Update quantity';
  @override String get replaceProduct => 'Replace product';
  @override String get addSeparately => 'Add separately';
}

// ========================================
// Checklist Screen
// ========================================

class ChecklistStringsEn extends ChecklistStrings {
  const ChecklistStringsEn();

  @override String get subtitle => 'Checklist ✓';
  @override String get gotItButton => 'Got it';
  @override String get checkAll => 'Check all';
  @override String get uncheckAll => 'Uncheck all';
  @override String percentComplete(int percent) => '$percent% completed';
  @override String get emptyTitle => 'List is empty';
  @override String get emptySubtitle => 'Add items to checklist';
}

// ========================================
// Contact Selector Dialog
// ========================================

class ContactSelectorStringsEn extends ContactSelectorStrings {
  const ContactSelectorStringsEn();

  @override String get title => 'Select People to Share With';
  @override String get searchHint => 'Search by name or email...';
  @override String get addNewContact => 'Add New Contact';
  @override String get emailLabel => 'Email';
  @override String get phoneLabel => 'Phone';
  @override String get emailHint => 'Enter email...';
  @override String get phoneHint => '05X-XXXXXXX';
  @override String get invalidEmail => 'Please enter a valid email';
  @override String get invalidPhone => 'Please enter a valid phone number (05X-XXXXXXX)';
  @override String get contactAlreadySelected => 'This contact is already selected';
  @override String genericError(String error) => 'Error: $error';
  @override String get noSavedContacts => 'No saved contacts';
  @override String get noSearchResults => 'No results found';
  @override String get cancelButton => 'Cancel';
  @override String confirmButton(int count) => 'Confirm ($count)';
  @override String selectRoleFor(String name) => 'Select role for $name';
  @override String get roleOwnerShortDesc => 'Owner - full permissions';
  @override String get roleAdminShortDesc => 'Can edit directly and invite others';
  @override String get roleEditorShortDesc => 'Can edit via approval';
  @override String get roleViewerShortDesc => 'View only';
  @override String get roleUnknownShortDesc => 'Unknown role';
}

class ShoppingSummaryStringsEn extends ShoppingSummaryStrings {
  const ShoppingSummaryStringsEn();
  @override String get title => 'Shopping completed!';
  @override String get successRate => 'Success';
  @override String get purchasedLabel => 'Purchased';
  @override String get missingLabel => 'Missing';
  @override String get totalLabel => 'Total';
  @override String get budgetTitle => 'Budget';
  @override String budgetRemaining(String amount) => '$amount left';
  @override String budgetOver(String amount) => '$amount over';
  @override String get backToHome => 'Back to home';
  @override String get loadError => 'Error loading summary';
  @override String get notFound => 'List not found';
  @override String get notFoundSubtitle => 'The list may have been deleted';
}

class OnboardingTipsStringsEn extends OnboardingTipsStrings {
  const OnboardingTipsStringsEn();

  @override String get fillPantryTitle => 'Set up your pantry';
  @override String get fillPantrySubtitle => 'Tell us what you have at home — we\'ll alert when something runs out';
  @override String get fillPantryAction => 'Start';

  @override String get createListsTitle => 'Create more lists';
  @override String get createListsSubtitle => 'Supermarket, produce, bakery, events — a list for every need';
  @override String get createListsAction => 'Create';
}

class ActionCenterStringsEn extends ActionCenterStrings {
  const ActionCenterStringsEn();

  @override String get title => 'Needs Attention';
  @override String pendingRequests(int count) => '$count pending requests';
  @override String get review => 'View';
  @override String get overdueList => 'Overdue list!';
  @override String overdueListsCount(int count) => '$count overdue lists!';
  @override String get startShopping => 'Start';
  @override String criticalStock(int count) => '$count items out of stock';
  @override String get goToPantry => 'Pantry';
}
