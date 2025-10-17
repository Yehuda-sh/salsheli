// 📄 File: lib/repositories/constants/repository_constants.dart
//
// 🎯 Purpose: Shared constants for all repositories
//
// Version: 1.0
// Created: 17/10/2025

/// Firestore collection names
class FirestoreCollections {
  static const String users = 'users';
  static const String households = 'households';
  static const String shoppingLists = 'shopping_lists';
  static const String inventory = 'inventory';
  static const String templates = 'templates';
  static const String receipts = 'receipts';
  static const String customLocations = 'custom_locations';
  static const String habitPreferences = 'habit_preferences';
  static const String products = 'products';
  static const String auditLogs = 'audit_logs';
  static const String notifications = 'notifications';
  
  // Prevent instantiation
  const FirestoreCollections._();
}

/// Repository configuration
class RepositoryConfig {
  /// Maximum items in a single batch operation
  static const int maxBatchSize = 500;
  
  /// Default cache duration
  static const Duration defaultCacheDuration = Duration(hours: 1);
  
  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;
  
  /// Delay between retries
  static const Duration retryDelay = Duration(milliseconds: 500);
  
  // Prevent instantiation
  const RepositoryConfig._();
}

/// Field names used across repositories
class FirestoreFields {
  // Common fields
  static const String id = 'id';
  static const String householdId = 'household_id';
  static const String userId = 'user_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String createdDate = 'created_date';
  static const String updatedDate = 'updated_date';
  
  // User fields
  static const String email = 'email';
  static const String name = 'name';
  static const String joinedAt = 'joined_at';
  static const String lastLoginAt = 'last_login_at';
  
  // Shopping list fields
  static const String listName = 'name';
  static const String listType = 'type';
  static const String listStatus = 'status';
  
  // Inventory fields
  static const String productName = 'product_name';
  static const String quantity = 'quantity';
  static const String location = 'location';
  static const String category = 'category';
  
  // Template fields
  static const String isSystem = 'is_system';
  static const String defaultFormat = 'default_format';
  static const String assignedTo = 'assigned_to';
  
  // Receipt fields
  static const String storeName = 'store_name';
  static const String date = 'date';
  static const String totalAmount = 'total_amount';
  static const String imageUrl = 'image_url';
  static const String items = 'items';
  
  // Habit fields
  static const String preferredProduct = 'preferred_product';
  static const String genericName = 'generic_name';
  static const String frequencyDays = 'frequency_days';
  static const String lastPurchased = 'last_purchased';
  
  // Prevent instantiation
  const FirestoreFields._();
}
