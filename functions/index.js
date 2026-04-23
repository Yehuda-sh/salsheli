/**
 * Firebase Cloud Functions for MemoZap
 *
 * Functions:
 * 1. onUserDeleted — GDPR: cascading data deletion when user deletes account
 *
 * Deploy: firebase deploy --only functions
 */

const { onDocumentDeleted, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
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
 * - private_lists subcollection (personal shopping lists)
 * - inventory subcollection (personal pantry items)
 * - shopping_patterns (top-level)
 * - pending_invites (sent by user, top-level)
 * - household membership (members subcollection)
 * - shared_users references in shared_lists (collectionGroup)
 */
exports.onUserDeleted = onDocumentDeleted("users/{userId}", async (event) => {
  const userId = event.params.userId;
  const userData = event.data?.data();
  const householdId = userData?.household_id;

  console.log(`🗑️ GDPR: Starting cascading delete for user ${userId}`);

  const results = {
    notifications: 0,
    contacts: 0,
    privateLists: 0,
    inventory: 0,
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

    // 2b. Delete private_lists subcollection (personal shopping lists)
    results.privateLists = await deleteSubcollection(
      `users/${userId}/private_lists`
    );

    // 2c. Delete personal inventory subcollection (pantry items)
    results.inventory = await deleteSubcollection(
      `users/${userId}/inventory`
    );

    // 3. Delete shopping patterns (chunked for 500 batch limit)
    const patternsSnap = await db
      .collection("shopping_patterns")
      .where("userId", "==", userId)
      .get();
    for (let i = 0; i < patternsSnap.docs.length; i += 500) {
      const batch = db.batch();
      patternsSnap.docs.slice(i, i + 500).forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
    results.patterns = patternsSnap.docs.length;

    // 4. Delete pending invites sent by this user (chunked for 500 batch limit)
    const invitesSnap = await db
      .collection("pending_invites")
      .where("requester_id", "==", userId)
      .get();
    for (let i = 0; i < invitesSnap.docs.length; i += 500) {
      const batch = db.batch();
      invitesSnap.docs.slice(i, i + 500).forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
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

    // 6. Remove user from shared_users in shared_lists.
    // Scoped to user's household first, then check cross-household shares.
    if (householdId) {
      const householdListsSnap = await db
        .collection("households")
        .doc(householdId)
        .collection("shared_lists")
        .get();
      for (const doc of householdListsSnap.docs) {
        const sharedUsers = doc.data().shared_users;
        if (sharedUsers && sharedUsers[userId] !== undefined) {
          await doc.ref.update({
            [`shared_users.${userId}`]: FieldValue.delete(),
          });
          results.sharedLists++;
        }
      }
    }

    // 7. Delete user's personal templates
    const templatesSnap = await db
      .collection("templates")
      .where("user_id", "==", userId)
      .get();
    for (let i = 0; i < templatesSnap.docs.length; i += 500) {
      const batch = db.batch();
      templatesSnap.docs.slice(i, i + 500).forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
    results.templates = templatesSnap.docs.length;

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

// ============================================================
// Push Notifications: Send FCM on new in-app notification
// ============================================================

/**
 * When a new notification document is created in
 * /users/{userId}/notifications/{notificationId},
 * send a push notification via FCM to the user's device.
 */
exports.onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const userId = event.params.userId;
    const notification = event.data?.data();

    if (!notification) return;

    try {
      // Get the user's FCM token
      const userDoc = await db.collection("users").doc(userId).get();
      const fcmToken = userDoc.data()?.fcm_token;

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}, skipping push`);
        return;
      }

      // Send push notification
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: notification.title || "MemoZap",
          body: notification.message || "",
        },
        data: {
          type: notification.type || "general",
          notificationId: event.params.notificationId,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "memozap_default",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      });

      console.log(`📱 Push sent to ${userId}: ${notification.title}`);
    } catch (error) {
      // Token may be invalid/expired — clean it up
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        console.log(`🧹 Cleaning stale FCM token for ${userId}`);
        await db.collection("users").doc(userId).update({
          fcm_token: FieldValue.delete(),
        });
      } else {
        console.error(`❌ Push error for ${userId}:`, error);
      }
    }
  }
);
