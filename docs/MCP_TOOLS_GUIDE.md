# 🛠️ MCP Tools Guide - MemoZap

> **MCP tools reference for Claude Desktop**  
> **Updated:** 23/10/2025 | **Version:** 2.1 - Current Installation Status

---

## 🎯 Quick Overview

**MCP (Model Context Protocol)** = Tools that give Claude access to external capabilities.

### Currently Installed (5 Servers):

| Server | Status | Functions | Criticality |
|--------|--------|-----------|-------------|
| **Filesystem** | ✅ Active | 16 functions | 🔴 Critical |
| **Memory** | ✅ Active | 9 functions | 🟡 Important |
| **GitHub** | ⚠️ Needs token | 26 functions | 🟡 Important |
| **Bash** | ✅ Active | 1 function | 🔴 Critical |
| **Sequential Thinking** | ✅ Active | 1 function | 🟡 Important |
| **Brave Search** | ⚠️ Needs API key | 2 functions | 🟢 Optional |

### Additional Built-in Tools:

| Tool | Purpose | Criticality |
|------|---------|-------------|
| **Web Search/Fetch** | Search + fetch pages | 🟢 Optional |
| **Conversation Tools** | Search past conversations (2 tools) | 🟡 Important |

---

## ⚙️ Installation & Setup

### Current Configuration File:

**Location:** `%APPDATA%\Claude\claude_desktop_config.json`

**Currently Installed:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:\\projects\\salsheli"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<YOUR_API_KEY>"
      }
    },
    "bash": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-bash"]
    }
  },
  "isUsingBuiltInNodeForMcp": true,
  "isDxtAutoUpdatesEnabled": true
}
```

### 🔑 API Keys Setup:

#### GitHub Token:
1. Go to: https://github.com/settings/tokens
2. Generate new token (classic)
3. Permissions: `repo`, `read:org`
4. Copy token to config

#### Brave Search API:
1. Go to: https://brave.com/search/api/
2. Sign up (free tier: 2000 queries/month)
3. Copy API key to config

### 💡 Recommended Additional Servers (Free):

#### 1. SQLite Server (Testing & Cache)
```json
"sqlite": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sqlite"]
}
```

#### 2. Fetch Server (Alternative to Brave)
```json
"fetch": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-fetch"]
}
```

#### 3. Puppeteer Server (UI Testing)
```json
"puppeteer": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
}
```

#### 4. Firebase Server (Direct Firestore Access)
```json
"firebase": {
  "command": "npx",
  "args": ["-y", "@firebase/mcp-server-firebase"],
  "env": {
    "GOOGLE_APPLICATION_CREDENTIALS": "C:\\path\\to\\serviceAccountKey.json"
  }
}
```

**Note:** Firebase server is especially useful for MemoZap since the project uses Firebase extensively!

---

## 📖 Tool Details

### 1️⃣ Filesystem - Primary Tool (13 Functions)

**All Available Functions:**

**Reading:**
- `read_file` / `read_text_file` - Read text files
- `read_media_file` - Read images/audio (base64)
- `read_multiple_files` - Batch read multiple files

**Writing:**
- `write_file` - Create/overwrite file
- `create_file` - Create new file
- `edit_file` - Line-based surgical edits
- `str_replace` - Quick string replacement

**Navigation:**
- `list_directory` - List files/folders
- `list_directory_with_sizes` - List with sizes
- `directory_tree` - Recursive tree view
- `view` - View file/directory

**Operations:**
- `search_files` - Find files by pattern
- `move_file` - Move/rename files
- `create_directory` - Create folders
- `get_file_info` - File metadata
- `list_allowed_directories` - Show accessible paths

**Best Practices:**
```
✅ Always use FULL paths: C:\projects\salsheli\lib\main.dart
✅ Prefer edit_file over write_file
✅ Read before editing
✅ Use search_files to find patterns
```

**Example:**
```
User: "Fix login_screen.dart"
→ read_text_file → edit_file → report changes
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

### 5️⃣ GitHub - Git Operations (26 Functions)

**Files & Commits:**
- `create_or_update_file` - Commit single file
- `push_files` - Commit multiple files
- `get_file_contents` - Read file from repo
- `list_commits` - List branch commits

**Repositories:**
- `create_repository` - Create new repo
- `fork_repository` - Fork existing repo
- `search_repositories` - Search GitHub repos

**Branches:**
- `create_branch` - Create new branch

