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
// Version: 1.1 - Emoji icons → Material Icons
// Last Updated: 24/03/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final userContext = Provider.of<UserContext>(context, listen: false);
    final repository = context.read<ShoppingListsRepository>();

    _service = PendingRequestsService(repository, userContext);

    // 🔒 Validation: רק Owner/Admin יכולים לראות בקשות
    final currentUserId = userContext.userId!;
    final canApprove = ShareListService.canUserApprove(widget.list, currentUserId);

    if (!canApprove) {
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
    final cs = Theme.of(context).colorScheme;
    final strings = AppStrings.sharing;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          const NotebookBackground(),
          SafeArea(
            child: Column(
              children: [
                // 📋 Inline header
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        child: Container(
                          padding: const EdgeInsets.all(kSpacingSmall),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                          child: Icon(Icons.arrow_forward_ios,
                              size: kIconSizeSmall, color: cs.onSurface),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: Center(
                          child: Icon(Icons.assignment_outlined, color: cs.primary, size: kIconSizeMedium),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.pendingRequestsTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_pendingRequests.isNotEmpty)
                              Text(
                                '${_pendingRequests.length} בקשות',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ]),
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
          color: cs.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: cs.scrim.withValues(alpha: 0.05),
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
            SizedBox(height: kSpacingLarge),
            Text(
              strings.noPendingRequests,
              style: TextStyle(fontSize: kFontSizeTitle, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSpacingSmall),
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
    final cs = Theme.of(context).colorScheme;
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
      color: isUnknownType ? cs.outlineVariant : color, // 🆕 צבע אפור ל-unknown
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
                        ? cs.tertiary.withValues(alpha: 0.3)
                        : cs.scrim.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: isUnknownType ? cs.tertiary : null),
                      SizedBox(width: 4),
                      Text(typeLabel, style: TextStyle(
                        fontSize: kFontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: isUnknownType ? cs.tertiary : null,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Text(
                    itemName,
                    style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Quantity badge (only for addItem)
                if (request.type == RequestType.addItem) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.scrim.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      'x${request.requestData['quantity'] ?? 1}',
                      style: const TextStyle(fontSize: kFontSizeMedium, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: kSpacingSmall),

            // Requester info
            Row(
              children: [
                Icon(Icons.person, size: 16, color: cs.outline),
                SizedBox(width: 4),
                Text(requesterName, style: TextStyle(fontSize: kFontSizeSmall, color: cs.outline)),
                SizedBox(width: kSpacingSmall),
                Icon(Icons.access_time, size: 16, color: cs.outline),
                SizedBox(width: 4),
                Text(timeAgo, style: TextStyle(fontSize: kFontSizeSmall, color: cs.outline)),
              ],
            ),

            // 🆕 אזהרה עבור unknown
            if (isUnknownType) ...[
              SizedBox(height: kSpacingSmall),
              Container(
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  color: cs.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  border: Border.all(color: cs.tertiary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: cs.tertiary),
                    SizedBox(width: kSpacingSmall),
                    Expanded(
                      child: Text(
                        AppStrings.sharing.unknownRequestWarning,
                        style: TextStyle(fontSize: kFontSizeSmall, color: cs.tertiary),
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
      case RequestType.inviteToHousehold:
        return (
          Icons.person_add,
          strings.requestTypeInvite,
          request.requestData['email'] as String? ?? AppStrings.shopping.defaultInviteLabel,
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
