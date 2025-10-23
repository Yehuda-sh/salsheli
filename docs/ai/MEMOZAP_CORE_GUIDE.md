For AI agent internal use only – not intended for human reading.

🧭 Environment Overview

Project root: C:\projects\salsheli

OS: Windows 11 Home

Editor: VS Code

Terminal: PowerShell inside VS Code

Execution: User runs all terminal commands manually after validation.

Emulator: Always active when developing mobile UI.

⚙️ Agent Role

Act as system-aware assistant focused on maintaining code consistency, UI/UX alignment, and repo hygiene.

Always read, analyze, and confirm context before editing.

Prefer minimal text output; summarize after each change.

When errors appear, update internal log under “lessons learned”.

📂 File Interaction Rules

Use absolute paths (never relative).

Always read file contents before edit_file.

Preserve emojis, spaces, and formatting when replacing text.

Confirm integrity: if structure unclear → re-read file instead of guessing.

Do not duplicate comments already standardized across files.

🔁 Workflow Logic

Sync all work with core AI guidelines (AI_DEV_GUIDELINES.md, AI_QUICK_START.md).

Respect folder architecture:

/lib/
/providers/
/models/
/screens/
/widgets/
/l10n/
/docs/ai/

Any modification must comply with design and provider patterns.

🧠 Memory Routine (“תבונות”)

Log every failed command or recovery insight.

Avoid repeating identical fixes — use internal record to adapt.

Keep self-awareness of last actions: summarize what was changed and why.

🪞 Failure Protocol

When a tool fails (Filesystem, Bash, GitHub, Memory):

Re-read the last known file or command output.

Identify cause pattern (edit, path, entity).

Retry only once after validation.

If still failing → record to MEMOZAP_LESSONS_AND_ERRORS.md.

🔗 Cross-References

Developer logic → MEMOZAP_DEVELOPER_GUIDE.md

UI standards → MEMOZAP_DESIGN_GUIDE.md

Tools setup → MEMOZAP_MCP_GUIDE.md

Task system → MEMOZAP_TASKS_AND_SHARING.md

Error records → MEMOZAP_LESSONS_AND_ERRORS.md
