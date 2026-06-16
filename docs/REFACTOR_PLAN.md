# 📋 תוכנית — MemoZap: מקוד לחנות

> נוצר: 8 מרץ 2026 · עודכן: יוני 2026 (כווץ + יושר למיקוד-סופר)
> מטרה: **אפליקציה מוכנה להפצה ב-App Store + Google Play**
>
> 🧭 **מקור אמת:** [PRODUCT_DIRECTION.md](PRODUCT_DIRECTION.md). פריטי "הושלם" שכבר לא תקפים אחרי המיקוד-לסופר: "Editor approval flow (PendingRequests)" ו-"מי מביא?" → **נחתכים**; "NotebookBackground ב-21/21" → מתרכך ל"נייר רגוע".
>
> 📜 פירוט מלא של מה שבוצע בכל פאזה — ב-`git log`. כאן רק **סטטוס + מה שנשאר**.

---

## 📊 סטטוס כללי

| פאזה | תיאור | סטטוס | סיכום |
|------|--------|--------|-------|
| 1 | ניקוי ויציבות | ✅ | מחיקת קוד מת (-6,530 ש'), 852 prints, l10n cleanup, הסרת onboarding flow |
| 2 | מערכת עיצוב | ✅ | Design tokens, Colors→theme (316→0), typography, border radius, widgets משותפים |
| 3 | איחוד סגנון + ריפקטור | 🟡 חלקי | code review מלא בוצע; פיצול קבצים גדולים נשאר (ראה למטה) |
| 4 | ליטוש UX | ✅ | page transitions, welcome redesign, dashboard, pantry, settings, history, scanner |
| 5 | הכנה ל-Store | 🟡 חלקי | package name, Firebase, privacy, demo data, rules v4.5 — נשאר keystore/icons/screenshots |
| 6 | Push Notifications (FCM) | ⬜ | טרם התחיל — **אפשר להשיק בלי** (ראה פירוט למטה) |
| 6.5 | ניהול הבית | ✅ | בית/תפקידים/הזמנות/sync (חלק נחתך אחרי המיקוד) |
| 6.6 | יומן פעילות | ✅ | model→service→repo→provider→UI, 8 injection points, 9 סוגי אירועים |
| 6.7–6.8 | UX polish + Screen review | ✅ | a11y sweep + 12-category review per screen (ראה REVIEW_BACKLOG) |
| 7 | מוניטיזציה | ⬜ | Post-launch — google_mobile_ads |
| 8 | בדיקות | ✅ | 478 unit tests (hand-written mocks); widget/integration — post-launch |
| 9 | i18n + נגישות | 🟡 | ~97% strings extracted + a11y sweep; נשאר ~20 strings + English manual testing |
| 10 | השקה | ⬜ | keystore → build → dog-food → beta → Play |

---

## 🔧 מה שנשאר (per phase)

### Phase 3 — ריפקטור מבני (Post-launch)
- פיצול קבצים גדולים: my_pantry (1,477), settings (1,471), shopping_lists_screen (1,187), shopping_list_details (1,136), shopping_lists_provider (1,196), auth_service (1,001).
- BaseProvider mixin — ~50 שורות כפולות ב-5 providers.
- notifications_service refactor — `_createNotification()` helper.

### Phase 5 — הכנה ל-Store (חוסם השקה — יהודה)
- [ ] 🔑 Release keystore (Windows)
- [ ] 🎨 App icons (1024×1024)
- [ ] 📱 Store screenshots (needs device)
- [ ] 📜 Privacy policy URL (GitHub Pages deploy)

### Phase 6 — Push Notifications (FCM) ⬜
> האפליקציה כבר תומכת בהתראות in-app (Firestore subcollection). FCM push הוא שדרוג — **לא חוסם launch**.

- **Android setup**: `POST_NOTIFICATIONS` permission (Android 13+), notification channel, default icon/color meta-data.
- **Token management**: `getToken()` → שמירה ב-`users/{uid}/fcmToken`, `onTokenRefresh`, מחיקה ב-logout.
- **Foreground/Background/Cold start**: `onMessage` (local notification), `onMessageOpenedApp` (ניווט), `getInitialMessage`, `onBackgroundMessage` handler.
- **Permission flow**: בקשה אחרי onboarding (לא מיד), fallback אם נדחה, שמירת סטטוס ב-UserContext.
- **Cloud Functions** (Blaze): שליחת FCM כשנוצרת התראה ב-Firestore; triggers (הזמנה/תפקיד/מלאי/רשימה); batching.
- **Settings integration**: toggles ↔ FCM topics, deep links.

### Phase 9 — i18n + נגישות (Post-launch)
- ~20 hardcoded Hebrew strings ב-~8 קבצים.
- Full English mode manual testing.

### Phase 10 — השקה
- Build APK (release keystore) → dog-food על מכשיר → beta → Google Play → crash monitoring.

---

## 🐛 באגים פתוחים

| ID | תיאור | חומרה | סטטוס |
|----|--------|--------|--------|
| W1 | `use_build_context_synchronously` ×2 in settings_screen | 🟢 | יש `mounted` guards — ממתין לאימות analyzer |

*כל שאר הבאגים (B1-B17, W2, B3) נפתרו. באגי אבטחה/לוגיקה פעילים — ב-[AGENTS.md](../AGENTS.md) §4 Known Issues.*

---

## 🔑 החלטות מפתח

- **Package name:** `com.memozap.app`
- **Proxy pattern for i18n** — 0 changes at 724+ call sites; HE base, EN extends.
- **Hand-written mocks** — mockito removed from dev_dependencies.
- **Firestore rules v4.5** — Apr-27 audit fixes deployed (closed 3 privilege-escalation holes; ראה Known Issues על over-corrections).
- **FCM push not required for launch** — in-app notifications work.
- **Onboarding removed** — -3,258 lines; welcome screen still works via `seenOnboarding`.
- **Single-class large files deferred** — post-launch.
- **Catalog**: supermarket.json הוא הפעיל; 5 הקטלוגים האחרים מוסתרים (מיקוד-סופר).

---

## 📋 מה צריך ל-Launch (MVP)

### חובה (blocking — יהודה)
1. 🔑 Release keystore (Windows)
2. 🎨 App icon 1024×1024
3. 📱 Build APK/AAB
4. 📱 Dog-food on real device
5. Fix critical bugs from dog-fooding + the security gate (Known Issues #11/#17/#19/#20/#22)

### רצוי (nice-to-have)
- i18n — extract remaining strings · store screenshots · privacy policy URL · fix W1

### Post-launch
- FCM push · file splitting · widget/integration tests · monetization · BaseProvider refactor
