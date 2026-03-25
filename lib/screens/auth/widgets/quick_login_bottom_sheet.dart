import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/ui_constants.dart';

class QuickLoginBottomSheet extends StatelessWidget {
  final List<Map<String, String>> users;
  final void Function(String email) onUserSelected;

  const QuickLoginBottomSheet({
    super.key,
    required this.users,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final groupedUsers = <String, List<Map<String, String>>>{};
    for (final user in users) {
      final group = user['group'] ?? 'אחר';
      groupedUsers.putIfAbsent(group, () => []).add(user);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kGlassBlurMedium, sigmaY: kGlassBlurMedium),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusLarge)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: Icon(Icons.bug_report, color: cs.tertiary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'התחברות מהירה - DEV',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'בחר משתמש דמו להתחברות',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: groupedUsers.length,
                  itemBuilder: (context, index) {
                    final group = groupedUsers.keys.elementAt(index);
                    final groupUsers = groupedUsers[group]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            group,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...groupUsers.map((user) => _buildUserTile(context, user)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, Map<String, String> user) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final roleColor = switch (user['role']) {
      'Owner' => cs.tertiary,
      'Admin' => cs.primary,
      'Editor' => cs.primary,
      _ => cs.outline,
    };

    final firstChar = user['name']!.characters.firstOrNull ?? '?';

    return ListTile(
      onTap: () => onUserSelected(user['email']!),
      leading: CircleAvatar(
        backgroundColor: roleColor.withValues(alpha: 0.2),
        child: Text(
          firstChar,
          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        user['name']!,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user['email']!,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Text(
          user['role']!,
          style: TextStyle(
            fontSize: kFontSizeSmall,
            fontWeight: FontWeight.w600,
            color: roleColor,
          ),
        ),
      ),
    );
  }
}
