// lib/config/filters_data.dart — Category data — 38 categories with emoji + 96 Hebrew→English synonym mappings

import '../l10n/app_strings.dart';

/// מידע על קטגוריה: שם (מהתרגום) + אמוג'י
/// label is resolved lazily so it updates on locale switch
class CategoryInfo {
  final String Function() _labelFn;
  final String emoji;
  CategoryInfo(this._labelFn, this.emoji);

  String get label => _labelFn();
}

/// Categories data - auto-generated list order
class CategoriesData {
  CategoriesData._();

  // ⚠️ DORMANT (hidden per the supermarket pivot — PRODUCT_DIRECTION §6).
  // The food-filtering block below (foodCategoryKeys, isFoodCategory,
  // nonFoodNameHints, looksLikeNonFood) is consumed ONLY by WhatsForDinnerCard,
  // which is no longer rendered on the home screen (the widget file is kept
  // for reversibility). Retained so the card compiles if restored. Delete this
  // block only if the card is permanently dropped.

  /// Edible categories — used to filter pantry items when surfacing
  /// recipe-related features (e.g. the "What's for dinner" card).
  ///
  /// Deliberately EXCLUDES `other` because uncategorized items are the
  /// most likely to be non-food (swimsuits, fabric softener, batteries
  /// — yes, all observed in real demo data). Better to miss a few
  /// genuinely edible items than to ship a recipe search with "swimsuit"
  /// in the query. Also excludes `vitamins`, `otc_medicine`, `first_aid`
  /// (consumed but not cooked), `pet_food`, `baby_products` (mixed —
  /// formula edible, diapers not), `hygiene`, `cosmetics`, `cleaning`.
  static const Set<String> foodCategoryKeys = {
    'dairy',
    'dairy_substitutes',
    'vegetables',
    'fruits',
    'meat_fish',
    'beef',
    'chicken',
    'turkey',
    'lamb',
    'fish',
    'meat_substitutes',
    'rice_pasta',
    'legumes_grains',
    'cereals',
    'bread_bakery',
    'cakes',
    'cookies_sweets',
    'sweets_snacks',
    'canned',
    'frozen',
    'ready_salads',
    'spices',
    'oils_sauces',
    'sweet_spreads',
    'coffee_tea',
    'beverages',
    'nuts_seeds',
    'dried_fruits',
  };

  /// Returns true if [categoryKey] represents an edible ingredient that
  /// can plausibly feature in a recipe.
  ///
  /// The pantry stores category strings exactly as they arrive from the
  /// supermarket catalog — typically Hebrew labels like "מוצרי חלב",
  /// "ניקיון", "אורז ופסטה". This helper resolves Hebrew → English key
  /// via [synonyms] before checking [foodCategoryKeys], so demo data
  /// (and real Shufersal/RamiLevi imports) match correctly. A direct
  /// English key (e.g. already-normalized data) also works.
  static bool isFoodCategory(String categoryKey) {
    if (categoryKey.isEmpty) return false;
    // Direct English-key match (e.g. 'dairy', 'vegetables').
    if (foodCategoryKeys.contains(categoryKey)) return true;
    // Hebrew label → translate via synonyms, then check the resolved key.
    final normalized = synonyms[categoryKey];
    return normalized != null && foodCategoryKeys.contains(normalized);
  }

