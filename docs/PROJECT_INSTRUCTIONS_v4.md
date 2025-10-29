# 📋 MemoZap Project Instructions v4.5

> Machine-Readable | Full YAML Format | Updated: 29/10/2025

---

## 🌍 ENVIRONMENT

```yaml
mode: MCP_Connected
access:
  filesystem: C:\projects\salsheli\ (read/edit/write/search)
  docs: /mnt/project/ (read-only)
  memory: 10_entities_optimized

project:
  name: MemoZap
  platform: Flutter 3.27+ | Dart 3.6+
  backend: Firebase (Auth, Firestore, Functions)
  state: Provider
  storage: Firebase + Hive
  design: Sticky Notes UI (RTL Hebrew)
  imports: package:memozap/ (NOT salsheli!)
  path: C:\projects\salsheli\
```

---

## 🛠️ TOOLS

```yaml
filesystem_primary_80_percent:
  read_file:
    usage: קריאת קבצים
    params: path, view_range (optional)
    example: read_file("C:\projects\salsheli\lib\models\task.dart")
  
  edit_file:
    usage: עריכת קבצים קיימים
    params: path, edits[{oldText, newText}]
    critical: EXACT match (spaces, emojis, newlines!)
    example: |
      edit_file(
        path: "lib/models/task.dart",
        edits: [{
          oldText: "class Task {",
          newText: "class Task extends Equatable {"
        }]
      )
  
  write_file:
    usage: יצירת קבצים חדשים בלבד
    warning: אל תשתמש על קבצים קיימים!
    example: write_file("lib/models/new_model.dart", content)
  
  search_files:
    usage: חיפוש בפרויקט
    params: path, pattern, excludePatterns
    example: search_files("C:\projects\salsheli\lib", "kCategories")
  
  list_directory:
    usage: רשימת תיכנים
    example: list_directory("C:\projects\salsheli\lib\config")

memory_long_term:
  search_nodes:
    usage: חיפוש entities קיימים
    critical: תמיד לפני add_observations!
    example: search_nodes("Current Work Context")
  
  create_entities:
    usage: יצירת entities חדשים
    when: רק אם search_nodes החזיר ריק
    example: |
      create_entities([{
        name: "Feature X",
        entityType: "Feature",
        observations: ["Status: in progress"]
      }])
  
  add_observations:
    usage: הוספת מידע ל-entity קיים
    critical: entity חייב להתקיים!
    example: |
      add_observations([{
        entityName: "Current Work Context",
        contents: ["Modified: file.dart - what changed"]
      }])

chats_history:
  recent_chats:
    usage: טעינת שיחות אחרונות
    params: n (1-20), before, after, sort_order
    example_continue: recent_chats(n=2) # 0=current, 1=previous
  
  conversation_search:
    usage: חיפוש בהיסטוריה
    params: query, max_results
    example: conversation_search("list types migration")

bash_powershell:
  usage: פקודות Windows
  network: limited (see allowed domains)
  
  CRITICAL_WARNING: |
    ⚠️ NEVER use bash_tool with Windows paths!
    bash_tool = Linux shell (/bin/sh)
    Linux doesn't understand C:\ drives
    Result: ALWAYS FAILS
    
    Wrong: bash_tool("cd C:\\projects\\salsheli && findstr ...")
    Right: search_files("C:\\projects\\salsheli\\lib", "pattern")
    
    This is the #1 MOST COMMON ERROR!
  
  examples:
    - flutter pub get
    - flutter test
    - dart format lib/
  
  when_to_use:
    - Flutter commands (pub, test, analyze)
    - Dart commands (format, fix)
    - NEVER for file operations!
```

---

## ⚡ WORKFLOW

