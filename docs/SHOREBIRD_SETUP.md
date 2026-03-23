# Shorebird Setup Guide — MemoZap

## מה זה Shorebird?

Shorebird מאפשר לדחוף שינויי קוד Dart ישירות למכשירים — **בלי להוריד APK חדש**.
השינויים נכנסים בפתיחה הבאה של האפליקציה.

---

## שלב 1: התקנת Shorebird CLI

```bash
# macOS / Linux
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# Windows (PowerShell)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex
```

אחרי ההתקנה, פתח טרמינל חדש ובדוק:
```bash
shorebird --version
```

---

## שלב 2: יצירת חשבון

```bash
shorebird login
```

ייפתח דפדפן — התחבר עם Google.

---

## שלב 3: אתחול בפרויקט

```bash
cd /path/to/salsheli
shorebird init
```

זה ייצור `shorebird.yaml` עם `app_id` ייחודי.
**ה-`app_id` שנוצר יחליף את ה-placeholder בקובץ `shorebird.yaml` הקיים.**

---

## שלב 4: הגדרת GitHub Secret

1. לך ל: **GitHub Repo → Settings → Secrets and variables → Actions**
2. הוסף secret חדש:
   - **Name:** `SHOREBIRD_TOKEN`
   - **Value:** הרץ `shorebird login:ci` בטרמינל והדבק את הטוקן שמתקבל

---

## שלב 5: Release ראשון

ה-release הראשון **חייב** להיות דרך Shorebird כדי שה-patches יעבדו:

```bash
shorebird release android
```

זה בונה APK עם Shorebird engine. **את ה-APK הזה צריך להפיץ ל-testers.**

אפשר גם להשתמש ב-CI — פשוט דחוף tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

ה-workflow `shorebird-release.yml` ירוץ אוטומטית, יבנה release ויעלה ל-Firebase App Distribution.

---

## שלב 6: שליחת Patch (עדכון OTA)

### מקומית:
```bash
shorebird patch android --release-version 1.0.0+1
```

### דרך CI:
1. לך ל: **GitHub → Actions → Shorebird Patch (OTA Update)**
2. לחץ **Run workflow**
3. בחר platform (android)
4. הגדר את `SHOREBIRD_RELEASE_VERSION` ב-Variables (Settings → Variables) לגירסה הנוכחית

---

## איך זה עובד?

```
שינוי קוד Dart → shorebird patch → Shorebird servers
                                          ↓
משתמש פותח אפליקציה ← patch מורד אוטומטית ← בפתיחה הבאה — הקוד מעודכן!
```

**מה כן עובד ב-patch:**
- שינויי קוד Dart (לוגיקה, UI, providers)
- שינויי strings, colors, layouts

**מה לא עובד ב-patch (צריך release חדש):**
- שינויים ב-native code (Android/iOS)
- הוספת/הסרת packages עם native plugins
- שינויים ב-assets (תמונות, פונטים)
- שינוי גירסה ב-pubspec.yaml

---

## Workflows

| Workflow | טריגר | מה עושה |
|----------|--------|---------|
| `firebase-distribution.yml` | כל push | Build רגיל + Firebase Distribution |
| `shorebird-release.yml` | tag `v*` | Shorebird release + Firebase Distribution |
| `shorebird-patch.yml` | Manual dispatch | שולח OTA patch למכשירים קיימים |

---

## הגדרת Repository Variable

ב-GitHub → Settings → Secrets and variables → Actions → **Variables**:

| Variable | Value | Description |
|----------|-------|-------------|
| `SHOREBIRD_RELEASE_VERSION` | `1.0.0+1` | הגירסה שאליה שולחים patch |

---

## Pricing

- **Free tier:** 5,000 patch installs/month
- מספיק לצוות testers
- [תמחור מלא](https://shorebird.dev/pricing)
