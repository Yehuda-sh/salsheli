# MemoZap

> Smart family shopping management app

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%C2%B7%20iOS-3DDC84?logo=android)](https://flutter.dev)

---

## About

MemoZap is a smart shopping list manager for any group that shares groceries — families, couples, roommates, partners, or solo users. It features real-time collaboration, a digital pantry with low-stock alerts, and a unique **Notebook + Sticky Notes** design language.

### Key Features

- **Shared Shopping Lists** — Create and manage lists with your household in real-time (9 list types)
- **Active Shopping Mode** — Real-time progress tracking while in-store with collaborative shopping
- **Smart Pantry** — Track inventory with automatic low-stock detection and purchase suggestions
- **Household Activity Feed** — See what's happening in your household (shopping, stock updates, new lists)
- **Roles & Permissions** — Owner, Admin, Editor, Viewer — control who can do what
- **Shopping History** — Browse past purchases with receipts and summaries
- **Notifications** — Invites, approvals, low stock alerts — all in one place
- **Hebrew RTL First** — Fully localized interface with English support
- **Dark Mode** — Full Material 3 theme support

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.8+ / Dart 3.8.1+ |
| Backend | Firebase (Auth, Firestore, Storage, Crashlytics, Analytics, Messaging) |
| State Management | Provider + ChangeNotifier |
| CI/CD | GitHub Actions → Firebase App Distribution |

---

## Quick Start

```bash
# 1. Clone + dependencies
git clone https://github.com/yehuda-sh/salsheli.git
cd salsheli
flutter pub get

# 2. Firebase config (one-time per machine)
#    Drops the lib/firebase_options.dart and ios/Runner/GoogleService-Info.plist
#    files — both gitignored.
flutterfire configure

# 3. Run on a connected device or emulator
flutter run
```

For demo data (admin only), see [`scripts/README.md`](scripts/README.md).

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [CLAUDE.md](CLAUDE.md) | File-review checklist, design tokens, response style, lessons learned |
| [AGENTS.md](AGENTS.md) | Operational guide for Claude instances — current state, known issues, architecture |
| [docs/REVIEW_BACKLOG.md](docs/REVIEW_BACKLOG.md) | Per-screen review memory — Decisions Made + Deferred |
| [TEST_PLAN.md](TEST_PLAN.md) | Unit / widget / integration test plan + KPIs |
| [docs/REFACTOR_PLAN.md](docs/REFACTOR_PLAN.md) | 10-phase refactor roadmap (status per phase) |
| [docs/spec-home-screen.md](docs/spec-home-screen.md) | Home dashboard spec (with Activity Feed) |
| [docs/store-listing.md](docs/store-listing.md) | App store listing copy |
| [scripts/README.md](scripts/README.md) | Demo data + catalog maintenance scripts |

---

## Status

**Pre-beta** — Internal testing via Firebase App Distribution.
See [docs/REVIEW_BACKLOG.md](docs/REVIEW_BACKLOG.md) for the latest review state.

---

## License

**Proprietary Software — All Rights Reserved**

**Copyright (c) 2026 Yehuda Sharabi**

This software and its source code are the exclusive property of Yehuda Sharabi.
Unauthorized copying, modification, distribution, or use is strictly prohibited.

---

**Made in Israel** | **Package:** `com.memozap.app`
