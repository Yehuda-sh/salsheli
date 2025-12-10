// 📄 File: lib/features/household/screens/join_household_screen.dart
// 🎯 Purpose: מסך הצטרפות למשפחה עם קוד הזמנה
//
// 📋 Flow:
// 1. משתמש מזין קוד 6 תווים
// 2. מערכת מאמתת את הקוד
// 3. נוצרת בקשת הצטרפות
// 4. ממתין לאישור מבעל הבית
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
import '../services/household_service.dart';

class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _householdService = HouseholdService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _householdName;
  String? _householdId;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 🔍 בדיקת קוד הזמנה
  Future<void> _validateCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _householdName = null;
    });

    try {
      final code = _codeController.text.trim().toUpperCase();
      final invite = await _householdService.validateInviteCode(code);

      if (invite == null) {
        setState(() {
          _errorMessage = 'קוד ההזמנה לא נמצא או שפג תוקפו';
        });
        return;
      }

      setState(() {
        _householdId = invite.householdId;
        _householdName = 'משפחת ${invite.createdByName}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'שגיאה בבדיקת הקוד: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 📨 שליחת בקשת הצטרפות
  Future<void> _submitJoinRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userContext = context.read<UserContext>();
      final user = userContext.user;

      if (user == null) {
        throw Exception('משתמש לא מחובר');
      }

      final code = _codeController.text.trim().toUpperCase();

      if (_householdId == null) {
        throw Exception('לא נמצא מזהה משפחה');
      }

      await _householdService.submitJoinRequest(
        inviteCode: code,
        householdId: _householdId!,
        requesterId: user.id,
        requesterName: user.name,
        requesterEmail: user.email,
        requesterAvatar: user.profileImageUrl,
      );

      if (!mounted) return;

      // הצגת הודעת הצלחה וחזרה
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('בקשת ההצטרפות נשלחה! ממתין לאישור'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ בדיקת תקינות קוד
  String? _validateInviteCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'נא להזין קוד הזמנה';
    }

    final code = value.trim().toUpperCase();
    if (code.length != 6) {
      return 'קוד ההזמנה חייב להכיל 6 תווים';
    }

    // בדיקה שהקוד מכיל רק אותיות ומספרים תקינים
    final validChars = RegExp(r'^[A-Z2-9]+$');
    if (!validChars.hasMatch(code)) {
      return 'קוד לא תקין - רק אותיות ומספרים';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('הצטרפות למשפחה'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const NotebookBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 📝 הסבר
                      const Text(
                        'הזן את קוד ההזמנה שקיבלת מבן משפחה',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // 🔑 שדה קוד הזמנה
                      StickyNote(
                        color: const Color(0xFFFFF59D),
                        rotation: 0.01,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _codeController,
                                textAlign: TextAlign.center,
                                textCapitalization: TextCapitalization.characters,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'XXXXXX',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    letterSpacing: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  counterText: '',
                                ),
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]'),
                                  ),
                                  UpperCaseTextFormatter(),
                                ],
                                validator: _validateInviteCode,
                                enabled: !_isLoading,
                                onChanged: (_) {
                                  // נקה הודעות שגיאה ותוצאה קודמת
                                  if (_errorMessage != null || _householdName != null) {
                                    setState(() {
                                      _errorMessage = null;
                                      _householdName = null;
                                      _householdId = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ❌ הודעת שגיאה
                      if (_errorMessage != null)
                        StickyNote(
                          color: const Color(0xFFFFCDD2),
                          rotation: -0.01,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text('❌', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ✅ קוד תקין - מציג שם משפחה
                      if (_householdName != null)
                        StickyNote(
                          color: const Color(0xFFC8E6C9),
                          rotation: 0.01,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('✅', style: TextStyle(fontSize: 32)),
                                const SizedBox(height: 8),
                                const Text(
                                  'קוד תקין!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'מצטרף ל: $_householdName',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 🔘 כפתורים
                      if (_householdName == null)
                        StickyButton(
                          label: _isLoading ? 'בודק...' : 'בדיקת קוד',
                          color: const Color(0xFF80DEEA),
                          onPressed: _isLoading ? null : _validateCode,
                        )
                      else
                        Column(
                          children: [
                            StickyButton(
                              label: _isLoading ? 'שולח...' : 'שליחת בקשת הצטרפות',
                              color: const Color(0xFFA5D6A7),
                              onPressed: _isLoading ? null : _submitJoinRequest,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _householdName = null;
                                        _householdId = null;
                                        _codeController.clear();
                                      });
                                    },
                              child: const Text('הזן קוד אחר'),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // 💡 טיפ
                      const Text(
                        '💡 לאחר שליחת הבקשה, בעל הבית יקבל התראה ויוכל לאשר אותך',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔤 Formatter להפיכת אותיות לגדולות
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
