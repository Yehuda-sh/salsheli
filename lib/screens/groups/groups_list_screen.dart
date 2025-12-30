// 📄 lib/screens/groups/groups_list_screen.dart
//
// מסך רשימת הקבוצות - מציג את כל הקבוצות שהמשתמש חבר בהן.
// כולל חיפוש, יצירת קבוצה חדשה, וכרטיסי קבוצה צבעוניים.
//
// 🔗 Related: Group, GroupsProvider, CreateGroupScreen, GroupDetailsScreen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_constants.dart';
import '../../models/group.dart';
import '../../providers/groups_provider.dart';
import '../../widgets/common/notebook_background.dart';
import '../../widgets/common/sticky_note.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    debugPrint('👥 GroupsListScreen: initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GroupsProvider>().loadGroups();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
  }

  void _openGroupDetails(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupDetailsScreen(groupId: group.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          const NotebookBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Consumer<GroupsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hasError) {
                  return _buildErrorState(cs, provider.errorMessage);
                }

                final groups = provider.groups
                    .where((g) => g.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (groups.isEmpty && _searchQuery.isEmpty) {
                  return _buildEmptyState(cs);
                }

                return Column(
                  children: [
                    // === Search Bar ===
                    Padding(
                      padding: const EdgeInsets.all(kSpacingMedium),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'חיפוש קבוצות...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.9),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(kBorderRadiusMedium),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),

                    // === Groups List ===
                    Expanded(
                      child: groups.isEmpty
                          ? Center(
                              child: Text(
                                'לא נמצאו קבוצות',
                                style:
                                    TextStyle(color: cs.onSurfaceVariant),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kSpacingMedium),
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return _GroupCard(
                                  group: group,
                                  onTap: () => _openGroupDetails(group),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _createNewGroup,
              icon: const Icon(Icons.add),
              label: const Text('קבוצה חדשה'),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'אין קבוצות עדיין',
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            'צור קבוצה חדשה כדי לשתף רשימות\nעם חברים, משפחה או עמיתים',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          FilledButton.icon(
            onPressed: _createNewGroup,
            icon: const Icon(Icons.add),
            label: const Text('צור קבוצה ראשונה'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme cs, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: cs.error,
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            'שגיאה בטעינת קבוצות',
            style: TextStyle(
              fontSize: kFontSizeLarge,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: kSpacingSmall),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: kSpacingLarge),
          FilledButton.icon(
            onPressed: () => context.read<GroupsProvider>().loadGroups(),
            icon: const Icon(Icons.refresh),
            label: const Text('נסה שוב'),
          ),
        ],
      ),
    );
  }
}

/// 📋 Group Card Widget
class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _GroupCard({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // בחר צבע לפי סוג הקבוצה
    Color cardColor;
    switch (group.type) {
      case GroupType.family:
        cardColor = kStickyPink;
      case GroupType.roommates:
        cardColor = kStickyGreen;
      case GroupType.building:
        cardColor = kStickyYellow;
      case GroupType.kindergarten:
        cardColor = kStickyOrange;
      case GroupType.friends:
        cardColor = kStickyCyan;
      case GroupType.event:
        cardColor = kStickyPurple;
      case GroupType.other:
        cardColor = kStickyCyan;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingMedium),
      child: GestureDetector(
        onTap: onTap,
        child: StickyNote(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  group.type.icon,
                  size: 28,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(width: kSpacingMedium),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: kFontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.members.length} חברים',
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: kSpacingMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            group.type.hebrewName,
                            style: TextStyle(
                              fontSize: kFontSizeTiny,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_left, // RTL
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
