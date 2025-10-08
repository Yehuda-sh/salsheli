// 📄 File: lib/l10n/strings/list_type_mappings_strings.dart
//
// Purpose: מחרוזות למיפוי סוגי רשימות - קטגוריות, חנויות, ופריטים מוצעים
//
// Features:
// - 180+ קטגוריות מוצרים לכל 21 סוגי הרשימות
// - 60+ שמות חנויות ומותגים
// - 140+ פריטים מוצעים (מלא!)
// - i18n ready - מוכן להוספת שפות נוספות
//
// Usage:
// ```dart
// import 'package:salsheli/l10n/app_strings.dart';
// 
// // קטגוריות
// Text(AppStrings.listMappings.catDairyProducts)  // "מוצרי חלב"
// 
// // חנויות
// Text(AppStrings.listMappings.storeShufersal)    // "שופרסל"
// 
// // פריטים
// Text(AppStrings.listMappings.itemMilk)          // "חלב"
// ```
//
// Version: 1.0
// Created: 08/10/2025

/// מחרוזות למיפוי סוגי רשימות
/// 
/// מכיל את כל המחרוזות עבור:
/// - קטגוריות מוצרים (21 סוגי רשימות)
/// - חנויות ומותגים מומלצים
/// - פריטים מוצעים לכל סוג רשימה
class ListTypeMappingsStrings {
  const ListTypeMappingsStrings();
  
  // ========================================
  // Base Event Categories (משותף לאירועים)
  // ========================================
  
  String get baseEventFood => 'אוכל ומשקאות';
  String get baseEventDecorations => 'קישוטים';
  String get baseEventServeware => 'כלי הגשה';
  String get baseEventNapkins => 'מפיות ומגבות';
  String get baseEventDisposables => 'כלים חד-פעמיים';
  String get baseEventCleaning => 'מוצרי ניקיון';
  
  // ========================================
  // Categories - Super (סופרמרקט)
  // ========================================
  
  String get catDairyProducts => 'מוצרי חלב';
  String get catMeatAndFish => 'בשר ודגים';
  String get catFruitsAndVegetables => 'פירות וירקות';
  String get catBakery => 'מאפים';
  String get catRiceAndPasta => 'אורז ופסטה';
  String get catCannedGoods => 'שימורים';
  String get catBeverages => 'משקאות';
  String get catSnacks => 'ממתקים וחטיפים';
  String get catSpicesAndBaking => 'תבלינים ואפייה';
  String get catOilsAndSauces => 'שמנים ורטבים';
  String get catFrozen => 'קפואים';
  String get catBreakfastItems => 'מוצרי בוקר';
  
  // ========================================
  // Categories - Pharmacy (בית מרקחת)
  // ========================================
  
  String get catMedications => 'תרופות';
  String get catVitamins => 'ויטמינים ותוספי תזונה';
  String get catBodyCare => 'טיפוח הגוף';
  String get catHairCare => 'טיפוח השיער';
  String get catPersonalHygiene => 'היגיינה אישית';
  String get catCosmetics => 'קוסמטיקה';
  String get catBabyProducts => 'מוצרי תינוקות';
  String get catMedicalAids => 'עזרים רפואיים';
  
  // ========================================
  // Categories - Hardware (חומרי בניין)
  // ========================================
  
  String get catTools => 'כלי עבודה';
  String get catBuildingMaterials => 'חומרי בניין';
  String get catPaints => 'צבעים';
  String get catElectricalAndLighting => 'חשמל ותאורה';
  String get catPlumbing => 'אינסטלציה';
  String get catGardening => 'גינון';
  String get catSafety => 'בטיחות';
  
  // ========================================
  // Categories - Clothing (ביגוד)
  // ========================================
  
  String get catShirts => 'חולצות';
  String get catPants => 'מכנסיים';
  String get catDressesAndSkirts => 'שמלות וחצאיות';
  String get catFootwear => 'הנעלה';
  String get catUnderwearAndSocks => 'תחתונים וגרביים';
  String get catCoatsAndJackets => 'מעילים וז\'קטים';
  String get catSportswear => 'ביגוד ספורט';
  String get catAccessories => 'אביזרים';
  
