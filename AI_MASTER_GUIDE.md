# AI Master Guide - Salsheli Project

> **CRITICAL:** Read this file at the start of EVERY new conversation  
> **Purpose:** Complete AI behavior instructions + technical rules  
> **Updated:** 18/10/2025 | **Version:** 2.2 - Production-Ready Checks 🚀

---

## 🗣️ Part 1: Communication & Response Guidelines

### Language Rule - ABSOLUTE
**ALL responses to user MUST be in Hebrew (except code itself)**

- Explanations: Hebrew
- Comments in responses: Hebrew  
- Error messages: Hebrew
- Code: English (standard)
- Code comments: Can be English

### Response Structure Template

**Standard response format:**
```
✅ [Action completed in Hebrew]

[Show code changes]

🔧 מה שינינו:
1. [Change 1]
2. [Change 2]
3. [Change 3]

💡 [Why these changes matter - brief explanation]
```

**Example:**
```
✅ תיקנתי את הקובץ!

[code changes shown]

🔧 מה שינינו:
1. הוספתי בדיקת mounted אחרי await
2. המרתי withOpacity ל-withValues
3. הוספתי const ל-widgets שלא משתנים

💡 השינויים האלה מונעים קריסות ומשפרים ביצועים.
```

### Tone & Style
- ✅ Friendly but professional
- ✅ Technical but accessible (user is beginner)
- ✅ Concise - no unnecessary explanations
- ✅ Use emojis sparingly for emphasis
- ✅ Bold key terms for scannability

### When to Ask vs When to Fix
**Fix immediately WITHOUT asking:**
- Technical errors (withOpacity, const, mounted check)
- Deprecated APIs
- Sticky Notes Design violations
- Missing imports
- Dead code removal (after verification)
- Performance issues (const, lazy loading)
- Security issues (household_id missing)
- Accessibility issues (sizes < 44px)

**Ask before fixing:**
- Architectural changes
- Feature additions/removals
- Major refactoring (>100 lines)
- Unclear requirements

---

## 🛠️ Part 2: Tools & Workflow

### Filesystem:edit_file > artifacts

**⚠️ CRITICAL: User prefers Filesystem:edit_file over artifacts!**

| Scenario | Tool | Why |
|----------|------|-----|
| Fix existing file | `Filesystem:edit_file` | ✅ Direct, fast, preferred |
| Create new file | `Filesystem:write_file` | ✅ Clean creation |
| Convert design | `Filesystem:edit_file` (multiple calls) | ✅ Precise changes |
| Code examples | Only if user asks | ❌ Avoid unnecessary artifacts |
| Documentation | `Filesystem:write_file` | ✅ Direct to file |

**Example workflow:**
```
User: "תקן את הקובץ"
You: [Read file] → [Filesystem:edit_file] → "✅ תוקן!"
```

**NOT:**
```
User: "תקן את הקובץ"
You: "הנה הקובץ המתוקן:" [500-line artifact]
User: "😡 אני לא רוצה בלוקים!"
```

---

## 🔍 Part 3: Auto Code Review

### When Reading ANY Dart File - Check Automatically:

#### 1️⃣ Technical Errors (Fix immediately!)

| Error | Fix | Why |
|-------|-----|-----|
| `withOpacity(0.5)` | → `withValues(alpha: 0.5)` | Deprecated API |
| `value` (Dropdown) | → `initialValue` | API change |
| `kQuantityFieldWidth` | → `kFieldWidthNarrow` | Renamed constant |
| `kBorderRadiusFull` | → `kRadiusPill` | Renamed constant |
| Async in onPressed | → Wrap: `() => func()` | Type safety |
| Static widget, no const | → Add `const` | Performance |
| Unused imports | → Remove | Clean code |
| No mounted check after await | → Add check | Prevent crashes |
| ListView with children | → `ListView.builder()` | Performance |
| Image.network() | → `CachedNetworkImage()` | Caching |

#### 2️⃣ Sticky Notes Design Compliance (UI screens only!)

**⚠️ CRITICAL: Check EVERY UI screen for Sticky Notes Design!**

**Required components:**
- ✅ `NotebookBackground()` + `kPaperBackground`
- ✅ `StickyNote()` for content
- ✅ `StickyButton()` for buttons
- ✅ `StickyNoteLogo()` for logo
- ✅ Rotations: -0.03 to 0.03
- ✅ Colors: kStickyYellow/Pink/Green/Cyan
- ✅ Max 3 colors per screen

**If screen is NOT compliant:**
1. 🚨 Report: "המסך לא מעוצב לפי Sticky Notes Design!"
2. 🎨 Offer: "האם תרצה שאהמיר את המסך?"
3. ⚡ If yes: Convert using `Filesystem:edit_file`

#### 3️⃣ Security Checks (Fix immediately!)

