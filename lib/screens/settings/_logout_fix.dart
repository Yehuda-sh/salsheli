  // התנתקות מלאה + מחיקת כל הנתונים
  Future<void> _logout() async {
    debugPrint('🔥 _logout: מתחיל התנתקות מלאה');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.settings.logoutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.settings.logoutMessage),
            const SizedBox(height: kSpacingMedium),
            Container(
              padding: const EdgeInsets.all(kSpacingSmall),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kBorderRadius),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: kIconSizeMedium,
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'כל הנתונים המקומיים יימחקו!\n(מוצרים, העדפות, cache)',
                      style: TextStyle(
                        fontSize: kFontSizeSmall,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.settings.logoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.settings.logoutConfirm,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      debugPrint('🔥 _logout: אושר - מתחיל מחיקת נתונים מלאה');
      
      // 🔥 התנתקות מלאה + מחיקת כל הנתונים המקומיים
      try {
        // הצגת Loading Dialog
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(kSpacingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: kSpacingMedium),
                      Text('ממחק נתונים...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // 🆕 קריאה לפונקציה החדשה שמוחקת הכל!
        await context.read<UserContext>().signOutAndClearAllData();

        debugPrint('🎉 _logout: כל הנתונים נמחקו + התנתקות הושלמה');

        // חזרה למסך התחברות
        if (!mounted) return;
        Navigator.of(context).pop(); // סגירת Loading Dialog
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      } catch (e) {
        debugPrint('❌ _logout: שגיאה - $e');
        if (!mounted) return;
        Navigator.of(context).pop(); // סגירת Loading Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בהתנתקות: $e'),
            backgroundColor: Colors.red,
            duration: kSnackBarDurationLong,
          ),
        );
      }
    } else {
      debugPrint('❌ _logout: בוטל');
    }
  }