```yaml
session_start:
  step_1: search_nodes("Current Work Context")
  step_2: |
    IF user says "המשך":
      recent_chats(n=2)  # load previous session
      continue from last checkpoint
  step_3: |
    IF need code context:
      read_file(specific_file)
    ELSE:
      start work immediately

during_session:
  response_style:
    language: Hebrew (except code/tech)
    length: 3-5 sentences max
    
    options_format: |
      ALWAYS separate lines (RTL issue!):
      
      **Option A:**
      תיאור קצר
      
      **Option B:**
      תיאור קצר
      
      **Option C:**
      תיאור קצר
      
      Sub-options: A1, A2, A3
    
    artifacts: NEVER use for code (edit_file ONLY)
    command_snippets: NEVER provide (user doesn't run manually)
    
  code_format:
    full_blocks: כשצריך להעתיק
    edit_file: לשינויים בקוד קיים
    write_file: לקבצים חדשים
    no_snippets: אל תתן חלקי קוד
  
  never_do:
    - ❌ תיאור כישלונות למשתמש
    - ❌ בקשת אישור לפעולות פשוטות
    - ❌ אופציות באותה שורה (RTL issue!)
    - ❌ artifacts for code (edit_file ONLY)
    - ❌ command snippets to run
    - ❌ introductions/apologies
    - ❌ קריאת docs אוטומטית
    - ❌ edit_file בלי read_file לפני

session_end:
  step_1: add_observations("Current Work Context")
  step_2: |
    IF work incomplete:
      suggest "המשך" למשתמש
```

---

## 📚 DOCUMENTATION

```yaml
docs_6_files:
  CODE.md:
    content: Architecture + Patterns + Testing
    size: 500_lines
    read_when:
      - כותב Provider חדש
      - צריך pattern ספציפי
      - שאלות על ארכיטקטורה
    
  DESIGN.md:
    content: Sticky Notes UI + RTL + Components
    size: 300_lines
    read_when:
      - בונה UI component
      - שאלות על design system
      - צבעים/spacing/עיצוב
    
  TECH.md:
    content: Firebase + Security + Models
    size: 400_lines
    read_when:
      - עבודה עם Firestore
      - household_id security
      - JSON serialization
    
  CODE_REVIEW_CHECKLIST.md:
    content: Review protocol + Dead code detection
    size: 300_lines
    read_when:
      - user says "תבדוק [file]"
      - לפני commit
      - סקירת קוד
    critical: |
      Protocol:
        1. read_file
        2. search_files (check usage!)
        3. apply checklist
        4. format response in Hebrew
    
  LESSONS_LEARNED.md:
    content: Common errors + solutions
    size: 300_lines
    read_when:
      - טעות חוזרת
      - אזהרה לפני שינוי מסוכן
      - תיקון באג מוכר
    
  WORK_PLAN.md:
    content: 8 weeks roadmap (Lists + Inventory)
    size: 500_lines
    read_when:
      - תכנון פיצ'רים חדשים
      - צריך big picture
      - שאלות על עתיד

reading_strategy:
  default: ZERO (אל תקרא!)
  memory_sufficient: 95% מקרים
  
  read_only_if:
    - user explicitly mentions doc
    - need exact pattern not in memory
    - user says "תבדוק בדוקס"
    - complex new feature (read multiple)
  
  never_read:
    - bug fix (memory has pattern)
    - typo/simple change
    - known task from memory
```

---

## 🎯 CRITICAL PROTOCOLS

```yaml
edit_protocol:
  step_1: read_file(path)
  step_2: copy EXACT oldText (spaces, emojis, newlines)
  step_3: edit_file(path, edits)
  step_4: |
    IF fails:
      read_file again
      find exact match
      retry
  
  common_mistake: |
    Missing emoji in oldText
    Example: "📌" vs no emoji

memory_protocol:
  step_1: search_nodes(query) OR read_graph()
  step_2: |
    IF entity exists:
      add_observations(entityName, contents)
    ELSE:
      create_entities([...])
  step_3: NEVER add_observations on non-existent entity!
  
  what_to_store:
    - architectural decisions
    - feature status
    - checkpoints
    - known issues
    - next steps
  
  what_NOT_to_store:
    - raw code
    - file contents
    - temp session data

code_review_protocol:
  trigger: user says "תבדוק [file]"
  
  step_0: read CODE_REVIEW_CHECKLIST.md
  step_1: read_file(target_file) FULL - not partial!
  step_2: search_files(lib, filename) # check external imports
  step_3: |
    6-Step Dead Code Verification (CRITICAL!):
    1. search_files - check imports across project
    2. read_file FULL - read entire file (not partial!)
    3. in-file usage - check usage within file itself
    4. constants usage - search for k[ClassName] patterns
    5. static usage - search for ClassName.method patterns
    6. final approval - only after 5 negative checks
  step_4: |
    Final decision:
    IF all 6 checks negative:
      report "💀 Dead Code - not used"
    ELSE:
      report "✅ ACTIVE - used via [mechanism]"
      apply full checklist
  step_5: |
    Format response:
      📄 קובץ: path
      סטטוס: ⚠️/✅/💀
      סיכום: 1 sentence
      
      🚨 CRITICAL: issues
      ⚡ PERFORMANCE: issues
      💀 DEAD CODE: what + why
      
      🔧 צעדים: 1,2,3
  
  always_consider:
    - QA tests for new features/changes
    - File organization (merge/delete/move) for old/messy code
    - Dormant Code: 5 questions (UI ready? Design ready? Tests? Docs? Need it?)
  
  before_reorganizing:
    rule: ALWAYS ASK user first
    why: Major refactoring needs approval
  
  critical_warning: |
    ⚠️ FALSE-POSITIVE PREVENTION:
    search_files misses 3 usage types:
    1. in-file usage (AppStrings.layout.title)
    2. constants usage (kMinFamilySize)
    3. static class usage (StoresConfig.isValid)
    
    Impact: DELETING ACTIVE CODE breaks entire app!
    Rule: When in doubt - DON'T DELETE!
    
    Real mistakes: sessions 41, 43 (2 active files deleted)
```

