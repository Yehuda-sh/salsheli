// 📄 File: lib/widgets/pending_actions_manager.dart
// תיאור: מנהל פעולות ממתינות לאישור/דחייה
//
// Purpose:
// וידג'ט מרכזי לניהול בקשות שיתוף פעולה בין חברי משק בית.
// מאפשר למשתמשים לאשר/לדחות פעולות שביקשו משתמשים אחרים (החלפת מוצר, הוספה, וכו').
//
// Features:
// - רשימת כל הפעולות הממתינות
// - אישור/דחייה עם Undo (5 שניות)
// - 3 Empty States: Loading, Error, No Pending
// - סינון אוטומטי של פעולות שהמשתמש הנוכחי יזם
// - Logging מפורט לכל פעולה
// - Confirmation dialogs לפעולות קריטיות
//
// Dependencies:
// - PendingActionCard widget
// - Theme colors (AppBrand)
// - PendingActionApi (TODO: להוסיף כשה-API מוכן)
//
// Usage:
// ```dart
// PendingActionsManager(
//   householdId: 'house_123',
//   currentUserEmail: 'user@example.com',
// )
// ```
//
// Flow:
// 1. initState → _loadActions (טעינה מ-API)
// 2. סינון פעולות שלא מהמשתמש הנוכחי
// 3. תצוגה: Loading/Error/Empty/List
// 4. אישור/דחייה → Confirmation → API → Undo option
//
// Version: 2.0

import 'package:flutter/material.dart';

import 'pending_action_card.dart';
import '../theme/app_theme.dart';

// ============================
// קבועים
// ============================

const double _kCardBorderRadius = 12.0;
const double _kEmptyStatePadding = 24.0;
const double _kEmptyStateIconSize = 48.0;
const double _kItemPaddingHorizontal = 12.0;
const double _kItemPaddingVertical = 6.0;

// ============================
// Model
// ============================

/// מודל פעולה ממתינה (יכול להגיע מ-API)
class PendingActionModel {
  final String id;
  final String requestedBy;
  final String actionType;
  final Map<String, dynamic> actionData;
  final String? message;
  final DateTime createdDate;
  final String targetId;

  const PendingActionModel({
    required this.id,
    required this.requestedBy,
    required this.actionType,
    required this.actionData,
    this.message,
    required this.createdDate,
    required this.targetId,
  });
}

// ============================
// Widget
// ============================

class PendingActionsManager extends StatefulWidget {
  final String householdId;
  final String currentUserEmail;

  const PendingActionsManager({
    super.key,
    required this.householdId,
    required this.currentUserEmail,
  });

  @override
  State<PendingActionsManager> createState() => _PendingActionsManagerState();
}

class _PendingActionsManagerState extends State<PendingActionsManager> {
  List<PendingActionModel> _pendingActions = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _updatingActionId;

  @override
  void initState() {
    super.initState();
    debugPrint('📋 PendingActionsManager.initState()');
    debugPrint('   🏠 householdId: ${widget.householdId}');
    debugPrint('   👤 currentUser: ${widget.currentUserEmail}');
    _loadActions();
  }

  @override
  void dispose() {
    debugPrint('📋 PendingActionsManager.dispose()');
    super.dispose();
  }

