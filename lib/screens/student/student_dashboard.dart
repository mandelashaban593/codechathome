import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/home_login_screen.dart';

import 'student_dashboard_controller.dart';
import 'student_models.dart';
import 'student_search_bar.dart';
import 'student_room_card.dart';
import 'student_sidebar.dart';

import '../chat/chat_screen.dart';
import '../need/create_need.dart';
import '../need/need_list.dart';
import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String username;

  const StudentDashboard({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  final controller = StudentDashboardController();
  final searchController = TextEditingController();

  bool isLoading = false;
  int page = 1;

  Timer? debounce;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future initApp() async {
    await fetchRooms();
    controller.startHeartbeat(widget.username);
    controller.startAutoRefresh(fetchRooms);
  }

  @override
  void dispose() {
    controller.stopTimers();
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  // ---------------- FETCH ----------------
  Future fetchRooms() async {

    setState(() => isLoading = true);

    try {
      await controller.loadRooms(
        widget.username,
        searchController.text,
        page,
      );

    } catch (e) {
      controller.rooms = [];
    }

    setState(() => isLoading = false);
  }

  // ---------------- SEARCH ----------------
  void onSearchChanged(String value) {

    debounce?.cancel();

    debounce = Timer(
      const Duration(milliseconds: 500),
      () => fetchRooms(),
    );
  }

  // ---------------- NAVIGATION + LOGOUT ----------------
  void onMenuTap(int index) async {

    Navigator.pop(context);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreateNeed()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NeedList()),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }

    // ================= LOGOUT =================
    if (index == 99) {

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        ),
      );

      if (confirm == true) {

        controller.stopTimers();

        await AuthService.logout();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeLoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  // ---------------- OPEN CHAT ----------------
  void openChat(StudentRoom room) {

    if (room.room_id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid room ID")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: room.room_id,
          username: widget.username,
          mentorUsername: room.mentorUsername,
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  Widget buildBody() {
    return Column(
      children: [

        StudentSearchBar(
          controller: searchController,
          onChanged: onSearchChanged,
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.rooms.length,
                  itemBuilder: (context, i) {

                    final room = controller.rooms[i];

                    return StudentRoomCard(
                      room: room,
                      onTap: () => openChat(room),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildSidebar() {
    return StudentSidebar(
      onTap: onMenuTap,
    );
  }

  // ---------------- MAIN ----------------
  @override
  Widget build(BuildContext context) {

    bool mobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: mobile
          ? AppBar(title: const Text("Student Dashboard"))
          : null,

      drawer: mobile
          ? Drawer(child: buildSidebar())
          : null,

      body: mobile
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