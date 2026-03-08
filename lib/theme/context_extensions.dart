// 📄 lib/theme/context_extensions.dart
//
// 🧩 Extension methods על BuildContext — גישה מהירה ל-Theme
// במקום לכתוב Theme.of(context).colorScheme בכל מקום.
//
// שימוש:
//   final cs = context.cs;           // ColorScheme
//   final tt = context.textTheme;    // TextTheme
//   final brand = context.brand;     // AppBrand (sticky colors etc.)
//
// 🔗 Related: app_theme.dart, design_tokens.dart

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 🧩 גישה מהירה ל-Theme דרך BuildContext
extension ThemeContextX on BuildContext {
  /// ColorScheme — צבעים ראשיים (primary, error, surface...)
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// TextTheme — סגנונות טקסט (bodySmall, titleLarge...)
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// AppBrand — צבעי מותג (sticky notes, success, warning...)
  AppBrand get brand => Theme.of(this).extension<AppBrand>()!;

  /// ThemeData המלא (לשימוש נדיר)
  ThemeData get theme => Theme.of(this);

  /// האם אנחנו ב-Dark Mode?
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// 📐 גישה מהירה ל-MediaQuery
extension MediaContextX on BuildContext {
  /// רוחב המסך
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// גובה המסך
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// padding (safe area)
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// האם מסך צר (טלפון portrait)
  bool get isNarrow => screenWidth < 360;

  /// האם מסך רחב (tablet)
  bool get isWide => screenWidth > 600;
}