  /// Hebrew substrings that almost certainly mean "this is not food",
  /// regardless of what category the catalog data assigned. The blocklist
  /// is the safety net against bad catalog labels.
  ///
  /// Observed catalog miscategorizations (assets/data/list_types/
  /// supermarket.json):
  ///  - "בגד ים חליפה בנות" → "מוצרי חלב" (clothing tagged as dairy)
  ///  - "תחבושת ..."         → "מוצרי חלב" (bandages tagged as dairy)
  ///  - "מטען ..."           → "שימורים"   (charger tagged as canned)
  ///  - "מברשת ..."          → "מוצרי חלב" (brush tagged as dairy)
  ///  - "צעצוע ..."          → "ממתקים"    (toy tagged as sweets)
  ///  - "ויטמין ..."         → "משקאות"   (vitamin tagged as beverage)
  ///
  /// Conclusion: category alone is not a trustworthy signal. The hints
  /// below are substring-matched against the product name as a second
  /// layer. Erring on the side of over-filtering — a missed edible item
  /// is a minor inconvenience; a "recipe with swimsuit" search is a
  /// trust-eroding bug.
  /// IMPORTANT: substring-matched against product names — so each entry
  /// must be specific enough not to occur inside real food names.
  /// Verified false positives that were REMOVED after sampling:
  ///   - 'כדורי' caught "כדורי בשר" (meatballs), "כדורי שוקולד" (chocolate
  ///     balls), "כדורי ג'לי" (jelly balls). 268 catalog matches, mostly food.
  ///   - 'ספריי' caught "ספרייט" (Sprite), "ממתק ספריי" (candy spray).
  ///   - 'גרב' caught "בוגרב" (a brand of cookies), "גרבלקס סלמון"
  ///     (gravlax), "זנגרביל" (ginger).
  /// Tightened: 'נעל' → 'נעלי' (avoids accidental matches), 'מברשת
  /// שיניים' → 'מברשת' (broader; brushes are reliably non-food).
  /// Curated through multiple catalog-audit rounds (19/5/2026) — see
  /// REVIEW_BACKLOG. Each entry was sampled against the live catalog
  /// to confirm it doesn't catch real food. Words known to create
  /// false positives have been deliberately omitted or refined:
  ///   - 'סיגרי' removed (caught "סיגרים בשר" = meat-stuffed pastries)
  ///   - 'בלון' removed (caught "אובלון"/"הובלון" beer brands)
  ///   - 'בובה' removed (caught "Hubba Bubba" gum, "קינדר בובה" candy)
  ///   - 'נייר אפיה'/'נייר אפייה' removed (legitimate kitchen item)
  ///   - 'אייפון' removed (only catalog hit was "אייפון שוקולד" candy)
  ///   - 'סיגרי' → 'סיגריה' (full-word form catches the electronics
  ///     without snagging the pastries)
  static const Set<String> nonFoodNameHints = {
    // ביגוד
    'בגד', 'חולצה', 'מכנס', 'גופיה', 'כובע', 'נעלי', 'סנדל',
    // ניקיון וכביסה
    'תרסיס', 'מנקה', 'מטליות', 'סמרטוט', 'דלי', 'מטאטא',
    'אקונומיקה', 'מרכך כביסה', 'אבקת כביסה', 'נוזל כלים',
    'לרצפה', 'לכביסה', 'לניקוי',
    // היגיינה וטיפוח
    'סבון', 'שמפו', 'מרכך שיער', 'משחת שיניים', 'מברשת',
    'דאודורנט', 'קרם פנים', 'קרם גוף', 'איפור', 'תחבושת',
    'חיתול',
    // פארם וויטמינים (קטגוריה כבר חוסמת, blocklist הוא backup)
    'ויטמין', 'תוסף', 'תרופה',
    // בית, אלקטרוניקה, צעצועים, אביזרים
    'סוללה', 'סוללות', 'נורה', 'מטען', 'מקלות גפן',
    'צעצוע', 'מגבת', 'סדין', 'אוזניות', 'אסלה',
    // טבק
    'טבק', 'סיגריה', 'סיגריות',
    // מכשירים גדולים שמסתננים
    'מסך טלוויזיה', 'שואב אבק', 'מכונת קפה',
    // 7% leakage still in food cats per Agent 9 sample — verified safe:
    'ויטמינצ',          // branded "Vitaminchik" drinks (final-nun escape)
    'חולץ',             // corkscrews (6 catalog items, all utensils)
    'שקיות אשפה',       // trash bags (21 in food cats, all bags)
    'מפיות',            // napkins (21 in food cats, all napkins)
    'אבקת חלבון',       // protein powder supplements (45 items)
    // Demo-data observed leakage in מוצרי חלב (Agent 11):
    'פנס',              // lanterns mis-tagged as dairy
    'מפות',             // tablecloths
    'קערת קרטון',       // cardboard bowl
    'קופסת שיש',        // marble box
    // English-side tech leakage (Agent 8 audit) — `.contains` is
    // case-sensitive in Dart, so we keep both common cases. Catalog
    // catches: "Ultra Slim 4-Port USB 3.0" in meat/fish, "Brita
    // קנקן Marella" in dairy, etc.
    'USB', 'usb', 'HDMI', 'hdmi', 'Bluetooth', 'bluetooth',
    'Type-C', 'type-c', 'Lightning', 'lightning',
    'PHILIPS', 'Philips', 'Airfry', 'airfryer',
    'Brita', 'MAXTRA', 'Marella',
  };

