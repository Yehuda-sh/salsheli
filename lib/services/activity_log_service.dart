// 📄 File: lib/services/activity_log_service.dart
//
// שירות רישום פעילות — כותב אירועים ל-Firestore.
// fire-and-forget: לא חוסם UI, לא זורק שגיאות.
//
// 🔗 Related:
//     - ActivityEvent (models/activity_event.dart)
//     - Firestore: /households/{householdId}/activity_log/{eventId}
//
// Version: 1.0
// Last Updated: 07/04/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_event.dart';

class ActivityLogService {
  final FirebaseFirestore _firestore;

  ActivityLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// כותב אירוע פעילות ל-Firestore.
  ///
  /// fire-and-forget — לא חוסם, לא זורק.
  /// נקרא עם unawaited() מהקוד הקורא.
  Future<void> log({
    required String householdId,
    required ActivityType type,
    required String actorId,
    required String actorName,
    Map<String, dynamic> data = const {},
  }) async {
    if (householdId.isEmpty || actorId.isEmpty) return;

    try {
      final id = const Uuid().v4();
      final event = ActivityEvent(
        id: id,
        householdId: householdId,
        type: type,
        actorId: actorId,
        actorName: actorName,
        createdAt: DateTime.now(),
        data: data,
      );

      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('activity_log')
          .doc(id)
          .set(event.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ ActivityLogService.log: $e');
    }
  }
}
