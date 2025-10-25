For AI agent internal use only – not intended for human reading.

**Updated:** 24/10/2025 | Version: 2.0 – Enhanced with LESSONS_LEARNED insights

⚙️ Active MCP Servers

| Tool | Status | Purpose | Criticality |
|------|--------|---------|-------------|
| Filesystem | ✅ Active | Read/write/edit project files | 🔴 Critical |
| Memory | ✅ Active | Persistent context between sessions | 🟡 Important |
| Bash | ✅ Active | Run terminal commands (PowerShell syntax) | 🔴 Critical |
| Sequential Thinking | ✅ Active | Multi-step reasoning | 🟡 Important |
| GitHub | ✅ Active | Repo operations, commits, file sync | 🟡 Important |
| Brave Search | ✅ Active | Web lookup (optional) | 🟢 Optional |

🧭 Coordination Logic

### 📁 Filesystem Tools

**Core Principle:** Always read before modifying

**Critical Rules:**
- ✅ Always use **full Windows path** (e.g., `C:\projects\salsheli\lib\main.dart`)
- ❌ Never use relative paths
- ✅ Use `read_text_file` (not deprecated `read_file`)
- ✅ Use `edit_file` for surgical changes
- ✅ Use `write_file` ONLY when creating new files
- ✅ Use `search_files` for finding files (not bash grep on Windows)

**File Editing Best Practices:**
1. `read_text_file` → confirm exact text
2. Copy exact block (preserve emojis, spaces, formatting)
3. `edit_file` with exact match
4. If "no match" error → re-read file and verify

**When to Use Each Tool:**
- `read_text_file` → Always before any edit
- `edit_file` → Surgical changes to existing files
- `write_file` → Create new files only
- `search_files` → Find files by pattern (Windows-compatible)
- `list_directory` → View folder contents
- `directory_tree` → View recursive structure

### 🧠 Memory Tool

**Purpose:** Persistent context between sessions (NOT for raw code)

**CRITICAL PATTERN (MANDATORY):**
1. **ALWAYS** start with `search_nodes` or `read_graph`
2. **If entity exists** → use `add_observations`
3. **If entity doesn't exist** → use `create_entities`
4. **NEVER** use `add_observations` on non-existent entity

**What to Store:**
- ✅ Architectural decisions
- ✅ Stage completion status
- ✅ Current work context
- ✅ Behavioral lessons
- ❌ Raw code (never!)

**Common Failure:**
- **Symptom:** "Tool execution failed"
- **Cause:** Trying to add observations to non-existent entity
- **Fix:** Always verify entity existence first

### 💻 Bash Tool

**Environment:** PowerShell inside VS Code on Windows 11

**Critical Rules:**
- User runs ALL commands manually after validation
- Suggest commands, don't auto-execute
- ❌ Don't use `grep` on Windows (use `search_files` instead)
- ✅ Prefer Filesystem tools for simple tasks
- ✅ Use Bash only for automation/complex tasks

**Common Issues:**
- Timeout on long processes → Split command or suggest manual retry
- `ENOENT` errors → Wrong path format (use Windows paths)

### 🔧 GitHub Tool

**Purpose:** Repo operations, commits, file sync

**Rules:**
- Only pull or push AFTER file validation
- Verify changes before committing
- Update CHANGELOG.md with commits

### 🧠 Sequential Thinking Tool

**Use Cases:**
- Multi-step audits
- Complex migrations
- Large refactors
- Planning with uncertainty

### 🔍 Brave Search Tool

**Purpose:** Web lookup for documentation

**Rules:**
- Documentation lookup only
- No external dependency calls
- Optional (not critical for project work)

🪞 Common Failure Patterns

| Type | Symptom | Cause | Fix |
|------|---------|-------|-----|
| **edit_file** | "Could not find exact match" | Emoji/spacing mismatch | Read file first, copy exact block |
| **memory** | "Tool execution failed" | Wrong entity schema / non-existent entity | Always `search_nodes` first |
| **path** | "File not found" | Relative or bad separator | Use full absolute Windows path |
| **bash** | Timeout | Long process | Split command or suggest manual retry |
| **grep** | `ENOENT` | Windows incompatibility | Use `search_files` instead |

🧠 Recovery Rules

1. **Retry Protocol:**
   - Retry only ONCE after validating context
   - Never guess missing text
   - Re-read source file if uncertain

2. **Failure Documentation:**
   - Record ALL recurring issues to **LESSONS_LEARNED.md**
   - Include: symptom, cause, fix
   - Update immediately after resolving

3. **Communication:**
   - Always summarize fix results at end of message
   - Explain what was changed (not how)
   - Keep responses concise in Hebrew

📊 Checkpoint Protocol

**When to Save:**
- After every 3-5 file modifications
- After completing a stage
- Before approaching token limits
- When user says "שמור checkpoint"

**What to Save:**
- Current work context (to Memory)
- List of completed changes
- Exact next task
- Stage completion percentage

**Checkpoint Format:**
```
✅ Checkpoint #N saved:
- [List of completed changes]
⏳ Next: [Exact next task]
```

**Session Continuity:**
- Update Current Work Context every 10 messages
- Store architectural decisions in Memory immediately
- On "המשך" → `recent_chats(n=1)` → read 5-10 last messages → continue

⚠️ Token Management

**Monitoring:**
- At 70% tokens (133K/190K) → Show alert: `⚠️ Token Alert: 70% - נותרו 30% מהשיחה`
- At 85% tokens → Ultra-concise mode + save everything to Memory
- On "נעבור" → Update Current Work Context + provide 4-sentence summary

🔧 Tool-Specific Best Practices

### Filesystem
- ✅ Read large files (>500 lines) before ANY `edit_file` operation
- ✅ Preserve exact formatting (emojis, spaces, RTL)
- ❌ Don't overuse `write_file` (only for new files)
- ✅ Confirm integrity: if unclear → re-read instead of guessing

### Memory
- ✅ Save checkpoint after every 3-5 file modifications
- ✅ Track progress in session with % complete
- ❌ Never store raw code
- ✅ Store only: decisions, lessons, context

### Bash
- ✅ Emulator always active when developing mobile UI
- ✅ User runs commands manually after validation
- ❌ Don't use for simple tasks (prefer Filesystem tools)

### GitHub
- ✅ Validate all changes before commit
- ✅ Update CHANGELOG.md with every commit
- ❌ Never commit without file validation

🔗 Cross References

| Topic | Document |
|-------|----------|
| Master entry point | README.md (in docs/) |
| Core behavior & constants | MEMOZAP_CORE_GUIDE.md |
| Developer flow & patterns | MEMOZAP_DEVELOPER_GUIDE.md |
| Error logs & lessons | LESSONS_LEARNED.md (in docs/) |
| UI/UX requirements | MEMOZAP_UI_REQUIREMENTS.md |
| Design system | MEMOZAP_DESIGN_GUIDE.md |
| Tasks & Sharing logic | MEMOZAP_TASKS_AND_SHARING.md |
| Security & validation | MEMOZAP_SECURITY_AND_RULES.md |

---

**Last Updated:** 24/10/2025  
**Version:** 2.0 – Enhanced with LESSONS_LEARNED insights  
**Maintained by:** AI System (Claude)  
**Location:** `C:\projects\salsheli\docs\ai\MEMOZAP_MCP_GUIDE.md`
