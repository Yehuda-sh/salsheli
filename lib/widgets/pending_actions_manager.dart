// 📄 File: lib/widgets/pending_actions_manager.dart
// תיאור: מנהל פעולות ממתינות לאישור/דחייה
//
// תכונות:
// - רשימת כל הפעולות הממתינות
// - אישור/דחייה לכל פעולה
// - מצבי טעינה/ריק/שגיאה
// - חיבור ל-PendingActionCard
// - תואם Material Design: theme colors, accessibility
//
// תלויות:
// - PendingActionCard widget
// - Theme colors (AppBrand)

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
  String? _updatingActionId;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    setState(() => _isLoading = true);
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

      // לא מציגים פעולות שהמשתמש הנוכחי יזם
      if (mounted) {
        setState(() {
          _pendingActions = actions
              .where((a) => a.requestedBy != widget.currentUserEmail)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ שגיאה בטעינת פעולות: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('שגיאה בטעינת בקשות')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(
    PendingActionModel action,
    bool isApproved,
  ) async {
    setState(() => _updatingActionId = action.id);

    try {
      // קריאת API לעדכון סטטוס
      // await PendingActionApi.update(...)

      await Future.delayed(const Duration(seconds: 1)); // סימולציה

      if (isApproved && action.actionType == 'replace_item') {
        // גם לעדכן את ShoppingItem
        // await ShoppingItemApi.update(action.targetId, {...});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('בקשה ${isApproved ? "אושרה" : "נדחתה"} בהצלחה'),
          ),
        );

        setState(() {
          _pendingActions.removeWhere((a) => a.id == action.id);
        });
      }
    } catch (e) {
      debugPrint('❌ שגיאה באישור פעולה: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('שגיאה בעדכון הבקשה')));
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
              Padding(
                padding: const EdgeInsets.all(_kEmptyStatePadding),
                child: Center(
                  child: CircularProgressIndicator(
                    color: brand?.accent ?? cs.primary,
                  ),
                ),
              )
            else if (_pendingActions.isEmpty)
              _buildEmptyState(theme, cs)
            else
              _buildActionsList(),
          ],
        ),
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