  // ========================================
  // Categories - Electronics (אלקטרוניקה)
  // ========================================
  
  String get catComputersAndTablets => 'מחשבים וטאבלטים';
  String get catSmartphones => 'סמארטפונים';
  String get catHeadphonesAndSpeakers => 'אוזניות ורמקולים';
  String get catTelevisions => 'טלוויזיות';
  String get catCameras => 'מצלמות';
  String get catElectronicsAccessories => 'אביזרים';
  String get catGames => 'משחקים';
  
  // ========================================
  // Categories - Pets (חיות מחמד)
  // ========================================
  
  String get catDogFood => 'מזון לכלבים';
  String get catCatFood => 'מזון לחתולים';
  String get catPetTreats => 'חטיפים לחיות';
  String get catPetAccessories => 'אביזרים';
  String get catPetToys => 'משחקים לחיות';
  String get catPetGrooming => 'טיפוח';
  String get catPetHealth => 'בריאות';
  
  // ========================================
  // Categories - Cosmetics (קוסמטיקה)
  // ========================================
  
  String get catFaceMakeup => 'איפור פנים';
  String get catSkincare => 'טיפוח העור';
  String get catPerfumes => 'בשמים';
  String get catHaircare => 'טיפוח שיער';
  String get catNailCare => 'מניקור ופדיקור';
  String get catMakeupAccessories => 'אביזרי איפור';
  
  // ========================================
  // Categories - Stationery (ציוד משרדי)
  // ========================================
  
  String get catWritingInstruments => 'כלי כתיבה';
  String get catNotebooksAndPads => 'מחברות ופנקסים';
  String get catPaper => 'נייר';
  String get catOfficeOrganization => 'ארגון משרדי';
  String get catArtsAndCrafts => 'אמנות ויצירה';
  String get catPrintersAndInk => 'מדפסות ודיו';
  
  // ========================================
  // Categories - Toys (צעצועים)
  // ========================================
  
  String get catInfantToys => 'צעצועים לגיל הרך';
  String get catBoardGames => 'משחקי קופסה';
  String get catBrainTeasers => 'משחקי חשיבה';
  String get catDollsAndFigures => 'בובות ודמויות';
  String get catOutdoorToys => 'משחקי חוץ';
  String get catLegoAndBuilding => 'לגו ובניה';
  String get catCrafts => 'אמנות ויצירה';
  String get catVideoGames => 'משחקי וידאו';
  
  // ========================================
  // Categories - Books (ספרים)
  // ========================================
  
  String get catFiction => 'ספרות בדיונית';
  String get catNonFiction => 'ספרי עיון';
  String get catChildrensBooks => 'ספרי ילדים';
  String get catComicsAndManga => 'קומיקס ומנגה';
  String get catMagazines => 'מגזינים';
  String get catTextbooks => 'ספרי לימוד';
  String get catCookbooks => 'ספרי בישול';
  String get catInspirational => 'ספרי השראה';
  
  // ========================================
  // Categories - Sports (ספורט)
  // ========================================
  
  String get catSportsClothing => 'ביגוד ספורט';
  String get catSportsShoes => 'נעלי ספורט';
  String get catBalls => 'כדורים';
  String get catWeights => 'משקולות וציוד כוח';
  String get catYogaMats => 'מזרני יוגה';
  String get catRunningAccessories => 'אביזרי ריצה';
  String get catSwimmingEquipment => 'ציוד שחייה';
  String get catSportsSupplements => 'תוספי תזונה';
  
  // ========================================
  // Categories - Home Decor (עיצוב הבית)
  // ========================================
  
  String get catFurniture => 'ריהוט';
  String get catPicturesAndFrames => 'תמונות ומסגרות';
  String get catPillowsAndRugs => 'כריות ושטיחים';
  String get catCurtains => 'וילונות';
  String get catLighting => 'תאורה';
  String get catKitchenAccessories => 'אביזרי מטבח';
  String get catPlants => 'צמחי נוי';
  String get catCandlesAndScents => 'נרות וריחות';
  
