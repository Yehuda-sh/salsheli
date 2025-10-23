For AI agent internal use only – not intended for human reading.

🎯 Purpose

To store recurring mistakes, misunderstandings, or failed operations, so the AI agent won’t repeat them.

⚠️ Common Errors & Fix Patterns
Type Symptom Root Cause How to Avoid
Path Confusion “file not found” relative paths or missing drive prefix Always use full path → C:\projects\salsheli\...
Encoding strange characters in Hebrew file saved in ANSI Force UTF-8 on every read/write
Code Merge “partial content edited” missing brackets or emojis in diff Read full block before editing
Overwriting “lost previous context” agent rewrote unrelated sections Confirm file scope before apply
Duplicate Responses repeated summary agent re-summarized already included data Check if summary already exists
Memory Drift conflicting versions too many parallel summaries Update only core docs, not local drafts
🧩 Recovery Flow

Log issue in this file under “Lessons”.

Add fix note in the relevant doc (DEVELOPER_GUIDE.md, MCP_GUIDE.md, etc.).

Retry once with clean state.

Mark as ✅ Resolved once confirmed working.

🗒️ Example Log

# Lesson 17 – File Edit Failure

Cause: missing line breaks between emoji blocks.
Fix: normalize text spacing before diff.
Status: ✅ resolved.

🔗 Cross References

Tool behavior → MEMOZAP_MCP_GUIDE.md

Developer patterns → MEMOZAP_DEVELOPER_GUIDE.md

Error context → MEMOZAP_CORE_GUIDE.md
