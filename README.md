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
- **Sticky Notes theme** - Beautiful post-it style UI
- **Smart suggestions** - Pantry-based recommendations
- **Smart inventory** - Auto-update pantry after shopping
- **Household-based security** - Your data stays private
- **8 smart list types** - Filtered product catalogs per store type
- **Hebrew RTL support** - Fully localized interface

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.27+ |
| Language | Dart 3.8.1+ |
| Backend | Firebase (Auth, Firestore) |
| State Management | Provider |
| Design System | Sticky Notes (Custom) |
| Localization | Hebrew RTL + English |

---

## Project Stats

| Type | Count |
|------|-------|
| Dart files | 130 |
| Models | 26 |
| Providers | 8 |
| Repositories | 15 |
| Services | 20 |
| Screens | 23 |
| Widgets | 19 |
| Documentation | 7 files |

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

## Documentation

Documentation files are in the `/docs` folder:

- `PROJECT_INSTRUCTIONS_v4.md` - AI instructions
- `CODE.md` - Code patterns & architecture
- `DESIGN.md` - Sticky Notes design system
- `TECH.md` - Firebase & security
- `CODE_REVIEW_CHECKLIST.md` - Review protocols
- `WORK_PLAN.md` - Roadmap
- `CLAUDE_GUIDE.md` - Quick reference

---

## License

**© 2025 MemoZap Team | All Rights Reserved**

Proprietary software. Unauthorized copying, modification, or distribution is prohibited.

---

**Made in Israel**

**Version:** 1.0.0 | **Updated:** 30/11/2025
