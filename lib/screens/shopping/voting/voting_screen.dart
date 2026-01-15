// 📄 File: lib/screens/shopping/voting/voting_screen.dart
//
// 🎯 Purpose: מסך רשימת הצבעה - הצגת פריטים להצבעה
//
// ✨ Features:
// - 📋 רשימת פריטים להצבעה
// - 👍👎 כפתורי הצבעה (בעד/נגד/נמנע)
// - 📊 תצוגת תוצאות בזמן אמת
// - 🔒 הצבעה חשאית/גלויה
// - ⏰ תאריך סיום הצבעה
// - 🎨 עיצוב Sticky Note
//
// 🔗 Related:
// - unified_list_item.dart - מודל פריט עם votes
// - shopping_lists_provider.dart - עדכון הצבעות
//
// Version 2.0 - No AppBar (Immersive)
// Last Updated: 13/01/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../../core/ui_constants.dart';
import '../../../models/shopping_list.dart';
import '../../../models/unified_list_item.dart';
import '../../../providers/shopping_lists_provider.dart';
import '../../../providers/user_context.dart';
import '../../../services/notifications_service.dart';
import '../../../widgets/common/notebook_background.dart';
import '../../../widgets/common/sticky_note.dart';

class VotingScreen extends StatefulWidget {
  final ShoppingList list;