  /// Returns true if [productName] contains any [nonFoodNameHints]
  /// substring. Used together with [isFoodCategory] as a two-layer
  /// filter: category → name → only then treat as a recipe ingredient.
  static bool looksLikeNonFood(String productName) {
    if (productName.isEmpty) return false;
    for (final hint in nonFoodNameHints) {
      if (productName.contains(hint)) return true;
    }
    return false;
  }

  /// All categories data (key → info)
  static final Map<String, CategoryInfo> data = {
    'all': CategoryInfo(() => AppStrings.categories.all, '📋'),
    'other': CategoryInfo(() => AppStrings.categories.other, '🏷️'),
    'dairy': CategoryInfo(() => AppStrings.categories.dairy, '🥛'),
    'vegetables': CategoryInfo(() => AppStrings.categories.vegetables, '🥬'),
    'fruits': CategoryInfo(() => AppStrings.categories.fruits, '🍎'),
    'meat_fish': CategoryInfo(() => AppStrings.categories.meatFish, '🥩'),
    'rice_pasta': CategoryInfo(() => AppStrings.categories.ricePasta, '🍝'),
    'spices': CategoryInfo(() => AppStrings.categories.spices, '🧂'),
    'coffee_tea': CategoryInfo(() => AppStrings.categories.coffeeTea, '☕'),
    'sweets_snacks': CategoryInfo(() => AppStrings.categories.sweetsSnacks, '🍬'),
    'beef': CategoryInfo(() => AppStrings.categories.beef, '🐄'),
    'chicken': CategoryInfo(() => AppStrings.categories.chicken, '🍗'),
    'turkey': CategoryInfo(() => AppStrings.categories.turkey, '🦃'),
    'lamb': CategoryInfo(() => AppStrings.categories.lamb, '🐑'),
    'fish': CategoryInfo(() => AppStrings.categories.fish, '🐟'),
    'meat_substitutes': CategoryInfo(() => AppStrings.categories.meatSubstitutes, '🌱'),
    'bread_bakery': CategoryInfo(() => AppStrings.categories.breadBakery, '🍞'),
    'cookies_sweets': CategoryInfo(() => AppStrings.categories.cookiesSweets, '🍪'),
    'cakes': CategoryInfo(() => AppStrings.categories.cakes, '🎂'),
    'canned': CategoryInfo(() => AppStrings.categories.canned, '🥫'),
    'legumes_grains': CategoryInfo(() => AppStrings.categories.legumesGrains, '🫘'),
    'cereals': CategoryInfo(() => AppStrings.categories.cereals, '🥣'),
    'dried_fruits': CategoryInfo(() => AppStrings.categories.driedFruits, '🍇'),
    'nuts_seeds': CategoryInfo(() => AppStrings.categories.nutsSeeds, '🥜'),
    'beverages': CategoryInfo(() => AppStrings.categories.beverages, '🥤'),
    'oils_sauces': CategoryInfo(() => AppStrings.categories.oilsSauces, '🫒'),
    'sweet_spreads': CategoryInfo(() => AppStrings.categories.sweetSpreads, '🍯'),
    'frozen': CategoryInfo(() => AppStrings.categories.frozen, '🧊'),
    'ready_salads': CategoryInfo(() => AppStrings.categories.readySalads, '🥗'),
    'dairy_substitutes': CategoryInfo(() => AppStrings.categories.dairySubstitutes, '🌾'),
    'hygiene': CategoryInfo(() => AppStrings.categories.hygiene, '🧴'),
    'cosmetics': CategoryInfo(() => AppStrings.categories.cosmetics, '💄'),
    'cleaning': CategoryInfo(() => AppStrings.categories.cleaning, '🧽'),
    'vitamins': CategoryInfo(() => AppStrings.categories.vitamins, '💊'),
    'baby_products': CategoryInfo(() => AppStrings.categories.babyProducts, '🍼'),
    'pet_food': CategoryInfo(() => AppStrings.categories.petFood, '🐕'),
    'otc_medicine': CategoryInfo(() => AppStrings.categories.otcMedicine, '🩹'),
    'first_aid': CategoryInfo(() => AppStrings.categories.firstAid, '🏥'),
  };

