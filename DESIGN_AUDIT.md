# 📐 DESIGN_AUDIT.md — UI/UX Standards Audit

> עודכן: 16 מרץ 2026
> מבוסס על עקרונות Material Design + UX סטנדרטיים

---

## ✅ מה תקין

| עקרון | סטטוס |
|--------|--------|
| NotebookBackground בכל מסך | ✅ |
| SafeArea / AppBar בכל מסך | ✅ |
| Double-tap prevention על כפתורי submit | ✅ |
| Confirm dialog לפני פעולות הרסניות (מחיקה, logout) | ✅ |
| Consistent spacing (`kSpacing*`) | ✅ |
| RTL support | ✅ |

## 🎨 עיצוב ייחודי — שומרים!

כל מסך יש לו אסתטיקה משלו — **לא מאחידים**:
- **Dashboard** — watercolor illustrations 🎨
- **Pantry** — highlighter markers 🖍️
- **Create List** — StickyNotes 📝
- **Shopping** — כרטיסים דינמיים ⚡
- **Settings** — Card sections מובנים

---

## 🟡 שיפור: Spinners → Skeleton Loading

33 `CircularProgressIndicator` עדיין קיימים. Skeleton shimmer נותן תחושת מהירות טובה יותר.

| קובץ | spinners |
|-------|----------|
| settings_screen | 7 |
| pantry_product_selection_sheet | 2 |
| contact_selector_dialog | 2 |
| active_shopping_screen | 2 |
| pending_invites_screen | 2 |
| suggestions_today_card | 2 |
| +14 קבצים נוספים | 1 כ"א |

**Reusable component קיים:** `AppLoadingSkeleton` — צריך רק להטמיע.

**עדיפות:** Phase 2 (אחרי launch). לא חוסם.

---

## ✅ Reusable Components (נוצרו 12/3)

- `AppSectionCard` — Card wrapper עם elevation + borderRadius
- `AppErrorState` — אייקון + הודעה + retry
- `AppLoadingSkeleton` — Skeleton shimmer loading
- `AppScreenHeader` — כותרת מסך עם אייקון

---
*Created: 2026-03-12 | Updated: 2026-03-16*
