# 📋 Salsheli - Project Information

> **Complete project overview for AI systems**  
> **Updated:** 19/10/2025 | **Version:** 2.3 - Cleaned & Optimized

---

## 🎯 Project Overview

**Salsheli** (סל שלי = "My Cart") - Family shopping list management app.

**Key Features:**
- 👨‍👩‍👧‍👦 Multi-user household collaboration
- 📱 Cross-platform (iOS, Android, Web)
- 🎨 Sticky Notes Design System
- 🔒 household-based security
- 📸 OCR receipt scanning (ML Kit)
- 🛒 21 list types, 6 templates, 66 pre-loaded items

---

## 📊 Project Statistics

### Codebase

| Category | Count |
|----------|-------|
| **Documentation Files** | 5 (optimized!) |
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

## 📂 Project Structure

```
C:\projects\salsheli\
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
└── docs/                  # 5 core documents
```

---

## 📚 The 5 Core Documents

### 1. 🤖 AI_MASTER_GUIDE.md
**For:** AI assistants  
**Contains:**
- Communication guidelines
- Auto code review (13 checks)
- Technical fixes
- Dead/Dormant code detection
- Security, Performance, Accessibility

**When:** Start of EVERY AI conversation

---

### 2. 👨‍💻 DEVELOPER_GUIDE.md
**For:** Developers  
**Contains:**
- Quick Reference
- Architecture patterns
- Code examples
- Testing guidelines
- Security best practices
- Checklists

**When:** Writing or reviewing code

---

### 3. 🎨 DESIGN_GUIDE.md
**For:** UI/UX work  
**Contains:**
- Sticky Notes Design System
- Color palette
- Components
- Compact design
- Accessibility

**When:** Creating or updating screens

---

### 4. 📋 PROJECT_INFO.md
**For:** Understanding the project  
**Contains:**
- Project overview (this file!)
- Tech stack
- Structure
- Documentation index

**When:** Understanding architecture

---

### 5. 🛠️ MCP_TOOLS_GUIDE.md
**For:** AI using Claude Desktop  
**Contains:**
- 11 MCP tools guide
- Workflows
- Anti-patterns
- Troubleshooting

**When:** Working with MCP tools

---

## 🚀 Quick Start

### Prerequisites

```bash
flutter doctor  # Verify: Flutter 3.27+, Dart 3.6+
```

### Installation

```bash
git clone https://github.com/Yehuda-sh/salsheli.git
cd salsheli
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Build

```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS
flutter build web --release   # Web
```

---

## 📗 Documentation Index

### By Use Case

| Need | Document |
|------|----------|
| **Getting started** | PROJECT_INFO.md (this file) |
| **Writing code** | DEVELOPER_GUIDE.md |
| **Architecture** | DEVELOPER_GUIDE.md |
| **Design UI** | DESIGN_GUIDE.md |
| **AI instructions** | AI_MASTER_GUIDE.md |
| **MCP tools** | MCP_TOOLS_GUIDE.md |

### Reading Order

**For AI Assistants 🤖:**
```
1. AI_MASTER_GUIDE.md (START HERE - EVERY conversation!)
2. PROJECT_INFO.md (THIS FILE - understand structure)
3. MCP_TOOLS_GUIDE.md (if using MCP)
4. DEVELOPER_GUIDE.md (reference as needed)
5. DESIGN_GUIDE.md (reference as needed)
```

**For Developers 👨‍💻:**
```
1. PROJECT_INFO.md (this file)
2. DEVELOPER_GUIDE.md
3. DESIGN_GUIDE.md
4. AI_MASTER_GUIDE.md (if using AI)
```

---

## 📖 Change History

### v2.3 - 19/10/2025 🆕 **LATEST - Cleaned & Optimized**
- 🧹 Removed contact info, license (not relevant for AI)
- ✂️ Removed old version history (kept 3 latest)
- ✂️ Removed roadmap, acknowledgments (not relevant for AI)
- 📊 Result: 50% reduction in size

### v2.2 - 19/10/2025
- ✅ Added 13th check: Navigation/Orphan Screens
- ✅ Updated all documentation

### v2.1 - 19/10/2025
- ✅ Added MCP_TOOLS_GUIDE.md
- ✅ Updated to 6 documents

---

## 📌 Important Paths

**Project Root:**
```
C:\projects\salsheli\
```

**Always use FULL paths:**
```
C:\projects\salsheli\lib\core\ui_constants.dart
```

**Never use relative paths:**
```
❌ lib\core\ui_constants.dart
❌ ./lib/core/ui_constants.dart
```

---

## 🔧 Dependencies

**Core:**
- `firebase_core`, `cloud_firestore`, `firebase_auth`
- `provider`

**UI:**
- `google_fonts`, `flutter_animate`

**ML:**
- `google_mlkit_text_recognition`

**Development:**
- `build_runner`, `json_serializable`, `mockito`

**Full list:** See `pubspec.yaml`

---

**Version:** 2.3  
**Created:** 18/10/2025 | **Updated:** 19/10/2025  
**Purpose:** Project overview for AI systems
