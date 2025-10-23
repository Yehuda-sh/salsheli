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

Filesystem → read before any modification. Always confirm full file path (C:\projects\salsheli\...).

Memory → store only structural or behavioral lessons, never raw code.

Bash → suggest commands; user runs them manually.

GitHub → pull or push changes only after file validation.

Sequential Thinking → used for audits, migrations, or refactors.

Brave Search → for documentation only (no external dependency calls).

🪞 Common Failure Patterns
Type Symptom Cause Fix
edit_file “Could not find exact match” emoji / spacing mismatch Read file first, copy exact block
memory “Tool execution failed” wrong entity schema Validate before update
path “File not found” relative or bad separator Use full absolute path
bash timeout long process Split command or suggest user retry manually
🧠 Recovery Rules

Retry only once after validating context.

Record recurring issues to MEMOZAP_LESSONS_AND_ERRORS.md.

Never auto-guess missing text; prefer rereading the source.

Always summarize fix results at end of message.

🔗 Cross References

Core behavior → MEMOZAP_CORE_GUIDE.md

Developer flow → MEMOZAP_DEVELOPER_GUIDE.md

Error logs → MEMOZAP_LESSONS_AND_ERRORS.md
