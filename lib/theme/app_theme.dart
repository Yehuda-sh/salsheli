// 📄 File: lib/theme/app_theme.dart
// תיאור: עיצוב האפליקציה - צבעים, טיפוגרפיה, ו-Theme components
//
// Purpose:
// מערכת Theme מרכזית לכל האפליקציה - מגדירה צבעים, טיפוגרפיה, ועיצוב רכיבים.
// תומכת ב-Light/Dark modes עם Material 3 ומותג מותאם אישית (AppBrand).
//
// Features:
// - Material 3 Theme מלא עם Dynamic Color (Android 12+)
// - Light/Dark modes עם Surface Containers
// - AppBrand: צבעי מותג מותאמים (Amber accent, harmonized colors)
// - RTL support מובנה (EdgeInsetsDirectional)
// - Typography: Assistant font family עם line-height מדויק
// - Accessible: גדלי מגע 48px, contrast AA+
//
// Dependencies:
// - flutter/material.dart
// - Assistant font (pubspec.yaml)
// - dynamic_color (optional, for Android 12+ Material You support)
//
// Usage:
//
// Example 1 - Apply theme in MaterialApp (basic):
// ```dart
// MaterialApp(
//   theme: AppTheme.lightTheme,
//   darkTheme: AppTheme.darkTheme,
//   themeMode: ThemeMode.system,
//   home: HomeScreen(),
// )
// ```
//
// Example 2 - With Dynamic Color (Android 12+ Material You):
// ```dart
// import 'package:dynamic_color/dynamic_color.dart';
// 
// DynamicColorBuilder(
//   builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
//     return MaterialApp(
//       theme: lightDynamic != null
//           ? AppTheme.fromDynamicColors(lightDynamic, dark: false)
//           : AppTheme.lightTheme,
//       darkTheme: darkDynamic != null
//           ? AppTheme.fromDynamicColors(darkDynamic, dark: true)
//           : AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       home: HomeScreen(),
//     );
//   },
// )
// ```
//
// Example 3 - Access brand colors in widgets:
// ```dart
// final brand = Theme.of(context).extension<AppBrand>();
// Container(
//   color: brand?.accent, // Amber (or harmonized if using dynamic color)
// )
// 
// SnackBar(
//   backgroundColor: brand?.success, // Green (success)
// )
// 
// SnackBar(
//   backgroundColor: brand?.warning, // Orange (warning)
// )
// ```
//
// Example 4 - Use theme colors:
// ```dart
// final cs = Theme.of(context).colorScheme;
// Text('Hello', style: TextStyle(color: cs.primary))
// ```
//
// Color Palette:
// - Primary Seed (#4CAF50): Green base for Material 3 palette
// - Amber (#FFC107): Accent color (buttons, highlights)
// - Green (#689F38): Success color (SnackBar, feedback)
// - Orange (#FF9800): Warning color (SnackBar, alerts)
// - Surface Containers: M3 surface system (surfaceContainerLow/High/Highest)
//
// Version: 3.0 - Dynamic Color + M3 Surface Containers + Typography Improvements

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/ui_constants.dart';

/// צבעי מותג (קבועים)
/// 
/// משמשים כברירת מחדל כאשר Dynamic Color לא זמין.
/// Amber: צבע accent ברור וחם
/// Primary Seed: בסיס ירוק לpalette של Material 3
class _Brand {
  // Accent ענבר - בולט וחם
  static const amber = Color(0xFFFFC107); // ענבר נעים וברור

  // בסיס ירקרק לזהות המותג
  static const primarySeed = Color(0xFF4CAF50); // ירוק Material
}

/// ThemeExtension כדי להעביר צבעי מותג לרכיבים/מסכים
/// 
/// מאפשר גישה לצבעים מותאמים אישית שלא חלק מ-ColorScheme הסטנדרטי.
/// גישה דרך: `Theme.of(context).extension<AppBrand>()`
@immutable
class AppBrand extends ThemeExtension<AppBrand> {
  /// צבע accent ראשי (Amber או harmonized)
  final Color accent;
  
  /// רקע surface לברירת־מחדל במסכים (נגזר מ-ColorScheme)
  final Color surfaceSlate;
  
  /// רקע מסך Welcome (נגזר מ-ColorScheme.surface)
  final Color welcomeBackground;
  
  /// צבע הצלחה (Success) - ירוק
  final Color success;
  
  /// צבע אזהרה (Warning) - כתום
  final Color warning;
  
  // 🎨📝 Sticky Notes Design System
  
