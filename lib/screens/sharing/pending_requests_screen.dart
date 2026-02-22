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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/ui_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/enums/request_type.dart';
import '../../models/pending_request.dart';
import '../../models/shopping_list.dart';
import '../../providers/user_context.dart';
import '../../repositories/shopping_lists_repository.dart';
import '../../services/notifications_service.dart';
import '../../services/pending_requests_service.dart';
import '../../services/share_list_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

class PendingRequestsScreen extends StatefulWidget {
  final ShoppingList list;

  const PendingRequestsScreen({super.key, required this.list});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  late PendingRequestsService _service;
  String? _processingRequestId; // ID של הבקשה שנמצאת בעיבוד (null = אף אחת)
  List<PendingRequest> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    debugPrint('📝 PendingRequestsScreen: פתיחת מסך בקשות ממתינות');

    final userContext = Provider.of<UserContext>(context, listen: false);
    final repository = context.read<ShoppingListsRepository>();

    _service = PendingRequestsService(repository, userContext);

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
    if (_processingRequestId != null) return;

    // Capture before async
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.sharing;

    setState(() => _processingRequestId = request.id);

    try {
      final userContext = Provider.of<UserContext>(context, listen: false);
      final notificationsService = NotificationsService(FirebaseFirestore.instance);
      final approverName = userContext.displayName ?? strings.roleAdmin;

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
        setState(() => _processingRequestId = null);
      }
    }
  }

  Future<void> _rejectRequest(PendingRequest request) async {
    if (_processingRequestId != null) return;

    // Capture before async
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.sharing;
    final userContext = Provider.of<UserContext>(context, listen: false);
    final notificationsService = NotificationsService(FirebaseFirestore.instance);
    final rejecterName = userContext.displayName ?? strings.roleAdmin;

    // Show rejection reason dialog
    final reason = await _showRejectDialog();
    if (reason == null) return; // User canceled

    setState(() => _processingRequestId = request.id);

    try {
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
        setState(() => _processingRequestId = null);
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancelButton)),
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
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(kSpacingLarge),
        padding: const EdgeInsets.all(kSpacingXLarge),
        decoration: BoxDecoration(
          // 🎨 בועה לבנה שקופה - נקי וקריא על רקע מחברת
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(kSpacingLarge),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined, size: 64, color: cs.primary),
            ),
            const SizedBox(height: kSpacingLarge),
            Text(
              strings.noPendingRequests,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingSmall),
            Text(
              strings.noPendingRequestsSubtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingLarge),
            StickyButtonSmall(
              color: kStickyGreen,
              label: strings.backButton,
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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

    final requesterName = request.requesterName ?? AppStrings.sharing.unknownUserFallback;
    final timeAgo = timeago.format(request.createdAt, locale: 'he', allowFromNow: true);

    // 🆕 בדיקה אם סוג הבקשה ידוע
    final isUnknownType = request.type == RequestType.unknown;

    // 🆕 אייקון וטקסט לפי סוג הבקשה
    final (IconData icon, String typeLabel, String itemName) = _getRequestTypeInfo(request);

    return StickyNote(
      color: isUnknownType ? Colors.grey.shade300 : color, // 🆕 צבע אפור ל-unknown
      rotation: rotation,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type badge + Item name
            Row(
              children: [
                // 🆕 Badge סוג בקשה
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnknownType
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: isUnknownType ? Colors.orange.shade800 : null),
                      const SizedBox(width: 4),
                      Text(typeLabel, style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isUnknownType ? Colors.orange.shade800 : null,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Quantity badge (only for addItem)
                if (request.type == RequestType.addItem) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'x${request.requestData['quantity'] ?? 1}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
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

            // 🆕 אזהרה עבור unknown
            if (isUnknownType) ...[
              const SizedBox(height: kSpacingSmall),
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        AppStrings.sharing.unknownRequestWarning,
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: kSpacingMedium),

            // Action buttons - 🆕 מושבתים עבור unknown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Approve button
                Expanded(
                  child: StickyButton(
                    label: AppStrings.sharing.approveButton,
                    color: kStickyGreen,
                    // 🆕 מושבת אם processing או unknown
                    onPressed: (_processingRequestId != null || isUnknownType)
                        ? null
                        : () => _approveRequest(request),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: kSpacingSmall),

                // Reject button
                Expanded(
                  child: StickyButton(
                    label: AppStrings.sharing.rejectButton,
                    color: kStickyPink,
                    // 🆕 מושבת אם processing או unknown
                    onPressed: (_processingRequestId != null || isUnknownType)
                        ? null
                        : () => _rejectRequest(request),
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),

            // Processing indicator
            if (_processingRequestId == request.id) ...[
              const SizedBox(height: kSpacingSmall),
              const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ],
          ],
        ),
      ),
    );
  }

  /// 🆕 מחזיר אייקון, תווית וטקסט לפי סוג הבקשה
  (IconData, String, String) _getRequestTypeInfo(PendingRequest request) {
    final strings = AppStrings.sharing;

    switch (request.type) {
      case RequestType.addItem:
        return (
          Icons.add_shopping_cart,
          strings.requestTypeAdd,
          request.requestData['name'] as String? ?? strings.unknownItemFallback,
        );
      case RequestType.editItem:
        return (
          Icons.edit,
          strings.requestTypeEdit,
          request.changes?['name'] as String? ??
              request.requestData['itemName'] as String? ??
              strings.editItemFallback,
        );
      case RequestType.deleteItem:
        return (
          Icons.delete_outline,
          strings.requestTypeDelete,
          request.requestData['itemName'] as String? ?? strings.deleteItemFallback,
        );
      case RequestType.inviteToList:
        return (
          Icons.person_add,
          strings.requestTypeInvite,
          request.requestData['email'] as String? ?? 'הזמנה',
        );
      case RequestType.unknown:
        return (
          Icons.help_outline,
          strings.requestTypeUnknown,
          strings.unknownRequestFallback,
        );
    }
  }
}
