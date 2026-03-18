// 📄 lib/widgets/common/pending_requests_section.dart
//
// מציג בקשות ממתינות לאישור — כרטיסים קומפקטיים.
// Version: 5.0 — Compact inline design (no StickyNote, no BackdropFilter)
// Last Updated: 16/03/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../models/enums/request_type.dart';
import '../../models/pending_request.dart';
import '../../providers/shopping_lists_provider.dart';
import '../../providers/user_context.dart';
import '../../services/notifications_service.dart';
import '../../services/pending_requests_service.dart';

/// Widget להצגת בקשות ממתינות — קומפקטי
class PendingRequestsSection extends StatelessWidget {
  final String listId;
  final List<PendingRequest> pendingRequests;
  final bool canApprove;

  const PendingRequestsSection({
    super.key,
    required this.listId,
    required this.pendingRequests,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingRequests.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final warningColor = brand?.warning ?? kStickyOrange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      padding: const EdgeInsets.all(kSpacingSmall),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת
          Row(
            children: [
              Icon(Icons.pending_actions, size: 18, color: cs.onSurface),
              const SizedBox(width: 6),
              Text(
                '${AppStrings.pendingInvitesScreen.pendingRequestsLabel(pendingRequests.length)} (${pendingRequests.length})',
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),

          // בקשות — שורה קומפקטית לכל אחת
          ...pendingRequests.map((request) => _CompactRequestRow(
            request: request,
            listId: listId,
            canApprove: canApprove,
          )),
        ],
      ),
    );
  }
}

/// שורת בקשה קומפקטית — אייקון + שם + כמות + כפתורי ✓/✗
class _CompactRequestRow extends StatefulWidget {
  final PendingRequest request;
  final String listId;
  final bool canApprove;

  const _CompactRequestRow({
    required this.request,
    required this.listId,
    required this.canApprove,
  });

  @override
  State<_CompactRequestRow> createState() => _CompactRequestRowState();
}

class _CompactRequestRowState extends State<_CompactRequestRow> {
  bool _isProcessing = false;

  String _getIcon(RequestType type) {
    switch (type) {
      case RequestType.addItem: return '➕';
      case RequestType.editItem: return '✏️';
      case RequestType.deleteItem: return '🗑️';
      case RequestType.inviteToList:
      case RequestType.inviteToHousehold: return '👥';
      case RequestType.unknown: return '❓';
    }
  }

  String _getContent(PendingRequest request) {
    final data = request.requestData;
    switch (request.type) {
      case RequestType.addItem:
        final name = data['name'] ?? '?';
        final qty = data['quantity'] ?? 1;
        return qty > 1 ? '$name ×$qty' : '$name';
      case RequestType.editItem:
        return data['changes']?.toString() ?? 'עריכה';
      case RequestType.deleteItem:
        return 'מחיקת ${data['itemName'] ?? 'פריט'}';
      default:
        return data['list_name']?.toString() ?? '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brand = Theme.of(context).extension<AppBrand>();
    final successColor = brand?.success ?? kStickyGreen;
    final request = widget.request;
    final requesterName = request.requesterName ?? AppStrings.sharing.unknownUserFallback;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // אייקון סוג
          Text(_getIcon(request.type), style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),

          // תוכן
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$requesterName: ',
                  style: TextStyle(fontSize: kFontSizeSmall, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                TextSpan(
                  text: _getContent(request),
                  style: TextStyle(fontSize: kFontSizeSmall, color: cs.onSurfaceVariant),
                ),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // כפתורי פעולה
          if (widget.canApprove && !_isProcessing) ...[
            // ✅ אשר
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () => _approve(),
                icon: Icon(Icons.check_circle, size: 20, color: successColor),
                padding: EdgeInsets.zero,
                tooltip: AppStrings.pendingInvitesScreen.approveRequest,
              ),
            ),
            // ❌ דחה
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () => _reject(),
                icon: Icon(Icons.cancel, size: 20, color: cs.error.withValues(alpha: 0.7)),
                padding: EdgeInsets.zero,
                tooltip: AppStrings.pendingInvitesScreen.rejectRequest,
              ),
            ),
          ] else if (_isProcessing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.mediumImpact());

    try {
      final userContext = context.read<UserContext>();
      final listsProvider = context.read<ShoppingListsProvider>();
      final notificationsService = context.read<NotificationsService?>();
      final service = PendingRequestsService(listsProvider.repository, userContext);

      final list = listsProvider.lists.where((l) => l.id == widget.listId).firstOrNull;
      if (list == null) throw Exception('List not found');

      await service.approveRequest(
        list: list,
        requestId: widget.request.id,
        approverName: userContext.displayName ?? AppStrings.sharing.unknownUserFallback,
        notificationsService: notificationsService ?? NotificationsService(FirebaseFirestore.instance),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.sharing.requestApprovedSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pendingInvitesScreen.approveError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.heavyImpact());

    try {
      final userContext = context.read<UserContext>();
      final listsProvider = context.read<ShoppingListsProvider>();
      final notificationsService = context.read<NotificationsService?>();
      final service = PendingRequestsService(listsProvider.repository, userContext);

      final list = listsProvider.lists.where((l) => l.id == widget.listId).firstOrNull;
      if (list == null) throw Exception('List not found');

      await service.rejectRequest(
        list: list,
        requestId: widget.request.id,
        rejecterName: userContext.displayName ?? AppStrings.sharing.unknownUserFallback,
        notificationsService: notificationsService ?? NotificationsService(FirebaseFirestore.instance),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.sharing.requestRejectedSuccess), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pendingInvitesScreen.rejectError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