  /// רקע נייר מחברת
  final Color paperBackground;
  
  /// פתק צהוב
  final Color stickyYellow;
  
  /// פתק ורוד
  final Color stickyPink;
  
  /// פתק ירוק
  final Color stickyGreen;
  
  /// פתק תכלת
  final Color stickyCyan;
  
  /// פתק סגול
  final Color stickyPurple;
  
  /// קווי מחברת כחולים
  final Color notebookBlue;
  
  /// קו אדום במחברת
  final Color notebookRed;

  const AppBrand({
    required this.accent,
    required this.surfaceSlate,
    required this.welcomeBackground,
    required this.success,
    required this.warning,
    required this.paperBackground,
    required this.stickyYellow,
    required this.stickyPink,
    required this.stickyGreen,
    required this.stickyCyan,
    required this.stickyPurple,
    required this.notebookBlue,
    required this.notebookRed,
  });

  @override
  AppBrand copyWith({
    Color? accent,
    Color? surfaceSlate,
    Color? welcomeBackground,
    Color? success,
    Color? warning,
    Color? paperBackground,
    Color? stickyYellow,
    Color? stickyPink,
    Color? stickyGreen,
    Color? stickyCyan,
    Color? stickyPurple,
    Color? notebookBlue,
    Color? notebookRed,
  }) {
    return AppBrand(
      accent: accent ?? this.accent,
      surfaceSlate: surfaceSlate ?? this.surfaceSlate,
      welcomeBackground: welcomeBackground ?? this.welcomeBackground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      paperBackground: paperBackground ?? this.paperBackground,
      stickyYellow: stickyYellow ?? this.stickyYellow,
      stickyPink: stickyPink ?? this.stickyPink,
      stickyGreen: stickyGreen ?? this.stickyGreen,
      stickyCyan: stickyCyan ?? this.stickyCyan,
      stickyPurple: stickyPurple ?? this.stickyPurple,
      notebookBlue: notebookBlue ?? this.notebookBlue,
      notebookRed: notebookRed ?? this.notebookRed,
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
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      paperBackground: Color.lerp(paperBackground, other.paperBackground, t)!,
      stickyYellow: Color.lerp(stickyYellow, other.stickyYellow, t)!,
      stickyPink: Color.lerp(stickyPink, other.stickyPink, t)!,
      stickyGreen: Color.lerp(stickyGreen, other.stickyGreen, t)!,
      stickyCyan: Color.lerp(stickyCyan, other.stickyCyan, t)!,
      stickyPurple: Color.lerp(stickyPurple, other.stickyPurple, t)!,
      notebookBlue: Color.lerp(notebookBlue, other.notebookBlue, t)!,
      notebookRed: Color.lerp(notebookRed, other.notebookRed, t)!,
    );
  }
}

