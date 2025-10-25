// 📄 File: lib/services/suggestions_service.dart
//
// 🇮🇱 שירות המלצות חכמות:
//     - מנתח מלאי במזווה ומייצר המלצות
//     - תומך בדחייה זמנית (יום/שבוע/חודש/לעולם)
//     - מנהל תור המלצות (queue)
//     - מעקב אחרי סטטוס (pending/added/dismissed/deleted)
//
// 🔁 תהליך עבודה:
//     1. generateSuggestions() - סורק מזווה, מוצא מוצרים שאוזלים
//     2. getNextSuggestion() - מביא המלצה הבאה מהתור
//     3. dismissSuggestion() - דוחה זמנית (שבוע)
//     4. deleteSuggestion() - מוחק (יום/שבוע/חודש/לעולם)
//     5. markAsAdded() - מסמן שנוסף לרשימה
//
// 💡 אלגוריתם דחיפות:
//     - אזל לגמרי (0) → critical (אדום)
//     - < 20% מהסף → high (כתום)
//     - < 50% מהסף → medium (צהוב)
//     - אחרת → low (ירוק)
//
// 🇬🇧 Smart suggestions service:
//     - Analyzes pantry inventory and generates suggestions
//     - Supports temporary dismissal (day/week/month/forever)
//     - Manages suggestions queue
//     - Tracks status (pending/added/dismissed/deleted)

import 'package:flutter/foundation.dart';
import '../models/smart_suggestion.dart';
import '../models/inventory_item.dart';
import '../models/enums/suggestion_status.dart';
import 'package:uuid/uuid.dart';

/// 🇮🇱 שירות המלצות חכמות
/// 🇬🇧 Smart suggestions service
class SuggestionsService {
  static const Uuid _uuid = Uuid();

  // ---- Constants ----

  /// 🇮🇱 סף ברירת מחדל למוצרים (5 יחידות)
  /// 🇬🇧 Default threshold for products (5 units)
  static const int defaultThreshold = 5;

  /// 🇮🇱 משך דחייה ברירת מחדל (7 ימים)
  /// 🇬🇧 Default dismissal duration (7 days)
  static const Duration defaultDismissalDuration = Duration(days: 7);

  // ---- Core Methods ----

  /// 🇮🇱 יצירת המלצות ממלאי נמוך
  /// 🇬🇧 Generate suggestions from low inventory
  /// 
  /// פרמטרים:
  /// - inventoryItems: רשימת פריטי מזווה
  /// - customThresholds: ספים מותאמים אישית למוצרים (productName -> threshold)
  /// - excludedProducts: מוצרים שלא להציע (מוצרים שנמחקו לצמיתות)
  /// 
  /// מחזיר: רשימת המלצות חכמות
  static List<SmartSuggestion> generateSuggestions({
    required List<InventoryItem> inventoryItems,
    Map<String, int>? customThresholds,
    Set<String>? excludedProducts,
  }) {
    if (kDebugMode) {
      debugPrint('🧠 SuggestionsService.generateSuggestions():');
      debugPrint('   📦 Total inventory items: ${inventoryItems.length}');
    }

    final suggestions = <SmartSuggestion>[];
    final now = DateTime.now();

    for (final item in inventoryItems) {
      // בדיקה: האם המוצר לא נמחק לצמיתות
      if (excludedProducts?.contains(item.productName) ?? false) {
        if (kDebugMode) {
          debugPrint('   ⏭️ Skipping excluded: ${item.productName}');
        }
        continue;
      }

      // קביעת סף (custom או default)
      final threshold = customThresholds?[item.productName] ?? defaultThreshold;

      // בדיקה: האם המלאי נמוך מהסף
      if (item.quantity < threshold) {
        final suggestion = SmartSuggestion.fromInventory(
          id: _uuid.v4(),
          productId: item.id,
          productName: item.productName,
          category: item.category,
          currentStock: item.quantity,
          threshold: threshold,
          unit: item.unit,
          now: now,
        );

        suggestions.add(suggestion);

        if (kDebugMode) {
          debugPrint(
            '   💡 Created suggestion: ${item.productName} '
            '(${{ item.quantity}}/$threshold) - ${suggestion.urgency}',
          );
        }
      }
    }

    // מיון לפי דחיפות: critical → high → medium → low
    suggestions.sort((a, b) {
      const urgencyOrder = {
        'critical': 0,
        'high': 1,
        'medium': 2,
        'low': 3,
      };

      final urgencyA = urgencyOrder[a.urgency] ?? 999;
      final urgencyB = urgencyOrder[b.urgency] ?? 999;

      if (urgencyA != urgencyB) {
        return urgencyA.compareTo(urgencyB);
      }

      // אם אותה רמת דחיפות, מיין לפי שם
      return a.productName.compareTo(b.productName);
    });

    if (kDebugMode) {
      debugPrint('   ✅ Generated ${suggestions.length} suggestions');
      if (suggestions.isNotEmpty) {
        debugPrint('   🥇 Top suggestion: ${suggestions.first.productName} '
            '(${suggestions.first.urgency})');
      }
    }

    return suggestions;
  }

