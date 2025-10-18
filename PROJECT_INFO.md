# 📋 Salsheli - Project Information

> **Complete project overview and documentation index**  
> **Updated:** 18/10/2025 | **Version:** 2.0 - Unified Documentation

---

## 🎯 Project Overview

### What is Salsheli?

**Salsheli** (סל שלי = "My Cart") is a family shopping list management app built with Flutter and Firebase.

**Key Features:**
- 👨‍👩‍👧‍👦 **Multi-user:** Share lists with household members
- 📱 **Cross-platform:** iOS, Android, Web
- 🎨 **Unique design:** Sticky Notes theme (post-it notes + notebook)
- 🔒 **Secure:** household-based data isolation
- 📸 **OCR:** Scan receipts with ML Kit
- 🛒 **Smart:** 21 list types, 6 system templates, 66 pre-loaded items

---

## 📊 Project Statistics

### Codebase (18/10/2025)

| Category | Count |
|----------|-------|
| **Documentation Files** | **5** (optimized!) |
| **Dart Files** | 100+ |
| **Models** | 11 |
| **Providers** | 9 |
| **Repositories** | 17 |
| **Services** | 7 |
| **Screens** | 30+ |
| **Widgets** | 25+ |
| **Tests** | 50+ |

### Tech Stack

- **Framework:** Flutter 3.27+
- **Language:** Dart 3.6+
- **Backend:** Firebase (Auth, Firestore, Functions)
- **State Management:** Provider
- **Database:** Cloud Firestore
- **ML:** ML Kit (OCR)
- **External API:** Shufersal (1,758 products)

---

## 📁 Project Structure

```
C:\projects\salsheli\
├── lib/
│   ├── core/
│   │   ├── ui_constants.dart       # All UI constants
│   │   └── theme.dart              # App theme
│   ├── models/                     # 11 data models
│   ├── providers/                  # 9 state providers
│   ├── repositories/               # 17 data repositories
│   ├── services/                   # 7 services
│   ├── screens/                    # 30+ screens
│   ├── widgets/                    # 25+ reusable widgets
│   ├── config/                     # Business logic config
│   └── main.dart                   # App entry point
├── test/                           # 50+ tests
├── assets/                         # Images, fonts
└── scripts/                        # Build scripts
# Documentation (5 files) in project root
```

---

## 📚 The 5 Core Documents

### 1. 🤖 AI_MASTER_GUIDE.md
**For: AI assistants**  
**Purpose:** Complete AI behavior instructions  
**Contains:**
- Communication guidelines (Hebrew responses)
- Auto code review rules
- Technical fixes (withOpacity → withValues)
- Dead Code detection (5-step process)
- Security, Performance, Accessibility checks
- Top 10 common mistakes

**When to use:** Start of EVERY AI conversation

---

### 2. 👨‍💻 DEVELOPER_GUIDE.md
**For: Developers**  
**Purpose:** All code patterns & best practices  
**Contains:**
- Quick Reference (30-second answers)
- Architecture patterns (Repository, Provider, etc.)
- Code examples (async, forms, error handling)
- Testing guidelines
- Security best practices
- Performance optimization
- Complete checklists

**When to use:** Writing or reviewing code

---

### 3. 🎨 DESIGN_GUIDE.md
**For: UI/UX work**  
**Purpose:** Sticky Notes Design System  
**Contains:**
- Complete design system
- Color palette (kStickyYellow, kStickyPink, etc.)
- Components (StickyNote, StickyButton, NotebookBackground)
- Compact design (single-screen layouts)
- Code examples
- Before/After screenshots

**When to use:** Creating or updating screens

---

### 4. 🚀 GETTING_STARTED.md
**For: Beginners**  
**Purpose:** Quick start guide  
**Contains:**
- 5-10 minute quick start
- Keyboard shortcuts table
- How to talk to Claude
- Claude Code setup
- Common mistakes
- Project examples

**When to use:** First time setup or onboarding

---

### 5. 📋 PROJECT_INFO.md
**For: Understanding the project**  
**Purpose:** Project overview (this file!)  
**Contains:**
- Project statistics
- Tech stack
- Documentation index
- Change history
- Setup instructions
- Contact information

**When to use:** Understanding architecture or history

---

## 🚀 Quick Start

### Prerequisites

```bash
# Verify Flutter installation
flutter doctor

# Required versions
Flutter: 3.27+
Dart: 3.6+
Android Studio / VS Code
```

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Yehuda-sh/salsheli.git
cd salsheli

# 2. Install dependencies
flutter pub get

# 3. Generate code (models)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run