  // ========================================
  // Categories - Automotive (רכב)
  // ========================================
  
  String get catEngineOil => 'שמן מנוע';
  String get catWindshieldFluid => 'נוזל שמשות';
  String get catAirFilter => 'מסנן אוויר';
  String get catCarBroom => 'מטאטא לרכב';
  String get catCarCleaning => 'מוצרי ניקוי רכב';
  String get catComfortAccessories => 'אביזרי נוחות';
  String get catSteeringWheelCover => 'כיסוי הגה';
  String get catCarCharger => 'מטען לרכב';
  
  // ========================================
  // Categories - Baby (תינוקות)
  // ========================================
  
  String get catDiapers => 'חיתולים';
  String get catWipes => 'מגבונים';
  String get catBabyFood => 'מזון תינוקות';
  String get catBottlesAndPacifiers => 'בקבוקים ומוצצים';
  String get catBathProducts => 'מוצרי רחצה';
  String get catBabyClothing => 'ביגוד תינוקות';
  String get catSafetyProducts => 'מוצרי בטיחות';
  String get catDevelopmentToys => 'צעצועי התפתחות';
  
  // ========================================
  // Categories - Gifts (מתנות)
  // ========================================
  
  String get catGiftsForMen => 'מתנות לגברים';
  String get catGiftsForWomen => 'מתנות לנשים';
  String get catGiftsForKids => 'מתנות לילדים';
  String get catGiftsForHome => 'מתנות לבית';
  String get catGiftCards => 'שוברי מתנה';
  String get catWrappingPaper => 'ניירות עטיפה';
  String get catGreetingCards => 'כרטיסי ברכה';
  String get catGiftBaskets => 'סלסלות מתנה';
  
  // ========================================
  // Categories - Birthday (יום הולדת)
  // ========================================
  
  String get catBirthdayCake => 'עוגת יום הולדת';
  String get catBirthdayCandles => 'נרות ליום הולדת';
  String get catBalloons => 'בלונים';
  String get catPartyHats => 'כובעי מסיבה';
  String get catBirthdayGifts => 'מתנות';
  String get catGoodieBags => 'שקיות הפתעה';
  String get catPartyGames => 'משחקים למסיבה';
  
  // ========================================
  // Categories - Party (מסיבה)
  // ========================================
  
  String get catMusic => 'מוזיקה';
  String get catAlcohol => 'אלכוהול';
  String get catPartyFood => 'מזון למסיבה';
  String get catPopcornAndSnacks => 'פופקורן וחטיפים';
  String get catPartyGamesCategory => 'משחקי חברה';
  String get catCostumes => 'תחפושות';
  String get catSpecialLighting => 'תאורה מיוחדת';
  
  // ========================================
  // Categories - Wedding (חתונה)
  // ========================================
  
  String get catFlowers => 'פרחים';
  String get catInvitations => 'הזמנות';
  String get catGuestGifts => 'מתנות לאורחים';
  String get catWeddingAlcohol => 'אלכוהול';
  String get catTableDecorations => 'עיטורי שולחן';
  String get catChuppah => 'חופה';
  String get catMenu => 'תפריט';
  String get catPhotographyAndVideo => 'צילום ווידאו';
  
  // ========================================
  // Categories - Picnic (פיקניק)
  // ========================================
  
  String get catSandwiches => 'כריכים';
  String get catSalads => 'סלטים';
  String get catFruits => 'פירות';
  String get catColdDrinks => 'משקאות קרים';
  String get catPicnicBlanket => 'שמיכת פיקניק';
  String get catCooler => 'צידנית';
  String get catDisposableUtensils => 'כלים חד-פעמיים';
  String get catOutdoorGames => 'משחקי חוץ';
  String get catInsectRepellent => 'דוחה יתושים';
  
  // ========================================
  // Categories - Holiday (חג)
  // ========================================
  
