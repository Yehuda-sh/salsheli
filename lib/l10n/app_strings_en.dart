// 📄 lib/l10n/app_strings_en.dart
//
// UI strings grouped by screens - English translation.
// Structure: AppStringsEn.layout, .common, .auth, .inventory, .shoppingList, etc.
//
// Version: 1.0 (12/03/2026) — English translation
// 🔗 Related: All screens and widgets, filters_config (for categories)

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
}

// ========================================
// _CategoryStrings
// ========================================

class CategoryStringsEn extends CategoryStrings {
  const CategoryStringsEn();

  String get all => 'All';
  String get other => 'Other';
  String get dairy => 'Dairy';
  String get vegetables => 'Vegetables';
  String get fruits => 'Fruits';
  String get meatFish => 'Meat & Fish';
  String get ricePasta => 'Rice & Pasta';
  String get spices => 'Spices';
  String get coffeeTea => 'Coffee & Tea';
  String get sweetsSnacks => 'Sweets & Snacks';
  String get beef => 'Beef';
  String get chicken => 'Chicken';
  String get turkey => 'Turkey';
  String get lamb => 'Lamb';
  String get fish => 'Fish';
  String get meatSubstitutes => 'Meat Substitutes';
  String get breadBakery => 'Bread & Bakery';
  String get cookiesSweets => 'Cookies & Sweets';
  String get cakes => 'Cakes';
  String get canned => 'Canned Goods';
  String get legumesGrains => 'Legumes & Grains';
  String get cereals => 'Cereals';
  String get driedFruits => 'Dried Fruits';
  String get nutsSeeds => 'Nuts & Seeds';
  String get beverages => 'Beverages';
  String get oilsSauces => 'Oils & Sauces';
  String get sweetSpreads => 'Sweet Spreads';
  String get frozen => 'Frozen';
  String get readySalads => 'Ready Salads';
  String get dairySubstitutes => 'Dairy Substitutes';
  String get hygiene => 'Hygiene';
  String get oralCare => 'Oral Care';
  String get cosmetics => 'Cosmetics & Care';
  String get feminineHygiene => 'Feminine Hygiene';
  String get cleaning => 'Cleaning Products';
  String get homeProducts => 'Home Products';
  String get disposable => 'Disposable';
  String get garden => 'Garden Products';
  String get petFood => 'Pet Food';
  String get otcMedicine => 'OTC Medicine';
  String get vitamins => 'Vitamins & Supplements';
  String get firstAid => 'First Aid';
  String get babyProducts => 'Baby Products';
  String get accessories => 'Accessories';
}

// ========================================
// Layout Strings
// ========================================

class LayoutStringsEn extends LayoutStrings {
  const LayoutStringsEn();

  String get appTitle => AppStringsEn.appName;
  String get notifications => 'Notifications';
  String get noNotifications => 'No new notifications';
  String notificationsCount(int count) => 'You have $count new updates';
  String get welcome => 'Welcome to ${AppStringsEn.appName}';
  String get offline => 'No internet connection';
  String get logoutError => 'Error logging out, try again';
  String get pendingInvitesTitle => 'Notifications & Invites';
  String get groupInvites => 'Group Invitations';
  String get groupInvitesSubtitle => 'Join a household';
  String get listInvites => 'List Invitations';
  String get listInvitesSubtitle => 'Share shopping lists';
  String get notificationsSubtitle => 'Recent updates & activity';
  @override String get lowStockTitle => 'Low Stock';
  @override String lowStockSubtitle(int count) => '$count items running low';
  String navSemanticLabel(String selectedTab) => 'Main navigation. Selected tab: $selectedTab';
  String get navSemanticHint => 'Swipe left or right to select another tab';
  String get longPressHint => 'Long press for more options';
}

// ========================================
// Navigation Strings (Tabs)
// ========================================

class NavigationStringsEn extends NavigationStrings {
  const NavigationStringsEn();

  String get home => 'Home';
  String get family => 'Home';
  String get groups => 'Groups';
  String get lists => 'Lists';
  String get pantry => 'Pantry';
  String get receipts => 'Receipts';
  String get history => 'History';
  String get settings => 'Settings';
}

// ========================================
// Common Strings (Buttons, Actions)
// ========================================

class CommonStringsEn extends CommonStrings {
  const CommonStringsEn();

  String get logout => 'Log Out';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get add => 'Add';
  String get search => 'Search';
  String get retry => 'Try Again';
  String get resetFilter => 'Reset Filter';
  String get clearAll => 'Clear All';
  String get searchProductHint => 'Search product...';
  String get categories => 'Categories';
  String get meatTypes => 'Meat Types';
  String get all => 'All';
  String get yes => 'Yes';
  String get no => 'No';
  String get ok => 'OK';
  String get loading => 'Loading...';
  String get error => 'Error';
  String get success => 'Success';
  String get categoryUnknown => 'Unknown';
  String get syncError => 'Sync issue - changes saved locally';
  String get saveFailed => 'Save failed, try again';
  String get unsavedChangesTitle => 'Unsaved Changes';
  String get unsavedChangesMessage => 'You have unsaved changes. Exit without saving?';
  String get stayHere => 'Stay';
  String get exitWithoutSaving => 'Exit Without Saving';

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
  @override String get unknownErrorGeneric => 'Unknown error';
  @override String get connected => 'Connected';
}

// ========================================
// Onboarding Strings
// ========================================


// ========================================
// Shopping Strings
// ========================================

class ShoppingStringsEn extends ShoppingStrings {
  const ShoppingStringsEn();

