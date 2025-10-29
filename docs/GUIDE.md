# GUIDE.md - MemoZap AI Operation Guide

> Machine-Readable | Updated: 26/10/2025 | Version: 3.0

---

## PROJECT

```yaml
name: MemoZap
path: C:\projects\salsheli
platform: Flutter (iOS/Android)
language: Hebrew (RTL primary)
state: Provider
storage: Firebase + Hive
os: Windows 11
editor: VS Code
terminal: PowerShell
emulator: Android (always active)
```

---

## FILES

```yaml
CRITICAL_RULES:
  - read before edit: read_text_file → edit_file
  - absolute paths: C:\projects\salsheli\...
  - never relative: ../ or ./
  - never write_file on existing files

TOOLS:
  read_text_file(path, head?, tail?)
  edit_file(path, edits[{oldText, newText}])
  write_file(path, content) # NEW FILES ONLY
  search_files(path, pattern, excludePatterns?)
  list_directory(path)

EDIT_PATTERN:
  1. read_text_file(path)
  2. find exact oldText (spaces, emojis, newlines)
  3. edit_file(path, edits)
  4. if fails → return to step 1
```

---

## MEMORY

```yaml
PATTERN (CRITICAL!):
  1. search_nodes(query) OR read_graph()
  2. IF exists → add_observations
     IF not exists → create_entities
  3. NEVER add_observations on non-existent entity!

TOOLS:
  read_graph() # load all
  search_nodes(query) # find entities
  create_entities([{name, entityType, observations}])
  add_observations([{entityName, contents}])
  delete_entities([names])

STORE:
  - architectural decisions
  - feature status
  - checkpoints
  - known issues
  - next steps

DONT_STORE:
  - raw code
  - file contents
  - temp data
```

---

## SECURITY (CRITICAL!)

```yaml
household_id_MANDATORY:
  # EVERY Firestore query MUST filter by household_id
  
  WRONG:
    .where('user_id', isEqualTo: userId)
    # Result: SECURITY BREACH - sees ALL households!
  
  CORRECT:
    .where('household_id', isEqualTo: householdId)
    .where('user_id', isEqualTo: userId)
    # Result: sees ONLY their household

IMPACT_IF_MISSING:
  - GDPR violation
  - Privacy breach
  - Data leakage
  - App store removal

CHECKLIST:
  - [ ] Every .collection() has .where('household_id', ...)
  - [ ] No query without household_id
  - [ ] Firebase Rules enforce household_id
  - [ ] Tested: user can't see other households

DETAILS: → TECH.md Security Rules
```

---

## PERFORMANCE

```yaml
LAZY_LOADING:
  # Don't load Providers in constructor
  
  WRONG:
    ProductsProvider(repo) {
      _loadProducts(); # Slows startup!
    }
  
  CORRECT:
    Future<void> ensureInitialized() async {
      if (_isInitialized) return;
      _isInitialized = true;
      await _loadProducts(); # Load when needed
    }
  
  USAGE:
    Provider.of<ProductsProvider>(context, listen: false)
        .ensureInitialized();
  
  BENEFITS:
    - 50%+ faster startup
    - 30-40% less memory
    - Load only what needed

CONST_OPTIMIZATION:
  # Missing const = 5-10% unnecessary rebuilds
  
  WITH_LITERALS:
    const SizedBox(height: 16)
    const EdgeInsets.all(8)
    const Text('Static text')
    const Icon(Icons.add)
  
  WITH_VARIABLES:
    SizedBox(height: spacing) # spacing is variable!
    _Card(data: item) # item is variable!

DETAILS: → CODE.md Performance Patterns
```

---

## CHECKPOINTS

```yaml
FREQUENCY: after EVERY file change

AFTER_EACH_EDIT:
  1. add_observations(session entity)
  2. update CHANGELOG.md [In Progress]
  3. if session ends → checkpoint exists!

FORMAT:
  ## [In Progress] - YYYY-MM-DD
  Modified: file.dart - what changed
  Status: complete/in-progress/blocked
  Next: next step

RESUME_PROTOCOL:
  USER_SAYS "המשך":
    1. search_nodes("last session")
    2. read CHANGELOG.md [In Progress]
    3. continue from exact point
```

---

## MCP_TOOLS

```yaml
FILESYSTEM (80% usage):
  read_text_file
  edit_file
  write_file
  search_files
  list_directory

MEMORY:
  read_graph
  search_nodes
  create_entities
  add_observations
  delete_entities

BASH (PowerShell):
  flutter run
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  dart format lib/
  git status

GITHUB:
  get_file_contents
  create_or_update_file
  push_files
```

---

## ANTI_PATTERNS

```yaml
NEVER_DO:
  artifacts_for_code:
    why: User explicitly prefers edit_file
    use: Filesystem:edit_file always
  
  sequential_thinking_simple:
    why: Waste tokens on 1-2 step fixes
    use: Only for complex 5+ step problems
  
  web_search_docs:
    why: Info already in docs/
    use: Read GUIDE/CODE/DESIGN first
  
  memory_temp_data:
    why: Memory = long-term only
    use: Current Work Context only
  
  auto_commit:
    why: User wants to review first
    use: Show changes, wait for approval
  
  read_unnecessary_files:
    why: Waste tokens
    use: Check docs/ first, then decide
```

