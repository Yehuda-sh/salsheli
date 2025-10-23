For AI agent internal use only – not intended for human reading.

⚙️ Purpose

Defines the core development standards for all agents working with the MemoZap project.
Focus: clarity, consistency, and maintainability of Flutter/Dart code.

🧩 Architecture Principles

Provider Pattern – every stateful module uses ChangeNotifier.

Must include addListener() and removeListener() in lifecycle.

init() and dispose() required in all Providers.

Repository Layer – centralizes data logic.

CRUD methods only.

Use async/await with error handling.

Model Layer – must be JSON serializable (json_serializable).

No direct UI logic in models.

State Management – minimal dependencies, prefer provider or riverpod.

Error Recovery – all async calls must support retry() and clearAll() helpers.

🪵 Logging Rules

Always include emoji prefix for quick visual scanning.

✅ Success

⚠️ Warning

❌ Error

Use short one-line logs:

log("✅ User added successfully [UserContext]");

Do not log sensitive data.

🔄 CRUD Flow Template

Create – Validate → Call Repository → Update state → Log success.

Read – Always from Repository (no direct DB access).

Update – Rebuild UI only if change detected.

Delete – Soft delete if possible, confirm with user flow.

🧠 Error Handling Pattern
try → catch(e) → log("❌ [file] [method] $e") → recovery()

If recovery fails twice → add to MEMOZAP_LESSONS_AND_ERRORS.md.

📚 Testing Standard

Unit tests for Providers and Repositories.

Widget tests for critical UI flows (create, update, delete).

No tests should depend on actual internet or live DB.

🔗 Cross References

UI/UX → MEMOZAP_DESIGN_GUIDE.md

Tasks & Sharing Logic → MEMOZAP_TASKS_AND_SHARING.md

Error Tracking → MEMOZAP_LESSONS_AND_ERRORS.md
