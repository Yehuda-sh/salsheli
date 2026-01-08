# Feature Status - MemoZap

## Overview

This document tracks what features are working, partially implemented, or not yet connected.

---

## Core Features

### Authentication

| Feature | Status | Notes |
|---------|--------|-------|
| Email/Password Registration | **Working** | Firebase Auth |
| Email/Password Login | **Working** | Firebase Auth |
| Logout | **Working** | Clears local data |
| Password Reset | **Unknown** | Needs verification |
| Profile Edit | **Partial** | Name change? Photo? |
| Account Deletion | **Not Implemented** | No option to delete account |
| Change Password | **Unknown** | Needs verification |

### Shopping Lists

| Feature | Status | Notes |
|---------|--------|-------|
| Create List | **Working** | Multiple types supported |
| Edit List Name | **Working** | |
| Delete List | **Working** | Owner only |
| Add Items | **Working** | Products + Tasks |
| Edit Items | **Working** | |
| Remove Items | **Working** | |
| Check/Uncheck Items | **Working** | |
| List Visibility (Private/Household) | **Working** | |
| Share with Users | **Working** | Role-based |
| Templates | **Working** | Create from template |
| Budget Setting | **Working** | |
| Event Date | **Working** | |
| Target Date | **Working** | |

### Active Shopping

| Feature | Status | Notes |
|---------|--------|-------|
| Start Shopping | **Working** | Timer starts |
| Join Shopping (Collaborative) | **Working** | Multiple shoppers |
| Check Items While Shopping | **Working** | Real-time sync |
| Skip/Missing Items | **Working** | |
| Shopping Timer | **Working** | 6-hour timeout |
| Finish Shopping | **Working** | Creates receipt |
| Shopping Summary | **Working** | Stats display |

### Pantry/Inventory

| Feature | Status | Notes |
|---------|--------|-------|
| View Inventory | **Working** | By location |
| Add Items | **Working** | |
| Edit Items | **Working** | |
| Delete Items | **Working** | |
| Undo Delete | **Not Working** | TODO in code (line 285) |
| Low Stock Alert | **Working** | |
| Expiry Date Tracking | **Working** | |
| Auto-update from Shopping | **Working** | For non-event lists |
| Group Inventory | **Working** | For family/roommates |

### Groups

| Feature | Status | Notes |
|---------|--------|-------|
| Create Group | **Working** | Multiple types |
| Edit Group | **Working** | |
| Delete Group | **Unknown** | Needs verification |
| Invite Members | **Working** | By email/phone |
| Accept/Reject Invites | **Working** | |
| Member Roles | **Working** | Owner/Admin/Editor/Viewer |
| Remove Members | **Working** | Admin+ only |
| Transfer Ownership | **Unknown** | Needs verification |
| Event Date for Group | **Not Working** | TODO in code (line 73) |

### Receipts/History

| Feature | Status | Notes |
|---------|--------|-------|
| View Receipt List | **Working** | |
| View Receipt Details | **Working** | |
| Virtual Receipts | **Working** | From shopping completion |
| Scan Real Receipts | **Unknown** | OCR mentioned in comments |

### Settings

| Feature | Status | Notes |
|---------|--------|-------|
| Theme (Light/Dark/System) | **Working** | |
| Compact View | **Not Saved** | Changes but doesn't persist |
| Show Prices | **Not Saved** | Changes but doesn't persist |
| Update Prices | **Working** | |
| Show Tutorial | **Working** | |

---

## TODO Items (from code)

### High Priority

| Location | Issue | Impact |
|----------|-------|--------|
| [welcome_screen.dart:191](../lib/screens/welcome/welcome_screen.dart) | Terms of Service link not working | Legal requirement |
| [welcome_screen.dart:215](../lib/screens/welcome/welcome_screen.dart) | Privacy Policy link not working | Legal requirement |
| [settings_screen.dart:768](../lib/screens/settings/settings_screen.dart) | Terms of Service button not working | Legal |
| [settings_screen.dart:780](../lib/screens/settings/settings_screen.dart) | Privacy Policy button not working | Legal |
| [settings_screen.dart:618,626,634](../lib/screens/settings/settings_screen.dart) | Settings not saving to SharedPreferences | User experience |

