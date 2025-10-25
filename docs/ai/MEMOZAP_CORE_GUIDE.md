# 🎯 MemoZap Core Guide
*For AI Agent Internal Use - Last Updated: October 2025*

---

## 📋 Quick Reference

**Project:** MemoZap - Smart Voice Notes App  
**Root Path:** `C:\projects\salsheli`  
**Platform:** Flutter (iOS/Android)  
**Primary Language:** Hebrew (RTL)  
**State Management:** Provider  
**Local DB:** Hive  

---

## 🧭 Environment Setup

### System Configuration
- **OS:** Windows 11 Home
- **Editor:** VS Code
- **Terminal:** PowerShell (inside VS Code)
- **Execution:** User runs commands manually after AI validation
- **Emulator:** Always active during mobile UI development
- **Testing:** iOS Simulator + Android Emulator

### Critical Paths
```
C:\projects\salsheli\
├── lib\                    # Main Flutter code
│   ├── models\            # Data models (Task, Note, etc.)
│   ├── providers\         # State management
│   ├── screens\           # App screens
│   ├── widgets\           # Reusable components
│   └── l10n\             # Localization
├── docs\
│   └── ai\               # AI documentation (this file)
└── test\                 # Unit & widget tests
```

---

## ⚙️ Agent Role & Responsibilities

### Primary Duties
1. **Code Consistency:** Maintain Flutter/Dart best practices
2. **UI/UX Alignment:** Follow Material Design 3 + RTL support
3. **Documentation:** Keep all AI docs synchronized
4. **Memory Management:** Track architectural decisions
5. **Error Prevention:** Learn from LESSONS_LEARNED.md

### Core Principles
- ✅ Always READ before WRITE
- ✅ Validate paths before file operations
- ✅ Preserve formatting (emojis, spacing, RTL)
- ✅ Update CHANGELOG.md for all modifications
- ✅ Use Hebrew strings for UI text
- ✅ Test with both LTR and RTL layouts

---

## 📂 File Interaction Protocol

### Absolute Path Rule
```dart
// ✅ CORRECT
C:\projects\salsheli\lib\models\task.dart

// ❌ WRONG
lib/models/task.dart
./models/task.dart
```

### Safe Edit Pattern
```
1. read_text_file(path)      # Always read first
2. Analyze current content    # Understand structure
3. str_replace or edit_file   # Make changes
4. Verify changes             # Confirm success
5. Update CHANGELOG.md        # Track modification
```

### Text Replacement Rules
- Preserve all whitespace (tabs, newlines)
- Keep emoji characters intact: 📝 ✅ 🎯 etc.
- Match old_str EXACTLY (including indentation)
- For RTL text: maintain Unicode direction markers

---

## 🧠 Memory Management (CRITICAL)

### Memory Tool Pattern
```
ALWAYS follow this sequence:

1. search_nodes("query") OR read_graph()
   ↓
2. IF entity exists:
   → add_observations(entity_name, [new_observations])
   
   IF entity doesn't exist:
   → create_entities([{name, entityType, observations}])

3. NEVER call add_observations on non-existent entity
   → This will cause tool failure!
```

### What to Store
```yaml
Entities to Track:
  - Project: "MemoZap"
    Type: "Project"
    Observations:
      - Architecture decisions
      - Major refactorings
      - Breaking changes
  
  - Feature: "Voice Notes", "Tasks", "Reminders"
    Type: "Feature"
    Observations:
      - Implementation status
      - Known issues
      - Dependencies
  
  - Session: "Checkpoint_<date>"
    Type: "WorkSession"
    Observations:
      - Files modified
      - Next steps
      - Pending tasks
```

### Session Continuity
Store after every 3-5 file changes:
```
✅ Checkpoint #N saved:
- Modified: lib/models/task.dart
- Modified: lib/providers/tasks_provider.dart
- Updated: CHANGELOG.md
⏳ Next: Add reminder notification logic
```

---

## 🔄 Workflow & Architecture

### Folder Structure Compliance
```
/lib/
  /models/          # Data classes (immutable)
  /providers/       # ChangeNotifier classes
  /screens/         # Full-page widgets
  /widgets/         # Reusable components
  /services/        # External integrations (MCP tools)
  /l10n/           # Hebrew + English strings
  /utils/          # Helper functions

/docs/ai/          # AI documentation ONLY
  ├── README.md                     # Master entry point (in docs/)
  ├── MEMOZAP_CORE_GUIDE.md         # This file
  ├── MEMOZAP_DEVELOPER_GUIDE.md    # Code patterns
  ├── MEMOZAP_DESIGN_GUIDE.md       # UI/UX rules
  ├── MEMOZAP_MCP_GUIDE.md          # MCP integration
  ├── MEMOZAP_UI_REQUIREMENTS.md    # UI specifications
  ├── MEMOZAP_TASKS_AND_SHARING.md  # Task system
  ├── MEMOZAP_SECURITY_AND_RULES.md # Security patterns
  ├── LESSONS_LEARNED.md            # Error prevention (in docs/)
  └── CHANGELOG.md                  # Version history (in docs/)
```

### Provider Pattern
```dart
// ✅ Standard Pattern
class TasksProvider extends ChangeNotifier {
  final HiveInterface _hive;
  List<Task> _tasks = [];
  
  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  
  // Methods
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveToHive();
    notifyListeners(); // ALWAYS notify after state change
  }
}
```

---

## 📊 Checkpoint Protocol

