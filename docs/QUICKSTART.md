# QUICKSTART - Machine-Readable AI Guide

## PROJECT INFO
```
name: MemoZap
path: C:\projects\salsheli
platform: Flutter (iOS/Android)
language: Hebrew (RTL primary)
state: Provider pattern
storage: Firebase + Hive
os: Windows 11 Home
editor: VS Code
terminal: PowerShell
emulator: Android (always active)
```

## TOKEN BUDGET
```
total: 190000
read_this: ~2000
available: ~188000 (99%)
```

## READING RULES - DEFAULT: ZERO!

```yaml
Task Type → Read What (If Needed)

ZERO READING (default):
  - bug_fix
  - typo
  - simple_change
  - anything_you_know

SELECTIVE READING:
  - new_provider → CODE.md (Provider Pattern section)
  - new_ui → DESIGN.md (Component section)
  - firebase_query → TECH.md (Security section)
  - repeated_error → LESSONS_LEARNED.md (search specific)
  - big_feature → GUIDE.md + relevant sections

FULL READING (rare):
  - architectural_change → all docs
  - user_explicitly_asks → as requested
```

## DOCS STRUCTURE
```
GUIDE.md (400 lines) - Project + Files + Memory + MCP tools
CODE.md (500 lines) - Architecture + Patterns + Testing
DESIGN.md (300 lines) - UI/UX + Sticky Notes + RTL
TECH.md (400 lines) - Firebase + Security + Models
LESSONS_LEARNED.md - Common mistakes + solutions
CHANGELOG.md - Project history + [In Progress]
TOKEN_MANAGEMENT.md - Full token strategy
```

## MCP TOOLS

### Filesystem (primary use)
```
read_text_file(path, head?, tail?)
edit_file(path, edits[{oldText, newText}])
write_file(path, content) - NEW FILES ONLY!
search_files(path, pattern, excludePatterns?)
list_directory(path)
```

### Memory (checkpoint use)
```
read_graph() - load all
search_nodes(query) - find entities
create_entities([{name, entityType, observations}]) - if not exists
add_observations([{entityName, contents}]) - if exists
delete_entities([names]) - cleanup

CRITICAL: search_nodes BEFORE add_observations!
```

### Bash (PowerShell)
```
flutter run
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
dart format lib/
git status
```

## FILE EDITING PROTOCOL

```
ALWAYS:
1. read_text_file(path)
2. find exact oldText
3. edit_file(path, edits)

PATHS:
- absolute Windows: C:\projects\salsheli\...
- never relative: ../lib, ./src

NEVER:
- edit without reading first
- use write_file on existing files
```

## CHECKPOINT PROTOCOL

```
FREQUENCY: after EVERY file change (not 3-5!)

AFTER EACH EDIT:
1. add_observations to Memory (session entity)
2. update CHANGELOG.md [In Progress]
3. if session ends - checkpoint exists!

FORMAT:
## [In Progress] - YYYY-MM-DD
Modified: file.dart - what changed
Status: complete/in-progress/blocked
Next: next step
```

## RESPONSE PROTOCOL

```
DEFAULT: Ultra-Concise

BEFORE:
"I read GUIDE.md and CODE.md. I see we need to change 
tasks_provider.dart because there's a memory leak.

The problem is removeListener() is missing in dispose().
This is important because...

Here's the full code:
[10 lines of code]

This will fix it!"

NOW:
"Fixed memory leak in tasks_provider.dart
✅ Added removeListener() in dispose()
Done"

SAVINGS: 150 tokens → 15 tokens = 90% less!
```

## TOKEN ALERTS

```
50% (95K):   show "📊 50%"
70% (133K):  ultra-concise ON (1-2 sentences max)
85% (161K):  save checkpoint + end immediately
90%+:        emergency end
```

## BATCHING

```
RULE: 1-2 files per session

EXAMPLE - "Implement Reminders":
Session 1: model.dart + test
Session 2: provider.dart + test
Session 3: screen.dart + strings
Session 4: integration + fixes

USER SAYS "המשך" → continue to next batch
```

## CRITICAL PATTERNS

### household_id Security
```dart
// ALWAYS filter by household_id in Firestore queries!
.where('household_id', isEqualTo: householdId)

// Missing this = SECURITY BREACH!
```

### Provider Disposal
```dart
@override
void dispose() {
  _userContext.removeListener(_onUserChanged); // MUST!
  _controller.dispose();
  _timer?.cancel();
  _subscription?.cancel();
  super.dispose(); // LAST!
}
```

### Context After Await
```dart
// WRONG: context may be invalid
await _save();
Navigator.of(context).push(...); // CRASH!

// CORRECT: capture before await
final nav = Navigator.of(context);
await _save();
if (!mounted) return;
nav.push(...); // SAFE!
```

### Package Imports
```dart
// WRONG: relative
import '../models/task.dart';

// CORRECT: package
import 'package:memozap/models/task.dart';
```

## CONTINUATION PROTOCOL

```
USER SAYS "המשך" or "continue":

1. search_nodes("last session")
2. read CHANGELOG.md [In Progress]
3. continue from exact point

DO NOT:
- ask questions
- re-read everything
- start over
```

## MEMORY USAGE

```yaml
Store:
  - architectural_decisions
  - feature_status
  - work_checkpoints
  - known_issues
  - next_steps

Don't Store:
  - raw_code
  - full_file_contents
  - rapidly_changing_data
```

## ERROR PROTOCOL

```
Tool fails:
1. PAUSE - don't retry blindly
2. READ - re-read last state
3. ANALYZE - find root cause
4. FIX - correct issue
5. RETRY - only once after validation
6. LOG - if still fails → LESSONS_LEARNED.md
```

## COMMON MISTAKES (from LESSONS_LEARNED.md)

```
1. edit_file "no match" → read again, copy exactly
2. memory "entity not found" → search_nodes first
3. missing const → add on static widgets
4. missing household_id → SECURITY BREACH!
5. missing removeListener → MEMORY LEAK!
6. context after await → CRASH!
7. relative imports → use package imports
8. >15 debugPrint → reduce to 15 max
```

## QUICK REFERENCE

```
Need code patterns? → CODE.md (Provider/Repository/Testing sections)
Need UI/UX? → DESIGN.md (Components/RTL sections)
Need Firebase? → TECH.md (Security/Models sections)
Repeated error? → LESSONS_LEARNED.md (search specific)
Full context? → GUIDE.md (but rarely needed)
```

## WORKFLOW

```
Start session:
1. read QUICKSTART.md only
2. search_nodes("last session")
3. check CHANGELOG [In Progress]
4. start work immediately

During session:
- ultra-concise responses
- checkpoint every change
- alert at 50%, 70%, 85%

End session:
- update Memory
- update CHANGELOG
- suggest "המשך" if incomplete
```

---

END OF QUICKSTART

This file is optimized for AI reading - minimal formatting, maximum data density.
Read this ONCE per session. Read other docs ONLY when needed (see READING RULES).

Last updated: 2025-10-26
Version: 1.0