  String get itemStatusOutOfStock => 'Out of stock';
  String get activeSaving => 'Saving...';
  String get activeFinish => 'Finish';
  String get activePurchased => 'Purchased';
  String get activeNotNeeded => 'Not needed';
  String get activeRemaining => 'Remaining';
  String get activeTotal => 'Total';
  String get activeSavingData => 'Saving data...';
  String get loadingDataError => 'Error loading data';
  String get shoppingCompletedSuccess => 'Shopping completed successfully! 🎉';
  String get viewerCannotShop => 'Viewers cannot participate in shopping';
  String pantryUpdated(int count) => '📦 $count products updated in pantry';
  String itemsMovedToNext(int count) => '🔄 $count items moved to next list';
  String get saveError => 'Save error';
  String get saveErrorMessage => 'We couldn\'t save the data.\nTry again?';
  String get oopsError => 'Oops! Something went wrong';
  String get listEmpty => 'List is empty';
  String get noItemsToBuy => 'No items to buy';
  String get sharedLabel => 'Shared';
  String get startShoppingButton => 'Start Shopping';
  String get addProductsToStart => 'Add products to get started';
  String listDeleted(String name) => 'List "$name" deleted';
  String get undoButton => 'Undo';
  String get restoreError => 'Error restoring list';
  String get deleteError => 'Error deleting list';
  String get urgencyPassed => 'Overdue!';
  String get urgencyToday => 'Today!';
  String get urgencyTomorrow => 'Tomorrow';
  String urgencyDaysLeft(int days) => '$days days left';
  String get typeSupermarket => 'Supermarket';
  String get typePharmacy => 'Pharmacy';
  String get typeGreengrocer => 'Greengrocer';
  String get typeButcher => 'Butcher';
  String get typeBakery => 'Bakery';
  String get typeMarket => 'Market';
  String get typeHousehold => 'Household';
  String get typeEvent => 'Event';
  String get typeOther => 'Other';
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
  String get deleteListTitle => 'Delete List';
  String deleteListMessage(String name) => 'Delete list "$name"?';
  String get deleteButton => 'Delete';
  String itemsAndDate(int count, String date) => 'Items: $count • Updated: $date';
  String get editListButton => 'Edit List';
  String get deleteListButton => 'Delete';
  String get summaryTitle => 'Shopping Summary';
  @override String get summarySuccess => 'Shopping done! ⚡';
  @override String get storeQuestion => 'Where did you shop?';
  @override String get whoBringsWhat => 'Who brings what';
  @override String get checklist => 'Checklist';
  @override String get defaultInviteLabel => 'Invitation';
  @override String get leaveShoppingTitle => 'Leave shopping?';
  @override String get leaveShoppingMessage => 'Shopping is still active. You can come back later.';
  @override String get continueShoppingButton => 'Keep shopping';
  @override String get leaveButton => 'Leave';
  String get summaryOutOfStock => 'Out of stock';
  String get summaryNotMarked => 'Not marked';
  String get summaryBack => 'Back';
  String get summaryFinishShopping => 'Finish Shopping';
  String summaryPurchased(int purchased, int total) => '$purchased of $total';
  String summaryPendingQuestion(int count) => count == 1 ? 'There is 1 unmarked item.' : 'There are $count unmarked items.';
  String get summaryPendingSubtitle => 'What would you like to do with them?';
  String get summaryPendingTransfer => 'Move to next list';
  String get summaryPendingTransferSubtitle => 'Items will be moved to the next shopping';
  String get summaryPendingLeave => 'Keep in list';
  String get summaryPendingLeaveSubtitle => 'The list will remain active';
  String get summaryPendingDelete => 'Delete, not needed';
  String get summaryPendingDeleteSubtitle => 'Items will be removed completely';
  String priceFormat(double price) => '₪${price.toStringAsFixed(2)}';
  String get noPrice => 'No price';
  String get categoryGeneral => 'General';
  String addProductsTitle(String listName) => 'Add Products: $listName';
  String productRemovedFromList(String name) => '$name removed from list';
  String productUpdatedQuantity(String name, int quantity) => '$name (updated to $quantity)';
  String productAddedToList(String name) => '$name added to list! ✓';
  String get loadingProducts => 'Loading products...';
  String noProductsMatchingSearch(String query) => 'No products matching "$query"';
  String get noProductsAvailable => 'No products available';
  String get loadProductsButton => 'Load Products';
  String get productNoName => 'No name';
  String updateProductError(String error) => 'Error updating product: $error';
  String addProductError(String error) => 'Error adding product: $error';
  String get searchAndFilter => 'Search & Filter';
  String get filterActive => 'Filter active';
  String get searchMenuLabel => 'Search';
  String get filterByTypeLabel => 'Filter by type';
  String get sortLabel => 'Sort';
  String get clearFilterLabel => 'Clear filter';
  String get newListTooltip => 'New list';
  String get searchListTitle => 'Search List';
  String get searchListHint => 'Type a list name...';
  String get clearButton => 'Clear';
  String get searchButton => 'Search';
  String get filterByTypeTitle => 'Filter by Type';
  String get allTypesLabel => 'All';
  String get sortTitle => 'Sort';
  String get sortDateDesc => 'Newest first';
  String get sortDateAsc => 'Oldest first';
  String get sortNameAZ => 'A-Z';
  String get sortBudgetDesc => 'Budget high → low';
  String get sortBudgetAsc => 'Budget low → high';
  String get sortLabelNew => 'New';
  String get sortLabelOld => 'Old';
  String get sortLabelAZ => 'A-Z';
  String get activeLists => '🔵 Active Lists';
  String get historyLists => '✅ History';
  String get historyListsNote => '(by last update)';
  String get noListsFoundTitle => 'No lists found';
  String get noListsFoundSubtitle => 'Try changing the search or filter';
  String get noListsTitle => 'No shopping lists';
  String get noListsSubtitle => 'Tap the button below to create\nyour first list!';
  String get createNewListButton => 'Create New List';
  String get orScanReceiptHint => 'Or scan a receipt in the receipts screen';
  String get loadingListsError => 'Error loading lists';
  String get somethingWentWrong => 'Something went wrong...';
  String get tryAgainButton => 'Try Again';
  String loadMoreLists(int remaining) => 'Load more lists ($remaining remaining)';
  String get moreOptionsTooltip => 'More options';
  String get defaultShoppingListName => 'General Shopping';
  String maxItemsReached(int max) => 'You\'ve reached the maximum of $max items per list';
  String maxListsReached(int max) => 'You\'ve reached the maximum of $max active lists';
  String get syncSuccess => 'Sync successful!';
  String get syncErrorTooltip => 'Not synced - tap to retry';
  String get shoppingSaved => 'Shopping saved';
  String pendingItemsLeftWarning(int count) => '$count items remaining, list stays active';
  String get legendOutOfStock => 'Out of stock';
  String get legendNotNeeded => 'Not needed';
  @override String get legendPending => 'Pending';
  @override String get editQuantity => 'Edit quantity';
  @override String get scanBarcode => 'Scan barcode';
  @override String get barcodeFoundAdd => 'Product not in list. Add it?';
  @override String get addToListButton => 'Add to list';
  @override String barcodeNotFound(String code) => 'Barcode $code not found';
  String get retryLoadSemantics => 'Double tap to try loading the list again';
  String get backToListSemantics => 'Double tap to return to the shopping list';
  String get finishAndSaveSemantics => 'Double tap to finish shopping and save data';
  String outOfStockToggleSemantics(String itemName, bool isOutOfStock) =>
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
  @override String get otherStoreHint => 'Other store...';
}

// ========================================
// Index (Splash) Strings
// ========================================

class IndexStringsEn extends IndexStrings {
  const IndexStringsEn();

  String get appName => AppStringsEn.appName;
  String get logoLabel => '${AppStringsEn.appName} app logo';
  String get loadingLabel => 'Loading the app';
  String get loading => 'Loading...';
  List<String> get loadingMessages => const ['Checking status...', 'Connecting...', 'Almost ready...'];
  String get errorTitle => 'Oops! Something went wrong';
  String get errorMessage => 'We couldn\'t load the app';
  String get retryButton => 'Try Again';
}

// ========================================
// Welcome Strings
// ========================================

class WelcomeStringsEn extends WelcomeStrings {
  const WelcomeStringsEn();

  String get title => AppStringsEn.appName;
  String get subtitle => 'Shared lists. One place.';
  String get group1Emoji => '🛒';
  String get group1Title => 'Shopping Lists';
  String get group1Question => '"What do we need to buy?"';
  String get group1Feature1 => 'Items ✅';
  String get group1Feature2 => 'Quantities 🔢';
  String get group2Emoji => '📦';
  String get group2Title => 'Digital Pantry';
  String get group2Question => '"What\'s missing at home?"';
  String get group2Feature1 => 'Stock 📊';
  String get group2Feature2 => 'Reminders ⏰';
  String get group3Emoji => '👨‍👩‍👧‍👦';
  String get group3Title => 'Household Sharing';
  String get group3Question => '"Who\'s in the group?"';
  String get group3Feature1 => 'Real-time 🔄';
  String get group3Feature2 => 'Sync ☁️';
  String get moreGroupsHint => 'Simple and easy - no complications';
  String get demoItem1 => 'Milk';
  String get demoItem2 => 'Bread';
  String get demoItem3 => 'Eggs';
  String get demoPantryHeader => '📦 Pantry';
  String get demoPantryItem1 => 'Milk';
  String get demoPantryItem2 => 'Eggs';
  String get demoPantryItem3 => 'Bread';
  String get demoFamilyHeader => '👨‍👩‍👧‍👦 Household';
  String get demoUser1 => 'Dad';
  String get demoUser2 => 'Mom';
  String get demoUser3 => 'Danny';
  String get statusOnline => 'Online';
  String get statusOffline => 'Offline';
  String get benefit1Title => 'Real-time Sharing';
  String get benefit1Subtitle => 'Everyone sees and updates - couple, household or work';
  String get benefit2Title => 'Products & Tasks Together';
  String get benefit2Subtitle => 'One list for everything you need - from groceries to tasks';
  String get benefit3Title => 'Smart Organized Pantry';
  String get benefit3Subtitle => 'Automatic suggestions for what\'s missing + shelf organization';
  String get startButton => 'Sign Up';
  String get loginButton => 'Log In';
  String get loginLink => 'Already have an account — Log In';
  String get authExplanation => 'To use the app you need to log in or sign up';
  String get registerButton => 'Sign Up';
  String get termsOfService => 'Terms of Service';
  String get privacyPolicy => 'Privacy Policy';
  String get logoLabel => '${AppStringsEn.appName} app logo';
}

// ========================================
// Auth Strings (Login/Register)
// ========================================

class AuthStringsEn extends AuthStrings {
  const AuthStringsEn();