  const VotingScreen({super.key, required this.list});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  late ShoppingList _list;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  /// הצבעה על פריט
  Future<void> _vote(UnifiedListItem item, String voteType) async {
    final userContext = context.read<UserContext>();
    final userId = userContext.userId;
    final displayName = userContext.displayName ?? 'אנונימי';

    if (userId == null) return;

    // בדוק אם כבר הצביע
    if (item.hasUserVoted(userId)) {
      _showSnackBar('כבר הצבעת על ${item.name}');
      return;
    }

    // בדוק אם ההצבעה הסתיימה
    if (item.hasVotingEnded) {
      _showSnackBar('ההצבעה על ${item.name} הסתיימה');
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ShoppingListsProvider>();

      // הוסף הצבעה חדשה
      final newVote = {
        'userId': userId,
        'displayName': item.isAnonymousVoting ? null : displayName,
        'votedAt': DateTime.now().toIso8601String(),
      };

      final updatedTaskData = Map<String, dynamic>.from(item.taskData ?? {});

      // הוסף לרשימה המתאימה
      switch (voteType) {
        case 'for':
          final currentVotes = List<Map<String, dynamic>>.from(
              updatedTaskData['votesFor'] as List? ?? []);
          currentVotes.add(newVote);
          updatedTaskData['votesFor'] = currentVotes;
          break;
        case 'against':
          final currentVotes = List<Map<String, dynamic>>.from(
              updatedTaskData['votesAgainst'] as List? ?? []);
          currentVotes.add(newVote);
          updatedTaskData['votesAgainst'] = currentVotes;
          break;
        case 'abstain':
          final currentVotes = List<Map<String, dynamic>>.from(
              updatedTaskData['votesAbstain'] as List? ?? []);
          currentVotes.add(newVote);
          updatedTaskData['votesAbstain'] = currentVotes;
          break;
      }

      final updatedItem = item.copyWith(taskData: updatedTaskData);

      await provider.updateItemById(_list.id, updatedItem);

      // עדכן את הרשימה המקומית
      _updateLocalList(updatedItem);

      // 📬 שלח התראה לבעל הרשימה
      await _sendVoteNotification(item, displayName, voteType);

      // 📬 בדוק אם יש תיקו והצבעה הסתיימה
      await _checkForTieAndNotify(updatedItem);

      final voteLabel = voteType == 'for'
          ? 'בעד 👍'
          : voteType == 'against'
              ? 'נגד 👎'
              : 'נמנע 🤷';
      _showSnackBar('הצבעת $voteLabel על ${item.name}', isSuccess: true);
    } catch (e) {
      debugPrint('❌ Error voting: $e');
      _showSnackBar('שגיאה בהצבעה');
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

  /// 📬 שליחת התראה על הצבעה חדשה
  Future<void> _sendVoteNotification(UnifiedListItem item, String voterName, String voteType) async {
    try {
      final userContext = context.read<UserContext>();
      final currentUserId = userContext.userId;
      final householdId = userContext.user?.householdId;

      if (householdId == null) return;

      // לא שולחים התראה אם ההצבעה חשאית
      if (item.isAnonymousVoting) {
        debugPrint('📬 הצבעה חשאית - לא שולח התראות');
        return;
      }

      final notificationsService = NotificationsService(FirebaseFirestore.instance);

      // שלח התראה לבעל הרשימה (אם זה לא המשתמש הנוכחי)
      final creatorId = _list.createdBy;
      if (creatorId != currentUserId) {
        await notificationsService.createNewVoteNotification(
          userId: creatorId,
          householdId: householdId,
          listId: _list.id,
          listName: _list.name,
          itemName: item.name,
          voterName: voterName,
          voteType: voteType,
        );
        debugPrint('📬 התראת הצבעה נשלחה לבעל הרשימה: $creatorId');
      }
    } catch (e) {
      debugPrint('⚠️ שגיאה בשליחת התראת הצבעה (לא קריטי): $e');
    }
  }

  /// 📬 בדיקה אם יש תיקו ושליחת התראה לבעלים
  Future<void> _checkForTieAndNotify(UnifiedListItem item) async {
    try {
      // בדוק רק אם ההצבעה הסתיימה
      if (!item.hasVotingEnded) return;

      // בדוק אם יש תיקו
      if (item.votingResult != 'tie') return;

      final userContext = context.read<UserContext>();
      final householdId = userContext.user?.householdId;

      if (householdId == null) return;

      final notificationsService = NotificationsService(FirebaseFirestore.instance);

      // שלח התראה לבעל הרשימה
      final creatorId = _list.createdBy;
      await notificationsService.createVoteTieNotification(
        userId: creatorId,
        householdId: householdId,
        listId: _list.id,
        listName: _list.name,
        itemName: item.name,
        votesFor: item.votesFor.length,
        votesAgainst: item.votesAgainst.length,
      );
      debugPrint('📬 התראת תיקו נשלחה לבעל הרשימה: $creatorId');
    } catch (e) {
      debugPrint('⚠️ שגיאה בשליחת התראת תיקו (לא קריטי): $e');
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
    final votedItems = _list.items
        .where((i) => userId != null && i.hasUserVoted(userId))
        .length;
    final endedItems = _list.items.where((i) => i.hasVotingEnded).length;

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
                      Icon(Icons.how_to_vote, size: 24, color: cs.primary),
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
                              'הצבעה',
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
                    color: kStickyPurple.withValues(alpha: 0.9),
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
                        icon: Icons.how_to_vote,
                        label: 'סה"כ',
                        value: '$totalItems',
                        color: Colors.purple,
                      ),
                      _StatItem(
                        icon: Icons.check_circle,
                        label: 'הצבעתי',
                        value: '$votedItems',
                        color: Colors.green,
                      ),
                      _StatItem(
                        icon: Icons.timer_off,
                        label: 'הסתיים',
                        value: '$endedItems',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),

                // 📝 הוראות
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
                  child: Container(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Colors.purple),
                        const SizedBox(width: kSpacingSmall),
                        Expanded(
                          child: Text(
                            'לחץ על 👍 בעד, 👎 נגד, או 🤷 נמנע',
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: kSpacingMedium),
                          itemCount: _list.items.length,
                          itemBuilder: (context, index) {
                            final item = _list.items[index];
                            final hasVoted =
                                userId != null && item.hasUserVoted(userId);
                            final userVote =
                                userId != null ? item.getUserVote(userId) : null;

                            return _VotingItemTile(
                              item: item,
                              hasVoted: hasVoted,
                              userVote: userVote,
                              onVote: (voteType) => _vote(item, voteType),
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
// Widget: פריט הצבעה
// ========================================

class _VotingItemTile extends StatelessWidget {
  final UnifiedListItem item;
  final bool hasVoted;
  final String? userVote;
  final void Function(String voteType) onVote;
  final bool isLoading;

  const _VotingItemTile({
    required this.item,
    required this.hasVoted,
    required this.userVote,
    required this.onVote,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasEnded = item.hasVotingEnded;
    final isAnonymous = item.isAnonymousVoting;

    // צבע הפתק לפי מצב
    Color stickyColor;
    if (hasEnded) {
      stickyColor = kStickyGreen; // הסתיים
    } else if (hasVoted) {
      stickyColor = kStickyYellow; // הצבעתי
    } else {
      stickyColor = kStickyPurple; // ממתין להצבעה
    }

    // תוצאה
    final votingResult = item.votingResult;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingSmall),
      child: StickyNote(
        color: stickyColor,
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === שורה עליונה: שם + תגיות ===
              Row(
                children: [
                  // אייקון סטטוס
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasEnded
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasEnded ? Icons.how_to_vote : Icons.pending_actions,
                      color: hasEnded ? Colors.grey : Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: kSpacingSmall),

                  // שם הפריט
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: kFontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        if (item.votingEndDate != null)
                          Text(
                            hasEnded
                                ? 'הסתיים'
                                : 'עד ${DateFormat('dd/MM HH:mm').format(item.votingEndDate!)}',
                            style: TextStyle(
                              fontSize: kFontSizeTiny,
                              color: hasEnded ? Colors.grey : Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // תגיות
                  if (isAnonymous)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacingSmall,
                        vertical: kSpacingXTiny,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_off, size: 12, color: Colors.grey),
                          SizedBox(width: 2),
                          Text(
                            'חשאי',
                            style: TextStyle(
                              fontSize: kFontSizeTiny,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: kSpacingSmall),

              // === בר התקדמות ===
              _VotingProgressBar(
                forCount: item.votesFor.length,
                againstCount: item.votesAgainst.length,
                abstainCount: item.votesAbstain.length,
              ),

              const SizedBox(height: kSpacingSmall),

              // === כפתורי הצבעה או תוצאה ===
              if (hasEnded)
                // הצבעה הסתיימה - הצג תוצאה
                _VotingResultBanner(result: votingResult)
              else if (hasVoted)
                // כבר הצבעתי - הצג את ההצבעה שלי
                _MyVoteBanner(vote: userVote!)
              else
                // הצבע עכשיו
                Row(
                  children: [
                    // 👍 בעד
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.thumb_up,
                        label: 'בעד',
                        color: Colors.green,
                        onTap: isLoading ? null : () => onVote('for'),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // 👎 נגד
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.thumb_down,
                        label: 'נגד',
                        color: Colors.red,
                        onTap: isLoading ? null : () => onVote('against'),
                      ),
                    ),
                    const SizedBox(width: kSpacingSmall),

                    // 🤷 נמנע
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.remove,
                        label: 'נמנע',
                        color: Colors.grey,
                        onTap: isLoading ? null : () => onVote('abstain'),
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
}

// ========================================
// Widget: בר התקדמות הצבעה
// ========================================

class _VotingProgressBar extends StatelessWidget {
  final int forCount;
  final int againstCount;
  final int abstainCount;

  const _VotingProgressBar({
    required this.forCount,
    required this.againstCount,
    required this.abstainCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = forCount + againstCount + abstainCount;

    return Column(
      children: [
        // מספרים
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '👍 $forCount',
              style: const TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '🤷 $abstainCount',
              style: const TextStyle(fontSize: kFontSizeSmall, color: Colors.grey),
            ),
            Text(
              '👎 $againstCount',
              style: const TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: kSpacingTiny),

        // בר
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: Row(
            children: [
              // בעד - ירוק
              if (forCount > 0)
                Expanded(
                  flex: forCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(4),
                        bottomLeft: const Radius.circular(4),
                        topRight: againstCount == 0 && abstainCount == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                        bottomRight: againstCount == 0 && abstainCount == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),

              // נמנע - אפור
              if (abstainCount > 0)
                Expanded(
                  flex: abstainCount,
                  child: Container(color: Colors.grey),
                ),

              // נגד - אדום
              if (againstCount > 0)
                Expanded(
                  flex: againstCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(4),
                        bottomRight: const Radius.circular(4),
                        topLeft: forCount == 0 && abstainCount == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                        bottomLeft: forCount == 0 && abstainCount == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),

              // ריק - אם אין הצבעות
              if (total == 0)
                const Expanded(
                  child: SizedBox(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================================
// Widget: כפתור הצבעה
// ========================================

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _VoteButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: kFontSizeTiny,
                  color: color,
                  fontWeight: FontWeight.bold,
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
// Widget: באנר תוצאה
// ========================================

class _VotingResultBanner extends StatelessWidget {
  final String result;

  const _VotingResultBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;
    Color color;

    switch (result) {
      case 'for':
        icon = Icons.check_circle;
        text = 'אושר! ✓';
        color = Colors.green;
        break;
      case 'against':
        icon = Icons.cancel;
        text = 'נדחה ✗';
        color = Colors.red;
        break;
      case 'tie':
        icon = Icons.balance;
        text = 'תיקו - ממתין להכרעת בעלים';
        color = Colors.orange;
        break;
      default:
        icon = Icons.pending;
        text = 'ממתין';
        color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: kSpacingTiny),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Widget: באנר ההצבעה שלי
// ========================================

class _MyVoteBanner extends StatelessWidget {
  final String vote;

  const _MyVoteBanner({required this.vote});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;
    Color color;

    switch (vote) {
      case 'for':
        icon = Icons.thumb_up;
        text = 'הצבעת בעד 👍';
        color = Colors.green;
        break;
      case 'against':
        icon = Icons.thumb_down;
        text = 'הצבעת נגד 👎';
        color = Colors.red;
        break;
      default:
        icon = Icons.remove;
        text = 'הצבעת נמנע 🤷';
        color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: kSpacingTiny),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            Icons.how_to_vote_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אין הצבעות פתוחות',
            style: TextStyle(
              fontSize: kFontSizeMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'הוסף פריטים להצבעה כדי להתחיל',
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