---

## 🚨 SECURITY & PERFORMANCE

```yaml
security_critical:
  household_id_mandatory:
    rule: EVERY Firestore query MUST filter by household_id
    
    wrong: |
      .where('user_id', isEqualTo: userId)
      # BREACH - sees ALL households!
    
    correct: |
      .where('household_id', isEqualTo: householdId)
      .where('user_id', isEqualTo: userId)
    
    impact:
      - GDPR violation
      - Privacy breach
      - App store removal
    
    checklist:
      - [ ] Every .collection() has .where('household_id', ...)
      - [ ] Firebase Rules enforce it
      - [ ] Tested: user can't see other households

performance_critical:
  lazy_loading:
    rule: Don't load Providers in constructor
    
    wrong: |
      ProductsProvider(repo) {
        _loadProducts(); # Slows startup!
      }
    
    correct: |
      Future<void> ensureInitialized() async {
        if (_isInitialized) return;
        _isInitialized = true;
        await _loadProducts();
      }
    
    benefits:
      - 50%+ faster startup
      - 30-40% less memory
      - Load only what needed
  
  const_optimization:
    rule: Missing const = 5-10% unnecessary rebuilds
    
    with_literals:
      - const SizedBox(height: 16)
      - const EdgeInsets.all(8)
      - const Text('Static text')
      - const Icon(Icons.add)
    
    with_variables:
      - SizedBox(height: spacing) # variable!
      - _Card(data: item) # variable!

  provider_disposal:
    rule: 5 things to ALWAYS clean in dispose()
    
    template: |
      @override
      void dispose() {
        // 1. UserContext listener (MOST COMMON leak!)
        _userContext.removeListener(_onUserChanged);
        
        // 2. Controllers
        _textController.dispose();
        _animationController.dispose();
        
        // 3. Timers
        _timer?.cancel();
        
        // 4. Streams
        _subscription?.cancel();
        
        // 5. Platform resources
        _recognizer?.close();
        
        super.dispose(); # ALWAYS last!
      }
    
    impact_if_forget:
      - 💀 Memory leak
      - 🔋 Battery drain
      - 🐌 App slows down
      - 💥 Crashes

  context_after_await:
    rule: Widget can dispose during await → CRASH!
    
    wrong: |
      await _save();
      Navigator.of(context).push(...); # CRASH!
    
    correct: |
      final nav = Navigator.of(context);
      await _save();
      if (!mounted) return;
      nav.push(...); # SAFE!
```

---

## 🔔 TOKEN MANAGEMENT