  String get loginTitle => 'Log In';
  String get loginSubtitle => 'Nice to see you again 👋';
  String get loginButton => 'Log In';
  String get registerTitle => 'Sign Up';
  String get registerSubtitle => 'Create a new account to share and manage lists together ✨';
  String get registerButton => 'Sign Up';
  String get forgotPassword => 'Forgot password?';
  String get sendResetEmailButton => 'Send Link';
  String get resetEmailSent => 'Password reset email sent successfully!';
  String get emailNotVerified => 'Email not verified';
  String get verifyEmailMessage => 'Please verify your email address';
  String get sendVerificationEmailButton => 'Send Verification Email';
  String get verificationEmailSent => 'Verification email sent!';
  String get checkYourEmail => 'Check your inbox';
  String get updateProfile => 'Update Profile';
  String get updateDisplayName => 'Update Display Name';
  String get displayNameUpdated => 'Display name updated successfully!';
  String get updateEmail => 'Update Email';
  String get emailUpdated => 'Email updated successfully!';
  String get updatePassword => 'Update Password';
  String get passwordUpdated => 'Password updated successfully!';
  String get deleteAccount => 'Delete Account';
  String get deleteAccountWarning => 'This action is irreversible!';
  String get deleteAccountConfirm => 'Are you sure you want to delete your account?';
  String get accountDeleted => 'Account deleted successfully';
  String get emailLabel => 'Email';
  String get emailHint => 'example@email.com';
  String get passwordLabel => 'Password';
  String get passwordHint => '••••••••';
  String get confirmPasswordLabel => 'Confirm Password';
  String get confirmPasswordHint => '••••••••';
  String get nameLabel => 'Full Name';
  String get nameHint => 'John Doe';
  String get phoneLabel => 'Phone';
  String get phoneHint => '050-1234567';
  String get noAccount => 'Don\'t have an account?';
  String get registerNow => 'Sign up now';
  String get haveAccount => 'Already have an account?';
  String get or => 'or';
  String get orContinueWith => 'Or sign up quickly with';
  String get emailRequired => 'Required field';
  String get emailInvalid => 'Invalid email';
  String get passwordRequired => 'Required field';
  String get passwordTooShort => 'Password must be at least 6 characters';
  String get confirmPasswordRequired => 'Required field';
  String get passwordsDoNotMatch => 'Passwords don\'t match';
  String get nameRequired => 'Required field';
  String get nameTooShort => 'Name must be at least 2 characters';
  String get phoneRequired => 'Required field';
  String get phoneInvalid => 'Invalid phone number (05X-XXXXXXX)';
  String get errorWeakPassword => 'Password is too weak';
  String get errorEmailInUse => 'Email is already in use';
  String get errorInvalidEmail => 'Invalid email format';
  String get errorOperationNotAllowed => 'Operation not allowed';
  String get errorUserNotFound => 'User not found';
  String get errorWrongPassword => 'Wrong password';
  String get errorUserDisabled => 'User is disabled';
  String get errorInvalidCredential => 'Invalid credentials';
  String get errorTooManyRequests => 'Too many attempts. Try again later';
  String get errorRequiresRecentLogin => 'Re-login required to perform this action';
  String get errorNetworkRequestFailed => 'Network error. Check your internet connection';
  String get errorTimeout => 'Operation failed - try again';
  String get errorNoUserLoggedIn => 'No user logged in';
  String get socialLoginCancelled => 'Login cancelled';
  String get socialLoginError => 'Login error';
  String signUpError(String? message) => 'Registration error${message != null ? ": $message" : ""}';
  String signInError(String? message) => 'Login error${message != null ? ": $message" : ""}';
  String resetEmailError(String? message) => 'Error sending email${message != null ? ": $message" : ""}';
  String verificationEmailError(String? message) => 'Error sending verification email${message != null ? ": $message" : ""}';
  String updateDisplayNameError(String? message) => 'Error updating name${message != null ? ": $message" : ""}';
  String updateEmailError(String? message) => 'Error updating email${message != null ? ": $message" : ""}';
  String updatePasswordError(String? message) => 'Error updating password${message != null ? ": $message" : ""}';
  String deleteAccountError(String? message) => 'Error deleting account${message != null ? ": $message" : ""}';
  String reloadUserError(String? message) => 'Error reloading${message != null ? ": $message" : ""}';
  String get mustCompleteLogin => 'Please complete the login process';
  String get loginSuccess => 'Logged in successfully!';
  String get registerSuccess => 'Registered successfully!';
  String get loginSuccessRedirect => 'Logged in successfully! Redirecting...';
  String get orLoginWith => 'Or log in with';
  String get showPassword => 'Show password';
  String get hidePassword => 'Hide password';
  String get enterEmailFirst => 'Please enter your email address in the field above';
  String resetEmailSentTo(String email) => 'Password reset email sent to $email';
  String get resetEmailSendError => 'Error sending reset email';
  String get forgotPasswordSemanticLabel => 'Forgot password? Tap to receive a reset email';
  String get forgotPasswordSemanticHint => 'Sends a password reset link to the entered email';
  String socialLoginSemanticLabel(String provider) => 'Log in with $provider';
  String get registerSuccessRedirect => 'Registered successfully! Redirecting...';
  String get pendingInvitesDialogTitle => 'Pending Invitations!';
  String pendingInvitesDialogContent(int count) =>
      'You have $count pending group invitations.\n\nWould you like to go to the invitations screen?';
  String get pendingInvitesLater => 'Later';
  String get pendingInvitesView => 'View Invitations';
  String get phoneHelperText => 'Israeli mobile number - for group updates';
  String get nameFieldSemanticLabel => 'Full name field, required';
  String get emailFieldSemanticLabel => 'Email address field, required';
  String get passwordFieldSemanticLabel => 'Password field, at least 6 characters';
  String get confirmPasswordFieldSemanticLabel => 'Confirm password field, must match password';
  String get phoneFieldSemanticLabel => 'Israeli mobile phone field, required';
  String get loginLinkSemanticLabel => 'Have an account? Tap to go to login screen';
  String socialRegisterSemanticLabel(String provider) => 'Sign up or log in with $provider';
}

// ========================================
// Home Dashboard Strings
// ========================================

class HomeStringsEn extends HomeStrings {
  const HomeStringsEn();

  String timeBasedGreeting(String userName, int hour) {
    final String greeting;
    if (hour >= 5 && hour < 12)
      greeting = 'Good morning';
    else if (hour >= 12 && hour < 17)
      greeting = 'Good afternoon';
    else if (hour >= 17 && hour < 21)
      greeting = 'Good evening';
    else
      greeting = 'Good night';
    return '$greeting, $userName! 👋';
  }

  String get sortLabel => 'Sort:';
  String get sortByDate => 'Date updated';
  String get noActiveLists => 'No active lists right now';
  String get otherActiveLists => 'Other active lists';
  String get noOtherActiveLists => 'No other lists right now';
  String get allLists => 'All lists';
  String itemsCount(int count) => '$count items';
  String listDeleted(String listName) => 'List "$listName" deleted';
  String get undo => 'Undo';
  String createListError(String error) => 'Error creating list: $error';
  String get doubleTapToExit => 'Tap again to close the app';
}

// ========================================
// Price Comparison Strings
// ========================================

class PriceComparisonStringsEn extends PriceComparisonStrings {
  const PriceComparisonStringsEn();

  String get title => 'Price Comparison';
  String get searchHint => 'Search product...';
  String get searchButton => 'Search';
  String get clearButton => 'Clear';
  String get storeIcon => '🏪';
  String get errorTitle => 'Search error';
  String get retry => 'Try Again';
}

// ========================================
// Settings Strings
// ========================================

class SettingsStringsEn extends SettingsStrings {
  const SettingsStringsEn();

