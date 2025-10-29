// 📄 File: lib/config/list_types_config.dart
//
// 📋 List Types Configuration
// 
// Defines the 8 smart list types with their properties:
// - name: Display name in Hebrew
// - icon: Emoji representation
// - description: Brief description
//
// Used by:
// - create_list_dialog.dart - List type selection UI
// - list_type_filter_service.dart - Product filtering logic
//
// Related: WORK_PLAN.md Phase 1 (List Types)
//
// Version: 1.0
// Created: 29/10/2025

/// Configuration for the 8 smart list types
/// 
/// Each type filters products from different categories:
/// - supermarket: All products (5000+)
/// - pharmacy: Hygiene & cleaning products
/// - greengrocer: Fruits & vegetables
/// - butcher: Meat & poultry
/// - bakery: Bread & pastries
/// - market: Mixed fresh products
/// - household: Custom household items
/// - other: Fallback for uncategorized items
const Map<String, Map<String, String>> kListTypes = {
  'supermarket': {
    'name': 'סופרמרקט',
    'icon': '🛒',
    'description': 'קניות כלליות - כל המוצרים',
  },
  'pharmacy': {
    'name': 'בית מרקחת',
    'icon': '💊',
    'description': 'היגיינה וניקיון',
  },
  'greengrocer': {
    'name': 'ירקן',
    'icon': '🥬',
    'description': 'פירות וירקות טריים',
  },
  'butcher': {
    'name': 'אטליז',
    'icon': '🥩',
    'description': 'בשר ועוף',
  },
  'bakery': {
    'name': 'מאפייה',
    'icon': '🍞',
    'description': 'לחם ומאפים',
  },
  'market': {
    'name': 'שוק',
    'icon': '🧺',
    'description': 'מוצרים טריים מעורבבים',
  },
  'household': {
    'name': 'כלי בית',
    'icon': '🏠',
    'description': 'פריטים מותאמים אישית',
  },
  'other': {
    'name': 'אחר',
    'icon': '📦',
    'description': 'קטגוריה כללית',
  },
};

/// Get list of all type keys
List<String> get allListTypes => kListTypes.keys.toList();

/// Check if a type is valid
bool isValidListType(String type) => kListTypes.containsKey(type);

/// Get display name for a type
String getListTypeName(String type) => kListTypes[type]?['name'] ?? 'לא ידוע';

/// Get icon for a type
String getListTypeIcon(String type) => kListTypes[type]?['icon'] ?? '📦';

/// Get description for a type
String getListTypeDescription(String type) => 
    kListTypes[type]?['description'] ?? 'אין תיאור';
