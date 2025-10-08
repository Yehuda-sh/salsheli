// 📄 File: lib/config/list_type_mappings.dart
//
// Purpose: מיפוי בין סוגי רשימות קניות לקטגוריות וחנויות רלוונטיות
//
// Features:
// - מיפוי type → קטגוריות מוצרים (const maps)
// - מיפוי type → חנויות/מותגים מומלצים
// - פריטים מוצעים לכל סוג רשימה (140+ פריטים!)
// - תמיכה בכל 21 סוגי הרשימות (מלא!)
// - קטגוריות משותפות לאירועים (birthday, party, wedding, etc.)
// - Cache אוטומטי ל-getAllCategories/getAllStores (performance)
// - Logging מפורט לדיבוג
// - i18n ready - כל המחרוזות מ-AppStrings
//
// Usage:
// ```dart
// // קבלת קטגוריות לסוג רשימה
// final categories = ListTypeMappings.getCategoriesForType(ListType.clothing);
// // → ['חולצות', 'מכנסיים', 'שמלות וחצאיות', ...]
//
// // קבלת חנויות מומלצות
// final stores = ListTypeMappings.getStoresForType(ListType.super_);
// // → ['שופרסל', 'רמי לוי', 'יוחננוף', ...]
//
// // פריטים מוצעים
// final items = ListTypeMappings.getSuggestedItemsForType(ListType.pharmacy);
// // → ['תרופת כאב', 'ויטמין D', ...]
//
// // בדיקת רלוונטיות
// final isRelevant = ListTypeMappings.isCategoryRelevantForType(
//   'מוצרי חלב',
//   ListType.super_,
// ); // → true
//
// // קבלת כל הקטגוריות (cached)
// final allCategories = ListTypeMappings.getAllCategories();
// ```
//
// Version: 4.0 - i18n Integration! 🌍
// Last Updated: 08/10/2025

import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../l10n/app_strings.dart';

class ListTypeMappings {
  // ========================================
  // קטגוריות בסיס לאירועים (משותפות)
  // ========================================

  /// קטגוריות משותפות לכל סוגי האירועים
  /// 
  /// משמש כבסיס ל: birthday, party, wedding, picnic, holiday
  static List<String> get _baseEventCategories => [
    AppStrings.listMappings.baseEventFood,
    AppStrings.listMappings.baseEventDecorations,
    AppStrings.listMappings.baseEventServeware,
    AppStrings.listMappings.baseEventNapkins,
    AppStrings.listMappings.baseEventDisposables,
    AppStrings.listMappings.baseEventCleaning,
  ];

  // ========================================
  // מיפוי Type → קטגוריות
  // ========================================

  /// מחזיר קטגוריות רלוונטיות לסוג הרשימה
  /// 
  /// אם [type] לא קיים, מחזיר קטגוריות של 'other' (fallback)
  static List<String> getCategoriesForType(String type) {
    final categories = _typeToCategories()[type];
    
    if (categories == null) {
      debugPrint('⚠️ ListTypeMappings: Unknown list type "$type", using fallback "other"');
      return _typeToCategories()[ListType.other]!;
    }
    
    debugPrint('📋 ListTypeMappings.getCategoriesForType($type) → ${categories.length} categories');
    return categories;
  }

