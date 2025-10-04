// 📄 File: lib/models/mappers/shopping_list_api_mapper.dart
//
// 🇮🇱 קובץ זה מטפל במיפוי (Mapping) דו־כיווני בין מודל השרת ApiShoppingList
//     לבין המודל הפנימי ShoppingList של האפליקציה.
//     המטרה: לשמור על ארכיטקטורה נקייה והפרדה בין שכבת ה־API ללוגיקה פנימית.
//
// 🇬🇧 This file handles bi-directional mapping between the API model
//     (ApiShoppingList) and the app's internal model (ShoppingList).
//     Goal: keep clean architecture separating API layer from app logic.
//

import '../../api/entities/shopping_list.dart' as api;
import '../receipt.dart';
import '../shopping_list.dart';

/// 🇮🇱 הרחבה על ApiShoppingList להמרה ל־ShoppingList פנימי.
/// 🇬🇧 Extension on ApiShoppingList to convert into an internal ShoppingList.
extension ApiShoppingListMapper on api.ApiShoppingList {
  ShoppingList toInternal({
    required String createdBy,
    String status = ShoppingList.statusActive,
    List<ReceiptItem> items = const [],
    List<String> sharedWith = const [],
    bool isShared = false,
  }) {
    return ShoppingList(
      id: id,
      name: name,
      updatedDate: _parseApiDate(updatedDate) ?? DateTime.now(),
      status: status,
      isShared: isShared,
      createdBy: createdBy,
      sharedWith: List<String>.unmodifiable(sharedWith),
      items: List<ReceiptItem>.unmodifiable(items),
    );
  }
}

/// 🇮🇱 הרחבה על ShoppingList להמרה חזרה ל־ApiShoppingList (לשליחה לשרת).
/// 🇬🇧 Extension on ShoppingList to convert back into ApiShoppingList (for sync).
extension ShoppingListApiMapper on ShoppingList {
  api.ApiShoppingList toApi(String householdId) {
    return api.ApiShoppingList(
      id: id,
      name: name,
      householdId: householdId,
      updatedDate: updatedDate.toIso8601String(),
    );
  }
}

/// 🇮🇱 ממיר מחרוזת תאריך ISO ל־DateTime (או null אם לא תקין).
/// 🇬🇧 Converts an ISO date string into DateTime (or null if invalid).
DateTime? _parseApiDate(String? iso) =>
    (iso == null || iso.isEmpty) ? null : DateTime.tryParse(iso);
