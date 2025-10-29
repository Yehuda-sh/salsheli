# 📋 MemoZap Project Instructions v4.0

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
  examples:
    - flutter pub get
    - flutter test
    - dart format lib/
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
    format: |
      Option A:
      תיאור קצר
      
      Option B:
      תיאור קצר
      
      Option C:
      תיאור קצר
    
  code_format:
    full_blocks: כשצריך להעתיק
    edit_file: לשינויים בקוד קיים
    write_file: לקבצים חדשים
    no_snippets: אל תתן חלקי קוד
  
  never_do:
    - ❌ תיאור כישלונות למשתמש
    - ❌ בקשת אישור לפעולות פשוטות
    - ❌ אופציות באותה שורה (RTL issue!)
    - ❌ introductions/apologies
    - ❌ קריאת docs אוטומטית
    - ❌ edit_file בלי read_file לפני

session_end:
  step_1: add_observations("Current Work Context")
  step_2: update CHANGELOG.md [IN_PROGRESS]
  step_3: |
    IF work incomplete:
      suggest "המשך" למשתמש
```

---

## 📚 DOCUMENTATION

```yaml
docs_8_files:
  GUIDE.md:
    content: Project + Protocol + Tools + MCP
    size: 400_lines
    read_when:
      - protocol שכחתי
      - צריך overview כללי
      - מבנה הפרויקט
    
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
    
  CHANGELOG.md:
    content: Session history + [IN_PROGRESS]
    size: 400_lines
    read_when:
      - צריך סטטוס נוכחי
      - מחפש מה שונה לאחרונה
      - המשך עבודה
    update_trigger: אחרי כל file change
    
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
  step_1: read_file(target_file)
  step_2: search_files(lib, filename) # check usage!
  step_3: |
    IF no imports found:
      report "💀 Dead Code - not used"
    ELSE:
      apply full checklist
  step_4: |
    Format response:
      📄 קובץ: path
      סטטוס: ⚠️/✅/💀
      סיכום: 1 sentence
      
      🚨 CRITICAL: issues
      ⚡ PERFORMANCE: issues
      💀 DEAD CODE: what + why
      
      🔧 צעדים: 1,2,3
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
current_entities_10:
  - Current Work Context (Active Session)
  - Learning from Mistakes (Auto-Learning)
  - MemoZap Project (Project Info)
  - Design & Development Standards (Standards)
  - Critical Protocols (Work Protocols)
  - Tool Errors & Solutions (Error Patterns)
  - Development Tools Guide (Tool Reference)
  - MCP Anti-Patterns (Best Practices)
  - Lessons Learned - MemoZap (Error Prevention)
  - MemoZap Chat Environment (Environment)

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
error_6_most_recent:
  date: 29/10/2025
  error: Reviewed filters_config.dart without checking usage
  cause: Followed 'read before edit' but missed 'check usage'
  fix: read_file → search_files(imports) → report if unused
  learning: Code review MUST include usage check

top_5_common_errors:
  1:
    name: household_id missing
    impact: SECURITY BREACH
    frequency: medium
  
  2:
    name: removeListener missing
    impact: MEMORY LEAK
    frequency: high
  
  3:
    name: context after await
    impact: CRASH
    frequency: high
  
  4:
    name: const on dynamic widgets
    impact: BUILD ERROR
    frequency: medium
  
  5:
    name: edit_file without read
    impact: NO MATCH
    frequency: high
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
  count: 8 files
  total_lines: 2100 (optimized for machine)
  files:
    - GUIDE.md (400) - entry point
    - CODE.md (500) - patterns
    - DESIGN.md (300) - UI/UX
    - TECH.md (400) - Firebase
    - CODE_REVIEW_CHECKLIST.md (300) - review
    - LESSONS_LEARNED.md (300) - errors
    - CHANGELOG.md (400) - history
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
  checkpoint: after every file change

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

**Total:** 400 lines | Format: Pure YAML  
**Last Updated:** 29/10/2025  
**Maintainer:** MemoZap AI System