  static Map<String, List<String>> _typeToCategories() {
    final s = AppStrings.listMappings;
    
    return {
      // סופרמרקט - מזון ומוצרי בית
      ListType.super_: [
        s.catDairyProducts,
        s.catMeatAndFish,
        s.catFruitsAndVegetables,
        s.catBakery,
        s.catRiceAndPasta,
        s.catCannedGoods,
        s.catBeverages,
        s.catSnacks,
        s.catSpicesAndBaking,
        s.catOilsAndSauces,
        s.catFrozen,
        s.catBreakfastItems,
      ],

      // בית מרקחת - בריאות וטיפוח
      ListType.pharmacy: [
        s.catMedications,
        s.catVitamins,
        s.catBodyCare,
        s.catHairCare,
        s.catPersonalHygiene,
        s.catCosmetics,
        s.catBabyProducts,
        s.catMedicalAids,
      ],

      // חומרי בניין - כלים וחומרים
      ListType.hardware: [
        s.catTools,
        s.catBuildingMaterials,
        s.catPaints,
        s.catElectricalAndLighting,
        s.catPlumbing,
        s.catGardening,
        s.catSafety,
      ],

      // ביגוד - בגדים והנעלה
      ListType.clothing: [
        s.catShirts,
        s.catPants,
        s.catDressesAndSkirts,
        s.catFootwear,
        s.catUnderwearAndSocks,
        s.catCoatsAndJackets,
        s.catSportswear,
        s.catAccessories,
      ],

      // אלקטרוניקה - מוצרי חשמל
      ListType.electronics: [
        s.catComputersAndTablets,
        s.catSmartphones,
        s.catHeadphonesAndSpeakers,
        s.catTelevisions,
        s.catCameras,
        s.catElectronicsAccessories,
        s.catGames,
      ],

      // חיות מחמד
      ListType.pets: [
        s.catDogFood,
        s.catCatFood,
        s.catPetTreats,
        s.catPetAccessories,
        s.catPetToys,
        s.catPetGrooming,
        s.catPetHealth,
      ],

      // קוסמטיקה - יופי וטיפוח
      ListType.cosmetics: [
        s.catFaceMakeup,
        s.catSkincare,
        s.catPerfumes,
        s.catHaircare,
        s.catNailCare,
        s.catMakeupAccessories,
      ],

      // ציוד משרדי
      ListType.stationery: [
        s.catWritingInstruments,
        s.catNotebooksAndPads,
        s.catPaper,
        s.catOfficeOrganization,
        s.catArtsAndCrafts,
        s.catPrintersAndInk,
      ],

      // צעצועים ומשחקים
      ListType.toys: [
        s.catInfantToys,
        s.catBoardGames,
        s.catBrainTeasers,
        s.catDollsAndFigures,
        s.catOutdoorToys,
        s.catLegoAndBuilding,
        s.catCrafts,
        s.catVideoGames,
      ],

      // ספרים וחומרי קריאה
      ListType.books: [
        s.catFiction,
        s.catNonFiction,
        s.catChildrensBooks,
        s.catComicsAndManga,
        s.catMagazines,
        s.catTextbooks,
        s.catCookbooks,
        s.catInspirational,
      ],

      // ציוד ספורט וכושר
      ListType.sports: [
        s.catSportsClothing,
        s.catSportsShoes,
        s.catBalls,
        s.catWeights,
        s.catYogaMats,
        s.catRunningAccessories,
        s.catSwimmingEquipment,
        s.catSportsSupplements,
      ],

      // עיצוב הבית וריהוט
      ListType.homeDecor: [
        s.catFurniture,
        s.catPicturesAndFrames,
        s.catPillowsAndRugs,
        s.catCurtains,
        s.catLighting,
        s.catKitchenAccessories,
        s.catPlants,
        s.catCandlesAndScents,
      ],

      // רכב ואביזרים
      ListType.automotive: [
        s.catEngineOil,
        s.catWindshieldFluid,
        s.catAirFilter,
        s.catCarBroom,
        s.catCarCleaning,
        s.catComfortAccessories,
        s.catSteeringWheelCover,
        s.catCarCharger,
      ],

      // תינוקות (מורחב מעבר ל-pharmacy)
      ListType.baby: [
        s.catDiapers,
        s.catWipes,
        s.catBabyFood,
        s.catBottlesAndPacifiers,
        s.catBathProducts,
        s.catBabyClothing,
        s.catSafetyProducts,
        s.catDevelopmentToys,
      ],

      // מתנות (כללי)
      ListType.gifts: [
        s.catGiftsForMen,
        s.catGiftsForWomen,
        s.catGiftsForKids,
        s.catGiftsForHome,
        s.catGiftCards,
        s.catWrappingPaper,
        s.catGreetingCards,
        s.catGiftBaskets,
      ],

      // יום הולדת (base + specific)
      ListType.birthday: [
        ..._baseEventCategories,
        s.catBirthdayCake,
        s.catBirthdayCandles,
        s.catBalloons,
        s.catPartyHats,
        s.catBirthdayGifts,
        s.catGoodieBags,
        s.catPartyGames,
      ],

      // מסיבה (base + specific)
      ListType.party: [
        ..._baseEventCategories,
        s.catMusic,
        s.catAlcohol,
        s.catPartyFood,
        s.catPopcornAndSnacks,
        s.catPartyGamesCategory,
        s.catCostumes,
        s.catSpecialLighting,
      ],

      // חתונה (base + specific)
      ListType.wedding: [
        ..._baseEventCategories,
        s.catFlowers,
        s.catInvitations,
        s.catGuestGifts,
        s.catWeddingAlcohol,
        s.catTableDecorations,
        s.catChuppah,
        s.catMenu,
        s.catPhotographyAndVideo,
      ],

      // פיקניק (base + specific)
      ListType.picnic: [
        s.catSandwiches,
        s.catSalads,
        s.catFruits,
        s.catColdDrinks,
        s.catPicnicBlanket,
        s.catCooler,
        s.catDisposableUtensils,
        s.catOutdoorGames,
        s.catInsectRepellent,
      ],

      // חג (base + specific)
      ListType.holiday: [
        ..._baseEventCategories,
        s.catHolidayFood,
        s.catWineAndKiddush,
        s.catCandles,
        s.catSpecialPlates,
        s.catPrayerBooks,
        s.catGiftsForGuests,
        s.catHolidayDecorations,
      ],

      // אחר - כללי
      ListType.other: [
        s.catGeneral,
      ],
    };
  }

