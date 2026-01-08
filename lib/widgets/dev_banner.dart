// 📄 lib/widgets/dev_banner.dart
//
// באנר DEV - מוצג רק במצב פיתוח להבדיל מ-production.
// משתמש ב-Banner widget של Flutter עם צבע כתום בפינה.
//
// 🔗 Related: AppConfig, main.dart

import 'package:flutter/material.dart';
import 'package:memozap/config/app_config.dart';

/// 🏷️ באנר DEV - מוצג בפינה ימנית עליונה במצב פיתוח
///
/// שימוש:
/// ```dart
/// Stack(
///   children: [
///     child,
///     const DevBanner(),
///   ],
/// )
/// ```
class DevBanner extends StatelessWidget {
  const DevBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // לא מציג כלום ב-production
    if (AppConfig.isProduction) {
      return const SizedBox.shrink();
    }

    return const Positioned(
      top: 0,
      right: 0,
      child: IgnorePointer(
        child: Banner(
          message: 'DEV',
          location: BannerLocation.topEnd,
          color: Colors.orange,
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
