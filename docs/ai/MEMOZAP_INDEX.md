📚 MEMOZAP INDEX

For AI agent internal use only – primary entry point for all AI instructions.
Updated: 23/10/2025 | Version: 2.2 – Synced with UI Requirements

🧭 Purpose

This index defines which internal AI documents exist, what each one contains, and when the agent should read them.
Every session must begin with this index → it determines reading order and scope.

🗂️ Documents Overview

# File Focus When to Use

1 MEMOZAP_CORE_GUIDE.md General project overview, constants, file paths, and behavioral expectations. Always load first in every context.
2 MEMOZAP_UI_REQUIREMENTS.md UX/UI decisions, layout logic, and user interaction priorities based on real user feedback. Before generating or editing any UI, widget, or screen.
3 MEMOZAP_MCP_GUIDE.md MCP tools: Filesystem, Memory, Bash, GitHub, Sequential Thinking, Brave Search – including cooperation logic. Before performing actions involving MCP tools.
4 MEMOZAP_DEVELOPER_GUIDE.md Code patterns, architecture rules, provider/repository standards, and security best practices. During code review or new feature implementation.
5 MEMOZAP_TASKS_AND_SHARING.md Mixed item model (Tasks + Products) and multi-user sharing permissions. When modifying list models, Firestore structure, or permissions.
6 MEMOZAP_DESIGN_GUIDE.md Sticky Notes design system, color palette, typography, and component layout rules. When designing or adjusting visual elements.
7 MEMOZAP_PROJECT_INFO.md File hierarchy, statistics, tech stack, and dependency overview. When the AI needs structural or dependency context.
🧩 Cooperation Logic Between Guides

CORE → always first.
Sets global context: folder paths, file naming, base assumptions.

MCP → governs actions.
Ensures tool usage (edit_file, memory ops, etc.) follows Windows path rules.

DEVELOPER → governs code structure.
Applies provider/repository patterns and error handling standards.

UI_REQUIREMENTS + DESIGN → govern visuals and flows.
Translate user intent into layout and behavior.

TASKS_AND_SHARING → governs complex logic.
Apply when working on collaborative lists or unified item systems.

PROJECT_INFO → reference only.
For context verification and high-level structure understanding.

🔁 Update Rules

Whenever a new .md file is added to docs/ai/, update this index immediately.

File names must remain uppercase for clarity.

Version numbers mirror the latest edit date (YYYY/MM/DD).

Each AI agent (Claude, GPT, etc.) should read only what’s required per task to minimize token usage.

Last updated: 23/10/2025
Maintained by: AI System (automated)
Purpose: Entry point and hierarchy reference for all MemoZap AI documentation.
