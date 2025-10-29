# LESSONS_LEARNED - MemoZap

> Machine-Readable | Updated: 26/10/2025 | Version: 2.0

## TOOL ERRORS

```yaml
edit_file:
  error: "no match found"
  cause: emoji/space mismatch
  fix: read_text_file → copy exact text → edit
  frequency: high

memory:
  error: "entity not found"
  cause: add_observations on non-existent entity
  fix: search_nodes first → if exists add_observations, if not create_entities
  frequency: medium

path:
  error: "ENOENT" or "Access denied"
  cause: /mnt/project/ with filesystem tools OR relative paths
  fix: use absolute C:\projects\salsheli\ paths
  frequency: medium

bash_windows:
  error: "can't cd to C:projectssalsheli" or "/bin/sh: cd: can't cd"
  cause: using bash_tool with Windows paths (C:\...)
  wrong: bash_tool + cd C:\projects\salsheli
  right: Filesystem:search_files or Filesystem:read_file
  why: bash_tool = Linux shell, doesn't understand C:\
  impact: ALWAYS FAILS on Windows paths
  frequency: VERY HIGH (repeating mistake!)
  fix: NEVER use bash_tool for Windows file operations

grep:
  error: "ENOENT"
  cause: using bash grep on Windows
  fix: use search_files instead
  frequency: low
```

## FLUTTER ERRORS

```yaml
const:
  error: "const with dynamic args"
  details: → CODE.md (const Usage section)
  frequency: medium

color_api:
  error: "deprecated withOpacity"
  wrong: Colors.black.withOpacity(0.5)
  right: Colors.black.withValues(alpha: 0.5)
  since: Flutter 3.22+
  frequency: low

async_callback:
  error: "type mismatch Future<void> vs void"
  wrong: onPressed: _asyncFunc
  right: onPressed: () => _asyncFunc()
  frequency: medium

context_after_await:
  error: "crash - context invalid after await"
  impact: CRASH
  details: → CODE.md (Common Mistakes section)
  frequency: high
```

## TESTING ERRORS

```yaml
widget_finder:
  error: "find.byWidgetPredicate doesn't work"
  wrong: find.byWidgetPredicate(widget.decoration)
  right: find.bySemanticsLabel(AppStrings.auth.emailLabel)
  benefit: adds_accessibility
  frequency: medium

missing_states:
  error: "incomplete test coverage"
  missing: Loading/Error/Empty states
  fix: test all 4 states (Loading, Error, Empty, Content)
  frequency: high

build_runner:
  error: "tests fail - .g.dart missing"
  cause: forgot build_runner before tests
  fix: flutter pub run build_runner build BEFORE flutter test
  frequency: medium

mock_stub:
  error: "getter not defined for Mock"
  cause: missing stub for property
  fix: when(() => mock.property).thenReturn(value)
  frequency: high

package_name:
  error: "import not found"
  wrong: package:salsheli/...
  right: package:memozap/...
  note: folder=salsheli, package=memozap
  frequency: low
```

## ARCHITECTURE ERRORS

```yaml
household_id:
  error: "SECURITY BREACH - sees other households"
  impact: CRITICAL - GDPR violation
  details: → TECH.md (Security Rules section)
  frequency: medium

logging:
  error: "too many logs"
  limit: 15 debugPrint per file
  keep: lifecycle (initState/dispose) + errors + critical actions
  remove: routine operations, navigations, UI buttons
  frequency: low

model_update:
  error: "compilation fails after model change"
  cause: forgot build_runner
  fix: flutter pub run build_runner build --delete-conflicting-outputs
  frequency: medium

repository_pattern:
  error: "direct Firestore in UI"
  wrong: FirebaseFirestore.instance in Screen/Widget
  right: Repository → Provider → Screen
  impact: hard to test, breaks pattern
  frequency: low

removeListener:
  error: "memory leak"
  impact: HIGH - memory leak + battery drain
  details: → CODE.md (Provider Cleanup section)
  frequency: high

old_method:
  error: "method not found"
  cause: using old method name after refactor
  example: addItemToList() → addUnifiedItem()
  fix: read Provider file first
  frequency: low

code_review:
  error: "false dead code detection"
  cause: search_files doesn't find in-file usage (AppStrings.layout.appTitle)
  wrong: "0 imports = dead code"
  right: read file + check actual usage + manual verification
  impact: CRITICAL - can delete active code!
  details: → CODE_REVIEW_CHECKLIST.md (Dead Code Detection)
  frequency: medium
  example: app_strings.dart claimed dead but used in 10+ files
```