  String get catHolidayFood => 'מאכלי החג';
  String get catWineAndKiddush => 'יין וקידוש';
  String get catCandles => 'נרות';
  String get catSpecialPlates => 'צלחות מיוחדות';
  String get catPrayerBooks => 'ספרי תפילה';
  String get catGiftsForGuests => 'מתנות לאורחים';
  String get catHolidayDecorations => 'עיטורי חג';
  
  // ========================================
  // Categories - Other (אחר)
  // ========================================
  
  String get catGeneral => 'כללי';
  
  // ========================================
  // Stores - Supermarkets
  // ========================================
  
  String get storeShufersal => 'שופרסל';
  String get storeRamiLevy => 'רמי לוי';
  String get storeYohananof => 'יוחננוף';
  String get storeVictory => 'ויקטורי';
  String get storeTivTaam => 'טיב טעם';
  String get storeOsherAd => 'אושר עד';
  String get storeSuperPharm => 'סופר פארם';
  String get storeShukMahaneYehuda => 'שוק מחנה יהודה';
  
  // ========================================
  // Stores - Pharmacy
  // ========================================
  
  String get storeNewPharm => 'ניו-פארם';
  String get storeBE => 'BE';
  String get storeLife => 'לייף';
  String get storeEstee => 'אסתי לאודר';
  String get storeMAC => 'MAC';
  
  // ========================================
  // Stores - Hardware
  // ========================================
  
  String get storeAce => 'איס הרדוור';
  String get storeBankHakelim => 'בנק הכלים';
  String get storeTotalCenter => 'טוטל סנטר';
  String get storeMasterfix => 'מאסטרפיקס';
  String get storeDexter => 'דקסטר';
  
  // ========================================
  // Stores - Clothing
  // ========================================
  
  String get storeCastro => 'קסטרו';
  String get storeFox => 'פוקס';
  String get storeGolf => 'גולף';
  String get storeHM => 'H&M';
  String get storeZara => 'זארה';
  String get storeMango => 'מנגו';
  String get storeRenuar => 'רנואר';
  String get storeTerminalX => 'טרמינל X';
  String get storeNike => 'נייקי';
  String get storeAdidas => 'אדידס';
  
  // ========================================
  // Stores - Electronics
  // ========================================
  
  String get storeKSP => 'KSP';
  String get storeIvgeni => 'יוניון';
  String get storeBug => 'בי אנד אייץ\'';
  String get storeElectra => 'אלקטרה';
  String get storeMahsaneiHashmal => 'מחסני חשמל';
  String get storePony => 'פוני';
  String get storeBaG => 'באג';
  String get storeIDigital => 'iDigital';
  
  // ========================================
  // Stores - Pets
  // ========================================
  
  String get storePetex => 'פטקס';
  String get storeZootov => 'זוטוב';
  String get storePetPlanet => 'פט פלאנט';
  String get storePetShop => 'פט שופ';
  String get storePetzone => 'פטזון';
  
  // ========================================
  // Stores - Other Categories
  // ========================================
  
  String get storeSteimatzky => 'סטימצקי';
  String get storeOfficeDepot => 'אופיס דיפו';
  String get storeFantastic => 'פנטסטיק';
  String get storeManor => 'מנור';
  String get storeYohanan => 'יוחאנן';
  String get storeToysRUs => 'צעצועים "ר" אס';
  String get storeHamashbir => 'המשביר לצרכן';
  String get storeTsometSfarim => 'צומת ספרים';
  String get storeBookOfLine => 'בוק אוף ליין';
  String get storeAmazon => 'אמזון';
  String get storeSport5 => 'ספורט 5';
  String get storeDecathlon => 'דקתלון';
  String get storeMishkolot => 'משקולות בנימין';
  String get storePulse => 'פולס';
  String get storeIkea => 'איקיאה';
  String get storeRosenfeld => 'רוזנפלד';
  String get storeDelek => 'דלק';
  String get storePaz => 'פז';
  String get storeBabyLove => 'ביבילוב';
  
  // ========================================
  // Suggested Items - Super
  // ========================================
  
