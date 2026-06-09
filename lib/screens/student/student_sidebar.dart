import 'package:flutter/material.dart';

class StudentSidebar extends StatelessWidget {

  final Function(int) onTap;

  const StudentSidebar({
    super.key,
    required this.onTap,
  });

  Widget item(
    IconData icon,
    String title,
    int index,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: () => onTap(index),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.blue.shade900,

      child: SafeArea(
        child: ListView(
          children: [

            const SizedBox(height: 40),

            const Text(
              "Student Panel",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(color: Colors.white54),

            item(
              Icons.dashboard,
              "Dashboard",
              0,
            ),

            item(
              Icons.add,
              "Create Need",
              1,
            ),

            item(
              Icons.list,
              "My Needs",
              2,
            ),

            item(
              Icons.person,
              "Profile",
              3,
            ),

            const Divider(color: Colors.white54),

            item(
              Icons.logout,
              "Logout",
              99,
            ),
          ],
        ),
      ),
    );
  }
}