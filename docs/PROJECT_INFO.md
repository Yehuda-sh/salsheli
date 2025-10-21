# 📋 MemoZap - Project Information

> **Complete project overview for AI systems**  
> **Updated:** 20/10/2025 | **Version:** 2.5 - AI Optimized

---

## 🎯 Project Overview

**MemoZap** - Family shopping list management app with smart memo features.

**Key Features:**
- 👨‍👩‍👧‍👦 Multi-user household collaboration
- 📱 Cross-platform (iOS, Android, Web)
- 🎨 Sticky Notes Design System
- 🔒 household-based security
- 📸 OCR receipt scanning (ML Kit)
- 🛒 21 list types, 6 templates, 66 pre-loaded items
- 💰 Shufersal Public API integration (dynamic pricing)
- 🌐 Multi-language support (l10n)

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
- **ML:** ML Kit (Text Recognition OCR)
- **External API:** Shufersal Public API (dynamic pricing)
- **Data Processing:** XML parsing, GZ decompression
- **HTTP Client:** http package
- **Localization:** l10n (multi-language support)

---

## 📂 Project Structure

```
C:\projects\salsheli\
├── lib/
│   ├── core/              # UI constants, theme base
│   ├── models/            # 11 data models
│   ├── providers/         # 9 state providers
│   ├── repositories/      # 17 data repositories
│   ├── services/          # 7 services (including Shufersal API)
│   ├── screens/           # 30+ screens
│   ├── widgets/           # 25+ reusable widgets
│   ├── config/            # Business logic config
│   ├── data/              # Static data (onboarding)
│   ├── layout/            # Layout helpers
│   ├── l10n/              # Localization files
│   ├── theme/             # Theme configuration
│   ├── firebase_options.dart  # Firebase config
│   └── main.dart          # App entry point
├── test/                  # 50+ tests (8 categories)
│   ├── models/            # Model tests
│   ├── providers/         # Provider tests
│   ├── repositories/      # Repository tests
│   ├── concurrent/        # Concurrency tests
│   ├── integration/       # Integration tests
│   ├── offline/           # Offline mode tests
│   ├── rtl/               # RTL support tests
│   └── helpers/           # Test utilities
├── assets/                # Images, fonts
├── docs/                  # 5 core documents
├── android/               # Android config + google-services.json
├── ios/                   # iOS config (⚠️ GoogleService-Info.plist needed)
└── scripts/               # Build automation scripts
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

## 🔧 Configuration Status

**Firebase:**
- **Android:** ✅ `google-services.json` exists
- **iOS:** ✅ `GoogleService-Info.plist` exists
- **Web:** ✅ `firebase_options.dart` exists
- **Project:** `memozap-5ad30`

**Shufersal API:**
- ✅ Public API (no authentication)
- Scrapes prices from `https://prices.shufersal.co.il/`
- Service: `lib/services/shufersal_prices_service.dart`

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

### v2.5 - 20/10/2025 🆕 **LATEST - AI Optimized**
- ✂️ Removed Quick Start commands (not relevant for AI)
- ✂️ Removed detailed Firebase setup (just status)
- ✂️ Removed detailed Shufersal API usage (just overview)
- ✂️ Kept only latest version (reduced size)
- 📊 Focused on structure + overview for AI

---

## 🔧 Dependencies

**Core:**
- `firebase_core`, `cloud_firestore`, `firebase_auth`
- `provider`

**UI:**
- `google_fonts`, `flutter_animate`

**ML:**
- `google_mlkit_text_recognition`

**API & Data:**
- `http` - HTTP requests
- `xml` - XML parsing (Shufersal)
- `archive` - GZ decompression

**Development:**
- `build_runner`, `json_serializable`, `mockito`

**Full list:** See `pubspec.yaml`

---

**Version:** 2.5  
**Created:** 18/10/2025 | **Updated:** 20/10/2025  
**Purpose:** Project overview for AI systems
