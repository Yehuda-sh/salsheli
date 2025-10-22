# 📋 MemoZap - Project Information

> **Complete project overview for AI systems**  
> **Updated:** 22/10/2025 | **Version:** 2.6 - Complete Structure

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
| **📁 Total lib/ Files** | 168 |
| **📚 Documentation** | 5 |
| **⚙️ Config Files** | 8 |
| **🎨 Core (Constants)** | 3 |
| **📦 Models** | 11 (+ 11 .g.dart + 2 utils) |
| **🔄 Providers** | 10 |
| **💾 Repositories** | 17 (8 interfaces + 9 implementations) |
| **🔧 Services** | 8 |
| **📱 Screens** | 36 (10 categories) |
| **🧩 Widgets** | 21 (4 categories) |
| **🧪 Test Files** | 29 (8 categories) |

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
├── lib/                            # 📱 Main application code (168 files)
│   ├── config/                    # ⚙️ Business logic config (8 files)
│   │   ├── filters_config.dart
│   │   ├── household_config.dart
│   │   ├── list_type_groups.dart
│   │   ├── list_type_mappings.dart
│   │   ├── pantry_config.dart
│   │   ├── receipt_patterns_config.dart
│   │   ├── storage_locations_config.dart
│   │   └── stores_config.dart
│   ├── core/                      # 🎨 UI constants & theme (3 files)
│   │   ├── constants.dart
│   │   ├── status_colors.dart
│   │   └── ui_constants.dart
│   ├── data/                      # 📊 Static data (1 file)
│   │   └── onboarding_data.dart
│   ├── l10n/                      # 🌐 Localization (3 files)
│   │   ├── app_strings.dart
│   │   ├── onboarding_extensions.dart
│   │   └── strings/
│   │       └── list_type_mappings_strings.dart
│   ├── layout/                    # 📐 Layout helpers (1 file)
│   │   └── app_layout.dart
│   ├── models/                    # 📦 Data models (24 files = 11 models + .g.dart + enums)
│   │   ├── active_shopper.dart (.g.dart)
│   │   ├── custom_location.dart (.g.dart)
│   │   ├── habit_preference.dart (.g.dart)
│   │   ├── inventory_item.dart (.g.dart)
│   │   ├── product_location_memory.dart (.g.dart)
│   │   ├── receipt.dart (.g.dart)
│   │   ├── shopping_list.dart (.g.dart)
│   │   ├── suggestion.dart (.g.dart)
│   │   ├── template.dart (.g.dart)
│   │   ├── user_entity.dart (.g.dart)
│   │   ├── timestamp_converter.dart
│   │   └── enums/
│   │       └── shopping_item_status.dart
│   ├── providers/                 # 🔄 State management (10 files)
│   │   ├── habits_provider.dart
│   │   ├── inventory_provider.dart
│   │   ├── locations_provider.dart
│   │   ├── products_provider.dart
│   │   ├── product_location_provider.dart
│   │   ├── receipt_provider.dart
│   │   ├── shopping_lists_provider.dart
│   │   ├── suggestions_provider.dart
│   │   ├── templates_provider.dart
│   │   └── user_context.dart
│   ├── repositories/              # 💾 Data access layer (19 files)
│   │   ├── constants/
│   │   │   └── repository_constants.dart
│   │   ├── utils/
│   │   │   └── firestore_utils.dart
│   │   ├── habits_repository.dart + firebase_habits_repository.dart
│   │   ├── inventory_repository.dart + firebase_inventory_repository.dart
│   │   ├── locations_repository.dart + firebase_locations_repository.dart
│   │   ├── products_repository.dart + firebase_products_repository.dart
│   │   ├── products_repository_optimized (firebase_products_repository_optimized.dart)
│   │   ├── receipt_repository.dart + firebase_receipt_repository.dart
│   │   ├── shopping_lists_repository.dart + firebase_shopping_lists_repository.dart
│   │   ├── templates_repository.dart + firebase_templates_repository.dart
│   │   └── user_repository.dart + firebase_user_repository.dart
│   ├── screens/                   # 📱 UI screens (36 files in 10 categories)
│   │   ├── auth/                  # 🔐 Authentication (2)
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── debug/                 # 🐛 Debug tools (1)
│   │   │   └── cleanup_screen.dart
│   │   ├── habits/                # 🎯 Habits (1)
│   │   │   └── my_habits_screen.dart
│   │   ├── home/                  # 🏠 Home & Dashboard (3)
│   │   │   ├── home_dashboard_screen.dart
│   │   │   ├── home_dashboard_screen_ux.dart
│   │   │   └── home_screen.dart
│   │   ├── insights/              # 📊 Analytics (1)
│   │   │   └── insights_screen.dart
│   │   ├── lists/                 # 📋 Templates (3)
│   │   │   ├── populate_list_screen.dart
│   │   │   ├── templates_screen.dart
│   │   │   └── template_form_screen.dart
│   │   ├── onboarding/            # 👋 Onboarding (2)
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/onboarding_steps.dart
│   │   ├── pantry/                # 🏪 Pantry/Inventory (1)
│   │   │   └── my_pantry_screen.dart
│   │   ├── price/                 # 💰 Price Comparison (1)
│   │   │   └── price_comparison_screen.dart
│   │   ├── receipts/              # 🧾 Receipt Management (5)
│   │   │   ├── link_receipt_screen.dart
│   │   │   ├── receipt_import_screen.dart
│   │   │   ├── receipt_to_inventory_screen.dart
│   │   │   ├── receipt_view_screen.dart
│   │   │   └── scan_receipt_screen.dart
│   │   ├── settings/              # ⚙️ Settings (1)
│   │   │   └── settings_screen.dart
│   │   ├── shopping/              # 🛒 Shopping Lists (6)
│   │   │   ├── active_shopping_screen.dart
│   │   │   ├── receipt_preview.dart
│   │   │   ├── receipt_scanner.dart
│   │   │   ├── shopping_lists_screen.dart
│   │   │   ├── shopping_list_details_screen.dart
│   │   │   └── shopping_summary_screen.dart
│   │   ├── index_screen.dart      # 🚪 Entry point
│   │   └── welcome_screen.dart    # 👋 Welcome
│   ├── services/                  # 🔧 Business logic services (8 files)
│   │   ├── auth_service.dart
│   │   ├── home_stats_service.dart
│   │   ├── ocr_service.dart
│   │   ├── onboarding_service.dart
│   │   ├── prefs_service.dart
│   │   ├── receipt_parser_service.dart
│   │   ├── receipt_to_inventory_service.dart
│   │   └── shufersal_prices_service.dart
│   ├── theme/                     # 🎨 App theme (1 file)
│   │   └── app_theme.dart
│   ├── widgets/                   # 🧩 Reusable widgets (21 files)
│   │   ├── auth/
│   │   │   └── demo_login_button.dart
│   │   ├── common/                # Common UI components (7)
│   │   │   ├── animated_button.dart
│   │   │   ├── benefit_tile.dart
│   │   │   ├── dashboard_card.dart
│   │   │   ├── notebook_background.dart
│   │   │   ├── sticky_button.dart
│   │   │   ├── sticky_note.dart
│   │   │   └── tappable_card.dart
│   │   ├── home/                  # Home widgets (2)
│   │   │   ├── smart_suggestions_card.dart
│   │   │   └── upcoming_shop_card.dart
│   │   ├── inventory/             # Inventory widgets (3)
│   │   │   ├── pantry_filters.dart
│   │   │   ├── receipt_to_inventory_dialog.dart
│   │   │   └── storage_location_manager.dart
│   │   ├── add_receipt_dialog.dart
│   │   ├── create_list_dialog.dart
│   │   ├── shopping_list_tile.dart
│   │   └── skeleton_loading.dart
│   ├── firebase_options.dart      # Firebase configuration
│   └── main.dart                  # 🚀 App entry point
│
├── test/                          # 🧪 Tests (29 files in 8 categories)
│   ├── concurrent/                # ⚡ Concurrency tests (1)
│   │   └── multi_user_test.dart
│   ├── helpers/                   # 🛠️ Test utilities (2)
│   │   ├── mock_data.dart
│   │   └── test_helpers.dart
│   ├── integration/               # 🔗 Integration tests (5)
│   │   ├── auth/
│   │   │   ├── login_flow_integration_test.dart (.mocks.dart)
│   │   │   └── register_flow_integration_test.dart (.mocks.dart)
│   │   └── login_flow_test.dart (.mocks.dart)
│   ├── models/                    # 📦 Model tests (10)
│   │   ├── custom_location_test.dart
│   │   ├── enums/shopping_item_status_test.dart
│   │   ├── habit_preference_test.dart
│   │   ├── inventory_item_test.dart
│   │   ├── receipt_test.dart
│   │   ├── shopping_list_test.dart
│   │   ├── suggestion_test.dart
│   │   ├── template_test.dart
│   │   ├── timestamp_converter_test.dart
│   │   └── user_entity_test.dart
│   ├── offline/                   # 📴 Offline mode tests (1)
│   │   └── offline_mode_test.dart
│   ├── providers/                 # 🔄 Provider tests (2)
│   │   └── user_context_test.dart (.mocks.dart)
│   ├── repositories/              # 💾 Repository tests (3)
│   │   ├── firebase_habits_repository_test.dart
│   │   ├── firebase_inventory_repository_test.dart
│   │   └── firestore_utils_test.dart
│   ├── rtl/                       # 🔄 RTL support tests (1)
│   │   └── rtl_layout_test.dart
│   ├── screens/                   # 📱 Screen tests (3)
│   │   ├── index_screen_test.dart (.mocks.dart)
│   │   └── onboarding/onboarding_screen_test.dart
│   ├── QUICK_START.md
│   └── README.md
│
├── docs/                          # 📚 Documentation (5 files)
│   ├── AI_MASTER_GUIDE.md         # AI behavior instructions
│   ├── DESIGN_GUIDE.md            # UI/UX guidelines
│   ├── DEVELOPER_GUIDE.md         # Code patterns & testing
│   ├── MCP_TOOLS_GUIDE.md         # MCP tools reference
│   └── PROJECT_INFO.md            # This file!
│
├── assets/                        # 🎨 Images, fonts, static resources
├── android/                       # 🤖 Android configuration
│   └── app/google-services.json  # ✅ Firebase Android config
├── ios/                           # 🍎 iOS configuration
│   └── Runner/GoogleService-Info.plist  # ✅ Firebase iOS config
├── web/                           # 🌐 Web configuration
├── scripts/                       # 🔧 Build automation scripts
├── pubspec.yaml                   # 📦 Dependencies
├── analysis_options.yaml          # 🔍 Linter rules
└── build_and_run.bat             # ⚡ Build & run automation
```

---

## 📚 The 5 Core Documents

### 1. 🤖 AI_MASTER_GUIDE.md
**For:** AI assistants  
**Contains:**
- Communication guidelines
- Auto code review (22 checks!)
- Technical fixes
- Dead/Dormant code detection
- Security, Performance, Accessibility, Navigation, Usage checks

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

### v2.6 - 22/10/2025 🆕 **LATEST - Complete Structure Update**
- ✅ Updated Project Structure with EXACT file count (168 files)
- ✅ Detailed breakdown of all folders (lib, test, docs)
- ✅ Added emojis for better readability
- ✅ Updated statistics: Models (11), Providers (10), Repos (17), Services (8), Screens (36), Widgets (21), Tests (29)
- 📊 Result: Complete, accurate, AI-optimized structure reference

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

**Version:** 2.6  
**Created:** 18/10/2025 | **Updated:** 22/10/2025  
**Purpose:** Complete project reference with accurate structure
