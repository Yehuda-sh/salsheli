# 📱 Mobile Development Guidelines

> **⚠️ קריטי:** פרויקט זה הוא **אפליקציית מובייל בלבד** (Android & iOS).  
> אין תמיכה ב-Web/Desktop.

---

## 🌟 כללי זהב

### 1. Mobile-First
```dart
// ✅ טוב
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      child: Column(/* ... */),
    ),
  ),
);

// ❌ רע
Container(height: 900, child: Column(/* ... */));  // גובה קבוע
```

### 2. RTL Support
```dart
// ✅ טוב
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// ❌ רע
padding: EdgeInsets.only(left: 16, right: 8)  // לא עובד RTL
```

### 3. Responsive
```dart
// ✅ טוב
final screenWidth = MediaQuery.of(context).size.width;
const minTouchTarget = 48.0;

// ❌ רע
const buttonWidth = 300.0;  // קבוע
```

---

## 🚫 אסור בהחלט

### Browser/Web APIs
```dart
// ❌ אסור
import 'dart:html';
window.localStorage.setItem(/* ... */);

// ✅ מותר
import 'package:shared_preferences/shared_preferences.dart';
final prefs = await SharedPreferences.getInstance();
```

### Desktop Checks
```dart
// ✅ מותר
if (Platform.isAndroid) { /* ... */ }
if (Platform.isIOS) { /* ... */ }

// ❌ אסור
if (Platform.isWindows) { /* ... */ }
```

### Fixed Dimensions
```dart
// ❌ אסור
Container(width: 1920, height: 1080)

// ✅ מותר
Container(
  width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.3,
)
```

---

## 🏗️ ארכיטקטורה

```
UI (Screens/Widgets)
    ↓
Providers (ChangeNotifier)
    ↓
Services (Business Logic)
    ↓
Repositories (Data Access)
    ↓
Data Sources (Local/Remote)
```

### הפרדת אחריות
```dart
// ✅ טוב
class MyProvider extends ChangeNotifier {
  final MyRepository _repository;
  
  Future<void> loadData() async {
    final data = await _repository.fetch();
    notifyListeners();
  }
}

// ❌ רע - לוגיקה ב-Widget
class MyWidget extends StatelessWidget {
  Widget build(context) {
    http.get('https://api.example.com/data');  // ❌
    return Container();
  }
}
```

---

## 🚀 Splash & Navigation

### סדר בדיקות נכון

**כלל זהב:** בדוק userId לפני seenOnboarding!

```dart
// ✅ טוב
Future<void> _checkAndNavigate() async {
  final prefs = await SharedPreferences.getInstance();

  // 1️⃣ קודם: האם מחובר?
  final userId = prefs.getString('userId');
  if (userId != null) {
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
    return;
  }

  // 2️⃣ שנית: האם ראה onboarding?
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  if (!seenOnboarding) {
    if (mounted) Navigator.pushReplacement(/* WelcomeScreen */);
    return;
  }

  // 3️⃣ ברירת מחדל
  if (mounted) Navigator.pushReplacementNamed(context, '/login');
}
```

### Error Handling + Mounted Checks
```dart
// ✅ טוב
Future<void> _checkAndNavigate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // ... בדיקות ...
  } catch (e) {
    debugPrint('Error: $e');
    if (mounted) {
      Navigator.pushReplacement(/* WelcomeScreen - fallback */);
    }
  }
}
```

### Template מלא
```dart
class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});
  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
      if (!seenOnboarding) {
        if (mounted) Navigator.pushReplacement(/* Welcome */);
        return;
      }

      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) Navigator.pushReplacement(/* Welcome */);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
```

---

## 🎨 UI/UX

```dart
// Touch Targets - מינימום 48x48
GestureDetector(
  child: Container(width: 48, height: 48, child: Icon(Icons.close)),
)

// Font Sizes - 14-24
fontSize: 14,  // Body
fontSize: 16,  // Body Large
fontSize: 20,  // Heading

// Spacing - כפולות של 8
padding: EdgeInsets.all(8),
SizedBox(height: 16),

// Safe Areas - תמיד
Scaffold(body: SafeArea(child: YourContent()))
```

---

## 🔄 State Management

```dart
// ✅ Consumer
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    return ListView.builder(/* ... */);
  },
)

// ✅ Immutable Models
class MyModel {
  final String id;
  const MyModel({required this.id});
  MyModel copyWith({String? id}) => MyModel(id: id ?? this.id);
}
```