# 5. Run tests
flutter test
```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 🔗 Documentation Index

### By Use Case

| Need | Document | Section |
|------|----------|---------|
| **Getting started** | GETTING_STARTED.md | Full guide |
| **Writing code** | DEVELOPER_GUIDE.md | Code Examples |
| **Architecture** | DEVELOPER_GUIDE.md | Architecture Patterns |
| **Design UI** | DESIGN_GUIDE.md | Full guide |
| **Quick answers** | DEVELOPER_GUIDE.md | Quick Reference |
| **Testing** | DEVELOPER_GUIDE.md | Testing Guidelines |
| **Security** | DEVELOPER_GUIDE.md | Security Best Practices |
| **Performance** | DEVELOPER_GUIDE.md | Performance Optimization |
| **AI instructions** | AI_MASTER_GUIDE.md | Full guide |
| **Project info** | PROJECT_INFO.md | This file! |

### Reading Order

#### For Beginners 🆕
```
1. GETTING_STARTED.md       (5-10 min)
2. PROJECT_INFO.md          (5 min) ← You are here!
3. DEVELOPER_GUIDE.md       (skim Quick Reference)
4. DESIGN_GUIDE.md          (when creating UI)
```

#### For Experienced Developers 👨‍💻
```
1. PROJECT_INFO.md          ← You are here!
2. DEVELOPER_GUIDE.md       (full read)
3. DESIGN_GUIDE.md          (full read)
4. AI_MASTER_GUIDE.md       (if using AI assistant)
```

#### For AI Assistants 🤖
```
1. AI_MASTER_GUIDE.md       (START HERE - EVERY conversation!)
2. DEVELOPER_GUIDE.md       (reference as needed)
3. DESIGN_GUIDE.md          (reference as needed)
```

---

## 📖 Change History

### v2.0 - 18/10/2025 🎉 **Major Update: Documentation Unification**

**🔥 Reduced from 14 to 5 documents!**

#### Created
- ✅ **AI_MASTER_GUIDE.md** (v2.0) - Complete AI guide with Security, Performance, Accessibility
- ✅ **DEVELOPER_GUIDE.md** (v1.0) - Merged 5 documents into one
- ✅ **PROJECT_INFO.md** (v2.0) - This file! Merged 6 documents

#### Renamed
- ✅ **STICKY_NOTES_DESIGN.md** → **DESIGN_GUIDE.md** (clearer name)

#### Kept (Updated)
- ✅ **GETTING_STARTED.md** - Updated links to new documents

#### Deprecated (Content Merged)
- ♻️ **BEST_PRACTICES.md** → Merged into DEVELOPER_GUIDE.md
- ♻️ **LESSONS_LEARNED.md** → Merged into DEVELOPER_GUIDE.md
- ♻️ **QUICK_REFERENCE.md** → Merged into DEVELOPER_GUIDE.md
- ♻️ **TESTING_GUIDE.md** → Merged into DEVELOPER_GUIDE.md
- ♻️ **SECURITY_GUIDE.md** → Merged into DEVELOPER_GUIDE.md + AI_MASTER_GUIDE.md
- ♻️ **PERFORMANCE_TEST.md** → Merged into DEVELOPER_GUIDE.md + AI_MASTER_GUIDE.md
- ♻️ **README.md** → Merged into PROJECT_INFO.md
- ♻️ **DOCS_STRUCTURE.md** → Merged into PROJECT_INFO.md
- ♻️ **WORK_LOG.md** → Merged into PROJECT_INFO.md
- ♻️ **DEPENDENCY_NOTE.md** → Merged into PROJECT_INFO.md
- ♻️ **CLAUDE_TECHNICAL_GUIDE.md** → Merged into AI_MASTER_GUIDE.md

**Result:** From 14 documents → **5 unified documents** ✨

---

### v1.4.0 - 18/10/2025

**Added:**
- ✅ GETTING_STARTED.md - Quick start for beginners
- ✅ Claude Code setup guide
- ✅ Updated all documentation links

---

### v1.3.0 - 16/10/2025

**Added:**
- ✅ SECURITY_GUIDE.md - Firebase Auth + Firestore Rules
- ✅ TESTING_GUIDE.md - Unit/Widget/Integration tests
- ✅ DOCS_STRUCTURE.md - Documentation index

**Cleaned:**
- ✅ Removed 5 duplicate/temporary files
- ✅ Updated STICKY_NOTES_DESIGN.md (imports + constants)

---

### v1.2.0 - 17/10/2025

**Added:**
- ✅ Receipt-to-Inventory system
- ✅ Product Location Memory
- ✅ Add-to-Shopping-List from Pantry
- ✅ Performance improvements (Debouncing, Isolate, Batch processing)

**Fixed:**
- ✅ withOpacity → withValues bug
- ✅ Hive removed (not in use)

---

### v1.1.0 - 16/10/2025

**Added:**
- ✅ Templates System (6 templates, 66 items)
- ✅ LocationsProvider migrated to Firebase
- ✅ Repository pattern improvements

---

### v1.0.0 - 15/10/2025

**Initial Release:**
- ✅ Firebase Auth + Firestore
- ✅ Sticky Notes Design System
- ✅ OCR with ML Kit
- ✅ Shufersal API integration
- ✅ 21 list types

---

## 🔧 Development Notes

### Important Paths

**Project Root:**
```
C:\projects\salsheli\
```

**Always use FULL paths when working with files:**
```
C:\projects\salsheli\lib\core\ui_constants.dart
```

**Never use relative paths:**
```
❌ lib\core\ui_constants.dart
❌ ./lib/core/ui_constants.dart
```

---

### Dependencies

**Core:**
- `firebase_core`: ^3.8.1
- `cloud_firestore`: ^5.6.1
- `firebase_auth`: ^5.3.3
- `provider`: ^6.1.2

**UI:**
- `google_fonts`: ^6.2.1
- `flutter_animate`: ^4.5.0

**ML:**
- `google_mlkit_text_recognition`: ^0.14.0

**Development:**
- `build_runner`: ^2.4.8
- `json_serializable`: ^6.8.0
- `mockito`: ^5.4.4

**Full list:** See `pubspec.yaml`

---

### Known Issues

**Fixed:**
1. ✅ Hive dependency conflict → Removed Hive (not in use)
2. ✅ withOpacity deprecated → Replaced with withValues
3. ✅ Race condition in signup → Added _isSigningUp flag

**Current:**
- None! 🎉

---

## 🤝 Contributing

### Code Style

- ✅ **Language:** Dart 3.6+
- ✅ **Formatting:** `dart format lib/`
- ✅ **Linting:** `flutter analyze` (0 issues)
- ✅ **Documentation:** Required for all public functions

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes
# ... edit files ...

# Format code
dart format lib/ -w

# Run tests
flutter test

# Commit (descriptive message!)
git commit -m "feat: add shopping list filters"

# Push
git push origin feature/my-feature

# Create Pull Request on GitHub
```

