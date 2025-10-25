# GUIDE.md - MemoZap AI Operation Guide

> **For AI agents only** | Updated: 25/10/2025 | Version: 2.0

---

## 📍 Project Info

**Project:** MemoZap - Smart Shopping & Task Lists  
**Root Path:** `C:\projects\salsheli`  
**Platform:** Flutter (iOS/Android)  
**Language:** Hebrew (RTL primary)  
**State:** Provider pattern  
**Storage:** Firebase + Hive  

**OS:** Windows 11 Home  
**Editor:** VS Code  
**Terminal:** PowerShell (inside VS Code)  
**Testing:** Android Emulator (always active)

---

## 📂 File Operations Protocol

### Critical Rules

```yaml
✅ Always:
  - Read before edit: read_text_file → edit_file
  - Absolute Windows paths: C:\projects\salsheli\...
  - Preserve formatting: emojis, RTL, whitespace
  - Match old_str EXACTLY (including spaces)

❌ Never:
  - Relative paths (../lib, ./src)
  - write_file on existing files (edit_file only!)
  - Edit without reading first
  - Use grep/find in bash (use search_files)
```

### Tool Examples

```python
# Read file (always first!)
read_text_file(path="C:\\projects\\salsheli\\lib\\models\\task.dart")

# Read with limit
read_text_file(path="C:\\projects\\salsheli\\lib\\main.dart", head=50)

# Edit file (surgical changes)
edit_file(
    path="C:\\projects\\salsheli\\lib\\models\\task.dart",
    edits=[{
        "oldText": "  final String title;",
        "newText": "  final String title;\n  final DateTime? reminder;"
    }]
)

# Create new file only
write_file(
    path="C:\\projects\\salsheli\\lib\\utils\\helper.dart",
    content="class Helper { }"
)

# Search files
search_files(
    path="C:\\projects\\salsheli\\lib",
    pattern="task",
    excludePatterns=["test", "*.g.dart"]
)

# List directory
list_directory(path="C:\\projects\\salsheli\\lib\\screens")
```

### Edit Pattern (CRITICAL)

```
1. read_text_file(path) → Read current content
2. Find exact block to change
3. Copy text EXACTLY (spaces, emojis, newlines)
4. edit_file with exact match
5. If fails → return to step 1
```

---

## 🧠 Memory Protocol (CRITICAL!)

### The Pattern

```
Always follow this sequence:

1. search_nodes("query") OR read_graph()
   ↓
2. IF entity exists:
   → add_observations(entity_name, [new_observations])
   
   IF entity doesn't exist:
   → create_entities([{name, entityType, observations}])

3. ⛔ NEVER call add_observations on non-existent entity
   → This causes tool failure!
```

### Tool Examples

```python
# Read all memory
read_graph()

# Search before modifying
search_nodes(query="last checkpoint")
search_nodes(query="MemoZap project")

# Create new entity (only if doesn't exist!)
create_entities(entities=[{
    "name": "Checkpoint_2025-10-25",
    "entityType": "WorkSession",
    "observations": [
        "Modified: task.dart, tasks_provider.dart",
        "Added: reminder field to Task model",
        "Next: UI for reminder selection",
        "Status: 60% complete"
    ]
}])

# Add to existing entity
add_observations(observations=[{
    "entityName": "MemoZap",
    "contents": [
        "Decision: Using flutter_local_notifications",
        "Refactoring: TasksProvider → Riverpod 2.0"
    ]
}])

# Delete old checkpoints
delete_entities(entityNames=["Checkpoint_2025-10-20"])
```

### What to Store

```yaml
✅ Store:
  - Architectural decisions
  - Feature status
  - Work checkpoints
  - Known issues
  - Next steps

❌ Don't store:
  - Raw code (never!)
  - Full file contents
  - Rapidly changing data
```

### Common Failure

```
❌ Error: "Tool execution failed"
🔍 Cause: Called add_observations on non-existent entity
✅ Fix:
   1. search_nodes("entity_name")
   2. If not exists → create_entities
   3. If exists → add_observations
```

---

## 💾 Checkpoint Protocol

### When to Save

- ✅ Every 3-5 file modifications
- ✅ Before context limit (~160K tokens)
- ✅ After completing feature stage
- ✅ User says: "שמור checkpoint"

### Checkpoint Format

```markdown
✅ Checkpoint #N saved (25/10/2025 14:30)

Changes:
- ✏️ lib/models/task.dart - Added reminder field
- ✏️ lib/providers/tasks_provider.dart - Save logic
- 🌐 lib/l10n/app_he.arb - Hebrew strings

Status: 60% 🟡

Next:
- [ ] UI for reminder selection
- [ ] Integration with notifications
- [ ] Test on emulator
```

### Resume Protocol

When user says **"תמשיך"** or **"continue"**:

```
1. read_graph() → Load all memory
2. search_nodes("Checkpoint") → Find last checkpoint
3. Read CHANGELOG.md → [In Progress] section
4. recent_chats(n=1) → Load last messages
5. Continue from exact stopping point
```

---

## 🔧 MCP Tools Quick Reference

