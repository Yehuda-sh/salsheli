# 🛒 MemoZap

> **Family shopping list management app** | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.9-blue)](docs/CHANGELOG.md)

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
3. **[docs/CHANGELOG.md](docs/CHANGELOG.md)** - Recent changes & `[In Progress]` work
4. **Specific guide** - Pick from table below based on your task

### For AI Assistants (Claude)

**🤖 Starting a new session? Follow this protocol:**

1. ✅ Read `README.md` (this file)
2. ✅ Read `docs/PROJECT_INSTRUCTIONS_v4.md` (complete AI instructions)
3. ✅ Check `docs/CHANGELOG.md` → look for `[In Progress]` section
4. ✅ Load memory: `read_graph()` or `search_nodes("last checkpoint")`
5. ✅ Ready to work! 🎯

**Continuation commands:**
- "**המשך**" or "**תמשיך**" → Resume from last checkpoint
- "**שמור checkpoint**" → Force save current state

---

## 💾 Work Sessions & Checkpoints

### Session Continuity

- Every 3-5 file changes → Auto-checkpoint created
- Check `docs/CHANGELOG.md` → `[In Progress]` section for current work
- Memory system tracks session state across conversations
- Document "Next Steps" before taking breaks

### For AI Assistants

```markdown
## How to resume work:
1. Read CHANGELOG.md → [In Progress] section
2. Search memory: search_nodes("last checkpoint")
3. Continue from documented "Next Steps"
```

---

## 📚 Documentation

### Core Documentation (7 Files)

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[PROJECT_INSTRUCTIONS_v4.md](docs/PROJECT_INSTRUCTIONS_v4.md)** | Complete AI instructions (Environment + Tools + Protocols) | 🔴 Always 2nd (after README) |
| **[CODE.md](docs/CODE.md)** | Code patterns, architecture, testing, mistakes | Before coding/reviewing |
| **[DESIGN.md](docs/DESIGN.md)** | Sticky Notes design system (RTL + Components) | Before UI work |
| **[TECH.md](docs/TECH.md)** | Firebase, security, models, dependencies | Before backend work |
| **[CODE_REVIEW_CHECKLIST.md](docs/CODE_REVIEW_CHECKLIST.md)** | Code review protocols + dead code detection | Before reviewing/deleting code |
| **[LESSONS_LEARNED.md](docs/LESSONS_LEARNED.md)** | Common mistakes & solutions | ⚠️ Before risky changes |
| **[CHANGELOG.md](docs/CHANGELOG.md)** | Project history + `[In Progress]` | Check for current work |
| **[WORK_PLAN.md](docs/WORK_PLAN.md)** | 8-week roadmap (Lists + Inventory systems) | Planning new features |

### By Task Type

| Need | Read These | Priority Order |
|------|-----------|---------------|
| **Write code** | CODE.md + PROJECT_INSTRUCTIONS | 1. PROJECT_INSTRUCTIONS, 2. CODE |
| **Design UI** | DESIGN.md + PROJECT_INSTRUCTIONS | 1. PROJECT_INSTRUCTIONS, 2. DESIGN |
| **Review code** | CODE_REVIEW_CHECKLIST | 1. CODE_REVIEW_CHECKLIST |
| **Firebase/Security** | TECH.md + CODE.md | 1. TECH, 2. CODE |
| **Build feature** | PROJECT_INSTRUCTIONS + CODE + DESIGN + TECH | 1. PROJECT_INSTRUCTIONS, 2. CODE, 3. DESIGN, 4. TECH |
| **Debug issues** | LESSONS_LEARNED + CODE | 1. LESSONS_LEARNED, 2. CODE |
| **Plan roadmap** | WORK_PLAN | 1. WORK_PLAN |

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.27+ |
| **Language** | Dart 3.6+ |
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

- 📁 **100+ Dart files**
- 🧪 **179 tests passing** (90%+ model coverage)
- 📋 **11 data models**
- 🔄 **9 providers**
- 🗄️ **17 repositories**
- 🎨 **30+ screens**
- 🧩 **25+ widgets**
- 📖 **7 documentation files** (~2,700 lines - machine-optimized)
- 🌐 **Full Hebrew RTL support**

---

## 🆕 What's New (v2.9 - Oct 29, 2025)

### ✅ Track 3 Complete - Smart Suggestions System

#### 🧠 Smart Suggestions
- SuggestionsService with predictive logic
- Smart suggestion cards on home screen
- Last Chance Banner during shopping
- 15/15 unit tests passing

#### 🛒 Shopping Lists V5.0
- Unified active + history view
- Complete Purchase flow
- Auto-inventory update
- Move unpurchased items to new list

#### 📋 Previous Tracks (v2.8)
- **Track 1:** Tasks + Products (Hybrid lists)
- **Track 2:** User Sharing (4 permission levels)
- Receipt Scanning removed (11 files cleaned)

### 🧪 Technical Improvements
- Documentation overhaul: 10→7 files (-38% redundancy)
- Enhanced CODE_REVIEW_CHECKLIST (6-step protocol)
- Bug fixes: 10+ files (compilation errors, RangeError, product loading)
- Code cleanup: 1,500+ lines dead code removed
- Testing: 179 tests passing (90%+ coverage)

**📖 Full changelog:** See [docs/CHANGELOG.md](docs/CHANGELOG.md)

---

## 📂 Project Structure

```
memozap/
├── lib/
│   ├── core/              # UI constants, theme
│   ├── models/            # 11 data models
│   ├── providers/         # 9 state providers
│   ├── repositories/      # 17 data repositories
│   ├── services/          # 7 services
│   ├── screens/           # 30+ screens
│   ├── widgets/           # 25+ reusable widgets
│   ├── config/            # Business logic config
│   ├── l10n/              # Localization (Hebrew + English)
│   └── main.dart          # App entry point
├── test/                  # 50+ tests
├── assets/                # Images, fonts
└── docs/                  # Documentation (7 files)
    ├── PROJECT_INSTRUCTIONS_v4.md # Complete AI instructions (450 lines)
    ├── CODE.md            # Code patterns & architecture (500 lines)
    ├── DESIGN.md          # Sticky Notes design system (300 lines)
    ├── TECH.md            # Firebase, security, models (400 lines)
    ├── CODE_REVIEW_CHECKLIST.md # Review protocols (300 lines)
    ├── LESSONS_LEARNED.md # Common mistakes & solutions (300 lines)
    ├── CHANGELOG.md       # Project history + [In Progress] (400 lines)
    └── WORK_PLAN.md       # 8-week roadmap (500 lines)
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
6. Check [docs/LESSONS_LEARNED.md](docs/LESSONS_LEARNED.md) to avoid common mistakes

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
**Version:** 2.9 | **Updated:** 29/10/2025

**🚀 Ready to start?** → Read [Quick Start](#-quick-start) above
