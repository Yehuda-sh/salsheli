# 📚 MemoZap Documentation Overview

> **Updated:** 24/10/2025  
> **Version:** 2.0  
> **Purpose:** Central entry point for AI and developer documentation  
> **Audience:** Both human readers and AI agents (Claude, GPT)  
> **Main Path:** `C:\projects\salsheli\docs\`

---

## 🧩 Structure Overview

```
docs/
│
├── ai/                              # 🤖 Internal AI logic and cooperation guides
│   ├── MEMOZAP_INDEX.md            # Master index - always read first
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
└── README.md                        # 📚 This file
```

---

## 🧠 Quick Reference for AI Agents

### Core Documents (Load Every Session)
| File | Purpose | Priority |
|------|---------|----------|
| **MEMOZAP_INDEX.md** | Master index and navigation guide | 🔴 Always first |
| **MEMOZAP_CORE_GUIDE.md** | Operating context, paths, protocols | 🔴 Always second |

### Task-Specific Documents
| File | Purpose | When to Load |
|------|---------|--------------|
| **MEMOZAP_MCP_GUIDE.md** | MCP tools (Filesystem, Memory, GitHub, etc.) | Before using MCP tools |
| **MEMOZAP_DEVELOPER_GUIDE.md** | Code patterns, providers, repositories | During code review/refactor |
| **MEMOZAP_DESIGN_GUIDE.md** | Sticky Notes design system & colors | Before UI changes |
| **MEMOZAP_UI_REQUIREMENTS.md** | UX decisions based on user feedback | Before implementing screens |
| **MEMOZAP_TASKS_AND_SHARING.md** | Mixed item model & permissions | When editing lists/collaboration |
| **MEMOZAP_SECURITY_AND_RULES.md** | Security patterns & validation rules | When handling auth/permissions |

### Reference Documents
| File | Purpose | When to Use |
|------|---------|-------------|
| **MEMOZAP_PROJECT_INFO.md** | File hierarchy, tech stack, statistics | For structural context |
| **CHANGELOG.md** | Project history and updates | To track recent changes |
| **LESSONS_LEARNED.md** | Known pitfalls and solutions | Before making changes |
| **IMPLEMENTATION_ROADMAP.md** | Feature priorities and planning | For roadmap discussions |
| **TASK_SUPPORT_OPTIONS.md** | Task system design decisions | When discussing task features |

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
| **README.md** | Quick overview (this file) | AI + manual review |

### Reading Order for New Developers
1. **This README** - Get overview
2. **CHANGELOG.md** - See recent updates
3. **IMPLEMENTATION_ROADMAP.md** - Understand priorities
4. **docs/ai/MEMOZAP_PROJECT_INFO.md** - Learn project structure

---

## 🎯 Core Principles

### For AI Agents
- ✅ All docs follow Windows paths (`C:\projects\salsheli\`)
- ✅ AI docs are in `docs/ai/` - not for manual editing
- ✅ Always validate against existing patterns before changes
- ✅ Maintain Hebrew (RTL) support in all UI components
- ✅ Track all modifications in CHANGELOG.md
- ✅ Use memory for cross-session continuity

### File Change Protocol
1. Show clear diff summaries before applying changes
2. Explain reasoning for each modification
3. Update relevant documentation after code changes
4. Preserve existing patterns unless explicitly asked to refactor

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
- Each guide tracks its own version in the header
- CHANGELOG.md tracks overall project versions
- README version reflects major structural changes

---

## 📊 Documentation Stats

| Metric | Count |
|--------|-------|
| Total AI Guides | 9 |
| Reference Docs | 4 |
| Last Major Update | 24/10/2025 |
| Documentation Version | 2.0 |

---

**Maintainer:** MemoZap AI System  
**Last Reviewed:** 24/10/2025  
**Next Review:** 01/11/2025  
**Contact:** docs/ai/ for AI protocols, manual review for human-facing content