  /// Fixed UI order (auto-generated from data keys, 'all' first, 'other' last)
  static final List<String> order = _buildOrder();

  static List<String> _buildOrder() {
    final keys = data.keys.toList();
    final result = <String>[];

    // 'all' always first
    if (keys.contains('all')) {
      result.add('all');
      keys.remove('all');
    }

    // 'other' always last
    if (keys.contains('other')) {
      keys.remove('other');
    }

    // Sort remaining alphabetically
    keys.sort();
    result.addAll(keys);

    // Add 'other' last
    if (data.containsKey('other')) {
      result.add('other');
    }

    return List.unmodifiable(result);
  }

  /// Synonyms mapping (Hebrew → English key)
  /// ⚠️ Matched by exact key, NOT substring! Use full category names.
  static const Map<String, String> synonyms = {
    // חלב
    'חלב': 'dairy',
    'חלבי': 'dairy',
    'גבינה': 'dairy',
    'יוגורט': 'dairy',
    'מוצרי חלב': 'dairy',
    // תחליפי חלב
    'תחליפי חלב': 'dairy_substitutes',
    // ירקות
    'ירקות': 'vegetables',
    'ירק': 'vegetables',
    'פירות וירקות': 'vegetables',
    // פירות
    'פירות': 'fruits',
    'פרי': 'fruits',
    'פירות יבשים': 'dried_fruits',
    // בשר ודגים
    'בשר': 'meat_fish',
    'בשר ודגים': 'meat_fish',
    'עוף': 'chicken',
    'דג': 'fish',
    'דגים': 'fish',
    // תחליפי בשר
    'תחליפי בשר': 'meat_substitutes',
    // לחם ומאפים
    'לחם': 'bread_bakery',
    'מאפה': 'bread_bakery',
    'לחם ומאפים': 'bread_bakery',
    // ממתקים
    'ממתקים': 'sweets_snacks',
    'חטיפים': 'sweets_snacks',
    'ממתקים וחטיפים': 'sweets_snacks',
    // משקאות
    'משקאות': 'beverages',
    'שתייה': 'beverages',
    // קפה ותה
    'קפה': 'coffee_tea',
    'תה': 'coffee_tea',
    'קפה ותה': 'coffee_tea',
    // תבלינים
    'תבלינים': 'spices',
    'תבלינים ואפייה': 'spices',
    // אורז ופסטה
    'אורז': 'rice_pasta',
    'פסטה': 'rice_pasta',
    'אורז ופסטה': 'rice_pasta',
    // דגנים וקטניות
    'דגנים': 'cereals',
    'קטניות': 'legumes_grains',
    'קטניות ודגנים': 'legumes_grains',
    // שימורים
    'שימורים': 'canned',
    // קפואים
    'קפוא': 'frozen',
    'קפואים': 'frozen',
    // ניקיון והיגיינה
    'ניקיון': 'cleaning',
    'מוצרי ניקיון': 'cleaning',
    'היגיינה': 'hygiene',
    'היגיינה אישית': 'hygiene',
    'מוצרי בית': 'cleaning',
    // קוסמטיקה וטיפוח
    'קוסמטיקה': 'cosmetics',
    'קוסמטיקה וטיפוח': 'cosmetics',
    'איפור': 'cosmetics',
    'טיפוח': 'cosmetics',
    // נקניקים ובשרים מעובדים (butcher.json — 230 פריטי דלי/מעובדים שהיו unmapped)
    'נקניקים ובשרים מעובדים': 'meat_fish',
    // קטגוריות שהיו במלכודת "כללי/other" (Agent 12 — 4,118 פריטים):
    'צעצועים ומתנות': 'other',
    'אלקטרוניקה': 'other',
    'סיגריות וטבק': 'other',
    'תוספי תזונה': 'vitamins',
    // 'אלכוהול' שמרתי unmapped → routes to 'other' → excluded from
    // recipe search. אלכוהול בקטגוריה הזאת ב-supermarket.json
    // מזוהם מאוד (70% serums/lights/cosmetics) — לא שווה את הסיכון.
    // פארם ורפואה
    'פארם': 'otc_medicine',
    'תרופות ללא מרשם': 'otc_medicine',
    'מוצרי עזר רפואיים': 'first_aid',
    'עזרה ראשונה': 'first_aid',
    // ויטמינים
    'ויטמינים ותוספי תזונה': 'vitamins',
    'ויטמינים': 'vitamins',
    // גילוח והיגיינה נשית
    'מוצרי גילוח': 'hygiene',
    'היגיינה נשית': 'hygiene',
    'טיפוח הפה': 'hygiene',
    // שיער
    'אביזרי שיער': 'cosmetics',
    // מזון בריאות
    'מזון בריאות': 'other',
    // תינוקות וחיות
    'תינוק': 'baby_products',
    'מוצרי תינוקות': 'baby_products',
    'חיות מחמד': 'pet_food',
    'מזון לחיות מחמד': 'pet_food',
    // קטגוריות חדשות (מ-supermarket.json)
    'אגוזים וגרעינים': 'nuts_seeds',
    'שמנים ורטבים': 'oils_sauces',
    'ממרחים מתוקים': 'sweet_spreads',
    'סלטים מוכנים': 'ready_salads',
    // כללי
    'כלים': 'other',
    'שונות': 'other',
    'כללי': 'other',
    'אחר': 'other',

    // ── Missing catalog categories (bakery/butcher/greengrocer/market/pharmacy) ──
    // bakery
    'לחמים ולחמניות': 'bread_bakery',
    'מאפים': 'bread_bakery',
    'מאפים מזרחיים': 'bread_bakery',
    'מאפים מלוחים': 'bread_bakery',
    'מאפים מתוקים': 'cookies_sweets',
    'עוגות': 'cakes',
    // butcher
    'בקר': 'beef',
    'הודו': 'turkey',
    'טלה וכבש': 'lamb',
    'מוצרים נלווים': 'other',
    // greengrocer
    'ירקות תיבול': 'vegetables',
    // market
    'ביצים': 'dairy',
    'דגנים וקטניות': 'legumes_grains',
    'חטיפים ומתוקים': 'sweets_snacks',
    'מוכנים ומרקים': 'ready_salads',
    'רטבים ותבלינים': 'oils_sauces',
    'שימורים וכבושים': 'canned',
    // pharmacy
    'דאודורנט והיגיינה': 'hygiene',
    'הגנה מהשמש': 'hygiene',
    'טיפוח גוף': 'hygiene',
    'טיפוח פנים': 'cosmetics',
    'טיפוח שיער': 'cosmetics',
    'סבון ורחצה': 'hygiene',
    'קוסמטיקה ואיפור': 'cosmetics',
  };
}