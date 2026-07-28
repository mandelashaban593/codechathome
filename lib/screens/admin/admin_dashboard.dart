// lib/screens/admin/admin_dashboard.dart
//
// Mirrors the structure of MentorDashboard so it's easy to maintain
// alongside it. Three views in one screen: Stats strip, Rooms tab,
// Users tab — switch with the sidebar/drawer.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/home_login_screen.dart';
import 'admin_dashboard_controller.dart';
import 'admin_models.dart';
import 'admin_room_card.dart';
import 'admin_user_card.dart';
import 'admin_search_bar.dart';
import 'admin_sidebar.dart';

class AdminDashboard extends StatefulWidget {
  final String username;

  const AdminDashboard({Key? key, required this.username}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminDashboardController controller = AdminDashboardController();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  int selectedTab = 0; // 0 = rooms, 1 = users
  Timer? debounce;
  Timer? statsRefreshTimer;

  @override
  void initState() {
    super.initState();
    initDashboard();
  }

  Future<void> initDashboard() async {
    await Future.wait([
      loadStats(),
      fetchRooms(),
    ]);
    // Keep the stats strip fresh without a manual refresh.
    statsRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadStats(),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    statsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeLoginScreen()),
      (route) => false,
    );
  }

  Future<void> loadStats() async {
    try {
      await controller.loadStats();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('STATS LOAD ERROR: $e');
    }
  }

  Future<void> fetchRooms() async {
    setState(() => isLoading = true);
    try {
      await controller.loadRooms(search: searchController.text);
    } catch (e) {
      debugPrint('ROOM FETCH ERROR: $e');
      controller.rooms = [];
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      await controller.loadUsers(search: searchController.text);
    } catch (e) {
      debugPrint('USER FETCH ERROR: $e');
      controller.users = [];
    }
    if (mounted) setState(() => isLoading = false);
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      selectedTab == 0 ? fetchRooms() : fetchUsers();
    });
  }

  void onSidebarTap(int index) {
    Navigator.pop(context); // close drawer on mobile
    if (index == 0) {
      setState(() => selectedTab = 0);
      fetchRooms();
    } else if (index == 1) {
      setState(() => selectedTab = 1);
      fetchUsers();
    } else if (index == 2) {
      // Hook up to your existing ProfileScreen if desired.
    } else if (index == 3) {
      logout();
    }
  }

  Future<void> toggleUserActive(AdminUser user) async {
    try {
      await controller.setUserActive(user.id, !user.isActive);
      await fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Future<void> changeUserRole(AdminUser user, String role) async {
    try {
      await controller.changeUserRole(user.id, role);
      await fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role change failed: $e')),
      );
    }
  }

  // =====================================================
  // STATS STRIP
  // =====================================================
  Widget buildStatsStrip() {
    final AdminStats s = controller.stats;
    Widget stat(String label, int value, {Color? color}) => Expanded(
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          stat('Rooms', s.totalRooms),
          stat('Today', s.roomsToday),
          stat('Flagged', s.flaggedRooms, color: Colors.redAccent),
          stat('Mentors online', s.onlineMentors, color: Colors.green),
          stat('Students online', s.onlineStudents, color: Colors.green),
          stat('Users', s.totalUsers),
        ],
      ),
    );
  }

  // =====================================================
  // BODY
  // =====================================================
  Widget buildBody() {
    return Column(
      children: [
        buildStatsStrip(),
        const Divider(height: 1),
        AdminSearchBar(
          controller: searchController,
          onChanged: onSearchChanged,
          hintText: selectedTab == 0
              ? 'Search rooms by username...'
              : 'Search users by username...',
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : selectedTab == 0
                  ? ListView.builder(
                      itemCount: controller.rooms.length,
                      itemBuilder: (context, index) {
                        final room = controller.rooms[index];
                        return AdminRoomCard(
                          room: room,
                          onTap: () => openRoomDetail(room),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: controller.users.length,
                      itemBuilder: (context, index) {
                        final user = controller.users[index];
                        return AdminUserCard(
                          user: user,
                          onToggleActive: () => toggleUserActive(user),
                          onRoleChange: (role) => changeUserRole(user, role),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void openRoomDetail(AdminRoom room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FutureBuilder<Map<String, dynamic>>(
        future: controller.loadRoomDetail(room.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final messages = snapshot.data!['messages'] as List;
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            builder: (context, scrollController) => ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                return ListTile(
                  dense: true,
                  title: Text('${m['username']}: ${m['message'] ?? ''}'),
                  subtitle: Text(m['timestamp'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () async {
                      await controller.deleteMessage(m['id']);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildSidebar() => AdminSidebar(
        onTap: onSidebarTap,
        selectedIndex: selectedTab,
      );

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text('Admin Dashboard')) : null,
      drawer: isMobile ? Drawer(child: buildSidebar()) : null,
      body: isMobile
          ? buildBody()
          : Row(
              children: [
                SizedBox(width: 250, child: buildSidebar()),
                Expanded(child: buildBody()),
              ],
            ),
    );
  }
}
