// 📄 File: lib/providers/templates_provider.dart
//
// 🎯 Purpose: Provider לניהול תבניות רשימות - ניהול state מרכזי של כל התבניות
//
// 📦 Dependencies:
// - TemplatesRepository: ממשק לטעינת/שמירת תבניות
// - UserContext: user_id + household_id + auth state
// - FirebaseTemplatesRepository: מימוש Firebase של Repository
//
// ✨ Features:
// - 📥 טעינה אוטומטית: מאזין ל-UserContext ומריענן כשמשתמש משתנה
// - ✏️ CRUD מלא: יצירה, עדכון, מחיקה, שחזור (Undo)
// - 📊 State management: isLoading, errorMessage, lastUpdated
// - 🔄 Auto-sync: רענון אוטומטי כשמשתמש מתחבר/מתנתק
// - 🎯 סינון: תבניות מערכת, אישיות, משותפות
// - 📋 Conversion: המרת תבנית → רשימת קניות
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<TemplatesProvider>();
// final templates = provider.templates;
//
// // ביצירת תבנית:
// final template = await provider.createTemplate(
//   name: 'קניות שבועיות',
//   type: 'super',
//   format: 'personal',
//   items: [...],
// );
//
// // בעדכון:
// await provider.updateTemplate(updatedTemplate);
//
// // במחיקה:
// await provider.deleteTemplate(templateId);
// ```
//
// 🔄 State Flow:
// 1. Constructor → מחכה ל-UserContext
// 2. updateUserContext() → _onUserChanged() → loadTemplates()
// 3. CRUD operations → Repository → loadTemplates() → notifyListeners()
//
// Version: 1.0 (Initial templates provider)
// Last Updated: 10/10/2025
//

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/template.dart';
import '../repositories/templates_repository.dart';
import 'user_context.dart';

class TemplatesProvider with ChangeNotifier {
  final TemplatesRepository _repository;
  final _uuid = const Uuid();

  // State
  List<Template> _templates = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // UserContext
  UserContext? _userContext;
  bool _listening = false;

  TemplatesProvider({
    required TemplatesRepository repository,
  }) : _repository = repository;

  // === Getters ===
  List<Template> get templates => List.unmodifiable(_templates);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isEmpty => _templates.isEmpty;

  /// מחזיר רק תבניות מערכת
  List<Template> get systemTemplates {
    return _templates.where((t) => t.isSystem).toList();
  }

  /// מחזיר רק תבניות אישיות
  List<Template> get personalTemplates {
    return _templates.where((t) => !t.isSystem && t.defaultFormat == 'personal').toList();
  }

  /// מחזיר רק תבניות משותפות
  List<Template> get sharedTemplates {
    return _templates.where((t) => !t.isSystem && t.defaultFormat == 'shared').toList();
  }

  /// מחזיר רק תבניות מוקצות
  List<Template> get assignedTemplates {
    return _templates.where((t) => !t.isSystem && t.defaultFormat == 'assigned').toList();
  }