### Medium Priority

| Location | Issue | Impact |
|----------|-------|--------|
| [shopping_lists_provider.dart:1099](../lib/providers/shopping_lists_provider.dart) | `checkedBy` and `checkedAt` not saved | Collaborative shopping |
| [create_group_screen.dart:73](../lib/screens/groups/create_group_screen.dart) | Event date selection not implemented | Group events |

### Low Priority

| Location | Issue | Impact |
|----------|-------|--------|
| [my_pantry_screen.dart:285](../lib/screens/pantry/my_pantry_screen.dart) | Undo delete not implemented | Nice to have |
| [smart_suggestions_card.dart:508](../lib/screens/home/dashboard/widgets/smart_suggestions_card.dart) | Create list from defaults not implemented | Smart features |

---

## Deprecated Methods

These methods work but should be migrated to newer Result-based versions:

### NotificationsService

| Method | Line | Replacement |
|--------|------|-------------|
| `getUserNotifications` | 730 | Result-based version |
| `getUnreadNotifications` | 773 | Result-based version |
| `getUnreadCount` | 806 | Result-based version |

### PendingInvitesService

| Method | Line | Issue |
|--------|------|-------|
| Multiple methods | 819-925 | 8 deprecated methods |

---

## Features by Screen

### Welcome Screen
- **Working:** Onboarding questions, Basic info collection
- **Not Working:** Terms of Service link, Privacy Policy link

### Home Dashboard
- **Working:** Active lists, Recent receipts, Statistics
- **Partial:** Smart suggestions (create list not implemented)

### Shopping Lists Screen
- **Working:** All core features

### Shopping List Details
- **Working:** All core features
- **Missing:** checkedBy/checkedAt tracking

### Active Shopping Screen
- **Working:** All core features

### Pantry Screen
- **Working:** All core features
- **Not Working:** Undo delete

### Groups Screen
- **Working:** All core features
- **Not Working:** Event date selection

### Settings Screen
- **Working:** Theme switching, Logout
- **Not Working:** Settings persistence, Legal links

---

## Push Notifications

| Feature | Status | Notes |
|---------|--------|-------|
| FCM Setup | **Implemented** | Code exists |
| Low Stock Alerts | **Unknown** | Code exists but needs verification |
| Group Invites | **Unknown** | Code exists but needs verification |
| Shopping Updates | **Unknown** | Needs verification |

---

## Data Sync

| Feature | Status | Notes |
|---------|--------|-------|
| Real-time Lists | **Working** | Firestore snapshots |
| Real-time Inventory | **Working** | Firestore snapshots |
| Real-time Groups | **Working** | Firestore snapshots |
| Offline Support | **Partial** | Firestore persistence enabled |
| Conflict Resolution | **Unknown** | Needs verification |

---

## Security

| Feature | Status | Notes |
|---------|--------|-------|
| Auth Required | **Working** | IndexScreen redirects |
| Household Scoping | **Working** | Data filtered by household_id |
| Role-based Access | **Working** | Owner/Admin/Editor/Viewer |
| Private Lists | **Working** | Stored under user document |

---

## Code Quality

| Metric | Status |
|--------|--------|
| Unused Files | **None found** |
| Commented-out Code Blocks | **None found** |
| TODO Comments | **9 found** |
| Deprecated Methods | **11 found** |
| Hebrew Documentation | **Good coverage** |
| Variable Naming | **Clear and consistent** |
| File Organization | **Well structured** |

---

## Recommended Priority

### Must Fix (Legal/Critical)
1. Terms of Service page/link
2. Privacy Policy page/link
3. Settings persistence

### Should Fix (User Experience)
4. checkedBy/checkedAt tracking
5. Deprecated method migration
6. Undo delete in pantry

### Nice to Have
7. Event date for groups
8. Smart suggestions create list
9. Account deletion option
10. Password change in settings

---

## Testing Status

| Area | Status |
|------|--------|
| Unit Tests | **Unknown** |
| Widget Tests | **Unknown** |
| Integration Tests | **Unknown** |
| Manual Testing | **Needed** |