/// מחלקה ראשית לניהול Themes
class AppTheme {
  // סכמות צבע לפי Material 3 - עם Fidelity variant לצבעים חיים יותר
  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: _Brand.primarySeed,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity, // צבעים נאמנים ל-seed
  );

  static final _darkScheme = ColorScheme.fromSeed(
    seedColor: _Brand.primarySeed,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity, // צבעים נאמנים ל-seed
  );

  /// יוצר Theme מ-Dynamic Colors (Android 12+ Material You)
  /// 
  /// מקבל ColorScheme דינמי מהמערכת ויוצר Theme מותאם אישית.
  /// הצבעים (Amber, Success, Warning) עוברים harmonization כדי להשתלב
  /// בצבעי המערכת אך לשמור על הזהות של המותג.
  /// 
  /// שימושי רק עם DynamicColorBuilder:
  /// ```dart
  /// DynamicColorBuilder(
  ///   builder: (lightDynamic, darkDynamic) {
  ///     return MaterialApp(
  ///       theme: lightDynamic != null
  ///           ? AppTheme.fromDynamicColors(lightDynamic, dark: false)
  ///           : AppTheme.lightTheme,
  ///       // ...
  ///     );
  ///   },
  /// )
  /// ```
  /// 
  /// See also:
  /// - [lightTheme] - ברירת מחדל ללא Dynamic Color
  /// - [darkTheme] - ברירת מחדל ללא Dynamic Color
  static ThemeData fromDynamicColors(
    ColorScheme dynamicScheme, {
    required bool dark,
  }) {
    // Harmonization: התאם את Amber/Success/Warning לצבעי המערכת
    // זה שומר על הזהות של המותג אבל משלב אותם בצבעי המשתמש
    final harmonizedAccent = _harmonizeColor(
      _Brand.amber,
      dynamicScheme.primary,
    );
    final harmonizedSuccess = _harmonizeColor(
      Colors.green.shade700,
      dynamicScheme.primary,
    );
    final harmonizedWarning = _harmonizeColor(
      Colors.orange.shade700,
      dynamicScheme.primary,
    );
    
    final brand = AppBrand(
      accent: harmonizedAccent,
      surfaceSlate: dynamicScheme.surface,
      welcomeBackground: dynamicScheme.surface,
      success: harmonizedSuccess,
      warning: harmonizedWarning,
      paperBackground: dark ? kDarkPaperBackground : kPaperBackground,
      stickyYellow: dark ? kStickyYellowDark : kStickyYellow,
      stickyPink: dark ? kStickyPinkDark : kStickyPink,
      stickyGreen: dark ? kStickyGreenDark : kStickyGreen,
      stickyCyan: dark ? kStickyCyanDark : kStickyCyan,
      stickyPurple: dark ? kStickyPurpleDark : kStickyPurple,
      notebookBlue: kNotebookBlue,
      notebookRed: kNotebookRed,
    );
    
    return _base(dynamicScheme, dark: dark, customBrand: brand);
  }

  /// Helper: Color Harmonization
  /// 
  /// מתאים צבע מותאם אישית לצבעי המערכת על ידי הזזת הue
  /// כך שהוא מרגיש "חלק מהסכמה" אבל שומר על אופי המקורי.
  /// 
  /// זוהי גרסה פשוטה של harmonization - לגרסה מלאה יש להשתמש ב:
  /// `import 'package:dynamic_color/dynamic_color.dart';`
  /// `color.harmonizeWith(primaryColor);`
  static Color _harmonizeColor(Color color, Color primaryColor) {
    // אם הצבעים דומים, אין צורך בharmonization
    final colorHsl = HSLColor.fromColor(color);
    final primaryHsl = HSLColor.fromColor(primaryColor);
    
    // מזיז את ה-hue ב-30% לעבר ה-primary
    final newHue = colorHsl.hue + (primaryHsl.hue - colorHsl.hue) * 0.3;
    
    return colorHsl.withHue(newHue).toColor();
  }

  /// בסיס משותף ל־Light/Dark
  /// 
  /// יוצר ThemeData מלא עם כל ההגדרות:
  /// - ColorScheme (light/dark או dynamic)
  /// - AppBrand extension (עם או בלי harmonization)
  /// - רכיבים (buttons, cards, inputs, etc.)
  /// - טיפוגרפיה (Assistant font עם line-height מדויק)
  /// 
  /// Parameters:
  /// - [scheme]: ColorScheme לשימוש (מ-fromSeed או dynamic)
  /// - [dark]: האם זה dark mode
  /// - [customBrand]: AppBrand מותאם אישית (לשימוש ב-fromDynamicColors)
  static ThemeData _base(
    ColorScheme scheme, {
    required bool dark,
    AppBrand? customBrand,
  }) {
    // צור AppBrand - או customBrand (מ-dynamic colors) או ברירת מחדל
    final brand = customBrand ?? AppBrand(
      accent: _Brand.amber,
      surfaceSlate: scheme.surface,
      welcomeBackground: scheme.surface,
      success: Colors.green.shade700,
      warning: Colors.orange.shade700,
      paperBackground: dark ? kDarkPaperBackground : kPaperBackground,
      stickyYellow: dark ? kStickyYellowDark : kStickyYellow,
      stickyPink: dark ? kStickyPinkDark : kStickyPink,
      stickyGreen: dark ? kStickyGreenDark : kStickyGreen,
      stickyCyan: dark ? kStickyCyanDark : kStickyCyan,
      stickyPurple: dark ? kStickyPurpleDark : kStickyPurple,
      notebookBlue: kNotebookBlue,
      notebookRed: kNotebookRed,
    );

    // צבעי מילוי דקים לשדות טופס
    // Light: שקוף יותר (6% opacity)
    // Dark: קצת יותר בולט (8% opacity)
    final fillOnLight = scheme.surfaceContainerHighest.withValues(alpha: 0.06);
    final fillOnDark = scheme.surfaceContainerHighest.withValues(alpha: 0.08);

    return ThemeData(
      useMaterial3: true, // Flutter 3.16+ זה ברירת מחדל, אבל מפורש = ברור יותר
      colorScheme: scheme,
      fontFamily: 'Assistant',
      extensions: [brand],

      // רקע כללי - M3 Surface System
      scaffoldBackgroundColor: scheme.surface,

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
          backgroundColor: brand.accent, // Amber (או harmonized)
          foregroundColor: Colors.black, // טקסט שחור על Amber
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: kFontSizeBody,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kButtonPaddingHorizontal,
            vertical: kButtonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      
      // OutlinedButton: כפתור משני עם מסגרת Amber
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: brand.accent),
          foregroundColor: brand.accent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: kFontSizeBody,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kButtonPaddingHorizontal,
            vertical: kButtonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      
      // FilledButton: כפתור מלא עם primary color
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: kFontSizeBody,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kButtonPaddingHorizontal,
            vertical: kButtonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
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

      // כרטיסים - Cards (M3 Surface Containers)
      cardTheme: CardThemeData(
        elevation: 2,
        // Surface Containers: רמות שונות של רקע
        // surfaceContainerLow = קרוב לרקע
        // surfaceContainerHigh = בולט יותר
        color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kCardMarginVertical,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
      ),

      // ListTile — טוב ל־RTL
      listTileTheme: ListTileThemeData(
        iconColor: dark ? Colors.white70 : scheme.onSurfaceVariant,
        textColor: dark ? Colors.white : scheme.onSurface,
        contentPadding: const EdgeInsetsDirectional.only(
          start: kListTilePaddingStart,
          end: kListTilePaddingEnd,
        ),
      ),

      // שדות קלט - TextField, TextFormField
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: dark ? fillOnDark : fillOnLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kInputPadding,
          vertical: kInputPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(
            color: (dark ? Colors.white24 : Colors.black12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(
            color: (dark ? Colors.white24 : Colors.black12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(
            color: brand.accent,
            width: kBorderWidthFocused,
          ), // Amber כש-focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(
            color: scheme.error,
            width: kBorderWidthFocused,
          ),
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
            return brand.accent.withValues(alpha: kOpacityMedium);
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
        overlayColor: brand.accent.withValues(alpha: kOpacityLight),
        valueIndicatorColor: brand.accent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),

      // מחווני התקדמות - Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.accent, // Amber spinner
        linearTrackColor: dark ? Colors.white10 : Colors.black12,
        linearMinHeight: kProgressIndicatorHeight,
      ),

      // דיאלוגים/BottomSheet (M3 Surface Containers)
      dialogTheme: DialogThemeData(
        // surfaceContainerHighest = הכי בולט (דיאלוגים)
        backgroundColor: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        ),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: kFontSizeLarge,
          fontWeight: FontWeight.bold,
          fontFamily: 'Assistant',
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontFamily: 'Assistant',
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusLarge),
          ),
        ),
      ),

      // סנאק־בר - הודעות זמניות
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontFamily: 'Assistant',
        ),
        actionTextColor: brand.accent, // כפתור action בAmber
        behavior: SnackBarBehavior.floating,
      ),

      // טיפוגרפיה כללית - גדלים, משקלים, ו-line-height מדויק לפי M3
      textTheme: TextTheme(
        // Display styles - כותרות גדולות
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 64 / 57, // line-height מדויק לפי M3
          letterSpacing: -0.25,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 52 / 45,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 44 / 36,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        
        // Headline styles - כותרות בינוניות
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 40 / 32,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 36 / 28,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 32 / 24,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        
        // Title styles - כותרות קטנות
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700, // M3 spec: 700!
          height: 28 / 22,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          letterSpacing: 0.1,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        
        // Body styles - טקסט גוף
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          letterSpacing: 0.5,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          letterSpacing: 0.25,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          letterSpacing: 0.4,
          color: dark ? Colors.white70 : scheme.onSurfaceVariant,
        ),
        
        // Label styles - תוויות כפתורים וכו'
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.5,
          color: dark ? Colors.white : scheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 16 / 11,
          letterSpacing: 0.5,
          color: dark ? Colors.white70 : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ערכות סופיות ליישום
  
  /// Light Theme - מצב יום
  /// 
  /// Theme בסיסי ללא Dynamic Color.
  /// לשימוש כ-fallback כאשר Dynamic Color לא זמין.
  static ThemeData get lightTheme {
    return _base(_lightScheme, dark: false);
  }

  /// Dark Theme - מצב לילה
  /// 
  /// Theme בסיסי ללא Dynamic Color.
  /// לשימוש כ-fallback כאשר Dynamic Color לא זמין.
  static ThemeData get darkTheme {
    return _base(_darkScheme, dark: true);
  }
}
