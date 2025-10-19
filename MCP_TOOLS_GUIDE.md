# 🛠️ MCP Tools Guide - Salsheli

> **MCP tools reference for Claude Desktop**  
> **Updated:** 19/10/2025 | **Version:** 1.2 - Cleaned & Optimized

---

## 🎯 Quick Overview

**MCP (Model Context Protocol)** = Tools that give Claude access to external capabilities.

### The 11 Tools:

| Tool | Purpose | Criticality |
|------|---------|-------------|
| **Filesystem** | Read/write/edit files | 🔴 Critical |
| **Memory** | Long-term memory | 🟡 Important |
| **Brave Search** | Internet search | 🟢 Optional |
| **Sequential Thinking** | Complex problem solving | 🟡 Important |
| **GitHub** | Git operations | 🟡 Important |
| **REPL** | Run JavaScript | 🟢 Optional |
| **Web Search/Fetch** | Search + fetch pages | 🟢 Optional |
| **Conversation Search** | Search past conversations | 🟡 Important |
| **Artifacts** | Display code/content | 🟢 Optional |
| **Extended Research** | Deep research | 🟢 Optional |
| **Windows MCP** | Windows UI interaction | 🟡 Important |

---

## 📖 Tool Details

### 1️⃣ Filesystem - Primary Tool

**Use for:**
- Reading files
- Editing existing files
- Creating new files
- Searching for patterns

**Best Practices:**
```
✅ Always use FULL paths: C:\projects\salsheli\lib\main.dart
✅ Prefer edit_file over write_file
✅ Read before editing
```

**Example:**
```
User: "Fix login_screen.dart"
→ read_file → edit_file → report changes
```

---

### 2️⃣ Memory - Long-Term Storage

**Use for:**
- Architectural decisions
- User preferences
- Project-specific rules
- Common mistakes to avoid

**Don't use for:**
- Temporary conversation state
- Info already in documentation
- One-time facts

**Example:**
```
"Remember: User prefers Filesystem:edit_file over artifacts"
"Remember: Always use Repository Pattern, never Firebase directly"
```

---

### 3️⃣ Search Tools - Internet Access

**Brave Search / Web Search / Web Fetch**

**Use for:**
- Finding packages
- Error solutions
- Current events (if relevant)
- API documentation

**Don't use for:**
- Info in project docs
- Code that exists in project
- General knowledge Claude has

---

### 4️⃣ Sequential Thinking - Problem Solving

**Use for:**
- Complex bugs
- Architecture decisions
- Performance issues
- Multi-step migrations

**Don't use for:**
- Simple fixes
- Well-documented solutions
- One-liner answers

---

### 5️⃣ GitHub - Git Operations

**Tools:**
- `create_or_update_file` - Commit single file
- `push_files` - Commit multiple files
- `create_branch` - New branch
- `create_pull_request` - New PR

**Best Practices:**
- Confirm before committing
- Use conventional commits: `fix:`, `feat:`, `refactor:`
- Check repo state first

---

### 6️⃣ REPL - JavaScript Execution

**Use for:**
- Complex calculations
- CSV/Excel analysis (large files)
- Data transformations

**Don't use for:**
- Simple math
- Dart/Flutter code
- File operations

---

### 7️⃣ Conversation Search - Past Chats

**Use for:**
- User references past conversations
- Finding decisions
- Locating past code

**Trigger phrases:**
- "What did we discuss about..."
- "In the previous conversation..."
- "Continue with..."

---

### 8️⃣ Artifacts - Code Display

**Use for:**
- User explicitly asks for example
- Interactive demos
- Complete examples

**Don't use for (Salsheli!):**
- Fixing existing files (use edit_file instead!)
- User didn't ask for example

---

### 9️⃣ Windows MCP - UI Interaction

**14 Internal Tools:**

**Category 1: Launch Apps**
- `Launch-Tool` - Open application
- `Powershell-Tool` - Run commands
- `Switch-Tool` - Switch windows

**Category 2: Info & Display**
- `State-Tool` - Screenshot + window list
- `Scrape-Tool` - Read webpage

**Category 3: Basic Actions**
- `Click-Tool` - Mouse click
- `Type-Tool` - Keyboard input
- `Clipboard-Tool` - Copy/paste
- `Scroll-Tool` - Scroll
- `Drag-Tool` - Drag & drop
- `Move-Tool` - Move mouse

**Category 4: Keyboard**
- `Shortcut-Tool` - Keyboard shortcuts
- `Key-Tool` - Single keys
- `Wait-Tool` - Wait/pause

**Use for:**
- UI testing
- Running Flutter commands
- Taking screenshots
- Copying errors
- Automated testing

**Don't use for:**
- Editing code (use Filesystem instead!)
- Dangerous operations
- Long repetitive tasks
- File operations

**Best combo:** Windows MCP + Filesystem!
```
1. State-Tool → See the bug
2. Filesystem:edit_file → Fix the code
3. Powershell: flutter hot reload
4. State-Tool → Verify fix
```

---

## 🔄 Recommended Workflows

### Workflow 1: Code Review + Fix

```
User sends: C:\projects\salsheli\lib\screens\auth\login_screen.dart

1. Filesystem:read_file(login_screen.dart)
2. Analyze (13 checks)
3. If critical issues → Filesystem:edit_file
4. If minor issues → Report + Ask
5. Memory:add_observation("Fixed withOpacity in login_screen")
6. Provide quality score (X/100)
```

