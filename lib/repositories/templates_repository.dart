// 📄 File: lib/repositories/templates_repository.dart
//
// 🇮🇱 Repository לניהול תבניות רשימות.
//     - משמש כשכבת ביניים בין Providers ↔ מקור הנתונים (Firebase / Mock).
//     - מאפשר להחליף בקלות מקור נתונים ע"י מימוש שונה.
//     - עוזר לשמור את TemplatesProvider נקי מהלוגיקה של אחסון/טעינה.
//
// 🇬🇧 Repository for managing shopping list templates.
//     - Acts as a bridge between Providers ↔ data source (Firebase / Mock).
//     - Makes it easy to swap data source by changing the implementation.
//     - Keeps TemplatesProvider clean from storage/fetching logic.
//
// 📝 Version: 1.0 - Initial templates repository
// 📅 Last Updated: 10/10/2025
//

import '../models/template.dart';

/// === Contract ===
///
/// 🇮🇱 כל מקור נתונים (Firebase, Mock) יצטרך לממש את הממשק הזה.
/// 🇬🇧 Any data source (Firebase, Mock) must implement this interface.
abstract class TemplatesRepository {
  /// טוען את כל התבניות הזמינות למשתמש
  ///
  /// [userId] - מזהה המשתמש (null = תבניות מערכת בלבד)
  /// [householdId] - מזהה משק הבית (לתבניות shared)
  ///
  /// Returns: רשימת כל התבניות הזמינות (system + personal + shared)
  ///
  /// Example:
  /// ```dart
  /// final templates = await repository.fetchTemplates(
  ///   userId: 'user_123',
  ///   householdId: 'house_demo',
  /// );
  /// print('נטענו ${templates.length} תבניות');
  /// ```
  Future<List<Template>> fetchTemplates({
    String? userId,
    String? householdId,
  });

  /// שומר או מעדכן תבנית
  ///
  /// [template] - התבנית לשמירה (חדשה או קיימת)
  /// [userId] - מזהה המשתמש (בעלים)
  /// [householdId] - מזהה משק הבית (יתווסף אוטומטית ל-Firestore)
  ///
  /// Returns: התבנית ששמרנו (עם שדות מעודכנים אם יש)
  ///
  /// ⚠️ לא ניתן לשמור תבניות מערכת (is_system=true)
  ///
  /// Example:
  /// ```dart
  /// final newTemplate = Template.newTemplate(...);
  /// final saved = await repository.saveTemplate(
  ///   template: newTemplate,
  ///   userId: 'user_123',
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<Template> saveTemplate({
    required Template template,
    required String userId,
    String? householdId,
  });

  /// מוחק תבנית
  ///
  /// [id] - מזהה התבנית למחיקה
  /// [userId] - מזהה המשתמש (לבדיקת הרשאות - רק בעלים)
  ///
  /// ⚠️ לא ניתן למחוק תבניות מערכת (is_system=true)
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteTemplate(
  ///   id: 'template_123',
  ///   userId: 'user_123',
  /// );
  /// ```
  Future<void> deleteTemplate({
    required String id,
    required String userId,
  });

  /// טוען תבניות לפי פורמט
  ///
  /// [format] - 'shared', 'assigned', או 'personal'
  /// [userId] - מזהה המשתמש
  /// [householdId] - מזהה משק הבית (לשימוש ב-shared)
  ///
  /// Returns: רשימת תבניות מהפורמט המבוקש
  ///
  /// Example:
  /// ```dart
  /// final sharedTemplates = await repository.fetchTemplatesByFormat(
  ///   format: 'shared',
  ///   householdId: 'house_demo',
  /// );
  /// ```
  Future<List<Template>> fetchTemplatesByFormat({
    required String format,
    String? userId,
    String? householdId,
  });

  /// טוען תבניות מערכת בלבד
  ///
  /// Returns: רשימת כל תבניות המערכת (is_system=true)
  ///
  /// Example:
  /// ```dart
  /// final systemTemplates = await repository.fetchSystemTemplates();
  /// print('יש ${systemTemplates.length} תבניות מערכת');
  /// ```
  Future<List<Template>> fetchSystemTemplates();
}
