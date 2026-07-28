// lib/screens/admin/admin_sidebar.dart

import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final void Function(int index) onTap;
  final int selectedIndex;

  const AdminSidebar({
    Key? key,
    required this.onTap,
    this.selectedIndex = 0,
  }) : super(key: key);

  static const List<String> _labels = ['Rooms', 'Users', 'Profile', 'Logout'];
  static const List<IconData> _icons = [
    Icons.forum_outlined,
    Icons.people_outline,
    Icons.person_outline,
    Icons.logout,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Admin Panel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _labels.length; i++)
            ListTile(
              leading: Icon(_icons[i]),
              title: Text(_labels[i]),
              selected: i == selectedIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}
