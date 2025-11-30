// 📄 File: lib/screens/demo/demo_user_selection_screen.dart
// 🎯 מסך בחירת משתמש דמו - מאפשר להיכנס כאחד מבני משפחת כהן

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui_constants.dart';
import '../../models/enums/user_role.dart';
import '../../services/demo_family_service.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_button.dart';
import '../../widgets/common/sticky_note.dart';

class DemoUserSelectionScreen extends StatefulWidget {
  const DemoUserSelectionScreen({super.key});

  @override
  State<DemoUserSelectionScreen> createState() => _DemoUserSelectionScreenState();
}

class _DemoUserSelectionScreenState extends State<DemoUserSelectionScreen> {
  final DemoFamilyService _demoService = DemoFamilyService();
  bool _isLoading = false;
  String? _loadingUserId;

  Future<void> _selectUser(DemoUser user) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingUserId = user.id;
    });

    try {
      await _demoService.signInAsDemoUser(user);

      if (mounted) {
        // נווט לדף הבית
        unawaited(Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בהתחברות: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingUserId = null;
        });
      }
    }
  }

  Color _getRoleColor(DemoUser user) {
    switch (user.role) {
      case UserRole.owner:
        return kStickyYellow;
      case UserRole.admin:
        return kStickyGreen;
      case UserRole.editor:
        return kStickyCyan;
      case UserRole.viewer:
        return kStickyPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPaperBackground,
        appBar: AppBar(
          title: const Text('בחר בן משפחה'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 📝 כותרת
                    StickyNote(
                      color: Colors.white,
                      rotation: -0.01,
                      child: Column(
                        children: [
                          const Text(
                            '👨‍👩‍👧‍👦 משפחת כהן',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: kSpacingSmall),
                          Text(
                            'בחר באיזה בן משפחה תרצה להיכנס\nכדי לראות את ההרשאות השונות',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: kSpacingLarge),

                    // 👥 כרטיסי משתמשים
                    ...DemoFamilyService.demoUsers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final user = entry.value;
                      final isLoadingThis = _loadingUserId == user.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingMedium),
                        child: _buildUserCard(user, isLoadingThis)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (100 * index).ms)
                            .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
                      );
                    }),

                    const SizedBox(height: kSpacingMedium),

                    // 🔙 כפתור חזרה
                    StickyButton(
                      label: 'חזרה',
                      icon: Icons.arrow_back,
                      color: Colors.white,
                      textColor: Colors.black87,
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(DemoUser user, bool isLoading) {
    final color = _getRoleColor(user);

    return GestureDetector(
      onTap: isLoading || _isLoading ? null : () => _selectUser(user),
      child: StickyNote(
        color: color,
        rotation: user.role == UserRole.owner ? 0.01 : (user.role == UserRole.admin ? -0.01 : 0.005),
        child: Row(
          children: [
            // אימוג'י
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  user.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: kSpacingMedium),

            // פרטים
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // אינדיקטור טעינה או חץ
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
