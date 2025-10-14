// 📄 File: lib/repositories/firebase_locations_repository.dart
//
// 🎯 Purpose: מימוש Firebase למאגר מיקומי אחסון מותאמים
//
// 🏗️ Architecture: Repository Pattern Implementation
//     - מממש את LocationsRepository interface
//     - מתקשר עם Firestore collection: custom_locations
//     - מסנן לפי household_id
//
// 🔥 Firestore Structure:
//     custom_locations/{id}
//       ├─ key: String (unique per household)
//       ├─ name: String
//       ├─ emoji: String
//       ├─ household_id: String
//       └─ created_at: Timestamp
//
// 🔐 Security: כל הפעולות מסננות לפי household_id
//
// 📦 Dependencies:
//     - cloud_firestore
//     - CustomLocation model
//
// Version: 1.0
// Created: 13/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/custom_location.dart';
import 'locations_repository.dart';

/// מימוש Firebase של LocationsRepository
class FirebaseLocationsRepository implements LocationsRepository {
  final FirebaseFirestore _firestore;

  /// שם ה-collection ב-Firestore
  static const String collectionName = 'custom_locations';

  /// Constructor
  /// 
  /// Parameters:
  /// - firestore: instance של FirebaseFirestore (default: FirebaseFirestore.instance)
  FirebaseLocationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CustomLocation>> fetchLocations(String householdId) async {
    debugPrint('📥 FirebaseLocationsRepository.fetchLocations: household=$householdId');

    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('household_id', isEqualTo: householdId)
          .orderBy('created_at', descending: false)
          .get();

      final locations = snapshot.docs.map((doc) {
        final data = doc.data();
        return CustomLocation.fromJson(data);
      }).toList();

      debugPrint('✅ FirebaseLocationsRepository: נטענו ${locations.length} מיקומים');
      
      // Log כל מיקום
      for (var loc in locations) {
        debugPrint('   ${loc.emoji} ${loc.name} (${loc.key})');
      }

      return locations;
    } catch (e, st) {
      debugPrint('❌ FirebaseLocationsRepository.fetchLocations: שגיאה - $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> saveLocation(
    CustomLocation location,
    String householdId,
  ) async {
    debugPrint('💾 FirebaseLocationsRepository.saveLocation: ${location.name} (household=$householdId)');

    try {
      final data = location.toJson();
      data['household_id'] = householdId; // הוספת household_id
      data['created_at'] = FieldValue.serverTimestamp();

      // שימוש ב-key כ-document ID (ייחודי per household)
      final docId = '${householdId}_${location.key}';
      
      await _firestore.collection(collectionName).doc(docId).set(
            data,
            SetOptions(merge: true),
          );

      debugPrint('✅ FirebaseLocationsRepository: מיקום נשמר - ${location.emoji} ${location.name}');
    } catch (e, st) {
      debugPrint('❌ FirebaseLocationsRepository.saveLocation: שגיאה - $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteLocation(String key, String householdId) async {
    debugPrint('🗑️ FirebaseLocationsRepository.deleteLocation: $key (household=$householdId)');

    try {
      final docId = '${householdId}_$key';
      
      await _firestore.collection(collectionName).doc(docId).delete();

      debugPrint('✅ FirebaseLocationsRepository: מיקום נמחק - $key');
    } catch (e, st) {
      debugPrint('❌ FirebaseLocationsRepository.deleteLocation: שגיאה - $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
