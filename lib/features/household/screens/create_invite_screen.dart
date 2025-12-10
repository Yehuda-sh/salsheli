// 📄 File: lib/features/household/screens/create_invite_screen.dart
// 🎯 Purpose: מסך יצירת קוד הזמנה למשפחה
//
// 📋 Flow:
// 1. Owner לוחץ על "הזמן בני משפחה"
// 2. נוצר קוד הזמנה (6 תווים)
// 3. אפשר לשתף את הקוד
//
// 📝 Version: 1.0
// 📅 Created: 04/12/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_context.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_button.dart';
import '../../../widgets/common/sticky_note.dart';
import '../models/household_invite.dart';
import '../services/household_service.dart';

class CreateInviteScreen extends StatefulWidget {
  const CreateInviteScreen({super.key});

  @override
  State<CreateInviteScreen> createState() => _CreateInviteScreenState();
}

class _CreateInviteScreenState extends State<CreateInviteScreen> {
  final _householdService = HouseholdService();

  bool _isLoading = true;
  HouseholdInvite? _currentInvite;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrCreateInvite();
  }

  /// 🔄 טעינת קוד קיים או יצירת חדש
  Future<void> _loadOrCreateInvite() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userContext = context.read<UserContext>();
      final householdId = userContext.householdId;
      final userId = userContext.userId;
      final userName = userContext.user?.name ?? 'משתמש';

      if (householdId == null || userId == null) {
        throw Exception('לא מחובר למשפחה');
      }

      // בדיקה אם יש קוד פעיל
      var invite = await _householdService.getActiveInvite(householdId);

      // אם אין קוד פעיל, צור חדש
      if (invite == null) {
        invite = await _householdService.createInviteCode(
          householdId: householdId,
          createdBy: userId,
          createdByName: userName,
        );
      }

      setState(() {
        _currentInvite = invite;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'שגיאה בטעינת קוד: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔄 יצירת קוד חדש
  Future<void> _createNewInvite() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userContext = context.read<UserContext>();
      final householdId = userContext.householdId;
      final userId = userContext.userId;
      final userName = userContext.user?.name ?? 'משתמש';

      if (householdId == null || userId == null) {
        throw Exception('לא מחובר למשפחה');
      }

      final invite = await _householdService.createInviteCode(
        householdId: householdId,
        createdBy: userId,
        createdByName: userName,
      );

      setState(() {
        _currentInvite = invite;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('נוצר קוד הזמנה חדש!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'שגיאה ביצירת קוד: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 📋 העתקת הקוד ללוח
  void _copyCode() {
    if (_currentInvite == null) return;

    Clipboard.setData(ClipboardData(text: _currentInvite!.code));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('הקוד הועתק!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 📤 שיתוף הקוד (העתקה עם הודעה מלאה)
  void _shareCode() {
    if (_currentInvite == null) return;

    final message = '''הזמנה להצטרף למשפחה שלי באפליקציית MemoZap! 🏠

קוד ההזמנה שלך: ${_currentInvite!.code}

הקוד בתוקף עד ${_formatDate(_currentInvite!.expiresAt)}''';

    Clipboard.setData(ClipboardData(text: message));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('הודעת ההזמנה הועתקה! שתף אותה בוואטסאפ או SMS')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// 📅 פורמט תאריך
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// ⏰ פורמט זמן נותר
  String _formatTimeRemaining() {
    if (_currentInvite == null) return '';

    final remaining = _currentInvite!.timeUntilExpiration;

    if (remaining.isNegative) {
      return 'פג תוקף';
    }

    if (remaining.inDays > 0) {
      return '${remaining.inDays} ימים';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} שעות';
    } else {
      return '${remaining.inMinutes} דקות';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('הזמנת בני משפחה'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrCreateInvite,
              child: const Text('נסה שוב'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 📝 הסבר
          const Text(
            'שתף את הקוד הזה עם בני משפחה שרוצים להצטרף',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // 🔑 הקוד
          StickyNote(
            color: const Color(0xFFA5D6A7),
            rotation: 0.01,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    '🔑',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'קוד הזמנה',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _currentInvite?.code ?? '',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'בתוקף עוד ${_formatTimeRemaining()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 📋 כפתורי פעולה
          Row(
            children: [
              Expanded(
                child: StickyButton(
                  label: 'העתק',
                  color: const Color(0xFF80DEEA),
                  onPressed: _copyCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StickyButton(
                  label: 'שתף',
                  color: const Color(0xFFFFCC80),
                  onPressed: _shareCode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔄 קוד חדש
          TextButton.icon(
            onPressed: _createNewInvite,
            icon: const Icon(Icons.refresh),
            label: const Text('צור קוד חדש'),
          ),

          const SizedBox(height: 32),

          // 💡 הוראות
          StickyNote(
            color: const Color(0xFFFFF59D),
            rotation: -0.01,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 הוראות:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('1. שתף את הקוד עם בן המשפחה'),
                  SizedBox(height: 4),
                  Text('2. הם יזינו את הקוד באפליקציה'),
                  SizedBox(height: 4),
                  Text('3. תקבל התראה לאישור הבקשה'),
                  SizedBox(height: 4),
                  Text('4. בחר את ההרשאה שלהם ואשר'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
