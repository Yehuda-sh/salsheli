// 📄 File: lib/repositories/templates_repository.dart
//
// 🎯 Purpose: Repository interface לניהול תבניות רשימות
//
// 📦 Contract:
// - Interface לגישה לתבניות (system + household)
// - CRUD operations על תבניות
// - Query by type, system/household
//
// 📝 Usage:
// ```dart
// final repo = FirebaseTemplatesRepository();
// final templates = await repo.fetchAllTemplates(householdId);
// ```
//
// Version: 1.0
// Last Updated: 10/10/2025
//

import '../models/template.dart';

/// Repository interface לניהול תבניות
/// 
/// כל מימוש (Firebase, Local, Mock) צריך ליישם את הממשק הזה
abstract class TemplatesRepository {
  /// טוען תבניות מערכת (is_system=true)
  /// 
  /// Returns: רשימת תבניות מערכת (זמינות לכל המשתמשים)
  /// 
  /// Example:
  /// ```dart
  /// final systemTemplates = await repo.fetchSystemTemplates();
  /// print('${systemTemplates.length} תבניות מערכת');
  /// ```
  Future<List<Template>> fetchSystemTemplates();

  /// טוען תבניות של משק בית
  /// 
  /// [householdId] - מזהה משק הבית
  /// 
  /// Returns: רשימת תבניות פרטיות של המשק בית
  /// 
  /// Example:
  /// ```dart
  /// final householdTemplates = await repo.fetchHouseholdTemplates('house_123');
  /// ```
  Future<List<Template>> fetchHouseholdTemplates(String householdId);

  /// טוען כל התבניות הזמינות (system + household)
  /// 
  /// [householdId] - מזהה משק הבית (לשליפת תבניות פרטיות)
  /// 
  /// Returns: רשימת כל התבניות (מערכת + פרטיות)
  /// 
  /// Example:
  /// ```dart
  /// final allTemplates = await repo.fetchAllTemplates('house_123');
  /// // מכיל גם תבניות מערכת וגם תבניות של house_123
  /// ```
  Future<List<Template>> fetchAllTemplates(String householdId);

  /// שומר תבנית חדשה או מעדכנת קיימת
  /// 
  /// [template] - התבנית לשמירה
  /// 
  /// Returns: התבנית ששמרנו (עם שדות מעודכנים אם יש)
  /// 
  /// Example:
  /// ```dart
  /// final template = Template.newTemplate(...);
  /// await repo.saveTemplate(template);
  /// ```
  Future<Template> saveTemplate(Template template);

  /// מוחק תבנית (רק user templates)
  /// 
  /// [id] - מזהה התבנית למחיקה
  /// [householdId] - מזהה משק הבית (לבדיקת הרשאות)
  /// 
  /// Throws: Exception אם מנסים למחוק תבנית מערכת
  /// 
  /// Example:
  /// ```dart
  /// await repo.deleteTemplate('template_custom_123', 'house_123');
  /// ```
  Future<void> deleteTemplate(String id, String householdId);

  /// מחזיר תבנית לפי ID
  /// 
  /// [id] - מזהה התבנית
  /// 
  /// Returns: התבנית או null אם לא נמצאה
  /// 
  /// Example:
  /// ```dart
  /// final template = await repo.getTemplateById('template_super');
  /// if (template != null) {
  ///   print('נמצא: ${template.name}');
  /// }
  /// ```
  Future<Template?> getTemplateById(String id);

  /// מחזיר תבניות לפי סוג
  /// 
  /// [type] - סוג הרשימה (מ-ListType)
  /// 
  /// Returns: רשימת תבניות מהסוג המבוקש
  /// 
  /// Example:
  /// ```dart
  /// final birthdayTemplates = await repo.getTemplatesByType(ListType.birthday);
  /// ```
  Future<List<Template>> getTemplatesByType(String type);
}
