# 📋 CODE_REVIEW_CHECKLIST.md

> **תיעוד:** מדריך בדיקת קבצים לפרויקט "סל שלי" (Mobile-Only Flutter App)  
> **שימוש:** קרא קובץ זה ביחד עם MOBILE_GUIDELINES.md לפני בדיקת קוד

**לקריאה:** Claude Code - קרא קובץ זה לפני כל עבודה על הפרויקט!

---

## 🎯 מטרת הקובץ

קובץ זה עוזר לבדוק קבצים בפרויקט בצורה מהירה ושיטתית. הוא **משלים** את MOBILE_GUIDELINES.md ולא מחליף אותו.

---

## 📚 כללי זהב - תמיד בדוק!

### ✅ כל קובץ חייב

- [ ] **תיעוד בראש הקובץ** - נתיב + תיאור קצר

  ```dart
  // 📄 File: lib/providers/shopping_lists_provider.dart
  // תיאור: Provider לניהול רשימות קניות
  ```

- [ ] **אין Web imports**

  ```dart
  // ❌ אסור
  import 'dart:html';

  // ✅ מותר
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  ```

- [ ] **אין שימוש ב-localStorage/sessionStorage**

  ```dart
  // ❌ אסור
  localStorage.setItem('key', 'value');

  // ✅ מותר
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('key', 'value');
  ```

---

## 🗂️ בדיקה לפי סוג קובץ

### 1️⃣ Providers (State Management)

#### ✅ Checklist מהיר

- [ ] משתמש ב-`ChangeNotifier`
- [ ] מחובר ל-Repository (לא עושה פעולות ישירות)
- [ ] יש `dispose()` אם צריך
- [ ] Getters מחזירים `unmodifiable` או `immutable`
- [ ] כל פעולה async עם try/catch

#### 📝 דוגמה

```dart
// ✅ טוב - Provider נכון
class ShoppingListsProvider with ChangeNotifier {
  final ShoppingListsRepository _repository;
  List<ShoppingList> _lists = [];

  ShoppingListsProvider({required ShoppingListsRepository repository})
      : _repository = repository;

  // ✅ Getter מוגן
  List<ShoppingList> get lists => List.unmodifiable(_lists);

  // ✅ פעולה דרך Repository
  Future<void> loadLists() async {
    try {
      _lists = await _repository.fetchLists(householdId);
      notifyListeners();
    } catch (e) {
      // טיפול בשגיאה
    }
  }

  @override
  void dispose() {
    // ניקוי
    super.dispose();
  }
}

// ❌ רע - Provider לא נכון
class BadProvider with ChangeNotifier {
  List<ShoppingList> lists = []; // ❌ ניתן לשינוי מבחוץ

  // ❌ קריאה ישירה ל-API בלי Repository
  Future<void> loadLists() async {
    final response = await http.get('https://api.com/lists');
    lists = jsonDecode(response.body);
    notifyListeners();
  }
}
```

---

### 2️⃣ Screens (UI)

#### ✅ Checklist מהיר

- [ ] עוטף ב-`SafeArea`
- [ ] כל תוכן scrollable (אם ארוך)
- [ ] משתמש ב-`Consumer` או `context.watch` לקריאת state
- [ ] משתמש ב-`context.read` לפעולות בלבד
- [ ] כפתורים בגודל מינימלי 48x48
- [ ] אין גדלים קבועים (hard-coded)
- [ ] padding symmetric (לא only - בגלל RTL)

#### 📝 דוגמה