---

## ERROR_HANDLING

```yaml
TOOL_FAILS:
  1. PAUSE - don't retry blindly
  2. READ - re-read last state
  3. ANALYZE - find root cause
  4. FIX - correct issue
  5. RETRY - only once after validation
  6. LOG - if still fails → LESSONS_LEARNED.md

COMMON_FAILURES:
  edit_file "no match":
    cause: emoji/space mismatch
    fix: read again, copy exactly
  
  memory "failed":
    cause: entity doesn't exist
    fix: search_nodes first
  
  filesystem "ENOENT":
    cause: wrong path
    fix: use absolute path
  
  bash timeout:
    cause: long process
    fix: split into shorter commands
```

---

## RESPONSE_FORMAT

```yaml
ULTRA_CONCISE:
  # Default mode - save tokens
  
  EXAMPLE:
    "Fixed memory leak in tasks_provider.dart
    ✅ Added removeListener() in dispose()
    Done"
  
  NOT:
    "I analyzed the code and found that...
    The problem is...
    Here's the full code...
    This will fix it!"
  
  PRINCIPLES:
    - Summarize, don't explain
    - Show diffs only if requested
    - Use emojis for visual parsing
    - Keep focused and actionable
    - Minimal text
  
  SAVINGS: 150 tokens → 15 tokens = 90% less!
```

---

## CRITICAL_PATTERNS

```yaml
1_PROVIDER_DISPOSAL:
  @override
  void dispose() {
    _userContext.removeListener(_onUserChanged); # MUST!
    _controller.dispose();
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose(); # LAST!
  }

2_CONTEXT_AFTER_AWAIT:
  WRONG:
    await _save();
    Navigator.of(context).push(...); # CRASH!
  
  CORRECT:
    final nav = Navigator.of(context);
    await _save();
    if (!mounted) return;
    nav.push(...); # SAFE!

3_PACKAGE_IMPORTS:
  WRONG:
    import '../models/task.dart';
  
  CORRECT:
    import 'package:memozap/models/task.dart';

4_HOUSEHOLD_ID:
  # See SECURITY section above

5_CONST:
  # See PERFORMANCE section above

DETAILS: → CODE.md Critical Patterns
```

---

## STRUCTURE

```yaml
lib/:
  models/         # Data classes
  providers/      # State management
  repositories/   # Data layer
  screens/        # Full-page UI
  widgets/        # Reusable components
  services/       # External integrations
  l10n/          # Translations (he, en)
  utils/         # Helpers

docs/:
  GUIDE.md                # This file (entry point)
  CODE.md                 # Development patterns
  DESIGN.md               # UI/UX guidelines
  TECH.md                 # Technical reference
  LESSONS_LEARNED.md      # Error prevention
  CHANGELOG.md            # Version history
  CODE_REVIEW_CHECKLIST.md # Code review protocol
  WORK_PLAN.md            # Future work plan

test/                     # Unit & widget tests
```

---

## DOCUMENTATION_MAP

```yaml
Entry_Point: GUIDE.md (this file)
Code_Patterns: CODE.md
UI_UX: DESIGN.md
Firebase_Models: TECH.md
Mistakes: LESSONS_LEARNED.md
History: CHANGELOG.md
Code_Review: CODE_REVIEW_CHECKLIST.md
Future_Work: WORK_PLAN.md
```

---

## BEST_PRACTICES

```yaml
DO:
  - read before edit
  - absolute paths
  - test RTL for Hebrew
  - update CHANGELOG immediately
  - checkpoint every change
  - search memory before create
  - validate commands
  - preserve emoji/formatting
  - package imports
  - const on static widgets
  - capture context before await

DONT:
  - relative paths
  - edit without reading
  - assume entity exists
  - ignore LESSONS_LEARNED
  - mix LTR/RTL without Directionality
  - hardcode strings (use l10n)
  - skip CHANGELOG
  - retry blindly
  - forget dispose cleanup
  - use context after await without mounted

CRITICAL_CHECKLIST:
  - [ ] household_id in ALL Firestore queries
  - [ ] removeListener() in ALL dispose()
  - [ ] context captured before await
  - [ ] const on ALL static widgets
  - [ ] package imports (not relative)
```

---

## WORKFLOW

```yaml
START_SESSION:
  1. read QUICKSTART.md OR GUIDE.md
  2. search_nodes("last session")
  3. check CHANGELOG [In Progress]
  4. start work immediately

DURING_SESSION:
  - ultra-concise responses
  - checkpoint every change
  - alert at 50%, 70%, 85%

END_SESSION:
  - update Memory
  - update CHANGELOG
  - suggest "המשך" if incomplete
```

---

**End of GUIDE v3.0**

Optimized for AI parsing - zero redundancy, maximum data density.
Read QUICKSTART.md first, then this file for full context.
Read other docs ONLY when needed (see QUICKSTART → READING RULES).

Last updated: 2025-10-26
