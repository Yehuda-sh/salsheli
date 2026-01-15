// 📄 lib/widgets/common/pending_requests_section.dart
//
// מציג בקשות ממתינות לאישור (הוספה/עריכה/מחיקה של פריטים).
// מופיע בפתק כתום עם כפתורי אישור/דחייה למי שיש הרשאה.
//
// ✅ תיקונים:
//    - המרת _RequestCard ל-StatefulWidget עם _isProcessing flag
//    - הוספת try-catch + mounted checks לפעולות async
//    - הוספת HapticFeedback (lightImpact לאישור, mediumImpact לדחייה)
//    - הוספת unawaited() לקריאות HapticFeedback
//    - הוספת Semantics wrapper לסקשן ולכרטיסים
//    - הוספת tooltips לכפתורי אישור/דחייה
//    - תמיכה ב-Dark Mode (kStickyOrangeDark)
//    - הוספת loading indicator בזמן עיבוד
//    - הוספת maxLines + TextOverflow.ellipsis לטקסטים
//
// 🔗 Related: PendingRequest, StickyNote

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/request_type.dart';
import '../../models/pending_request.dart';
import '../../providers/user_context.dart';
import 'sticky_note.dart';

/// Widget להצגת בקשות ממתינות
///
/// Version 2.0: שונה לעבוד עם רשימה ישירה במקום Provider
class PendingRequestsSection extends StatelessWidget {
  final String listId;
  final List<PendingRequest> pendingRequests;
  final bool canApprove; // האם המשתמש יכול לאשר בקשות

  const PendingRequestsSection({
    super.key,
    required this.listId,
    required this.pendingRequests,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    // אם אין בקשות - לא מציגים כלום
    if (pendingRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ תמיכה ב-Dark Mode
    final stickyColor = isDark ? kStickyOrangeDark : kStickyOrange;

    return Semantics(
      label: 'בקשות ממתינות לאישור, ${pendingRequests.length} בקשות',
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kSpacingMedium),
        child: StickyNote(
          color: stickyColor,
          rotation: 0.01,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // כותרת
              Row(
                children: [
                  const Icon(Icons.pending_actions, size: 20),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Text(
                      'בקשות ממתינות (${pendingRequests.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),

              // רשימת בקשות
              ...pendingRequests.map((request) => _RequestCard(
                    request: request,
                    listId: listId,
                    canApprove: canApprove,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// כרטיס בקשה בודדת
///
/// ✅ Version 2.0: StatefulWidget עם _isProcessing flag, HapticFeedback, Semantics
class _RequestCard extends StatefulWidget {
  final PendingRequest request;
  final String listId;
  final bool canApprove;

  const _RequestCard({
    required this.request,
    required this.listId,
    required this.canApprove,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final userContext = context.read<UserContext>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final requestTitle = _getRequestTitle(widget.request.type);
    final requestContent = _getRequestContent(widget.request);

    return Semantics(
      label: '$requestTitle: $requestContent',
      container: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: kSpacingSmall),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - סוג בקשה + זמן
              Row(
                children: [
                  Text(
                    _getRequestIcon(widget.request.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.request.requesterName ?? 'משתמש'} • ${widget.request.timeAgoText}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // תוכן הבקשה
              Text(
                requestContent,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // כפתורי אישור/דחייה (רק אם יש הרשאה)
              if (widget.canApprove) ...[
                const SizedBox(height: kSpacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ✅ Loading indicator בזמן עיבוד
                    if (_isProcessing)
                      Padding(
                        padding: const EdgeInsets.only(left: kSpacingSmall),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ),

                    // דחה
                    Tooltip(
                      message: 'דחה את הבקשה',
                      child: TextButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _rejectRequest(userContext.userId!),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('דחה'),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    // אשר
                    Tooltip(
                      message: 'אשר את הבקשה',
                      child: FilledButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _approveRequest(userContext.userId!),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('אשר'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRequestIcon(RequestType type) {
    switch (type) {
      case RequestType.addItem:
        return '➕';
      case RequestType.editItem:
        return '✏️';
      case RequestType.deleteItem:
        return '🗑️';
      case RequestType.inviteToList:
        return '👥';
      case RequestType.unknown:
        return '❓';
    }
  }

  String _getRequestTitle(RequestType type) {
    switch (type) {
      case RequestType.addItem:
        return 'בקשה להוספת פריט';
      case RequestType.editItem:
        return 'בקשה לעריכת פריט';
      case RequestType.deleteItem:
        return 'בקשה למחיקת פריט';
      case RequestType.inviteToList:
        return 'הזמנה לרשימה';
      case RequestType.unknown:
        return 'בקשה לא מוכרת';
    }
  }

  String _getRequestContent(PendingRequest request) {
    final data = request.requestData;

    switch (request.type) {
      case RequestType.addItem:
        final name = data['name'] ?? 'לא ידוע';
        final quantity = data['quantity'] ?? 1;
        return '$name (כמות: $quantity)';

      case RequestType.editItem:
        final changes = data['changes'] as Map<String, dynamic>?;
        if (changes == null) return 'שינויים לא ידועים';
        final parts = <String>[];
        if (changes.containsKey('name')) {
          parts.add('שם: ${changes['name']}');
        }
        if (changes.containsKey('quantity')) {
          parts.add('כמות: ${changes['quantity']}');
        }
        return parts.join(', ');

      case RequestType.deleteItem:
        final itemName = data['itemName'] ?? 'פריט';
        return 'מחיקת: $itemName';

      case RequestType.inviteToList:
        final listName = data['list_name'] ?? 'רשימה';
        final role = data['role'] ?? 'משתמש';
        return 'הזמנה לרשימה "$listName" כ-$role';

      case RequestType.unknown:
        return 'תוכן לא מוכר';
    }
  }

  Future<void> _approveRequest(String reviewerId) async {
    // ✅ מניעת לחיצות כפולות
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // ✅ HapticFeedback - lightImpact לאישור
    unawaited(HapticFeedback.lightImpact());

    try {
      // TODO: Call PendingRequestsService.approveRequest()
      // For now, just show message after delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ הבקשה אושרה')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה באישור הבקשה: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectRequest(String reviewerId) async {
    // ✅ מניעת לחיצות כפולות
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // ✅ HapticFeedback - mediumImpact לדחייה (פעולה יותר "כבדה")
    unawaited(HapticFeedback.mediumImpact());

    try {
      // TODO: Call PendingRequestsService.rejectRequest()
      // For now, just show message after delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ הבקשה נדחתה')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בדחיית הבקשה: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