  String get itemMilk => 'חלב';
  String get itemBread => 'לחם';
  String get itemEggs => 'ביצים';
  String get itemTomatoes => 'עגבניות';
  String get itemCucumbers => 'מלפפונים';
  String get itemBananas => 'בננות';
  String get itemApples => 'תפוחים';
  String get itemChicken => 'עוף';
  String get itemBeef => 'בקר';
  String get itemRice => 'אורז';
  String get itemPasta => 'פסטה';
  String get itemOil => 'שמן';
  String get itemSugar => 'סוכר';
  String get itemFlour => 'קמח';
  String get itemChocolate => 'שוקולד';
  String get itemDrink => 'משקה';
  
  // ========================================
  // Suggested Items - Pharmacy
  // ========================================
  
  String get itemPainMedicine => 'תרופת כאב';
  String get itemVitaminD => 'ויטמין D';
  String get itemVitaminC => 'ויטמין C';
  String get itemToothpaste => 'משחת שיניים';
  String get itemToothbrush => 'מברשת שיניים';
  String get itemShampoo => 'שמפו';
  String get itemConditioner => 'מרכך';
  String get itemSoap => 'סבון';
  String get itemMoisturizer => 'קרם לחות';
  String get itemBabyDiapers => 'חיתולים';
  String get itemBabyWipes => 'מגבונים';
  
  // ========================================
  // Suggested Items - Other Categories
  // (ממשיך עם כל שאר הפריטים...)
  // ========================================
  
  // Hardware
  String get itemHammer => 'פטיש';
  String get itemScrewdrivers => 'מברגים';
  String get itemScrews => 'ברגים';
  String get itemNails => 'מסמרים';
  String get itemWhitePaint => 'צבע לבן';
  String get itemBrushes => 'מברשות';
  String get itemGlue => 'דבק';
  String get itemMeasuringTape => 'מטר';
  String get itemDrill => 'מקדחה';
  String get itemLightBulbs => 'נורות';
  
  // Clothing
  String get itemWhiteShirt => 'חולצה לבנה';
  String get itemTShirt => 'חולצת טי';
  String get itemJeans => 'ג\'ינס';
  String get itemBlackShoes => 'נעליים שחורות';
  String get itemSocks => 'גרביים';
  String get itemUnderwear => 'תחתונים';
  String get itemDress => 'שמלה';
  String get itemCoat => 'מעיל';
  String get itemScarf => 'צעיף';
  String get itemHat => 'כובע';
  
  // Electronics
  String get itemHeadphones => 'אוזניות';
  String get itemUSBCable => 'כבל USB';
  String get itemCharger => 'מטען';
  String get itemMouse => 'עכבר';
  String get itemKeyboard => 'מקלדת';
  String get itemFlashDrive => 'זיכרון נייד';
  String get itemPhoneCase => 'כיסוי לטלפון';
  String get itemScreenProtector => 'מגן מסך';
  
  // Pets
  String get itemDryDogFood => 'מזון יבש לכלב';
  String get itemDryCatFood => 'מזון יבש לחתול';
  String get itemPetTreatsItem => 'חטיפים';
  String get itemPetToy => 'צעצוע';
  String get itemCollar => 'קולר';
  String get itemLeash => 'רצועה';
  String get itemBowl => 'קערה';
  String get itemCatLitter => 'חול לחתול';
  
  // ========================================
  // Suggested Items - Cosmetics (קוסמטיקה)
  // ========================================
  
  String get itemFoundation => 'מייק אפ';
  String get itemMascara => 'מסקרה';
  String get itemLipstick => 'שפתון';
  String get itemEyeliner => 'איילנר';
  String get itemBlush => 'סומק';
  String get itemRemover => 'מסיר איפור';
  String get itemFaceCream => 'קרם פנים';
  String get itemSunscreen => 'קרם הגנה';
  String get itemPerfume => 'בושם';
  String get itemNailPolish => 'לק ציפורניים';
  
  // ========================================
  // Suggested Items - Stationery (ציוד משרדי)
  // ========================================
  