  /// 🇮🇱 סינון המלצות פעילות בלבד
  /// 🇬🇧 Filter only active suggestions
  /// 
  /// מחזיר רק המלצות ב-status: pending ולא נדחו
  static List<SmartSuggestion> getActiveSuggestions(
    List<SmartSuggestion> suggestions,
  ) {
    final now = DateTime.now();
    return suggestions.where((s) {
      // רק pending
      if (s.status != SuggestionStatus.pending) return false;

      // לא נדחתה או שזמן הדחייה עבר
      if (s.dismissedUntil == null) return true;
      return now.isAfter(s.dismissedUntil!);
    }).toList();
  }

  /// 🇮🇱 קבלת ההמלצה הבאה מהתור
  /// 🇬🇧 Get the next suggestion from the queue
  /// 
  /// מחזיר את ההמלצה הדחופה ביותר שעדיין פעילה
  static SmartSuggestion? getNextSuggestion(
    List<SmartSuggestion> suggestions,
  ) {
    final active = getActiveSuggestions(suggestions);

    if (active.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔵 No active suggestions available');
      }
      return null;
    }

    // ההמלצה הראשונה היא הדחופה ביותר (כבר ממוין)
    final next = active.first;

    if (kDebugMode) {
      debugPrint('🎯 Next suggestion: ${next.productName} (${next.urgency})');
    }