| Check | Action if missing |
|-------|-------------------|
| household_id in Firestore queries | **Add immediately** |
| API keys in code | **Report as CRITICAL** |
| Passwords in debugPrint | **Remove immediately** |
| Sensitive data exposed | **Report as CRITICAL** |

#### 4️⃣ Performance Checks

| Check | Action if missing |
|-------|-------------------|
| `const` for static widgets | Add |
| ListView.builder for lists | Convert |
| Image caching | Add CachedNetworkImage |
| Batch processing (100+ items) | Implement |

#### 5️⃣ Accessibility Checks

| Check | Action if missing |
|-------|-------------------|
| Button height < 44px | Increase to 44px minimum |
| Text size < 11px | Increase to 11px minimum |
| Missing Semantics | Add for custom widgets |
| Poor contrast | Fix color combinations |

#### 6️⃣ Best Practices

| Check | Action if missing |
|-------|-------------------|
| File header documentation | Add |
| Public function docs (`///`) | Add |
| Private function docs | Add (brief) |
| Consistent naming | Fix |
| Magic numbers | Replace with constants |
| Dead code (commented) | Remove |
| Context saved before await | Fix |
| mounted check after await | Add |
| Error handling in async | Add try-catch |

#### 7️⃣ Business Logic Validation (Salsheli-Specific) 🛒

**Check these validations in the project:**

| Check | Where | Action if missing |
|-------|-------|-------------------|
| Empty list name | `ShoppingListsProvider.createList()` | Add validation: trim + check isEmpty |
| Empty product name | `ShoppingItem` model | Add validation in constructor |
| Invalid quantity | `ShoppingItem.quantity` | Check: 1-9999 range |
| Negative price | `Product.price` | Check: >= 0 |
| Missing household_id | All save operations | Add validation before save |
| Expired date | `InventoryItem.expiryDate` | Warn if date < now |
| Empty OCR result | `ReceiptProvider.scanReceipt()` | Handle gracefully |

**Example validations:**
```dart
// ✅ List name validation
if (name.trim().isEmpty) {
  throw Exception('שם הרשימה לא יכול להיות ריק');
}
if (name.length > 50) {
  throw Exception('שם הרשימה ארוך מדי (מקסימום 50 תווים)');
}

// ✅ Quantity validation
if (quantity <= 0 || quantity > 9999) {
  throw ArgumentError('כמות לא תקינה (1-9999)');
}

// ✅ household_id validation
if (_userContext.householdId == null) {
  throw Exception('לא ניתן ליצור רשימה ללא household_id');
}
```

#### 8️⃣ State Management Issues (Salsheli-Specific) 🔄

**Critical checks for Providers:**

| Check | Where | Action if missing | Priority |
|-------|-------|-------------------|----------|
| `notifyListeners()` after update | Every state change | **Add immediately** | 🔴 High |
| `removeListener()` in dispose | All Providers with UserContext | **Add immediately** | 🔴 Critical! |
| Race condition protection | `loadData()` methods | Add `if (_isLoading) return;` | 🟡 Medium |
| `notifyListeners()` in loop | Batch operations | Move outside loop | 🟡 Medium |
| `setState()` after dispose | All async Screen methods | Add `if (!mounted) return;` | 🔴 High |

**Example fixes:**
```dart
// ❌ Missing notifyListeners
void updateList(ShoppingList list) {
  final index = _lists.indexWhere((l) => l.id == list.id);
  if (index != -1) {
    _lists[index] = list;
    // 🚨 UI won't update!
  }
}

// ✅ With notifyListeners
void updateList(ShoppingList list) {
  final index = _lists.indexWhere((l) => l.id == list.id);
  if (index != -1) {
    _lists[index] = list;
    notifyListeners(); // ✅
  }
}

// ❌ CRITICAL: Memory leak - listener not removed!
class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  // Missing dispose()!
}

// ✅ FIXED: Proper cleanup
class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); // ✅ Critical!
    super.dispose();
  }
}

// ❌ Race condition
Future<void> loadProducts() async {
  _isLoading = true;
  notifyListeners();
  // If called twice, data gets mixed!
  final products = await _repository.fetchProducts();
  _products = products;
  _isLoading = false;
  notifyListeners();
}

// ✅ Protected
Future<void> loadProducts() async {
  if (_isLoading) return; // ✅ Prevent race condition
  
  _isLoading = true;
  notifyListeners();
  
  try {
    final products = await _repository.fetchProducts();
    _products = products;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

#### 9️⃣ Memory Leaks (Salsheli-Specific) 💧

**Critical resources to dispose:**

| Resource | Where in Project | Action | Priority |
|----------|------------------|--------|----------|
| `TextEditingController` | All Screens with TextFields | Dispose in `dispose()` | 🟡 Medium |
| `TextRecognizer` (OCR) | `ReceiptImportScreen` | Call `.close()` in `dispose()` | 🔴 Critical! |
| `Timer` (debounce) | Search screens | Cancel in `dispose()` | 🟡 Medium |
| `StreamSubscription` | Real-time Firestore | Cancel in `dispose()` | 🔴 Critical! |
| `AnimationController` | Animated screens | Dispose in `dispose()` | 🟡 Medium |
| UserContext listeners | All Providers | Remove in `dispose()` | 🔴 Critical! |

**Example fixes:**
```dart
// ❌ CRITICAL: OCR not closed - huge memory leak!
class _ReceiptImportScreenState extends State<ReceiptImportScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  Future<void> _scanReceipt() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    final recognizedText = await _textRecognizer.processImage(inputImage);
  }
  // Missing dispose()!
}

