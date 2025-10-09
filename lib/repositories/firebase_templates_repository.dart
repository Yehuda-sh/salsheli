// 📄 File: lib/repositories/firebase_templates_repository.dart
//
// 🎯 Purpose: Firebase implementation של TemplatesRepository
//
// 📦 Features:
// - שמירה/טעינה של תבניות מ-Firestore
// - Query by system/household
// - Query by type
// - מניעת מחיקת תבניות מערכת
//
// 📝 Usage:
// ```dart
// final repo = FirebaseTemplatesRepository();
// final templates = await repo.fetchSystemTemplates();
// ```
//
// Version: 1.0
// Last Updated: 10/10/2025
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/template.dart';
import 'templates_repository.dart';

class FirebaseTemplatesRepository implements TemplatesRepository {
  final FirebaseFirestore _firestore;

  FirebaseTemplatesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ========================================
  // Fetch Templates
  // ========================================

  @override
  Future<List<Template>> fetchSystemTemplates() async {
    try {
      debugPrint('📥 FirebaseTemplatesRepository.fetchSystemTemplates');

      final snapshot = await _firestore
          .collection(FirestoreCollections.templates)
          .where('is_system', isEqualTo: true)
          .orderBy('sort_order')
          .get();

      final templates = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return Template.fromJson(data);
      }).toList();

      debugPrint('✅ נטענו ${templates.length} תבניות מערכת');
      return templates;
    } catch (e, stackTrace) {
      debugPrint('❌ fetchSystemTemplates: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to fetch system templates', e);
    }
  }

  @override
  Future<List<Template>> fetchHouseholdTemplates(String householdId) async {
    try {
      debugPrint('📥 fetchHouseholdTemplates: $householdId');

      final snapshot = await _firestore
          .collection(FirestoreCollections.templates)
          .where('household_id', isEqualTo: householdId)
          .orderBy('sort_order')
          .get();

      final templates = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return Template.fromJson(data);
      }).toList();

      debugPrint('✅ נטענו ${templates.length} תבניות משק בית');
      return templates;
    } catch (e, stackTrace) {
      debugPrint('❌ fetchHouseholdTemplates: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException(
          'Failed to fetch household templates', e);
    }
  }

  @override
  Future<List<Template>> fetchAllTemplates(String householdId) async {
    try {
      debugPrint('📥 fetchAllTemplates: system + $householdId');

      // טוען תבניות מערכת
      final systemTemplates = await fetchSystemTemplates();

      // טוען תבניות משק בית
      final householdTemplates = await fetchHouseholdTemplates(householdId);

      // מאחד את שתי הרשימות
      final allTemplates = [...systemTemplates, ...householdTemplates];

      debugPrint('✅ סה"כ ${allTemplates.length} תבניות');
      return allTemplates;
    } catch (e, stackTrace) {
      debugPrint('❌ fetchAllTemplates: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to fetch all templates', e);
    }
  }

  // ========================================
  // Save Template
  // ========================================

  @override
  Future<Template> saveTemplate(Template template) async {
    try {
      debugPrint('💾 saveTemplate: ${template.id} (${template.name})');

      final data = template.toJson();

      await _firestore
          .collection(FirestoreCollections.templates)
          .doc(template.id)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ תבנית נשמרה');
      return template;
    } catch (e, stackTrace) {
      debugPrint('❌ saveTemplate: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to save template', e);
    }
  }

  // ========================================
  // Delete Template
  // ========================================

  @override
  Future<void> deleteTemplate(String id, String householdId) async {
    try {
      debugPrint('🗑️ deleteTemplate: $id');

      final doc =
          await _firestore.collection(FirestoreCollections.templates).doc(id).get();

      if (!doc.exists) {
        debugPrint('⚠️ תבנית לא קיימת');
        return;
      }

      final data = doc.data();

      // אי אפשר למחוק תבניות מערכת
      if (data?['is_system'] == true) {
        debugPrint('⚠️ לא ניתן למחוק תבנית מערכת');
        throw TemplatesRepositoryException(
            'Cannot delete system template', null);
      }

      // וודא שהתבנית שייכת ל-household
      if (data?['household_id'] != householdId) {
        debugPrint('⚠️ תבנית לא שייכת למשק בית זה');
        throw TemplatesRepositoryException(
            'Template does not belong to household', null);
      }

      await _firestore.collection(FirestoreCollections.templates).doc(id).delete();

      debugPrint('✅ תבנית נמחקה');
    } catch (e, stackTrace) {
      debugPrint('❌ deleteTemplate: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to delete template', e);
    }
  }

  // ========================================
  // Get Template By ID
  // ========================================

  @override
  Future<Template?> getTemplateById(String id) async {
    try {
      debugPrint('🔍 getTemplateById: $id');

      final doc =
          await _firestore.collection(FirestoreCollections.templates).doc(id).get();

      if (!doc.exists) {
        debugPrint('⚠️ תבנית לא נמצאה');
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      final template = Template.fromJson(data);

      debugPrint('✅ תבנית נמצאה: ${template.name}');
      return template;
    } catch (e, stackTrace) {
      debugPrint('❌ getTemplateById: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to get template by id', e);
    }
  }

  // ========================================
  // Get Templates By Type
  // ========================================

  @override
  Future<List<Template>> getTemplatesByType(String type) async {
    try {
      debugPrint('🔍 getTemplatesByType: $type');

      final snapshot = await _firestore
          .collection(FirestoreCollections.templates)
          .where('type', isEqualTo: type)
          .orderBy('sort_order')
          .get();

      final templates = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return Template.fromJson(data);
      }).toList();

      debugPrint('✅ נמצאו ${templates.length} תבניות מסוג $type');
      return templates;
    } catch (e, stackTrace) {
      debugPrint('❌ getTemplatesByType: שגיאה - $e');
      debugPrintStack(stackTrace: stackTrace);
      throw TemplatesRepositoryException('Failed to get templates by type', e);
    }
  }

  // ========================================
  // 🆕 Additional Methods (Optional)
  // ========================================

  /// מחזיר stream של תבניות (real-time updates)
  /// 
  /// Example:
  /// ```dart
  /// repo.watchTemplates('house_123').listen((templates) {
  ///   print('Templates updated: ${templates.length}');
  /// });
  /// ```
  Stream<List<Template>> watchTemplates(String householdId) {
    return _firestore
        .collection(FirestoreCollections.templates)
        .where('household_id', isEqualTo: householdId)
        .orderBy('sort_order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return Template.fromJson(data);
      }).toList();
    });
  }

  /// מחזיר stream של תבניות מערכת (real-time updates)
  Stream<List<Template>> watchSystemTemplates() {
    return _firestore
        .collection(FirestoreCollections.templates)
        .where('is_system', isEqualTo: true)
        .orderBy('sort_order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        return Template.fromJson(data);
      }).toList();
    });
  }
}

// ========================================
// Exception Class
// ========================================

/// Exception class for templates repository errors
class TemplatesRepositoryException implements Exception {
  final String message;
  final Object? cause;

  TemplatesRepositoryException(this.message, this.cause);

  @override
  String toString() =>
      'TemplatesRepositoryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
