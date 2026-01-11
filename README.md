# MemoZap

> Family shopping list management app | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## About

Smart family shopping list manager with unique Sticky Notes design.

### Features

- **Smart Home Dashboard** - Quick overview with banners, suggestions, and quick-add
- **Multi-user collaboration** - Share lists with household members
- **Groups system** - Family groups with role-based permissions
- **Sticky Notes theme** - Beautiful post-it style UI
- **Smart inventory (Pantry)** - Track stock with auto low-stock alerts
- **Collaborative shopping** - Real-time multi-user shopping sessions
- **Smart suggestions** - Pantry-based recommendations (≤3 per day)
- **Quick Add** - Add items instantly from home screen
- **Notifications center** - Bell badge with unread count
- **Household-based security** - Your data stays private
- **8 smart list types** - Filtered product catalogs per store type
- **Push notifications** - Low stock alerts, shopping invites
- **Hebrew RTL support** - Fully localized interface

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.27+ |
| Language | Dart 3.8.1+ |
| Backend | Firebase (Auth, Firestore, Storage, Messaging) |
| State Management | Provider |
| Design System | Sticky Notes (Custom) |
| Localization | Hebrew RTL + English |

---

## Project Stats

| Type | Count |
|------|-------|
| Dart files | ~160 |
| Models | 37 |
| Providers | 10 |
| Repositories | 16 |
| Services | 16 |
| Screens | 35 |
| Widgets | 26 |

---

## Project Structure

```
lib/
├── core/           # UI constants, theme
├── models/         # Data models
├── providers/      # State providers
├── repositories/   # Data repositories
├── services/       # Business logic services
├── screens/        # App screens
├── widgets/        # Reusable widgets
├── config/         # Business logic config
├── l10n/           # Localization (Hebrew + English)
└── main.dart       # App entry point
```

---

## Installation

```bash
# Clone repository
git clone https://github.com/Yehuda-sh/memozap.git
cd memozap

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

## Development Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/ -w

# Build APK
flutter build apk --release
```

---

## Firebase Emulator (Local Development)

```bash
# Start all emulators (Firestore, Auth, etc.)
firebase emulators:start

# Load demo data (Cohen family + more)
dart run scripts/demo_data_cohen_family.dart --clean
```

**Emulator UI:** http://localhost:4000

### Demo Users

| User | Email | Password |
|------|-------|----------|
| רונית כהן | ronit.cohen@demo.com | Demo123! |
| אבי כהן | avi.cohen@demo.com | Demo123! |
| יובל כהן | yuval.cohen@demo.com | Demo123! |
| שירן גל | shiran.gal@demo.com | Demo123! |

---

## License

**© 2026 MemoZap Team | All Rights Reserved**

Proprietary software. Unauthorized copying, modification, or distribution is prohibited.

---

**Made in Israel**

**Version:** 1.2.0 | **Updated:** 08/01/2026
