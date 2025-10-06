// 📄 File: lib/widgets/mini_chart.dart
// תיאור: תרשים עמודות מיניאטורי (Bar Chart) למידע מהיר
//
// Purpose:
// וידג'ט תרשים עמודות קומפקטי להצגת מידע סטטיסטי בצורה ויזואלית.
// מתאים במיוחד ל-dashboards, כרטיסי סיכום, ותצוגות מהירות.
//
// Features:
// - תצוגה קומפקטית של נתונים (גובה ברירת מחדל 40px)
// - תמיכה בצבעים דינמיים לכל עמודה
// - Tooltip אינטראקטיבי בלחיצה
// - Empty state אוטומטי
// - Error handling מובנה
// - תואם Material Design: theme colors, accessibility
//
// Dependencies:
// - fl_chart package (^0.68.0)
// - Theme colors (AppBrand)
//
// Usage:
//
// Example 1 - Basic (צבע אחיד):
// ```dart
// MiniChart(
//   data: [
//     {'value': 10},
//     {'value': 25},
//     {'value': 15},
//     {'value': 30},
//   ],
//   color: Colors.blue,
//   height: 50,
// )
// ```
//
// Example 2 - Custom colors per bar:
// ```dart
// MiniChart(
//   data: [
//     {'value': 10, 'color': Colors.red},
//     {'value': 25, 'color': Colors.green},
//     {'value': 15, 'color': '#FF5733'}, // HEX support
//     {'value': 30, 'color': Colors.blue},
//   ],
// )
// ```
//
// Example 3 - Custom data key:
// ```dart
// MiniChart(
//   data: [
//     {'count': 100, 'color': Colors.purple},
//     {'count': 200, 'color': Colors.orange},
//   ],
//   dataKey: 'count', // instead of default 'value'
//   accessibilityLabel: 'תרשים מכירות שבועי',
// )
// ```
//
// Version: 2.0

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kDefaultHeight = 40.0;
const double _kBarWidth = 10.0;
const double _kBarBorderRadius = 2.0;
const double _kEmptyStateFontSize = 12.0;

// ============================
// MiniChart Widget
// ============================

class MiniChart extends StatelessWidget {
  /// רשימת נתונים להצגה
  /// כל item צריך להכיל: { "value": num, "color"?: Color/String }
  final List<Map<String, dynamic>> data;

  /// צבע ברירת מחדל לעמודות (אם לא מוגדר בdata)
  final Color? color;

  /// גובה התרשים
  final double height;

  /// שם המפתח לערך בכל item (ברירת מחדל: "value")
  final String dataKey;

  /// תיאור נגישות לתרשים
  final String accessibilityLabel;

  const MiniChart({
    super.key,
    required this.data,
    this.color,
    this.height = _kDefaultHeight,
    this.dataKey = 'value',
    this.accessibilityLabel = 'תרשים עמודות מיני',
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('📊 MiniChart.build()');
    debugPrint('   📦 data.length: ${data.length}');
    debugPrint('   📏 height: $height');
    debugPrint('   🔑 dataKey: $dataKey');

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    // צבע ברירת מחדל מ-theme
    final defaultColor = color ?? brand?.accent ?? cs.primary;
    debugPrint('   🎨 defaultColor: ${defaultColor.value.toRadixString(16)}');

    // מצב ריק
    if (data.isEmpty) {
      debugPrint('   ⚠️  data ריק - מציג Empty State');
      return Semantics(
        label: 'אין נתונים להצגה בתרשים',
        child: Center(
          child: Text(
            'אין נתונים להצגה',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _kEmptyStateFontSize,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: '$accessibilityLabel: ${data.length} נקודות מידע',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            titlesData: const FlTitlesData(
              show: false, // בלי טקסטים מסביב - תרשים מינימליסטי
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final value = rod.toY;
                  return BarTooltipItem(
                    value.toStringAsFixed(0),
                    TextStyle(
                      color: cs.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            barGroups: _buildBarGroups(defaultColor),
          ),
        ),
      ),
    );
  }

  /// בונה את קבוצות העמודות
  List<BarChartGroupData> _buildBarGroups(Color defaultColor) {
    debugPrint('   🔨 MiniChart._buildBarGroups()');
    
    int successCount = 0;
    int errorCount = 0;

    final groups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      // שליפת הערך
      double value = 0.0;
      try {
        final rawValue = item[dataKey];
        if (rawValue is num) {
          value = rawValue.toDouble();
          successCount++;
        } else {
          errorCount++;
          debugPrint('      ❌ item[$index]: "$dataKey" לא מספר (${rawValue.runtimeType})');
        }
      } catch (e) {
        errorCount++;
        debugPrint('      ❌ item[$index]: שגיאה בקריאת "$dataKey" - $e');
      }

      // שליפת הצבע
      Color barColor = defaultColor;
      try {
        final colorData = item['color'];
        if (colorData != null) {
          barColor = _parseColor(colorData, defaultColor);
        }
      } catch (e) {
        // אם יש שגיאה בפרסום הצבע, נשתמש בברירת מחדל
        debugPrint('      ⚠️  item[$index]: שגיאה בפרסום "color" - $e (משתמש בdefault)');
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_kBarBorderRadius),
              topRight: Radius.circular(_kBarBorderRadius),
            ),
            width: _kBarWidth,
          ),
        ],
      );
    }).toList();

    debugPrint('      ✅ נוצרו $successCount עמודות בהצלחה');
    if (errorCount > 0) {
      debugPrint('      ⚠️  $errorCount שגיאות בקריאת ערכים');
    }

    return groups;
  }

  /// ממיר צבע מ-Color או String HEX
  Color _parseColor(dynamic input, Color fallback) {
    if (input is Color) {
      return input;
    }

    if (input is String && input.startsWith('#')) {
      try {
        final hex = input.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          // תמיכה ב-alpha channel
          return Color(int.parse('0x$hex'));
        }
      } catch (e) {
        debugPrint('      ⚠️  _parseColor: לא הצלחתי להמיר "$input" - $e (משתמש בfallback)');
      }
    }

    return fallback;
  }
}