```yaml
token_budget: 190000
current_usage: monitor frequently

alerts:
  70_percent:
    threshold: 133000_tokens
    remaining: 30_percent
    action: |
      ⚠️ **התראה: 70% טוקנים**
      נותרו 30% (~57K טוקנים)
      
      **Option A:**
      המשך עבודה (עוד 5-10 קבצים)
      
      **Option B:**
      שמור checkpoint עכשיו
    mode: alert_only
    trigger: user_decision
  
  85_percent:
    threshold: 161500_tokens
    remaining: 15_percent
    action: |
      🚨 **התראה קריטית: 85% טוקנים**
      נותרו 15% (~28.5K טוקנים)
      שומר checkpoint אוטומטי...
    mode: auto_checkpoint + ultra_concise
    trigger: automatic
  
  90_percent:
    threshold: 171000_tokens
    remaining: 10_percent
    action: |
      ❌ **סיום חירום: 90% טוקנים**
      נותרו 10% (~19K טוקנים)
      שומר checkpoint סופי + סיכום...
    mode: emergency_save + end_session
    trigger: automatic

checkpoint_protocol:
  automatic_updates:
    trigger: After 3-5 file changes OR topic switch
    entity: Current Work Context
    content: |
      Last Updated: [date] [time]
      Task: [exact task description]
      Status: [stage/percentage/completion]
      Files Touched: [list with changes]
      Next Steps: [EXACT continuation point]
      Critical Context: [any info needed to continue]
      Decisions Made: [architectural/design decisions]
  
  session_rotation:
    entity: Recent Sessions
    behavior: Auto-rotate (keep last 3-5 sessions)
    content: |
      Session [N]:
      Date: [date]
      Task: [description]
      Outcome: [complete/partial/blocked]
      Files: [list]
  
  user_message:
    output: |
      📌 **מוכן להמשך בשיחה חדשה**
      
      **פקודה:** "המשך"
      
      **המערכת תטען אוטומטית:**
      ✅ Current Work Context (מצב עדכני)
      ✅ Recent Sessions (3-5 אחרונות)
      ✅ ימשיך בדיוק מ-Next Steps
      
      **יתרונות:**
      - אפס אובדן מידע
      - אין maintenance ידני
      - עובד מאחורי הקלעים

continuation_protocol:
  user_command: "המשך"
  
  system_execution:
    step_1: recent_chats(n=2) # load previous chat
    step_2: search_nodes("Current Work Context") # load state
    step_3: |
      Continue EXACTLY from "Next Steps"
      Do NOT repeat work
      Do NOT ask what to do
      Just CONTINUE
  
  benefits:
    - ✅ Zero context loss
    - ✅ Seamless continuation
    - ✅ No repeated explanations
    - ✅ Efficient token usage
    - ✅ No manual documentation
    - ✅ Automatic tracking
```

---

## 🚫 ANTI-PATTERNS

```yaml
never_do:
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
    use: Check docs/ + memory first
  
  relative_imports:
    why: Breaks when moving files
    use: package:memozap/ always
  
  edit_without_read:
    why: Will fail (no exact match)
    use: read_file → copy exact → edit_file
```

---

## 💾 MEMORY ENTITIES

```yaml
memory_structure_10:
  1_current_work_context:
    entity: Current Work Context
    type: Active Session
    updates: Auto (after 3-5 files)
    content: |
      - Last Updated
      - Task
      - Status
      - Files Touched
      - Next Steps
      - Critical Context
      - Decisions Made
  
  2_recent_sessions:
    entity: Recent Sessions
    type: Session History
    updates: Auto-rotate (keep 3-5)
    content: |
      - Session date
      - Task
      - Outcome
      - Files modified
  
  3_active_issues:
    entity: Active Issues
    type: Bugs & Tasks
    updates: Manual
    content: |
      - Issue #N
      - Priority
      - Status
      - Context
  
  4_feature_progress:
    entity: Feature Progress
    type: Feature Tracking
    updates: Manual
    content: |
      - Feature name
      - Completion %
      - Blockers
      - Next milestone
  
  5_learning_from_mistakes:
    entity: Learning from Mistakes
    type: Auto-Learning
    updates: Auto (on error)
    content: |
      - Error #N
      - Cause
      - Fix
      - Learning
  
  6_project_info:
    entity: MemoZap Project
    type: Project Info
    updates: Rare
    content: |
      - Tech stack
      - Architecture
      - Key decisions
  
  7_standards:
    entity: Design & Development Standards
    type: Standards
    updates: Rare
    content: |
      - Code patterns
      - Design system
      - Best practices
  
  8_protocols:
    entity: Critical Protocols
    type: Work Protocols
    updates: Rare
    content: |
      - Edit protocol
      - Memory protocol
      - Review protocol
  
  9_tool_errors:
    entity: Tool Errors & Solutions
    type: Error Patterns
    updates: Auto (on error)
    content: |
      - Tool name
      - Error pattern
      - Solution
  
  10_environment:
    entity: MemoZap Chat Environment
    type: Environment
    updates: Rare
    content: |
      - Paths
      - Tools
      - Preferences

update_triggers_only_2:
  trigger_1:
    when: After 3-5 files edited
    what: Current Work Context
    format: |
      - Last action (1 sentence)
      - Files touched (list)
      - Next step (1 sentence)
  
  trigger_2:
    when: Before switching topic
    what: Current Work Context
    format: Same as trigger_1

learning_protocol:
  when_error_detected:
    step_1: Identify what went wrong
    step_2: Understand why
    step_3: add_observations to "Learning from Mistakes"
    step_4: Continue (don't tell user about error)
  
  format: |
    Error #N (date): what happened
    Cause #N: why it happened
    Fix #N: how to prevent
    Learning #N: lesson learned
```

