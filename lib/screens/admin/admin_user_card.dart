// lib/screens/admin/admin_user_card.dart

import 'package:flutter/material.dart';
import 'admin_models.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onToggleActive;
  final ValueChanged<String> onRoleChange;

  const AdminUserCard({
    Key? key,
    required this.user,
    required this.onToggleActive,
    required this.onRoleChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')),
        title: Text(user.username),
        subtitle: Text('${user.role} • ${user.email}'
            '${user.isActive ? '' : '  (suspended)'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              onSelected: onRoleChange,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'student', child: Text('Set: Student')),
                PopupMenuItem(value: 'mentor', child: Text('Set: Mentor')),
                PopupMenuItem(value: 'admin', child: Text('Set: Admin')),
              ],
              icon: const Icon(Icons.badge_outlined),
            ),
            Switch(
              value: user.isActive,
              onChanged: (_) => onToggleActive(),
            ),
          ],
        ),
      ),
    );
  }
}
