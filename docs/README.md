# 📚 MemoZap Documentation Overview

> **Updated:** 25/10/2025  
> **Version:** 2.1  
> **Purpose:** Master entry point for all AI and developer documentation  
> **Audience:** Both human readers and AI agents (Claude, GPT)  
> **Main Path:** `C:\projects\salsheli\docs\`

---

## 🧭 Purpose & Usage

This README serves as the **primary entry point** for all MemoZap documentation. Every AI session should begin here to understand the documentation structure and determine which files to load for specific tasks.

### For AI Agents
- **Always read this file first** - it maps all available documentation
- Load task-specific docs on-demand to minimize token usage
- Follow the "Cooperation Logic" to understand document relationships
- Update this file when adding new documentation

### For Human Developers
- Start here to navigate the documentation
- Check CHANGELOG.md for recent updates
- See "Human Developer Summary" section below for quick start

---

## 🗂️ Complete Documentation Index

### 📋 Core Documents (Load Every Session)
| # | File | Purpose | When to Load |
|---|------|---------|--------------|
| 1 | **README.md** | Master index and navigation (this file) | 🔴 Always first |
| 2 | **MEMOZAP_CORE_GUIDE.md** | Operating context, paths, constants, behavioral expectations | 🔴 Always second |

### 🎯 Task-Specific Documents
| # | File | Purpose | When to Load |
|---|------|---------|--------------|
| 3 | **MEMOZAP_UI_REQUIREMENTS.md** | UX/UI decisions, layout logic, user interaction priorities | Before generating/editing UI, widgets, screens |
| 4 | **MEMOZAP_MCP_GUIDE.md** | MCP tools (Filesystem, Memory, Bash, GitHub, Search) + cooperation logic | Before using any MCP tools |
| 5 | **MEMOZAP_DEVELOPER_GUIDE.md** | Code patterns, architecture rules, provider/repository standards | During code review or feature implementation |
| 6 | **MEMOZAP_TASKS_AND_SHARING.md** | Mixed item model (Tasks + Products) and multi-user sharing permissions | When modifying lists, Firestore structure, permissions |
| 7 | **MEMOZAP_DESIGN_GUIDE.md** | Sticky Notes design system, color palette, typography, components | When designing or adjusting visual elements |
| 8 | **MEMOZAP_SECURITY_AND_RULES.md** | Security patterns, validation rules, Firestore rules | When handling auth, permissions, data validation |

### 📚 Reference Documents
| # | File | Purpose | When to Use |
|---|------|---------|-------------|
| 9 | **MEMOZAP_PROJECT_INFO.md** | File hierarchy, statistics, tech stack, dependency overview | For structural or dependency context verification |
| 10 | **CHANGELOG.md** | Project history, version updates, completed work | To track recent changes or understand project evolution |
| 11 | **LESSONS_LEARNED.md** | Known pitfalls, recurring errors, prevention strategies | **Before making risky changes** or after encountering errors |
| 12 | **IMPLEMENTATION_ROADMAP.md** | Feature priorities, planning, future work | For roadmap discussions or prioritization questions |
| 13 | **TASK_SUPPORT_OPTIONS.md** | Task system design decisions and alternatives | When discussing task feature implementations |

---

## 🧩 Cooperation Logic Between Guides

Understanding document relationships helps determine which files to read together:

### **CORE_GUIDE** → Foundation (Always First)
- Sets global context: folder paths, file naming, base assumptions
- Defines behavioral expectations and response formats
- Establishes constants and environment details

### **MCP_GUIDE** → Governs Actions
- Ensures tool usage follows Windows path rules
- Defines cooperation between MCP tools and VS Code workflow
- Specifies checkpoint and session continuity protocols

### **DEVELOPER_GUIDE** → Governs Code Structure
- Applies provider/repository patterns
- Enforces error handling standards
- Defines code organization rules

### **UI_REQUIREMENTS + DESIGN_GUIDE** → Govern Visuals & Flows
- Translate user intent into layout and behavior
- Apply design system consistently
- Ensure RTL (Hebrew) support

### **TASKS_AND_SHARING** → Governs Complex Logic
- Apply when working on collaborative lists
- Handle unified item systems (mixed products/tasks)
- Manage multi-user permissions

### **SECURITY_AND_RULES** → Governs Data Safety
- Apply when handling user permissions
- Validate data before Firestore operations
- Implement security patterns

### **PROJECT_INFO** → Reference Only
- For context verification
- High-level structure understanding
- No action requirements

---

## 📖 Common Task Scenarios

### UI/UX Work
```
Read: DESIGN_GUIDE + UI_REQUIREMENTS
Optional: DEVELOPER_GUIDE (for widget patterns)
```

### Code Review/Refactoring
```
Read: DEVELOPER_GUIDE + CORE_GUIDE
Check: LESSONS_LEARNED (before risky changes)
```

### MCP Tool Integration
```
Read: MCP_GUIDE
Reference: CORE_GUIDE (for paths)
```

### Permissions & Sharing
```
Read: TASKS_AND_SHARING + SECURITY_AND_RULES
Reference: DEVELOPER_GUIDE (for Firestore patterns)
```

### New Feature Implementation
```
Read: DEVELOPER_GUIDE + UI_REQUIREMENTS + DESIGN_GUIDE
Check: IMPLEMENTATION_ROADMAP (priorities)
Update: CHANGELOG (after completion)
```

---

## 🗂️ File Structure

```
docs/
│
├── ai/                              # 🤖 Internal AI logic and cooperation guides
│   ├── MEMOZAP_CORE_GUIDE.md       # Core instructions & environment
│   ├── MEMOZAP_MCP_GUIDE.md        # MCP tools & cooperation logic
│   ├── MEMOZAP_DEVELOPER_GUIDE.md  # Code patterns & architecture
│   ├── MEMOZAP_DESIGN_GUIDE.md     # UI/UX design system
│   ├── MEMOZAP_UI_REQUIREMENTS.md  # User experience requirements
│   ├── MEMOZAP_TASKS_AND_SHARING.md # Collaboration & permissions
│   ├── MEMOZAP_SECURITY_AND_RULES.md # Security patterns & validation
│   └── MEMOZAP_PROJECT_INFO.md     # Project structure & stats
│
├── CHANGELOG.md                     # 🕒 All project updates
├── IMPLEMENTATION_ROADMAP.md        # 🗺️ Feature roadmap & priorities
├── TASK_SUPPORT_OPTIONS.md          # 🔧 Task system implementation options
├── LESSONS_LEARNED.md               # 📘 Common mistakes & prevention
└── README.md                        # 📚 This file (master entry point)
```

---

## 💾 Checkpoint & Continuity Protocol

### Auto-Save Rules
- Create checkpoint after every **3-5 file modifications**
- Update CHANGELOG.md with `[In Progress]` section
- Use memory tools to store session state
- Before context limit: save detailed "Next Steps"

### Checkpoint Format
```
✅ Checkpoint #N saved:
- [List of completed changes]
⏳ Next: [Exact next task]
```

### Continuity Commands
| Command | Action |
|---------|--------|
| **"תמשיך"** (Continue) | Load last checkpoint and resume work |
| **"שמור checkpoint"** (Save checkpoint) | Force manual save point |
| **"המשך"** (Resume) | Load recent_chats and continue from last message |

### Resume Process
1. Read CHANGELOG.md `[In Progress]` section
2. Check conversation memory for last session
3. Load last checkpoint state
4. Continue from exact stopping point

---

## 💡 Human Developer Summary

### Essential Files
| File | Purpose | Who Updates |
|------|---------|-------------|
| **CHANGELOG.md** | What changed and when | AI (with manual review) |
| **LESSONS_LEARNED.md** | What failed and how to prevent it | AI (after errors) |
| **IMPLEMENTATION_ROADMAP.md** | Feature roadmap and priorities | Manual (team decisions) |
| **docs/ai/** | AI-only logic files | AI only (no manual edits) |
| **README.md** | Master index (this file) | AI + manual review |

### Reading Order for New Developers
1. **This README** - Get documentation overview
2. **CHANGELOG.md** - See recent updates
3. **IMPLEMENTATION_ROADMAP.md** - Understand priorities
4. **docs/ai/MEMOZAP_PROJECT_INFO.md** - Learn project structure
5. **docs/ai/MEMOZAP_DEVELOPER_GUIDE.md** - Understand code patterns

### Quick Command Reference
```bash
# View project structure
tree /F docs

