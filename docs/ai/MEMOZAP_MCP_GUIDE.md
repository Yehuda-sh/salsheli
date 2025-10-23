For AI agent internal use only – not intended for human reading.

⚙️ Active MCP Servers
Tool Status Purpose Criticality
Filesystem ✅ Active Read/write/edit project files 🔴 Critical
Memory ✅ Active Persistent context between sessions 🟡 Important
Bash ✅ Active Run terminal commands (PowerShell syntax) 🔴 Critical
Sequential Thinking ✅ Active Multi-step reasoning 🟡 Important
GitHub ✅ Active Repo operations, commits, file sync 🟡 Important
Brave Search ✅ Active Web lookup (optional) 🟢 Optional
🧭 Coordination Logic

**Filesystem** → read before any modification. Always confirm full file path (C:\projects\salsheli\...).
- Use `read_text_file` (not deprecated `read_file`)
- Use `edit_file` for surgical changes (not `write_file` unless creating new file)
- Use `search_files` for finding files (not bash grep on Windows)

**Memory** → store only structural or behavioral lessons, never raw code.
- **CRITICAL PATTERN:**
  1. ALWAYS `search_nodes` or `read_graph` first
  2. If entity exists → `add_observations`
  3. If entity doesn't exist → `create_entities`
  4. NEVER `add_observations` on non-existent entity

**Bash** → suggest commands; user runs them manually.

**GitHub** → pull or push changes only after file validation.

**Sequential Thinking** → used for audits, migrations, or refactors.

**Brave Search** → for documentation only (no external dependency calls).

🪞 Common Failure Patterns
Type Symptom Cause Fix
edit_file “Could not find exact match” emoji / spacing mismatch Read file first, copy exact block
memory “Tool execution failed” wrong entity schema Validate before update
path “File not found” relative or bad separator Use full absolute path
bash timeout long process Split command or suggest user retry manually
🧠 Recovery Rules

Retry only once after validating context.

Record recurring issues to **LESSONS_LEARNED.md**.

Never auto-guess missing text; prefer rereading the source.

Always summarize fix results at end of message.

🔗 Cross References

- Core behavior → MEMOZAP_CORE_GUIDE.md
- Developer flow → MEMOZAP_DEVELOPER_GUIDE.md
- Error logs → LESSONS_LEARNED.md
- UI Requirements → MEMOZAP_UI_REQUIREMENTS.md
- Design Guide → MEMOZAP_DESIGN_GUIDE.md
