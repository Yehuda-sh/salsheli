# 🛠️ MCP Tools Guide - Salsheli Project

> **מדריך מקיף לשימוש בכלי MCP של Claude Desktop**  
> **עדכון:** 19/10/2025 | **גרסה:** 1.0  
> **למי:** AI Assistants + Developers using Claude Desktop

---

## 📚 תוכן עניינים

- [סקירה כללית](#סקירה-כללית)
- [10 הכלים במפורט](#10-הכלים-במפורט)
- [Workflows מומלצים](#workflows-מומלצים)
- [Anti-Patterns - מה לא לעשות](#anti-patterns)
- [Troubleshooting](#troubleshooting)
- [Integration עם מסמכי הפרויקט](#integration)

---

## 🎯 סקירה כללית

### מה זה MCP Tools?

**MCP (Model Context Protocol)** = פרוטוקול שנותן ל-Claude גישה לכלים חיצוניים דרך Claude Desktop.

### 10 הכלים בפרויקט Salsheli:

| # | כלי | תפקיד ראשי | קריטיות |
|---|-----|------------|----------|
| 1️⃣ | **Filesystem** | קריאה/כתיבה/עריכת קבצים | 🔴 Critical |
| 2️⃣ | **Memory** | זיכרון ארוך טווח | 🟡 Important |
| 3️⃣ | **Brave Search** | חיפוש אינטרנט | 🟢 Nice to have |
| 4️⃣ | **Sequential Thinking** | חשיבה מובנית | 🟡 Important |
| 5️⃣ | **GitHub** | Git operations | 🟡 Important |
| 6️⃣ | **REPL** | הרצת JavaScript | 🟢 Nice to have |
| 7️⃣ | **Web Search/Fetch** | חיפוש + אחזור דפים | 🟢 Nice to have |
| 8️⃣ | **Conversation Search** | חיפוש בשיחות קודמות | 🟡 Important |
| 9️⃣ | **Artifacts** | יצירת קבצים מוצגים | 🟢 Nice to have |
| 🔟 | **Extended Research** | מחקר מתקדם | 🟢 Nice to have |

---

## 📖 10 הכלים במפורט

---

### 1️⃣ Filesystem - המוח של העבודה

**תפקיד:** קריאה, כתיבה, עריכה של קבצים בפרויקט.

#### כלים פנימיים:

| Tool | Use Case | Example |
|------|----------|---------|
| `read_file` | קריאת קובץ | "תקרא את login_screen.dart" |
| `write_file` | יצירת קובץ חדש | "צור lib/models/user.dart" |
| `edit_file` | עריכת קובץ קיים | "תקן את השגיאה" |
| `list_directory` | רשימת קבצים | "מה יש בתיקייה?" |
| `search_files` | חיפוש קבצים | "מצא את כל השימושים ב-UserContext" |
| `create_directory` | יצירת תיקייה | "צור lib/features/notifications" |

#### ✅ When to Use:

```
User: "תקן את הבאג ב-login_screen.dart"
→ read_file → edit_file

User: "צור מסך חדש: settings_screen.dart"
→ write_file

User: "מה יש בתיקיית lib/providers?"
→ list_directory

User: "מצא את כל השימושים ב-kStickyYellow"
→ search_files
```

#### ❌ When NOT to Use:

```
❌ User: "הסבר מה זה Repository Pattern"
→ Don't read files - just explain

❌ User: "תן לי דוגמה לכפתור"
→ Don't write file - use artifacts (if user asks)

❌ User: "איך עושים X בפרויקט?"
→ Check documentation first (DEVELOPER_GUIDE)
```

#### 🎯 Best Practices:

1. **Always use FULL paths:**
   ```dart
   ✅ C:\projects\salsheli\lib\main.dart
   ❌ lib\main.dart
   ❌ ./lib/main.dart
   ```

2. **Prefer edit_file over write_file for existing files:**
   ```
   ✅ edit_file - surgical changes
   ❌ write_file - overwrites entire file
   ```

3. **Read before edit:**
   ```
   Always: read_file → analyze → edit_file
   Never: edit_file without reading first
   ```

#### 💡 Salsheli-Specific Examples:

**Example 1: Fix withOpacity → withValues**
```
User sends: C:\projects\salsheli\lib\screens\auth\login_screen.dart

AI:
1. read_file(login_screen.dart)
2. Find: withOpacity(0.5)
3. edit_file: Replace with withValues(alpha: 0.5)
4. Report: "✅ תיקנתי את withOpacity"
```

**Example 2: Add const to SizedBox**
```
AI:
1. search_files("SizedBox", "lib/screens/")
2. For each file with SizedBox(height: X):
   - read_file
   - edit_file: Add const
3. Report: "✅ הוספתי const ל-15 מקומות"
```

---

### 2️⃣ Memory - הזיכרון הארוך טווח

**תפקיד:** שמירת החלטות, העדפות, וידע ארוך טווח על הפרויקט.

#### ✅ When to Use:

```
✅ Architectural decisions:
"תזכור: תמיד להשתמש ב-Repository Pattern, אף פעם לא Firebase ישירות"

✅ User preferences:
"תזכור: המשתמש מעדיף edit_file על artifacts"

✅ Project-specific rules:
"תזכור: כל מסך UI חייב להשתמש ב-Sticky Notes Design"

✅ Common mistakes to avoid:
"תזכור: אל תשתמש ב-withOpacity - זה deprecated"

✅ Code patterns:
"תזכור: async callbacks צריכים wrapping: onPressed: () => _func()"
```

#### ❌ When NOT to Use:

```
❌ Temporary conversation state:
"תזכור את השם של הקובץ שעבדנו עליו לפני 5 דקות"
→ זה בשיחה הנוכחית, לא צריך Memory

❌ Information already in documentation:
"תזכור ש-kStickyYellow זה צהוב"
→ זה כבר ב-DESIGN_GUIDE.md

❌ One-time facts:
"תזכור שהיום יום שלישי"
→ זה לא רלוונטי לטווח ארוך
```

#### 🎯 Best Practices:

1. **Be specific:**
   ```
   ✅ "Repository Pattern mandatory - NEVER use Firebase directly in screens"
   ❌ "Use good patterns"
   ```

2. **Link to docs when possible:**
   ```
   ✅ "Sticky Notes Design required - see DESIGN_GUIDE.md Part 13"
   ❌ "Use sticky design"
   ```

3. **Update when needed:**
   ```
   If rule changes:
   - Delete old memory
   - Create new memory
   - Explain why changed
   ```

#### 💡 Salsheli-Specific Examples:

**What to Store in Memory:**

```
1. Architecture Rules (from AI_MASTER_GUIDE Part 7):
   - "Repository Pattern mandatory"
   - "household_id required in all queries"
   - "4 Loading States required"
   - "UserContext listeners must be disposed"

2. Common Fixes (from AI_MASTER_GUIDE Part 6):
   - "withOpacity → withValues(alpha:)"
   - "Async callbacks need lambda wrapper"
   - "mounted check after await"
   - "const for static widgets"

3. User Preferences:
   - "User prefers Filesystem:edit_file over artifacts"
   - "User is Hebrew speaker - all responses in Hebrew"
   - "User is beginner developer - technical but accessible"

4. Project-Specific Validations:
   - "List name: trim + isEmpty check"
   - "Quantity: 1-9999 range"
   - "household_id validation before save"
```

#### 🔧 Memory Operations:

| Operation | When | Example |
|-----------|------|---------|
| `create_entities` | First time learning something | "Repository Pattern is mandatory" |
| `add_observations` | Adding details to existing knowledge | "Repository Pattern: see DEVELOPER_GUIDE Part 1" |
| `delete_entities` | Rule changed | "Old: Hive for local storage" (now deleted) |
| `search_nodes` | Checking if we know something | "Do we have rules about Firebase?" |

---

### 3️⃣ Brave Search - חיפוש אינטרנט

**תפקיד:** חיפוש מידע עדכני באינטרנט.

#### ✅ When to Use:

```
✅ Finding packages:
"מצא Flutter package לסריקת QR codes"

✅ Error solutions:
"איך מתקנים 'setState called after dispose'?"

✅ Current events (if relevant):
"מה החדשות על Flutter 3.27?"

✅ API documentation:
"מה הפרמטרים של Firebase batch.commit()?"
```

#### ❌ When NOT to Use:

```
❌ Information in project docs:
"מה זה Sticky Notes Design?"
→ It's in DESIGN_GUIDE.md

❌ Code that exists in project:
"איך עושים login בפרויקט?"
→ Read lib/screens/auth/login_screen.dart

❌ General Flutter knowledge:
"מה זה StatefulWidget?"
→ Claude knows this
```

#### 💡 Salsheli-Specific Examples:

```
✅ "מצא package ל-OCR שתומך בעברית"
✅ "מה הגרסה האחרונה של firebase_auth?"
✅ "איך מתקנים build errors ב-Flutter 3.27?"

❌ "איך עובד ה-Repository Pattern בפרויקט?"
   → Read DEVELOPER_GUIDE.md instead
```

---

### 4️⃣ Sequential Thinking - חשיבה מובנית

**תפקיד:** פתרון בעיות מורכבות בצעדים מסודרים.

#### ✅ When to Use:

```
✅ Complex bugs:
"למה ה-UI לא מתעדכן אחרי שמירה?"
→ Use Sequential Thinking to trace the flow

✅ Architecture decisions:
"איך לארגן את ה-features החדשים?"
→ Think through options systematically

✅ Performance issues:
"למה האפליקציה איטית?"
→ Analyze step by step

✅ Multi-step migrations:
"איך להמיר את כל המסכים ל-Sticky Notes?"
→ Plan the migration systematically
```

#### ❌ When NOT to Use:

```
❌ Simple fixes:
"תוסיף const ל-SizedBox"
→ Just do it, no thinking needed

❌ Well-documented solutions:
"איך עושים Repository Pattern?"
→ It's in DEVELOPER_GUIDE.md

❌ One-liner answers:
"מה הגובה המינימלי לכפתור?"
→ 44px (from DESIGN_GUIDE.md)
```

#### 🎯 Best Practices:

1. **Use for multi-step problems:**
   - More than 3 steps
   - Uncertainty about approach
   - Need to explore alternatives

2. **Don't overuse:**
   - Simple tasks don't need thinking
   - Clear solutions don't need exploration

#### 💡 Salsheli-Specific Examples:

**Good use:**
```
Problem: "המסך לא מתעדכן אחרי שמירת רשימה"

Sequential Thinking:
1. Check if notifyListeners() called → Missing!
2. Check if Provider listening to UserContext → Yes
3. Check if dispose() removes listener → Missing!
4. Conclusion: Memory leak + missing notifyListeners
→ Fix both issues
```

**Bad use:**
```
Problem: "תקן withOpacity"

❌ Don't use Sequential Thinking
✅ Just replace: withOpacity → withValues
```

---

### 5️⃣ GitHub - Git Operations

**תפקיד:** ניהול Git: commit, push, branch, PR.

#### כלים זמינים:

| Tool | Purpose | Example |
|------|---------|---------|
| `create_or_update_file` | Commit single file | "עשה commit לשינוי" |
| `push_files` | Commit multiple files | "עשה commit ל-5 הקבצים" |
| `create_branch` | יצירת branch חדש | "צור branch: feature/notifications" |
| `create_pull_request` | יצירת PR | "צור PR עם השינויים" |
| `fork_repository` | Fork repo | "עשה fork מ-flutter/flutter" |

#### ✅ When to Use:

```
✅ User asks for commit:
"עשה commit עם ההודעה: 'fix: login screen'"

✅ User asks to push:
"תעשה push לכל השינויים"

✅ User asks for PR:
"צור PR עם הפיצ'ר החדש"

✅ User asks for branch:
"צור branch חדש: feature/settings"
```

#### ❌ When NOT to Use:

```
❌ User didn't ask for Git operations:
Just fixing code → Don't auto-commit

❌ User wants manual control:
"תתקן את הקוד" ≠ "תעשה commit"

❌ Uncommitted changes unclear:
Ask first: "האם לעשות commit לשינויים?"
```

#### 🎯 Best Practices:

1. **Confirm before committing:**
   ```
   User: "תקן את הבאג"
   AI: [Fixes code]
   AI: "✅ תיקנתי. האם לעשות commit?"
   ```

2. **Use conventional commits:**
   ```
   ✅ "fix: login screen mounted check"
   ✅ "feat: add settings screen"
   ✅ "refactor: convert to Sticky Notes design"
   ❌ "updated files"
   ```

3. **Check repo state first:**
   ```
   - Are there uncommitted changes?
   - Is there a remote configured?
   - Am I on the right branch?
   ```

#### 💡 Salsheli-Specific Examples:

```
User: "תקן את login_screen.dart ותעשה commit"

AI:
1. read_file(login_screen.dart)
2. edit_file [fixes]
3. GitHub:push_files with message: "fix(auth): add mounted check to login screen"
4. Report: "✅ תיקנתי ועשיתי commit"
```

---

### 6️⃣ REPL (Analysis Tool) - הרצת JavaScript

**תפקיד:** הרצת JavaScript לחישובים, בדיקות, ניתוח קבצים.

#### ✅ When to Use:

```
✅ Complex calculations:
"מה 847293 * 652847?"

✅ CSV/Excel analysis:
User uploads large file → Use REPL to parse + analyze

✅ Data transformations:
"המר את ה-JSON הזה ל-CSV"

✅ Testing code snippets:
"תבדוק אם הביטוי הרגולרי הזה עובד"
```

#### ❌ When NOT to Use:

```
❌ Simple math:
"מה 15% מ-100?" → No need for REPL

❌ Dart/Flutter code:
Can't run Dart in REPL → Only JavaScript

❌ File operations:
Use Filesystem tools instead

❌ Showing code to user:
Use artifacts or code blocks
```

#### 🎯 Best Practices:

1. **Use for JavaScript only:**
   ```
   ✅ Calculate, parse, transform
   ❌ Can't run Dart/Flutter
   ```

2. **Import libraries when needed:**
   ```javascript
   import Papa from 'papaparse';  // CSV parsing
   import * as math from 'mathjs'; // Math operations
   import _ from 'lodash';         // Data manipulation
   ```

3. **Use for large file analysis:**
   ```
   User uploads 1000-row CSV
   → Use REPL with Papaparse to analyze
   → Don't try to read manually
   ```

#### 💡 Salsheli-Specific Examples:

```
❌ Not relevant for Salsheli (Flutter project)
→ REPL is for JavaScript, not Flutter/Dart

Exception: If user uploads CSV data for analysis
```

---

### 7️⃣ Web Search / Web Fetch - חיפוש ואחזור

**תפקיד:** חיפוש ברשת + אחזור תוכן דפים.

#### כלים:

| Tool | Purpose | Example |
|------|---------|---------|
| `web_search` | חיפוש Google-style | "חפש: Flutter State Management" |
| `web_fetch` | אחזור דף ספציפי | "תקרא: https://docs.flutter.dev" |

#### ✅ When to Use:

```
✅ Finding documentation:
"מה כתוב ב-docs של Firebase על batch?"
→ web_search + web_fetch

✅ Current info:
"מה החדשות על Flutter היום?"

✅ API references:
"תן לי את ה-API של Shufersal"
```

#### ❌ When NOT to Use:

```
❌ Info in project docs:
Don't search web for info that's in DESIGN_GUIDE.md

❌ Code from project:
Don't fetch GitHub for code you can read with Filesystem

❌ General knowledge:
Don't search for "what is a widget" - Claude knows
```

---

### 8️⃣ Conversation Search - חיפוש שיחות קודמות

**תפקיד:** מציאת מידע משיחות קודמות.

#### ✅ When to Use:

```
✅ User references past:
"מה דיברנו על OCR?"
"תמשיך עם מה שעשינו אתמול"

✅ Finding decisions:
"מה החלטנו לגבי ה-color palette?"

✅ Locating past code:
"איפה הקובץ שעשינו עם ה-buttons?"
```

#### ❌ When NOT to Use:

```
❌ Info in current chat:
"מה עשינו לפני 5 דקות?"
→ It's in the current conversation

❌ Info in docs:
"מה הצבעים של Sticky Notes?"
→ It's in DESIGN_GUIDE.md

❌ General questions:
"איך עושים widget?"
→ Not about past conversations
```

#### 🎯 Best Practices:

1. **Look for trigger phrases:**
   ```
   "מה דיברנו על..."
   "בשיחה הקודמת..."
   "תמשיך עם..."
   "אתמול עשינו..."
   ```

2. **Search with keywords:**
   ```
   ✅ "OCR", "receipt", "scanning"
   ❌ "that thing we did"
   ```

3. **Provide links:**
   ```
   "מצאתי את השיחה: [link to chat]"
   ```

---

### 9️⃣ Artifacts - תצוגת קוד מובנית

**תפקיד:** יצירת קוד/מסמכים לתצוגה אינטראקטיבית.

#### ✅ When to Use:

```
✅ User explicitly asks:
"תן לי דוגמה לכפתור"
"הראה לי template של Provider"

✅ Interactive demos:
React components, HTML pages

✅ Complete examples:
Full screen code, complete widget
```

#### ❌ When NOT to Use (CRITICAL for Salsheli):

```
❌ Fixing existing files:
User: "תקן את login_screen.dart"
→ Use Filesystem:edit_file NOT artifacts!

❌ User didn't ask for example:
User: "תקן את הבאג"
→ Fix it, don't show artifact

❌ User prefers file changes:
Salsheli user prefers edit_file over artifacts
```

#### 🎯 Best Practices:

1. **Ask first if unclear:**
   ```
   User: "תן לי כפתור"
   AI: "האם אתה רוצה דוגמה או להוסיף לקובץ קיים?"
   ```

2. **For Salsheli: Default to edit_file:**
   ```
   ✅ edit_file (preferred)
   ⚠️ artifacts (only if user asks)
   ```

---

### 🔟 Extended Research - מחקר מתקדם

**תפקיד:** מחקר מקיף עם מקורות רבים.

#### ✅ When to Use:

```
✅ Complex research questions:
"מה השיטות הטובות ביותר ל-State Management ב-Flutter?"

✅ Comparing options:
"Flutter vs React Native - מה יותר מתאים לפרויקט שלנו?"

✅ In-depth topics:
"הסבר מפורט על Firebase Security Rules"
```

#### ❌ When NOT to Use:

```
❌ Simple queries:
"מה זה Widget?" → Claude knows

❌ Info in project:
"מה הצבעים?" → DESIGN_GUIDE.md

❌ Quick fixes:
"תקן את הבאג" → Just fix it
```

#### 💡 Salsheli-Specific:

```
✅ "חקור את המתחרים של Salsheli בישראל"
✅ "מה הטכנולוגיות החדשות ל-shopping apps?"

❌ "תקן את הקוד" → Just fix, don't research
```

---

## 🔄 Workflows מומלצים

### Workflow 1: Code Review + Fix

**Scenario:** User sends file path

```
Input: C:\projects\salsheli\lib\screens\auth\login_screen.dart

Steps:
1. Filesystem:read_file(login_screen.dart)
2. Analyze:
   - Technical errors
   - Sticky Notes compliance
   - Security issues
   - Performance issues
3. If critical issues found:
   → Filesystem:edit_file [auto-fix]
4. If non-critical issues:
   → Report + Ask
5. Memory:add_observation("Fixed withOpacity in login_screen")
6. Provide quality score (X/100)
```

---

### Workflow 2: Create New Screen

**Scenario:** User asks to create new screen

```
Input: "צור מסך הגדרות חדש"

Steps:
1. Sequential Thinking: Plan structure
2. Memory:search("Sticky Notes Design requirements")
3. Filesystem:write_file(settings_screen.dart)
   → Include: NotebookBackground, StickyNote, StickyButton
4. Filesystem:read_file(main.dart)
5. Filesystem:edit_file(main.dart) - Add route
6. Report: "✅ יצרתי מסך הגדרות"
7. Ask: "האם לעשות commit?"
```

---

### Workflow 3: Fix Bug Across Multiple Files

**Scenario:** Bug in multiple files

```
Input: "תקן את כל ה-withOpacity בפרויקט"

Steps:
1. Filesystem:search_files("withOpacity", "lib/")
2. For each file:
   - read_file
   - edit_file: Replace with withValues
3. Memory:add_observation("Migrated all withOpacity → withValues")
4. Report: "✅ תיקנתי 23 קבצים"
5. Ask: "האם לעשות commit?"
```

---

### Workflow 4: Research + Implement

**Scenario:** User asks about new technology

```
Input: "איך מוסיפים push notifications?"

Steps:
1. Brave Search: "Flutter push notifications best practices 2025"
2. Sequential Thinking: Plan implementation
3. Create files:
   - Filesystem:write_file(lib/services/notification_service.dart)
   - Filesystem:edit_file(lib/main.dart) - Initialize service
4. Memory:add_observation("Added push notifications using firebase_messaging")
5. Report with references
```

---

### Workflow 5: Git Operations

**Scenario:** User asks to commit changes

```
Input: "עשה commit לכל השינויים"

Steps:
1. Filesystem:search_files to identify changed files
2. GitHub:push_files with proper commit message
3. Memory:add_observation("Committed: [list changes]")
4. Report: "✅ עשיתי commit עם ההודעה: 'feat: add settings screen'"
```

---

## 🚫 Anti-Patterns - מה לא לעשות

### Anti-Pattern 1: Artifacts Instead of edit_file

```
❌ BAD:
User: "תקן את login_screen.dart"
AI: [Shows 500-line artifact with full file]

✅ GOOD:
User: "תקן את login_screen.dart"
AI: [Uses edit_file for surgical fix]
AI: "✅ תיקנתי את השורות 45-47"
```

---

### Anti-Pattern 2: Over-using Sequential Thinking

```
❌ BAD:
User: "הוסף const ל-SizedBox"
AI: [Sequential Thinking with 10 steps]
AI: "Step 1: Understanding const..."

✅ GOOD:
User: "הוסף const ל-SizedBox"
AI: [Just adds const]
AI: "✅ הוספתי const"
```

---

### Anti-Pattern 3: Searching Web for Project Info

```
❌ BAD:
User: "מה הצבעים של Sticky Notes?"
AI: [Brave Search: "Sticky Notes colors"]

✅ GOOD:
User: "מה הצבעים של Sticky Notes?"
AI: [Reads DESIGN_GUIDE.md]
AI: "הצבעים הם: kStickyYellow, kStickyPink..."
```

---

### Anti-Pattern 4: Creating Memory for Everything

```
❌ BAD:
Memory:create_entity("Today is Tuesday")
Memory:create_entity("User said hello")
Memory:create_entity("It's raining outside")

✅ GOOD:
Memory:create_entity("Repository Pattern is mandatory in Salsheli")
Memory:create_entity("User prefers edit_file over artifacts")
Memory:create_entity("withOpacity is deprecated - always use withValues")
```

---

### Anti-Pattern 5: Auto-Committing Without Permission

```
❌ BAD:
User: "תקן את הבאג"
AI: [Fixes bug]
AI: [Auto-commits to Git]

✅ GOOD:
User: "תקן את הבאג"
AI: [Fixes bug]
AI: "✅ תיקנתי. האם לעשות commit?"
```

---

### Anti-Pattern 6: Reading Files Unnecessarily

```
❌ BAD:
User: "הסבר מה זה Provider"
AI: [Reads all Provider files]
AI: [Explains based on files]

✅ GOOD:
User: "הסבר מה זה Provider"
AI: [Explains from knowledge]
AI: "Provider זה pattern ל-state management..."
```

---

## 🐛 Troubleshooting

### Problem 1: Filesystem Operation Failed

**Symptoms:**
- "Permission denied"
- "File not found"
- "Path not allowed"

**Solutions:**
1. **Check path format:**
   ```
   ✅ C:\projects\salsheli\lib\main.dart
   ❌ lib\main.dart
   ```

2. **Verify file exists:**
   ```
   Use list_directory first
   ```

3. **Check allowed directories:**
   ```
   Use list_allowed_directories
   ```

---

### Problem 2: Memory Not Persisting

**Symptoms:**
- "I don't remember that"
- Information lost between chats

**Solutions:**
1. **Create entity explicitly:**
   ```dart
   Memory:create_entities([{
     name: "Repository Pattern Rule",
     entityType: "Architecture Rule",
     observations: ["Always use Repository, never Firebase directly in screens"]
   }])
   ```

2. **Link to documentation:**
   ```
   "See AI_MASTER_GUIDE.md Part 7.1"
   ```

---

### Problem 3: GitHub Tools Not Working

**Symptoms:**
- "Not authenticated"
- "No remote configured"

**Solutions:**
1. **Check GitHub connection:**
   - Is Claude Desktop connected to GitHub?
   - Are credentials valid?

2. **Check repository state:**
   - Is git initialized?
   - Is remote configured?

3. **Manual fallback:**
   ```
   "אני לא יכול לגשת ל-Git. תוכל לעשות commit ידנית:
   git add .
   git commit -m 'fix: ...'
   git push"
   ```

---

### Problem 4: Web Search Returns Nothing

**Symptoms:**
- Empty results
- No relevant information

**Solutions:**
1. **Refine query:**
   ```
   ❌ "flutter stuff"
   ✅ "Flutter Provider pattern best practices 2025"
   ```

2. **Try different keywords:**
   ```
   Try: "Dart async await", "Flutter state", "Provider example"
   ```

3. **Check if info exists locally:**
   ```
   Maybe it's in DEVELOPER_GUIDE.md?
   ```

---

### Problem 5: Conversation Search Finds Nothing

**Symptoms:**
- "No past conversations found"

**Solutions:**
1. **Check scope:**
   - Only searches current project conversations
   - Different projects = different history

2. **Use better keywords:**
   ```
   ❌ "that thing"
   ✅ "OCR", "receipt scanning", "UserContext"
   ```

3. **Check date range:**
   - Maybe conversation was too long ago?

---

## 🔗 Integration עם מסמכי הפרויקט

### AI_MASTER_GUIDE.md

**Reference this guide for:**
- Tool usage patterns
- When to use which tool
- Anti-patterns to avoid

**AI_MASTER_GUIDE should link here:**
```markdown
## Part 2: Tools & Workflow

**For detailed MCP tools guide:** See MCP_TOOLS_GUIDE.md

**Quick rules:**
- Filesystem:edit_file > artifacts
- Memory for long-term only
- Sequential Thinking for complex problems only
```

---

### DEVELOPER_GUIDE.md

**Add to Git Workflow section:**
```markdown
### Git with MCP Tools

**Manual workflow:**
```bash
git add .
git commit -m "fix: ..."
git push
```

**MCP workflow:**
Just say: "עשה commit עם ההודעה: 'fix: ...'"
→ AI uses GitHub:push_files automatically
```

---

### GETTING_STARTED.md

**Already has MCP section - perfect!**

Keep it as beginner-friendly overview, link to this guide:

```markdown
**📚 רוצה לימוד מעמיק על הכלים?** 
→ ראה MCP_TOOLS_GUIDE.md - מדריך מקיף
```

---

## 📊 Quick Reference Card

### Decision Tree: Which Tool to Use?

```
Question: "What should I do?"
│
├─ Need to read/write file?
│  └─ Use: Filesystem
│
├─ Need to remember long-term?
│  └─ Use: Memory
│
├─ Need to search past conversations?
│  └─ Use: Conversation Search
│
├─ Need to search internet?
│  └─ Use: Brave Search / Web Search
│
├─ Need to do Git operations?
│  └─ Use: GitHub
│
├─ Complex multi-step problem?
│  └─ Use: Sequential Thinking
│
├─ Need to show code example?
│  └─ Use: Artifacts (only if user asks!)
│
├─ Need to run JavaScript?
│  └─ Use: REPL
│
└─ Need deep research?
   └─ Use: Extended Research
```

---

### Tool Priority Matrix

| Situation | 1st Choice | 2nd Choice | Never Use |
|-----------|-----------|-----------|-----------|
| **Fix existing file** | Filesystem:edit_file | - | Artifacts |
| **Create new file** | Filesystem:write_file | - | Artifacts |
| **Find past discussion** | Conversation Search | Memory | Web Search |
| **Architecture decision** | Sequential Thinking | Memory | REPL |
| **Git commit** | GitHub tools | Manual instructions | - |
| **Show example** | Code block | Artifacts (if user asks) | edit_file |
| **Complex calculation** | REPL | - | Sequential Thinking |
| **Search info** | Check docs first | Web Search | Conversation Search |

---

## 🎯 Summary - מהות הכלים

### The Big Picture:

```
1. Filesystem = העבודה היומיומית (90% of tasks)
2. Memory = הזיכרון הארוך (saves time long-term)
3. GitHub = אוטומציה של Git (convenience)
4. Sequential Thinking = פתרון בעיות מורכבות (when needed)
5. Rest = כלי עזר נוספים (nice to have)
```

### Golden Rules:

1. **Default to Filesystem** for file operations
2. **Use Memory** for long-term knowledge only
3. **Ask before Git operations** unless explicitly requested
4. **Don't over-think** simple tasks
5. **Check docs first** before searching web
6. **Prefer edit_file** over artifacts (Salsheli-specific)

---

## 📚 Additional Resources

### Internal Docs:
- **AI_MASTER_GUIDE.md** - AI behavior rules
- **DEVELOPER_GUIDE.md** - Code patterns
- **DESIGN_GUIDE.md** - UI guidelines
- **GETTING_STARTED.md** - Quick start
- **PROJECT_INFO.md** - Project overview

### External Resources:
- [Claude Desktop MCP Docs](https://docs.anthropic.com/en/docs/claude-desktop)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- [Anthropic API Docs](https://docs.anthropic.com/)

---

**גרסה:** 1.0  
**נוצר:** 19/10/2025  
**מטרה:** מדריך מקיף לשימוש נכון בכלי MCP  
**Made with ❤️ by Humans & AI** 👨‍💻🤖