### Filesystem
```
read_text_file(path)     # Always read first
edit_file(path, edits)   # Surgical changes
write_file(path, content) # New files only
search_files(path, pattern)
list_directory(path)
```

### Memory
```
read_graph()              # Load all memory
search_nodes(query)       # Find entities
create_entities([...])    # Create new
add_observations([...])   # Update existing
delete_entities([names])  # Cleanup old
```

### Bash (PowerShell)
```bash
flutter run              # Run app
flutter pub get          # Get dependencies
dart format lib/         # Format code
git status              # Check git status
```

### GitHub
```python
get_file_contents(owner, repo, path, branch)
create_or_update_file(owner, repo, branch, path, message, content, sha)
push_files(owner, repo, branch, message, files)
```

---

## ⚠️ Error Handling Protocol

### Tool Failure Pattern

```
When ANY tool fails:

1. ⏸️ PAUSE - Don't retry blindly
2. 📖 READ - Re-read last known state
3. 🔍 ANALYZE - Find root cause:
   - Filesystem: Wrong path? File deleted?
   - Memory: Entity doesn't exist?
   - Bash: Command syntax? Permission?
   - GitHub: Auth? Rate limit?
4. 🔧 FIX - Correct the issue
5. 🔁 RETRY - Only ONCE after validation
6. 📝 LOG - If still fails → LESSONS_LEARNED.md
```

### Common Failures

| Tool | Error | Cause | Fix |
|------|-------|-------|-----|
| edit_file | "no match" | Emoji/space mismatch | Read again, copy exactly |
| memory | "failed" | Entity doesn't exist | search_nodes first |
| filesystem | "ENOENT" | Wrong path | Use absolute path |
| bash | timeout | Long process | Split into shorter commands |

---

## 📊 Token Management

**Total Budget:** 190,000 tokens

### Alerts

```yaml
70% (133K):
  Message: "⚠️ Token Alert: 70% - 30% remaining"
  Action: Start planning completion

85% (161.5K):
  Message: "🚨 Token Critical: 85% - finish now"
  Action:
    - Ultra-concise mode
    - Save everything to Memory
    - Summarize and finish

90%+:
  Message: "❌ Token Emergency"
  Action: End immediately with full checkpoint
```

### Emergency Protocol

```
1. create_entities → Checkpoint_Emergency
2. Update CHANGELOG.md → [In Progress]
3. Write detailed "Next Steps"
4. Summarize in final message
```

---

## 📝 Response Format

### Standard Output

```markdown
[Brief summary of action]

✅ Changes:
- File: path/to/file.dart
  - Added: feature X
  - Modified: function Y

⏳ Next: [Clear next step if applicable]

💾 [Checkpoint saved if needed]
```

### Principles

- ✅ Summarize, don't explain extensively
- ✅ Show diffs only when requested
- ✅ Use emojis for visual parsing
- ✅ Keep focused and actionable
- ✅ Minimal text

---

## 🎨 UI/UX Standards

### Hebrew (RTL) Support

```dart
// ✅ Always for Hebrew text
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('טקסט בעברית'),
)

// ✅ Auto-detect with l10n
Text(AppLocalizations.of(context)!.taskTitle)
```

### Material Design 3

- Use `ColorScheme` from theme
- Prefer `FilledButton.icon` over deprecated buttons
- Use `SegmentedButton` for toggles
- Follow 8dp grid: EdgeInsets(8, 16, 24, 32)

---

## 📚 Project Structure

```
C:\projects\salsheli\
├── lib\
│   ├── models\          # Data classes
│   ├── providers\       # State management
│   ├── screens\         # Full-page UI
│   ├── widgets\         # Reusable components
│   ├── services\        # External integrations
│   ├── l10n\           # Translations (he, en)
│   └── utils\          # Helpers
├── docs\
│   ├── GUIDE.md         # This file (entry point)
│   ├── CODE.md          # Development patterns
│   ├── DESIGN.md        # UI/UX guidelines
│   ├── TECH.md          # Technical reference
│   ├── LESSONS_LEARNED.md  # Error prevention
│   └── CHANGELOG.md     # Version history
└── test\               # Unit & widget tests
```

---

## 🔗 Documentation Map

| Topic | File |
|-------|------|
| **Entry point** | GUIDE.md (this file) |
| **Code patterns** | CODE.md |
| **UI/UX rules** | DESIGN.md |
| **Firebase/models** | TECH.md |
| **Past mistakes** | LESSONS_LEARNED.md |
| **Version history** | CHANGELOG.md |

---

## ✅ Best Practices Summary

### DO

- Read files before editing
- Use absolute Windows paths
- Test RTL layout for Hebrew
- Update CHANGELOG.md immediately
- Save checkpoints every 3-5 changes
- Search memory before creating entities
- Validate commands before execution
- Preserve emoji and formatting

### DON'T

- Use relative paths
- Edit without reading first
- Assume entity exists in memory
- Ignore LESSONS_LEARNED.md
- Mix LTR/RTL without Directionality
- Hardcode strings (use l10n)
- Skip CHANGELOG updates
- Retry failed tools blindly

---

**End of Guide** 🎯

*Remember: This guide is your primary reference. Read it at the start of every session.*
