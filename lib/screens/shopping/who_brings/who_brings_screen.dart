// 📄 File: lib/screens/shopping/who_brings/who_brings_screen.dart
//
// 🎯 Purpose: מסך רשימת "מי מביא" - הצגת פריטים עם אפשרות התנדבות
//
// ✨ Features:
// - 📋 רשימת פריטים עם תצוגת X/Y מתנדבים
// - ✋ כפתור "אני מביא" לכל פריט
// - 👥 תצוגת שמות מתנדבים
// - 🔒 חסימה כשהפריט מלא
// - ↩️ ביטול התנדבות
// - 🎨 עיצוב Sticky Note
//
// 🔗 Related:
// - unified_list_item.dart - מודל פריט עם volunteers
// - shopping_lists_provider.dart - עדכון מתנדבים
//
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../services/notifications_service.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_note.dart';

class WhoBringsScreen extends StatefulWidget {
  final ShoppingList list;

  const WhoBringsScreen({super.key, required this.list});

  @override
  State<WhoBringsScreen> createState() => _WhoBringsScreenState();
}

class _WhoBringsScreenState extends State<WhoBringsScreen> {
  late ShoppingList _list;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  /// הוספת התנדבות לפריט
  Future<void> _volunteer(UnifiedListItem item) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final displayName = userContext.displayName ?? 'אנונימי';

    if (userId == null) return;

    // בדוק אם כבר התנדב
    if (item.hasUserVolunteered(userId)) {
      _showSnackBar('כבר התנדבת להביא את ${item.name}');
      return;
    }

