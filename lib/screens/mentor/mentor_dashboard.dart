import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/home_login_screen.dart';

import 'mentor_dashboard_controller.dart';
import 'mentor_models.dart';
import 'mentor_room_card.dart';
import 'mentor_search_bar.dart';
import 'mentor_sidebar.dart';

import '../chat/chat_screen.dart';
import '../need/need_list.dart';
import '../profile/profile_screen.dart';

class MentorDashboard extends StatefulWidget {
  final String username;

  const MentorDashboard({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<MentorDashboard> createState() =>
      _MentorDashboardState();
}

class _MentorDashboardState
    extends State<MentorDashboard> {

  final MentorDashboardController controller =
      MentorDashboardController();

  final TextEditingController searchController =
      TextEditingController();

  bool isLoading = false;
  int page = 1;

  Timer? debounce;

  @override
  void initState() {
    super.initState();
    initDashboard();
  }

  Future<void> initDashboard() async {
    print("=================================");
    print("MENTOR DASHBOARD STARTED");
    print("USERNAME: ${widget.username}");
    print("=================================");

    await fetchRooms();

    controller.startHeartbeat(widget.username);

    controller.startAutoRefresh(() {
      fetchRooms();
    });
  }

  @override
  void dispose() {
    controller.stopHeartbeat();
    controller.stopAutoRefresh();

    searchController.dispose();
    debounce?.cancel();

    super.dispose();
  }

  // =====================================================
  // LOGOUT FUNCTION (NEW)
  // =====================================================
  Future<void> logout() async {
    await AuthService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeLoginScreen(),
      ),
      (route) => false,
    );
  }

  // =====================================================
  // FETCH ROOMS
  // =====================================================
  Future<void> fetchRooms() async {
    setState(() => isLoading = true);

    try {
      await controller.loadRooms(
        widget.username,
        searchController.text,
        page,
      );

      print("=================================");
      print("MENTOR ROOMS LOADED");
      print("TOTAL ROOMS: ${controller.rooms.length}");

      for (final room in controller.rooms) {
        print(
          "ROOM ID: ${room.room_id} "
          "STUDENT: ${room.studentUsername}",
        );
      }

      print("=================================");

    } catch (e) {
      print("FETCH ROOM ERROR: $e");
      controller.rooms = [];
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // =====================================================
  // SEARCH
  // =====================================================
  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }

    debounce = Timer(
      const Duration(milliseconds: 500),
      () => fetchRooms(),
    );
  }

  // =====================================================
  // MENU HANDLER (UPDATED WITH LOGOUT)
  // =====================================================
  void onMenuTap(int index) {
    Navigator.pop(context);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NeedList()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }

    // 🔥 LOGOUT
    if (index == 3) {
      logout();
    }
  }

  // =====================================================
  // OPEN CHAT
  // =====================================================
  void openChat(MentorRoom room) {
    print("=================================");
    print("MENTOR ROOM CLICKED");
    print("ROOM ID: ${room.room_id}");
    print("STUDENT: ${room.studentUsername}");
    print("MENTOR: ${widget.username}");
    print("=================================");

    if (room.room_id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid room ID received from server"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: room.room_id,
          username: widget.username,
          mentorUsername: room.studentUsername,
        ),
      ),
    );
  }

  // =====================================================
  // BODY
  // =====================================================
  Widget buildBody() {
    return Column(
      children: [
        MentorSearchBar(
          controller: searchController,
          onChanged: onSearchChanged,
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.rooms.length,
                  itemBuilder: (context, index) {
                    final room = controller.rooms[index];

                    return MentorRoomCard(
                      room: room,
                      onTap: () => openChat(room),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =====================================================
  // SIDEBAR
  // =====================================================
  Widget buildSidebar() {
    return MentorSidebar(
      onTap: onMenuTap,
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: const Text("Mentor Dashboard"))
          : null,

      drawer: isMobile
          ? Drawer(child: buildSidebar())
          : null,

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