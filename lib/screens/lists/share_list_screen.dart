import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list.dart';
import '../../models/shared_user.dart';
import '../../models/enums/user_role.dart';
import '../../providers/shared_users_provider.dart';
import '../../providers/user_context.dart';
import '../../core/ui_constants.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/notebook_background.dart';

/// מסך לניהול שיתוף רשימה
class ShareListScreen extends StatefulWidget {
  final ShoppingList list;

  const ShareListScreen({
    super.key,
    required this.list,
  });

  @override
  State<ShareListScreen> createState() => _ShareListScreenState();
}

class _ShareListScreenState extends State<ShareListScreen> {
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.editor;

  @override
  void initState() {
    super.initState();
    // טען את המשתמשים המשותפים
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SharedUsersProvider>();
      provider.loadSharedUsers(widget.list.sharedUsers);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userContext = context.read<UserContext>();
    final isOwner = widget.list.isCurrentUserOwner;

    return Scaffold(
      backgroundColor: kPaperBackground,
      body: NotebookBackground(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'שיתוף רשימה',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(kSpacingMedium),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // כותרת הרשימה
                  StickyNote(
                    color: kStickyYellow,
                    rotation: -0.01,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.list.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          '${widget.list.sharedUsers.length} משתמשים',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: kSpacingLarge),

                  // הוספת משתמש (רק לבעלים)
                  if (isOwner) ...[
                    StickyNote(
                      color: kStickyCyan,
                      rotation: 0.01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'הוסף משתמש',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: kSpacingMedium),
                          
                          // שדה אימייל
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'אימייל',
                              hintText: 'user@example.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: kSpacingMedium),

                          // בחירת תפקיד
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'תפקיד',
                              prefixIcon: Icon(Icons.admin_panel_settings),
                            ),
                            items: [
                              UserRole.admin,
                              UserRole.editor,
                              UserRole.viewer,
                            ].map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Row(
                                  children: [
                                    Text(role.emoji),
                                    const SizedBox(width: kSpacingSmall),
                                    Text(role.hebrewName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (role) {
                              if (role != null) {
                                setState(() => _selectedRole = role);
                              }
                            },
                          ),

                          const SizedBox(height: kSpacingMedium),

                          // כפתור הוספה
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _addUser,
                              icon: const Icon(Icons.person_add),
                              label: const Text('הוסף משתמש'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpacingLarge),
                  ],

                  // רשימת משתמשים
                  Consumer<SharedUsersProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final users = provider.sharedUsers;

                      if (users.isEmpty) {
                        return StickyNote(
                          color: kStickyPink,
                          child: Center(
                            child: Text(
                              'אין משתמשים משותפים',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'משתמשים משותפים',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: kSpacingMedium),
                          ...users.map((user) => _UserCard(
                                user: user,
                                listId: widget.list.id,
                                isOwner: isOwner,
                                currentUserId: userContext.userId!,
                              )),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addUser() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להזין אימייל')),
      );
      return;
    }

    // TODO: חיפוש משתמש לפי אימייל ב-Firestore
    // כרגע: dummy user ID
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final provider = context.read<SharedUsersProvider>();
    provider.addSharedUser(
      listId: widget.list.id,
      userId: userId,
      role: _selectedRole,
      userName: email.split('@').first,
      userEmail: email,
    );

    _emailController.clear();
    setState(() => _selectedRole = UserRole.editor);
  }
}

/// כרטיס משתמש בודד
class _UserCard extends StatelessWidget {
  final SharedUser user;
  final String listId;
  final bool isOwner;
  final String currentUserId;

  const _UserCard({
    required this.user,
    required this.listId,
    required this.isOwner,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentUser = user.userId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.role.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          user.userName ?? user.userEmail ?? 'משתמש',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Row(
          children: [
            Text(user.role.hebrewName),
            if (isCurrentUser) ...[
              const SizedBox(width: kSpacingSmall),
              Text(
                '(אתה)',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ],
        ),
        trailing: isOwner && !isCurrentUser
            ? PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz),
                        SizedBox(width: kSpacingSmall),
                        Text('שנה תפקיד'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, color: Colors.red),
                        SizedBox(width: kSpacingSmall),
                        Text('הסר משתמש', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeUser(context);
                  } else if (value == 'change_role') {
                    _showChangeRoleDialog(context);
                  }
                },
              )
            : null,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Colors.amber;
      case UserRole.admin:
        return Colors.deepPurple;
      case UserRole.editor:
        return Colors.blue;
      case UserRole.viewer:
        return Colors.grey;
    }
  }

  void _removeUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הסרת משתמש'),
        content: Text('האם להסיר את ${user.userName ?? 'משתמש זה'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () {
              final provider = context.read<SharedUsersProvider>();
              provider.removeSharedUser(
                listId: listId,
                userId: user.userId,
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('הסר'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('שינוי תפקיד'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...UserRole.values
                  .where((r) => r != UserRole.owner)
                  .map((role) => RadioListTile<UserRole>(
                        title: Row(
                          children: [
                            Text(role.emoji),
                            const SizedBox(width: kSpacingSmall),
                            Text(role.hebrewName),
                          ],
                        ),
                        value: role,
                        groupValue: selectedRole,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedRole = value);
                          }
                        },
                      )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () {
                final provider = context.read<SharedUsersProvider>();
                provider.updateUserRole(
                  listId: listId,
                  userId: user.userId,
                  newRole: selectedRole,
                );
                Navigator.pop(context);
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }
}
