# MemoZap 📝

> Smart family shopping list app | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## About

Smart family shopping list manager with a unique **Notebook + Sticky Notes** design language.

### Features

- 🏠 **Smart Home Dashboard** — Daily suggestions, active shopping banners
- 👨‍👩‍👧‍👦 **Multi-user collaboration** — Share lists with household members in real-time
- 🔐 **Groups & Roles** — Owner, Admin, Editor permissions per list
- 📓 **Notebook Design** — Unique lined-paper background with sticky note cards
- 🏪 **9 Smart List Types** — Supermarket, market, bakery, butcher, greengrocer, pharmacy & more
- 🛒 **Active Shopping Mode** — Real-time progress tracking while in-store
- 🔔 **Notifications Center** — Invites, approvals, low stock alerts
- 🏺 **Smart Pantry** — Track inventory with auto low-stock detection
- 🧾 **Shopping History** — Browse past purchases and summaries
- 🇮🇱 **Hebrew RTL** — Fully localized interface with RTL support
- 🌙 **Dark Mode** — Full theme support with Material 3

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.8+ |
| Language | Dart 3.8.1+ |
| Backend | Firebase (Auth, Firestore, Storage, Crashlytics, Analytics) |
| State Management | Provider |
| Design System | Notebook + Sticky Notes (Material 3) |
| Package | `com.memozap.app` |

---

## Design System

| Token | Values |
|-------|--------|
| Spacing | 8-pt grid (4, 8, 12, 16, 24, 32) |
| Border Radius | Small(8), Default(12), Large(16), XLarge(24) |
| Typography | 8 sizes (Tiny→Display) via `kFontSize*` constants |
| Colors | Theme-only — zero `Colors.xxx` in screens |
| Background | `NotebookBackground` on all 21 screens |

---

## Project Structure

```
lib/
├── core/           # Constants, status colors
├── config/         # Business logic config, filters
├── l10n/           # Localization (AppStrings)
├── models/         # Data models (26)
├── providers/      # State providers (7)
├── repositories/   # Firebase repositories (13)
├── services/       # Business logic services (17)
├── theme/          # Design tokens, app theme, transitions
├── screens/        # App screens (21)
│   ├── auth/       # Login, Register + widgets/
│   ├── home/       # Dashboard + widgets/
│   ├── shopping/   # Lists, Details, Active, Create + widgets/
│   ├── pantry/     # Inventory management
│   ├── settings/   # Settings, Manage Users
│   ├── sharing/    # Invites, Requests
│   └── ...
├── widgets/        # Shared widgets
│   └── common/     # NotebookBackground, StickyNote, EmptyState, etc.
└── main.dart
```

---

## Getting Started

```bash
# Clone
git clone https://github.com/Yehuda-sh/salsheli.git
cd salsheli

# Install dependencies
flutter pub get

# Run
flutter run
```

### Firebase Setup

1. Create a Firebase project
2. Add Android app with package `com.memozap.app`
3. Add iOS app with bundle ID `com.memozap.app`
4. Download `google-services.json` → `android/app/`
5. Download `GoogleService-Info.plist` → `ios/Runner/`

---

## Development

```bash
flutter test          # Run tests
dart analyze lib/     # Analyze code
dart format lib/ -w   # Format code
flutter build apk --release   # Build APK
```

### Demo Users (Firebase Emulator)

```bash
firebase emulators:start
```

| User | Email | Password |
|------|-------|----------|
| רונית כהן | ronit.cohen@demo.com | Demo123! |
| אבי כהן | avi.cohen@demo.com | Demo123! |
| יובל כהן | yuval.cohen@demo.com | Demo123! |
| שירן גל | shiran.gal@demo.com | Demo123! |

---

## License

**© 2026 Yehuda Sharabi | All Rights Reserved**

Proprietary software. Unauthorized copying, modification, or distribution is prohibited.

---

🇮🇱 **Made in Israel** | **Version:** 1.0.0 | **Updated:** March 2026
