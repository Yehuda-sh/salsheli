# 📘 LESSONS_LEARNED - MemoZap

> **Updated:** 23/10/2025  
> **Purpose:** Internal AI reference — mistakes to avoid and refined best practices.  
> **Context:** Project path → `C:\projects\salsheli\`

---

## 🔧 Code & Logic Patterns

### 1️⃣ File Editing

- ❌ Edited files without verifying original string → “no match” errors.  
  ✅ Always `read_text_file` → confirm → then `edit_file`.
- ❌ Used relative paths.  
  ✅ Always use **full Windows path** (e.g., `C:\projects\salsheli\lib\main.dart`).
- ❌ Overused `write_file` instead of `edit_file`.  
  ✅ Only use `edit_file` for surgical changes.

### 2️⃣ MCP & Terminal

- ❌ Tried `grep` with Windows path → failed (`ENOENT`).  
  ✅ Use `search_files` instead of `bash_tool` for search operations.
- ❌ Overreliance on Bash for short tasks.  
  ✅ Prefer Filesystem tools unless automation needed.

### 3️⃣ Project Logic

- ❌ Forgot to migrate data when changing repository pattern.  
  ✅ Always create `migrate_*` script in `scripts/`.
- ❌ Suggested logic outside MemoZap scope (e.g., receipt scanning).  
  ✅ Keep focus on pantry, shopping lists, tasks, and smart suggestions.

---

## 🎨 UI/UX & Structure

### 1️⃣ Hebrew & RTL

- ❌ Ignored RTL layout.  
  ✅ All UI text → align right + test with Hebrew labels.

### 2️⃣ Sticky Notes Design System

- ❌ Suggested random UI elements.  
  ✅ Always reference `DESIGN_GUIDE.md`.

### 3️⃣ User Flow

- ❌ Focused on features before UI skeleton.  
  ✅ Build UI first → then connect logic.

---

## 💬 Communication

### 1️⃣ With User

- ❌ Provided long code blocks.  
  ✅ Explain in **text**, simple Hebrew, real project context.
- ❌ Too many tokens → redundant phrasing.  
  ✅ Keep concise; one clear summary per topic.

### 2️⃣ With Other AI Agents

- ❌ Missing shared memory for past issues.  
  ✅ Store lessons here, and update on each fix.

---

## 🧠 Meta Rules

| Keyword           | Meaning                                        |
| ----------------- | ---------------------------------------------- |
| **"תבונות"**      | Trigger to recall this file and apply lessons. |
| **"בדיקה חוזרת"** | Re-run same analysis, avoiding prior errors.   |
| **"שגיאה חוזרת"** | Append to this file under relevant section.    |

---

**Next Review:** 30/10/2025  
**Maintainer:** AI System (Claude + GPT)  
**Location:** `C:\projects\salsheli\docs\LESSONS_LEARNED.md`