// ✅ FIXED
class _ReceiptImportScreenState extends State<ReceiptImportScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  @override
  void dispose() {
    _textRecognizer.close(); // ✅ Must close!
    super.dispose();
  }
  
  Future<void> _scanReceipt() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    final recognizedText = await _textRecognizer.processImage(inputImage);
  }
}

// ❌ Controllers not disposed
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Missing dispose()!
}

// ✅ Properly disposed
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ❌ CRITICAL: Firestore stream not cancelled!
class ShoppingListsProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _listsSubscription;
  
  void startListening(String householdId) {
    _listsSubscription = FirebaseFirestore.instance
      .collection('shopping_lists')
      .where('household_id', isEqualTo: householdId)
      .snapshots()
      .listen((snapshot) {
        _lists = snapshot.docs.map((doc) => ShoppingList.fromJson(doc.data())).toList();
        notifyListeners();
      });
  }
  // Missing dispose()!
}

// ✅ FIXED
class ShoppingListsProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _listsSubscription;
  
  void startListening(String householdId) {
    _listsSubscription = FirebaseFirestore.instance
      .collection('shopping_lists')
      .where('household_id', isEqualTo: householdId)
      .snapshots()
      .listen((snapshot) {
        _lists = snapshot.docs.map((doc) => ShoppingList.fromJson(doc.data())).toList();
        notifyListeners();
      });
  }
  
  @override
  void dispose() {
    _listsSubscription?.cancel(); // ✅ Must cancel!
    super.dispose();
  }
}
```

#### 🔟 Firebase Best Practices (Salsheli-Specific) 🔥

**Critical Firebase checks:**

| Check | Where | Action if wrong | Priority |
|-------|-------|-----------------|----------|
| Batch > 500 operations | Mass save/delete | Split into 500-item batches | 🔴 Critical |
| Query without limit | All `.get()` calls | Add `.limit(50)` | 🟡 Medium |
| Real-time listener no error handler | All `.snapshots()` | Add `onError` callback | 🔴 High |
| Missing offline persistence | Repository init | Enable offline | 🟡 Medium |
| No retry on server error | HTTP calls | Add retry logic (3x) | 🔴 High |

**Example fixes:**
```dart
// ❌ CRITICAL: Batch > 500 operations
final batch = _firestore.batch();
for (final item in allItems) { // 1000 items!
  batch.delete(_firestore.collection('items').doc(item.id));
}
await batch.commit(); // 🚨 ERROR: Max 500!

// ✅ FIXED: Batches of 500
const batchSize = 500;
for (int i = 0; i < allItems.length; i += batchSize) {
  final batch = _firestore.batch();
  final chunk = allItems.sublist(i, min(i + batchSize, allItems.length));
  
  for (final item in chunk) {
    batch.delete(_firestore.collection('items').doc(item.id));
  }
  
  await batch.commit();
}

// ❌ Query without limit - can return 10,000 items!
final snapshot = await _firestore
  .collection('products')
  .where('name', isGreaterThanOrEqualTo: query)
  .get();

// ✅ With limit
final snapshot = await _firestore
  .collection('products')
  .where('name', isGreaterThanOrEqualTo: query)
  .limit(50) // ✅ Prevent loading thousands
  .get();

// ❌ Listener without error handler
_firestore.collection('lists')
  .snapshots()
  .listen((snapshot) {
    _lists = snapshot.docs.map((d) => ShoppingList.fromJson(d.data())).toList();
  });
  // 🚨 Network error crashes app!

// ✅ With error handler
_listsSubscription = _firestore.collection('lists')
  .snapshots()
  .listen(
    (snapshot) {
      _lists = snapshot.docs.map((d) => ShoppingList.fromJson(d.data())).toList();
      _errorMessage = null;
      notifyListeners();
    },
    onError: (error) {
      debugPrint('❌ Firestore error: $error');
      _errorMessage = 'בעיית חיבור לשרת';
      notifyListeners();
    },
    cancelOnError: false, // ✅ Don't cancel on error
  );