  // === חיבור UserContext ===

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// נקרא אוטומטית מ-ProxyProvider
  void updateUserContext(UserContext newContext) {
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
      _listening = false;
    }
    _userContext = newContext;
    _userContext!.addListener(_onUserChanged);
    _listening = true;
    _initialize();
  }

  void _onUserChanged() {
    loadTemplates();
  }

  void _initialize() {
    if (_userContext?.isLoggedIn == true) {
      loadTemplates();
    } else {
      _templates = [];
      notifyListeners();
    }
  }

  /// טוען את כל התבניות מחדש מה-Repository
  ///
  /// Example:
  /// ```dart
  /// await templatesProvider.loadTemplates();
  /// ```
  Future<void> loadTemplates() async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    debugPrint('📥 loadTemplates: מתחיל טעינה (user: $userId, household: $householdId)');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _repository.fetchTemplates(
        userId: userId,
        householdId: householdId,
      );
      _lastUpdated = DateTime.now();
      debugPrint('✅ loadTemplates: נטענו ${_templates.length} תבניות');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ loadTemplates: שגיאה - $e');
      notifyListeners(); // ← עדכון UI מיידי על שגיאה
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ניסיון חוזר אחרי שגיאה
  ///
  /// Example:
  /// ```dart
  /// if (provider.hasError) {
  ///   await provider.retry();
  /// }
  /// ```
  Future<void> retry() async {
    debugPrint('🔄 retry: מנסה שוב לטעון תבניות');
    _errorMessage = null;
    await loadTemplates();
  }

  /// מנקה את כל ה-state (שימושי ב-logout)
  ///
  /// Example:
  /// ```dart
  /// await provider.clearAll();
  /// ```
  void clearAll() {
    debugPrint('🧹 clearAll: מנקה state');
    _templates = [];
    _errorMessage = null;
    _isLoading = false;
    _lastUpdated = null;
    notifyListeners();
  }

  /// יוצר תבנית חדשה מאובייקט Template
  ///
  /// Example:
  /// ```dart
  /// final template = Template.newTemplate(...);
  /// await provider.createTemplateFromObject(template);
  /// ```
  Future<void> createTemplateFromObject(Template template) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null) {
      debugPrint('❌ createTemplateFromObject: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('➕ createTemplateFromObject: "${template.name}" (סוג: ${template.type}, פורמט: ${template.defaultFormat})');

    await _repository.saveTemplate(
      template: template,
      userId: userId,
      householdId: householdId,
    );
    await loadTemplates();
    debugPrint('✅ createTemplateFromObject: תבנית "${template.name}" נוצרה!');
  }

  /// יוצר תבנית חדשה
  ///
  /// Example:
  /// ```dart
  /// final template = await provider.createTemplate(
  ///   name: 'קניות שבועיות',
  ///   type: 'super',
  ///   format: 'personal',
  ///   items: [
  ///     TemplateItem(name: 'חלב', category: 'dairy'),
  ///     TemplateItem(name: 'לחם', category: 'bakery'),
  ///   ],
  /// );
  /// ```
  Future<Template> createTemplate({
    required String name,
    required String type,
    String format = 'personal',
    List<TemplateItem>? items,
  }) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null) {
      debugPrint('❌ createTemplate: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('➕ createTemplate: "$name" (סוג: $type, פורמט: $format)');

    final newTemplate = Template.newTemplate(
      id: _uuid.v4(),
      name: name,
      type: type,
      createdBy: userId,
      defaultFormat: format,
      defaultItems: items ?? [],
      icon: _getIconForType(type),
      description: _getDescriptionForType(type),
    );

    await _repository.saveTemplate(
      template: newTemplate,
      userId: userId,
      householdId: householdId,
    );
    await loadTemplates();
    debugPrint('✅ createTemplate: תבנית "$name" נוצרה!');
    return newTemplate;
  }

  /// מחיקת תבנית
  ///
  /// ⚠️ רק בעלים יכול למחוק (ולא תבניות מערכת)
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteTemplate(templateId);
  /// ```
  Future<void> deleteTemplate(String id) async {
    final userId = _userContext?.user?.id;
    if (userId == null) {
      debugPrint('❌ deleteTemplate: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('🗑️ deleteTemplate: מוחק תבנית $id');
    await _repository.deleteTemplate(id: id, userId: userId);
    await loadTemplates();
    debugPrint('✅ deleteTemplate: תבנית $id נמחקה');
  }

  /// משחזר תבנית שנמחקה (Undo)
  ///
  /// Example:
  /// ```dart
  /// await provider.restoreTemplate(deletedTemplate);
  /// ```
  Future<void> restoreTemplate(Template template) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null) {
      debugPrint('❌ restoreTemplate: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('↩️ restoreTemplate: משחזר תבנית ${template.id}');
    await _repository.saveTemplate(
      template: template,
      userId: userId,
      householdId: householdId,
    );
    await loadTemplates();
    debugPrint('✅ restoreTemplate: תבנית ${template.id} שוחזרה');
  }

  /// מעדכן תבנית קיימת
  ///
  /// Example:
  /// ```dart
  /// await provider.updateTemplate(updatedTemplate);
  /// ```
  Future<void> updateTemplate(Template updated) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null) {
      debugPrint('❌ updateTemplate: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('📝 updateTemplate: מעדכן תבנית ${updated.id}');
    await _repository.saveTemplate(
      template: updated,
      userId: userId,
      householdId: householdId,
    );
    await loadTemplates();
    debugPrint('✅ updateTemplate: תבנית ${updated.id} עודכנה');
  }

  // === Get Template By ID ===
  Template? getById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (_) {
      return null;
    }
  }

  // === Add Item To Template ===
  Future<void> addItemToTemplate(String templateId, TemplateItem item) async {
    debugPrint('➕ addItemToTemplate: מוסיף פריט "${item.name}" לתבנית $templateId');
    final template = getById(templateId);
    if (template == null) {
      debugPrint('❌ addItemToTemplate: תבנית $templateId לא נמצאה');
      throw Exception('תבנית $templateId לא נמצאה');
    }

    // וידוא שהתבנית ניתנת לעריכה (לא system)
    if (!template.isEditable) {
      debugPrint('❌ addItemToTemplate: אין הרשאה לערוך תבנית זו');
      throw Exception('אין הרשאה לערוך תבנית זו');
    }

    final updatedTemplate = template.withItemAdded(item);
    await updateTemplate(updatedTemplate);
    debugPrint('✅ addItemToTemplate: פריט "${item.name}" נוסף');
  }

  // === Remove Item From Template ===
  Future<void> removeItemFromTemplate(String templateId, int index) async {
    debugPrint('🗑️ removeItemFromTemplate: מוחק פריט #$index מתבנית $templateId');
    final template = getById(templateId);
    if (template == null) {
      debugPrint('❌ removeItemFromTemplate: תבנית $templateId לא נמצאה');
      throw Exception('תבנית $templateId לא נמצאה');
    }

    // וידוא שהתבנית ניתנת לעריכה (לא system)
    if (!template.isEditable) {
      debugPrint('❌ removeItemFromTemplate: אין הרשאה לערוך תבנית זו');
      throw Exception('אין הרשאה לערוך תבנית זו');
    }

    final updatedTemplate = template.withItemRemoved(index);
    await updateTemplate(updatedTemplate);
    debugPrint('✅ removeItemFromTemplate: פריט #$index הוסר');
  }

  // === Update Item At Index ===
  Future<void> updateItemAt(
    String templateId,
    int index,
    TemplateItem Function(TemplateItem) updateFn,
  ) async {
    debugPrint('📝 updateItemAt: מעדכן פריט #$index בתבנית $templateId');
    final template = getById(templateId);
    if (template == null) {
      debugPrint('❌ updateItemAt: תבנית $templateId לא נמצאה');
      throw Exception('תבנית $templateId לא נמצאה');
    }

    // וידוא שהתבנית ניתנת לעריכה (לא system)
    if (!template.isEditable) {
      debugPrint('❌ updateItemAt: אין הרשאה לערוך תבנית זו');
      throw Exception('אין הרשאה לערוך תבנית זו');
    }

    final currentItem = template.defaultItems[index];
    final newItem = updateFn(currentItem);
    final updatedTemplate = template.withItemUpdated(index, newItem);
    await updateTemplate(updatedTemplate);
    debugPrint('✅ updateItemAt: פריט #$index עודכן');
  }

  /// מחזיר תבניות לפי סוג רשימה
  ///
  /// Example:
  /// ```dart
  /// final superTemplates = provider.getTemplatesByType('super');
  /// ```
  List<Template> getTemplatesByType(String type) {
    return _templates.where((t) => t.type == type).toList();
  }

  /// מחזיר תבניות זמינות למשתמש (לפי household_id)
  ///
  /// Example:
  /// ```dart
  /// final availableTemplates = provider.getAvailableTemplates();
  /// ```
  List<Template> getAvailableTemplates() {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) return [];

    return _templates.where((t) => t.isAvailableFor(householdId)).toList();
  }

  // === Helper Methods ===

  /// מחזיר אייקון לפי סוג רשימה
  String _getIconForType(String type) {
    const icons = {
      'super': '🛒',
      'pharmacy': '💊',
      'birthday': '🎂',
      'party': '🎉',
      'wedding': '💍',
      'picnic': '🧺',
      'holiday': '🕎',
      'camping': '⛺',
    };
    return icons[type] ?? '📝';
  }

  /// מחזיר תיאור לפי סוג רשימה
  String _getDescriptionForType(String type) {
    const descriptions = {
      'super': 'רשימת קניות סופרמרקט',
      'pharmacy': 'רשימת קניות בית מרקחת',
      'birthday': 'רשימה ליום הולדת',
      'party': 'רשימה למסיבה',
      'wedding': 'רשימה לחתונה',
      'picnic': 'רשימה לפיקניק',
      'holiday': 'רשימה לחג',
      'camping': 'רשימה לטיול/קמפינג',
    };
    return descriptions[type] ?? 'תבנית מותאמת אישית';
  }

  @override
  void dispose() {
    debugPrint('🗑️ TemplatesProvider.dispose()');
    if (_listening && _userContext != null) {
      _userContext!.removeListener(_onUserChanged);
    }
    super.dispose();
  }
}