  String get itemPens => 'עטים';
  String get itemPencils => 'עפרונות';
  String get itemNotebook => 'מחברת';
  String get itemEraser => 'מחק';
  String get itemRuler => 'סרגל';
  String get itemScissors => 'מספריים';
  String get itemGlueStick => 'דבק סטיק';
  String get itemStapler => 'מהדק';
  String get itemHighlighter => 'טוש סימון';
  String get itemCalculator => 'מחשבון';
  
  // ========================================
  // Suggested Items - Toys (צעצועים)
  // ========================================
  
  String get itemPuzzle => 'פאזל';
  String get itemDoll => 'בובה';
  String get itemCarToy => 'מכונית צעצוע';
  String get itemBuildingBlocks => 'קוביות בניה';
  String get itemBoardGame => 'משחק קופסה';
  String get itemBall => 'כדור';
  String get itemColoringBook => 'ספר צביעה';
  String get itemCrayons => 'צבעי פנדה';
  String get itemPlayDoh => 'פלסטלינה';
  String get itemBubbles => 'בועות סבון';
  
  // ========================================
  // Suggested Items - Books (ספרים)
  // ========================================
  
  String get itemNovel => 'רומן';
  String get itemCookbookItem => 'ספר בישול';
  String get itemChildrenBook => 'ספר ילדים';
  String get itemComic => 'קומיקס';
  String get itemMagazine => 'מגזין';
  String get itemTextbook => 'ספר לימוד';
  String get itemDiary => 'יומן';
  String get itemCalendar => 'לוח שנה';
  String get itemPhotoAlbum => 'אלבום תמונות';
  
  // ========================================
  // Suggested Items - Sports (ספורט)
  // ========================================
  
  String get itemRunningShoes => 'נעלי ריצה';
  String get itemYogaMat => 'מזרן יוגה';
  String get itemWaterBottle => 'בקבוק מים';
  String get itemSweatband => 'סרט סופג זיעה';
  String get itemJumpRope => 'חבל קפיצה';
  String get itemWeights => 'משקולות';
  String get itemProteinPowder => 'אבקת חלבון';
  String get itemSwimGoggles => 'משקפי שחייה';
  String get itemSoccerBall => 'כדור כדורגל';
  String get itemTennisBall => 'כדור טניס';
  
  // ========================================
  // Suggested Items - Home Decor (עיצוב הבית)
  // ========================================
  
  String get itemCushion => 'כרית נוי';
  String get itemVase => 'אגרטל';
  String get itemFrame => 'מסגרת לתמונה';
  String get itemClock => 'שעון קיר';
  String get itemMirror => 'מראה';
  String get itemCandle => 'נר';
  String get itemPlant => 'צמח נוי';
  String get itemRug => 'שטיח';
  String get itemTableCloth => 'מפת שולחן';
  String get itemCurtain => 'וילון';
  
  // ========================================
  // Suggested Items - Automotive (רכב)
  // ========================================
  
  String get itemEngineOilItem => 'שמן מנוע';
  String get itemWindshieldFluidItem => 'נוזל שמשות';
  String get itemAirFilterItem => 'מסנן אוויר';
  String get itemCarWash => 'חומר שטיפה';
  String get itemWax => 'ווקס';
  String get itemTirePressureGauge => 'מד לחץ אוויר';
  String get itemCarFreshener => 'מטהר אוויר לרכב';
  String get itemPhoneHolder => 'מחזיק טלפון';
  String get itemFirstAidKit => 'ערכת עזרה ראשונה';
  String get itemJumperCables => 'כבלי עזר';
  
  // ========================================
  // Suggested Items - Baby (תינוקות)
  // ========================================
  
  String get itemDiapersItem => 'חיתולים';
  String get itemWipesItem => 'מגבונים';
  String get itemBottle => 'בקבוק';
  String get itemPacifier => 'מוצץ';
  String get itemBabyFoodItem => 'מזון תינוקות';
  String get itemBabyLotion => 'קרם תינוקות';
  String get itemBabyShampoo => 'שמפו לתינוקות';
  String get itemOnesie => 'בגד גוף';
  String get itemBlanket => 'שמיכה';
  String get itemRattle => 'רעשן';
  