```dart
// ✅ טוב - Screen נכון
class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // ✅ SafeArea
        child: Consumer<ShoppingListsProvider>( // ✅ Consumer
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder( // ✅ scrollable
              padding: EdgeInsets.symmetric(horizontal: 16), // ✅ symmetric
              itemCount: provider.lists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  minVerticalPadding: 24, // ✅ גודל מגע מספיק
                  title: Text(provider.lists[index].name),
                  onTap: () {
                    // ✅ פעולה עם context.read
                    context.read<ShoppingListsProvider>().openList(index);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ❌ רע - Screen לא נכון
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ אין SafeArea
    // ❌ קריאת Provider בלי Consumer
    final provider = context.read<ShoppingListsProvider>();

    return Container(
      width: 1920, // ❌ גודל קבוע
      height: 1080, // ❌ גודל קבוע
      padding: EdgeInsets.only(left: 16), // ❌ לא תומך RTL
      child: Column( // ❌ לא scrollable
        children: provider.lists.map((list) =>
          GestureDetector(
            child: Container(
              width: 30, // ❌ גודל מגע קטן מדי
              height: 30,
              child: Text(list.name),
            ),
          )
        ).toList(),
      ),
    );
  }
}
```

---

### 3️⃣ Models (Data Classes)

#### ✅ Checklist מהיר

- [ ] יש `@JsonSerializable()`
- [ ] שדות `final` (immutable)
- [ ] יש `copyWith()` method
- [ ] יש `*.g.dart` file
- [ ] constructor נכון עם `required`/optional

#### 📝 דוגמה

```dart
// ✅ טוב - Model נכון
@JsonSerializable(explicitToJson: true)
class ShoppingList {
  final String id;
  final String name;
  final List<ReceiptItem> items;

  const ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
  });

  ShoppingList copyWith({
    String? name,
    List<ReceiptItem>? items,
  }) {
    return ShoppingList(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);

  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);
}

// ❌ רע - Model לא נכון
class BadModel {
  String id; // ❌ לא final
  String name; // ❌ לא final
  List<ReceiptItem> items; // ❌ ניתן לשינוי

  BadModel(this.id, this.name, this.items);

  // ❌ אין copyWith
  // ❌ אין JSON serialization
}
```

---

### 4️⃣ Repositories (Data Layer)

#### ✅ Checklist מהיר

- [ ] יש ממשק (abstract class)
- [ ] פעולות async עם Future
- [ ] שמות פעולות ברורים (fetch, save, delete)
- [ ] לא עושה notifyListeners (זה תפקיד Provider!)
- [ ] מחזיר מודלים, לא JSON

#### 📝 דוגמה

```dart
// ✅ טוב - Repository נכון

// ממשק
abstract class ShoppingListsRepository {
  Future<List<ShoppingList>> fetchLists(String householdId);
  Future<ShoppingList> saveList(ShoppingList list, String householdId);
  Future<void> deleteList(String id, String householdId);
}

// מימוש מקומי
class LocalShoppingListsRepository implements ShoppingListsRepository {
  final SharedPreferences _prefs;

  @override
  Future<List<ShoppingList>> fetchLists(String householdId) async {
    final json = _prefs.getString('lists_$householdId');
    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((item) => ShoppingList.fromJson(item)).toList();
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list, String householdId) async {
    // שמירה...
    return list;
  }
}

// ❌ רע - Repository לא נכון
class BadRepository {
  // ❌ לא async
  List<ShoppingList> getLists() {
    return [];
  }

  // ❌ מחזיר JSON במקום מודל
  Map<String, dynamic> getList(String id) {
    return {};
  }
}
```

---

## 🎨 בדיקות UI ספציפיות

### Touch Targets (גודל מינימלי)

```dart
// ✅ טוב
GestureDetector(
  onTap: () {},
  child: Container(
    width: 48,
    height: 48,
    child: Icon(Icons.close),
  ),
)

// ❌ רע
IconButton(
  iconSize: 16, // ❌ קטן מדי
  onPressed: () {},
  icon: Icon(Icons.close),
)
```

### Font Sizes

```dart
// ✅ טוב
TextStyle(
  fontSize: 14, // Body
  fontSize: 16, // Body Large
  fontSize: 20, // Heading
  fontSize: 24, // Title
)

// ❌ רע
TextStyle(
  fontSize: 10, // ❌ קטן מדי
  fontSize: 32, // ❌ גדול מדי לכותרת מובייל
)
```