  String get title => 'Settings & Profile';
  String get editProfile => 'Edit';
  String get statsActiveLists => 'Active Lists';
  String get statsPantryItems => 'Pantry Items';
  String get householdName => 'Group Name';
  String get householdNameHint => 'Group Name';
  String get editHouseholdNameSave => 'Save';
  String get editHouseholdNameEdit => 'Edit Name';
  String get roleOwner => 'Owner';
  String get roleAdmin => 'Admin';
  String get roleEditor => 'Editor';
  String get roleViewer => 'Viewer';
  String get storesTitle => 'Favorite Stores';
  String get addStoreHint => 'Add store...';
  String get addStoreTooltip => 'Add Store';
  String get familySizeLabel => 'Group size (number of people)';
  String get weeklyRemindersLabel => 'Weekly Reminders';
  String get weeklyRemindersSubtitle => 'Get a reminder to plan shopping';
  String get notificationsSectionTitle => 'Notifications';
  String get notifyShoppingTitle => 'Shopping Activity';
  String get notifyShoppingSubtitle => 'When someone starts or finishes shopping';
  String get notifyGroupTitle => 'Group Changes';
  String get notifyGroupSubtitle => 'New member, invitation or departure';
  String get notifyRemindersTitle => 'Reminders';
  String get notifyRemindersSubtitle => 'Open list over 24 hours, weekly reminder';
  String get notifyListUpdatesTitle => 'List Updates';
  String get notifyListUpdatesSubtitle => 'When someone adds or removes items from a shared list';
  String get generalSettingsSectionTitle => 'General Settings';
  String get themeLabel => 'Theme';
  String get themeLight => 'Light';
  String get themeDark => 'Dark';
  String get themeSystem => 'System';
  String get householdManagementTitle => 'Household Management';
  String get householdMembersTitle => 'Household Members';
  String get householdMembersSubtitle => 'Add and remove members';
  String get householdInviteTitle => 'Invite Friends';
  String get householdInviteSubtitle => 'Send an invitation to join';
  String get householdComingSoon => 'Full management - coming soon!';
  String get inviteToHouseholdTitle => 'Invite to Household';
  String get inviteToHouseholdSubtitle => 'Send an invitation to join your household';
  String get inviteToHouseholdHint => 'Enter invitee\'s email';
  String get inviteToHouseholdSuccess => '✅ Invitation sent!';
  String get inviteToHouseholdAlreadyMember => 'User is already a member';
  String get inviteToHouseholdAlreadyPending => 'There\'s already a pending invitation';
  String get inviteToHouseholdButton => 'Send Invitation';
  String get householdJoinedSuccess => '🏠 Successfully joined the household!';
  String get myPantry => 'My Pantry';
  String get priceComparison => 'Price Comparison';
  String get updatePricesTitle => 'Update Prices from API';
  String get updatePricesSubtitle => 'Load updated prices from the network';
  String get updatingPrices => '💰 Updating prices from API...';
  String pricesUpdated(int withPrice, int total) => '✅ Updated $withPrice prices out of $total products!';
  String pricesUpdateError(String error) => '❌ Error updating prices: $error';
  String get logoutTitle => 'Log Out';
  String get logoutMessage => 'Are you sure you want to log out?';
  String get logoutCancel => 'Cancel';
  String get logoutConfirm => 'Log Out';
  String get logoutSubtitle => 'Sign out of account';
  String get deleteAccountTitle => 'Delete Account';
  String get deleteAccountSubtitle => 'Permanently delete all data';
  String get deleteAccountWarning =>
      'This action will permanently delete:\n• All lists you created\n• Shopping history\n• Your pantry\n• All personal data\n\nData cannot be recovered!';
  String get deleteAccountConfirmLabel => 'Type "delete my account" to confirm:';
  String get deleteAccountConfirmText => 'delete my account';
  String get deleteAccountButton => 'Delete Account Permanently';
  String get deleteAccountSuccess => 'Account deleted successfully';
  String deleteAccountError(String error) => 'Error deleting account: $error';
  String get deleteAccountRequiresReauth => 'Re-login required before deleting account';
  String get loading => 'Loading...';
  String loadError(String error) => 'Error loading settings: $error';
  String saveError(String error) => 'Error saving settings: $error';

  @override String get editProfileTitle => 'Edit Profile';
  @override String get chooseAvatar => 'Choose Avatar:';
  @override String get displayNameLabel => 'Display Name:';
  @override String get displayNameHint => 'Enter your name';
  @override String get enterNameError => 'Please enter a name';
  @override String get profileUpdated => 'Profile updated successfully';
  @override String profileUpdateError(String error) => 'Error updating: $error';

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
  @override String get showOnboardingSubtitle => 'View the app tutorial again';
  @override String get about => 'About';
  @override String get aboutDescription => 'Smart app for managing shopping and home pantry';
  @override String get termsOfService => 'Terms of Service';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get debugResetOnboarding => 'Deletes seenOnboarding - returns to Welcome';
}

// ========================================
// Household Strings
// ========================================

class HouseholdStringsEn extends HouseholdStrings {
  const HouseholdStringsEn();

  String get typeFamily => 'Home';
  String get typeOther => 'Other';
  String get typeExtendedFamily => 'Extended Family';
  String get descFamily => 'Manage shared shopping and needs for the household';
  String get descExtendedFamily => 'Plan shopping and events for the extended family';

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

  String get title => 'List Templates';
  String get subtitle => 'Create ready-made templates for reuse';
  String get filterAll => 'All';
  String get filterShared => 'Shared';
  String get emptyMyTemplatesTitle => 'No personal templates';
  String get emptyMyTemplatesMessage => 'Create a template to save time when creating recurring lists';
  String get emptySharedTemplatesTitle => 'No shared templates';
  String get emptySharedTemplatesMessage => 'Group members can create shared templates';
  String itemsCount(int count) => '$count items';
  String get formatShared => 'Shared';
  String get createButton => 'New Template';
  String get deleteButton => 'Delete';
  String get useTemplateButton => 'Use Template';
  String get nameLabel => 'Template Name';
  String get nameHint => 'e.g., Weekly Shopping';
  String get nameRequired => 'Please enter a template name';
  String get formatSharedDesc => 'Visible to the whole group';
  String get saveButton => 'Save Template';
  String get cancelButton => 'Cancel';
  String templateNameExists(String name) => 'A template named "$name" already exists';
  String templateCreated(String name) => 'Template "$name" created successfully!';
  String templateUpdated(String name) => 'Template "$name" updated!';
  String templateDeleted(String name) => 'Template "$name" deleted';
  String get undo => 'Undo';
  String updateError(String error) => 'Error updating: $error';
  String deleteError(String error) => 'Error deleting: $error';
  String get useTemplateTitle => 'Choose Template';
  String get useTemplateHint => 'Choose a template to auto-fill the list';
  String get useTemplateEmpty => 'No templates available';
  String get useTemplateSelect => 'Select';
}

// ========================================
// Create List Dialog Strings
// ========================================

class CreateListDialogStringsEn extends CreateListDialogStrings {
  const CreateListDialogStringsEn();

  String get title => 'Create New List';
  String get useTemplateButton => '📋 Use Template';
  String get useTemplateTooltip => 'Choose a ready template';
  String get selectTemplateTitle => 'Choose Template';
  String get selectTemplateHint => 'Choose a template to auto-fill the list';
  String get noTemplatesAvailable => 'No templates available';
  String get noTemplatesMessage => 'Create your first template in the templates screen';
  String templateSelected(String name) => 'Template "$name" selected';
  String templateApplied(String name, int itemsCount) => '✨ Template "$name" applied! Added $itemsCount items';
  String get nameLabel => 'List Name';
  String get nameHint => 'e.g., Weekly Shopping';
  String get nameRequired => 'Please enter a list name';
  String nameAlreadyExists(String name) => 'A list named "$name" already exists';
  String get typeLabel => 'List Type';
  String get budgetLabel => 'Budget (optional)';
  String get budgetHint => '₪500';
  String get budgetInvalid => 'Please enter a valid number';
  String get budgetMustBePositive => 'Budget must be greater than 0';
  String get clearBudgetTooltip => 'Clear budget';
  String get eventDateLabel => 'Event Date (optional)';
  String get eventDateHint => 'e.g., Birthday, Gathering';
  String get noDate => 'No date';
  String get selectDate => 'Select event date';
  String get clearDateTooltip => 'Clear date';
  String get cancelButton => 'Cancel';
  String get cancelTooltip => 'Cancel list creation';
  String get createButton => 'Create List';
  String get creating => 'Creating...';
  String get loadingTemplates => 'Loading templates...';
  String get loadingTemplatesError => 'Error loading templates';
  String listCreated(String name) => 'List "$name" created successfully! 🎉';
  String listCreatedWithBudget(String name, double budget) =>
      'List "$name" created with budget ₪${budget.toStringAsFixed(0)}';
  String get validationFailed => 'Please fix the errors in the form';
  String get userNotLoggedIn => 'User not logged in';
  String createListError(String error) => 'Error creating list';
  String get createListErrorGeneric => 'An error occurred creating the list. Try again.';
  String get networkError => 'Network error. Check your internet connection';
  String get removeTemplateTooltip => 'Remove template';
  String get visibilityLabel => 'Who will see the list?';
  String get visibilityPrivate => '🔒 Private';
  String get visibilityHousehold => '👨‍👩‍👧 Shared with household';
  String get visibilityShared => '👥 Share';
  String get visibilityPrivateDesc => 'Only you will see this list';
  String get visibilityHouseholdDesc => 'All household members can view and edit';
  String get visibilitySharedDesc => 'Share with specific people (no access to your pantry)';
  String get eventModeLabel => 'How will you manage the list?';
  String get eventModeWhoBrings => 'Who Brings What';
  String get eventModeWhoBringsDesc => 'Each participant volunteers to bring items';
  String get eventModeShopping => 'Regular Shopping';
  String get eventModeShoppingDesc => 'One person buys everything on the list';
  String get eventModeTasks => 'Personal Tasks';
  String get eventModeTasksDesc => 'Simple checklist just for me';
  String get recommended => 'Recommended';
  String get selectContactsButton => 'Select people to share with';
  String get addMoreContactsButton => 'Add more people';
  String get pendingInviteNote => 'Unregistered users will receive a pending invitation';
}

