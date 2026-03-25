/**
 * Firebase Cloud Functions for MemoZap
 *
 * Functions:
 * 1. onUserDeleted — GDPR: cascading data deletion when user deletes account
 *
 * Deploy: firebase deploy --only functions
 */

const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { initializeApp } = require("firebase-admin/app");

initializeApp();
const db = getFirestore();

// ============================================================
// GDPR: Cascading data deletion on account delete
// ============================================================

/**
 * When a user document is deleted from /users/{userId},
 * cascade delete all their data across collections:
 * - notifications subcollection
 * - saved_contacts subcollection
 * - shopping_patterns
 * - pending_invites (sent by user)
 * - household membership
 * - shared_users references in shopping_lists
 * - inventory items (if personal pantry)
 */
exports.onUserDeleted = onDocumentDeleted("users/{userId}", async (event) => {
  const userId = event.params.userId;
  const userData = event.data?.data();
  const householdId = userData?.household_id;

  console.log(`🗑️ GDPR: Starting cascading delete for user ${userId}`);

  const results = {
    notifications: 0,
    contacts: 0,
    patterns: 0,
    invites: 0,
    household: false,
    sharedLists: 0,
  };

  try {
    // 1. Delete notifications subcollection
    results.notifications = await deleteSubcollection(
      `users/${userId}/notifications`
    );

    // 2. Delete saved_contacts subcollection
    results.contacts = await deleteSubcollection(
      `users/${userId}/saved_contacts`
    );

    // 3. Delete shopping patterns
    const patternsSnap = await db
      .collection("shopping_patterns")
      .where("userId", "==", userId)
      .get();
    const patternsBatch = db.batch();
    patternsSnap.docs.forEach((doc) => patternsBatch.delete(doc.ref));
    if (patternsSnap.docs.length > 0) await patternsBatch.commit();
    results.patterns = patternsSnap.docs.length;

    // 4. Delete pending invites sent by this user
    const invitesSnap = await db
      .collection("pending_invites")
      .where("requester_id", "==", userId)
      .get();
    const invitesBatch = db.batch();
    invitesSnap.docs.forEach((doc) => invitesBatch.delete(doc.ref));
    if (invitesSnap.docs.length > 0) await invitesBatch.commit();
    results.invites = invitesSnap.docs.length;

    // 5. Remove from household members
    if (householdId) {
      const memberRef = db
        .collection("households")
        .doc(householdId)
        .collection("members")
        .doc(userId);
      await memberRef.delete();
      results.household = true;

      // Check if household is now empty → delete it
      const remainingMembers = await db
        .collection("households")
        .doc(householdId)
        .collection("members")
        .limit(1)
        .get();
      if (remainingMembers.empty) {
        await db.collection("households").doc(householdId).delete();
        console.log(`🏠 Deleted empty household ${householdId}`);
      }
    }

    // 6. Remove user from shared_users in shopping_lists
    const sharedListsSnap = await db
      .collection("shopping_lists")
      .where(`shared_users.${userId}`, "!=", null)
      .get();
    for (const doc of sharedListsSnap.docs) {
      await doc.ref.update({
        [`shared_users.${userId}`]: FieldValue.delete(),
      });
      results.sharedLists++;
    }

    console.log(`✅ GDPR: Cascade delete complete for ${userId}:`, results);
  } catch (error) {
    console.error(`❌ GDPR: Error during cascade delete for ${userId}:`, error);
    // Don't throw — this is a background function, errors are logged
  }
});

// ============================================================
// Helper: Delete all documents in a subcollection
// ============================================================

async function deleteSubcollection(path) {
  const snap = await db.collection(path).get();
  if (snap.empty) return 0;

  // Firestore batch limit is 500
  const batchSize = 500;
  let deleted = 0;

  for (let i = 0; i < snap.docs.length; i += batchSize) {
    const batch = db.batch();
    const chunk = snap.docs.slice(i, i + batchSize);
    chunk.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    deleted += chunk.length;
  }

  return deleted;
}
