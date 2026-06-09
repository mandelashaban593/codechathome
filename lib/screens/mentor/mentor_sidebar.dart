import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/home_login_screen.dart';

class MentorSidebar extends StatelessWidget {
  final Function(int) onTap;

  const MentorSidebar({
    super.key,
    required this.onTap,
  });

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeLoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget item(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Mentor Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(),

            item(Icons.dashboard, "Dashboard", 0),
            item(Icons.people, "Needs", 1),
            item(Icons.person, "Profile", 2),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }
}