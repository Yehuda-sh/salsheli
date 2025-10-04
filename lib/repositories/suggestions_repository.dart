// 📄 File: lib/repositories/suggestions_repository.dart
// תיאור: Repository לניהול המלצות - ממשק Mock פשוט

import '../models/suggestion.dart';

/// === Contract ===
abstract class SuggestionsRepository {
  Future<List<Suggestion>> fetchSuggestions(String householdId);
}

/// === Mock Implementation ===
class MockSuggestionsRepository implements SuggestionsRepository {
  @override
  Future<List<Suggestion>> fetchSuggestions(String householdId) async {
    // סימולציה של latency
    await Future.delayed(const Duration(milliseconds: 300));

    // מחזיר רשימה ריקה - ה-Provider יחשב המלצות אמיתיות
    return [];
  }
}