---

### Workflow 2: Create New Screen

```
User: "Create settings screen"

1. Sequential Thinking: Plan structure
2. Memory:search("Sticky Notes Design requirements")
3. Filesystem:write_file(settings_screen.dart)
4. Filesystem:read_file(main.dart)
5. Filesystem:edit_file(main.dart) - Add route
6. Report: "✅ Created settings screen"
7. Ask: "Should I commit?"
```

---

### Workflow 3: Fix Bug Across Multiple Files

```
User: "Fix all withOpacity in project"

1. Filesystem:search_files("withOpacity", "lib/")
2. For each file:
   - read_file
   - edit_file: Replace with withValues
3. Memory:add_observation("Migrated all withOpacity → withValues")
4. Report: "✅ Fixed 23 files"
5. Ask: "Should I commit?"
```

---

### Workflow 4: Git Operations

```
User: "Commit all changes"

1. Filesystem:search_files to identify changed files
2. GitHub:push_files with proper commit message
3. Memory:add_observation("Committed: [list changes]")
4. Report: "✅ Committed: 'feat: add settings screen'"
```

---

## 🚫 Anti-Patterns

### ❌ Don't: Use Artifacts Instead of edit_file

```
Bad:
User: "Fix login_screen.dart"
AI: [Shows 500-line artifact]

Good:
User: "Fix login_screen.dart"
AI: [Uses edit_file for surgical fix]
```

---

### ❌ Don't: Over-use Sequential Thinking

```
Bad:
User: "Add const to SizedBox"
AI: [Sequential Thinking with 10 steps]

Good:
User: "Add const to SizedBox"
AI: [Just adds const]
```

---

### ❌ Don't: Search Web for Project Info

```
Bad:
User: "What are Sticky Notes colors?"
AI: [Brave Search]

Good:
User: "What are Sticky Notes colors?"
AI: [Reads DESIGN_GUIDE.md]
```

---

### ❌ Don't: Create Memory for Everything

```
Bad:
Memory:create_entity("Today is Tuesday")
Memory:create_entity("User said hello")

Good:
Memory:create_entity("Repository Pattern is mandatory")
Memory:create_entity("User prefers edit_file over artifacts")
```

---

### ❌ Don't: Auto-Commit Without Permission

```
Bad:
User: "Fix the bug"
AI: [Fixes bug]
AI: [Auto-commits to Git]

Good:
User: "Fix the bug"
AI: [Fixes bug]
AI: "✅ Fixed. Should I commit?"
```

---

## 🐛 Troubleshooting

### Problem 1: Filesystem Operation Failed

**Solutions:**
1. Check path format: `C:\projects\salsheli\lib\main.dart`
2. Verify file exists: Use list_directory first
3. Check allowed directories: Use list_allowed_directories

---

### Problem 2: Memory Not Persisting

**Solutions:**
1. Create entity explicitly with Memory:create_entities
2. Link to documentation: "See AI_MASTER_GUIDE.md Part 7.1"

---

### Problem 3: GitHub Tools Not Working

**Solutions:**
1. Check GitHub connection in Claude Desktop
2. Check repository state: Is git initialized?
3. Manual fallback: Provide git commands

---

## 📊 Decision Tree: Which Tool to Use?

```
Need to read/write file? → Filesystem
Need to remember long-term? → Memory
Need to search past conversations? → Conversation Search
Need to search internet? → Brave Search / Web Search
Need to do Git operations? → GitHub
Complex multi-step problem? → Sequential Thinking
Need to show code example? → Artifacts (only if user asks!)
Need to run JavaScript? → REPL
Need to test UI / run commands? → Windows MCP
Need deep research? → Extended Research
```

---

## 🎯 Tool Priority Matrix

| Situation | 1st Choice | 2nd Choice |
|-----------|-----------|-----------|
| **Fix existing file** | Filesystem:edit_file | - |
| **Create new file** | Filesystem:write_file | - |
| **Find past discussion** | Conversation Search | Memory |
| **Architecture decision** | Sequential Thinking | Memory |
| **Git commit** | GitHub tools | Manual instructions |
| **Show example** | Code block | Artifacts (if user asks) |
| **UI testing** | Windows MCP | - |
| **Run Flutter commands** | Windows MCP | Manual terminal |

---

## 🎯 Summary

### The Big Picture:

```
1. Filesystem = Daily work (80% of tasks)
2. Windows MCP = UI testing + commands (10%)
3. Memory = Long-term knowledge
4. GitHub = Git automation
5. Sequential Thinking = Complex problems
6. Rest = Helper tools
```

### Golden Rules:

1. **Default to Filesystem** for file operations
2. **Use Windows MCP** for UI testing and commands
3. **Combine tools** - Windows MCP + Filesystem = powerful!
4. **Use Memory** for long-term knowledge only
5. **Ask before Git operations** unless explicitly requested
6. **Don't over-think** simple tasks
7. **Check docs first** before searching web
8. **Prefer edit_file** over artifacts (Salsheli-specific)

---

## 📚 Related Docs

- **AI_MASTER_GUIDE.md** - AI behavior rules
- **DEVELOPER_GUIDE.md** - Code patterns
- **DESIGN_GUIDE.md** - UI guidelines
- **PROJECT_INFO.md** - Project overview

---

**Version:** 1.2  
**Created:** 19/10/2025 | **Updated:** 19/10/2025  
**Purpose:** MCP tools reference for Claude Desktop
