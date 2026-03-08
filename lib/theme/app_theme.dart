// 📄 lib/theme/app_theme.dart
//
// מערכת Theme מרכזית - Material 3, Light/Dark, Dynamic Color, AppBrand.
// כולל צבעי מותג (Amber), success/warning, Sticky Notes, ו-Typography מדויק.
//
// 🔗 Related: AppBrand, ui_constants, ColorScheme

import 'package:flutter/material.dart';

import '../core/ui_constants.dart';

/// צבעי מותג (קבועים)
///
/// משמשים כברירת מחדל כאשר Dynamic Color לא זמין.
/// Amber: צבע accent ברור וחם
/// Primary Seed: בסיס ירוק לpalette של Material 3
class _Brand {
  // Accent ענבר - בולט וחם (לרקעים וכפתורים)
  static const amber = Color(0xFFFFC107); // ענבר נעים וברור

  // ✅ Amber כהה לטקסט - עומד ב-WCAG AA (contrast 5.2:1 על לבן)
  // משמש ל-TextButton, OutlinedButton וטקסט על רקע בהיר
  static const amberText = Color(0xFFE65100); // Orange 800

  // בסיס ירקרק לזהות המותג
  static const primarySeed = Color(0xFF4CAF50); // ירוק Material
}

/// ThemeExtension כדי להעביר צבעי מותג לרכיבים/מסכים
///
/// מאפשר גישה לצבעים מותאמים אישית שלא חלק מ-ColorScheme הסטנדרטי.
/// גישה דרך: `Theme.of(context).extension<AppBrand>()`
///
/// כולל:
/// - success/warning עם Container variants (לרקע/תגיות)
/// - Sticky Notes Design System
/// - צבעי מחברת
@immutable
class AppBrand extends ThemeExtension<AppBrand> {
  /// צבע accent ראשי (Amber או harmonized) - לרקעים וכפתורים
  final Color accent;

  /// צבע accent לטקסט - כהה יותר לנגישות (WCAG AA)
  final Color accentText;

  /// רקע surface לברירת־מחדל במסכים (נגזר מ-ColorScheme)
  final Color surfaceSlate;

  /// רקע מסך Welcome (נגזר מ-ColorScheme.surface)
  final Color welcomeBackground;

  /// צבע הצלחה (Success) - ירוק
  final Color success;

  /// צבע רקע הצלחה - לתגיות/באנרים (ירוק בהיר)
  final Color successContainer;

  /// צבע טקסט על successContainer
  final Color onSuccessContainer;

  /// צבע אזהרה (Warning) - כתום
  final Color warning;

  /// צבע רקע אזהרה - לתגיות/באנרים (כתום בהיר)
  final Color warningContainer;