### Pull Request Checklist

- [ ] Code formatted (`dart format`)
- [ ] No linting errors (`flutter analyze`)
- [ ] Tests pass (`flutter test`)
- [ ] Documentation updated
- [ ] Breaking changes noted

---

## 📧 Contact & Support

### Team

- **Project Lead:** [Your Name]
- **Email:** your.email@example.com
- **GitHub:** [@Yehuda-sh](https://github.com/Yehuda-sh)

### Resources

- **Repository:** https://github.com/Yehuda-sh/salsheli
- **Issues:** https://github.com/Yehuda-sh/salsheli/issues
- **Discussions:** https://github.com/Yehuda-sh/salsheli/discussions
- **Wiki:** https://github.com/Yehuda-sh/salsheli/wiki

### Getting Help

1. **Check documentation first:**
   - GETTING_STARTED.md for setup
   - DEVELOPER_GUIDE.md for code questions
   - DESIGN_GUIDE.md for UI questions

2. **Search existing issues:**
   - https://github.com/Yehuda-sh/salsheli/issues

3. **Ask Claude (AI):**
   - Give it AI_MASTER_GUIDE.md at conversation start
   - Ask specific questions

4. **Create new issue:**
   - Use issue templates
   - Include code samples
   - Describe expected vs actual behavior

---

## 📜 License

**© 2025 Salsheli Team | All Rights Reserved**

[Add your license here - MIT, Apache, etc.]

---

## 🎉 Acknowledgments

### Built With

- ❤️ **Flutter** - Beautiful cross-platform apps
- 🔥 **Firebase** - Backend as a service
- 🤖 **Claude (Anthropic)** - AI coding assistant
- 🎨 **Material Design** - UI components

### Special Thanks

- Flutter team for excellent documentation
- Firebase team for robust backend
- Anthropic for Claude AI
- Open source community

---

## 🗺️ Roadmap

### Phase 1 - Core Features ✅ (Completed)
- [x] Firebase Auth
- [x] Firestore integration
- [x] Sticky Notes Design
- [x] Templates System
- [x] OCR (ML Kit)
- [x] Shufersal API

### Phase 2 - Enhanced UX (In Progress)
- [x] Receipt-to-Inventory
- [x] Product Location Memory
- [x] Add-to-Shopping from Pantry
- [ ] Barcode scanning
- [ ] Price comparison
- [ ] Shopping history analytics

### Phase 3 - Advanced Features (Planned)
- [ ] AI meal planning
- [ ] Budget tracking
- [ ] Nutritional information
- [ ] Recipe suggestions
- [ ] Smart notifications

### Phase 4 - Polish (Future)
- [ ] Offline mode
- [ ] Web app
- [ ] iOS release
- [ ] Multi-language support

---

## 🔍 Quick Links

### Internal Docs
- [AI_MASTER_GUIDE.md](AI_MASTER_GUIDE.md) - AI instructions
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Developer reference
- [DESIGN_GUIDE.md](DESIGN_GUIDE.md) - UI/UX guide
- [GETTING_STARTED.md](GETTING_STARTED.md) - Quick start

### External Resources
- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)

---

**Made with ❤️ in Israel** 🇮🇱  
**Version:** 2.0 | **Updated:** 18/10/2025  
**Purpose:** Complete project information and documentation index
