# 🛒 MemoZap

> **Family shopping list management app** | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue)](#)

---

## 🎯 What is MemoZap?

**Smart family shopping list manager** with unique Sticky Notes design.

### Key Features

- 👨‍👩‍👧‍👦 **Multi-user collaboration** - Share lists with household members
- 🎨 **Unique Sticky Notes theme** - Beautiful post-it style UI
- 🧠 **Smart suggestions** - Pantry-based recommendations
- 💡 **Smart inventory** - Auto-update pantry after shopping
- 🔒 **Household-based security** - Your data stays private
- 🛒 **8 smart list types** - Filtered product catalogs per store type
- 🏪 **Shufersal API integration** - Public API with dynamic pricing
- 🌐 **Hebrew RTL support** - Fully localized interface

---

## 🚀 Quick Start

### For New Developers

**📖 Read in this order:**

1. **README.md** (this file) - Project overview
2. **[docs/PROJECT_INSTRUCTIONS_v4.md](docs/PROJECT_INSTRUCTIONS_v4.md)** - Complete AI instructions
3. **Specific guide** - Pick from table below based on your task

### For AI Assistants (Claude)

**🤖 Starting a new session? Follow this protocol:**

1. ✅ Read `README.md` (this file)
2. ✅ Read `docs/PROJECT_INSTRUCTIONS_v4.md` (complete AI instructions)
3. ✅ Load memory: `read_graph()` or `search_nodes("Current Work Context")`
4. ✅ Ready to work! 🎯

**Continuation commands:**
- "**המשך**" or "**תמשיך**" → Resume from last checkpoint
- "**שמור checkpoint**" → Force save current state

---

## 💾 Work Sessions & Checkpoints

### Automatic Session Tracking

**The system automatically tracks everything:**
- ✅ **Auto-checkpoint** every 3-5 file changes
- ✅ **Memory entities** store work context
- ✅ **Zero maintenance** - no manual documentation
- ✅ **Perfect continuity** - "המשך" resumes seamlessly

**Quick Commands:**
```bash
# Load latest state
search_nodes("Current Work Context")

# Resume previous session
recent_chats(n=2)  # Then continue from "Next Steps"
```

**What's tracked automatically:**
- Current task and progress (%)
- Files modified + specific changes
- Next steps for continuation
- Architectural decisions
- Critical context needed

**Continuation Protocol:**
1. User types: **"המשך"**
2. AI loads: Memory + Recent chat
3. AI continues: Exactly from "Next Steps"
4. Zero context loss ✅

---

## 📚 Documentation

### Core Documentation (7 Files)

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[PROJECT_INSTRUCTIONS_v4.md](docs/PROJECT_INSTRUCTIONS_v4.md)** | Complete AI instructions (Environment + Tools + Protocols) | 🔴 Always 2nd (after README) |
| **[CODE.md](docs/CODE.md)** | Code patterns, architecture, testing, mistakes | Before coding/reviewing |
| **[DESIGN.md](docs/DESIGN.md)** | Sticky Notes design system (RTL + Components) | Before UI work |
| **[TECH.md](docs/TECH.md)** | Firebase v1.4, security (4-tier permissions), models | Before backend work |
| **[CODE_REVIEW_CHECKLIST.md](docs/CODE_REVIEW_CHECKLIST.md)** | Code review protocols v2.5 + 7-step dead code detection | Before reviewing/deleting code |
| **[WORK_PLAN.md](docs/WORK_PLAN.md)** | 8-week roadmap (Lists + Inventory systems) | Planning new features |
| **[CLAUDE_GUIDE.md](docs/CLAUDE_GUIDE.md)** | Quick reference for AI assistants (barcodes, patterns) | Quick lookup during work |

### By Task Type

| Need | Read These | Priority Order |
|------|-----------|---------------|
| **Write code** | CODE.md + PROJECT_INSTRUCTIONS | 1. PROJECT_INSTRUCTIONS, 2. CODE |
| **Design UI** | DESIGN.md + PROJECT_INSTRUCTIONS | 1. PROJECT_INSTRUCTIONS, 2. DESIGN |
| **Review code** | CODE_REVIEW_CHECKLIST | 1. CODE_REVIEW_CHECKLIST |
| **Firebase/Security** | TECH.md + CODE.md | 1. TECH, 2. CODE |
| **Build feature** | PROJECT_INSTRUCTIONS + CODE + DESIGN + TECH | 1. PROJECT_INSTRUCTIONS, 2. CODE, 3. DESIGN, 4. TECH |
| **Debug issues** | CODE + PROJECT_INSTRUCTIONS | 1. CODE, 2. PROJECT_INSTRUCTIONS |
| **Plan roadmap** | WORK_PLAN | 1. WORK_PLAN |

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.27+ |
| **Language** | Dart 3.8.1+ |
| **Backend** | Firebase (Auth, Firestore, Functions) |
| **State Management** | Provider |
| **Database** | Cloud Firestore |
| **External API** | Shufersal (1,758 products) |
| **Design System** | Sticky Notes (Custom) |
| **Localization** | `flutter_localizations` (Hebrew RTL + English) |
| **Testing** | flutter_test, mockito |
| **CI/CD** | GitHub Actions (planned) |

---

## 📊 Project Stats

- 📁 **130 Dart files**
- 🧪 **179 tests passing** (90%+ model coverage)
- 📋 **20 data models**
- 🔄 **8 providers** (moved to Services architecture)
- 🗄️ **15 repositories**
- 💼 **15 services**
- 🎨 **20 screens**
- 🧩 **23 widgets**
- 📖 **7 documentation files** (~3,500 lines - machine-optimized)
- 🌐 **Full Hebrew RTL support**

---

## 🆕 What's New (v1.0.0 - Nov 20, 2025)

### 🎉 Phase 3B Complete - User Sharing System (100%)

#### ✅ Fully Implemented
- **Services** (870 lines total)
  - **ShareListService** (460 lines) - Invite/remove/update users with role management
  - **PendingRequestsService** (410 lines) - Editor approval workflow (add/approve/reject)
  - 7 permission helper methods
  - Auto-cleanup (7-day old requests)

- **Models** (5 classes)
  - SharedUser, PendingRequest
  - UserRole (4 levels), RequestType (3 types), RequestStatus (3 states)

- **UI Screens** (3 screens + 1 widget)
  - InviteUsersScreen - Email + role selection
  - ManageUsersScreen - List users + edit roles
  - PendingRequestsScreen - Badge + approve/reject
  - PendingRequestsSection v2.0 - Inline widget (no Provider dependency)

- **4-tier permission system**:
  - Owner: Full access + delete + manage users
  - Admin: Full access + manage users (no delete)
  - Editor: Read + create pending requests (needs approval)
  - Viewer: Read-only access

- **Architecture**: Services-based (no Providers) - cleaner and more efficient

#### 🔜 Next: Phase 4
- Firebase Security Rules integration
- End-to-end testing
- Push notifications for sharing events

#### 📋 Previous Releases (v2.9)
- **Track 3:** Smart Suggestions System
- **Track 2:** User Sharing infrastructure
- **Track 1:** Tasks + Products (Hybrid lists)

### 🧪 Technical Improvements (Nov 2025)
- **Code cleanup**: 989 lines dead code removed (filters, providers, screens)
- **Documentation**: 5→7 optimized files (+CLAUDE_GUIDE.md, +WORK_PLAN.md)
- **Architecture**: Migrated from Providers to Services pattern (Phase 3B)
- **Widgets**: PendingRequestsSection v2.0 - removed Provider dependency
- **Models**: 11→20 data models (added sharing system models)
- **Services**: 7→15 services (major expansion)
- **Testing**: 179 tests passing (90%+ coverage)

**📖 Version history:** Check Memory (`search_nodes("Recent Sessions")`)

---

## 📂 Project Structure

```
memozap/
├── lib/
│   ├── core/              # UI constants, theme
│   ├── models/            # 20 data models
│   ├── providers/         # 8 state providers
│   ├── repositories/      # 15 data repositories
│   ├── services/          # 15 services (ShareList, PendingRequests, etc.)
│   ├── screens/           # 20 screens
│   ├── widgets/           # 23 reusable widgets
│   ├── config/            # Business logic config
│   ├── l10n/              # Localization (Hebrew + English)
│   └── main.dart          # App entry point
├── test/                  # 179 tests passing
├── assets/                # Images, fonts, data (list_types JSON)
└── docs/                  # Documentation (7 files)
    ├── PROJECT_INSTRUCTIONS_v4.md # Complete AI instructions (1,110 lines)
    ├── CODE.md            # Code patterns & architecture (1,247 lines)
    ├── DESIGN.md          # Sticky Notes design system (687 lines)
    ├── TECH.md            # Firebase, security, models (617 lines)
    ├── CODE_REVIEW_CHECKLIST.md # Review protocols (695 lines)
    ├── WORK_PLAN.md       # 8-week roadmap (832 lines)
    └── CLAUDE_GUIDE.md    # Quick reference for AI (238 lines)
```

---

## 🌐 Internationalization

### Primary Language: Hebrew (עברית)
- **Full RTL support** in all UI components
- Main localization file: `lib/l10n/app_he.arb`
- English fallback: `lib/l10n/app_en.arb`
- All text wrapped with `Directionality` widgets where needed

### Usage Example
```dart
// ✅ Correct - Automatic RTL for Hebrew
Text(AppLocalizations.of(context)!.taskTitle)

// ✅ Explicit RTL wrapper
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('טקסט בעברית'),
)
```

---

## 💻 Installation & Development

### Setup

```bash
# 1. Clone repository
git clone https://github.com/Yehuda-sh/memozap.git
cd memozap

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

### Development Commands

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/ -w

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## 🤝 Contributing

### Getting Started
1. Read [docs/PROJECT_INSTRUCTIONS_v4.md](docs/PROJECT_INSTRUCTIONS_v4.md) for complete AI instructions
2. Check [docs/CODE.md](docs/CODE.md) for code patterns & architecture
3. Follow [docs/DESIGN.md](docs/DESIGN.md) for UI/UX guidelines
4. Review [docs/TECH.md](docs/TECH.md) for Firebase & security
5. Use [docs/CODE_REVIEW_CHECKLIST.md](docs/CODE_REVIEW_CHECKLIST.md) before reviewing/deleting code

### Code Style
- ✅ Run `dart format lib/ -w` before commit
- ✅ Ensure `flutter analyze` shows 0 issues
- ✅ Write tests for new features
- ✅ Update documentation (especially CHANGELOG.md)

### Pull Request Checklist
- [ ] Code formatted and analyzed
- [ ] Tests pass (`flutter test`)
- [ ] Documentation updated
- [ ] Follows Sticky Notes Design System
- [ ] Hebrew strings in `l10n/app_he.arb`
- [ ] No breaking changes (or documented in CHANGELOG)
- [ ] CHANGELOG.md updated with changes

---

## 📧 Contact & Support

### Team
- **Project Lead:** Yehuda
- **GitHub:** [@Yehuda-sh](https://github.com/Yehuda-sh)

### Resources
- **🐛 Report Bug:** [Create Issue](https://github.com/Yehuda-sh/memozap/issues/new)
- **💡 Feature Request:** [Discussions](https://github.com/Yehuda-sh/memozap/discussions)
- **📖 Documentation:** All docs in this repo under `/docs`
- **🔧 Support:** Check documentation first, then create issue

---

## 📜 License

**© 2025 MemoZap Team | All Rights Reserved**

This is proprietary software. All rights reserved. Unauthorized copying, modification, distribution, or use of this software is strictly prohibited.

---

## 🙏 Acknowledgments

Built with:
- ❤️ **Flutter** - Beautiful cross-platform apps
- 🔥 **Firebase** - Scalable backend platform
- 🤖 **Claude (Anthropic)** - AI coding assistant with MCP integration
- 🎨 **Material Design 3** - Modern UI components

Special thanks to the open source community and all contributors!

---

**Made with ❤️ in Israel** 🇮🇱
**Version:** 1.0.0 | **Updated:** 20/11/2025

**🚀 Ready to start?** → Read [Quick Start](#-quick-start) above
