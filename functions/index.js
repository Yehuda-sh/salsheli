/**
 * Firebase Cloud Functions for MemoZap
 *
 * Functions:
 * 1. onUserDeleted — GDPR: cascading data deletion when user deletes account
 * 2. onNotificationCreated — FCM Push Notifications trigger
 *
 * Deploy: firebase deploy --only functions
 */

const {
  onDocumentDeleted,
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");
const {
  getFirestore,
  FieldValue,
  FieldPath,
} = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");

initializeApp();
const db = getFirestore();

// ============================================================
// GDPR: Cascading data deletion on account delete
// ============================================================

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
    // 1-2. Delete user's isolated subcollections
    results.notifications = await deleteSubcollection(
      `users/${userId}/notifications`,
    );
    results.contacts = await deleteSubcollection(
      `users/${userId}/saved_contacts`,
    );
    results.privateLists = await deleteSubcollection(
      `users/${userId}/private_lists`,
    );
    results.inventory = await deleteSubcollection(`users/${userId}/inventory`);

    // 3. Delete shopping patterns (using safe batch chunks)
    results.patterns = await deleteQueryBatch(
      db.collection("shopping_patterns").where("userId", "==", userId),
    );

    // 4. Delete pending invites sent by this user
    results.invites = await deleteQueryBatch(
      db.collection("pending_invites").where("requester_id", "==", userId),
    );

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

    // 6. Remove user from shared_users in all shared_lists subcollections.
    // OPTIMIZATION: Using orderBy on a FieldPath leverages Firestore's built-in
    // index to return ONLY documents where this map key exists, avoiding a full DB scan.
    const sharedListsSnap = await db
      .collectionGroup("shared_lists")
      .orderBy(new FieldPath("shared_users", userId))
      .get();

    if (!sharedListsSnap.empty) {
      let batch = db.batch();
      let count = 0;
      const batches = [];

      sharedListsSnap.docs.forEach((doc) => {
        batch.update(doc.ref, {
          [`shared_users.${userId}`]: FieldValue.delete(),
        });
        count++;

        if (count === 500) {
          batches.push(batch.commit());
          batch = db.batch();
          count = 0;
        }
      });

      if (count > 0) batches.push(batch.commit());
      await Promise.all(batches);
      results.sharedLists = sharedListsSnap.docs.length;
    }

    console.log(`✅ GDPR: Cascade delete complete for ${userId}:`, results);
  } catch (error) {
    console.error(`❌ GDPR: Error during cascade delete for ${userId}:`, error);
  }
});

// ============================================================
// Helpers: Delete Batches and Subcollections (Safe <500 limits)
// ============================================================

async function deleteQueryBatch(query) {
  const snap = await query.get();
  if (snap.empty) return 0;

  const batches = [];
  let batch = db.batch();
  let count = 0;

  snap.docs.forEach((doc) => {
    batch.delete(doc.ref);
    count++;
    if (count === 500) {
      batches.push(batch.commit());
      batch = db.batch();
      count = 0;
    }
  });

  if (count > 0) batches.push(batch.commit());
  await Promise.all(batches);

  return snap.docs.length;
}

async function deleteSubcollection(path) {
  return await deleteQueryBatch(db.collection(path));
}

// ============================================================
// Push Notifications: Send FCM on new in-app notification
// ============================================================

/**
 * Notification type → user-preference field on the user doc.
 *
 * Mirrors the 4 toggles in settings_screen.dart. When a user turns a
 * group off, every type bound to that group is suppressed at the server
 * — the client never sees a push it can't filter out.
 *
 * Types missing from the map (or `unknown`) default to "always send" —
 * a fail-open posture so we never silently drop a notification because
 * someone added a new type but forgot to wire the mapping. (Spam is
 * recoverable; a missed invite is not.)
 */
const NOTIFICATION_TYPE_TO_PREF = {
  // Group membership / household lifecycle
  invite: "notify_group",
  request_approved: "notify_group",
  request_rejected: "notify_group",
  role_changed: "notify_group",
  user_removed: "notify_group",
  member_left: "notify_group",
  // Pantry reminders
  low_stock: "notify_reminders",
  expiry_expired: "notify_reminders",
  expiry_soon: "notify_reminders",
};

exports.onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const userId = event.params.userId;
    const notification = event.data?.data();

    if (!notification) return;

    try {
      // Get the user's FCM token + notification preferences in one read.
      const userDoc = await db.collection("users").doc(userId).get();
      const userData = userDoc.data() || {};
      const fcmToken = userData.fcm_token;

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}, skipping push`);
        return;
      }

      // ✋ Preference gate — skip push if the user has the matching toggle off.
      // Missing field == undefined → treated as "enabled" (backward compat
      // for users who haven't visited the settings screen yet).
      const prefField = NOTIFICATION_TYPE_TO_PREF[notification.type];
      if (prefField && userData[prefField] === false) {
        console.log(
          `🔕 Push suppressed for ${userId} (type=${notification.type}, ` +
            `pref=${prefField}=false)`,
        );
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
  },
);