  // ========================================
  // Suggested Items - Gifts (מתנות)
  // ========================================
  
  String get itemGiftCard => 'שובר מתנה';
  String get itemWrappingPaperItem => 'נייר אריזה';
  String get itemRibbon => 'סרט נוי';
  String get itemGreetingCard => 'כרטיס ברכה';
  String get itemChocolateBox => 'קופסת שוקולד';
  String get itemFlowers => 'זר פרחים';
  String get itemWine => 'בקבוק יין';
  String get itemPhotoFrame => 'מסגרת לתמונה';
  String get itemCoffeeSet => 'ערכת קפה';
  String get itemGiftBasket => 'סלסלת מתנה';
  
  // ========================================
  // Suggested Items - Birthday (יום הולדת)
  // ========================================
  
  String get itemBirthdayCakeItem => 'עוגת יום הולדת';
  String get itemBalloonsItem => 'בלונים';
  String get itemCandlesItem => 'נרות';
  String get itemPartyHatsItem => 'כובעי מסיבה';
  String get itemInvitations => 'הזמנות';
  String get itemGoodieBagsItem => 'שקיות הפתעה';
  String get itemBanner => 'שלט ברכה';
  String get itemConfetti => 'קונפטי';
  String get itemNoisemakers => 'חצוצרות מסיבה';
  String get itemPaperPlatesItem => 'צלחות חד-פעמיות';
  
  // ========================================
  // Suggested Items - Party (מסיבה)
  // ========================================
  
  String get itemChips => 'צ\'יפס';
  String get itemSoda => 'משקה קל';
  String get itemBeer => 'בירה';
  String get itemWineItem => 'יין';
  String get itemNuts => 'אגוזים';
  String get itemPopcorn => 'פופקורן';
  String get itemCups => 'כוסות חד-פעמיות';
  String get itemNapkins => 'מפיות';
  String get itemIce => 'קרח';
  String get itemPlaylist => 'רשימת השמעה';
  
  // ========================================
  // Suggested Items - Wedding (חתונה)
  // ========================================
  
  String get itemFlowersItem => 'פרחים';
  String get itemInvitationsItem => 'הזמנות';
  String get itemFavors => 'מתנות לאורחים';
  String get itemChampagne => 'שמפניה';
  String get itemCenterpieces => 'קישוטי שולחן';
  String get itemTableNumbers => 'מספרי שולחנות';
  String get itemGuestBook => 'ספר אורחים';
  String get itemDJEquipment => 'ציוד DJ';
  String get itemPhotographer => 'צלם';
  String get itemWeddingCake => 'עוגת חתונה';
  
  // ========================================
  // Suggested Items - Picnic (פיקניק)
  // ========================================
  
  String get itemSandwichesItem => 'כריכים';
  String get itemFruitsItem => 'פירות';
  String get itemSaladsItem => 'סלטים';
  String get itemJuice => 'מיץ';
  String get itemBlanketItem => 'שמיכה';
  String get itemCoolerItem => 'צידנית';
  String get itemPaperPlates => 'צלחות חד-פעמיות';
  String get itemPlasticUtensils => 'סכו"ם חד-פעמי';
  String get itemSunscreenPicnic => 'קרם הגנה';
  String get itemInsectSpray => 'ספריי נגד יתושים';
  
  // ========================================
  // Suggested Items - Holiday (חג)
  // ========================================
  
  String get itemWineForKiddush => 'יין לקידוש';
  String get itemChallah => 'חלה';
  String get itemMatzo => 'מצה';
  String get itemHoneyApple => 'דבש ותפוח';
  String get itemCandlesForShabbat => 'נרות שבת';
  String get itemMenorah => 'חנוכייה';
  String get itemSederPlate => 'קערת סדר';
  String get itemPrayerBook => 'סידור';
  String get itemShofar => 'שופר';
  String get itemGregorianCalendar => 'לוח שנה';
}
