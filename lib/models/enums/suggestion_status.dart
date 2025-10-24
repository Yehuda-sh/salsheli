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

  /// 🇮🇱 שם בעברית
  /// 🇬🇧 Hebrew name
  String get hebrewName {
    switch (this) {
      case SuggestionStatus.pending:
        return 'ממתין';
      case SuggestionStatus.added:
        return 'נוסף';
      case SuggestionStatus.dismissed:
        return 'נדחה';
      case SuggestionStatus.deleted:
        return 'נמחק';
    }
  }

  /// 🇮🇱 אמוג'י מייצג
  /// 🇬🇧 Representative emoji
  String get emoji {
    switch (this) {
      case SuggestionStatus.pending:
        return '🔵';
      case SuggestionStatus.added:
        return '✅';
      case SuggestionStatus.dismissed:
        return '⏭️';
      case SuggestionStatus.deleted:
        return '❌';
    }
  }

  /// 🇮🇱 האם ההמלצה פעילה (pending)
  /// 🇬🇧 Is the suggestion active (pending)
  bool get isActive => this == SuggestionStatus.pending;

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