    return next;
  }

  /// 🇮🇱 דחיית המלצה זמנית
  /// 🇬🇧 Dismiss suggestion temporarily
  /// 
  /// דוחה את ההמלצה למשך זמן מסוים (ברירת מחדל: שבוע)
  static SmartSuggestion dismissSuggestion(
    SmartSuggestion suggestion, {
    const Duration duration = defaultDismissalDuration,
  }) {
    final dismissedUntil = DateTime.now().add(duration);

    if (kDebugMode) {
      debugPrint('⏭️ Dismissing: ${suggestion.productName}');
      debugPrint('   Until: ${dismissedUntil.toIso8601String()}');
    }

    return suggestion.copyWith(
      status: SuggestionStatus.dismissed,
      dismissedUntil: dismissedUntil,
    );
  }

  /// 🇮🇱 מחיקת המלצה (זמנית או קבועה)
  /// 🇬🇧 Delete suggestion (temporary or permanent)
  /// 
  /// פרמטרים:
  /// - duration: null = לצמיתות, Duration = זמני
  /// 
  /// דוגמאות:
  /// - deleteSuggestion(s, duration: null) → לעולם לא
  /// - deleteSuggestion(s, duration: Duration(days: 1)) → יום אחד
  /// - deleteSuggestion(s, duration: Duration(days: 7)) → שבוע
  /// - deleteSuggestion(s, duration: Duration(days: 30)) → חודש
  static SmartSuggestion deleteSuggestion(
    SmartSuggestion suggestion, {
    Duration? duration,
  }) {
    if (duration == null) {
      // מחיקה קבועה
      if (kDebugMode) {
        debugPrint('❌ Deleting permanently: ${suggestion.productName}');
      }

      return suggestion.copyWith(
        status: SuggestionStatus.deleted,
        dismissedUntil: null,
      );
    } else {
      // מחיקה זמנית (כמו dismiss)
      final dismissedUntil = DateTime.now().add(duration);

      if (kDebugMode) {
        debugPrint('❌ Deleting temporarily: ${suggestion.productName}');
        debugPrint('   Until: ${dismissedUntil.toIso8601String()}');
      }

      return suggestion.copyWith(
        status: SuggestionStatus.dismissed,
        dismissedUntil: dismissedUntil,
      );
    }
  }

  /// 🇮🇱 סימון המלצה כנוספה לרשימה
  /// 🇬🇧 Mark suggestion as added to list
  /// 
  /// משנה סטטוס ל-added ושומר איזו רשימה נוספה אליה
  static SmartSuggestion markAsAdded(
    SmartSuggestion suggestion, {
    required String listId,
  }) {
    if (kDebugMode) {
      debugPrint('✅ Marking as added: ${suggestion.productName}');
      debugPrint('   To list: $listId');
    }

    return suggestion.copyWith(
      status: SuggestionStatus.added,
      addedAt: DateTime.now(),
      addedToListId: listId,
    );
  }

  /// 🇮🇱 קבלת משך זמן לפי בחירת משתמש
  /// 🇬🇧 Get duration based on user choice
  /// 
  /// מחזיר Duration לפי טקסט או null ללצמיתות
  static Duration? getDurationFromChoice(String choice) {
    switch (choice) {
      case 'day':
        return const Duration(days: 1);
      case 'week':
        return const Duration(days: 7);
      case 'month':
        return const Duration(days: 30);
      case 'forever':
        return null; // לצמיתות
      default:
        return defaultDismissalDuration; // ברירת מחדל: שבוע
    }
  }

  /// 🇮🇱 קבלת טקסט תיאור משך זמן
  /// 🇬🇧 Get duration description text
  static String getDurationText(Duration? duration) {
    if (duration == null) return 'לעולם לא';
    if (duration.inDays == 1) return 'יום אחד';
    if (duration.inDays == 7) return 'שבוע';
    if (duration.inDays == 30) return 'חודש';
    return '${duration.inDays} ימים';
  }

  // ---- Statistics & Analysis ----

  /// 🇮🇱 קבלת סטטיסטיקה על המלצות
  /// 🇬🇧 Get suggestions statistics
  static Map<String, int> getSuggestionsStats(
    List<SmartSuggestion> suggestions,
  ) {
    final stats = <String, int>{
      'total': suggestions.length,
      'active': 0,
      'critical': 0,
      'high': 0,
      'medium': 0,
      'low': 0,
      'added': 0,
      'dismissed': 0,
      'deleted': 0,
    };

    for (final s in suggestions) {
      // סטטוס
      switch (s.status) {
        case SuggestionStatus.pending:
          if (s.isActive) stats['active'] = (stats['active'] ?? 0) + 1;
          break;
        case SuggestionStatus.added:
          stats['added'] = (stats['added'] ?? 0) + 1;
          break;
        case SuggestionStatus.dismissed:
          stats['dismissed'] = (stats['dismissed'] ?? 0) + 1;
          break;
        case SuggestionStatus.deleted:
          stats['deleted'] = (stats['deleted'] ?? 0) + 1;
          break;
      }

      // דחיפות (רק למלצות פעילות)
      if (s.isActive) {
        final key = s.urgency;
        stats[key] = (stats[key] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// 🇮🇱 בדיקה אם יש המלצות דחופות
  /// 🇬🇧 Check if there are urgent suggestions
  static bool hasUrgentSuggestions(List<SmartSuggestion> suggestions) {
    return getActiveSuggestions(suggestions)
        .any((s) => s.urgency == 'critical' || s.urgency == 'high');
  }

  /// 🇮🇱 קבלת כמות המלצות פעילות
  /// 🇬🇧 Get count of active suggestions
  static int getActiveSuggestionsCount(List<SmartSuggestion> suggestions) {
    return getActiveSuggestions(suggestions).length;
  }
}