**Issues:**
- `create_issue` - Create issue
- `list_issues` - List issues with filters
- `get_issue` - Get issue details
- `update_issue` - Update existing issue
- `add_issue_comment` - Add comment to issue

**Pull Requests:**
- `create_pull_request` - Create PR
- `get_pull_request` - Get PR details
- `list_pull_requests` - List PRs with filters
- `merge_pull_request` - Merge PR
- `create_pull_request_review` - Create review
- `get_pull_request_files` - Get changed files
- `get_pull_request_status` - Get status checks
- `update_pull_request_branch` - Update PR branch
- `get_pull_request_comments` - Get comments
- `get_pull_request_reviews` - Get reviews

**Search:**
- `search_code` - Search code in repos
- `search_issues` - Search issues/PRs
- `search_users` - Search users

**Best Practices:**
- Confirm before committing
- Use conventional commits: `fix:`, `feat:`, `refactor:`
- Check repo state first

---

### 6️⃣ Bash Tool - Terminal Commands

**Function:** `bash_tool`

**Use for:**
- Running Flutter commands (`flutter run`, `flutter test`)
- Git operations (when GitHub tool isn't suitable)
- Build operations
- File operations (grep, find, etc.)
- Package management (flutter pub get)

**Parameters:**
- `command` - The bash command to execute
- `description` - Why running this command

**Example:**
```dart
bash_tool(
  command: "flutter test",
  description: "Running all unit tests"
)
```

**Best Practices:**
- Always provide clear description
- Check command syntax before running
- Use for automation tasks
- Combine with Filesystem for powerful workflows

**Don't use for:**
- Dangerous operations (rm -rf)
- Long-running processes
- Interactive commands

---

### 7️⃣ Conversation Tools - Past Chats (2 Tools)

**Tool 1: conversation_search**

**Use for:**
- Searching by keywords/topics
- Finding specific discussions
- Locating past decisions

**Parameters:**
- `query` - Search keywords
- `max_results` - Number of results (1-10, default 5)

**Example:**
```
conversation_search(query="Sticky Notes Design")
```

**Tool 2: recent_chats**

**Use for:**
- Getting last N conversations
- Continuing from previous chat
- Time-based retrieval

**Parameters:**
- `n` - Number of chats (1-20, default 3)
- `sort_order` - 'asc' or 'desc' (default 'desc')
- `before` - Get chats before datetime
- `after` - Get chats after datetime

**Example:**
```
recent_chats(n=1)  # Get last conversation
recent_chats(n=10, after="2025-01-01T00:00:00Z")
```

**Trigger phrases:**
- "המשך" - Use recent_chats(n=1)
- "What did we discuss about X" - Use conversation_search
- "Last week's conversations" - Use recent_chats with after/before

---

### 8️⃣ str_replace & view - Quick Tools

**str_replace:**

**Use for:**
- Quick single-string replacement
- When edit_file is overkill
- Simple fixes

**Parameters:**
- `path` - File path
- `old_str` - String to replace (must be unique!)
- `new_str` - Replacement string
- `description` - Why making this edit

**Example:**
```
str_replace(
  path="C:\projects\salsheli\lib\main.dart",
  old_str="withOpacity(0.5)",
  new_str="withValues(alpha: 0.5)",
  description="Fixing deprecated API"
)
```

**view:**

**Use for:**
- Quick file preview
- Viewing specific line range
- Directory listing
- Images

**Parameters:**
- `path` - File/directory path
- `view_range` - Optional [start_line, end_line]
- `description` - Why viewing

**Example:**
```
view(
  path="C:\projects\salsheli\lib\main.dart",
  view_range=[1, 50],
  description="Checking imports section"
)
```

---

### 9️⃣ Uploaded Files - Working with User Uploads

**Location:** `/mnt/user-data/uploads/`

**What are uploaded files?**
- Files the user uploads during conversation
- Can be any type: code, JSON, images, text, etc.
- Some files have their content in context window, some don't

**Files with content in context:**
- `.md`, `.txt`, `.html`, `.csv` (as text)
- `.png`, `.pdf` (as images)

**How to access:**

**Option 1: view tool (recommended)**
```dart
view(
  path="/mnt/user-data/uploads/filename.txt",
  description="Reading uploaded file"
)
```

**Option 2: read_text_file**
```dart
read_text_file(
  path="/mnt/user-data/uploads/filename.txt"
)
```

**Common scenarios:**

1. **VS Code error JSON:**
```json
[{
  "resource": "/C:/projects/...",
  "code": "argument_type_not_assignable",
  "message": "The argument type 'int?' can't be assigned..."
}]
```
- Parse the JSON
- Extract error locations and messages
- Fix the issues in the actual files

2. **Code snippet:**
- Read the uploaded code
- Analyze or fix issues
- Apply changes to project files

3. **Configuration files:**
- Read and understand settings
- Update project configuration accordingly

**Best Practices:**
- Always use `view` tool first for uploaded files
- Check if content is already in context window
- For binary files (images, PDFs), use appropriate handling
- Extract real file paths from error JSONs

**Important Notes:**
- Uploaded files are READ-ONLY in `/mnt/user-data/uploads/`
- To make changes, work on files in `C:\projects\salsheli\`
- Error JSONs often contain full paths to actual project files

---

### 🔟 create_file - Direct File Creation

**Function:** `create_file`

**Use for:**
- Creating new files directly
- When you have complete content ready
- Faster than write_file for new files

**Parameters:**
- `path` - Full file path
- `file_text` - Complete file content
- `description` - Why creating this file (ALWAYS FIRST)

**Example:**
```dart
create_file(
  description="Creating new widget for settings",
  path="C:\projects\salsheli\lib\widgets\settings_widget.dart",
  file_text="""import 'package:flutter/material.dart';

class SettingsWidget extends StatelessWidget {
  // ...
}
"""
)
```

**Best Practices:**
- Always provide description FIRST
- Use for completely new files
- For existing files, use edit_file instead

---

## 🔄 Recommended Workflows

### Workflow 1: Code Review + Fix

```
User sends: C:\projects\salsheli\lib\screens\auth\login_screen.dart

1. Filesystem:read_text_file(login_screen.dart)
2. Analyze (22 comprehensive checks!)
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
2. Read DESIGN_GUIDE.md for Sticky Notes requirements
3. create_file(settings_screen.dart)
4. Filesystem:read_text_file(main.dart)
5. Filesystem:edit_file(main.dart) - Add route
6. Report: "✅ Created settings screen"
7. Ask: "Should I commit?"
```

---

### Workflow 3: Fix Bug Across Multiple Files

```
User: "Fix all withOpacity in project"

1. bash_tool: grep -r "withOpacity" lib/
2. For each file:
   - read_text_file
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

### ❌ Don't: Use write_file for Existing Files

```
Bad:
User: "Fix login_screen.dart"
AI: [Reads file, uses write_file with full content]

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
4. For edit_file: Make sure old_str matches EXACTLY (including emojis, spaces)

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

### Problem 4: Bash Tool with Windows Paths

**Problem:** `grep: C:\projects\... No such file or directory`

**Why:** Bash tool doesn't handle Windows paths well (C:\...)

**Solutions:**
1. Use Filesystem tools instead:
```dart
// ❌ Bad
bash_tool: grep -r "pattern" "C:\projects\salsheli\lib"

// ✅ Good
search_files(
  path="C:\projects\salsheli\lib",
  pattern="pattern"
)
```

2. If you must use bash, convert to Unix path:
```bash
grep -r "pattern" /c/projects/salsheli/lib
```

---

### Problem 5: view Tool Parameter Errors

**Problem:** `Cannot specify both head and tail parameters simultaneously`

**Solutions:**
```dart
// ❌ Bad
view(path="file.dart", head=10, tail=10)

// ✅ Good - Use one or none
view(path="file.dart", view_range=[1, 50])  // Specific range
view(path="file.dart")  // Full file
```

---

### Problem 6: Access Denied - Uploaded Files

**Problem:** `Access denied - path outside allowed directories`

**Why:** Trying to access `/mnt/user-data/uploads/` with wrong tool

**Solutions:**
```dart
// ❌ Bad
read_text_file("C:\mnt\user-data\uploads\file.txt")

// ✅ Good
view("/mnt/user-data/uploads/file.txt")
```

---

### Problem 7: Working with VS Code Error JSON

**Scenario:** User uploads JSON of VS Code errors

**Workflow:**
```
1. view("/mnt/user-data/uploads/errors.json")
2. Parse JSON - extract:
   - resource (file path)
   - startLineNumber
   - message
3. For each error:
   - read_text_file(actual_file_path)
   - Analyze the specific line
   - Fix with edit_file
4. Report all fixes
```

**Example:**
```json
{
  "resource": "/C:/projects/salsheli/lib/screen.dart",
  "startLineNumber": 431,
  "message": "The argument type 'int?' can't be assigned to 'int'"
}
```
→ Go fix line 431 in `C:\projects\salsheli\lib\screen.dart`

---

## 📊 Decision Tree: Which Tool to Use?

```
Need to read project file? → read_text_file / view
Need to read uploaded file? → view (/mnt/user-data/uploads/)
Need to edit existing file? → edit_file
Need to create new file? → create_file
Need quick string replacement? → str_replace
Need to search files? → search_files (not bash grep!)
Need to run command? → bash_tool (careful with Windows paths)
Need to remember long-term? → Memory
Need past conversation by topic? → conversation_search
Need to continue last chat? → recent_chats(n=1)
Need to search internet? → Brave Search / Web Search
Need to do Git operations? → GitHub (26 functions!)
Complex multi-step problem? → Sequential Thinking
Need deep research? → Extended Research
Got VS Code errors? → Parse JSON → Fix actual files
```

---

## 🎯 Tool Priority Matrix

| Situation | 1st Choice | 2nd Choice |
|-----------|-----------|-----------|  
| **Fix existing file** | edit_file | str_replace (simple) |
| **Create new file** | create_file | write_file |
| **Quick preview** | view | read_text_file |
| **Find past discussion** | conversation_search | recent_chats |
| **Continue last chat** | recent_chats(n=1) | - |
| **Architecture decision** | Sequential Thinking | Memory |
| **Git commit** | GitHub:push_files | bash_tool |
| **Run Flutter commands** | bash_tool | Manual instructions |
| **Search project files** | search_files | read_multiple_files |
| **Read uploaded file** | view (/mnt/user-data/uploads/) | - |
| **Fix VS Code errors** | Parse JSON → edit_file | - |

---

## 🎯 Summary

### The Big Picture:

```
1. Filesystem = Daily work (70% of tasks)
   - 16 functions for every file need!
   - Includes uploaded files handling
2. Bash = Commands + automation (15%)
   - ⚠️ Limited on Windows paths
3. GitHub = Git operations (26 functions!)
4. Memory = Long-term knowledge
5. Conversation = Past discussions (2 tools)
6. Sequential Thinking = Complex problems
7. Uploaded Files = /mnt/user-data/uploads/
8. Rest = Helper tools
```

### Golden Rules:

1. **Default to Filesystem** for file operations
2. **Use bash_tool** for commands and automation
3. **Combine tools** - bash + Filesystem = powerful!
4. **Use Memory** for long-term knowledge only
5. **Ask before Git operations** unless explicitly requested
6. **Don't over-think** simple tasks
7. **Check docs first** before searching web
8. **Prefer edit_file** over write_file (MemoZap-specific)
9. **Use recent_chats(n=1)** when user writes "המשך"
10. **Always read before edit** - avoid "exact match" errors
11. **Use view for uploaded files** - /mnt/user-data/uploads/
12. **Avoid bash for Windows paths** - use Filesystem tools instead
13. **Parse VS Code errors** - extract real file paths and fix

---

## 📚 Related Docs

- **AI_MASTER_GUIDE.md** - AI behavior rules
- **DEVELOPER_GUIDE.md** - Code patterns
- **DESIGN_GUIDE.md** - UI guidelines
- **PROJECT_INFO.md** - Project overview

---

**Version:** 2.2  
**Created:** 19/10/2025 | **Updated:** 24/10/2025  
**Purpose:** Complete MCP tools reference - current installation + recommendations

---

## 📝 Changelog

### v2.2 - 24/10/2025 🆕 **LATEST - Uploaded Files & Troubleshooting**
- ✅ Added section 9: Uploaded Files handling
- ✅ Enhanced Troubleshooting with 4 new problems:
  - Problem 4: Bash tool with Windows paths
  - Problem 5: view tool parameter errors
  - Problem 6: Access denied on uploaded files
  - Problem 7: Working with VS Code error JSON
- ✅ Updated Decision Tree with uploaded files
- ✅ Updated Tool Priority Matrix
- ✅ Updated Golden Rules (3 new rules)
- 💡 Real-world learnings from actual debugging session

### v2.1 - 23/10/2025
- ✅ Added "Installation & Setup" section
- ✅ Documented current server configuration
- ✅ Added API keys setup instructions
- ✅ Added recommended additional servers (SQLite, Fetch, Puppeteer, Firebase)
- ✅ Updated status table with current installation

### v2.0 - 22/10/2025
- ✅ Complete tool documentation
- ✅ All 8 core tools + functions documented
