// 📄 lib/screens/home/dashboard/widgets/household_activity_feed.dart
//
// פיד פעילות הבית — מציג פעולות אחרונות של חברי הבית:
// - קניות שהסתיימו (מקבלות)
// - רשימות שנוצרו/עודכנו
//
// Version: 1.0 (12/03/2026)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui_constants.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../models/receipt.dart';
import '../../../../models/shopping_list.dart';
import '../../../../providers/receipt_provider.dart';
import '../../../../providers/shopping_lists_provider.dart';
import '../../../../providers/user_context.dart';
import '../../../history/shopping_history_screen.dart';

/// פיד פעילות הבית
class HouseholdActivityFeed extends StatefulWidget {
  /// Callback למעבר לטאב היסטוריה (במקום push חדש)
  final VoidCallback? onSeeAllHistory;
  
  const HouseholdActivityFeed({super.key, this.onSeeAllHistory});

  @override
  State<HouseholdActivityFeed> createState() => _HouseholdActivityFeedState();
}

class _HouseholdActivityFeedState extends State<HouseholdActivityFeed> {
  /// מפת userId → name מחברי הבית
  Map<String, String> _memberNames = {};
  bool _membersLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_membersLoaded) {
      _membersLoaded = true;
      _loadMemberNames();
    }
  }

  Future<void> _loadMemberNames() async {
    final householdId = context.read<UserContext>().user?.householdId;
    if (householdId == null || householdId.isEmpty) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('members')
          .get();
      
      if (!mounted) return;
      setState(() {
        _memberNames = {
          for (final doc in snap.docs)
            doc.id: (doc.data()['name'] as String?) ?? '',
        };
      });
    } catch (_) {
      // Silent fail — fallback to 'חבר/ת בית'
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipts = context.watch<ReceiptProvider>().receipts;
    final lists = context.watch<ShoppingListsProvider>().lists;
    final userContext = context.watch<UserContext>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // בנה רשימת פעילויות
    final activities = _buildActivities(receipts, lists, userContext);

    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // כותרת — ממורכזת
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icon_home_activity.webp', width: 36, height: 36),
            const SizedBox(width: 8),
            Text(
              'מה חדש בבית',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: widget.onSeeAllHistory ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShoppingHistoryScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.homeDashboard.seeAll,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    size: 16,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),

        // כרטיסי פעילות
        Card(
          elevation: 0,
          color: cs.surface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
            side: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < activities.length; i++) ...[
                activities[i],
                if (i < activities.length - 1)
                  Divider(height: 1, indent: 56, endIndent: kSpacingMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// בונה רשימת פעילויות ממיון לפי תאריך
  List<Widget> _buildActivities(
    List<Receipt> receipts,
    List<ShoppingList> lists,
    UserContext userContext,
  ) {
    final activities = <_ActivityData>[];
    final currentUserId = userContext.userId;
    

    // 1. קניות שהסתיימו (מקבלות) — עד 3 אחרונות
    final sortedReceipts = List<Receipt>.from(receipts)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final receipt in sortedReceipts.take(3)) {
      // שם הקונה
      String personName;
      if (receipt.createdBy == currentUserId) {
        personName = 'את/ה';
      } else {
        // נסה למצוא שם מ-shared users
        personName = _findUserName(receipt.createdBy, lists) ?? 'חבר/ת בית';
      }

      // אימוגי מוצרים (עד 5)
      final itemEmojis = receipt.items
          .take(5)
          .map((item) => _getItemEmoji(item.category))
          .toList();

      activities.add(_ActivityData(
        type: _ActivityType.completedShopping,
        personName: personName,
        isMe: receipt.createdBy == currentUserId,
        description: receipt.storeName,
        itemCount: receipt.items.length,
        itemEmojis: itemEmojis,
        date: receipt.date,
        receiptId: receipt.id,
      ));
    }

    // מיון לפי תאריך (חדש קודם)
    activities.sort((a, b) => b.date.compareTo(a.date));

    // מגביל ל-3 פעילויות
    return activities.take(3).map((a) => _ActivityTile(activity: a)).toList();
  }

  /// מחפש שם משתמש — קודם מחברי הבית, אח"כ מ-shared users ברשימות
  String? _findUserName(String? userId, List<ShoppingList> lists) {
    if (userId == null) return null;
    // 1. חפש בחברי הבית
    final memberName = _memberNames[userId];
    if (memberName != null && memberName.isNotEmpty) return memberName;
    // 2. חפש ב-shared users של רשימות
    for (final list in lists) {
      final user = list.sharedUsers[userId];
      if (user?.userName != null) return user!.userName;
    }
    return null;
  }

  /// מחזיר אימוגי לפי קטגוריה
  String _getItemEmoji(String? category) {
    if (category == null) return '📦';
    final lower = category.toLowerCase();
    if (lower.contains('dairy') || lower.contains('חלב')) return '🥛';
    if (lower.contains('bread') || lower.contains('לחם') || lower.contains('baked')) return '🍞';
    if (lower.contains('egg') || lower.contains('ביצ')) return '🥚';
    if (lower.contains('fruit') || lower.contains('פרי') || lower.contains('ירק')) return '🍎';
    if (lower.contains('meat') || lower.contains('בשר') || lower.contains('עוף')) return '🥩';
    if (lower.contains('fish') || lower.contains('דג')) return '🐟';
    if (lower.contains('drink') || lower.contains('שתי') || lower.contains('beverage')) return '🥤';
    if (lower.contains('snack') || lower.contains('חטיף')) return '🍿';
    if (lower.contains('clean') || lower.contains('ניקיון')) return '🧹';
    if (lower.contains('hygiene') || lower.contains('טיפוח')) return '🧴';
    if (lower.contains('frozen') || lower.contains('קפוא')) return '🧊';
    if (lower.contains('spice') || lower.contains('תבלין')) return '🧂';
    if (lower.contains('pasta') || lower.contains('פסטה') || lower.contains('grain')) return '🍝';
    if (lower.contains('sauce') || lower.contains('רוטב')) return '🫙';
    if (lower.contains('coffee') || lower.contains('קפה') || lower.contains('tea')) return '☕';
    return '📦';
  }
}

// ============================================
// Data Models
// ============================================

enum _ActivityType {
  completedShopping,
}

class _ActivityData {
  final _ActivityType type;
  final String personName;
  final bool isMe;
  final String description;
  final int itemCount;
  final List<String> itemEmojis;
  final DateTime date;
  final String? receiptId;

  const _ActivityData({
    required this.type,
    required this.personName,
    required this.isMe,
    required this.description,
    required this.itemCount,
    required this.itemEmojis,
    required this.date,
    this.receiptId,
  });
}

// ============================================
// Activity Tile Widget
// ============================================

class _ActivityTile extends StatelessWidget {
  final _ActivityData activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: () {
        if (activity.receiptId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShoppingHistoryScreen(
                initialReceiptId: activity.receiptId,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // אווטר
            _buildAvatar(cs, theme),
            const SizedBox(width: kSpacingMedium),

            // תוכן
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // שורה 1: שם + זמן
                  Row(
                    children: [
                      Text(
                        activity.isMe ? '🧑 את/ה' : '👤 ${activity.personName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${_formatRelativeDate(activity.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // שורה 2: פעולה
                  Text(
                    '✅ סיים קנייה ב${activity.description}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // שורה 3: אימוגי מוצרים
                  Row(
                    children: [
                      Text(
                        activity.itemEmojis.join(''),
                        style: const TextStyle(fontSize: kFontSizeBody),
                      ),
                      if (activity.itemCount > activity.itemEmojis.length) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+${activity.itemCount - activity.itemEmojis.length} פריטים',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // חץ
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 18,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, ThemeData theme) {
    final initial = activity.isMe
        ? '🧑'
        : activity.personName.isNotEmpty
            ? activity.personName[0]
            : '?';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: activity.isMe
            ? cs.primaryContainer
            : cs.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: activity.isMe
            ? Text(initial, style: const TextStyle(fontSize: kFontSizeMedium))
            : Text(
                initial,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSecondaryContainer,
                ),
              ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'לפני ${diff.inMinutes} דק\'';
    if (diff.inHours < 24) return 'לפני ${diff.inHours} שע\'';
    if (diff.inDays == 0) return 'היום';
    if (diff.inDays == 1) return 'אתמול';
    if (diff.inDays < 7) return 'לפני ${diff.inDays} ימים';
    return '${date.day}/${date.month}';
  }
}