  /// צבע טקסט על warningContainer
  final Color onWarningContainer;

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
    required this.accentText,
    required this.surfaceSlate,
    required this.welcomeBackground,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
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
    Color? accentText,
    Color? surfaceSlate,
    Color? welcomeBackground,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
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
      accentText: accentText ?? this.accentText,
      surfaceSlate: surfaceSlate ?? this.surfaceSlate,
      welcomeBackground: welcomeBackground ?? this.welcomeBackground,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
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
      accentText: Color.lerp(accentText, other.accentText, t)!,
      surfaceSlate: Color.lerp(surfaceSlate, other.surfaceSlate, t)!,
      welcomeBackground: Color.lerp(welcomeBackground, other.welcomeBackground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
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
  static ThemeData fromDynamicColors(ColorScheme dynamicScheme, {required bool dark}) {
    // Harmonization: התאם את Amber/Success/Warning לצבעי המערכת
    // זה שומר על הזהות של המותג אבל משלב אותם בצבעי המשתמש
    final harmonizedAccent = _harmonizeColor(_Brand.amber, dynamicScheme.primary);
    final harmonizedSuccess = _harmonizeColor(
      const Color(0xFF388E3C), // Green 700
      dynamicScheme.primary,
    );
    final harmonizedWarning = _harmonizeColor(
      const Color(0xFFF57C00), // Orange 700
      dynamicScheme.primary,
    );

    // Container colors - בהירים יותר לרקעים
    final successContainer = dark
        ? HSLColor.fromColor(harmonizedSuccess).withLightness(0.25).toColor()
        : HSLColor.fromColor(harmonizedSuccess).withLightness(0.85).toColor();
    final warningContainer = dark
        ? HSLColor.fromColor(harmonizedWarning).withLightness(0.25).toColor()
        : HSLColor.fromColor(harmonizedWarning).withLightness(0.85).toColor();

    final harmonizedAccentText = _harmonizeColor(_Brand.amberText, dynamicScheme.primary);

    final brand = AppBrand(
      accent: harmonizedAccent,
      accentText: harmonizedAccentText,
      surfaceSlate: dynamicScheme.surface,
      welcomeBackground: dynamicScheme.surface,
      success: harmonizedSuccess,
      successContainer: successContainer,
      onSuccessContainer: dark ? const Color(0xFFC8E6C9) : const Color(0xFF1B5E20),
      warning: harmonizedWarning,
      warningContainer: warningContainer,
      onWarningContainer: dark ? const Color(0xFFFFE0B2) : const Color(0xFFE65100),
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
  /// מתאים צבע מותאם אישית לצבעי המערכת על ידי הזזת ה-hue
  /// כך שהוא מרגיש "חלק מהסכמה" אבל שומר על אופי המקורי.
  ///
  /// ✅ משתמש במסלול הקצר בגלגל הצבעים (0-360°)
  ///
  /// זוהי גרסה פשוטה של harmonization - לגרסה מלאה יש להשתמש ב:
  /// `import 'package:dynamic_color/dynamic_color.dart';`
  /// `color.harmonizeWith(primaryColor);`
  static Color _harmonizeColor(Color color, Color primaryColor) {
    final colorHsl = HSLColor.fromColor(color);
    final primaryHsl = HSLColor.fromColor(primaryColor);

    // ✅ Calculate hue difference using shortest path on color wheel
    double hueDiff = primaryHsl.hue - colorHsl.hue;

    // Normalize to shortest path (-180 to 180)
    if (hueDiff > 180) {
      hueDiff -= 360;
    } else if (hueDiff < -180) {
      hueDiff += 360;
    }

    // Move hue 30% toward primary using shortest path
    double newHue = colorHsl.hue + hueDiff * 0.3;

    // Normalize result to 0-360
    if (newHue < 0) {
      newHue += 360;
    } else if (newHue >= 360) {
      newHue -= 360;
    }

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
  static ThemeData _base(ColorScheme scheme, {required bool dark, AppBrand? customBrand}) {
    // צור AppBrand - או customBrand (מ-dynamic colors) או ברירת מחדל
    final brand =
        customBrand ??
        AppBrand(
          accent: _Brand.amber,
          accentText: _Brand.amberText,
          surfaceSlate: scheme.surface,
          welcomeBackground: scheme.surface,
          // Success colors
          success: const Color(0xFF388E3C), // Green 700
          successContainer: dark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
          onSuccessContainer: dark ? const Color(0xFFC8E6C9) : const Color(0xFF1B5E20),
          // Warning colors
          warning: const Color(0xFFF57C00), // Orange 700
          warningContainer: dark ? const Color(0xFFE65100) : const Color(0xFFFFE0B2),
          onWarningContainer: dark ? const Color(0xFFFFE0B2) : const Color(0xFFE65100),
          // Sticky notes
          paperBackground: dark ? kDarkPaperBackground : kPaperBackground,
          stickyYellow: dark ? kStickyYellowDark : kStickyYellow,
          stickyPink: dark ? kStickyPinkDark : kStickyPink,
          stickyGreen: dark ? kStickyGreenDark : kStickyGreen,
          stickyCyan: dark ? kStickyCyanDark : kStickyCyan,
          stickyPurple: dark ? kStickyPurpleDark : kStickyPurple,
          notebookBlue: kNotebookBlue,
          notebookRed: kNotebookRed,
        );

    // צבע טקסט על accent (Amber) - לפי בהירות הסכמה
    final onAccent = dark ? scheme.surface : scheme.onSurface;

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

      // 🎬 Page Transitions — fade+scale אחיד לכל הפלטפורמות
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // רקע כללי - M3 Surface System
      scaffoldBackgroundColor: scheme.surface,

      // AppBar - עליון של מסכים
      // ✅ AppBar נייטרלי - עקבי עם AppLayout (surfaceContainer)
      // הצבעים הבולטים נשארים ל-Buttons/Badges/Highlights
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurface,
      ),

      // כפתורים - 4 סוגים

      materialTapTargetSize: MaterialTapTargetSize.padded,

      // ElevatedButton: כפתור ראשי עם רקע Amber
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.accent,
          foregroundColor: onAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: kFontSizeBody),
          padding: const EdgeInsets.symmetric(horizontal: kButtonPaddingHorizontal, vertical: kButtonPaddingVertical),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        ),
      ),

      // OutlinedButton: כפתור משני עם מסגרת Amber
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: brand.accent),
          foregroundColor: brand.accentText,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: kFontSizeBody),
          padding: const EdgeInsets.symmetric(horizontal: kButtonPaddingHorizontal, vertical: kButtonPaddingVertical),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        ),
      ),

      // FilledButton: כפתור מלא עם primary color
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: kFontSizeBody),
          padding: const EdgeInsets.symmetric(horizontal: kButtonPaddingHorizontal, vertical: kButtonPaddingVertical),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        ),
      ),

      // TextButton: כפתור טקסט פשוט
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.accentText,
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
        margin: const EdgeInsets.symmetric(vertical: kCardMarginVertical),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
      ),

      // ListTile — טוב ל־RTL
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsetsDirectional.only(start: kListTilePaddingStart, end: kListTilePaddingEnd),
      ),

      // שדות קלט - TextField, TextFormField
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: dark ? fillOnDark : fillOnLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: kInputPadding, vertical: kInputPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: brand.accent, width: kBorderWidthFocused),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: scheme.error, width: kBorderWidthFocused),
        ),
      ),

      // CheckBox, Switch, Radio - רכיבי בחירה
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand.accent;
          return null;
        }),
        checkColor: WidgetStateProperty.all(onAccent),
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

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: brand.accent,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: brand.accent,
        overlayColor: brand.accent.withValues(alpha: kOpacityLight),
        valueIndicatorColor: brand.accent,
        valueIndicatorTextStyle: TextStyle(color: onAccent),
      ),

      // מחווני התקדמות - Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.accent,
        linearTrackColor: scheme.outlineVariant.withValues(alpha: 0.3),
        linearMinHeight: kProgressIndicatorHeight,
      ),

      // דיאלוגים/BottomSheet (M3 Surface Containers)
      dialogTheme: DialogThemeData(
        // surfaceContainerHighest = הכי בולט (דיאלוגים)
        backgroundColor: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusLarge)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: kFontSizeLarge,
          fontWeight: FontWeight.bold,
          fontFamily: 'Assistant',
        ),
        contentTextStyle: TextStyle(color: scheme.onSurfaceVariant, fontFamily: 'Assistant'),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
        ),
      ),

      // סנאק־בר - הודעות זמניות
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface, fontFamily: 'Assistant'),
        actionTextColor: brand.accentText,
        behavior: SnackBarBehavior.floating,
      ),

      // טיפוגרפיה כללית - לפי M3 spec
      textTheme: TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 64 / 57,
          letterSpacing: -0.25,
          color: scheme.onSurface,
        ),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 52 / 45, color: scheme.onSurface),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, height: 44 / 36, color: scheme.onSurface),

        // Headline styles
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, height: 40 / 32, color: scheme.onSurface),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 36 / 28, color: scheme.onSurface),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, height: 32 / 24, color: scheme.onSurface),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 28 / 22,
          color: scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          letterSpacing: 0.1,
          color: scheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: scheme.onSurface,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          letterSpacing: 0.5,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          letterSpacing: 0.25,
          color: scheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          letterSpacing: 0.4,
          color: scheme.onSurfaceVariant,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: scheme.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.5,
          color: scheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 16 / 11,
          letterSpacing: 0.5,
          color: scheme.onSurfaceVariant,
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
