// 📄 File: lib/models/enums/suggestion_status.dart
//
// 🇮🇱 סטטוס המלצה חכמה:
//     - pending: ממתין להחלטת משתמש
//     - added: נוסף לרשימת קניות
//     - dismissed: נדחה זמנית (ידווח שוב בהמשך)
//     - deleted: נמחק (לא להציע יותר)
//
// 🇬🇧 Smart suggestion status:
//     - pending: Waiting for user decision
//     - added: Added to shopping list
//     - dismissed: Temporarily dismissed (will show again later)
//     - deleted: Deleted (don't suggest anymore)

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 סטטוס המלצה חכמה
/// 🇬🇧 Smart suggestion status
@JsonEnum(valueField: 'value')
enum SuggestionStatus {
  /// 🔵 ממתין להחלטת משתמש
  pending('pending'),

  /// ✅ נוסף לרשימת קניות
  added('added'),

  /// ⏭️ נדחה זמנית (ידווח שוב בהמשך)
  dismissed('dismissed'),

  /// ❌ נמחק (לא להציע יותר)
  deleted('deleted');

  const SuggestionStatus(this.value);

  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized status names are needed.

  /// 🇮🇱 האם הסטטוס ממתין (pending)
  /// 🇬🇧 Is the status pending
  ///
  /// Note: For full "is active" check including `dismissedUntil`,
  /// use `SmartSuggestion.isActive` instead.
  bool get isPending => this == SuggestionStatus.pending;

  /// 🇮🇱 האם נוסף לרשימה
  /// 🇬🇧 Was it added to a list
  bool get wasAdded => this == SuggestionStatus.added;

  /// 🇮🇱 האם נדחה זמנית
  /// 🇬🇧 Was it temporarily dismissed
  bool get wasDismissed => this == SuggestionStatus.dismissed;

  /// 🇮🇱 האם נמחק לצמיתות
  /// 🇬🇧 Was it permanently deleted
  bool get wasDeleted => this == SuggestionStatus.deleted;
}
