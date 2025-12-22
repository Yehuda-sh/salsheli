# MemoZap

> Family shopping list management app | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## About

Smart family shopping list manager with unique Sticky Notes design.

### Features

- **Multi-user collaboration** - Share lists with household members
- **Groups system** - Family groups with role-based permissions
- **Sticky Notes theme** - Beautiful post-it style UI
- **Smart inventory (Pantry)** - Track stock with auto low-stock alerts
- **Collaborative shopping** - Real-time multi-user shopping sessions
- **Smart suggestions** - Pantry-based recommendations
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

## License

**© 2025 MemoZap Team | All Rights Reserved**

Proprietary software. Unauthorized copying, modification, or distribution is prohibited.

---

**Made in Israel**

**Version:** 1.1.0 | **Updated:** 19/12/2025