---

## 🎓 LEARNING FROM MISTAKES

```yaml
error_11_most_recent:
  date: 29/10/2025
  error_6: Reviewed filters_config.dart without checking usage
  cause_6: Followed 'read before edit' but missed 'check usage'
  fix_6: read_file → search_files(imports) → report if unused
  learning_6: Code review MUST include usage check
  
  error_7: ui_constants.dart - over-planning anti-pattern (session 40)
  cause_7: Created comprehensive 600-line constants file before actual need
  fix_7: YAGNI principle - add constants only when pattern appears 3+ times
  learning_7: Don't design perfect systems upfront, grow organically
  impact_7: ✅ True dead code - correctly identified and deleted
  
  error_8: app_strings.dart false dead code claim (session 42)
  cause_8: Used search_files alone, missed in-file usage (AppStrings.layout.title)
  fix_8: 6-step protocol - all usage types must be checked
  learning_8: Never claim dead code without verifying in-file usage
  impact_8: CRITICAL - almost deleted active file (1100+ lines)
  
  error_9: bash_tool with Windows paths (session 42)
  cause_9: Used bash_tool("cd C:\\...") - Linux shell doesn't understand Windows drives
  symptom_9: "/bin/sh: cd: can't cd to C:projectssalsheli"
  fix_9: ALWAYS use Filesystem:search_files/read_file for Windows file operations
  learning_9: bash_tool = Linux shell, NEVER for Windows paths
  impact_9: CRITICAL - wastes tool calls, this is THE MOST COMMON ERROR
  
  error_10: constants.dart false dead code (session 41)
  cause_10: search_files("constants.dart") = 0 imports, but missed constants usage
  actual_usage_10: kMinFamilySize, kMaxFamilySize, kValidChildrenAges in onboarding_data
  fix_10: Must search for k[ClassName] patterns separately
  learning_10: Constants used via name, not import - search_files misses this!
  impact_10: CRITICAL - deleted active file, broke onboarding (430 lines)
  
  error_11: stores_config.dart false dead code (session 43)
  cause_11: search_files("stores_config.dart") = 0 imports, missed static usage
  actual_usage_11: StoresConfig.isValid() called in onboarding_data
  fix_11: Must search for ClassName.method patterns separately
  learning_11: Static classes used without import - search_files misses this!
  impact_11: CRITICAL - deleted active file, broke onboarding (recovered manually)
  
  error_12: undefined identifiers compilation (session 45)
  cause_12: Used constants before verifying they exist in ui_constants.dart
  symptom_12: kDoubleTapTimeout, kSnackBarBottomMargin, kBorderRadiusSmall not found
  fix_12: Check ui_constants.dart first, add missing constants if needed
  learning_12: Before using new constants - verify they exist or add them
  impact_12: Medium - 8 compilation errors, fixed by adding 4 constants

top_6_common_errors:
  1:
    name: false dead code detection
    impact: DELETING ACTIVE CODE (breaks entire app!)
    frequency: very_high
    recent: 3 files (sessions 41-43: app_strings, constants, stores_config)
    fix: Use 6-step protocol (not just search_files!)
  
  2:
    name: bash_tool with Windows paths
    impact: ALWAYS FAILS
    frequency: very_high
    fix: Use Filesystem:search_files instead
  
  3:
    name: household_id missing
    impact: SECURITY BREACH
    frequency: medium
  
  4:
    name: removeListener missing
    impact: MEMORY LEAK
    frequency: high
  
  5:
    name: context after await
    impact: CRASH
    frequency: high
  
  6:
    name: over-planning (YAGNI violation)
    impact: 1000+ lines dead code
    frequency: medium
    examples: ui_constants (600), constants (430)
    fix: Add code only when pattern appears 3+ times
```

---

## 📊 PROJECT STRUCTURE

