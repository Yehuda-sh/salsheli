// 📄 File: lib/theme/app_theme.dart
// תיאור: עיצוב האפליקציה - צבעים, טיפוגרפיה, ו-Theme components
//
// Purpose:
// מערכת Theme מרכזית לכל האפליקציה - מגדירה צבעים, טיפוגרפיה, ועיצוב רכיבים.
// תומכת ב-Light/Dark modes עם Material 3 ומותג מותאם אישית (AppBrand).
//
// Features:
// - Material 3 Theme מלא
// - Light/Dark modes עם Slate כהה
// - AppBrand: צבעי מותג מותאמים (Amber accent, Slate backgrounds)
// - RTL support מובנה (EdgeInsetsDirectional)
// - Typography: Assistant font family
// - Accessible: גדלי מגע 48px, contrast AA+
//
// Dependencies:
// - flutter/material.dart
// - Assistant font (pubspec.yaml)
//
// Usage:
//
// Example 1 - Apply theme in MaterialApp:
// ```dart
// MaterialApp(
//   theme: AppTheme.lightTheme,
//   darkTheme: AppTheme.darkTheme,
//   themeMode: ThemeMode.system,
//   home: HomeScreen(),
// )
// ```
//
// Example 2 - Access brand colors in widgets:
// ```dart
// final brand = Theme.of(context).extension<AppBrand>();
// Container(
//   color: brand?.accent, // Amber
// )
// ```
//
// Example 3 - Use theme colors:
// ```dart
// final cs = Theme.of(context).colorScheme;
// Text('Hello', style: TextStyle(color: cs.primary))
// ```
//
// Color Palette:
// - Slate 900 (#0F172A): Dark backgrounds (Welcome, Home)
// - Slate 800 (#1E293B): Cards, Dialogs in dark mode
// - Slate 700 (#334155): Dividers, borders
// - Amber (#FFC107): Accent color (buttons, highlights)
// - Primary Seed (#4CAF50): Green base for Material palette
//
// Version: 2.0

import 'package:flutter/material.dart';

/// צבעי מותג (קבועים)
/// 
/// Slate: משפחת צבעים כהים לרקעים ו-surfaces
/// Amber: צבע accent ברור וחם
/// Primary Seed: בסיס ירוק לpalette של Material 3
class _Brand {
  // Slate כהה כמו במסכי Home/Onboarding
  static const slate900 = Color(0xFF0F172A); // רקע כהה עמוק
  static const slate800 = Color(0xFF1E293B); // כרטיסים ודיאלוגים
  static const slate700 = Color(0xFF334155); // גבולות ודיווידרים

  // Accent ענבר - בולט וחם
  static const amber = Color(0xFFC107); // ענבר נעים וברור

  // בסיס ירקרק (אם תרצה לשמר זהות קיימת)
  static const primarySeed = Color(0xFF4CAF50); // ירוק Material
}

/// ThemeExtension כדי להעביר צבעי מותג לרכיבים/מסכים
/// 
/// מאפשר גישה לצבעים מותאמים אישית שלא חלק מ-ColorScheme הסטנדרטי.
/// גישה דרך: `Theme.of(context).extension<AppBrand>()`
@immutable
class AppBrand extends ThemeExtension<AppBrand> {
  /// צבע accent ראשי (Amber)
  final Color accent;
  
  /// רקע Slate כהה לברירת־מחדל במסכים
  final Color surfaceSlate;
  
