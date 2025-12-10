// 📄 File: lib/features/household/screens/household_requests_screen.dart
// 🎯 Purpose: מסך בקשות הצטרפות ממתינות
//
// 📋 Flow:
// 1. Owner רואה רשימת בקשות ממתינות
// 2. לכל בקשה: אישור/דחייה
// 3. באישור - בוחר תפקיד למשתמש
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/enums/user_role.dart';
import '../../../providers/user_context.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_note.dart';
import '../models/household_join_request.dart';
import '../services/household_service.dart';

class HouseholdRequestsScreen extends StatefulWidget {
  const HouseholdRequestsScreen({super.key});

  @override
  State<HouseholdRequestsScreen> createState() =>
      _HouseholdRequestsScreenState();
}

class _HouseholdRequestsScreenState extends State<HouseholdRequestsScreen> {
  final _householdService = HouseholdService();

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContext>();
    final householdId = userContext.householdId;

    if (householdId == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('בקשות הצטרפות')),
          body: const Center(child: Text('לא מחובר למשפחה')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('בקשות הצטרפות'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: StreamBuilder<List<HouseholdJoinRequest>>(
                stream: _householdService.watchPendingRequests(householdId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('שגיאה: ${snapshot.error}'),
                    );
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(requests[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'אין בקשות ממתינות',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'כשמישהו יזין את קוד ההזמנה שלך,\nהבקשה תופיע כאן',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(HouseholdJoinRequest request) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StickyNote(
        color: const Color(0xFFB3E5FC),
        rotation: 0.005,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 פרטי המבקש
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: request.requesterAvatar != null
                        ? NetworkImage(request.requesterAvatar!)
                        : null,
                    child: request.requesterAvatar == null
                        ? Text(
                            request.requesterName.isNotEmpty
                                ? request.requesterName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requesterName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          request.requesterEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 📅 תאריך הבקשה
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'נשלחה ב-${_formatDateTime(request.requestedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // 🔘 כפתורי פעולה
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        'דחייה',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(request),
                      icon: const Icon(Icons.check),
                      label: const Text('אישור'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// ✅ דיאלוג אישור עם בחירת תפקיד
  void _showApproveDialog(HouseholdJoinRequest request) {
    UserRole selectedRole = UserRole.editor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('אישור בקשה'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('לאשר את ${request.requesterName}?'),
                const SizedBox(height: 16),
                const Text(
                  'בחר תפקיד:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // תפקידים
                ...UserRole.values
                    .where((r) => r != UserRole.owner)
                    .map((role) => RadioListTile<UserRole>(
                          title: Text(_getRoleTitle(role)),
                          subtitle: Text(
                            _getRoleDescription(role),
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: role,
                          groupValue: selectedRole,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedRole = value);
                            }
                          },
                          dense: true,
                        )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ביטול'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _approveRequest(request, selectedRole);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('אישור'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ❌ דיאלוג דחייה
  void _showRejectDialog(HouseholdJoinRequest request) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('דחיית בקשה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('לדחות את הבקשה של ${request.requesterName}?'),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'הודעה (אופציונלי)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectRequest(request, messageController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('דחייה'),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ אישור הבקשה
  Future<void> _approveRequest(
      HouseholdJoinRequest request, UserRole role) async {
    try {
      final userContext = context.read<UserContext>();
      final reviewerId = userContext.userId;

      if (reviewerId == null) return;

      await _householdService.approveJoinRequest(
        requestId: request.id,
        reviewerId: reviewerId,
        assignedRole: role,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.requesterName} הצטרף למשפחה!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ❌ דחיית הבקשה
  Future<void> _rejectRequest(
      HouseholdJoinRequest request, String? message) async {
    try {
      final userContext = context.read<UserContext>();
      final reviewerId = userContext.userId;

      if (reviewerId == null) return;

      await _householdService.rejectJoinRequest(
        requestId: request.id,
        reviewerId: reviewerId,
        message: message?.isNotEmpty == true ? message : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('הבקשה של ${request.requesterName} נדחתה'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '👨‍💼 מנהל';
      case UserRole.editor:
        return '✏️ עורך';
      case UserRole.viewer:
        return '👁️ צופה';
      case UserRole.owner:
        return '👑 בעלים';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'יכול להזמין ולנהל משתמשים';
      case UserRole.editor:
        return 'יכול לערוך רשימות ומלאי';
      case UserRole.viewer:
        return 'יכול לצפות בלבד';
      case UserRole.owner:
        return 'שליטה מלאה';
    }
  }
}