### Spacing (ריווחים)

```dart
// ✅ טוב - כפולות של 8
padding: EdgeInsets.all(8)
padding: EdgeInsets.all(16)
padding: EdgeInsets.all(24)
SizedBox(height: 8)

// ❌ רע - לא עקבי
padding: EdgeInsets.all(13)
SizedBox(height: 7)
```

---

## 🚀 הנחיות ל-Claude Code

כשאתה (Claude Code) עובד על פרויקט זה:

### 1. לפני כל עבודה

- [ ] קרא את `MOBILE_GUIDELINES.md`
- [ ] קרא את `CODE_REVIEW_CHECKLIST.md` (הקובץ הזה)
- [ ] בדוק איזה סוג קובץ אתה הולך לעבוד עליו

### 2. בזמן עבודה

- [ ] השתמש ב-checklist המתאים מלמעלה
- [ ] בדוק כל נקודה לפני שממשיך
- [ ] אם לא בטוח - **שאל** את המשתמש!

### 3. לפני שליחת הקובץ

- [ ] עבור על הchecklist שוב
- [ ] ודא שיש תיעוד בראש הקובץ
- [ ] הרץ `flutter analyze` מנטלית

### 4. דוגמה לתגובה טובה

```
✅ בדקתי את הקובץ לפי CODE_REVIEW_CHECKLIST.md:

Provider:
✅ מחובר ל-Repository
✅ יש dispose()
✅ Getters מוגנים
✅ Error handling

UI:
✅ SafeArea
✅ Consumer לstate
✅ גדלי מגע 48x48+

הקובץ תקין ומוכן לשימוש!
```

---

## 🔍 טיפים לבדיקה מהירה

### איך למצוא בעיות מהר?

1. **חפש בקובץ:**

   - `Ctrl+F` → `dart:html` → אם מצאת = ❌ בעיה
   - `Ctrl+F` → `localStorage` → אם מצאת = ❌ בעיה
   - `Ctrl+F` → `Platform.isWindows` → אם מצאת = ❌ בעיה

2. **בדוק את השורה הראשונה:**

   - יש `// 📄 File:` = ✅ טוב
   - אין = ❌ הוסף תיעוד

3. **בדוק imports:**

   - רק `package:flutter` ו-`package:` אחרים = ✅ טוב
   - יש `dart:html` = ❌ בעיה

4. **אם זה Screen:**

   - חפש `SafeArea` = אם אין = ⚠️ אולי בעיה
   - חפש `Consumer` או `context.watch` = צריך להיות

5. **אם זה Provider:**
   - חפש `_repository` = צריך להיות
   - חפש `http.get` או `http.post` ישירות = ❌ בעיה (צריך דרך Repository)

---

## 📊 סיכום מהיר

| סוג קובץ   | בדיקה ראשית                           | זמן משוער |
| ---------- | ------------------------------------- | --------- |
| Provider   | Repository + ChangeNotifier + dispose | 2-3 דקות  |
| Screen     | SafeArea + Consumer + Touch Targets   | 3-4 דקות  |
| Model      | @JsonSerializable + copyWith + final  | 1-2 דקות  |
| Repository | Abstract + async + מחזיר מודלים       | 2 דקות    |

---

## ✨ הערה אחרונה

קובץ זה **לא מחליף** את MOBILE_GUIDELINES.md - הוא **משלים** אותו.

- **MOBILE_GUIDELINES.md** = הנחיות כלליות מפורטות
- **CODE_REVIEW_CHECKLIST.md** (הקובץ הזה) = בדיקה מהירה לקובץ ספציפי

**השתמש בשניהם יחד!**

---

**עדכון אחרון:** ספטמבר 2025  
**גרסה:** 1.0.0  
**תאימות:** Flutter 3.x, Dart 3.x, Mobile Only (Android & iOS)
