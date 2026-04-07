// 📄 File: lib/repositories/activity_log_repository.dart
//
// Repository לקריאת אירועי פעילות מ-Firestore.
// כתיבה מתבצעת דרך ActivityLogService (fire-and-forget).
//
// Firestore: /households/{householdId}/activity_log/{eventId}
//
// Version: 1.0
// Last Updated: 07/04/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity_event.dart';
import 'utils/firestore_utils.dart';

class ActivityLogRepository {
  final FirebaseFirestore _firestore;

  ActivityLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String householdId) =>
      _firestore
          .collection('households')
          .doc(householdId)
          .collection('activity_log');

  /// טוען אירועים, ממוין מהחדש לישן, מוגבל ל-[limit]
  Future<List<ActivityEvent>> fetchEvents(
    String householdId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _collection(householdId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.toDartMap()!;
          data['id'] ??= doc.id;
          return ActivityEvent.fromJson(data);
        } catch (e) {
          if (kDebugMode) debugPrint('⚠️ Failed to parse activity ${doc.id}: $e');
          return null;
        }
      }).whereType<ActivityEvent>().toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ActivityLogRepository.fetchEvents: $e');
      return [];
    }
  }

  /// מוחק אירועים ישנים מעל [days] ימים
  Future<void> deleteOldEvents(String householdId, {int days = 90}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _collection(householdId)
          .where('created_at', isLessThan: Timestamp.fromDate(cutoff))
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (kDebugMode) {
        debugPrint('🗑️ ActivityLog: נמחקו ${snapshot.docs.length} אירועים ישנים');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ActivityLog.deleteOldEvents: $e');
    }
  }
}