  /// רקע מסך Welcome (Slate 900)
  final Color welcomeBackground;

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
    debugPrint('🎨 AppBrand.copyWith()');
    return AppBrand(
      accent: accent ?? this.accent,
      surfaceSlate: surfaceSlate ?? this.surfaceSlate,
      welcomeBackground: welcomeBackground ?? this.welcomeBackground,
    );
  }

  @override
  AppBrand lerp(ThemeExtension<AppBrand>? other, double t) {
    debugPrint('🎨 AppBrand.lerp(t: ${t.toStringAsFixed(2)})');
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

/// מחלקה ראשית לניהול Themes
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
  /// 
  /// יוצר ThemeData מלא עם כל ההגדרות:
  /// - ColorScheme (light/dark)
  /// - AppBrand extension
  /// - רכיבים (buttons, cards, inputs, etc.)
  /// - טיפוגרפיה (Assistant font)
  static ThemeData _base(ColorScheme scheme, {required bool dark}) {
    debugPrint('🎨 AppTheme._base(dark: $dark)');
    
    final brand = AppBrand(
      accent: _Brand.amber,
      surfaceSlate: _Brand.slate900,
      welcomeBackground: _Brand.slate900,
    );
    
    debugPrint('   🎨 accent: ${brand.accent.value.toRadixString(16)}');
    debugPrint('   🎨 surfaceSlate: ${brand.surfaceSlate.value.toRadixString(16)}');

    // צבעי מילוי דקים לשדות טופס
    // Light: שקוף יותר (6% opacity)
    // Dark: קצת יותר בולט (8% opacity)
    final fillOnLight = scheme.surfaceContainerHighest.withValues(alpha: 0.06);
    final fillOnDark = scheme.surfaceContainerHighest.withValues(alpha: 0.08);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Assistant',
      extensions: [brand],

      // רקע כללי — בדארק נרצה Slate כהה
      scaffoldBackgroundColor: dark ? _Brand.slate900 : scheme.surface,

      // AppBar - עליון של מסכים
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: dark ? scheme.surface : scheme.primary,
        foregroundColor: dark ? scheme.onSurface : scheme.onPrimary,
      ),

      // כפתורים - 4 סוגים
      
      // ElevatedButton: כפתור ראשי עם רקע Amber
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.accent, // Amber
          foregroundColor: Colors.black, // טקסט שחור על Amber
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // OutlinedButton: כפתור משני עם מסגרת Amber
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
      
      // FilledButton: כפתור מלא עם primary color
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
      
      // TextButton: כפתור טקסט פשוט
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // כרטיסים - Cards
      cardTheme: CardThemeData(
        elevation: 2,
        color: dark ? _Brand.slate800 : scheme.surface, // Slate בdark
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

      // שדות קלט - TextField, TextFormField
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
          borderSide: BorderSide(color: brand.accent, width: 2), // Amber כש-focused
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

      // CheckBox, Switch, Radio - רכיבי בחירה
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

      // Slider - ווליום, בהירות, וכו'
      sliderTheme: SliderThemeData(
        activeTrackColor: brand.accent,
        inactiveTrackColor: dark ? Colors.white24 : Colors.black12,
        thumbColor: brand.accent,
        overlayColor: brand.accent.withValues(alpha: 0.2),
        valueIndicatorColor: brand.accent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),

      // מחווני התקדמות - Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.accent, // Amber spinner
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

      // סנאק־בר - הודעות זמניות
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? _Brand.slate700 : scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: dark ? Colors.white : scheme.onInverseSurface,
          fontFamily: 'Assistant',
        ),
        actionTextColor: brand.accent, // כפתור action בAmber
        behavior: SnackBarBehavior.floating,
      ),

      // טיפוגרפיה כללית - גדלים ומשקלים
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
      ),
    ).copyWith(
      // צבעי טקסט לפי מצב - white בdark, onSurface בlight
      textTheme: ThemeData().textTheme.apply(
        bodyColor: dark ? Colors.white : scheme.onSurface,
        displayColor: dark ? Colors.white : scheme.onSurface,
      ),
    );
  }

  // ערכות סופיות ליישום
  
  /// Light Theme - מצב יום
  static ThemeData get lightTheme {
    debugPrint('☀️ AppTheme.lightTheme - Loading...');
    return _base(_lightScheme, dark: false);
  }

  /// Dark Theme - מצב לילה
  static ThemeData get darkTheme {
    debugPrint('🌙 AppTheme.darkTheme - Loading...');
    return _base(_darkScheme, dark: true);
  }
}
