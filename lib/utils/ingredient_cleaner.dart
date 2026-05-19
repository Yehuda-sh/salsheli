// lib/utils/ingredient_cleaner.dart — Strip catalog noise from product names before sending them to Google recipe search

/// Hebrew brand names commonly appended/embedded in catalog product
/// names. Stripping them tightens Google recipe queries — "חלב תנובה 3%"
/// → "חלב" returns recipes; the verbose form returns store listings.
const Set<String> _hebrewBrands = {
  'תנובה', 'טרה', 'שטראוס', 'עלית', 'אסם', 'יטבתה', 'יוטבתה',
  'גד', 'מולר', 'גליל', 'הראל', 'דנונה', 'מילקה', 'נסטלה',
  'קוקה', 'קולה', 'פפסי', 'שופרסל', 'סוגת', 'אחווה', 'כרמית',
  'נביעות', 'יכין', 'שמיר', 'נקסט', 'ויקטורי', 'רמי', 'לוי',
  'ספרינג', 'ביכורים', 'גמי', 'ביגה', 'שוופס', 'טבעולנו', 'עטרה',
  'מעדנות', 'בייגל', 'צבר',
};

/// Descriptor stopwords — tokens that survive size/unit stripping but
/// add no information to a recipe search ("organic milk" vs "milk" both
/// return milk recipes).
const Set<String> _descriptorStopwords = {
  'אורגני', 'אורגנית', 'אורגניים', 'אורגניות',
  'במשקל', 'מארז', 'חבילה', 'אריזה', 'גודל',
  'של', 'דק', 'דקיק', 'עבה',
};

// Allow units to be quoted variations — catalog uses both `ק"ג` and `קג`.
const String _unitsAlt =
    "גרם|גר|ק\"ג|קג|קילו|ליטר|ל|מ\"ל|מל|סמ\"ק|יחידות|יחידה|יח|יח'";

// Order matters — strip composites first, then leftovers.
final RegExp _junk = RegExp(r'''[\[\](){}"'\\/]+''');
final RegExp _percent = RegExp(r'\b\d+(?:[.,]\d+)?\s*%\s*\w*');
final RegExp _numUnit =
    RegExp('\\b\\d+(?:[.,]\\d+)?\\s*(?:$_unitsAlt)\\.?\\b');
final RegExp _pack = RegExp(r'\bמארז(?:\s+(?:של\s+)?\d+(?:\s+\S+)?)?\b');
final RegExp _sizeCode = RegExp(r'\bגודל\s+[A-Zא-ת0-9]+\b');
final RegExp _leftoverUnit = RegExp('\\b(?:$_unitsAlt)\\.?\\b');
final RegExp _leftoverNum = RegExp(r'\b\d+(?:[.,]\d+)?\b');
final RegExp _bareLatin = RegExp(r'(?<=\s)[LMSXl]{1,2}(?=\s|$)');
final RegExp _whitespace = RegExp(r'\s+');

// Cap on tokens kept per ingredient. 3 covers `שמן זית כתית` (canonical
// noun + 2 qualifiers); 4-token names like `שמן זית כתית מעולה` lose
// the final descriptor, which is fine for a recipe query.
const int _kMaxTokensPerIngredient = 3;

/// Strip catalog noise from a raw product name to produce a short,
/// recipe-friendly ingredient phrase suitable for a Google search.
///
/// Examples:
///   `'חלב תנובה 3% 1 ליטר'`          → `'חלב'`
///   `'ביצים אורגניות גודל L 12 יחידות'` → `'ביצים'`
///   `'סוכר חום 500 גר'`              → `'סוכר חום'`
///   `'שמן זית כתית מעולה 750 מ"ל'`   → `'שמן זית כתית'`
///
/// If [brand] is supplied (typically `InventoryItem.brand`) it's also
/// stripped — catches per-item brand variants the generic [_hebrewBrands]
/// set misses.
///
/// Returns the original [raw] string unchanged if cleaning would leave
/// nothing — better to send the verbose name than an empty query.
String cleanIngredientName(String raw, {String? brand}) {
  var s = raw.replaceAll(_junk, ' ');

  // Item-specific brand has priority — handles unusual brand strings
  // (e.g. an obscure regional brand not in the global set).
  if (brand != null && brand.trim().isNotEmpty) {
    s = s.replaceAll(brand.trim(), ' ');
  }

  s = s
      .replaceAll(_percent, ' ')
      .replaceAll(_numUnit, ' ')
      .replaceAll(_pack, ' ')
      .replaceAll(_sizeCode, ' ')
      .replaceAll(_leftoverUnit, ' ')
      .replaceAll(_leftoverNum, ' ')
      .replaceAll(_bareLatin, ' ');

  final tokens = s
      .split(_whitespace)
      .where((t) => t.isNotEmpty)
      .where((t) => !_hebrewBrands.contains(t))
      .where((t) => !_descriptorStopwords.contains(t))
      .where((t) => t.length > 1)
      .take(_kMaxTokensPerIngredient)
      .toList();

  if (tokens.isEmpty) return raw.trim();
  return tokens.join(' ');
}
