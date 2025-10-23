For AI agent internal use only – not intended for human reading.

🎯 Purpose

To define the Firestore access model, validation boundaries, and write permissions for all list and sharing operations.

🧱 Core Concepts
Concept Meaning
Owner full control, may delete or reassign list
Admin manage items, approve requests, invite editors
Editor submit requests for approval only
Viewer read-only access
Household Scope all lists tied to household_id for data isolation
📁 Firestore Structure
shopping_lists/
{listId}:
id: string
name: string
household_id: string
created_by: string
created_date: timestamp
updated_date: timestamp
items: [UnifiedListItem...]
shared_users: [SharedUser...]
pending_requests: [PendingRequest...]

🔐 Security Rules (Simplified)
rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
match /shopping_lists/{listId} {
allow read: if request.auth != null && canRead(resource);
allow create: if request.auth != null &&
request.resource.data.created_by == request.auth.uid &&
request.resource.data.household_id == request.auth.token.household_id;
allow update: if request.auth != null && (
canWrite(resource) ||
(hasRole(resource, 'editor') &&
request.resource.data.diff(resource.data).affectedKeys()
.hasOnly(['pending_requests', 'updated_date']))
);
allow delete: if request.auth != null && hasRole(resource, 'owner');
}
}
}

🧩 Helper Logic (internal)

canRead(resource) → true for owner, admin, editor, viewer

canWrite(resource) → true for owner or admin

hasRole(resource, role) → matches shared_users[].role

getUserRole() → resolves from auth.uid or shared_users.user_id

🧠 Agent Behavior

Never attempt to modify rules directly.

When proposing code that writes to Firestore, always ensure:

Writes include updated_date: FieldValue.serverTimestamp().

Editors only modify pending_requests.

Never bypass role validation or simulate admin.

Use mock data only inside test files (test/ folder).

🔗 Cross References

Logic context → MEMOZAP_TASKS_AND_SHARING.md

Repo layer → MEMOZAP_DEVELOPER_GUIDE.md

MCP handling → MEMOZAP_MCP_GUIDE.md