### Auto-Save Triggers
- After 3-5 file modifications
- Before context window limit (≈160K tokens)
- After completing major feature
- When user says: "שמור checkpoint"

### Checkpoint Format
```markdown
## [In Progress] - 2025-10-25

### Session #N - Feature: Voice Note Playback
**Files Modified:**
1. `lib/widgets/voice_note_player.dart` - Added playback controls
2. `lib/providers/audio_provider.dart` - Implemented pause/resume
3. `lib/l10n/app_he.arb` - Added Hebrew strings

**Status:** 60% complete

**Next Steps:**
- [ ] Add progress indicator
- [ ] Implement seek functionality
- [ ] Test on iOS device

**Blocked By:** Waiting for MCP audio tool integration
```

### Resume Protocol
When user says **"תמשיך"**:
1. Read `CHANGELOG.md` "[In Progress]" section
2. Call `search_nodes("last checkpoint")`
3. Load exact stopping point
4. Continue without repeating completed work

---

## 🪞 Error Handling & Recovery

### Tool Failure Protocol
```
When ANY tool fails:

1. PAUSE - Don't retry blindly
2. READ - Re-read last known state
3. ANALYZE - Identify root cause:
   - Filesystem: Wrong path? File deleted?
   - Memory: Entity doesn't exist?
   - Bash: Command syntax? Permission?
   - GitHub: Auth? Rate limit?
4. FIX - Correct the issue
5. RETRY - Only ONCE after validation
6. LOG - If still fails → LESSONS_LEARNED.md
```

### Common Failure Patterns
```yaml
# Pattern 1: Memory Tool
Error: "Entity not found"
Fix: Call search_nodes first, then add_observations

# Pattern 2: File Edit
Error: "old_str not found"
Fix: Re-read file, match exact whitespace/formatting

# Pattern 3: Path Resolution
Error: "File not found"
Fix: Use absolute Windows path (C:\...)

# Pattern 4: RTL Rendering
Error: Text appears reversed
Fix: Wrap in Directionality(textDirection: TextDirection.rtl)
```

---

## 🎨 UI/UX Standards

### Hebrew (RTL) Support
```dart
// ✅ ALWAYS for Hebrew text
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('טקסט בעברית'),
)

// ✅ Auto-detect in AppLocalizations
Text(AppLocalizations.of(context)!.taskTitle)
```

### Material Design 3
- Use `ColorScheme` from theme
- Prefer `FilledButton.icon` over `RaisedButton`
- Use `SegmentedButton` for toggles
- Follow 8dp grid system

### Consistency Checklist
- [ ] All Hebrew strings in `l10n/app_he.arb`
- [ ] English fallback in `l10n/app_en.arb`
- [ ] Icons use Material Icons or custom assets
- [ ] Colors from `theme.colorScheme`
- [ ] Spacing uses `EdgeInsets` (8, 16, 24, 32)

---

## 📝 Documentation Update Rules

### After Code Changes
```
1. Update CHANGELOG.md:
   - Add to [Unreleased] section
   - Use format: "Feature/Fix/Chore: Description"

2. Update relevant AI doc:
   - DEVELOPER_GUIDE for code patterns
   - DESIGN_GUIDE for UI changes
   - MCP_GUIDE for tool integration

3. Update memory:
   - Log architectural decision
   - Add to feature observation
```

### Documentation Hierarchy
```
READ FIRST (every session):
├── README.md                   # Master entry point
└── MEMOZAP_CORE_GUIDE.md      # This file

READ ON-DEMAND:
├── Task-specific guides        # See README.md
└── LESSONS_LEARNED.md          # Before making risky changes

UPDATE ALWAYS:
└── CHANGELOG.md                # After ANY modification
```

---

## 🔗 Cross-Reference Quick Links

| Need Help With... | Read This File |
|-------------------|---------------|
| Code patterns & architecture | `MEMOZAP_DEVELOPER_GUIDE.md` |
| UI design & components | `MEMOZAP_DESIGN_GUIDE.md` |
| MCP tool integration | `MEMOZAP_MCP_GUIDE.md` |
| Task & sharing system | `MEMOZAP_TASKS_AND_SHARING.md` |
| UI specifications | `MEMOZAP_UI_REQUIREMENTS.md` |
| Past mistakes | `LESSONS_LEARNED.md` |
| Version history | `CHANGELOG.md` |

---

## 💡 Best Practices Summary

### DO ✅
- Read files before editing
- Use absolute Windows paths
- Test RTL layout for Hebrew
- Update CHANGELOG.md immediately
- Store checkpoints every 3-5 changes
- Search memory before creating entities
- Validate commands before execution
- Preserve emoji and formatting

### DON'T ❌
- Use relative paths
- Edit without reading first
- Assume entity exists in memory
- Ignore LESSONS_LEARNED.md
- Mix LTR/RTL without Directionality
- Hardcode strings (use l10n)
- Skip CHANGELOG updates
- Retry failed tools blindly

---

## 🚦 Response Protocol

### Output Format
```
[Brief summary of action]

✅ Changes Applied:
- File: path/to/file.dart
  - Added: feature X
  - Modified: function Y

⏳ Next: [Clear next step if applicable]

[Memory checkpoint saved if needed]
```

### Minimal Text Rule
- Summarize, don't explain extensively
- Show diffs only when requested
- Use emojis for quick visual parsing
- Keep responses focused and actionable

---

**End of Core Guide** 🎯

*Remember: This guide evolves. Update it when you discover new patterns or better practices.*
