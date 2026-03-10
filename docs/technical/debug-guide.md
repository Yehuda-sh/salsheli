# Debug Guide - MemoZap

> עודכן: מרץ 2026

## Debug Print Policy

**כל ה-debug prints הוסרו מקוד הפרודקשן** (Phase 1.2).
רק `kDebugMode`-guarded prints ו-`debugPrintStack` נשארו.

Rule: `avoid_print: error` ב-`analysis_options.yaml` — אכפה אוטומטית.

### Emoji Prefixes (convention)

| Emoji | Meaning |
|-------|---------|
| `🔐` | Auth |
| `🔥` | Firebase |
| `📦` | Storage/Hive |
| `📥` | Data incoming |
| `📤` | Data outgoing |
| `⚠️` | Warning |
| `🔴` | Error |
| `❌` | Failure |
| `✅` | Success |
| `🛒` | Shopping |
| `📋` | Lists |

### Adding Debug Logs

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('📋 MyProvider.myMethod: state=$_state');
}
```

---

## Firebase Emulators

### Starting

```bash
firebase emulators:start
# With clean data:
firebase emulators:start --clear
```

### Demo Data

```bash
dart run scripts/demo_data_cohen_family.dart --clean
```

### Emulator UI
- Firestore: http://localhost:8080
- Auth: http://localhost:9099
- Storage: http://localhost:9199

---

## Common Debug Scenarios

### User Not Loading
- Check Firebase initialized
- Check auth token not expired
- Check `UserContext.isLoggedIn` / `householdId`

### Lists Not Showing
- Check `householdId` matches between user doc and household
- Check Firestore security rules
- Check provider subscription active

### Permission Denied
- Check user's `household_id` field matches the household document
- Check `shared_users` map in list doc contains user UID
- Check user role (viewer can't write)

### Shopping Session Issues
- Check user in `activeShoppers`
- Check `isStarter` flag
- Check timeout (6 hours max)

---

## Useful Commands

```bash
# Clean build
flutter clean && flutter pub get

# Analyze
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub outdated

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

---

## Quick Checklist

1. ✅ Firebase initialized?
2. ✅ User logged in? `householdId` set?
3. ✅ Provider subscription active?
4. ✅ Firestore document exists?
5. ✅ Security rules allow access?
6. ✅ Indexes created?
