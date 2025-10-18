# 🛒 Salsheli - סל שלי

> **Family shopping list management app** | Built with Flutter + Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.1-blue)](CHANGELOG.md)

---

## 🎯 What is Salsheli?

**Smart family shopping list manager** with unique Sticky Notes design.

### Key Features

- 👨‍👩‍👧‍👦 **Multi-user collaboration** - Share lists with household members
- 🎨 **Unique Sticky Notes theme** - Beautiful post-it style UI
- 📸 **OCR receipt scanning** - Scan and import items automatically
- 🔒 **Household-based security** - Your data stays private
- 🛒 **21 list types + 6 templates** - Pre-loaded with 66 common items
- 🏪 **Shufersal API integration** - 1,758 products database

---

## 🚀 Quick Start

### For New Users

**🆕 First time here?** → [**GETTING_STARTED.md**](GETTING_STARTED.md) (5-10 min)

**📋 Want full project overview?** → [**PROJECT_INFO.md**](PROJECT_INFO.md)

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Yehuda-sh/salsheli.git
cd salsheli

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

## 📚 Documentation (6 Core Documents)

### By Role

| Role | Document | What's Inside |
|------|----------|---------------|
| 🆕 **Beginner** | [GETTING_STARTED.md](GETTING_STARTED.md) | 5-10 min quick start guide |
| 👨‍💻 **Developer** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | Code patterns, testing, security |
| 🎨 **Designer** | [DESIGN_GUIDE.md](DESIGN_GUIDE.md) | Sticky Notes Design System |
| 🤖 **AI Assistant** | [AI_MASTER_GUIDE.md](AI_MASTER_GUIDE.md) | AI behavior + auto code review |
| 🛠️ **Using Claude Desktop** | [MCP_TOOLS_GUIDE.md](MCP_TOOLS_GUIDE.md) | MCP tools reference |
| 📋 **Project Manager** | [PROJECT_INFO.md](PROJECT_INFO.md) | Complete project overview |

### By Task

| Need | Go To | Section |
|------|-------|---------|
| **Write code** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | Architecture + Examples |
| **Design screens** | [DESIGN_GUIDE.md](DESIGN_GUIDE.md) | Components + Colors |
| **Test code** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | Testing Guidelines |
| **Secure data** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | Security Best Practices |
| **Optimize performance** | [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) | Performance Tips |
| **Use MCP tools** | [MCP_TOOLS_GUIDE.md](MCP_TOOLS_GUIDE.md) | Tools + Workflows |

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.27+ |
| **Language** | Dart 3.6+ |
| **Backend** | Firebase (Auth, Firestore, Functions) |
| **State Management** | Provider |
| **Database** | Cloud Firestore |
| **ML/OCR** | ML Kit (Text Recognition) |
| **External API** | Shufersal (1,758 products) |
| **Design System** | Sticky Notes (Custom) |
| **Testing** | flutter_test, mockito |
| **CI/CD** | GitHub Actions (planned) |

---

## 📊 Project Stats

- 📁 **100+ Dart files**
- 🧪 **50+ tests** (90%+ model coverage)
- 📋 **11 data models**
- 🔄 **9 providers**
- 🗄️ **17 repositories**
- 🎨 **30+ screens**
- 🧩 **25+ widgets**
- 📖 **6 documentation files** (lean & focused)

---

## 🆕 What's New (v2.1 - Oct 19, 2025)

### Documentation Updates
- ✅ **MCP_TOOLS_GUIDE.md** - Complete guide for Claude Desktop MCP tools
- ✅ **AI_MASTER_GUIDE.md** - Reduced from 1500 to 500 lines (67% lighter!)
- ✅ **GETTING_STARTED.md** - Removed marketing content (32% lighter)
- ✅ **DESIGN_GUIDE.md** - Removed code duplications (37% lighter)
- ✅ **Overall reduction** - ~50% less documentation, same value!

### Recent Features (v2.0 - Oct 18, 2025)
- ✅ Receipt-to-Inventory system
- ✅ Product Location Memory
- ✅ Add-to-Shopping from Pantry
- ✅ Performance improvements (debouncing, batch processing)
- ✅ Documentation unification (14 → 6 files)

**📖 Full changelog:** See [PROJECT_INFO.md](PROJECT_INFO.md#change-history)

---

## 📂 Project Structure

```
salsheli/
├── lib/
│   ├── core/              # UI constants, theme
│   ├── models/            # 11 data models
│   ├── providers/         # 9 state providers
│   ├── repositories/      # 17 data repositories
│   ├── services/          # 7 services
│   ├── screens/           # 30+ screens
│   ├── widgets/           # 25+ reusable widgets
│   ├── config/            # Business logic config
│   └── main.dart          # App entry point
├── test/                  # 50+ tests
├── assets/                # Images, fonts
└── docs/                  # 6 core documents
    ├── AI_MASTER_GUIDE.md
    ├── DEVELOPER_GUIDE.md
    ├── DESIGN_GUIDE.md
    ├── GETTING_STARTED.md
    ├── MCP_TOOLS_GUIDE.md
    └── PROJECT_INFO.md
```

---

## 🤝 Contributing

### Getting Started
1. Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. Check [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for code patterns
3. Follow [DESIGN_GUIDE.md](DESIGN_GUIDE.md) for UI/UX

### Code Style
- ✅ Run `dart format lib/ -w` before commit
- ✅ Ensure `flutter analyze` shows 0 issues
- ✅ Write tests for new features
- ✅ Update documentation

### Pull Request Checklist
- [ ] Code formatted and analyzed
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Follows Sticky Notes Design System
- [ ] No breaking changes (or documented)

---

## 📧 Contact & Support

### Team
- **Project Lead:** [Your Name]
- **Email:** your.email@example.com
- **GitHub:** [@Yehuda-sh](https://github.com/Yehuda-sh)

### Resources
- **🐛 Report Bug:** [Create Issue](https://github.com/Yehuda-sh/salsheli/issues/new)
- **💡 Feature Request:** [Discussions](https://github.com/Yehuda-sh/salsheli/discussions)
- **📖 Documentation:** All docs in this repo
- **🔧 Support:** Check docs first, then create issue

---

## 📜 License

**© 2025 Salsheli Team | All Rights Reserved**

[Add your license here - MIT, Apache, Proprietary, etc.]

---

## 🙏 Acknowledgments

Built with:
- ❤️ **Flutter** - Beautiful cross-platform apps
- 🔥 **Firebase** - Scalable backend
- 🤖 **Claude (Anthropic)** - AI coding assistant
- 🎨 **Material Design** - UI components

Special thanks to the open source community!

---

**Made with ❤️ in Israel** 🇮🇱  
**Version:** 2.1 | **Updated:** 19/10/2025

**🚀 Ready to start?** → [GETTING_STARTED.md](GETTING_STARTED.md)
