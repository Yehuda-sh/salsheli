// 📄 lib/widgets/common/pending_requests_section.dart
// Version 4.0 - Hybrid Premium | 22/02/2026
//
// מציג בקשות ממתינות לאישור (הוספה/עריכה/מחיקה של פריטים).
// מופיע בפתק כתום עם כפתורי אישור/דחייה למי שיש הרשאה.
//
// Features:
//   - כניסה מדורגת (Staggered Entrance) עם flutter_animate
//   - כרטיסים בעיצוב Glassmorphic עדין (BackdropFilter)
//   - חתימת Haptic דינמית (Success vs Error)
//   - אופטימיזציית RepaintBoundary
//
// 🔗 Related: PendingRequest, StickyNote

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/request_type.dart';
import '../../models/pending_request.dart';
import '../../providers/user_context.dart';
import 'sticky_note.dart';

/// Widget להצגת בקשות ממתינות
///
/// Version 4.0: Hybrid Premium - staggered entrance, glassmorphic cards,
/// dynamic haptic signatures, RepaintBoundary optimization.
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

    // 🎨 RepaintBoundary isolates card animations from notebook background
    return RepaintBoundary(
      child: Semantics(
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
                    const Gap(kSpacingSmall),
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
                const Gap(kSpacingMedium),

                // 🎬 רשימת בקשות עם כניסה מדורגת (Staggered Entrance)
                ...pendingRequests.asMap().entries.map((entry) {
                  final index = entry.key;
                  final request = entry.value;
                  return _RequestCard(
                    request: request,
                    listId: listId,
                    canApprove: canApprove,
                  )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: (50 * index).ms,
                      )
                      .slideX(
                        begin: 0.1,
                        end: 0,
                        curve: Curves.easeOutCubic,
                        delay: (50 * index).ms,
                      );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// כרטיס בקשה בודדת - Glassmorphic Premium
///
/// ✅ Version 4.0: Glassmorphic surface, shimmer processing, dynamic haptic
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

    // 🎨 Glassmorphic card surface
    Widget cardWidget = ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadiusUnified),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(kBorderRadiusUnified),
          ),
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
                  const Gap(kSpacingSmall),
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

              const Gap(kSpacingSmall),

              // תוכן הבקשה
              Text(
                requestContent,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // כפתורי אישור/דחייה (רק אם יש הרשאה)
              if (widget.canApprove) ...[
                const Gap(kSpacingMedium),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cs.primary),
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
                    const Gap(kSpacingSmall),
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

    // ✨ Shimmer effect during processing - subtle "action in progress" feel
    if (_isProcessing) {
      cardWidget = cardWidget
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1200.ms,
            color: cs.onSurface.withValues(alpha: 0.04),
          );
    }

    return Semantics(
      label: '$requestTitle: $requestContent',
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kSpacingSmall),
        child: cardWidget,
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

    // ✅ Haptic - mediumImpact מיידי לתחילת פעולה
    unawaited(HapticFeedback.mediumImpact());

    try {
      // TODO: Call PendingRequestsService.approveRequest()
      // For now, just show message after delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // ✅ Success Tick - double lightImpact
      unawaited(HapticFeedback.lightImpact());
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());

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

    // ✅ Haptic - heavyImpact לפעולת שלילה
    unawaited(HapticFeedback.heavyImpact());

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
