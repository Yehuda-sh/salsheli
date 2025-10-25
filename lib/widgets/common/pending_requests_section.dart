import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pending_request.dart';
import '../../models/enums/request_type.dart';
import '../../providers/pending_requests_provider.dart';
import '../../providers/user_context.dart';
import '../../core/ui_constants.dart';
import 'sticky_note.dart';

/// Widget להצגת בקשות ממתינות
class PendingRequestsSection extends StatelessWidget {
  final String listId;
  final bool canApprove; // האם המשתמש יכול לאשר בקשות

  const PendingRequestsSection({
    super.key,
    required this.listId,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PendingRequestsProvider>(
      builder: (context, provider, child) {
        final pendingRequests = provider.pendingRequests;

        if (pendingRequests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: kSpacingMedium),
          child: StickyNote(
            color: kStickyOrange,
            rotation: 0.01,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // כותרת
                Row(
                  children: [
                    const Icon(Icons.pending_actions, size: 20),
                    const SizedBox(width: kSpacingSmall),
                    Text(
                      'בקשות ממתינות (${pendingRequests.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}

/// כרטיס בקשה בודדת
class _RequestCard extends StatelessWidget {
  final PendingRequest request;
  final String listId;
  final bool canApprove;

  const _RequestCard({
    required this.request,
    required this.listId,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    final userContext = context.read<UserContext>();
    final theme = Theme.of(context);

    return Card(
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
                  _getRequestIcon(request.type),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRequestTitle(request.type),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${request.requesterName ?? 'משתמש'} • ${request.timeAgoText}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: kSpacingSmall),

            // תוכן הבקשה
            Text(
              _getRequestContent(request),
              style: theme.textTheme.bodyMedium,
            ),

            // כפתורי אישור/דחייה (רק אם יש הרשאה)
            if (canApprove) ...[
              const SizedBox(height: kSpacingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // דחה
                  TextButton.icon(
                    onPressed: () => _rejectRequest(context, userContext.userId!),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('דחה'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),
                  // אשר
                  FilledButton.icon(
                    onPressed: () => _approveRequest(context, userContext.userId!),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('אשר'),
                  ),
                ],
              ),
            ],
          ],
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
    }
  }

  void _approveRequest(BuildContext context, String reviewerId) {
    final provider = context.read<PendingRequestsProvider>();
    provider.approveRequest(
      listId: listId,
      requestId: request.id,
      reviewerId: reviewerId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ הבקשה אושרה')),
    );
  }

  void _rejectRequest(BuildContext context, String reviewerId) {
    final provider = context.read<PendingRequestsProvider>();
    provider.rejectRequest(
      listId: listId,
      requestId: request.id,
      reviewerId: reviewerId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ הבקשה נדחתה')),
    );
  }
}