```

#### 1️⃣1️⃣ API Integration Best Practices (Salsheli-Specific) 🌐

**Critical API checks (Shufersal API):**

| Check | Why Critical | Fix |
|-------|-------------|-----|
| No timeout | App stuck waiting | Add `.timeout(Duration(seconds: 10))` |
| No retry logic | Fails on network hiccup | Retry 3 times with backoff |
| Generic error messages | Poor UX | Differentiate 401, 404, 429, 500 |
| No rate limiting | API blocks you | Add throttling |
| No caching | Slow + expensive | Add cache layer |

**Example fix:**
```dart
// ❌ No timeout or retry
Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('$apiUrl/products'));
  
  if (response.statusCode == 200) {
    return parseProducts(response.body);
  }
  throw Exception('Failed to load products');
}

// ✅ With timeout, retry, and proper errors
Future<List<Product>> fetchProducts() async {
  const maxRetries = 3;
  
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final response = await http
        .get(Uri.parse('$apiUrl/products'))
        .timeout(Duration(seconds: 10)); // ✅ Timeout
      
      if (response.statusCode == 200) {
        return parseProducts(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('יש להתחבר מחדש');
      } else if (response.statusCode == 429) {
        throw RateLimitException('יותר מדי בקשות');
      } else if (response.statusCode >= 500) {
        // Server error - retry
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        throw ServerException('השרת לא זמין');
      }
    } on TimeoutException {
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
        continue;
      }
      throw TimeoutException('החיבור איטי מדי');
    }
  }
  throw Exception('Failed after $maxRetries attempts');
}
```

#### 1️⃣2️⃣ Production Readiness (Salsheli-Specific) 🚀

**Pre-release checks:**

| Check | Why Critical | Command |
|-------|-------------|----------|
| debugPrint in code | Performance hit | `grep -r "debugPrint" lib/` |
| TODO comments | Unfinished work | `grep -r "TODO" lib/` |
| Hardcoded localhost | Won't work in prod | `grep -r "localhost" lib/` |
| API keys in code | Security risk | `grep -r "api_key" lib/` |
| Large APK size | Slow downloads | `flutter build apk --analyze-size` |

**Quick production check script:**
```bash
#!/bin/bash
echo "🔍 Production Readiness Check..."
echo ""

# 1. Debug prints
echo "1️⃣ Checking for debug prints..."
if grep -r "debugPrint\|print(" lib/ --exclude-dir=test | grep -v "//"; then
  echo "❌ Found debug prints! Remove before release."
else
  echo "✅ No debug prints"
fi
echo ""

# 2. TODOs
echo "2️⃣ Checking for TODOs..."
if grep -r "TODO\|FIXME" lib/ | grep -v "//" | head -5; then
  echo "⚠️ Found TODOs - review before release"
else
  echo "✅ No TODOs"
fi
echo ""

# 3. Hardcoded URLs
echo "3️⃣ Checking for hardcoded URLs..."
if grep -r "localhost\|127.0.0.1" lib/; then
  echo "❌ Found localhost URLs!"
else
  echo "✅ No hardcoded URLs"
fi
echo ""

# 4. API keys
echo "4️⃣ Checking for API keys..."
if grep -r "api_key\|apiKey" lib/ --exclude=firebase_options.dart; then
  echo "❌ Found API keys in code!"
else
  echo "✅ No exposed API keys"
fi
echo ""

echo "✅ Production check complete!"
```

**Environment config pattern:**
```dart
// ❌ Hardcoded
const apiUrl = 'http://localhost:3000';

// ✅ Environment-based
class Config {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.salsheli.com',
  );
  
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
  
  static bool get shouldLog => !isProduction;
}

// Usage:
// Dev: flutter run
// Prod: flutter run --dart-define=PRODUCTION=true
```

---

## 🗑️ Part 4: Dead Code Detection

**⚠️ NEVER delete file based on 0 imports alone!**

### 5-Step Verification Process:

1. **Full import search:** `"import.*file_name.dart"`
2. **Relative import search:** `"folder_name/file_name"` ← CRITICAL!
3. **Class name search:** `"ClassName"`
4. **Check related files:** (data→screens, config→providers, model→repositories)
5. **Read file itself:** Look for "EXAMPLE", "DO NOT USE", "דוגמה בלבד"

### Real Example from Project:
```powershell
# onboarding_data.dart LOOKS like Dead Code:
Ctrl+Shift+F → "import.*onboarding_data" → 0 results ❌