---

## 🧭 Navigation

```dart
// push - מוסיף לstack
Navigator.push(context, MaterialPageRoute(builder: (_) => Details()));

// pushReplacement - מחליף
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));

// pushAndRemoveUntil - מנקה stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => Welcome()),
  (route) => false,
);

// Back Button - לחיצה כפולה
DateTime? _lastBackPress;

Future<bool> _onWillPop() async {
  final now = DateTime.now();
  if (_lastBackPress == null || 
      now.difference(_lastBackPress!) > Duration(seconds: 2)) {
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('לחץ שוב לצאת')),
    );
    return false;
  }
  return true;
}
```

---

## 🛡️ Error Handling

```dart
// SharedPreferences
try {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('key', 'value');
} catch (e) {
  debugPrint('Error: $e');
}

// Provider
class MyProvider extends ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _repository.fetch();
    } catch (e) {
      _errorMessage = 'שגיאה: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Mounted Checks
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) setState(() => _data = data);
}
```

---

## ⚡ Performance

```dart
// Lists - builder
ListView.builder(
  key: PageStorageKey('my_list'),
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(
    key: ValueKey(items[index].id),
  ),
)

// Images - cache
import 'package:cached_network_image/cached_network_image.dart';
CachedNetworkImage(imageUrl: url)
```

---

## 💾 Storage

```dart
// SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');

// Path Provider
import 'package:path_provider/path_provider.dart';
final dir = await getApplicationDocumentsDirectory();
```

---

## 📱 Platform

```dart
// Permissions
import 'package:permission_handler/permission_handler.dart';
final status = await Permission.camera.status;
if (status.isDenied) await Permission.camera.request();

// Android Manifest
<uses-permission android:name="android.permission.CAMERA" />

// iOS Info.plist
<key>NSCameraUsageDescription</key>
<string>גישה למצלמה לסריקת קבלות</string>
```

---

## 🔴 שגיאות נפוצות

### 1. SharedPreferences ישיר
```dart
// ❌ bypass Provider
final prefs = await SharedPreferences.getInstance();

// ✅ דרך Provider
Consumer<MyProvider>(/* ... */)
```

### 2. context אחרי async בdialog
```dart
// ❌ רע
showDialog(
  builder: (context) => AlertDialog(
    actions: [
      ElevatedButton(
        onPressed: () async {
          await asyncOp();
          Navigator.pop(context);  // ❌
        },
      ),
    ],
  ),
);

// ✅ טוב
showDialog(
  builder: (dialogContext) => AlertDialog(
    actions: [
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(dialogContext);  // סגור קודם
          await asyncOp();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(/* ... */);
        },
      ),
    ],
  ),
);
```

### 3. Deprecated APIs
```dart
// ❌ deprecated
Colors.blue.withOpacity(0.5)

// ✅ נכון
Colors.blue.withValues(alpha: 0.5)
```

---

## ✅ Code Review

**לפני כל commit, השתמש ב-Checklist המלא:**

👉 **[CODE_REVIEW_CHECKLIST.md](./CODE_REVIEW_CHECKLIST.md)**

הChecklist כולל בדיקות עבור:
- General (imports, SafeArea, תיעוד)
- Splash/Index (סדר בדיקות, mounted)
- UI/UX (גדלים, פונטים, RTL)
- State Management
- Navigation
- Error Handling
- Performance
- Platform-specific

---

## 🤖 הנחיות ל-AI Tools

1. **בדוק תמיד** התאמה למובייל
2. **אל תציע** web packages
3. **תזכיר** אם משהו לא תואם
4. **תציע חלופות** mobile-friendly
5. **השתמש ב-CODE_REVIEW_CHECKLIST.md**
6. **תוסיף תיעוד** - כל קובץ חדש
7. **בדוק mounted** לפני async
8. **טפל בשגיאות** - try-catch

---

## 📝 Template לתיקון מסך

```dart
// 📄 File: lib/screens/example/example_screen.dart
// תיאור: [מטרת המסך] - מחובר ל-[Provider]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ExampleProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExampleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(title: Text('Example')),
          body: ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ListTile(title: Text(item.name));
            },
          ),
        );
      },
    );
  }
}
```

---

**עדכון:** אוקטובר 2025  
**גרסה:** 2.1 (ללא כפילויות)
