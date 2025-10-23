# 📚 MemoZap Documentation Overview

> **Updated:** 23/10/2025  
> **Purpose:** Central entry point for AI and developer documentation.  
> **Audience:** Both human readers and AI agents (Claude, GPT).  
> **Main Path:** `C:\projects\salsheli\docs\`

---

## 🧩 Structure Overview

docs/
│
├── ai/ # 🤖 Internal AI logic and cooperation guides
│ ├── MEMOZAP_INDEX.md
│ ├── MEMOZAP_CORE_GUIDE.md
│ ├── MEMOZAP_MCP_GUIDE.md
│ ├── MEMOZAP_DEVELOPER_GUIDE.md
│ ├── MEMOZAP_DESIGN_GUIDE.md
│ ├── MEMOZAP_TASKS_AND_SHARING.md
│ ├── MEMOZAP_PROJECT_INFO.md
│ └── MEMOZAP_UI_REQUIREMENTS.md
│
├── CHANGELOG.md # 🕒 Tracks all major project updates
├── LESSONS_LEARNED.md # 📘 Common mistakes & prevention rules for AI
└── README.md # 📚 (This file)

---

## 🧠 Quick Summary for AI Agents

| File                             | Purpose                                 | When to Load                     |
| -------------------------------- | --------------------------------------- | -------------------------------- |
| **MEMOZAP_INDEX.md**             | Table of contents for all AI docs       | Always first                     |
| **MEMOZAP_CORE_GUIDE.md**        | Core instructions and operating context | Each new session                 |
| **MEMOZAP_MCP_GUIDE.md**         | MCP tools and cooperation logic         | When using Claude Desktop        |
| **MEMOZAP_DEVELOPER_GUIDE.md**   | Coding standards and provider patterns  | During refactor or review        |
| **MEMOZAP_DESIGN_GUIDE.md**      | UI/UX visuals, colors, components       | Before UI changes                |
| **MEMOZAP_TASKS_AND_SHARING.md** | User roles, list permissions            | When editing collaboration logic |
| **MEMOZAP_PROJECT_INFO.md**      | Project structure and stats             | For global understanding         |
| **MEMOZAP_UI_REQUIREMENTS.md**   | UX decisions & user expectations        | Before implementing screens      |

---

## 💡 Human Developer Summary

| File                   | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| **CHANGELOG.md**       | Shows what changed and when                           |
| **LESSONS_LEARNED.md** | Shows what failed and how to prevent it               |
| **docs/ai/**           | Reserved for AI-only logic — no need to edit manually |
| **README.md**          | Quick overview (this file)                            |

---

## ⚙️ Notes

- All paths are **Windows-based**, using the root:  
  `C:\projects\salsheli\`
- All AI-related markdown files follow same format:
  > “_For AI agent internal use only – not intended for human reading._”
- Claude and GPT agents must **read MEMOZAP_INDEX.md first** in every new session.

---

**Maintainer:** MemoZap AI System  
**Last Reviewed:** 23/10/2025  
**Next Review:** 01/11/2025  
**Version:** 1.0