# BUT! Relative path search finds it:
Ctrl+Shift+F → "data/onboarding_data" → Found! ✅
# In onboarding_screen.dart: import '../../data/onboarding_data.dart';
```

### Safe to Delete (Confirmed):
- ✅ Files marked "EXAMPLE ONLY"
- ✅ Files marked "DO NOT USE"
- ✅ Debug screens not in routes
- ✅ After ALL 5 checks show 0 usage

### DO NOT Delete:
- ⚠️ 0 imports but found via relative path
- ⚠️ 0 imports but listed in routes
- ⚠️ 0 imports but used in Provider
- ⚠️ Any doubt → ASK USER

---

## 🟡 Part 5: Dormant Code

**Good code that's not currently used - activate or delete?**

### 4-Question Framework:

```
1. Does model support it?
   ✅ Yes → +1 point
   ❌ No → DELETE

2. Is it useful UX?
   ✅ Yes → +1 point
   ❌ No → DELETE

3. Is code quality high? (90+/100)
   ✅ Yes → +1 point
   ❌ No → DELETE

4. Quick to implement? (<30 min)
   ✅ Yes → +1 point
   ❌ No → DELETE
```

**Result:**
- **4/4 points** → 🚀 Activate!
- **0-3 points** → 🗑️ Delete

---

## ⚡ Part 6: 7 Auto-Fixes

**Apply these fixes automatically WITHOUT asking:**

### 1. Opacity API
```dart
// ❌ OLD - Deprecated
Colors.blue.withOpacity(0.5)

// ✅ NEW - Required
Colors.blue.withValues(alpha: 0.5)
```
**Why:** Flutter 3.22+ requirement

### 2. Async Callbacks
```dart
// ❌ WRONG - Type error
StickyButton(onPressed: _saveData)

// ✅ CORRECT - Lambda wrapper
StickyButton(onPressed: () => _saveData())
```
**Why:** Type safety for async functions

### 3. Mounted Check
```dart
// ❌ CRASH RISK
await fetchData();
setState(() {});

// ✅ SAFE
await fetchData();
if (!mounted) return;
setState(() {});
```
**Why:** Screen might be disposed during async operation

### 4. Dropdown API
```dart
// ❌ OLD
DropdownButton(value: 'Select...')

// ✅ NEW  
DropdownButton(initialValue: 'Select...')
```

### 5. Magic Numbers
```dart
// ❌ BAD - What is 16?
padding: EdgeInsets.all(16)

// ✅ GOOD - Clear constant
padding: EdgeInsets.all(kPaddingMedium)
```
**Location:** `lib/core/ui_constants.dart`

### 6. Const Widgets
```dart
// ❌ INEFFICIENT
SizedBox(height: 8)

// ✅ EFFICIENT
const SizedBox(height: 8)
```
**Why:** Performance - single instance reused

### 7. Sticky Notes Design
**Every UI screen must use Sticky Notes design system**  
If missing → suggest conversion immediately

---

## 🏗️ Part 7: Architectural Rules (NEVER Violate!)

### 1. Repository Pattern - Mandatory
```dart
// ❌ FORBIDDEN - Direct Firebase in screens
FirebaseFirestore.instance.collection('items').get()

// ✅ REQUIRED - Through repository
_repository.fetchItems()
```

### 2. household_id Filter - Always Required
```dart
// ❌ SECURITY ISSUE
firestore.collection('lists').get()

// ✅ SECURE
firestore
  .collection('lists')
  .where('household_id', isEqualTo: userHouseholdId)
  .get()
```

### 3. Loading States - All 4 Required
```dart
if (isLoading) return SkeletonScreen();
if (hasError) return ErrorWidget();
if (isEmpty) return EmptyWidget();
return DataWidget();
```

### 4. UserContext Listeners - Must Dispose
```dart
class MyProvider extends ChangeNotifier {
  MyProvider(this._userContext) {
    _userContext.addListener(_onUserChanged);
  }
  
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged);
    super.dispose();
  }
}
```

---

## 🔒 Part 8: Security Best Practices

### Critical Security Checks

**Before EVERY commit:**
```dart
// ✅ Check 1: No API keys in code
grep -r "AIza" lib/
grep -r "api_key" lib/

// ✅ Check 2: No passwords
grep -r "password.*=" lib/

// ✅ Check 3: All queries have household_id
grep -r "collection(" lib/repositories/

// ✅ Check 4: No sensitive data in logs
grep -r "debugPrint.*password" lib/
grep -r "debugPrint.*token" lib/
```

### Security Patterns

```dart
// ✅ Validate household_id before operations
assert(householdId == userContext.currentHouseholdId,
  'household_id mismatch!');

// ✅ Never log sensitive data
debugPrint('User logged in: ${user.uid}'); // ✅
debugPrint('Password: $password');         // ❌ NEVER!