// ========================================
// Manage Users Strings
// ========================================

class ManageUsersStringsEn extends ManageUsersStrings {
  const ManageUsersStringsEn();

  String get title => 'Manage Users';
  String get me => 'Me';
  String get you => 'You';
  String userShortId(String shortId) => 'User #$shortId';
  String get defaultUserName => 'User';
  String get errorUserNotLoggedIn => 'Error: User not logged in';
  String get errorNoPermissionRemove => 'You don\'t have permission to remove users';
  String get errorNoPermissionEditRole => 'You don\'t have permission to change roles';
  String get errorNoHousehold => 'Error: User not assigned to a household';
  String errorRemovingUser(String error) => 'Error removing user: $error';
  String errorUpdatingRole(String error) => 'Error updating role: $error';
  String get removeUserTitle => 'Remove User';
  String removeUserConfirmation(String name) => 'Are you sure you want to remove $name?';
  String get removeButton => 'Remove';
  String get userRemovedSuccess => 'User removed successfully';
  String get editRoleTitle => 'Edit Role';
  String selectNewRole(String name) => 'Select a new role for $name:';
  String roleUpdatedSuccess(String roleName) => 'Role updated to $roleName';
  String get cancel => 'Cancel';
  String get inviteUser => 'Invite User';
  String get editRole => 'Edit Role';
  String get removeUser => 'Remove User';
  String get loadingUsers => 'Loading users...';
  String get retryButton => 'Try Again 🔄';
  String get noSharedUsers => 'No shared users';
  String get inviteUsersHint => 'Tap + to invite users';
  String get onlyOwnerCanInvite => 'Only the list owner can invite users';
}

// ========================================
// Inventory Strings
// ========================================

class InventoryStringsEn extends InventoryStrings {
  const InventoryStringsEn();

  String get addDialogTitle => 'Add Item';
  String get editDialogTitle => 'Edit Item';
  String get addButton => 'Add';
  String get saveButton => 'Save';
  String get productNameLabel => 'Item Name';
  String get productNameHint => 'e.g., Milk';
  String get productNameRequired => 'Please enter an item name';
  String get categoryLabel => 'Category';
  String get quantityLabel => 'Quantity';
  String get unitLabel => 'Unit';
  String get unitHint => 'pcs, kg, liters';
  String get locationLabel => 'Location';
  String get addLocationButton => 'Add';
  String get addLocationTitle => 'Add New Location';
  String get locationNameLabel => 'Location Name';
  String get locationNameHint => 'e.g., "Small Fridge"';
  String get selectEmojiLabel => 'Choose an emoji:';
  String get locationAdded => 'New location added successfully! 📍';
  String get locationExists => 'This location already exists';
  String get locationNameRequired => 'Please enter a location name';
  String get filterLabel => 'Filter Pantry';
  String get filterByCategory => 'Filter by Category';
  String get itemAdded => 'Item added successfully';
  String get itemUpdated => 'Item updated successfully';
  String get addError => 'Error adding item';
  String get updateError => 'Error updating item';
  String get addFromCatalogTitle => 'Add from Catalog';
  String get searchProductsHint => 'Search product...';
  String get loadingProducts => 'Loading products...';
  String get noProductsFound => 'No products found';
  String get noProductsAvailable => 'No products available';
  String productAddedSuccess(String name) => '$name added to pantry!';
  String get stockOutOfStock => 'Out of stock! Need to buy';
  String stockOnlyOneLeft(String unit) => 'Only 1 $unit left';
  String stockOnlyFewLeft(int count, String unit) => 'Only $count $unit left';
  String get unknownSuggestionWarning => 'Unknown suggestion type - app update required';
  String get unknownSuggestionCannotDelete => 'Cannot delete unknown suggestion';
  String get unknownSuggestionUpdateApp => 'Update App';
  @override String get defaultUnit => 'pcs';
  @override String get statisticsLabel => 'Statistics';
  @override String get popularLabel => 'Popular';
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

  String get expiryAlertTitleExpired => 'Expired!';
  String get expiryAlertTitleExpiringSoon => 'Expiring Soon';
  String expiryAlertSubtitle(int expiredCount, int expiringSoonCount) {
    final parts = <String>[];
    if (expiredCount > 0) parts.add('$expiredCount expired');
    if (expiringSoonCount > 0) parts.add('$expiringSoonCount expiring soon');
    return parts.join(' | ');
  }

  String get expiryAlertGoToPantry => 'Go to Pantry';
  String get expiryAlertDismissToday => 'Don\'t show again today';
  String expiryAlertMoreItems(int count) => 'Show $count more items...';
  String expiryAlertSemanticLabel(int expiredCount, int expiringSoonCount, bool isExpiredMode) => isExpiredMode
      ? 'Expiry alert: $expiredCount expired items, $expiringSoonCount about to expire'
      : 'Expiry alert: $expiringSoonCount items about to expire soon';
  String get expiryAlertCloseTooltip => 'Close';
  String get expiryAlertGoToPantryTooltip => 'Go to pantry to view all items';
  String get expiryAlertDismissTodayTooltip => 'This alert won\'t show again today';
  String get expiryExpiredToday => 'Expired today';
  String get expiryExpiredYesterday => 'Expired yesterday';
  String expiryExpiredDaysAgo(int days) => 'Expired $days days ago';
  String get expiryExpiresToday => 'Expires today!';
  String get expiryExpiresTomorrow => 'Expires tomorrow';
  String expiryExpiresInDays(int days) => 'Expires in $days days';
  String get settingsTitle => 'Pantry Settings';
  String get settingsSemanticLabel => 'Pantry settings dialog';
  String get pantryModePersonal => 'Personal pantry - yours only';
  String get pantryModeGroup => 'Connected to shared group pantry';
  String get alertsSectionTitle => 'Alerts';
  String get settingsLowStockAlertTitle => 'Low Stock Alert';
  String get settingsLowStockAlertSubtitle => 'Get alerted when an item reaches minimum';
  String get settingsExpiryAlertTitle => 'Expiry Alert';
  String get settingsExpiryAlertSubtitle => 'Get alerted about items about to expire';
  String get settingsExpiryAlertDaysPrefix => 'Alert ';
  String get settingsExpiryAlertDaysSuffix => ' days before expiry';
  String get displaySectionTitle => 'Display';
  String get showExpiredFirstTitle => 'Show expired first';
  String get showExpiredFirstSubtitle => 'Expired items will appear at the top of the list';
  String get lowStockAlertTitle => 'Low Stock';
  String lowStockAlertSubtitle(int count) => '$count products are running low';
  String get lowStockAlertAddToList => 'Add to List';
  String get lowStockAlertGoToPantry => 'Go to Pantry';
  String get lowStockAlertDismissToday => 'Don\'t show again today';
  String lowStockAlertMoreItems(int count) => 'and $count more items...';
  String lowStockAlertSemanticLabel(int count) => 'Low stock alert: $count products are running low';
  String get lowStockAlertCloseTooltip => 'Close';
  String get lowStockAlertAddToListTooltip => 'Add all products to shopping list';
  String get lowStockAlertGoToPantryTooltip => 'Go to pantry to view all items';
  String get lowStockAlertDismissTodayTooltip => 'This alert won\'t show again today';
  String get locationMainPantry => 'Pantry';
  String get locationMainPantryDesc => 'Main pantry - dry goods';
  String get locationRefrigerator => 'Refrigerator';
  String get locationRefrigeratorDesc => 'Refrigerator - fresh products';
  String get locationFreezer => 'Freezer';
  String get locationFreezerDesc => 'Freezer - frozen products';
  String get locationOther => 'Other';
  String get locationOtherDesc => 'Other location';
  String get locationUnknown => 'Unknown';
  String get locationUnknownDesc => 'Unknown location';
  String maxItemsReached(int max) => 'You\'ve reached the maximum of $max pantry items';
  String pantryHealthStatus(double healthPercent) {
    if (healthPercent >= 80) return 'Your pantry looks great! 💚';
    if (healthPercent >= 50) return 'Pantry is decent, might want to restock a few things';
    if (healthPercent >= 25) return 'Time to visit the store soon 🛒';
    return 'Pantry is almost empty — time to shop! 🚨';
  }

