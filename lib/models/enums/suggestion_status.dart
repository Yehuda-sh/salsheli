// lib/models/enums/suggestion_status.dart — Suggestion status enum — pending, added, dismissed, skipped, unknown

import 'package:json_annotation/json_annotation.dart';

/// 🇮🇱 סטטוס המלצה חכמה
/// 🇬🇧 Smart suggestion status
@JsonEnum(valueField: 'value')
enum SuggestionStatus {
  /// 🔵 ממתין להחלטת משתמש
  pending('pending'),

  /// ✅ נוסף לרשימת קניות
  added('added'),

  /// ⏭️ נדחה זמנית (יוצג שוב בהמשך)
  dismissed('dismissed'),

  /// ❌ נמחק (לא להציע יותר)
  deleted('deleted'),

  /// ❓ סטטוס לא מוכר (fallback למניעת קריסה)
  /// Used when server returns an unknown status value
  unknown('unknown');

  const SuggestionStatus(this.value);

  final String value;

  // Note: hebrewName and emoji were removed - use AppStrings in UI layer
  // if localized status names are needed.

  /// האם זה סטטוס תקין (לא unknown)
  bool get isKnown => this != SuggestionStatus.unknown;

  /// 🇮🇱 האם הסטטוס ממתין (pending) - כולל unknown שלא ייעלמו
  /// 🇬🇧 Is the status pending (includes unknown so they don't disappear)
  ///
  /// Note: For full "is active" check including `dismissedUntil`,
  /// use `SmartSuggestion.isActive` instead.
  bool get isPending => this == SuggestionStatus.pending || this == SuggestionStatus.unknown;

  /// 🇮🇱 האם נוסף לרשימה
  /// 🇬🇧 Was it added to a list
  bool get wasAdded => this == SuggestionStatus.added;

  /// 🇮🇱 האם נדחה זמנית
  /// 🇬🇧 Was it temporarily dismissed
  bool get wasDismissed => this == SuggestionStatus.dismissed;

  /// 🇮🇱 האם נמחק לצמיתות
  /// 🇬🇧 Was it permanently deleted
  bool get wasDeleted => this == SuggestionStatus.deleted;

  /// 🇮🇱 האם הסטטוס "סגור" (added/deleted)
  /// 🇬🇧 Is the status "closed" (added/deleted)
  bool get isClosed => wasAdded || wasDeleted;
}
