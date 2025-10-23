For AI agent internal use only – not intended for human reading.

🎯 Purpose

Unifies two key systems:

Mixed lists (Tasks + Products)

User roles and sharing permissions

🧱 Core Model – UnifiedListItem

Type: product | task
Data: each item holds either productData or taskData map.

productData → {quantity, unitPrice, barcode, unit}

taskData → {dueDate, assignedTo, priority}
✅ Allows mixing items freely in one list.
✅ Simple JSON (no polymorphic converter).
✅ Backward-compatible with old ReceiptItem.

🧩 Helpers
productCount → counts only ItemType.product  
taskCount → counts only ItemType.task  
totalAmount → sums all product totalPrice  
isUrgent → true if task due ≤ 3 days

🔄 Migration Strategy

Read all existing shopping_lists.

Convert each ReceiptItem → UnifiedListItem.

Replace items array in Firestore.

Verify totals with totalAmount.

👥 Sharing & Roles

Four permission levels:

Role Can Edit Can Approve Can Manage Users Can Delete
👑 Owner ✅ ✅ ✅ ✅
🔧 Admin ✅ ✅ ❌ ❌
✏️ Editor ⏳ via requests ❌ ❌ ❌
👀 Viewer ❌ ❌ ❌ ❌
📨 Request Workflow

Editor Action: creates PendingRequest (type: add/edit/delete).

Admin/Owner: approve or reject with reason.

Status: pending → approved/rejected.

UI feedback: 🔵 pending / ✅ approved / ❌ rejected.

📦 Firestore Structure
shopping_lists/
{listId}:
items: [UnifiedListItem...]
shared_users: [SharedUser...]
pending_requests: [PendingRequest...]

Indexes

household_id + created_date

household_id + shared_users.user_id

🔐 Security Rules (summary)

Read: owner/admin/editor/viewer

Write: owner/admin

Editors may update only pending_requests

Delete: owner only

🧭 Implementation Phases
Stage Focus Time
Day 1–2 Model + Migration 8h
Day 3–4 Repository Updates 10h
Day 5–6 UI Integration 8h
Day 7 Testing & Deployment 4h
🧩 UX Notes

Editors see “Request Add/Edit/Delete” instead of direct actions.

Owners/Admins see “Approve/Reject” panels.

All list views display mixed tasks & products with distinct colors/icons.

🔗 Cross References

Developer Logic → MEMOZAP_DEVELOPER_GUIDE.md

Firestore Rules → MEMOZAP_SECURITY_AND_RULES.md

Lessons & Errors → MEMOZAP_LESSONS_AND_ERRORS.md