  String get pantryHealthLabel => 'Pantry Health';
  String pantryHealthPercent(int percent) => '$percent% properly stocked';
  String get pantryFullyStocked => 'Everything in stock — no worries!';
  String pantryLowItems(int count) => count == 1 ? '1 product is running low' : '$count products are running low';

  @override String get quantityMustBePositive => 'Quantity must be greater than zero';
  @override String get notesHint => 'Additional notes (optional)';
  @override String get permanentProduct => 'Permanent product';
  @override String addCustomProduct(String query) => 'Add "$query"';
}

// ========================================
// Shopping List Details
// ========================================

class ShoppingListDetailsStringsEn extends ShoppingListDetailsStrings {
  const ShoppingListDetailsStringsEn();

  String get addProductTitle => 'Add Product';
  String get editProductTitle => 'Edit Product';
  String get productNameLabel => 'Product Name';
  String get brandLabel => 'Brand (optional)';
  String get categoryLabel => 'Category';
  String get selectCategory => 'Select Category';
  String get quantityLabel => 'Quantity';
  String get priceLabel => 'Price per unit';
  String get addTaskTitle => 'Add Task';
  String get editTaskTitle => 'Edit Task';
  String get taskNameLabel => 'Task Name';
  String get notesLabel => 'Notes (optional)';
  String get dueDateLabel => 'Select due date (optional)';
  String dueDateSelected(String date) => 'Due date: $date';
  String get priorityLabel => 'Priority';
  String get priorityLow => '🟢 Low';
  String get priorityMedium => '🟡 Medium';
  String get priorityHigh => '🔴 High';
  String get productNameEmpty => 'Product name cannot be empty';
  String get quantityInvalid => 'Invalid quantity (1-9999)';
  String get priceInvalid => 'Invalid price (must be a positive number)';
  String get taskNameEmpty => 'Task name cannot be empty';
  String get searchHint => 'Search item...';
  String get sortPriceDesc => 'Price (high→low)';
  String itemsCount(int count) => '$count items';
  String get categoryAll => 'All';
  String get categoryDairy => 'Dairy & Eggs';
  String get categoryOther => 'Other';
  String get addProductButton => 'Add Product';
  String get addTaskButton => 'Add Task';
  String get shareListTooltip => 'Share list';
  @override
  String get pendingRequestsTooltip => 'Pending requests';
  String get addFromCatalogTooltip => 'Add from catalog';
  String get deleteTitle => 'Delete Product';
  String deleteMessage(String name) => 'Delete "$name"?';
  String itemDeleted(String name) => 'Product "$name" deleted';
  String get totalLabel => 'Total:';
  String get emptyListTitle => 'List is empty';
  @override
  String get emptyListSubtitle => 'Search for products above or add from catalog';
  String get populateFromCatalog => 'Populate from catalog';
  @override
  String get quickSearchHint => 'Search product to add...';
  @override
  String get addFreeText => 'Add as free text';
  @override
  String categoriesCount(int count) => '$count categories';
  String get noSearchResultsTitle => 'No items found';
  String get clearSearchButton => 'Clear search';
  String get loadingError => 'Error loading data';
  String get errorTitle => 'Oops! Something went wrong';
  String errorMessage(String? error) => error ?? 'An error occurred loading data';
}

// ========================================
// Select List Dialog
// ========================================

class SelectListStringsEn extends SelectListStrings {
  const SelectListStringsEn();

  String get defaultTitle => 'Select List';
  String addingItem(String itemName) => 'Adding: $itemName';
  String get noActiveLists => 'No active lists';
  String get createNewToAddItems => 'Create a new list to add items';
  String get createNewButton => 'Create New List';
  String get cancelButton => 'Cancel';
  String get closeTooltip => 'Close';
  String get createNewTooltip => 'Create a new shopping list';
  String get cancelTooltip => 'Cancel list selection';
  String itemsCount(int count) => '$count items';
  String get semanticLabel => 'List selection';
  String semanticLabelWithItem(String itemName) => 'Select list to add $itemName';
  String listTileSemanticLabel(String listName, int itemCount, int checkedCount) =>
      '$listName, $itemCount items${checkedCount > 0 ? ', $checkedCount checked' : ''}';
}

// ========================================
// Recurring Product Dialog
// ========================================

class RecurringStringsEn extends RecurringStrings {
  const RecurringStringsEn();

  String get title => 'Popular Product!';
  String get subtitle => 'Looks like you buy this often';
  String get statPurchases => 'Purchases';
  String get statLastPurchase => 'Last purchase';
  String formatLastPurchase(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    return '${(diff / 30).floor()} months ago';
  }

  String get explanation => 'A recurring product will be automatically added to new shopping lists';
  String get confirmButton => 'Make Recurring';
  String get dismissButton => 'No, thanks';
  String get askLaterButton => 'Ask me later';
  String get closeTooltip => 'Close';
  String get confirmTooltip => 'Make this a recurring product';
  String get dismissTooltip => 'Don\'t suggest this product as recurring';
  String get askLaterTooltip => 'Remind me next time';
  String semanticLabel(String productName) => 'Suggestion to make $productName a recurring product';
}

// ========================================
// Receipt Details
// ========================================

class ReceiptDetailsStringsEn extends ReceiptDetailsStrings {
  const ReceiptDetailsStringsEn();

  String get totalLabel => 'Total';
  String get virtualTag => 'Virtual';
  String get noItemsMessage => 'No items in receipt';
}

// ========================================
// Shopping History
// ========================================

class ShoppingHistoryStringsEn extends ShoppingHistoryStrings {
  const ShoppingHistoryStringsEn();

  String get title => 'Shopping History';
  String get sortTooltip => 'Sort';
  String get sortByDate => 'By date';
  String get sortByList => 'By list type';
  String get sortByAmount => 'By amount';
  String get filterThisMonth => 'This Month';
  String get filterThreeMonths => '3 Months';
  String get filterAll => 'All';
  String get shoppingsLabel => 'Shopping trips';
  String get totalLabel => 'Total';
  String get averageLabel => 'Average';
  String get totalItemsLabel => 'Items';
  String itemsCount(int count) => '$count items';
  String get virtualTag => 'Virtual';
  String get noResults => 'No shopping in this period';
  String get emptyTitle => "You haven't finished shopping yet";
  String get emptySubtitle => 'Completed lists will appear here so you can\ntrack your shopping! 🛒';
  String get defaultError => 'Error loading';
  String get retryButton => 'Try Again';
}

// ========================================
// Active Shopper Banner
// ========================================

class ActiveShopperBannerStringsEn extends ActiveShopperBannerStrings {
  const ActiveShopperBannerStringsEn();

  String get myActiveTitle => 'You have active shopping';
  String myActiveSubtitle(String listName, int remaining) => '"$listName" - $remaining items remaining';
  String get continueButton => 'Continue';
  String othersActiveTitle(String shopperName) => '$shopperName is shopping now';
  String othersActiveTitleMultiple(int count) => '$count shoppers active now';
  String othersActiveSingle(String listName) => 'Shopping from "$listName"';
  String othersActiveMultiple(int count, String listName) => '$count people shopping from "$listName"';
  String get joinButton => 'Join';
  String get viewListTooltip => 'Live view';
  String shopperJoined(String name) => '$name joined the shopping';
  String shopperLeft(String name) => '$name left the shopping';
  String shopperUpdatingPantry(String name) => '$name is updating the pantry';
  String shopperCheckedItem(String name, String item) => '$name checked "$item" as bought';
  String activeShoppersCount(int count) => '$count active shoppers now';
  String shopperAvatarLabel(String name, bool isStarter) =>
      isStarter ? '$name (started the shopping)' : '$name is shopping now';
  String get moreShoppersLabel => 'More active shoppers';
}