  Future<void> _loadActions() async {
    debugPrint('🔄 PendingActionsManager._loadActions()');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // כאן תבצע קריאה ל-API שלך
      // לדוגמה:
      // final actions = await PendingActionApi.filter(...);

      await Future.delayed(const Duration(seconds: 1)); // סימולציה

      final actions = <PendingActionModel>[
        PendingActionModel(
          id: '1',
          requestedBy: 'user1@test.com',
          actionType: 'replace_item',
          actionData: {
            'original_item_name': 'חלב תנובה',
            'proposed_alternative': 'חלב יטבתה',
          },
          message: 'החלב המקורי לא במלאי',
          createdDate: DateTime.now().subtract(const Duration(minutes: 12)),
          targetId: 'item123',
        ),
      ];

      debugPrint('   📦 נטענו ${actions.length} פעולות');

      // לא מציגים פעולות שהמשתמש הנוכחי יזם
      final filtered = actions
          .where((a) => a.requestedBy != widget.currentUserEmail)
          .toList();

      debugPrint('   🔍 אחרי סינון: ${filtered.length} פעולות ממתינות');

      if (mounted) {
        setState(() {
          _pendingActions = filtered;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ PendingActionsManager._loadActions: שגיאה - $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'שגיאה בטעינת בקשות. נסה שוב.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(
    PendingActionModel action,
    bool isApproved,
  ) async {
    debugPrint('${isApproved ? "✅" : "❌"} PendingActionsManager._handleApproval()');
    debugPrint('   📋 actionId: ${action.id}');
    debugPrint('   🔧 actionType: ${action.actionType}');
    debugPrint('   👤 requestedBy: ${action.requestedBy}');
    debugPrint('   🎯 isApproved: $isApproved');

    // Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isApproved ? 'אישור בקשה' : 'דחיית בקשה'),
        content: Text(
          isApproved
              ? 'האם אתה בטוח שברצונך לאשר את הבקשה הזו?'
              : 'האם אתה בטוח שברצונך לדחות את הבקשה הזו?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved
                  ? const Color(0xFF10B981) // green
                  : Theme.of(context).colorScheme.error,
            ),
            child: Text(isApproved ? 'אשר' : 'דחה'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      debugPrint('   ⏸️  המשתמש ביטל');
      return;
    }

    setState(() => _updatingActionId = action.id);

    try {
      // קריאת API לעדכון סטטוס
      // await PendingActionApi.update(...)

      await Future.delayed(const Duration(seconds: 1)); // סימולציה

      if (isApproved && action.actionType == 'replace_item') {
        // גם לעדכן את ShoppingItem
        // await ShoppingItemApi.update(action.targetId, {...});
        debugPrint('   🔄 עדכון ShoppingItem: ${action.targetId}');
      }

      debugPrint('   ✅ פעולה הושלמה בהצלחה');

      if (!mounted) return;

      // שמירה לצורך Undo
      final savedAction = action;
      final savedIndex = _pendingActions.indexOf(action);

      setState(() {
        _pendingActions.removeWhere((a) => a.id == action.id);
      });

      // SnackBar עם Undo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'בקשה ${isApproved ? "אושרה" : "נדחתה"} בהצלחה',
          ),
          backgroundColor: isApproved
              ? const Color(0xFF10B981) // green
              : Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'בטל',
            textColor: Colors.white,
            onPressed: () async {
              debugPrint('⏪ ביטול פעולה: ${savedAction.id}');
              // TODO: קריאת API לביטול
              if (mounted) {
                setState(() {
                  _pendingActions.insert(savedIndex, savedAction);
                });
              }
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ PendingActionsManager._handleApproval: שגיאה - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('שגיאה בעדכון הבקשה'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingActionId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brand = theme.extension<AppBrand>();

    return Semantics(
      label: 'מנהל בקשות ממתינות',
      child: Card(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            // Header
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: brand?.accent ?? cs.primary,
              ),
              title: Text(
                'בקשות ממתינות לאישור',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),

            // Content
            if (_isLoading)
              _buildLoadingState(brand, cs)
            else if (_hasError)
              _buildErrorState(theme, cs)
            else if (_pendingActions.isEmpty)
              _buildEmptyState(theme, cs)
            else
              _buildActionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppBrand? brand, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(_kEmptyStatePadding),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: brand?.accent ?? cs.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'טוען בקשות...',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(_kEmptyStatePadding),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: _kEmptyStateIconSize,
            color: cs.error,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'שגיאה בטעינת בקשות',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadActions,
            icon: const Icon(Icons.refresh),
            label: const Text('נסה שוב'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(_kEmptyStatePadding),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: _kEmptyStateIconSize,
            color: const Color(0xFF10B981), // green-500
          ),
          const SizedBox(height: 8),
          Text(
            'אין בקשות שממתינות לך',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'הכל מעודכן!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    return Column(
      children: _pendingActions.map((action) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kItemPaddingHorizontal,
            vertical: _kItemPaddingVertical,
          ),
          child: PendingActionCard(
            action: PendingAction(
              requestedBy: action.requestedBy,
              actionType: action.actionType,
              actionData: action.actionData,
              message: action.message,
              createdDate: action.createdDate,
            ),
            onApprove: () => _handleApproval(action, true),
            onReject: () => _handleApproval(action, false),
            isLoading: _updatingActionId == action.id,
          ),
        );
      }).toList(),
    );
  }
}