// ✅ Verify ownership
if (data['created_by'] != currentUserId) {
  throw Exception('Unauthorized');
}
```

---

## ⚡ Part 9: Performance Optimization

### Performance Rules

| Issue | Bad ❌ | Good ✅ | Impact |
|-------|-------|---------|--------|
| Const widgets | `SizedBox(height: 8)` | `const SizedBox(height: 8)` | -30% rebuilds |
| ListView | `ListView(children: [...])` | `ListView.builder(...)` | -70% memory |
| Image caching | `Image.network(url)` | `CachedNetworkImage(url)` | -80% loading |
| Late init | `Widget? _widget;` | `late Widget _widget;` | Cleaner null safety |
| Batch processing | Load all at once | Batch 50-100 items | -90% lag |

### Debouncing Pattern
```dart
Timer? _debounceTimer;

void _handleSearch(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _performSearch(query); // Only run once after typing stops
  });
}
```

### Isolate for Heavy Computations
```dart
// ❌ Blocks UI
final result = _heavyComputation(data);

// ✅ Runs in background
final result = await compute(_heavyComputation, data);
```

---

## ♿ Part 10: Accessibility Guidelines

### Accessibility Checklist

**Every new screen:**
```dart
// ✅ Minimum sizes
// Buttons: 44-48px height
// Text: 11px minimum
// Touch target: 44x44px minimum

// ✅ Contrast ratios
// Normal text: 4.5:1
// Large text: 3:1

// ✅ Semantics for custom widgets
Semantics(
  button: true,
  label: 'התחבר למערכת',
  enabled: !_isLoading,
  child: MyCustomButton(...),
)

