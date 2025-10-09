// 📄 File: lib/providers/templates_provider.dart
//
// 🎯 Purpose: Provider לניהול תבניות רשימות - ניהול state מרכזי
//
// 📦 Dependencies:
// - TemplatesRepository: ממשק לטעינת/שמירת תבניות
// - UserContext: household_id + auth state
// - FirebaseTemplatesRepository: מימוש Firebase
//
// ✨ Features:
// - 📥 טעינה אוטומטית: מאזין ל-UserContext ומריענן כשמשתמש משתנה
// - 📊 State management: isLoading, errorMessage
// - 🔄 Auto-sync: רענון אוטומטי כשמשתמש מתחבר/מתנתק
// - 🔍 Query methods: getByType, getSystemTemplates, getHouseholdTemplates
// - 🐛 Logging מפורט: כל פעולה עם debugPrint
//
// 📝 Usage:
// ```dart
// // בקריאת נתונים:
// final provider = context.watch<TemplatesProvider>();
// final templates = provider.templates;
//
// // בחירת תבנית:
// final template = provider.getByType(ListType.birthday).first;
// ```
//
// Version: 1.0
// Last Updated: 10/10/2025
//

import 'package:flutter/foundation.dart';
import '../models/template.dart';
import '../repositories/templates_repository.dart';
import 'user_context.dart';

class TemplatesProvider with ChangeNotifier {
  final TemplatesRepository _repository;

  // State
  List<Template> _templates = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // UserContext
  UserContext? _userContext;
  bool _listening = false;

  TemplatesProvider({required TemplatesRepository repository})
      : _repository = repository;

  // ========================================
  // Getters
  // ========================================

  List<Template> get templates => List.unmodifiable(_templates);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isEmpty => _templates.isEmpty;

  // ========================================
  // חיבור UserContext
  // ========================================

  /// מעדכן את ה-UserContext ומאזין לשינויים
  /// 
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

  // ========================================
  // Load Templates
  // ========================================

  /// טוען את כל התבניות (system + household)
  /// 
  /// Example:
  /// ```dart
  /// await templatesProvider.loadTemplates();
  /// ```
  Future<void> loadTemplates() async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('⚠️ loadTemplates: householdId is null');
      return;
    }

    debugPrint('📥 loadTemplates: מתחיל (householdId: $householdId)');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _repository.fetchAllTemplates(householdId);
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

  // ========================================
  // Query Methods
  // ========================================

  /// מחזיר תבנית לפי ID
  /// 
  /// Example:
  /// ```dart
  /// final template = provider.getById('template_super');
  /// ```
  Template? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// מחזיר תבניות לפי סוג
  /// 
  /// Example:
  /// ```dart
  /// final birthdayTemplates = provider.getByType(ListType.birthday);
  /// ```
  List<Template> getByType(String type) {
    final filtered = _templates.where((t) => t.type == type).toList();
    debugPrint('🔍 getByType($type): ${filtered.length} תבניות');
    return filtered;
  }

  /// מחזיר תבניות מערכת בלבד
  /// 
  /// Example:
  /// ```dart
  /// final systemTemplates = provider.getSystemTemplates();
  /// ```
  List<Template> getSystemTemplates() {
    final filtered = _templates.where((t) => t.isSystem).toList();
    debugPrint('🔍 getSystemTemplates: ${filtered.length} תבניות');
    return filtered;
  }

  /// מחזיר תבניות משק בית בלבד
  /// 
  /// Example:
  /// ```dart
  /// final householdTemplates = provider.getHouseholdTemplates();
  /// ```
  List<Template> getHouseholdTemplates() {
    final filtered = _templates.where((t) => !t.isSystem).toList();
    debugPrint('🔍 getHouseholdTemplates: ${filtered.length} תבניות');
    return filtered;
  }

  /// מחזיר תבניות זמינות למשק בית מסוים
  /// 
  /// Example:
  /// ```dart
  /// final available = provider.getAvailableFor('house_123');
  /// ```
  List<Template> getAvailableFor(String householdId) {
    final filtered = _templates.where((t) => t.isAvailableFor(householdId)).toList();
    debugPrint('🔍 getAvailableFor($householdId): ${filtered.length} תבניות');
    return filtered;
  }

  // ========================================
  // CRUD Operations (Optional - for Phase 2+)
  // ========================================

  /// יוצר תבנית חדשה (משק בית)
  /// 
  /// Example:
  /// ```dart
  /// final template = await provider.createTemplate(
  ///   name: 'הרשימה שלי',
  ///   type: ListType.other,
  ///   ...
  /// );
  /// ```
  Future<Template> createTemplate({
    required String id,
    required String type,
    required String name,
    required String description,
    required String icon,
    String defaultFormat = Template.formatShared,
    List<TemplateItem> defaultItems = const [],
  }) async {
    final userId = _userContext?.user?.id;
    final householdId = _userContext?.user?.householdId;

    if (userId == null || householdId == null) {
      debugPrint('❌ createTemplate: משתמש לא מחובר');
      throw Exception('❌ משתמש לא מחובר');
    }

    debugPrint('➕ createTemplate: "$name" (type: $type)');

    final newTemplate = Template.newTemplate(
      id: id,
      type: type,
      name: name,
      description: description,
      icon: icon,
      createdBy: userId,
      householdId: householdId,
      defaultFormat: defaultFormat,
      defaultItems: defaultItems,
      isSystem: false,
    );

    await _repository.saveTemplate(newTemplate);
    await loadTemplates();

    debugPrint('✅ createTemplate: תבנית "$name" נוצרה');
    return newTemplate;
  }

  /// מוחק תבנית (רק של משק בית)
  /// 
  /// Example:
  /// ```dart
  /// await provider.deleteTemplate('template_custom_123');
  /// ```
  Future<void> deleteTemplate(String id) async {
    final householdId = _userContext?.user?.householdId;
    if (householdId == null) {
      debugPrint('❌ deleteTemplate: householdId לא נמצא');
      throw Exception('❌ householdId לא נמצא');
    }

    debugPrint('🗑️ deleteTemplate: $id');
    await _repository.deleteTemplate(id, householdId);
    await loadTemplates();
    debugPrint('✅ deleteTemplate: תבנית $id נמחקה');
  }

  /// מעדכן תבנית קיימת
  /// 
  /// Example:
  /// ```dart
  /// await provider.updateTemplate(updatedTemplate);
  /// ```
  Future<void> updateTemplate(Template updated) async {
    debugPrint('📝 updateTemplate: ${updated.id}');
    await _repository.saveTemplate(updated);
    await loadTemplates();
    debugPrint('✅ updateTemplate: תבנית ${updated.id} עודכנה');
  }

  // ========================================
  // Statistics
  // ========================================

  /// מחזיר סטטיסטיקות על התבניות
  /// 
  /// Returns: Map עם total, system, household
  /// 
  /// Example:
  /// ```dart
  /// final stats = provider.getStats();
  /// print('סה"כ: ${stats['total']}, מערכת: ${stats['system']}');
  /// ```
  Map<String, int> getStats() {
    final total = _templates.length;
    final system = _templates.where((t) => t.isSystem).length;
    final household = total - system;

    return {
      'total': total,
      'system': system,
      'household': household,
    };
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
