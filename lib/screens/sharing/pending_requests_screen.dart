// 📄 File: lib/screens/sharing/pending_requests_screen.dart
//
// 🎯 מטרה: מסך אישור/דחיית בקשות מ-Editors (Phase 3B)
//
// 🔐 הרשאות: רק Owner/Admin רואים מסך זה
//
// 📝 תהליך:
// 1. Editor הוסיף מוצר → בקשה נוצרה (RequestStatus.pending)
// 2. Owner/Admin פותח מסך זה → רואה רשימת בקשות
// 3. Owner/Admin לוחץ ✅ → approveRequest() → מוצר מתווסף לרשימה
// 4. Owner/Admin לוחץ ❌ → rejectRequest() → בקשה נמחקת
// 5. Badge: getPendingRequestsCount() מציג כמה בקשות ממתינות
//
// Version: 1.0
// Last Updated: 04/11/2025

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:memozap/core/ui_constants.dart';
import 'package:memozap/l10n/app_strings.dart';
import 'package:memozap/models/pending_request.dart';
import 'package:memozap/models/shopping_list.dart';
import 'package:memozap/providers/user_context.dart';
import 'package:memozap/repositories/shopping_lists_repository.dart';
import 'package:memozap/services/notifications_service.dart';
import 'package:memozap/services/pending_requests_service.dart';
import 'package:memozap/services/share_list_service.dart';
import 'package:memozap/widgets/common/notebook_background.dart';
import 'package:memozap/widgets/common/sticky_button.dart';
import 'package:memozap/widgets/common/sticky_note.dart';

class PendingRequestsScreen extends StatefulWidget {
  final ShoppingList list;

  const PendingRequestsScreen({super.key, required this.list});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  late PendingRequestsService _service;
  bool _isProcessing = false;
  List<PendingRequest> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    debugPrint('📝 PendingRequestsScreen: פתיחת מסך בקשות ממתינות');

    final userContext = Provider.of<UserContext>(context, listen: false);
    final repository = context.read<ShoppingListsRepository>();
    final shareService = context.read<ShareListService>();

    _service = PendingRequestsService(repository, shareService, userContext);

    // 🔒 Validation: רק Owner/Admin יכולים לראות בקשות
    final currentUserId = userContext.userId!;
    final canApprove = ShareListService.canUserApprove(widget.list, currentUserId);

    if (!canApprove) {
      debugPrint('⛔ PendingRequestsScreen: אין הרשאה - רק Owner/Admin');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.block, color: kStickyPink),
                  const SizedBox(width: kSpacingSmall),
                  Expanded(child: Text(AppStrings.sharing.noPermissionViewRequests)),
                ],
              ),
              backgroundColor: kStickyPink,
            ),
          );

          navigator.pop();
        }
      });
      return;
    }

    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _pendingRequests = _service.getPendingRequests(widget.list);
    });
  }

  Future<void> _approveRequest(PendingRequest request) async {
    if (_isProcessing) return;

    // Capture before async
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.sharing;

    setState(() => _isProcessing = true);

    try {
      final userContext = Provider.of<UserContext>(context, listen: false);
      final notificationsService = NotificationsService(FirebaseFirestore.instance);
      final approverName = userContext.displayName ?? 'מנהל';

      await _service.approveRequest(
        list: widget.list,
        requestId: request.id,
        approverName: approverName,
        notificationsService: notificationsService,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: kStickyGreen),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text(strings.requestApprovedSuccess)),
            ],
          ),
        ),
      );

      _loadRequests();
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: kStickyPink),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text('${strings.requestApprovedError}: $e')),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectRequest(PendingRequest request) async {
    if (_isProcessing) return;

    // Show rejection reason dialog
    final reason = await _showRejectDialog();
    if (reason == null) return; // User canceled

    // Capture before async
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.sharing;

    setState(() => _isProcessing = true);

    try {
      final userContext = Provider.of<UserContext>(context, listen: false);
      final notificationsService = NotificationsService(FirebaseFirestore.instance);
      final rejecterName = userContext.displayName ?? 'מנהל';

      await _service.rejectRequest(
        list: widget.list,
        requestId: request.id,
        reason: reason.isEmpty ? null : reason,
        rejecterName: rejecterName,
        notificationsService: notificationsService,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel, color: kStickyOrange),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text(strings.requestRejectedSuccess)),
            ],
          ),
        ),
      );

      _loadRequests();
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: kStickyPink),
              const SizedBox(width: kSpacingSmall),
              Expanded(child: Text('${strings.requestRejectedError}: $e')),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    final strings = AppStrings.sharing;

    return showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(strings.rejectDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.rejectDialogMessage),
              const SizedBox(height: kSpacingMedium),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(hintText: strings.rejectReasonHint, border: const OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(strings.cancelButton)),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: kStickyPink),
              child: Text(strings.rejectButton),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.sharing;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: Text(strings.pendingRequestsTitle),
          actions: [
            // Badge with count
            if (_pendingRequests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 4),
                    decoration: BoxDecoration(color: kStickyOrange, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${_pendingRequests.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(children: [const NotebookBackground(), _buildContent()]),
      ),
    );
  }

  Widget _buildContent() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(kSpacingMedium),
      itemCount: _pendingRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: kSpacingMedium),
      itemBuilder: (context, index) {
        return _buildRequestCard(_pendingRequests[index], index);
      },
    );
  }

  Widget _buildEmptyState() {
    final strings = AppStrings.sharing;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: kSpacingMedium),
          Text(strings.noPendingRequests, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: kSpacingSmall),
          Text(
            strings.noPendingRequestsSubtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(PendingRequest request, int index) {
    // Alternate colors for visual variety
    final colors = [kStickyCyan, kStickyYellow, kStickyPink, kStickyGreen, kStickyPurple];
    final color = colors[index % colors.length];

    // Alternate rotation for sticky note effect
    final rotations = [0.01, -0.01, 0.015, -0.015, 0.02];
    final rotation = rotations[index % rotations.length];

    final itemName = request.requestData['name'] as String? ?? 'מוצר לא ידוע';
    final quantity = request.requestData['quantity'] as int? ?? 1;
    final requesterName = request.requesterName ?? 'משתמש לא ידוע';

    // Format time using timeago package
    final timeAgo = timeago.format(request.createdAt, locale: 'he', allowFromNow: true);

    return StickyNote(
      color: color,
      rotation: rotation,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Item name + quantity
            Row(
              children: [
                const Icon(Icons.add_shopping_cart, size: 20),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('x$quantity', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),

            // Requester info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(requesterName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: kSpacingSmall),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: kSpacingMedium),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Approve button
                Expanded(
                  child: StickyButton(
                    label: AppStrings.sharing.approveButton,
                    color: kStickyGreen,
                    onPressed: _isProcessing ? null : () => _approveRequest(request),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: kSpacingSmall),

                // Reject button
                Expanded(
                  child: StickyButton(
                    label: AppStrings.sharing.rejectButton,
                    color: kStickyPink,
                    onPressed: _isProcessing ? null : () => _rejectRequest(request),
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),

            // Processing indicator
            if (_isProcessing) ...[
              const SizedBox(height: kSpacingSmall),
              const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ],
          ],
        ),
      ),
    );
  }
}