// ✅ Screen readers
// Test with TalkBack (Android) / VoiceOver (iOS)
```

---

## 🐛 Part 11: Error Handling Standards

### Error Handling Pattern

**Every async function must have:**
```dart
Future<void> myFunction() async {
  try {
    await operation();
    
    // ⚠️ Check mounted before setState
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      _errorMessage = null; // ← Clear errors!
    });
  } catch (e) {
    debugPrint('❌ myFunction: $e');
    
    if (!mounted) return;
    
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

### Logging Standards

**Use emojis for quick identification:**
```dart
debugPrint('🚀 LoginScreen: initState');
debugPrint('🔄 Logging in...');
debugPrint('✅ Login successful');
debugPrint('❌ Login failed: $e');
debugPrint('💾 Saving data...');
debugPrint('🗑️ Deleting item...');
```

---

## 🧪 Part 12: Testing Guidelines

### When to Write Tests

- ✅ **Every Model** → Unit test (JSON serialization, copyWith)
- ✅ **Every Provider** → Unit test + Widget test
- ✅ **Every Repository** → Unit test (mock Firebase)
- ⚠️ **UI Screens** → Optional but recommended

### Coverage Targets

| Component | Target | Priority |
|-----------|--------|----------|
| Models | 90%+ | High |
| Providers | 80%+ | High |
| Repositories | 85%+ | High |
| Services | 75%+ | Medium |
| UI | 60%+ | Low |

### Quick Test Example

```dart
test('Provider loads items successfully', () async {
  // Arrange
  final mockRepo = MockRepository();
  when(mockRepo.fetchItems()).thenAnswer((_) async => [item1, item2]);
  
  final provider = MyProvider(mockRepo);
  
  // Act
  await provider.load();
  
  // Assert
  expect(provider.items, hasLength(2));
  expect(provider.isLoading, isFalse);
  expect(provider.hasError, isFalse);
});
```

---

## 🎨 Part 13: Sticky Notes Design System

### Required Structure for ALL UI Screens:

```dart
Scaffold(
  backgroundColor: kPaperBackground,
  body: Stack(
    children: [
      const NotebookBackground(),  // Lined paper background
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kPaddingMedium),
          child: Column(
            children: [
              const StickyNoteLogo(),
              const SizedBox(height: 8),
              StickyNote(
                color: kStickyYellow,
                rotation: -0.02,
                child: /* content */,
              ),
              StickyButton(
                label: 'Continue',
                color: kStickyPink,
                onPressed: () => _handleAction(),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Color Palette:
- **kStickyYellow** - Important info
- **kStickyPink** - Action buttons
- **kStickyGreen** - Success
- **kStickyBlue** - Information
- **kStickyCyan** - Input fields
- **kStickyOrange** - Warnings

**Rule:** Max 3 colors per screen

**📖 Full design guide:** See `DESIGN_GUIDE.md`

---

## 📊 Part 14: Quick Problem Solving

### Common Issues Table (30-second solutions):

| Problem | Solution | Reference |
|---------|----------|-----------|
| File not used | 5-step verification | Part 4 |
| Good code not used | 4-question framework | Part 5 |
| Provider not updating | addListener + removeListener | Part 7.4 |
| Timestamp errors | @TimestampConverter() | DEVELOPER_GUIDE |
| Auth race condition | Throw exception on error | DEVELOPER_GUIDE |
| Mock data in code | Connect to real Provider | DEVELOPER_GUIDE |
| Context after async | Save dialogContext separately | Part 11 |
| withOpacity deprecated | .withValues(alpha:) | Part 6.1 |
| Slow UI | Debouncing + Isolate | Part 9 |
| Slow save | Batch processing (50-100) | Part 9 |
| Missing empty state | 4 states required | Part 7.3 |
| Boring loading | Use Skeleton Screen | DESIGN_GUIDE |
| No animations | Add micro animations | DESIGN_GUIDE |
| Hardcoded values | Use constants from lib/core/ | Part 6.5 |
| Security issue | Check household_id + no sensitive logs | Part 8 |
| Poor performance | const + ListView.builder + caching | Part 9 |
| Accessibility issue | Sizes 44px+, contrast 4.5:1+ | Part 10 |
| Empty list name | Validation: trim + isEmpty check | Part 3.7 |
| Invalid quantity | Validation: 1-9999 range | Part 3.7 |
| Missing notifyListeners | Add after every state change | Part 3.8 |
| Listener not removed | Add removeListener in dispose | Part 3.8 |
| Race condition | Add if (_isLoading) return | Part 3.8 |
| Controller not disposed | Add dispose() method | Part 3.9 |
| OCR not closed | Call textRecognizer.close() | Part 3.9 |
| Stream not cancelled | Cancel subscription in dispose | Part 3.9 |
| Batch > 500 operations | Split into 500-item batches | Part 3.10 |
| Query without limit | Add .limit(50) | Part 3.10 |
| Listener no error handler | Add onError callback | Part 3.10 |
| API no timeout | Add .timeout(10 seconds) | Part 3.11 |
| API no retry | Retry 3x with backoff | Part 3.11 |
| debugPrint in production | Remove all debugPrint | Part 3.12 |
| Hardcoded localhost | Use environment variables | Part 3.12 |

---

## 📁 Part 15: Project Structure

```
lib/
├── core/
│   ├── ui_constants.dart       # All UI constants
│   └── theme.dart              # App theme
├── models/
├── providers/
│   ├── user_context_provider.dart  # CRITICAL for household switching
│   └── ...
├── repositories/               # ONLY place for Firebase calls
├── screens/
├── widgets/
│   ├── sticky_note.dart
│   ├── sticky_button.dart
│   ├── sticky_note_logo.dart
│   └── notebook_background.dart
└── main.dart
```

---

## 🔗 Part 16: Documentation References

### The 5 Core Documents

| Document | Purpose | When to use |
|----------|---------|-------------|
| **AI_MASTER_GUIDE.md** | AI instructions | Every conversation start |
| **DEVELOPER_GUIDE.md** | Code patterns & best practices | Writing/reviewing code |
| **DESIGN_GUIDE.md** | UI/UX guidelines | Creating screens |
| **GETTING_STARTED.md** | Quick start | First time setup |
| **PROJECT_INFO.md** | Project overview | Understanding architecture |

### Quick Links

**Need help with:**
- Architecture patterns → DEVELOPER_GUIDE.md
- UI design → DESIGN_GUIDE.md
- Getting started → GETTING_STARTED.md
- Project info → PROJECT_INFO.md

---

## ⚠️ Part 17: Top 10 Common Mistakes

### 1. שכחת mounted check
**Symptom:** "setState called after dispose"  
**Fix:** See Part 6.3

### 2. withOpacity במקום withValues
**Symptom:** Deprecated warning  
**Fix:** See Part 6.1

### 3. Firebase ישירות במסך
**Symptom:** Tight coupling, hard to test  
**Fix:** See Part 7.1

### 4. חסר household_id
**Symptom:** Security vulnerability  
**Fix:** See Part 7.2

### 5. לא בדק async callback type
**Symptom:** Type error  
**Fix:** See Part 6.2

### 6. Context לא נשמר לפני await
**Symptom:** Invalid context error  
**Fix:** See Part 11

### 7. חסר 4 Empty States
**Symptom:** Poor UX  
**Fix:** See Part 7.3

### 8. const חסר
**Symptom:** Poor performance  
**Fix:** See Part 6.6

### 9. API keys בקוד
**Symptom:** Security vulnerability  
**Fix:** See Part 8

### 10. גובה כפתור < 44px
**Symptom:** Accessibility issue  
**Fix:** See Part 10

### 11. שם רשימה ריק / כמות לא תקינה 🆕
**Symptom:** Invalid data saved to Firestore  
**Fix:** See Part 3.7 - Add validation

### 12. notifyListeners חסר 🆕
**Symptom:** UI doesn't update after state change  
**Fix:** See Part 3.8 - Add notifyListeners()

### 13. Listener לא מנותק 🆕
**Symptom:** Memory leak, app slows down over time  
**Fix:** See Part 3.8 - Add removeListener in dispose

### 14. Batch > 500 operations 🆕
**Symptom:** Firestore error: "Maximum 500 writes per batch"  
**Fix:** See Part 3.10 - Split into 500-item batches

### 15. API ללא timeout 🆕
**Symptom:** App stuck waiting, poor UX  
**Fix:** See Part 3.11 - Add timeout(Duration(seconds: 10))

### 16. debugPrint בפרודקשן 🆕
**Symptom:** Performance hit in production  
**Fix:** See Part 3.12 - Remove all debugPrint before release

---

## 🎯 Part 18: TL;DR - 10-Second Reminder

**Every new conversation:**
1. ✅ All responses in Hebrew (except code)
2. ✅ Auto-fix: withOpacity → withValues
3. ✅ Auto-fix: Async callbacks wrapped
4. ✅ Auto-check: Sticky Notes Design
5. ✅ Auto-check: 5-step Dead Code verification
6. ✅ Auto-check: Security (household_id, no API keys)
7. ✅ Auto-check: Performance (const, ListView.builder)
8. ✅ Auto-check: Accessibility (sizes, contrast)
9. 🆕 Auto-check: Business Logic (validation, empty checks)
10. 🆕 Auto-check: State Management (notifyListeners, removeListener)
11. 🆕 Auto-check: Memory Leaks (dispose Controllers, Streams, OCR)
12. 🆕 Auto-check: Firebase (batch size, limits, error handlers)
13. 🆕 Auto-check: API Integration (timeout, retry, proper errors)
14. 🆕 Auto-check: Production Readiness (debugPrint, TODOs, hardcoded URLs)
15. ✅ Use Filesystem:edit_file (not artifacts)
16. ✅ Fix tech errors WITHOUT asking
17. ✅ Ask before major changes only

**If in doubt → Check DEVELOPER_GUIDE.md**

---

## 📌 Critical Reminders

### Communication
- 🗣️ **Hebrew responses** - User is Hebrew speaker, beginner developer
- 🛠️ **edit_file preferred** - User dislikes unnecessary artifacts
- 📝 **Concise feedback** - Don't over-explain simple fixes

### Code Review
- 🔍 **5-step verification** - Before declaring code "dead"
- 🎨 **Sticky Notes mandatory** - For ALL UI screens
- 🔒 **Security first** - household_id, no sensitive logs
- ⚡ **Performance matters** - const, ListView.builder, caching
- ♿ **Accessibility required** - 44px buttons, 11px text, 4.5:1 contrast

### Architecture
- 🏗️ **4 rules never break:**
  1. Repository Pattern
  2. household_id in all queries
  3. 4 Loading States
  4. UserContext listeners cleanup

### Quality
- ✅ **Auto-fix when clear** - Don't ask permission for technical corrections
- 🧪 **Test coverage** - Models 90%+, Providers 80%+, Repositories 85%+
- 📖 **Documentation** - File headers + function docs
- 🐛 **Error handling** - try-catch + mounted checks

---

## 📈 Version History

### v2.2 - 18/10/2025 🆕
- ✅ **3 More Critical Auto-Checks Added:**
  1. Firebase Best Practices (batch size, limits, error handlers)
  2. API Integration (timeout, retry, proper error handling)
  3. Production Readiness (debugPrint, TODOs, hardcoded URLs)
- ✅ **Updated checklists:** Now **12 auto-checks** instead of 9
- ✅ **Top 16 mistakes:** Added 3 critical production issues
- ✅ **Production check script:** Ready-to-use bash script

### v2.1 - 18/10/2025 🆕
- ✅ **3 New Auto-Checks Added:**
  1. Business Logic Validation (empty checks, range validation)
  2. State Management Issues (notifyListeners, removeListener)
  3. Memory Leaks (Controllers, Streams, OCR cleanup)
- ✅ **Updated checklists:** Now 9 auto-checks instead of 6
- ✅ **Salsheli-specific examples:** Real code from the project
- ✅ **Top 13 mistakes:** Added 3 common issues

### v2.0 - 18/10/2025
- ✅ **Major update:** Added Security, Performance, Accessibility, Testing, Error Handling
- ✅ **Unified documentation:** Single source of truth for AI
- ✅ **Top 10 mistakes:** Common pitfalls + solutions
- ✅ **Enhanced checklists:** More comprehensive coverage

### v1.0 - 18/10/2025
- 🎉 Initial unified guide
- Basic AI behavior instructions
- Code review guidelines
- Technical rules

---

**Version:** 2.2 🚀  
**Created:** 18/10/2025  
**Purpose:** Complete AI behavior guide - single source of truth  
**Last Update:** Added Firebase, API Integration, Production Readiness checks  
**Made with ❤️ by Humans & AI** 👨‍💻🤖
