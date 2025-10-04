# 📋 CODE_REVIEW_CHECKLIST

> בדיקה מהירה לפני עבודה על קבצים בפרויקט. קרא עם MOBILE_GUIDELINES.md

---

## ✅ כל קובץ חייב

- [ ] תיעוד בראש: `// 📄 File: path/to/file.dart`
- [ ] אין `dart:html`, `localStorage`, `sessionStorage`
- [ ] אין `Platform.isWindows/isMacOS`

---

## 🗂️ לפי סוג קובץ

### Providers

- [ ] `ChangeNotifier` + `dispose()`
- [ ] מחובר ל-Repository (לא פעולות ישירות)
- [ ] Getters: `unmodifiable` או `immutable`
- [ ] async עם `try/catch`
- [ ] **ProxyProvider:** `lazy: false` אם צריך אתחול מיידי
- [ ] **ProxyProvider:** בדיקה ב-`update()` למנוע כפילויות

```dart
// ✅ טוב
class MyProvider with ChangeNotifier {
  final MyRepository _repo;
  List<Item> _items = [];
  
  List<Item> get items => List.unmodifiable(_items);
  
  Future<void> load() async {
    try {
      _items = await _repo.fetch();
      notifyListeners();
    } catch (e) { }
  }
}

// ❌ רע
class BadProvider with ChangeNotifier {
  List<Item> items = []; // ניתן לשינוי
  Future<void> load() async {
    items = await http.get(...); // ישיר בלי Repository
  }
}
```

---

### Screens

- [ ] `SafeArea`
- [ ] תוכן scrollable אם ארוך
- [ ] `Consumer`/`context.watch` לקריאת state
- [ ] `context.read` לפעולות בלבד
- [ ] כפתורים 48x48 מינימום
- [ ] padding symmetric (RTL)

```dart
// ✅ טוב
Scaffold(
  body: SafeArea(
    child: Consumer<MyProvider>(
      builder: (context, provider, _) => 
        ListView(...), // scrollable
    ),
  ),
);

// ❌ רע
Container(
  width: 1920, // גודל קבוע
  padding: EdgeInsets.only(left: 16), // לא RTL
);
```

---

### Models

- [ ] `@JsonSerializable()` (אם JSON)
- [ ] שדות `final`
- [ ] `copyWith()` method
- [ ] `*.g.dart` קיים
- [ ] **Hive:** `@HiveType` + `@HiveField` על כל שדה

```dart
@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  
  const MyModel({required this.id, required this.name});
  
  MyModel copyWith({String? name}) => 
    MyModel(id: id, name: name ?? this.name);
  
  factory MyModel.fromJson(Map<String, dynamic> json) => 
    _$MyModelFromJson(json);
}
```

---

### Repositories

- [ ] יש ממשק (`abstract class`)
- [ ] async עם `Future`
- [ ] מחזיר מודלים, לא JSON
- [ ] **Hybrid:** Fallback אם API נכשל
- [ ] **Hive:** TypeAdapter רשום

```dart
abstract class MyRepository {
  Future<List<Item>> fetch();
}

class LocalRepo implements MyRepository {
  @override
  Future<List<Item>> fetch() async {
    // SharedPreferences / Hive
  }
}
```

---

### Services

- [ ] שיטות `static`
- [ ] פרמטרים nullable עם בדיקות
- [ ] Logging מפורט (`debugPrint`)
- [ ] **חישובים אמיתיים אם יש נתונים** - לא תמיד Mock!
- [ ] Fallback רק אם אין נתונים
- [ ] תיעוד TODO למה שחסר

```dart
class MyService {
  static Future<Stats> calculate({
    required List<Item> items,
  }) async {
    debugPrint('📊 מחשב...');
    
    // ✅ חישוב אמיתי
    if (items.isNotEmpty) {
      final result = items.fold(0, (sum, i) => sum + i.value);
      debugPrint('   ✅ תוצאה: $result');
      return Stats(result);
    }
    
    // Fallback רק אם אין נתונים
    debugPrint('   ⚠️ אין נתונים - fallback');
    return Stats(0);
  }
}

// ❌ רע
class BadService {
  List<Item> items = []; // יש state
  
  double calculate() { // לא static, לא async
    return items.length * 1.5; // תמיד Mock!
  }
}
```

---

### Caching

- [ ] Cache key מכל המשתנים
- [ ] ניקוי כשמשתנים משתנים
- [ ] Getter בודק cache לפני חישוב

```dart
List<Item> _cached = [];
String _cacheKey = "";

List<Item> get items {
  final key = "$location|$search";
  if (key == _cacheKey) return _cached;
  
  _cached = _filter();
  _cacheKey = key;
  return _cached;
}

void updateFilter() {
  _cacheKey = ""; // נקה
  setState(() {});
}
```

---

### JSON Handling

- [ ] בדיקת סוג (`is List` / `is Map`)
- [ ] Logging של רכיב ראשון
- [ ] `whereType<T>()` validation
- [ ] Error handling

```dart
final data = json.decode(content);
debugPrint('סוג: ${data.runtimeType}');

if (data is List) {
  return data
    .whereType<Map<String, dynamic>>()
    .map((i) => Item.fromJson(i))
    .toList();
}
return [];
```

---

### Undo Pattern

- [ ] שמירת **כל** הנתונים לפני מחיקה
- [ ] `SnackBarAction` לביטול
- [ ] duration: 5+ שניות
- [ ] שחזור מדויק

```dart
void _delete(String key, String name, String emoji) {
  // שמור לפני!
  final saved = (key: key, name: name, emoji: emoji);
  
  provider.delete(key);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('נמחק "$name"'),
      action: SnackBarAction(
        label: 'בטל',
        onPressed: () => provider.add(saved.name, emoji: saved.emoji),
      ),
      duration: Duration(seconds: 5),
    ),
  );
}
```

---

### i18n Mappings

- [ ] תמיכה בעברית **וגם** אנגלית
- [ ] Fallback אם Key לא נמצא
- [ ] לוגיקה: עברית → אנגלית → fallback

```dart
class Mapper {
  static const _he = {'חלבי': '🥛', 'ירקות': '🥬'};
  static const _en = {'dairy': '🥛', 'vegetables': '🥬'};
  
  static String get(String key) {
    return _he[key] ?? _en[key] ?? '📦';
  }
}
```

---

## 🎨 UI Specifics

**Touch Targets:** 48x48 מינימום  
**Font Sizes:** 14-24px  
**Spacing:** כפולות של 8 (8, 16, 24)  
**Colors (Flutter 3.27+):** `withValues(alpha: 0.5)` לא `withOpacity`

---

## 🔍 בדיקה מהירה

**Ctrl+F חפש:**
- `dart:html` → ❌
- `localStorage` → ❌
- `Platform.is` → ❌
- `debugPrint` → אם אין = ⚠️ חסר logging
- `TODO` → סמן לעתיד

**שורה ראשונה:** יש `// 📄 File:` ? אם לא = ❌

**Providers:** יש `_repository`? אם אין = ⚠️ בעיה

**Services:** כל מתודה `static`? אם לא = ❌

---

## 📊 זמני בדיקה

| סוג             | זמן      |
| --------------- | -------- |
| Provider        | 2-3 דק'  |
| Screen          | 3-4 דק'  |
| Model           | 1-2 דק'  |
| Hive Model      | 2-3 דק'  |
| Repository      | 2 דק'    |
| Service         | 3 דק'    |
| Cache/JSON/Undo | 1-2 דק'  |

---

**גרסה:** 3.0 (מצומצם)  
**תאימות:** Flutter 3.27+, Mobile Only