    // בדוק אם הפריט מלא
    if (item.isVolunteersFull) {
      _showSnackBar('${item.name} כבר מלא!');
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ShoppingListsProvider>();

      // הוסף מתנדב חדש
      final newVolunteer = {
        'userId': userId,
        'displayName': displayName,
        'volunteeredAt': DateTime.now().toIso8601String(),
      };

      final updatedVolunteers = [...item.volunteers, newVolunteer];

      // עדכן את הפריט
      final updatedTaskData = Map<String, dynamic>.from(item.taskData ?? {});
      updatedTaskData['volunteers'] = updatedVolunteers;

      final updatedItem = item.copyWith(taskData: updatedTaskData);

      await provider.updateItemById(_list.id, updatedItem);

      // עדכן את הרשימה המקומית
      _updateLocalList(updatedItem);

      // 📬 שלח התראה לבעל הרשימה ולאדמינים
      await _sendVolunteerNotification(item, displayName);

      _showSnackBar('נרשמת להביא: ${item.name} ✓', isSuccess: true);
    } catch (e) {
      debugPrint('❌ Error volunteering: $e');
      _showSnackBar('שגיאה בהרשמה');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ביטול התנדבות
  Future<void> _cancelVolunteer(UnifiedListItem item) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;

    if (userId == null) return;

    // בדוק אם התנדב
    if (!item.hasUserVolunteered(userId)) {
      return;
    }

    unawaited(HapticFeedback.lightImpact());

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ShoppingListsProvider>();

      // הסר את המתנדב
      final updatedVolunteers = item.volunteers
          .where((v) => v['userId'] != userId)
          .toList();

      // עדכן את הפריט
      final updatedTaskData = Map<String, dynamic>.from(item.taskData ?? {});
      updatedTaskData['volunteers'] = updatedVolunteers;

      final updatedItem = item.copyWith(taskData: updatedTaskData);

      await provider.updateItemById(_list.id, updatedItem);

      // עדכן את הרשימה המקומית
      _updateLocalList(updatedItem);

      _showSnackBar('ביטלת את ההתנדבות ל${item.name}');
    } catch (e) {
      debugPrint('❌ Error canceling volunteer: $e');
      _showSnackBar('שגיאה בביטול');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// עדכון הרשימה המקומית
  void _updateLocalList(UnifiedListItem updatedItem) {
    final updatedItems = _list.items.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();

    setState(() {
      _list = _list.copyWith(items: updatedItems);
    });
  }

  /// 📬 שליחת התראה על התנדבות חדשה
  Future<void> _sendVolunteerNotification(UnifiedListItem item, String volunteerName) async {
    try {
      final userContext = context.read<UserContext>();
      final currentUserId = userContext.userId;
      final householdId = userContext.user?.householdId;

      if (householdId == null) return;

      final notificationsService = NotificationsService(FirebaseFirestore.instance);

      // שלח התראה לבעל הרשימה (אם זה לא המשתמש הנוכחי)
      final creatorId = _list.createdBy;
      if (creatorId != currentUserId) {
        await notificationsService.createWhoBringsVolunteerNotification(
          userId: creatorId,
          householdId: householdId,
          listId: _list.id,
          listName: _list.name,
          itemName: item.name,
          volunteerName: volunteerName,
        );
        debugPrint('📬 התראה נשלחה לבעל הרשימה: $creatorId');
      }

      // שלח התראה לאדמינים (sharedUsers עם role=admin)
      for (final entry in _list.sharedUsers.entries) {
        final sharedUserId = entry.key;
        final sharedUser = entry.value;

        if (sharedUser.role.name == 'admin' && sharedUserId != currentUserId && sharedUserId != creatorId) {
          await notificationsService.createWhoBringsVolunteerNotification(
            userId: sharedUserId,
            householdId: householdId,
            listId: _list.id,
            listName: _list.name,
            itemName: item.name,
            volunteerName: volunteerName,
          );
          debugPrint('📬 התראה נשלחה לאדמין: $sharedUserId');
        }
      }
    } catch (e) {
      debugPrint('⚠️ שגיאה בשליחת התראות (לא קריטי): $e');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final userContext = context.watch<UserContext>();
    final userId = userContext.userId;

    // חשב סטטיסטיקות
    final totalItems = _list.items.length;
    final fullItems = _list.items.where((i) => i.isVolunteersFull).length;
    final myItems = _list.items.where((i) =>
        userId != null && i.hasUserVolunteered(userId)).length;

    return Stack(
      children: [
        const NotebookBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 🏷️ כותרת inline
                Padding(
                  padding: const EdgeInsets.all(kSpacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.volunteer_activism, size: 24, color: cs.primary),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'מי מביא?',
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 📊 Header עם סטטיסטיקות
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  padding: const EdgeInsets.all(kSpacingMedium),
                  decoration: BoxDecoration(
                    color: kStickyYellow.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.list_alt,
                        label: 'סה"כ',
                        value: '$totalItems',
                        color: cs.primary,
                      ),
                      _StatItem(
                        icon: Icons.check_circle,
                        label: 'הושלם',
                        value: '$fullItems',
                        color: Colors.green,
                      ),
                      _StatItem(
                        icon: Icons.person,
                        label: 'אני מביא',
                        value: '$myItems',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: kSpacingSmall),

                // 📝 הוראות
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  child: Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: cs.primary),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            'לחץ על "אני מביא" כדי להתנדב להביא פריט',
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpacingSmall),

                // 📋 רשימת פריטים
                Expanded(
                  child: _list.items.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                          itemCount: _list.items.length,
                          itemBuilder: (context, index) {
                            final item = _list.items[index];
                            final hasVolunteered = userId != null &&
                                item.hasUserVolunteered(userId);

                            return _WhoBringsItemTile(
                              item: item,
                              hasVolunteered: hasVolunteered,
                              onVolunteer: () => _volunteer(item),
                              onCancelVolunteer: () => _cancelVolunteer(item),
                              isLoading: _isLoading,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

// ========================================
// Widget: פריט "מי מביא"
// ========================================

class _WhoBringsItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final bool hasVolunteered;
  final VoidCallback onVolunteer;
  final VoidCallback onCancelVolunteer;
  final bool isLoading;

  const _WhoBringsItemTile({
    required this.item,
    required this.hasVolunteered,
    required this.onVolunteer,
    required this.onCancelVolunteer,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isFull = item.isVolunteersFull;
    final volunteerCount = item.volunteerCount;
    final neededCount = item.neededCount;

    // צבע הפתק לפי מצב
    Color stickyColor;
    if (isFull) {
      stickyColor = kStickyGreen; // מלא - ירוק
    } else if (volunteerCount > 0) {
      stickyColor = kStickyYellow; // יש מתנדבים - צהוב
    } else {
      stickyColor = kStickyPink; // אין מתנדבים - ורוד
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: StickyNote(
        color: stickyColor,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === שורה עליונה: שם + מונה ===
              Row(
                children: [
                  // אייקון סטטוס
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isFull ? Icons.check_circle : Icons.group_add,
                      color: isFull ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),

                  // שם הפריט
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                        decoration: isFull ? TextDecoration.lineThrough : null,
                        color: isFull
                            ? cs.onSurface.withValues(alpha: 0.6)
                            : cs.onSurface,
                      ),
                    ),
                  ),

                  // מונה X/Y
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingSmall,
                      vertical: kSpacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.green
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      '$volunteerCount/$neededCount',
                      style: TextStyle(
                        color: isFull
                            ? Colors.white
                            : cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: kFontSizeMedium,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // === שמות מתנדבים ===
              if (volunteerCount > 0) ...[
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: kSpacingTiny),
                    Expanded(
                      child: Text(
                        item.getVolunteerDisplay(maxNames: 3),
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingSmall),
              ],

              // === כפתור פעולה ===
              if (hasVolunteered)
                // כפתור ביטול
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onCancelVolunteer,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('בטל התנדבות'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                )
              else if (!isFull)
                // כפתור התנדבות
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onVolunteer,
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: const Text('אני מביא! ✋'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                )
              else
                // הפריט מלא
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      SizedBox(width: kSpacingTiny),
                      Text(
                        'מלא! ✓',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// Widget: סטטיסטיקה
// ========================================

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: kFontSizeLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: kFontSizeTiny,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: Empty State
// ========================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אין פריטים ברשימה',
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'הוסף פריטים כדי שחברי הקבוצה יוכלו להתנדב',
            style: TextStyle(
              fontSize: kFontSizeSmall,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
