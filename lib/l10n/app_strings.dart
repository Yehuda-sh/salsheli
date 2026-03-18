// 📄 lib/l10n/app_strings.dart
//
// 🌐 Locale-aware proxy — delegates to Hebrew or English strings.
// All existing `AppStrings.xxx.yyy` references work without changes.
//
// To switch language: LocaleManager.instance.setLocale(AppLocale.en)
// Default: Hebrew (he)
//
// Version: 5.0 (13/03/2026)

import 'app_strings_he.dart';
import 'app_strings_en.dart';
import 'locale_manager.dart';

// Re-export for files that import specific string classes
export 'app_strings_he.dart' hide AppStringsHe;

/// 🌐 Locale-aware string proxy
/// Delegates to AppStringsHe or AppStringsEn based on current locale.
class AppStrings {
  const AppStrings._();

  static String get appName => 'MemoZap';

  static bool get _isEnglish => LocaleManager.instance.isEnglish;

  static LayoutStrings get layout => _isEnglish ? AppStringsEn.layout : AppStringsHe.layout;
  static NavigationStrings get navigation => _isEnglish ? AppStringsEn.navigation : AppStringsHe.navigation;
  static CommonStrings get common => _isEnglish ? AppStringsEn.common : AppStringsHe.common;
  static CategoryStrings get categories => _isEnglish ? AppStringsEn.categories : AppStringsHe.categories;
  static ShoppingStrings get shopping => _isEnglish ? AppStringsEn.shopping : AppStringsHe.shopping;
  static IndexStrings get index => _isEnglish ? AppStringsEn.index : AppStringsHe.index;
  static WelcomeStrings get welcome => _isEnglish ? AppStringsEn.welcome : AppStringsHe.welcome;
  static AuthStrings get auth => _isEnglish ? AppStringsEn.auth : AppStringsHe.auth;
  static HomeStrings get home => _isEnglish ? AppStringsEn.home : AppStringsHe.home;
  static PriceComparisonStrings get priceComparison => _isEnglish ? AppStringsEn.priceComparison : AppStringsHe.priceComparison;
  static SettingsStrings get settings => _isEnglish ? AppStringsEn.settings : AppStringsHe.settings;
  static HouseholdStrings get household => _isEnglish ? AppStringsEn.household : AppStringsHe.household;
  static ListTypeGroupsStrings get listTypeGroups => _isEnglish ? AppStringsEn.listTypeGroups : AppStringsHe.listTypeGroups;
  static TemplatesStrings get templates => _isEnglish ? AppStringsEn.templates : AppStringsHe.templates;
  static CreateListDialogStrings get createListDialog => _isEnglish ? AppStringsEn.createListDialog : AppStringsHe.createListDialog;
  static ManageUsersStrings get manageUsers => _isEnglish ? AppStringsEn.manageUsers : AppStringsHe.manageUsers;
  static InventoryStrings get inventory => _isEnglish ? AppStringsEn.inventory : AppStringsHe.inventory;
  static ShoppingListDetailsStrings get listDetails => _isEnglish ? AppStringsEn.listDetails : AppStringsHe.listDetails;
  static SelectListStrings get selectList => _isEnglish ? AppStringsEn.selectList : AppStringsHe.selectList;
  static RecurringStrings get recurring => _isEnglish ? AppStringsEn.recurring : AppStringsHe.recurring;
  static SharingStrings get sharing => _isEnglish ? AppStringsEn.sharing : AppStringsHe.sharing;
  static ReceiptDetailsStrings get receiptDetails => _isEnglish ? AppStringsEn.receiptDetails : AppStringsHe.receiptDetails;
  static ShoppingHistoryStrings get shoppingHistory => _isEnglish ? AppStringsEn.shoppingHistory : AppStringsHe.shoppingHistory;
  static ActiveShopperBannerStrings get activeShopperBanner => _isEnglish ? AppStringsEn.activeShopperBanner : AppStringsHe.activeShopperBanner;
  static SuggestionsTodayCardStrings get suggestionsToday => _isEnglish ? AppStringsEn.suggestionsToday : AppStringsHe.suggestionsToday;
  static LastChanceBannerStrings get lastChanceBanner => _isEnglish ? AppStringsEn.lastChanceBanner : AppStringsHe.lastChanceBanner;
  static PendingInviteBannerStrings get pendingInviteBanner => _isEnglish ? AppStringsEn.pendingInviteBanner : AppStringsHe.pendingInviteBanner;
  static PendingInvitesScreenStrings get pendingInvitesScreen => _isEnglish ? AppStringsEn.pendingInvitesScreen : AppStringsHe.pendingInvitesScreen;
  static HomeDashboardStrings get homeDashboard => _isEnglish ? AppStringsEn.homeDashboard : AppStringsHe.homeDashboard;
  static NotificationsCenterStrings get notificationsCenter => _isEnglish ? AppStringsEn.notificationsCenter : AppStringsHe.notificationsCenter;
  static PantryStrings get pantry => _isEnglish ? AppStringsEn.pantry : AppStringsHe.pantry;
  static ChecklistStrings get checklist => _isEnglish ? AppStringsEn.checklist : AppStringsHe.checklist;
  static ContactSelectorStrings get contactSelector => _isEnglish ? AppStringsEn.contactSelector : AppStringsHe.contactSelector;
  static ShoppingSummaryStrings get shoppingSummary => _isEnglish ? AppStringsEn.shoppingSummary : AppStringsHe.shoppingSummary;
  static LegalStrings get legal => _isEnglish ? AppStringsEn.legal : AppStringsHe.legal;
}