# Search documentation
findstr /S /I "keyword" docs\*.md

# View recent changes
type docs\CHANGELOG.md
```

---

## 🎯 Core Principles

### For AI Agents
- ✅ All docs follow Windows paths (`C:\projects\salsheli\`)
- ✅ AI docs are in `docs/ai/` - not for manual editing
- ✅ Always validate against existing patterns before changes
- ✅ Maintain Hebrew (RTL) support in all UI components
- ✅ Track all modifications in CHANGELOG.md
- ✅ Use memory for cross-session continuity
- ✅ Read only required docs to minimize token usage

### File Change Protocol
1. Show clear diff summaries before applying changes
2. Explain reasoning for each modification
3. Update relevant documentation after code changes
4. Preserve existing patterns unless explicitly asked to refactor

### Documentation Update Rules
- When adding a new .md file to `docs/ai/`, update this README immediately
- File names must remain UPPERCASE for clarity
- Each guide tracks its own version in the header
- Update CHANGELOG.md with documentation changes

---

## 🔧 Technical Notes

### Environment
- **OS:** Windows 11 Home
- **Project Root:** `C:\projects\salsheli\`
- **Editor:** VS Code
- **Terminal:** PowerShell inside VS Code
- **Mobile Testing:** Android Emulator (always active during development)

### Path Format
All paths use **Windows backslashes**: `C:\projects\salsheli\lib\models\`

### Documentation Standards
All AI-related markdown files begin with:
> "_For AI agent internal use only – not intended for human reading._"

### Version Control
- README version reflects major structural changes
- Each guide tracks its own version in the header
- CHANGELOG.md tracks overall project versions
- Update dates use DD/MM/YYYY format

---

## 📊 Documentation Stats

| Metric | Value |
|--------|-------|
| Total AI Guides | 8 |
| Reference Docs | 5 |
| Last Major Update | 25/10/2025 |
| Documentation Version | 2.1 |

---

## 🔗 Cross-Reference Quick Links

| Need Help With... | Read This File |
|-------------------|---------------|
| Code patterns & architecture | `MEMOZAP_DEVELOPER_GUIDE.md` |
| UI design & components | `MEMOZAP_DESIGN_GUIDE.md` |
| MCP tool integration | `MEMOZAP_MCP_GUIDE.md` |
| Task & sharing system | `MEMOZAP_TASKS_AND_SHARING.md` |
| UI specifications | `MEMOZAP_UI_REQUIREMENTS.md` |
| Security & validation | `MEMOZAP_SECURITY_AND_RULES.md` |
| Past mistakes | `LESSONS_LEARNED.md` |
| Version history | `CHANGELOG.md` |
| Project structure | `MEMOZAP_PROJECT_INFO.md` |

---

**Maintainer:** MemoZap AI System  
**Last Updated:** 25/10/2025  
**Next Review:** 01/11/2025  
**Contact:** docs/ai/ for AI protocols, manual review for human-facing content