  // ========================================
  // מיפוי Type → חנויות/מותגים
  // ========================================

  /// מחזיר רשימת חנויות/מותגים מומלצים לסוג הרשימה
  /// 
  /// אם [type] לא קיים או אין חנויות מוצעות, מחזיר רשימה ריקה
  static List<String> getStoresForType(String type) {
    final stores = _typeToStores()[type] ?? [];
    debugPrint('🏪 ListTypeMappings.getStoresForType($type) → ${stores.length} stores');
    return stores;
  }

  static Map<String, List<String>> _typeToStores() {
    final s = AppStrings.listMappings;
    
    return {
      ListType.super_: [
        s.storeShufersal,
        s.storeRamiLevy,
        s.storeYohananof,
        s.storeVictory,
        s.storeTivTaam,
        s.storeOsherAd,
        s.storeSuperPharm,
        s.storeShukMahaneYehuda,
      ],

      ListType.pharmacy: [
        s.storeSuperPharm,
        s.storeNewPharm,
        s.storeBE,
        s.storeLife,
        s.storeEstee,
        s.storeMAC,
      ],

      ListType.hardware: [
        s.storeAce,
        s.storeBankHakelim,
        s.storeTotalCenter,
        s.storeMasterfix,
        s.storeDexter,
      ],

      ListType.clothing: [
        s.storeCastro,
        s.storeFox,
        s.storeGolf,
        s.storeHM,
        s.storeZara,
        s.storeMango,
        s.storeRenuar,
        s.storeTerminalX,
        s.storeNike,
        s.storeAdidas,
      ],

      ListType.electronics: [
        s.storeKSP,
        s.storeIvgeni,
        s.storeBug,
        s.storeElectra,
        s.storeMahsaneiHashmal,
        s.storePony,
        s.storeBaG,
        s.storeIDigital,
      ],

      ListType.pets: [
        s.storePetex,
        s.storeZootov,
        s.storePetPlanet,
        s.storePetShop,
        s.storePetzone,
      ],

      ListType.cosmetics: [
        s.storeSuperPharm,
        s.storeHamashbir,
        s.storeMAC,
      ],

      ListType.stationery: [
        s.storeSteimatzky,
        s.storeOfficeDepot,
        s.storeFantastic,
        s.storeManor,
      ],

      ListType.toys: [
        s.storeYohanan,
        s.storeToysRUs,
        s.storeHamashbir,
      ],

      ListType.books: [
        s.storeSteimatzky,
        s.storeTsometSfarim,
        s.storeBookOfLine,
        s.storeAmazon,
      ],

      ListType.sports: [
        s.storeSport5,
        s.storeDecathlon,
        s.storeTerminalX,
        s.storeMishkolot,
        s.storePulse,
      ],

      ListType.homeDecor: [
        s.storeIkea,
        s.storeHamashbir,
        s.storeTerminalX,
        s.storeRosenfeld,
      ],

      ListType.automotive: [
        s.storeIvgeni,
        s.storeDelek,
        s.storePaz,
        s.storeAce,
      ],

      ListType.baby: [
        s.storeYohanan,
        s.storeHamashbir,
        s.storeSuperPharm,
        s.storeBabyLove,
      ],

      ListType.gifts: [
        s.storeSteimatzky,
        s.storeHamashbir,
        s.storeIkea,
        s.storeTerminalX,
      ],

      ListType.birthday: [],
      ListType.party: [],
      ListType.wedding: [],
      ListType.picnic: [],
      ListType.holiday: [],

      ListType.other: [],
    };
  }

