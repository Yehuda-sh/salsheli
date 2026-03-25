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
// Version 2.1 - Emoji icons → Material Icons + design tokens
// Last Updated: 24/03/2026

import '../../../l10n/app_strings.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final displayName = userContext.displayName ?? AppStrings.shopping.anonymousUser;

    if (userId == null) return;

    // בדוק אם כבר התנדב
    if (item.hasUserVolunteered(userId)) {
      _showSnackBar(AppStrings.shopping.alreadyVolunteered(item.name));
      return;
    }

    // בדוק אם הפריט מלא
    if (item.isVolunteersFull) {
      _showSnackBar(AppStrings.shopping.whoBringsItemFull(item.name));
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

      _showSnackBar(AppStrings.shopping.volunteerSuccess(item.name), isSuccess: true);
    } catch (e) {
      _showSnackBar(AppStrings.shopping.volunteerError);
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

      _showSnackBar(AppStrings.shopping.cancelVolunteer(item.name));
    } catch (e) {
      _showSnackBar(AppStrings.shopping.cancelVolunteerError);
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

      final notificationsService = context.read<NotificationsService>();

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
        }
      }
    } catch (e) {
      debugPrint('WhoBringsScreen: notification send failed — $e');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    final cs = Theme.of(context).colorScheme;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? cs.primary : null,
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
                // 🏷️ Inline header with back button
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
                        width: kIconSizeLarge + kSpacingXTiny,
                        height: kIconSizeLarge + kSpacingXTiny,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: Center(
                          child: Icon(Icons.handshake_outlined, color: cs.primary, size: kIconSizeMedium),
                        ),
                      ),
                      const SizedBox(width: kSpacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.shopping.whoBringsTitle,
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
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),

                // 📊 Header עם סטטיסטיקות
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  padding: const EdgeInsets.all(kSpacingMedium),
                  decoration: BoxDecoration(
                    color: kStickyYellow.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: cs.scrim.withValues(alpha: 0.1),
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
                        label: AppStrings.shopping.statsTotal,
                        value: '$totalItems',
                        color: cs.primary,
                      ),
                      _StatItem(
                        icon: Icons.check_circle,
                        label: AppStrings.shopping.statsCompleted,
                        value: '$fullItems',
                        color: cs.primary,
                      ),
                      _StatItem(
                        icon: Icons.person,
                        label: AppStrings.shopping.statsIBring,
                        value: '$myItems',
                        color: cs.primary,
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
                        Icon(Icons.info_outline, size: kIconSizeSmall + 2, color: cs.primary),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            AppStrings.shopping.whoBringsHint,
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
            color: cs.scrim.withValues(alpha: 0.3),
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
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: isFull
                          ? cs.primary.withValues(alpha: 0.2)
                          : cs.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Icon(
                      isFull ? Icons.check_circle : Icons.group_add,
                      color: isFull ? cs.primary : cs.tertiary,
                      size: kIconSizeMedium,
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
                          ? cs.primary
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Text(
                      '$volunteerCount/$neededCount',
                      style: TextStyle(
                        color: isFull
                            ? cs.onPrimary
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
                    Icon(Icons.people, size: kIconSizeSmall, color: cs.outline),
                    const SizedBox(width: kSpacingTiny),
                    Expanded(
                      child: Text(
                        item.getVolunteerDisplay(maxNames: 3),
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: cs.onSurfaceVariant,
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
                  icon: const Icon(Icons.close, size: kIconSizeSmall + 2),
                  label: Text(AppStrings.shopping.cancelVolunteerButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                )
              else if (!isFull)
                // כפתור התנדבות
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onVolunteer,
                  icon: const Icon(Icons.volunteer_activism, size: kIconSizeSmall + 2),
                  label: Text(AppStrings.shopping.iBringButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                )
              else
                // הפריט מלא
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: cs.primary, size: kIconSizeMedium),
                      const SizedBox(width: kSpacingTiny),
                      Text(
                        AppStrings.shopping.whoBringsFullLabel,
                        style: TextStyle(
                          color: cs.primary,
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: kIconSizeMedium),
            const SizedBox(width: kSpacingXTiny),
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
            color: cs.onSurfaceVariant,
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
            size: kIconSizeXXLarge,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            AppStrings.shopping.whoBringsEmptyTitle,
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            AppStrings.shopping.whoBringsEmptySubtitle,
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
