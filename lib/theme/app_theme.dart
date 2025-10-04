// 📄 File: lib/theme/app_theme.dart
// תיאור: עיצוב האפליקציה - צבעים, טיפוגרפיה, ו-Theme components
//
// עדכון: הוספת welcomeBackground ל-AppBrand

import 'package:flutter/material.dart';

/// צבעי מותג (קבועים)
class _Brand {
  // Slate כהה כמו במסכי Home/Onboarding
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);

  // Accent ענבר
  static const amber = Color(0xFFFFC107); // ענבר נעים וברור

  // בסיס ירקרק (אם תרצה לשמר זהות קיימת)
  static const primarySeed = Color(0xFF4CAF50);
}

/// ThemeExtension כדי להעביר צבעי מותג לרכיבים/מסכים
@immutable
class AppBrand extends ThemeExtension<AppBrand> {
  final Color accent; // ענבר
  final Color surfaceSlate; // Slate כהה לברירת־מחדל במסכים
  final Color welcomeBackground; // רקע מסך Welcome (Slate 900)

  const AppBrand({
    required this.accent,
    required this.surfaceSlate,
    required this.welcomeBackground,
  });

  @override
  AppBrand copyWith({
    Color? accent,
    Color? surfaceSlate,
    Color? welcomeBackground,
  }) {
    return AppBrand(
      accent: accent ?? this.accent,
      surfaceSlate: surfaceSlate ?? this.surfaceSlate,
      welcomeBackground: welcomeBackground ?? this.welcomeBackground,
    );
  }

  @override
  AppBrand lerp(ThemeExtension<AppBrand>? other, double t) {
    if (other is! AppBrand) return this;
    return AppBrand(
      accent: Color.lerp(accent, other.accent, t)!,
      surfaceSlate: Color.lerp(surfaceSlate, other.surfaceSlate, t)!,
      welcomeBackground: Color.lerp(
        welcomeBackground,
        other.welcomeBackground,
        t,
      )!,
    );
  }
}

class AppTheme {
  // סכמות צבע לפי Material 3
  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: _Brand.primarySeed,
    brightness: Brightness.light,
  );

  static final _darkScheme = ColorScheme.fromSeed(
    seedColor: _Brand.primarySeed,
    brightness: Brightness.dark,
  );

  /// בסיס משותף ל־Light/Dark
  static ThemeData _base(ColorScheme scheme, {required bool dark}) {
    final brand = AppBrand(
      accent: _Brand.amber,
      surfaceSlate: _Brand.slate900,
      welcomeBackground: _Brand.slate900, // ✅ הוספה
    );

    // צבעי מילוי דקים לשדות טופס
    final fillOnLight = scheme.surfaceContainerHighest.withValues(alpha: 0.06);
    final fillOnDark = scheme.surfaceContainerHighest.withValues(alpha: 0.08);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Assistant',
      extensions: [brand],

      // רקע כללי — בדארק נרצה Slate כהה
      scaffoldBackgroundColor: dark ? _Brand.slate900 : scheme.surface,

      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: dark ? scheme.surface : scheme.primary,
        foregroundColor: dark ? scheme.onSurface : scheme.onPrimary,
      ),

      // כפתורים
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.accent,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: brand.accent),
          foregroundColor: brand.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // כרטיסים
      cardTheme: CardThemeData(
        elevation: 2,
        color: dark ? _Brand.slate800 : scheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ListTile — טוב ל־RTL
      listTileTheme: ListTileThemeData(
        iconColor: dark ? Colors.white70 : scheme.onSurfaceVariant,
        textColor: dark ? Colors.white : scheme.onSurface,
        contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12),
      ),

      // שדות קלט
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: dark ? fillOnDark : fillOnLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (dark ? Colors.white24 : Colors.black12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (dark ? Colors.white24 : Colors.black12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brand.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),

      // CheckBox, Switch, Radio
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand.accent;
          return null;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand.accent;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return brand.accent.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand.accent;
          return null;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: brand.accent,
        inactiveTrackColor: dark ? Colors.white24 : Colors.black12,
        thumbColor: brand.accent,
        overlayColor: brand.accent.withValues(alpha: 0.2),
        valueIndicatorColor: brand.accent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),

      // מחווני התקדמות
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.accent,
        linearTrackColor: dark ? Colors.white10 : Colors.black12,
        linearMinHeight: 6,
      ),

      // דיאלוגים/BottomSheet
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? _Brand.slate800 : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Assistant',
        ),
        contentTextStyle: TextStyle(
          color: dark ? Colors.white70 : scheme.onSurfaceVariant,
          fontFamily: 'Assistant',
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? _Brand.slate800 : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // סנאק־בר
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? _Brand.slate700 : scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: dark ? Colors.white : scheme.onInverseSurface,
          fontFamily: 'Assistant',
        ),
        actionTextColor: brand.accent,
        behavior: SnackBarBehavior.floating,
      ),

      // טיפוגרפיה כללית
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
      ),
    ).copyWith(
      // צבעי טקסט לפי מצב
      textTheme: ThemeData().textTheme.apply(
        bodyColor: dark ? Colors.white : scheme.onSurface,
        displayColor: dark ? Colors.white : scheme.onSurface,
      ),
    );
  }

  // ערכות סופיות ליישום
  static final ThemeData lightTheme = _base(_lightScheme, dark: false);
  static final ThemeData darkTheme = _base(_darkScheme, dark: true);
}