  // ========================================
  // פריטים מוצעים לפי Type
  // ========================================

  /// מחזיר רשימת פריטים כלליים מוצעים לסוג הרשימה
  /// 
  /// (לא מוצרים ספציפיים, אלא רעיונות כלליים)
  /// אם [type] לא קיים או אין פריטים מוצעים, מחזיר רשימה ריקה
  static List<String> getSuggestedItemsForType(String type) {
    final items = _typeToSuggestedItems()[type] ?? [];
    debugPrint('🛒 ListTypeMappings.getSuggestedItemsForType($type) → ${items.length} items');
    return items;
  }

  static Map<String, List<String>> _typeToSuggestedItems() {
    final s = AppStrings.listMappings;
    
    return {
      ListType.super_: [
        s.itemMilk,
        s.itemBread,
        s.itemEggs,
        s.itemTomatoes,
        s.itemCucumbers,
        s.itemBananas,
        s.itemApples,
        s.itemChicken,
        s.itemBeef,
        s.itemRice,
        s.itemPasta,
        s.itemOil,
        s.itemSugar,
        s.itemFlour,
        s.itemChocolate,
        s.itemDrink,
      ],

      ListType.pharmacy: [
        s.itemPainMedicine,
        s.itemVitaminD,
        s.itemVitaminC,
        s.itemToothpaste,
        s.itemToothbrush,
        s.itemShampoo,
        s.itemConditioner,
        s.itemSoap,
        s.itemMoisturizer,
        s.itemBabyDiapers,
        s.itemBabyWipes,
      ],

      ListType.hardware: [
        s.itemHammer,
        s.itemScrewdrivers,
        s.itemScrews,
        s.itemNails,
        s.itemWhitePaint,
        s.itemBrushes,
        s.itemGlue,
        s.itemMeasuringTape,
        s.itemDrill,
        s.itemLightBulbs,
      ],

      ListType.clothing: [
        s.itemWhiteShirt,
        s.itemTShirt,
        s.itemJeans,
        s.itemBlackShoes,
        s.itemSocks,
        s.itemUnderwear,
        s.itemDress,
        s.itemCoat,
        s.itemScarf,
        s.itemHat,
      ],

      ListType.electronics: [
        s.itemHeadphones,
        s.itemUSBCable,
        s.itemCharger,
        s.itemMouse,
        s.itemKeyboard,
        s.itemFlashDrive,
        s.itemPhoneCase,
        s.itemScreenProtector,
      ],

      ListType.pets: [
        s.itemDryDogFood,
        s.itemDryCatFood,
        s.itemPetTreatsItem,
        s.itemPetToy,
        s.itemCollar,
        s.itemLeash,
        s.itemBowl,
        s.itemCatLitter,
      ],

      ListType.cosmetics: [
        s.itemFoundation,
        s.itemMascara,
        s.itemLipstick,
        s.itemEyeliner,
        s.itemBlush,
        s.itemRemover,
        s.itemFaceCream,
        s.itemSunscreen,
        s.itemPerfume,
        s.itemNailPolish,
      ],

      ListType.stationery: [
        s.itemPens,
        s.itemPencils,
        s.itemNotebook,
        s.itemEraser,
        s.itemRuler,
        s.itemScissors,
        s.itemGlueStick,
        s.itemStapler,
        s.itemHighlighter,
        s.itemCalculator,
      ],

      ListType.toys: [
        s.itemPuzzle,
        s.itemDoll,
        s.itemCarToy,
        s.itemBuildingBlocks,
        s.itemBoardGame,
        s.itemBall,
        s.itemColoringBook,
        s.itemCrayons,
        s.itemPlayDoh,
        s.itemBubbles,
      ],

      ListType.books: [
        s.itemNovel,
        s.itemCookbookItem,
        s.itemChildrenBook,
        s.itemComic,
        s.itemMagazine,
        s.itemTextbook,
        s.itemDiary,
        s.itemCalendar,
        s.itemPhotoAlbum,
      ],

      ListType.sports: [
        s.itemRunningShoes,
        s.itemYogaMat,
        s.itemWaterBottle,
        s.itemSweatband,
        s.itemJumpRope,
        s.itemWeights,
        s.itemProteinPowder,
        s.itemSwimGoggles,
        s.itemSoccerBall,
        s.itemTennisBall,
      ],

      ListType.homeDecor: [
        s.itemCushion,
        s.itemVase,
        s.itemFrame,
        s.itemClock,
        s.itemMirror,
        s.itemCandle,
        s.itemPlant,
        s.itemRug,
        s.itemTableCloth,
        s.itemCurtain,
      ],

      ListType.automotive: [
        s.itemEngineOilItem,
        s.itemWindshieldFluidItem,
        s.itemAirFilterItem,
        s.itemCarWash,
        s.itemWax,
        s.itemTirePressureGauge,
        s.itemCarFreshener,
        s.itemPhoneHolder,
        s.itemFirstAidKit,
        s.itemJumperCables,
      ],

      ListType.baby: [
        s.itemDiapersItem,
        s.itemWipesItem,
        s.itemBottle,
        s.itemPacifier,
        s.itemBabyFoodItem,
        s.itemBabyLotion,
        s.itemBabyShampoo,
        s.itemOnesie,
        s.itemBlanket,
        s.itemRattle,
      ],

      ListType.gifts: [
        s.itemGiftCard,
        s.itemWrappingPaperItem,
        s.itemRibbon,
        s.itemGreetingCard,
        s.itemChocolateBox,
        s.itemFlowers,
        s.itemWine,
        s.itemPhotoFrame,
        s.itemCoffeeSet,
        s.itemGiftBasket,
      ],

      ListType.birthday: [
        s.itemBirthdayCakeItem,
        s.itemBalloonsItem,
        s.itemCandlesItem,
        s.itemPartyHatsItem,
        s.itemInvitations,
        s.itemGoodieBagsItem,
        s.itemBanner,
        s.itemConfetti,
        s.itemNoisemakers,
        s.itemPaperPlatesItem,
      ],

      ListType.party: [
        s.itemChips,
        s.itemSoda,
        s.itemBeer,
        s.itemWineItem,
        s.itemNuts,
        s.itemPopcorn,
        s.itemCups,
        s.itemNapkins,
        s.itemIce,
        s.itemPlaylist,
      ],

      ListType.wedding: [
        s.itemFlowersItem,
        s.itemInvitationsItem,
        s.itemFavors,
        s.itemChampagne,
        s.itemCenterpieces,
        s.itemTableNumbers,
        s.itemGuestBook,
        s.itemDJEquipment,
        s.itemPhotographer,
        s.itemWeddingCake,
      ],

      ListType.picnic: [
        s.itemSandwichesItem,
        s.itemFruitsItem,
        s.itemSaladsItem,
        s.itemJuice,
        s.itemBlanketItem,
        s.itemCoolerItem,
        s.itemPaperPlates,
        s.itemPlasticUtensils,
        s.itemSunscreenPicnic,
        s.itemInsectSpray,
      ],

      ListType.holiday: [
        s.itemWineForKiddush,
        s.itemChallah,
        s.itemMatzo,
        s.itemHoneyApple,
        s.itemCandlesForShabbat,
        s.itemMenorah,
        s.itemSederPlate,
        s.itemPrayerBook,
        s.itemShofar,
        s.itemGregorianCalendar,
      ],
      
      ListType.other: [],
    };
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// בדיקה אם קטגוריה רלוונטית לסוג רשימה
  /// 
  /// בודק התאמה חלקית (contains) בשני הכיוונים
  static bool isCategoryRelevantForType(String category, String type) {
    final relevantCategories = getCategoriesForType(type);
    final isRelevant = relevantCategories.any(
      (cat) => category.toLowerCase().contains(cat.toLowerCase()) ||
          cat.toLowerCase().contains(category.toLowerCase()),
    );
    
    debugPrint('🔍 ListTypeMappings.isCategoryRelevantForType("$category", $type) → $isRelevant');
    return isRelevant;
  }

  // Cache לשיפור ביצועים (נוצר פעם אחת בלבד)
  static List<String>? _cachedAllCategories;
  static List<String>? _cachedAllStores;

  /// קבלת כל הקטגוריות הייחודיות מכל הסוגים
  /// 
  /// משתמש ב-cache פנימי - נוצר פעם אחת בלבד
  static List<String> getAllCategories() {
    if (_cachedAllCategories != null) {
      debugPrint('📦 ListTypeMappings.getAllCategories() → ${_cachedAllCategories!.length} categories (cached)');
      return _cachedAllCategories!;
    }
    
    final allCategories = <String>{};
    for (final categories in _typeToCategories().values) {
      allCategories.addAll(categories);
    }
    
    _cachedAllCategories = allCategories.toList()..sort();
    debugPrint('📦 ListTypeMappings.getAllCategories() → ${_cachedAllCategories!.length} categories (created cache)');
    return _cachedAllCategories!;
  }

  /// קבלת כל החנויות הייחודיות מכל הסוגים
  /// 
  /// משתמש ב-cache פנימי - נוצר פעם אחת בלבד
  static List<String> getAllStores() {
    if (_cachedAllStores != null) {
      debugPrint('🏬 ListTypeMappings.getAllStores() → ${_cachedAllStores!.length} stores (cached)');
      return _cachedAllStores!;
    }
    
    final allStores = <String>{};
    for (final stores in _typeToStores().values) {
      allStores.addAll(stores);
    }
    
    _cachedAllStores = allStores.toList()..sort();
    debugPrint('🏬 ListTypeMappings.getAllStores() → ${_cachedAllStores!.length} stores (created cache)');
    return _cachedAllStores!;
  }
  
  /// ניקוי Cache (לשימוש בטסטים או reload)
  /// 
  /// ⚠️ רק לשימוש פנימי - בדרך כלל אין צורך
  static void clearCache() {
    _cachedAllCategories = null;
    _cachedAllStores = null;
    debugPrint('🗑️ ListTypeMappings.clearCache() - Cache cleared (categories + stores)');
  }
}