// ========================================
// Suggestions Today Card
// ========================================

class SuggestionsTodayCardStringsEn extends SuggestionsTodayCardStrings {
  const SuggestionsTodayCardStringsEn();

  String get title => 'Pantry Suggestions';
  String get loading => 'Loading suggestions...';
  String itemCount(int count) => '$count items';
  String get urgencyCritical => 'Out of stock!';
  String get urgencyHigh => 'Almost out';
  String get urgencyMedium => 'Running low';
  String get urgencyLow => 'Recommended';
  String inStock(int stock, String unit) => 'In stock: $stock $unit';
  String get addButton => 'Add';
  String get noActiveLists => 'No active lists - create a new list';
  @override
  String get addedToList => 'Added to list';
  String addedToListName(String productName) => 'Added "$productName" to list';
  String dismissedForWeek(String productName) => 'Dismissed "$productName" for a week';
  @override String suggestionError(String error) => 'Error: $error';
}

// ========================================
// Last Chance Banner
// ========================================

class LastChanceBannerStringsEn extends LastChanceBannerStrings {
  const LastChanceBannerStringsEn();

  String get title => 'Wait, here\'s something you usually need...';
  String semanticsLabel(String productName, int stock) =>
      'Smart suggestion: $productName is running low in your pantry. $stock units remaining. Double tap to add to list.';
  String stockText(int stock) => 'Only $stock left in pantry';
  String addTooltip(String productName) => 'Add "$productName" to shopping list';
  String get addButton => 'Add to list';
  String get nextTooltip => 'Go to next suggestion';
  String get nextButton => 'Next';
  String get skipSessionTooltip => 'Skip — we\'ll remind you next time';
  String get skipSessionButton => 'Not this time';
  String addedSuccess(String productName) => 'Added "$productName" to list';
  String get addError => 'Error adding item';
  String get genericError => 'An error occurred, try again';
  String get skippedForSession => 'Skipped for now — we\'ll remind you next time';
}

// ========================================
// Pending Invites Screen
// ========================================

class PendingInvitesScreenStringsEn extends PendingInvitesScreenStrings {
  const PendingInvitesScreenStringsEn();

  String get title => 'Pending Invitations';
  String get loading => 'Loading invitations...';
  String get loadError => 'Error loading invitations';
  String get retryButton => 'Try Again';
  String get emptyTitle => 'No pending invitations';
  String get emptySubtitle => 'When someone invites you to a list,\nthe invitation will appear here';
  String get pullToRefresh => '↓ Pull to refresh';
  String get listFallback => 'List';
  String get userFallback => 'User';
  String inviteToList(String listName) => 'Invitation to list "$listName"';
  String inviterMessage(String inviterName) => '$inviterName invites you to join';
  String get roleLabel => 'Role: ';
  String get acceptButton => 'Join';
  String get declineButton => 'Decline';
  String acceptSuccess(String listName) => 'Joined list "$listName"';
  String acceptError(String error) => 'Error accepting invitation: $error';
  String get declineDialogTitle => 'Decline Invitation';
  String declineDialogMessage(String listName) => 'Decline invitation to list "$listName"?';
  String get cancelButton => 'Cancel';
  String get declineConfirmButton => 'Decline';
  String get declineSuccess => 'Invitation declined';
  String declineError(String error) => 'Error declining invitation: $error';

  @override String pendingRequestsLabel(int count) => 'Pending requests, $count requests';
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

  String get title => 'Group Invitation';
  String moreCount(int count) => '+$count';
  String inviteMessage(String inviterName, String groupName) => '$inviterName invited you to "$groupName"';
  String get acceptButton => 'Accept';
  String get rejectButton => 'Decline';
  String get rejectDialogTitle => 'Decline Invitation';
  String get cancelButton => 'Cancel';
  String acceptSuccess(String groupName) => 'Joined group "$groupName"';
  String get acceptError => 'Error accepting invitation';
}

// ========================================
// User Sharing System
// ========================================

class SharingStringsEn extends SharingStrings {
  const SharingStringsEn();

  String get roleOwner => 'Owner';
  String get roleAdmin => 'Admin';
  String get roleEditor => 'Editor';
  String get roleViewer => 'Viewer';
  String get roleOwnerDesc => 'Full access + delete list + manage users';
  String get roleAdminDesc => 'Full access + manage users (no delete)';
  String get roleEditorDesc => 'Read + add items via requests (requires approval)';
  String get roleViewerDesc => 'Read only (cannot edit anything)';
  String get inviteTitle => 'Invite Users';
  String get inviteSubtitle => 'Invite people to share the list';
  String get emailLabel => 'Email';
  String get emailHint => 'example@email.com';
  String get emailRequired => 'Please enter an email address';
  String get emailInvalid => 'Invalid email';
  String get selectRoleLabel => 'Select Role';
  String get inviteButton => 'Send Invitation';
  String get inviting => 'Sending...';
  String get cancelButton => 'Cancel';
  String inviteSent(String email) => 'Invitation sent to $email 📧';
  String inviteResent(String email) => 'Invitation resent to $email';
  String get userNotFound => 'User not found in the system';
  String get cannotInviteSelf => 'You cannot invite yourself';
  String inviteError(String error) => 'Error sending invitation: $error';
  String get inviteUserButton => 'Invite User';
  String get changeRoleTooltip => 'Change role';
  String get resendInviteTooltip => 'Resend invitation';
  String get changeRoleTitle => 'Change Role';
  String changeRoleMessage(String userName) => 'Select a new role for $userName:';
  String get changeRoleButton => 'Change';
  String roleChanged(String userName, String newRole) => '$userName updated to $newRole';
  String changeRoleError(String error) => 'Error changing role: $error';
  String get removeUserTitle => 'Remove User';
  String get removeButton => 'Remove';
  String userRemoved(String userName) => '$userName removed from list';
  String get savedContactsTitle => 'Saved Contacts';
  String get savedContactsSubtitle => 'Choose from contacts you\'ve invited before';
  String showMoreContacts(int count) => 'Show $count more contacts';
  String get orEnterNewEmail => '── or enter a new email ──';
  String get contactSelectedEmailDisabled => 'Contact selected - email won\'t be used';
  String get alreadySharedBadge => 'Already shared';
  String inviteConfirmation(String recipient, String role, String listName) =>
      'Invitation will be sent to $recipient as $role in list "$listName"';
  String inviteSentPending(String name) => 'Invitation sent to $name - pending approval';
  String inviteSentUnregistered(String name) => 'Invitation sent to $name - they\'ll see it when they register';
  String get householdNameDialogTitle => 'What should we call your group?';
  String get householdNameDialogHint => 'e.g., The Smith House';
  String get householdNameDialogSkip => 'Skip';
  String get cannotChangeOwnRole => 'You cannot change your own role';
  String get noPermissionInvite => 'Only the owner can invite users';
  String get pendingRequestsTitle => 'Pending Requests';
  String get noPermissionViewRequests => 'Only owners/admins can view requests';
  String get noPendingRequests => 'No pending requests';
  String get noPendingRequestsSubtitle => 'Requests from editors will appear here for approval';
  String get requestTypeAdd => 'Add';
  String get requestTypeEdit => 'Edit';
  String get requestTypeDelete => 'Delete';
  String get requestTypeInvite => 'Invite';
  String get requestTypeUnknown => 'Unknown';
  String get unknownRequestWarning => 'Unknown request type - app update required';
  String get viewDetailsButton => 'Details';
  String get approveButton => 'Approve ✅';
  String get rejectButton => 'Reject ❌';
  String get backButton => 'Back';
  String get unknownUserFallback => 'Unknown user';
  String get unknownItemFallback => 'Unknown item';
  String get editItemFallback => 'Edit item';
  String get deleteItemFallback => 'Delete item';
  String get unknownRequestFallback => 'Unknown request';
  String get requestDetailsTitle => 'Request Details';
  String get quantityLabel => 'Quantity';
  String get categoryLabel => 'Category';
  String get priceLabel => 'Price';
  String get notesLabel => 'Notes';
  String requestApproved(String itemName) => '✅ Request to add "$itemName" approved';
  String get requestApprovedSuccess => 'Request approved successfully';
  String get requestApprovedError => 'Error approving request';
  String requestRejected(String itemName) => '❌ Request to add "$itemName" rejected';
  String get requestRejectedSuccess => 'Request rejected';
  String get requestRejectedError => 'Error rejecting request';
  String get rejectDialogTitle => 'Reject Request';
  String get rejectDialogMessage => 'Why reject the request? (optional)';
  String get rejectReasonHint => 'Rejection reason...';
  String get noPermissionTitle => 'No Permission';
  String get onlyOwnerCanChangePermissions => 'Only the owner can change permissions';
  String get mustBeOwnerOrAdmin => 'Must be an owner or admin to perform this action';
  String get requestCreated => 'Request sent for owner/admin approval';
  String get requestWaitingApproval => 'Item will wait for approval before appearing in the list';
  String get notificationInviteTitle => 'Shared list invitation';
  String notificationInviteBody(String listName, String inviterName) => '$inviterName invited you to list "$listName"';
  String get notificationRequestApprovedTitle => 'Request approved';
  String notificationRequestApprovedBody(String itemName, String listName) =>
      'Your request to add "$itemName" to "$listName" was approved ✅';
  String get notificationRequestRejectedTitle => 'Request rejected';
  String notificationRequestRejectedBody(String itemName, String listName) =>
      'Your request to add "$itemName" to "$listName" was rejected ❌';
  String get notificationNewRequestTitle => 'New request';
  String notificationNewRequestBody(String requesterName, String itemName) =>
      '$requesterName requested to add "$itemName" to the list';
  String get notificationRoleChangedTitle => 'Your role was changed';
  String notificationRoleChangedBody(String newRole, String listName) => 'Your role in "$listName" changed to $newRole';
  String get notificationRemovedTitle => 'Removed from list';
  String notificationRemovedBody(String listName) => 'You were removed from list "$listName"';
  String get sharedListBadge => 'Shared';
  String sharedWith(int count) => 'Shared with $count people';
  String get youAreAdmin => 'You\'re an admin';
  String get loadingUsers => 'Loading users...';
  String get loadingError => 'Error loading data';
  String get retryButton => 'Try Again';
  String maxGroupsReached(int max) => 'You\'ve reached the maximum of $max groups';
  String groupsNearLimit(int current, int max) => 'You have $current of $max groups';
}

