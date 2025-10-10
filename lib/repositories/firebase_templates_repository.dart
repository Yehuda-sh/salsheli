// 📄 File: lib/repositories/firebase_templates_repository.dart
//
// 🇮🇱 Repository לתבניות רשימות עם Firestore:
//     - שמירת תבניות ב-Firestore
//     - טעינת תבניות (system + personal + shared + assigned)
//     - עדכון תבניות
//     - מחיקת תבניות (רק אם user_id=שלי וגם is_system=false)
//     - Real-time updates
//
// 🇬🇧 Templates repository with Firestore:
//     - Save templates to Firestore
//     - Load templates (system + personal + shared + assigned)
//     - Update templates
//     - Delete templates (only if user_id=mine and is_system=false)
//     - Real-time updates
//
// 📝 Version: 1.0 - Initial templates repository with Firebase
// 📅 Last Updated: 10/10/2025
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/template.dart';
import 'templates_repository.dart';

class FirebaseTemplatesRepository implements TemplatesRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'templates';

  FirebaseTemplatesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // === Fetch Templates ===

  @override
  Future<List<Template>> fetchTemplates({
    String? userId,
    String? householdId,
  }) async {
    try {
      debugPrint(
        '📥 FirebaseTemplatesRepository.fetchTemplates: טוען תבניות (user: $userId, household: $householdId)',
      );

      // אסטרטגיה: טוען הכל בשאילתות נפרדות ומאחד
      final List<Template> allTemplates = [];

      // 1️⃣ תבניות מערכת (כולם רואים)
      final systemTemplates = await fetchSystemTemplates();
      allTemplates.addAll(systemTemplates);
      debugPrint('✅ נטענו ${systemTemplates.length} תבניות מערכת');

      // 2️⃣ תבניות אישיות (רק שלי)
      if (userId != null) {
        final personalTemplates = await _fetchPersonalTemplates(userId);
        allTemplates.addAll(personalTemplates);
        debugPrint('✅ נטענו ${personalTemplates.length} תבניות אישיות');
      }

      // 3️⃣ תבניות משותפות (household)
      if (householdId != null) {
        final sharedTemplates = await _fetchSharedTemplates(householdId);
        allTemplates.addAll(sharedTemplates);
        debugPrint('✅ נטענו ${sharedTemplates.length} תבניות משותפות');
      }

      // 4️⃣ תבניות מוקצות לי
      if (userId != null) {
        final assignedTemplates = await _fetchAssignedTemplates(userId);
        allTemplates.addAll(assignedTemplates);
        debugPrint('✅ נטענו ${assignedTemplates.length} תבניות מוקצות');
      }

      debugPrint(
        '✅ FirebaseTemplatesRepository.fetchTemplates: סה"כ ${allTemplates.length} תבניות',
      );
      return allTemplates;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseTemplatesRepository.fetchTemplates: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to fetch templates',
        e,
      );
    }
  }

  // === Helper Methods ===

  Future<List<Template>> _fetchPersonalTemplates(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('is_system', isEqualTo: false)
        .where('user_id', isEqualTo: userId)
        .where('default_format', isEqualTo: 'personal')
        .orderBy('updated_date', descending: true)
        .get();

    return _parseTemplates(snapshot);
  }

  Future<List<Template>> _fetchSharedTemplates(String householdId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('is_system', isEqualTo: false)
        .where('household_id', isEqualTo: householdId)
        .where('default_format', isEqualTo: 'shared')
        .orderBy('updated_date', descending: true)
        .get();

    return _parseTemplates(snapshot);
  }

  Future<List<Template>> _fetchAssignedTemplates(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('is_system', isEqualTo: false)
        .where('default_format', isEqualTo: 'assigned')
        .where('assigned_to', arrayContains: userId)
        .orderBy('updated_date', descending: true)
        .get();

    return _parseTemplates(snapshot);
  }

  List<Template> _parseTemplates(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      return Template.fromJson(data);
    }).toList();
  }

  // === Fetch System Templates ===

  @override
  Future<List<Template>> fetchSystemTemplates() async {
    try {
      debugPrint(
        '📥 FirebaseTemplatesRepository.fetchSystemTemplates: טוען תבניות מערכת',
      );

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('is_system', isEqualTo: true)
          .orderBy('name')
          .get();

      final templates = _parseTemplates(snapshot);

      debugPrint('✅ נטענו ${templates.length} תבניות מערכת');
      return templates;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseTemplatesRepository.fetchSystemTemplates: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to fetch system templates',
        e,
      );
    }
  }

  // === Fetch Templates By Format ===

  @override
  Future<List<Template>> fetchTemplatesByFormat({
    required String format,
    String? userId,
    String? householdId,
  }) async {
    try {
      debugPrint(
        '📥 FirebaseTemplatesRepository.fetchTemplatesByFormat: פורמט=$format',
      );

      Query query = _firestore
          .collection(_collectionName)
          .where('is_system', isEqualTo: false)
          .where('default_format', isEqualTo: format);

      // סינון נוסף לפי פורמט
      if (format == 'personal' && userId != null) {
        query = query.where('user_id', isEqualTo: userId);
      } else if (format == 'shared' && householdId != null) {
        query = query.where('household_id', isEqualTo: householdId);
      } else if (format == 'assigned' && userId != null) {
        query = query.where('assigned_to', arrayContains: userId);
      }

      final snapshot = await query.orderBy('updated_date', descending: true).get();
      final templates = _parseTemplates(snapshot);

      debugPrint('✅ נמצאו ${templates.length} תבניות');
      return templates;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ FirebaseTemplatesRepository.fetchTemplatesByFormat: שגיאה - $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to fetch templates by format',
        e,
      );
    }
  }

  // === Save Template ===

  @override
  Future<Template> saveTemplate({
    required Template template,
    required String userId,
    String? householdId,
  }) async {
    try {
      debugPrint(
        '💾 FirebaseTemplatesRepository.saveTemplate: שומר תבנית ${template.id} (${template.name})',
      );

      // ⚠️ אסור לשמור תבניות מערכת!
      if (template.isSystem) {
        debugPrint('❌ אסור לשמור תבניות מערכת!');
        throw TemplateRepositoryException(
          'Cannot save system templates - use Admin SDK',
          null,
        );
      }

      // המרת המודל ל-JSON
      final data = template.toJson();

      // וידוא שדות חובה
      data['user_id'] = userId;
      data['is_system'] = false;

      // הוספת household_id אם רלוונטי
      if (template.defaultFormat == 'shared' && householdId != null) {
        data['household_id'] = householdId;
      }

      await _firestore
          .collection(_collectionName)
          .doc(template.id)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ FirebaseTemplatesRepository.saveTemplate: תבנית נשמרה');
      return template;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseTemplatesRepository.saveTemplate: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to save template ${template.id}',
        e,
      );
    }
  }

  // === Delete Template ===

  @override
  Future<void> deleteTemplate({
    required String id,
    required String userId,
  }) async {
    try {
      debugPrint(
        '🗑️ FirebaseTemplatesRepository.deleteTemplate: מוחק תבנית $id',
      );

      // וידוא שהתבנית קיימת ושייכת למשתמש
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        debugPrint('⚠️ תבנית לא קיימת');
        return;
      }

      final data = doc.data();

      // ⚠️ אסור למחוק תבניות מערכת!
      if (data?['is_system'] == true) {
        debugPrint('❌ אסור למחוק תבניות מערכת!');
        throw TemplateRepositoryException(
          'Cannot delete system templates',
          null,
        );
      }

      // וידוא שהמשתמש הוא הבעלים
      if (data?['user_id'] != userId) {
        debugPrint('⚠️ תבנית לא שייכת למשתמש זה');
        throw TemplateRepositoryException(
          'Template does not belong to this user',
          null,
        );
      }

      await _firestore.collection(_collectionName).doc(id).delete();

      debugPrint('✅ FirebaseTemplatesRepository.deleteTemplate: תבנית נמחקה');
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseTemplatesRepository.deleteTemplate: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to delete template $id',
        e,
      );
    }
  }

  // === 🆕 פונקציות נוספות ===

  /// מחזיר stream של תבניות (real-time updates)
  ///
  /// Example:
  /// ```dart
  /// repository.watchTemplates(userId: 'user_123').listen((templates) {
  ///   print('Templates updated: ${templates.length}');
  /// });
  /// ```
  Stream<List<Template>> watchTemplates({
    String? userId,
    String? householdId,
  }) {
    // לצורך פשטות - stream של תבניות אישיות בלבד
    // ניתן להרחיב ל-combine של כל הסוגים
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionName)
        .where('is_system', isEqualTo: false)
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_date', descending: true)
        .snapshots()
        .map((snapshot) => _parseTemplates(snapshot));
  }

  /// מחזיר תבנית לפי ID
  ///
  /// Example:
  /// ```dart
  /// final template = await repository.getTemplateById('template_123');
  /// ```
  Future<Template?> getTemplateById(String templateId) async {
    try {
      debugPrint(
        '🔍 FirebaseTemplatesRepository.getTemplateById: מחפש תבנית $templateId',
      );

      final doc = await _firestore
          .collection(_collectionName)
          .doc(templateId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ תבנית לא נמצאה');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      final template = Template.fromJson(data);

      debugPrint('✅ תבנית נמצאה');
      return template;
    } catch (e, stackTrace) {
      debugPrint('❌ FirebaseTemplatesRepository.getTemplateById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplateRepositoryException(
        'Failed to get template by id',
        e,
      );
    }
  }
}

/// Exception class for template repository errors
class TemplateRepositoryException implements Exception {
  final String message;
  final Object? cause;

  TemplateRepositoryException(this.message, this.cause);

  @override
  String toString() =>
      'TemplateRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