## UI/UX ERRORS

```yaml
rtl:
  error: "text displays backwards"
  missing: Directionality(textDirection: RTL)
  fix: wrap all Hebrew text
  frequency: low

design_system:
  error: "inconsistent UI"
  cause: ignored Sticky Notes design system
  fix: always reference DESIGN.md
  frequency: low
```

## COMMUNICATION ERRORS

```yaml
artifacts:
  error: "user doesn't want artifacts"
  wrong: creating artifacts
  right: filesystem:edit_file ALWAYS
  user_preference: EXPLICIT
  frequency: medium

verbose:
  error: "too many tokens"
  cause: long explanations + code blocks
  fix: ultra-concise Hebrew + what changed (not how)
  frequency: high

continue:
  error: "asking questions instead of continuing"
  trigger: user says "המשך"
  right: recent_chats(n=1) → load last messages → continue immediately
  frequency: medium
```

## SESSION ERRORS

```yaml
token_alert:
  70%: show "⚠️ 70% - נותרו 30%"
  85%: ultra-concise + save Memory + end
  90%: emergency checkpoint + end

checkpoint:
  frequency: every 3-5 files (NOT after each file)
  format: update Memory + CHANGELOG [In Progress]
  
memory_usage:
  store: decisions, status, checkpoints, issues, next_steps
  dont_store: code, file_contents, temp_data
```

## RECENT FIXES (Last 5)

```yaml
29_10_2025:
  - bash_windows_error: used bash_tool with Windows paths (C:\...) - FAILS ALWAYS
  - lesson: bash_tool = Linux shell, doesn't understand C:\ drives
  - fix: NEVER bash_tool for file ops, use Filesystem:search_files/read_file
  - frequency: VERY HIGH - this mistake repeats constantly!
  
  - code_review_error: app_strings.dart false "dead code" claim
  - lesson: search_files ≠ full usage check (in-file usage exists!)
  - protocol: read file + verify usage + manual check before claiming dead

26_10_2025:
  - doc_compression: AI_INSTRUCTIONS + TOKEN_MANAGEMENT created
  - token_strategy: zero-reading default, selective when needed
  - checkpoint: every file (not 3-5)

25_10_2025:
  - widget_testing: find.bySemanticsLabel() pattern learned
  - mock_stubs: all properties need explicit stubs
  - 4_states: Loading/Error/Empty/Content mandatory

24_10_2025:
  - const_fix: removed const from dynamic widgets
  - doc_cleanup: merged/deleted duplicate files
  - memory_pattern: search first, then add/create

23_10_2025:
  - track1_complete: UnifiedListItem + tests
  - track2_complete: 4 permission levels + Security Rules
  - build_runner: must run before tests
```

## QUICK REFERENCE

```yaml
most_common_errors:
  1. bash_tool with Windows paths (ALWAYS FAILS!)
  2. household_id missing (SECURITY BREACH!)
  3. removeListener missing (MEMORY LEAK!)
  4. context after await (CRASH!)
  5. false dead code detection (DELETING ACTIVE CODE!)
  6. edit_file without read first (NO MATCH!)

most_critical_patterns:
  1. ALWAYS filter by household_id in Firestore
  2. ALWAYS removeListener in dispose()
  3. ALWAYS capture context before await
  4. ALWAYS read_text_file before edit_file
  5. ALWAYS search_nodes before add_observations

error_frequency:
  very_high: bash_windows (repeating constantly!)
  high: context_after_await, removeListener, edit_no_match, verbose, missing_states
  medium: household_id, const, memory, async_callback, continue, code_review
  low: color_api, package_name, rtl, design_system
```

---

End of LESSONS_LEARNED  
Version: 2.0 | Date: 26/10/2025  
Optimized for AI parsing - minimal formatting, maximum data density.