// ========================================
// Home Dashboard Screen
// ========================================

class HomeDashboardStringsEn extends HomeDashboardStrings {
  const HomeDashboardStringsEn();

  String get newListButton => 'New List';
  String get errorTitle => 'Error loading data';
  String get retryButton => 'Try Again';
  String greeting(String? userName) => (userName?.trim().isNotEmpty ?? false) ? 'Hello, $userName!' : 'Hello!';
  String timeBasedGreeting(String? userName, int hour) {
    final String greet;
    if (hour >= 5 && hour < 12)
      greet = 'Good morning';
    else if (hour >= 12 && hour < 17)
      greet = 'Good afternoon';
    else if (hour >= 17 && hour < 21)
      greet = 'Good evening';
    else
      greet = 'Good night';
    return (userName?.trim().isNotEmpty ?? false) ? '$greet, $userName!' : '$greet!';
  }

  String get personalFamily => 'My Home';
  String get sharedFamily => 'Shared Home';
  String get familyOf => 'Home of ';
  String get activeListsTitle => 'Active Lists';
  String get noActiveLists => 'No active lists';
  String get createListHint => 'Tap here to create a new list';
  String get emptyList => 'Empty list';
  String get completed => 'Completed! ✓';
  String remainingItems(int count) => '$count items remaining';
  String itemsCount(int count) => '$count items';
  String get historyTitle => 'History';
  String get seeAll => 'See all';
  String get today => 'Today';
  String get yesterday => 'Yesterday';
  String daysAgo(int days) => '$days days ago';
  String dateFormat(int day, int month, int year) => '$month/$day/$year';
}

// ========================================
// Notifications Center Screen
// ========================================

class NotificationsCenterStringsEn extends NotificationsCenterStrings {
  const NotificationsCenterStringsEn();

  String get title => 'Notifications';
  String get markAllAsRead => 'Mark all as read';
  String get userNotLoggedIn => 'User not logged in';
  String get loadingError => 'Error loading notifications';
  String get retryButton => 'Try Again';
  String get emptyTitle => 'No notifications';
  String get emptySubtitle => 'When you receive new notifications, they\'ll appear here';
  String get allMarkedAsRead => 'All notifications marked as read';
}

// ========================================
// Pantry Screen
// ========================================

class PantryStringsEn extends PantryStrings {
  const PantryStringsEn();

  String get screenLabel => 'My Pantry screen';
  String get addItemLabel => 'Add product to pantry';
  String quantityLabel(int quantity, bool isLowStock) =>
      '$quantity units${isLowStock ? ', low stock' : ''}, tap to update';
  String get pantryPrefix => 'Pantry ';
  String get addItemTooltip => 'Add product';
  String get loadingText => 'Loading...';
  String get loadingErrorTitle => 'Error loading pantry';
  String get loadingErrorDefault => 'Try again later';
  String get retryButton => 'Try Again';
  String get noItemsFound => 'No items found';
  String get clearFilters => 'Clear filters';
  String get noStarterItemsFound => 'No starter items found';
  String starterItemsAdded(int count) => 'Added $count starter items to pantry';
  String get starterItemsError => 'Error adding starter items';
  String get suggestionsTitle => 'Good to have at home';
  String get hideSuggestions => 'Hide';
  String itemDeleted(String name) => '$name deleted';
  String get deleteItemError => 'Error deleting item';
  String get updateQuantityError => 'Error updating quantity';
  String get searchHint => 'Search pantry...';
  String get clearSearchTooltip => 'Clear search';
  String get allLocations => 'All';
  String get swipeDelete => 'Delete';
  String get deleteDialogTitle => 'Delete Item';
  String deleteDialogContent(String name) => 'Delete "$name"?';
  String get updateQuantityTitle => 'Update quantity:';
  String lowStockWarning(int minQuantity) => 'Low stock (minimum: $minQuantity)';
  String get cancelButton => 'Cancel';
  String get saveButton => 'Save';
  String get unitAbbreviation => 'pcs';

  @override String get tabItems => 'Items';
  @override String get tabMissing => 'Missing';
  @override String get tabLocations => 'Locations';
  @override String get addBasicsButton => 'Yes, add!';
  @override String get emptyLabel => 'Pantry empty';
  @override String get addFirstProduct => 'Add first product';

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

  String get subtitle => 'Checklist ✓';
  String get gotItButton => 'Got it';
  String get checkAll => 'Check all';
  String get uncheckAll => 'Uncheck all';
  String percentComplete(int percent) => '$percent% completed';
  String get emptyTitle => 'List is empty';
  String get emptySubtitle => 'Add items to checklist';
}

// ========================================
// Contact Selector Dialog
// ========================================

class ContactSelectorStringsEn extends ContactSelectorStrings {
  const ContactSelectorStringsEn();

  String get title => 'Select People to Share With';
  String get searchHint => 'Search by name or email...';
  String get addNewContact => 'Add New Contact';
  String get emailLabel => 'Email';
  String get phoneLabel => 'Phone';
  String get emailHint => 'Enter email...';
  String get invalidEmail => 'Please enter a valid email';
  String get invalidPhone => 'Please enter a valid phone number (05X-XXXXXXX)';
  String get contactAlreadySelected => 'This contact is already selected';
  String genericError(String error) => 'Error: $error';
  String get noSavedContacts => 'No saved contacts';
  String get noSearchResults => 'No results found';
  String get cancelButton => 'Cancel';
  String confirmButton(int count) => 'Confirm ($count)';
  String selectRoleFor(String name) => 'Select role for $name';
  String get roleOwnerShortDesc => 'Owner - full permissions';
  String get roleAdminShortDesc => 'Can edit directly and invite others';
  String get roleEditorShortDesc => 'Can edit via approval';
  String get roleViewerShortDesc => 'View only';
  String get roleUnknownShortDesc => 'Unknown role';
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