```yaml
lib:
  models: Data classes (JSON serializable)
  providers: State management (Provider pattern)
  repositories: Data layer (Firebase abstraction)
  screens: Full-page UI
  widgets: Reusable components
  services: External integrations
  l10n: Translations (he, en)
  utils: Helpers
  config: Constants + configs

docs:
  count: 6 files
  total_lines: 2300 (optimized for machine)
  files:
    - CODE.md (500) - patterns
    - DESIGN.md (300) - UI/UX
    - TECH.md (400) - Firebase
    - CODE_REVIEW_CHECKLIST.md (300) - review
    - LESSONS_LEARNED.md (300) - errors
    - WORK_PLAN.md (500) - future

test:
  unit: model tests (90%+ coverage)
  widget: UI tests (bySemanticsLabel pattern)
  integration: (minimal)
```

---

## 🔗 QUICK REFERENCE

```yaml
commands:
  user_says_continue:
    hebrew: "המשך"
    action: recent_chats(2) + search_nodes + continue
  
  user_says_review:
    hebrew: "תבדוק [file]"
    action: CODE_REVIEW_CHECKLIST protocol
  
  user_says_fix:
    hebrew: "תקן [issue]"
    action: read_file → edit_file → done
  
  user_says_create:
    hebrew: "צור [file]"
    action: write_file(path, content)

shortcuts:
  read_docs: /mnt/project/[DOC].md
  read_code: C:\projects\salsheli\lib\...
  memory: search_nodes first, always!
  checkpoint: after 3-5 files OR topic switch
  yagni: don't create systems before needed (3+ pattern rule)

critical_checklist_before_commit:
  - [ ] household_id in ALL Firestore queries
  - [ ] removeListener() in ALL dispose()
  - [ ] context captured before await
  - [ ] const on ALL static widgets
  - [ ] package imports (not relative)
  - [ ] bySemanticsLabel in tests
  - [ ] 4 UI states (Loading/Error/Empty/Content)
  - [ ] max 15 debugPrint per file
```

---

**End of Instructions v4.0** 🎯

**Changes from v3.0:**
- ✅ Full YAML format (100% machine-readable)
- ✅ Added CODE_REVIEW_CHECKLIST.md + CHANGELOG.md
- ✅ Added examples for every tool
- ✅ Cross-references between sections
- ✅ Expanded protocols (edit, memory, review)
- ✅ Added quick reference shortcuts
- ✅ Security + Performance in one place

**Updates v4.1 (session 41):**
- ✅ Removed GUIDE.md references (deleted)
- ✅ Updated docs: 8→7 files, 2100→2700 lines
- ✅ Added YAGNI lessons (ui_constants, constants)
- ✅ Updated checkpoint: every file→3-5 files

**Updates v4.2 (session 42):**
- ✅ Added bash_tool Windows warning
- ✅ Added error_9: bash_tool paths
- ✅ Impact: THE MOST COMMON ERROR

**Updates v4.3 (session 43 - CRITICAL):**
- ✅ Enhanced Dead Code Detection: 4→6 steps
- ✅ Added error_10: constants.dart false positive (kMinFamilySize)
- ✅ Added error_11: stores_config.dart false positive (StoresConfig.isValid)
- ✅ Updated top_5→top_6_common_errors (false dead code #1!)
- ✅ Critical fix: search_files misses 3 usage types
- ✅ Impact: Prevents DELETING ACTIVE CODE (3 incidents!)
- ✅ New rule: When in doubt - DON'T DELETE!

**Updates v4.4 (session 45 - TOKEN MANAGEMENT):**
- ✅ Added User Communication Preferences (artifacts + snippets + format)
- ✅ Added Code Review Additions (QA tests + file organization + ASK before refactor)
- ✅ Added TOKEN MANAGEMENT section (70%/85%/90% alerts + continuation protocol)
- ✅ Added error_12: undefined identifiers (session 45 pattern)
- ✅ Impact: Seamless session continuation + zero context loss

**Updates v4.5 (session 46 - MEMORY FIRST):**
- ✅ Removed CHANGELOG.md (Memory replaces it!)
- ✅ Enhanced Memory Structure (10 entities detailed)
- ✅ Automatic checkpoint protocol (no manual docs)
- ✅ Session rotation (keep last 3-5)
- ✅ Docs: 7→6 files, 2700→2300 lines
- ✅ Impact: Zero maintenance, automatic tracking, efficient tokens

**Total:** 500 lines | Format: Pure YAML  
**Version:** 4.5
**Last Updated:** 29/10/2025  
**Maintainer:** MemoZap AI System
