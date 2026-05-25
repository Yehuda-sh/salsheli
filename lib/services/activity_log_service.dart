// lib/services/activity_log_service.dart — Activity log service — fire-and-forget logging of household events to Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_event.dart';

class ActivityLogService {
  // Stored as nullable so the constructor never touches FirebaseFirestore.instance.
  // Resolved lazily on first log() call — keeps the service safe to instantiate
  // in environments where Firebase hasn't been initialized (e.g. unit tests).
  final FirebaseFirestore? _firestoreOverride;

  ActivityLogService({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

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
